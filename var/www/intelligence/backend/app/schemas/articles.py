from pydantic import BaseModel
from typing import Optional
from uuid import UUID

class ArticoloCreate(BaseModel):
    codice: str
    nome: str
    descrizione: Optional[str]
    tipo_prodotto: str
    prezzo_base: Optional[float]
    durata_mesi: Optional[int]
    attivo: Optional[bool] = True
    tipologia_servizio_id: Optional[int]
    partner_id: Optional[int]
    responsabile_user_id: Optional[UUID]
    modello_ticket_id: Optional[UUID]
    art_code: Optional[str]
    art_description: Optional[str]
    art_kit: Optional[bool] = False
