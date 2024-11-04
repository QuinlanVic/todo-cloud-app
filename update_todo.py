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

def update_todo_handler(event, context):
    try:
        data = json.loads(event['body'])
        todo_id = event['pathParameters']['id']
        
        # Update only the fields that are provided in the request
        update_expression = "SET "
        expression_attribute_values = {}
        if 'task' in data:
            update_expression += "task = :task, "
            expression_attribute_values[':task'] = data['task']
        if 'description' in data:
            update_expression += "description=:description, "
            expression_attribute_values[':description'] = data['description']
        if 'status' in data:
            update_expression += "status = :status, "
            expression_attribute_values[':status'] = data['status']
        if 'image_url' in data:
            update_expression += "image_url=:image_url"
            expression_attribute_values[':image_url'] = data['image_url']
        
        # Remove trailing comma
        update_expression = update_expression.rstrip(', ')
        
        # Update the item
        response = table.update_item(
            Key={'id': todo_id},
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_attribute_values,
            ReturnValues="UPDATED_NEW"
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Todo updated successfully!', 'updatedAttributes': response['Attributes']})
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
