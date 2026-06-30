import gspread
from typing import Optional, List
from datetime import datetime
from google.oauth2.service_account import Credentials

SCOPES = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive",
]

# Инициализация клиента
creds = Credentials.from_service_account_file(
    "management-google-cloud.json",
    scopes=SCOPES
)
client = gspread.authorize(creds)
spreadsheet = client.open_by_key("1MLNY8I3weaB2e42ESSb96WyWBV3zJpcu0TDeo7nSc9c")

# Доступ к листам
users_sheet = spreadsheet.worksheet("Users")
projects_sheet = spreadsheet.worksheet("Projects")
teams_sheet = spreadsheet.worksheet("Teams")
tasks_sheet = spreadsheet.worksheet("Tasks")
comments_sheet = spreadsheet.worksheet("Comments")
history_sheet = spreadsheet.worksheet("History_logs")


def get_all_users():
    return users_sheet.get_all_records()


def get_user_by_email(email: str):
    records = get_all_users()
    target_email = email.strip().lower()

    for record in records:
        # Нормализуем ключи (заголовки колонок)
        normalized_record = {str(k).strip().lower(): v for k, v in record.items()}
        
        if normalized_record.get("email") == target_email:
            return {
                "email": normalized_record.get("email"),
                "hashed_password": normalized_record.get("hashed_password"),
                # Достаем роль, если её нет в таблице — отдаем базовую 'member'
                "role": normalized_record.get("role", "member")
            }
    return None


def add_user(user_data: dict):
    """
    Добавляет пользователя в таблицу.
    ВАЖНО: Структура колонок в твоем Google Sheets должна быть:
    A: id | B: email | C: hashed_password | D: role
    """
    records = get_all_users()
    next_id = len(records) + 1
    
    users_sheet.append_row([
        next_id, 
        user_data["email"].strip().lower(), 
        user_data["hashed_password"],
        user_data.get("role", "member") # Записываем роль в 4-ю колонку
    ])

def get_all_tasks():
    return tasks_sheet.get_all_records()

def get_all_projects():
    return projects_sheet.get_all_records()

def add_project(name: str, description: str, deadline: str, owner_email: str):
    records = get_all_projects()
    next_id = len(records) + 1
    created_at = datetime.now().strftime("%d.%m.%Y")
    
    # id | name | description | status | created_at | deadline | owner_id
    projects_sheet.append_row([
        next_id, name, description, "In process", created_at, deadline, owner_email
    ])

# ----------------- КОМАНДЫ -----------------

def get_all_teams():
    return teams_sheet.get_all_records()

def add_team_member(team_name: str, user_email: str):
    # team_name | user_email
    teams_sheet.append_row([team_name, user_email])

def get_user_teams(email: str) -> list:
    """Возвращает список имён команд, в которых состоит пользователь"""
    records = get_all_teams()
    user_teams = []
    for r in records:
        if str(r.get("user_email")).strip().lower() == email.strip().lower():
            user_teams.append(r.get("team_name"))
    return user_teams

# ----------------- ЗАДАЧИ -----------------

def add_task(project_id: int, title: str, description: str, team: Optional[str], user: Optional[str]):
    records = get_all_tasks()
    next_id = len(records) + 1
    
    # id | project_id | title | description | assigned_to_team | assigned_to_user | status
    tasks_sheet.append_row([
        next_id, project_id, title, description, team or "", user or "", "To Do"
    ])

def update_task_status_in_db(task_id: int, new_status: str):
    records = get_all_tasks()
    # Ищем строку (номер строки в Sheets = индекс в массиве + 2, т.к. индексация с 0 и первая строка — заголовок)
    for index, record in enumerate(records):
        if int(record.get("id")) == task_id:
            row_number = index + 2
            # Статус находится в 7-й колонке (G)
            tasks_sheet.update_cell(row_number, 7, new_status)
            return True
    return False

# ----------------- КОММЕНТАРИИ -----------------

def get_task_comments(task_id: int):
    records = comments_sheet.get_all_records()
    return [r for r in records if int(r.get("task_id")) == task_id]

def add_comment(task_id: int, user_email: str, text: str):
    records = comments_sheet.get_all_records()
    next_id = len(records) + 1
    created_at = "30.06.2026 20:00" # Или datetime
    
    # id | task_id | user_email | text | created_at
    comments_sheet.append_row([next_id, task_id, user_email, text, created_at])


def add_history_log(task_id: int, user_email: str, action: str):
    """
    Автоматически записывает действие в историю изменений.
    Структура колонок в Sheets: id | task_id | user_email | action | timestamp
    """
    try:
        records = history_sheet.get_all_records()
        next_id = len(records) + 1
    except Exception:
        # Если лист пустой или нет заголовков, берем ID = 1
        next_id = 1
        
    # Форматируем текущее время: "30.06.2026 19:57"
    from datetime import datetime
    timestamp = datetime.now().strftime("%d.%m.%Y %H:%M")
    
    history_sheet.append_row([
        next_id, 
        task_id, 
        user_email.strip().lower(), 
        action, 
        timestamp
    ])
