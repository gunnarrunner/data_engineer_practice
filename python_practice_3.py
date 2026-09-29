import requests
import json
import time
from datetime import datetime, timezone
import boto3

API_URL = "https://api.example.com/data"  # Replace with the actual API URL
API_KEY = "your_api_key_here"  # replace with env varriable

def fetch_all_orders(): 
    """Handles pagination and rate limits - this is most of the real work."""
    orders = []
    url = API_URL
    headers = {"Authorization": f"Bearer {API_KEY}"}

    while url:
        resp = requests.get(url, headers=headers, timeout=30)

        if resp.status_code == 429:  # Rate limit exceeded
            wait = int(resp.headers.get("Retry-After", 5))
            print(f"Rate limit exceeded. Retrying after {retry_after} seconds...")
            time.sleep(wait)
            continue

        resp.raise_for_status()
        data = resp.json()

        orders.extend(data["results"])
        url = data.get("next_page_url")

    return orders

def write_to_s3(records, bucket_name, file_name):
    """Land raw data, partitionaed by ingestion date - this partitioning is critical"""
    s3 = boto3.client("s3")
    today = datetime.now(timezone.utc).strftime("%Y/%m/%d")
    key = f"{prefix}/{today}/orders{"int(time.time())}.jsonl"}

    body = "\n".join(json.dumps(r) for r in records)
    s3.put_object(Bucket=bucket, Key=key, Body=body.encode("utf-8"))
    print(f"Wrote {len(records)} records to s3://{bucket}/{key}")

  if __name__ == "__main__":
    orders = fetch_all_orders()
    write_to_s3(orders, bucket="my-raw-data-lake", prefix="orders")
