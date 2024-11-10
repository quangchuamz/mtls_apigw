import requests
import json
from datetime import datetime

def call_hdb_api():
    # API endpoint
    api_url = "https://openbanking-uat.hdbank.com.vn/kieuHoiService/v2/GetOrderStatus"
    
    # Certificate paths (using .cert instead of .pem)
    client_cert = ('hdbcerts/JRF-uat.cert', 'hdbcerts/JRF-uat.key')
    
    # Request headers
    headers = {
        'X-IBM-Client-Id': 'd668879fef0c26cad86b0efdb056bb8c',
        'X-IBM-CLIENT-SECRET': 'nA0aKCfvf2g1KHwZ4KCO89U6PY5K17P3FHwfJvV0',
        'Content-Type': 'application/json'
    }
    
    # Request payload
    payload = {
        "request": {
            "requestId": "3de62896-5634-4a84-8efb-36fa29cf5500",
            "requestTime": "15032021181900"
        },
        "data": {
            "batchId": "7980e87c-7f09-4f74-baa8-65c9cb9e5d1b",
            "reference": "456798"
        }
    }
    
    try:
        # Make POST request with client certificates
        response = requests.post(
            api_url,
            cert=client_cert,
            verify=True,  # You may need to adjust this based on your environment
            headers=headers,
            json=payload
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
    except requests.exceptions.SSLError as e:
        print(f"SSL Error: {e}")
    except requests.exceptions.RequestException as e:
        print(f"Request Error: {e}")

if __name__ == "__main__":
    call_hdb_api() 