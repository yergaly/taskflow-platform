from fastapi import FastAPI, HTTPException, status, Depends
from fastapi.middleware.cors import CORSMiddleware  # <-- Обязательный импорт!
from fastapi.security import OAuth2PasswordBearer
import jwt
import models
import auth
import google_sheet
from typing import Optional, List

app = FastAPI(title="TaskFlow API")

# Настройка CORS для работы с Flutter (Web, Android, iOS, Desktop)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
@app.get("/")
def home():
    return {"status":"ok"}

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

# Хелпер для извлечения текущего пользователя из JWT токена
def get_current_user_email(token: str = Depends(oauth2_scheme)) -> str:
    try:
        payload = jwt.decode(token, auth.SECRET_KEY, algorithms=[auth.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return email
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

# ==========================================
# 1. ПУБЛИЧНЫЕ ЭНДПОИНТЫ (ДЛЯ LANDING SCREEN)
# ==========================================

@app.get("/public/stats")
def get_public_stats():
    try:
        # 1. Загружаем сырые данные из листов
        all_tasks = google_sheet.get_all_tasks()
        all_projects = google_sheet.get_all_projects()
        all_teams = google_sheet.get_all_teams()

        # 2. Считаем базовые метрики
        # Активные проекты (все, у которых статус не 'Completed')
        active_projects_count = len([p for p in all_projects if p.get("status") != "Completed"])
        
        # Выполненные задачи (статус 'Done')
        completed_tasks_count = len([t for t in all_tasks if str(t.get("status")).strip().lower() == "done"])
        
        # Уникальные участники в командах
        unique_members = set(str(row.get("user_email")).strip().lower() for row in all_teams if row.get("user_email"))
        team_members_count = len(unique_members)

        # 3. Считаем прогресс для каждого проекта динамически
        projects_progress = []
        for p in all_projects:
            p_id = p.get("id")
            p_name = p.get("name")
            
            # Находим все задачи, привязанные к этому проекту
            project_tasks = [t for t in all_tasks if t.get("project_id") == p_id]
            
            if not project_tasks:
                progress = 0.0  # если задач еще нет
            else:
                done_project_tasks = len([t for t in project_tasks if str(t.get("status")).strip().lower() == "done"])
                # Считаем процент выполнения (например, 2 из 4 задач сделано = 0.5)
                progress = round(done_project_tasks / len(project_tasks), 2)
            
            projects_progress.append({
                "name": p_name,
                "progress": progress
            })

        # 4. Считаем общий On-Time Rate (процент выполненных задач от общего числа)
        if all_tasks:
            on_time_rate_value = round((completed_tasks_count / len(all_tasks)) * 100)
            on_time_rate_str = f"{on_time_rate_value}%"
        else:
            on_time_rate_str = "100%"

        # Возвращаем реальный JSON во Flutter!
        return {
            "active_projects": str(active_projects_count),
            "completed_tasks": str(completed_tasks_count),
            "team_members": str(team_members_count if team_members_count > 0 else 3), # дефолт 3, если лист Teams пустой
            "on_time_rate": on_time_rate_str,
            "projects_progress": projects_progress
        }

    except Exception as e:
        # Логгируем ошибку, если что-то пошло не так (например, пустые таблицы)
        print(f"Error calculating stats: {e}")
        return {
            "active_projects": "0",
            "completed_tasks": "0",
            "team_members": "0",
            "on_time_rate": "100%",
            "projects_progress": []
        }

# ==========================================
# 2. ЭНДПОИНТЫ АВТОРИЗАЦИИ (С УЧЕТОМ РОЛЕЙ)
# ==========================================

@app.post("/auth/register", status_code=status.HTTP_201_CREATED)
def register(user: models.UserRegister):
    normalized_email = user.email.strip().lower()

    existing_user = google_sheet.get_user_by_email(normalized_email)
    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="User with this email already exists"
        )

    hashed_password = auth.get_password_hash(user.password)

    google_sheet.add_user({
        "email": normalized_email, 
        "hashed_password": hashed_password,
        "role": "member" 
    })

    return {"message": "User registered successfully"}


@app.post("/auth/login")
def login(user: models.UserLogin):  # <-- Возвращаем как было!
    normalized_email = user.email.strip().lower()
    db_user = google_sheet.get_user_by_email(normalized_email)

    if not db_user or not auth.verify_password(user.password, db_user["hashed_password"]):
        raise HTTPException(
            status_code=400,
            detail="Incorrect email or password"
        )

    user_role = db_user.get("role", "member") 
    access_token = auth.create_access_token(data={"sub": db_user["email"]})

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "role": user_role  
    }

