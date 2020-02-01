
def enable_cors(fn):
    def wrapper(event, context):
        response = fn(event, context)
        headers = { 'Access-Control-Allow-Origin': '*' }

        try:
            headers.update(response['headers'])
        except KeyError:
            pass

        response['headers'] = headers

        return response
    return wrapper
