from sqlalchemy import Column, Integer, ForeignKey, Boolean, Text, UUID
from sqlalchemy.orm import relationship
from app.models.base import BaseModel

class KitArticoloSchema(BaseModel):
    __tablename__ = "kit_articoli"
    __table_args__ = {'extend_existing': True}

    kit_commerciale_id = Column(Integer, ForeignKey("kit_commerciali.id", ondelete="CASCADE"))
    articolo_id = Column(Integer, ForeignKey("articoli.id"))
    quantita = Column(Integer, default=1)
    obbligatorio = Column(Boolean, default=False)
    ordine = Column(Integer, default=0)

    partner_id = Column(Integer, ForeignKey("partner.id"), nullable=True)
    modello_ticket_id = Column(UUID, ForeignKey("modelli_ticket.id"), nullable=True)
    note = Column(Text)

    articolo = relationship("Articolo", lazy="joined")
    partner = relationship("Partner", lazy="joined")
    modello_ticket = relationship("ModelloTicket", lazy="joined")
