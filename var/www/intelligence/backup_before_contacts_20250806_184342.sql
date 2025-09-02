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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: intelligence_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO intelligence_user;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: intelligence_user
--

COMMENT ON SCHEMA public IS '';


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: intelligence_user
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO intelligence_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ai_conversations; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.ai_conversations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    session_id text,
    conversation_data jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.ai_conversations OWNER TO intelligence_user;

--
-- Name: articoli; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.articoli (
    id integer NOT NULL,
    codice character varying(10) NOT NULL,
    nome character varying(200) NOT NULL,
    descrizione text,
    tipo_prodotto character varying(20) DEFAULT 'semplice'::character varying NOT NULL,
    partner_id integer,
    prezzo_base numeric(10,2),
    durata_mesi integer,
    attivo boolean DEFAULT true,
    tipologia_servizio_id integer,
    responsabile_user_id uuid,
    modello_ticket_id uuid,
    art_code character varying(10),
    art_description character varying(200),
    art_kit boolean DEFAULT false,
    tipo_commessa_legacy_id uuid,
    sla_default_hours integer DEFAULT 48,
    template_milestones text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.articoli OWNER TO intelligence_user;

--
-- Name: articoli_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.articoli_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.articoli_id_seq OWNER TO intelligence_user;

--
-- Name: articoli_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.articoli_id_seq OWNED BY public.articoli.id;


--
-- Name: bi_cache; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.bi_cache (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    cache_key text NOT NULL,
    cache_data jsonb,
    expires_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.bi_cache OWNER TO intelligence_user;

--
-- Name: business_cards; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.business_cards (
    id character varying NOT NULL,
    filename character varying(255) NOT NULL,
    original_filename character varying(255),
    extracted_data json,
    confidence_score double precision,
    nome character varying(255),
    cognome character varying(255),
    azienda character varying(255),
    posizione character varying(255),
    email character varying(255),
    telefono character varying(100),
    indirizzo text,
    status character varying(50),
    processing_error text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    processed_at timestamp with time zone,
    company_id integer,
    contact_id integer
);


ALTER TABLE public.business_cards OWNER TO intelligence_user;

--
-- Name: commesse; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.commesse (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_id integer,
    name text NOT NULL,
    codice text,
    descrizione text,
    stato text DEFAULT 'attiva'::text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    client_id integer,
    owner_id uuid,
    budget numeric(15,2),
    data_inizio date,
    data_fine_prevista date,
    status character varying(50) DEFAULT 'active'::character varying,
    sla_default_hours integer DEFAULT 48,
    metadata jsonb DEFAULT '{}'::jsonb,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    kit_commerciale_id integer,
    commerciale_id uuid,
    tipo_commessa character varying(50) DEFAULT 'standard'::character varying,
    valore_contratto numeric(15,2),
    ord_date date,
    ord_description text,
    cst_id integer
);


ALTER TABLE public.commesse OWNER TO intelligence_user;

--
-- Name: companies; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.companies (
    id bigint NOT NULL,
    name text NOT NULL,
    partita_iva text,
    codice_fiscale text,
    indirizzo text,
    settore text,
    email text,
    telefono text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    is_partner boolean DEFAULT false,
    is_supplier boolean DEFAULT false,
    partner_category character varying(100),
    partner_description text,
    partner_expertise jsonb DEFAULT '[]'::jsonb,
    partner_rating double precision DEFAULT 0.0,
    partner_status character varying(50) DEFAULT 'active'::character varying,
    last_scraped_at timestamp without time zone,
    scraping_status character varying(50) DEFAULT 'pending'::character varying,
    ai_analysis_summary text
);


ALTER TABLE public.companies OWNER TO intelligence_user;

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.companies_id_seq OWNER TO intelligence_user;

--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: document_chunks; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.document_chunks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    document_id uuid,
    content text NOT NULL,
    chunk_index integer,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.document_chunks OWNER TO intelligence_user;

--
-- Name: kit_articoli; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.kit_articoli (
    id integer NOT NULL,
    kit_commerciale_id integer NOT NULL,
    articolo_id integer NOT NULL,
    quantita integer DEFAULT 1,
    obbligatorio boolean DEFAULT false,
    ordine integer DEFAULT 0
);


ALTER TABLE public.kit_articoli OWNER TO intelligence_user;

--
-- Name: kit_articoli_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.kit_articoli_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kit_articoli_id_seq OWNER TO intelligence_user;

--
-- Name: kit_articoli_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.kit_articoli_id_seq OWNED BY public.kit_articoli.id;


--
-- Name: kit_commerciali; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.kit_commerciali (
    id integer NOT NULL,
    nome character varying(200) NOT NULL,
    descrizione text,
    articolo_principale_id integer,
    attivo boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.kit_commerciali OWNER TO intelligence_user;

--
-- Name: kit_commerciali_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.kit_commerciali_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kit_commerciali_id_seq OWNER TO intelligence_user;

--
-- Name: kit_commerciali_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.kit_commerciali_id_seq OWNED BY public.kit_commerciali.id;


--
-- Name: knowledge_documents; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.knowledge_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    content text,
    source_url text,
    content_hash text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.knowledge_documents OWNER TO intelligence_user;

--
-- Name: milestones; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.milestones (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome character varying(255) NOT NULL,
    descrizione text,
    tipo_commessa_id text,
    data_inizio timestamp without time zone,
    data_fine_prevista timestamp without time zone,
    data_fine_effettiva timestamp without time zone,
    sla_hours integer DEFAULT 48,
    warning_days integer DEFAULT 3,
    escalation_days integer DEFAULT 7,
    auto_generate_tickets boolean DEFAULT false,
    template_data text,
    stato character varying(50) DEFAULT 'pianificata'::character varying,
    percentuale_completamento double precision DEFAULT 0.0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by text
);


ALTER TABLE public.milestones OWNER TO intelligence_user;

--
-- Name: modelli_task; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.modelli_task (
    id character varying NOT NULL,
    nome character varying(255) NOT NULL,
    descrizione text,
    descrizione_operativa text,
    sla_hours integer NOT NULL,
    priorita character varying(20),
    ordine integer,
    categoria character varying(100),
    tags character varying(500),
    is_required boolean,
    is_parallel boolean,
    dipendenze text,
    milestone_id integer,
    tipo_commessa_id character varying,
    auto_assign_logic text,
    notification_template text,
    is_active boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    created_by character varying,
    updated_by character varying
);


ALTER TABLE public.modelli_task OWNER TO intelligence_user;

--
-- Name: modelli_ticket; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.modelli_ticket (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    descrizione text,
    workflow_template_id integer,
    priority character varying(20) DEFAULT 'medium'::character varying,
    auto_assign_rules jsonb DEFAULT '{}'::jsonb,
    template_description text,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.modelli_ticket OWNER TO intelligence_user;

--
-- Name: partner; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.partner (
    id integer NOT NULL,
    nome character varying(200) NOT NULL,
    ragione_sociale character varying(200),
    email character varying(100),
    telefono character varying(20),
    attivo boolean DEFAULT true,
    servizi_count integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.partner OWNER TO intelligence_user;

--
-- Name: partner_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.partner_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.partner_id_seq OWNER TO intelligence_user;

--
-- Name: partner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.partner_id_seq OWNED BY public.partner.id;


--
-- Name: processing_queue; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.processing_queue (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    task_type text NOT NULL,
    task_data jsonb,
    status text DEFAULT 'pending'::text,
    priority integer DEFAULT 5,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    processed_at timestamp without time zone
);


ALTER TABLE public.processing_queue OWNER TO intelligence_user;

--
-- Name: system_health; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.system_health (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    service_name text NOT NULL,
    status text NOT NULL,
    metrics jsonb DEFAULT '{}'::jsonb,
    checked_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.system_health OWNER TO intelligence_user;

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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    opportunity_id uuid,
    modello_ticket_id uuid,
    milestone_id uuid,
    sla_deadline timestamp without time zone,
    metadata jsonb DEFAULT '{}'::jsonb,
    commessa_id uuid,
    assigned_to uuid,
    activity_id bigint,
    articolo_id integer,
    workflow_milestone_id bigint,
    ticket_code character varying(50),
    due_date timestamp without time zone,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tickets OWNER TO intelligence_user;

--
-- Name: tipi_commesse; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.tipi_commesse (
    id character varying NOT NULL,
    nome character varying(255) NOT NULL,
    codice character varying(50) NOT NULL,
    descrizione text,
    sla_default_hours integer NOT NULL,
    template_milestones text,
    template_tasks text,
    is_active boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone,
    created_by character varying,
    updated_by character varying,
    colore_ui character varying(7),
    icona character varying(50),
    priorita_ordinamento integer
);


ALTER TABLE public.tipi_commesse OWNER TO intelligence_user;

--
-- Name: tipologie_servizi; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.tipologie_servizi (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    descrizione text,
    colore character varying(7) DEFAULT '#3b82f6'::character varying,
    icona character varying(50) DEFAULT 'star'::character varying,
    attivo boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tipologie_servizi OWNER TO intelligence_user;

--
-- Name: tipologie_servizi_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.tipologie_servizi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tipologie_servizi_id_seq OWNER TO intelligence_user;

--
-- Name: tipologie_servizi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.tipologie_servizi_id_seq OWNED BY public.tipologie_servizi.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username text NOT NULL,
    email text NOT NULL,
    password_hash text,
    role text DEFAULT 'operator'::text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    name text,
    surname text,
    first_name character varying(100),
    last_name character varying(100),
    permissions jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true,
    last_login timestamp without time zone,
    must_change_password boolean DEFAULT false,
    crm_id integer
);


ALTER TABLE public.users OWNER TO intelligence_user;

--
-- Name: articoli id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli ALTER COLUMN id SET DEFAULT nextval('public.articoli_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: kit_articoli id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.kit_articoli ALTER COLUMN id SET DEFAULT nextval('public.kit_articoli_id_seq'::regclass);


--
-- Name: kit_commerciali id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.kit_commerciali ALTER COLUMN id SET DEFAULT nextval('public.kit_commerciali_id_seq'::regclass);


--
-- Name: partner id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.partner ALTER COLUMN id SET DEFAULT nextval('public.partner_id_seq'::regclass);


--
-- Name: tipologie_servizi id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tipologie_servizi ALTER COLUMN id SET DEFAULT nextval('public.tipologie_servizi_id_seq'::regclass);


--
-- Data for Name: ai_conversations; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.ai_conversations (id, user_id, session_id, conversation_data, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: articoli; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.articoli (id, codice, nome, descrizione, tipo_prodotto, partner_id, prezzo_base, durata_mesi, attivo, tipologia_servizio_id, responsabile_user_id, modello_ticket_id, art_code, art_description, art_kit, tipo_commessa_legacy_id, sla_default_hours, template_milestones, created_at, updated_at) FROM stdin;
1	RVF	Revenue-Founding	Servizio di revenue founding	semplice	\N	\N	\N	t	1	\N	\N	RVF	Revenue Founding	f	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.829841
3	BND	Bandi	Gestione bandi	semplice	\N	\N	\N	t	\N	\N	\N	BND	Bandi	f	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.829841
7	I24	Incarico 24 Mesi	Consulenza strategica biennale	composito	\N	\N	\N	t	\N	\N	\N	I24	Incarico 24 Mesi	t	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.829841
10	STB	StartOffice Business	Pacchetto consulenza business	composito	\N	\N	\N	t	3	\N	\N	SOB	Start Office Business	f	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.829841
13	ICS	Incarico Consulenza Strumenti Economico-Finanziari	Sottoscrivendo il presente documento, la Vostra Azienda da ad EndUser Italia l'incarico di proporVi strumenti economici-finanziari adatti alla Vostra organizzazione per generare liquidità e copertura finanziaria per i Vostri investimenti e, ove ci sia approvazione a procedere, sovraintendere al processo necessario per l'ottenimento dei benefici economici derivanti dagli strumenti selezionati.	composito	\N	\N	\N	t	1	\N	\N	\N	\N	f	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.829841
9	STD	StartOffice Digital	Pacchetto digitalizzazione	composito	\N	\N	\N	t	2	\N	7a324655-f0b4-4166-b4ae-ccc6a0d1c738	SOD	Start Office Digital	t	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.850394
11	STT	StartOffice Training	Pacchetto formazione	composito	\N	\N	\N	t	4	\N	7a324655-f0b4-4166-b4ae-ccc6a0d1c738	SOT	Start Office Training	t	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.850394
12	STS	StartOffice Sustainability	Pacchetto ESG	composito	\N	\N	\N	t	3	\N	7a324655-f0b4-4166-b4ae-ccc6a0d1c738	\N	\N	f	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.850394
2	FNZ	Finanziamenti	Servizio finanziamenti	semplice	\N	\N	\N	t	1	\N	adee46d3-8605-440a-9572-d627362298f0	FNZ	Finanziamenti	f	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.853757
4	KHW	Know How	Trasferimento competenze	semplice	\N	\N	\N	t	\N	\N	d9623add-a776-4db1-ab53-d513fb72ca3b	KNW	Know How	f	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.854895
5	PBX	Patent Box	Agevolazione fiscale per beni immateriali	semplice	\N	\N	\N	t	\N	\N	d9623add-a776-4db1-ab53-d513fb72ca3b	PBX	Patent Box	f	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.854895
6	F40	Formazione 4.0	Credito imposta formazione digitale	semplice	\N	\N	\N	t	4	da164b34-f16b-46f4-8dce-8fdcb622214c	\N	F40	Formazione 4.0	f	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.856902
8	STF	StartOffice Finance	Pacchetto servizi finanziari	composito	\N	\N	\N	t	1	da164b34-f16b-46f4-8dce-8fdcb622214c	7a324655-f0b4-4166-b4ae-ccc6a0d1c738	SOF	Start Office Finance	t	\N	48	\N	2025-08-06 18:16:51.829841	2025-08-06 18:16:51.856902
\.


--
-- Data for Name: bi_cache; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.bi_cache (id, cache_key, cache_data, expires_at, created_at) FROM stdin;
\.


--
-- Data for Name: business_cards; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.business_cards (id, filename, original_filename, extracted_data, confidence_score, nome, cognome, azienda, posizione, email, telefono, indirizzo, status, processing_error, created_at, updated_at, processed_at, company_id, contact_id) FROM stdin;
\.


--
-- Data for Name: commesse; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.commesse (id, company_id, name, codice, descrizione, stato, created_at, client_id, owner_id, budget, data_inizio, data_fine_prevista, status, sla_default_hours, metadata, updated_at, kit_commerciale_id, commerciale_id, tipo_commessa, valore_contratto, ord_date, ord_description, cst_id) FROM stdin;
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.companies (id, name, partita_iva, codice_fiscale, indirizzo, settore, email, telefono, created_at, is_partner, is_supplier, partner_category, partner_description, partner_expertise, partner_rating, partner_status, last_scraped_at, scraping_status, ai_analysis_summary) FROM stdin;
1	EndUser Italia Srl	12345678901	\N	\N	Consulenza IT	info@enduser-italia.com	\N	2025-08-06 18:16:51.818659	f	f	\N	\N	[]	0	active	\N	pending	\N
2	Demo Company	98765432109	\N	\N	Manifatturiero	demo@company.com	\N	2025-08-06 18:16:51.818659	f	f	\N	\N	[]	0	active	\N	pending	\N
\.


--
-- Data for Name: document_chunks; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.document_chunks (id, document_id, content, chunk_index, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: kit_articoli; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.kit_articoli (id, kit_commerciale_id, articolo_id, quantita, obbligatorio, ordine) FROM stdin;
1	3	1	1	t	1
2	3	2	1	f	2
3	3	6	1	f	3
4	4	4	1	t	1
5	4	6	1	t	2
6	5	6	1	t	1
7	5	4	1	f	2
\.


--
-- Data for Name: kit_commerciali; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.kit_commerciali (id, nome, descrizione, articolo_principale_id, attivo, created_at) FROM stdin;
1	Kit Incarico 24 Mesi	Kit completo consulenza biennale	7	t	2025-08-06 18:16:51.836911
2	Kit PMI Completo	Kit completo per PMI	7	t	2025-08-06 18:16:51.836911
3	Kit StartOffice Finance	Pacchetto servizi finanziari completo	8	t	2025-08-06 18:16:51.836911
4	Kit StartOffice Digital	Pacchetto digitalizzazione completa	9	t	2025-08-06 18:16:51.836911
5	Kit StartOffice Training	Pacchetto formazione completa	11	t	2025-08-06 18:16:51.836911
\.


--
-- Data for Name: knowledge_documents; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.knowledge_documents (id, title, content, source_url, content_hash, metadata, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: milestones; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.milestones (id, nome, descrizione, tipo_commessa_id, data_inizio, data_fine_prevista, data_fine_effettiva, sla_hours, warning_days, escalation_days, auto_generate_tickets, template_data, stato, percentuale_completamento, created_at, updated_at, created_by) FROM stdin;
\.


--
-- Data for Name: modelli_task; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.modelli_task (id, nome, descrizione, descrizione_operativa, sla_hours, priorita, ordine, categoria, tags, is_required, is_parallel, dipendenze, milestone_id, tipo_commessa_id, auto_assign_logic, notification_template, is_active, created_at, updated_at, created_by, updated_by) FROM stdin;
\.


--
-- Data for Name: modelli_ticket; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.modelli_ticket (id, nome, descrizione, workflow_template_id, priority, auto_assign_rules, template_description, is_active, created_at) FROM stdin;
7a324655-f0b4-4166-b4ae-ccc6a0d1c738	Template Standard	Template di base per ticket	\N	medium	{}	\N	t	2025-08-06 18:16:51.848052
adee46d3-8605-440a-9572-d627362298f0	Template Finanziamenti	Template per servizi finanziari	\N	high	{}	\N	t	2025-08-06 18:16:51.848052
d9623add-a776-4db1-ab53-d513fb72ca3b	Template Know How	Template per trasferimento competenze	\N	medium	{}	\N	t	2025-08-06 18:16:51.848052
\.


--
-- Data for Name: partner; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.partner (id, nome, ragione_sociale, email, telefono, attivo, servizi_count, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: processing_queue; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.processing_queue (id, task_type, task_data, status, priority, created_at, processed_at) FROM stdin;
\.


--
-- Data for Name: system_health; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.system_health (id, service_name, status, metrics, checked_at) FROM stdin;
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.tickets (id, company_id, title, description, status, priority, created_at, created_by, opportunity_id, modello_ticket_id, milestone_id, sla_deadline, metadata, commessa_id, assigned_to, activity_id, articolo_id, workflow_milestone_id, ticket_code, due_date, updated_at) FROM stdin;
\.


--
-- Data for Name: tipi_commesse; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.tipi_commesse (id, nome, codice, descrizione, sla_default_hours, template_milestones, template_tasks, is_active, created_at, updated_at, created_by, updated_by, colore_ui, icona, priorita_ordinamento) FROM stdin;
\.


--
-- Data for Name: tipologie_servizi; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.tipologie_servizi (id, nome, descrizione, colore, icona, attivo, created_at, updated_at) FROM stdin;
1	Finanziario	Servizi finanziari e consulenza economica	#22c55e	dollar-sign	t	2025-08-06 18:16:51.811336	2025-08-06 18:16:51.811336
2	Digitale	Trasformazione digitale e tecnologia	#3b82f6	monitor	t	2025-08-06 18:16:51.811336	2025-08-06 18:16:51.811336
3	Business	Consulenza strategica e business	#8b5cf6	briefcase	t	2025-08-06 18:16:51.811336	2025-08-06 18:16:51.811336
4	Formazione	Training e sviluppo competenze	#f59e0b	graduation-cap	t	2025-08-06 18:16:51.811336	2025-08-06 18:16:51.811336
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.users (id, username, email, password_hash, role, created_at, name, surname, first_name, last_name, permissions, is_active, last_login, must_change_password, crm_id) FROM stdin;
da164b34-f16b-46f4-8dce-8fdcb622214c	s.andrello@enduser-italia.com	s.andrello@enduser-italia.com	$2b$12$KzE4p8h9YqE5lJ2nO1mF3eJ7vC5qA9wR6tS8bD3fG2hK4lM7nP0oQ	admin	2025-08-06 18:16:51.814705	Stefano	Andrello	Stefano	Andrello	{"admin": true, "view_all": true, "manage_users": true}	t	\N	f	\N
2ffdbe6d-0d90-4e7f-bf8d-d45d50ee625f	b.romano@enduser-italia.com	b.romano@enduser-italia.com	\N	manager	2025-08-06 18:16:51.859587	Barbara Mercedes	Romano	Barbara	Romano	{}	t	\N	f	\N
\.


--
-- Name: articoli_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.articoli_id_seq', 13, true);


--
-- Name: companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.companies_id_seq', 2, true);


--
-- Name: kit_articoli_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.kit_articoli_id_seq', 7, true);


--
-- Name: kit_commerciali_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.kit_commerciali_id_seq', 5, true);


--
-- Name: partner_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.partner_id_seq', 1, false);


--
-- Name: tipologie_servizi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.tipologie_servizi_id_seq', 4, true);


--
-- Name: ai_conversations ai_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.ai_conversations
    ADD CONSTRAINT ai_conversations_pkey PRIMARY KEY (id);


--
-- Name: articoli articoli_codice_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli
    ADD CONSTRAINT articoli_codice_key UNIQUE (codice);


--
-- Name: articoli articoli_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli
    ADD CONSTRAINT articoli_pkey PRIMARY KEY (id);


--
-- Name: bi_cache bi_cache_cache_key_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.bi_cache
    ADD CONSTRAINT bi_cache_cache_key_key UNIQUE (cache_key);


--
-- Name: bi_cache bi_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.bi_cache
    ADD CONSTRAINT bi_cache_pkey PRIMARY KEY (id);


--
-- Name: business_cards business_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.business_cards
    ADD CONSTRAINT business_cards_pkey PRIMARY KEY (id);


--
-- Name: commesse commesse_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.commesse
    ADD CONSTRAINT commesse_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: document_chunks document_chunks_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.document_chunks
    ADD CONSTRAINT document_chunks_pkey PRIMARY KEY (id);


--
-- Name: kit_articoli kit_articoli_kit_commerciale_id_articolo_id_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.kit_articoli
    ADD CONSTRAINT kit_articoli_kit_commerciale_id_articolo_id_key UNIQUE (kit_commerciale_id, articolo_id);


--
-- Name: kit_articoli kit_articoli_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.kit_articoli
    ADD CONSTRAINT kit_articoli_pkey PRIMARY KEY (id);


--
-- Name: kit_commerciali kit_commerciali_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.kit_commerciali
    ADD CONSTRAINT kit_commerciali_pkey PRIMARY KEY (id);


--
-- Name: knowledge_documents knowledge_documents_content_hash_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.knowledge_documents
    ADD CONSTRAINT knowledge_documents_content_hash_key UNIQUE (content_hash);


--
-- Name: knowledge_documents knowledge_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.knowledge_documents
    ADD CONSTRAINT knowledge_documents_pkey PRIMARY KEY (id);


--
-- Name: milestones milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.milestones
    ADD CONSTRAINT milestones_pkey PRIMARY KEY (id);


--
-- Name: modelli_task modelli_task_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.modelli_task
    ADD CONSTRAINT modelli_task_pkey PRIMARY KEY (id);


--
-- Name: modelli_ticket modelli_ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.modelli_ticket
    ADD CONSTRAINT modelli_ticket_pkey PRIMARY KEY (id);


--
-- Name: partner partner_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.partner
    ADD CONSTRAINT partner_pkey PRIMARY KEY (id);


--
-- Name: processing_queue processing_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.processing_queue
    ADD CONSTRAINT processing_queue_pkey PRIMARY KEY (id);


--
-- Name: system_health system_health_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.system_health
    ADD CONSTRAINT system_health_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: tipi_commesse tipi_commesse_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tipi_commesse
    ADD CONSTRAINT tipi_commesse_pkey PRIMARY KEY (id);


--
-- Name: tipologie_servizi tipologie_servizi_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tipologie_servizi
    ADD CONSTRAINT tipologie_servizi_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_articoli_art_kit; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_articoli_art_kit ON public.articoli USING btree (art_kit);


--
-- Name: idx_articoli_codice; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_articoli_codice ON public.articoli USING btree (codice);


--
-- Name: idx_articoli_tipo_prodotto; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_articoli_tipo_prodotto ON public.articoli USING btree (tipo_prodotto);


--
-- Name: idx_companies_is_partner; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_companies_is_partner ON public.companies USING btree (is_partner);


--
-- Name: idx_companies_is_supplier; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_companies_is_supplier ON public.companies USING btree (is_supplier);


--
-- Name: idx_companies_partner_category; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_companies_partner_category ON public.companies USING btree (partner_category);


--
-- Name: idx_kit_articoli_articolo_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_kit_articoli_articolo_id ON public.kit_articoli USING btree (articolo_id);


--
-- Name: idx_kit_articoli_kit_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_kit_articoli_kit_id ON public.kit_articoli USING btree (kit_commerciale_id);


--
-- Name: idx_tickets_commessa_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_tickets_commessa_id ON public.tickets USING btree (commessa_id);


--
-- Name: idx_tickets_company_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_tickets_company_id ON public.tickets USING btree (company_id);


--
-- Name: idx_tickets_status; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_tickets_status ON public.tickets USING btree (status);


--
-- Name: ix_business_cards_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX ix_business_cards_id ON public.business_cards USING btree (id);


--
-- Name: ix_modelli_task_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX ix_modelli_task_id ON public.modelli_task USING btree (id);


--
-- Name: ix_tipi_commesse_codice; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE UNIQUE INDEX ix_tipi_commesse_codice ON public.tipi_commesse USING btree (codice);


--
-- Name: ix_tipi_commesse_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX ix_tipi_commesse_id ON public.tipi_commesse USING btree (id);


--
-- Name: ix_tipi_commesse_nome; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX ix_tipi_commesse_nome ON public.tipi_commesse USING btree (nome);


--
-- Name: articoli update_articoli_updated_at; Type: TRIGGER; Schema: public; Owner: intelligence_user
--

CREATE TRIGGER update_articoli_updated_at BEFORE UPDATE ON public.articoli FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: partner update_partner_updated_at; Type: TRIGGER; Schema: public; Owner: intelligence_user
--

CREATE TRIGGER update_partner_updated_at BEFORE UPDATE ON public.partner FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: tipologie_servizi update_tipologie_servizi_updated_at; Type: TRIGGER; Schema: public; Owner: intelligence_user
--

CREATE TRIGGER update_tipologie_servizi_updated_at BEFORE UPDATE ON public.tipologie_servizi FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: ai_conversations ai_conversations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.ai_conversations
    ADD CONSTRAINT ai_conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: articoli articoli_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli
    ADD CONSTRAINT articoli_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partner(id);


--
-- Name: articoli articoli_responsabile_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli
    ADD CONSTRAINT articoli_responsabile_user_id_fkey FOREIGN KEY (responsabile_user_id) REFERENCES public.users(id);


--
-- Name: articoli articoli_tipologia_servizio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli
    ADD CONSTRAINT articoli_tipologia_servizio_id_fkey FOREIGN KEY (tipologia_servizio_id) REFERENCES public.tipologie_servizi(id);


--
-- Name: commesse commesse_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.commesse
    ADD CONSTRAINT commesse_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.companies(id);


--
-- Name: commesse commesse_commerciale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.commesse
    ADD CONSTRAINT commesse_commerciale_id_fkey FOREIGN KEY (commerciale_id) REFERENCES public.users(id);


--
-- Name: commesse commesse_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.commesse
    ADD CONSTRAINT commesse_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: commesse commesse_kit_commerciale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.commesse
    ADD CONSTRAINT commesse_kit_commerciale_id_fkey FOREIGN KEY (kit_commerciale_id) REFERENCES public.kit_commerciali(id);


--
-- Name: commesse commesse_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.commesse
    ADD CONSTRAINT commesse_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: document_chunks document_chunks_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.document_chunks
    ADD CONSTRAINT document_chunks_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.knowledge_documents(id) ON DELETE CASCADE;


--
-- Name: kit_articoli kit_articoli_articolo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.kit_articoli
    ADD CONSTRAINT kit_articoli_articolo_id_fkey FOREIGN KEY (articolo_id) REFERENCES public.articoli(id) ON DELETE CASCADE;


--
-- Name: kit_articoli kit_articoli_kit_commerciale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.kit_articoli
    ADD CONSTRAINT kit_articoli_kit_commerciale_id_fkey FOREIGN KEY (kit_commerciale_id) REFERENCES public.kit_commerciali(id) ON DELETE CASCADE;


--
-- Name: kit_commerciali kit_commerciali_articolo_principale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.kit_commerciali
    ADD CONSTRAINT kit_commerciali_articolo_principale_id_fkey FOREIGN KEY (articolo_principale_id) REFERENCES public.articoli(id);


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
-- Name: tickets tickets_modello_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_modello_ticket_id_fkey FOREIGN KEY (modello_ticket_id) REFERENCES public.modelli_ticket(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: intelligence_user
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: intelligence_user
--

ALTER DEFAULT PRIVILEGES FOR ROLE intelligence_user IN SCHEMA public GRANT ALL ON TABLES TO intelligence_user;


--
-- PostgreSQL database dump complete
--

