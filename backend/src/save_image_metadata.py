import json
import os
from datetime import datetime
from logging import getLogger

import boto3

logger = getLogger(__name__)


def lambda_handler(event: dict, context) -> dict:
    logger.debug("get event.", extra={"event": event})

    origin = os.environ["AWS_ORIGIN"]
    dynamodb = boto3.resource("dynamodb")
    table_name = os.environ["AWS_IMAGE_METADATA_TABLE"]
    table = dynamodb.Table(table_name)

    return main(event, origin, table)


def main(event: dict, origin: str, table) -> dict:
    try:
        body = json.loads(event["body"])
        file_name = body["fileName"]
        file_url = body["fileUrl"]

        # Get Cognito user ID
        # user_id = event["requestContext"]["authorizer"]["claims"]["sub"]
        user_id = "test-user"  # TODO: Cognito user ID

        item = {
            "userId": user_id,
            "fileName": file_name,
            "fileUrl": file_url,
            "uploadTime": datetime.now().isoformat(),
        }
        table.put_item(Item=item)
        logger.debug("saved image metadata.", extra={"item": item})

        return {
            "statusCode": 201,
            "headers": {
                "Access-Control-Allow-Origin": origin
            },
            "body": json.dumps({
                "item": item
            }),
        }
    except Exception:
        logger.exception("error saving metadata.")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": origin
            },
            "body": json.dumps({
                "message": "Error saving metadata"
            }),
        }
