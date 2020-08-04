import os
import logging


from router import Router
from json_middleware import json_body
from cors_middleware import enable_cors
from auth_middleware import require_auth
from error_middleware import handle_errors
from event_log_middleware import log_events


LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')
AUTH_DOMAIN = os.environ['AUTH_DOMAIN']
AUTH_AUDIENCE = os.environ['AUTH_AUDIENCE']

# Root Logger
logger = logging.getLogger()
logger.setLevel(LOG_LEVEL)



router = Router()
router.decorators = [
    log_events(logger),
    enable_cors,
    json_body,
    handle_errors,
    require_auth(AUTH_DOMAIN, AUTH_AUDIENCE),
]


