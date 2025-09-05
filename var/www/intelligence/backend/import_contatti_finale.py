#!/usr/bin/env python3
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import SessionLocal
from sqlalchemy import text
import pandas as pd
from datetime import datetime
import uuid

def import_remaining_contacts():
    print("👥 Import contatti rimanenti (commit singolo)...")
    
    # Leggi Excel
    df = pd.read_excel("exportcontatto20250806083450.xlsx")
    print(f"📊 Totale contatti Excel: {len(df)}")
    
    imported_count = 0
    skipped_count = 0
    error_count = 0
    
    for index, row in df.iterrows():
        # Una sessione per ogni record
        session = SessionLocal()
        try:
            # Dati base
            nome = str(row['Nome']).strip() if pd.notna(row['Nome']) else None
            cognome = str(row['Cognome']).strip() if pd.notna(row['Cognome']) else None
            
            if not nome and not cognome:
                skipped_count += 1
                continue
            
            # Genera ID univoco
            contact_id = str(uuid.uuid4())
            
            # Controlla se esiste già (per nome+cognome+azienda)
            azienda = str(row['Azienda']).strip() if pd.notna(row['Azienda']) else None
            existing = session.execute(text("""
                SELECT id FROM contacts 
                WHERE nome = :nome AND cognome = :cognome AND azienda = :azienda
            """), {"nome": nome, "cognome": cognome, "azienda": azienda}).fetchone()
            
            if existing:
                skipped_count += 1
                session.close()
                continue
            
            # Insert singolo
            session.execute(text("""
                INSERT INTO contacts (
                    id, nome, cognome, azienda, email, telefono, 
                    cellulare, posizione, created_at
                ) VALUES (
                    :id, :nome, :cognome, :azienda, :email, :telefono,
                    :cellulare, :posizione, :created_at
                )
            """), {
                "id": contact_id,
                "nome": nome,
                "cognome": cognome,
                "azienda": azienda,
                "email": str(row['E-mail']).strip() if pd.notna(row['E-mail']) else None,
                "telefono": str(row['Telefono 1']).strip() if pd.notna(row['Telefono 1']) else None,
                "cellulare": str(row['Cellulare 1']).strip() if pd.notna(row['Cellulare 1']) else None,
                "posizione": str(row['Ruolo aziendale']).strip() if pd.notna(row['Ruolo aziendale']) else None,
                "created_at": datetime.now()
            })
            
            session.commit()
            imported_count += 1
            
            if imported_count % 50 == 0:
                print(f"📊 Importati {imported_count} nuovi contatti...")
                
        except Exception as e:
            session.rollback()
            error_count += 1
            if error_count < 10:
                print(f"❌ Errore riga {index}: {e}")
        finally:
            session.close()
    
    print(f"🎉 Import finale completato!")
    print(f"  ➕ Nuovi contatti: {imported_count}")
    print(f"  ⏭️ Saltati (esistenti): {skipped_count}")
    print(f"  ❌ Errori: {error_count}")
    
    # Verifica finale
    session = SessionLocal()
    total = session.execute(text("SELECT COUNT(*) FROM contacts")).scalar()
    session.close()
    print(f"📊 Totale contatti in database: {total}")

if __name__ == "__main__":
    import_remaining_contacts()
