--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13
-- Dumped by pg_dump version 16.9 (Ubuntu 16.9-0ubuntu0.24.10.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tickets; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.tickets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_id bigint,
    title text,
    description text,
    status text,
    priority text,
    created_at timestamp without time zone DEFAULT now(),
    created_by uuid,
    opportunity_id uuid,
    modello_ticket_id uuid,
    milestone_id uuid,
    sla_deadline timestamp without time zone,
    metadata jsonb DEFAULT '{}'::jsonb,
    commessa_id uuid,
    assigned_to uuid,
    activity_id integer,
    articolo_id integer,
    workflow_milestone_id integer,
    ticket_code character varying(50),
    due_date timestamp without time zone,
    updated_at timestamp without time zone,
    note text
);


ALTER TABLE public.tickets OWNER TO intelligence_user;

--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.tickets (id, company_id, title, description, status, priority, created_at, created_by, opportunity_id, modello_ticket_id, milestone_id, sla_deadline, metadata, commessa_id, assigned_to, activity_id, articolo_id, workflow_milestone_id, ticket_code, due_date, updated_at, note) FROM stdin;
371ad43e-0933-414b-bc5c-b78a85bace4a	1740449	Kit Start Office Finance - Cliente	Ticket generato automaticamente da CRM Intelligence\n\n🎯 Kit Commerciale: Kit Start Office Finance\n📋 Servizio: Start Office Finance (STF)\n🏢 Cliente: N/A\n👤 Account Manager: Intelligence HUB\n⚡ Workflow: Workflow start\n\n📝 Descrizione originale:\ndobbiamo creare uno startoffice finance per il cliente Ducati Fake\n\n🔄 Workflow automatico attivato con milestone e task operativi.\n	aperto	media	2025-08-04 07:10:51.295353	35f6852d-c9bd-4736-8314-23c9494c8a79	\N	\N	85bccfdd-08d8-405a-bec2-28ab4b17e7dc	\N	{}	\N	2ffdbe6d-0d90-4e7f-bf8d-d45d50ee625f	86	10	3	TCK-STF-4246-00	2025-08-11 07:10:51.295337	2025-08-04 07:10:51.295357	\N
ad683918-829c-464c-b389-e9e91ccde23b	1740449	Kit Start Office Finance - Cliente	Ticket generato automaticamente da CRM Intelligence\n\n🎯 Kit Commerciale: Kit Start Office Finance\n📋 Servizio: Start Office Finance (STF)\n🏢 Cliente: N/A\n👤 Account Manager: Intelligence HUB\n⚡ Workflow: Workflow start\n\n📝 Descrizione originale:\ndobbiamo creare uno startoffice finance per il cliente Ducati Fake\n\n🔄 Workflow automatico attivato con milestone e task operativi.\n	aperto	media	2025-08-04 07:53:58.193274	35f6852d-c9bd-4736-8314-23c9494c8a79	\N	\N	ebb41111-cede-4830-a943-8e84824ddfb2	\N	{}	\N	2ffdbe6d-0d90-4e7f-bf8d-d45d50ee625f	86	10	3	TCK-STF-4246-00	2025-08-11 07:53:58.193252	2025-08-04 07:53:58.193278	\N
\.


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: idx_tickets_activity; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_tickets_activity ON public.tickets USING btree (activity_id);


--
-- Name: idx_tickets_assigned; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_tickets_assigned ON public.tickets USING btree (assigned_to);


--
-- Name: idx_tickets_commessa; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_tickets_commessa ON public.tickets USING btree (commessa_id);


--
-- Name: idx_tickets_sla; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_tickets_sla ON public.tickets USING btree (sla_deadline);


--
-- Name: tickets tickets_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activities(id);


--
-- Name: tickets tickets_articolo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_articolo_id_fkey FOREIGN KEY (articolo_id) REFERENCES public.articoli(id);


--
-- Name: tickets tickets_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: tickets tickets_commessa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_commessa_id_fkey FOREIGN KEY (commessa_id) REFERENCES public.commesse(id);


--
-- Name: tickets tickets_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: tickets tickets_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: tickets tickets_milestone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_milestone_id_fkey FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE SET NULL;


--
-- Name: tickets tickets_modello_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_modello_ticket_id_fkey FOREIGN KEY (modello_ticket_id) REFERENCES public.modelli_ticket(id) ON DELETE SET NULL;


--
-- Name: tickets tickets_opportunity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_opportunity_id_fkey FOREIGN KEY (opportunity_id) REFERENCES public.opportunities(id) ON DELETE SET NULL;


--
-- Name: tickets tickets_workflow_milestone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_workflow_milestone_id_fkey FOREIGN KEY (workflow_milestone_id) REFERENCES public.workflow_milestones(id);


--
-- PostgreSQL database dump complete
--

