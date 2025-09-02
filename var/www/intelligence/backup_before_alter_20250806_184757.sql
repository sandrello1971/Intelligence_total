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
-- Name: contacts; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.contacts (
    id character varying NOT NULL,
    business_card_id character varying,
    nome character varying NOT NULL,
    cognome character varying NOT NULL,
    nome_completo character varying,
    azienda character varying,
    posizione character varying,
    telefono character varying,
    cellulare character varying,
    email character varying,
    sito_web character varying,
    indirizzo text,
    citta character varying,
    cap character varying,
    paese character varying,
    linkedin character varying,
    altri_social jsonb,
    note text,
    tags jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by character varying(255)
);


ALTER TABLE public.contacts OWNER TO intelligence_user;

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
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.contacts (id, business_card_id, nome, cognome, nome_completo, azienda, posizione, telefono, cellulare, email, sito_web, indirizzo, citta, cap, paese, linkedin, altri_social, note, tags, created_at, updated_at, created_by) FROM stdin;
dc827377-1646-47aa-a96e-129cbac51376	\N	Luigi	Vitaletti	\N	ENDUSER ITALIA S.R.L.S.	\N	392.9165923	\N	l.vitaletti@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.251107	2025-08-06 18:44:29.280718	\N
1cc953f3-fc07-45d9-8508-639d01930232	\N	Matteo	Boieri	\N	\N	Amministratore Delegato	320.4195926	\N	matteo.boieri@autoveicolierzelli.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.28411	2025-08-06 18:44:29.280718	\N
4f4ae803-3fbf-4168-8c46-9b73b2b319d4	\N	Stefano	Alessandri	\N	CENTRO OTTICO SAN RUFFILLO DI ALESSANDRI STEFANO E C. S.A.S.	Proprietario	347.4651383	\N	stefanoalessandri70@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.285264	2025-08-06 18:44:29.280718	\N
444481f9-6b31-43d8-868d-eb372e88038a	\N	Melania	Schintu	\N	CIBUS BZ SRL	Referente	339.1045730	\N	schintumelania@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.286146	2025-08-06 18:44:29.280718	\N
34dd8570-0653-4511-929c-619cdd63c73c	\N	Davide	Baio	\N	CIBUS BZ SRL	Titolare	3385640851	\N	d.baio@cbuspay.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.286995	2025-08-06 18:44:29.280718	\N
59ddf046-344c-4a51-8927-c30df069ee0f	\N	Katia	Vezzoni	\N	CONSORZIO DEL PROSCIUTTO DI SAN DANIELE	Referente	0432 957515	\N	vezzoni@prosciuttosandaniele.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.287889	2025-08-06 18:44:29.280718	\N
985d8afc-9ec2-4cfd-81ae-debd3a53b00c	\N	Luca	Forestan	\N	STUDIO FORESTAN S.R.L.	Titolare	348.3636364	\N	luca@studioforestan.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.288879	2025-08-06 18:44:29.280718	\N
a6465d93-ae3c-4ca2-8415-62dabc98e18d	\N	Marica	Rossi	\N	C.M. BALASSO SRL	Refeferente	0445-621211	\N	info@balasso.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.289815	2025-08-06 18:44:29.280718	\N
807dd71a-13bd-491e-86ec-2125e1f5cd88	\N	Norberto	Albieri	\N	GRAPHIC DIVISION DI ALBIERI NORBERTO	Titolare	3356634734	\N	norberto@graphicdivision.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.290689	2025-08-06 18:44:29.280718	\N
ac28f011-ff9f-4524-8bac-3f3ade059bc7	\N	Matteo	Boieri	\N	AUTOVEICOLI ERZELLI SPA	Titolare	320.4195926	\N	matteo.boieri@autoveicolierzelli.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.291594	2025-08-06 18:44:29.280718	\N
b493b1e7-0329-41d3-9299-63b09502a397	\N	Cristina	Silvestri	\N	TRADING LOGISTIC SAC SRL	Referente	392 1382237	\N	cristina.silvestri@tradinglogistic.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.292427	2025-08-06 18:44:29.280718	\N
a5c890fb-6b51-4ad3-bfdf-9902f026370d	\N	Ferdinando	Panconi	\N	PANCONI CATERING S.R.L.	Titolare	\N	346.6743451	ferdinandopanconi@grosf4.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.293697	2025-08-06 18:44:29.280718	\N
5b29459b-1c42-45d3-8a79-7ce77c450865	\N	Giovanni	D' Agostino	\N	ENDI' S.R.L.	Referente	3395461489	\N	info@endipubblicita.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.295001	2025-08-06 18:44:29.280718	\N
7e21d0ea-aa25-45b5-96fa-002fd9e25e96	\N	Giampiero	Ciarleglio	\N	PANCONI CATERING S.R.L.	Commercialista	\N	335.6780828	dottciarleglio@studiociarleglio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.296053	2025-08-06 18:44:29.280718	\N
add184b7-3b14-4f5e-be3c-03b644812b1e	\N	LUIGI	Poli	\N	AMEL MEDICAL DIVISION SRL	Titolare	3492209025	\N	luigipoli@amelmedical.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.296979	2025-08-06 18:44:29.280718	\N
e35fdbf9-f057-40f7-995e-ace2326d2706	\N	Alfonsina	Imperato	\N	AMEL MEDICAL DIVISION SRL	Referente	349.2209025	\N	alfonsinaimperato@amelmedical.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.298651	2025-08-06 18:44:29.280718	\N
2886924d-4ae5-4fe8-a748-f78b577cba8a	\N	Marco	Fabbro	\N	FRIUL  AL SRL	Titolare	334.8230526	\N	marco@friulal.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.300063	2025-08-06 18:44:29.280718	\N
6e234b35-abad-4659-9725-cb5291b1f973	\N	Chiara	Vosca	\N	FRIUL  AL SRL	Referente	338.2348831	\N	serramenti@friulal.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.301706	2025-08-06 18:44:29.280718	\N
7c787ffa-0ee4-475f-bbeb-4c8c52e334fb	\N	Cristian	Nadalutti	\N	FRIUL  AL SRL	Consulente del lavoro	328.2196452	\N	c.nadalutti@studionadalutti.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.303193	2025-08-06 18:44:29.280718	\N
c471af20-c2ff-4644-8dd3-ef9d3e6c82b0	\N	Felice	Sabatino	\N	N.E.W. SRL	Titolare	366.3825045	\N	felice.sabatino@newsrl.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.304665	2025-08-06 18:44:29.280718	\N
87142fc7-db1d-4674-b94a-4dbb723250e0	\N	Stefano	Affortunati	\N	N.E.W. SRL	Revisore	335.1234747	\N	stefano.affortunati@studioaffortunati.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.306077	2025-08-06 18:44:29.280718	\N
1bf5e805-ac7f-42dc-818c-f0870ef782eb	\N	Francesco	Zani	\N	MZ&Z ADVISORS SRL	Amministratore	347.5855434	\N	francesco.zani@studiozani.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.307392	2025-08-06 18:44:29.280718	\N
99c76720-3cb1-4021-a8e7-bed5a08d1a3c	\N	Stefano	Luciani	\N	LUCIANI SRL	Titolare	328.2788908	\N	amministrazione@lucianisrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.309364	2025-08-06 18:44:29.280718	\N
18ba7f20-8a4d-46f0-9288-a6aee03b8138	\N	Andrea	Luciani	\N	LUCIANI SRL	Socio	366.2824033	\N	a.luciani@lucianisrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.310965	2025-08-06 18:44:29.280718	\N
f30abc2e-f8ff-4f4c-8748-1b1c02c45848	\N	Santo	Ardizzone	\N	WINIT S.R.L.	Titolare	338.5645715	\N	sardizzone@winitsrl.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.31223	2025-08-06 18:44:29.280718	\N
431aceb2-b044-4d1f-b16f-b1e18593b161	\N	Andrea	Frediani	\N	F.LLI FREDIANI SRL	Titolare	348.2473543	\N	andrea@fratellifredianisrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.313505	2025-08-06 18:44:29.280718	\N
c76e9e5a-3feb-4bae-807c-86e7b81569ec	\N	Antonio	Pivotto	\N	LAC SPA	Titolare	340.8315648	\N	finance@lacspa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.314785	2025-08-06 18:44:29.280718	\N
10ff6f74-f56f-474b-954c-e2e2511b80c2	\N	Gianelvi	Ceccato	\N	LAC SPA	Referente	0424.510348	\N	amm@lacspa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.316419	2025-08-06 18:44:29.280718	\N
8f83547f-3cb7-4d7c-8673-f388e8c4c551	\N	Matteo	Beltrame	\N	VENBATT DI BELTRAME MATTEO E MARCO S.N.C.	Titolare	340.8634162	\N	info@venbatt.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.317748	2025-08-06 18:44:29.280718	\N
0fa3231e-c67b-42ad-9eb7-cedc34020067	\N	Matteo	Danzi	\N	RLS LEX	Avvocato	347.9935945;045.8001561	\N	m.danzi@rlslex.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.318735	2025-08-06 18:44:29.280718	\N
ea259782-42ec-4fea-8b72-7fe27f8d1ce1	\N	Federico	Lolli	\N	RLS LEX	Socio	348.8711002	\N	f.lolli@rlslex.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.319757	2025-08-06 18:44:29.280718	\N
4bfe4a8a-61ad-4daf-aca9-82d7c3da73e2	\N	Loredana	Pistis	\N	TERRANTICA S.R.L.	Referente	393.9344341	\N	loredanapistis@crocchias.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.320759	2025-08-06 18:44:29.280718	\N
5d79714e-7332-4633-8b53-8748a443d56b	\N	Riccardo	Soru	\N	TERRANTICA S.R.L.	Socio	370.1022000	\N	riccardosoru@crocchias.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.321752	2025-08-06 18:44:29.280718	\N
fe081bbf-22fd-45d4-aaa9-24b59d81b60c	\N	Alberto	Caria	\N	TERRANTICA S.R.L.	Referente	392.9098233	\N	alberto.caria@crocchias.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.32267	2025-08-06 18:44:29.280718	\N
c7a58ecd-69e1-40b2-93f0-85d4a4fa5822	\N	Emanuele	Soru	\N	TERRANTICA S.R.L.	Socio	3701050120	\N	emanuele.soru@tiscali.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.32394	2025-08-06 18:44:29.280718	\N
e0a5ef2f-2587-4e63-9ae7-a7dcbcd8ddb5	\N	Marco	Roselli	\N	ISTITUTO SONCIN S.A.S. DI ROSELLI MARCO & C.	Titolare	329.5935089	\N	marcoroselli@istitutosoncin.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.327401	2025-08-06 18:44:29.280718	\N
86a29a03-c870-432d-8ff1-499e8e1bed92	\N	Paolo	Serra	\N	INDUSTRIA SARDA ALBERGHI S.R.L.	Direttore	3470853077	\N	direzione@hotelmarianoiv.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.32912	2025-08-06 18:44:29.280718	\N
bbb1e198-8cfa-4a90-9d9d-a2bb9d9e1423	\N	Alessandro	Ladu	\N	\N	Referente	3455913950	\N	alessandro.ladu@laduservizi.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.330701	2025-08-06 18:44:29.280718	\N
74631d8c-c0cf-40c6-8fd5-da4ee47e7d33	\N	Michele	Tognetti	\N	BT SOLUTIONS SRL	Titolare	344.1252363	\N	ufficiotecnico@btsolutions.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.33217	2025-08-06 18:44:29.280718	\N
fd8df671-7d1e-40eb-8388-16fea26d2b00	\N	Alessandro	Costa	\N	CO.VER COLORIFICIO SRL	Titolare	347.4913485	\N	alessandro@covercolorificio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.333668	2025-08-06 18:44:29.280718	\N
41af6392-2ae9-4eb9-b7aa-5c04b2ef2946	\N	Giovanna	Carollo	\N	CO.VER COLORIFICIO SRL	Referente	0445.314745	\N	info@covercolorificio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.335172	2025-08-06 18:44:29.280718	\N
04d704c3-eb6e-4c76-8c79-635d1daf6c58	\N	Marco	Calamari	\N	M.R. CALAMARI S.R.L.	Titolare	\N	338.6224536	calamariracing@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.336686	2025-08-06 18:44:29.280718	\N
085176d8-8442-43af-b8f0-daf00180be2a	\N	Francesco	Cerqueti	\N	STUDIO BRACCO & CERQUETI - SOCIETA' SEMPLICE TRA PROFESSIONISTI	Titolare	335.5479048	\N	francesco.cerqueti@braccocerqueti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.337782	2025-08-06 18:44:29.280718	\N
c6a5989a-f67b-4d48-9b05-824275e678f3	\N	Pasquale	De Marco	\N	BARZANTI MIRIO SRL	\N	329.4272442	\N	p.demarco@barzanti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.339031	2025-08-06 18:44:29.280718	\N
e724e166-f7a7-421e-b8cd-5dab7f3762b8	\N	Stefano	Passarelli	\N	PASSARELLI AUTOMAZIONI S.R.L.	Titolare	335.5771613	\N	info@passarelliautomazioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.340416	2025-08-06 18:44:29.280718	\N
cf6d201b-7720-490e-88ba-daa68f03c70f	\N	Patrizia	D'Agostino	\N	PASSARELLI AUTOMAZIONI S.R.L.	Referente	3496465942	\N	info@passarelliautomazioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.341674	2025-08-06 18:44:29.280718	\N
bd8fb146-d866-439c-97d8-57a671466794	\N	Sandro	Pisanu	\N	SURGELSARDA SAS DI PI SANU AUGUSTO - SIGLA ABBR. SURGELSARDA S.A.S. DI PISANU AUGUSTO"	\N	3473257002	\N	surgelsarda@hotmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.343319	2025-08-06 18:44:29.280718	\N
029afaaf-4436-4ca8-8f7b-c4aaf45d34d7	\N	Enrico	Piras	\N	VIDEO PIU' S.R.L.	Titolare	335485525	\N	enrico@expertalghero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.34461	2025-08-06 18:44:29.280718	\N
5327fa6a-cb8f-4930-9901-33d14b941c46	\N	Andrea	De Raho	\N	QUATTRO STELLE ARREDAMENTI S.R.L.	Titolare	342.8537297	\N	quattrostellearredamenti.srl@live.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.346026	2025-08-06 18:44:29.280718	\N
3be98e7a-c669-446a-a19f-720503367550	\N	Vito	De Mitri	\N	SIS*MED S.R.L. SISTEMI MEDICALI	Titolare	366.1039609	\N	sismed.lecce@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.34718	2025-08-06 18:44:29.280718	\N
8e918cee-99a2-4f5a-8842-8b3ace4cfca5	\N	Fabrizio	Negro	\N	IL GIGLIO SOCIETA' COOPERATIVA SOCIALE	Titolare	347.2300412	\N	drnegrofabrizio@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.352216	2025-08-06 18:44:29.354234	\N
a1ed2b99-c94d-4dbc-bf5b-fd31206d5a57	\N	Mario	Gigola	\N	INDUSTRIAL SOFTWARE S.R.L.	Titolare	353 4141228	\N	mgigola@industrialsoftware.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.355254	2025-08-06 18:44:29.354234	\N
4e05f426-26f1-4eca-9883-909593a64446	\N	Francesco	Bertolini	\N	CAFFARO INDUSTRIE S.P.A.	Titolare	335.7505673	\N	gustavo.bertolini@caffaroindustrie.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.356269	2025-08-06 18:44:29.354234	\N
4604d7f2-063a-469e-aa54-5f6789f48c30	\N	Alessandro	Sbrana	\N	GE.M.E.G. S.R.L.	Responsabile amministrativo	338 7241986	\N	alessandro@gemeg.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.357196	2025-08-06 18:44:29.354234	\N
623f964c-5003-4ec9-8345-1409cd6c670c	\N	Gustavo	Bertolini	\N	HALO INDUSTRY S.P.A.	Titolare	335.7505673	\N	gustavo.bertolini@caffaroindustrie.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.358184	2025-08-06 18:44:29.354234	\N
a1032b46-f445-4ef2-b728-6f31262e280b	\N	Gianluca	Marchi	\N	TURRISMARKET S.R.L.	Referente- commercialista	348.4903482	\N	gianluca@turrismarket.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.359081	2025-08-06 18:44:29.354234	\N
3c8129f5-52b4-462d-934d-0ab01f1b9e46	\N	Maurizio	Zolesi	\N	TURRISMARKET S.R.L.	Presidente	348.4903481	\N	maurizio@turrismarket.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.359989	2025-08-06 18:44:29.354234	\N
c269e93b-9a9a-4f22-b884-2cb66dc58939	\N	Pier Carlo	Frabboni	\N	THE ORAL ATELIER S.R.L.	Titolare	335.7325737	\N	Info@theoralatelier.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.361045	2025-08-06 18:44:29.354234	\N
262c1ffd-05d4-4906-abc2-1041211c964f	\N	Michela	Sirigu	\N	SERVIZI IMPRESE SARDEGNA SRL	Referente	338.6822825	\N	sirigu@si-sardegna.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.362375	2025-08-06 18:44:29.354234	\N
d7711919-1dad-4a70-80df-caa694dbbca9	\N	Cesarina	Polini	\N	INTERACTIVE STYLE SRL	Referente	347.5079974	\N	amministrazione@interactivestyle.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.363567	2025-08-06 18:44:29.354234	\N
12f2a732-7f91-4d15-933f-285c0c0b0ac5	\N	Alberto	Scotti	\N	CENTRO DATI VIGEVANO S.R.L.	Referente	342.8532336	\N	info@cdvcentrodativigevano.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.36471	2025-08-06 18:44:29.354234	\N
facfcf7d-a2b4-4767-8f18-22948cd3bb09	\N	Nicola	Malossini	\N	ARIKI S.R.L.	Rappresentante Legale	\N	339.3158456	amministrazione@ariki.srl	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.365793	2025-08-06 18:44:29.354234	\N
22832f63-5532-4f0a-bbee-a790ff8f1cbb	\N	Gabriella	Andreaus	\N	ARIKI S.R.L.	Referente Amministrativa	\N	339.3158456	amministrazione@ariki.srl	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.366865	2025-08-06 18:44:29.354234	\N
1aa934cc-dd7b-41f0-bc25-9a6c4ac7e5e2	\N	Luciano	Gasparini	\N	MY DENT SRL	Referente	3401220149	\N	gmindsrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.368153	2025-08-06 18:44:29.354234	\N
ffd08be1-dc06-4f71-aeb3-c41785846781	\N	Alessandro	Ladu	\N	EASY CONTACT S.R.L.	Referente	\N	345 5913950	alessandro.ladu@laduservizi.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.369568	2025-08-06 18:44:29.354234	\N
4d60bd61-ea57-4612-b362-a2557beba994	\N	Marco	Balzarini	\N	GESTIONE BENESSERE SRL	Referente	335 6451512	\N	m.balzarini@khspa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.370774	2025-08-06 18:44:29.354234	\N
3214aaa0-daaa-4a8f-991b-80e6576e84f5	\N	Matteo	Chiacchiararelli	\N	GESTIONE BENESSERE SRL	Commercialista	339.8097282	\N	matteo.chia@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.371965	2025-08-06 18:44:29.354234	\N
382b9ba3-ada9-44ce-a951-a705b62856fc	\N	Federico	Marchetti	\N	GESTIONE BENESSERE SRL	Consulente del lavoro	338.3009993	\N	segreteria@cdlroma.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.373166	2025-08-06 18:44:29.354234	\N
b1ad0ee8-4fa7-467f-a27f-b320e61fc86b	\N	Carlo	Masini	\N	GESTIONE BENESSERE SRL	Revisore	335.8376076	\N	carlo@studiomasinicarlo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.374251	2025-08-06 18:44:29.354234	\N
d2c09d2f-fcf4-4070-84b8-ddb285a7a474	\N	Lorenza	Renzetti	\N	IL FORNO DI GERMANO DI RENZETTI GERMANO E LORENA S.N.C.	Titolare	349.5155381	\N	ilfornodigermano@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.375491	2025-08-06 18:44:29.354234	\N
c26d0c56-15ce-485c-bb75-df34f9dd10a3	\N	Fabio	Armani	\N	ECO GARDEN NET & SERVICES S.R.L.	Titolare	348.7915204	\N	armanifabio@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.376743	2025-08-06 18:44:29.354234	\N
26e14879-a581-4045-9d4b-78be9ca802d1	\N	Guido	Nelli	\N	NELLI AUTO S.R.L.	Titolare	338.6955592	\N	guido.nelli@nelli1956.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.377701	2025-08-06 18:44:29.354234	\N
e0eb635b-1c25-4d4c-a701-6bc3d341755c	\N	Alberto	Nelli	\N	ALPHA RENT SRLS	Titolare	333 7988551	\N	alberto.nelli@nelli1956.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.378668	2025-08-06 18:44:29.354234	\N
63bee9a0-0e05-4f6e-b8df-3184d18fec3a	\N	Lucio	Petretto	\N	4H SRL	Referente	345.5852022	\N	art.academy@outlook.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.379747	2025-08-06 18:44:29.354234	\N
d2f3a621-11b9-43ae-b013-2d9cd236263f	\N	Lucio	Petretto	\N	5S S.R.L.	Referente	345.5852022	\N	info@artacademybrand.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.381024	2025-08-06 18:44:29.354234	\N
9e801c52-4542-44eb-baa1-0cb110264d1d	\N	Lorenzo	Scardigli	\N	TINGHI MOTORS - S.R.L.	Referente	349.7833139	\N	lorenzo.scardigli@tinghimotors.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.382464	2025-08-06 18:44:29.354234	\N
e675f6ff-1c45-40bb-9132-d4b3793a6a8e	\N	Alberto	Ortile	\N	PRO STUDIO S.R.L. SOCIETA' TRA PROFESSIONISTI	Socio	348.8750016	\N	alberto.ortile@prostudiosrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.383861	2025-08-06 18:44:29.354234	\N
97dff86f-fcf2-4d6a-ab86-8d66f2a42c5b	\N	Filippo	Bertolini	\N	I.C.P. S.P.A.	Consigliere Delegato	\N	335 7505673	filippo.bertolini@caffaroindustrie.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.385133	2025-08-06 18:44:29.354234	\N
2f8bad6d-ed7c-405e-a15d-0bb22ae4167f	\N	Gustavo	Bertolini	\N	I.C.P. S.P.A.	Referente	\N	335 7505673	gustavo.bertolini@caffaroindustrie.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.386553	2025-08-06 18:44:29.354234	\N
d404c343-130f-4868-8c24-849ce487661c	\N	Giorgio	Messina	\N	DE.FI.ME - S.R.L.	Legale rappresentante	3298215280	\N	giorgio@defime.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.388137	2025-08-06 18:44:29.354234	\N
c84b98fb-830a-4a7d-831f-dff95a54e9ee	\N	Valeria	Danca	\N	DE.FI.ME - S.R.L.	Referente	3200627418	\N	valeria@defime.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.389504	2025-08-06 18:44:29.354234	\N
40388fff-3c7b-49eb-acce-fe4ce49f9784	\N	Mattia	Finotti	\N	DELTA INFORMATICA S.P.A.	Responsabile Tecnico-Commerciale	328.8161836	\N	mattia.finotti@deltainformatica.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.390612	2025-08-06 18:44:29.354234	\N
894befab-63e7-44cf-8565-d91f43c30f33	\N	Luca	Lorefice	\N	SANGFOR TECHNOLOGIES ITALY S.r.l.	Sales Director Nord Est	348.2529838	\N	luca.lorefice@sangfor.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.391761	2025-08-06 18:44:29.354234	\N
501e0537-8021-41e3-88a8-bfdefcfbc305	\N	Andrea	Bonardi	\N	GREENTEC	Co-founder e CEO	329.9770037	\N	commerciale@greentecitalia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.392974	2025-08-06 18:44:29.354234	\N
08d2d661-57be-46db-b518-98d4c127a948	\N	Stefano	Nerozzi	\N	ORTOPEDIA PODOLOGIA MALPIGHI S.R.L.	Socio - Legale Rappresentante	335 618 7528	\N	direzione@ortopediamalpighi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.394163	2025-08-06 18:44:29.354234	\N
10999217-c493-4b0f-8161-e290207cae5c	\N	Alessandro	Palumbo	\N	FONDITAL SPA	Amministrazione - Gestione Finanza Agevolata	\N	\N	alessandro.palumbo@fondital.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.395262	2025-08-06 18:44:29.354234	\N
e5dd76d5-c83f-4e53-aa2c-4375613fd8f4	\N	Stefano	Colbrelli	\N	FONDITAL SPA	Ufficio Acquisti	\N	\N	stefano.colbrelli@fondital.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.396383	2025-08-06 18:44:29.354234	\N
21e324bc-81d5-4f5f-80d1-91282a6ff207	\N	Rocco	Poli	\N	ENTERPRISE S.R.L.	Amministratore Delegato	\N	\N	rocco.poli@enterprisesrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.397405	2025-08-06 18:44:29.354234	\N
aed4508a-a288-49a1-ae36-00610123a739	\N	Michela	Mistrello	\N	PIEFFE S.R.L.	Referente	049.9620937	\N	info@pieffe-srl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.590977	2025-08-06 18:44:29.580033	\N
0ffb988d-83bd-4e8a-9f11-ec4caf42a7cb	\N	Michele	Labellottini	\N	VIDA S.P.A.	Titolare	3484082531	\N	michelelabellottini@vida-spa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.398482	2025-08-06 18:44:29.354234	\N
1d9b46b4-a70e-4888-9828-e5b671a7818d	\N	Giorgio	Baruzzi	\N	O.M.O. S.P.A.	Titolare	\N	\N	info@omospa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.399676	2025-08-06 18:44:29.354234	\N
c96352fd-1f05-485d-8662-4baad2dea890	\N	Vincenza	Freddi	\N	FBL PRESSOFUSIONI S.R.L.	Titolare	\N	\N	vincenza.freddi@fblcastings.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.400755	2025-08-06 18:44:29.354234	\N
c203624b-2775-49eb-97b8-15878e621ae7	\N	Rita	Bettinsoli	\N	FBL PRESSOFUSIONI S.R.L.	\N	\N	\N	rita.bettinsoli@fblcastings.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.4023	2025-08-06 18:44:29.354234	\N
2d83256f-4624-4151-9916-ac1fa6ec6b06	\N	Giorgio	Appoloni	\N	STUDIO GABRIELLI APPOLONI SRL	Socio	0461.1975610	\N	appoloni@csatn.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.403581	2025-08-06 18:44:29.354234	\N
34d63176-b391-4e1a-846b-ae47812b97b0	\N	Maria Silvia	Gentile	\N	ENDUSER ITALIA S.R.L.S.	Area Manager	351 3864077	\N	ms.gentile@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.404759	2025-08-06 18:44:29.354234	\N
352b190b-747f-43ab-83cf-edc94e928cd5	\N	Davide	Magnabosco	\N	ASI - ASSOCIAZIONI SPORTIVE E SOCIALI ITALIANE	Consigliere Nazionale	3313729506	\N	davide.magnabosco@asibrescia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.406154	2025-08-06 18:44:29.354234	\N
767963eb-d2a1-46ca-871d-817c9d525486	\N	Stefano	Righettini	\N	TMF CONSULTING SRL	\N	\N	\N	s.righettini@tmfconsulting.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.407493	2025-08-06 18:44:29.354234	\N
8ebbb8a2-9261-45f7-a43e-3e0a9a9d73ef	\N	Massimiliano	Ghiso	\N	F.A.I.C. INDUSTRY S.R.L.	Referente	347.5241544	\N	massimiliano.ghiso@faicindustry.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.408782	2025-08-06 18:44:29.354234	\N
daa24e9e-1b9f-4af6-870d-441e7bf7500a	\N	Fabrizio	Assetta	\N	ASSE S.R.L.	Titolare	338.3409056	\N	f.assetta@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.410017	2025-08-06 18:44:29.354234	\N
7606e1ba-f7b0-46df-b862-36163a6033a8	\N	Alessio	Piccardi	\N	FIERAMENTE SRL	Titolare	339.7425663	\N	a.piccardi@fieramente.biz	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.411168	2025-08-06 18:44:29.354234	\N
c3a962aa-af19-4328-ba21-933602d52f81	\N	Gianfranco	Cavaretta	\N	CAVARRETTA ASSICURAZIONI DI GIANFRANCO CAVARRETTA E FRANCO AUDISIO E C. SOCIETA' IN ACCOMANDITA SEMPLICE	Titolare	335 5860087	\N	gianfranco@cavarrettaassicurazioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.412331	2025-08-06 18:44:29.354234	\N
b26649be-28a8-4ec6-8c6c-03c70f872039	\N	Franco	Audisio	\N	CAVARRETTA ASSICURAZIONI DI GIANFRANCO CAVARRETTA E FRANCO AUDISIO E C. SOCIETA' IN ACCOMANDITA SEMPLICE	Socio Cavarretta Assicurazioni/Vicepresidente FenImprese Pescara	338.2517813	\N	f.audisio@fenimpresepescara.org	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.41658	2025-08-06 18:44:29.417914	\N
3f6074c8-cd27-49e3-a0c1-5b43dd0b96f8	\N	Eugenia	Gallerani	\N	CAVARRETTA ASSICURAZIONI DI GIANFRANCO CAVARRETTA E FRANCO AUDISIO E C. SOCIETA' IN ACCOMANDITA SEMPLICE	Referente	051.306805	\N	amministrazionecavarretta@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.419054	2025-08-06 18:44:29.417914	\N
9316f6e6-6b30-4428-872d-d69a014e650d	\N	Fabio	Aliboni	\N	ENDUSER ITALIA S.R.L.S.	Area Manager	378 3073508	\N	f.aliboni@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.420414	2025-08-06 18:44:29.417914	\N
5da2f06c-79fe-4a4d-b579-d8d6f3322738	\N	Pier Luigi	Menin	\N	ENDUSER ITALIA S.R.L.S.	Account Manager	351 3715381	\N	p.menin@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.421643	2025-08-06 18:44:29.417914	\N
ed6548f9-0778-41bf-abc9-e87a41d809ee	\N	Giovanni	Fulgheri	\N	ENDUSER ITALIA S.R.L.S.	Account Manager	346 8545437	\N	g.fulgheri@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.42291	2025-08-06 18:44:29.417914	\N
109379ec-bb1a-4c16-a2e1-b825e1443fad	\N	Francesca	De Vita	\N	ENDUSER ITALIA S.R.L.S.	Account Manager	333 8870772	\N	f.devita@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.424054	2025-08-06 18:44:29.417914	\N
6e47a334-56e3-4ccf-b016-7aecf4a19d17	\N	Francesca	Zarfati	\N	ENDUSER ITALIA S.R.L.S.	Customer Care	378 3056160	\N	f.zarfati@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.425005	2025-08-06 18:44:29.417914	\N
eb5c6e30-e419-4342-898d-6a0ac7a67d3c	\N	Francesco	Rainaldi	\N	ENDUSER ITALIA S.R.L.S.	Customer Care	351 3704890	\N	f.rainaldi@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.426318	2025-08-06 18:44:29.417914	\N
d4883422-77ee-435b-819b-a193a0bccd05	\N	Sabrina	Cristofanelli	\N	ENDUSER ITALIA S.R.L.S.	Customer Care	351 3001244	\N	s.cristofanelli@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.427627	2025-08-06 18:44:29.417914	\N
3ad57daf-6955-418b-a671-c918cadad39e	\N	Barbara Mercedes	Romano	\N	ENDUSER ITALIA S.R.L.S.	Amministrazione	351 9581736	\N	b.romano@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.428732	2025-08-06 18:44:29.417914	\N
dd0158c0-ee4c-473c-a4a6-b504dd9361ce	\N	Massimiliano	Ciotti	\N	ENDUSER ITALIA S.R.L.S.	Business Strategies	378 3073523;3482619045	\N	m.ciotti@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.429731	2025-08-06 18:44:29.417914	\N
a03ca871-7e9e-4cb5-848a-2cd96b3a7f2b	\N	Candida	Persico	\N	ENDUSER ITALIA S.R.L.S.	HR & Controller	378 3053717	\N	c.persico@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.430714	2025-08-06 18:44:29.417914	\N
7bdb3c46-743f-4742-9714-97e5e2fd9b09	\N	Ivano	Meli	\N	OTTICA ROLIN S.R.L.	Titolare	335.1417602	\N	ivan@otticarolin.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.431604	2025-08-06 18:44:29.417914	\N
17b9c3cf-12b7-47c3-b96d-d66e1f998a64	\N	Simone	Banchini	\N	HIHO S.R.L.	Titolare	348.6509020	\N	sb@hiho.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.432423	2025-08-06 18:44:29.417914	\N
28bdfe08-cd7d-46f1-ba34-db2b06e39d33	\N	Domingo	Bianco	\N	PROGETTO S.P.A.	Legale rappresentante	392.1071053	\N	massimo.antoci@urbanhomy.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.433517	2025-08-06 18:44:29.417914	\N
87f34f84-8244-499e-b700-adf5e9eca97c	\N	Riccardo Diego	Caulo	\N	PROGETTO S.P.A.	Referente	349.5907713	\N	riccardo.caulo@urbanhomy.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.434683	2025-08-06 18:44:29.417914	\N
bc2140b7-2685-4da5-9b83-5852b557f470	\N	Danilo	Puddu	\N	CORMEDICA S.R.L.	Amministratore Delegato	337.536767	\N	danilo@cormedica.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.435843	2025-08-06 18:44:29.417914	\N
73720c42-3dfc-4c62-989c-26303abcc9a0	\N	Massimo	Antoci	\N	OSTERIA DEL CAFFE' S.R.L.	Legale rappresentante	392.1071053	\N	massimo.antoci@urbanhomy.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.43714	2025-08-06 18:44:29.417914	\N
81eb6e3c-4204-441c-9411-bfd48530e3ca	\N	Riccardo Diego	Caulo	\N	OSTERIA DEL CAFFE' S.R.L.	Referente	349.5907713	\N	riccardo.caulo@urbanhomy.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.43807	2025-08-06 18:44:29.417914	\N
b8525731-e546-4b39-8cb3-1dd675b4fd9f	\N	Massimo	Antoci	\N	ITER IMPRESA SOCIALE S.R.L.	Legale rappresentante	392.1071053	\N	massimo.antoci@urbanhomy.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.439116	2025-08-06 18:44:29.417914	\N
d185d588-8844-4c5b-9357-b1d118a45cf5	\N	Riccardo Diego	Caulo	\N	ITER IMPRESA SOCIALE S.R.L.	Amministrazione	349.5907713	\N	riccardo.caulo@urbanhomy.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.442419	2025-08-06 18:44:29.417914	\N
1fd22daf-7314-4754-b930-32a47dd93611	\N	Lisa	Bonetto	\N	OMT BONETTO S.R.L.	Referente (titolare)	348.3572843	\N	lisa.bonetto@omttech.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.443524	2025-08-06 18:44:29.417914	\N
88b8ec49-88fd-4a84-b250-31ee31f3ba26	\N	Marco	Bonetto	\N	OMT BONETTO S.R.L.	Titolare	0445.6290289	\N	marco.bonetto@omttech.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.444587	2025-08-06 18:44:29.417914	\N
0a71af81-99fd-43c2-ac36-d004738c00bf	\N	Federico	Bonetto	\N	OMT BONETTO S.R.L.	Titolare	348.3572841	\N	federico.bonetto@omttech.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.445714	2025-08-06 18:44:29.417914	\N
0979d986-8e5c-4fc7-8425-38eb467c0941	\N	Vinicio	Vaccari	\N	V & V GROUP SRL	Socio Amministratore	\N	351.6749536	info@vev-group.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.446948	2025-08-06 18:44:29.417914	\N
8451fdb5-c298-4764-8cc8-8475c6cf0826	\N	Daniele	Pez	\N	\N	\N	\N	335.6135772	daniele.pez@evenio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.448175	2025-08-06 18:44:29.417914	\N
ecd56ddc-0c53-4d85-b922-bcdd13b2781a	\N	Francesco	Rubino	\N	FARMACIA RUBINO S.R.L.	Socio Amministratore	\N	338.2100545	francesco@farmaciarubino.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.449408	2025-08-06 18:44:29.417914	\N
263b993c-4f5b-40bc-bfd4-0b8fa3b33914	\N	Umberto	Rubino	\N	FARMACIA RUBINO S.R.L.	Titolare	\N	335.251281	amministrazione@farmaciarubino.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.450599	2025-08-06 18:44:29.417914	\N
8ee9e22f-c713-4d5f-93ce-f179c7f41409	\N	Massimo	Tonin	\N	KRESOS S.R.L.	Titolare	348.7018128	\N	massimo@kresos.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.451766	2025-08-06 18:44:29.417914	\N
6f765f4c-c264-489b-b48f-f2d2591d776f	\N	Paolo	Dani	\N	KRESOS S.R.L.	Referente	348.7018125	\N	paolo@kresos.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.452951	2025-08-06 18:44:29.417914	\N
ccac07bd-1be7-4674-9cb5-972a070d31d2	\N	Marco	Scandogliero	\N	4 CIACOLE S.R.L.	Titolare	\N	340 2838808	marco.scandogliero@le4ciacole.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.45412	2025-08-06 18:44:29.417914	\N
3f6d48f0-7e67-4901-b205-570e42ec08b1	\N	Lorella	Angelini	\N	KOMPLETT SOCIETA' COOPERATIVA	Responsabile HR	338.6078487	\N	lorella.angelini@komplettservizi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.4554	2025-08-06 18:44:29.417914	\N
29ab384c-b68c-4650-a2e7-763398fcbc12	\N	Giuliana	Rigatti	\N	KOMPLETT SOCIETA' COOPERATIVA	Referente	346.7593314	\N	giuliana.rigatti@komplettservizi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.456978	2025-08-06 18:44:29.417914	\N
df018309-0d0b-4ac4-8c51-0752c9af1fca	\N	Andrea	Porcu	\N	EUTEL 2005 S.R.L.	Titolare	3494384149	\N	andrea.porcu@eutel2005.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.458173	2025-08-06 18:44:29.417914	\N
9cae7e25-3eff-4f7f-b106-ac430e26ce93	\N	Sabrina	Venali	\N	SPRINT CAR AND SERVICE - SOCIETA' COOPERATIVA	Referente	339.2242773	\N	amministrazione@sprintcarservice.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.45933	2025-08-06 18:44:29.417914	\N
ab1f6690-2bf6-48c4-9c18-d6eda95d210d	\N	Studio De Meis	Studio De Meis	\N	SPRINT CAR AND SERVICE - SOCIETA' COOPERATIVA	Commercialista	328.7258432	\N	c.gioco@gandpartners.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.46053	2025-08-06 18:44:29.417914	\N
c2feec39-9a2a-46fd-a7cb-d46b294eb903	\N	Giuseppe	Munafo	\N	SPRINT CAR AND SERVICE - SOCIETA' COOPERATIVA	Revisore	328.7218240	\N	g.munafo@gandpartners.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.461702	2025-08-06 18:44:29.417914	\N
6a66f3e1-9dd7-4c88-afa7-84f76dc7f3a3	\N	Giuseppe	La Rocca	\N	STUDIO FARINA E LA ROCCA DI GIUSEPPE LA ROCCA & C. S.A.S.	Titolare	329.4211199	\N	giuseppe.larocca@studiofarinalarocca.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.46294	2025-08-06 18:44:29.417914	\N
21726936-00c8-469f-869e-5c7e5dbc1884	\N	Piero	Cordone	\N	STUDIO FARINA E LA ROCCA DI GIUSEPPE LA ROCCA & C. S.A.S.	Revisore	340.4177582	\N	piero.cordone@studiofarinalarocca.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.46411	2025-08-06 18:44:29.417914	\N
34ddfc44-27e8-4ed1-897c-fbc8f1a9efd5	\N	Roberto	Vitaggio	\N	IET SERVICE S.A.S. DI ROBERTO VITAGGIO & C.	Titolare	377 4358822	\N	amministrazione@ietservice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.46525	2025-08-06 18:44:29.417914	\N
83759c40-16e3-4c59-aec9-7eafbe777faa	\N	Luca	Hu	\N	SUPERPRICE S.R.L.	Titolare	388.9570188	\N	lucah@ymail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.466361	2025-08-06 18:44:29.417914	\N
df66f029-48ae-498b-913e-9512e8b52d92	\N	Gianmarco	Masini	\N	STUDIO MASINI E CO SRL	Titolare	389 5805902	\N	gianmarco@studiomasinicarlo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.467475	2025-08-06 18:44:29.417914	\N
f4663b98-06fa-4ad4-9c11-a75321b4c14b	\N	Lorena	Villa	\N	PRENOTAZIONI 24 S.R.L.	Referente	345.8416528;0565.917888	\N	lorena.villa@napoleonviaggi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.468644	2025-08-06 18:44:29.417914	\N
bd27bf76-15d3-43ed-920d-aa64bee7dee6	\N	Arturo	Cravera	\N	CANTINA SOCIALE DI NIZZA MONFERRATO   SOCIETA' COOPERATIVA AGRICO LA  SIGLABILE: CANTINA DI NIZZA SOC. COOP. AGR. CANTINA DI NIZZA CANTINA DEL NIZZA	Referente	347.9351611	\N	arturo.cravera@nizza.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.469836	2025-08-06 18:44:29.417914	\N
17554c38-4022-4fd6-9102-b9cc1902f8a3	\N	Studio Porta Rota	Studio Porta Rota	\N	CANTINA SOCIALE DI NIZZA MONFERRATO   SOCIETA' COOPERATIVA AGRICO LA  SIGLABILE: CANTINA DI NIZZA SOC. COOP. AGR. CANTINA DI NIZZA CANTINA DEL NIZZA	Consulente del lavoro	0141.721513	\N	studio@studioporta.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.470989	2025-08-06 18:44:29.417914	\N
db277cc1-0d03-485f-8add-44a055dc44f9	\N	Union Link Srl	Union Link Srl	\N	CANTINA SOCIALE DI NIZZA MONFERRATO   SOCIETA' COOPERATIVA AGRICO LA  SIGLABILE: CANTINA DI NIZZA SOC. COOP. AGR. CANTINA DI NIZZA CANTINA DEL NIZZA	Commercialista	0141.357111	\N	unionlink@confcooperative.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.472055	2025-08-06 18:44:29.417914	\N
4170df07-ebe1-4bf6-84ed-f8eec48cd077	\N	Federico	Musetti	\N	HIHO S.R.L.	Commercialista	329 8513685	\N	federico@studiomusetti.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.47302	2025-08-06 18:44:29.417914	\N
26696a46-b3c8-4f65-893a-f5349f1dae02	\N	Claudio	Zamengo	\N	ISOFT S.R.L.	Titolare	\N	348.8569740	claudio@isoft.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.473907	2025-08-06 18:44:29.417914	\N
83c60e42-1148-4dda-8d31-b48fedf6d9ab	\N	Giulia	Zamengo	\N	ISOFT S.R.L.	Socia Amministrativa	\N	338.7979360	giulia@isoft.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.474688	2025-08-06 18:44:29.417914	\N
ccc14e6b-6db6-4ab4-99cc-4c7ea685a837	\N	Vincenzo	Buonocore	\N	C.O.F. - CENTRO ORTOPEDICO FISIOTERAPICO  SOCIETA' A RESPONSABILITA' LIMITATA	Titolare	392.9732029	\N	info@cofvelletri.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.475496	2025-08-06 18:44:29.417914	\N
c02ec979-866f-46ee-ae6e-74f84128b16d	\N	Valentino	Di Prisco	\N	C.O.F. - CENTRO ORTOPEDICO FISIOTERAPICO  SOCIETA' A RESPONSABILITA' LIMITATA	Commercialista	393.9255943	\N	valentinodiprisco@studiodiprisco.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.478231	2025-08-06 18:44:29.479125	\N
992dcf05-ecbf-457b-a862-287d72ca726a	\N	Silvia	Giustiniani	\N	C.O.F. - CENTRO ORTOPEDICO FISIOTERAPICO  SOCIETA' A RESPONSABILITA' LIMITATA	Consulente del lavoro	339.2379985	\N	giustiniani@cnaroma.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.480095	2025-08-06 18:44:29.479125	\N
66b9a105-797b-4498-8c6f-a4d188843710	\N	Manolo	Centrella	\N	ESSEPIEFFE ITALIA S.R.L.	Socio Amministratore	\N	329 5735969	m.centrella@essepieffeitalia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.481023	2025-08-06 18:44:29.479125	\N
921f0e69-cb4f-4bd7-b0aa-7e7a884702f8	\N	Stefano	Brazzioli	\N	B&B SERVICE S.R.L.	Referente	335.6748651	\N	stefano.b@dpr462.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.481894	2025-08-06 18:44:29.479125	\N
253f4627-ef89-4f41-8d04-56c335901ae5	\N	Barbara	Lestini	\N	LESTINI FRANCO	Referente	328.8852200	\N	officinalestini@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.482786	2025-08-06 18:44:29.479125	\N
60524664-0804-459d-82e6-b94375554759	\N	Cristina	(Ufficio Roma)	\N	GESTIONE BENESSERE SRL	Referente Formazione 4.0	333 5814191;06 49776876	\N	gestionebenessere@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.483794	2025-08-06 18:44:29.479125	\N
ae20bc43-4d84-4e75-9dd7-907abfb31f23	\N	Jacopo	Odorico	\N	VE.GA. BOOKING SRL	Ragioniere	\N	392.6020222	jacopo@apogia.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.484626	2025-08-06 18:44:29.479125	\N
0988cb26-ae02-4e51-a38e-f741a7affa4f	\N	Teo	Bocchinfuso	\N	BRINDISI ELEVATORI S.R.L.	Referente	392.4744813	\N	sicurezza@brindisielevatori.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.485756	2025-08-06 18:44:29.479125	\N
521b68e4-6e64-43c6-98cd-11c2f73e0eab	\N	Luigi	Roberti	\N	NON SOLO IMPIANTI S.R.L.	Titolare	335.1038535	\N	luigiroberti71@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.486608	2025-08-06 18:44:29.479125	\N
74615f30-3c63-482a-8123-1d29298817e0	\N	Cristina	Lofari	\N	ALPHA COSTRUZIONI E IMPIANTI S.R.L.	Referente	0832-277686	\N	lofari.cristina@aliaci.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.487417	2025-08-06 18:44:29.479125	\N
616e4112-0c24-4d59-a85b-b2f2e53d3e20	\N	Angelo	Liaci	\N	ALPHA COSTRUZIONI E IMPIANTI S.R.L.	Titolare	336.826310	\N	liaci.angelo@aliaci.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.488349	2025-08-06 18:44:29.479125	\N
74fb8246-a4b3-46f3-982a-c70bca53cb46	\N	Dott.ssa	Gentile	\N	ALPHA COSTRUZIONI E IMPIANTI S.R.L.	Referente	335.1207316	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.489162	2025-08-06 18:44:29.479125	\N
90e3c1ac-903a-4f1d-87b0-8aee485a45d8	\N	Giuseppe	Papa	\N	VE.GA. CED SRL	Titolare	\N	335.7126477	giuseppe@apogia.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.490004	2025-08-06 18:44:29.479125	\N
a48dbbd8-faab-43de-b8e9-107cc65547c0	\N	Giovanni	Stefanon	\N	C.B.A. S.R.L.	Titolare	\N	331.4184828	giovanni.s@clinicaveterinariaconcordia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.490941	2025-08-06 18:44:29.479125	\N
e8085c91-92a6-4188-b5b6-8eede807b611	\N	Salvatore	Tondo	\N	TONDO SALVATORE	Titolare	320.7569535	\N	etnosalento.le@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.491698	2025-08-06 18:44:29.479125	\N
eacf4368-8577-4658-94a7-8ed4ec7166ba	\N	Dario	Morone	\N	LOGTRAS S.A.S.	Referente	\N	335.8047333	direzione@logtras.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.492509	2025-08-06 18:44:29.479125	\N
b22b5473-5482-44f1-8f9b-f0027ae87b3e	\N	Dario	Morone	\N	LOGTRAS S.R.L.	Referente	\N	335.8047333	direzione@logtras.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.493262	2025-08-06 18:44:29.479125	\N
4c24514d-71ae-46d1-89cc-8073bc534da6	\N	Francesco	Favrin	\N	POLG SRL	Titolare	391.3609679	\N	effefavrin@polg.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.494045	2025-08-06 18:44:29.479125	\N
a6161a6f-28b9-4bec-a416-23da0a785866	\N	Marica	Brunello	\N	POLG SRL	Referente	0424.570192	\N	conta.for@polg.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.494827	2025-08-06 18:44:29.479125	\N
7e8edf40-03e3-469f-b7ea-3396e0c4321c	\N	Natale	Calderato	\N	SKYNAT SRL	Titolare	348.0349596	\N	natale@skynat.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.495585	2025-08-06 18:44:29.479125	\N
25bdb08e-472b-4d60-902b-33ba54e0b052	\N	Matteo	Serra	\N	ECOSISTEMA SAS DI MATTEO SERRA & C.	Titolare	\N	333.4745118	studiomatdue@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.496408	2025-08-06 18:44:29.479125	\N
c0026a18-51cb-4852-babd-eee9275030bd	\N	Sonia	Sartori	\N	SKYNAT SRL	Legale rappresentante	0445.820024	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.497169	2025-08-06 18:44:29.479125	\N
042e4f00-bd27-4554-a2a4-95625fb441b4	\N	Graziella	Marchioro	\N	SKYNAT SRL	Amministrativa	0445.820024	\N	amministrazione@skynat.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.497961	2025-08-06 18:44:29.479125	\N
3a25799d-d2ec-46c9-8308-6f993f455fe7	\N	Studio Integrato	Studio Integrato	\N	SKYNAT SRL	Commercialista	0445.382372	\N	beatrice@spisrl.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.498798	2025-08-06 18:44:29.479125	\N
6deb547b-85d3-4891-8449-146eebc9a759	\N	Luca	Colombo	\N	SKYNAT SRL	Consulente del lavoro	0445.560600	\N	luca.colombo@tefide.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.499559	2025-08-06 18:44:29.479125	\N
691004ee-331b-4d72-88cc-4a8703b1d4e2	\N	Carlo	Del Pietro	\N	ENPOWER S.R.L.	Titolare	\N	\N	carlo.delpietro@enpower.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.500506	2025-08-06 18:44:29.479125	\N
1acceba0-2efe-48b3-97f7-a1ba7e7130fd	\N	Stefania	Mazzucato	\N	G.V.S. SRL	Titolare	348.2523843	\N	info@gvsstampi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.501439	2025-08-06 18:44:29.479125	\N
1b289d15-4aaa-47ae-98f8-658ec9071092	\N	Ellen	Cademartiri	\N	SABRE ITALIA S.R.L.	Referente	348.0027030	\N	ellen@sabreitalia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.502228	2025-08-06 18:44:29.479125	\N
cf260c05-f37c-47f0-af91-a508b9e31c72	\N	Allan	Cademartini	\N	SABRE ITALIA S.R.L.	Legale rappresentante	0444.977655	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.502993	2025-08-06 18:44:29.479125	\N
44537d8b-2001-404d-be0b-c510b3536a82	\N	Stefano	Golisano	\N	ANGELUS S.R.L.	Legale Rappresentate e Referente	\N	346 1473403	stefanogolisano@outlook.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.503733	2025-08-06 18:44:29.479125	\N
069e8b65-6962-40b1-9d76-83f823561276	\N	Valentina	Pietrobon	\N	TREVISOSTAMPA S.R.L.	Referente	327.4240021	\N	valentina.pietrobon@trevisostampa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.504576	2025-08-06 18:44:29.479125	\N
ceb6224c-c4ca-4748-94f4-5d2e8e9afd21	\N	Massimiliano	Papadia	\N	ROSSI S.R.L.	Referente	049.9201166	\N	massimiliano@rossisas.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.505374	2025-08-06 18:44:29.479125	\N
29520154-1b7e-45b4-ad09-69db1dd8ccbe	\N	Diego	Buggin	\N	MODELLERIA BUGGIN S.R.L.	Titolare	348.4421102	\N	diego@modelleriabuggin.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.506233	2025-08-06 18:44:29.479125	\N
e781b827-774e-40c4-ad4d-060fdfd9bfd3	\N	Emma	Zancan	\N	MODELLERIA BUGGIN S.R.L.	Referente	348.4421103	\N	amministrazione@modelleriabuggin.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.507025	2025-08-06 18:44:29.479125	\N
b3544c6e-96fe-47dc-8656-b676bb0d99aa	\N	Paolo	Nico	\N	\N	Referente	342.5255732	\N	risorse@impresacoima.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.5078	2025-08-06 18:44:29.479125	\N
bb5058d4-2bf3-48b4-acb4-cc7a4b18c74d	\N	Mario	Nico	\N	IMPRESA EDILE ABBADESSE S.R.L.	Referente	348.4066190	\N	risorse@edileabbadesse.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.508623	2025-08-06 18:44:29.479125	\N
6f34354d-d410-47bf-a45e-2825d40f69a9	\N	Matteo	Bonetti	\N	BONFANTI CAR SRL	Referente	348.4485229	\N	bonfanticar@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.509483	2025-08-06 18:44:29.479125	\N
72bcd238-9172-458a-9a24-17d1fa9203ec	\N	Anna	Matzedda	\N	BONFANTI CAR SRL	Commercialista	035.373358	\N	info@coesasrl.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.510336	2025-08-06 18:44:29.479125	\N
a9ad5a13-8297-45b1-b6b0-2c2f6a114b68	\N	Elena	Bergero	\N	F.A.I.C. INDUSTRY S.R.L.	Revisore interno	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.511213	2025-08-06 18:44:29.479125	\N
0ae7034f-f9c3-4ddd-a409-dfe327de45f3	\N	Marco	Bonfanti	\N	BONFANTI CAR SRL	Titolare	345.8101855	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.511989	2025-08-06 18:44:29.479125	\N
413e0d0f-96fa-4d98-802a-1cf4bc0c7cbb	\N	Giuseppina	Vinciguerra	\N	B.L.T. TRANSPORT SRL	Referente	0522.087370	\N	amministrazioneblt@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.512695	2025-08-06 18:44:29.479125	\N
cdb7b7b1-f2b7-4b65-9c54-f26e5c6ba769	\N	Nunzia	Formicola	\N	B.L.T. TRANSPORT SRL	Titolare	366.9596172	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.513459	2025-08-06 18:44:29.479125	\N
769bc4a5-50a0-4e11-b7d0-42f248657986	\N	Lando	Franchi	\N	\N	Partner esterno e Revisore	329 9442536	\N	info@landofranchi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.514201	2025-08-06 18:44:29.479125	\N
fa92396e-d1cd-4ddd-89a5-4954a071faca	\N	Fausto	Costenaro	\N	STUDIO COSTENARO S.R.L.	Titolare	335.1368495	\N	studiocostenaro@integrabusiness.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.514913	2025-08-06 18:44:29.479125	\N
7bb67bc0-79b3-4121-802a-8084704ab2a5	\N	Anna Maria	Lumaca	\N	GRUPPO LUMACA S.R.L.	Socia	348.9042240	\N	annamaria@lumacagroup.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.515699	2025-08-06 18:44:29.479125	\N
eebe09dc-e8a0-40af-9e6c-d0492151c713	\N	Kujtim (Nick)	Mataj	\N	KM S.R.L.	Titolare	320.3663816	\N	kmsrl@yahoo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.516426	2025-08-06 18:44:29.479125	\N
cab7e2d5-5afc-4a9e-bfd3-7e6f96e25029	\N	Mirco	Gallerani	\N	LA PERGOLA SRLS	Titolare	335.7503403	\N	info@alleaie.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.517225	2025-08-06 18:44:29.479125	\N
f5586aff-64ff-46fe-a559-76b76f163555	\N	Mara	Serra	\N	SERRA TRASPORTI E LOGISTICA S.R.L.	Referente	3474398026	\N	serratrasportilogisticasrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.517985	2025-08-06 18:44:29.479125	\N
b14db79a-f77f-46bb-93b1-0cf8f3fe67e8	\N	Luigi Massimiliano	Serra	\N	SERRA TRASPORTI E LOGISTICA S.R.L.	Titolare	347.4398026	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.518765	2025-08-06 18:44:29.479125	\N
33e6a347-fe55-4e2a-ad39-2fca6b42fb52	\N	Giancarlo	Matzutzi	\N	CONSULCOOP SOCIETA' COOPERATIVA A RESPONSABILITA' LIMITATA	Referente	347.1919484	\N	presidenza.consul@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.519662	2025-08-06 18:44:29.479125	\N
bd6b9f63-36fe-4e4e-a365-b3483b989123	\N	Silvio	Frongia	\N	S. E C. S.R.L.	Referente	348.1558671	\N	silviofrongia@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.522333	2025-08-06 18:44:29.523032	\N
739b8bc9-0be2-4932-9b59-9893fd335814	\N	Gianluca	Piga	\N	ANTEA S.R.L.S.	Socio	347.9342518	\N	anteassicurazioni@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.523768	2025-08-06 18:44:29.523032	\N
a401616f-8e8c-4c92-ad3b-c95b9d2e86f3	\N	Miriam	Carboni	\N	ANTEA S.R.L.S.	Consulente del lavoro	338.9834153	\N	carbonimiriam@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.524634	2025-08-06 18:44:29.523032	\N
0cdacd0b-7471-4670-a60c-42af73fbd5a9	\N	Mattia	Murgia	\N	ANTEA S.R.L.S.	Commercialista	349.1382923	\N	studio.murgiamattia@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.525556	2025-08-06 18:44:29.523032	\N
7ad6fa66-c841-455c-8791-686ffa4a6202	\N	Marcello	Martis	\N	ANTEA S.R.L.S.	Socio	3286329951	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.526449	2025-08-06 18:44:29.523032	\N
4b6a04fc-2c0d-4c0e-b77c-5413bb11ed20	\N	Sara	Cau	\N	CLOUD CONSULENTICA S.R.L.	Titolare (Referente)	3403976566	\N	direzione@consulentica.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.52729	2025-08-06 18:44:29.523032	\N
35e69130-9a85-4853-adf4-15b4a17a2bca	\N	Daniela	Abis	\N	CLOUD CONSULENTICA S.R.L.	Consulente del lavoro	347.5045752	\N	d.abis74@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.528204	2025-08-06 18:44:29.523032	\N
4a87fba4-703d-4f84-aed2-dd7afbad036d	\N	Renzo	Mereu	\N	LEO VIRIDIS S.R.L.	Titolare	392.4815404	\N	renzo.mereu84@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.529081	2025-08-06 18:44:29.523032	\N
db9702c5-fbb1-409d-9f20-e597683392a7	\N	Renzo	Mereu	\N	OHANA S.R.L.	Titolare	392 4815404;0783 83792	\N	renzo.mereu84@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.529932	2025-08-06 18:44:29.523032	\N
12b1065e-18ec-4703-92e1-fbd20c59201b	\N	Alberto	Pievani	\N	BANCA VALSABBINA	Resp. Finanza Agevolata	\N	\N	alberto.pievani@bancavalsabbina.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.530749	2025-08-06 18:44:29.523032	\N
e484bf22-6d12-4b5b-b8a0-c66583a4b1b6	\N	Alessandro	Casella	\N	INNPROJEKT FUTURE LAB SRL	Referente	\N	366.3227383	a.casella@innprojekt.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.531623	2025-08-06 18:44:29.523032	\N
03a10aa3-da79-4130-87ae-4859a45e7950	\N	Davide	Verdesca	\N	SINERGIE S.R.L.	Legale rappresentante	348.3680026	\N	d.verdesca@sinergie.org	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.532483	2025-08-06 18:44:29.523032	\N
c300b79c-960d-496d-953f-4f3ef9e97039	\N	Francesco	Merone	\N	SG COMPANY SOCIETA' BENEFIT SPA E CON SIGLA  SG COMPANY S.B. SPA	Referente	348.3252143	\N	f.merone@sg-company.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.533334	2025-08-06 18:44:29.523032	\N
e54cbe56-7b58-4f29-a98d-90b2e39a6788	\N	Leonardo	Bozzo	\N	CENTRO SERVIZI S.E.F. S.R.L.	Legale Rappresentante	335.6149658	\N	leobozzo@centroservizisef.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.534361	2025-08-06 18:44:29.523032	\N
417d75a7-f373-4ab0-9c58-acc7090d5f31	\N	Vincenzo	Valentino	\N	AUTOMOBILI VALENTINO SRL	Titolare	340.6762828	\N	automobilivalentino@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.535491	2025-08-06 18:44:29.523032	\N
57f29996-2b2e-45e3-8a9e-359630c822dc	\N	Mauro	Elias	\N	SUNSERVICE ENERGY SOLUTIONS S.R.L.	Referente	335.6077331	\N	mauro.elias@sunservice.biz	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.536689	2025-08-06 18:44:29.523032	\N
8ab69519-4dd4-4d6e-9465-e2dcb091c2c6	\N	Antonello	Palmas	\N	SUNSERVICE ENERGY SOLUTIONS S.R.L.	Titolare	392.9972861	\N	antonello@sunservice.biz	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.537872	2025-08-06 18:44:29.523032	\N
3bffe9e3-6ccc-4886-b343-140f2bc43b52	\N	Mauro	Elias	\N	SUNSERVICE S.R.L.	Referente	335.6077331	\N	mauro.elias@sunservice.biz	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.539079	2025-08-06 18:44:29.523032	\N
436861d4-ecca-4c36-a927-a206b67f64fe	\N	Antonello	Palmas	\N	SUNSERVICE S.R.L.	Titolare	392.9972861	\N	antonello@sunservice.biz	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.540217	2025-08-06 18:44:29.523032	\N
5c9bc436-1492-4aaf-896c-4d45904c772f	\N	Antonio	Ruttino	\N	SUNSERVICE S.R.L.	Commercialista	079.2824080	\N	dantrutt@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.541473	2025-08-06 18:44:29.523032	\N
cd6f2519-260b-4111-8a42-f003f100d154	\N	Giovanni	Frau	\N	SUNSERVICE S.R.L.	Consulente del lavoro	079.262619	\N	g.frau@studiofrau.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.542633	2025-08-06 18:44:29.523032	\N
dc6cd49c-6423-46b2-9f79-949623d9dd08	\N	Nadia	Masella	\N	BENE S.R.L.	Titolare	339.6895110	\N	amministrazione@benesrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.543835	2025-08-06 18:44:29.523032	\N
ca07a672-21df-47b4-9e7e-3633e0b37235	\N	Alessandro	Fornero	\N	BENE S.R.L.	Commercialista	01.0465117	\N	alessandrofornero@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.544878	2025-08-06 18:44:29.523032	\N
8fee8083-b13d-4567-a5f6-9a4e786f44e0	\N	Fabrizio	Capurro	\N	BENE S.R.L.	Consulente del lavoro	0187.5722251	\N	paghe@ragrobertomusso.191.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.545774	2025-08-06 18:44:29.523032	\N
a7b3772b-4999-4e2c-ba11-ff74842e7194	\N	Roberto	Galuppini	\N	GALUPPINI RAG. ROBERTO	Titolare	\N	\N	roberto.galuppini@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.546725	2025-08-06 18:44:29.523032	\N
7c4fdbe8-c095-4406-a5c2-237a508f98e6	\N	Gabriele	Gneri	\N	\N	Proprietario	335.8749031	\N	gabriele.gneri@hotelsdoctors.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.547711	2025-08-06 18:44:29.523032	\N
46be09bc-ff92-409d-9de8-652a1360c219	\N	Mattia	Balasso	\N	C.M. BALASSO SRL	Socio Amministratore	\N	347.4249308	info@cmbalasso.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.548861	2025-08-06 18:44:29.523032	\N
700b2543-b8d6-409a-ae2a-e049e75353d6	\N	Nicola	Giovannoni	\N	P.R. COMMERCIALISTI RIUNITI SOCIETA' TRA PROFESSIONISTI S.R.L. IN SIGLA: P.R. COMMERCIALISTI RIUNITI S.T.P. S.R.L.	Referente	347.1857642	\N	giovannoninicola@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.550063	2025-08-06 18:44:29.523032	\N
52f0801e-ee26-40d3-93ae-d0c09b54ab53	\N	Renato	Della Pina	\N	DELLA PINA RENATO	Titolare	348 2341504	\N	renato.dellapina@cheapnet.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.55111	2025-08-06 18:44:29.523032	\N
a11c721c-7b80-4839-93f2-81148763c41b	\N	Gianmaria	Della Pina	\N	DELLA PINA RENATO	Figlio del Titolare	392 1135545	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.551988	2025-08-06 18:44:29.523032	\N
9c8a9990-06a2-474f-8453-5e6b7c4e4b05	\N	Nicola Domenico	Fiori	\N	EFINEN SRL	Titolari	340.0783586	\N	nicoldomenico@gmail.com;magnaescappa@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.552838	2025-08-06 18:44:29.523032	\N
101ebb76-5990-4dd8-bb68-b07721a62d28	\N	Andrea	Lusardi	\N	LUSARDI SAS DI LUSARDI ENRICO & FRATELLI	Titolare	348.5266075	\N	andrea.lusardi@lusardilogistica.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.553716	2025-08-06 18:44:29.523032	\N
478a36b1-a34a-4d47-a1c9-f34a5275f9db	\N	Raffaele	Parodi	\N	LUSARDI SAS DI LUSARDI ENRICO & FRATELLI	Referente	0108.353086	\N	raffaele.parodi@lusardisas.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.554708	2025-08-06 18:44:29.523032	\N
75756678-6e6c-4792-8254-ddb380c27bdb	\N	Stefano	Cecchetti	\N	PACINI TRADE S.R.L.	Titolare-Referente	328.6758879	\N	stefano@pacinitrade.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.555673	2025-08-06 18:44:29.523032	\N
58c9d4ee-dc5a-4f3e-a1c3-132d362a81be	\N	Lorenzo	Corazza	\N	CORAZZA LORENZO GABRIELE E C. S.A.S.	Titolare	348.3836732	\N	lorecorazza@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.556869	2025-08-06 18:44:29.523032	\N
2cbcaf4d-578a-4dd3-8a57-2ec1b95fd7c3	\N	Luca	Baccelli	\N	BACCELLI LUCA	Titolare	335.6906538	\N	lucabaccelli2010@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.55804	2025-08-06 18:44:29.523032	\N
97d84209-23fc-460e-8d4c-69526dc23223	\N	Giada	Crescenzi	\N	ROEMER GROUP DI MARCO BOZZA SAS	Responsabile Ufficio Amministrazione ( Referente)	393.4832362	\N	segreteria@roemergroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.559185	2025-08-06 18:44:29.523032	\N
2b00f7aa-9a8d-42a5-b23b-a01e31bd804c	\N	Roberto	Bonicciolli	\N	DALDOSS ELEVETRONIC S.P.A.	Responsabile Amministrazione	340.1885825	\N	amministrazione@daldoss.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.560366	2025-08-06 18:44:29.523032	\N
9d679d39-2f16-4fe5-87dd-ca86248f8fda	\N	Andrea	Daldoss	\N	DALDOSS ELEVETRONIC S.P.A.	Titolare	334.6721344	\N	andrea.daldoss@daldoss.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.561554	2025-08-06 18:44:29.523032	\N
6fdc1011-f1fd-4ccd-9b26-1b1ba4bad1ec	\N	Marco Giuseppe	Fontana	\N	GEOTAG  S.R.L.	Titolare	348.7912171	\N	m.fontana@geotagzone.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.562682	2025-08-06 18:44:29.523032	\N
de33dfdf-5da7-4cd5-b006-43633972b2e7	\N	Antonio	Musio	\N	KALINTOUR S.R.L.	Titolare	328.9846689	\N	antonio@kalintour.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.565087	2025-08-06 18:44:29.523032	\N
e9a77d32-25fc-4505-bd50-623dac419ecf	\N	Massimo	Dell'Anna	\N	RDE TEAM S.R.L.	Titolare	329.0537403	\N	massimodellanna1972@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.566355	2025-08-06 18:44:29.523032	\N
1d3a4702-703a-4ba0-b3ec-d67a0c7f1f3a	\N	Gemma	Zaccaria	\N	RDE TEAM S.R.L.	Referente	324.7405555	\N	amministrazione@rdeteam.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.567487	2025-08-06 18:44:29.523032	\N
99b7d658-a4b5-415c-9538-59c58e243c21	\N	Andrea	Parascandolo	\N	PUNTORICARICA S.R.L.	Titolare	380.7823431	\N	direzione@puntoricarica.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.568608	2025-08-06 18:44:29.523032	\N
29a89899-51e0-44bd-ae9b-a1eb5a305d3b	\N	Serafino	De Giuseppe	\N	PUNTORICARICA S.R.L.	Referente	392.7066000	\N	serafino.degiuseppe@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.569784	2025-08-06 18:44:29.523032	\N
74021cf0-b76c-4be0-8499-d11be8112feb	\N	Gino	Bigai	\N	G.B.M. SYSTEM DI MUMMOLO DORA & C. S.A.S.	Socio Amministratore	\N	393.9937824	gino.bigai@gbmsystem.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.57094	2025-08-06 18:44:29.523032	\N
dd3a23a8-60dd-47ec-8707-aa9bcb05df04	\N	Fabio	Moro	\N	AL CANTINON DI MORO FABIO E C. S.N.C.	Titolare	\N	345.5912224	fabiomoro1704@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.572084	2025-08-06 18:44:29.523032	\N
0c47830d-2d44-471d-9868-86c9481624fa	\N	Maria Luisa	De Matteis	\N	PUNTORICARICA S.R.L.	Commercialista	328.0149445	\N	mluisa.dematteis69@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.573329	2025-08-06 18:44:29.523032	\N
bf25d189-59fc-49cb-9f50-1ed151d01ba7	\N	Michele	Ceccato	\N	CECCATO MOTORS S.R.L.	\N	\N	348.3773767	michele.ceccato@ceccatomotors.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.574555	2025-08-06 18:44:29.523032	\N
e43155e7-a0c1-4c88-96ae-ddbfa5f688d8	\N	Marco	Danuso	\N	D4U S.R.L.	Socio	\N	+3168515295	marco@dolomiti4u.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.575737	2025-08-06 18:44:29.523032	\N
d60ec202-fcc4-467f-92b2-ee0ad2f8097d	\N	Bruno	Ghedini	\N	D4U S.R.L.	Socio	\N	342.8534040	amministrazione@dolomiti4u.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.578987	2025-08-06 18:44:29.580033	\N
f2820a6a-076e-4b94-9c30-407946cdc51b	\N	Massimo	Schirosi	\N	MEG SERVICE S.R.L.	Referente	329.9468212	\N	massimo.schirosi@megservice.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.58094	2025-08-06 18:44:29.580033	\N
3e3519b5-eb8d-4fc1-bd85-f95a30ff8e53	\N	Gianfranco	Fiorentino	\N	MEG SERVICE S.R.L.	Titolare	0831.619229	\N	gianfranco.fiorentino@megservice.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.581953	2025-08-06 18:44:29.580033	\N
bf5be46c-7ba0-4e57-8ef1-b11920001792	\N	Ludovica	Doria	\N	S.I.A.P. SOCIETA' INDUSTRIALE ALBERGO DELLE PALME *S.R.L.	Referente	320.4863716	\N	sales@hoteldellepalmelecce.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.58283	2025-08-06 18:44:29.580033	\N
d8277a43-236d-44ad-a2ae-45d3f05a238c	\N	Roberto	Astuni	\N	BASSANO HOTEL SAS DI DARIA CONTE & C.	Titolare	339.2991587	\N	direzione@hotelallacorte.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.583756	2025-08-06 18:44:29.580033	\N
4ebc8ce3-d2aa-4d6d-b32c-70a170baaf24	\N	Michele	Chimienti	\N	CONSOLIDATI S.R.L.	Titolare	329.7361531	\N	michele.chimienti@consolidati.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.584669	2025-08-06 18:44:29.580033	\N
1ddbfc28-2cbb-4019-aa5d-e97ed7dfb860	\N	Lorena	Villa	\N	GRANDI VACANZE S.R.L.	Referente	0565.917888	\N	lorena.villa@napoleonviaggi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.585525	2025-08-06 18:44:29.580033	\N
62f4dfa6-abf3-44e2-bca0-51195b63a664	\N	Emanuele	Calianno	\N	CALEMA S.R.L.	Titolare	347.1477828	\N	calemasrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.586364	2025-08-06 18:44:29.580033	\N
e589c06c-ecaf-46a2-b06a-d3f25349717e	\N	Simone	Amendola	\N	CALEMA S.R.L.	Referente	379.187.6997	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.587233	2025-08-06 18:44:29.580033	\N
93819c61-c836-4b95-8d9b-92a382520e7a	\N	Alfonso	Lombardi	\N	I. C. & E. S.R.L.	Titolare	349.7393871	\N	a.lombardi@itce.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.588176	2025-08-06 18:44:29.580033	\N
5fe42605-7b03-422e-b72a-26f38595e0b9	\N	Paola Rosaria	Disarò	\N	PIEFFE S.R.L.	Rappresentante Legale	393.0101835	\N	info@pieffe-srl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.589077	2025-08-06 18:44:29.580033	\N
8be3a8c4-e48c-4f83-9d73-8e1d8aab22d2	\N	Alberto	Simonato	\N	PIEFFE S.R.L.	Socio Amministratore	347.1832229	\N	info@pieffe-srl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.589995	2025-08-06 18:44:29.580033	\N
bb210e87-7f58-4d0e-a466-a5195b199337	\N	Federica	Gianfranchi	\N	\N	Commercialista	345 0906211	\N	federica.gianfranchi@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.591788	2025-08-06 18:44:29.580033	\N
4c63662f-24e7-48e6-aadd-da78d73a2bc8	\N	Mauro	Scudeler	\N	MD FRIGO SERVICE S.N.C. DI SCUDELER MAURO & C.	Titolare	338.5321102	\N	amministrazione@mdfrigoservice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.592718	2025-08-06 18:44:29.580033	\N
02935a64-9b9d-4d9b-8828-01efe369e556	\N	Elisa	Tolomio	\N	MD FRIGO SERVICE S.N.C. DI SCUDELER MAURO & C.	Referente	0431.43253	\N	amministrazione@mdfrigoservice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.593579	2025-08-06 18:44:29.580033	\N
c14650cc-16b8-435c-9af6-75b068fa40fa	\N	Emanuele	Vidotti	\N	PALMARKET DI VIDOTTI EMANUELE & C. S.A.S.	Titolare	347.4418668	\N	commerciale@palmarket.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.594495	2025-08-06 18:44:29.580033	\N
c5868496-98e8-44df-81fb-8d8ceb265428	\N	Giada	Bevilacqua	\N	PALMARKET DI VIDOTTI EMANUELE & C. S.A.S.	Referente	0432.660143	\N	amministrazione@palmarket.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.595466	2025-08-06 18:44:29.580033	\N
2054469e-4c4d-4c1c-96c9-c424636fc528	\N	Jacopo	Bassi	\N	GELARTE SRL	Rappresentante Legale	\N	324 8193817	gelartesrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.596335	2025-08-06 18:44:29.580033	\N
95d44aec-96d8-48af-8e7f-12d071f9a64e	\N	Elia	Berlingerio	\N	FISIOMED ITALIA SRL	Referente	338.7078858	\N	e.berlingerio@fisiomedambulatori.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.597184	2025-08-06 18:44:29.580033	\N
c8456d5a-2fe8-49f0-bc0d-d7253b3e6d92	\N	Rosanna	Forza	\N	FISIOMED ITALIA SRL	Legale Rappresentante	349.3534909	\N	amministrazione@fisiomedambulatori.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.598177	2025-08-06 18:44:29.580033	\N
59fd21c3-998f-43d1-adc5-71810a61921f	\N	Manuela	Tonolo	\N	FARMACIA INTERNAZIONALE DI CONEGLIANO S.R.L.	Titolare	377.3375553	\N	tonolofarm@yahoo.it;info@farmaciainternazionaleconegliano.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.599084	2025-08-06 18:44:29.580033	\N
478ca559-14c2-49fe-9f28-ccdfb7f12cf7	\N	Laura	Scatolini	\N	FARMACIA INTERNAZIONALE DI CONEGLIANO S.R.L.	Referente	0438.415554	\N	info@farmaciainternazionaleconegliano.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.599942	2025-08-06 18:44:29.580033	\N
5a025fdf-2edd-4b1e-b71e-e01bf5d47943	\N	Mirko	Rugolo	\N	FARMACIA INTERNAZIONALE DI CONEGLIANO S.R.L.	Commercialista	0422.1590065	\N	segreteria@studiorugolo.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.600749	2025-08-06 18:44:29.580033	\N
c437b574-6455-4087-85c5-aae7bcfd7eb9	\N	Paolo	Sacilotto	\N	FARMACIA INTERNAZIONALE DI CONEGLIANO S.R.L.	Consulente del lavoro	0422.235999	\N	paghe@sacilottopellegrini.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.601626	2025-08-06 18:44:29.580033	\N
6d84ca98-ac5e-488c-80ad-87f606703ab5	\N	Fabrizio	Cusin	\N	SEASON S.R.L.	Titolare	351.5589320	\N	fabriziocusin@me.com;amministrazione@seasonsrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.602473	2025-08-06 18:44:29.580033	\N
4bb26bb2-1cb5-405b-973e-30b67f2bb22f	\N	Antonio	Bergamo	\N	SEASON S.R.L.	Commercialista	348.8730472	\N	a.bergamo@sbpassociati.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.603332	2025-08-06 18:44:29.580033	\N
e7a03f1e-3a0c-4830-90e5-f5858e0f7b02	\N	Katia	Collaviti	\N	SEASON S.R.L.	Referente	351.5589320	\N	amministrazione@seasonsrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.60421	2025-08-06 18:44:29.580033	\N
446e3ccb-6cc6-4215-b0a7-d98776da8cfd	\N	Mirco	Ramanzin	\N	RAMITOURS SRL	Titolare	338.2733632	\N	mirco.ramanzin@ramitours.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.605032	2025-08-06 18:44:29.580033	\N
775fd974-1af0-492f-97b3-6ed9b604b001	\N	Antonietta	Rossi	\N	RAMITOURS SRL	Referente	0444.1322644	\N	amministrazione@ramitours.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.605985	2025-08-06 18:44:29.580033	\N
130a184f-e9ce-447c-95e9-f9b5bb659ac5	\N	Angela	Bernardi	\N	SALUS S.R.L.	Referente	339.4522110	\N	sicurezza@grupposalus.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.606865	2025-08-06 18:44:29.580033	\N
6ba99563-f77d-4ff3-9900-984618f96f00	\N	Lorenzo	Bertacco	\N	SALUS S.R.L.	Titolare	335.5936086	\N	bertacco@grupposalus.it;sicurezza@grupposalus.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.60771	2025-08-06 18:44:29.580033	\N
f75f4007-c61d-45cd-8016-09a4d8e13966	\N	Michele	Lincetto	\N	POLTRONA EMME SRL	Titolare	\N	327.7372725	poltronaemme@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.608634	2025-08-06 18:44:29.580033	\N
951d3d57-ab0f-4de2-a363-5ac05d5c02ee	\N	Antonia	Zoccali	\N	SALUS S.R.L.	Consulente del Lavoro	0424.470566	\N	katia.magrin@ericed.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.609518	2025-08-06 18:44:29.580033	\N
59dda009-9074-4a60-9972-b4219cca51b7	\N	Alessandra	Zennaro	\N	POLTRONA EMME SRL	Amministrativa	049.9200966	\N	poltronaemme@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.610366	2025-08-06 18:44:29.580033	\N
de706332-b7fc-42e1-89c8-9cff534814ae	\N	Nicola	D'Orazio	\N	GRAPHIC DIVISION DI ALBIERI NORBERTO	Commercialista	\N	335.1500760	nicola.dorazio@studiodorazio.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.611244	2025-08-06 18:44:29.580033	\N
0965835d-5069-400e-9e48-39135f14afdf	\N	Cinzia	Munerato	\N	AUTOACCESSORIO POLESANO DI MUNERATO FABRIZIO & C. S.N.C.	Socia Amministratore	\N	335.7597375	info@autoaccessoriopolesano.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.61213	2025-08-06 18:44:29.580033	\N
f848684f-a1b4-46e0-b366-d9b22dee5a4b	\N	Mauro	Brotto	\N	BROTTER SRL	Titolare	392.7995026	\N	commerciale@brotter.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.612986	2025-08-06 18:44:29.580033	\N
62420dfd-8ffc-4f30-b65f-0addab639af1	\N	Sara	Daldin	\N	BROTTER SRL	Amministrativa ( Referente)	0424.592363	\N	amministrazione@brotter.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.613832	2025-08-06 18:44:29.580033	\N
ad84b588-7b62-4ec5-a4d9-f228e69b3ea6	\N	Antonia	Zoccali	\N	BROTTER SRL	Consulente del Lavoro	0424.470566	\N	antonella@ericed.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.614603	2025-08-06 18:44:29.580033	\N
8d7e31a4-d3e9-40c7-8ae2-bed540f2a6e5	\N	Luca	Rebellato	\N	LEO BET SRL	Referente	328.9321852	\N	info@leobetsrl.it;amministrazione@leobetsrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.615603	2025-08-06 18:44:29.580033	\N
51e115de-370e-4902-8e70-9270524276b0	\N	Angelo	Costenaro	\N	LEO BET SRL	Legale Rappresentante	3289321852	\N	amministrazione@leobetsrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.616561	2025-08-06 18:44:29.580033	\N
34fcf611-2757-4262-b9f0-09109849310a	\N	Denis	Conte	\N	MAZARACK DI CONTE DENIS & C. S.N.C.	Titolare	338.5445410	\N	info@mazarack.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.61748	2025-08-06 18:44:29.580033	\N
65472dc8-2790-4cfa-b11d-24ef6a08b616	\N	Alessandro	Tonolo	\N	FARMACIA TONOLO DR. ALESSANDRO S.A.S.	Titolare	392.9769563	\N	info@farmaciatonolo.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.618378	2025-08-06 18:44:29.580033	\N
1afbf208-a163-48a9-825a-b9defe35ecae	\N	Federica	Vailati	\N	FARMACIA TONOLO DR. ALESSANDRO S.A.S.	Referente	333.2127298	\N	info@farmaciatonolo.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.619324	2025-08-06 18:44:29.580033	\N
93ffe47e-9d78-4efc-8bed-518a0bfc5f43	\N	Federica	Tinazzi	\N	FARMACIA TONOLO DR. ALESSANDRO S.A.S.	Commercialista	0422.1590065	\N	federica.tinazzi@studiorugolo.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.620242	2025-08-06 18:44:29.580033	\N
17459964-837f-4238-8e5e-32affcdfd9e1	\N	Marcella	Pasqualato	\N	FARMACIA TONOLO DR. ALESSANDRO S.A.S.	Consulente del lavoro	0422.570702	\N	m.pasqualato@ascom.tv.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.621166	2025-08-06 18:44:29.580033	\N
108822ae-dc96-498c-984b-00b18d289f11	\N	Liliana	Cerrone	\N	STUDIO CERRONE & TARGA SRL	Titolare	338.6097407	\N	l.cerrone@studiocerrone.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.622062	2025-08-06 18:44:29.580033	\N
3c39b425-696f-427b-9ccc-f1cff0cae329	\N	Paolo	Canetto	\N	STUDIO CERRONE & TARGA SRL	Consulente del lavoro	347.7128793	\N	info@canetto.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.622892	2025-08-06 18:44:29.580033	\N
eabd7b60-7f18-447d-bf58-acddcfcd475c	\N	Petruska	Sbabo	\N	MECCANICA SBABO SRL	Titolare	339.6709611	\N	amministrazione@meccanicasbabo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.623763	2025-08-06 18:44:29.580033	\N
cae42c2f-2b02-445d-acf4-7740c4d10607	\N	Matteo	Boieri	\N	\N	Amministratore Delegato	320.4195926	\N	matteo.boieri@autoveicolierzelli.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:36.87863	2025-08-06 18:45:36.878122	\N
0063605d-dbbc-4179-8fa7-6c55635b8c91	\N	Alessandro	Ladu	\N	\N	Referente	3455913950	\N	alessandro.ladu@laduservizi.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:36.965822	2025-08-06 18:45:36.965263	\N
61ba1497-af95-4494-bdc1-91bf55ad7b13	\N	Daniele	Pez	\N	\N	\N	\N	335.6135772	daniele.pez@evenio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.13695	2025-08-06 18:45:37.136338	\N
815155f4-c6a9-4d23-933e-b8901472e6b3	\N	Paolo	Nico	\N	\N	Referente	342.5255732	\N	risorse@impresacoima.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.245383	2025-08-06 18:45:37.244764	\N
b655cb1d-665d-4e33-9389-38f0f5916fef	\N	Lando	Franchi	\N	\N	Partner esterno e Revisore	329 9442536	\N	info@landofranchi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.260474	2025-08-06 18:45:37.259977	\N
a7d353da-809c-4137-9c71-ff5a55eab581	\N	Gabriele	Gneri	\N	\N	Proprietario	335.8749031	\N	gabriele.gneri@hotelsdoctors.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.322726	2025-08-06 18:45:37.322184	\N
c1996f3e-8049-45bc-b438-a56266c0e3a7	\N	Federica	Gianfranchi	\N	\N	Commercialista	345 0906211	\N	federica.gianfranchi@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.407082	2025-08-06 18:45:37.406451	\N
aedca09f-0024-4543-8bfb-c35c484c4fa2	\N	Riccardo	Dreas	\N	GORETTI GOMME DI DREAS RICCARDO & C. - S.A.S.	Titolare	348.820723	\N	riccardo@gorettigomme.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.479472	2025-08-06 18:45:37.47875	\N
e4dae7b2-96a0-471d-aecb-0d5ebba1a085	\N	Sara	Spanu	\N	GORETTI GOMME DI DREAS RICCARDO & C. - S.A.S.	Referente	040.3481535	\N	sara@gorettigomme.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.483039	2025-08-06 18:45:37.482157	\N
b98aa68c-7da9-4219-862d-f7c1fe3bc7dd	\N	Diana	Povolo	\N	SOLUTIONS 600 S.R.L.	Referente	329.0428877	\N	diana@solutions600.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.488239	2025-08-06 18:45:37.486739	\N
61627576-255b-4f08-926e-b2a5a1d7287f	\N	Mauro	Apperti	\N	SOLUTIONS 600 S.R.L.	Socio	329.0428990	\N	mauro@solutions600.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.493302	2025-08-06 18:45:37.491948	\N
3a5b0544-e0ff-4018-a8dd-9d2356199a7c	\N	Nino	Stazzone	\N	ASSICURATORE FACILE SRL - SOCIETA' BENEFIT	Titolare	392.4157602	\N	nino.stazzone@assicuratorefacile.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.497781	2025-08-06 18:45:37.496905	\N
a1598329-fcd0-4215-b315-8b912fc75ef7	\N	Michela	Dutto	\N	COBE S.R.L.	Referente	339.8450497	\N	cobecobestsrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.501732	2025-08-06 18:45:37.500725	\N
c2ebdfce-feb8-4e2c-87f1-f8e9e84c865f	\N	Alessandra	Mogentale	\N	MOGENTALE S.R.L.	Titolare	333.3316881	\N	info@mogentaleimpianti.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.505667	2025-08-06 18:45:37.504682	\N
74db2e58-084a-4939-8687-2d6893db1899	\N	Stefano	Dall'Osto	\N	STUDIO DALL' OSTO S.R.L.	Titolare	339 3548736	\N	stefano.dallosto@dallosto-partners.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.509723	2025-08-06 18:45:37.508774	\N
50b72620-dba5-4c31-b203-0faf4332cf6b	\N	Michele	Perotto	\N	STUDIO DALL' OSTO S.R.L.	Referente	0445.315119	\N	michele.perotto@dallosto-partners.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.514062	2025-08-06 18:45:37.51301	\N
0c9f6ac4-7ca6-4c8b-ab29-a79a1cea35cc	\N	Silvia	Binotto	\N	MJM ASSICURAZIONI SNC	Referente	0445.539016	\N	s.binotto@mjmass.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.518104	2025-08-06 18:45:37.516955	\N
cc24571a-9bdb-4d4e-bd4d-0f867e5ae87a	\N	Manuel	Meda	\N	MJM ASSICURAZIONI SNC	Titolare	349.7106567	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.521774	2025-08-06 18:45:37.520689	\N
b88615dd-53f3-4bca-be05-45ffea2d4dcf	\N	Erika	Vergine	\N	INFINITECH SOCIETA' COOPERATIVA	Referente	333.3687661	\N	infinitechcarpi@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.525361	2025-08-06 18:45:37.524306	\N
3f863661-bf71-4bfd-bf8b-8cad1de0ac1d	\N	Alexa	Celin	\N	I.M.A.S. SRL	Referente	347.1376556	\N	imas@imassnc.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.528825	2025-08-06 18:45:37.527791	\N
6055a420-4668-4e69-af11-3f1b47c2d0a0	\N	Antonio	Basso	\N	I.M.A.S. SRL	Titolare	0444.610264	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.532447	2025-08-06 18:45:37.531332	\N
73528ecb-c490-4fa7-a06e-9a9ccf8a086b	\N	Paola	Brajato	\N	STAMPO PRESS S.R.L.	Referente	0444.636002	\N	amministrazione@stampopress.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.536243	2025-08-06 18:45:37.535391	\N
2b86a219-92d3-4274-9bf5-dc613a1e6b34	\N	Fabio	Dal Maso	\N	STAMPO PRESS S.R.L.	Titolare	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.540153	2025-08-06 18:45:37.539128	\N
60d2fe86-4ac5-4949-b349-468f97ea2d4b	\N	Moira	Matteazzi	\N	NEDOR S.R.L.	Referente	347.2986040	\N	nedorsrl@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.543884	2025-08-06 18:45:37.542974	\N
31ca3304-e5cf-42a2-9a05-372441af7091	\N	Diego	Benin	\N	NEDOR S.R.L.	Socio	340.2480964	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.549281	2025-08-06 18:45:37.547462	\N
1a7c8413-9d3f-40b0-b44b-8462dadb5c1f	\N	Paola	Bordignon	\N	GSOPEN SOFTWARE SRL	Legale Rappresentante	348.7828220	\N	p.bordignon@gsopen.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.555536	2025-08-06 18:45:37.553908	\N
3a8c4e1d-3b39-4faf-963e-5d7cb52ddb1e	\N	Naomi	Abbate	\N	GSOPEN SOFTWARE SRL	Amministrativa	329.7819714	\N	segreteria@gsopen.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.559881	2025-08-06 18:45:37.558785	\N
e9b14aae-084a-47d1-a115-c1421eeaa879	\N	Luca	Lovison	\N	AUTOFFICINA LOVISON DI LOVISON LUCA	Titolare	340.6929837	\N	autofficinalovison@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.564709	2025-08-06 18:45:37.562845	\N
68587638-c4e3-4462-8cc2-43958f081ed5	\N	Giusy	Marchetto	\N	CARGERA S.R.L.	Referente	0445.440119	\N	u.amministrazione@cargera.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.568467	2025-08-06 18:45:37.567554	\N
602b8976-75e5-4f26-98ff-28b936693b81	\N	Filippo	Gelai	\N	CARGERA S.R.L.	Titolare	389.6080333	\N	u.amministrazione@cargera.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.572244	2025-08-06 18:45:37.571225	\N
87e7f832-0843-40e7-af81-a8a62fd56d1e	\N	Giordano	Zorzi	\N	ZORZI SALOTTI S.N.C. DI ZORZI IVONE E C.	Titolare	347.5756919	\N	giordano@zorziarredamenti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.575965	2025-08-06 18:45:37.575008	\N
2c787726-2349-4374-bcde-e8b43e1493d7	\N	Romina	Turato	\N	ZORZI SALOTTI S.N.C. DI ZORZI IVONE E C.	Referente	351.6810404;049.5742491	\N	contabilita@zorziarredamenti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.580057	2025-08-06 18:45:37.579168	\N
0dc30cf8-b6ab-4fda-9626-4b49f1419497	\N	Andrea	Poli	\N	PR S.R.L.	Titolare	339.7067253	\N	andrea@famigliapoli.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.583587	2025-08-06 18:45:37.582722	\N
08972a84-31e3-45cf-87cb-4e1a47e5e2ac	\N	Maria	Mazzilli	\N	PR S.R.L.	Referente	049.0991687;049.0991204	\N	info@gustificio.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.587203	2025-08-06 18:45:37.586338	\N
a8f1a649-e0d9-4d15-a4a8-564fa9819f0e	\N	Severino	Guarise	\N	L.E.M.O. DI BERTOLLO FULVIO E GUARISE SEVERINO & C. - S.N.C.	Titolare	335.6193197	\N	lemo1985@lemo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.591708	2025-08-06 18:45:37.590513	\N
375b5b53-749b-4638-a67c-38f701b4f470	\N	Lara	Faggion	\N	CLIOS S.N.C. DI MADRASSI SANDRO E ROSSETTO OSVY	Referente	349.1524451	\N	amministrazione@clios.biz	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.596508	2025-08-06 18:45:37.595013	\N
8c909cfa-1ef1-47cb-b8ea-f8db34e0c42c	\N	Sandro	Madrassi	\N	CLIOS S.N.C. DI MADRASSI SANDRO E ROSSETTO OSVY	Titolare	348.54500264	\N	sandro@clios.biz	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.602154	2025-08-06 18:45:37.600689	\N
3a8a6c22-6286-4e93-a61c-f91c022ec860	\N	Francesco	Parolini	\N	PAROLINI GIANNANTONIO S.P.A.	Socio	348.1511377	\N	francesco@parolinispa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.607643	2025-08-06 18:45:37.606309	\N
c8f6eadf-8d9b-480a-86aa-1386c07570e6	\N	Massimo	Stanzial	\N	PAROLINI GIANNANTONIO S.P.A.	Referente	348.6727737	\N	massimo.stanzial@parolinispa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.613025	2025-08-06 18:45:37.611992	\N
5060f8cc-42df-4944-8b1b-aeb3d14d42e8	\N	Erika	Geninatti	\N	TEVERONE SRL	Legale Rappresentante	348.7726128	\N	teverone.pizzeria@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.618189	2025-08-06 18:45:37.616887	\N
7c8be1e6-44fa-402d-a5df-d60df9b1fa74	\N	Romeo	Zanotto	\N	JOIN SERVICE S.R.L.	Legale Rappresentante	348.3147088	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.622284	2025-08-06 18:45:37.621406	\N
8d52e229-4f94-48e7-927b-6210c3950591	\N	Federica	Settin	\N	JOIN SERVICE S.R.L.	Referente	348.2825782	\N	federica.sattin@joinservicesrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.625845	2025-08-06 18:45:37.624976	\N
96091f3c-95a5-4f9d-b750-0f4d59e22de9	\N	Stefano	Buriola	\N	JOIN SERVICE S.R.L.	\N	3420723397	\N	stefano.buriola@joinservicesrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.629593	2025-08-06 18:45:37.628353	\N
b7bb0bbd-01d5-42b5-9a2a-8bda7f36ff04	\N	Claudio	Bertinazzi	\N	AUTOSERVICE BERTINAZZI S.R.L.	Socio	338.4313756	\N	info@autoservicebertinazzi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.633704	2025-08-06 18:45:37.632631	\N
804f1910-5bec-4f11-9e39-6edc2c156b1c	\N	Michele	Bertinazzi	\N	AUTOSERVICE BERTINAZZI S.R.L.	Socio	335.4677576	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.637604	2025-08-06 18:45:37.636294	\N
03b41734-c8a7-4218-9555-6c2f7b356b55	\N	Simone	Galdiolo	\N	STYLGROUP S.R.L.	Titolare	348.8047981	\N	simone.galdiolo@stylgroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.644038	2025-08-06 18:45:37.643228	\N
f549ad97-ebc4-4c05-9592-cf7a1de08925	\N	Alberto	Annis	\N	\N	Revisore	\N	347 9434941	albertoannis@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.647119	2025-08-06 18:45:37.646545	\N
4f0f44fe-d241-4e41-a0bf-4b3525712029	\N	Lidia	Balboni	\N	\N	Revisore	\N	348 5267600	l.balboni@lidiabalboni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.650428	2025-08-06 18:45:37.649778	\N
0f5ba686-09cb-41b0-b29f-c0a55cdcf428	\N	Alfredo	Baù	\N	\N	Revisore	0444.986576	\N	bau@teamstudio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.654113	2025-08-06 18:45:37.653438	\N
0ecc3b7d-247d-489e-9a93-79f913374d19	\N	Benedetti Lucio	Vallenari	\N	\N	Revisore	\N	338.5085857	lucio@studiobenedetti.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.657703	2025-08-06 18:45:37.657044	\N
347cb448-5a8f-4b90-8187-69c027f556d6	\N	Eleonora	De Biaggi	\N	ECON-TEST S.R.L. - SOCIETA' TRA PROFESSIONISTI	Referente	393.9192287;366.4995564	\N	debiaggi.e@econ-test.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.661624	2025-08-06 18:45:37.66058	\N
1dba929a-f28a-4468-9043-430329b2471f	\N	Paola	Curtarello	\N	\N	Revisore	\N	349.5140630	paolacurtarello@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.664628	2025-08-06 18:45:37.664092	\N
5f6edd9f-97ff-4c46-ab08-46006158611f	\N	Carola	De Donno	\N	\N	Revisore	\N	335.8020335	carola.dedonno@studiodedonno.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.667675	2025-08-06 18:45:37.667144	\N
90bcbb9f-8e4a-4710-8304-f8a944e1381a	\N	Laura	Fasoli	\N	\N	Revisore	\N	339.1333986	laura.fasoli@studiocavaggioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.670761	2025-08-06 18:45:37.670213	\N
68aef182-9435-40a6-9453-f9950f426075	\N	Chiara	Franzon	\N	ARCHE' SRL	Socio	\N	331 3474650	c.franzon@mfassociati.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.674464	2025-08-06 18:45:37.673294	\N
1ff04cc7-03b6-4dd9-952e-375fbbc904ea	\N	Stefano	Ghelardoni	\N	\N	Partner esterno e Revisore	\N	335 8111857	stefano@studioghelardoni.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.678473	2025-08-06 18:45:37.677724	\N
b96100d2-a5d8-450f-b1d3-05438d4bc4fb	\N	Monica	Gilmozzi	\N	\N	\N	051.308240	347.4109144	m.gilmozzi@studiogilmozzi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.682102	2025-08-06 18:45:37.681378	\N
495e2b1e-4e0d-481b-aacf-baf6044a8663	\N	Luca	Ginesi	\N	\N	Revisore	\N	339.3260765	lucaginesi1964@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.685491	2025-08-06 18:45:37.684835	\N
24fe87d3-5f7d-45bf-95a6-aab967e0bf9a	\N	Benedetta	Soldati	\N	GE.M.E.G. S.R.L.	Referente Formazione 4.0	\N	366 1083549	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.728471	2025-08-06 18:44:29.729326	\N
28ab9cc0-4395-4551-9315-1fa0ba0e4652	\N	Alessandra	Soprana	\N	FARMACIA SOPRANA DELLA DOTT.SSA ALESSANDRA SOPRANA & C. S.A.S.	Referente	335.8273904	\N	335.8273904	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.730095	2025-08-06 18:44:29.729326	\N
3b040e48-cbee-45ab-8d97-2699190f6333	\N	Nccolò	Silvestrini	\N	FARMACIA SOPRANA DELLA DOTT.SSA ALESSANDRA SOPRANA & C. S.A.S.	Titolare	045.941070	\N	ni1980@hotmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.730887	2025-08-06 18:44:29.729326	\N
878e44b4-dca3-4d0a-a8c6-5bcdb23e6f2e	\N	Davide	Destri	\N	FARMACIA SOPRANA DELLA DOTT.SSA ALESSANDRA SOPRANA & C. S.A.S.	Commercialista	340.101 9725	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.731755	2025-08-06 18:44:29.729326	\N
54763033-a123-4d41-b9b4-32cd44d748fd	\N	Giada	Crescenzi	\N	ROEMER GARDEN S.R.L.	Responsabile  Ufficio  Amministrazione	393.4832362;0473.446593	\N	segreteria@roemergroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.732535	2025-08-06 18:44:29.729326	\N
e21fc445-730a-4562-adae-bdf27c4ad4d2	\N	Giada	Crescenzi	\N	GIRAMA SERVICE S.R.L.	Responsabile Ufficio Amministrazione	393.4832362	\N	segreteria@roemergroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.733395	2025-08-06 18:44:29.729326	\N
5c145246-43ee-4a12-af45-ae9b781f1aab	\N	Giada	Crescenzi	\N	MANDARAVA GROUP S.R.L.	Responsabile Ufficio Amministrazione	393.4832362;0473.446593	\N	segreteria@roemergroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.734218	2025-08-06 18:44:29.729326	\N
f853460b-bb67-4c72-880d-77007d265e77	\N	Giada	Crescenzi	\N	PRM SRL	Responsabile Ufficio Amministrazione	393.4832362;0473.446593	\N	segreteria@roemergroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.734989	2025-08-06 18:44:29.729326	\N
9d9bcd8e-ce6b-430f-96d3-66bc3d71c78a	\N	Valentina	Arcozzi	\N	GROUPS MANUFACTORING S.R.L.	Titolare	347.0192614	\N	valentina.arcozzi@pcm-ups.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.735786	2025-08-06 18:44:29.729326	\N
59204021-5dd4-4c1d-96a9-4cc6bd04c860	\N	Valentina	Arcozzi	\N	POWERCOM EUROPE S.R.L.	Titolare	347 0192614	\N	valentina.arcozzi@pcm-ups.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.736825	2025-08-06 18:44:29.729326	\N
cb1aaddb-64a0-4d9f-b19b-37c304477914	\N	Jolanda	Notari	\N	JOL-AND S.R.L.	Titolare	391.3197722;051.248174	\N	direzione@hoteldonatello.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.737665	2025-08-06 18:44:29.729326	\N
faff5c21-df96-47ed-914d-fe430227174a	\N	Serena	Pensierini	\N	CENTRO ESTETICO SERENA DI PENSIERINI SERENA	Titolare	\N	333 7487067	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.738547	2025-08-06 18:44:29.729326	\N
c2e064bc-72c0-44d9-9e09-d7f9b60460a3	\N	Roberta	Cordiviola	\N	CENTRO ESTETICO SERENA DI PENSIERINI SERENA	Referente Formazione 4.0	\N	333 6317942	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.73933	2025-08-06 18:44:29.729326	\N
8cfa73e0-32d8-4b24-b6fc-fafa99c2b54c	\N	Beatrice	Rubbini	\N	ORTOPEDIA RUBBINI 1832 S.R.L.	Titolare	338.4809466; 051.225734	\N	beatricerubbini@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.74024	2025-08-06 18:44:29.729326	\N
8c17a18b-8b86-41c6-a0ae-b865a90234ae	\N	Paolo	Mantovani	\N	AP INFISSI S.R.L.	Socio	339.3624345;051.751663	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.741029	2025-08-06 18:44:29.729326	\N
be7ec976-df01-4470-bef7-f21c42ba89d3	\N	Daniele	Brizzi	\N	AP INFISSI S.R.L.	Socio	339.6111741; 051.751663	\N	info@apinfissi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.741958	2025-08-06 18:44:29.729326	\N
c8afbce2-75ba-4c7d-82b6-709eac4172eb	\N	Alberto	Pritoni	\N	AP INFISSI S.R.L.	Commercialista (Referente)	349.4202776	\N	dr.a.pritoni@studiopritoni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.74279	2025-08-06 18:44:29.729326	\N
ed7f50f0-25a6-4e5d-b47b-de33b2702034	\N	Silvia	Giorgi	\N	AP INFISSI S.R.L.	Legale Rappresentante	339 3624345	\N	info@apinfissi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.743599	2025-08-06 18:44:29.729326	\N
acced113-c4a5-4d3e-994c-3ea356de0708	\N	Alessandro	Zanarini	\N	CLIMART ZETA S.R.L.	Socio	335 832 2798	\N	zanarini@climartzeta.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.744395	2025-08-06 18:44:29.729326	\N
ca3bb08c-59f1-4af3-9793-ae3b50948f37	\N	Cristina	Tinarelli	\N	CLIMART ZETA S.R.L.	Socia	051.6053553	\N	cristina@climartzeta.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.745191	2025-08-06 18:44:29.729326	\N
10d7542d-669c-4492-b171-b7837437dd9c	\N	Leonardo	Guazzaloca	\N	S.LLE BARRACCA S.N.C. DI GUAZZALOCA LEONARDO & C.	Titolare	335.6304952; 051.734 151	\N	leonardo@barracca.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.746059	2025-08-06 18:44:29.729326	\N
10d053d1-5efb-4103-961b-5a45a4e50eec	\N	Claudio	Marchetti	\N	METALCUT SRL	Titolare	339.8371697	\N	info@cmtsrl.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.746925	2025-08-06 18:44:29.729326	\N
6048c302-ef47-4252-ad3b-a7fa8b136318	\N	Nadia	Piccirilli	\N	PIZZERIA INSIEME SAS DI PIERORAZIO VINCENZO	Titolare	320.2762852	\N	nadiapiccirilli@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.747704	2025-08-06 18:44:29.729326	\N
a8c03e4d-f666-4316-a1e1-d7dc8563039f	\N	Angelo	Messana	\N	CIRENAICA RISTRUTTURAZIONI S.A.S. DI MESSANA ANGELO	Titolare	392.2275106	\N	tecnico@cirenaicaristrutturazioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.748537	2025-08-06 18:44:29.729326	\N
29e34ad8-e29b-4e62-8e15-966462f99880	\N	Massimiliano	Giordani	\N	ORTOPEDIA PODOLOGIA MALPIGHI S.R.L.	Socio	051.346200	\N	info@ortopediamalpighi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.749417	2025-08-06 18:44:29.729326	\N
816072d2-8a09-400d-b0d1-f4c27bde3a74	\N	Mattia	Carnieri	\N	MC FRUTTA S.R.L.	Titolare	\N	340 2264613	mcfruttasrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.750275	2025-08-06 18:44:29.729326	\N
da13870a-5329-4b33-9c73-966c57fbe371	\N	Russel	Giovannini	\N	\N	\N	347 6847722	\N	russellgiovannini@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.751186	2025-08-06 18:44:29.729326	\N
5701ee77-4384-48b9-84f0-bce176ac425d	\N	Simone	Nutarelli	\N	MIND INNOVATION SRL	Account Business	\N	347 9913994	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.752235	2025-08-06 18:44:29.729326	\N
56b787d4-7888-499e-a212-53e3b996a97c	\N	Riccardo	Negro	\N	MIND INNOVATION SRL	Titolare	\N	348 6504238	ric.negro3@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.753194	2025-08-06 18:44:29.729326	\N
500a85c7-3ebb-477b-87fe-6bff3d40b471	\N	Vito	Laurino	\N	\N	\N	377.5301731	\N	info@vrassociati.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.754127	2025-08-06 18:44:29.729326	\N
bb547e10-c01d-4f0a-88bd-5fb79c63519b	\N	Flavio	Girardi	\N	INTOFER S.R.L.	Legale Rappresentante	348.35119900	\N	flaviogirardi@intofer.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.755036	2025-08-06 18:44:29.729326	\N
b9986e93-084a-462a-88ba-acd3dde19357	\N	Diego	Malaffo	\N	ADIGE VENDING S.A.S. DI MALAFFO DIEGO & C.	Titolare	348.2202609	\N	direzione@adigevending.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.755966	2025-08-06 18:44:29.729326	\N
e4939dad-ada9-4281-90a6-a84a7a2e79f4	\N	Sabrina	Canto	\N	JEVA SRL	Referente	338.2670462	\N	oldbridge-dragon@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.756782	2025-08-06 18:44:29.729326	\N
08a25e1a-9fee-48b9-8477-e2a41880bd8b	\N	Valerio	Rinaldi	\N	JEVA SRL	Titolare	335.5719802	\N	valerio.rinaldi60@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.757702	2025-08-06 18:44:29.729326	\N
44e53b96-c631-4d72-a007-c386a20d91da	\N	Emanuele	Lanza	\N	MASER IMPIANTI ELETTRICI S.R.L.	Titolare	340.0625039	\N	amministrazione@maserimpianti.com;ufficiotecnico@maserimpianti.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.758515	2025-08-06 18:44:29.729326	\N
58c857fa-439c-4181-9f71-a965d799af62	\N	Antonio	Merlin	\N	MASER IMPIANTI ELETTRICI S.R.L.	Commercialista	347.4308178	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.759503	2025-08-06 18:44:29.729326	\N
4e842797-d5cd-4a4a-ba67-34a489147c93	\N	Monica	Passarini	\N	CARMA S.R.L.	Legale Rappresentante	328.1592642	\N	passarini.monica@carma-vr.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.760429	2025-08-06 18:44:29.729326	\N
0b24aecc-f71d-427c-9388-aa43e343868c	\N	Silvio	Paganello	\N	CARMA S.R.L.	Titolare	348.7828733	\N	direzione@carma-vr.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.761373	2025-08-06 18:44:29.729326	\N
8d2dc59a-29ea-4c54-b6e5-725294266563	\N	Federico	Gori	\N	\N	Revisore	\N	393.9432592	studiofgori@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.68897	2025-08-06 18:45:37.688312	\N
a1b8ec12-3ec5-4326-bf9e-0eada17d5ac0	\N	Roberto	Galuppini	\N	EDIL VITALIY S.R.L.	Commercialista	338.7531025	\N	roberto.galuppini@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.76222	2025-08-06 18:44:29.729326	\N
765d1d36-a7fa-4761-8640-e33d91b9157c	\N	Edoardo	Moretti	\N	LYCONET ITALIA S.R.L.	Consulente	366 9924407	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.763208	2025-08-06 18:44:29.729326	\N
be4bcdc0-3f08-4716-a3e2-4a02c047108f	\N	Danilo	Anicito	\N	B2B GROUP S.R.L.	Titolare	331.5277721	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.76412	2025-08-06 18:44:29.729326	\N
c63c7dc2-06f7-46c3-aa0c-abf318c1b40c	\N	Stefano	Brazzioli	\N	S.T. SAFETY TECHNOLOGY S.R.L.	Titolare	3356748651	\N	stefano.b@dpr462.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.765053	2025-08-06 18:44:29.729326	\N
9e062380-3154-4839-81d6-786e7cb735a5	\N	Luigi	Menini	\N	MYWORLD ITALIA S.R.L.	Referente	348.8666323	\N	luigi.menini@myworld.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.766104	2025-08-06 18:44:29.729326	\N
40ad05c0-c1e4-4157-ad33-32fc49603e0c	\N	Giacomo	Ragonesi	\N	TUSCIA ENERGIA S.R.L.	Titolare	392.8661971	\N	tusciaenergia@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.767218	2025-08-06 18:44:29.729326	\N
d3ff616c-c911-4e5a-a277-c27a363c7173	\N	Xenia	Ragonesi	\N	TUSCIA ENERGIA S.R.L.	Referente	380.3859004	\N	xragonesi@tusciaenergia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.768282	2025-08-06 18:44:29.729326	\N
dd52fa20-8335-4fb7-9175-ecfe526260da	\N	Massimo	Veronesi	\N	TERZA PILA S.R.L.	Titolare	339 403 9539	\N	m.veronesi@verogelateria.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.769251	2025-08-06 18:44:29.729326	\N
0ebe9ccf-1ae3-41fd-b299-33cc49212a3f	\N	Andrea	Olivo	\N	COOPERATIVA SOCIALE INCONTRO - SOCIETA' COOPERATIVA ONLUS	Vice Presidente con poteri di rappresentanza	3486440274	\N	infocoop.incontro@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.770144	2025-08-06 18:44:29.729326	\N
e0121763-09f3-4573-bcce-96426d80f254	\N	Carlo	Pusceddu	\N	COOPERATIVA SOCIALE INCONTRO - SOCIETA' COOPERATIVA ONLUS	Referente	3486440274	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.771002	2025-08-06 18:44:29.729326	\N
b588aa29-7ee1-4df1-baa8-20b083e956a1	\N	Dragana	Salev	\N	IPV PACK S.R.L.	HR	049.9431318	\N	dragana.salev@ipvpack.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.771826	2025-08-06 18:44:29.729326	\N
d6e196e1-4604-42fe-8d01-9b12bfa90909	\N	Stefano	Tiana	\N	FASHION HAIR S.R.L.	Titolare	3477463143	\N	stefanotiana@fashionhair.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.772606	2025-08-06 18:44:29.729326	\N
1b1d821c-b47d-4bc9-b9eb-0750b520570e	\N	Sonia	Serpi	\N	FASHION HAIR S.R.L.	Referente	340.2157955	\N	info@fashionhair.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.775168	2025-08-06 18:44:29.776132	\N
c2e39e17-6e7a-4d24-a249-0299e90a0633	\N	Simone	Pratesi	\N	ESSEPI S.R.L.	Titolare	\N	338.5317610	info@essepizucchero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.777018	2025-08-06 18:44:29.776132	\N
7fde9916-32ad-4e6d-89dd-78614a2fccd2	\N	Lorenzo	Galgano	\N	ESSEPI S.R.L.	Commercialista	\N	339.6293610	lorenzo@studiogalgano.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.77784	2025-08-06 18:44:29.776132	\N
182ad9b3-9914-4d6d-ac1e-ab985184f689	\N	Stefano	Berti	\N	ESSEPI S.R.L.	Consulente Del Lavoro	0573.358206	\N	info@stpconslavsrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.778929	2025-08-06 18:44:29.776132	\N
cff6c236-5700-46f6-beab-e74d233ed99d	\N	Gabriele	Boi	\N	BOI AUTOMOBILI SRL	Titolare	\N	340.0952463	info@boiautomobili.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.779941	2025-08-06 18:44:29.776132	\N
b37344a1-60db-4d72-8b0b-420963cd58ae	\N	Manuel	Koch	\N	MISTRAL DI ALBERTO SANNA & C SRL	Titolare	347.6862273	\N	m.koch@hotel-mistral.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.780907	2025-08-06 18:44:29.776132	\N
edd95951-edc4-4889-aa8c-f4856f9cc996	\N	Stefano	Ruggeri	\N	MISTRAL DI ALBERTO SANNA & C SRL	Commercialista	0783.70379	\N	stefanoaldruggeri@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.781761	2025-08-06 18:44:29.776132	\N
94fe8f0e-cd92-4a52-a80e-7a6166074d87	\N	Luca	Sanna	\N	SC. HI-FI S.R.L.	Consulente del lavoro	349.6842475	\N	studiosanna4@studiosanna.191.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.782649	2025-08-06 18:44:29.776132	\N
9e06bfd7-d0d1-444c-b26c-c13d69ef6d04	\N	Alberto	Contini	\N	SC. HI-FI S.R.L.	Titolare  Referente	347.8852037	\N	albertoschifi89@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.783616	2025-08-06 18:44:29.776132	\N
c2c35133-6c7b-4662-a8c6-63fedc115243	\N	Alberto	Annis	\N	SC. HI-FI S.R.L.	Commercialista e Revisore Legale	347 .9434941	\N	albertoannis@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.784553	2025-08-06 18:44:29.776132	\N
cf4cfe9e-3c70-48dc-920b-08a6cbbec16b	\N	Giampiero	Contini	\N	SC. HI-FI S.R.L.	Socio	348.3344783	\N	g.continischifi@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.785536	2025-08-06 18:44:29.776132	\N
38056fdf-7d66-4595-8b50-742856b3b202	\N	Luca	Pieri	\N	TEK REF SRL	Titolare - Referente	348.8837580	\N	luca.pieri@zio-ciro.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.786422	2025-08-06 18:44:29.776132	\N
f47b774f-6196-440c-a390-5788ba215f3c	\N	Federica	De Villa	\N	FARMACIA DOTT.SSA FEDERICA DE VILLA	Titolare	3488041530	\N	farmaciadevilla@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.787378	2025-08-06 18:44:29.776132	\N
012e71e9-bdbb-4857-832e-11d46594ad92	\N	Andrea	Cappellacci	\N	FARMACIA DOTT.SSA FEDERICA DE VILLA	Consulente del lavoro	070.654354	\N	andreacappellacci@cappellacci.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.788234	2025-08-06 18:44:29.776132	\N
044a34a7-e16b-4509-a7fa-5a129717b36b	\N	Stefano	Piras	\N	NEW FLOWERS SRLS	Legale Rappresentante	348.7055100	\N	studiodenottipiras@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.789137	2025-08-06 18:44:29.776132	\N
57e3fba0-fe8a-4776-a4f1-b311923193ca	\N	Monica	Manca	\N	AGRICOLA CAMPIDANESE - SOCIETA' COOPERATIVA	Ufficio del personale - Referente	342.5176311	\N	monicamanca.campidanese@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.789996	2025-08-06 18:44:29.776132	\N
035befbe-eeb3-4df1-b1b5-a44b2786ddb8	\N	Salvatore	Lotta	\N	AGRICOLA CAMPIDANESE - SOCIETA' COOPERATIVA	Titolare	346 060 3266	\N	lotta.salvatore@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.79092	2025-08-06 18:44:29.776132	\N
0c17cdde-391e-4fc4-9e4c-8b00b2eeca33	\N	Gianfranco	Fresu	\N	AGRICOLA CAMPIDANESE - SOCIETA' COOPERATIVA	Amministratore	346.0675035	\N	amministrazione.campidanese@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.791718	2025-08-06 18:44:29.776132	\N
a1a9c9bd-9228-4ccb-af43-54daff0e9ee1	\N	Antonello Franco	Peddio	\N	QUATTRO P S.R.L.	Titolare	347.7134744	\N	info@quattrop.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.79279	2025-08-06 18:44:29.776132	\N
a325f755-28fb-4e62-9602-729af12b1b21	\N	Alex	Cittadella	\N	\N	\N	\N	340.8405440	alexcittadella@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.793796	2025-08-06 18:44:29.776132	\N
b07764ab-577a-4616-b946-76446f49301d	\N	Gianluigi	Porta	\N	AUTORICAMBI THARROS S.R.L.	Titolare	393.9430078	\N	autoricambitharros@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.794687	2025-08-06 18:44:29.776132	\N
e409ca7a-ad95-45f0-9c00-3860eb33f10e	\N	Luca	Meloni	\N	CENTRO RIABILITATIVO ORTOPEDICO SARDO DI SECCI ROSINA E C. S.R.L.	Socio	347.9407662	\N	centrocros@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.795666	2025-08-06 18:44:29.776132	\N
4f1ae354-1c13-4617-9e49-e2bac71f73ba	\N	Roberto	De Muro	\N	CENTRO RIABILITATIVO ORTOPEDICO SARDO DI SECCI ROSINA E C. S.R.L.	Socio	348.0663840	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.796704	2025-08-06 18:44:29.776132	\N
af4055be-9451-4f58-ba81-d44c4c26800d	\N	Renato	Macciotta	\N	CENTRO RIABILITATIVO ORTOPEDICO SARDO DI SECCI ROSINA E C. S.R.L.	Commercialista	070.3495035	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.797564	2025-08-06 18:44:29.776132	\N
3fbea091-e9fd-4793-a016-ed23f776fe97	\N	Stefano	De Rosa	\N	DE ROSA STEFANO	Titolare	\N	393.5472092	drsstefa1@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.798397	2025-08-06 18:44:29.776132	\N
a3aca472-5154-4a64-89b3-1495ab61c645	\N	William	Congera	\N	CONGERA WILLIAM	Titolare	348 1802615	\N	william.congera@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.799305	2025-08-06 18:44:29.776132	\N
f31472d4-64f9-4cc8-9cf0-0c6d903e86a3	\N	William	Congera	\N	OBIETTIVO 50 S.R.L.	Titolare	348.1802615	\N	william.congera@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.800076	2025-08-06 18:44:29.776132	\N
4b4f28d4-9c03-410a-84c8-d76010a6e04f	\N	Barbara	Graverini	\N	CENTRO BENESSERE SINERGIE DI GRAVERINI BARBARA & C.	Titolare	\N	338 1113165	sinergie.livorno@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.800982	2025-08-06 18:44:29.776132	\N
7ba81abf-39f2-4c74-8d19-ca2eb4dcd10a	\N	Lidia	Balboni	\N	BHT SRL	Segnalatore - Referente	348.5267600;051.6836785	\N	l.balboni@lidiabalboni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.801849	2025-08-06 18:44:29.776132	\N
c0426dbd-58ba-4093-a04d-c0ecc23a7d49	\N	Fabio	Pivato	\N	IMPRESA EDILE PIVATO SRL	Titolare	335.6077506	\N	impresapivato@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.802712	2025-08-06 18:44:29.776132	\N
c5138889-2c48-4fd7-8435-3628742c8b11	\N	Cristian	Govoni	\N	ENERGYGAS DI GOVONI CRISTIAN & ANTHONY SRL	Titolare	348.6036832	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.803613	2025-08-06 18:44:29.776132	\N
d2aaa61b-f345-41f0-9706-6b4ff9532a32	\N	Antonio	Palumbo	\N	PALUMBO S.R.L.	Titolare	333.4552017	\N	bellanapoli@lignano.it;ristorantecatina@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.804476	2025-08-06 18:44:29.776132	\N
b50cfdb0-9d5d-466b-ad7b-87aa427badc7	\N	Stefano	Ceni	\N	QUINTA PILA S.R.L.	Titolare	335.7284536	\N	s.ceni@oggigelato.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.805298	2025-08-06 18:44:29.776132	\N
707a69dc-8f36-4686-9202-455306fb24df	\N	Elisa	Nardini	\N	CENTRO RESIDENZIALE PER ANZIANI E ADULTI INABILI RUGGERI MARIA DI NARDINI ELISA	Titolare	\N	327 8166945	elisanardini83@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.806295	2025-08-06 18:44:29.776132	\N
48fdf007-85f2-46c0-b4a6-14cc240c34ae	\N	Emilio	Manini	\N	CIMSYSTEM S.R.L.	Vice Presidente	\N	335 6106796	manini@cimsystem.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.807299	2025-08-06 18:44:29.776132	\N
e59e5375-be25-4aaf-9588-bd3932abe1f7	\N	Roberto	Salamo	\N	R.S. - S.R.L.	\N	339.691372	\N	condominiosunsettopea@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.808145	2025-08-06 18:44:29.776132	\N
dda9f28c-4ac3-4cb2-b2e9-10c4e4a4baa5	\N	Emilio	Manini	\N	LAB SRL	Titolare	\N	335 6106796	manini@lab3d.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.808963	2025-08-06 18:44:29.776132	\N
541d5862-abce-4ab8-a207-f173aaa904a2	\N	Roberto	Salamo	\N	GREEN FOOD S.R.L.	\N	339.691372	\N	condominiosunsettopea@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.809851	2025-08-06 18:44:29.776132	\N
b4c53ed0-f5c4-4f34-a890-4aa7eb192e59	\N	Patrizio	Bianco	\N	BIANCO MOTO DI BIANCO PATRIZIO	Titolare	\N	338 5724907	patrizio@biancomoto.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.810745	2025-08-06 18:44:29.776132	\N
a706d2f5-7762-4004-85a4-9ea4c36535f2	\N	Germano	Bianconi	\N	MODO SRL	Titolare	347.2230483	\N	germano@mhpmedia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.811528	2025-08-06 18:44:29.776132	\N
1c89bf1a-689d-40ef-a1a0-6dda613976bd	\N	Alessia	Piscini	\N	HOTEL UNIVERSAL S.R.L.	Referente	320 8627064	\N	commerciale@hoteluniversal.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.812424	2025-08-06 18:44:29.776132	\N
e2653bd3-9e07-44e7-b845-1da17005474a	\N	Fabrizio	Frontalini	\N	CATALANI & FRONTALINI S.R.L.	Socio	335.5684231	\N	opelservice@alice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.813359	2025-08-06 18:44:29.776132	\N
dde40884-08fa-4c5a-a93f-e2c1eefcbd18	\N	Cristina	Casella	\N	NUOVA ZETA SRL	\N	335.373629	\N	cristina.casella0107@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.814142	2025-08-06 18:44:29.776132	\N
dec07285-2860-4585-b5b1-a125cb6fed3e	\N	Cristina	Casella	\N	ZETA PIU' SRL	\N	335.373629	\N	cristina.casella0107@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.814999	2025-08-06 18:44:29.776132	\N
bfdf6209-fce4-4286-b95f-4d02379b1f44	\N	Alessandro	Mancin	\N	ALIDENT DEI DOTT. LUCCHESE E MANCIN S.R.L. - SOCIETA' TRA PROFESSIONISTI	Socio	338.4630758	\N	dr.alessandro.mancin@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.815801	2025-08-06 18:44:29.776132	\N
40585f69-d97f-4bb6-b781-16144de13a09	\N	Francesca	Capellini	\N	FRAUNASCELTA S.R.L.S.	Titolare	\N	\N	francesca.capellini@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.816713	2025-08-06 18:44:29.776132	\N
808ca023-0a03-4e97-95c0-2e5764733df0	\N	Halyna	Demkiv	\N	EDIL VITALIY S.R.L.	Socia minoritaria e contabile	3283789679	\N	edilvitaliysrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.817568	2025-08-06 18:44:29.776132	\N
295914a3-d33c-4701-bf4b-1c1aad6ffc98	\N	Marco	Minarelli	\N	G.S.V. DI MINARELLI MARCO & C. S.A.S.	Titolare	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.818432	2025-08-06 18:44:29.776132	\N
dbeb723f-c70a-4c6d-99fe-256a864145ea	\N	Stefano	Legnani	\N	LEGNANI UMBERTO S.R.L.	Titolare	3355420268	\N	stefano.legnani@legnani.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.82047	2025-08-06 18:44:29.776132	\N
39549d88-53bb-4210-9f77-3c1384c30314	\N	Fabio	Iacono	\N	ATHENA S.R.L.	Titolare	347.4561935	\N	athenasrlcasana@pec.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.822108	2025-08-06 18:44:29.776132	\N
711be003-3832-4dca-a90b-8b9e6709af61	\N	Giorgio	Ibba	\N	\N	Revisore	\N	393,3374005	ibbagiorgio@studioibba.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.692196	2025-08-06 18:45:37.691659	\N
81e512bc-deba-4689-ae29-edc3a35aadfc	\N	Gianfranco	Casella	\N	AL VIGORANTINO DI ZAMPIERI STEFANO	Commercialista	339.3173335	\N	gianfranco@cieffeservizi.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.695937	2025-08-06 18:45:37.694794	\N
9b2378be-681e-4e5a-8cd4-2d66839b4197	\N	Adriano	Marchetto	\N	\N	Revisore	\N	348.2304148	marchetto@marchettoezaccaria.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.699143	2025-08-06 18:45:37.698556	\N
db6b7b81-8219-45b8-a6a4-395e22cbbcd6	\N	Alberto	Meneghini	\N	\N	Revisore	349 7898961	\N	alberto@studio-meneghini.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.702216	2025-08-06 18:45:37.701612	\N
b3bd328b-9ee2-4fd5-aef2-c896a65766ea	\N	Stefano	Zampieri	\N	AL VIGORANTINO DI ZAMPIERI STEFANO	Titolare	349.4251367	\N	zampieris@yahoo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.705965	2025-08-06 18:45:37.704938	\N
865f29f5-8d84-404a-8b92-c69c65e4627a	\N	Alberto	Petrillo	\N	M.R. CALAMARI S.R.L.	Revisore	\N	347.4847552	studioalepetrillo@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.709729	2025-08-06 18:45:37.708553	\N
78b33e75-6566-4eec-9864-a094fc0d20c8	\N	Edward	Brusamolin	\N	AL VIGORANTINO DI ZAMPIERI STEFANO	Consulente del Lavoro	3477438082	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.713055	2025-08-06 18:45:37.712264	\N
05ae9c41-2772-476f-ac16-cf7373e176c4	\N	David	Pignotti	\N	\N	Revisore	049.8712371	\N	davidpignotti@studiobaggio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.71597	2025-08-06 18:45:37.715476	\N
421aeb3f-1867-4789-9890-5bb825fcd613	\N	Daniele	Sanguineti	\N	\N	Revisore	0185.481269	\N	daniele@danielesanguineti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.719174	2025-08-06 18:45:37.718532	\N
d127dc35-8db2-493e-a0b0-30b1a1484efb	\N	Nicola	Zambello	\N	\N	Revisore	\N	392.0389014	zambellonicola@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.72266	2025-08-06 18:45:37.721992	\N
86ba11c3-2086-4993-8662-b1f8d9783d1d	\N	Marzio	Mocellin	\N	MACRO S.A.S. DI SARTOR MARCO & MOCELLIN MARZIO	Titolare	348.3133443	\N	marzio@macro.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.726802	2025-08-06 18:45:37.725598	\N
2bdd1a1a-ff51-4a09-88cb-80ad9070915c	\N	Mattia	Franchin	\N	SERIEMME SAS DI FRANCHIN M.	Titolare	348.8979877	\N	commerciale@graficheseriemme.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.73137	2025-08-06 18:45:37.73013	\N
b41aff63-ab63-449c-9771-84fdd60d1096	\N	Luca	Trevisan	\N	SERIEMME SAS DI FRANCHIN M.	Commercialista	348.2229612	\N	luca.trevisan@sintesistudioassociato.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.734754	2025-08-06 18:45:37.733941	\N
55b3ab24-469e-46d5-bb46-180a9046b78e	\N	Tiziana	Fonelli	\N	SERIEMME SAS DI FRANCHIN M.	Referente	0444.371313	\N	amministrazione@graficheseriemme.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.737877	2025-08-06 18:45:37.736984	\N
27d61699-1564-4e37-8f01-306279a0a9a7	\N	Andrea	Favretto	\N	LOGISTICA PORDENONESE S.R.L.	Titolare	349.3518768	\N	a.favretto@logser.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.741054	2025-08-06 18:45:37.74025	\N
4dd213d2-cf34-4058-af8b-7cc6163875e9	\N	Antonio	Saccardo	\N	A.D. STUDIO S.R.L.	Titolare	340.6098403	\N	antoniosaccardo@hotmail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.744206	2025-08-06 18:45:37.743362	\N
2b997a1a-8928-4702-afff-bad8a9a3d698	\N	Marco	Fortunato	\N	INFORMATIC ALL S.R.L.	Titolare	339.1278271	\N	amministrazione@informaticall.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.747925	2025-08-06 18:45:37.74676	\N
795dd9a1-1674-441a-9d1c-31b0b64609b6	\N	Vincenzo	Cioffi	\N	RISTORANTE ALLA CATINA DI PALUMBO ANTONIO E CIOFFI VINCENZO S.N.C .	Titolare	338.2103035; 0434.520358	\N	ristorantecatina@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.755401	2025-08-06 18:45:37.754294	\N
48400cda-5eb3-4174-b028-a8a072850327	\N	Martina	Lando	\N	CONNETICAL S.R.L.	Titolare	347.8114934	\N	m.lando@connetical.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.759414	2025-08-06 18:45:37.758574	\N
da9239d7-6081-4676-b513-95c44b7ef139	\N	Debora	Parise	\N	PARISE DOMENICO S.R.L.	Titolare	0424.567706	\N	info@cablaggiparise.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.762952	2025-08-06 18:45:37.762047	\N
ead401cb-b3a9-49bc-a194-b06b505b559d	\N	Marco	Montecala	\N	\N	Account Manager di IPRATICO	\N	393 9923779	marco.montecala@ipratico.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.766566	2025-08-06 18:45:37.765904	\N
d2d60953-bfc6-4bff-bfc9-ddc76f2855c4	\N	Fabio	Genicco	\N	\N	Business Manager di WISHARE	\N	347 6991902	info@wishare.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.770152	2025-08-06 18:45:37.769473	\N
9ed81fe6-b26d-42be-831c-23aec25c44ec	\N	Fan	Luo	\N	\N	Business Manager di WISHARE	\N	389 5205478	info@wishare.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.774206	2025-08-06 18:45:37.773412	\N
cf48a3cb-53e9-4718-a6f4-fc659a87b8c2	\N	Fabrizio	Giomo	\N	IMESA S.P.A.	Account Manager	\N	327 0403183	f.giorno@imesa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.778235	2025-08-06 18:45:37.777157	\N
f2ce145c-ef49-4763-86af-d0060ab7a286	\N	Davide	Michielan	\N	OTTICA 2M S.R.L.	Titolare	340.0541945	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.782937	2025-08-06 18:45:37.781859	\N
b0cfe1b9-5d39-4e0b-a37e-8d496edafc26	\N	Nicola	Bettanin	\N	MANES S.R.L.	Titolare	347.6010290	\N	nicola.bettanin@manes.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.787402	2025-08-06 18:45:37.786191	\N
40854093-2771-496a-90cf-9cf85c3e5087	\N	Marco	Bonotti	\N	SNACK & DRINK S.R.L.	Direttore Aziendale	\N	335 1242023	marcobonotti@snackedrink.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.791536	2025-08-06 18:45:37.790202	\N
f4095026-8cb5-491d-b63d-abad59f765a7	\N	Gianluca	Danesin	\N	D4I SRL	Socio Unico amministratore	\N	348.3417740	gianluca.danesin@dcircle.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.091465	2025-08-06 18:45:39.090575	\N
7dfd5c57-401f-42ab-b419-399b28a21fa4	\N	Luca	Gigli	\N	MUGELLO SISTEMI SAS DI GIGLI LUCA, SONIA & C.	Responsabile Commerciale	\N	337 682709	mugellosistemi1962@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.79684	2025-08-06 18:45:37.795305	\N
3af8302f-d9bf-4914-8643-48f906eaee84	\N	Stefania	Manna	\N	LAPE SRL	Amministrazione	\N	350 0091596	info@lapesrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.801562	2025-08-06 18:45:37.800212	\N
f4979d16-1369-4d38-8511-031cbbee3d5b	\N	Stefano	Ceccuti	\N	DATAITALIA S.R.L.	Commerciale	\N	335 5987280	stefano.ceccuti@dataitaliasrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.806727	2025-08-06 18:45:37.805268	\N
aa4a8654-bf19-41ba-b63c-de3486a0cb5b	\N	Filippo	(Tagliagambe)	\N	TAGLIAGAMBE & ZILIO SRL	\N	\N	348 2505697	info@tagliagambebilance.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.811473	2025-08-06 18:45:37.810216	\N
edc5bb3e-ddfb-49be-81a3-feb303afa50b	\N	Giuseppe	Santucci	\N	MEROPE S.A.S. DI SANTUCCI GIUSEPPE E C.	Titolare	334.1401578	\N	osteriamerope@alice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.933943	2025-08-06 18:44:29.93503	\N
616ff428-1138-4e99-bdde-c6e5b1524fcd	\N	Luana	Picu	\N	MEROPE S.A.S. DI SANTUCCI GIUSEPPE E C.	Referente	334.1401578	\N	info@meropessteakhouse.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.935985	2025-08-06 18:44:29.93503	\N
43338a74-fabd-40e9-ac81-9efbb84a0d21	\N	Cristiano	Mazzoni	\N	LUCA'S CAFFE' S.R.L.	Titolare	320.9375308	\N	cristiano.m75@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.937034	2025-08-06 18:44:29.93503	\N
dc0d2445-879e-4f78-9421-ce411596990b	\N	Roberto	Tognetti	\N	TUBI PLASTIC S.R.L.	Titolare	393.4775160	\N	roberto.tognetti@tubiplastic.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.938071	2025-08-06 18:44:29.93503	\N
d52b2ce0-60a4-4196-b9a3-9ea6b4f43799	\N	Paola	Bruschi	\N	TUBI PLASTIC S.R.L.	Referente	0187.693403	\N	paola.bruschi@tubiplastic.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.938858	2025-08-06 18:44:29.93503	\N
c65bb66d-6436-4054-a0c8-1e7b320661da	\N	Sara	Bertani	\N	LA SUITE BEAUTY SPA DI SARA BERTANI	Titolare	340.3731841	\N	lasuite.beautyspa@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.939625	2025-08-06 18:44:29.93503	\N
f70f14ad-7b29-4a87-bc87-5e67a85fe0c8	\N	Elena	Baccioli	\N	LA SUITE BEAUTY SPA DI SARA BERTANI	Commercialista	0585632760	\N	info@elenad.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.940502	2025-08-06 18:44:29.93503	\N
6fd6514b-7ec6-4cee-92df-311580c6b57d	\N	Jessica	Sartore	\N	CAST BOLZONELLA SRL	Referente	340.3048398	\N	amministrazione@castbolzonella.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.941267	2025-08-06 18:44:29.93503	\N
847472fb-1870-4f37-8b02-d99de989cb6c	\N	Daniele	Carraro	\N	CAST BOLZONELLA SRL	Consulente del lavoro	049 657986;340 3112047	\N	paghe@clapartners.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.942169	2025-08-06 18:44:29.93503	\N
f5a64335-fed1-450f-a284-7fc567e886ab	\N	Giuseppe	Negra	\N	CAST BOLZONELLA SRL	Commercialista	320 0845165	\N	giuseppe@studionegra.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.942978	2025-08-06 18:44:29.93503	\N
b1b985ef-caed-40b2-8bef-57af076286cf	\N	Valerio	Tiranti	\N	IMPIANTI PADOVA S.A.S. DI TIRANTI VALERIO & C.	Titolare	329 1630002	\N	valerio@impiantipadova.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.943724	2025-08-06 18:44:29.93503	\N
0913dfe0-e8a8-4d6f-b1f8-5a084de23702	\N	Carole	Consigliere	\N	IMPIANTI PADOVA S.A.S. DI TIRANTI VALERIO & C.	Amministrativa	393.3839090	\N	carole@impiantipadova.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.944473	2025-08-06 18:44:29.93503	\N
f8486491-f384-4233-bf24-b71a207c2a57	\N	Stefano	Pallotti	\N	G.P.INOSSIDABILE S.R.L.	Titolare	370 3355402	\N	info@gpinossidabile.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.945242	2025-08-06 18:44:29.93503	\N
ebcd0041-5626-4164-b21e-ae183fb37726	\N	Mara	Novelli	\N	LIDI GROUP S.R.L.	Referente	348.8720893	\N	m.novelli@lidigroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.94598	2025-08-06 18:44:29.93503	\N
c9865256-e375-4b41-b948-a74b8f1a6407	\N	Fabrizio	Pezzi	\N	LIDI GROUP S.R.L.	Amministratore Unico	0533.327195	\N	info@lidigroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.946851	2025-08-06 18:44:29.93503	\N
0d30e955-73a6-4b5e-92f5-b2853b2dba41	\N	Mara	Novelli	\N	LIDI LIFE S.R.L.	Referente	348.8720893	\N	m.novelli@lidigroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.9476	2025-08-06 18:44:29.93503	\N
a574a93e-a1b8-4224-9d81-3c413705e059	\N	Cristiano	Mazzoni	\N	C.M.I.T.  DI CRISTIANO MAZZONI E C. - S.N.C.	Titolare	320.9375308	\N	cristiano.m75@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.948357	2025-08-06 18:44:29.93503	\N
a0df4feb-42b0-4072-99f6-0bd8b9eb21c1	\N	Giuseppe	Anderlini	\N	ANDERLINI GIUSEPPE E FIGLI S.R.L.	Titolare	347.2266929	\N	a.anderlini@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.949082	2025-08-06 18:44:29.93503	\N
7095f738-0783-48ae-b8ab-74fcc5a43ef2	\N	Marzia	Margheriti	\N	HELLO SAILOR S.R.L.	Titolare	347 1454922	\N	marzia@vintro.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.950065	2025-08-06 18:44:29.93503	\N
3918ea34-70dd-4b7b-aa4c-ceda2de43a6c	\N	Pio	Frascella	\N	ROMA VIA VENETO S.R.L.	Titolare	348.3520192	\N	romaentireligiosi@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.950997	2025-08-06 18:44:29.93503	\N
691fc6ff-d895-47b4-9670-e5f6ad05a128	\N	Claudio	Marchetti	\N	C.M.T. SRL	Amministratore	339.8371697	\N	info@cmtsrl.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.951911	2025-08-06 18:44:29.93503	\N
702fc2fc-ef84-46cd-9450-142d97f20d0f	\N	Aurora	Giosuè	\N	MS IMPIANTI S.R.L.S.	Referente	393.3824723	\N	ufficiomsimpianti2020@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.952625	2025-08-06 18:44:29.93503	\N
8ab604ed-624d-4f7a-bc02-d81de357e49f	\N	Marinella	Garbati	\N	T-MOTION S.R.L.	Referente	\N	351 8970949	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.953503	2025-08-06 18:44:29.93503	\N
eae98eff-60b0-447e-bc4c-a113ca98fdd0	\N	Maurizio	Meroni	\N	MERONI S.R.L.	Titolare	327.4773338	\N	fratellimeroni18@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.954276	2025-08-06 18:44:29.93503	\N
acc5b41c-b394-41a1-b6f5-0768c0dda2aa	\N	Anna Maria	Lumaca	\N	IMPRESA LUMACA S.R.L.	Socia	348.9042240	\N	annamaria@lumacagroup.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.955015	2025-08-06 18:44:29.93503	\N
5dc2e027-8f3f-46dc-971f-c262f3b0f6aa	\N	Anna Maria	Lumaca	\N	IMMOBILIARE LUMACA S.R.L.	Socia	348.9042240	\N	annamaria@lumacagroup.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.955902	2025-08-06 18:44:29.93503	\N
c79ea33a-1bbe-4f7c-93de-910afc8bb510	\N	Anna Maria	Lumaca	\N	ISO 2000 APPALTI S.R.L.	Socia	348.9042240	\N	annamaria@lumacagroup.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.956704	2025-08-06 18:44:29.93503	\N
ef9628e2-f7f1-462e-b7b7-e6a2fae43ea1	\N	Elisabetta	Becker	\N	ISO S.R.L.	Referente	335.7301749	\N	amministrazione@isoproduzioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.95759	2025-08-06 18:44:29.93503	\N
505e1a58-0be7-40c9-acf6-e0c517f220ec	\N	Daniele	Commissari	\N	SICURA DOMUS SNC DI CERESA LUCA E COMMISARI DANIELE	Titolare	347.5177077	\N	info@sicuradomus.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.95842	2025-08-06 18:44:29.93503	\N
b2a865bc-2978-49f1-87ce-dbc9d3867b60	\N	Luca	Marchiolo	\N	SICURA DOMUS SNC DI CERESA LUCA E COMMISARI DANIELE	Consulente del lavoro	339.7716591	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.959235	2025-08-06 18:44:29.93503	\N
4fa6a23f-7742-480e-8e07-1e011abddf5b	\N	Francesco	Colonna	\N	SWD COMPUTER S.R.L.	Referente	348.5838144	\N	info@swdcomputer.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.960201	2025-08-06 18:44:29.93503	\N
f79687c9-43b8-41e9-a75b-27b31decd1f0	\N	Giuseppe	Spagnolo	\N	SWD COMPUTER S.R.L.	Revisore	338.1840776	\N	gfa.spagnolo@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.961056	2025-08-06 18:44:29.93503	\N
4fa5688a-646d-42b5-abf0-72137f01c9c6	\N	Nicola	Svaizer	\N	JLB BOOKS S.A.S. DI SVAIZER NICOLA & C.	Titolare	329.4836858	\N	nsvaizer@winitsrl.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.962142	2025-08-06 18:44:29.93503	\N
ac942b12-dc48-41ed-9df1-8902da0ace21	\N	Leonardo	Maroccolo	\N	MAROCCOLO SRL	Titolare	333.8466918	\N	l.maroccolo@maroccolo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.963187	2025-08-06 18:44:29.93503	\N
337b643a-7bf9-4a8b-81d4-66f87408bfd9	\N	Samuel	Forti	\N	IL GABBIANO SOCIETA' COOPERATIVA SOCIALE DI SOLIDARIETA' IN SIGLA IL GABBIANO COOPERATIVA SOCIALE	Titolare	329.9059107	\N	samuel.forti@ilgabbiano.tn.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.964215	2025-08-06 18:44:29.93503	\N
2ea4f0b4-84e9-4568-bb3d-b45d2d8d76ab	\N	Alba	Galtieri	\N	CRAZY CAT CAFE' SRL	Titolare	340.4864398	\N	g.albaclaire@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.965553	2025-08-06 18:44:29.93503	\N
81276e5d-84b9-486e-9ca2-230c9a80b554	\N	Riccardo	Manservisi	\N	MANSERVISI ENERGY SRL	Socio	339.8445126	\N	commerciale@manservisienergy.it;direzione@manservisienergy.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.966634	2025-08-06 18:44:29.93503	\N
e8cfdbe8-3d06-4591-b3ca-0369a9b9b824	\N	Maurizio	Guidotti	\N	L'OFFICINA DEL GUSTO S.R.L.	Titolare	347.4117349	\N	maurizio@guidottiofficinadelgusto.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.9676	2025-08-06 18:44:29.93503	\N
f4206e9e-e75b-456a-b6e4-00c3c2d078e0	\N	Annamaria	Righi	\N	L'OFFICINA DEL GUSTO S.R.L.	Referente	347.4117349	\N	maurizio@guidottiofficinadelgusto.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.968504	2025-08-06 18:44:29.93503	\N
80265c20-a61c-4381-ad3b-b411030d75a0	\N	Matteo	Belesolo	\N	IN & OUT GIARDINI DI BELESOLO MATTEO	Titolare	349.5868478	\N	inoutgiardini@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.969344	2025-08-06 18:44:29.93503	\N
17c8298e-3d2e-4bea-8692-b4ad80589de4	\N	Leonardo	Maroccolo	\N	MAROCCOLO STEFANO	Referente	333.8466918	\N	l.maroccolo@maroccolo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.970198	2025-08-06 18:44:29.93503	\N
02e4d007-fd01-4414-a426-70c476cf6b4d	\N	Anna Maria	Stanco	\N	ESTETICA PIU' BELLA DI STANCO ANNA MARIA	Titolare	\N	329 6178802	esteticapiùbella@live.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.971067	2025-08-06 18:44:29.93503	\N
8671473b-5a25-4735-9930-1f51a8e37d16	\N	Anna Maria	Stanco	\N	PIUBELLA S.R.L.	Titolare	\N	329 6178802	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.971928	2025-08-06 18:44:29.93503	\N
366d5a5a-808a-49f3-9e2f-0160d0846cbc	\N	Romolo	Benvenuto	\N	GRUPPO INSIEME S.R.L.	Referente	\N	348 7446118	romolo.benvenuto@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.972736	2025-08-06 18:44:29.93503	\N
82821db3-5e65-40ff-b09c-fa7d6c2bac9d	\N	Rosalba	Nasi	\N	M.P. FLOWERS SANREMO S.R.L.	Referente	\N	340 4555559	rosalba@mpflowers.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.973655	2025-08-06 18:44:29.93503	\N
2d4d3f72-f8d4-4895-b0ce-98867401d608	\N	Rosalba	Nasi	\N	M.P. FLOWERS S.A.S. DI NASI ROSALBA & C.	Titolare	\N	340 4555559	rosalba@mpflowers.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.974542	2025-08-06 18:44:29.93503	\N
206d3d62-2889-48bf-bec4-55e4b479fe89	\N	Beatrice	Tassinari	\N	EGOZONA S.R.L.	Titolare	\N	347 5100934	info@egozona.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.975513	2025-08-06 18:44:29.93503	\N
d616924f-553d-44e9-807b-92f7ca08b566	\N	Davide	Losso	\N	\N	Commercialista	040.301391	338.6663212	dl@asscoter.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.976379	2025-08-06 18:44:29.93503	\N
b03bfb1b-31ee-4916-a050-91ecea6d5e5d	\N	Giuseppe	Pepi	\N	\N	Commercialista - Revisore Legale	\N	335.6768981	giuseppe.pepi@fastwebnet.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.977356	2025-08-06 18:44:29.93503	\N
44e28f22-e898-40d9-9181-0fcfeef38aac	\N	Giancarlo	Cortellino	\N	\N	\N	040.7600368	335.6067484	cortellino@sgfarm.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.978216	2025-08-06 18:44:29.93503	\N
201c72cc-a0d2-4a15-a738-bef8fdb3fec0	\N	Michele	Bonzagni	\N	MANSERVISI ENERGY SRL	Commerciale	329.6976522; 051904252	\N	commerciale@manservisienergy.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.981665	2025-08-06 18:44:29.982998	\N
f34d1975-7515-47a5-b931-330b00450272	\N	Loretta	Gazzotti	\N	MANSERVISI ENERGY SRL	\N	051.904252;333.5240392	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.984138	2025-08-06 18:44:29.982998	\N
88e4c8fe-e989-4613-8f5d-e273058beb3a	\N	Francesca	Tavernari	\N	ALLEO SRL	Titolare	335.6818979	\N	amministrazione@alleosrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.985267	2025-08-06 18:44:29.982998	\N
dca9c6a3-cb59-44d5-a4ff-145bcb546c29	\N	Antonio	Costa	\N	ARBURG S.R.L.	CFO	02.533799.241	\N	antonio_costa@arburg.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.986571	2025-08-06 18:44:29.982998	\N
b1fc0385-a58d-4ea2-8132-4bf925ee987a	\N	Luca	Sala	\N	ENDUSER ITALIA S.R.L.S.	\N	\N	\N	l.sala@enduser-italia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.987795	2025-08-06 18:44:29.982998	\N
420fbfb9-8e77-4866-a273-47822372d679	\N	Cecilia	Blasetti	\N	ELETTRA SINCROTRONE TRIESTE S.C.P.A.	International Project Officer	366.6176911	\N	cecilia.blasetti@elettra.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.98915	2025-08-06 18:44:29.982998	\N
1cd1e9c5-fefd-4abf-9764-de2fa63de6ab	\N	Giacomo	Leanza	\N	EDILIZIA PARISI DI MAZZURCO FRANCESCA	Legale Rappresentante	\N	380.5966151	leanzagia@hotmail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.99036	2025-08-06 18:44:29.982998	\N
60f01f9c-40b7-4b93-8fd2-4354fbd53120	\N	Tony	Parisi	\N	EDILIZIA PARISI DI MAZZURCO FRANCESCA	\N	\N	329.6953422	parisitony87@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.99136	2025-08-06 18:44:29.982998	\N
5fe0ce8a-b941-4d05-8988-897477344def	\N	Martina	Tinelli	\N	M.P. FLOWERS SANREMO S.R.L.	Referente	\N	338 3229899	martina@mpflowers.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.992478	2025-08-06 18:44:29.982998	\N
52d4a190-86b7-467a-a26c-a94a977d7373	\N	Martina	Tinelli	\N	M.P. FLOWERS S.A.S. DI NASI ROSALBA & C.	Referente	\N	338 3229899	martina@mpflowers.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.993537	2025-08-06 18:44:29.982998	\N
29d7b2e1-7313-4792-9b0e-3d829745ff3d	\N	Ivano	Upennini	\N	\N	Revisore	\N	328 3011147	serviziced@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.994516	2025-08-06 18:44:29.982998	\N
c8609660-0951-4557-8719-6582ebec73d2	\N	Flavio	Pol	\N	\N	Tributarista	\N	348.8601656	flavio@cedass.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.995489	2025-08-06 18:44:29.982998	\N
194ebe01-57c0-4210-bcde-0815f0606337	\N	Sandro	Sartori	\N	Sartori's Hotel	Managing Director	\N	\N	info@sartorishotel.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.996608	2025-08-06 18:44:29.982998	\N
ae8843c8-d18a-44f3-a9b7-b675570a46b0	\N	Petro	Bucaneve	\N	RISTORANTE BUCANEVE	Titolare	348.6686494	\N	petro.bucaneve2020@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.998027	2025-08-06 18:44:29.982998	\N
4ddea4d4-5ccc-4617-8ff8-a233596a2169	\N	Gianfranco	Zoppi	\N	ZOPPI A. SRLS	Titolare	\N	335 6901585	gianfranco@zoppisrl.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:29.99924	2025-08-06 18:44:29.982998	\N
ff847dbd-b04a-4faa-a2f1-a5a6b3ae27b0	\N	Claudio	Cordano	\N	\N	\N	334 8774968	\N	claudiocordano8@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.000463	2025-08-06 18:44:29.982998	\N
07dd5da1-7e3b-4ec3-8d82-69b51bcbe7a4	\N	Stefano	Farolfi	\N	Farolfi Arredamenti	Titolare	349.3721704	\N	farolfiarredamenti@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.001874	2025-08-06 18:44:29.982998	\N
344f7339-e02c-4ef9-87ee-1586054c29ca	\N	Riccardo	Praticò	\N	PIUMA S.R.L. UNIPERSONALE	Titolare	327.0273867	\N	piumapizzaecucina@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.00303	2025-08-06 18:44:29.982998	\N
d429fd41-92de-4506-812b-a52c985ac360	\N	Valentina	Bonelli	\N	HOTEL ALLA ROCCA DI BONELLI VALENTINA	Titolare	349.7018238	\N	info@hotelallarocca.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.003973	2025-08-06 18:44:29.982998	\N
49cae6f4-186d-4abd-8e87-cff5922dca3e	\N	Dania	Baga	\N	ENPOWER S.R.L.	Responsabile Amministrazione	+393351664436	\N	dania.baga@enpower.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.006054	2025-08-06 18:44:29.982998	\N
188264ae-716a-4056-a7f5-d045c43461f2	\N	Davide	Russo	\N	DAVIDE RUSSO STUDIO DI FISIOTERAPIA	Titolare	\N	349.5214877	fisioterapia.russo@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.007179	2025-08-06 18:44:29.982998	\N
406a8538-f741-4acc-8729-2e3dfe21c9e4	\N	Aldo	Rizzardi	\N	O.M.O. S.P.A.	Responsabile Amministrazione	\N	\N	amministrazione@omospa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.008173	2025-08-06 18:44:29.982998	\N
4ceeb3e6-b4ef-4be8-b9e1-4184d230dd0a	\N	Stefano	Sciannamblo	\N	\N	\N	\N	340.2598807	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.009131	2025-08-06 18:44:29.982998	\N
6613b82c-9163-4e1a-9c1e-cdb2153192fa	\N	Martino	Merlin	\N	MOKAMO SRL	Titolare	335.8156367	\N	info@braocaffe.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.010161	2025-08-06 18:44:29.982998	\N
5f12c88e-9287-4fa4-807d-075b7fc1745b	\N	Gianluca	Leonardi	\N	Studio Leonardi Seppi Commercialisti	Socio	340.6667172;0461.402225	\N	gianluca.leonardi@lscommercialisti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.011119	2025-08-06 18:44:29.982998	\N
6c9b1dc4-b7e9-48f9-9d19-ae3ba5dedfc9	\N	Domenico	Gualdi	\N	Santi e Gualdi Servizi Assicurativi srl	Socio	347.19110494	\N	domenico.gualdi@agenzia.unipol.it;d.gualdi@unipoltrento.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.012138	2025-08-06 18:44:29.982998	\N
c7705682-d567-4820-8ef7-37ce548b24fd	\N	Mirko	Santi	\N	Santi e Gualdi Servizi Assicurativi srl	Socio	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.013255	2025-08-06 18:44:29.982998	\N
8cedacc6-d8cc-4a3b-828e-3cda10446f82	\N	Paolo	Pisciali	\N	\N	\N	335.7233369	\N	paolo.pisciali@conciliumteam.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.01448	2025-08-06 18:44:29.982998	\N
70f7b9c5-b8b2-42d0-8b26-921b7ca8679f	\N	Niko	Zecchinato	\N	G.M.T. S.P.A.	\N	\N	348.3251882	zecchinato@gmtspa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.01563	2025-08-06 18:44:29.982998	\N
8c6a6788-c220-49fd-8d3d-27cfc43d1d73	\N	Luca	Brentan	\N	G.M.T. S.P.A.	Socio	\N	393.9680399	brentan@gmtspa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.016773	2025-08-06 18:44:29.982998	\N
d9b2cd85-34da-4e6b-84f6-f2de86cba53d	\N	Francesco	Avoni	\N	AVONI INDUSTRIAL SRL	Titolare	335.5404520	\N	avoni@avonisrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.01797	2025-08-06 18:44:29.982998	\N
6bac457a-0cac-413a-bb16-14ae00879f37	\N	Guido	Saccani	\N	AVONI INDUSTRIAL SRL	CFO	342.6467294	\N	guido.saccani@avonisrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.019095	2025-08-06 18:44:29.982998	\N
cb7ffaf4-97fa-427d-ae1f-1740f8bd7be3	\N	Roberto	Zanni	\N	MOBILI ZANNI Srl	Titolare	+393357458340	\N	roberto@mobilizanni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.020197	2025-08-06 18:44:29.982998	\N
de44433f-87c8-465f-809f-a486e7c05d3d	\N	Matteo	Minghinelli	\N	LAB SRL	Revisore	\N	348 5491746	matteo@studio-blm.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.021426	2025-08-06 18:44:29.982998	\N
ee01f136-dfe3-4d2f-bed2-efac619bd0e9	\N	Alessia	Azzalini	\N	CAMPING VAL RENDENA S.R.L.	Titolare	349.8527748	\N	info@campingvalrendena.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.022722	2025-08-06 18:44:29.982998	\N
138b7fdf-3643-4b3e-a5b9-b66ac8cafb2b	\N	Giorgio	Vento	\N	\N	Partner Esterno	\N	333 2440640	info@finanzaimpresa360.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.023749	2025-08-06 18:44:29.982998	\N
05e56979-7677-4280-90f7-76ca4fd64ebd	\N	Patrick	Federici	\N	LA TERRAZZA DI FEDERICI PATRIK	Titolare	333.6507890	\N	laterrazza.federici@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.024681	2025-08-06 18:44:29.982998	\N
57144cc9-84e8-483d-b738-e17d6a1d4ef8	\N	Eva	Prelz	\N	ENERGIA E SERVIZI S.R.L.	Socia	\N	366.1812611	eva.prelz@energiaservizi.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.0259	2025-08-06 18:44:29.982998	\N
21f5a88f-1e9c-4ecd-b368-24f60cd58f7b	\N	Giorgio	Prelz	\N	ENERGIA E SERVIZI S.R.L.	\N	\N	348.3667268	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.027099	2025-08-06 18:44:29.982998	\N
17345a14-a281-44fa-b6c1-b04865b64c72	\N	Sara	Magnani	\N	GEO INFISSI S.R.L.C.R.	Titolare	\N	340 6548488	saramagnani79@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.028363	2025-08-06 18:44:29.982998	\N
c2f5c3a5-9329-4223-99f1-bd9f015b9365	\N	Christian	Borghetti	\N	EDIL COLOR DI BORGHETTI CHRISTIAN	Titolare- Rappresentante Legale	\N	329 2533286	christianborghetti@yahoo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.02979	2025-08-06 18:44:29.982998	\N
ca8cc14d-a65e-4674-954e-8f72f78e9507	\N	Sara	Cavara	\N	Mavericks	Titolare	345.7634936	\N	s.cavara@mavericksinbologna.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.031042	2025-08-06 18:44:29.982998	\N
0682c064-daab-4016-8dc8-ed623e5ac71b	\N	Paola	D' Ambrosio	\N	BELL'E PRONTO DI D'AMBROSIO PAOLA	Titolare	\N	339 6475644	pd300572@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.032126	2025-08-06 18:44:29.982998	\N
5e1b0f51-3fd6-42fb-80d3-b75d76501c0d	\N	Alessandra	Argiolu	\N	EASY CONTACT S.R.L.	Referente	\N	348 3966310	alessandra.argiolu@easyceditalia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.033129	2025-08-06 18:44:29.982998	\N
51ef887e-8d44-44eb-ac7a-8a8e4fb6b730	\N	Francesco	Liuzzi	\N	THE FACTORY S.R.L.	Titolare	328.4122238	\N	direzione@thefactorygroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.034125	2025-08-06 18:44:29.982998	\N
f0b28fc7-fd4c-42c1-a9f5-1be8d7f61194	\N	Serena	Moscabianca	\N	THE FACTORY S.R.L.	Referente	\N	\N	serena@moscabianca.info	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.035205	2025-08-06 18:44:29.982998	\N
7a616327-bb34-403f-acf7-a416337761c1	\N	Dario	Polimeno	\N	THEMA SERVIZI TURISTICI DI DE SANTIS RAFFAELE & C. *S.A.S.	Referente	347.8574134	\N	info@borgodelisanti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.036175	2025-08-06 18:44:29.982998	\N
061ca671-28a2-4e51-9567-0de9f88024ac	\N	Riccardo	Schito	\N	SPHERA LAB DI MARINO DONATEO	Referente	334.5783042	\N	info@spheralab.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.037197	2025-08-06 18:44:29.982998	\N
01ecbd57-a61c-4bfc-8c77-eff1d4aa6d40	\N	Marino	Donateo	\N	SPHERA LAB DI MARINO DONATEO	Titolare	333.2894940	\N	info@spheralab.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.038427	2025-08-06 18:44:29.982998	\N
f7eaab65-58dc-4640-8dfc-03fc1296e837	\N	Katia	Comingio	\N	GOMMA SERVICE ADL S.R.L.	Referente	349.3002030	\N	katia.comingio@gommaservice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.03952	2025-08-06 18:44:29.982998	\N
9a65af21-8e36-4af7-8580-6bd078a9deee	\N	Adriano	De Luca	\N	GOMMA SERVICE ADL S.R.L.	Referente	329.0546820	\N	adriano@gommaservice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.042579	2025-08-06 18:44:30.043606	\N
1d84342a-6d96-4b75-a5bc-1137f7381d9b	\N	Laura	Ciocio	\N	H.G.V. ITALIA S.R.L.	Referente	351.1267382	\N	amministrazione@hgvitalia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.044423	2025-08-06 18:44:30.043606	\N
be934a03-681d-4d76-a56a-0915615b19a3	\N	Ciro	Cinelli	\N	H.G.V. ITALIA S.R.L.	\N	329.8922083	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.045407	2025-08-06 18:44:30.043606	\N
fa5f63ca-8f9f-4e30-97f8-107d54cb52fa	\N	Alessandro	Libertini	\N	LA GATTA S.R.L.	Titolare	320.8034258	\N	alexristorantelecce@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.046322	2025-08-06 18:44:30.043606	\N
9217133b-5d8e-4012-9e55-1ceeaa9ae27d	\N	Francesco	Mauro	\N	ADRIATICO S.R.L.	Titolare	0434.639301	\N	info@ristoranteadriatico.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.047201	2025-08-06 18:44:30.043606	\N
2c393387-f441-434d-9a08-14a9bf1e4d29	\N	Michele	Gambini	\N	ADAPTA S.R.L.	Titolare	349.4008614	\N	michele.gambini02687@unipolsai.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.048068	2025-08-06 18:44:30.043606	\N
2f20e6d6-3a20-4a80-ae72-60128bbb8db9	\N	Paolo	Sfreddo	\N	ELITA SRL	Referente	0432.661208	\N	paolo.sfreddo@elitasrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.04892	2025-08-06 18:44:30.043606	\N
cebb1abb-26bf-4879-a110-08525e0545de	\N	Liliana	Lepore	\N	BEW TECNOLOGIA ITALIANA S.R.L.	Referente	0432.965172	\N	amministrazione@bewtecnologia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.049802	2025-08-06 18:44:30.043606	\N
795aca3f-6fcf-49f2-908d-3027efecdaf9	\N	Luca	Cappellazzo	\N	TRAS SERVICE DI CAPPELLAZZO LUCA	Titolare	338.5871000	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.050715	2025-08-06 18:44:30.043606	\N
341e1c94-6694-43ac-aa46-f12aa3501425	\N	Giorgia	Fattori	\N	TRAS SERVICE DI CAPPELLAZZO LUCA	Referente	340.4713515	\N	giorgia.trasservice@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.051599	2025-08-06 18:44:30.043606	\N
1d342dd8-0ee5-4bd1-ac99-94511c119742	\N	Luca	Cappellazzo	\N	WE SPEED S.R.L.	Titolare	338 5871000	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.052495	2025-08-06 18:44:30.043606	\N
d5982f2d-aa3b-4d0d-8319-67e5eae626e1	\N	Giorgia	Fattori	\N	WE SPEED S.R.L.	Referente	340 4713515	\N	giorgia.trasservice@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.053485	2025-08-06 18:44:30.043606	\N
4f4785fb-bfca-4a00-bc58-cc4104de1b85	\N	Marco	Mucini	\N	MUCINI S.R.L.	Titolare	335.7748943	\N	marco.mucini@mucini.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.054324	2025-08-06 18:44:30.043606	\N
79600359-f480-4dc9-be86-59d2f558aeb9	\N	Paolo	Tonelli	\N	ITECH SOLUZIONI S.R.L.	Responsabile Amministrativo	347.1590932	\N	paolo.tonelli@itechsoluzioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.055167	2025-08-06 18:44:30.043606	\N
47454e80-210b-4eb9-9017-1c4f08fac9aa	\N	Guido	Porcellato	\N	SO.VE.T. SOCIETA' VETRARIA TREVIGIANA S.R.L	Referente	\N	\N	guido@sovet.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.05612	2025-08-06 18:44:30.043606	\N
7ee401eb-3edd-45b0-b91c-09686414bf77	\N	Pompeo	Tria	\N	STEP IMPIANTI S.R.L.	Presidente - Ceo	348.8265434	\N	p.tria@fintria.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.057025	2025-08-06 18:44:30.043606	\N
192ea519-2aad-4db7-82ca-ca74e1ab490d	\N	Anna	Tria	\N	STEP IMPIANTI S.R.L.	Referente	348.2608768	\N	a.tria@tintria.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.058083	2025-08-06 18:44:30.043606	\N
8083e0ab-899c-4ae5-9c40-b6744c748514	\N	Antonella	Migliori	\N	SIMOPARMA PACKAGING ITALIA S.R.L.	Referente	345.1458454	\N	antonella.migliori@technepackaging.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.059012	2025-08-06 18:44:30.043606	\N
ba7f6d9c-433a-4025-b8eb-2f19543e5468	\N	Barbara	Zanotti	\N	SIMOPARMA PACKAGING ITALIA S.R.L.	Referente	0542.639901	\N	barbara.zanotti@technepackaging.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.059929	2025-08-06 18:44:30.043606	\N
870f1747-a2d0-42cf-af02-8c7bb21ccd37	\N	Manuel	Piva	\N	PET SOLUTIONS S.P.A.	\N	340.6452388	\N	manuel.piva@petsolutions.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.060902	2025-08-06 18:44:30.043606	\N
1c291b57-3631-4088-8ddd-ba9a729d452b	\N	Luca	Morosin	\N	PET SOLUTIONS S.P.A.	\N	338.6181259	\N	luca.morosin@pegasoindustries.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.062142	2025-08-06 18:44:30.043606	\N
05fa6c1b-0b88-4ef6-8b89-9ae8354440e7	\N	Luca	Bogana	\N	PET SOLUTIONS S.P.A.	\N	049.9335901	\N	luca.bogana@pegasoindustries.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.063238	2025-08-06 18:44:30.043606	\N
06a4930b-4546-4ca1-a5d7-fea70586d83f	\N	Jessica	Ciutto	\N	FRIULBRAU S.R.L.	Referente	335.5722608	\N	hr.fornitori@friulbrau.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.064318	2025-08-06 18:44:30.043606	\N
2ef162a0-7ea0-470d-a218-a2514909c2e6	\N	Matteo	Fantin	\N	FRIULBRAU S.R.L.	\N	335.5722608	\N	hr.fornitori@friulbrau.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.065455	2025-08-06 18:44:30.043606	\N
e82bef26-1a5d-4dbb-bfc9-f81225cf41c1	\N	David	Bassi	\N	SYSTEMA S.P.A.	Titolare	340.8685698	\N	340.8685698	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.066602	2025-08-06 18:44:30.043606	\N
0b1edd6a-d5a0-4141-a56a-f9da6824c87f	\N	Barbara	Rigotti	\N	RIGOTTI F.LLI S.R.L.	Titolare	0461.827574	\N	amministrazione@autodemolizionirigotti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.067627	2025-08-06 18:44:30.043606	\N
2a23855a-c319-4f51-8c25-f10d8e3e5412	\N	Paolo Giulio	Calvi	\N	CALVI IL SALUMIERE S.N.C. DI CALVI PAOLO GIULIO E C.	Titolare	\N	333 6418986	paolo-calvi@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.068747	2025-08-06 18:44:30.043606	\N
df331b9f-e667-48a0-ad2b-2de34311d484	\N	Marco	Santini	\N	LONER S.R.L.	Referente	393.3300883	\N	lonerlavanderia@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.069949	2025-08-06 18:44:30.043606	\N
f6ebc38c-55f2-4ae9-8989-376a92228271	\N	Ronald	Masi	\N	R.K. S.A.S. DI RONALD MASI & C.	Titolare	\N	346 9454160	ilinfo@lachiesaccia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.071099	2025-08-06 18:44:30.043606	\N
1d63cadc-b2a4-48ff-b9a7-05655ee4ceb7	\N	Matteo	De Zuani	\N	CO.RA.PEL. S.R.L.	Titolare	340.5219799	\N	document@corapel.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.07246	2025-08-06 18:44:30.043606	\N
8789da02-c5af-4ca3-91bb-9bff521d21e8	\N	Massimiliano	Cascone	\N	MC SERVIZI DI MASSIMILIANO CASCONE S.A.S.	Titolare	\N	320 1922070	info@mcservizi.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.0738	2025-08-06 18:44:30.043606	\N
0d84e025-8295-4cdc-8f75-782e48993073	\N	Roberto	Verna	\N	OPERA GROUP S.R.L.	Titolare	0536.934811	\N	roberto.verna@ceramicaopera.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.075152	2025-08-06 18:44:30.043606	\N
cc6bb565-bd73-4719-80b5-10af395952d8	\N	Maria	D' Ambra	\N	MANGIAROTTI S.P.A.	Financial Analyst	3427592330	\N	maria.dambra@westinghouse.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.076356	2025-08-06 18:44:30.043606	\N
96429609-f178-41e4-a802-94e240f6b4a5	\N	Giulia	Perosa	\N	MANGIAROTTI S.P.A.	\N	\N	\N	perosag@westinghouse.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.077541	2025-08-06 18:44:30.043606	\N
2169bd21-acc9-4547-8392-b34d7038af95	\N	Vittorio	Murer	\N	MANGIAROTTI S.P.A.	\N	\N	\N	vittorio.murer@westinghouse.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.07859	2025-08-06 18:44:30.043606	\N
42b39d88-0129-4491-89d3-ad88b132a93d	\N	Gianni	Tagliariol	\N	TAGLIARIOL DI TAGLIARIOL PIETRO E GIANNI S.A.S.	Titolare	348.4440244	\N	direzione@tagliariol.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.079515	2025-08-06 18:44:30.043606	\N
c23cd870-4cad-45ac-b522-1e9b5a30bb7d	\N	Corrado	Vitale	\N	IL CIELO DI VITALE CORRADO & C. S.A.S.	Titolare	\N	349 6165519	polpette@polpettecrescentine.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.080504	2025-08-06 18:44:30.043606	\N
8c389bcd-08e8-489c-8ee1-db50cfe602d1	\N	Bianca	Cappelletti	\N	LA LUNA DI CAPPELLETTI BIANCA E C. S.A.S.	Titolare	333 1222048	\N	jazz@cantinabentivoglio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.081605	2025-08-06 18:44:30.043606	\N
fbea12fe-c211-4a1a-a46a-0a7492e1b7ec	\N	Marco	Sabato	\N	LE STELLE DI BONESI FABIO & C. S.A.S.	Referente	\N	328 8992541	marco.sabato@studioms.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.082792	2025-08-06 18:44:30.043606	\N
dc30b557-c7b1-46c2-897a-d651bcd84096	\N	Claudio	Cristofori	\N	TERMOIDRAULICA CRISTOFORI S.R.L.	Titolare	\N	328 9581185	segreteria@termoidraulicacristofori.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.08398	2025-08-06 18:44:30.043606	\N
e2a7d2ce-9dc7-493d-85a9-b8c07ab890a2	\N	Serena	Scatoletti	\N	ORIZZONTE S.A.S. DI SCATOLETTI SERENA	\N	\N	329 6625440	lsere.scatoletti@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.085079	2025-08-06 18:44:30.043606	\N
ab49c7bc-f3a6-4c58-b5c6-bcaaa07e3c32	\N	Massimiliano	Bandini	\N	CM ENERGY MARKET S.R.L.	Referente	342 5255135	\N	massimiliano.bandini@termoidraulicacristofori.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.08631	2025-08-06 18:44:30.043606	\N
e013fcb4-c1e1-43ca-a795-99462846be13	\N	Sergio	De Giuseppe	\N	COMMEDIA S.R.L.	\N	\N	\N	info@commediasrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.087266	2025-08-06 18:44:30.043606	\N
e79ecd98-9f4a-4f2c-8e35-e51e857c4837	\N	Salvatore	Maduli	\N	CREAZIONI EDITORIALI S.R.L.	Titolare	\N	393.9403689	salvatore.maduli@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.088283	2025-08-06 18:44:30.043606	\N
174a20c5-7bf4-4343-8c07-763753e9c91a	\N	Gemma	Gravina	\N	GSG PORTE	Titolare	\N	338 8202104	gsgporte@yahoo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.089484	2025-08-06 18:44:30.043606	\N
8dcca684-2494-434c-a39b-27ff66b3cae1	\N	Serena	Pautasso	\N	GASTRONOMIA CUCINA AMICA	Titolare	\N	347 5858634	cucinaamica@icloud.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.090519	2025-08-06 18:44:30.043606	\N
7d011b73-9778-4bb7-8b3d-8a88b483935a	\N	Fabio	Caponetto	\N	SUN&CO S.N.C. DI CAPONETTO FABIO E C.	Titolare	\N	340 9078629	fcaponetto@suneco.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.091453	2025-08-06 18:44:30.043606	\N
7a103813-067d-4d4a-b31a-8c0e45e91197	\N	Elisa	Pinto	\N	SUN&CO S.N.C. DI CAPONETTO FABIO E C.	Referente	\N	349 7657168	epinto@suneco.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.092633	2025-08-06 18:44:30.043606	\N
5652ab9b-7fa0-4d79-804d-99bb784d8475	\N	Luca	Pasquini	\N	\N	Partner esterno	+43 664 1305785	\N	luca.pasquini@engageitservices.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.093476	2025-08-06 18:44:30.043606	\N
1aabb6a9-1044-4129-b44d-8c2517e67831	\N	Massimo	Dasara	\N	GEAL S.R.L.	Titolare	\N	328 9605388	maxdasara@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.094495	2025-08-06 18:44:30.043606	\N
a744e180-86fd-4c67-ab61-e678c2fb79fa	\N	Samuel	Facecchia	\N	VERA PIZZA S.N.C. DI SAMUEL FACECCHIA & TORALDO GABRIELE	\N	\N	327 2105482	info.tipo0@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.09801	2025-08-06 18:44:30.099132	\N
94e25baa-66a7-46d6-9b76-508b0bdc3be0	\N	Domitilla	Zolezzi	\N	RIATTIVA S.R.L.	\N	\N	347 4363340	domitillazolezzi@yahoo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.100503	2025-08-06 18:44:30.099132	\N
64e71019-1007-41e0-9053-a30a06653677	\N	Gianluigi	Mariotto Rocca	\N	GELATERIA GEPI MARE S.A.S. DI MARIOTTO ROCCA GIANLUIGI & C.	Titolare	\N	333.33377857	gepimare@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.101511	2025-08-06 18:44:30.099132	\N
4ec5bcdb-b047-4c22-8cfa-88d23b929b85	\N	Nadia	Mazzaferro	\N	TRATTORIA BAR EDERA S.R.L.	Titolare	\N	340 8376845	barederage@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.102669	2025-08-06 18:44:30.099132	\N
f6c594e9-07f9-4997-a063-b53e0f9a4917	\N	Ludovico	Zamarian	\N	PROMOCOLOR S.R.L.	Direttore Commerciale	335.7329695	\N	ludovicozamarian@promocolor.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.103682	2025-08-06 18:44:30.099132	\N
71871c12-0cc7-45a4-b921-69ac8680f27d	\N	Francesca	Zucca	\N	IDROTECNOSARDA S.R.L.	Amministrazione	\N	3492174634	idrotecnosarda@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.104656	2025-08-06 18:44:30.099132	\N
00bbb799-8241-43f0-a09a-9e18a17db730	\N	Maurizio	Granucci	\N	G INFISSI S.R.L.	\N	\N	346 2611139	ginfissisrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.10561	2025-08-06 18:44:30.099132	\N
5a3609f8-069a-44a1-abf8-73457cea56ec	\N	Consuelo	Sammarco	\N	FUTURA MED SRL	Amministratrice	\N	347.8262146	medicidelbenessere@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.106657	2025-08-06 18:44:30.099132	\N
1ac58bd8-fb59-4f09-8498-a4bee5ce190e	\N	Sara	Chiari	\N	ECOSERVIM SRL	Referente	\N	338 7822101	s.chiari@ecoservim.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.107765	2025-08-06 18:44:30.099132	\N
1a8b62ae-80d0-4223-b11f-18c80a5bb52d	\N	Marco	Mura	\N	SARDINIAN CLUB S.N.C. DI GIUSEPPE MARRONE & MARCO MURA	Titolare	\N	349 3777380	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.108786	2025-08-06 18:44:30.099132	\N
60356192-fb7e-404c-8280-f0376f5eb73a	\N	Iole	Varrucciu	\N	VARPESCA S.R.L.	Titolare	\N	339.6125682	iolevarrucciu@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.109729	2025-08-06 18:44:30.099132	\N
1d24c87d-ef4d-428b-a684-8d89cdd42232	\N	Cesare	Bellamoli	\N	BELLAMOLI GRANULATI S.P.A.	Titolare	045.8650355	\N	cesare@bellamoli.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.110746	2025-08-06 18:44:30.099132	\N
24749a36-5f9f-40e0-a185-871aa383aea8	\N	Vittorio	Nacar	\N	NACAR'S RESTAURANT DI VITTORIO NACAR	Titolare	345 2361442	\N	nacar.vittorio95@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.11178	2025-08-06 18:44:30.099132	\N
90c7a40c-9387-41ce-819a-ecb474bd28a6	\N	Antonio	Bedin	\N	COSTENARO ASSICURAZIONI S.R.L.	Socio	338.7305406	\N	antonio@costenaroassicurazioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.113047	2025-08-06 18:44:30.099132	\N
7130a4ed-7921-4dfb-8129-b822370289bb	\N	Donatella	Zanini	\N	ZANINI BASSANO S.R.L.	Titolare	\N	347 5971103	info@zaninibassano.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.11409	2025-08-06 18:44:30.099132	\N
faeeb190-eae3-494e-aaa5-8c0a849af36c	\N	Antonella	Ghezzi	\N	MG SERVIZI S.R.L.	Titolare	320 1879292	\N	amministrazione@mg-servizi.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.115157	2025-08-06 18:44:30.099132	\N
32731de5-dc14-4190-98cc-d54f1b46e361	\N	Marco	Maggi	\N	CEGS	Titolare	\N	320 1879292	ufficio.personal@cegs.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.116227	2025-08-06 18:44:30.099132	\N
f0f3d231-028b-4776-9336-fd41edde0cb7	\N	Marco	Frediani	\N	FREDIANI MARCO	Consulente del lavoro	\N	328 8828378	studiofrediani@hotmail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.117521	2025-08-06 18:44:30.099132	\N
da99e2f9-c75d-4084-bd9a-9d0abc45636d	\N	Bruna	Civiero	\N	IDROTECNOSARDA S.R.L.	\N	0783.852007	\N	idrotecnosarda.qualita@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.118775	2025-08-06 18:44:30.099132	\N
f7cd9b38-f8e7-4d00-a483-8d951dc86c7b	\N	Fiorenzo	Pavan	\N	A.S.P. TECNOLOGIE S.R.L.	Titolare	348.7378377	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.120065	2025-08-06 18:44:30.099132	\N
7297b7c0-b704-4c44-a9c0-3a625c45cdd5	\N	Paola	Basso	\N	A.S.P. TECNOLOGIE S.R.L.	Referente	329.4570630	\N	amministrazione@asptecnologie.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.121301	2025-08-06 18:44:30.099132	\N
bb9fca78-7332-4a4a-9ff8-c370132d48ce	\N	Aurora	Schneider	\N	SCHNEIDER RAFFAELE	Referente	333.1663206	\N	servizioclienti@entrate.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.122477	2025-08-06 18:44:30.099132	\N
0ec9ae84-d927-4b31-9b04-4f723ab7f194	\N	Raffaele	Schneider	\N	SCHNEIDER RAFFAELE	Titolare	335.6293320	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.123475	2025-08-06 18:44:30.099132	\N
1163877a-b063-4cc4-bd31-373cc3a53753	\N	Ilaria	Marchetti	\N	PANIFICIO E PASTICCERIA MARCHETTI ITALO S.A.S. DI MARCHETTI ILARI A & C.	Titolare	\N	345 0221311	ilariamarchetti.71@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.124507	2025-08-06 18:44:30.099132	\N
a228fa26-cb1b-4000-ad8e-9c9ba1eff56e	\N	Rossano	Caon	\N	IL GRATICOLATO SOCIETA' COOPERATIVA SOCIALE	Referente	340.7771284	\N	rossanocaon@ilgraticolato.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.125492	2025-08-06 18:44:30.099132	\N
fa01be7e-9ba8-4b8d-98fb-c65d1d1ea8cd	\N	Marcello	Carta	\N	CODIAL S.R.L.	\N	\N	335.5495889	amministrazione@codialsrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.12745	2025-08-06 18:44:30.099132	\N
1444903e-8db2-4315-91a3-d6d7103b3c25	\N	Zaheer	Ahmed Ksana	\N	QUICK SERVICE S.R.L.	Referente	393.9486126	\N	ksana@quickservicetrasporti.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.128258	2025-08-06 18:44:30.099132	\N
fcf81a10-f680-44d4-ba4a-bb316760934c	\N	Monica	Cecchetto	\N	QUICK SERVICE S.R.L.	Impiegata Amministrativa	0424.592243	\N	info@quickservicetrasporti.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.129052	2025-08-06 18:44:30.099132	\N
7d3574d2-7ff6-4d27-a3fa-6d68c69731f3	\N	Roberta	Costantini	\N	INLINEA S.R.L.	Titolare	\N	348 7708134	costantiniroberta67@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.130323	2025-08-06 18:44:30.099132	\N
858b2dcf-4826-4f30-b9c7-479809cacfb6	\N	Moreno	Bertolo	\N	ERREBI AMBIENTE S.R.L.	Amministratore Unico	\N	335.7683383	m.bertolo@errebiambiente.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.131414	2025-08-06 18:44:30.099132	\N
0cd45ca7-4fcc-4da4-9837-725d97a5a32f	\N	Simone	Grando	\N	\N	\N	\N	349.5474540	gs.consulenzeaziendali@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.132523	2025-08-06 18:44:30.099132	\N
30dc4618-e9ca-4bd1-852d-7ec515a9a07d	\N	Roberto	Ferrari	\N	\N	\N	\N	\N	rfcdsfgf@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.133888	2025-08-06 18:44:30.099132	\N
5cef90d1-22a3-47ee-9c8c-1ad840c40e02	\N	Roberto	Re	\N	PR SERVIZI S.A.S. DI ROBERTO RE	Titolare	329.8610850	\N	roberto@studiore.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.134908	2025-08-06 18:44:30.099132	\N
5fd28812-fed0-4be6-84bf-4e93b13bd349	\N	Lara	Vidoni	\N	OFFICINA DEL CARRELLO DI VIDONI GIUSEPPE SRL	Referente	335.431587	\N	lara.vidoni@officinadelcarrello.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.135767	2025-08-06 18:44:30.099132	\N
fb7aa8c0-a4dc-4146-8914-626bec5fa675	\N	Giulio	Tessaro	\N	CHIMICA ECOLOGICA S.P.A.	Socio	340.5909372	\N	giulio.tessaro@chimeco.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.13667	2025-08-06 18:44:30.099132	\N
4186a756-84a7-47c2-a4a8-6831dd2bedae	\N	Lorenzo	Romonato	\N	NUOVA SABI SRL	Titolare	0424.75222	\N	info@sabi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.137583	2025-08-06 18:44:30.099132	\N
a27bed39-4d6f-473d-ad4d-876279df9360	\N	Adam	Santoni	\N	FAN srl	Legale Rappresentante	348.7191037	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.138418	2025-08-06 18:44:30.099132	\N
dea3dc6d-5bec-4ef8-8c1f-b0c3a588c5bd	\N	Andrea	Fontanini	\N	RENOVA SRL	Titolare	\N	393 1485164	andrea@carrozzerialatirrena.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.139294	2025-08-06 18:44:30.099132	\N
5bc4d24d-9260-429c-b49f-e3616495694b	\N	Elisa	Pistillo	\N	FROST ITALY S.R.L.	Titolare	333.1708320	\N	pistillo.e@frostitaly.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.140254	2025-08-06 18:44:30.099132	\N
a6aaa0b8-a889-4d8c-9c1c-0b7365357343	\N	Roberto	Zattara	\N	SIEL SISTEMI ELETTRONICI S.R.L.	Socio	339.7160758	\N	roberto@zattara.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.141345	2025-08-06 18:44:30.099132	\N
4f3e3af8-35b5-4672-bff8-cd4c4d0607ab	\N	Michele	Gelai	\N	MEKTRONIC S.R.L.	Referente	\N	\N	michele@mektronic.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.142387	2025-08-06 18:44:30.099132	\N
e2fbb7f7-4dc8-4cd5-b70f-55b82533ad1b	\N	Alessio	Seri	\N	RISTORANTE ALBERGO IL BERSAGLIERE DI SERI ALESSIO & C. S.A.S.	Titolare	0577 718629	\N	info@hotellapace.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.143679	2025-08-06 18:44:30.099132	\N
a84c8f6f-29f2-435f-bc13-92fb7328ca3e	\N	Loris	Bosseggia	\N	BRUNNEN INDUSTRIE S.R.L.	Referente	334.1516138	\N	info@brunnenindustrie.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.144858	2025-08-06 18:44:30.099132	\N
56cf919e-363d-4a18-a7ac-36b23c53baf4	\N	Andrea	Pecori	\N	TH.E S.R.L.	\N	0583 495630	\N	andrea.pecori@the-engineering.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.14616	2025-08-06 18:44:30.099132	\N
4b619a87-12a9-4983-897f-161ceb89fde5	\N	Ido	Mariani	\N	TENUTA MARIANI	\N	\N	334 6240890	info@segretodelcastello.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.147501	2025-08-06 18:44:30.099132	\N
e23a8d6d-7630-4eb9-a174-9e95b91f5708	\N	Diego	Gasparini	\N	BERGAMIN S.R.L.	Referente	0444.659201	\N	info@bergaminsrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.148623	2025-08-06 18:44:30.099132	\N
c47bcba8-a6c4-4cba-ba06-b22d6117999c	\N	Ursula	Zelioli	\N	MOOD'S CLINIC SRL	Titolare	\N	331 5055859	moodsclinicsrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.150106	2025-08-06 18:44:30.099132	\N
fd2904b2-3674-400b-8e45-81819ded07a8	\N	Federico	Rubbi	\N	Clique Srl	Socio Amministratore	371.4182850	\N	federico@cliquesrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.151455	2025-08-06 18:44:30.099132	\N
258eed65-5913-43e9-b3bf-0aba3f4c7fdc	\N	Leonardo	Petruccelli	\N	Clique Srl	Socio Amministratore	\N	\N	leonardo@cliquesrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.152678	2025-08-06 18:44:30.099132	\N
5acf3d29-8efd-4515-8bd7-39fc9932e05c	\N	Paolo	xxx	\N	Clique Srl	Socio Amministratore	\N	\N	paolo@cliquesrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.153921	2025-08-06 18:44:30.099132	\N
d4a23dcf-a084-4136-a419-98539bc5ac74	\N	Daniele	Cabassi	\N	Clique Srl	Socio	\N	\N	daniele@cliquesrl.it;daniele.cabassi@auctory.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.157388	2025-08-06 18:44:30.158548	\N
be98095c-f8d9-4658-aa31-20283e0563de	\N	Marcello	Rosa	\N	DOLOMATIC S.r.l.	Titolare	335.6265366	\N	m.rosa@buonristoro.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.159653	2025-08-06 18:44:30.158548	\N
534a9a67-6384-4165-997a-93eeb115db1c	\N	Alessio	Degasperi	\N	\N	Dottore Commercialista e Revisore	349.8060065;0461.1975610	\N	degasperi@csatn.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.160924	2025-08-06 18:44:30.158548	\N
09eb6ffa-5775-404c-b9bf-bf2125a1f7bd	\N	Roberto	D' Alessandro	\N	MARKET ALIMENTARE VERSILIA SRL	Titolare	\N	335 6012891	robertodalex@alice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.162088	2025-08-06 18:44:30.158548	\N
001fe7c5-b9ee-4ff5-b06f-ae6a6390dd27	\N	Andrea	Ciuci	\N	MARKET ALIMENTARE VERSILIA SRL	Commercialista	\N	389 1574129	andrea.ciuci@studio3elaborazione.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.163073	2025-08-06 18:44:30.158548	\N
09dc1449-2d0e-4508-b430-537f161dc6e3	\N	Massimiliano	Maracich	\N	EHMILO SRL	Amministratore	366.1556607	\N	ehmilosrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.164146	2025-08-06 18:44:30.158548	\N
85bc4ab2-f354-4967-9483-9a8c808d83d4	\N	Mimi	Menini	\N	MENINI ROMOLO NOLEGGI S.R.L.	Referente	0583 38375	\N	mimi@meninitensostrutture.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.16487	2025-08-06 18:44:30.158548	\N
c9b5e35e-4d9f-423c-83cf-07218438e5e4	\N	Hamado	Bance	\N	GASH S.P.A.	Referente	393.8857273	\N	gashsrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.165592	2025-08-06 18:44:30.158548	\N
fef937bb-77d7-4341-a0bf-4c1e9fafdcb6	\N	Francesca	Girardi	\N	OLEV SRL	Direttrice	328.5811362	\N	direzione@olevlight.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.166682	2025-08-06 18:44:30.158548	\N
3f054bd9-a15a-4b98-8462-02725f8eab62	\N	Andrea	Salvatori	\N	AURORA S.R.L.	Titolare	\N	349 3784495	andrea.salvatori@computerdiscover.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.167673	2025-08-06 18:44:30.158548	\N
f51a5623-9f7b-4e02-a7b2-ab42fdb7b80d	\N	Alberto	Belluomini	\N	LAB S.R.L.	Titolare	333 2910437	\N	amaro@hotmail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.168759	2025-08-06 18:44:30.158548	\N
2b61c713-616b-4fdd-8ada-fdbadb28db0d	\N	Nicola	Marzaro	\N	SIRMAN S.P.A.	Referente	348.7672258	\N	nicola.marzaro@sirman.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.17006	2025-08-06 18:44:30.158548	\N
c7c2db9c-9981-4461-a97f-37b90494710d	\N	Giovanni	Polli	\N	POLLI S.R.L.	Titolare	348 0099013	\N	g.polli@pollisrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.1712	2025-08-06 18:44:30.158548	\N
d5622828-3991-4cd5-ad0f-dfaf97058345	\N	Silvia	Grosso	\N	A C T I V A   S.R.L.	Referente	0422.898949	\N	amministrazione@activain.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.172129	2025-08-06 18:44:30.158548	\N
321905be-cb63-49e2-9565-273ba7e65415	\N	Alessandro	Ciriaci	\N	WEBCOOM S.R.L.	Titolare	392 1342392	\N	info@webcoom.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.173156	2025-08-06 18:44:30.158548	\N
5f00647d-535a-4b36-bb40-119ce0939afd	\N	Francesca	Fasolato	\N	FAIR S.R.L.	Amministrativa	049.9620444	\N	info@fairsrlcarpenteria.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.174243	2025-08-06 18:44:30.158548	\N
44cc4cc9-a720-43eb-a7c8-bd4773702648	\N	Annalisa	Barco	\N	BARCO S.R.L.	Referente	0445.962207	\N	annalisa@barcofratelli.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.17531	2025-08-06 18:44:30.158548	\N
5549c8f9-a64e-4a43-add0-ffc46e36fbab	\N	Silvia	Crotti	\N	\N	Commercialista	\N	339 5236712	silvia@cedarluno.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.176516	2025-08-06 18:44:30.158548	\N
b66d1ca4-1952-42d3-8442-141aa97999b9	\N	Giorgio	Guerrini	\N	FARMACIA RAVINA S.R.L.	\N	340.3531344	\N	info@giorgioguerrini.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.177938	2025-08-06 18:44:30.158548	\N
fcc8742c-5635-4fa5-bbc5-366f3eb43941	\N	Moira	Aramini	\N	B.S.J. MECCANICA S.R.L.	Referente	0442.480394 int 4	\N	amministrazione@bsj-meccanica.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.179291	2025-08-06 18:44:30.158548	\N
f9be908b-204c-4282-999a-f35c56b9a546	\N	Giuseppe	Portesan	\N	CALOR CLIMA DI PORTESAN GIUSEPPE ASSISTENZA RISCALDAMENTO	Titolare	335.5985307	\N	info@calorclima.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.180671	2025-08-06 18:44:30.158548	\N
f0abbe65-17a7-4f78-9253-7635ad60b11b	\N	Paolo Giacomo	Bonfiglio	\N	INCARIM DI BONFIGLIO PAOLO GIACOMO & C. SNC	Titolare	\N	328 6676376	lincarim@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.181912	2025-08-06 18:44:30.158548	\N
45477ef7-c903-4174-98ef-0443706af85a	\N	Giulia	Amoretti	\N	T.P.A. IMPEX S.P.A.	Referente	340.1637968	\N	giulia.amoretti@tpaimpex.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.182881	2025-08-06 18:44:30.158548	\N
0386c9d8-737a-49a8-8836-3416b827eefd	\N	Simone	Toffanin	\N	\N	\N	\N	334.1813208	simone.toffanin@nordest-group.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.183857	2025-08-06 18:44:30.158548	\N
317588d5-575f-4b89-a66f-a5b746fb5717	\N	Tiziana	Bellofiore	\N	FARMACIA RAVINA S.R.L.	Amministrativa e Responsabile Bandi	377.3416556	\N	amministrazione.ravina@farmaciegoodlife.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.184775	2025-08-06 18:44:30.158548	\N
23663103-907b-49cb-8484-c6320b024b39	\N	Guido	Bonazza	\N	FARMACIA RAVINA S.R.L.	Responsabile Formazione Dipendenti	351.3879343	\N	infermiere@farmaciegoodlife.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.185741	2025-08-06 18:44:30.158548	\N
74fceca7-4e23-41ce-b427-149e0b66c382	\N	Inna	Cioban	\N	Winner Bar S.r.l.s.	Titolare	375.6681770	\N	inna.cioban@yahoo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.18661	2025-08-06 18:44:30.158548	\N
77315a67-e3c8-4940-8887-4724891aae6f	\N	Fabio	Aguiari	\N	TWINCAD S.R.L.	Referente	349.3959827	\N	fabio@twincad.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.187484	2025-08-06 18:44:30.158548	\N
b0b3c0bf-eca1-4a8d-81e8-cbecaa8b6eeb	\N	Francesco	Innocenti	\N	TOSCOCELL S.R.L.	Titolare	\N	393 9211910	francesco.innocenti@toscocell.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.188525	2025-08-06 18:44:30.158548	\N
93ed3ba3-ecf9-4138-8505-ac7cf7a91ecf	\N	Stefano	Salmaso	\N	CARROZZERIA LA PERLA S.N.C. DI SALMASO STEFANO E C.	Referente	347.0700942	\N	347.0700942	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.18956	2025-08-06 18:44:30.158548	\N
ffb7c1da-0b60-457e-8f9b-3e2b977617dc	\N	Nicolò	Santoni	\N	SANTONI'S S.R.L.	Titolare	0461.984400;347.3955384	\N	info@orso-grigio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.190582	2025-08-06 18:44:30.158548	\N
4fd385c4-d67f-4c35-998a-af17c7dc255e	\N	Martina	Gorgoglione	\N	DELTA INFORMATICA S.P.A.	Marketing Specialist	0461.042200	\N	martina.gorgoglione@deltainformatica.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.191598	2025-08-06 18:44:30.158548	\N
d98107dd-3bc7-450b-b09a-0212840364d2	\N	Irene	Smalzi	\N	DELTA INFORMATICA S.P.A.	\N	\N	\N	Irene.Smalzi@deltainformatica.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.192612	2025-08-06 18:44:30.158548	\N
e4c52f9d-adbe-440a-add5-1ea477dc845c	\N	Miriam	Carboni	\N	CARBONI MIRIAM SRL	\N	\N	3389834153	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.193575	2025-08-06 18:44:30.158548	\N
26b23c28-1d3b-437b-b7b0-f74b0e591d56	\N	Miriam	Carboni	\N	TEK REF SRL	\N	\N	3389834153	carbonimiriam@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.1946	2025-08-06 18:44:30.158548	\N
cd77b091-b85e-40b7-9bdd-d458e6d49128	\N	Isabella	Gomez D'Arza	\N	IGO DISTRIBUTION S.r.l.	Titolare	348.7223039	\N	isabella.gomez@igodistribution.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.195539	2025-08-06 18:44:30.158548	\N
56fc0832-6721-4a51-a940-63c92306cd8f	\N	Miriam	Carboni	\N	STUDIO MIRIAM CARBONI - S.T.P. A R.L.	\N	\N	338 9834153	carbonimiriam@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.196668	2025-08-06 18:44:30.158548	\N
4f22e29d-ac31-497e-b8c8-a306a75bcabd	\N	Nico	Panigiani	\N	ISCHIETO RISTORANTE DI PIANIGIANI FIORENZO & C. S.N.C.	Titolare	\N	392 3187321	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.197618	2025-08-06 18:44:30.158548	\N
67e1159b-1fa0-4f0f-9ba0-d42182e942e5	\N	Cesare	Lencioni	\N	F.LLI LENCIONI DI LENCIONI CESARE & C. S.N.C.	\N	\N	339 2853420	cesare.lencioni@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.198759	2025-08-06 18:44:30.158548	\N
c0b5aba4-39f4-4b47-943b-79f1d5830fe3	\N	Cristian	Lupi	\N	HOTEL HELVETIA S.R.L. UNIPERSONALE	Revisore	\N	333 6785112	lupicristian@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.199864	2025-08-06 18:44:30.158548	\N
242ba803-e895-4ef2-bb78-64633aff399f	\N	Elisa	Lora	\N	VALFUSSBETT S.R.L.	Amministrazione	0445 408888 interno 0145	\N	elisa.lora@valfussbett.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.200697	2025-08-06 18:44:30.158548	\N
745ce24f-8a57-476b-aa96-c019666b7a33	\N	Michele	Vallerini	\N	LA GENTILE S.R.L.	Referente	0425.28800	\N	amministrazione@lagentile.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.20183	2025-08-06 18:44:30.158548	\N
37c8af0e-5a49-46e9-b494-66a58bae4998	\N	Alessandro	Calore	\N	ELMEC S.R.L.	Referente	347.6889722	\N	ale.calore@elmec.biz	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.202867	2025-08-06 18:44:30.158548	\N
374c34e2-e3a2-410d-9dfa-ef78a4a60bbc	\N	Ingrid	Bordin	\N	ELMEC S.R.L.	Legale rappresentante	0444.610746	\N	info@elmec.biz	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.203874	2025-08-06 18:44:30.158548	\N
86c13869-0e90-4b88-a357-eb430e7f3095	\N	Matteo	Agrofoglio	\N	RIVIERA SERVICE CENTER DI MATTEO AGROFOGLIO & C SAS	Titolare	\N	335 6059209	matteo@rscsanremo.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.204832	2025-08-06 18:44:30.158548	\N
1a7c3c93-7217-4260-b808-e20c4a5d4d6a	\N	Elisabetta	Malvestio	\N	INGROS'S FORNITURE S.R.L.	Referente	348.6706121	\N	segreteria@ingrossforniture.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.205874	2025-08-06 18:44:30.158548	\N
228f4401-f72c-495f-8d46-7123ddef8716	\N	Massimo	Alberghi	\N	RIVIERA SERVICE CENTER DI MATTEO AGROFOGLIO & C SAS	Revisore	\N	338 5093628	massimoalberghi1970@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.206941	2025-08-06 18:44:30.158548	\N
83a4100b-8de2-409c-b5c7-cbb48e09716a	\N	Emanuele	Crotti	\N	CARPANO S.R.L.	Referente	335.8438559	\N	info@carpanosrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.20798	2025-08-06 18:44:30.158548	\N
d55ca712-0703-4962-b2f7-c6de4ca5a60e	\N	Andrea	Morgavi	\N	RO.MO.LO. SRL	Socio	\N	335 1691008	morgavi100@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.20905	2025-08-06 18:44:30.158548	\N
00508cab-0e9d-44d0-8ecf-d658b46e5860	\N	Elena	Davià	\N	BI-DA SRL	Referente	0437.46906	\N	bigidav@gmx.co.uk	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.210299	2025-08-06 18:44:30.158548	\N
ff37d6b4-6d67-4bae-948d-7f0a68c827cf	\N	Andrea	Capaccioli	\N	DGNET S.R.L.	Socio	\N	333 1462792	a.capaccioli@dgnet.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.815823	2025-08-06 18:45:37.814546	\N
4da9dc60-b975-4383-99e3-fd3888ad11c8	\N	Stefano	Romoli Fenu	\N	DGNET S.R.L.	Socio	\N	328 3269760	s.romolifenu@dgnet.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.820038	2025-08-06 18:45:37.818679	\N
41bb65db-7d1a-493f-8bde-0c2157f9cf6c	\N	Luciano	Santi	\N	COMEX GROUP S.R.L.	Titolare	338.3256255	\N	info@comexgroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.825459	2025-08-06 18:45:37.823778	\N
a6909a9f-b014-4915-b276-d08ada99814f	\N	Santi	Desirè	\N	COMEX GROUP S.R.L.	Referente	\N	\N	amministrazione@comexgroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.830397	2025-08-06 18:45:37.829308	\N
bda4f366-e0ce-477c-9bcc-40eb8f1d9ea8	\N	Maria Pia	Falsia	\N	2AUTOCENTRI LA STORTA SRLS	Referente	335.1540509	\N	dueautocentrilastorta@outlook.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.834942	2025-08-06 18:45:37.833905	\N
a85c1b66-775f-492e-ac02-7e79b84b8c30	\N	Andrea	Zaccherini	\N	ADS AUTOMATION SRL	Titolare	333.6475795; 0542.643082	\N	andrea.zaccherini@ADSautomation.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.839723	2025-08-06 18:45:37.838545	\N
767257ff-5bbe-4a4d-b502-ac8df02aef20	\N	Antonella	Casisi	\N	ADS AUTOMATION SRL	Responsabile Amministrazione	334.6584890;0542.643082	\N	antonella.casisi@adsautomation.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.845035	2025-08-06 18:45:37.843606	\N
4431f86e-3261-4513-a1aa-073d88e186b4	\N	Enrico	Ceccarelli	\N	DGNET S.R.L.	Commerciale	\N	335 6244861	enrico.ceccarelli@dgnet.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.849034	2025-08-06 18:45:37.847986	\N
2b0adfaa-a6d6-478e-aadc-2b9a8f1b1d7a	\N	Alberto	Mainetti	\N	CITY CAR S.R.L.	Titolare	335.7720924;0543.86658	\N	albertomainetti@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.853247	2025-08-06 18:45:37.852275	\N
4e739d13-63c5-488e-8fa3-5c1fb38d353c	\N	Daniele	Pampaloni	\N	DGNET S.R.L.	Socio	\N	393 9650268	d.pampaloni@dgnet.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.856964	2025-08-06 18:45:37.855939	\N
3f831e77-27cf-4de6-9123-c9553d259958	\N	Marco	Lonardi	\N	TERMICA SISTEMI SRL	Titolare	335.8251327	\N	lonardi.marco@termicasistemi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.86114	2025-08-06 18:45:37.860094	\N
22a69abb-723e-4e10-aa99-3257d718b353	\N	Matilde	Danese	\N	TERMICA SISTEMI SRL	Amministrativa	320.1327611	\N	danese.matilde@termicasistemi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.865133	2025-08-06 18:45:37.864165	\N
c70e3644-43c5-454f-9509-99685af34afc	\N	Michele	Fontebasso	\N	GASTRONOMIA FONTEBASSO S.R.L.	Titolare	0422.777155	\N	fontebasso@ascotlc.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.868719	2025-08-06 18:45:37.867838	\N
3ef6b24f-eda0-4c5b-94c1-85639edfd87a	\N	Andrea	Paio	\N	ERREBI TECHNOLOGY S.P.A.	Referente	327.1355153	\N	info.andreapaio@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.872698	2025-08-06 18:45:37.87164	\N
4fcab2f2-31b3-4c66-a325-68894c8e29fc	\N	Maria Piera	Pigorini	\N	ACQUABIKE SRL	Legale Rappresentante	347.7828029;02.34534138	\N	biba.pigorini@acquago.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.876443	2025-08-06 18:45:37.875557	\N
61ddd642-9250-439a-bd23-eeda98a4e53b	\N	Russel	Giovannini	\N	\N	\N	347 6847722	\N	russellgiovannini@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.938191	2025-08-06 18:45:37.937475	\N
232fc48d-b0db-40cb-bc7d-e33b397bf630	\N	Vito	Laurino	\N	\N	\N	377.5301731	\N	info@vrassociati.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:37.947683	2025-08-06 18:45:37.947003	\N
80c9c62b-d023-4c4c-9488-b67964aab788	\N	Alex	Cittadella	\N	\N	\N	\N	340.8405440	alexcittadella@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.0488	2025-08-06 18:45:38.048224	\N
b14fea6a-fc50-493b-b05c-b6b734b8f9c5	\N	Roberta	Sforza	\N	ESSELLE SRLS	Titolare	+393346509161	\N	info@essellelavorazioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.119232	2025-08-06 18:45:38.118503	\N
6e2871ee-4cf1-48ae-a04a-f0063ba49cd3	\N	Iacono	Fabio	\N	MINERVA S.R.L.	Titolare	347.4561935	\N	minervasrlmarsala@pec.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.122596	2025-08-06 18:45:38.121721	\N
072c1925-d2f8-4210-a6bb-bab125580f90	\N	Francesca	Moscardini	\N	ANANDA S.R.L.	Titolare	\N	392 9770046	anandaflexy@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.126001	2025-08-06 18:45:38.125098	\N
ae24ef3f-5e26-412a-8c52-2a600e470bf6	\N	Fabio	Iacono	\N	IACONO FABIO & C. S.N.C.	Titolare	347 4561935	\N	genovamarketsnc@pec.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.130146	2025-08-06 18:45:38.128863	\N
75a7a70a-6b89-4a7f-a21b-b628f2215916	\N	Francesca	Moscardini	\N	MASALA S.R.L.S.	Titolare	392.9770046;0586 016315	\N	francescamoscardini@yahoo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.13442	2025-08-06 18:45:38.133276	\N
4b0df247-7352-4494-86ec-d0a24984b0f9	\N	Mirko	Frison	\N	CARROZZERIA FRISON 2 S.R.L.	Titolare	\N	\N	mirko@carrozzeriafrizon.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.335046	2025-08-06 18:44:30.335779	\N
4a35858c-2767-4e03-939e-f8ed5cc94374	\N	Monica	Loato	\N	LOATO S.N.C. DI MORENO E MONICA & C.	Titolare	392.9020006	\N	monica@loato.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.33687	2025-08-06 18:44:30.335779	\N
9240b1d4-9bcf-4a11-97ff-76122a21696e	\N	Laura	Noce	\N	SUNSER S.R.L.	Referente	375.6525034	\N	info@sunser.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.337897	2025-08-06 18:44:30.335779	\N
2fc545e6-d832-490c-b5a3-766b9b573b2d	\N	Claudio	Chiavaroli	\N	SOGIN S.R.L.	Titolare	335.8294074	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.338703	2025-08-06 18:44:30.335779	\N
d148847b-aa9b-4b59-b85b-1e074945f417	\N	Lorenzo	Torretti	\N	IDEA SERVIZI TECNICI SRL	Referente	329.6683926	\N	info@studioideapomezia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.339518	2025-08-06 18:44:30.335779	\N
89ec4148-e534-4248-91b9-a89fa0c331ed	\N	Roberto	Sterbini	\N	FALEGNAMERIA ARTIGIANA STERBINI SRL	Titolare	339 7473137	\N	falegnameriasterbini@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.340357	2025-08-06 18:44:30.335779	\N
3bd7c852-0546-41b9-b341-2a8ccf7e420f	\N	Roberto	Soccodato	\N	ACQUA EWO S.R.L.	Titolare	349 813 1354	\N	roberto.soccodato@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.341244	2025-08-06 18:44:30.335779	\N
6faf114b-fde1-47a9-a63b-15b8e892fc13	\N	Lorenzo	Agostinelli	\N	CANTIERE NAVALE AGOSTINELLI S.R.L.	Titolare	328.9538558	\N	cantiereagostinelli@hotmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.34213	2025-08-06 18:44:30.335779	\N
638e0296-f364-4b29-a385-86a8d14e6f00	\N	Katia	Filippini	\N	FILIPPINI UMBERTO & C. S.N.C.	Titolare	348 8005787	\N	amministrazione@filippinicereali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.342914	2025-08-06 18:44:30.335779	\N
df4d1ccc-cdcb-4c44-8f36-35fda9e9a4a0	\N	Aldo	Reale	\N	LA CURA MEDICAL SPA S.R.L.	\N	\N	338 6288871	aldoreale@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.344121	2025-08-06 18:44:30.335779	\N
7edcbd19-c64e-486d-a5c9-5306417b03c6	\N	Massimiliano	Corradini	\N	MY VOICE SRL	Titolare	347.5047740	\N	massimiliano.corradini@my-voice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.345208	2025-08-06 18:44:30.335779	\N
398c7fc9-0d34-48ec-bf3e-5dd2f97f48dc	\N	Marco	Pozzati	\N	TORNADO SERVIZI SRLS	Rappresentante Legale	\N	339.7629464	m.pozzati@tornadoservice.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.346282	2025-08-06 18:44:30.335779	\N
d337abb2-1625-43c1-8427-8794f30f9438	\N	Flavio	Assi	\N	LIBERA ADV S.R.L.	Titolare	348.5609582	\N	flavio@liberaadv.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.347353	2025-08-06 18:44:30.335779	\N
7d739696-b9ee-4529-943c-e34864b1f631	\N	Fiorella	Lanzeni	\N	LIBERA ADV S.R.L.	Referente	392.3787052	\N	amministrazione@liberaadv.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.348387	2025-08-06 18:44:30.335779	\N
93a01bdd-6e23-4e4d-98c2-353f968dc891	\N	Sara	Corradi	\N	S.C.A.R. REFRIGERAZIONE S.R.L.	Referente	340.4137122; 0362.491901	\N	s.corradi@scar-refrigerazione.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.34949	2025-08-06 18:44:30.335779	\N
233c39ae-817d-4891-8a0c-4e0476fcf788	\N	Giovanni	Ronconi	\N	REGGIANA GOURMET S.R.L.	Referente	348.9019003;0521.1797310	\N	giovanni.ronconi@reggianagourmet.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.350513	2025-08-06 18:44:30.335779	\N
cdeaaf3f-ae1e-4eb4-9ea9-de4cfdd40f79	\N	Sergio	Michelotto	\N	TORREFAZIONE CAFFE' ISOLA S.R.L.	Rappresentante Legale	\N	328.4574072	sergio.michelotto@caffeisola.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.35166	2025-08-06 18:44:30.335779	\N
f7e53c0c-ec5f-4733-a70c-8d1a728ce5a7	\N	Paolo	D'Ammassa	\N	CONNEXIA SOCIETA' BENEFIT SRL	Referente	348.4105843	\N	paolo.dammassa@connexia.retexspa.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.352616	2025-08-06 18:44:30.335779	\N
3f224574-a079-41e4-b8cf-74f1f456ec60	\N	Flavio	Mazzanti	\N	CENTRO STUDI SAMO S.R.L.	Titolare	051.268212	\N	flavio.mazzanti@studiosamo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.353749	2025-08-06 18:44:30.335779	\N
9ad01c1e-18c2-47af-b4f9-f0c48081c5ff	\N	Francesco	Di vicino	\N	DELISCA DI FRANCESCO DI VICINO S.A.S.	Titolare	\N	376 0751603	divicinofrancesco1@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.354715	2025-08-06 18:44:30.335779	\N
6141a64d-be6c-49ce-b36a-c8dee5022fc8	\N	Gabriele	Basso	\N	TANTOSVAGO S.R.L. SOCIETA' BENEFIT	Referente	340.6684695	\N	cfo2@tantosvago.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.35595	2025-08-06 18:44:30.335779	\N
d7346567-0edb-4db2-be65-feac1dd8dd94	\N	Antonio	Reverdito  Bove	\N	EUREKA S.R.L. - SOCIETA' BENEFIT	Referente	329.6987860	\N	antonio.reverdito@eurekaitalia.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.356885	2025-08-06 18:44:30.335779	\N
f14531dd-0e23-4052-94a1-ab45402c7d3d	\N	Jimmi	Baratti	\N	SUZZARA CASA S.R.L.	Titolare	0376.536868	\N	suzzara@immobiliarebaratti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.357896	2025-08-06 18:44:30.335779	\N
f9ed64ae-d4bb-401f-95f4-c8f368201632	\N	Filippo	Serlini	\N	GIARDINO S.R.L.	Titolare	334.9430420	\N	info@ristorantevillagiardino.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.358577	2025-08-06 18:44:30.335779	\N
78674dfd-8ac7-43b6-b552-7a6106e6b083	\N	Federica	"Vitaggio"	\N	IET SERVICE S.A.S. DI ROBERTO VITAGGIO & C.	Amministrazione	\N	377 4821618	info@ietservice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.359362	2025-08-06 18:44:30.335779	\N
42f84ca8-8b27-46a7-b99a-baa28df2407c	\N	Milo	Salamon	\N	MEDIACY S.R.L.	Titolare	328 212 1918	\N	info@mediacy.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.360104	2025-08-06 18:44:30.335779	\N
aa5aa7dd-ce1e-4554-820f-da9ceb114bfa	\N	Nicola	Gerotto	\N	MEDIACY S.R.L.	Socio	392.1795721	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.36088	2025-08-06 18:44:30.335779	\N
91d3c587-3956-4813-b0c8-013343d13569	\N	Michela	Perin	\N	OCREV SOCIETA' A RESPONSABILITA' LIMITATA FORMA ABBREVIATA  OCREV S.R.L.	\N	\N	344 0494212	michela_perin@ocrev.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.36158	2025-08-06 18:44:30.335779	\N
e956fde4-4163-4839-b417-0b7dc2da9be5	\N	Vilmer	Selleri	\N	CONAD NORD OVEST SOCIETA' COOPERATIVA	\N	348 3575152	\N	vilmer.selleri@conadnordovest.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.362366	2025-08-06 18:44:30.335779	\N
3ebb9a29-e4ad-4966-92ea-15a15ee16076	\N	Valentina	Arcozzi	\N	L'ITALIANA S.R.L.	Referente	347.0192614	\N	valentina.arcozzi@pcm-ups.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.363094	2025-08-06 18:44:30.335779	\N
2efa8aff-f05b-4bab-8433-40e8d76c854b	\N	Alex	Morotti	\N	N.T.M. S.R.L.	Commerciale e braccio destro del Titolare	+39 335 109 7709	\N	sales2@ntmsrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.36395	2025-08-06 18:44:30.335779	\N
d3e73835-e93f-4671-a455-a729e2b6ab07	\N	Cristina	Bonsaglia	\N	N.T.M. S.R.L.	Ufficio Amministrazione	0354381286	\N	amministrazione@ntrsrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.364722	2025-08-06 18:44:30.335779	\N
1a1384a7-88d6-43d5-9bf2-4c17ad220f2d	\N	Salvatore	Piccinato	\N	NARDI ELETTRONICA S.R.L.	Referente	348.2338842	\N	salvatore@nardielettronic.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.365433	2025-08-06 18:44:30.335779	\N
a7f9a14e-39e7-4e38-ab12-d1df8477dffa	\N	Umberto	Falsarolo	\N	F.B. INGROS SERVICE SRL	Titolare	3482710040	\N	info@fbingros.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.36628	2025-08-06 18:44:30.335779	\N
2130461b-9ce8-45a0-bd8d-f3d00658f4a2	\N	Andrea	Ghidini	\N	ODPIU' S.P.A.	Titolare	339.7647058	\N	a.ghidini@odplus.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.367014	2025-08-06 18:44:30.335779	\N
3db5609c-7ca7-40a6-b5a5-e9633d32c708	\N	Barbara	Castellari	\N	ODPIU' S.P.A.	Ufficio Amministrativo e Commerciale	339.7260905	\N	b.castellari@odplus.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.367701	2025-08-06 18:44:30.335779	\N
2ef81dc9-6607-4560-9492-77c5f9a08141	\N	Ermanno	Viscogni	\N	SPIRALFLEX S.R.L.	Referente	348.0194300	\N	info@spiralflex.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.368475	2025-08-06 18:44:30.335779	\N
982b4e53-98c5-4e6a-a780-fc308c902164	\N	Silvia	De Pretto	\N	QUADRIFOGLIO E C. S.R.L.	Referente	+39 392 335 6570	\N	info@lavanderia-quadrifoglio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.369538	2025-08-06 18:44:30.335779	\N
0c103137-94b3-49c4-968d-b7c9da484175	\N	Emanuele	Galli	\N	GALLI GIULIO CESARE & C. S.N.C.	Titolare	339.4139007; 051. 6145454	\N	info@carrozzeriagalli.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.370388	2025-08-06 18:44:30.335779	\N
b4537dc9-07c6-4804-8e07-edd4ab74696e	\N	Fabio	Dal Corso	\N	MARMOBON S.R.L.	Referente	333.9814187	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.371141	2025-08-06 18:44:30.335779	\N
430e8b17-fa30-4524-8445-269fdd8fed80	\N	Daniele	Dal Corso	\N	MARMOBON S.R.L.	Referente	3346012002	\N	daniele.dalcorso@marmobon.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.37195	2025-08-06 18:44:30.335779	\N
9e6eee83-d017-440c-9d23-c5daec7c7ca6	\N	Fabrizio	Cefalo	\N	CEFALO S.R.L.	Titolare	0874.92000	\N	f.cefalo@enotecacefalo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.372791	2025-08-06 18:44:30.335779	\N
c739c390-2770-4bed-80ec-1e9803e4f515	\N	Franco	Beretta	\N	AUTOLAVAGGIO S. MARIA DI BERETTA FRANCO & C. S.N.C.	Titolare	\N	339 3667655	carwash-sm@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.373573	2025-08-06 18:44:30.335779	\N
3febbc9a-95f3-4243-899f-3891799947c7	\N	Luca	Hu	\N	LOVE SUSHI SRLS	Titolare	388.9570188	\N	lucah@ymail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.374344	2025-08-06 18:44:30.335779	\N
8c693ad4-50d9-4a01-93c4-24afb556f0fd	\N	Luca	Hu	\N	SUSHI RESTAURANT SRLS	Titolare	388.9570188	\N	lucah@ymail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.375366	2025-08-06 18:44:30.335779	\N
06a82f78-d7b4-4418-91bd-39c7e0b1d737	\N	Stefania	Cerioni	\N	RISTORANTE DA JARI S.N.C. DI TOSELLI JARI E C.	Referente	\N	347 1969928	ristorantedajari@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.376189	2025-08-06 18:44:30.335779	\N
b0827b0c-ed2c-4fa9-a6b9-1b5fd8cee0d9	\N	Nicola	Perazzoli	\N	PERAZZOLI NICOLA	Titolare	348 6933968	\N	info@perazzolinicola.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.377196	2025-08-06 18:44:30.335779	\N
98ba217d-ec59-45f4-92e0-ed4ce479fa9a	\N	Valeria	Rossi	\N	BELLIN S.P.A.	Accounting & Financial Dept	0444.874900	\N	v.rossi@bellinpompe.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.378043	2025-08-06 18:44:30.335779	\N
49995ce2-52ed-406f-8939-975fdef04bc9	\N	Giovanna	Bellin	\N	BELLIN S.P.A.	CEO	0444.874900	\N	g.bellin@bellinpompe.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.378836	2025-08-06 18:44:30.335779	\N
ba9b816b-080e-471e-9313-376872c5d887	\N	Francesco	Bellin	\N	BELLIN S.P.A.	CEO	0444.874900	\N	f.bellin@bellinpompe.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.379556	2025-08-06 18:44:30.335779	\N
c2d68f90-86ce-485f-bf12-66244aff2f71	\N	Fabio	Iacono	\N	GENOVA MARKET DI FABIO IACONO & C. S.N.C.	Titolare	347.4561935	\N	genovamarketsnc@pec.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.137858	2025-08-06 18:45:38.136946	\N
3d8e8bd8-7b04-4aaf-9ab2-b6885cb9d498	\N	Luca	Pasquini	\N	ENGAGE LABS SRL	Referente	+43 664 1305785	\N	luca.pasquini@engagelabs.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.141901	2025-08-06 18:45:38.140832	\N
1cc90f9b-67a3-435b-81a9-3f5494228ecc	\N	Massimiliano	Spina	\N	LIM S.R.L.	Titolare	\N	348 1698526	info@littleitalybarbershop.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.145782	2025-08-06 18:45:38.144757	\N
f18d2916-76f4-4426-9e0b-852bbfcda3f3	\N	Paola	Poggi	\N	PISORNO AXICURA S.R.L.	Titolare	348.2474666	\N	amministrazione.ag4704@axa-agenzie.it;paola.polipoggi@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.149449	2025-08-06 18:45:38.148598	\N
11239b63-8493-4bd9-a0c8-8bc5222339f8	\N	Letizia	Paoli	\N	PISORNO AXICURA S.R.L.	Referente	339.7309890	\N	amministrazione.ag4704@axa-agenzie.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.152958	2025-08-06 18:45:38.151935	\N
d7a3e527-0d01-447d-a8d8-48915ec2800b	\N	Giulio	Consortini	\N	PISORNO AXICURA S.R.L.	Commercialista	333.9213272	\N	giulio.consortini@studioconsortini.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.157139	2025-08-06 18:45:38.155927	\N
780b277b-6fe5-4bcd-834e-74f07494f841	\N	Luciano	Romano	\N	FONTANA SERAFINO & FIGLIO S.R.L.	Ragioniere amministrativo	328.1034102	\N	luciano@fontanaserafino.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.164572	2025-08-06 18:45:38.163714	\N
1f2eb275-2e8e-476b-98af-8d1e89db54dd	\N	Fabio	Armani	\N	MPR SRL	Titolare	348.7915204	\N	armanifabio@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.168158	2025-08-06 18:45:38.167259	\N
8e524540-5540-40d3-a9d1-00df22e13fcc	\N	Vittoria	Bazzu	\N	VSGS SRLS	Titolare	342 9102495	\N	vsgssrls@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.172289	2025-08-06 18:45:38.171162	\N
300c9ef5-229f-45c4-a2ae-ce0733439c72	\N	Francesca	Taccola	\N	ESCHINI AUTO S.R.L.	Titolare	335.5417629	\N	francesca.taccola@eschiniauto.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.17717	2025-08-06 18:45:38.175923	\N
e491fb05-c707-4735-a47c-c424a3ba3173	\N	Lando	Franchi	\N	\N	Partner esterno e Revisore	329 9442536	\N	info@landofranchi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.180567	2025-08-06 18:45:38.18005	\N
6a76729b-ed42-4017-b790-0a3e2983a559	\N	Mauro	Lupetti	\N	RENATO LUPETTI S.R.L.	Legale Rappresentante	327.7410671	\N	renato.lupetti@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.183874	2025-08-06 18:45:38.183005	\N
897cf585-a05b-4d0c-a23a-437da4390400	\N	Monica	Del Papa	\N	RENATO LUPETTI S.R.L.	Referente	3478894855	\N	renato.lupetti@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.187491	2025-08-06 18:45:38.186579	\N
08bdf62f-7951-487c-8faa-596ec5aaf877	\N	Mirco	Cappetta	\N	ENGAGE IT SERVICES SRL	Commercialista	348.1565250	\N	cappetta@studiocappetta.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.190676	2025-08-06 18:45:38.189799	\N
eb8549c9-0b5f-4221-a281-28334821f68b	\N	Luca	Pasquini	\N	ENGAGE IT SERVICES SRL	Amministratore unico	0043.664.1305785	\N	luca.pasquini@engageitservices.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.193908	2025-08-06 18:45:38.193067	\N
7d3cc1f4-55f8-49a1-a296-9a6654a01cb1	\N	Romina	Mignani	\N	PASTICCERIA CAFFETTERIA DOLCI MAGIE SNC DI MIGNANI ROMINA SOLEDAD & C.	Titolare	393.8086347	\N	dolcimagie@hotmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.197987	2025-08-06 18:45:38.196783	\N
53742844-32a6-4b67-a067-1ee5ce181b9b	\N	Andrea	Marinesi	\N	PASTICCERIA CAFFETTERIA DOLCI MAGIE SNC DI MIGNANI ROMINA SOLEDAD & C.	Consulente del lavoro	0187.1473622	\N	andrea.marinesi@studiomarinesi.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.201944	2025-08-06 18:45:38.200755	\N
565fd388-2ef3-4a08-a766-fe683bb5032e	\N	Mario	Tolaini	\N	PASTICCERIA CAFFETTERIA DOLCI MAGIE SNC DI MIGNANI ROMINA SOLEDAD & C.	Revisore	0585 74076	348 6591093	mario.tolaini@studiotolaini.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.205734	2025-08-06 18:45:38.204675	\N
b2f74c0f-dde4-4096-a8cd-cf6662f607d0	\N	Federica	Benvenuti	\N	PYROGIOCHI ITALIA S.R.L.	Referente	3494774961	\N	federica.benvenuti@pyrogiochi.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.208705	2025-08-06 18:45:38.207943	\N
9fe17c40-91e1-4da1-b86c-1b979abb4577	\N	Stefano	Ghelardoni	\N	PYROGIOCHI ITALIA S.R.L.	Revisore	335.8111857	\N	stefano@studioghelardoni.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.211762	2025-08-06 18:45:38.211047	\N
d8396f09-cc0d-4c0c-b350-0158d8a82d7a	\N	Angela	Alberi	\N	COOPERATIVA SOCIALE ALLE CASCINE	Referente	329.6523504	\N	angela.alberi@promozioneumana.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.214717	2025-08-06 18:45:38.213956	\N
1d45097b-4f9e-42ee-b14b-178c2c1044df	\N	Alberto	Agosti	\N	OSTERIA DEL CAFFE' S.R.L.	Revisore Legale	\N	320.8034542	alberto.agosti@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.21794	2025-08-06 18:45:38.217158	\N
859bc4af-d8cd-4a92-b3ee-3f1c0cb067c4	\N	Giacomo	Goria	\N	STUDIO SCIANDRA & ASSOCIATI	Commercialista - Referente	340 9800577	\N	g.goria@studiosciandra.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.221079	2025-08-06 18:45:38.220315	\N
7c4b6519-db8c-4f5b-996b-f533911a234a	\N	Danilo	Ciangaglini	\N	COOPERATIVA SOCIALE PROMOZIONE UMANA	Consulente del lavoro	337.910721	\N	danilo@selmar.info	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.224239	2025-08-06 18:45:38.223432	\N
2fb69edd-2a7b-4e32-a652-54be739c8db2	\N	Patrick	Perissutti	\N	L.S. NORD S.R.L.	\N	\N	334.6136191	tecnico@lsnord.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.22787	2025-08-06 18:45:38.226715	\N
1277a4dc-7d29-4f21-80ce-a7f86808a323	\N	Christian	Facchinelli	\N	ART POLISH S.R.L.	Titolare	\N	\N	christian@artpolish.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.231746	2025-08-06 18:45:38.230517	\N
e216f170-5b35-4ff8-a7db-c8a012e892df	\N	Daniele	Pinna	\N	PINNA DANIELE	Amministratore	3494127844	\N	giardinodeglianimali@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.234647	2025-08-06 18:45:38.23383	\N
d7f74581-cc43-422e-bf94-4ce7aca30797	\N	Marco	Barozzi	\N	STUDIO 1 AUTOMAZIONI INDUSTRIALI SRL	\N	\N	335.1343281	m.barozzi@studio1srl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.237941	2025-08-06 18:45:38.237071	\N
9aadb213-3317-43d2-8310-b0d7942e5301	\N	Barbara	Righi	\N	STUDIO 1 AUTOMAZIONI INDUSTRIALI SRL	\N	\N	\N	b.righi@studio1srl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.241564	2025-08-06 18:45:38.240447	\N
0f9b4b73-f679-4fc4-877f-8c3f5a5af169	\N	Patrizia	Pietrelli	\N	FERAL S.R.L.	Referente	3288735770	\N	patrizia@feralsp.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.244893	2025-08-06 18:45:38.243874	\N
cd6393b3-2a4f-478d-ae4c-13fe0709909b	\N	Davide	Piccioli	\N	FERAL S.R.L.	Revisore	338.3068353	\N	info@studio-piccioli.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.248369	2025-08-06 18:45:38.24728	\N
b467b5fe-7331-4f4e-b6fa-c120e4e144bc	\N	Luca	Ginesi	\N	\N	Commercialista	\N	339.3260765	lucaginesi1964@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.25156	2025-08-06 18:45:38.251004	\N
78926dde-1ab9-40a4-a0fb-567c716e41c1	\N	Ottavio	Montaresi	\N	FERAL S.R.L.	Consulente del lavoro	0187.286640	\N	montaresi@confartigianato.laspezia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.254867	2025-08-06 18:45:38.253798	\N
4a0ce315-bbfa-48ad-8ac8-cc8b42ee3303	\N	Nicola	Giovannoni	\N	CIFRA SAS DI BERTUCCELLI MARIA CINZIA	Socio	347.1857642	\N	giovannoninicola@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.258153	2025-08-06 18:45:38.257105	\N
b3c14961-d54a-4148-af59-57fafe5376ef	\N	Fabio	Piccoli	\N	CIFRA SAS DI BERTUCCELLI MARIA CINZIA	Commercialista	347.1857642	\N	fabio.piccoli@piccoliconsulting.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.261839	2025-08-06 18:45:38.260591	\N
39a83b71-51d2-4101-b0df-7f89a859f8c2	\N	Giovanni	Della Pina	\N	EDILCOMPONENTI S.R.L.	Commercialista	348 3363126	\N	dellapina@inwind.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.265569	2025-08-06 18:45:38.264818	\N
7a060fe2-a6c0-4daa-aac8-451016bb14c5	\N	Alessandro	Grassi	\N	EDILCOMPONENTI S.R.L.	Consulente del lavoro	335 6210155	\N	segreteria@studiograssicdl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.26894	2025-08-06 18:45:38.267891	\N
45cc8dc5-b435-44cd-8447-f621868416b1	\N	Ferdinando	Crudeli	\N	EDILCOMPONENTI S.R.L.	Titolare	335 7806362	\N	ferdy@edilcomponenti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.272038	2025-08-06 18:45:38.271234	\N
daf38102-d719-4046-bb5b-e116748baefd	\N	Lisa	Luciani	\N	\N	Commercialista	\N	347.5877369	info@studiolisaluciani.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.275007	2025-08-06 18:45:38.274452	\N
545bc7e8-101c-461f-8e75-1cfeadcf25c1	\N	Marco	Accordi	\N	L' EXTRO DI ACCORDI MARCO	Titolare	347.7614868	\N	lextro.shop@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.278505	2025-08-06 18:45:38.277564	\N
1b3301f6-7143-47d5-a916-d1418662e446	\N	Alessandro	Alberti	\N	CSCA SRL	Referente	333.367.2391	\N	laspezia@cscasrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.281954	2025-08-06 18:45:38.280959	\N
1c4e089d-4d67-45a4-a3b5-381f8cacb53f	\N	Alessio	Alberti	\N	CSCA SRL	Commercialista	335.6058237	\N	alberti.a@outlook.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.285702	2025-08-06 18:45:38.284434	\N
9bcd8745-a1a2-43d9-a7b3-b1c626f89a8c	\N	Cesare	Alberti	\N	CSCA SRL	Consulente del lavoro	345.7711300	\N	laspezia@cscasrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.290556	2025-08-06 18:45:38.28951	\N
cbe9f6f2-e8cd-4a72-bde2-d01ece7ebde8	\N	Andrea	Scotto	\N	SCOTTO PNEUMATICI DI MASSIMO E ANDREA SCOTTO SOCIETA' IN NOME COLLETTIVO	Titolare	347.4652627	\N	scottopneumatici@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.294278	2025-08-06 18:45:38.293227	\N
23ac2b66-379e-4180-9fe1-7543af636345	\N	Roberto	Bavestrello	\N	SCOTTO PNEUMATICI DI MASSIMO E ANDREA SCOTTO SOCIETA' IN NOME COLLETTIVO	Revisore	349.5377212	\N	robertobavestrello@studiobavestrello.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.298075	2025-08-06 18:45:38.297007	\N
1a135f10-c11f-47a0-87c0-dcba10663b21	\N	Luigi	Baldini	\N	PANETTERIA BALDINI DI FICERAI FRANCESCA	Referente	393.9598503	\N	amministrazione.baldinigp@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.302142	2025-08-06 18:45:38.301102	\N
c6ef16ce-d99f-45ca-8f93-9cd05bb81edd	\N	Luigi	Baldini	\N	PANETTERIA BALDINI S.R.L.	Titolare	393.9598503	\N	amministrazione.baldinigp@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.305749	2025-08-06 18:45:38.304945	\N
75023f78-5727-480d-bffc-e25164648945	\N	Giuliano	Angeli	\N	PANETTERIA BALDINI S.R.L.	Commercialista	0584.768895	\N	giuliano.angeli@gruppoangeli.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.308753	2025-08-06 18:45:38.307958	\N
5fe110d4-02d7-4260-b9aa-cc62f85a933c	\N	Egidio	Lusardi	\N	LUSARDI S.R.L.	Titolare	335.6060957	\N	lusardi@lusardisrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.31167	2025-08-06 18:45:38.310927	\N
5e9210af-e23c-4e63-a669-08bd56ea6196	\N	Luca	Nolli	\N	LEAF4LIFE SRL	Socio	+393393053393	\N	leaf4life2024@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.314865	2025-08-06 18:45:38.314061	\N
bd4ee50b-ceb7-411d-9bea-da185191534a	\N	Vincenzo	De Petrillo	\N	COIFFEUR VANNI DI OLIVETI GRAZIELLA E C. S.N.C.	Titolare	347.0533163	\N	coiffeurvanni@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.317691	2025-08-06 18:45:38.316994	\N
2f9ed4ed-01eb-4428-9f47-6d638dde1ed6	\N	Pierluigi	Anedda	\N	AG FARMA S.R.L.	Titolare	334.3986416	\N	agfarmasrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.321518	2025-08-06 18:45:38.320564	\N
d71f4588-44e6-433f-b8dc-900b0a320632	\N	Sonia	Anedda	\N	AG FARMA S.R.L.	Commercialista	\N	\N	Sonia.anedda@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.326181	2025-08-06 18:45:38.324763	\N
cb1685d7-b88f-4f50-9cc8-4b5b2c853906	\N	Francesca	Bastianoni	\N	XLR8  S.R.L.	Referente	335 6265155	\N	francesca@xlr8.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.331437	2025-08-06 18:45:38.330359	\N
9dfe9af2-b033-49de-90db-d009e097dad1	\N	Daniela	Gosio	\N	XLR8  S.R.L.	Commercialista	02 5417971	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.335362	2025-08-06 18:45:38.334412	\N
fccf38eb-8da0-46f6-aa0b-4d3eb99b0553	\N	Giovanni	Cucci	\N	XLR8  S.R.L.	Consulente del lavoro	02 3311352	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.339326	2025-08-06 18:45:38.338247	\N
d4a705f7-2c08-44c6-8b31-3d464bbc4447	\N	Nicola	Pannozzo	\N	GELATERIA K2 DI PANNOZZO NICOLA S.A.S.	Titolare	340.2686040	\N	info@gelateriak2.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.342986	2025-08-06 18:45:38.341903	\N
2a6c611d-9899-4161-9854-bcf29fe72f4b	\N	Daniele	Sanguineti	\N	GELATERIA K2 DI PANNOZZO NICOLA S.A.S.	Commercialista e Revisore Legale	0185.481269	\N	daniele@danielesanguineti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.346701	2025-08-06 18:45:38.345612	\N
8c71535f-fed1-4410-ae17-95073fa7d0ac	\N	Andrea	Ghelardoni	\N	\N	Partner esterno e Revisore	\N	346.6858695	a.ghelardoni@outlook.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.350223	2025-08-06 18:45:38.349521	\N
cf7139fe-64ff-496c-9807-7af4fcfc48b0	\N	Andrea	Bini	\N	WELCOME WAY S.R.L.	Titolare	347 3223741	\N	andrea@terremarine.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.353938	2025-08-06 18:45:38.352981	\N
297dbcd2-afc4-437f-aa13-f66adc7d3c0a	\N	Carlo	Luigini	\N	LUIGINI ECOLOGIA SRL	Titolare	335.7191512	\N	carlo.luigini@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.358033	2025-08-06 18:45:38.356929	\N
f153739d-d9e8-40ba-869f-2ce1cbb2b0eb	\N	Giovanni	Tassan	\N	TASSAN IMPIANTI SRL	Titolare	\N	348.2558552	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.362174	2025-08-06 18:45:38.361071	\N
dbe92887-971e-4631-b951-9cdfd642cc1a	\N	Nicoletta	Aresu	\N	TASSAN IMPIANTI SRL	Amministrativa	040.383886	\N	amministrazione@tassanimpianti.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.366033	2025-08-06 18:45:38.365154	\N
07e5d901-9700-40f2-b928-98b4dc88c82b	\N	Eros	Levratto	\N	NUOVA SICMI S.R.L.	Amministratore	333 5733342	\N	eros@nuovasicmi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.370416	2025-08-06 18:45:38.369439	\N
722048de-a2c8-484b-8711-94e15f3b331d	\N	Manola	Celeri	\N	FRIGORGELO S.A.S. DI MANOLA CELERI & C.	Amministratore e Legale Rappresentante	346 7483315	\N	frigorgelo@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.380146	2025-08-06 18:45:38.37851	\N
e978fc1e-e42d-42d3-8120-073128565c61	\N	Stefano	De Martini	\N	FRIGORGELO S.A.S. DI MANOLA CELERI & C.	Consulente del lavoro	333.4147206	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.385527	2025-08-06 18:45:38.384031	\N
75a63ce7-ed6b-4b3e-9d0f-29680f38270c	\N	Ermanno	Biselli	\N	SO.GE. S.R.L.	Titolare	348.6086380	\N	direttore.sempreverde@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.396142	2025-08-06 18:45:38.395159	\N
c0bf2cdf-2ba1-4444-a35a-5aeaafcefc3d	\N	Marco	Maggi	\N	BISTRO' SRL	Titolare	347.5813966	\N	admin@bistrosestrilevante.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.399875	2025-08-06 18:45:38.398992	\N
97c7cba7-f40b-488c-a56a-9ac428d8f4da	\N	Mattia	Zanini	\N	CMZ DI ZANINI RINO & C. S.R.L.	Titolare	339.1239848	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.581151	2025-08-06 18:44:30.581853	\N
322e6ee9-ba6f-4821-a6cd-8a8019fcd4c4	\N	Paolo	Nico	\N	CO.I.MA. - COSTRUZIONI IDRAULICHE MARANGONI - S.R.L.	Referente	342.5255732	\N	risorse@impresacoima.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.582553	2025-08-06 18:44:30.581853	\N
6f214ef6-9737-4ea9-b8e8-5cdfc08c6830	\N	Nina Gabriella	Madaffari	\N	NINA MADAFFARI	Titolare	328.4543354	\N	nina.madaffari@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.583391	2025-08-06 18:44:30.581853	\N
01583878-12fc-4cd1-9dc5-809bf2c53302	\N	Gilberto	Castoldi	\N	COBUE S.S. SOC. AGR. DI CASTOLDI SIMONA MARIA ELSA E GILBERTO	Referente	335.7680734	\N	commerciale@cobue.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.584365	2025-08-06 18:44:30.581853	\N
50785653-1fe5-4511-aded-86adb2e8027e	\N	Andrea	Carniel	\N	COMEC S.R.L.	Chef Executive Officier	335.7803033	\N	andreac@comecpn.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.585207	2025-08-06 18:44:30.581853	\N
6f35e952-9392-4445-b02d-416094724d3d	\N	Anna	Termini	\N	PROGETTO VACANZE SNC DI BOEDDU GIAN PIERO & MARONGIU GIAN LUIGI	Referente	\N	328 7768172	amministrazioneprogettovacanze@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.586046	2025-08-06 18:44:30.581853	\N
d54e3f99-753c-495f-aff9-726b31b24e27	\N	Paola	Moriondo	\N	COMITEC OLEODINAMICA E PNEUMATICA S.R.L.	Referente	329.6584744	\N	p.moriondo@comitecnet.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.586865	2025-08-06 18:44:30.581853	\N
350fdc8a-e901-46a2-b04f-e0795e3feb24	\N	Lorenzo	Ravella	\N	COMMUNICATION PRODUCTS S.R.L.	Referente	347.2117147	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.587728	2025-08-06 18:44:30.581853	\N
0bf8aff7-5e18-447c-a0be-16ccf37cc90d	\N	Simona	Compagnoni	\N	COMPAGNONI FRANCO E C. S.N.C.	Referente	328.4105000	\N	amministrazione@compagnonifranco.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.588601	2025-08-06 18:44:30.581853	\N
2880010a-837c-4458-ac23-1e886670e7e0	\N	Alberto	Lanaro	\N	COMPIUTA S.R.L.	Referente	375.7113508	\N	alberto.lanaro@compiuta.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.589504	2025-08-06 18:44:30.581853	\N
aff1c325-b7dc-4ce0-bfef-748f9ada8a05	\N	Chiara	Ratta	\N	B2CONNECT SOCIETA A RESPONSABILITA' LIMITATA START-UP INNOVATIVA - SOCIETA' BENEFIT	Business Developer	327.4967862	\N	c.ratta@connecteed.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.590357	2025-08-06 18:44:30.581853	\N
65430f8d-2e98-4e05-a825-38cc6f526906	\N	Anna	Termini	\N	O.B.M. S.N.C. DI BOEDDU GIAN PIERO & C.	Referente	\N	328 7768172	amministrazioneprogettovacanze@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.591219	2025-08-06 18:44:30.581853	\N
5ac3a3bb-3ecb-41a4-bfaa-6f3fed0c6de9	\N	Anna	Termini	\N	G.E.G. S.N.C. DI BOEDDU GIAN PIERO & C.	Referente	328 7768172	\N	amministrazioneprogettovacanze@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.592038	2025-08-06 18:44:30.581853	\N
e75f686d-d8df-4c87-aa14-8e3a09a65217	\N	Anna	Termini	\N	FORMULA 4 S.R.L.	\N	\N	328 7768172	amministrazioneprogettovacanze@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.592828	2025-08-06 18:44:30.581853	\N
325a5e03-ea23-4227-9be8-c6045f75ac5c	\N	Matteo	Tedeschi	\N	CONSORZIO PER LA TUTELA DEI VINI VALPOLICELLA	Direttore	045.7703194	\N	direzione@consorziovalpolicella.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.593682	2025-08-06 18:44:30.581853	\N
a870bce5-b892-47d5-a814-723b8ebbe380	\N	Rubens	Butera	\N	CONSULTECH SRL	Commerciale	334.7608253	\N	rbutera@consultech.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.59461	2025-08-06 18:44:30.581853	\N
04812959-db60-4f9f-b703-397357ce5868	\N	Ruben	Fornito	\N	CONSULTECH SRL	Referente	345.5804842	\N	rfornito@consultech.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.595596	2025-08-06 18:44:30.581853	\N
c731017a-2214-4d02-9b7a-592d9c000808	\N	Simone	Spataro	\N	COOPERATIVA SOCIALE L'ORTO SOCIETA' COOPERATIVA SOCIALE IN SIGL A L'ORTO SOC. COOP. SOCIALE.	Presidente	051.878169	\N	s.spataro@cooperativalorto.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.596508	2025-08-06 18:44:30.581853	\N
fd755572-2fa6-42ba-a818-50c6977f3143	\N	Giulia	Doretto	\N	OSAC3 DI SILVIO MINUZ & C. S.N.C. - S.T.P.	\N	0421.276488	\N	giuliadoretto@osac3.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.597427	2025-08-06 18:44:30.581853	\N
58fb11b7-ea5a-476a-8fc1-56a74f99945e	\N	Luca	Cabassi	\N	CORMACH S.R.L. CORREGGIO MACCHINE	Commerciale	335.314041	\N	sabrina@cormachsrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.598316	2025-08-06 18:44:30.581853	\N
8a199187-b6c4-4142-b7bf-1bb67b7f1a40	\N	Pier Luigi	Zuccari	\N	COROFAR - COOPERATIVA DI SERVIZI ALLE FARMACIE - SOCIETA' COOPERATIVA	Referente	335.5757131	\N	zuccari@corofar.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.599106	2025-08-06 18:44:30.581853	\N
76cc1e57-1d36-46d3-98b5-f78ac67bec48	\N	Nicola	Poponi	\N	COROFAR - COOPERATIVA DI SERVIZI ALLE FARMACIE - SOCIETA' COOPERATIVA	Commercialista della Cooperativa	340.3820651	\N	npoponi@studiopoponi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.599888	2025-08-06 18:44:30.581853	\N
5a7609f7-f24d-478b-8a60-3392726753d7	\N	Margherita	Carloni	\N	COROFAR - COOPERATIVA DI SERVIZI ALLE FARMACIE - SOCIETA' COOPERATIVA	Referente	\N	\N	carloni@corofar.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.600623	2025-08-06 18:44:30.581853	\N
dadf040a-b3a7-4336-b775-f2f1d0458ef3	\N	Mirko Lucio	Furia	\N	CROCE DEL VENTO S.R.L.	Titolare	\N	\N	mirkolucio.furia@crocedelvento.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.601397	2025-08-06 18:44:30.581853	\N
7955dea9-f201-44b7-9a28-a1131ba47b39	\N	Massimo	Negrin	\N	OMC S.R.L.	Socio	\N	0444.623998	postvendita@omc-srl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.602244	2025-08-06 18:44:30.581853	\N
d9b0e89f-32ad-452c-9944-3ca3a56a656d	\N	Dino	Muraro	\N	CRV S.A.S DI MURARO DINO	Titolare	349.6269326	\N	muraro@crvsistemi.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.60307	2025-08-06 18:44:30.581853	\N
5ed9d173-b8d0-4966-ace1-27dc89c19eff	\N	Vito	Di Lorenzo	\N	CUSTOM BUSINESS SRL	Ttolare	329.6493353	\N	vito.dilorenzo@custombusiness.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.603873	2025-08-06 18:44:30.581853	\N
0ba94d87-a11e-4dcc-9941-e26a3c7ccb0d	\N	Davide	Duregon	\N	DUREGON SRL	Titolare	347.4420259	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.604604	2025-08-06 18:44:30.581853	\N
8ddd5b4c-df1c-4513-ae04-3b150c8aee8b	\N	Arianna	Calzava	\N	DUREGON SRL	Referente	340.3325611	\N	info@duregonsoluzionielettriche.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.60537	2025-08-06 18:44:30.581853	\N
b60a1bbd-743c-493e-8922-cab9b33d1fea	\N	Fabrizio	Vivona	\N	ANGELUS S.R.L.	Commercialista	380 3019817	\N	prampolinivivona@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.606204	2025-08-06 18:44:30.581853	\N
cf6150e0-8436-4953-b172-4b63d3244b00	\N	Alberto	Maggiore	\N	LA MAGGIORE S.R.L.	Socio	\N	348.2700814	alberto@lamaggiore.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.606959	2025-08-06 18:44:30.581853	\N
fe94d6c4-0f5a-4bee-a08c-317d5393a93b	\N	Giovanni	Rigo	\N	DAKOTA GROUP S.A.S. DI ZENO CIPRIANI & C.	Referente	351.9727666	\N	giovanni.rigo@dakotaitalia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.607677	2025-08-06 18:44:30.581853	\N
75e834c1-6caa-4952-a1af-019a154e7132	\N	Michele	Cipriani	\N	DAKOTA GROUP S.A.S. DI ZENO CIPRIANI & C.	Titolare	348.6001037	\N	mc@dakota.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.608514	2025-08-06 18:44:30.581853	\N
3127e3a6-7093-4387-bc0c-7c4e92103878	\N	Matteo	Maggiore	\N	LA MAGGIORE S.R.L.	\N	\N	373.7609293	matteo@lamaggiore.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.609363	2025-08-06 18:44:30.581853	\N
2dce9626-7e04-4fa0-9363-5d5f4938bba9	\N	Debora	Daffini	\N	I DADI DI DEBORA DAFFINI	Titolare	328.8583873	\N	debora@ddbeautyzone.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.61017	2025-08-06 18:44:30.581853	\N
e0b73bbf-ab8a-4a77-9e22-3ef9000725f9	\N	Francesca	Dea	\N	DEA S.R.L.	Referente	051.732684	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.610978	2025-08-06 18:44:30.581853	\N
13b14756-d674-4492-9768-927ca0bbd197	\N	Nicola	Schena	\N	DNA SPORT CONSULTING SRL	Titolare	328.2134183	\N	nicola.schena@dnasportconsulting.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.611764	2025-08-06 18:44:30.581853	\N
da688028-fe8b-499c-9118-bb4bc61371a8	\N	Alessio	Degasperi	\N	SANTONI'S S.R.L.	Revisore	349.8060065	\N	degasperi@csatn.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.612564	2025-08-06 18:44:30.581853	\N
dac7fc79-1b80-44cb-b993-baf2a3818a59	\N	Giorgio	Appoloni	\N	SANTONI'S S.R.L.	Commercialista	0461.1975610	\N	appoloni@csatn.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.613411	2025-08-06 18:44:30.581853	\N
bf757f4e-9244-446f-9faa-729aa532687d	\N	Vincenzo	Belsito	\N	DOMUS NOSTRA S.R.L.	Titolare	335.7558177	\N	info@domusnostra.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.61428	2025-08-06 18:44:30.581853	\N
19e19863-09b0-4d7c-bcdc-a958967f58ee	\N	Salvatore	Grizzanti	\N	FOODBRAND S.P.A.	Head of Business Development e Innovation	320.9294377	\N	sgrizzanti@doppiomalto.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.615078	2025-08-06 18:44:30.581853	\N
c5d11880-46ab-48a2-9d60-ace0e613a4c5	\N	Paolo	Sarto	\N	DUE SPIGA D'ORO SRL	Referente	335.6602289	\N	amministrazione@sartopasticceria.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.615932	2025-08-06 18:44:30.581853	\N
771dc9ed-9442-46d9-9c62-dc4650dd9f2f	\N	Marco	Bongiorno	\N	E - TEAM DI RIGHINI BRUNO & C. S.A.S.	Referente	0535.47180	\N	commerciale@eteamtecnology.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.616739	2025-08-06 18:44:30.581853	\N
80090135-c7b4-4088-8dc2-43898bcf3f7c	\N	Emanuele	Rinieri	\N	E.R. LUX S.R.L.	Titolare	335.349976	\N	emanuele.rinieri@erlux.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.617585	2025-08-06 18:44:30.581853	\N
31730b4e-a2d5-4301-a930-4b59a9b5ff00	\N	Francesca	Crescenzi	\N	O.M. PES. AMA. S.R.L.	Referente	0445 440390	\N	info@ompesama.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.618444	2025-08-06 18:44:30.581853	\N
a688c686-ca82-41a8-be1c-60eeaf4216b7	\N	Matteo	Mastella	\N	PERNIX S.R.L.	Referente	\N	347 9652165	matteo.mastella@pernix.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.619279	2025-08-06 18:44:30.581853	\N
c962f10c-2fb8-4a79-b219-2db293b95dec	\N	Fabio	Rizzo	\N	ECORISORSE S.R.L.	Amministratore e Legale Rappresentante	349.4339312	\N	hr@ecorisorsesrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.620089	2025-08-06 18:44:30.581853	\N
1aa67de5-66be-42b6-a7b7-5a23d9a770aa	\N	Lorenzo	Berselli	\N	PAYPRINT S.R.L.	Referente	\N	331 3177431	l.berselli@payprint.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.620875	2025-08-06 18:44:30.581853	\N
3a2d3c22-6f00-4d51-8e8c-4e8290208f84	\N	Marco	Palmieri	\N	PAX ITALIA S.R.L.	\N	\N	346 4771723	marco.palmieri@paxitalia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.621656	2025-08-06 18:44:30.581853	\N
ea9ba9ab-3f58-4cbe-81ac-a3ebd014602e	\N	Giovanni	Polimeno	\N	ECOTECNICA *SRL	Referente	349.4339312	\N	hr@ecotecnicalecce.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.62238	2025-08-06 18:44:30.581853	\N
ff015e4f-4ae2-4a99-9939-0abee2e4c41a	\N	Alessandra	Cesari	\N	PATROL VIGILANZA S.R.L.	Referente	\N	338 8702780	a.cesari@patrolvigilanza.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.624799	2025-08-06 18:44:30.625761	\N
ebded5bf-4e84-4215-a778-a554e8a9ce6f	\N	Omar	Salvini	\N	EDILTECK SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	Referente	346.6946555	\N	salvini.omar@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.626476	2025-08-06 18:44:30.625761	\N
896e994d-e200-496b-bf36-4c6e222d46a8	\N	Davide	Rasia	\N	EKOTEAM S.R.L.	Titolare	347.1464992	\N	ambiente@ekoteam.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.627334	2025-08-06 18:44:30.625761	\N
1d016b2f-89f9-476d-8561-637344c1f54d	\N	Elisa	Meconi	\N	ELI.MAR. S.R.L.	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.62815	2025-08-06 18:44:30.625761	\N
4af19f1d-32bc-48a5-b860-22c98f0e7797	\N	Paolo	Lombardo	\N	\N	Revisore	\N	335 8135128	info@studio-lombardo.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.6289	2025-08-06 18:44:30.625761	\N
a0b8ae35-20fd-432b-9edf-d9bdb516a540	\N	Giovanni	Padovan	\N	ELIXEA SRL	Titolare	346.0663166	\N	g.padovan@elixea.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.629778	2025-08-06 18:44:30.625761	\N
daddb8f0-c488-45c9-804a-484ccbe921a7	\N	Lidia	Balboni	\N	ELLE EMME STUDIO S.R.L.	Titolare	348 5267600	\N	l.balboni@lidiabalboni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.630609	2025-08-06 18:44:30.625761	\N
7503ca39-cdef-434b-9857-51b570ee136f	\N	Paolo	Marocco	\N	EN-GAS SRL	Presidente del Consiglio di Amministrazione	393.3312199	\N	paolo.marocco@engas.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.631402	2025-08-06 18:44:30.625761	\N
752c719f-1c0b-4b23-9307-ba05d0a0d295	\N	Claudia	Garino	\N	EN-GAS SRL	Resonsabile ufficio Amministrazione Engas	011.9455757 int213	\N	claudia.garino@alcene.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.633145	2025-08-06 18:44:30.625761	\N
7eaa6f55-056c-4bd1-bf8c-e054a89d1ae7	\N	Giovanni	Candiano	\N	EN-GAS SRL	Responsabile Area Commerciale	329.5388356	\N	giovanni.sandiano@engas.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.633976	2025-08-06 18:44:30.625761	\N
5aa56a5b-247a-4316-9190-b8333c787540	\N	Pierluigi	Faenza	\N	ENJOY SYSTEM SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	Titolare	348.1554074	\N	pierluigi.faenza@enjoysystem.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.634682	2025-08-06 18:44:30.625761	\N
0f08facc-1408-49b8-b9aa-2b57988e06e4	\N	Tommaso	Boner	\N	ENVICON MEDICAL S.R.L.	Titolare	335.1049774	\N	tommaso.boner@envicon.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.635441	2025-08-06 18:44:30.625761	\N
72f61821-3097-47c8-90b7-c831091007ce	\N	Linda	Aldighieri	\N	ENVICON MEDICAL S.R.L.	Referente	348.3717828	\N	amministrazione@envicon.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.636179	2025-08-06 18:44:30.625761	\N
3e741187-b665-476b-aab4-9c230b4015f0	\N	Sebastiano	Scaggiante	\N	EPPINGER CAFFE' S.A.S DI SCAGGIANTE SEBASTIANO	Referente	393.0250969	\N	eppingercaffe.s@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.637108	2025-08-06 18:44:30.625761	\N
419fb835-f799-43a9-82d7-6b5a78d86b5b	\N	Elvira	Erario	\N	ERARIO IMMOBILIARE S.R.L.	Titolare	351.6802588	\N	erarioimmobiliare@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.638157	2025-08-06 18:44:30.625761	\N
7435885b-7329-498c-aba0-644238948ff2	\N	Adolfo	Rinaldi	\N	ERRECI DI RINALDI CARMELO	Titolare	348.2620971	\N	erreciedizionidirinaldi@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.639258	2025-08-06 18:44:30.625761	\N
d821f4d6-a724-4df0-9dc4-16a1aabbf0c4	\N	Annalisa	Borghi	\N	STUDIO BARTOLINI BORGHI DALRIO FARIOLI	Titolare	335.5621929	\N	annalisa.borghi@etikasmart.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.640143	2025-08-06 18:44:30.625761	\N
73b64d1d-87cd-4e23-9012-9e65525a4e29	\N	Andrea	Ballandi	\N	EUROCERT S.P.A.	Titolare	348.7128171	\N	andrea.ballandi@eurocert.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.641175	2025-08-06 18:44:30.625761	\N
17c2dbd4-7d74-45c3-8172-3878e3c94d7b	\N	Luciano	Gasparini	\N	EURODENT SRL	Titolare	340.1220149	\N	gmindsrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.642331	2025-08-06 18:44:30.625761	\N
a440594d-5dbd-4ed2-83ff-7349b55c8e7a	\N	Giusy	Sibilla	\N	ISILAB SRLS UNIPERSONALE	\N	0831 951386	\N	info@isilab.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.64353	2025-08-06 18:44:30.625761	\N
3e2787a4-0bbd-4cf9-8534-5652d3e46ba5	\N	Gabriele	Bianchi	\N	IL MARE DEL GELATO DI DANIELA DE FILIPPO SOCIETA' IN ACCOMANDITA SEMPLICE	\N	\N	\N	392 5672438	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.644662	2025-08-06 18:44:30.625761	\N
51618212-724f-4865-b944-f82c3136d96a	\N	Mosè	Ferrighi	\N	IL PANIFICIO FERRIGHI	Titolare	\N	346 6728541	ilpanificioferrighi@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.645666	2025-08-06 18:44:30.625761	\N
b5d6f6a6-d36a-40b0-a2d0-d7ba0cc2c7a2	\N	Michele	Nanetti	\N	ILCA TARGHE S.R.L.	Referente	051 780013	\N	mnanetti@ilcatarghe.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.646425	2025-08-06 18:44:30.625761	\N
3445644a-d31a-41cd-af34-8668aae19fe0	\N	Pierluigi	Magurno	\N	MAGURNO PIERLUIGI	Titolare	\N	348 5539669	pierluigimagurno@hotmail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.647198	2025-08-06 18:44:30.625761	\N
d52b0922-9aca-45b8-b1f5-3e465840f605	\N	Mariangela	Albanese	\N	ALBANESE MARIANGELA	\N	\N	349 8085650	beauty@immaginestetica.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.647961	2025-08-06 18:44:30.625761	\N
de32f968-4a14-4730-bdbc-91cc751904d4	\N	Alberto	Gava	\N	INFORMATICASERVICE S.R.L.	Partners	043 8402099	\N	alberto@informaticaservice.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.648794	2025-08-06 18:44:30.625761	\N
ac8f98a8-4a00-43c5-a275-c6a61d70ece8	\N	Yuri	Storniolo	\N	ILLUMIA S.P.A.	Agente della Toscana	\N	366 5495250	yuri.storniolo@pwn.illumia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.649713	2025-08-06 18:44:30.625761	\N
159512dd-ea90-4b6c-96d1-3f1b93c16afa	\N	Mauro	Zani	\N	INTEGRA DI ZANI MAURO	\N	\N	333 7747129	mauro.zani@integra.vision	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.650498	2025-08-06 18:44:30.625761	\N
b3145b5f-b4c1-4e2d-89ff-d565dae6bd75	\N	Michela	Panzella	\N	ITA.PRO. S.R.L.	Referente	\N	393 9545869	amministrazione@itapro.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.651377	2025-08-06 18:44:30.625761	\N
2def9e05-4ecb-47d2-88a5-c7aacbc1c85b	\N	Stefano	Stefanelli	\N	ITALCHIM S.R.L.	\N	051 531108	\N	contabilita@italchim.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.652178	2025-08-06 18:44:30.625761	\N
b90f4644-bfbb-4ac8-af6f-2df235a37783	\N	Chiara	Olzi	\N	BLUCHIARA S.R.L.	\N	\N	320 6941689	pubirishtimes@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.653037	2025-08-06 18:44:30.625761	\N
79f352ff-a791-4b80-9844-00bc8090043b	\N	Manuel	Rinaldi	\N	JULIAN	Referente	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.653838	2025-08-06 18:44:30.625761	\N
c9b7da1c-db1d-4728-ab7b-90d67da50e9b	\N	Carlo	Iacone	\N	F.I.S.A.R. - FEDERAZIONE ITALIANA SOMMELIER ALBERGATORI RISTORATO RI ASSOCIAZIONE DI PROMOZIONE SOCIALE	Vice prescindente Fisar	330.350100	\N	carloiacone@hotmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.654653	2025-08-06 18:44:30.625761	\N
df932448-8367-4a74-9099-915de42280cb	\N	Pierfrancesco	Proietto Randazzo	\N	KUWAIT PETROLEUM ITALIA S.P.A.	\N	\N	334 6251384	piproiet@q8.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.655452	2025-08-06 18:44:30.625761	\N
688e5357-42cf-4e6a-9ca5-0d1a564e41d1	\N	Alessandro	Pattaro	\N	KAPACITA SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	Revisore	\N	329 2083894	ila.pattaro@kapacita.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.656177	2025-08-06 18:44:30.625761	\N
152835ea-1410-4091-be42-7aac92d56e75	\N	Miriam	Zaggia	\N	KANBANBOX S.R.L.	\N	388 0647977	\N	miriam.zaggia@kanbanbox.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.657003	2025-08-06 18:44:30.625761	\N
b7b6c096-8bd1-45ee-a8ad-0996b690e342	\N	Andrea	Pegoraro	\N	EL.PA. SERVICE S.R.L.	General Manager	\N	335.7067300	andrea@elpaservice.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.657961	2025-08-06 18:44:30.625761	\N
bff9b9ca-913d-4705-adfe-8b934193ed74	\N	Bruno	Marchesini	\N	KAESER COMPRESSORI - S.R.L.	Referente	\N	392 4328746	marchesinibruno.b@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.658936	2025-08-06 18:44:30.625761	\N
7663cf43-d938-4d11-b109-69fe531cfcd0	\N	Luca	Rogai	\N	K-TEAM S.R.L.	Referente	\N	335 7740398	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.659758	2025-08-06 18:44:30.625761	\N
5fa63452-acb1-4ac7-abe1-d5da29da54b9	\N	Paolo	Provvedi	\N	LA CERTOSA S.R.L.	\N	\N	\N	lacertosasrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.660535	2025-08-06 18:44:30.625761	\N
7ad32729-aaa6-47e1-93dc-75604d193329	\N	Barbara	Zanini	\N	F.A.B. S.R.L.	Referente	348.6974660	\N	info@fabarredamenti.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.661329	2025-08-06 18:44:30.625761	\N
23b7bf25-19c4-4d31-825d-459ac73fb8ac	\N	Marco	Sorci	\N	L & M AUTOMATION S.R.L.	Referente	\N	338 8819761	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.66213	2025-08-06 18:44:30.625761	\N
ed480712-1d30-4ec7-8ab7-7318622a3b92	\N	Simone	Castelli	\N	FAIRSGATE S.R.L.	Referente	347.3420524	\N	s.castelli@fairsgate.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.662917	2025-08-06 18:44:30.625761	\N
84cb30c0-7be9-456b-86f1-bc401bebec89	\N	Katia	Comingio	\N	FAM S.R.L.	Referente	349.3002030	\N	katia.comingio@gommaservice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.663681	2025-08-06 18:44:30.625761	\N
f9bb2eff-34a7-4f2c-a2e1-7bee69d83d85	\N	Adriano	De Luca	\N	FAM S.R.L.	Referente	329.0546820;349.3002030	\N	adriano@gommaservice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.664527	2025-08-06 18:44:30.625761	\N
de2b0064-11ae-4ea3-a378-f468f93f6482	\N	Massimo	Pietralunga	\N	LA LOGGIA RAMBALDI DI PIETRALUNGA UMBERTO  &  C. S.N.C.	Titolare	\N	392.4857999	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.665395	2025-08-06 18:44:30.625761	\N
f77e301f-7780-4d42-8f11-b1da80244da5	\N	Simone	Bertin	\N	LA ORANGE SRL	\N	\N	388 9381769	simone@laorange.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.666306	2025-08-06 18:44:30.625761	\N
3e00d121-65ec-40eb-9c0c-ebc6980d658e	\N	Marco	Schiesaro	\N	LA MAFALDINA S.A.S. DI GIORGIA FAULISI	\N	\N	329 6262905	lamafaldinapizzeria@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.66712	2025-08-06 18:44:30.625761	\N
a82cf8a0-3b89-403f-87c3-f213b66a0e62	\N	Aldo	Alluigi	\N	FARMACIA MAURI DI ALLUIGI ALDO & C. SNC	Titolare	348.2288449	\N	aldoalluigi@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.667894	2025-08-06 18:44:30.625761	\N
04c83849-719b-4e54-ac7d-f95b77272b49	\N	Andrea	Boccardo	\N	FARMACIA MODERNA-VASSALLO DEL DOTT.BOCCARDO	Referente	333.3921990	\N	farmaciamoderna@hotmail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.668708	2025-08-06 18:44:30.625761	\N
edde9e18-f15c-4030-8c08-d544730ebbb1	\N	Antonio	Princi	\N	FARMACIA SAN GIORGIO S.R.L.	Referente	335.8003434	\N	pronto@farmaciasangiorgio.roma.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.671349	2025-08-06 18:44:30.672075	\N
1222f004-d29c-49a1-88e4-afd58dcc21cb	\N	Maria Grazia	Spargoli	\N	FARMACIA SPARGOLI DR. MARIO	Titolare	3474831699	\N	ufficio.spargoli@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.672749	2025-08-06 18:44:30.672075	\N
bdf91b45-5081-43ab-8793-ce2511a4dfe1	\N	Massimo	Di Domenico	\N	ELENA S.A.S. DI BRANDI NICOLAS E C.	Referente	347 2147590	\N	massimo.didomenico0101@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.673548	2025-08-06 18:44:30.672075	\N
1878a78e-a089-43e0-bb81-724ee008551d	\N	Bruno	Neri	\N	FARMACIE NERI S.R.L.	Titolare	335.257608	\N	brunoneri73@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.674297	2025-08-06 18:44:30.672075	\N
1de7e4b1-2a15-4c99-b854-95fb6a64545e	\N	Franca	Tagliapietra	\N	LABRENTA SRL	HR	335 5749483	\N	hr@labrenta.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.675068	2025-08-06 18:44:30.672075	\N
8d4d1522-8c79-47cb-ad45-7ea456464c11	\N	Alessia	Rossi	\N	LE DELIZIE DI ALESSIA DI ALESSIA ROSSI E GIACOMO GRASSI S.N.C.	Titolare	\N	334 7194245	ledeliziedialessia@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.675851	2025-08-06 18:44:30.672075	\N
4697f1c5-ad98-4faa-9e05-8219df2233d8	\N	Giovanna	Braga	\N	4 CIACOLE S.R.L.	Referente	\N	349 4462974	amministrazione@le4ciacole.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.676607	2025-08-06 18:44:30.672075	\N
36b8ccb9-9219-4a99-a085-529c33d2a05d	\N	Alessio	Costa	\N	LC FRUIT S.R.L.	Referente	\N	340 5495366	alessiocosta88@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.677369	2025-08-06 18:44:30.672075	\N
ddcb14ad-2aaa-4c75-a4b8-50eaa4524521	\N	Matteo	Tomasi	\N	LAVANDERIA GIRASOLE SOCIETA' COOPERATIVA	Referente	\N	349 3627761	info@lavanderiagirasole.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.678076	2025-08-06 18:44:30.672075	\N
2849e663-0c45-42c7-8b4f-e5a8821ad7cd	\N	Antonio	Testa	\N	FERROPOL COATING S.R.L.	Referente	345.9807910	\N	antonio.testa@ferropolcoating.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.678795	2025-08-06 18:44:30.672075	\N
edad87fb-2dc3-4cca-aab4-f4356eccee48	\N	Andrea	Guglielmi	\N	FLYTECH SRL	Amministratore	348.7307204	\N	andrea.guglielmi@flytech.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.679586	2025-08-06 18:44:30.672075	\N
6bf120ae-d9b9-4f56-a3af-84325ef98197	\N	Stefano	Zangani	\N	FOR J S.R.L.	Referente	335 1090854	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.680324	2025-08-06 18:44:30.672075	\N
7cc06fd3-8eb3-4017-93fd-af9ff428a957	\N	Marco	Pizzimenti	\N	FOR J S.R.L.	Referente	347.0404854	\N	m.pizzimenti@forj.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.681063	2025-08-06 18:44:30.672075	\N
3fba07d3-71b0-48d6-a76d-1bfd34c1bd2a	\N	Andrea	Canteri	\N	FRAC S.R.L.	Titolare	348.3146683	\N	ptezza@frac1948.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.681864	2025-08-06 18:44:30.672075	\N
700a8be7-46b0-4590-b9fb-10701cf75430	\N	Elisabetta	Migliorini	\N	FRAME ABOUT YOU - S.N.C. DI FRANCESCO ASARA & C.	Referente	3351755398	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.682603	2025-08-06 18:44:30.672075	\N
6140555b-f269-42a0-bf03-fa935e3034c2	\N	Stefano	Lovato	\N	F.LLI LOVATO S.R.L.	Titolare	328.87037500	\N	stefano.lovato@fratellilovato.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.683333	2025-08-06 18:44:30.672075	\N
c14e3a53-442d-4c72-9206-5f7664e06ef0	\N	Giovanni	Frigomar	\N	FRIGOMAR S.R.L.	Referente	344.1935733	\N	filippifrigomar@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.684091	2025-08-06 18:44:30.672075	\N
9f6e6332-aa64-4f2b-8e34-a129b128a6d4	\N	Filippo	Zago	\N	\N	Referente	346.6257701	\N	funfactory@funfactorymode.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.684847	2025-08-06 18:44:30.672075	\N
ae554aa7-611c-456b-aa11-f2885538195a	\N	Paola	Ciucci	\N	G.E.MA.R.C. DI BAGLIONI GIOVANNI E C. S.N.C.	Referente	345.2596722	\N	baglionigemarc@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.685606	2025-08-06 18:44:30.672075	\N
87bcaabe-e08d-43af-ac54-2d72efd74382	\N	Elisa	Leoni	\N	LEEUS CONSULTING SRL	\N	\N	328 5587801	e.leoni@leeusconsulting.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.68639	2025-08-06 18:44:30.672075	\N
0399cdc9-0478-49a5-b1cc-a728f087855c	\N	Ermanno	Pozzler	\N	LEGNOSTILE DEI FRATELLI PLOZZER S.N.C. DI PLOZZER DANILO, ERMANNO E DARIO	Titolare	\N	388 6023740	info@legnostileplozzer.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.687204	2025-08-06 18:44:30.672075	\N
ae840e35-755c-4406-8f00-892bb400bea6	\N	Beatrice	Cesarano	\N	AUGUSTA RATIO S.P.A.	Referente	02 83593270	366 3020239	beatrice.cesarano@augustaratio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.687941	2025-08-06 18:44:30.672075	\N
73020aab-2aea-45ae-ab23-e1b52db78849	\N	Monica	Leodari	\N	LEODARI PUBBLICITA' S.R.L.	Titolare	0444 962233	\N	lmonica@leodari.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.688718	2025-08-06 18:44:30.672075	\N
68b442e3-dc2b-4f68-980d-1ff5efd52334	\N	Anna	Gemmo	\N	GEMMO METALSIDER S.R.L.	Titolare	0444.760552	\N	info@gemmometalsider.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.689475	2025-08-06 18:44:30.672075	\N
c5d30f7f-d9b8-4dc8-b488-f3301cf6b8b0	\N	Giuseppe	Giannone	\N	GENERAL INTERIORS S.R.L.	Titolare	393.9308905	\N	g.giannone@generalinteriors.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.690283	2025-08-06 18:44:30.672075	\N
001bfeba-5ba0-4626-bcae-b8482da2c10d	\N	Michele	Bertuzzi	\N	GEO HYDRICA S.R.L.	Referente	045.9582423	\N	michele@venber.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.69108	2025-08-06 18:44:30.672075	\N
c5bcdcb2-6a96-4e65-a808-67e638e1ca19	\N	Vincenzo	Gugliotta	\N	GERICA S.R.L.	Referente	338 5076519	\N	v.gugliotta@gerica.org	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.691983	2025-08-06 18:44:30.672075	\N
b21edce2-a91b-4fc4-b666-8916a2331dc2	\N	Silvia	Roveda	\N	G.E.R.S. S.R.L.	Referente	338.3681866	\N	silvia.roveda@gers.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.692916	2025-08-06 18:44:30.672075	\N
90c50057-db91-43bf-b04a-c4c201ae3516	\N	Gianluca	Baldazzi	\N	TIPOGRAFIA A.G. DI BALDAZZI GIAN LUCA & C. S.N.C.	Titolare	051768664	\N	gianluca@tipografia.ag.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.693692	2025-08-06 18:44:30.672075	\N
f5cdce97-11ba-4c21-b1e9-b31a312a7295	\N	Alfredo	Formisano	\N	GLOBAL SERVICE CAR S.R.L.	Responsabile Commerciale XMaster School	393.1418558	\N	a.formisano@ggroup.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.694491	2025-08-06 18:44:30.672075	\N
d98a6bca-cd85-4519-90fe-dc81b7956712	\N	Matteo	Zantomio	\N	GLOBAL SOLAR S.R.L.	Referente	347.0018963	\N	matteo@globalsolar.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.695272	2025-08-06 18:44:30.672075	\N
22231cde-1a1c-4a89-83b8-351d2ac80693	\N	Marco	Gavanelli	\N	GM - GAVANELLI BROKER S.R.L.	Titolare	348.8049755	\N	m.gavanelli@gavanellibroker.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.696211	2025-08-06 18:44:30.672075	\N
be5da9a4-371d-44a7-8b47-edc4a1de46ef	\N	Giacomo	Mitrotti	\N	GM LAB SRL	Titolare	334 3321002	\N	giacomomitrotti@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.697033	2025-08-06 18:44:30.672075	\N
257985cc-cd0b-4fce-961c-d2544e9bd7a3	\N	Daniela	De Benedetti	\N	LASER MECCANICA SRL	\N	\N	334 3636792	amministrazione@lasermeccanica.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.69786	2025-08-06 18:44:30.672075	\N
e538dbba-f5a5-4d2f-8d13-439ef83fb4bf	\N	Rudi	Dalpiaz	\N	GRAFICHE DALPIAZ S.R.L.	Titolare	0461.913545	\N	rudi@grafichedalpiaz.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.698643	2025-08-06 18:44:30.672075	\N
590bae33-aef2-4cde-ac4e-3d2d3e4d83ce	\N	Patrizia	Conti	\N	LANZI S.R.L.	\N	0141 954541	\N	amministrazione@lanzi.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.699425	2025-08-06 18:44:30.672075	\N
5a8aa48b-dd9c-431c-ab41-45507ddb4399	\N	Maurizio	Mitri	\N	ALI GROUP HOLDING S.R.L.	\N	\N	335 219959	maurizio.mitri@lainox.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.700233	2025-08-06 18:44:30.672075	\N
9fc9540e-8c51-40f2-ab99-e581c1ebfd41	\N	Alessandra	Chiari	\N	G.M.T. S.P.A.	\N	\N	\N	chiari@gmtspa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.701074	2025-08-06 18:44:30.672075	\N
971e4040-7377-42ff-bf4c-67b6f1abcb35	\N	Ezio	Del Giudice	\N	EZDIRECT S.R.L.	Titolare	\N	329 4404515	ezio.delgiudice@ezdirect.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.701952	2025-08-06 18:44:30.672075	\N
64071200-237b-4a92-a65b-c2aec71a2bbf	\N	Valentina	Sala	\N	GROUPAUTO ITALIA S .C. A R. L.	Procurement Specialist	02.26950207	\N	v.sala@groupauto.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.702709	2025-08-06 18:44:30.672075	\N
cf6ddd68-c9f7-4b71-8e43-b66956f8d9b9	\N	Franco	Cordano	\N	\N	Partner	\N	335 6366317	franco.cordano@dscsrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.703495	2025-08-06 18:44:30.672075	\N
1db14b8f-b2a5-43a4-9932-759ddf15a723	\N	Massimo	Ciaglia	\N	GROWNNECTIA S.R.L.	Titolare	348 156 3540	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.704317	2025-08-06 18:44:30.672075	\N
577d36c9-567f-464f-a714-c3d31ec1332b	\N	Brian	Razzi	\N	GROWNET SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	Founder e account manager	392.1589760	\N	brian.razzi@grownet.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.705177	2025-08-06 18:44:30.672075	\N
93afefb0-becd-4ec9-9f44-342e208c815b	\N	Simona	Marchesini	\N	GRUPPO CIEMME SOCIETA' A RESPONSABILITA' LIMITATA	Technical and Sales Manager	351.0864380	\N	smarchesini@gruppociemme.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.706033	2025-08-06 18:44:30.672075	\N
adea2530-3ced-48ac-a884-a7eb72157726	\N	Marco	Sartori	\N	DSG AUTOMATION S.R.L.	Commerciale	\N	388.1271483	marco.sartori@dicircle.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.70683	2025-08-06 18:44:30.672075	\N
0e4e4fcc-bba1-4ba5-b364-5e717b38ce97	\N	Marco	Morelli	\N	O.E.M.A. DI MORELLI MARCO & C. -  S.N.C.	Titolare	0543.751203	\N	amministrazione@oema.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.707679	2025-08-06 18:44:30.672075	\N
2d60e45f-06fc-4384-be47-b92f211834d3	\N	Samira	Gruber	\N	GUESTNET S.R.L.	Referente	0472.940966	\N	s.gruber@guest.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.708458	2025-08-06 18:44:30.672075	\N
1babe3f8-74fe-443f-9dac-aff831ff4429	\N	Michela	Ferretti	\N	GRUPPO VILLA MARIA S.P.A  O ANCHE  G.V.M. S.P.A.	Referente	\N	\N	mferretti@gvmnet.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.709258	2025-08-06 18:44:30.672075	\N
d228ab13-6810-4a77-90f2-532fd86be628	\N	Oriano	Gemignani	\N	LOKALL DI GEMIGNANI ORIANO E C. - S.N.C.	Referente	335.6109225	\N	lokall@lokall.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.710091	2025-08-06 18:44:30.672075	\N
7936cdc7-0d18-43db-ab06-8f6b60b0c6a6	\N	Silvia	Piccolo	\N	LUBROMEC S.R.L.	Titolare	335.8175391	\N	silvia.piccolo@levaspa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.710868	2025-08-06 18:44:30.672075	\N
93032219-f08e-4a34-8524-fe930558ff10	\N	Lino	Perron	\N	LINO PERRON	Titolare	339.1532023; 366.4100243	\N	linosbar@yahoo.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.71319	2025-08-06 18:44:30.713898	\N
3d84930b-37c2-4491-9d65-327657c03de1	\N	Andrea	Peschiulli	\N	MAGNA GRECIA SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	Referente	393.2912005	\N	andreapeschiulli@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.71453	2025-08-06 18:44:30.713898	\N
142b3c50-7e57-48d5-8bf9-b07b7b0c48df	\N	Elisabetta	Mangoni	\N	MAIL DATE BUREAU S.R.L.	Referente	340.4943911	\N	e.mangoni@maildatebureau.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.715278	2025-08-06 18:44:30.713898	\N
29cb1971-6d9a-477c-876f-fab9e28812fc	\N	Raimondo	Di Sciacca Magneti Marelli	\N	MARELLI AFTERMARKET ITALY S.P.A.	Referente	335 198 8570	\N	raimondo.disciacca@marelli.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.716039	2025-08-06 18:44:30.713898	\N
c225b027-ee2c-46b7-a154-9381d3cf5b16	\N	Marco	Vita	\N	MARCO VITA ASSICURAZIONI S.R.L.	Titolare	348.6827506	\N	marcovitaassicurazioni@yahoo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.71675	2025-08-06 18:44:30.713898	\N
cb335664-d0f6-474d-bcc4-15398375b586	\N	Gabriele	Marcozzi	\N	MARCOZZI S.R.L.	Referente	320.1119834	\N	amministrazione.anticapasta@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.717541	2025-08-06 18:44:30.713898	\N
0656bbfb-3b8c-48b4-b06e-f1b3b519c4cc	\N	Giorgio	Paiola	\N	MARMI LANZA SRL	Responsabile Amministrativo	045.6836054	\N	amministrazione@marmilanzasrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.718293	2025-08-06 18:44:30.713898	\N
dfa762aa-e9d4-4485-9b84-ca20c12d7433	\N	Elia	Graziano	\N	GRAZIANO S.R.L.	Titolare	\N	349 1268778	eliagraziano@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.719033	2025-08-06 18:44:30.713898	\N
9945a727-34df-424d-8bde-bf781e9786a8	\N	Massimo	Schiassi	\N	MARMOFORNITURE GIORGI CARLO DI SCHIASSI ANDREA, ORSI DANIELE E SCHIASSI MASSIMO S.N.C.	Titolare	329.6148785	\N	andrea@marmoforniture.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.719727	2025-08-06 18:44:30.713898	\N
483402dd-b6ad-41bf-a212-2c73d48473a3	\N	Federico	Chigbugh Gasparini	\N	MARSHYELLOW S.R.L.	Referente	392.9783724	\N	gasfe2@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.720481	2025-08-06 18:44:30.713898	\N
99e06d45-8cfc-4cdb-9327-de18a04c9421	\N	Paolo	Mascellani	\N	MASCELLANI S.R.L.	Titolare	348.253.0202	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.721219	2025-08-06 18:44:30.713898	\N
84d240f5-5e7d-421c-ba3d-3bd54c059951	\N	Mario	Maselli	\N	MASELLI MISURE S.P.A.	Titolare	0521.257411	\N	mariomaselli@maselli.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.721966	2025-08-06 18:44:30.713898	\N
09a54a72-5142-4d04-a789-bb930ac72812	\N	Andrea	Masi	\N	MASI GLASS SRL	Titolare	327.1506777	\N	masiglass@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.722712	2025-08-06 18:44:30.713898	\N
41dbb312-a23b-4d19-8ce7-8a38d786e6cc	\N	Elisabetta	Brusori	\N	MASSIMO S.R.L.	Referente	334.5646614	\N	info@cartabiancacafe.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.723464	2025-08-06 18:44:30.713898	\N
1991607e-85b0-41ba-8b28-91e3b3ce13f3	\N	Gianluca	Mastroianni	\N	'MAST INDUSTRIA ITALIANA SRL''	Referente	328.6638104	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.724244	2025-08-06 18:44:30.713898	\N
03c7fb32-60e5-43d8-bfa3-c4faa81c615c	\N	Andrea	Salvatori	\N	MEGASTORE SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	Referente	349 3784495	\N	andrea.salvatori@computerdiscover.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.724985	2025-08-06 18:44:30.713898	\N
3f35846b-0f56-4f59-8b70-5c0f3eff9435	\N	Alessandro	Minghetti	\N	METALTARGHE-SOCIETA A RESPONSABILITA LIMITATA	Titolare	051.776052	\N	amministrazione@metaltarghe.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.725752	2025-08-06 18:44:30.713898	\N
3c782e2f-dd14-4222-bc38-ed23ff6db25b	\N	Alberto	Biavati	\N	MFM S.R.L.	Glass Containers Technology Expert	329.6515863	\N	alberto.biavati@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.726516	2025-08-06 18:44:30.713898	\N
1298b477-c961-4675-b75c-e21e1f1f5416	\N	Elisa	Gentili	\N	MODULGRAFICA FORLIVESE S.P.A.	Referente	0543.720596	\N	info@modulforlivese.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.727299	2025-08-06 18:44:30.713898	\N
9af7fa5c-8fc6-4c3a-ae15-d1bee5a2f967	\N	Gianluca	Oddolini	\N	MODULO SEI S.R.L.	Agente	335.8380623	\N	gianluca.oddolini@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.72803	2025-08-06 18:44:30.713898	\N
cd731cdb-06bf-4ea0-8e53-7cbb95fd0016	\N	Davide	Esposito	\N	MONTEFARMACO OTC S.P.A.	Responsabile	\N	\N	davide_esposito@montefarmaco.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.728741	2025-08-06 18:44:30.713898	\N
8277eea5-64c0-4855-a697-13cde39cc105	\N	Paolo	Borsani	\N	MONTEFARMACO OTC S.P.A.	Responsabile HR	\N	\N	paolo_borsani@montefarmaco.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.729515	2025-08-06 18:44:30.713898	\N
4525b56b-daba-4442-a306-65608b1308db	\N	Elisabetta	Brusori	\N	MORANDI S.R.L.	Referente	334.5646614	\N	elisabettabrusori@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.730236	2025-08-06 18:44:30.713898	\N
8a0c6332-c27d-415b-a92a-e1a30f3721ad	\N	Giuseppe	Betti	\N	MOVENDO TECHNOLOGY SOCIETA' A RESPONSABILITA' LIMITATA IN FORMA ABBREVIATA MOVENDO TECHNOLOGY S.R.L.	Titolare	010.0995700	\N	giuseppe.betti@movendo.technology	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.731008	2025-08-06 18:44:30.713898	\N
6891f053-3a80-4691-8e32-e2d2ae32e4e0	\N	Fabio	Torreggiani	\N	MTS ONLINE GMBH	Referente	0472.694229	\N	ft@mts-online.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.731886	2025-08-06 18:44:30.713898	\N
a6ca0006-b9da-4e3e-85b8-7e4e03bd969e	\N	Lorenzo	Bucci	\N	M.V. S.R.L.	Collaboratore esterno	334.9973655	\N	info@lorenzobucci.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.7332	2025-08-06 18:44:30.713898	\N
e4218e86-8d50-4775-97c4-6d60145feb73	\N	Mirco	Mengozzi	\N	N.C. AUTO S.R.L.	Titolare	346.0115590	\N	centroserviziauto@ncauto.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.73406	2025-08-06 18:44:30.713898	\N
5631cc75-bb1b-4461-a9b8-8de20fbba6d2	\N	Leonardo	Moretti	\N	WSM S.R.L.	Referente	02.50020500	\N	l.guagenti@negrifirman.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.735041	2025-08-06 18:44:30.713898	\N
0a0fbcbc-9e24-4bfc-8900-7df9e6c855d6	\N	Guido	Nelli	\N	\N	Titolare	338.6955592	\N	guido.nelli@nelli1956.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.735917	2025-08-06 18:44:30.713898	\N
ba6e93eb-9ebe-45b6-9876-541be8176fde	\N	Luciano	De Franco	\N	PARADIGMA SOCIETA' COOPERATIVA	Titolare	\N	328 4819721	luciano.defranco@paradigma.me	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.736855	2025-08-06 18:44:30.713898	\N
2ead808a-07e4-454b-9c34-a3b88311e273	\N	Luciano	De Franco	\N	PARADIGMA S.P.A.	Titolare	\N	328 4819721	finance@paradigma.me	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.737759	2025-08-06 18:44:30.713898	\N
6effb3bc-7bd4-43fe-9db2-ce5b33850161	\N	Maurizio	Di Domenico	\N	PLAYHOTEL S.R.L.	Titolare	\N	328 7968322	m.didomenico@playhotelnext.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.738649	2025-08-06 18:44:30.713898	\N
2f75afb8-0c68-4e69-94c7-137ebb7a276e	\N	Sabina	Scarchilli	\N	NEW MIND S.R.L. IN LIQUIDAZIONE	Referente	3490895952	\N	sabina.scarchilli@new-mind.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.739543	2025-08-06 18:44:30.713898	\N
bb8c1405-1b82-4917-9106-9c75c4494a03	\N	Giuseppe Nicola	Isgrò	\N	HEXADRIVE ENGINEERING SRL	Growth Manager	334.1869011	\N	giuni@newtwen.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.74048	2025-08-06 18:44:30.713898	\N
dbd04b4c-c22d-436e-80cd-d4a8dbcdee48	\N	Marco	Squazoni	\N	NICO.FER  S.R.L.	Commercialista	045. 8104214	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.741405	2025-08-06 18:44:30.713898	\N
a2550ea8-416c-47fa-bf5b-5449274ca8a5	\N	Michele	Lavezzari	\N	NICO.FER  S.R.L.	Consulente del lavoro	045. 575277	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.742305	2025-08-06 18:44:30.713898	\N
57328184-eff7-42a6-affa-1ac77b9d4e81	\N	Alberto	Nicolis	\N	NICO.FER  S.R.L.	Responsabile	348.3861922	\N	alberto@nicofer.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.743148	2025-08-06 18:44:30.713898	\N
6e603054-a9b7-40b0-9380-fc8bc0dad330	\N	Michele	Ferrulli	\N	NOVAENERGY S.R.L.	Referente	345.1025683	\N	michele.ferrulli@nova-energy.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.743998	2025-08-06 18:44:30.713898	\N
09335eda-7e4d-4963-af25-29421b6085d2	\N	Lorenzo	Cappiello	\N	NOVAENERGY S.R.L.	Referente	338.9757161	\N	cappiello@nova-energy.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.74478	2025-08-06 18:44:30.713898	\N
ab9a101c-959e-469f-9fe9-e55949cc33d1	\N	Sergio	Martini	\N	NOVAMAR S.N.C. DI MARTINI SERGIO E C.	Referente	347.4350367	\N	amministrazione@novamar.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.745661	2025-08-06 18:44:30.713898	\N
3c6b45c9-c4c0-45ea-8cbd-52ad8c822325	\N	Mauro	Cortinovis	\N	OMCN S.P.A.	Referente	035.4234411	\N	info@omcn.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.746488	2025-08-06 18:44:30.713898	\N
4d0873b5-31bf-4576-a832-e18e92c4ffe6	\N	Alessia	Grandis	\N	OPEN SERVICE S.R.L.	CEO	392.9592577	\N	a.grandis@openservicevr.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.747355	2025-08-06 18:44:30.713898	\N
db623c4a-3b3d-4002-8e30-d0648b4a8d2b	\N	Federica	Mori	\N	OPEN SERVICE S.R.L.	Referente	339.3215919	\N	f.mori@openservicevr.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.748189	2025-08-06 18:44:30.713898	\N
b3e452dc-d282-4514-bea8-8494cf010e51	\N	Silvia	Busatto	\N	ORTECO - S.R.L.	Impiegata	051.731051	\N	silvia.busatto@orteco.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.749036	2025-08-06 18:44:30.713898	\N
908904ff-e16f-4dad-8a9f-c19cd6b26d3c	\N	Marco	Minarelli	\N	OPEN SOURCE MANAGEMENT S.R.L. IN BREVE OSM S.R.L.	Referente	348.3599450	\N	m.minarelli@osmpartnerferrara.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.749889	2025-08-06 18:44:30.713898	\N
febda148-2dcd-4100-b81c-6cda996c7f3d	\N	Alice	Tosi Brandi	\N	CASA DI CURA PRIVATA PROF. E.MONTANARI S.P.A.	Referente	0541.988129 int. 419	\N	formazione@casadicuramontanari.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.750738	2025-08-06 18:44:30.713898	\N
9043f8bb-c0d4-49db-8830-a54607f16614	\N	Michele	Venturelli	\N	OSTERIA PERBACCO S.N.C. DI VENTURELLI MICHELE & C.	Titolare	348.981 3974	\N	osteriaperbaccovr@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.75161	2025-08-06 18:44:30.713898	\N
6450a649-dfaa-4dbe-b5b7-e94605f61963	\N	Cinzia	Panzolato	\N	OTTO SERVICE DI MENICI OTTORINO	Event coordinator	340.7110876	\N	eventi@ottoservice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.752379	2025-08-06 18:44:30.713898	\N
699a2248-6990-40ed-b176-2aa75b1c4971	\N	Gian Piero	Villella	\N	RADIO WELLNESS NETWORK S.R.L.	Direttore della Segreteria Commerciale	049.5207416	\N	segreteria@radiowellness.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.753193	2025-08-06 18:44:30.713898	\N
c335dd1a-039a-4c27-b96e-8774fcbf83f5	\N	Alessandro	Ramorino	\N	ADVERTISING RAMORINO ALESSANDRO	Titolare	339.5302726	\N	info@ramorinoadvertising.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.753973	2025-08-06 18:44:30.713898	\N
3c4866ab-cb9c-4146-a33e-31fa2fbc40cf	\N	Gabriele	Camezzana	\N	U' PESCOU S.R.L.	Titolare	328.7964058	\N	gabriele.camezzana@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.404324	2025-08-06 18:45:38.402938	\N
d4994371-54d8-4aa0-985e-d3d462509fbf	\N	Paolo	Bellolio	\N	U' PESCOU S.R.L.	Commercialista	346.7879710	\N	paolobellolio@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.408969	2025-08-06 18:45:38.407691	\N
3c6a1e8b-0e76-4e50-b795-03a4d10e23e5	\N	Daniele	Giro	\N	\N	\N	\N	335.8391861	giro.daniele@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.412948	2025-08-06 18:45:38.412252	\N
f66a5ffe-de1f-421c-ba02-a0cce87c73d2	\N	Antonella	Pagotto	\N	D4I SRL	Accounting	041.5150998	\N	antonella.pagotto@dsg.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.095098	2025-08-06 18:45:39.094153	\N
6e7b6b58-e0ae-42e0-a1ad-0022fa476f39	\N	Giuseppe	La Rocca	\N	\N	Titolare	329.4211199	\N	giuseppe.larocca@studiofarinalarocca.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.8075	2025-08-06 18:44:30.808144	\N
71255210-c5ea-4fd7-b687-1451a9ccf66d	\N	Laura	Fasoli	\N	STUDIO CAVAGGIONI SOCIETA' CONSORTILE A RESPONSABILITA' LIMITATA	Referente	339.1333986	\N	laura.fasoli@studiocavaggioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.808868	2025-08-06 18:44:30.808144	\N
8340f43f-13c8-4538-ac99-6aec87db6f32	\N	Sandro	Giobbi	\N	FISIOPRO S.R.L.	Titolare	\N	347 3995590	sandrogiobbi@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.809617	2025-08-06 18:44:30.808144	\N
6b99baba-e1ca-4b08-bba4-35e157bce01a	\N	Licia	Monari	\N	STUDIO CRABILLI & MONARI S.R.L.	Referente	335.7143435	\N	licia.monari@studiomonari.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.810322	2025-08-06 18:44:30.808144	\N
3f862700-60e1-4657-8c3c-86ddc8f9f21b	\N	Alessandra	Bulla	\N	L'UNIONE SARDA S.P.A.	\N	070 60131	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.811068	2025-08-06 18:44:30.808144	\N
22bd5698-50a4-45cb-8c28-f36eefc05951	\N	Federico	Ghinato	\N	GHINATO & ASSOCIATI	Commercialista Revisore	347.2336940	\N	federico.ghinato@studioghinato.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.811982	2025-08-06 18:44:30.808144	\N
83141085-c7f6-47a4-88bb-0337adc54017	\N	Luca	Mazzoni	\N	STUDIO ASSOCIATO MAZZONI & PARTNERS	Commercialista Revisore	051.405207	\N	luca.mazzoni@studio-mazzoni.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.812776	2025-08-06 18:44:30.808144	\N
f352a71e-c4b1-4060-ab2e-ca1c55dcd9c4	\N	Davide	Faraci	\N	UNIDEA SRL	Referente	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.813612	2025-08-06 18:44:30.808144	\N
3677a1c0-cee4-4d1c-b2ae-b81752ebcb40	\N	Agostino	Cicalò	\N	FELIX HOTELS S.R.L.	Titolare e Presidente Confcommercio Nuoro	\N	337 818144	agostino.cicalo@felixhotels.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.814378	2025-08-06 18:44:30.808144	\N
6f5c9bbd-1412-4660-b114-470a05a698e4	\N	Cristina	Turetta	\N	NECCHIO ALESSANDRO	Referente	049.8056445	\N	cristina@studionecchio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.815184	2025-08-06 18:44:30.808144	\N
7879bb8f-58e0-43ae-bca9-abed8cf9d6bd	\N	Alberto	Pitroni	\N	STUDIO PRITONI	Referente	349.4202776	\N	dr.a.pritoni@studiopritoni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.815962	2025-08-06 18:44:30.808144	\N
1bec77f7-cf2c-422e-809a-d646ab27f00d	\N	Armando	Roncher	\N	SEDIGIT SRL	Titolare	347.1004953	\N	armando.roncher@sedigit.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.816827	2025-08-06 18:44:30.808144	\N
ccc124ad-b0b8-48ba-9abb-d56b35a70bd8	\N	Loris	Tiso	\N	STYLPLEX SRL	\N	348.4407497	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.817565	2025-08-06 18:44:30.808144	\N
fa81ae78-490a-4a89-afd6-3f8c5cf3d47e	\N	Ivano	D'Ortenzi	\N	SUSHIDB SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	\N	333.3505068	\N	info@sushidb.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.818363	2025-08-06 18:44:30.808144	\N
826d4c4d-1e51-4a9f-a818-a6ba8037f3ae	\N	Emanuele	Sartore	\N	SWP SRL	\N	347.6150548	\N	es@swpsrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.819123	2025-08-06 18:44:30.808144	\N
31ed78e7-5621-4948-aafc-69db3faa5c10	\N	Fabio	Vanzelli	\N	SYNERGY SYSTEM SRL	\N	\N	347.3078140	f.vanzelli@synergysystem.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.819891	2025-08-06 18:44:30.808144	\N
f008e1b7-4a59-43d9-abef-f3b23a50438d	\N	Marco	Sala	\N	VALBIA S.R.L.	\N	030 8969411	\N	msala@valbia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.820677	2025-08-06 18:44:30.808144	\N
75b66b4e-9dd6-415a-bdad-ab266dd16a51	\N	Nerino	Martinaggia	\N	T.P.A. IMPEX S.P.A.	\N	\N	348.7384523	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.821495	2025-08-06 18:44:30.808144	\N
48dc652e-8922-47d4-8a04-968f237e0d3a	\N	Nicola	Amoretti	\N	T.P.A. IMPEX S.P.A.	\N	335.5222436	\N	nicola.amoretti@tpaimpex.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.822299	2025-08-06 18:44:30.808144	\N
fc9ff6a6-88d4-4183-8a3e-d6b255171dc1	\N	Roberto	De Luca	\N	STAZIONE DI SERVIZIO DI DE LUCA VINCENZO & C. S.N.C.	Titolare	349.6856744	\N	robydeluca1989@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.823061	2025-08-06 18:44:30.808144	\N
6ff8d5e3-52fa-475a-a6c6-f4e764dd706b	\N	Alberto	Cortese	\N	VALBRENTA SUOLE SRL IN LIQUIDAZIONE	\N	\N	348 2287925	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.823798	2025-08-06 18:44:30.808144	\N
a0a39791-29e3-41af-b8bd-fa1e43832e54	\N	Michela	Bruni	\N	\N	Referente UnipolSai	\N	340 4665433	michela@bruniassicurazioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.824612	2025-08-06 18:44:30.808144	\N
d7e79a95-95d9-4a31-b1e8-d1bd1eed6f7d	\N	Marco	Bertelli	\N	TEAM DUEMILA S.R.L.	Referente	348.9004901	\N	lm.bertelli@teamduemila.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.825417	2025-08-06 18:44:30.808144	\N
9a2d6bf2-e0b4-40a5-b672-6e4ab06dfbbc	\N	Massimo	Ramina	\N	TECNERGA S.R.L.	Referente	345.2367785	\N	massimo.ramina@tecnerga.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.826207	2025-08-06 18:44:30.808144	\N
e5736de0-c8a0-47e4-ad3c-62c28fcf1666	\N	Veronica	Barbiero	\N	TECNERGA S.R.L.	Referente	345.7984132	\N	veronica.barbiero@tecnerga.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.827024	2025-08-06 18:44:30.808144	\N
15ac0bd9-3671-46d7-b1f0-dd37913c5f2d	\N	Savino	Bof	\N	TECNOSYSTEM RETAIL S.R.L.	Referente	328.7050750	\N	info@tecnosystemretail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.827787	2025-08-06 18:44:30.808144	\N
2929acbe-7223-4481-b228-4718ad14cd99	\N	Giuseppe	Franchini	\N	TECNOVAP S.R.L.	Referente	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.828559	2025-08-06 18:44:30.808144	\N
6a77939e-c790-4e36-879a-c82c8b80b475	\N	Igino	Mortari	\N	TECNOVATION S.A.S. DI MORTARI IGINO & C.	Referente	\N	348.0319659	igino.mortari@tecnovation.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.829333	2025-08-06 18:44:30.808144	\N
72fcf0fb-5408-4f7f-81c3-0cf8df68a060	\N	Alessandra	Balbinot	\N	L'IMMOBILIARE S.R.L.	\N	+393482402013	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.8301	2025-08-06 18:44:30.808144	\N
c7744ea9-d638-4ecb-ac7f-1e3037ca902e	\N	Lorenzo	Pellino	\N	TESTI GROUP SRL	Referente	345.8555035	\N	lorenzo@testigroup.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.830914	2025-08-06 18:44:30.808144	\N
53ccff30-1dca-4afd-b559-2cf426fc7477	\N	Federica	Raneri	\N	THINKIN S.R.L.	Referente	347.3396605	\N	federica.raneri@thinkin.io	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.831757	2025-08-06 18:44:30.808144	\N
08c41096-7ab3-4873-a531-adcbaf0e78cd	\N	Alessandro	Pege	\N	VENETA COMPONENTI SRL	Referente	\N	392 0988883	alessandro@venetacomponenti.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.832597	2025-08-06 18:44:30.808144	\N
0fce8d9e-d7e4-404b-a97a-71c24f0bccfb	\N	Fabio	Malfarà	\N	\N	\N	\N	335 7563187	f.m@ventures-bridge.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.833581	2025-08-06 18:44:30.808144	\N
c3c44836-17ea-4565-93d0-e6e7fd57d8af	\N	Tommaso	Zoccarato	\N	VEYAL SRL	\N	049 8076551	\N	amministrazione@veyal.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.834431	2025-08-06 18:44:30.808144	\N
b1230cd5-3a97-4167-80d5-7b4d1313463b	\N	Fabio	Torchia	\N	TORINO FOOTBALL CLUB S.P.A. O, IN FORMA ABBREVIATA, TORINO F.C. S.P.A.	referente	\N	\N	f.torchia@torinofc.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.83526	2025-08-06 18:44:30.808144	\N
8b32c8d1-5f59-4f99-b6a0-ccdbb5803881	\N	Luca	Boccone	\N	\N	\N	\N	\N	l.boccone@torinofc.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.836066	2025-08-06 18:44:30.808144	\N
93ae1877-ef8d-42ef-8514-475bd4f7c9ef	\N	Luca	Boccone	\N	TORINO FOOTBALL CLUB S.P.A. O, IN FORMA ABBREVIATA, TORINO F.C. S.P.A.	\N	\N	\N	l.boccone@torinofc.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.836846	2025-08-06 18:44:30.808144	\N
2af1792e-0939-47f4-a018-574033932876	\N	Naddi	Bugatti	\N	TORREFAZIONE ARTIGIANALE DI BUGATTI N. & C. SAS	\N	327.5991516	\N	info.torrefazionenaddi@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.837644	2025-08-06 18:44:30.808144	\N
b4925845-1220-45b4-98ff-7db02482b503	\N	Antonio	Carelli	\N	TRAMEC S.R.L.	\N	051.728935	\N	tramec@tramec.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.838361	2025-08-06 18:44:30.808144	\N
c7a14842-116f-4bf2-a415-e8ac05365b2e	\N	Federico	De Rossi	\N	TRASMINET S.A.S. DI DE ROSSI FEDERICO E DAMIANO E C.	\N	045.8905050	393.9114486	federico@trasminet.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.839078	2025-08-06 18:44:30.808144	\N
d01422c6-aa14-463e-9861-c0b7dea1fdcf	\N	Cristiano	Mavroidis	\N	VERO SAPORE GRECO DUOMO S.R.L.	\N	\N	348 0907205	verosaporegrecosrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.839846	2025-08-06 18:44:30.808144	\N
075fa7e4-c7a2-49f9-b5b0-959f71c11ff8	\N	Chiara	Sandrin	\N	DALLA BRUNA S.R.L.	\N	\N	347.9735772	dallabrunavr@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.840547	2025-08-06 18:44:30.808144	\N
d358b473-ac9e-43fe-b27e-98f3c74beabc	\N	Ernesto	Colombo Bera	\N	P-TREE CONSULTING S.R.L.	\N	\N	3401074643	e.c.bera@ptree.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.841296	2025-08-06 18:44:30.808144	\N
b49aa90f-0d4c-4392-bbdd-5d70b975b3dc	\N	Edoardo	Accetti	\N	VICO S.R.L.	\N	\N	346 7849517	edoardo.accetti@vicosrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.842084	2025-08-06 18:44:30.808144	\N
0aeae113-11da-4e17-bfc7-baf116d542c6	\N	Orfeo	Sparelli	\N	VIDEOTECNICA S.R.L.	\N	\N	335 7866850	o.sparelli@videotecnica.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.842879	2025-08-06 18:44:30.808144	\N
f3aee39e-4c62-4a56-894f-3d3b37548e9e	\N	Bruno	Lubatti	\N	FARMACIA MADONNA PELLEGRINA DEL DR. OLDANI JACOPO NICOLO' ALESSANDRO QUALE TRUSTEE DEL TRUST LUBATTI	\N	\N	+39 338 8876821	farmacia.lubatti@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.843615	2025-08-06 18:44:30.808144	\N
8605cace-abad-45cf-8c8b-ffef43a028f6	\N	Carlotta	Stecchini	\N	VILLA STECCHINI RESORT SRL	Titolare	\N	329 1710960	info@villastecchini.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.844377	2025-08-06 18:44:30.808144	\N
3790b83c-2911-4f0d-9344-4d805fc96438	\N	Irene	Brancia	\N	VILLA SALUS ISTITUTO ELIOTERAPICO ORTOPEDICO S.R.L.	\N	0541 720315	\N	i.brancia@villasalus.rn.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.845104	2025-08-06 18:44:30.808144	\N
693cb76f-a059-4576-863d-3236af010aa2	\N	Maria Francesca	Napoliello	\N	VILLA MATILDE S.S.	\N	\N	335 6615586	mfnapoliello@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.84591	2025-08-06 18:44:30.808144	\N
63c11824-f0b5-4933-9b51-a3e4aa04825c	\N	Andrea	Biasibetti	\N	VIMEK BAKERY AUTOMATION S.R.L.	\N	049 9374790	\N	consulting@vimekbakery.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.846608	2025-08-06 18:44:30.808144	\N
3cd81e2b-4f91-44d2-ab5a-ba5d8d214eb0	\N	Fabio	Pasquali	\N	VLV CAPITAL SAGL	\N	\N	\N	f.pasquali@vlvcapital.ch	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.849205	2025-08-06 18:44:30.849989	\N
c27157b7-1501-4d99-8ee7-62e9a0b67f85	\N	Anna	Brizio	\N	VLV CAPITAL SAGL	\N	\N	340 2635422	annabrizio336@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.850646	2025-08-06 18:44:30.849989	\N
e38f520b-0cbe-4fc4-883c-93bbcb52f6fd	\N	Giacomo	Francesconi	\N	VNE S.P.A.	\N	\N	348 1189916	g.francesconi@vneglobal.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.851438	2025-08-06 18:44:30.849989	\N
f44eefed-edea-4e71-965e-917d2f1789bb	\N	Stefano	Tomacelli	\N	XTEAM SOFTWARE SOLUTIONS SRLS	\N	\N	345 7343689	xteam@xteamsoftware.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.852223	2025-08-06 18:44:30.849989	\N
01ebcfb4-67df-4276-8645-c5014ce1282e	\N	Roberto	D' Agostino	\N	WORLDLINE MERCHANT SERVICES ITALIA S.P.A.	\N	\N	348 1484068	r.dagostino@agenti.worldlineitalia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.852967	2025-08-06 18:44:30.849989	\N
9d72ddbe-d895-43a3-bae1-7972b1787f34	\N	Claudio	Greco	\N	WORKING STRATEGIES S.R.L.	\N	\N	371 3687452	workingstrategies1@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.853768	2025-08-06 18:44:30.849989	\N
9fe08436-a7f4-44d2-81ef-5bd540ae305c	\N	Antonio	Lipari	\N	ANTONINO LIPARI DITTA	\N	\N	340 4609677	antonio.lipari@wetmail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.85454	2025-08-06 18:44:30.849989	\N
e85dacee-3d83-48ac-bfd3-fd9119b75615	\N	Felice E.	Andolfi	\N	ZURICH ITALY BANK  S.P.A.	\N	\N	339.6005487	felice.andolfi@zurichbank.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.855291	2025-08-06 18:44:30.849989	\N
0af973e1-7d7d-4f0c-92d0-3e69c09f2d12	\N	Rossano	Zirondelli	\N	ZIRONDELLI & REGAZZI S.R.L.	\N	\N	335.6033947	rossano.zirondelli@zirondelliregazzi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.85602	2025-08-06 18:44:30.849989	\N
076f6958-28d7-4498-8cc1-0ede1f494551	\N	Sandro	Petris	\N	ZAHREBEER SOCIETA' SEMPLICE AGRICOLA	Referente	348.0990199	\N	info@zahrebeer.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.856754	2025-08-06 18:44:30.849989	\N
ca93aa0a-e64a-49b0-af6c-02229d49a730	\N	Slavica	Petris	\N	ZIP-LINE SAURIS ZAHRE SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	\N	\N	340.8803160	ilicslavica.551@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.857549	2025-08-06 18:44:30.849989	\N
70309756-a947-41f5-8dab-9205f6096256	\N	Laura	Zaino	\N	ZAINO FOODSERVICE S.R.L.	Titolare	\N	\N	Zaino Foodservice srl	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.858316	2025-08-06 18:44:30.849989	\N
389a509d-9690-4ad5-8ff4-857c6faea378	\N	Cristiano	Zanolli	\N	DOTT.ZANOLLI SRL	Titolare	\N	\N	amministrazione@zanolli.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.859088	2025-08-06 18:44:30.849989	\N
6f0b0368-a33a-4d5a-b2ae-b12fa5269cc6	\N	Agostino	Raggi	\N	SA.I.T. S.P.A.	Referente	339 7738276	\N	agostino.r@saitspa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.859841	2025-08-06 18:44:30.849989	\N
fe42532e-32bc-4d04-a02e-9aa49a0e3740	\N	Luca	Frattin	\N	FRATTIN GROUP SRL	\N	\N	0424.533348	luca@frattin-auto.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.860595	2025-08-06 18:44:30.849989	\N
901be2d9-5f97-4fe1-a67a-624ca8cf5444	\N	Davide	Fabris	\N	ACCESSIWAY S.R.L.	Account Executive	\N	333 2047794	davide.fabris@accessiway.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.861376	2025-08-06 18:44:30.849989	\N
442392bb-3d40-42be-93ea-6f0a17da0677	\N	Federico	Onoscuri	\N	ACCESSIWAY S.R.L.	Partnership Manager	\N	333 2047850	federico.onoscuri@accessiway.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.862139	2025-08-06 18:44:30.849989	\N
521d4be6-fbda-4e73-956d-166d37d7c50d	\N	Roberto	Tarzia	\N	MADBIT ENTERTAINMENT S.R.L.	Chief Executive Officer	02 94755820	\N	info@activepowered.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.862932	2025-08-06 18:44:30.849989	\N
aa449e8d-89ba-4745-8c31-fe4c52912ffb	\N	Domenico	Bianco	\N	AD CONSULTING SPA	Business Development	\N	346 0138057	domenico.bianco@adcgroup.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.863702	2025-08-06 18:44:30.849989	\N
a12c335e-a231-4cef-aef3-00518745b5cf	\N	Rebecca	My	\N	AGRI-E	Co-Founder	\N	348 2440275	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.864449	2025-08-06 18:44:30.849989	\N
b388a8c3-c8ce-4b24-9666-e50f83749fb1	\N	Alessandra	Caringella	\N	AI GARAGE SRL	Founder	\N	345 6410834	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.865192	2025-08-06 18:44:30.849989	\N
6964a27f-14a9-44a6-ae8f-ca4e77848d4a	\N	Michele	Colavito	\N	ART-ER  SCA	Cluster Manager	\N	340 2882715	michele.colavito@tourism.clust-er.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.866003	2025-08-06 18:44:30.849989	\N
10552130-76c4-4f65-bd41-c36401ab499b	\N	Diego	La Monica	\N	AXIO STUDIO S.R.L.	Founder & CEO	\N	333 7235382	d.lamonica@axio.studio	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.866743	2025-08-06 18:44:30.849989	\N
661e91f5-97d5-4c6d-803b-1c024cb9b65d	\N	Luca	Prioreschi	\N	B2LOCAL SRL	PM & ADS	\N	392 9846283	info@b2local.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.867535	2025-08-06 18:44:30.849989	\N
09146c57-513c-4909-bef2-3d5e6b1376ae	\N	Sara	Giannotte	\N	BLUEGREEN STRATEGY S.R.L.	Customare Support	\N	346 0285889	sara.giannotte@bluegreenstrategy.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.868339	2025-08-06 18:44:30.849989	\N
085f85a3-30da-42e3-804f-3115f3fd322f	\N	Massimo	Spaltro	\N	COLLI DI BRUNO COLLI SAS DI MORO ALDO & C.	Direttore	\N	348 7208719	direzione@collistampaggio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.869169	2025-08-06 18:44:30.849989	\N
f0286885-4fe5-4975-b7a9-5a597c85b69c	\N	Rosa	De Angelis	\N	\N	Banca Sella	\N	\N	rosa.deangelis@sella.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.87002	2025-08-06 18:44:30.849989	\N
66058ead-039c-4bdf-ba9d-084e78e45af9	\N	Orestis	Bozas	\N	\N	Co-Founder	\N	\N	orestisbozas2002@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.870886	2025-08-06 18:44:30.849989	\N
a4f66a67-aa07-446a-afeb-08d88253f4d6	\N	Dayana Vinueza	Calderon	\N	\N	Tech Marketing & Sales	\N	\N	dayanacalderon1204@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.871632	2025-08-06 18:44:30.849989	\N
41d8ee18-2720-4588-9946-c6145bd71941	\N	Ilaria	Bertelli	\N	CENTOFORM SRL	Consulente	\N	342 1705950	ilaria.bertelli@centoform.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.872391	2025-08-06 18:44:30.849989	\N
32c0709f-55f0-409e-ae10-617c860ae246	\N	Francesco	Guerrini	\N	CIRCLE PROJECT S.R.L.	Responsabile Commerciale	\N	333 6758563	francesco.guerrini@circleproject.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.873108	2025-08-06 18:44:30.849989	\N
91177ade-0fa4-4ac9-88b6-e8e857216698	\N	Ida	Di Costanzo	\N	CODE THIS LAB S.R.L.	Project Manager	\N	340 0733325	ida.dicostanzo@codethislab.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.873947	2025-08-06 18:44:30.849989	\N
75df4e55-a376-430a-91df-ea6caa132762	\N	Andrea	Elia	\N	CODEPLOY S.R.L.	\N	\N	342 3689970	andrea.elia@codeploy.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.874761	2025-08-06 18:44:30.849989	\N
fa294d70-88bb-498a-8ace-74250fe84dea	\N	Steven	Crosato	\N	\N	\N	\N	340 3405559	hello@stevencrosato.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.875518	2025-08-06 18:44:30.849989	\N
74fa7679-756a-4335-aed7-f61847c32657	\N	Jessica	Zuccolo	\N	CROWD M ITALY S.R.L.	Account Manager	\N	344 1361912	jessica.zuccolo@crowdm.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.876304	2025-08-06 18:44:30.849989	\N
9191b1cd-471d-4c85-97eb-41c212c9d4bc	\N	Antonella	Benedetti	\N	TECNICHE NUOVE S.P.A.	Business Development Manager Italy	\N	349 5641550	antonella@depositphotos.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.87709	2025-08-06 18:44:30.849989	\N
77980c9e-e9d1-40a3-a98e-6ded04eb5230	\N	Simone	Sabba	\N	DEVPUNKS S.R.L.	Chief Technology Officer	\N	349 6724353	simone.sabba@devpunks.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.877926	2025-08-06 18:44:30.849989	\N
52abeb28-45f0-4ecb-b745-16c8368c31f2	\N	Alan	Gallicchio	\N	ECOMATE S.R.L.	CPO e Founder	\N	339 3291927	alan@ecomate.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.878916	2025-08-06 18:44:30.849989	\N
7db26e67-cb52-4097-a49b-8e5d3de8550a	\N	Marco	Bogliotti	\N	EURID SERVICE S.R.L.          UNIPERSONALE	Senior Sales	\N	\N	marco.bogliotti@team.blue	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.880028	2025-08-06 18:44:30.849989	\N
33bf5504-f0b7-4906-976a-e70379ed5b96	\N	Daniela	Santona	\N	\N	Amministratore	3396416307	\N	santona@santona.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.881101	2025-08-06 18:44:30.849989	\N
73f6cea9-2b64-4f27-a2a3-0511c9fc7728	\N	Daniela	Santona	\N	OTTICA SANTONA S.R.L.	\N	339 6416307	\N	santona@santona.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.882128	2025-08-06 18:44:30.849989	\N
62d24b2d-6ae8-4f44-b853-8ec2f7ff3adf	\N	Guido	Colombo	\N	EDO RADICI FELICI S.R.L.	Delegato Area Tecnica	\N	393 9753750	g.colombo@edoradicifelici.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.883157	2025-08-06 18:44:30.849989	\N
85b406cd-fc7a-4d44-89db-daaad627c55f	\N	Guendalina	Guglielmino	\N	ERMASTUFF S.R.L.S.	Social Media Manager	0376 1410501	\N	guendalina@ermastuff.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.883964	2025-08-06 18:44:30.849989	\N
792d3be5-26c4-4a36-b91c-2ea88fd071c9	\N	Stefania	Frasson	\N	FONDAZIONE RIDE2MED	\N	\N	347 2681635	stefania.frasson@ride2med.org	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.884764	2025-08-06 18:44:30.849989	\N
b44c5b55-87b4-42f8-b474-c31ec58b1341	\N	Edgaedo	Fantazzini	\N	FORTGALE S.R.L.	Chief Executive Officer	328 8158036	\N	edgardo.fantazzini@fortgale.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.885539	2025-08-06 18:44:30.849989	\N
60147f4c-bd09-45b4-bbe2-12ba859912cd	\N	Alessandro	Bortoletto	\N	STUDIO BORTOLETTO S.R.L.	\N	049.8097175	\N	alessandro.bortoletto@studiobortoletto.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.886314	2025-08-06 18:44:30.849989	\N
bb3a0fde-9273-4c04-a825-c20b2643e63f	\N	Simone	Accoroni	\N	GREENBUBBLE AGENCY S.R.L.	Co-Founder & Technical Director	\N	349 2348117	s.accaroni@greenbubble.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.887083	2025-08-06 18:44:30.849989	\N
28481f3c-409e-4830-9e80-15344c85cca6	\N	Chiara	Di Lorenzo	\N	GLUTENSENS SRL	Founder e CSO	\N	334 3652249	chiara.dilorenzo@glutensens.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.887909	2025-08-06 18:44:30.849989	\N
03e511a0-7f50-4907-ab72-7dcedb9f612a	\N	Andrea	Basso	\N	\N	Consulente del Lavoro	049.738 2361	347.7685437	a.basso@cdlandreabasso.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.888717	2025-08-06 18:44:30.849989	\N
25a35454-412b-4329-8719-ee84998cc479	\N	Giacomo	Leanza	\N	AMPEREONE S.R.L.	Titolare	\N	380 5966151	info@ampereone.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.889493	2025-08-06 18:44:30.849989	\N
e8841b57-4320-42de-b5fb-9f7ccc6d76a3	\N	Andrea	Giusti	\N	SEA SISTEMI SNC DI GIUSTI ANDREA E ROBERTO	Titolare	\N	348 6606630	andrea@seasistemi.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.892004	2025-08-06 18:44:30.8927	\N
efdd87b9-2763-4682-bc39-cee12f0deda4	\N	Giuseppe	Bertolini	\N	I.C.P. S.P.A.	Titolare	\N	327 7405265	segreteria@icpspa.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.893538	2025-08-06 18:44:30.8927	\N
e46672bf-4162-433c-9976-469527b9d0c4	\N	Massimo	Maccarone	\N	EMC S.R.L.	Titolare	\N	333 4555240	m.maccarone@emcr.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.894515	2025-08-06 18:44:30.8927	\N
c9705b36-db0d-4bae-b792-4d86f161f114	\N	Filippo	Marcon	\N	EF STYLE HOTEL S.R.L.	Titolare	\N	393 1367441	info@efstylehotel.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.895375	2025-08-06 18:44:30.8927	\N
3ee14580-db40-424a-bac0-a70521b03f25	\N	Massimo	Salardi	\N	SALARDI SISTEMI S.R.L.	\N	\N	348.8012182	amministrazione@salardisistemi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.896142	2025-08-06 18:44:30.8927	\N
d5ef804b-0438-40b2-b4ba-8e010933c8a7	\N	Stefania	Fontanini	\N	NEW STYLE S.R.L.	Referente	\N	349 2932719	info@newstyleservice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.897024	2025-08-06 18:44:30.8927	\N
9da9d24f-555d-4e7a-90c9-4ff2b52e5754	\N	Claudio	Bruno	\N	EDILIMPIANTI TRIESTE S.R.L. - SOCIETA' BENEFIT	Referente	335.8010151	\N	claudio.bruno@edilgrouptrieste.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.898263	2025-08-06 18:44:30.8927	\N
66be47aa-2b2a-43be-9451-07cf307e4077	\N	Enzo	Settimo	\N	EDILIMPIANTI TRIESTE S.R.L. - SOCIETA' BENEFIT	Referente	331.8768504	\N	enzo.settimo@edilimpiantitrieste.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.899408	2025-08-06 18:44:30.8927	\N
ec904443-2edd-4a9f-8bb8-7d8ea1bc4c4d	\N	Martina	Vaccaro	\N	DSG AUTOMATION S.R.L.	Marketing & Communication Manager	389.1344604	\N	martina.vaccaro@dcircle.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.900551	2025-08-06 18:44:30.8927	\N
7853a19a-822d-4991-9bb2-0a3c59c2e345	\N	Alessandro	Chiappa	\N	\N	Revisore	\N	329 2025856	alessandro.chiappa@chiappa.org	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.90166	2025-08-06 18:44:30.8927	\N
c7147118-508b-4164-a9ea-3ca00a196e46	\N	Matteo	Cappelletti	\N	CAPPELLETTI MATTEO	Titolare	\N	328 9632232	matteo.cappelletti.k@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.902846	2025-08-06 18:44:30.8927	\N
c975afe7-8500-4d66-a273-3580a98fc750	\N	Dario	Lorandi	\N	ASSICURAZIONI BELTRAME LUCA & LORANDI DARIO S.N.C.	Titolare	392.2059885	\N	dario.lorandi@generalicento.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.903973	2025-08-06 18:44:30.8927	\N
3cbe731b-8f60-48be-9b28-0093fe12b6c1	\N	Luca	Garbin	\N	\N	\N	\N	342.1510512	lucagarbin16@yahoo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.905008	2025-08-06 18:44:30.8927	\N
188906f1-1e77-4b20-ae40-6c6d84f2231f	\N	Cristian	Agostini	\N	\N	\N	\N	348.7612849	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.906097	2025-08-06 18:44:30.8927	\N
5bfdee57-3001-4bdf-b8de-972bb8b2fe07	\N	Giacomo	Manna	\N	\N	\N	\N	331.8725574	mannagro.aziendagricola@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.907118	2025-08-06 18:44:30.8927	\N
bcc3bc82-a2e5-4fcd-b360-0c9225f043bc	\N	Stefania	De Agostini	\N	\N	\N	\N	328.3163312	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.908214	2025-08-06 18:44:30.8927	\N
2d413b90-2f85-4854-bfef-15186f12021f	\N	Elisa	Boccasin	\N	AB SUITE S.R.L.	Titolare	\N	348 7403667	info@absuite.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.909223	2025-08-06 18:44:30.8927	\N
7f0c5373-e37a-4f9a-a66c-7ccd86ab0df7	\N	Elisa	Cristofori	\N	S.LLE BARRACCA S.N.C. DI GUAZZALOCA LEONARDO & C.	Socia	339.4797455	\N	elisa@barracca.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.910287	2025-08-06 18:44:30.8927	\N
b4584ace-5b85-49f6-ace9-20da40e41961	\N	Maurizio	Coluccio	\N	\N	\N	\N	333 2478775	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.911341	2025-08-06 18:44:30.8927	\N
67e588dc-a752-4748-b8f3-95472bb3aba7	\N	Cristian	Gasparotto	\N	GASPAROTTO S.R.L. SB	Titolare	\N	335.7188789	cristian@gasparotto.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.912363	2025-08-06 18:44:30.8927	\N
ec329510-c345-4a1c-8689-042c3e2c26fa	\N	Francesca	Costenaro	\N	GASPAROTTO S.R.L. SB	Amministrazione	0424.1755379	338.3205791	amministrazione@gasparotto.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.913403	2025-08-06 18:44:30.8927	\N
88cce0a1-0dc4-4d90-a62f-c41352ce104c	\N	Nardino	Fogu	\N	FPM DA NARDINO S.R.L.	\N	\N	335 7083780	ristorantedanardino@hotmail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.914388	2025-08-06 18:44:30.8927	\N
c7a3393e-fdf7-4138-820f-98c3081da9cc	\N	Martina	Fogu	\N	FPM DA NARDINO S.R.L.	Figlia Titolare	\N	348 8353110	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.915452	2025-08-06 18:44:30.8927	\N
ad8a4b1b-25b6-4cfd-85ca-766b4689cc00	\N	Davide	Russotti	\N	HANDY S.R.L.	CEO e Co-Founder	\N	388 1132557	d.russotti@handysoftware.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.916564	2025-08-06 18:44:30.8927	\N
9bb51c51-3b05-44d1-8b64-1ef7269c8bf8	\N	Ilaria	Ceppatelli	\N	REDDOAK S.R.L.	Social Media Specialist	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:44:30.917672	2025-08-06 18:44:30.8927	\N
01c529bd-8ca0-4417-8806-371fb7072009	\N	Andrea	Fontanini	\N	AUTOCARROZZERIA LA TIRRENA S.N.C. DI GABRIELLI GIORGIO E GABRIELLI MARIA	Titolare	393.1485164	\N	andrea@carrozzerialatirrena.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.417187	2025-08-06 18:45:38.416093	\N
94ad6806-dbf9-467a-98bf-4a53f223f473	\N	Renato	Bianco	\N	\N	\N	\N	335.7787980	renbia.62@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.420656	2025-08-06 18:45:38.419978	\N
45a85cd3-4757-4b38-85ff-6be9828848af	\N	Maria	Gabrielli	\N	AUTOCARROZZERIA LA TIRRENA S.N.C. DI GABRIELLI GIORGIO E GABRIELLI MARIA	Referente	389.7850227	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.423876	2025-08-06 18:45:38.423044	\N
166e9be9-e93b-44b7-a2c9-19dd61a0134d	\N	Giorgio	Prelz	\N	\N	\N	\N	348.3667268	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.428033	2025-08-06 18:45:38.427228	\N
efa2e74c-0d5b-4be7-8476-4c93114717f7	\N	Arianna	Attorrese	\N	AGENZIA ATTORRESE DI PATRIZIA LIBERTINI, ARIANNA ATTORRESE & C. S .A.S.	Titolare	338.6398681	\N	arianna@agenziaattorrese.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.432079	2025-08-06 18:45:38.430976	\N
a3587aa0-2486-4da2-96b5-0d8914fdba76	\N	Stefano	Polo	\N	VIP AGENCY DI STEFANO POLO	Titolare	\N	329.2112142	info@vipagency.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.435575	2025-08-06 18:45:38.434699	\N
d9fa3303-96a5-44ad-929d-5f16ecd6416d	\N	Tommaso	Mucchiut	\N	\N	\N	\N	389.5503033	tommaso.mucchiut@bluenergygroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.438798	2025-08-06 18:45:38.438305	\N
304d3fe4-fd66-4d53-80b5-9b5c9750dbfa	\N	Claudio	Greco	\N	ACQUA PONICA	\N	371.3687452	\N	claudio7087@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.442261	2025-08-06 18:45:38.441076	\N
dfc81332-ed11-49ce-86a9-18f740b266fe	\N	Gianpaolo	Sempreboni	\N	ACQUA PONICA	\N	\N	\N	sempreboni@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.445718	2025-08-06 18:45:38.444819	\N
096acf81-43be-46e0-a507-7f030fe8351b	\N	Valentino	Paroncini	\N	VALEVEND SRL	Titolare	331.6919026	\N	valentino.paroncini@valevend.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.449694	2025-08-06 18:45:38.448412	\N
b1077158-f4ce-4695-8d4f-7ba29f66e2cd	\N	Samanta	Feleri	\N	NEW KARISMA DI FALERI SAMANTA	Titolare	328.1932034	\N	samanta.faleri82@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.454496	2025-08-06 18:45:38.453056	\N
32bfcdf5-a8a3-4eaf-a7bf-3c8ded62b381	\N	Luca	Di Giusto	\N	MARCHETTI S.R.L.	Titolare	393.1997070	\N	marcellodigiusto@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.4579	2025-08-06 18:45:38.457096	\N
9c0dd7fa-7de9-4333-812d-01a3afbd0940	\N	Monia	Matteucci	\N	MARCHETTI S.R.L.	Revisore - Studio Bonuccelli e Matteucci	0584.969509	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.460977	2025-08-06 18:45:38.460233	\N
189d5fa9-4c4f-4ffa-a899-9ed0504b54c9	\N	Roberto	Gastrini	\N	GASTRINI ROBERTO S.N.C. DI GASTRINI CHRISTIAN & C.	Titolare	339.1185972	\N	gastrini@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.464192	2025-08-06 18:45:38.463366	\N
a1ec52c9-3cc8-4a74-a7cf-ca7e1283d44a	\N	Roberto	Martini	\N	PRIMO VARCO S.A.S. DI ROBERTO MARTINI & C.	Titolare	347.4857101	\N	robmartini1971@yahoo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.47112	2025-08-06 18:45:38.469961	\N
318ba5f2-780c-4d2b-8989-016cbaf74a67	\N	Carolina	Betti	\N	FARMACIA BETTI DEL DOTT. BETTI CESARE	Titolare	348 7080461	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.47509	2025-08-06 18:45:38.474085	\N
2cae2c1d-fdb2-415b-90c5-e9b08c0e8191	\N	Giuseppe	Pastine	\N	HOTEL DUE TORRI SRL	Titolare	331.9092077	\N	giuseppepastine@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.478424	2025-08-06 18:45:38.47764	\N
e5b19abb-2ef6-4106-af97-1a2b6df875e7	\N	Luigi	Larco	\N	HOTEL DUE TORRI SRL	Consulente del lavoro	0185.286536	\N	studio.larco@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.481466	2025-08-06 18:45:38.480657	\N
adc909b8-2c61-48f5-9763-567dce37f074	\N	Mirko	Lucchesi	\N	ROSAJE S.R.L.	Titolare	348.5660839	\N	Dulcinea.pasticceria@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.48429	2025-08-06 18:45:38.48356	\N
20e1a111-09e3-4dc5-b8d9-020dfe9c9842	\N	Davide	Losso	\N	\N	Commercialista	040.301391	338.6663212	dl@asscoter.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.6001	2025-08-06 18:45:38.5996	\N
10f2f2bf-4ccb-42a7-bfcc-d934a022f5bf	\N	Giuseppe	Pepi	\N	\N	Commercialista - Revisore Legale	\N	335.6768981	giuseppe.pepi@fastwebnet.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.603281	2025-08-06 18:45:38.602678	\N
d8132971-2b9d-4ab6-83c4-42fec18d7d47	\N	Giancarlo	Cortellino	\N	\N	\N	040.7600368	335.6067484	cortellino@sgfarm.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.606257	2025-08-06 18:45:38.605664	\N
569a039c-2d79-4bfd-b643-e54ec826a205	\N	Ivano	Upennini	\N	\N	Revisore	\N	328 3011147	serviziced@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.627857	2025-08-06 18:45:38.627332	\N
cc3ee1f7-9bc1-4709-a256-9569abdc2066	\N	Flavio	Pol	\N	\N	Tributarista	\N	348.8601656	flavio@cedass.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.630822	2025-08-06 18:45:38.63023	\N
7a9d3419-f450-4e97-8820-0f53bd9b1c8e	\N	Claudio	Cordano	\N	\N	\N	334 8774968	\N	claudiocordano8@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.639956	2025-08-06 18:45:38.63942	\N
f4fb583a-b55b-4712-8f55-67fb1c257d4b	\N	Stefano	Sciannamblo	\N	\N	\N	\N	340.2598807	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.657223	2025-08-06 18:45:38.656709	\N
05ffc52c-ed77-4768-9cc1-46f6908748aa	\N	Paolo	Pisciali	\N	\N	\N	335.7233369	\N	paolo.pisciali@conciliumteam.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.671802	2025-08-06 18:45:38.671075	\N
cc9820e8-c1b7-4c7a-9276-1a3a509d4469	\N	Giorgio	Vento	\N	\N	Partner Esterno	\N	333 2440640	info@finanzaimpresa360.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.697572	2025-08-06 18:45:38.696964	\N
af6a64e1-2d5d-4639-a62f-da7b5933c4ce	\N	Luca	Pasquini	\N	\N	Partner esterno	+43 664 1305785	\N	luca.pasquini@engageitservices.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.825119	2025-08-06 18:45:38.824596	\N
8401959f-c80f-4f70-95a1-ef213657ab95	\N	Simone	Grando	\N	\N	\N	\N	349.5474540	gs.consulenzeaziendali@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.89091	2025-08-06 18:45:38.890403	\N
a7b2f765-3353-48c5-a7d4-4cd62e315940	\N	Roberto	Ferrari	\N	\N	\N	\N	\N	rfcdsfgf@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.893876	2025-08-06 18:45:38.893365	\N
d62a1161-02e1-4164-b007-8c0b5c0ef13c	\N	Alessio	Degasperi	\N	\N	Dottore Commercialista e Revisore	349.8060065;0461.1975610	\N	degasperi@csatn.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.936627	2025-08-06 18:45:38.936132	\N
c7a07930-d941-4dcd-9d4d-cc4fce0990fa	\N	Silvia	Crotti	\N	\N	Commercialista	\N	339 5236712	silvia@cedarluno.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.966889	2025-08-06 18:45:38.966318	\N
622a2fd2-d33f-4896-9848-c00e83d2da0a	\N	Simone	Toffanin	\N	\N	\N	\N	334.1813208	simone.toffanin@nordest-group.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:38.979748	2025-08-06 18:45:38.979278	\N
01a765df-f112-4c05-90ab-8aa55a369d8b	\N	Valentino	Dalla Bona	\N	AL CASELLO S.A.S. DI DALLA BONA VALENTINO	Titolare	\N	345 0253443	info@alcasello.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.044673	2025-08-06 18:45:39.043597	\N
62238b27-b6f8-40c3-9f8d-ddca2fb31ec9	\N	Fabrizio	Libardi	\N	PIZZERIA PAPILLON SRL	\N	347.9616156	\N	papillon1989@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.049071	2025-08-06 18:45:39.047789	\N
8901c42b-b062-4d77-acec-784c4223f4b6	\N	Angela	Ruggeri	\N	EFFEUNO S.R.L.	Socia	347.5707479	\N	amministrazione@effeuno.biz	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.053142	2025-08-06 18:45:39.051958	\N
64a59e53-e103-45c8-8dfc-a8f427f8cf6c	\N	Cosetta	Comellini	\N	EFFEUNO S.R.L.	Referente	049.5798415	\N	contabilita@effeuno.biz	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.058772	2025-08-06 18:45:39.057277	\N
83000886-3a42-4b0d-9d0f-ab2d7fbeab3d	\N	Filippo	Zago	\N	FUN FACTORY DI CRIVELLARO DANIELA E C. - S.A.S.	Referente	346.6257701	\N	funfactory@funfactorymode.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.063418	2025-08-06 18:45:39.062236	\N
2c2c4aee-11e6-4823-89be-20aef53336cc	\N	Carla	Giannotti	\N	GIOVANNINI BIBITE SRL	Referente	\N	366 2670013	giannotti.carla@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.067049	2025-08-06 18:45:39.066189	\N
f3466a12-cf03-41c2-96f2-6df6f553a550	\N	Nicola	Sartori	\N	OLSAR S.R.L.	Referente	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.070383	2025-08-06 18:45:39.069545	\N
76bccd0a-fef3-451e-b7db-cd9ae844eaa6	\N	Luigino	Bottini	\N	CONTITALIA SOCIETA' A RESPONSABILITA' LIMITATA	Titolare	\N	348 2662432	info@luiginobottini.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.076987	2025-08-06 18:45:39.075972	\N
04d97ed2-c547-4146-8e7b-10484762abfb	\N	Alice	Contu	\N	CF SERVIZI S.R.L.	Referente	333 5242552	\N	info@cfservizi.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.080887	2025-08-06 18:45:39.079971	\N
31e72b2b-2d6d-4aba-a400-0199bb8df167	\N	Ivano	Upennini	\N	CED SERVIZI IMPRESE S.A.S. DI UPENNINI IVANO  &  C.	Titolare	\N	328 3011147	serviziced@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.08446	2025-08-06 18:45:39.083428	\N
1a396574-3d3d-41d8-8676-6dab41fe56d6	\N	Giancarlo	Gattazzo	\N	GATTAZZO S.R.L.	Titolare	320.1703950	\N	giancarlo.g@gattazzo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.088072	2025-08-06 18:45:39.087135	\N
df385ac7-efe5-40c4-a2ac-d8d1e04fbe06	\N	Ida	Tesser	\N	FARMACIA VALZOLDANA DELLA DOTT.SSA IDA TESSER	Referente	0437.78262	\N	f.valzoldana@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.099196	2025-08-06 18:45:39.098281	\N
b6757f4a-a440-4a64-958f-d02c222c3087	\N	Massimo	Alberghi	\N	CED SERVIZI IMPRESE S.A.S. DI UPENNINI IVANO  &  C.	Revisore	338 5093628	\N	massimoalberghi1970@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.103154	2025-08-06 18:45:39.102072	\N
45cc7f05-456f-42d2-a1fc-11a657cb13cc	\N	Edoardo Achille	Cavalli	\N	ENIMA SRL	Legale Rappresentante	348.5507730	\N	enima.gasluce@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.106691	2025-08-06 18:45:39.105658	\N
2e9bb150-5a75-447e-9116-ce6f14086e47	\N	Ottonello	Nedo	\N	HOTEL HELVETIA S.R.L. UNIPERSONALE	Referente	\N	347 5835250	direzione@hotelhelvetiagenova.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.110122	2025-08-06 18:45:39.109168	\N
016b67cf-7603-4099-adbc-1043c527ebf4	\N	Luca	Serafini	\N	PEPE NERO DI SERAFINI LUCA	Titolare	347 4758491	\N	lucasera33@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.113434	2025-08-06 18:45:39.112516	\N
d18da70a-848b-4161-9d25-350ee7b54959	\N	Rocco	Fama'	\N	EDILMONTI DI FAMA' ROCCO	Titolare	\N	348 6526825	edilmonti@hotmail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.116547	2025-08-06 18:45:39.115726	\N
5b49b30e-62d1-46de-b9ef-10f1cb55c827	\N	Alex	Lorenzon	\N	FININVI S.R.L.	Referente	338.8313017; 0424.383350	\N	info@ca-sette.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.119627	2025-08-06 18:45:39.118881	\N
4172ae47-ba2f-4edd-8a90-552a8f050b51	\N	Simone	Arisci	\N	SERVIZI DELICATI SRL	Referente	339.6536838	\N	direzione@servizidelicati.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.122725	2025-08-06 18:45:39.121942	\N
5b633eba-8b79-4aaf-9e83-3024550ba9d6	\N	Luca	Nardello	\N	NARDELLO STAMPI SRL	Titolare	347.8460924	\N	info@nardellostampi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.126861	2025-08-06 18:45:39.125587	\N
1a802e64-aba5-4b77-9951-91bff4cd534a	\N	Davide	Flagello	\N	FAST S.P.A.	Responsabile Amministrazione	\N	\N	d.flagello@fastspa.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.130904	2025-08-06 18:45:39.129572	\N
2acae29d-2df6-42b8-9155-54e3a533233d	\N	Giovanni	Soria	\N	SORIA COSTRUZIONI S.R.L.	Titolare	392.8073938	\N	soriacostruzionisrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.135219	2025-08-06 18:45:39.133876	\N
ee852993-015c-4f1a-9444-5a9da5f2347d	\N	Tristano	Mussini	\N	COP ASFALTI GROUP S.R.L.	Referente	335.7234866	\N	tristano.copasfaltigroup@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.139082	2025-08-06 18:45:39.137847	\N
ea210bdf-6652-4b3c-bbba-cfaef52eaca0	\N	Gianfranco	Testi	\N	STUDIO ISCHIA S.A.S. DI BOTTURA ROSITA, FRAPPORTI MIRIAM, TESTI GIANFRANCO E C.	Referente	\N	\N	gianfranco@studioischiasas.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.142969	2025-08-06 18:45:39.141691	\N
78d24fbd-b5be-439d-8818-ddff58f0afee	\N	Gabriele	Campana	\N	TESSILVENETA S.R.L.	Titolare	393.9934494	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.147065	2025-08-06 18:45:39.145749	\N
2e7ac2d0-8af2-4155-9d84-7dcd98911cde	\N	Andrea	Dalle Vedove	\N	IMMOBILIARE DALLE VEDOVE S.R.L.	Titolare	335.5492635	\N	andrea.adv@imdv.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.150566	2025-08-06 18:45:39.149715	\N
d050a49d-e216-469b-9c7f-0d6be675040a	\N	Mattia	Pozza	\N	EURO HYGIENE S.R.L.	Referente	347.5952477	\N	mattia.pozza@eurohygiene.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.153993	2025-08-06 18:45:39.153118	\N
142d4ad8-cae3-4a7b-90ea-eabac816f0ea	\N	Gianna	Berardi	\N	PIZZERIA AL BACIO DI BERARDI MARIA GIANNA & C. S.N.C.	\N	\N	329.2195479	giannaberardi61@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.157218	2025-08-06 18:45:39.15639	\N
d6a33044-beae-41c5-bca4-ff556511cbfb	\N	Gabriele	Maragno	\N	N.E.C. CHIUSURE S.R.L.	Titolare	334.5468798	\N	commerciale@chiusure-nec.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.160397	2025-08-06 18:45:39.159542	\N
85bd5ba0-df51-411b-a73d-d10b3762548d	\N	Valentina	Colombu	\N	RISTORANTE DONATELLA	Titolare	\N	328 1576016	valentinacolombu@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.163778	2025-08-06 18:45:39.162764	\N
ba78f820-2c7d-445f-8797-d3c881cbfebd	\N	Henri	Prosperi	\N	TRINITY WINES & FOODS SOCIETA' A RESPONSABILITA' LIMITATA	Titolare	\N	339 6472909	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.167311	2025-08-06 18:45:39.166439	\N
e8465584-01ca-49ae-bf87-0ab726acc019	\N	Daniela	Granelli	\N	LOGILUSA S.A.S. DI SQUERI GABRIELE & C.	Referente	\N	339 4624844	logilusa@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.170236	2025-08-06 18:45:39.169396	\N
9dd6bac4-4a97-4d85-afb3-8a8b59ff9345	\N	Massimiliano	Spiri	\N	K.A.S.RAHMA S.R.L.	Titolare	\N	347 1864606	massi.spiri@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.173504	2025-08-06 18:45:39.172705	\N
c6783c95-db28-496b-b1f9-b549669405a6	\N	Manrico	Milone	\N	SILBER S.A.S . DI MILONE MANRICO & C.	Titolare	\N	329 0549171	manricomilone@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.176467	2025-08-06 18:45:39.175743	\N
1881c42d-14ac-431b-84f0-b824a1e56b75	\N	Matteo	Nardi	\N	S.A.N.A. - S.R.L.	Titolare	\N	\N	info@sanainfrastrutture.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.179555	2025-08-06 18:45:39.17882	\N
e11518fe-c767-495a-a828-3a932f7d89b7	\N	Francesco	Maffei	\N	ITALIANITY SRL	Titolare	348 4081740	\N	f.maffei@italianity.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.183038	2025-08-06 18:45:39.182173	\N
8bd390e1-9090-48be-895f-7358c51a1aa7	\N	Nicola Domenico	Fiori	\N	MAGNA & SCAPPA S.R.L.	Titolare	340 0783586	\N	magnaescappa@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.186353	2025-08-06 18:45:39.185529	\N
ef7a16b8-fffb-4fc7-aaa8-571f5fe3180d	\N	Antonio	Telve	\N	GREENTEL S.R.L.	Referente	347.1440766	\N	info@green-tel.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.192459	2025-08-06 18:45:39.191425	\N
1cf88a1e-3452-4afb-8c52-2eb392c2c903	\N	Jonni	Gamba	\N	MODELLERIA GRIGGIO S.R.L.	Titolare	348.8014938	\N	jonni.gamba@promegasrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.196117	2025-08-06 18:45:39.195181	\N
acc42537-9daf-4fd8-affd-d96070c60d64	\N	Davide	Iozzelli	\N	IOZZELLI GROUP S.R.L.	Titolare	335 7367747	\N	info@iozzelli.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.199859	2025-08-06 18:45:39.198985	\N
2d0e0166-68e9-4e97-b22b-01f1963d62fa	\N	Samuele	Gamba	\N	PROMEGA  S.R.L.	Titolare	\N	\N	samuele.gamba@promegasrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.203106	2025-08-06 18:45:39.202216	\N
cdb68b64-03b5-4803-836c-004bcebcdabe	\N	Lisa	Modotti	\N	ALBERGO FLORIDA S.N.C. DI NASSIVERA G. E M.	Referente	349 6871904	\N	modottilisa@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.2072	2025-08-06 18:45:39.206296	\N
7a77b531-bf25-4414-96a1-5e47eefa351d	\N	Andrea	Gulberti	\N	ALBERGO IOLANDA SRL	Titolare	\N	331 2290346	andrea.gulberti12@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.211064	2025-08-06 18:45:39.210081	\N
d824e46c-d7f6-4049-874f-5c3c06a30226	\N	Federica	Bedin	\N	ROMITAL S.R.L.	Referente	349.3984949	\N	amministrazione@romitasrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.215323	2025-08-06 18:45:39.213993	\N
50700515-9ffe-4686-b79a-905b572bd58c	\N	Alexandru	Bogdan Micu	\N	ROMITAL S.R.L.	Referente	340.8216583	\N	alexandru@romitalsrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.219423	2025-08-06 18:45:39.218406	\N
10b42e27-bda8-4d70-9dab-f802d553aca8	\N	Andrea	Gulberti	\N	IMMOBILIARE SAN GIUSEPPE SRL	\N	\N	\N	info@hotelsantandrea.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.223094	2025-08-06 18:45:39.221972	\N
1e599931-639d-4ec3-9f1c-5c3f41cf1867	\N	Silvano	Genero	\N	SCATOLIFICIO GLORIA S.R.L.	Titolare	\N	\N	amministrazione@scatolificiogloria.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.226592	2025-08-06 18:45:39.225775	\N
a7e35d32-8a7b-449a-9c7c-9187e6c51f58	\N	Rosanna	Sablone	\N	UNIONFLOR S.R.L.	\N	\N	393 9521995	amministrazione@unionflor.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.229876	2025-08-06 18:45:39.229063	\N
e377eb36-aee8-44f5-b2ee-d996ae061564	\N	Mirco	Bruzzo	\N	TECNOHABITAT IMPIANTI S.R.L.	Titolare	\N	392 1152139	info@tecnohabitat.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.232482	2025-08-06 18:45:39.2318	\N
0124e63a-8500-451d-8767-2e7cace2f7a7	\N	Luca	D'Orazio	\N	TECNOINGROS S.A.S. DI PASTORELLO GIOVANNI E C.	Referente	340.7552523	\N	centralino@tecnoingros.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.235249	2025-08-06 18:45:39.234539	\N
20b62f4f-5395-46d2-abae-fe060a376726	\N	Federico	Dall'Olio	\N	CARTOLANDIA DI DALL'OLIO ENNIO & C. S.N.C.	Referente	346.2896658	\N	amministrazione@cartolandiasnc.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.238036	2025-08-06 18:45:39.237235	\N
3e97cb44-a539-4e2b-9ba0-8ca8a1dfe1e1	\N	Daniele	Gorza	\N	A.R.A. SRL	Referente	335.5804591	\N	daniele@arafeltre.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.241109	2025-08-06 18:45:39.240344	\N
16a53f0a-07c1-4030-a726-fd9e88a11e98	\N	Gastone	Soncin	\N	FRIGOMEC S.R.L.	\N	335.6402749	\N	amministrazione@frigomec.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.244057	2025-08-06 18:45:39.243331	\N
060a03c7-aad2-42f7-982e-277626b60909	\N	Danilo	Erdas	\N	ANANDA SRLS	Amministratore	\N	3349508749	otticaerdas@alice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.246969	2025-08-06 18:45:39.246199	\N
7476ae11-a5c1-48f6-8ae5-b17b7838b92d	\N	Daniele	Nichele	\N	HOTEL RISTORANTE GIADA DI NICOLA CUOMO & C. S.R.L.	Referente	328.2131606	\N	daniele.nichel@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.249948	2025-08-06 18:45:39.249059	\N
6a12d51c-7933-4aec-b87d-6db47087fa10	\N	Gianluca	D' Avanzo	\N	ALL'INFERNO DI D'AVANZO GIANLUCA E ANDREA S.N.C.	Titolare	328 2929092	\N	osteriainferno1908@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.253015	2025-08-06 18:45:39.252225	\N
2daaedf1-f958-482b-832c-6feb6387d799	\N	Rino	Vago	\N	FARA S.R.L.	\N	\N	393 2962468	rino.vago@grandhoteltorrefara.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.256143	2025-08-06 18:45:39.255323	\N
2fb08aa1-36da-4a98-ba95-5e5f2e086814	\N	Pier Francesco	Bocus	\N	PLAYA S.R.L.	Referente	335.5973621	\N	mail@playa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.259522	2025-08-06 18:45:39.258709	\N
5c9e9d70-c1f9-425d-8360-3a1eb5014019	\N	Vanni	Giuriato	\N	CARTA DELTA S.R.L.	Referente	0426.632916	\N	cartadeltasrl@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.262499	2025-08-06 18:45:39.261756	\N
e99aded7-5504-4548-8717-b9378b816b78	\N	Roberto	Penello	\N	FORPEN S.R.L.	Titolare	348.2289619	\N	robertoforpen@forpen.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.265298	2025-08-06 18:45:39.264493	\N
3076d0ac-7a4a-464a-ae10-7c281881aae0	\N	Stefanina	Puddighinu	\N	A.S.T.I. SUPERMERCATI S.R.L. DI PIRINA E RASPITZU	Titolare	\N	339 5935549	astisupermercati@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.268392	2025-08-06 18:45:39.267544	\N
3a92092f-2cc3-4262-9598-b7fa7ad979b9	\N	Alberto	Valente	\N	VALENTE S.R.L.	Titolare	335.7099812	\N	alberto.valente@valentepali.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.271515	2025-08-06 18:45:39.270668	\N
31a26023-4bb7-4329-baf0-ef7df7e6bd5c	\N	Claudio	Rivelli	\N	STUDIO RIVELLI CONSULTING - S.R.L.	Titolare	335 8439835	\N	c.rivelli@studiorivelli.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.27737	2025-08-06 18:45:39.276491	\N
74f53a4f-d86e-40ad-9365-a2ef19191b37	\N	Andrea	Cattelan	\N	AZIENDA AGRICOLA DALLE RIVE S.S. SOCIETA' AGRICOLA	Referente	349.1274893	\N	andrea@vivaidallerive.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.28195	2025-08-06 18:45:39.280366	\N
06260b22-5f43-46ff-9389-8b165aabd309	\N	Marco	Pittaluga	\N	NICO S.A.S. DI  DONADEL PENNY E C.	Amministratore	347.7818288	\N	amministrazionepepido@catoresele.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.285995	2025-08-06 18:45:39.284914	\N
8d859e82-eb97-4746-8835-63cdd7f81541	\N	Francesco	Comparini	\N	NUOVADATA GRAFIX WIDE S.R.L.	Titolare	\N	349 6400745	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.290613	2025-08-06 18:45:39.289235	\N
f81725cc-5d8c-47bd-a6f2-cc43d8edf8af	\N	Floris	Penazzato	\N	ELETTRODELTA S.A.S. DI PENAZZATO MATTEO & C.	Titolare	349.1969777	\N	floris1658@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.295067	2025-08-06 18:45:39.293715	\N
6d6c6710-c6f3-4d62-ba15-b467cbd36389	\N	Ambra	Maggiolo	\N	AUTO MAGGIOLO S.R.L.	Titolare	328.4532105	\N	info@automaggiolo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.300438	2025-08-06 18:45:39.298344	\N
86532ff3-1d16-4dc1-8c4d-561b2b50e32b	\N	Luca	Diquigiovanni	\N	DIQUIGIOVANNI TERMOIMPIANTI IL BAGNO S.R.L.	Titolare	338.9174076	\N	amministrazione@diquigiovanni1967.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.304707	2025-08-06 18:45:39.303745	\N
cb30a7d2-45c2-4031-b1c7-af36c65c69a5	\N	Raffaele	Fasuolo	\N	FUNSEVEN BIKES S.R.L.	Referente	\N	347 3655166	jessica.zecca@funseventech.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.308983	2025-08-06 18:45:39.307641	\N
7e9204fb-09bb-4962-9bff-1dc099ff9963	\N	Raffaele	Fasuolo	\N	FUNSEVEN TECNOLOGY SRL	Referente	\N	392 9396298	funseven@funseven.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.314057	2025-08-06 18:45:39.312555	\N
d0d4ddf0-8f7b-4d68-bb35-733c7ad05960	\N	Massimo	Bocchi	\N	BOCCHI SUPERMERCATI S.N.C. DI BOCCHI PAOLA MASSIMO E FRANCESCO	Titolare	339.8646636	\N	cn023@goldnet.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.318718	2025-08-06 18:45:39.317347	\N
93dcdcbc-918b-4da7-b676-c5193f89412f	\N	Alessio	Pagnini	\N	BLU INNOVATION MEDIA S.R.L.	Titolare	\N	347 3172298	info@bluinnovationmedia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.323367	2025-08-06 18:45:39.322094	\N
50222967-d1ea-407b-b19e-dea2024a3bc5	\N	Federica	Mazzoni	\N	AD LA FALEGNAMERIA S.R.L.	\N	\N	349.6622814	adlafalegnameria@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.327614	2025-08-06 18:45:39.326349	\N
5d8b95ec-fd4c-4eec-bb83-585f06321573	\N	Jacopo	Del Campo	\N	1 BYTE S.R.L.	\N	348 5124704	\N	jacopodelcampo@1byte.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.332199	2025-08-06 18:45:39.330828	\N
e7b83241-5aa0-4141-94dd-117c7cc9420f	\N	Viviana	Balbon	\N	1 BYTE S.R.L.	\N	351 3129726	\N	v.baldon@forumlaboris.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.336795	2025-08-06 18:45:39.335459	\N
bbc3c4c6-d9f9-46e4-b3dd-1c7a00fc0be0	\N	Michele	Molaro	\N	M.G.M. DI MOLARO MICHELE	Titolare	331.1804692	\N	mgmsecurity@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.341622	2025-08-06 18:45:39.340226	\N
e501667b-14fa-4164-b91d-8ae47a94cfa1	\N	Dario	Pedron	\N	CONSORZIO STABILE PEDRON	Titolare	329.8625628	\N	dario.pedron@consorziopedron.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.346186	2025-08-06 18:45:39.344822	\N
5e52639c-4b16-4124-8178-db8fbd9f7d6e	\N	Dario	Vettorato	\N	SAND-BLAST DI VETTORATO DARIO ANTONIO	Titolare	335.7277493	\N	sandblast@virgilio.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.351152	2025-08-06 18:45:39.349627	\N
00dc643c-0d62-476e-b35c-7a91327565a5	\N	Gina	Passaro	\N	IMOIL S.R.L.	Referente	328 8765343	\N	studiopassaro.p@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.355725	2025-08-06 18:45:39.354521	\N
b10e1e53-b9bd-4c72-b9b7-e484f88f29ba	\N	Magnolia	Gjokaj	\N	IMOIL S.R.L.	\N	\N	379 2387176	m.gjokaj@imoil.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.359899	2025-08-06 18:45:39.35874	\N
778370f0-477c-4f74-b8e5-7dac4e20d7bc	\N	Luca	Dal Balcon	\N	DAL BALCON S.R.L.	Titolare	347.4383310	\N	luca@dalbalcon.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.363488	2025-08-06 18:45:39.362235	\N
35e59134-f423-411b-b0ed-35d341d3fa7f	\N	Denis	Tomasi	\N	TOMASI S.R.L.	Socio	335.5499672	\N	info@tomasife.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.367693	2025-08-06 18:45:39.366332	\N
b61fdbe0-e34b-4b5c-b279-5748d7dcc76d	\N	Giacomo	Costi	\N	DR. DENT SARZANA S.R.L.	\N	328 2954951	\N	giacomocosti@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.371716	2025-08-06 18:45:39.37069	\N
b3eb56df-c09e-40f2-b14c-c388ac5ba513	\N	Angelo	Beccaria	\N	MEDIA TRADE S.R.L. DENOMINAZIONE ABBREVIATA: M.TRADE S.R.L.	Referente	320 2937144	\N	amministrazione@mediatradecompany.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.375648	2025-08-06 18:45:39.374623	\N
493da619-2b1b-49c0-8402-19d155ca285b	\N	Martino	Musso	\N	ECOCLEAN ITALIA S.R.L.	\N	\N	348 0078395	m.musso@ecocleanitalia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.379403	2025-08-06 18:45:39.378441	\N
03f12a7b-9d28-498a-94b1-0dca62e94310	\N	Enrico	Bettarini	\N	TECNO GOMMA S.A.S. DI BETTARINI ENRICO & C.	Referente	391.7349515	\N	jessicatecnog@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.383203	2025-08-06 18:45:39.382273	\N
38c0fbd7-cdc6-4a33-8b7b-efe55780eaad	\N	Alessandra	Panzeri	\N	ON CAFFE' SRL	\N	\N	391 3933284	amministrazione@oncaffe.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.387131	2025-08-06 18:45:39.386094	\N
908b8526-b4fb-46bc-b98b-7d7651b2de56	\N	Giorgio	Magi	\N	HOTEL AURORA DI MAGI GIORGIO E C. S.N.C.	Referente	348.2633065	\N	aurora@familyhotel.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.392031	2025-08-06 18:45:39.390615	\N
e5f69d65-577a-4a7f-bf46-ce722abae113	\N	Mendo	Bitonci	\N	STUDIO BITONCI, MENDO & ASSOCIATI S.R.L.	Titolare	049.9401570	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.396594	2025-08-06 18:45:39.395494	\N
3a146be2-8b34-4bf8-96aa-b8dd97e8d688	\N	Paolo	Luperini	\N	C.R.C. CENTRO RICERCHE CLINICHE  S.R.L.	Referente	331 1505441	\N	paolo.luperini@crcpisa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.401449	2025-08-06 18:45:39.399797	\N
d4ed0d6e-4dc4-45c9-a201-30ebf19d814f	\N	Federico	Meoni	\N	FO.G. SRL	Referente	335 7870860	\N	f.meoni@foglucca.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.405835	2025-08-06 18:45:39.404643	\N
604311cc-4567-49c1-8e46-d6634532ca66	\N	Luca	Gori	\N	KREDICI S.R.L.	Referente	328 2757193	\N	luca.gori@kredici.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.410363	2025-08-06 18:45:39.408987	\N
5a317de6-7e6a-40c8-8696-d089627049b3	\N	Claudio	Frontori	\N	KING BREAK S.A.S. DI C. FRONTORI	Titolare	377 1459728	\N	ilovecaffe1@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.414915	2025-08-06 18:45:39.413509	\N
1b8be273-63ed-4a8d-8ec4-e22ecf31fcf7	\N	Gabriella	Gandelli	\N	WILD FOOD S.R.L.	Referente	\N	339 3913762	gabriella.gandelli@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.419426	2025-08-06 18:45:39.418155	\N
2eea3de4-4a23-4ed0-ac12-fc471bb86101	\N	Pietro	Giordano	\N	RISTORANTE PIZZERIA DA PIETRO DI GIORDANO PIETRO	Titolare	\N	335 7172402	pietro-giordano@alice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.539419	2025-08-06 18:45:39.537894	\N
1f96ee57-122a-4d8a-8b5d-3388b00a606c	\N	Marco	Scelza	\N	CARROZZERIA SCELZA S.R.L.	Titolare	339.2362626; 030.347552	\N	info@scelza.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.544203	2025-08-06 18:45:39.542756	\N
c77e10bf-4cdf-4442-bc53-ede335588133	\N	Valentina	Costa	\N	CARROZZERIA SCELZA S.R.L.	Commercialista	333.6978336	\N	segreteria.ignaziobellitti@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.548301	2025-08-06 18:45:39.547073	\N
7b0f0752-d65f-4249-b99f-095eb9c701ac	\N	Luca	Guidetti	\N	GANDAL HOSPITALITY SRL (FAM)	Referente	339.6138801	\N	info@famlifestyle.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.552433	2025-08-06 18:45:39.551102	\N
6e5fb071-bc7a-4010-aaab-91a995650dcc	\N	Alex	Busi	\N	BUSI IMPIANTI S.R.L.	Titolare	335.1358542;392.9625319	\N	busiimpianti@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.556788	2025-08-06 18:45:39.555339	\N
d0d5ab44-72ce-4901-a81a-982b2eaa0942	\N	Massimiliano	Franceschi	\N	FRAUFA TECH S.R.L.	Referente	338.3311652	\N	mfranceschi@fraufa.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.561214	2025-08-06 18:45:39.560034	\N
df447d5c-015e-4dd6-8b21-0f23291042af	\N	Alessandro	Bertolone	\N	PREVIA ASSICURA SRL	Referente	335.8241246	\N	alessandro.bertolone@previaassicura.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.565735	2025-08-06 18:45:39.564493	\N
865916f8-003c-4492-a593-0399dbd1dafb	\N	Rian	Alebbi	\N	A.R.CON DI ALEBBI RIAN	Titolare	327 8134930	\N	arconmezzolara@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.570095	2025-08-06 18:45:39.568997	\N
7c26ebae-1f0a-43c9-8897-afda9053bc8c	\N	Giuseppe	Posse	\N	GP SRL	Referente	349.2735395	\N	infanziaoggiverona@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.574581	2025-08-06 18:45:39.573374	\N
c18db51e-07dd-4ec9-837c-f4c800913309	\N	Graziella	Ticca	\N	SG PLUS S.R.L.	Referente	346 0303938	\N	graziella.ticca@sgplus.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.579141	2025-08-06 18:45:39.577942	\N
4f72cfaa-edf0-45dc-b3c2-5144377e1a38	\N	Alessandro	Pasini	\N	PASINI GOMME DI PASINI ALESSANDRO	Titolare	\N	\N	info@pasinigomme.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.58384	2025-08-06 18:45:39.582388	\N
4b410920-b8f7-402e-a6ed-883294f2c488	\N	Maria Silvia	Leo	\N	ENERPETROLI S.R.L.	\N	0761.240345	\N	silvialeo@enerpetroli.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.589003	2025-08-06 18:45:39.587286	\N
872073a1-12ce-4ca8-bc1d-f08f5cb35de7	\N	Stefano	Barghini	\N	ENERPETROLI S.R.L.	Consulente	0761 354073	\N	stefano@studiobarghini.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.593983	2025-08-06 18:45:39.592305	\N
c605475d-1fbd-4957-9242-6ed7b7ed66c0	\N	Gianfranco	Nigro	\N	DESIDERIA 3 DI NIGRO GIANFRANCO E C. SNC	Titolare	339.8121842	\N	gianfry.nigro@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.598936	2025-08-06 18:45:39.597528	\N
3634b319-cc2f-4600-ac20-b90757b61e61	\N	Fabrizio	Facchini	\N	\N	Titolare	\N	335 6893618	fabrizio.facchini@fourstarspetroleum.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.603305	2025-08-06 18:45:39.602122	\N
92c8a352-1a9c-4d1c-8e77-24dc4c21bd7c	\N	Liviu	Tugui	\N	ARENA GLASS DI TUGUI LIVIU & C. S.N.C.	Referente	347.7418708	\N	info@arenaglass.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.607018	2025-08-06 18:45:39.605883	\N
d927d5bd-a210-46fa-b2ab-2841e273aa7b	\N	Nancy	Pini	\N	CASEIFICIO PINI S.R.L.	Titolare	347.6509808	\N	nancypini@caseificiopini.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.610977	2025-08-06 18:45:39.609653	\N
ae3bc735-496e-4ef6-aaa8-91c3d92b501f	\N	Fabrizio	Facchini	\N	ENERPETROLI S.R.L.	Ingegnere	\N	335 6893618	fabrizio.facchini@enerpetroli.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.614743	2025-08-06 18:45:39.613693	\N
272c715a-e5bc-478a-9394-2e161b743bc3	\N	Fabrizio	Facchini	\N	FOUR STARS PETROLEUM S.R.L.	Ingegnere	335 6893618	\N	fabrizio.facchini@fourstarspetroleum.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.618349	2025-08-06 18:45:39.617096	\N
645f238a-2b3e-4082-b100-4e27bd933280	\N	Fabrizio	Facchini	\N	VELKA PETROLI S.R.L.	Ingegnere	\N	335 6893618	velkap@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.621663	2025-08-06 18:45:39.620624	\N
0d597b63-ae3d-4e9d-958e-c568c4f6aaa7	\N	Maurizio	Pisani	\N	TEAM ITALIA S.R.L.	Referente	3357002050	\N	amm1@teamitaliailluminazione.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.62506	2025-08-06 18:45:39.623999	\N
566017b9-3221-4318-b46a-e0c1b63d3e48	\N	Cristian	Zaffani	\N	ZAFFANI CAR S.R.L.	Referente	347.9339547	\N	cristian@zaffanicar.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.628255	2025-08-06 18:45:39.627297	\N
a3b6d0a6-4765-4642-87bb-c8d138dd641d	\N	Monica	Galloni	\N	D.D.I. DI MANTOAN ANDREA & C. S.N.C.	Referente	329.4873818	\N	m.galloni@ddidisinfestazioni.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.631466	2025-08-06 18:45:39.630508	\N
599c4dcc-da10-44bc-8bab-495ca19b6ca8	\N	Domenico	Dall'Olio	\N	Applied S.r.l.	\N	345.1418879	\N	ddallolio@erere.it;domenico.dallolio@applied.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.63492	2025-08-06 18:45:39.63393	\N
113c571c-7539-4851-81f5-07437b301148	\N	Claudio	Maruzzi	\N	MGTM Avvocati Associati	Socio	329.8607474	\N	claudiomaruzzi@mgtm.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.641788	2025-08-06 18:45:39.640829	\N
1649ea60-808f-4f39-9671-9c365d705f68	\N	Giulia	Gioachin	\N	MGTM Avvocati Associati	\N	349.6534873	\N	giuliagioachin@mgtm.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.645707	2025-08-06 18:45:39.64467	\N
2833ebbe-e6c7-4cc3-b414-634c0fa199ca	\N	Alessia	Alessandri	\N	CENTRO OTTICO ARNO S.A.S. DI ALESSIA ALESSANDRI & C.	\N	\N	338 9720205	alessiaalessandri1975@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.649582	2025-08-06 18:45:39.648481	\N
b715cec2-cd01-437f-8c14-2cc4600488fc	\N	Lorenzo	Bucci	\N	GRUPPO PULITA S.R.L.	Referente	\N	334 9973655	info@lorenzobucci.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.653285	2025-08-06 18:45:39.652363	\N
808bcbb0-5901-4b19-97ae-9c89f5a9f847	\N	Fabio	Pedrotti	\N	NIPE SYSTEM S.R.L.	\N	\N	349 2402501	fabio.pedrotti@nipe.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.657038	2025-08-06 18:45:39.65604	\N
234babeb-0d8b-441d-8796-321e9f8a9f36	\N	Roberta	Di Donfrancesco	\N	DI DONFRANCESCO ROBERTA	Titolare	335.6667545	\N	dottoressaroberta1@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.661033	2025-08-06 18:45:39.660006	\N
3ef4b47a-5fa1-4817-a5d0-5262473b10c6	\N	Antonio	D'Isa	\N	SINESTESIA DI D'ISA ANTONIO	Titolare	347.1818911	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.665165	2025-08-06 18:45:39.664094	\N
09bce4a7-d8f7-4218-b83b-fa1ef0583ffc	\N	Paolo	Garbolino	\N	OTTICA GARBOLINO S.N.C. DI PAOLO GARBOLINO & C.	Titolare	\N	\N	paolo.garbolino@otticagarbolino.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.669286	2025-08-06 18:45:39.668242	\N
20d1cb7f-40eb-4e6e-b4f0-1d3c1740d7fb	\N	Veronica	Cardamone	\N	CARDAMONE VERONICA	Titolare	379.2796633	\N	veronicacardamone81@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.673367	2025-08-06 18:45:39.672262	\N
59b9170a-d28c-459a-a49a-6c0a54a54a6c	\N	Tiziana	Barile	\N	ZOSTAN S.A.S. DI ZOLIN STEFANO E C.	Referente	045.8103576 int 305	\N	tiziana.barile@zostan.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.677468	2025-08-06 18:45:39.676365	\N
aafcc606-3824-489c-abdd-89899ec9a1c6	\N	Roberta	Albonetti	\N	HOTEL UNIVERSAL S.R.L.	\N	071 7927474	\N	roberta@hoteluniversal.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.682005	2025-08-06 18:45:39.680657	\N
fac1d000-1b96-4e36-b04a-573160d01829	\N	Gian Luca	Pitzalis	\N	BAR SPORT DI PITZALIS GIAN LUCA	Referente	3331793306	\N	gianlucapitzalis@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.687009	2025-08-06 18:45:39.685428	\N
fe7ad2cc-1bf5-4979-895e-f18274e692d8	\N	Veronica	Cossu	\N	DI.GI. DI GIANCARLO PIRAS E DIEGO ARESTI S.N.C.	Referente	347.1970677	\N	cossu_veronica@hotmail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.691867	2025-08-06 18:45:39.690474	\N
e3550fc9-08dd-420e-9aac-8206b4341c5c	\N	Giancarlo	Piras	\N	DI.GI. DI GIANCARLO PIRAS E DIEGO ARESTI S.N.C.	Titolare	3925247277	\N	templewinebar@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.696481	2025-08-06 18:45:39.695317	\N
8b3dc058-3205-4a65-aeaa-d860d17f61ee	\N	Antonello	Scano	\N	DI.GI. DI GIANCARLO PIRAS E DIEGO ARESTI S.N.C.	Commercialista	347.5717056	\N	studio.scano@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.700334	2025-08-06 18:45:39.699336	\N
763449bc-11ca-4f35-b7b0-309c2d484ab3	\N	Ugo	Melis	\N	ALTSYS IMMOBILIARE S.N.C. DI UGO MELIS & C.	Titolare	3926724955	\N	melis@altsys.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.705154	2025-08-06 18:45:39.704129	\N
cfcea17e-de16-4bef-8167-8dbcd9077a75	\N	William	Congera	\N	DOMINIO  SARDEGNA S.R.L.	Referente	348.1802615	\N	william.congera@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.70966	2025-08-06 18:45:39.708355	\N
ae488e20-9ce8-4d3d-9811-f83a5342f4de	\N	Siro	Salehi	\N	SALEHI CONSULTING SOCIETA' A RESPONSABILITA' LIMITATA IN SIGLA  SALEHI CONSULTING S.R.L.	Titolare	\N	320 76378654	siro.salehi@salehiconsulting.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.713593	2025-08-06 18:45:39.712562	\N
0140e7f5-a3fb-4531-9a2b-ad3d6db8dc45	\N	William	Congera	\N	QUARTU STAGIONI S.R.L.	Referente	348.1802615	\N	william.congera@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.717705	2025-08-06 18:45:39.716451	\N
718403ec-5e92-4187-9d80-1a37d7c51031	\N	Emanuela	Proxienergy	\N	PROXIENERGY S.R.L.	Referente	3486152238	\N	emanuela.dalessandro@proxienergy.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.721696	2025-08-06 18:45:39.720505	\N
f0375e33-d436-456a-917c-c6a3e56733c8	\N	Ivano	Stecconi	\N	STE.MO S.R.L	Titolare	\N	329 8836130	stemo@stemo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.725454	2025-08-06 18:45:39.724337	\N
80c1d76f-90a0-435d-9cb9-d725c0ee52bc	\N	Antonio	Manca	\N	DESSI' ALESSANDRA S.R.L.	Referente	335.404752	\N	ditta.dessi@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.72941	2025-08-06 18:45:39.72819	\N
5f169987-e7de-4135-9d72-fb9d3b080055	\N	Sebastiano	Benassini	\N	RISTORANTE ADRIANA S.N.C. DEI F.LLI BENASSINI	Referente	328.9844173	\N	sebastianobenassini@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.733397	2025-08-06 18:45:39.732218	\N
55b89fc3-67df-4d22-b0d4-a20e996a4e9a	\N	Loredana	Ciurlia	\N	SOCIP S.R.L.	Referente	335.7627839	\N	l.ciurlia@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.737295	2025-08-06 18:45:39.736097	\N
1a7a55b5-dd07-4102-ab0f-a995d1f8459f	\N	Alessandro	Pallotta	\N	STALG DI V. PALLOTTA DI ROBERTO PALLOTTA	\N	\N	348 2460132	a.pallotta@stalg.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.741191	2025-08-06 18:45:39.740075	\N
beb3fcdf-f336-4018-8b74-a09052ad8c1d	\N	Alessia	Pasello	\N	PASELLO TRATTAMENTI TERMICI S.R.L.	\N	\N	333 7896917	alessia.pasello@pasello.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.745266	2025-08-06 18:45:39.744037	\N
7b3cf12c-3af9-4b59-a2d2-c0e2d5f8caea	\N	Lorenzo	Baldini	\N	LORENZO PASTICCERIA & CAFFE'DI BALDINI LORENZO	Titolare	333.4635073	\N	baldinilorenzo89@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.74984	2025-08-06 18:45:39.748466	\N
780f2770-2fc4-49c1-a280-fb0d9460e635	\N	Domenico	Amasino	\N	FENIMPRESE	\N	\N	345 2475157	d.amasino@fenimprese.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.754286	2025-08-06 18:45:39.753026	\N
493afaee-11a0-4a70-872e-3dd90a964abe	\N	Roberta	Bussinello	\N	BUSSINELLO S.R.L.	Titolare	\N	338 8965628	roberta@bussinellopetroli.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.758437	2025-08-06 18:45:39.757206	\N
18b36473-da60-422e-b6f1-216f431f1ea7	\N	Barbara	Zanini	\N	FAB ARREDAMENTI DI ZANINI BARBARA	Titolare	\N	348 6974660	info@fabarredamenti.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.762902	2025-08-06 18:45:39.761546	\N
88aba9fa-f8f0-4428-86ac-58c0a1bbb817	\N	Andrea	Dati	\N	DATI AUTOMOBILI DI DATI RENZO & C. S.R.L.	Socio	349.1924603	\N	emanuele.dati@datiutomobili.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.767641	2025-08-06 18:45:39.766312	\N
06834998-6e7c-47a2-923c-4e818c270eff	\N	Simona	Ferro	\N	BAGNO E DINTORNI DI FERRO CLAUDIO LORENZO	Referente	347.4991696	\N	ferro.v@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.772541	2025-08-06 18:45:39.771065	\N
c4448135-7004-460b-81ec-23d26fd019dd	\N	Daniela	Martis	\N	AUTOFFICINA GWIMAR DI SLAWOMIR GWIZDON	Referente	340.1187665	\N	info@ricambiautoweb.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.780862	2025-08-06 18:45:39.77945	\N
3271b005-efc6-421e-86f5-b7f331afbbc6	\N	Giacomo	Pondi	\N	I.SA.F Line Bagno S.r.l.	\N	333.1493464	\N	giacomo@isaflineabagno.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.7856	2025-08-06 18:45:39.784224	\N
e100f1a1-964a-43e2-bdb0-50c0dfd55847	\N	Francesco	Rasera	\N	INNOVATECH SRL	Titolare	+393409000538	\N	francesco.rasera@innovatechsrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.790034	2025-08-06 18:45:39.788758	\N
01d7620e-aa56-4b1a-abf8-dc367c6a61bb	\N	Fabrizio	Frombola	\N	12OZ COFFEE JOINT S.R.L.	Business Development Director	335.7753265	\N	fabrizio.frombola@12ozcj.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.794731	2025-08-06 18:45:39.793274	\N
56e540e8-bec4-4684-9c9f-ce18a5184e1c	\N	Mariano	Galizia	\N	5 EMME INFORMATICA - S.P.A.	Referente	\N	\N	marianogalizia@5minformatica.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.798882	2025-08-06 18:45:39.797946	\N
f0fa99a3-a326-4d27-8264-726921c1fa0a	\N	Mario	Costa	\N	5PM ADVISORY SRL	Senior Project Manager	320.3676798	\N	mario.costa@5pmadvisory.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.802881	2025-08-06 18:45:39.801657	\N
1a42f3e3-c7ee-4cf9-9af9-798050110122	\N	Davide	Facco	\N	A.C.I.S.	Presidente	347.5852664	\N	presidenza@confacis.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.806979	2025-08-06 18:45:39.806043	\N
153a577c-a1c3-4998-a990-45c9cdb0f6fa	\N	Gigliola	Biasiolli	\N	ABBREVIA S.P.A.	Direttore Amministrazione & Finanza	0461.1920491	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.810714	2025-08-06 18:45:39.809571	\N
54e4cc58-898a-4193-a072-aadb11c33c71	\N	Francesca	Zucca	\N	ALL INCLUSIVE S.R.L.	\N	\N	3492174634	allinclusivesrl.terralba@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.814854	2025-08-06 18:45:39.81361	\N
2e10812a-04d9-48e5-a324-e249b310c3c8	\N	Alessandra	Lorenzetti	\N	ACS DATA SYSTEMS S.P.A.	Responsabile Ricerca e Sviluppo	0471.063063	\N	alessia.lorenzetti@acs.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.818371	2025-08-06 18:45:39.81744	\N
c179bc07-5bfb-4cee-8746-77d858a37510	\N	Toni	Ingrao	\N	ADCONTRACT S.R.L.	Referente	334.7000963	\N	support@adcontract.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.822145	2025-08-06 18:45:39.820886	\N
e7922a5e-d8c4-41b8-a1d4-574dd310909c	\N	Corrado	Creston Addvalue	\N	ADD VALUE S.R.L.	Partner & CEO	348 901 0230	\N	corrado.creston@addvalue.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.826584	2025-08-06 18:45:39.825205	\N
02be65c0-0784-4b5c-ac45-78727e18cca2	\N	Moreno	Domenichini	\N	ADD VALUE S.R.L.	Partner, Finance and Amministration Manager	348.9010232	\N	moreno.domenichini@addvalue.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.83061	2025-08-06 18:45:39.829619	\N
d1a13bc8-a868-4c3e-9fe8-831463eac36c	\N	Fabio	Denegri	\N	HAPPILY S.R.L. SOCIETA' BENEFIT	\N	\N	335 7588911	fabio@happily-welfare.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.834491	2025-08-06 18:45:39.833528	\N
96f8b3bd-b3ee-4aa0-9a81-cd932ea36573	\N	Fabio	Conforti	\N	HEDERA S.R.L.	\N	\N	347 3363114	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.838059	2025-08-06 18:45:39.837133	\N
3ec0207c-2621-4917-85c7-8bbab87d5bfa	\N	Flavio	Croce	\N	HEDERA S.R.L.	\N	\N	349 4712559	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.841761	2025-08-06 18:45:39.840737	\N
902a1b6a-72e5-4faa-a685-8341b3c63499	\N	Evelyn	Gruber	\N	HELIUM S.R.L.	\N	\N	349 8657244	evelyn@smartpricing.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.845743	2025-08-06 18:45:39.844712	\N
df4b80ef-1688-4135-a123-96db15587572	\N	Marzia	Margheriti	\N	HIBRO S.R.L.	\N	\N	347 1454922	marzia@vintro.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.849506	2025-08-06 18:45:39.84857	\N
b2762e0f-3681-4e1e-912a-2e9aa7b36d16	\N	J. Sebastian	Matte Bon	\N	HERZUM S.R.L.	\N	\N	335 5422307	mattebon@herzum.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.853263	2025-08-06 18:45:39.852245	\N
e5d6c86b-2656-465c-8445-9dee1d26542e	\N	Luca	Di Giacomo	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.856847	2025-08-06 18:45:39.855984	\N
60a9e6d9-8997-4ad4-903b-bf8e629793be	\N	Francesco	Lambroia	\N	AGENZIA VALBORMIDA DI LAMBROIA FRANCESCO	Referente	335.7209155	\N	lambroiafr55@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.861288	2025-08-06 18:45:39.859838	\N
76881b2f-0bbd-4aac-834d-2cadefa88d00	\N	Daniele	Cannalire	\N	AGRUSTI & C. S.R.L.	Referente	338.4854794	\N	d.cannalire@agrusti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.866354	2025-08-06 18:45:39.864542	\N
464bae9d-20ce-4877-a4e2-b5a8f535f4d5	\N	Nicola	Agrusti	\N	AGRUSTI & C. S.R.L.	Titolare	331.7820888	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.871374	2025-08-06 18:45:39.870116	\N
989b1e39-66b8-4689-9f80-080d1f9deb7a	\N	Greta	Mutti	\N	AL VECCHIO PALAZZO S.R.L.	Referente	0365.88761	\N	info@vecchiopalazzo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.874942	2025-08-06 18:45:39.87392	\N
8728caa4-2ef2-4cde-85a5-2806e7417525	\N	Raffaela	Casini	\N	ALA SERVICE S.R.L.	Titolare	348.2208936	\N	lela@alaservice.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.877879	2025-08-06 18:45:39.877044	\N
7c4ffde9-a629-4148-b6b6-6cf7ef3aeed8	\N	Marta	Fiorentini	\N	ALBRICCI NOVE S.R.L.	Referente	\N	\N	marta@agbassociati.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.883188	2025-08-06 18:45:39.882408	\N
db1b08f3-f509-49fb-bce2-3359c29f52e2	\N	Eros	Peronato	\N	AMAJOR S.P.A. SOCIETA' BENEFIT	Referente	345.5601941	\N	eros.peronato@amajorsb.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.886213	2025-08-06 18:45:39.88528	\N
2b5ffa0b-6c66-43a9-971e-c8fc32423775	\N	Martina	Waddel	\N	AMMINISTRAZIONI MAJ S.R.L.	Referente	333.7864185	\N	Amministrazioni Maj S.r.l.	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.890279	2025-08-06 18:45:39.88832	\N
b0f9d07a-d386-4a01-b3e3-6d79d3e3ad28	\N	Massimo	Marini	\N	ANALYSIS S.R.L. - SOFTWARE E RICERCA	Responsabile Commerciale e Marketing	342.5783054	\N	mmarini@qualiware.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.895696	2025-08-06 18:45:39.894775	\N
fdf5da0b-c16e-47c1-830a-31f15ac15282	\N	Nicolò	Veronesi	\N	ANTI S.R.L.	Figlio Del Titolare	347.0178620	\N	nicolo.veronesi@calzedonia.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.89949	2025-08-06 18:45:39.898534	\N
94708502-e720-4d35-b53a-b3a89ec55cd9	\N	Matteo	Facchetti	\N	M.C.S. FACCHETTI S.R.L.	Responsabile Amministrazione	+390365890209	\N	matteo.facchetti@mcsfacchetti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.90242	2025-08-06 18:45:39.901625	\N
63e3932f-0f20-464d-8372-e1e5440233a7	\N	Ivan	Ciman	\N	HOME FOOD DI CARLUCCI GIULIA	Referente	\N	391 3626683	homefoodvicenza@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.905584	2025-08-06 18:45:39.904484	\N
de264112-3c20-44a7-816c-68e2c7450038	\N	Luca	Sfamurri	\N	TEKNET S.R.L.	Titolare	\N	338 8500835	luca@teknet.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.908499	2025-08-06 18:45:39.907693	\N
7f58f36f-0c23-4a93-9c31-ec9924d7f726	\N	Simone	Pazzaglia	\N	ASTRA RESEARCH SRL	Chief Marketing Officier	331.7950273	\N	simone.pazzaglia@astraresearch.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.911511	2025-08-06 18:45:39.910667	\N
2629aafc-e0d7-4a76-acec-7a54fb92d08e	\N	Chiara	De Mattia	\N	M.C.G. CONSULTING SRL	Referente	329.8503404	\N	ateliercdcgenova@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.914966	2025-08-06 18:45:39.914109	\N
5f019b87-52f7-46b2-adcc-584ff90cb3c1	\N	Federico	Porcu	\N	ATLANTIAS SRL	Referente	347.5280187	\N	amministrazione@illidorestaurant.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.918098	2025-08-06 18:45:39.917295	\N
14c4039a-3497-4f43-92ba-12a7b004e201	\N	Fabio	Porro	\N	AUTO 180 S.P.A.	Responsabile Network	349.3957661	\N	fabio.porro@auto180.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.921092	2025-08-06 18:45:39.920272	\N
312782fc-9d16-4f4c-8bb9-356bcf99078a	\N	Marianna	Consiglio	\N	F & F GESTIONI S.R.L.	Referente	045 995000	347 0894444	direzione@hotelcatulloverona.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.924091	2025-08-06 18:45:39.923239	\N
dca7d5dc-760b-4495-b86a-16831ac671d8	\N	Massimo	Galeazzo	\N	MOTORICAMBI 2000 S.R.L.	Titolare	347.8513137	\N	maximilian19@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.92702	2025-08-06 18:45:39.926187	\N
461fa9e3-ce49-4396-88a9-660644c7f94f	\N	Marco	Paoloni	\N	PRASCO SPA	Referente	051 766441  ;335 6115843	\N	marco.paoloni@prasco.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.930052	2025-08-06 18:45:39.92925	\N
a58925b0-b541-4aeb-b034-54a1fd6862a8	\N	Jacopo	Venturi	\N	PREVEN S.R.L.	\N	051 969125	339 8968505	jacopo.venturi@preventsrl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.932832	2025-08-06 18:45:39.93206	\N
73e47c7e-7d77-4643-a9bd-7e8fc53c9d9f	\N	Marta	Monte Tondo	\N	AZ.AGR.MONTETONDO DI MAGNABOSCO GINO E MARTA E TOLO MARIA PAOLA SOCIETA' AGRICOLA	Titolare	045.7680347	\N	marta@montetondo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.935722	2025-08-06 18:45:39.934967	\N
692e858e-4296-4473-973d-403dd420a0d6	\N	Angelo Michele	Zurillo	\N	IVARS S.P.A.	Responsabile Amministrativo	3666719460	\N	angelo.zurillo@ivars.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.939032	2025-08-06 18:45:39.93823	\N
500aa326-30d3-4897-b25c-c6d7392f976e	\N	Barbara	Pippia	\N	PUBBLICITAS S.R.L.	Referente	\N	346 8957443	amministrazione@pubblicitas.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.942145	2025-08-06 18:45:39.941376	\N
5426b4a6-c275-4eb7-9d58-17ff9412237f	\N	Emanuele	Rubini	\N	PRSE S.R.L. SOCIETA' BENEFIT	Referente	\N	339 1386196	emanuele.rubini@prse-srl.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.945063	2025-08-06 18:45:39.944296	\N
1eed2402-8940-44fa-a97f-a9ebe8b72fce	\N	Stefano	Petris	\N	PROSCIUTTIFICIO WOLF SAURIS S.P.A.	Referente	\N	335 415198	stefano.p@wolfsauris.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.948105	2025-08-06 18:45:39.947359	\N
83be9d44-0eaa-4fcb-a49f-e09229120465	\N	Giuseppe	Bisi	\N	PRONTOFOODS - S.P.A.	\N	030 9961381	\N	g.bisi@ristora.com  030.9961381	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.950881	2025-08-06 18:45:39.950131	\N
49493565-0294-4085-8d40-859938f41588	\N	Alessandra	Ribani	\N	CARROZZERIA AUTOSERVICE RIBANI S.R.L.	Titolare	\N	\N	alessandraribani@autoserviceribani.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.953909	2025-08-06 18:45:39.953086	\N
4342dd3c-9e53-4cf8-8eaf-badac068fd37	\N	Pietro	Mattioli	\N	PROFILGLASS S.P.A.	\N	\N	335 6340465	pietro.mattioli@profilglass.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.956928	2025-08-06 18:45:39.956111	\N
efe42a34-150c-48a7-b9a5-47fb327f761c	\N	F	Paesano	\N	PROBIOS S.R.L. SOCIETA' BENEFIT	\N	\N	053 886931	f.paesano@probios.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.959766	2025-08-06 18:45:39.959042	\N
215c2962-18d3-40a5-b48b-7dbb854e6ab9	\N	Simone	Benetazzo	\N	PROEVO SRL	\N	049 8074467	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.962702	2025-08-06 18:45:39.961926	\N
4f6e3739-2c9b-4a95-909e-6aa4c9648f54	\N	Manlio	Reffo	\N	BAGS4DREAMS S.R.L.	Referente	328.4749301	\N	m.reffo@bags4dreams.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.96577	2025-08-06 18:45:39.965007	\N
4c5e792f-51f2-45d3-9bc9-d461fdfd636b	\N	Roberto	Corbin	\N	ERAS - S.R.L. ( Baia Flaminia Resort)	Titolare	349.8783980	\N	direzione@hotelbaiaflaminia.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.969442	2025-08-06 18:45:39.968224	\N
41fb8fac-95bd-4007-963f-7196ed9b5e13	\N	Catia	Cassanelli	\N	CASSANELLI CATIA ( Bar gelateria su di giri)	Titolare	339.7855128	\N	bargelateria2018@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.9729	2025-08-06 18:45:39.971999	\N
310f26be-8326-483e-b37b-a97c10a10ebb	\N	Gregorio	Gesummaria	\N	GEPAM S.R.L.	Referente	329 274 5579	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.976101	2025-08-06 18:45:39.975271	\N
dacb9e9d-609b-4f01-b8f4-fcdad0e131fa	\N	Salvatore	Siciliano	\N	SALVATORE BARBER SHOP DI SICILIANO SALVATORE	Titolare	347.5921750	\N	info@tallisciuupilu.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.979165	2025-08-06 18:45:39.978316	\N
77c1e4dc-202e-4ce3-bd7a-8383235c02da	\N	Cristina	Barracca	\N	BARRACCA OFFICE S.R.L.	Titolare	\N	\N	ordini@barraccaoffice.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.982315	2025-08-06 18:45:39.98144	\N
0885516d-e028-4b9c-96cc-e58fd20661f5	\N	Giorgio	Dongu	\N	BBYACHT SRL	Referente	333.1253558	\N	giorgiodongu@bbyacht.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.986011	2025-08-06 18:45:39.984818	\N
cd7af035-3c0f-42aa-ab00-8d3c0de23d77	\N	Antonino	Finarelli	\N	BDF INDUSTRIES S.P.A.	Tecnical Manager - Melitng	345.6957706	\N	a.finarelli@bdf.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.99258	2025-08-06 18:45:39.991366	\N
3c60a210-ece2-4056-9878-8d06f895314d	\N	Luca	Anastasia	\N	HUKO SRL	\N	\N	392 4625168	lan@huko.hk	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:39.996091	2025-08-06 18:45:39.994905	\N
7e1b5ded-1189-4d90-b28a-1177f65f5460	\N	Carol	Morzilli	\N	HOTELTURIST S.P.A.	Responsabile Finanziaria	\N	\N	carol.morzilli@th-resorts.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.00008	2025-08-06 18:45:39.998746	\N
617fb8ab-14f6-4101-8f96-d01f7f117821	\N	Stefano	Golisano	\N	CITY HOUSE SRL	\N	\N	\N	stefanogolisano@outlook.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.007297	2025-08-06 18:45:40.005833	\N
ed6de672-27d6-431a-8e3c-b5c10abc6927	\N	Maria Luisa	Bellè	\N	BELLE' ANTONIO SUCC.RI S.R.L.	Referente	335.7795752	\N	Bellè Antonio Successori Srl	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.013567	2025-08-06 18:45:40.010486	\N
736bba53-bacb-4c77-b124-e21add47aa7b	\N	Rachele	Toscana Verde	\N	ARABA FENICE S.R.L.	Titolare	\N	366 5093668	rachele@toscanaverde.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.017558	2025-08-06 18:45:40.016544	\N
d36c7f62-4b1b-4bba-b6f3-da403deaa98a	\N	Nicola	Di Lorenzo	\N	ARABA FENICE S.R.L.	Direttore	\N	\N	nicoladilorenzo.chef@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.021375	2025-08-06 18:45:40.020324	\N
898cf698-8876-4b14-9940-0b67babe8801	\N	Elisa	Cicognani	\N	BERARDI BULLONERIE S.R.L.	Referente	0542.671911	\N	info@gberardi.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.025013	2025-08-06 18:45:40.02413	\N
2a0e26af-ff82-488b-9f72-10ced954e40e	\N	Paolo	Mayer	\N	ALBERGO MAYER E SPLENDID DI MAYER GIUSEPPE E C. S.A.S.	\N	\N	\N	p.mayer@splendidmayer.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.028912	2025-08-06 18:45:40.027708	\N
ed84ddd6-0bb2-47f3-9a68-d46ae4fb4cdb	\N	Anna	Bai	\N	BEST TOOL S.R.L.	Referente	342.8075186	\N	anna.bai@besttool.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.032684	2025-08-06 18:45:40.031562	\N
d9fc5f71-c132-4617-a115-617b28943970	\N	Marco	Fazzoli	\N	BEST TOOL S.R.L.	Sales Executive	335.8470337	\N	marco.fazzoli@besttool.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.03667	2025-08-06 18:45:40.035545	\N
1d6bd339-275e-4486-b230-abfc3de3949a	\N	Matteo	Capitani	\N	BEST TOOL S.R.L.	Vice President	331.4857423	\N	matteo.capitani@besttool.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.040378	2025-08-06 18:45:40.039439	\N
e866fc91-c95e-45fd-99f2-e1ab06526282	\N	Piero	Tinnirello	\N	BEST TOOL S.R.L.	President	334.3555924	\N	piero.tinnirello@besttool.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.043728	2025-08-06 18:45:40.042857	\N
7b02523c-fae1-4d03-89bd-499f6a4aa676	\N	Elisabetta	Baini	\N	BETACOM SRL	Account Manager	366.6180947	\N	e.baini@betacom.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.047065	2025-08-06 18:45:40.046182	\N
4ca4d28c-7bc8-4cde-ad6d-a69c7d48f789	\N	Severino	Bettini	\N	BETTINI GROUP DI SEVERINO BETTINI	Titolare	329.1779292	\N	severino@bettinigroup.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.050491	2025-08-06 18:45:40.049567	\N
22fd5f8f-b971-4691-9705-e68115690f31	\N	Nicole	Paganotto	\N	BEVANDE VERONA S.R.L.	Referente	347.3924905	\N	nicolepaganotto@bevandeverona.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.053867	2025-08-06 18:45:40.05291	\N
810b5205-c0aa-466f-8f47-e9ff1bdb326a	\N	Fabio	Biasibetti	\N	BIASIBETTI S.N.C. DI BIASIBETTI FABIO E C.	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.057068	2025-08-06 18:45:40.056205	\N
c97d6bfc-f92d-432f-b94b-b8f6e8e4a51f	\N	Arianna	Zanotti	\N	BIOZETA FARM DI SALVATI GIUSEPPA E C. - S.A.S.	Referente	347.9167921	\N	info@biozeta.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.06045	2025-08-06 18:45:40.059401	\N
f128824b-a840-4dd0-9b4b-a456c24d474e	\N	Simone	Trevisan	\N	BLUETENSOR S.R.L.	Referente	347.4300174	\N	simone.trevisan@bluetensor.ai	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.063864	2025-08-06 18:45:40.062859	\N
ee5a2629-d3fa-4dd2-962a-e1257e79d7b4	\N	Paolo	Lipparini	\N	BO.RI. S.R.L.	Titolare	348.7046295	\N	paolo@bori.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.067341	2025-08-06 18:45:40.0663	\N
e237ef16-26ec-44a0-ba4f-ff02dd70832b	\N	Stefano	Ottaviani	\N	BOMA 77 S.R.L.	Referente	347.9801059	\N	stefano@boma77.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.071618	2025-08-06 18:45:40.070344	\N
e620e673-4aaf-48cc-b4ae-c39d559793eb	\N	Mattia	Donnola	\N	BOMA 77 S.R.L.	Titolare	393.9749372	\N	mattia@boma77.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.076136	2025-08-06 18:45:40.075046	\N
3e979bc8-6ad1-41c9-9660-c3d2ff55763b	\N	Elisa	Michelini	\N	BRAVA S.R.L.	Referente	348.2882223	\N	info@bravasrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.080506	2025-08-06 18:45:40.079343	\N
63c5eace-b3a3-4445-a8ae-832c107499d7	\N	Federica	Bressan	\N	BRESSAN VALVOLE SRL	Socia	335.7299701	\N	bressanvalvole@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.08519	2025-08-06 18:45:40.083742	\N
8bb2780b-e0d7-4948-b3e9-fd47efb39353	\N	Patrizia	Medda	\N	I MARINAI S.R.L.S.	\N	\N	\N	info@imarinai.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.090307	2025-08-06 18:45:40.089002	\N
d3323566-6abc-409d-abd1-46598c41d3ff	\N	Simone	Schenk	\N	ICIT-SOFTWARE SRL	\N	\N	348 8060195	s.schenk@icit-software.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.095923	2025-08-06 18:45:40.094333	\N
23a81026-4d60-4beb-bc5a-66109be6dafc	\N	Salvatore	Brogna	\N	IDNOVA S.R.L.	\N	\N	334 3634228	sales.rfid@idnova.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.100471	2025-08-06 18:45:40.099321	\N
d7953b91-2084-4f48-8e93-eccddaa466f5	\N	Giovanni	Sandiano	\N	\N	\N	\N	329 5388356	giovanni.sandiano@utexco.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.104109	2025-08-06 18:45:40.10345	\N
9b373ac4-5b7f-403e-8437-889a344bbd74	\N	Marco	Altieri	\N	I.C.P. S.P.A.	Referente	0545 40182 (Int. 228)	348 4075442	marco.altieri@icpspa.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.108149	2025-08-06 18:45:40.107064	\N
383e88bb-584c-460e-a572-a9d43db8c891	\N	Ivan	Troncon	\N	IDROSERVICE S.R.L.	\N	392 1448941	\N	ivan@idroserviceferrara.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.112048	2025-08-06 18:45:40.111047	\N
79730541-2ee6-45d7-91d9-95b2667e9b25	\N	Alessandra	Mauri	\N	BULLONERIE RIUNITE ROMAGNA S.P.A.	Amministrativa	0543.723240	\N	info@bullonerieromagna.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.115789	2025-08-06 18:45:40.114898	\N
c79ad73d-699b-421b-b79e-c2cbd7c1846c	\N	Roberto	Serrago	\N	C QUADRA S.R.L.	Referente	392.1416362	\N	innovazione@c-quadra.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.120182	2025-08-06 18:45:40.119008	\N
cc1b4978-dc61-471c-9e6d-679e2ebb6eef	\N	Angelo	Nicolosi	\N	C.A. BROKER S.R.L.	Titolare	320.8625302	\N	angelo.nicolosi@cabrokersrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.123919	2025-08-06 18:45:40.122847	\N
a06cb168-baf0-42ba-ad9c-7a24230764ad	\N	Enrico	Marangoni	\N	C.E.D. - CENTRO ELABORAZIONE DATI S.R.L.	Referente	051.904468	\N	marangoni@studiocedsrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.127209	2025-08-06 18:45:40.126324	\N
db15ea30-8593-4b1a-a037-777772b368d9	\N	Massimiliano	Golfieri	\N	CABLOTECH - S.R.L.	Production Manager	051.6950936	\N	m.golfieri@cablotech.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.130255	2025-08-06 18:45:40.129349	\N
b03dcee8-552b-4734-b5bd-c32a593d2fcc	\N	Agron	Morina	\N	MORINA AGRON E C. SNC	\N	\N	328 3171558	anfiteatrotrento@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.133253	2025-08-06 18:45:40.132407	\N
6b82646f-c788-40a6-bc16-fb1e4e52e69a	\N	Loris	Micheletti	\N	MORINA AGRON E C. SNC	Commercialista	0463 902692	\N	loris@lo-studio.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.136708	2025-08-06 18:45:40.135785	\N
c3143853-0ea6-4cd6-bce8-7d8598138674	\N	Luisa	Michelotti	\N	MORINA AGRON E C. SNC	Consulente	0463 902692	\N	luisa@lo-studio.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.140287	2025-08-06 18:45:40.139246	\N
cf3ea7ed-34b2-45e2-ac65-33aa4c2ad66f	\N	Mauro	Pruzzo	\N	SE.GE.SA. SERVIZI E GESTIONI SOCIO ASSISTENZIALI - S.R.L.	Legale Rappresentante	\N	348 2326841	pruzz@iol.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.144279	2025-08-06 18:45:40.143247	\N
062c34c7-76b4-44a6-89c2-1aaa6f075060	\N	Roberto	Agosti	\N	B & R S.R.L.	Titolare	\N	338 5097258	info@birrificio-pizzagrill.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.148186	2025-08-06 18:45:40.147142	\N
b2dea633-cfc2-4152-a240-3a98e9c2bd21	\N	Paolo	Corsi	\N	PIZZEGHELLA E STEVAN S.R.L.	Titolare	\N	349 6086612	paolo.corsi@stevanelevatori.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.151657	2025-08-06 18:45:40.150712	\N
a2476e0c-1abf-48fd-9c3b-f486200a721c	\N	Andrea	Frustoli	\N	PIZZEGHELLA E STEVAN S.R.L.	\N	\N	348 2889029	andrea.frustoli@stevanelevatori.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.155144	2025-08-06 18:45:40.154227	\N
881885a5-e212-43bd-bd7d-deeb1d1cc0b7	\N	Barbara	Pereto	\N	PODERE PERETO DI BORDONI FRANCO	\N	0577 704719	\N	info@poderepereto.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.158316	2025-08-06 18:45:40.157495	\N
299210fd-5e67-4769-bc9c-5cb27917c01c	\N	Luca	Ferrari	\N	POIANO S.P.A.	\N	045 7200100	\N	direzione@poiano.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.161482	2025-08-06 18:45:40.160618	\N
976ec9cd-8379-402a-b308-2c079ae5b1ad	\N	Matteo	Rigo	\N	P.K. GROUP S.R.L.	\N	\N	333 3831012	matteo.rigo@prokeepers.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.164541	2025-08-06 18:45:40.163698	\N
fc0f2bd7-b9e5-4dae-91b8-9255e1c981c7	\N	Domenico	Folla	\N	LA TORRE DI DOMENICO FOLLA & C.  S.A.S.	Titolare	335 6770364	\N	latorrefolla@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.168174	2025-08-06 18:45:40.167146	\N
c33bad63-042a-482d-85b5-3a39636ddad9	\N	Marco	Mura	\N	DAMAX S.R.L.	\N	349 3777380	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.171771	2025-08-06 18:45:40.170563	\N
9630a623-e6c2-4bfa-b76d-52f37074ff49	\N	Massimiliano	Salustri	\N	CMD ROMA S.R.L. (Campo Marzio)	Referente	392.3376053	\N	m.salustri@campomarzio.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.176389	2025-08-06 18:45:40.174589	\N
b4f3e47d-a3d7-41fb-9aaf-2c158c5b688f	\N	Marco	Fantato	\N	CARPINOX  S.A.S. DI CESTA LUIGI & C.	Referente	348.5656590	\N	marco.fantato@carpinoxgroup.eu	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.180618	2025-08-06 18:45:40.179325	\N
af48defe-97d2-4970-9ace-612db86d575b	\N	Flavio	Carraro	\N	EFFEKAPPA INVESTIMENTI S.R.L.	Referente	392.4825399	\N	amministrazione@carrarohotels.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.184176	2025-08-06 18:45:40.183158	\N
349b602f-9460-47f6-ac8f-dfc60fcf24c7	\N	Michele	Paderno	\N	CARROZZERIA LA BETTOLA DI PADERNO MICHELE	Titolare	\N	\N	michelepaderno84@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.187942	2025-08-06 18:45:40.186975	\N
a6100dad-3cd1-4b45-85e3-b9f57542b3ff	\N	Elisabetta	Brusori	\N	CARTABIANCA S.R.L.	Referente	334.5646614	\N	amministrazione@cartabiancacafe.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.191135	2025-08-06 18:45:40.190111	\N
d7d4e75d-fda1-4b25-9d5b-da1eb772f6cc	\N	Marlon	Kaculi	\N	HAGLEITNER HYGIENE CARTEMANI SRL	Referente	335.6373216	\N	marlon.kaculi@hagleitner.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.195309	2025-08-06 18:45:40.193844	\N
4da7895a-7ea5-42cb-9add-3bfb3517fb35	\N	Fabio	Castiglia	\N	CASTIGLIA COSTRUZIONI INDUSTRIALI S.R.L.	Titolare	333.3584255	\N	f.castiglia@castigliacostruzioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.20191	2025-08-06 18:45:40.200943	\N
3da1e185-9a95-4472-9dca-741883c5bf6b	\N	Martina	Guarino	\N	IMMOBILIARE MAGGIOLINA S.A.S. DI GUARINO ZAVVARONE MARTINA & C.	\N	\N	333 2089334	t.tty87@hotmail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.206216	2025-08-06 18:45:40.204795	\N
8e26fdf8-2019-4396-a64e-5b82d8721777	\N	Laura	Giacometti	\N	Ne.s.c.e. Consulting Srl	\N	345.9925297	\N	l.giacometti@nesce-consulting.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.210971	2025-08-06 18:45:40.209557	\N
9d9ded66-2959-4993-b7aa-0894be49b258	\N	Lorenzo	Nardi	\N	AMALI SRL	\N	\N	\N	nardi.lorenzo91@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.215109	2025-08-06 18:45:40.213848	\N
fd76a5de-4c30-4d45-b349-21365657f960	\N	Alex	Brognara	\N	AMALI SRL	\N	351.5008163	\N	brognara06@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.218793	2025-08-06 18:45:40.217844	\N
32ffe0c2-5eca-44d7-a059-c23dfda796b0	\N	Alberto	Augustini	\N	CATTEL S.P.A.	Referente	0421.355311	\N	alberto.augustini@cattel.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.221919	2025-08-06 18:45:40.221003	\N
176824c6-ebe4-4b70-b081-04879bf01813	\N	Nicola	Canessa	\N	CBA LAB SOCIETA' A RESPONSABILITA LIMITATA O, IN FORMA ABBREVIATA , CBA LAB S.R.L	Referente	02.778061	\N	nicola.canessa@cbalex.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.224961	2025-08-06 18:45:40.224156	\N
03dde5e7-3458-431e-97ee-dfa33800fcd5	\N	Giovanna	Avanzi	\N	ATLANTE S.R.L.	Responsabile Amministrazione e Contabilità	338.6830137	\N	giovanna.atlante@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.228108	2025-08-06 18:45:40.227217	\N
15312193-b0d4-4368-a489-749658d80c44	\N	Andrea	Gagliardi	\N	NetLite snc	\N	340.0692741	\N	andrea.gagliardi@auctory.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.231146	2025-08-06 18:45:40.230269	\N
7c2500b3-e4c3-4ac9-84ce-c0db0dcc6e32	\N	Daniele	Cabassi	\N	NetLite snc	\N	\N	\N	daniele.cabassi@auctory.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.234329	2025-08-06 18:45:40.233522	\N
1da98808-91f7-4344-af54-00ed0346f639	\N	Matteo	Cazzador	\N	NetLite snc	\N	\N	\N	matteo.cazzador@auctory.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.237245	2025-08-06 18:45:40.236414	\N
27c47c29-824f-407a-a85c-fc2edf8cbdc4	\N	Marco	Benvegnù	\N	CASOIN ONLINE SRL	Titolare	377.3451998	\N	info@casoinonline.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.240068	2025-08-06 18:45:40.239322	\N
63850d4f-0f9b-4e52-b8e6-d0d586c65ad8	\N	Guido	Bertellotti	\N	CENTRO IMPIANTI S.R.L.	Referente	347.0545404	\N	guido.bertellotti@centroimpianti.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.24297	2025-08-06 18:45:40.24209	\N
9187ccc0-1ae1-42d8-9907-10cccaecff6a	\N	Giovanni	Serra	\N	IMPRESA EDILE S.G.B. DI SERRA GIOVANNI	Referente	380 5128504	\N	info@impresasgb.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.246273	2025-08-06 18:45:40.245425	\N
60c03ae2-6a87-4a7a-a9c8-9c32cd456d1f	\N	Gian Piero	Cristoni	\N	CENTRO OTTICO ANZOLA S.R.L.	Referente	335.5255221	\N	centrootticoanzola@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.249252	2025-08-06 18:45:40.248469	\N
1656ef83-e71a-469c-8253-46867c905cff	\N	Federico	Calamelli	\N	CENTRO OTTICO CREVALCORE DI CALAMELLI FEDERICO & C. S.A.S.	Referente	335.5620205	\N	cocrevalcore@iol.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.252236	2025-08-06 18:45:40.251419	\N
5bdb3dc2-fc44-4c97-a4a7-896d6e59b4e9	\N	Irene	Tardioli	\N	CENTRO RADIODIAGNOSTICO BARBIERI SRL	Referente	349.2529672	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.255331	2025-08-06 18:45:40.254451	\N
be61879c-4a6a-4ac7-9027-a56b99cb91da	\N	Carlo	Dammicco	\N	DAMMICCO S.R.L.	Titolare	02.3659 2977	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.259212	2025-08-06 18:45:40.257978	\N
616f169d-ade7-4765-b8c0-272842c44be4	\N	Maura	Luzzi	\N	CENTRO SUB PORTOROTONDO SNC DI PATRIZIA MEDDA & C. POTRA' AVVALERSI DELLA RAGIONE SOCIALE ABBREVIATA CENTRO SUB PORTOROTONDO SNC	Referente	339. 6184490	\N	csubportorotondo@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.264268	2025-08-06 18:45:40.263012	\N
03cc165e-dfcd-4462-b3be-7760d3e9e5a8	\N	Fabrizio	Maiocco	\N	CGM VERSE S.R.L.	Titolare	329.2318978	\N	fabrizio.maiocco@cgm-verse.io	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.269287	2025-08-06 18:45:40.268002	\N
f1be02e3-bb7a-4e04-b999-9fb31f006561	\N	Manuel	Leardini	\N	CHILEA RAPPRESENTANZE SRL	Socio	320.0722882	\N	manuel.leardini@chilearappresentanze.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.273108	2025-08-06 18:45:40.272154	\N
3f59a188-8a76-4845-95a6-9de608683f37	\N	Paolo	Chizzola	\N	CHILEA RAPPRESENTANZE SRL	Socio	348.2204718	\N	paolo.chizzola@chilearappresentanze.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.277138	2025-08-06 18:45:40.275767	\N
5fd22c10-1c26-438a-b4ec-3519c9a57a90	\N	Fabrizio	Ragaiolo	\N	CHILEA RAPPRESENTANZE SRL	Socio	340.8211650	\N	fabrizio.ragaiolo@chilearappresentanze.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.280724	2025-08-06 18:45:40.279534	\N
ff783d21-8135-4343-a254-6c4840250dba	\N	Gianluca	Granati	\N	CISCRA S.P.A.	Referente	338.2147931	\N	gianluca.granati@ciscra.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.283954	2025-08-06 18:45:40.283112	\N
11e3ab69-77b0-48ce-9306-61d74605388e	\N	Omar	Furgeri	\N	CLEF S.R.L.	Titolare	348.9730627	\N	omar.furgeri@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.286988	2025-08-06 18:45:40.286135	\N
edbc0011-60ec-4daf-976d-bee3d23bd1a0	\N	Paolo	Ferrari	\N	CLIMA TECNIKA S.R.L.	Referente	333.7766474	\N	info@climatecnika.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.290264	2025-08-06 18:45:40.289249	\N
c52db7e4-118c-4aca-9294-a2280f783fce	\N	Maria	Sagula	\N	CMC VENTILAZIONE S.R.L.	Titolare	348.7478428	\N	maria@cmcventilazione.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.293771	2025-08-06 18:45:40.292788	\N
6a18547c-64da-4148-9b8b-d681e86955a1	\N	Antonio	Venturini	\N	CMEV S.R.L.	Referente	389.4777760	\N	direzione@cmev.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.29797	2025-08-06 18:45:40.296439	\N
037721a9-bc41-4dfa-8bf0-dea67070e0a0	\N	Paolo	Lombardo	\N	\N	Revisore	\N	335 8135128	info@studio-lombardo.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.420327	2025-08-06 18:45:40.419709	\N
013da4dc-c025-46a1-bf96-02a1751c611e	\N	Filippo	Zago	\N	\N	Referente	346.6257701	\N	funfactory@funfactorymode.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.551123	2025-08-06 18:45:40.550615	\N
a02cc000-ce50-4d1c-a537-b7d74f3dfb51	\N	Franco	Cordano	\N	\N	Partner	\N	335 6366317	franco.cordano@dscsrl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.594944	2025-08-06 18:45:40.594481	\N
8f33a69c-d7c5-4501-a834-e26ffd228b89	\N	Guido	Nelli	\N	\N	Titolare	338.6955592	\N	guido.nelli@nelli1956.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.667608	2025-08-06 18:45:40.666982	\N
80b1253c-f3e1-42c1-a972-6a9484414ebe	\N	Antonio	Fiumi	\N	RENO SUPERMERCATI S.R.L.	Referente	335.7557932	\N	totte05@tiscali.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.712007	2025-08-06 18:45:40.711074	\N
52cbeec2-bc8e-49a3-8d43-614c129e9b66	\N	Giorgio	Giaretta	\N	WARDA S.R.L.	Referente	\N	\N	giorgio@rielloepartners.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.715701	2025-08-06 18:45:40.714857	\N
81277077-193d-4750-897d-e3c1fb68ce1a	\N	Gilberto	Righetti	\N	RIGHETTI S.R.L.	Titolare	045.7157621	\N	info@righettisollevamenti.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.719535	2025-08-06 18:45:40.718378	\N
b0eea916-1feb-4c12-be45-235b20e38287	\N	Maurizio	Firinu	\N	COCCO & DESSI' S.R.L.	Referente	347.2128121	\N	info@coccoedessi.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.722622	2025-08-06 18:45:40.721826	\N
e946df2f-19ce-4013-b583-2b44e69f51a7	\N	Salvatore	Acanfora	\N	RISTORANTE CARUSO DI ACANFORA SALVATORE & C. S.A.S.	Titolare	339.3371824	\N	ristocaruso@hotmail.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.727982	2025-08-06 18:45:40.727187	\N
644c40af-8c5f-4013-b228-afb16e7eba55	\N	Marino	Cuomo	\N	PIZZERIA ADA DI CUOMO MARIO & C. SNC	Titolare	393.7043706	\N	adaristorante@libero.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.730991	2025-08-06 18:45:40.73023	\N
83205b05-c7bd-4409-8b44-d482aae66b6b	\N	Michele	Corradini	\N	ALBERGO VALCANOVER S.A.S. DI BIASI MARIA & C.	Titolare	0461.548037	\N	valcanovervillage@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.734501	2025-08-06 18:45:40.733459	\N
f2e26078-b186-48db-9cd4-9d582dc6cc73	\N	Federico	Lolli	\N	RSG STUDIO LEGALE ASSOCIATO RUFINI SANTI GRANATIERO	Socio Titolare	348.8711002	\N	f.lolli@rlslex.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.738442	2025-08-06 18:45:40.737215	\N
8efce1ec-3bb1-4c0f-8fa8-9c95ee58b199	\N	Roberto	De Luca	\N	DE LUCA ROBERTO	Titolare	349.6856744	\N	robydeluca1989@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.74235	2025-08-06 18:45:40.741038	\N
018af278-7c1f-49f7-b1ed-e81fee8a5f81	\N	Alberto	Crivellaro	\N	S & H S.R.L.	Referente	02.55301618	\N	a.crivellaro@seh.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.746484	2025-08-06 18:45:40.744969	\N
244da34b-d874-46bd-a791-7da1984b6a1d	\N	Antonello	Cppellato	\N	RED COMPANY S.R.L.	Coordinatore Commerciale delle Filiali Gruppo Saf	392.9359171	\N	assistenzafiliali2@trading-srl.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.750033	2025-08-06 18:45:40.749171	\N
ef586317-007f-4fda-8f3d-1b41670c8b68	\N	Maura	Da Pian	\N	SALUMIFICIO DA PIAN S.R.L.	Titolare	333.6454599	\N	maura@dapian.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.753013	2025-08-06 18:45:40.752198	\N
38187ecb-8e6e-4359-a228-47582560e61e	\N	Luca	Scapocchin	\N	SALUMIFICIO F.LLI SCAPOCCHIN S.R.L.	Titolare	328 7580208	\N	salumificio.scapocchin@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.756001	2025-08-06 18:45:40.755242	\N
b21e08ca-63b9-465d-8590-f1ce4b4f5f7c	\N	Fabio	Scarselli	\N	SARDEX S.P.A.	Referente	3356243557	\N	fabio.scarselli@sardexpay.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.758706	2025-08-06 18:45:40.75791	\N
7cc860ed-f4ab-4f77-9a49-19b61647f43b	\N	Paola	Pittu	\N	GAR - BO SRL	Titolare	348.3672407	\N	pittaupaola@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.762401	2025-08-06 18:45:40.761092	\N
ecc2c0fa-f2da-48aa-83d7-f291aab17e8c	\N	Luca	Fostini	\N	SCANSOFT - SOCIETA' COOPERATIVA	Referente	349 6825983	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.766334	2025-08-06 18:45:40.765037	\N
1e144f36-4a49-4815-a157-08f05668e094	\N	Germano	Iseppi	\N	SCELL-IT ITALIA S.R.L.	Direttore Commerciale	051.0099734	\N	germano.iseppi@scellit.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.770126	2025-08-06 18:45:40.768763	\N
aa3e7fe4-b6ba-4de3-8708-095730b21100	\N	Andrea	Codazzi	\N	SCHNEIDER ELECTRIC S.P.A.	MMM Segment Manager	338.6464915	\N	andrea.codazzi@se.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.773463	2025-08-06 18:45:40.772497	\N
87efa5e2-eb73-49e5-af0f-94025b69ce9a	\N	Giuliano	Ramondino	\N	SCHNEIDER ELECTRIC S.P.A.	Responsabile Vendite	335.6184422	\N	giuliano.ramondino@se.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.776886	2025-08-06 18:45:40.77562	\N
900ffcd4-8aba-467e-9d46-fe195e47b198	\N	Annarita	Stellati	\N	SERRAMENTI 82 BY FRANCESCHINI S.R.L.	Referente	06.9340262	\N	annarita@serramenti82.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.781159	2025-08-06 18:45:40.78019	\N
6af1c152-c881-45eb-ad38-c96e26f69e59	\N	Roberto	Russo	\N	BC SOFT S.R.L.	CEO	\N	328 0277212	roberto.russo@bcsoft.net	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.786935	2025-08-06 18:45:40.784439	\N
7efe25b9-734b-43fd-ba9a-f83ed6b2bd05	\N	Roberta	Denaro	\N	\N	Referente	\N	\N	roberta@itshamrock.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.790088	2025-08-06 18:45:40.789578	\N
126be961-eb94-4a17-99ef-3582e85b2d15	\N	Emanuele	Sogus	\N	CERTY  S.R.L.	Chief Executive Officer	\N	378 0840024	emanuelesogus@certy.me	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.792962	2025-08-06 18:45:40.792145	\N
cbecee00-f864-446c-a15a-37d00c19b537	\N	Roberto	Cortese	\N	BIOS MANAGEMENT S.R.L.	Chief Technology Officer	\N	331 9020920	r.cortese@biosmanagement.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.796095	2025-08-06 18:45:40.795153	\N
d74fa67a-b738-4d22-a552-75164de973b3	\N	Edoardo	Pollastri	\N	BIOS MANAGEMENT S.R.L.	\N	\N	339 8117888	e.pollastri@biosmanagement.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.799125	2025-08-06 18:45:40.798296	\N
484b9527-c2b6-4800-96b1-84bdb95b1ccf	\N	Giammatteo	Sole	\N	SICUREZZA 1963 SRL	Referente	329.8118425	\N	sicurezza@securityteosole.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.803411	2025-08-06 18:45:40.802228	\N
f531b486-9416-40e7-83d8-2b31935ae1ef	\N	Nicolò	Sarasini	\N	SIDEROS ENGINEERING SOCIETA' A RESPONSABILITA' LIMITATA OPPURE: SIDEROS ENGINEERING S.R.L. O SIDEROS S.R.L.	Referente	0523.524066	\N	n.sarasini@siderosengineering.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.808139	2025-08-06 18:45:40.806884	\N
fb3a2e38-6158-4c5e-8b79-571fed67fc15	\N	Luigi	Di Michele	\N	QIPO S.R.L.	Sales Manager	\N	328 0941040	luigi.dimichele@qipo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.81306	2025-08-06 18:45:40.811627	\N
fe47f4be-60f6-4bc9-8e16-c5b2e9ca08cf	\N	Davide	Barberis	\N	QIPO S.R.L.	Chief Marketing Officer & Founder	\N	328 8333893	davide.barberis@qipo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.820052	2025-08-06 18:45:40.817159	\N
fe3206fd-d2db-4a71-b2e9-ef2539eec23b	\N	Gianluca	Locatelli	\N	SIMECOM S.R.L.	Referente	\N	\N	gianluca.locatelli@simecom.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.823386	2025-08-06 18:45:40.822493	\N
f750bfa8-e88b-46b6-8305-d38dab54fec4	\N	Claudia	Guerri	\N	FORTOP S.R.L.	Amministratore Delegato	348 1686228	\N	c.guerri@fortop.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.826362	2025-08-06 18:45:40.825505	\N
1f1cbafa-1fbd-4f33-957a-04a8ee4d6904	\N	Andrea	Jurisic	\N	EXERTIS ENTERPRISE IT S.R.L.	Account Manager	\N	\N	andrea.jurisic@exertisenterprise.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.829482	2025-08-06 18:45:40.8286	\N
7b6d0a92-d41a-4451-9ece-645c94bc8186	\N	Giosef	Perricci	\N	UPNOVA GROUP S.R.L.	Referente	\N	327 2852130	g.perricci@upnova.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.832721	2025-08-06 18:45:40.831873	\N
b0beefc4-3655-46c9-b65e-c66e84828b4c	\N	Beatrice	Meliconi	\N	SOFTWAREONE ITALIA S.R.L.	Sales Manager	\N	351 3297432	beatrice.meliconi@eye-able.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.835893	2025-08-06 18:45:40.835001	\N
5696590a-4160-4326-bbec-76229cf3ed93	\N	Antonio	Barbatelli	\N	GLUE LABS SRL	Chief Executive Officer	\N	347 2995767	antonio.barbatelli@glue-labs.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.839437	2025-08-06 18:45:40.838383	\N
597d7da2-c4ed-4406-a68a-8ba6baa8c409	\N	Flavio	Trione	\N	3X1010 S.R.L	Founder e Business Developer	\N	347 6824317	flavio.trione@3x1010.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.843273	2025-08-06 18:45:40.842237	\N
15ebd96a-01e6-4cf0-9f80-699f396c818d	\N	Daniele	Cimmarrusti	\N	AI4WHAT S.R.L.	\N	\N	\N	daniele@ai4what.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.847587	2025-08-06 18:45:40.846536	\N
849ec7bf-045b-452a-8115-009620ad62f9	\N	Roberto	Murgia	\N	DIALOGSPHERE S.R.L.	\N	\N	\N	r.murgia@dialogsphere.ai	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.851895	2025-08-06 18:45:40.85093	\N
a71c962b-53dd-4d70-a196-3804dc49ac66	\N	Melania	Alessandri	\N	SINERGEST S.R.L.	Referente	0583.378530	\N	melania.alessandri@sinergest.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.85614	2025-08-06 18:45:40.855073	\N
eba920c2-3567-4f28-b7ae-e614bb8e29de	\N	Emanuele	Paulon	\N	SINERGIA NET SRLS	Titolare	349.8641086	\N	emanuele@sinergianet.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.859328	2025-08-06 18:45:40.858467	\N
f24f684c-c2cc-4833-b512-aea718200790	\N	Lorenzo	Molinari	\N	SINTESI S.R.L.	Commercialista	0461.968900	\N	lorenzo.molinari@sintesiservizi.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.862486	2025-08-06 18:45:40.861386	\N
fd964765-bcc5-4c5f-8dda-733e580145e8	\N	Antonio	Pistritto	\N	S.R.L. *SO.GE.RI. - SOCIETA' GESTIONE RISTORANTI	Referente	349.7265352	\N	ristoranteisoladicaprera@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.867245	2025-08-06 18:45:40.865935	\N
f663b474-cc5b-46aa-8cc2-21d1fab14fd8	\N	Stefano	Sajetti	\N	SOLUNIO SRL	Referente	335.1782684	\N	stefano.sajetti@solunio.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.872039	2025-08-06 18:45:40.870396	\N
f72b9c89-da8b-41da-8cbf-14afd3d0ae02	\N	Stefano	Cecchini	\N	MIFAST SRL	Referente	339.6304500	\N	stefano@spediamopro.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.879953	2025-08-06 18:45:40.878533	\N
12993b5e-aa53-4551-8454-fb5cde4ee58c	\N	Paolo	Sarto	\N	SPIGA D'ORO SRL	Referente	335.6602289	\N	amministrazione@sartopasticceria.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.886001	2025-08-06 18:45:40.883491	\N
9fbe9bbd-40cb-4949-b09b-e68de2c9883f	\N	Mario	Gulisano	\N	VAPOUR ITALIA SRL	Referente	\N	339 8790632	mario@kiwivapor.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.892097	2025-08-06 18:45:40.891242	\N
12f1ebd0-b48b-46a6-85f2-1df6ca4107d1	\N	Claudio	Lolli	\N	S.T.A.C. 2000 S.R.L.	Titolare	335.5401592	\N	info@stac2000.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.895508	2025-08-06 18:45:40.894654	\N
db0141fd-d9e8-477d-a392-d36f0df0a1a6	\N	Andrea	Vit	\N	STOREIS S.R.L.	Referente	\N	\N	info@store.is	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.899061	2025-08-06 18:45:40.898024	\N
eba5535f-3101-4128-b3e2-0900ea114cc9	\N	Giuseppe	La Rocca	\N	\N	Titolare	329.4211199	\N	giuseppe.larocca@studiofarinalarocca.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.902745	2025-08-06 18:45:40.902184	\N
e54c229d-9aa9-4aa4-8ade-e3b49a7de8e9	\N	Michela	Bruni	\N	\N	Referente UnipolSai	\N	340 4665433	michela@bruniassicurazioni.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.955993	2025-08-06 18:45:40.955118	\N
03f6e367-73a4-4fa1-b957-317d19affb91	\N	Fabio	Malfarà	\N	\N	\N	\N	335 7563187	f.m@ventures-bridge.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:40.991301	2025-08-06 18:45:40.990266	\N
27551937-9ddf-4115-84c5-9539fe7c3af0	\N	Luca	Boccone	\N	\N	\N	\N	\N	l.boccone@torinofc.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.001517	2025-08-06 18:45:41.000574	\N
08063bc3-d0ec-4fb1-9a1c-884c4a827392	\N	Rosa	De Angelis	\N	\N	Banca Sella	\N	\N	rosa.deangelis@sella.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.12364	2025-08-06 18:45:41.123034	\N
d263e77f-ddd9-4b08-b3cd-10133edc2b3d	\N	Orestis	Bozas	\N	\N	Co-Founder	\N	\N	orestisbozas2002@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.12688	2025-08-06 18:45:41.126327	\N
213fcc9f-58e5-47d9-a7ca-17c191267328	\N	Dayana Vinueza	Calderon	\N	\N	Tech Marketing & Sales	\N	\N	dayanacalderon1204@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.129778	2025-08-06 18:45:41.129154	\N
b182d8b8-4bd6-4b30-a9a5-430067015565	\N	Steven	Crosato	\N	\N	\N	\N	340 3405559	hello@stevencrosato.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.139347	2025-08-06 18:45:41.138878	\N
a99fd582-9694-4a27-a73c-7975ce4e796b	\N	Daniela	Santona	\N	\N	Amministratore	3396416307	\N	santona@santona.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.151414	2025-08-06 18:45:41.150926	\N
c558eacc-56d9-4a48-96f3-4cbec07cbd40	\N	Andrea	Basso	\N	\N	Consulente del Lavoro	049.738 2361	347.7685437	a.basso@cdlandreabasso.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.171716	2025-08-06 18:45:41.17124	\N
ae5fb2af-6dd3-4e96-8c40-84afd3ae3867	\N	Alessandro	Chiappa	\N	\N	Revisore	\N	329 2025856	alessandro.chiappa@chiappa.org	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.192324	2025-08-06 18:45:41.191883	\N
52c99f85-0c90-4cfc-9717-2b404b07adc0	\N	Luca	Garbin	\N	\N	\N	\N	342.1510512	lucagarbin16@yahoo.it	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.198614	2025-08-06 18:45:41.198172	\N
ddf84484-c315-440f-8c66-14f7c033ef5d	\N	Cristian	Agostini	\N	\N	\N	\N	348.7612849	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.200969	2025-08-06 18:45:41.200513	\N
43c83ec3-3ea5-430e-94d7-81ead57996da	\N	Giacomo	Manna	\N	\N	\N	\N	331.8725574	mannagro.aziendagricola@gmail.com	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.203354	2025-08-06 18:45:41.202899	\N
18c79d1a-a177-4a2e-93e1-b4fa132ef5ef	\N	Stefania	De Agostini	\N	\N	\N	\N	328.3163312	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.205611	2025-08-06 18:45:41.205163	\N
109639c8-fccd-4ea2-ae8f-8edbca82e947	\N	Maurizio	Coluccio	\N	\N	\N	\N	333 2478775	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-08-06 18:45:41.211271	2025-08-06 18:45:41.210839	\N
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
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


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
-- Name: contacts contacts_business_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_business_card_id_fkey FOREIGN KEY (business_card_id) REFERENCES public.business_cards(id);


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

