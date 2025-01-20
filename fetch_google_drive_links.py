from googleapiclient.discovery import build
from google.oauth2 import service_account

# Authenticate using a service account key
SCOPES = ['https://www.googleapis.com/auth/drive.readonly']
SERVICE_ACCOUNT_FILE = '${{secrets.GOOGLE_KEY}}'

# Build the Drive service
credentials = service_account.Credentials.from_service_account_file(
    SERVICE_ACCOUNT_FILE, scopes=SCOPES)
drive_service = build('drive', 'v3', credentials=credentials)

# Specify the folder ID
folder_id = '1_BIXdURNlwRfVQJJB142TI1J7jVf69-2'

# Get files in the folder
results = drive_service.files().list(
    q=f"'{folder_id}' in parents",
    fields="nextPageToken, files(id, name, webViewLink)",
).execute()

items = results.get('files', [])

if not items:
    print('No files found.')
else:
    print('Files:')
    for item in items:
        print(f"{item['name']} ({item['webViewLink']})")
