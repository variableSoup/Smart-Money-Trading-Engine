import http.client
import json
from utils.ndjson import write_ndjson
from utils.googleBucketLoader import upload_json

def fetch_congress():
    BUCKET_NAME = ""

    conn = http.client.HTTPSConnection("api.quiverquant.com")
    headers = {
        'Accept': "application/json",
        'Authorization': "Bearer "
    }

    conn.request("GET", "/beta/live/congresstrading", headers=headers)

    res = conn.getresponse()
    raw_data = res.read().decode("utf-8")
    

    try:
        # Parse the JSON
        #parsed_data = json.loads(raw_data)
        data = write_ndjson(raw_data, "congress_transactions.ndjson", coerce_numeric=True)
        # Upload to GCS
        upload_json(BUCKET_NAME, data, "PATH/TO/BUCKET")

        #print(json.dumps(parsed_data, indent=2))  # Optional preview
        return data

    except json.JSONDecodeError as e:
        print("JSON decoding error:", e)
        print("Raw data:", raw_data)
        return None


# Run the function
fetch_congress()
