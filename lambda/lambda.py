import json
import boto3

def lambda_handler(event,context):
    name = event['Name']
    surname = event['Surname']

    dynamodb = boto3.resource('dynamodb')

    table = dynamodb.Table('SampleTable')

    response = table.put_item(
       Item={
            'name': name,
            'surname': surname
        }
    )
    return response