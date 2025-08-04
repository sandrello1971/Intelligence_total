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
-- Name: modelli_ticket; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.modelli_ticket (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    descrizione text,
    workflow_template_id integer,
    priority character varying(20) DEFAULT 'media'::character varying,
    sla_hours integer DEFAULT 24,
    auto_assign_rules jsonb DEFAULT '{}'::jsonb,
    template_description text,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.modelli_ticket OWNER TO intelligence_user;

--
-- Data for Name: modelli_ticket; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.modelli_ticket (id, nome, descrizione, workflow_template_id, priority, sla_hours, auto_assign_rules, template_description, is_active, created_at) FROM stdin;
e702be72-3af2-4caa-be36-1d4b086da0fc	test	test	\N	medium	24	{}	\N	f	2025-07-25 14:03:51.591969
9df2b775-c63e-4468-89b5-21ff0a8da4af	test	test	\N	medium	24	{}	\N	f	2025-07-25 14:04:23.740121
aaa88533-b160-48ae-9bb4-0a253422119a	prova - Copia	\N	1	medium	104	{}	\N	f	2025-07-25 14:38:43.700803
a23c9b78-530e-4c7d-be87-6479a7a7336e	provaxxx		1	medium	104	{}	\N	f	2025-07-25 14:41:42.403088
7a324655-f0b4-4166-b4ae-ccc6a0d1c738	Ticket Start	Inizio pratiche per gestione firma incarichi	1	medium	24	{}	\N	t	2025-07-28 17:56:50.297537
bfe2a8f4-01e3-4c5f-8e20-4c39fdc96c4e	provaxxx		1	medium	104	{}	\N	f	2025-07-25 14:38:38.540987
\.


--
-- Name: modelli_ticket modelli_ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.modelli_ticket
    ADD CONSTRAINT modelli_ticket_pkey PRIMARY KEY (id);


--
-- Name: modelli_ticket modelli_ticket_workflow_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.modelli_ticket
    ADD CONSTRAINT modelli_ticket_workflow_template_id_fkey FOREIGN KEY (workflow_template_id) REFERENCES public.workflow_templates(id);


--
-- PostgreSQL database dump complete
--

