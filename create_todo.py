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

def upload_image_to_s3(image_content, image_name):
    try:
        # Generate a unique image name using UUID to avoid conflicts
        unique_image_name = f"{uuid.uuid4()}_{image_name}"
        s3.put_object(Bucket=BUCKET_NAME, Key=unique_image_name, Body=image_content)
        image_url = f"https://{BUCKET_NAME}.s3.amazonaws.com/{unique_image_name}"
        return image_url
    except ClientError as e:
        print(f"Error uploading image: {e}")
        return None


def create_todo_handler(event, context):
    try:
        data = json.loads(event['body'])
        todo_id = str(uuid.uuid4())  # Generate a unique ID for the todo
        image_url = None 

        # If an image is provided, upload it to S3
        if 'image' in event:
            image_content = event['image']  # Should be a binary content of the image
            image_name = f"{todo_id}.jpg"  # Assuming JPG; adjust as needed
            image_url = upload_image_to_s3(image_content, image_name)

        todo_item = {
            'id': todo_id,
            'task': data['task'],
            'description': data['description'],
            'status': data.get('status', 'pending'),  # Default status to 'pending'
            'image_url': image_url
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
