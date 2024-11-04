import json
import boto3
from botocore.exceptions import ClientError
import uuid

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Todos')  # Replace 'Todos' with your DynamoDB table name

def delete_todo_handler(event, context):
    try:
        todo_id = event['pathParameters']['id']
        
        # Delete the item
        table.delete_item(Key={'id': todo_id})
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Todo deleted successfully!'})
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
