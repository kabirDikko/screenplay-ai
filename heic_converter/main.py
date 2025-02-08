import os
import boto3
from pillow_heif import register_heif_opener
from PIL import Image
import io

# Register HEIF opener with Pillow
register_heif_opener()

s3_client = boto3.client('s3')

def handler(event, context):
    """
    Lambda function to convert HEIC images in an S3 bucket to JPEG format,
    replacing the original files
    """
    try:
        source_bucket = os.environ['SOURCE_BUCKET']
        converted_count = 0
        
        paginator = s3_client.get_paginator('list_objects_v2')
        
        for page in paginator.paginate(Bucket=source_bucket):
            if 'Contents' not in page:
                continue
                
            for obj in page['Contents']:
                key = obj['Key']
                
                # Check if file is HEIC
                if not key.lower().endswith(('.heic', '.heif')):
                    continue
                
                print(f"Converting {key}")
                
                # Download HEIC file
                response = s3_client.get_object(Bucket=source_bucket, Key=key)
                image_data = response['Body'].read()
                
                # Convert HEIC to JPEG
                with io.BytesIO(image_data) as heic_bytes:
                    # Open and convert image
                    image = Image.open(heic_bytes)
                    
                    # Create buffer for JPEG
                    jpeg_buffer = io.BytesIO()
                    
                    # Save as JPEG with original quality
                    image.save(jpeg_buffer, format='JPEG', quality=95)
                    jpeg_buffer.seek(0)
                    
                    # Upload JPEG to the same location but with .jpg extension
                    new_key = os.path.splitext(key)[0] + '.jpg'
                    
                    # Upload the JPEG version
                    s3_client.put_object(
                        Bucket=source_bucket,
                        Key=new_key,
                        Body=jpeg_buffer.getvalue(),
                        ContentType='image/jpeg'
                    )
                    
                    # Delete the original HEIC file
                    s3_client.delete_object(Bucket=source_bucket, Key=key)
                    
                print(f"Successfully converted and replaced {key} with {new_key}")
                converted_count += 1
        
        message = f"Successfully processed {converted_count} HEIC images"
        print(message)
        return {
            'statusCode': 200,
            'body': message
        }
        
    except Exception as e:
        error_message = f"Error: {str(e)}"
        print(error_message)
        return {
            'statusCode': 500,
            'body': error_message
        } 