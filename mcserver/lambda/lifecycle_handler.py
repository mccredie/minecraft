import os
import json

import boto3


as_client = boto3.client('autoscaling')
ec2 = boto3.resource("ec2")
r53_client = boto3.client('route53')

HOSTED_ZONE_ID = os.environ["HOSTED_ZONE_ID"]
DOMAIN_NAME = os.environ["DOMAIN_NAME"]


def handler(event, context):
    instance = ec2.Instance(event["detail"]["EC2InstanceId"])
    if event["detail"]["LifecycleTransition"] == "autoscaling:EC2_INSTANCE_LAUNCHING":
        update_record(HOSTED_ZONE_ID, 'CREATE', DOMAIN_NAME, instance.public_ip_address)
    elif event["detail"]["LifecycleTransition"] == "autoscaling:EC2_INSTANCE_TERMINATING":
        update_record(HOSTED_ZONE_ID, 'DELETE', DOMAIN_NAME, instance.public_ip_address)

    return as_client.complete_lifecycle_action(
        LifecycleHookName=event["detail"]["LifecycleHookName"],
        AutoScalingGroupName=event["detail"]["AutoScalingGroupName"],
        LifecycleActionToken=event["detail"]["LifecycleActionToken"],
        LifecycleActionResult='CONTINUE',
        InstanceId=event["detail"]["EC2InstanceId"],
    )


def update_record(hosted_zone, action, domain, ip):
    return r53_client.change_resource_record_sets(
        HostedZoneId=hosted_zone,
        ChangeBatch={
            'Comment': 'Create Domain for MC Server',
            'Changes': [
                {
                    'Action': action,
                    'ResourceRecordSet': {
                        'Name': domain,
                        'Type': 'A',
                        'TTL': 5,
                        'ResourceRecords': [
                            {
                                'Value': ip,
                            },
                        ],
                    }
                },
            ]
        }
    )
