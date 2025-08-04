"""
Intelligence AI Platform - Articles Routes
API endpoints per gestione articoli
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List, Optional

from app.core.database import get_db
from app.models.articles import Articolo
from app.schemas.articles import ArticoloCreate

router = APIRouter(prefix="/articles", tags=["Articles Management"])


@router.get("/health")
async def health_check():
    return {"status": "healthy", "service": "articles", "version": "1.0"}


@router.get("/")
async def get_articles(
    search: str = "",
    tipo_prodotto: str = "",
    db: Session = Depends(get_db)
):
    try:
        base_query = """
        SELECT 
            a.*, 
            u.username as responsabile_username, u.email as responsabile_email,
            CASE 
                WHEN u.first_name IS NOT NULL AND u.last_name IS NOT NULL 
                THEN u.first_name || ' ' || u.last_name
                WHEN u.name IS NOT NULL AND u.surname IS NOT NULL 
                THEN u.name || ' ' || u.surname
                ELSE u.username
            END as responsabile_display_name
        FROM articoli a
        LEFT JOIN users u ON a.responsabile_user_id = u.id
        WHERE a.attivo = true
        """

        params = {}

        if search:
            base_query += " AND (a.nome ILIKE :search OR a.codice ILIKE :search)"
            params["search"] = f"%{search}%"

        if tipo_prodotto:
            base_query += " AND a.tipo_prodotto = :tipo_prodotto"
            params["tipo_prodotto"] = tipo_prodotto

        base_query += " ORDER BY a.created_at DESC"

        result = db.execute(text(base_query), params)
        articles = []

        for row in result:
            articles.append({
                "id": row.id,
                "codice": row.codice,
                "nome": row.nome,
                "descrizione": row.descrizione,
                "tipo_prodotto": row.tipo_prodotto,
                "partner_id": row.partner_id,
                "prezzo_base": float(row.prezzo_base) if row.prezzo_base else None,
                "durata_mesi": row.durata_mesi,
                "attivo": row.attivo,
                "tipologia_servizio_id": row.tipologia_servizio_id,
                "responsabile_user_id": str(row.responsabile_user_id) if row.responsabile_user_id else None,
                "modello_ticket_id": str(row.modello_ticket_id) if row.modello_ticket_id else None,
                "art_code": row.art_code,
                "art_description": row.art_description,
                "art_kit": row.art_kit,
                "created_at": row.created_at.isoformat() if row.created_at else None,
                "updated_at": row.updated_at.isoformat() if row.updated_at else None,
                "responsabile_username": row.responsabile_username,
                "responsabile_email": row.responsabile_email,
                "responsabile_display_name": row.responsabile_display_name
            })

        return {"success": True, "count": len(articles), "articles": articles}
    except Exception as e:
        return {"success": False, "error": str(e)}


@router.post("/", status_code=201)
async def create_article(article: ArticoloCreate, db: Session = Depends(get_db)):
    """Crea un nuovo articolo"""
    try:
        nuovo_articolo = Articolo(
            codice=article.codice,
            nome=article.nome,
            descrizione=article.descrizione,
            tipo_prodotto=article.tipo_prodotto,
            prezzo_base=article.prezzo_base,
            durata_mesi=article.durata_mesi,
            attivo=article.attivo,
            tipologia_servizio_id=article.tipologia_servizio_id,
            partner_id=article.partner_id,
            responsabile_user_id=article.responsabile_user_id,
            modello_ticket_id=article.modello_ticket_id,
            art_code=article.art_code or article.codice,
            art_description=article.art_description or article.nome,
            art_kit=article.art_kit
        )
        db.add(nuovo_articolo)
        db.commit()
        db.refresh(nuovo_articolo)

        # Recupera dati responsabile
        responsabile_info = {
            "responsabile_username": None,
            "responsabile_email": None,
            "responsabile_display_name": None
        }

        if nuovo_articolo.responsabile_user_id:
            result = db.execute(text("""
                SELECT username, email,
                CASE 
                    WHEN first_name IS NOT NULL AND last_name IS NOT NULL 
                    THEN first_name || ' ' || last_name
                    WHEN name IS NOT NULL AND surname IS NOT NULL 
                    THEN name || ' ' || surname
                    ELSE username
                END as display_name
                FROM users
                WHERE id = :uid
            """), {"uid": str(nuovo_articolo.responsabile_user_id)}).fetchone()

            if result:
                responsabile_info = {
                    "responsabile_username": result.username,
                    "responsabile_email": result.email,
                    "responsabile_display_name": result.display_name
                }

        return {
            "success": True,
            "message": "Articolo creato con successo",
            "article": {
                **nuovo_articolo.to_dict(),
                **responsabile_info
            }
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Errore creazione articolo: {str(e)}")

@router.get("/users-disponibili")
async def get_users_disponibili(db: Session = Depends(get_db)):
    """Lista utenti per assegnazione responsabilità servizi"""
    try:
        query = text("""
        SELECT id, username, email, first_name, last_name, name, surname, role, is_active
        FROM users 
        WHERE is_active = true 
        ORDER BY 
            CASE 
                WHEN first_name IS NOT NULL AND last_name IS NOT NULL 
                THEN first_name || ' ' || last_name
                WHEN name IS NOT NULL AND surname IS NOT NULL 
                THEN name || ' ' || surname
                ELSE username
            END
        """)

        result = db.execute(query)
        users = []

        for row in result:
            display_name = None
            if row.first_name and row.last_name:
                display_name = f"{row.first_name} {row.last_name}"
            elif row.name and row.surname:
                display_name = f"{row.name} {row.surname}"
            else:
                display_name = row.username

            users.append({
                "id": str(row.id),
                "username": row.username,
                "email": row.email,
                "display_name": display_name,
                "role": row.role,
                "is_active": row.is_active
            })

        return {
            "success": True,
            "count": len(users),
            "users": users
        }

    except Exception as e:
        return {"success": False, "error": str(e)}
