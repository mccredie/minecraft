import json

def json_body(fn):
    def wrapper(event, context):
        response = fn(event, context)
        headers = {'Content-Type': 'application/json'}

        try:
            headers.update(response['headers'])
        except KeyError:
            pass

        response['body'] = json.dumps(response.get('body', {}))
        response['headers'] = headers

        return response
    return wrapper
