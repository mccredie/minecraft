
import logging

logger = logging.getLogger(__name__)
from error_middleware import HttpError


class Router:
    decorators = ()
    def __init__(self):
        self.routes = []

    def route(self, matcher):
        def _reg(fn):
            self.routes.append((matcher, fn))
            return fn
        return _reg


    def handler(self, event, context):
        logger.debug("Handling path %r", event['path'])
        handler = self.default_handler
        for matcher, path_handler in self.routes:
            if match := matcher(event['path']):
                logger.debug("Match found for path %r", event['path'])
                handler = path_handler
                break

        handler = _apply_decorators(handler, self.decorators)
        return handler(event, context)

    def default_handler(self, event, context):
        logger.info("Unable to match a path")
        raise HttpError(
            "NotFound",
            "The requested resouce does not exist",
            404,
        )


def _apply_decorators(fn, decorators):
    for decorator in reversed(decorators):
        fn = decorator(fn)
    return fn
