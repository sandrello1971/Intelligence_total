from sqlalchemy import Column, Text, Boolean, DateTime, String, Integer, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.sql import func
import uuid
from app.core.database import Base

class ModelloTicket(Base):
    __tablename__ = "modelli_ticket"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    nome = Column(Text, nullable=False)
    descrizione = Column(Text)
    workflow_template_id = Column(Integer, ForeignKey("workflow_templates.id"))
    priority = Column(String(20), default="medium")
    auto_assign_rules = Column(JSONB, default=dict)
    template_description = Column(Text)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
