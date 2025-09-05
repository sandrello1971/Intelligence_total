"""
Business Cards model for OCR processing
"""
from sqlalchemy import Column, String, Text, JSON, Float, DateTime
#from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .base import Base

class BusinessCard(Base):
    __tablename__ = "business_cards"
    
    id = Column(String, primary_key=True)  # UUID
    filename = Column(String, nullable=False)
    image_data = Column(Text, nullable=True)  # Base64 encoded
    extracted_data = Column(JSON, nullable=True)  # OCR results
    raw_text = Column(Text, nullable=True)
    confidence_score = Column(Float, default=0.0)
    processing_time = Column(Float, default=0.0)
    status = Column(String, default="processing")  # processing, completed, failed
    created_at = Column(DateTime, default=func.now())
    created_by = Column(String(255), nullable=True)
    
    # Relationships
#    contacts = relationship("Contact", back_populates="business_card")
