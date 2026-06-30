from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# ==========================================
# МОДЕЛИ АВТОРИЗАЦИИ (УЖЕ ЕСТЬ + ДОБАВИЛИ РОЛЬ)
# ==========================================

class UserRegister(BaseModel):
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str
    role: str  # Возвращаем роль во Flutter при логине

# ==========================================
# МОДЕЛИ ДЛЯ ПРОЕКТОВ (PROJECTS)
# ==========================================

class ProjectCreate(BaseModel):
    name: str
    description: str
    deadline: str  # YYYY-MM-DD

class Project(BaseModel):
    id: int
    name: str
    description: str
    status: str
    created_at: str
    deadline: str
    owner_id: str

# ==========================================
# МОДЕЛИ ДЛЯ КОМАНД (TEAMS)
# ==========================================

class TeamMemberAdd(BaseModel):
    team_name: str
    user_email: EmailStr

# ==========================================
# МОДЕЛИ ДЛЯ ЗАДАЧ (TASKS)
# ==========================================

class TaskCreate(BaseModel):
    project_id: int
    title: str
    description: str
    assigned_to_team: Optional[str] = None
    assigned_to_user: Optional[EmailStr] = None

class TaskStatusUpdate(BaseModel):
    status: str  # To Do, In Progress, Review, Done

class Task(BaseModel):
    id: int
    project_id: int
    title: str
    description: str
    assigned_to_team: Optional[str] = None
    assigned_to_user: Optional[str] = None
    status: str

# ==========================================
# МОДЕЛИ ДЛЯ КОММЕНТАРИЕВ (COMMENTS)
# ==========================================

class CommentCreate(BaseModel):
    text: str

class Comment(BaseModel):
    id: int
    task_id: int
    user_email: str
    text: str
    created_at: str