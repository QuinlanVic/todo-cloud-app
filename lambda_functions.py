import json
import boto3
from botocore.exceptions import ClientError
import uuid

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

# Set your DynamoDB table name and S3 bucket name
TABLE_NAME = 'Todos'
BUCKET_NAME = 'my-todo-app-bucket'

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
        if 'image' in data:  # Ensure 'image' is in the parsed body, not event directly
            image_content = data['image']  # Expecting base64 encoded image or binary
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

def update_todo_handler(event, context):
    try:
        data = json.loads(event['body'])
        todo_id = event['pathParameters']['id']
        
        # Ensure there are fields to update
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
        
        # Remove trailing comma and check if there's anything to update
        update_expression = update_expression.rstrip(', ')
        if not expression_attribute_values:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'No valid fields provided for update'})
            }
        
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
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Unexpected error: {str(e)}'})
        }


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
