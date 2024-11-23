import json
import os
from logging import getLogger

import boto3

logger = getLogger(__name__)


def lambda_handler(event: dict, context) -> dict:
    logger.debug("get event.", extra={"event": event})

    bucket_name = os.environ["AWS_S3_BUCKET_NAME"]
    expires = int(os.environ["AWS_PRESIGNED_URL_EXPIRES"])
    s3_client = boto3.client("s3")

    return main(event, bucket_name, expires, s3_client)


def main(event: dict, bucket_name: str, expires: int, s3_client) -> dict:
    try:
        file_name = event["fileName"]
        file_type = event["fileType"]
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
            "uploadUrl": upload_url
        }
    except Exception:
        logger.exception("failed")
        return {
            "statusCode": 500,
            "body": json.dumps({"message": "Error generating URL"}),
        }
