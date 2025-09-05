from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from app.core.database import get_db
from app.models.kit_commerciali_db import KitCommerciale
from app.models.kit_articoli import KitArticoloSchema
from app.models.articles import Articolo
from app.models.partner import Partner
from app.models.ticket_templates import ModelloTicket
from app.models.kit_commerciali_db import KitArticoloDB
from typing import Dict, Any
from fastapi import APIRouter, Depends, HTTPException
from app.routes.auth import get_current_user_from_jwt as get_current_user

router = APIRouter(prefix="/kit-articoli", tags=["Kit Articoli"])

@router.get("/by-articolo/{articolo_id}")
def get_kit_servizi_by_articolo(articolo_id: int, db: Session = Depends(get_db)):
    try:
        kit = db.query(KitCommerciale).filter(KitCommerciale.articolo_principale_id == articolo_id).first()
        
        if not kit:
            # Fallback: cerca se l'articolo è usato in kit_articoli
            ka = db.query(KitArticoloDB).filter(KitArticoloDB.articolo_id == articolo_id).first()
            if ka:
                kit = db.query(KitCommerciale).filter(KitCommerciale.id == ka.kit_commerciale_id).first()
        
        if not kit:
            return {"success": True, "count": 0, "servizi": []}
        
        servizi = db.query(KitArticoloDB).filter(KitArticoloDB.kit_commerciale_id == kit.id).order_by(KitArticoloDB.ordine).all()

        result = []
        for s in servizi:
            articolo = db.query(Articolo).filter(Articolo.id == s.articolo_id).first()
            partner = db.query(Partner).filter(Partner.id == s.partner_id).first() if s.partner_id else None
            modello = db.query(ModelloTicket).filter(ModelloTicket.id == s.modello_ticket_id).first() if s.modello_ticket_id else None

            result.append({
                "id": s.id,
                "articolo_id": s.articolo_id,
                "nome_articolo": articolo.nome if articolo else None,
                "quantita": s.quantita,
                "obbligatorio": s.obbligatorio,
                "ordine": s.ordine,
                "partner_id": s.partner_id,
                "partner_nome": partner.nome if partner else None,
                "modello_ticket_id": str(s.modello_ticket_id) if s.modello_ticket_id else None,
                "modello_ticket_nome": modello.nome if modello else None,
                "note": s.note
            })

        return {"success": True, "count": len(result), "servizi": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/kit-articoli/{id}", response_model=Dict[str, Any], dependencies=[Depends(get_current_user)])
def delete_kit_articolo(id: int, db: Session = Depends(get_db)):
    ka = db.query(KitArticoloDB).filter(KitArticoloDB.id == id).first()
    if not ka:
        raise HTTPException(status_code=404, detail="KitArticolo not found")
    db.delete(ka)
    db.commit()
    return {"success": True, "message": f"KitArticolo {id} deleted"}
