from fastapi import FastAPI, HTTPException, status, Depends
from fastapi.middleware.cors import CORSMiddleware
import models
import auth
import google_sheet

app = FastAPI(title="TaskFlow API")

# Настройка CORS, чтобы Flutter Web/Desktop могли делать запросы
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



@app.post("/auth/register", status_code=status.HTTP_201_CREATED)
def register(user: models.UserRegister):
    # ПРИНУДИТЕЛЬНО переводим email в нижний регистр на входе
    normalized_email = user.email.strip().lower()

    # 1. Проверяем по очищенному email
    existing_user = google_sheet.get_user_by_email(normalized_email)
    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="User with this email already exists"
        )

    # 2. Хешируем пароль
    hashed_password = auth.get_password_hash(user.password)

    # 3. Сохраняем строго очищенный email
    google_sheet.add_user({"email": normalized_email, "hashed_password": hashed_password})

    return {"message": "User registered successfully"}


@app.post("/auth/login", response_model=models.Token)
def login(user: models.UserLogin):
    # Здесь тоже приводим к нижнему регистру!
    normalized_email = user.email.strip().lower()

    db_user = google_sheet.get_user_by_email(normalized_email)

    if not db_user:
        raise HTTPException(
            status_code=400,
            detail="Incorrect email or password"
        )

    if not auth.verify_password(user.password, db_user["hashed_password"]):
        raise HTTPException(
            status_code=400,
            detail="Incorrect email or password"
        )

    return {
        "access_token": auth.create_access_token(data={"sub": db_user["email"]}),
        "token_type": "bearer"
    }


@app.get("/tasks")
def read_tasks():
    # Эндпоинт для Flutter-экрана задач
    return google_sheet.get_all_tasks()