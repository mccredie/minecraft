import json
import logging


def log_events(logger):
    def wrap(fn):
        def wrapper(event, context):
            logger.debug("event %s", json.dumps(event))
            resp = fn(event, context)
            logger.debug("response %s", json.dumps(resp))
            return resp
        return wrapper
    return wrap
