"""
Intelligence AI Platform - Articles Model (ER Compatible)
Gestione articoli con nuovo schema ER
"""
from sqlalchemy import Column, Integer, String, Text, Boolean, UUID, ForeignKey, Numeric
from sqlalchemy.orm import relationship
from app.models.base import BaseModel

class Articolo(BaseModel):
    __tablename__ = "articoli"

    codice = Column(String(10), unique=True, nullable=False, index=True)
    nome = Column(String(200), nullable=False)
    descrizione = Column(Text)
    tipo_prodotto = Column(String(20), nullable=False)
    partner_id = Column(Integer, ForeignKey("partner.id"), nullable=True)
    attivo = Column(Boolean, default=True)
    partner = relationship("Partner", back_populates="articoli")
    # ✅ Campi mancanti
    prezzo_base = Column(Numeric(10, 2))
    durata_mesi = Column(Integer)
    tipologia_servizio_id = Column(Integer, ForeignKey("tipologie_servizi.id"))
    responsabile_user_id = Column(UUID, ForeignKey("users.id", ondelete="SET NULL"))
    modello_ticket_id = Column(UUID, ForeignKey("modelli_ticket.id", ondelete="SET NULL"))

    tipo_commessa_legacy_id = Column(UUID, ForeignKey("tipi_commesse.id"))
    sla_default_hours = Column(Integer, default=48)
    template_milestones = Column(Text)

    art_kit = Column(Boolean, default=False)
    art_code = Column(String(10))
    art_description = Column(String(200))

    def __repr__(self):
        return f"<Articolo {self.codice}: {self.nome} ({'Kit' if self.art_kit else 'Standard'})>"

    def to_dict(self):
        return {
            'id': self.id,
            'codice': self.codice,
            'nome': self.nome,
            'descrizione': self.descrizione,
            'tipo_prodotto': self.tipo_prodotto,
            'partner_id': self.partner_id,
            'attivo': self.attivo,
            'prezzo_base': float(self.prezzo_base) if self.prezzo_base else None,
            'durata_mesi': self.durata_mesi,
            'tipologia_servizio_id': self.tipologia_servizio_id,
            'responsabile_user_id': str(self.responsabile_user_id) if self.responsabile_user_id else None,
            'modello_ticket_id': str(self.modello_ticket_id) if self.modello_ticket_id else None,
            'tipo_commessa_legacy_id': str(self.tipo_commessa_legacy_id) if self.tipo_commessa_legacy_id else None,
            'sla_default_hours': self.sla_default_hours,
            'template_milestones': self.template_milestones,
            'art_code': self.art_code or self.codice,
            'art_description': self.art_description or self.nome,
            'art_kit': self.art_kit,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }
