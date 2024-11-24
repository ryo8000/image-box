import json
import os
from logging import getLogger

import boto3
from boto3.dynamodb.conditions import Key

logger = getLogger(__name__)


def lambda_handler(event: dict, context) -> dict:
    logger.debug("get event.", extra={"event": event})

    origin = os.environ["APP_ORIGIN"]
    dynamodb = boto3.resource("dynamodb")
    table_name = os.environ["APP_IMAGE_METADATA_TABLE"]
    table = dynamodb.Table(table_name)

    return main(event, origin, table)


def main(event: dict, origin: str, table) -> dict:
    try:
        # Get Cognito user ID
        # user_id = event["requestContext"]["authorizer"]["claims"]["sub"]
        user_id = "test-user"  # TODO: Cognito user ID

        response = table.query(
            KeyConditionExpression=Key("userId").eq(user_id)
        )
        items = response.get("Items", [])

        images = [
            {
                "fileName": item["fileName"],
                "fileUrl": item["fileUrl"],
                "uploadTime": item["uploadTime"]
            }
            for item in items
        ]

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": origin
            },
            "body": json.dumps({
                "images": images
            }),
        }
    except Exception:
        logger.exception("error fetching images.")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": origin
            },
            "body": json.dumps({
                "message": "Error fetching images"
            }),
        }
