#!/usr/bin/env -S uv run --script

# clientId for FortiExtender Cloud:    A4DGnqJly8bB9NENPm8TedP0WgFYzEWu884AkWtQ
# clientId for FortiPresence Cloud:    fortipresence
# clientId for FortiManager Cloud:   FortiManager
# clientId for FortiGate Cloud:      fortigatecloud
# clientId for FortiAnalyzer Cloud:    FortiAnalyzer
# clientId for FortiPhish Cloud:       fortiphish
# clientId for FortiLAN Cloud:      fortilancloud
# clientId for FortiZTP (Beta) Cloud:   fortiztp
# clientId for Asset Management Cloud:  assetmanagement
# clientId for FlexVM Cloud:   flexvm

import requests
import json
import os
from tabulate import tabulate
from dotenv import load_dotenv

load_dotenv()

oauth_url = "https://customerapiauth.fortinet.com/api/v1/oauth/token/"

def main():
    pass

def portalAuth(client_id):
    body = {
        "username": os.getenv("FORTI_API_USERNAME"),
        "password": os.getenv("FORTI_API_PASSWORD"),
        "client_id": client_id,
        "grant_type": "password",
    }
    response = requests.post(oauth_url, json=body)
    token = response.json().get("access_token")
    return token

def registerAsset(assets):
    token = portalAuth("assetmanagement")
    url = "https://support.fortinet.com/ES/api/registration/v3/products/register"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    body = dict()
    regUnits = []
    for a in assets:
        regUnits.append(a)
    body.update({"registrationUnits": regUnits})
    print(body)

    response = requests.post(url, headers=headers, json=body)
    print(response.json())

def getAssets():
    token = portalAuth("assetmanagement")
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    url = "https://support.fortinet.com/ES/api/registration/v3/products/list"
    body = {"expireBefore": "2030-01-20T10:11:11-8:00"}

    response = requests.post(url, headers=headers, json=body)
    assets = response.json().get("assets")
    tableHeaders = ["productModel", "description", "serialNumber", "status"]
    formatted = []
    for asset in assets:
        formatted.append({x: y for (x, y) in asset.items() if x in tableHeaders})
    print(tabulate(formatted, headers="keys", tablefmt="mixed_grid"))

def getZTP():
    token = portalAuth("fortiztp")
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    url = "https://fortiztp.forticloud.com/public/api/v2/devices"
    response = requests.get(url, headers=headers)
    assets = response.json().get("data")
    tableHeaders = [
        "deviceSN",
        "deviceType",
        "provisionStatus",
        "provisionTarget",
        "externalControllerSn",
        "externalControllerIp",
        "platform",
    ]
    formatted = []
    for asset in assets:
        formatted.append({x: y for (x, y) in asset.items() if x in tableHeaders})
    print(tabulate(formatted, headers="keys", tablefmt="mixed_grid"))

def provisionZTP(deviceZTP):
    token = portalAuth("fortiztp")
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    url = f'https://fortiztp.forticloud.com/public/api/v2/devices/{deviceZTP.get("deviceSN")}'
    print(url)
    jsonBody = json.dumps(deviceZTP)
    print(json.dumps(deviceZTP, indent=4))
    response = requests.put(url, headers=headers, json=jsonBody)
    print(response.json())

def printTable(data):
    pass

if __name__ == "__main__":
    main()
    # getAssets()
    getZTP()
    # registerAsset([{"serialNumber": "", "cloudKey": "", "isGovernment": False}])
    provisionZTP(
        {
            "deviceSN": "",
            "deviceType": "FortiGate",
            "provisionStatus": "provisioned",
            "provisionTarget": "FortiManager",
            "externalControllerSn": os.getenv("FORTI_FMGR_SERIAL"),
            "externalControllerIp": os.getenv("FORTI_FMGR_IP"),
            "platform": "FortiGate-VM64-KVM",
        }
    )
