import json
import os

def lambda_handler(event, context):
    """
    Simple Lambda function handler
    """
    print(f"Event: {json.dumps(event)}")
    
    # Get environment variables
    env = os.environ.get('ENV', 'unknown')
    log_level = os.environ.get('LOG_LEVEL', 'INFO')
    
    # Create response
    response = {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from Lambda!',
            'environment': env,
            'log_level': log_level,
            'event_received': event
        })
    }
    
    return response
