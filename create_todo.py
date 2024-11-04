import json
import boto3
from botocore.exceptions import ClientError
import uuid

# Initialize the DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Todos')  # Replace 'Todos' with your DynamoDB table name

def create_todo_handler(event, context):
    try:
        data = json.loads(event['body'])
        todo_id = str(uuid.uuid4())  # Generate a unique ID for the todo
        todo_item = {
            'id': todo_id,
            'task': data['task'],
            'status': data.get('status', 'pending')  # Default status to 'pending'
        }
        table.put_item(Item=todo_item)
        
        return {
            'statusCode': 201,
            'body': json.dumps({'message': 'Todo created successfully!', 'todo_id': todo_id})
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
