import os
import re
import json
import logging

import boto3

from app_router import router
from auth_middleware import HttpError

LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')

AUTOSCALING_GROUP_NAME = os.environ['AUTOSCALING_GROUP_NAME']
SERVER_DOMAIN = os.environ['SERVER_DOMAIN']

# Root Logger
logger = logging.getLogger(__name__)
logger.setLevel(LOG_LEVEL)

autoscaling = boto3.client("autoscaling")

@router.route(re.compile(r'^/api/servers/survival/status').match)
def app(event, context):
    permissions = event['auth']['permissions']
    if event['httpMethod'] == 'GET':
        if 'servers:read' not in permissions:
            raise HttpError(
                "permission_denied",
                "You do not have access to this resource",
                403)
        status = get_autoscaling_group_status(AUTOSCALING_GROUP_NAME)

        return {
            'statusCode': 200,
            'body': status,
        }
    elif event['httpMethod'] == 'PUT':
        if 'servers:write' not in permissions:
            raise HttpError(
                "permission_denied",
                "You do not have access to this resource",
                403)
        body = json.loads(event['body'])
        capacity = 0
        if body['active']:
            capacity = 1
        autoscaling.set_desired_capacity(
            AutoScalingGroupName=AUTOSCALING_GROUP_NAME,
            DesiredCapacity=capacity,
        )
        status = get_autoscaling_group_status(AUTOSCALING_GROUP_NAME)
        return {
            'statusCode': 200,
            'body': status,
        }
    else:
        return {
            "isBase64Encoded": False,
            "statusCode": 405,
            "headers": {},
            "body": {
                "error": "Method Not Allowed",
                "message": "Method not allowed for resource",
                "code": 405,
            }
        }

def get_autoscaling_group_status(group_name):
    response = autoscaling.describe_auto_scaling_groups(
        AutoScalingGroupNames=[group_name],
    )
    desc = response['AutoScalingGroups'][0]
    capacity = desc['DesiredCapacity']
    instances = desc['Instances']
    if instances:
        state = instances[0]['LifecycleState']
    else:
        state = None

    return {
        "active": capacity == 1,
        "state": state,
        "domain": SERVER_DOMAIN,
    }


