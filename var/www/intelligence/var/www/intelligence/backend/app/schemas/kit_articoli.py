from pydantic import BaseModel
from typing import Optional
from uuid import UUID

class KitArticoloCreate(BaseModel):
    kit_commerciale_id: int
    articolo_id: int
    quantita: Optional[int] = 1
    obbligatorio: Optional[bool] = False
    ordine: Optional[int] = 0
    partner_id: Optional[int] = None
    modello_ticket_id: Optional[UUID] = None
    note: Optional[str] = None

class KitArticoloOut(KitArticoloCreate):
    id: int

    class Config:
        orm_mode = True
