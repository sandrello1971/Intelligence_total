#!/usr/bin/env python3
import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.core.database import SessionLocal
from sqlalchemy import text
import pandas as pd
from datetime import datetime

def safe_str(value):
    if pd.isna(value) or value is None:
        return None
    return str(value).strip() if str(value).strip() else None

def safe_int(value):
    if pd.isna(value) or value is None:
        return None
    try:
        return int(float(value))
    except:
        return None

def import_companies():
    print("🏢 Import aziende da Excel...")
    
    # Leggi Excel
    df = pd.read_excel("exportazienda20250806083432.xlsx")
    print(f"📊 Trovate {len(df)} aziende in Excel")
    
    imported_count = 0
    updated_count = 0
    error_count = 0
    
    for index, row in df.iterrows():
        session = SessionLocal()
        try:
            # Dati essenziali
            company_id = safe_int(row['ID'])
            name = safe_str(row['Azienda'])
            
            if not company_id or not name:
                session.close()
                continue
            
            # Verifica se esiste
            existing = session.execute(text("SELECT id FROM companies WHERE id = :id"), 
                                     {"id": company_id}).fetchone()
            
            if existing:
                # Update azienda esistente
                session.execute(text("""
                    UPDATE companies SET 
                        name = :name,
                        email = :email,
                        telefono = :telefono,
                        partita_iva = :partita_iva,
                        codice_fiscale = :codice_fiscale,
                        indirizzo = :indirizzo,
                        citta = :citta,
                        provincia = :provincia,
                        cap = :cap,
                        regione = :regione,
                        sito_web = :sito_web,
                        settore = :settore,
                        numero_dipendenti = :numero_dipendenti
                    WHERE id = :id
                """), {
                    "id": company_id,
                    "name": name,
                    "email": safe_str(row['E-mail (azienda)']),
                    "telefono": safe_str(row['Telefono']),
                    "partita_iva": safe_str(row['Partita IVA']),
                    "codice_fiscale": safe_str(row['Codice fiscale']),
                    "indirizzo": safe_str(row['Indirizzo']),
                    "citta": safe_str(row['Città (Azienda)']),
                    "provincia": safe_str(row['Provincia (Azienda)']),
                    "cap": safe_str(row['CAP']),
                    "regione": safe_str(row['Regione (Azienda)']),
                    "sito_web": safe_str(row['Sito web']),
                    "settore": safe_str(row['Settore merceologico azienda']),
                    "numero_dipendenti": safe_int(row['N° dipendenti'])
                })
                updated_count += 1
            else:
                # Insert nuova azienda
                session.execute(text("""
                    INSERT INTO companies (
                        id, name, email, telefono, partita_iva, codice_fiscale,
                        indirizzo, citta, provincia, cap, regione, sito_web,
                        settore, numero_dipendenti, created_at
                    ) VALUES (
                        :id, :name, :email, :telefono, :partita_iva, :codice_fiscale,
                        :indirizzo, :citta, :provincia, :cap, :regione, :sito_web,
                        :settore, :numero_dipendenti, :created_at
                    )
                """), {
                    "id": company_id,
                    "name": name,
                    "email": safe_str(row['E-mail (azienda)']),
                    "telefono": safe_str(row['Telefono']),
                    "partita_iva": safe_str(row['Partita IVA']),
                    "codice_fiscale": safe_str(row['Codice fiscale']),
                    "indirizzo": safe_str(row['Indirizzo']),
                    "citta": safe_str(row['Città (Azienda)']),
                    "provincia": safe_str(row['Provincia (Azienda)']),
                    "cap": safe_str(row['CAP']),
                    "regione": safe_str(row['Regione (Azienda)']),
                    "sito_web": safe_str(row['Sito web']),
                    "settore": safe_str(row['Settore merceologico azienda']),
                    "numero_dipendenti": safe_int(row['N° dipendenti']),
                    "created_at": datetime.now()
                })
                imported_count += 1
            
            session.commit()
            
        except Exception as e:
            session.rollback()
            error_count += 1
            print(f"❌ Errore riga {index} (ID: {company_id}): {e}")
        finally:
            session.close()
    
    print(f"🎉 Import aziende completato!")
    print(f"  ➕ Nuove aziende: {imported_count}")
    print(f"  🔄 Aziende aggiornate: {updated_count}")
    print(f"  ❌ Errori: {error_count}")

if __name__ == "__main__":
    import_companies()
