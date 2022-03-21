# Lambda Function Code - SPTool_OD_pricing_Download
# Function to download OnDemand pricing, get out the required lines & upload it to S3 as a zipped file
# It will find 'OnDemand' and 'Compute Instance', and write to a file
# Written by natbesh@amazon.com
# Please reachout to costoptimization@amazon.com if there's any comments or suggestions
# Lambda Function Code - SPTool_OD_pricing_Download

import boto3
import gzip
import urllib3
import os
import json

def lambda_handler(event, context):

    # Create the connection
    http = urllib3.PoolManager()
    coreURL = "https://pricing.us-east-1.amazonaws.com"

    try:
        # Get the EC2 OnDemand pricing file, its huge >1GB
            
        r = http.request('GET', 'https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/region_index.json')
        data = json.loads(r.data)

        client = boto3.client('s3')
            
        # read data from template
        print(data)
        for region in data["regions"]:
                
            region_code = "ec2pricedata/" + region + ".csv"
            print(region_code)
                
            region_url = coreURL + data['regions'][region]["currentVersionUrl"].replace(".json", ".csv")
            r = http.request('GET', region_url)
                
            # Put the response data into a variable & split it into an array line by line
            plaintext_content = r.data
            plaintext_lines = plaintext_content.splitlines()
                
            # Varaible to hold the OnDemand pricing data
            pricing_output = ""
                
            # Go through each of the pricing lines to find the ones we need
            for line in plaintext_lines:
                
                # If the line contains 'OnDemand' or 'Compute Instance' then add it to the output string
                if ((str(line).find('OnDemand') != -1) and (str(line).find('RunInstances') != -1)):
                    pricing_output += str(line.decode("utf-8")).replace('"', '')
                    pricing_output += "\n"
                
            # Add the output to a local temporary file & zip it
            with gzip.open('/tmp/od_pricedata.txt.gz', 'wb') as f:
                f.write(pricing_output.encode())
                
            # Upload the zipped file to S3
            s3 = boto3.resource('s3')
                
            # Specify the local file, the bucket, and the folder and object name - you MUST have a folder and object name
            s3.meta.client.upload_file('/tmp/od_pricedata.txt.gz', 'bucket_name', 'od_pricedata/od_pricedata.txt.gz')
        
            # Die if you cant get the pricing file     
                        
    except Exception as e:
        print(e)
        raise e

    # Return happy
    return {
    'statusCode': 200
    }
