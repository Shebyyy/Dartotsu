from googleapiclient.discovery import build
from google.oauth2 import service_account

# Authenticate using a service account key
SCOPES = ['https://www.googleapis.com/auth/drive.readonly']
SERVICE_ACCOUNT_FILE = 'service_account.json'

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





from googleapiclient.discovery import build
from google.oauth2 import service_account
import os

# Authenticate using the service account key
SCOPES = ['https://www.googleapis.com/auth/drive.readonly']
SERVICE_ACCOUNT_FILE = 'service_account.json'

credentials = service_account.Credentials.from_service_account_file(
    SERVICE_ACCOUNT_FILE, scopes=SCOPES)
drive_service = build('drive', 'v3', credentials=credentials)

# Specify the parent folder ID
parent_folder_id = '1_BIXdURNlwRfVQJJB142TI1J7jVf69-2'
subfolder_name = 'Dartotsu_apks'

# Step 1: Find the subfolder ID
subfolder_id = None
response = drive_service.files().list(
    q=f"'{parent_folder_id}' in parents and mimeType = 'application/vnd.google-apps.folder'",
    fields="files(id, name)"
).execute()

for folder in response.get('files', []):
    if folder['name'] == subfolder_name:
        subfolder_id = folder['id']
        break

if not subfolder_id:
    print(f"Subfolder '{subfolder_name}' not found in parent folder.")
    exit()

# Step 2: Get files in the subfolder
files_response = drive_service.files().list(
    q=f"'{subfolder_id}' in parents",
    fields="files(id, name, webViewLink)"
).execute()

files = files_response.get('files', [])

# Step 3: Generate an HTML page with download links
html_content = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Download Links</title>
</head>
<body>
    <h1>Files in Subfolder: {}</h1>
    <ul>
""".format(subfolder_name)

for file in files:
    html_content += f'<li><a href="{file["webViewLink"]}" target="_blank">{file["name"]}</a></li>\n'

html_content += """
    </ul>
</body>
</html>
"""

# Step 4: Save the HTML to a file
output_file = 'download_links.html'
with open(output_file, 'w') as f:
    f.write(html_content)

print(f"HTML file '{output_file}' generated successfully!")

