import json
import os
from datetime import datetime

def lambda_handler(event, context):
    """
    Lambda function triggered by EventBridge
    Handles both scheduled events and EC2 state change events
    """
    print(f"Event received: {json.dumps(event, indent=2)}")
    
    # Determine event source
    event_source = event.get('source', 'unknown')
    detail_type = event.get('detail-type', 'unknown')
    
    response = {
        'timestamp': datetime.utcnow().isoformat(),
        'event_source': event_source,
        'detail_type': detail_type
    }
    
    # Handle scheduled events
    if event_source == 'aws.events' and 'Scheduled Event' in detail_type:
        print("Processing scheduled event")
        response['message'] = 'Scheduled event processed successfully'
        response['schedule_time'] = event.get('time', 'N/A')
    
    # Handle EC2 state change events
    elif event_source == 'aws.ec2':
        detail = event.get('detail', {})
        instance_id = detail.get('instance-id', 'unknown')
        state = detail.get('state', 'unknown')
        
        print(f"EC2 Instance {instance_id} changed to state: {state}")
        
        response['message'] = f'EC2 instance state change detected'
        response['instance_id'] = instance_id
        response['new_state'] = state
        response['time'] = event.get('time', 'N/A')
    
    # Handle other events
    else:
        print("Processing other event type")
        response['message'] = 'Event processed'
        response['raw_event'] = event
    
    print(f"Response: {json.dumps(response, indent=2)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }
