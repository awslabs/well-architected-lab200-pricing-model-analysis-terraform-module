# Lambda Function Code - SPTool_SP_pricing_Download
# Function to download SavingsPlans pricing, get out the required lines & upload it to S3 as a zipped file
# It will get each regions pricing file in CSV, find 'Usage' and '1yr', and write to a file
# Written by natbesh@amazon.com
# Please reachout to costoptimization@amazon.com if there's any comments or suggestions
import boto3
import gzip
import urllib3
import json
import os

def lambda_handler(event, context):

    # Create the connection
    http = urllib3.PoolManager()

    try:
        # Get the SavingsPlans pricing index file, so you can get all the region files, which have the pricing in them
        r = http.request('GET', 'https://pricing.us-east-1.amazonaws.com/savingsPlan/v1.0/aws/AWSComputeSavingsPlan/current/region_index.json')

        # Load the json file into a variable, and parse it
        sp_regions = r.data
        sp_regions_json = (json.loads(sp_regions))

        # Variable to hold all of the pricing data, its large at over 150MB
        sp_pricing_data = ""

        # Cycle through each regions pricing file, to get the data we need
        for region in sp_regions_json['regions']:

            # Get the CSV URL
            url = "https://pricing.us-east-1.amazonaws.com" + region['versionUrl']
            url = url.replace('.json', '.csv')

            # Create a connection & get the regions pricing data CSV file
            http = urllib3.PoolManager()
            r = http.request('GET', url)
            spregion_content = r.data

            # Split the lines into an array
            spregion_lines = spregion_content.splitlines()

            # Go through each of the pricing lines
            for line in spregion_lines:

                # If the line has 'Usage' then grab it for pricing data, exclude all others
                if (str(line).find('Usage') != -1):
                    sp_pricing_data += str(line.decode("utf-8"))
                    sp_pricing_data += "\n"

        # Compress the text into a local temporary file
        with gzip.open('/tmp/sp_pricedata.txt.gz', 'wb') as f:
            f.write(sp_pricing_data.encode())

        # Upload the file to S3
        s3 = boto3.resource('s3')

        # Specify the local file, the bucket, and the folder and object name - you MUST have a folder and object name
        s3.meta.client.upload_file('/tmp/sp_pricedata.txt.gz', os.environ["BUCKET_NAME"], 'Pricing/sp_pricedata/sp_pricedata.txt.gz')

    # Die if you cant get the file
    except Exception as e:
        print(e)
        raise e

    # Return happy
    return {
        'statusCode': 200
    }