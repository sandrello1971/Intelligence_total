# 🧠 IntelligenceHub – Stato progetto (Ticketing + Workflow CRM)
📅 Aggiornato: 2025-08-04

---

## 🔧 Obiettivo

Costruire un sistema modulare di ticketing e orchestrazione operativa, integrato con un CRM (es. CRM in Cloud), in grado di:
- Creare flussi operativi da attività CRM
- Espandere kit commerciali in opportunità e ticket figli
- Tracciare KPI e milestones operative
- Supportare trigger manuali da parte dell’operatore

---

## 📦 Architettura Logica

```plaintext
📌 Ticket PADRE (da attività CRM)
 └─ 1 milestone (Onboarding)
     └─ 4 task standard (firma, invio, onboarding...)

✅ Chiusura task = chiusura milestone = ticket padre chiuso

🟡 Pulsante: "Genera Opportunità"
 └─ Opportunità CRM → 1 per ogni servizio del kit

🟠 Pulsante: "Sincronizza Opportunità"
 └─ Per ogni opportunità → crea Ticket figlio:
      - Workflow completo
      - Milestones (multiple)
      - Tasks operativi

🟣 Pulsante: "Genera Attività CRM"
 └─ Per ogni milestone creata → attività CRM collegate all’opportunità

✅ Stato attuale
Componente	Stato	Note
workflow_generator.py	Esistente	Funziona ma genera solo 1 milestone
KitExpander	Da rifattorizzare	Presente nel vecchio sistema
CRMClient	Parziale	Alcuni endpoint su CRM da adattare
TicketFactory	Da creare	Per creare ticket figli da opportunità
ActivityGenerator	Da creare	Per milestone → crea attività CRM
Pulsanti UI (Vue.js)	Esistenti	Da replicare in React o mantenere lato admin

🔘 Pulsanti previsti (trigger manuali)
Pulsante	Endpoint previsto	Azione
Genera Opportunità	POST /tickets/{id}/generate-opportunities	Crea opportunità da kit
Sincronizza Opportunità	POST /crm/sync-opportunities	Scarica opportunità → crea ticket figli
Genera Attività CRM	POST /opportunities/{id}/generate-activities	Milestone → attività CRM

📁 Moduli in refactoring / da creare
🧩 WorkflowManager
✅ Genera ticket (1+ milestones, tasks)

✅ Scrittura in corso

🧩 KitExpander
🔄 Da rifattorizzare dal vecchio sistema

🔹 Funzione: generate_opportunities(ticket_id)

🧩 CRMClient
🔧 Wrapper per:

create_opportunity()

get_opportunities(company_id)

create_activity(opportunity_id, milestone_name)

🧩 TicketFactory
📌 Funzione: create_from_opportunity(opportunity)

🧩 ActivityGenerator
📌 Funzione: generate_from_milestone(milestone_id, opportunity_id)

🛠️ Prossimi passi (in ordine)
✳️ WorkflowManager completo (multi-milestone, multi-task)

✳️ KitExpander.generate_opportunities()

✳️ CRMClient

✳️ TicketFactory.create_from_opportunity()

✳️ ActivityGenerator.generate_from_milestone()

✳️ Endpoints FastAPI per ogni azione manuale
