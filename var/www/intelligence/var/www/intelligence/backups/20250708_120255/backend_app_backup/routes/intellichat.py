from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
import openai
import json
import time
import uuid
from datetime import datetime

from app.core.database import get_db
from app.routes.auth import get_current_user_dep
from app.schemas.intellichat import (
    ChatRequest, ChatResponse, DocumentContext, 
    ConversationHistory, DocumentSummary, ChatMessage
)
from app.models.users import User
from app.models.knowledge import KnowledgeDocument, DocumentChunk
from app.models.ai_conversation import AIConversation
from app.modules.rag_engine.vector_service import VectorRAGService

router = APIRouter(prefix="/intellichat", tags=["intellichat"])

# Initialize RAG service
rag_service = VectorRAGService()

@router.post("/chat", response_model=ChatResponse)
async def chat_with_rag(
    request: ChatRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_dep)
):
    """Chat con RAG integration - Come ChatGPT/Claude ma sui documenti aziendali"""
    start_time = time.time()
    
    try:
        # 1. Ricerca documenti rilevanti se richiesto
        sources = []
        context_text = ""
        
        if request.include_documents:
            # Ricerca semantica nei documenti
            search_results = await rag_service.search_documents(
                query=request.message,
                company_id=request.company_id,
                limit=request.max_context_docs
            )
            
            # Prepara contesto dai documenti
            for result in search_results:
                doc_context = DocumentContext(
                    document_id=result.get('document_id'),
                    filename=result.get('filename', 'Unknown'),
                    relevance_score=result.get('score', 0.0),
                    matched_content=result.get('content', ''),
                    page_number=result.get('page_number')
                )
                sources.append(doc_context)
                context_text += f"\n--- {result.get('filename')} ---\n{result.get('content')}\n"
        
        # 2. Prepara prompt per AI con contesto documenti
        system_prompt = f"""Sei un assistente AI aziendale intelligente come ChatGPT/Claude. 
        
CAPACITÀ:
- Rispondi domande sui documenti aziendali caricati
- Riassumi contenuti e identifica argomenti principali
- Esegui calcoli matematici contenuti nei documenti
- Analizza dati e fornisci insights
- Mantieni conversazioni naturali e professionali

DOCUMENTI DISPONIBILI:
{context_text if context_text else "Nessun documento rilevante trovato per questa domanda."}

ISTRUZIONI:
- Se la domanda riguarda i documenti, usa SOLO le informazioni fornite
- Se richiesti calcoli, mostra i passaggi
- Se richiesti riassunti, elenca i punti chiave
- Se non trovi informazioni nei documenti, dillo chiaramente
- Cita sempre le fonti quando usi informazioni dai documenti
- Rispondi in italiano professionale ma amichevole"""

        # 3. Genera conversation_id se non fornito
        conversation_id = request.conversation_id or str(uuid.uuid4())
        
        # 4. Recupera storico conversazione se esiste
        conversation_history = []
        if request.conversation_id:
            existing_conv = db.query(AIConversation).filter(
                AIConversation.conversation_id == request.conversation_id
            ).first()
            if existing_conv and existing_conv.messages:
                conversation_history = existing_conv.messages
        
        # 5. Prepara messaggi per OpenAI
        messages = [{"role": "system", "content": system_prompt}]
        
        # Aggiungi storico conversazione
        for msg in conversation_history[-10:]:  # Ultimi 10 messaggi
            messages.append({
                "role": msg.get("role", "user"),
                "content": msg.get("content", "")
            })
        
        # Aggiungi messaggio corrente
        messages.append({"role": "user", "content": request.message})
        
        # 6. Chiamata a OpenAI
        openai_response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=messages,
            max_tokens=1500,
            temperature=0.1,
            top_p=0.9
        )
        
        ai_response = openai_response.choices[0].message.content
        tokens_used = openai_response.usage.total_tokens
        
        # 7. Salva conversazione nel database
        new_messages = conversation_history + [
            {
                "role": "user",
                "content": request.message,
                "timestamp": datetime.now().isoformat(),
                "metadata": {"sources_count": len(sources)}
            },
            {
                "role": "assistant", 
                "content": ai_response,
                "timestamp": datetime.now().isoformat(),
                "metadata": {"tokens_used": tokens_used}
            }
        ]
        
        # Salva o aggiorna conversazione
        conversation = db.query(AIConversation).filter(
            AIConversation.conversation_id == conversation_id
        ).first()
        
        if conversation:
            conversation.messages = new_messages
            conversation.updated_at = datetime.now()
        else:
            conversation = AIConversation(
                conversation_id=conversation_id,
                user_id=current_user.id,
                company_id=request.company_id,
                messages=new_messages,
                created_at=datetime.now(),
                updated_at=datetime.now()
            )
            db.add(conversation)
        
        db.commit()
        
        # 8. Calcola tempo di processamento
        processing_time = time.time() - start_time
        
        return ChatResponse(
            response=ai_response,
            conversation_id=conversation_id,
            sources=sources,
            ai_model="gpt-4",
            processing_time=processing_time,
            tokens_used=tokens_used
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Errore chat: {str(e)}")

@router.get("/conversations", response_model=List[ConversationHistory])
async def get_conversations(
    company_id: Optional[int] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_dep)
):
    """Recupera storico conversazioni"""
    query = db.query(AIConversation).filter(AIConversation.user_id == current_user.id)
    
    if company_id:
        query = query.filter(AIConversation.company_id == company_id)
    
    conversations = query.order_by(AIConversation.updated_at.desc()).limit(20).all()
    
    result = []
    for conv in conversations:
        messages = [
            ChatMessage(
                role=msg.get("role", "user"),
                content=msg.get("content", ""),
                timestamp=datetime.fromisoformat(msg.get("timestamp", datetime.now().isoformat())),
                metadata=msg.get("metadata")
            )
            for msg in conv.messages
        ]
        
        result.append(ConversationHistory(
            conversation_id=conv.conversation_id,
            messages=messages,
            company_id=conv.company_id,
            created_at=conv.created_at,
            updated_at=conv.updated_at
        ))
    
    return result

