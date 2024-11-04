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

def delete_todo_handler(event, context):
    try:
        todo_id = event['pathParameters']['id']
        # Optional: Delete associated image from S3 if image_url exists
        response = table.get_item(Key={'id': todo_id})
        item = response.get('Item', None)

        if item and 'image_url' in item:
            image_key = item['image_url'].split("/")[-1]  # Extract image key from URL
            s3.delete_object(Bucket=BUCKET_NAME, Key=image_key)
        
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
