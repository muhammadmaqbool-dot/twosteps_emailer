import os
import requests
import gspread
from google.oauth2.service_account import Credentials


# ------------------------------
# Config from ENV (docker-compose.yml se)
# ------------------------------
SHEET_ID = os.getenv("SHEET_ID", "1hUtVfCSO3J3zaa7tkv3q42_dvC4-Jk2Ovraaa0R9CSE")
CREDENTIALS_FILE = os.getenv("CREDENTIALS_FILE", "/app/credentials.json")
RANGE = os.getenv("RANGE_NAME", "Sheet1!A1")

LISTMONK_URL = os.getenv("LISTMONK_URL", "http://listmonk_app:9000/api/campaigns")
LISTMONK_USER = os.getenv("LISTMONK_USERNAME", "admin")
LISTMONK_PASS = os.getenv("LISTMONK_PASSWORD", "supersecret")


def fetch_campaigns():
    """Fetch campaign data from Listmonk API"""
    try:
        resp = requests.get(LISTMONK_URL, auth=(LISTMONK_USER, LISTMONK_PASS))
        resp.raise_for_status()
        return resp.json()["data"]["results"]
    except Exception as e:
        print("❌ Error fetching campaigns:", e)
        return []


def write_to_sheets(campaigns):
    """Write campaign status to Google Sheets"""
    try:
        scopes = ["https://www.googleapis.com/auth/spreadsheets"]
        creds = Credentials.from_service_account_file(CREDENTIALS_FILE, scopes=scopes)
        client = gspread.authorize(creds)
        sheet = client.open_by_key(SHEET_ID).sheet1

        # Header row
        rows = [["ID", "Name", "Status"]]
        for c in campaigns:
            rows.append([c["id"], c["name"], c["status"]])

        # Update whole sheet from A1
        sheet.update("A1", rows)
        print(f"✅ Updated {len(campaigns)} campaigns to Google Sheet {SHEET_ID}")
    except Exception as e:
        print("❌ Error writing to sheet:", e)


def main():
    campaigns = fetch_campaigns()
    if campaigns:
        write_to_sheets(campaigns)
    else:
        print("⚠️ No campaigns fetched.")


if __name__ == "__main__":
    main()