@router.get("/document-summary/{document_id}", response_model=DocumentSummary)
async def get_document_summary(
    document_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_dep)
):
    """Genera riassunto intelligente di un documento"""
    
    # Recupera documento
    document = db.query(KnowledgeDocument).filter(
        KnowledgeDocument.id == document_id
    ).first()
    
    if not document:
        raise HTTPException(status_code=404, detail="Documento non trovato")
    
    # Recupera chunks del documento
    chunks = db.query(DocumentChunk).filter(
        DocumentChunk.document_id == document_id
    ).all()
    
    # Prepara testo completo
    full_text = "\n".join([chunk.content for chunk in chunks])
    
    # Genera riassunto con AI
    summary_prompt = f"""Analizza questo documento e fornisci:

DOCUMENTO: {document.filename}
CONTENUTO:
{full_text}

RICHIESTO:
1. ARGOMENTI PRINCIPALI (3-5 punti)
2. PUNTI CHIAVE (5-7 punti)
3. CONTENUTO MATEMATICO (formule, calcoli, numeri importanti)
4. TIPO DI DOCUMENTO (contratto, report, manuale, etc.)

Rispondi in formato JSON:
{{
    "main_topics": ["topic1", "topic2", ...],
    "key_points": ["point1", "point2", ...],
    "mathematical_content": ["formula1", "calcolo1", ...],
    "document_type": "tipo_documento",
    "confidence_score": 0.95
}}"""

    try:
        openai_response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[{"role": "user", "content": summary_prompt}],
            max_tokens=800,
            temperature=0.1
        )
        
        ai_response = openai_response.choices[0].message.content
        
        # Parse JSON response
        try:
            summary_data = json.loads(ai_response)
        except:
            # Fallback se JSON parsing fallisce
            summary_data = {
                "main_topics": ["Analisi non riuscita"],
                "key_points": ["Impossibile analizzare il documento"],
                "mathematical_content": [],
                "document_type": "unknown",
                "confidence_score": 0.0
            }
        
        return DocumentSummary(
            document_id=document_id,
            filename=document.filename,
            main_topics=summary_data.get("main_topics", []),
            key_points=summary_data.get("key_points", []),
            mathematical_content=summary_data.get("mathematical_content"),
            document_type=summary_data.get("document_type", "unknown"),
            confidence_score=summary_data.get("confidence_score", 0.0)
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Errore generazione riassunto: {str(e)}")

@router.delete("/conversation/{conversation_id}")
async def delete_conversation(
    conversation_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_dep)
):
    """Elimina conversazione"""
    conversation = db.query(AIConversation).filter(
        AIConversation.conversation_id == conversation_id,
        AIConversation.user_id == current_user.id
    ).first()
    
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversazione non trovata")
    
    db.delete(conversation)
    db.commit()
    
    return {"message": "Conversazione eliminata"}

@router.get("/health")
async def intellichat_health():
    """Health check intellichat"""
    return {
        "status": "healthy",
        "rag_service": "active",
        "ai_model": "gpt-4",
        "timestamp": datetime.now().isoformat()
    }

@router.post("/query-database")
async def query_database(
    request: ChatRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user_dep)
):
    """Query database e presenta dati elaborati"""
    
    # Sistema per interpretare richieste database
    db_prompt = f"""Sei un assistente AI che può interrogare il database aziendale.
    
    DOMANDA UTENTE: {request.message}
    
    TABELLE DISPONIBILI:
    - users: gestione utenti
    - companies: aziende clienti  
    - commesse: progetti aziendali
    - milestones: tappe progetti
    - tickets: sistema ticketing
    - tasks: attività operative
    
    CAPACITÀ:
    - Estrai dati dal database
    - Calcola statistiche e metriche
    - Genera report personalizzati
    - Identifica trend e pattern
    - Fornisci insights business
    
    Cosa vuoi sapere dal database?"""
    
    try:
        # Logica per interpretare la richiesta e fare query appropriate
        response_data = {
            "message": "Funzionalità database query in sviluppo",
            "query_type": "database",
            "available_soon": True
        }
        
        return {
            "response": f"Ho capito che vuoi interrogare il database. Questa funzionalità sarà disponibile a breve. Nel frattempo posso aiutarti con i documenti caricati.",
            "conversation_id": str(uuid.uuid4()),
            "sources": [],
            "ai_model": "gpt-4",
            "processing_time": 0.1,
            "tokens_used": 0
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Errore query database: {str(e)}")
