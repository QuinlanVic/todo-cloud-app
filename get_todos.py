import json
import boto3
from botocore.exceptions import ClientError
import uuid

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

# Set your DynamoDB table name and S3 bucket name
TABLE_NAME = 'Todos'
BUCKET_NAME = 'your-s3-bucket-name'

table = dynamodb.Table(TABLE_NAME)

def get_todos_handler(event, context):
    try:
        # Check if a specific todo_id is passed in the query string
        todo_id = event['queryStringParameters'].get('id') if event.get('queryStringParameters') else None
        
        if todo_id:
            # Retrieve a single todo item by id
            response = table.get_item(Key={'id': todo_id})
            todo = response.get('Item')
            if not todo:
                return {
                    'statusCode': 404,
                    'body': json.dumps({'error': 'Todo not found'})
                }
            return {
                'statusCode': 200,
                'body': json.dumps(todo)
            }
        else:
            # Retrieve all todo items
            response = table.scan()
            todos = response.get('Items', [])
            return {
                'statusCode': 200,
                'body': json.dumps(todos)
            }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