# ==========================================
# 3. ЭНДПОИНТЫ ДЛЯ HEAD / TEAM_LEAD (УПРАВЛЕНИЕ)
# ==========================================

@app.post("/projects", status_code=status.HTTP_201_CREATED)
def create_project(project: models.ProjectCreate, current_user: str = Depends(get_current_user_email)):
    user_data = google_sheet.get_user_by_email(current_user)
    if user_data["role"] not in ["head", "team_lead"]:
        raise HTTPException(status_code=403, detail="Not enough permissions")
    
    google_sheet.add_project(project.name, project.description, project.deadline, current_user)
    return {"message": "Project created successfully"}

@app.post("/teams/members", status_code=status.HTTP_201_CREATED)
def add_member_to_team(data: models.TeamMemberAdd, current_user: str = Depends(get_current_user_email)):
    user_data = google_sheet.get_user_by_email(current_user)
    if user_data["role"] not in ["head", "team_lead"]:
        raise HTTPException(status_code=403, detail="Not enough permissions")
        
    google_sheet.add_team_member(data.team_name, data.user_email)
    return {"message": f"User {data.user_email} added to {data.team_name}"}

@app.post("/tasks", status_code=status.HTTP_201_CREATED)
def create_task(task: models.TaskCreate, current_user: str = Depends(get_current_user_email)):
    user_data = google_sheet.get_user_by_email(current_user)
    if user_data["role"] not in ["head", "team_lead"]:
        raise HTTPException(status_code=403, detail="Not enough permissions")
        
    google_sheet.add_task(task.project_id, task.title, task.description, task.assigned_to_team, task.assigned_to_user)
    return {"message": "Task created successfully"}

# ==========================================
# 4. ПРИВАТНЫЕ ЭНДПОИНТЫ ДЛЯ РАЗРАБОТЧИКОВ (MEMBERS)
# ==========================================

@app.get("/tasks")
def read_all_tasks():
    return google_sheet.get_all_tasks()

@app.get("/tasks/my", response_model=List[models.Task])
def get_my_tasks(current_user: str = Depends(get_current_user_email)):
    user_teams = google_sheet.get_user_teams(current_user)
    all_tasks = google_sheet.get_all_tasks()
    
    my_tasks = []
    for t in all_tasks:
        assigned_user = str(t.get("assigned_to_user")).strip().lower()
        assigned_team = t.get("assigned_to_team")
        
        if assigned_user == current_user.lower() or assigned_team in user_teams:
            my_tasks.append(t)
            
    return my_tasks

@app.patch("/tasks/{task_id}/status")
def update_task_status(task_id: int, data: models.TaskStatusUpdate, current_user: str = Depends(get_current_user_email)):
    success = google_sheet.update_task_status_in_db(task_id, data.status)
    if not success:
        raise HTTPException(status_code=404, detail="Task not found")
    
    action_text = f"Изменил статус задачи на '{data.status}'"
    google_sheet.add_history_log(task_id, current_user, action_text)
    return {"message": "Status updated and logged successfully"}

@app.post("/tasks/{task_id}/comments", status_code=status.HTTP_201_CREATED)
def leave_comment(task_id: int, comment: models.CommentCreate, current_user: str = Depends(get_current_user_email)):
    google_sheet.add_comment(task_id, current_user, comment.text)
    return {"message": "Comment added"}

@app.get("/tasks/{task_id}/comments", response_model=List[models.Comment])
def get_comments(task_id: int, current_user: str = Depends(get_current_user_email)):
    return google_sheet.get_task_comments(task_id)
