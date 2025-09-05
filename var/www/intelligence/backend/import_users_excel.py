#!/usr/bin/env python3
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import SessionLocal
from sqlalchemy import text
import pandas as pd
from datetime import datetime
import uuid
from passlib.context import CryptContext

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def safe_str(value):
    if pd.isna(value) or value is None:
        return None
    return str(value).strip() if str(value).strip() else None

def map_role(tipo_utente):
    """Mappa il tipo utente CRM al role del sistema"""
    if not tipo_utente:
        return 'operator'
    
    tipo_lower = str(tipo_utente).lower()
    if 'admin' in tipo_lower or 'system' in tipo_lower:
        return 'admin'
    elif 'manager' in tipo_lower or 'commerciale' in tipo_lower:
        return 'manager'
    else:
        return 'operator'

def import_users():
    print("👤 Import users da Excel...")
    
    # Leggi Excel
    df = pd.read_excel("export20250806084902.xlsx")
    print(f"📊 Trovati {len(df)} users in Excel")
    
    imported_count = 0
    updated_count = 0
    error_count = 0
    
    for index, row in df.iterrows():
        session = SessionLocal()
        try:
            # Dati essenziali
            email = safe_str(row['User ID'])  # User ID è l'email
            nome = safe_str(row['Nome'])
            cognome = safe_str(row['Cognome'])
            tipo_utente = safe_str(row['Tipo utente'])
            crm_uid = safe_str(row['UID'])
            
            if not email or '@' not in email:
                session.close()
                continue
            
            # Username dalla parte prima della @
            username = email.split('@')[0]
            
            # Role mapping
            role = map_role(tipo_utente)
            
            # Password default hashata
            default_password = "Intelligence2025!"
            password_hash = pwd_context.hash(default_password)
            
            # Verifica se esiste già
            existing = session.execute(text("SELECT id FROM users WHERE email = :email"), 
                                     {"email": email}).fetchone()
            
            if existing:
                # Update utente esistente
                session.execute(text("""
                    UPDATE users SET 
                        name = :name,
                        surname = :surname,
                        first_name = :first_name,
                        last_name = :last_name,
                        role = :role,
                        crm_id = :crm_id
                    WHERE email = :email
                """), {
                    "email": email,
                    "name": nome,
                    "surname": cognome,
                    "first_name": nome,
                    "last_name": cognome,
                    "role": role,
                    "crm_id": int(crm_uid) if crm_uid and crm_uid.isdigit() else None
                })
                updated_count += 1
                print(f"🔄 Updated user: {email}")
            else:
                # Insert nuovo utente
                session.execute(text("""
                    INSERT INTO users (
                        username, email, password_hash, name, surname,
                        first_name, last_name, role, crm_id, created_at, is_active
                    ) VALUES (
                        :username, :email, :password_hash, :name, :surname,
                        :first_name, :last_name, :role, :crm_id, :created_at, :is_active
                    )
                """), {
                    "username": username,
                    "email": email,
                    "password_hash": password_hash,
                    "name": nome,
                    "surname": cognome,
                    "first_name": nome,
                    "last_name": cognome,
                    "role": role,
                    "crm_id": int(crm_uid) if crm_uid and crm_uid.isdigit() else None,
                    "created_at": datetime.now(),
                    "is_active": True
                })
                imported_count += 1
                print(f"➕ Created user: {email} (role: {role})")
            
            session.commit()
            
        except Exception as e:
            session.rollback()
            error_count += 1
            print(f"❌ Errore riga {index} ({email}): {e}")
        finally:
            session.close()
    
    print(f"\n🎉 Import users completato!")
    print(f"  ➕ Nuovi users: {imported_count}")
    print(f"  🔄 Users aggiornati: {updated_count}")
    print(f"  ❌ Errori: {error_count}")
    print(f"  🔑 Password default: Intelligence2025!")

if __name__ == "__main__":
    import_users()
