import json
import boto3

def lambda_handler(event,context):
    userId = event['UserId']
    user = event['User']

    dynamodb = boto3.resource('dynamodb')

    table = dynamodb.Table('SampleTable')

    response = table.put_item(
       Item={
            'userId' : userId,
            'user': user
        }
    )
    return response