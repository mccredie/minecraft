
import logging

import requests
from jose import jwt

from error_middleware import HttpError


def require_auth(auth_domain, audience):
    def wrap(fn):
        def wrapper(event, context):
            headers = event['headers']
            if headers is None:
                headers = {}
            try:
                auth_header = headers['Authorization']
            except KeyError:
                raise HttpError(
                    'Authorization',
                    'Missing Authorization Header',
                    401)

            parts = auth_header.split()

            if parts[0].lower() != 'bearer':
                raise HttpError(
                    'Authorization',
                    'Invalid Authorization Header',
                    401)
            elif len(parts) == 1:
                raise HttpError(
                    'Authorization',
                    'Token not found',
                    401)
            elif len(parts) > 2:
                raise HttpError(
                    'Authorization',
                    'Invalid header',
                    401)
            token = parts[1]

            jwks = requests.get(
                    "https://"+auth_domain+"/.well-known/jwks.json").json()

            try:
                unverified_header = jwt.get_unverified_header(token)
            except jwt.JWTError:
                raise HttpError(
                    'Authorization',
                    'Invalid Token',
                    401)

            rsa_key = {}
            for key in jwks["keys"]:
                if key["kid"] == unverified_header["kid"]:
                    rsa_key = {
                        "kty": key["kty"],
                        "kid": key["kid"],
                        "use": key["use"],
                        "n": key["n"],
                        "e": key["e"]}

            if rsa_key:
                try:
                    payload = jwt.decode(
                        token,
                        rsa_key,
                        algorithms=["RS256"],
                        audience=audience,
                        issuer=f"https://{auth_domain}/")
                except jwt.ExpiredSignatureError:
                    raise HttpError(
                        "token_expired",
                        "token is expired",
                        401)
                except jwt.JWTClaimsError:
                    raise HttpError(
                        "invalid_claims",
                        "incorrect claims,please check the audience and issuer",
                        401)

                return fn(
                    dict(event, auth=payload),
                    context,
                )

        return wrapper
    return wrap

