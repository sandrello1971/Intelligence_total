#!/usr/bin/env python3

import logging
from datetime import datetime, timedelta
from uuid import uuid4
from typing import List, Dict, Optional
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
import sys

# Logging setup
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("workflow_manager")

# DB setup
DATABASE_URL = "postgresql://intelligence_user:intelligence_pass@localhost/intelligence"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

class WorkflowManager:
    def __init__(self, db: Session):
        self.db = db

    def get_activity(self, activity_id: int) -> Optional[Dict]:
        result = self.db.execute(text("""
            SELECT id, title, description, owner_id, customer_id
            FROM activities WHERE id = :activity_id
        """), {"activity_id": activity_id}).fetchone()
        return dict(result._mapping) if result else None

    def detect_kit_name_from_text(self, text_body: str) -> Optional[str]:
        results = self.db.execute(text("""
            SELECT nome FROM kit_commerciali WHERE attivo = true
        """)).fetchall()

        kit_names = [r.nome for r in results]
        logger.info(f"📦 Kit disponibili: {kit_names}")
        logger.info(f"📝 Testo attività: {text_body}")

        normalized_text = text_body.lower()

        # Match esatto case-insensitive
        for nome in kit_names:
            if nome.lower() in normalized_text:
                logger.info(f"✅ Match diretto trovato: {nome}")
                return nome

        # Match per parole chiave
        for nome in kit_names:
            keywords = nome.replace("Kit", "").strip().lower().split()
            if all(k in normalized_text for k in keywords):
                logger.info(f"🔍 Match parziale trovato: {nome}")
                return nome

        logger.warning("⚠️ Nessun match trovato per i kit nel testo")
        return None

    def get_kit_details(self, kit_name: str) -> Optional[Dict]:
        result = self.db.execute(text("""
            SELECT k.nome, a.id AS articolo_id, a.nome AS articolo_nome, a.responsabile_user_id
            FROM kit_commerciali k
            LEFT JOIN articoli a ON k.articolo_principale_id = a.id
            WHERE k.nome = :kit_name
            LIMIT 1
        """), {"kit_name": kit_name}).fetchone()
        return dict(result._mapping) if result else None

    def get_default_workflow(self) -> Optional[Dict]:
        result = self.db.execute(text("""
            SELECT id, nome FROM workflow_templates
            WHERE nome ILIKE 'workflow start' AND attivo = true LIMIT 1
        """)).fetchone()
        return dict(result._mapping) if result else None

    def get_milestones(self, workflow_id: int) -> List[Dict]:
        results = self.db.execute(text("""
            SELECT id, nome, ordine, sla_giorni, warning_giorni
            FROM workflow_milestones
            WHERE workflow_template_id = :workflow_id
            ORDER BY ordine
        """), {"workflow_id": workflow_id}).fetchall()
        return [dict(r._mapping) for r in results]

    def get_tasks_for_milestone(self, milestone_id: int) -> List[Dict]:
        results = self.db.execute(text("""
            SELECT id, nome, descrizione, ordine, durata_stimata_ore
            FROM milestone_task_templates
            WHERE milestone_id = :milestone_id
            ORDER BY ordine
        """), {"milestone_id": milestone_id}).fetchall()
        return [dict(r._mapping) for r in results]

    def create_ticket(self, activity: Dict, kit: Optional[Dict]) -> str:
        ticket_id = str(uuid4())
        self.db.execute(text("""
            INSERT INTO tickets (
                id, title, description, status, priority,
                created_at, updated_at, activity_id,
                articolo_id, assigned_to
            ) VALUES (
                :id, :title, :description, 'aperto', 'media',
                :created_at, :updated_at, :activity_id,
                :articolo_id, :assigned_to
            )
        """), {
            "id": ticket_id,
            "title": f"Ticket CRM #{activity['id']}",
            "description": activity.get("description", ""),
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
            "activity_id": activity["id"],
            "articolo_id": kit["articolo_id"] if kit else None,
            "assigned_to": kit["responsabile_user_id"] if kit and kit["responsabile_user_id"] else None
        })
        if not kit or not kit.get("responsabile_user_id"):
            logger.warning(f"⚠️ Nessun responsabile assegnato per il ticket {ticket_id}, task non assegnato")
        return ticket_id

    def create_milestone(self, milestone_template: Dict) -> str:
        milestone_id = str(uuid4())
        self.db.execute(text("""
            INSERT INTO milestones (
                id, title, stato, data_inizio, data_fine_prevista,
                workflow_milestone_id, sla_hours, warning_days,
                escalation_days, auto_generate_tickets
            ) VALUES (
                :id, :title, 'pianificata', :start, :end,
                :template_id, :sla, :warning, 1, false
            )
        """), {
            "id": milestone_id,
            "title": milestone_template["nome"],
            "start": datetime.utcnow(),
            "end": datetime.utcnow() + timedelta(days=milestone_template.get("sla_giorni") or 5),
            "template_id": milestone_template["id"],
            "sla": (milestone_template.get("sla_giorni") or 5) * 24,
            "warning": milestone_template.get("warning_giorni", 2),
        })
        return milestone_id

    def link_ticket_to_milestone(self, ticket_id: str, milestone_id: str, workflow_milestone_id: int):
        self.db.execute(text("""
            UPDATE tickets SET milestone_id = :m_id, workflow_milestone_id = :w_id
            WHERE id = :ticket_id
        """), {
            "m_id": milestone_id,
            "w_id": workflow_milestone_id,
            "ticket_id": ticket_id
        })

    def create_task(self, ticket_id: str, milestone_id: str, task_template: Dict, assigned_to: Optional[str]):
        task_id = str(uuid4())
        due_date = datetime.utcnow().date() + timedelta(
            days=task_template.get("durata_stimata_ore", 8) // 24 or 1
        )
        self.db.execute(text("""
            INSERT INTO tasks (
                id, title, description, status,
                ticket_id, milestone_id, created_at, due_date,
                estimated_hours, ordine, priorita, task_template_id,
                assigned_to
            ) VALUES (
                :id, :title, :desc, 'todo',
                :ticket_id, :milestone_id, :created, :due,
                :hours, :ordine, 'normale', :template_id,
                :assigned_to
            )
        """), {
            "id": task_id,
            "title": task_template["nome"],
            "desc": task_template.get("descrizione", ""),
            "ticket_id": ticket_id,
            "milestone_id": milestone_id,
            "created": datetime.utcnow(),
            "due": due_date,
            "hours": task_template.get("durata_stimata_ore", 8),
            "ordine": task_template.get("ordine", 0),
            "template_id": task_template["id"],
            "assigned_to": assigned_to
        })

    def run(self, activity_id: int) -> Dict:
        stats = {"ticket": None, "milestones": 0, "tasks": 0, "error": None}
        try:
            activity = self.get_activity(activity_id)
            if not activity:
                raise Exception(f"Attività {activity_id} non trovata")

            full_text = f"{activity['title']} {activity['description']}"
            kit_name = self.detect_kit_name_from_text(full_text)
            if not kit_name:
                raise Exception("Kit commerciale non identificato")

            kit = self.get_kit_details(kit_name)
            workflow = self.get_default_workflow()
            if not workflow:
                raise Exception("Workflow di default non trovato")

            ticket_id = self.create_ticket(activity, kit)
            stats["ticket"] = ticket_id

            milestones = self.get_milestones(workflow["id"])
            for m in milestones:
                milestone_id = self.create_milestone(m)
                if stats["milestones"] == 0:
                    self.link_ticket_to_milestone(ticket_id, milestone_id, m["id"])
                stats["milestones"] += 1

                for t in self.get_tasks_for_milestone(m["id"]):
                    self.create_task(ticket_id, milestone_id, t, kit.get("responsabile_user_id") if kit else None)
                    stats["tasks"] += 1

            self.db.commit()
            logger.info(f"✅ Workflow completato: {stats}")
        except Exception as e:
            self.db.rollback()
            stats["error"] = str(e)
            logger.error(f"❌ Errore generazione workflow: {e}")
        return stats

# CLI
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python workflow_manager.py <activity_id>")
        sys.exit(1)

    try:
        activity_id = int(sys.argv[1])
    except ValueError:
        logger.error("❌ L'ID attività deve essere un intero.")
        sys.exit(1)

    db = SessionLocal()
    try:
        wm = WorkflowManager(db)
        result = wm.run(activity_id)
        print(result)
    finally:
        db.close()
