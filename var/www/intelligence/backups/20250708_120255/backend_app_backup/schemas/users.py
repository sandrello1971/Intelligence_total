from pydantic import BaseModel, Field, EmailStr, ConfigDict
from typing import Optional, Dict, Any
from datetime import datetime
from uuid import UUID

class UserBase(BaseModel):
    username: str = Field(..., min_length=3, max_length=100, description="Nome utente univoco")
    email: EmailStr = Field(..., description="Email utente")
    first_name: Optional[str] = Field(None, max_length=100, description="Nome")
    last_name: Optional[str] = Field(None, max_length=100, description="Cognome")
    role: str = Field("operator", pattern="^(admin|manager|operator|viewer)$", description="Ruolo utente")
    permissions: Optional[Dict[str, Any]] = Field(default_factory=dict, description="Permessi specifici")

class UserCreate(UserBase):
    password: str = Field(..., min_length=8, description="Password (min 8 caratteri)")

class UserUpdate(BaseModel):
    username: Optional[str] = Field(None, min_length=3, max_length=100)
    email: Optional[EmailStr] = None
    first_name: Optional[str] = Field(None, max_length=100)
    last_name: Optional[str] = Field(None, max_length=100)
    role: Optional[str] = Field(None, pattern="^(admin|manager|operator|viewer)$")
    permissions: Optional[Dict[str, Any]] = None
    password: Optional[str] = Field(None, min_length=8, description="Nuova password")
    is_active: Optional[bool] = None

class UserResponse(UserBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: UUID
    is_active: bool
    last_login: Optional[datetime]
    created_at: datetime
    name: Optional[str] = None
    surname: Optional[str] = None
    must_change_password: bool = False

class UserListItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: UUID
    username: str
    email: str
    first_name: Optional[str]
    last_name: Optional[str]
    role: str
    is_active: bool
    last_login: Optional[datetime]
    created_at: datetime

class UserDetailResponse(UserResponse):
    total_tickets_assigned: Optional[int] = Field(0, description="Ticket assegnati")
    total_tasks_assigned: Optional[int] = Field(0, description="Task assegnati")
    completed_tasks_count: Optional[int] = Field(0, description="Task completati")
    average_completion_time: Optional[float] = Field(None, description="Tempo medio completamento")

class UserProfile(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    
    id: UUID
    username: str
    email: str
    first_name: Optional[str]
    last_name: Optional[str]
    role: str
    permissions: Dict[str, Any]
    is_active: bool
    last_login: Optional[datetime]

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserProfile
    expires_in: int
    must_change_password: bool = False

class PasswordChange(BaseModel):
    current_password: str
    new_password: str = Field(..., min_length=8, description="Nuova password (min 8 caratteri)")

class PasswordReset(BaseModel):
    email: EmailStr

class PasswordResetConfirm(BaseModel):
    token: str
    new_password: str = Field(..., min_length=8)
