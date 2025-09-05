#!/usr/bin/env python3
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import SessionLocal
from sqlalchemy import text
import pandas as pd
from datetime import datetime
import uuid

def safe_str(value):
    if pd.isna(value) or value is None:
        return None
    return str(value).strip() if str(value).strip() else None

def import_contacts_batch():
    print("👥 Import contatti con gestione batch...")
    
    session = SessionLocal()
    try:
        # Leggi Excel
        df = pd.read_excel("exportcontatto20250806083450.xlsx")
        print(f"📊 Trovati {len(df)} contatti in Excel")
        
        imported_count = 0
        batch_size = 50
        
        for start_idx in range(0, len(df), batch_size):
            end_idx = min(start_idx + batch_size, len(df))
            batch_df = df.iloc[start_idx:end_idx]
            
            print(f"🔄 Processing batch {start_idx}-{end_idx}...")
            
            batch_imported = 0
            for index, row in batch_df.iterrows():
                try:
                    # Dati essenziali
                    nome = safe_str(row['Nome'])
                    cognome = safe_str(row['Cognome']) 
                    
                    if not nome and not cognome:
                        continue
                    
                    # Genera ID univoco
                    contact_id = str(uuid.uuid4())
                    
                    # Dati aggiuntivi
                    azienda = safe_str(row['Azienda'])
                    email = safe_str(row['E-mail'])
                    telefono = safe_str(row['Telefono 1'])
                    cellulare = safe_str(row['Cellulare 1'])
                    ruolo = safe_str(row['Ruolo aziendale'])
                    
                    # Insert singolo contatto
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
                        "email": email,
                        "telefono": telefono,
                        "cellulare": cellulare,
                        "posizione": ruolo,
                        "created_at": datetime.now()
                    })
                    
                    batch_imported += 1
                    
                except Exception as e:
                    print(f"❌ Errore riga {index}: {e}")
                    continue
            
            # Commit del batch
            try:
                session.commit()
                imported_count += batch_imported
                print(f"✅ Batch {start_idx}-{end_idx}: {batch_imported} contatti importati")
            except Exception as e:
                session.rollback()
                print(f"❌ Errore commit batch {start_idx}-{end_idx}: {e}")
        
        print(f"🎉 Import completato: {imported_count} contatti totali importati!")
        
        # Verifica finale
        total_contacts = session.execute(text("SELECT COUNT(*) FROM contacts")).scalar()
        print(f"📊 Totale contatti in database: {total_contacts}")
        
    except Exception as e:
        session.rollback()
        print(f"❌ Errore generale: {e}")
    finally:
        session.close()

if __name__ == "__main__":
    import_contacts_batch()
