import gspread
from google.oauth2.service_account import Credentials

SCOPES = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive",
]

# Инициализация клиента
creds = Credentials.from_service_account_file(
    "management-499913-4c943176ab51.json",
    scopes=SCOPES
)
client = gspread.authorize(creds)
spreadsheet = client.open_by_key("1MLNY8I3weaB2e42ESSb96WyWBV3zJpcu0TDeo7nSc9c")

# Доступ к листам
users_sheet = spreadsheet.worksheet("Users")
tasks_sheet = spreadsheet.worksheet("Tasks")

def get_all_users():
    return users_sheet.get_all_records()

def add_user(user_data: dict):

    records = get_all_users()
    next_id = len(records) + 1
    users_sheet.append_row([next_id, user_data["email"], user_data["hashed_password"]])


def get_user_by_email(email: str):
    records = get_all_users()

    for record in records:
        normalized_record = {str(k).strip().lower(): v for k, v in record.items()}
        if normalized_record.get("email") == email.strip():
            return {
                "email": normalized_record.get("email"),
                "hashed_password": normalized_record.get("hashed_password")
            }
    return None


def add_user(user_data: dict):
    records = get_all_users()
    next_id = len(records) + 1
    # Убедитесь, что порядок колонок в Sheets соответствует: ID | Email | Password
    users_sheet.append_row([next_id, user_data["email"].strip().lower(), user_data["hashed_password"]])

def get_all_tasks():
    return tasks_sheet.get_all_records()