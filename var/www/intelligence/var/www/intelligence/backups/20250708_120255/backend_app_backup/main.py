# app/main.py
# FastAPI Main Application - IntelligenceHUB Complete System

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import asyncpg
from dotenv import load_dotenv

load_dotenv()

# Import dei router esistenti (con gestione errori)
routers_loaded = {}

try:
    from app.routes.rag_routes import router as rag_router
    routers_loaded['rag'] = rag_router
    print("✅ RAG router loaded successfully")
except ImportError as e:
    print(f"❌ RAG router failed: {e}")
    routers_loaded['rag'] = None

try:
    from app.routes.intellichat import router as intellichat_router
    routers_loaded['intellichat'] = intellichat_router
    print("✅ IntelliChat router loaded successfully")
except ImportError as e:
    print(f"❌ IntelliChat router failed: {e}")
    routers_loaded['intellichat'] = None

try:
    from app.routes.intellichat_webscraping_route import router as webscraping_router
    routers_loaded['webscraping'] = webscraping_router
    print("✅ WebScraping router loaded successfully")
except ImportError as e:
    print(f"❌ WebScraping router failed: {e}")
    routers_loaded['webscraping'] = None

# App initialization
app = FastAPI(
    title="IntelligenceHUB",
    version="5.0.0",
    description="IntelligenceHUB - Complete AI Platform with RAG, IntelliChat, WebScraping"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include all available routers
if routers_loaded['rag']:
    app.include_router(routers_loaded['rag'], prefix="/api/v1")
    print("✅ RAG routes registered at /api/v1/rag")

if routers_loaded['intellichat']:
    app.include_router(routers_loaded['intellichat'], prefix="/api/v1")
    print("✅ IntelliChat routes registered at /api/v1/intellichat")

if routers_loaded['webscraping']:
    app.include_router(routers_loaded['webscraping'], prefix="/api")
    print("✅ WebScraping routes registered at /api/web-scraping")

# Database connection (compatibilità con il main.py esistente)
async def get_db_connection():
    return await asyncpg.connect(
        host="localhost",
        port=5432,
        user="intelligence_user", 
        password="intelligence_pass",
        database="intelligence"
    )

@app.get("/")
async def root():
    return {
        "message": "IntelligenceHUB API", 
        "version": "5.0.0", 
        "status": "operational",
        "modules_loaded": {k: v is not None for k, v in routers_loaded.items()},
        "endpoints": {
            "health": "/health",
            "docs": "/docs",
            "rag": "/api/v1/rag/health" if routers_loaded['rag'] else "not_available",
            "intellichat": "/api/v1/intellichat/health" if routers_loaded['intellichat'] else "not_available",
            "webscraping": "/api/web-scraping/scraped-sites" if routers_loaded['webscraping'] else "not_available"
        }
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy", 
        "version": "5.0.0", 
        "service": "IntelligenceHUB",
        "modules": {k: v is not None for k, v in routers_loaded.items()}
    }

@app.get("/api/health")
async def api_health_check():
    return await health_check()

# AUTH ENDPOINTS (manteniamo quelli che funzionano)
@app.post("/api/auth/login")
@app.post("/api/v1/auth/login")
@app.post("/api/v1/auth/login1")
async def login(credentials: dict):
    email = credentials.get("email", "").strip()
    password = credentials.get("password", "")
    
    if not email or not password:
        raise HTTPException(status_code=400, detail="Email and password required")
    
    try:
        conn = await get_db_connection()
        
        user = await conn.fetchrow(
            "SELECT id, username, email, role, name, surname, first_name, last_name, is_active FROM users WHERE email = $1",
            email
        )
        
        await conn.close()
        
        if not user:
            raise HTTPException(status_code=401, detail="User not found")
        
        if not user['is_active']:
            raise HTTPException(status_code=401, detail="User account disabled")
        
        return {
            "access_token": f"token-{user['username']}",
            "token_type": "bearer",
            "user": {
                "id": str(user['id']),
                "email": user['email'],
                "username": user['username'],
                "name": user['first_name'] or user['name'],
                "surname": user['last_name'] or user['surname'],
                "role": user['role']
            }
        }
        
    except Exception as e:
        print(f"Login error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

# USERS ENDPOINTS (manteniamo quelli che funzionano)
@app.get("/api/v1/users")
@app.get("/api/users")
@app.get("/api/v1/admin/users/")
@app.get("/api/v1/admin/users")
async def get_users():
    try:
        conn = await get_db_connection()
        
        users = await conn.fetch("""
            SELECT id, username, email, role, name, surname, first_name, last_name, 
                   is_active, created_at, last_login, crm_id
            FROM users 
            WHERE is_active = true
            ORDER BY created_at DESC
        """)
        
        await conn.close()
        
        users_list = []
        for user in users:
            users_list.append({
                "id": str(user['id']),
                "username": user['username'],
                "email": user['email'],
                "name": user['first_name'] or user['name'] or '',
                "surname": user['last_name'] or user['surname'] or '',
                "role": user['role'],
                "is_active": user['is_active'],
                "created_at": user['created_at'].isoformat() if user['created_at'] else None,
                "last_login": user['last_login'].isoformat() if user['last_login'] else None,
                "crm_id": user['crm_id']
            })
        
        return {"users": users_list, "total": len(users_list)}
        
    except Exception as e:
        print(f"Users list error: {e}")
        raise HTTPException(status_code=500, detail="Error loading users")

# Admin endpoints
@app.get("/api/v1/admin/dashboard")
async def admin_dashboard():
    try:
        conn = await get_db_connection()
        users_count = await conn.fetchval("SELECT COUNT(*) FROM users WHERE is_active = true")
        companies_count = await conn.fetchval("SELECT COUNT(*) FROM companies")
        await conn.close()
        
        return {
            "stats": {
                "users": users_count,
                "companies": companies_count,
                "active_sessions": 0
            }
        }
    except Exception as e:
        return {"error": str(e)}

if __name__ == "__main__":
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
