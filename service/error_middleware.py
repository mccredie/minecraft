
import logging

logger = logging.getLogger(__name__)

class HttpError(Exception):
    def __init__(self, error, message, code):
        self.error = error
        self.message = message
        self.code = code


def handle_errors(fn):
    def wrapper(event, context):
        try:
            return fn(event, context)
        except HttpError as e:
            return {
                "isBase64Encoded": False,
                "statusCode": e.code,
                "headers": {},
                "body": {
                    "error": e.error,
                    "message": e.message,
                    "code": e.code,
                },
            }
        except:
            logger.exception("Unhandled Exception")
            return {
                "isBase64Encoded": False,
                "statusCode": 500,
                "headers": {},
                "body": {
                    "error": "Unknown Error",
                    "message": "Something went wrong",
                    "code": 500,
                }
            }

    return wrapper
