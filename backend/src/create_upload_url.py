import json
import os
from logging import getLogger

import boto3

logger = getLogger(__name__)


def lambda_handler(event: dict, context) -> dict:
    logger.debug("get event.", extra={"event": event})

    bucket_name = os.environ["AWS_S3_BUCKET_NAME"]
    expires = int(os.environ["AWS_PRESIGNED_URL_EXPIRES"])
    origin = os.environ["AWS_ORIGIN"]
    s3_client = boto3.client("s3")

    return main(event, bucket_name, expires, origin, s3_client)


def main(event: dict, bucket_name: str, expires: int, origin: str, s3_client) -> dict:
    try:
        body = json.loads(event['body'])
        file_name = body["fileName"]
        file_type = body["fileType"]
        # user_id = event["requestContext"]["authorizer"]["claims"]["sub"]
        user_id = "test-user"  # TODO : Cognito user ID
        params = {
            "Bucket": bucket_name,
            "Key": f"{user_id}/{file_name}",
            "ContentType": file_type,
        }

        upload_url = s3_client.generate_presigned_url(
            "put_object",
            Params=params,
            ExpiresIn=expires,
        )
        logger.debug("created presigned url.", extra={"uploadUrl": upload_url})

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": origin
            },
            "body": json.dumps({
                "uploadUrl": upload_url
            }),
        }
    except Exception:
        logger.exception("error generating url.")
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": origin
            },
            "body": json.dumps({
                "error": {
                    "message": "Error generating URL"
                }
            }),
        }
