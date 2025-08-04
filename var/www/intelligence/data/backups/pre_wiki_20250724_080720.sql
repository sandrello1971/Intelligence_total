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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: calculate_task_sla_deadlines(); Type: FUNCTION; Schema: public; Owner: intelligence_user
--

CREATE FUNCTION public.calculate_task_sla_deadlines() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Calcola le deadline solo se sla_giorni è presente
    IF NEW.sla_giorni IS NOT NULL THEN
        -- SLA principale: usa valore manuale o calcola automaticamente
        IF NEW.sla_deadline IS NULL THEN
            NEW.sla_deadline = NEW.created_at + INTERVAL '1 day' * NEW.sla_giorni;
        END IF;
        
        -- Warning deadline: usa valore manuale o calcola automaticamente  
        IF NEW.warning_deadline IS NULL THEN
            NEW.warning_deadline = NEW.sla_deadline - INTERVAL '1 day' * COALESCE(NEW.warning_giorni, 1);
        END IF;
        
        -- Escalation deadline: usa valore manuale o calcola automaticamente
        IF NEW.escalation_deadline IS NULL THEN
            NEW.escalation_deadline = NEW.sla_deadline + INTERVAL '1 day' * COALESCE(NEW.escalation_giorni, 1);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.calculate_task_sla_deadlines() OWNER TO intelligence_user;

--
-- Name: generate_order_number(); Type: FUNCTION; Schema: public; Owner: intelligence_user
--

CREATE FUNCTION public.generate_order_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Popola un campo order_number se esiste
    IF TG_TABLE_NAME = 'orders' THEN
        -- Questo trigger può essere usato se aggiungiamo un campo order_number
        RETURN NEW;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.generate_order_number() OWNER TO intelligence_user;

--
-- Name: update_order_status(); Type: FUNCTION; Schema: public; Owner: intelligence_user
--

CREATE FUNCTION public.update_order_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_rows INTEGER;
    completed_rows INTEGER;
    in_progress_rows INTEGER;
    new_status VARCHAR(20);
BEGIN
    -- Conta le righe dell'ordine
    SELECT COUNT(*) INTO total_rows
    FROM order_rows 
    WHERE ord_id = COALESCE(NEW.ord_id, OLD.ord_id);
    
    -- Conta le righe completate
    SELECT COUNT(*) INTO completed_rows
    FROM order_rows 
    WHERE ord_id = COALESCE(NEW.ord_id, OLD.ord_id) 
    AND row_status = 'completed';
    
    -- Conta le righe in progress
    SELECT COUNT(*) INTO in_progress_rows
    FROM order_rows 
    WHERE ord_id = COALESCE(NEW.ord_id, OLD.ord_id) 
    AND row_status IN ('ticket_generated', 'in_progress');
    
    -- Determina nuovo status ordine
    IF completed_rows = total_rows AND total_rows > 0 THEN
        new_status := 'completed';
    ELSIF in_progress_rows > 0 THEN
        new_status := 'in_progress';
    ELSIF completed_rows > 0 THEN
        new_status := 'in_progress';
    ELSE
        new_status := 'processing';
    END IF;
    
    -- Aggiorna status ordine
    UPDATE orders 
    SET status = new_status, updated_at = NOW()
    WHERE id = COALESCE(NEW.ord_id, OLD.ord_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION public.update_order_status() OWNER TO intelligence_user;

--
-- Name: update_timestamp(); Type: FUNCTION; Schema: public; Owner: intelligence_user
--

CREATE FUNCTION public.update_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_timestamp() OWNER TO intelligence_user;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: intelligence_user
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO intelligence_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.activities (
    created_at timestamp without time zone,
    id integer NOT NULL,
    title character varying,
    description text,
    start_date character varying,
    end_date character varying,
    status character varying,
    priority character varying,
    owner_id character varying,
    owner_name character varying,
    customer_id character varying,
    customer_name character varying,
    account_name character varying,
    activity_type character varying,
    creation_date character varying,
    last_modified_date character varying,
    ticket_number character varying,
    ticket_date character varying,
    has_end_date boolean,
    last_synced character varying,
    opportunity_id character varying,
    email_subject character varying,
    email_approved character varying,
    approved_by character varying,
    approval_date character varying,
    due_date timestamp without time zone,
    ticket_id character varying,
    predicted_ticket integer,
    ticket_code character varying,
    gtd_generated integer,
    accompagnato_da character varying,
    company_id integer,
    detected_services character varying,
    milestone_id integer,
    project_type character varying,
    accompagnato_da_nome text
);


ALTER TABLE public.activities OWNER TO intelligence_user;

--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.activities_id_seq OWNER TO intelligence_user;

--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.activities_id_seq OWNED BY public.activities.id;


--
-- Name: ai_conversations; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.ai_conversations (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    company_id integer,
    conversation_id character varying(100),
    message_type character varying(20),
    content text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ai_conversations_message_type_check CHECK (((message_type)::text = ANY ((ARRAY['user'::character varying, 'assistant'::character varying, 'system'::character varying])::text[])))
);


ALTER TABLE public.ai_conversations OWNER TO intelligence_user;

--
-- Name: TABLE ai_conversations; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.ai_conversations IS 'AI agent conversation history and context';


--
-- Name: articoli; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.articoli (
    id integer NOT NULL,
    codice character varying(10) NOT NULL,
    nome character varying(200) NOT NULL,
    descrizione text,
    tipo_prodotto character varying(20) NOT NULL,
    prezzo_base numeric(10,2),
    durata_mesi integer,
    attivo boolean DEFAULT true,
    tipo_commessa_legacy_id uuid,
    sla_default_hours integer DEFAULT 48,
    template_milestones jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    art_kit boolean DEFAULT false,
    art_code character varying(10),
    art_description character varying(200),
    tipologia_servizio_id integer,
    partner_id integer,
    responsabile_user_id uuid,
    CONSTRAINT articoli_tipo_prodotto_check CHECK (((tipo_prodotto)::text = ANY ((ARRAY['semplice'::character varying, 'composito'::character varying])::text[])))
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
-- Name: audit_log; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.audit_log (
    id integer NOT NULL,
    user_id uuid,
    action character varying(100) NOT NULL,
    entity_type character varying(100) NOT NULL,
    entity_id character varying(100),
    old_values jsonb,
    new_values jsonb,
    ip_address inet,
    user_agent text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.audit_log OWNER TO intelligence_user;

--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.audit_log_id_seq OWNER TO intelligence_user;

--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.audit_log_id_seq OWNED BY public.audit_log.id;


--
-- Name: bi_cache; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.bi_cache (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    cache_key character varying(255) NOT NULL,
    data jsonb,
    expires_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.bi_cache OWNER TO intelligence_user;

--
-- Name: TABLE bi_cache; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.bi_cache IS 'Business intelligence cache for performance optimization';


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
    company_id bigint,
    name text NOT NULL,
    codice text,
    descrizione text,
    stato text DEFAULT 'attiva'::text,
    created_at timestamp without time zone DEFAULT now(),
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
    codice text,
    name text NOT NULL,
    partita_iva text,
    codice_fiscale text,
    indirizzo text,
    citta text,
    cap text,
    provincia text,
    regione text,
    stato text DEFAULT 'IT'::text,
    settore text,
    numero_dipendenti integer,
    data_acquisizione date,
    note text,
    sito_web text,
    email text,
    telefono text,
    score integer,
    zona_commerciale text,
    sales_persons jsonb,
    created_at timestamp without time zone DEFAULT now(),
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
-- Name: contacts; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.contacts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_id bigint,
    nome text,
    cognome text,
    codice text,
    indirizzo text,
    citta text,
    cap text,
    provincia text,
    regione text,
    stato text,
    ruolo_aziendale text,
    email text,
    telefono text,
    sesso smallint,
    sales_persons jsonb,
    note text,
    sorgente text,
    data_nascita date,
    luogo_nascita text,
    skype text,
    codice_fiscale text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.contacts OWNER TO intelligence_user;

--
-- Name: document_chunks; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.document_chunks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    document_id uuid,
    chunk_index integer NOT NULL,
    content_chunk text NOT NULL,
    vector_id character varying(100),
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.document_chunks OWNER TO intelligence_user;

--
-- Name: TABLE document_chunks; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.document_chunks IS 'Document chunks for vector database integration';


--
-- Name: document_chunks_v2; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.document_chunks_v2 (
    id integer NOT NULL,
    document_id integer NOT NULL,
    chunk_index integer NOT NULL,
    chunk_text text NOT NULL,
    vector_id character varying,
    created_at timestamp without time zone
);


ALTER TABLE public.document_chunks_v2 OWNER TO intelligence_user;

--
-- Name: document_chunks_v2_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.document_chunks_v2_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.document_chunks_v2_id_seq OWNER TO intelligence_user;

--
-- Name: document_chunks_v2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.document_chunks_v2_id_seq OWNED BY public.document_chunks_v2.id;


--
-- Name: kit_articoli; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.kit_articoli (
    id integer NOT NULL,
    kit_commerciale_id integer,
    articolo_id integer,
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
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    filename character varying(255) NOT NULL,
    content_type character varying(100),
    file_size bigint,
    content_hash character varying(64),
    extracted_text text,
    metadata jsonb DEFAULT '{}'::jsonb,
    processed_at timestamp without time zone,
    company_id integer,
    uploaded_by uuid,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.knowledge_documents OWNER TO intelligence_user;

--
-- Name: TABLE knowledge_documents; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.knowledge_documents IS 'Enterprise knowledge management - document storage and metadata';


--
-- Name: milestone_task_templates; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.milestone_task_templates (
    id integer NOT NULL,
    milestone_id integer,
    nome character varying(200) NOT NULL,
    descrizione text,
    ordine integer DEFAULT 0,
    durata_stimata_ore integer,
    ruolo_responsabile character varying(100),
    obbligatorio boolean DEFAULT true,
    tipo_task character varying(50) DEFAULT 'standard'::character varying,
    checklist_template jsonb DEFAULT '[]'::jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.milestone_task_templates OWNER TO intelligence_user;

--
-- Name: milestone_task_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.milestone_task_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.milestone_task_templates_id_seq OWNER TO intelligence_user;

--
-- Name: milestone_task_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.milestone_task_templates_id_seq OWNED BY public.milestone_task_templates.id;


--
-- Name: milestones; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.milestones (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    opportunity_id uuid,
    title text,
    start_date date,
    due_date date,
    auto_generate_tickets boolean DEFAULT true,
    warning_days integer DEFAULT 2,
    escalation_days integer DEFAULT 1,
    template_data jsonb DEFAULT '{}'::jsonb,
    commessa_id uuid,
    tipo_commessa_id uuid,
    stato character varying(50) DEFAULT 'pianificata'::character varying,
    percentuale_completamento double precision DEFAULT 0.0,
    sla_hours integer DEFAULT 48,
    data_inizio timestamp with time zone,
    data_fine_prevista timestamp with time zone,
    data_fine_effettiva timestamp with time zone,
    descrizione text,
    created_by character varying,
    workflow_milestone_id integer,
    articolo_id integer
);


ALTER TABLE public.milestones OWNER TO intelligence_user;

--
-- Name: modelli_task; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.modelli_task (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    descrizione text,
    descrizione_operativa text,
    sla_hours integer DEFAULT 8,
    ordine integer DEFAULT 0,
    is_required boolean DEFAULT true,
    milestone_id uuid,
    tipo_commessa_id uuid,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    sla_giorni integer,
    warning_giorni integer DEFAULT 1,
    escalation_giorni integer DEFAULT 1,
    priorita character varying(20) DEFAULT 'normale'::character varying,
    CONSTRAINT check_modelli_task_association CHECK ((((milestone_id IS NOT NULL) AND (tipo_commessa_id IS NULL)) OR ((milestone_id IS NULL) AND (tipo_commessa_id IS NOT NULL))))
);


ALTER TABLE public.modelli_task OWNER TO intelligence_user;

--
-- Name: modelli_ticket; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.modelli_ticket (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    descrizione text
);


ALTER TABLE public.modelli_ticket OWNER TO intelligence_user;

--
-- Name: opportunities; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.opportunities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    company_id bigint,
    commessa_id uuid,
    title text,
    description text,
    status text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.opportunities OWNER TO intelligence_user;

--
-- Name: order_number_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.order_number_seq
    START WITH 1000
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_number_seq OWNER TO intelligence_user;

--
-- Name: order_rows; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.order_rows (
    id integer NOT NULL,
    ord_id integer NOT NULL,
    art_id integer NOT NULL,
    quantity integer DEFAULT 1,
    row_status character varying(20) DEFAULT 'selected'::character varying,
    completion_percentage numeric(5,2) DEFAULT 0.00,
    ticket_id uuid,
    task_id uuid,
    custom_specs text,
    notes text,
    row_order integer DEFAULT 0,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT order_rows_completion_percentage_check CHECK (((completion_percentage >= (0)::numeric) AND (completion_percentage <= (100)::numeric))),
    CONSTRAINT order_rows_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT order_rows_row_status_check CHECK (((row_status)::text = ANY ((ARRAY['selected'::character varying, 'excluded'::character varying, 'ticket_generated'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.order_rows OWNER TO intelligence_user;

--
-- Name: TABLE order_rows; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.order_rows IS 'Righe ordine - articoli specifici scelti dal cliente (secondo ER Model)';


--
-- Name: COLUMN order_rows.ord_id; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON COLUMN public.order_rows.ord_id IS 'ID ordine secondo ER Model';


--
-- Name: COLUMN order_rows.art_id; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON COLUMN public.order_rows.art_id IS 'ID articolo secondo ER Model';


--
-- Name: COLUMN order_rows.ticket_id; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON COLUMN public.order_rows.ticket_id IS 'Ticket generato per questa riga ordine';


--
-- Name: COLUMN order_rows.task_id; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON COLUMN public.order_rows.task_id IS 'Task principale generato per questa riga';


--
-- Name: orders; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    cst_id bigint NOT NULL,
    ord_date date DEFAULT CURRENT_DATE NOT NULL,
    ord_description text,
    status character varying(20) DEFAULT 'received'::character varying,
    created_by uuid NOT NULL,
    assigned_to uuid,
    notes text,
    internal_notes text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT orders_status_check CHECK (((status)::text = ANY ((ARRAY['received'::character varying, 'processing'::character varying, 'tickets_generated'::character varying, 'in_progress'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.orders OWNER TO intelligence_user;

--
-- Name: TABLE orders; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.orders IS 'Ordini cliente - cosa il cliente ha effettivamente scelto (secondo ER Model)';


--
-- Name: COLUMN orders.cst_id; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON COLUMN public.orders.cst_id IS 'ID cliente (companies) secondo ER Model';


--
-- Name: COLUMN orders.ord_date; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON COLUMN public.orders.ord_date IS 'Data ordine secondo ER Model';


--
-- Name: COLUMN orders.ord_description; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON COLUMN public.orders.ord_description IS 'Descrizione ordine secondo ER Model';


--
-- Name: order_rows_detail; Type: VIEW; Schema: public; Owner: intelligence_user
--

CREATE VIEW public.order_rows_detail AS
 SELECT or_row.id AS row_id,
    or_row.ord_id,
    or_row.art_id,
    or_row.quantity,
    or_row.row_status,
    or_row.completion_percentage,
    o.ord_date,
    o.ord_description,
    o.status AS order_status,
    c.name AS customer_name,
    a.codice AS article_code,
    a.nome AS article_name,
    a.descrizione AS article_description,
    a.tipo_prodotto,
    a.durata_mesi,
    a.sla_default_hours,
    or_row.ticket_id,
    or_row.task_id,
    or_row.created_at,
    or_row.updated_at
   FROM (((public.order_rows or_row
     LEFT JOIN public.orders o ON ((or_row.ord_id = o.id)))
     LEFT JOIN public.companies c ON ((o.cst_id = c.id)))
     LEFT JOIN public.articoli a ON ((or_row.art_id = a.id)));


ALTER VIEW public.order_rows_detail OWNER TO intelligence_user;

--
-- Name: order_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

ALTER TABLE public.order_rows ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.order_rows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username text NOT NULL,
    email text NOT NULL,
    password_hash text,
    role text DEFAULT 'operator'::text,
    created_at timestamp without time zone DEFAULT now(),
    name text,
    surname text,
    first_name character varying(100),
    last_name character varying(100),
    permissions jsonb DEFAULT '{}'::jsonb,
    is_active boolean DEFAULT true,
    last_login timestamp without time zone,
    must_change_password boolean DEFAULT false,
    crm_id integer,
    google_id character varying(255),
    google_credentials text,
    auto_sync_enabled boolean DEFAULT false,
    last_sync_at timestamp without time zone
);


ALTER TABLE public.users OWNER TO intelligence_user;

--
-- Name: orders_complete; Type: VIEW; Schema: public; Owner: intelligence_user
--

CREATE VIEW public.orders_complete AS
 SELECT o.id AS order_id,
    o.ord_date,
    o.ord_description,
    o.status AS order_status,
    c.id AS customer_id,
    c.name AS customer_name,
    c.partita_iva,
    ( SELECT count(*) AS count
           FROM public.order_rows
          WHERE (order_rows.ord_id = o.id)) AS total_items,
    ( SELECT count(*) AS count
           FROM public.order_rows
          WHERE ((order_rows.ord_id = o.id) AND ((order_rows.row_status)::text = 'completed'::text))) AS completed_items,
    ( SELECT avg(order_rows.completion_percentage) AS avg
           FROM public.order_rows
          WHERE (order_rows.ord_id = o.id)) AS avg_completion,
    ((creator.name || ' '::text) || creator.surname) AS created_by_name,
    ((assignee.name || ' '::text) || assignee.surname) AS assigned_to_name,
    o.created_at,
    o.updated_at
   FROM (((public.orders o
     LEFT JOIN public.companies c ON ((o.cst_id = c.id)))
     LEFT JOIN public.users creator ON ((o.created_by = creator.id)))
     LEFT JOIN public.users assignee ON ((o.assigned_to = assignee.id)));


ALTER VIEW public.orders_complete OWNER TO intelligence_user;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

ALTER TABLE public.orders ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: partner; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.partner (
    id integer NOT NULL,
    nome character varying(200) NOT NULL,
    ragione_sociale character varying(250),
    partita_iva character varying(20),
    email character varying(100),
    telefono character varying(50),
    sito_web character varying(200),
    indirizzo text,
    note text,
    attivo boolean DEFAULT true,
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
-- Name: partner_servizi; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.partner_servizi (
    id integer NOT NULL,
    partner_id integer,
    articolo_id integer,
    prezzo_partner numeric(10,2),
    note text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.partner_servizi OWNER TO intelligence_user;

--
-- Name: partner_servizi_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.partner_servizi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.partner_servizi_id_seq OWNER TO intelligence_user;

--
-- Name: partner_servizi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.partner_servizi_id_seq OWNED BY public.partner_servizi.id;


--
-- Name: processing_queue; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.processing_queue (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    job_type character varying(100) NOT NULL,
    job_data jsonb,
    status character varying(20) DEFAULT 'pending'::character varying,
    error_message text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    processed_at timestamp without time zone
);


ALTER TABLE public.processing_queue OWNER TO intelligence_user;

--
-- Name: TABLE processing_queue; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.processing_queue IS 'Asynchronous job processing queue';


--
-- Name: roles; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    permissions jsonb DEFAULT '{}'::jsonb,
    is_system_role boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.roles OWNER TO intelligence_user;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO intelligence_user;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: sales_opportunities; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.sales_opportunities (
    id integer NOT NULL,
    sales_manager_id uuid NOT NULL,
    sales_manager_type character varying(20) NOT NULL,
    cliente character varying(255) NOT NULL,
    company_id integer,
    data_apertura date,
    stato_opportunita character varying(50),
    valore_opportunita numeric(12,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    tipo_opportunita character varying(100),
    nome_opportunita text,
    nuovo_cliente boolean,
    origine_opportunita character varying(100),
    data_presa_carico date,
    delta_giorni integer,
    data_primo_appuntamento date,
    fase_opportunita character varying(100),
    percentuale_successo character varying(50),
    data_presentazione_offerta date,
    azione_da_fare text,
    data_ultimo_aggiornamento date,
    previsione_chiusura_mese character varying(20),
    data_chiusura date,
    note text,
    riferimenti text,
    priorita character varying(20) DEFAULT 'media'::character varying,
    CONSTRAINT check_manager_type CHECK (((sales_manager_type)::text = ANY ((ARRAY['account_manager'::character varying, 'area_manager'::character varying])::text[])))
);


ALTER TABLE public.sales_opportunities OWNER TO intelligence_user;

--
-- Name: sales_manager_stats; Type: VIEW; Schema: public; Owner: intelligence_user
--

CREATE VIEW public.sales_manager_stats AS
 SELECT (((u.first_name)::text || ' '::text) || (u.last_name)::text) AS manager_name,
    u.role AS manager_type,
    count(so.id) AS total_opportunities,
    count(
        CASE
            WHEN ((so.stato_opportunita)::text ~~* '%vinta%'::text) THEN 1
            ELSE NULL::integer
        END) AS won_opportunities,
    count(
        CASE
            WHEN ((so.stato_opportunita)::text ~~* '%aperta%'::text) THEN 1
            ELSE NULL::integer
        END) AS open_opportunities,
    count(
        CASE
            WHEN ((so.stato_opportunita)::text ~~* '%persa%'::text) THEN 1
            ELSE NULL::integer
        END) AS lost_opportunities,
    COALESCE(sum(so.valore_opportunita), (0)::numeric) AS total_value,
    COALESCE(sum(
        CASE
            WHEN ((so.stato_opportunita)::text ~~* '%vinta%'::text) THEN so.valore_opportunita
            ELSE (0)::numeric
        END), (0)::numeric) AS won_value,
    round((((count(
        CASE
            WHEN ((so.stato_opportunita)::text ~~* '%vinta%'::text) THEN 1
            ELSE NULL::integer
        END))::numeric * 100.0) / (NULLIF(count(so.id), 0))::numeric), 2) AS win_rate_percentage
   FROM (public.users u
     LEFT JOIN public.sales_opportunities so ON ((u.id = so.sales_manager_id)))
  WHERE (u.role = ANY (ARRAY['account_manager'::text, 'area_manager'::text]))
  GROUP BY u.id, u.first_name, u.last_name, u.role
  ORDER BY COALESCE(sum(
        CASE
            WHEN ((so.stato_opportunita)::text ~~* '%vinta%'::text) THEN so.valore_opportunita
            ELSE (0)::numeric
        END), (0)::numeric) DESC;


ALTER VIEW public.sales_manager_stats OWNER TO intelligence_user;

--
-- Name: sales_opportunities_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.sales_opportunities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sales_opportunities_id_seq OWNER TO intelligence_user;

--
-- Name: sales_opportunities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.sales_opportunities_id_seq OWNED BY public.sales_opportunities.id;


--
-- Name: scraped_companies; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.scraped_companies (
    id integer NOT NULL,
    scraped_content_id integer,
    company_name character varying(200) NOT NULL,
    description text,
    sector character varying(100),
    company_size character varying(50),
    website character varying(300),
    email character varying(150),
    phone character varying(50),
    address_street character varying(200),
    address_city character varying(100),
    address_zip character varying(20),
    address_country character varying(50) DEFAULT 'Italia'::character varying,
    partita_iva character varying(20),
    social_media jsonb,
    services_offered text[],
    products_offered text[],
    confidence_score double precision DEFAULT 0.0,
    data_completeness double precision DEFAULT 0.0,
    matched_company_id integer,
    integration_status character varying(20) DEFAULT 'unprocessed'::character varying,
    extracted_at timestamp without time zone DEFAULT now(),
    last_updated timestamp without time zone DEFAULT now()
);


ALTER TABLE public.scraped_companies OWNER TO intelligence_user;

--
-- Name: TABLE scraped_companies; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.scraped_companies IS 'Aziende estratte - Autonome con P.IVA linking';


--
-- Name: COLUMN scraped_companies.partita_iva; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON COLUMN public.scraped_companies.partita_iva IS 'P.IVA per future integration';


--
-- Name: scraped_companies_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.scraped_companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scraped_companies_id_seq OWNER TO intelligence_user;

--
-- Name: scraped_companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.scraped_companies_id_seq OWNED BY public.scraped_companies.id;


--
-- Name: scraped_contacts; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.scraped_contacts (
    id integer NOT NULL,
    scraped_content_id integer,
    full_name character varying(200),
    first_name character varying(100),
    last_name character varying(100),
    email character varying(150),
    phone character varying(50),
    "position" character varying(150),
    department character varying(100),
    linkedin_url character varying(300),
    other_social jsonb,
    company_name character varying(200),
    company_website character varying(300),
    confidence_score double precision DEFAULT 0.0,
    data_source character varying(50),
    matched_contact_id integer,
    integration_status character varying(20) DEFAULT 'unprocessed'::character varying,
    extracted_at timestamp without time zone DEFAULT now(),
    company_id bigint
);


ALTER TABLE public.scraped_contacts OWNER TO intelligence_user;

--
-- Name: TABLE scraped_contacts; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.scraped_contacts IS 'Contatti estratti - Autonomi con future integration';


--
-- Name: scraped_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.scraped_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scraped_contacts_id_seq OWNER TO intelligence_user;

--
-- Name: scraped_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.scraped_contacts_id_seq OWNED BY public.scraped_contacts.id;


--
-- Name: scraped_content; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.scraped_content (
    id integer NOT NULL,
    website_id integer,
    page_url character varying(500) NOT NULL,
    page_title character varying(500),
    content_type character varying(50) NOT NULL,
    content_hash character varying(64),
    raw_html text,
    cleaned_text text,
    structured_data jsonb,
    extraction_method character varying(50),
    confidence_score double precision DEFAULT 0.0,
    language character varying(10) DEFAULT 'it'::character varying,
    knowledge_document_id uuid,
    rag_processed boolean DEFAULT false,
    rag_processing_status character varying(20) DEFAULT 'pending'::character varying,
    rag_processing_error text,
    scraped_at timestamp without time zone DEFAULT now(),
    processed_at timestamp without time zone,
    url text,
    title text,
    company_id bigint
);


ALTER TABLE public.scraped_content OWNER TO intelligence_user;

--
-- Name: TABLE scraped_content; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.scraped_content IS 'Contenuti estratti - Ponte verso knowledge_documents (UUID)';


--
-- Name: COLUMN scraped_content.knowledge_document_id; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON COLUMN public.scraped_content.knowledge_document_id IS 'UUID link a knowledge_documents per RAG';


--
-- Name: COLUMN scraped_content.rag_processed; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON COLUMN public.scraped_content.rag_processed IS 'Flag per tracking processo RAG';


--
-- Name: scraped_content_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.scraped_content_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scraped_content_id_seq OWNER TO intelligence_user;

--
-- Name: scraped_content_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.scraped_content_id_seq OWNED BY public.scraped_content.id;


--
-- Name: scraped_documents_v2; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.scraped_documents_v2 (
    id integer NOT NULL,
    url character varying NOT NULL,
    domain character varying NOT NULL,
    title character varying,
    content text NOT NULL,
    content_hash character varying NOT NULL,
    status character varying,
    scraped_at timestamp without time zone,
    vectorized boolean,
    vector_chunks_count integer,
    error_message text,
    company_id bigint
);


ALTER TABLE public.scraped_documents_v2 OWNER TO intelligence_user;

--
-- Name: scraped_documents_v2_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.scraped_documents_v2_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scraped_documents_v2_id_seq OWNER TO intelligence_user;

--
-- Name: scraped_documents_v2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.scraped_documents_v2_id_seq OWNED BY public.scraped_documents_v2.id;


--
-- Name: scraped_websites; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.scraped_websites (
    id integer NOT NULL,
    url character varying(500) NOT NULL,
    domain character varying(100),
    title character varying(500),
    description text,
    scraping_frequency character varying(20) DEFAULT 'weekly'::character varying,
    max_depth integer DEFAULT 1,
    follow_external_links boolean DEFAULT false,
    respect_robots_txt boolean DEFAULT true,
    status character varying(20) DEFAULT 'active'::character varying,
    last_scraped timestamp without time zone,
    next_scrape_scheduled timestamp without time zone,
    company_name character varying(200),
    partita_iva character varying(20),
    sector character varying(100),
    country character varying(2) DEFAULT 'IT'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    created_by character varying(50),
    robots_txt_content text,
    success_count integer DEFAULT 0,
    error_count integer DEFAULT 0,
    last_error_message text,
    company_id bigint
);


ALTER TABLE public.scraped_websites OWNER TO intelligence_user;

--
-- Name: TABLE scraped_websites; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.scraped_websites IS 'Siti web per scraping - Autonomo con integration hooks';


--
-- Name: scraped_websites_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.scraped_websites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scraped_websites_id_seq OWNER TO intelligence_user;

--
-- Name: scraped_websites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.scraped_websites_id_seq OWNED BY public.scraped_websites.id;


--
-- Name: scraping_jobs; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.scraping_jobs (
    id integer NOT NULL,
    website_id integer,
    job_type character varying(50) DEFAULT 'scheduled'::character varying,
    status character varying(20) DEFAULT 'pending'::character varying,
    priority integer DEFAULT 5,
    started_at timestamp without time zone,
    completed_at timestamp without time zone,
    duration_seconds integer,
    pages_scraped integer DEFAULT 0,
    content_extracted integer DEFAULT 0,
    contacts_found integer DEFAULT 0,
    companies_found integer DEFAULT 0,
    rag_documents_created integer DEFAULT 0,
    error_message text,
    retry_count integer DEFAULT 0,
    max_retries integer DEFAULT 3,
    scraping_config jsonb,
    created_at timestamp without time zone DEFAULT now(),
    created_by character varying(50),
    results_summary jsonb
);


ALTER TABLE public.scraping_jobs OWNER TO intelligence_user;

--
-- Name: TABLE scraping_jobs; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.scraping_jobs IS 'Job scraping con tracking risultati RAG';


--
-- Name: scraping_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.scraping_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.scraping_jobs_id_seq OWNER TO intelligence_user;

--
-- Name: scraping_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.scraping_jobs_id_seq OWNED BY public.scraping_jobs.id;


--
-- Name: servizi_commessa; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.servizi_commessa (
    id integer NOT NULL,
    commessa_id uuid,
    articolo_id integer,
    kit_articolo_id integer,
    owner_servizio_id uuid,
    stato character varying(50) DEFAULT 'assegnato'::character varying,
    quantita integer DEFAULT 1,
    prezzo_unitario numeric(10,2),
    sconto_percentuale numeric(5,2) DEFAULT 0,
    valore_totale numeric(10,2),
    data_inizio date,
    data_fine_prevista date,
    data_fine_effettiva date,
    note text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    ord_id uuid
);


ALTER TABLE public.servizi_commessa OWNER TO intelligence_user;

--
-- Name: servizi_commessa_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.servizi_commessa_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.servizi_commessa_id_seq OWNER TO intelligence_user;

--
-- Name: servizi_commessa_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.servizi_commessa_id_seq OWNED BY public.servizi_commessa.id;


--
-- Name: sla_tracking; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.sla_tracking (
    id integer NOT NULL,
    entity_type character varying(50) NOT NULL,
    entity_id integer NOT NULL,
    sla_deadline timestamp without time zone NOT NULL,
    warning_sent_at timestamp without time zone,
    escalation_sent_at timestamp without time zone,
    completed_at timestamp without time zone,
    is_breached boolean DEFAULT false,
    breach_duration interval,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.sla_tracking OWNER TO intelligence_user;

--
-- Name: sla_tracking_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.sla_tracking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sla_tracking_id_seq OWNER TO intelligence_user;

--
-- Name: sla_tracking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.sla_tracking_id_seq OWNED BY public.sla_tracking.id;


--
-- Name: system_health; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.system_health (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    service_name character varying(100) NOT NULL,
    status character varying(20) NOT NULL,
    details jsonb,
    checked_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.system_health OWNER TO intelligence_user;

--
-- Name: TABLE system_health; Type: COMMENT; Schema: public; Owner: intelligence_user
--

COMMENT ON TABLE public.system_health IS 'System health monitoring and alerting';


--
-- Name: task_aggiuntivi; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.task_aggiuntivi (
    id integer NOT NULL,
    ticket_id uuid,
    milestone_id uuid,
    parent_task_id uuid,
    nome character varying(200) NOT NULL,
    descrizione text,
    assigned_to uuid,
    created_by uuid,
    stato character varying(50) DEFAULT 'da_fare'::character varying,
    priorita character varying(20) DEFAULT 'normale'::character varying,
    data_scadenza date,
    ore_stimate numeric(5,2),
    motivo_aggiunta text,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.task_aggiuntivi OWNER TO intelligence_user;

--
-- Name: task_aggiuntivi_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.task_aggiuntivi_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.task_aggiuntivi_id_seq OWNER TO intelligence_user;

--
-- Name: task_aggiuntivi_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.task_aggiuntivi_id_seq OWNED BY public.task_aggiuntivi.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.tasks (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ticket_id uuid,
    milestone_id uuid,
    title text,
    description text,
    status text DEFAULT 'todo'::text,
    due_date date,
    assigned_to uuid,
    created_at timestamp without time zone DEFAULT now(),
    modello_task_id uuid,
    sla_hours integer DEFAULT 24,
    sla_deadline timestamp without time zone,
    estimated_hours numeric(5,2),
    actual_hours numeric(5,2),
    checklist jsonb DEFAULT '[]'::jsonb,
    task_metadata jsonb DEFAULT '{}'::jsonb,
    parent_task_id uuid,
    company_id bigint,
    commessa_id uuid,
    descrizione_operativa text,
    workflow_milestone_id integer,
    task_template_id integer,
    is_aggiuntivo boolean DEFAULT false,
    priorita character varying(20) DEFAULT 'normale'::character varying,
    sla_giorni integer,
    warning_giorni integer DEFAULT 1,
    escalation_giorni integer DEFAULT 1,
    warning_deadline timestamp without time zone,
    escalation_deadline timestamp without time zone
);


ALTER TABLE public.tasks OWNER TO intelligence_user;

--
-- Name: tasks_global; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.tasks_global (
    id integer NOT NULL,
    tsk_code character varying(50) NOT NULL,
    tsk_description text,
    tsk_type character varying(20) DEFAULT 'standard'::character varying,
    tsk_category character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    sla_giorni integer,
    warning_giorni integer DEFAULT 1,
    escalation_giorni integer DEFAULT 1,
    priorita character varying(20) DEFAULT 'normale'::character varying
);


ALTER TABLE public.tasks_global OWNER TO intelligence_user;

--
-- Name: tasks_global_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.tasks_global_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tasks_global_id_seq OWNER TO intelligence_user;

--
-- Name: tasks_global_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.tasks_global_id_seq OWNED BY public.tasks_global.id;


--
-- Name: ticket_rows; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.ticket_rows (
    id integer NOT NULL,
    tck_id uuid,
    tsk_id integer,
    wkf_row_id integer,
    tsk_status character varying(20) DEFAULT 'todo'::character varying,
    tsk_assigned_to uuid,
    tsk_start_date date,
    tsk_due_date date,
    tsk_completed_date date,
    tsk_notes text,
    tsk_order integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.ticket_rows OWNER TO intelligence_user;

--
-- Name: ticket_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.ticket_rows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ticket_rows_id_seq OWNER TO intelligence_user;

--
-- Name: ticket_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.ticket_rows_id_seq OWNED BY public.ticket_rows.id;


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
    workflow_milestone_id integer
);


ALTER TABLE public.tickets OWNER TO intelligence_user;

--
-- Name: tipi_commesse; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.tipi_commesse (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    codice text NOT NULL,
    descrizione text,
    sla_default_hours integer DEFAULT 48,
    template_milestones jsonb,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.tipi_commesse OWNER TO intelligence_user;

--
-- Name: tipologie_servizi; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.tipologie_servizi (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    descrizione text,
    colore character varying(7),
    icona character varying(50),
    attivo boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
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
-- Name: wkf_rows; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.wkf_rows (
    id integer NOT NULL,
    wkf_id integer,
    tsk_id integer,
    mls_id integer,
    tsk_position character varying(20) DEFAULT 'middle'::character varying,
    tsk_sla_hours integer DEFAULT 24,
    tsk_order integer DEFAULT 0,
    tsk_mandatory boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.wkf_rows OWNER TO intelligence_user;

--
-- Name: wkf_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.wkf_rows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wkf_rows_id_seq OWNER TO intelligence_user;

--
-- Name: wkf_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.wkf_rows_id_seq OWNED BY public.wkf_rows.id;


--
-- Name: workflow_milestones; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.workflow_milestones (
    id integer NOT NULL,
    workflow_template_id integer,
    nome character varying(200) NOT NULL,
    descrizione text,
    ordine integer NOT NULL,
    durata_stimata_giorni integer,
    sla_giorni integer,
    warning_giorni integer DEFAULT 2,
    escalation_giorni integer DEFAULT 1,
    tipo_milestone character varying(50) DEFAULT 'standard'::character varying,
    auto_generate_tickets boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.workflow_milestones OWNER TO intelligence_user;

--
-- Name: workflow_milestones_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.workflow_milestones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workflow_milestones_id_seq OWNER TO intelligence_user;

--
-- Name: workflow_milestones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.workflow_milestones_id_seq OWNED BY public.workflow_milestones.id;


--
-- Name: workflow_templates; Type: TABLE; Schema: public; Owner: intelligence_user
--

CREATE TABLE public.workflow_templates (
    id integer NOT NULL,
    articolo_id integer,
    nome character varying(200) NOT NULL,
    descrizione text,
    durata_stimata_giorni integer,
    ordine integer DEFAULT 0,
    attivo boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    wkf_code character varying(50),
    wkf_description text
);


ALTER TABLE public.workflow_templates OWNER TO intelligence_user;

--
-- Name: workflow_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: intelligence_user
--

CREATE SEQUENCE public.workflow_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workflow_templates_id_seq OWNER TO intelligence_user;

--
-- Name: workflow_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intelligence_user
--

ALTER SEQUENCE public.workflow_templates_id_seq OWNED BY public.workflow_templates.id;


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.activities ALTER COLUMN id SET DEFAULT nextval('public.activities_id_seq'::regclass);


--
-- Name: articoli id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli ALTER COLUMN id SET DEFAULT nextval('public.articoli_id_seq'::regclass);


--
-- Name: audit_log id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN id SET DEFAULT nextval('public.audit_log_id_seq'::regclass);


--
-- Name: document_chunks_v2 id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.document_chunks_v2 ALTER COLUMN id SET DEFAULT nextval('public.document_chunks_v2_id_seq'::regclass);


--
-- Name: kit_articoli id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.kit_articoli ALTER COLUMN id SET DEFAULT nextval('public.kit_articoli_id_seq'::regclass);


--
-- Name: kit_commerciali id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.kit_commerciali ALTER COLUMN id SET DEFAULT nextval('public.kit_commerciali_id_seq'::regclass);


--
-- Name: milestone_task_templates id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.milestone_task_templates ALTER COLUMN id SET DEFAULT nextval('public.milestone_task_templates_id_seq'::regclass);


--
-- Name: partner id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.partner ALTER COLUMN id SET DEFAULT nextval('public.partner_id_seq'::regclass);


--
-- Name: partner_servizi id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.partner_servizi ALTER COLUMN id SET DEFAULT nextval('public.partner_servizi_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: sales_opportunities id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.sales_opportunities ALTER COLUMN id SET DEFAULT nextval('public.sales_opportunities_id_seq'::regclass);


--
-- Name: scraped_companies id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_companies ALTER COLUMN id SET DEFAULT nextval('public.scraped_companies_id_seq'::regclass);


--
-- Name: scraped_contacts id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_contacts ALTER COLUMN id SET DEFAULT nextval('public.scraped_contacts_id_seq'::regclass);


--
-- Name: scraped_content id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_content ALTER COLUMN id SET DEFAULT nextval('public.scraped_content_id_seq'::regclass);


--
-- Name: scraped_documents_v2 id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_documents_v2 ALTER COLUMN id SET DEFAULT nextval('public.scraped_documents_v2_id_seq'::regclass);


--
-- Name: scraped_websites id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_websites ALTER COLUMN id SET DEFAULT nextval('public.scraped_websites_id_seq'::regclass);


--
-- Name: scraping_jobs id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraping_jobs ALTER COLUMN id SET DEFAULT nextval('public.scraping_jobs_id_seq'::regclass);


--
-- Name: servizi_commessa id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.servizi_commessa ALTER COLUMN id SET DEFAULT nextval('public.servizi_commessa_id_seq'::regclass);


--
-- Name: sla_tracking id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.sla_tracking ALTER COLUMN id SET DEFAULT nextval('public.sla_tracking_id_seq'::regclass);


--
-- Name: task_aggiuntivi id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.task_aggiuntivi ALTER COLUMN id SET DEFAULT nextval('public.task_aggiuntivi_id_seq'::regclass);


--
-- Name: tasks_global id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tasks_global ALTER COLUMN id SET DEFAULT nextval('public.tasks_global_id_seq'::regclass);


--
-- Name: ticket_rows id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.ticket_rows ALTER COLUMN id SET DEFAULT nextval('public.ticket_rows_id_seq'::regclass);


--
-- Name: tipologie_servizi id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tipologie_servizi ALTER COLUMN id SET DEFAULT nextval('public.tipologie_servizi_id_seq'::regclass);


--
-- Name: wkf_rows id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.wkf_rows ALTER COLUMN id SET DEFAULT nextval('public.wkf_rows_id_seq'::regclass);


--
-- Name: workflow_milestones id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.workflow_milestones ALTER COLUMN id SET DEFAULT nextval('public.workflow_milestones_id_seq'::regclass);


--
-- Name: workflow_templates id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.workflow_templates ALTER COLUMN id SET DEFAULT nextval('public.workflow_templates_id_seq'::regclass);


--
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.activities (created_at, id, title, description, start_date, end_date, status, priority, owner_id, owner_name, customer_id, customer_name, account_name, activity_type, creation_date, last_modified_date, ticket_number, ticket_date, has_end_date, last_synced, opportunity_id, email_subject, email_approved, approved_by, approval_date, due_date, ticket_id, predicted_ticket, ticket_code, gtd_generated, accompagnato_da, company_id, detected_services, milestone_id, project_type, accompagnato_da_nome) FROM stdin;
\.


--
-- Data for Name: ai_conversations; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.ai_conversations (id, user_id, company_id, conversation_id, message_type, content, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: articoli; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.articoli (id, codice, nome, descrizione, tipo_prodotto, prezzo_base, durata_mesi, attivo, tipo_commessa_legacy_id, sla_default_hours, template_milestones, created_at, updated_at, art_kit, art_code, art_description, tipologia_servizio_id, partner_id, responsabile_user_id) FROM stdin;
14	TEST	Articolo Test	Test CRUD operations	semplice	\N	\N	t	\N	48	\N	2025-07-17 13:52:24.144161	2025-07-17 19:48:45.622222	f	\N	\N	2	1	96538adf-a127-4cc3-b0a6-13460b39d290
3	F40	Formazione 4.0	Credito imposta formazione digitale	semplice	\N	\N	t	\N	48	\N	2025-07-10 13:34:10.161777	2025-07-10 13:34:10.161777	f	F40	Formazione 4.0	\N	\N	\N
4	PBX	Patent Box	Agevolazione fiscale per beni immateriali	semplice	\N	\N	t	\N	48	\N	2025-07-10 17:28:39.035001	2025-07-10 17:28:39.035001	f	PBX	Patent Box	\N	\N	\N
7	BND	Bandi		semplice	\N	\N	t	\N	48	\N	2025-07-10 17:30:16.137646	2025-07-10 17:30:16.137646	f	BND	Bandi	\N	\N	\N
8	FNZ	Finanziamenti		semplice	\N	\N	t	\N	48	\N	2025-07-10 17:30:35.337277	2025-07-10 17:30:35.337277	f	FNZ	Finanziamenti	\N	\N	\N
2	I24	Incarico 24 Mesi	Consulenza strategica biennale	composito	\N	\N	t	\N	48	\N	2025-07-10 13:34:10.11907	2025-07-10 13:34:10.11907	t	I24	Incarico 24 Mesi	\N	\N	\N
10	SOF	Start Office Finance		composito	\N	\N	t	\N	48	\N	2025-07-10 17:31:43.166975	2025-07-10 17:31:43.166975	t	SOF	Start Office Finance	\N	\N	\N
11	SOD	Start Office Digital		composito	\N	\N	t	\N	48	\N	2025-07-10 17:31:54.337156	2025-07-10 17:31:54.337156	t	SOD	Start Office Digital	\N	\N	\N
13	SOT	Start Office Training		composito	\N	\N	t	\N	48	\N	2025-07-10 17:32:27.937442	2025-07-10 17:32:27.937442	t	SOT	Start Office Training	\N	\N	\N
12	SOB	Start Office Business		composito	\N	\N	t	\N	48	\N	2025-07-10 17:32:03.977883	2025-07-17 14:27:52.94491	f	SOB	Start Office Business	\N	\N	\N
15	SOS	Start Office Sustainability		composito	\N	\N	t	\N	48	\N	2025-07-17 14:28:38.221101	2025-07-17 14:28:51.920894	f	\N	\N	\N	\N	\N
6	KHW	Know How		semplice	\N	\N	t	\N	48	\N	2025-07-10 17:30:01.757946	2025-07-17 14:31:08.578426	f	KNW	Know How	\N	\N	\N
17	ICS	Incarico Consulenza Strumenti Economico- Finanziari	Sottoscrivendo il presente documento, la Vostra Azienda da ad EndUser Italia l’incarico di proporVi\nstrumenti economici-finanziari adatti alla Vostra organizzazione per generare liquidità e copertura\nfinanziaria per i Vostri investimenti e, ove ci sia approvazione a procedere, sovraintendere al processo\nnecessario per l’ottenimento dei benefici economici derivanti dagli strumenti selezionati.	composito	\N	\N	t	\N	48	\N	2025-07-17 17:21:39.442271	2025-07-17 17:21:39.442271	f	\N	\N	\N	\N	\N
9	RVF	Revenue-Founding		semplice	\N	\N	t	\N	48	\N	2025-07-10 17:31:16.821889	2025-07-17 17:42:40.337716	f	RVF	Revenew Founding	\N	\N	\N
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.audit_log (id, user_id, action, entity_type, entity_id, old_values, new_values, ip_address, user_agent, created_at) FROM stdin;
\.


--
-- Data for Name: bi_cache; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.bi_cache (id, cache_key, data, expires_at, created_at) FROM stdin;
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

COPY public.companies (id, codice, name, partita_iva, codice_fiscale, indirizzo, citta, cap, provincia, regione, stato, settore, numero_dipendenti, data_acquisizione, note, sito_web, email, telefono, score, zona_commerciale, sales_persons, created_at, is_partner, is_supplier, partner_category, partner_description, partner_expertise, partner_rating, partner_status, last_scraped_at, scraping_status, ai_analysis_summary) FROM stdin;
1569045	\N	ENDUSER ITALIA S.R.L.S.	15281631000.0	15281631000	VIA LUIGI SETTEMBRINI, 30	ROMA	195.0	RM	Lazio	Italia	\N	8	2025-02-03	NaN	https://www.enduser-italia.com/	NaN	NaN	\N	NaN	[]	2025-07-03 20:34:34.703659	f	f	\N	\N	[]	0	active	\N	pending	\N
1569134	\N	ORTOPEDIA PODOLOGIA MALPIGHI S.R.L.	1860001203.0	01860001203	VIA PELAGIO PALAGI, 33/2	BOLOGNA	40138.0	BO	Emilia-romagna	Italia	\N	21	2025-02-03	NaN	www.ortopediamalpighi.it	NaN	051346200	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.711327	f	f	\N	\N	[]	0	active	\N	pending	\N
1569800	\N	CIBUS BZ SRL	2971190216.0	02971190216	VIA VIA MARIE CURIE, 13	BOLZANO	39100.0	BZ	Trentino-alto adige	Italia	\N	25	2025-02-05	CIBUS BZ srl\nP.I. 02971190216\nSede legale: Via Maria Curie 13 - 39100 Bolzano (BZ)\nPEC: bpsolution@arubapec.it\n\nCodice ATECO: Codice: 156.10.11 - Ristorazione con somministrazione\nAmministratore: Davide Baio\n\nCIBUS BZ è una start-up in rapida espansione operante nel settore della ristorazione della\nProvincia di Bolzano, gestore del ristorante Cibus in via Marie Curie 13 a Bolzano, che è\nriuscita in breve tempo a ritagliarsi uno spazio nella realtà bolzanina, nonostante le\nprecedenti altre gestioni di insuccesso dello stesso locale. Cibus rappresenta un punto di\nriferimento per tutti i lavoratori e avventori della Zona Industriale di Bolzano ed intende\ngarantire alla numerosa clientela un servizio altamente qualitativo ed efficiente. In poco\ntempo i titolari, grazie alla loro intraprendenza e all'esperienza nel campo, sono riusciti a\ndiventare un punto di riferimento in Zona Industriale, andando a erodere in modo\nsignificativo il mercato degli operatori consolidati. Cibus ha saputo proporsi in modo\ndiverso sui servizi del pranzo e quelli della cena, orientando i primi principalmente\nall'utenza aziendale - stipulando convenzioni con le molte aziende con sedi in Zona - ei\nsecondi ad un'utenza più esigente e raffinata differenziando ambiente, il tipo di servizio e i\npiatti, mantenendo sempre elevati standard qualitativi. Dal 2018 Cibus è stata sede di\ndiversi corsi finanziati dal Fondo Sociale Europeo per sostenere l'occupazione nell'ambito\ndella ristorazione, fornendo sia gli spazi adatti per le esercitazioni pratiche, sia nelle\nattività di docenza.	www.cibus.bz/?utm_source=tripadvisor&utm_medium=referral	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.714892	f	f	\N	\N	[]	0	active	\N	pending	\N
1569804	\N	CENTRO OTTICO SAN RUFFILLO DI ALESSANDRI STEFANO E C. S.A.S.	4273440372.0	04273440372	VIA TOSCANA, 56/B	BOLOGNA	40141.0	BO	Emilia-romagna	NaN	\N	1	2025-02-05	NaN	www.ottica-sanruffillo.com	NaN	051-472382	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:34.718353	f	f	\N	\N	[]	0	active	\N	pending	\N
1569826	\N	CONSORZIO DEL PROSCIUTTO DI SAN DANIELE	220330302.0	00220330302	VIA IPPOLITO NIEVO, 19	SAN DANIELE DEL FRIULI	33038.0	UD	Friuli-venezia giulia	NaN	\N	14	2025-02-05	NaN	www.sandanielemagazine.com	NaN	0432 957515	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:34.721656	f	f	\N	\N	[]	0	active	\N	pending	\N
1569834	\N	STUDIO FORESTAN S.R.L.	3820480246.0	03820480246	VIA CANOVE, 7	CAMISANO VICENTINO	36043.0	VI	Veneto	NaN	\N	5	2025-02-05	Studio di Commercialista	NaN	NaN	0444-411412	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.724944	f	f	\N	\N	[]	0	active	\N	pending	\N
1570266	\N	PANCONI CATERING S.R.L.	578780454.0	00578780454	VIA DELLE BOCCHETTE, 8/N	CAMAIORE	55041.0	LU	Toscana	Italia	\N	10	2025-02-06	NaN	www.panconicatering.it	NaN	0584.944122	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.728415	f	f	\N	\N	[]	0	active	\N	pending	\N
1570267	\N	C.M. BALASSO SRL	2363000247.0	NaN	Via G. Marconi, 48	Marano Vicentino  (Vi)	36035.0	Vicenza	Veneto	Italia	\N	8	2025-02-06	Lavorazione meccanica di precisione	NaN	info@cmbalasso.com	0445-621211	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.731872	f	f	\N	\N	[]	0	active	\N	pending	\N
1570282	\N	GRAPHIC DIVISION DI ALBIERI NORBERTO	936420298.0	LBRNBR61R22H620V	VIA DEL MERCANTE, 53	ROVIGO	45100.0	RO	Veneto	Italia	\N	7	2025-02-06	Azienda di Grafica	www.graphicdivision.it	NaN	0425-410616	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.735092	f	f	\N	\N	[]	0	active	\N	pending	\N
1570285	\N	AUTOVEICOLI ERZELLI SPA	451180103.0	00451180103	VIA MELEN ENRICO, 73	GENOVA	16152.0	GE	Liguria	Italia	\N	29	2025-02-06	NaN	www.autoveicolierzelli.it	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.73846	f	f	\N	\N	[]	0	active	\N	pending	\N
1570295	\N	TRADING LOGISTIC SAC SRL	1415720117.0	01415720117	VIA PROVINCIALE RIPA,	VEZZANO LIGURE	19020.0	SP	Liguria	Italia	\N	14	2025-02-06	NaN	www.tradinglogistic.com	NaN	0187.503784	\N	NaN	["Fabio Aliboni"]	2025-07-03 20:34:34.741675	f	f	\N	\N	[]	0	active	\N	pending	\N
1570302	\N	ENDI' S.R.L.	1043330867.0	01043330867	PIAZZA SAN FRANCESCO, 17	LEONFORTE	94013.0	EN	Sicilia	NaN	\N	16	2025-02-06	NaN	www.endisrl.com	NaN	0935-905052	\N	NaN	["Fabio Aliboni"]	2025-07-03 20:34:34.745104	f	f	\N	\N	[]	0	active	\N	pending	\N
1570312	\N	AMEL MEDICAL DIVISION SRL	4494630280.0	NaN	Via provinciale 37	Carmignano di Brenta	35010.0	Padova	Veneto	Italia	\N	10	2025-02-06	Azienda di commercio materiale sanitario\nCodice Ateco: 77.39.99 - Noleggio senza operatore di altre macchine ed attrezzature nca (vendita e noleggio di macchinari per magnetoterapia). #Luana	NaN	info@amelmedical.com	049-9431144	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.748089	f	f	\N	\N	[]	0	active	\N	pending	\N
1570331	\N	FRIUL  AL SRL	650830300.0	NaN	Via Paludo, 2	Magnano in Riviera	33010.0	Udine	Friuli-Venezia Giulia	Italia	\N	12	2025-02-06	Azienda di produzione serramenti	NaN	serramenti@friulal.com	0432.792014	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.750351	f	f	\N	\N	[]	0	active	\N	pending	\N
1570340	\N	N.E.W. SRL	11150891007.0	NaN	Via Bolivia 16	Pomezia	71.0	Roma	Lazio	Italia	\N	0	2025-02-06	NaN	NaN	felice.sabatino@newsrl.net	366.3825045	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:34.75252	f	f	\N	\N	[]	0	active	\N	pending	\N
1570345	\N	MZ&Z ADVISORS SRL	3065920302.0	NaN	Via Poscolle, 8c	Udine	33100.0	Udine	Friuli-Venezia Giulia	Italia	\N	5	2025-02-06	Società di consulenza contabile	NaN	francesco.zani@studiozani.it	3475855434	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.755141	f	f	\N	\N	[]	0	active	\N	pending	\N
1570369	\N	LUCIANI SRL	144720240.0	NaN	Via Bassano, 96	Rossano Veneto	36028.0	Vicenza	Veneto	Italia	\N	12	2025-02-06	NaN	NaN	info@lucianisrl.it	0424 540050	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.757837	f	f	\N	\N	[]	0	active	\N	pending	\N
1571386	\N	WINIT S.R.L.	1771370226.0	01771370226	Via Oss Mazzurana, 3	TRENTO	38122.0	TN	Trentino-alto adige	Italia	\N	5	2025-02-10	NaN	www.winit.it	NaN	338.5645715	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.760717	f	f	\N	\N	[]	0	active	\N	pending	\N
1571390	\N	F.LLI FREDIANI SRL	555510452.0	NaN	Via Morucciola, 40	Luni	19034.0	La Spezia	Liguria	Italia	\N	0	2025-02-10	NaN	NaN	NaN	348 2473543	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.76327	f	f	\N	\N	[]	0	active	\N	pending	\N
1571398	\N	LAC SPA	509113024.0	NaN	Via Palazzo Storto, 16	Romano d'Ezzelino	36060.0	Vicenza	Veneto	Italia	\N	110	2025-02-10	Lavorazione dell' oro.\n# Sabrina	NaN	NaN	0424.510348	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.767397	f	f	\N	\N	[]	0	active	\N	pending	\N
1571407	\N	VENBATT DI BELTRAME MATTEO E MARCO S.N.C.	4510220272.0	04510220272	VIA PADRE E. VENTURINI, 33	CHIOGGIA	30015.0	VE	Veneto	NaN	\N	1	2025-02-10	Azienda commerciale di rivendita batterie	www.venbatt.it	NaN	3408634162	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.771017	f	f	\N	\N	[]	0	active	\N	pending	\N
1571424	\N	RLS LEX	1736001205.0	NaN	VIA MASI, 40	Bologna	40121.0	Bologna	Emilia-Romagna	Italia	\N	0	2025-02-10	NaN	https://rlslex.it/	NaN	051.0195197	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.773587	f	f	\N	\N	[]	0	active	\N	pending	\N
1571433	\N	TERRANTICA S.R.L.	2260980921.0	02260980921	STRADA STATALE 131 KM. 40.300, 131	SERRENTI	9027.0	CA	Sardegna	NaN	\N	18	2025-02-10	NaN	www.terrantica.it	NaN	070-9301604	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:34.776039	f	f	\N	\N	[]	0	active	\N	pending	\N
1571441	\N	ISTITUTO SONCIN S.A.S. DI ROSELLI MARCO & C.	1506370285.0	01506370285	VIA SONCIN,, 34	PADOVA	35122.0	PD	Veneto	Italia	\N	19	2025-02-10	Azienda di fisioterapia e riabilitazione	www.istitutosoncin.it	NaN	049-666229	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.778761	f	f	\N	\N	[]	0	active	\N	pending	\N
1571456	\N	INDUSTRIA SARDA ALBERGHI S.R.L.	28970952.0	00028970952	PIAZZA P MARIANO, 50	ORISTANO	9170.0	OR	Sardegna	Italia	\N	23	2025-02-10	Hotel Mariano	www.hotelmarianoiv.com	NaN	0783 360101	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:34.781277	f	f	\N	\N	[]	0	active	\N	pending	\N
1571509	\N	BT SOLUTIONS SRL	2406960464.0	NaN	Via S. Michele, 21	CAPEZZANO PIANORE	\N	LUCCA	NaN	NaN	\N	0	2025-02-10	NaN	NaN	bianchinietognetti@pec.it	344.1252363	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.783771	f	f	\N	\N	[]	0	active	\N	pending	\N
1571821	\N	CO.VER COLORIFICIO SRL	4062580248.0	NaN	Via Prà Bordoni, 53	Zanè	36010.0	Vicenza	Veneto	Italia	\N	10	2025-02-11	Vendita di materiali di verniciatura per meccanici auto	http://www.covercolorificio.it/	colorificiocover@pec.telemar.it	0445.314745	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.78691	f	f	\N	\N	[]	0	active	\N	pending	\N
1571826	\N	M.R. CALAMARI S.R.L.	1153530454.0	01153530454	VIALE GALILEI, 1	CARRARA	54031.0	MS	Toscana	Italia	\N	10	2025-02-11	NaN	http://www.calamariracing.it	NaN	0585877241	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.78922	f	f	\N	\N	[]	0	active	\N	pending	\N
1571836	\N	STUDIO BRACCO & CERQUETI - SOCIETA' SEMPLICE TRA PROFESSIONISTI	1627660085.0	01627660085	VIA G. MATTEOTTI, 167	SANREMO	18038.0	IM	Liguria	Italia	\N	7	2025-02-11	Studio commercialista  gestione paghe e contabilità con 4/5 dipendenti negli anni 20,21 e 22.	www.braccocerqueti.it	NaN	0184531472	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.792033	f	f	\N	\N	[]	0	active	\N	pending	\N
1571838	\N	BARZANTI MIRIO SRL	3284091208.0	03284091208	VIA GIOVANNI AMENDOLA, 56/D	IMOLA	40026.0	BO	Emilia-romagna	NaN	\N	15	2025-02-11	Codice Ateco: 43.12 - Preparazione del cantiere edile (costruzione capannoni). #Luana	www.scavidemolizioni.net	NaN	0542.56149	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.795046	f	f	\N	\N	[]	0	active	\N	pending	\N
1571843	\N	PASSARELLI AUTOMAZIONI S.R.L.	6670611000.0	06670611000	VIA PIETRO CROSTAROSA, 23	ROMA	173.0	RM	Lazio	NaN	\N	17	2025-02-11	NaN	www.passarelliautomazioni.it	NaN	06-89581037	\N	NaN	["Massimiliano Ciotti"]	2025-07-03 20:34:34.798068	f	f	\N	\N	[]	0	active	\N	pending	\N
1571850	\N	SURGELSARDA SAS DI PI SANU AUGUSTO - SIGLA ABBR. SURGELSARDA S.A.S. DI PISANU AUGUSTO"	53300950.0	00053300950	,Via Bruxelles Snc	ORISTANO	9025.0	OR	Sardegna	NaN	\N	12	2025-02-11	NaN	NaN	surgelsarda@hotmail.com	0783-358220	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:34.801369	f	f	\N	\N	[]	0	active	\N	pending	\N
1571862	\N	VIDEO PIU' S.R.L.	1692430901.0	01692430901	VIA BRIGATA SASSARI, 9/B	ALGHERO	7041.0	SS	Sardegna	NaN	\N	12	2025-02-11	NaN	www.expertalghero.it	NaN	079-951801	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:34.804608	f	f	\N	\N	[]	0	active	\N	pending	\N
1571866	\N	QUATTRO STELLE ARREDAMENTI S.R.L.	4169910751.0	04169910751	VIA G. LEONE,	SURBO	73010.0	LE	Puglia	NaN	\N	15	2025-02-11	NaN	www.quattrostellearredamenti.it	NaN	0832-366072	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:34.807962	f	f	\N	\N	[]	0	active	\N	pending	\N
1571875	\N	SIS*MED S.R.L. SISTEMI MEDICALI	2608850752.0	02608850752	VIALE ORONZO QUARTA, 10	LECCE	73100.0	LE	Puglia	Italia	\N	13	2025-02-11	NaN	NaN	NaN	0832455695	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:34.810927	f	f	\N	\N	[]	0	active	\N	pending	\N
1571883	\N	IL GIGLIO SOCIETA' COOPERATIVA SOCIALE	1633260094.0	01633260094	VIA BAZZINO, 3	SAVONA	17100.0	SV	Liguria	Italia	\N	105	2025-02-11	NaN	NaN	NaN	347.2300412	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.814205	f	f	\N	\N	[]	0	active	\N	pending	\N
1571888	\N	INDUSTRIAL SOFTWARE S.R.L.	1083540458.0	01083540458	VIA FRASSINA, 51	CARRARA	54033.0	MS	Toscana	Italia	\N	12	2025-02-11	NaN	www.industrialsoftware.it	NaN	0585 1886670	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.817578	f	f	\N	\N	[]	0	active	\N	pending	\N
1571901	\N	CAFFARO INDUSTRIE S.P.A.	3034951206.0	03034951206	PIAZZALE MARINOTTI, 1	TORVISCOSA	33050.0	UD	Friuli-venezia giulia	NaN	\N	178	2025-02-11	NaN	www.caffaroindustrie.com	NaN	0431-381379	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.820775	f	f	\N	\N	[]	0	active	\N	pending	\N
1571907	\N	GIOVEN S.R.L.	625760459.0	00625760459	VIA LOTTIZZAZIONE,, 12	MASSA	54100.0	MS	Toscana	NaN	\N	4	2025-02-11	NaN	NaN	NaN	0585-835125	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.824405	f	f	\N	\N	[]	0	active	\N	pending	\N
1571914	\N	GE.M.E.G. S.R.L.	596830455.0	00596830455	VIA ILICE, 17	CARRARA	54033.0	MS	Toscana	Italia	\N	15	2025-02-11	NaN	NaN	NaN	0585 856424	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.827926	f	f	\N	\N	[]	0	active	\N	pending	\N
1571918	\N	HALO INDUSTRY S.P.A.	2678490307.0	02678490307	PIAZZALE FRANCO MARINOTTI, 1	TORVISCOSA	33050.0	UD	Friuli-venezia giulia	Italia	\N	35	2025-02-11	NaN	www.haloindustry.it	NaN	0431-610547	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.831109	f	f	\N	\N	[]	0	active	\N	pending	\N
1571925	\N	TURRISMARKET S.R.L.	71320907.0	00071320907	VIA SASSARI, 102	PORTO TORRES	7046.0	SS	Sardegna	NaN	\N	100	2025-02-11	NaN	www.turrismarket.it	NaN	079-515240	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.833906	f	f	\N	\N	[]	0	active	\N	pending	\N
1571934	\N	THE ORAL ATELIER S.R.L.	3712331200.0	03712331200	VIA TOSCANA, 52	BOLOGNA	40141.0	BO	Emilia-romagna	Italia	\N	2	2025-02-11	NaN	https://www.piercarlofrabboni.com/studi-dentistici/bologna/	NaN	051471964	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.836567	f	f	\N	\N	[]	0	active	\N	pending	\N
1571947	\N	SERVIZI IMPRESE SARDEGNA SRL	2620240909.0	02620240909	VIA PASCOLI, 16/B	SASSARI	7100.0	SS	Sardegna	NaN	\N	16	2025-02-11	NaN	www.si-sardegna.it	NaN	338.6822825	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:34.83905	f	f	\N	\N	[]	0	active	\N	pending	\N
1571995	\N	INTERACTIVE STYLE SRL	4099770168.0	04099770168	VIA GROMOLEVATE, 8/I	CHIUDUNO	24060.0	BG	Lombardia	Italia	\N	4	2025-02-12	NaN	NaN	NaN	347.5079974	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.841436	f	f	\N	\N	[]	0	active	\N	pending	\N
1572004	\N	CENTRO DATI VIGEVANO S.R.L.	2523220180.0	02523220180	VIA BIFFIGNANDI, 37	VIGEVANO	27029.0	PV	Lombardia	Italia	\N	5	2025-02-12	NaN	NaN	NaN	0381.77575	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.844348	f	f	\N	\N	[]	0	active	\N	pending	\N
1572008	\N	ARIKI S.R.L.	1338920224.0	01338920224	VIA OSS MAZZURANA, 38	TRENTO	38122.0	TN	Trentino-alto adige	Italia	\N	77	2025-02-12	Azienda che gestisce ristoranti per la catena Forst.\nCodice Ateco: 56.10.11 - Ristorazione con Somministrazione (Ristorante). #Luana	www.nikys.it	NaN	0461235590	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.847022	f	f	\N	\N	[]	0	active	\N	pending	\N
1572019	\N	MY DENT SRL	4485380234.0	04485380234	VIA CRESCINI, 15	SANT'AMBROGIO DI VALPOLICELLA	37015.0	VR	Veneto	Italia	\N	3	2025-02-12	NaN	NaN	NaN	340.1220149	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.849597	f	f	\N	\N	[]	0	active	\N	pending	\N
1572026	\N	EASY CONTACT S.R.L.	4002430926.0	04002430926	VIA GIOVANNI BATTISTA TUVERI, 47	CAGLIARI	9129.0	CA	Sardegna	NaN	\N	12	2025-02-12	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:34.852505	f	f	\N	\N	[]	0	active	\N	pending	\N
1572028	\N	GESTIONE BENESSERE SRL	15601271008.0	15601271008	VIA APPIA NUOVA, 868	ROMA	178.0	RM	Lazio	NaN	\N	10	2025-02-12	NaN	NaN	NaN	335.6451512	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.855423	f	f	\N	\N	[]	0	active	\N	pending	\N
1572059	\N	IL FORNO DI GERMANO DI RENZETTI GERMANO E LORENA S.N.C.	1012130116.0	01012130116	PIAZZA VITTORIO EMANUELE, 5	VARESE LIGURE	19028.0	SP	Liguria	Italia	\N	28	2025-02-12	NaN	www.ilfornodigermano.it	NaN	349.5155381	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.858125	f	f	\N	\N	[]	0	active	\N	pending	\N
1572064	\N	ECO GARDEN NET & SERVICES S.R.L.	2139070508.0	02139070508	VIA CHIASSATELLO, 96	PISA	56121.0	PI	Toscana	NaN	\N	21	2025-02-12	NaN	NaN	NaN	348.7915204	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.861474	f	f	\N	\N	[]	0	active	\N	pending	\N
1572071	\N	NELLI AUTO S.R.L.	2051710503.0	02051710503	VIA TOSCO ROMAGNOLA, 255	PONTEDERA	56025.0	PI	Toscana	Italia	\N	4	2025-02-12	NaN	www.alpharent.it	NaN	058755333	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.86477	f	f	\N	\N	[]	0	active	\N	pending	\N
1572092	\N	ALPHA RENT SRLS	2225630504.0	NaN	Via Tosco Romagnolo 197	Pontedera	56025.0	Pisa	Toscana	Italia	\N	0	2025-02-12	Codice Ateco: 77.11 Noleggio di autovetture ed autoveicoli leggeri. #Luana	NaN	alpharentsrl@pec.it	333 7988551	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.867936	f	f	\N	\N	[]	0	active	\N	pending	\N
1584030	\N	ASI - ASSOCIAZIONI SPORTIVE E SOCIALI ITALIANE	4901361008.0	96258170586	VIA PIAVE, 8	ROMA	187.0	RM	Lazio	Italia	\N	12	2025-02-13	E' un primario Ente di Promozione Sportiva riconosciuto dal CONI. Riunisce le associazioni sportive dilettantistiche, le società sportive, i circoli culturali affiliati e tutte le associazioni del terzo settore.\nCodice Ateco: 93.11.9 - Gestione impianti sportivi (Associazione Sportiva). #Luana	www.asiequitazione.com	NaN	0695945226	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:34.906451	f	f	\N	\N	[]	0	active	\N	pending	\N
1572107	\N	4H SRL	1475840912.0	01475840912	VIA G. D'ANNUNZIO,	SAN TEODORO	7052.0	SS	Sardegna	Italia	\N	42	2025-02-12	Codice Ateco: 56.10.11\nOggetto:  (Laboratorio Pasticceria)\nLA SOCIETA' HA PER OGGETTO LA REALIZZAZIONE DI UNA INIZIATIVA PRODUTTIVA\nNELL'AMBITO DELLA REGIONE AUTONOMA DELLA SARDEGNA.\nIN PARTICOLARE L'OGGETTO SOCIALE COMPRENDE L'ATTIVITA' DI PRODUZIONE DI\nPRODOTTI DI PASTICCERIA, GELATERIA, DOLCIUMI, PASTA FRESCA, PRODOTTI DI\nGASTRONOMIA, PIZZE DA ASPORTO NONCHE' LA LORO COMMERCIALIZZAZIONE ALL'INGROSSO\nED AL DETTAGLIO;\n- SERVIZI DI RISTORAZIONE AZIENDALE E COLLETTIVA, FORNITURA DI DERRATE\nALIMENTARI A MENSE, ALBERGHI E COMUNITA';\n- PREPARAZIONE DI PASTI PER RISTORANTI, AZIENDE, SCUOLE ED OSPEDALI;\n- LA GESTIONE DI RISTORANTI, GELATERIE, BAR, ALBERGHI, DISCOTECHE E SERVIZI\nACCESSORI.\n- PRODUZIONE ED ORGANIZZAZIONE DI EVENTI MUSICALI, SPORTIVI E DI\nINTRATTENIMENTO IN GENERALE.\nLA SOCIETA', PER IL RAGGIUNGIMENTO DELL'OGGETTO SOCIALE, POTRA' COMPIERE TUTTE\nLE OPERAZIONI COMMERCIALI, INDUSTRIALI ED IMMOBILIARI OCCORRENTI ED INOLTRE\nPOTRA' COMPIERE, IN VIA NON PREVALENTE E DEL TUTTO ACCESSORIA E STRUMENTALE E\nCOMUNQUE CON ESPRESSA ESCLUSIONE DI QUALSIASI ATTIVITA' SVOLTA NEI CONFRONTI\nDEL PUBBLICO, OPERAZIONI FINANZIARIE E MOBILIARI, CONCEDERE FIDEIUSSIONI,\nAVALLI, CAUZIONI, GARANZIE ANCHE A FAVORE DI TERZI, NONCHE' ASSUMERE, SOLO A\nSCOPO DI STABILE INVESTIMENTO E NON DI COLLOCAMENTO, SIA DIRETTAMENTE CHE\nINDIRETTAMENTE, PARTECIPAZIONI IN SOCIETA' ITALIANE ED ESTERE AVENTI OGGETTO\nANALOGO, AFFINE O CONNESSO AL PROPRIO. #Luana\n09/05 Nel 2005 il comune di San Teodoro è passato dalla provincia di Nuoro alla provincia di Olbia-Tempio e nel 2017 è passato dalla provincia di Olbia-Tempio alla provincia di Sassari. Prima del novembre 2017 il CAP del comune era 08020, ora è il 07052. #Barbara	www.artacademybrand.it	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.870438	f	f	\N	\N	[]	0	active	\N	pending	\N
1572111	\N	5S S.R.L.	1576360919.0	01576360919	VIA GABRIELE D'ANNUNZIO,	SAN TEODORO	7052.0	Sassari	Sardegna	Italia	\N	14	2025-02-12	Codice Ateco: 56.10.11\nOggetto: (Laboratorio Pasticceria)\nLA GESTIONE DI LABORATORI DI PASTICCERIA, LA VENDITA DI GELATI, LA GESTIONE DI\nESERCIZIO PUBBLICO DI BAR, GELATERIA E AFFINI, CON VENDITA AL MINUTO DI GENERI\nRELATIVI, LA VENDITA E LO SPACCIO DI BEVANDE IN GENERE INCLUSE QUELLE\nALCOOLICHE E SUPER ALCOOLICHE E ALTRI GENERI ANALOGHI O AFFINI NONCHE' TUTTO\nQUANTO PREVISTO NELLA TABELLA MERCEOLOGICA RELATIVA;\n- LA GESTIONE DI ESERCIZIO PUBBLICO DI BAR, GELATERIA E AFFINI, CON VENDITA AL\nMINUTO DI GENERI RELATIVI, LA VENDITA E LO SPACCIO DI BEVANDE IN GENERE INCLUSE\nQUELLE ALCOOLICHE E SUPER ALCOOLICHE E ALTRI GENERI ANALOGHI O AFFINI NONCHE'\nTUTTO QUANTO PREVISTO NELLA TABELLA MERCEOLOGICA RELATIVA;\n- L'ATTIVITA' DI RISTORAZIONE CON SOMMINISTRAZIONE AL PUBBLICO DI ALIMENTI E\nBEVANDE - RISTORAZIONE - BAR - PIZZERIA;\n- L'ESERCIZIO E LA GESTIONE DI ALBERGHI, RISTORANTI, TRATTORIE, MENSE, TAVOLE\nCALDE E FREDDE, CAFFETTERIA, PIZZERIE SALE DA BAR, PASTICCERIE O SIMILI E\nL'INERENTE COMMERCIO AL DETTAGLIO E ALL'INGROSSO DI BEVANDE ALCOLICHE E\nANALCOLICHE, LIQUORI, SCIROPPI, ESSENZE ED ESTRATTI, PRODOTTI ALIMENTARI,\nFRESCHI E CONSERVATI, ANCHE DEL GENERE DI LATTERIA PASTICCERIA PANETTERIA E\nGELATERIA, CON INOLTRE PRODUZIONE PROPRIA DI DOLCIUMI E GELATI;\n- ORGANIZZAZIONE DI BUFFET PRESSO TERZI, SERVIZI CATERING, CONVEGNI, FESTE,\nINTRATTENIMENTO E SVAGO.\nLA SOCIETA', PER IL RAGGIUNGIMENTO DELL'OGGETTO SOCIALE, POTRA' COMPIERE TUTTE\nLE OPERAZIONI COMMERCIALI, INDUSTRIALI ED IMMOBILIARI OCCORRENTI ED INOLTRE\nPOTRA' COMPIERE, IN VIA NON PREVALENTE E DEL TUTTO ACCESSORIA E STRUMENTALE E\nCOMUNQUE CON ESPRESSA ESCLUSIONE DI QUALSIASI ATTIVITA' SVOLTA NEI CONFRONTI\nDEL PUBBLICO, OPERAZIONI FINANZIARIE E MOBILIARI, CONCEDERE FIDEIUSSIONI,\nAVALLI, CAUZIONI, GARANZIE ANCHE A FAVORE DI TERZI, NONCHE' ASSUMERE, SOLO A\nSCOPO DI STABILE INVESTIMENTO E NON DI COLLOCAMENTO, SIA DIRETTAMENTE CHE\nINDIRETTAMENTE, PARTECIPAZIONI IN SOCIETA' ITALIANE ED ESTERE AVENTI OGGETTO\nANALOGO, AFFINE O CONNESSO AL PROPRIO. #Luana	naturalovers.it	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.872906	f	f	\N	\N	[]	0	active	\N	pending	\N
1572129	\N	TINGHI MOTORS - S.R.L.	918250481.0	00918250481	VIA L. GIUNTINI, 39/43	EMPOLI	50053.0	FI	Toscana	NaN	\N	37	2025-02-12	NaN	www.tinghimotors.it	NaN	0571-592500	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.875563	f	f	\N	\N	[]	0	active	\N	pending	\N
1572131	\N	PRO STUDIO S.R.L. SOCIETA' TRA PROFESSIONISTI	36320281.0	00036320281	VIA ROMA, 72.1 I	VILLAFRANCA PADOVANA	35010.0	PD	Veneto	Italia	\N	12	2025-02-12	Studio commercialista	www.prostudiosrl.it	NaN	0499050399	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.878006	f	f	\N	\N	[]	0	active	\N	pending	\N
1572142	\N	I.C.P. S.P.A.	3438751202.0	03438751202	VIA DELL ARCOVEGGIO, 74-2	BOLOGNA	40129.0	BO	Emilia-romagna	Italia	\N	33	2025-02-12	NaN	www.icpspa.com	NaN	051 0827467	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.880534	f	f	\N	\N	[]	0	active	\N	pending	\N
1572152	\N	DE.FI.ME - S.R.L.	2855760100.0	02855760100	VIA COLANO, 9/14 M	GENOVA	16162.0	GE	Liguria	Italia	\N	14	2025-02-12	NaN	www.defime.net	NaN	01074502553	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.882828	f	f	\N	\N	[]	0	active	\N	pending	\N
1572177	\N	DELTA INFORMATICA S.P.A.	1112330228.0	NaN	via Kufstein, 5	Trento	38121.0	Trento	Trentino-Alto Adige/Südtirol	Italia	\N	0	2025-02-12	NaN	https://www.deltainformatica.eu/	NaN	046.1042200	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.885063	f	f	\N	\N	[]	0	active	\N	pending	\N
1572178	\N	SANGFOR TECHNOLOGIES ITALY S.r.l.	11946590962.0	NaN	Centro Direzionale Le Torri Via Marsala 36B	Gallarate	21013.0	Varese	Lombardia	Italia	\N	0	2025-02-12	NaN	https://www.sangfor.com/it	NaN	0331.648773	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.887316	f	f	\N	\N	[]	0	active	\N	pending	\N
1572182	\N	GREENTEC	4401700986.0	NaN	Via Aldo Moro 10	Brescia	25124.0	Brescia	Lombardia	Italia	\N	0	2025-02-12	EROGATORI Linea Home\nPROFESSIONAL Ho.re.ca\nTRATTAMENTO ACQUE Addolcitori\nSOLUZIONI SOSTENIBILI Energia\n\n\nL’azienda Greentec pone la propria VISION nell’intento di migliorare il proprio stile di vita, in maniera SANA, sia in ambiente professionale che domestico, attraverso dispositivi ECOLOGICI, 100% MADE IN ITALY.\nLe parole d’ordine sono:\nINNOVAZIONE,\nSOSTENIBILITÀ,\nSALUTE & BENESSERE\nCrediamo fortemente che la sostenibilità non sia la ricerca della perfezione ma bensì una visione a lungo termine, moralmente condivisa ed economicamente percorribile.	https://www.greentecitalia.it/	NaN	329.9770037	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.889552	f	f	\N	\N	[]	0	active	\N	pending	\N
1572278	\N	FONDITAL SPA	667490981.0	01963300171	VIA CERRETO, 40	VOBARNO	25079.0	BS	Lombardia	Italia	\N	898	2025-02-13	Produce radiatori in alluminio e sistemi di riscaldamento.	www.fondital.it	NaN	036587831	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:34.892002	f	f	\N	\N	[]	0	active	\N	pending	\N
1582939	\N	ENTERPRISE S.R.L.	648320224.0	00648320224	VIA DELL'ORA DEL GARDA, 103	TRENTO	38121.0	TN	Trentino-alto adige	NaN	\N	129	2025-02-13	NaN	www.bevandewin.it	NaN	0461-822264	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.894253	f	f	\N	\N	[]	0	active	\N	pending	\N
1583310	\N	VIDA S.P.A.	2783670983.0	02783670983	VIA STAZIONE VECCHIA, 55/57	PROVAGLIO D'ISEO	25050.0	BS	Lombardia	NaN	\N	62	2025-02-13	- Gruppo di 6 punti vendita di materiali edili; \n- realizza manufatti di carpenteria conto terzi;\n- vende tinte su misura;\n- vende all'ingrosso e al dettaglio articoli di ferramenta, elettroutensili e utensileria professionale.	www.vidasrl.net	NaN	0365-541296	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:34.896919	f	f	\N	\N	[]	0	active	\N	pending	\N
1584011	\N	O.M.O. S.P.A.	565170982.0	00467770178	VIA MADONNINA, 1/5	ODOLO	25067.0	BS	Lombardia	Italia	\N	21	2025-02-13	Azienda specializzata in:\n- calibratura cilindri in acciaio e ghisa di ogni profilo;\n- calibratura rulli in carburo di ogni tipo;\n- nervatura e marchio;\n- riporti vari su cilindri in acciaio e ghisa;\n- montaggi rulli in carburo;\n- rettifica cilindri e alberi.	NaN	NaN	0365860126	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:34.899192	f	f	\N	\N	[]	0	active	\N	pending	\N
1584018	\N	FBL PRESSOFUSIONI S.R.L.	568050983.0	00508440179	VIA PROVINCIALE, 55	VOBARNO	25079.0	BS	Lombardia	Italia	\N	91	2025-02-13	Azienda che sviluppa e produce particolari tecnici in pressofusione di alluminio di medie e grandi dimensioni, per la media e grande serie; si va dai componenti per il settore automobilistico, fino agli accessori finalizzati ai comparti elettrico industriale.	www.fblcastings.it	NaN	0365825043	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:34.901371	f	f	\N	\N	[]	0	active	\N	pending	\N
1584025	\N	STUDIO GABRIELLI APPOLONI SRL	2311940221.0	02311940221	VIA TORRE VERDE, 21	TRENTO	38122.0	TN	Trentino-alto adige	Italia	\N	0	2025-02-13	NaN	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.903746	f	f	\N	\N	[]	0	active	\N	pending	\N
1584031	\N	LEALI DOTTOR FRANCESCO	2360890988.0	LLEFNC73S27B157V	Via Toccabelli Monsignor	Vestone	25078.0	Brescia	Lombardia	Italia	\N	0	2025-02-13	NaN	NaN	info@studioleali.com;federico.leali@studioleali.com	3343104218	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:34.909111	f	f	\N	\N	[]	0	active	\N	pending	\N
1584033	\N	TMF CONSULTING SRL	3639290984.0	03639290984	VICOLO UNGARETTI, 13/B	MAZZANO	25080.0	BS	Lombardia	Italia	\N	3	2025-02-13	NaN	www.tmfconsulting.it	NaN	0302629471	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:34.912545	f	f	\N	\N	[]	0	active	\N	pending	\N
1584056	\N	F.A.I.C. INDUSTRY S.R.L.	1633460090.0	01633460090	STRADA ANTICA DI NONE, 2	BEINASCO	10092.0	TO	Piemonte	Italia	\N	37	2025-02-14	NaN	www.faicindustry.it	NaN	011-2673240	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.91558	f	f	\N	\N	[]	0	active	\N	pending	\N
1584058	\N	ASSE S.R.L.	2008430999.0	02008430999	VIA GOFFREDO MAMELI, 234	RAPALLO	16035.0	GE	Liguria	NaN	\N	32	2025-02-14	Codice Ateco: 47.11.2 - identifica l'attività di commercio al dettaglio in esercizi non specializzati con prevalenza di prodotti alimentari e bevande, nello specifico quella dei supermercati.#Luana	NaN	NaN	0185-67954	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.918171	f	f	\N	\N	[]	0	active	\N	pending	\N
1584061	\N	FIERAMENTE SRL	6583970485.0	06583970485	VIA NELLO TRAQUANDI, 5/7	MONTEVARCHI	52025.0	AR	Toscana	Italia	\N	50	2025-02-14	NaN	www.bencienni.it	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.92087	f	f	\N	\N	[]	0	active	\N	pending	\N
1584109	\N	CAVARRETTA ASSICURAZIONI DI GIANFRANCO CAVARRETTA E FRANCO AUDISIO E C. SOCIETA' IN ACCOMANDITA SEMPLICE	2270061209.0	91216050376	VIA MAZZINI, 146/2	BOLOGNA	40138.0	BO	Emilia-romagna	Italia	\N	9	2025-02-14	NaN	NaN	NaN	051346992	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.923256	f	f	\N	\N	[]	0	active	\N	pending	\N
1584143	\N	OTTICA ROLIN S.R.L.	2065500163.0	02065500163	VIA ENRICO FERMI, 1	CURNO	24035.0	BG	Lombardia	NaN	\N	6	2025-02-13	NaN	www.otticarolin.org	NaN	035-462330	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.9259	f	f	\N	\N	[]	0	active	\N	pending	\N
1584160	\N	HIHO S.R.L.	5443270482.0	05443270482	VIA GAETANO DONIZETTI, 52	SCANDICCI	50018.0	FI	Toscana	NaN	\N	1	2025-02-14	NaN	www.figline.it	NaN	055-9125446	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.928438	f	f	\N	\N	[]	0	active	\N	pending	\N
1584204	\N	PROGETTO S.P.A.	1075860310.0	01075860310	VIA C. COSULICH, 20	MONFALCONE	34074.0	GO	Friuli-venezia giulia	Italia	\N	7	2025-02-14	NaN	www.europalacehotel.com	NaN	0481.486447	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.931141	f	f	\N	\N	[]	0	active	\N	pending	\N
1584208	\N	CORMEDICA S.R.L.	1101010310.0	01101010310	VIA FILANDA, 2/A	CORMONS	34071.0	GO	Friuli-venezia giulia	Italia	\N	12	2025-02-14	Centro medico con 3 sedi. Gestito da un fondo, Quadrilio.	referti.cormedica.it	NaN	0481-630417	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.933327	f	f	\N	\N	[]	0	active	\N	pending	\N
1584209	\N	OSTERIA DEL CAFFE' S.R.L.	1296480328.0	01296480328	VIA VALDIRIVO, 6	TRIESTE	34132.0	TS	Friuli-venezia giulia	Italia	\N	14	2025-02-14	NaN	https://www.facebook.com/osteriadelcaffe/?ref=bookmarks	NaN	040.9571251	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.93551	f	f	\N	\N	[]	0	active	\N	pending	\N
1584214	\N	ITER IMPRESA SOCIALE S.R.L.	1311490328.0	01311490328	VIA VALDIRIVO, 6	TRIESTE	34132.0	TS	Friuli-venezia giulia	NaN	\N	9	2025-02-14	NaN	www.hotello.space	NaN	040-9892908	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.93791	f	f	\N	\N	[]	0	active	\N	pending	\N
1584238	\N	OMT BONETTO S.R.L.	4456290289.0	04456290289	VIA FORNACE PRIMA STRADA, 5	SAN GIORGIO DELLE PERTICHE	35010.0	PD	Veneto	Italia	\N	25	2025-02-14	NaN	www.omttech.com	NaN	049.5742838	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.940429	f	f	\N	\N	[]	0	active	\N	pending	\N
1584250	\N	V & V GROUP SRL	4020460244.0	04020460244	VIA BEATO BARTOLOMEO, 17	BREGANZE	36042.0	VI	Veneto	Italia	\N	3	2025-02-14	Azienda che installa Fotovoltaico	www.vev-group.com	NaN	0444040161	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.943009	f	f	\N	\N	[]	0	active	\N	pending	\N
1584256	\N	FARMACIA RUBINO S.R.L.	1162910325.0	01162910325	VIA DELLE SETTEFONTANE, 39	TRIESTE	34141.0	TS	Friuli-venezia giulia	Italia	\N	12	2025-02-14	Farmacia molto dinamica e aperta alla possibilità di agevolazioni	www.farmaciarubino.net	NaN	040.390898	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.945599	f	f	\N	\N	[]	0	active	\N	pending	\N
1584376	\N	KRESOS S.R.L.	2291340244.0	02291340244	VIA MONTE ORTIGARA, 18/E	CORNEDO VICENTINO	36073.0	VI	Veneto	Italia	\N	11	2025-02-17	NaN	NaN	NaN	0445400411	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.948018	f	f	\N	\N	[]	0	active	\N	pending	\N
1584379	\N	4 CIACOLE S.R.L.	4641910239.0	04641910239	PIAZZA VITTORIO EMANUELE, 10	ROVERCHIARA	37050.0	VR	Veneto	Italia	\N	5	2025-02-17	Codice Ateco: 56.10.11\nRistorante Locanda #Luana	www.le4ciacole.it	NaN	0459617792	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.950496	f	f	\N	\N	[]	0	active	\N	pending	\N
1584506	\N	KOMPLETT SOCIETA' COOPERATIVA	2061150229.0	02061150229	VIA ALDO MORO, 51	ARCO	38062.0	TN	Trentino-alto adige	Italia	\N	216	2025-02-16	NaN	www.komplettservizi.it	NaN	0464521555	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:34.952727	f	f	\N	\N	[]	0	active	\N	pending	\N
1584555	\N	EUTEL 2005 S.R.L.	3074480926.0	03074480926	VIA STANISLAO CABONI, 3	CAGLIARI	9125.0	CA	Sardegna	Italia	\N	49	2025-02-17	NaN	www.risparmiatu.com	NaN	349.4384149	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:34.956177	f	f	\N	\N	[]	0	active	\N	pending	\N
1584558	\N	SPRINT CAR AND SERVICE - SOCIETA' COOPERATIVA	8173331003.0	08173331003	VIA LUCIO MARIANI, 66	ROMA	178.0	RM	Lazio	NaN	\N	8	2025-02-17	NaN	www.sprintcarservice.com	NaN	06-72633435	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:34.958933	f	f	\N	\N	[]	0	active	\N	pending	\N
1584563	\N	STUDIO FARINA E LA ROCCA DI GIUSEPPE LA ROCCA & C. S.A.S.	1722820089.0	01722820089	VIA RUFFINI, 14	SANREMO	18038.0	IM	Liguria	NaN	\N	8	2025-02-16	01/07 La ragione sociale è     SOCIETA' TRA PROFESSIONISTI STUDIO FARINA E LA ROCCA DI GIUSEPPE LA ROCCA & C. S.A.S. ma per comodità nella ricerca correggo lasciando solo Studio Farina La Rocca #Barbara	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.961869	f	f	\N	\N	[]	0	active	\N	pending	\N
1584571	\N	IET SERVICE S.A.S. DI ROBERTO VITAGGIO & C.	1325640454.0	01325640454	VIA DEGLI ARTIGIANI, 16	MASSA	54100.0	MS	Toscana	NaN	\N	8	2025-02-17	NaN	NaN	info@ietservice.it	377 4358822	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.964892	f	f	\N	\N	[]	0	active	\N	pending	\N
1584572	\N	SUPERPRICE S.R.L.	2787810908.0	02787810908	VIALE ALDO MORO, 260	OLBIA	7026.0	SS	Sardegna	Italia	\N	6	2025-02-17	NaN	NaN	lucah@ymail.com	0789387144	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.967883	f	f	\N	\N	[]	0	active	\N	pending	\N
1584574	\N	STUDIO MASINI E CO SRL	2185130503.0	02185130503	VIA ANTONIO GRAMSCI, 52	BIENTINA	56031.0	PI	Toscana	Italia	\N	5	2025-02-17	NaN	NaN	NaN	0587962965	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.970382	f	f	\N	\N	[]	0	active	\N	pending	\N
1584578	\N	PRENOTAZIONI 24 S.R.L.	1512130491.0	01512130491	VIA BONISTALLO, 50/B	EMPOLI	50053.0	FI	Toscana	Italia	\N	48	2025-02-17	NaN	www.traghettilines.it	NaN	0565912011	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.973146	f	f	\N	\N	[]	0	active	\N	pending	\N
1584592	\N	CANTINA SOCIALE DI NIZZA MONFERRATO   SOCIETA' COOPERATIVA AGRICO LA  SIGLABILE: CANTINA DI NIZZA SOC. COOP. AGR. CANTINA DI NIZZA CANTINA DEL NIZZA	72300056.0	00072300056	STRADA ALESSANDRIA, 57	NIZZA MONFERRATO	14049.0	AT	Piemonte	Italia	\N	16	2025-02-17	NaN	www.nizza.it	NaN	0141721348	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:34.97575	f	f	\N	\N	[]	0	active	\N	pending	\N
1584618	\N	ISOFT S.R.L.	3569920261.0	03569920261	VIA MOLINETTO, 110/A	BORSO DEL GRAPPA	31030.0	TV	Veneto	Italia	\N	6	2025-02-17	Software House per macchine sul settore orafo.	www.isoft.it	NaN	0423 910250	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.978253	f	f	\N	\N	[]	0	active	\N	pending	\N
1584621	\N	C.O.F. - CENTRO ORTOPEDICO FISIOTERAPICO  SOCIETA' A RESPONSABILITA' LIMITATA	1172751008.0	03218320582	VIA DEGLI ATLANTICI,	VELLETRI	49.0	RM	Lazio	Italia	\N	11	2025-02-17	NaN	www.cofvelletri.it	NaN	06-9636510	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:34.981006	f	f	\N	\N	[]	0	active	\N	pending	\N
1584627	\N	ESSEPIEFFE ITALIA S.R.L.	2082590643.0	02082590643	ZONA INDUSTRIALE PIP,	PIETRADEFUSI	83030.0	AV	Campania	NaN	\N	80	2025-02-17	Stampaggio polieretano	www.essepieffeitalia.it	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.983906	f	f	\N	\N	[]	0	active	\N	pending	\N
1584629	\N	B&B SERVICE S.R.L.	1673670384.0	01673670384	VIA A. TOSCANINI, 14 A	FERRARA	44124.0	FE	Emilia-romagna	NaN	\N	8	2025-02-17	Codice Ateco: 43.21.01 - Installazione di impianti elettrici in edifici o in altre opere di costruzione (inclusa manutenzione e riparazione). #Luana	NaN	NaN	3457284468	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:34.987178	f	f	\N	\N	[]	0	active	\N	pending	\N
1584633	\N	LESTINI FRANCO	409201001.0	LSTFNC46D21A132R	VIA GALLERIE DI SOTTO, 15	ALBANO LAZIALE	41.0	RM	Lazio	Italia	\N	3	2025-02-17	NaN	vw.lestinifranco.it	NaN	06-9324573	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:34.990408	f	f	\N	\N	[]	0	active	\N	pending	\N
1584638	\N	VE.GA. CED SRL	4160680270.0	04160680270	VIA ORSA MAGGIORE, 34	SAN MICHELE AL TAGLIAMENTO	30020.0	VE	Veneto	Italia	\N	10	2025-02-17	NaN	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.993691	f	f	\N	\N	[]	0	active	\N	pending	\N
1584639	\N	VE.GA. BOOKING SRL	4478010277.0	04478010277	VIA ORSA MAGGIORE, 36	SAN MICHELE AL TAGLIAMENTO	30028.0	VE	Veneto	Italia	\N	18	2025-02-17	NaN	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:34.996776	f	f	\N	\N	[]	0	active	\N	pending	\N
1584645	\N	BRINDISI ELEVATORI S.R.L.	1697770749.0	01697770749	STRADA PICCOLI, 29	BRINDISI	72100.0	BR	Puglia	NaN	\N	37	2025-02-17	Codice Ateco: 43.29.01 - Installazione, riparazione e manutenzione di ascensori e scale mobili. # Luana	www.brindisielevatori.it	NaN	0831-515913	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:34.999902	f	f	\N	\N	[]	0	active	\N	pending	\N
1584647	\N	NON SOLO IMPIANTI S.R.L.	2355190741.0	02355190741	VIA DAUNIA, 9	BRINDISI	72100.0	BR	Puglia	NaN	\N	9	2025-02-17	NaN	NaN	NaN	0831 527756	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.003529	f	f	\N	\N	[]	0	active	\N	pending	\N
1584651	\N	ALPHA COSTRUZIONI E IMPIANTI S.R.L.	3434890756.0	03434890756	VIALE IRLANDA, 5	LECCE	73100.0	LE	Puglia	Italia	\N	30	2025-02-16	Codice Ateco: 43.21.01 - Installazione di impianti elettrici in edifici o in altre opere di costruzione (inclusa manutenzione e riparazione). # Luana	http://www.aliaci.com	NaN	0832277686	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.006384	f	f	\N	\N	[]	0	active	\N	pending	\N
1584662	\N	BLUCENTER PORTOGRUARO S.R.L.	4240790271.0	04240790271	VIA ERACLITO, 26	PORTOGRUARO	30026.0	VE	Veneto	NaN	\N	0	2025-02-17	Centro Medico veterinario	www.blucenter.it	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.009225	f	f	\N	\N	[]	0	active	\N	pending	\N
1584663	\N	C.B.A. S.R.L.	3414260277.0	03414260277	RIVIERA COMM. A. FURLANIS, 110	CONCORDIA SAGITTARIA	30023.0	VE	Veneto	NaN	\N	1	2025-02-17	Clinica veterinaria	www.clinicaveterinaria-concordia.it	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.011628	f	f	\N	\N	[]	0	active	\N	pending	\N
1584666	\N	TONDO SALVATORE	4440340752.0	TNDSVT76T25E506J	VIA E. FERMI, 7	CALIMERA	73021.0	LE	Puglia	NaN	\N	6	2025-02-17	NaN	www.ilcanapaio.it	NaN	0832-092454	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.014696	f	f	\N	\N	[]	0	active	\N	pending	\N
1584690	\N	LOGTRAS S.A.S.	2594330223.0	02594330223	VIA INNSBRUCK, 31	TRENTO	38121.0	TN	Trentino-alto adige	NaN	\N	5	2025-02-17	NaN	www.logtras.it	NaN	0461-960609	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.01789	f	f	\N	\N	[]	0	active	\N	pending	\N
1584691	\N	LOGTRAS S.R.L.	1699440226.0	01699440226	VIA INNSBRUCK, 31	TRENTO	38121.0	TN	Trentino-alto adige	NaN	\N	11	2025-02-17	NaN	www.logtras.it	NaN	0461-960609	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.020385	f	f	\N	\N	[]	0	active	\N	pending	\N
1584695	\N	POLG SRL	812040244.0	01537850289	VIA MONTE VERENA, 27	CASSOLA	36022.0	VI	Veneto	Italia	\N	23	2025-02-17	NaN	www.polg.it	NaN	0424570192	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.023122	f	f	\N	\N	[]	0	active	\N	pending	\N
1584699	\N	SKYNAT SRL	3625020247.0	03625020247	VIA GIOVANNI DOLFIN, 1	THIENE	36016.0	VI	Veneto	Italia	\N	5	2025-02-17	L'azienda si occupa di commercializzare materiale per le imprese: antinfortunistica, pulizia ecc...\nIn azienda sono in 6 a busta paga e tutti che utilizzano il pc.\nNel 2021 hanno inserito un Software nuovo dove hanno speso circa 20.000€.\nPrecedentemente ne avevano uno di Zucchetti acquistato nel 2010 ma negli anni ampliato nella sua composizione.	NaN	NaN	0445-820024	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.026131	f	f	\N	\N	[]	0	active	\N	pending	\N
1584700	\N	ECOSISTEMA SAS DI MATTEO SERRA & C.	1324680295.0	01324680295	VIA EINAUDI, 115	ROVIGO	45100.0	RO	Veneto	NaN	\N	2	2025-02-17	NaN	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.028893	f	f	\N	\N	[]	0	active	\N	pending	\N
1584707	\N	ENPOWER S.R.L.	3097820983.0	03097820983	VIA GUGLIELMO OBERDAN, 1/A	BRESCIA	25128.0	BS	Lombardia	Italia	\N	102	2025-02-17	E' una società che opera nel settore dell'energia, ponendosi sul mercato come Contractor nella realizzazione e nella gestione di impianti Tecnologici.	www.enpower.eu	NaN	036581320	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:35.031783	f	f	\N	\N	[]	0	active	\N	pending	\N
1585184	\N	G.V.S. SRL	3398740286.0	03398740286	VIA CESARE PAVESE, 26	SELVAZZANO DENTRO	35030.0	PD	Veneto	Italia	\N	11	2025-02-17	NaN	www.gvsstampi.it	NaN	049.8974241	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.034568	f	f	\N	\N	[]	0	active	\N	pending	\N
1585303	\N	SABRE ITALIA S.R.L.	498100247.0	00498100247	VIA SPINA', 9	ISOLA VICENTINA	36033.0	VI	Veneto	Italia	\N	8	2025-02-18	NaN	www.sabreitalia.com	NaN	0444976041	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.036894	f	f	\N	\N	[]	0	active	\N	pending	\N
1585307	\N	ANGELUS S.R.L.	3986241200.0	03986241200	VIA GIANNI PALMIERI, 25	BOLOGNA	40138.0	BO	Emilia-romagna	NaN	\N	10	2025-02-18	NaN	NaN	NaN	051-302997	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.040023	f	f	\N	\N	[]	0	active	\N	pending	\N
1585309	\N	TREVISOSTAMPA S.R.L.	4161650264.0	04161650264	VIA EDISON, 133	VILLORBA	31050.0	TV	Veneto	NaN	\N	10	2025-02-18	NaN	www.trevisostampa.it	NaN	0422-440200	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.043023	f	f	\N	\N	[]	0	active	\N	pending	\N
1585320	\N	ROSSI S.R.L.	1294580285.0	01294580285	VIA COLOMBO, 15	CAMPODARSEGO	35011.0	PD	Veneto	NaN	\N	116	2025-02-18	NaN	www.rossisas.it	NaN	049-9201166	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.046097	f	f	\N	\N	[]	0	active	\N	pending	\N
1585327	\N	MODELLERIA BUGGIN S.R.L.	4122220280.0	04122220280	VIA DEL LAVORO, 16	VIGONZA	35010.0	PD	Veneto	NaN	\N	12	2025-02-18	NaN	NaN	NaN	049.8930800	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.04939	f	f	\N	\N	[]	0	active	\N	pending	\N
1585335	\N	CO.I.MA. - COSTRUZIONI IDRAULICHE MARANGONI - S.R.L.	1289660241.0	01289660241	VIA DELL'ARTIGIANATO, 71	CAMISANO VICENTINO	36043.0	VI	Veneto	Italia	\N	47	2025-02-18	NaN	www.impresacoima.it	NaN	0444413322	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.053057	f	f	\N	\N	[]	0	active	\N	pending	\N
1585345	\N	IMPRESA EDILE ABBADESSE S.R.L.	1469430241.0	01469430241	VIA VANZO NUOVO, 61/A	CAMISANO VICENTINO	36043.0	VI	Veneto	Italia	\N	44	2025-02-18	NaN	www.edileabbadesse.it	NaN	0444 413737	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.056277	f	f	\N	\N	[]	0	active	\N	pending	\N
1585352	\N	BONFANTI CAR SRL	4200270165.0	04200270165	VIA VITRUVIO, 15	VERONA	37138.0	VR	Veneto	Italia	\N	21	2025-02-18	Codice Ateco: 45.11.01 - Commercio al dettaglio di autoveicoli e autovetture. (Concessionaria).#Luana	www.bonfanticar.it	NaN	035500613	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.058804	f	f	\N	\N	[]	0	active	\N	pending	\N
1585373	\N	B.L.T. TRANSPORT SRL	4343970614.0	04343970614	VIA RIMINI, 7	RUBIERA	42048.0	RE	Emilia-romagna	Italia	\N	25	2025-02-18	NaN	www.blttransport.it	NaN	0522.087370	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.061483	f	f	\N	\N	[]	0	active	\N	pending	\N
1585387	\N	STUDIO COSTENARO S.R.L.	3699110247.0	03699110247	PIAZZA F.FILIPPI, 18	MAROSTICA	36063.0	VI	Veneto	Italia	\N	9	2025-02-18	NaN	www.studiocostenaro.com	NaN	0424473062	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.06413	f	f	\N	\N	[]	0	active	\N	pending	\N
1585392	\N	GRUPPO LUMACA S.R.L.	10536691008.0	10536691008	VIA DEI CANDIANO, 58	ROMA	148.0	RM	Lazio	NaN	\N	14	2025-02-18	NaN	NaN	NaN	348.9042240	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.066755	f	f	\N	\N	[]	0	active	\N	pending	\N
1585396	\N	KM S.R.L.	2033020229.0	02033020229	PIAZZA GRANDA, 54	CLES	38023.0	TN	Trentino-alto adige	NaN	\N	14	2025-02-18	NaN	www.pizzagrandacles.com	NaN	0463-424007	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.069839	f	f	\N	\N	[]	0	active	\N	pending	\N
1585400	\N	LA PERGOLA SRLS	1916520388.0	01916520388	VIA TASSINARI, 30/1	CENTO	44042.0	FE	Emilia-romagna	NaN	\N	14	2025-02-18	NaN	www.alleaie.it	NaN	335.7503403	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.072685	f	f	\N	\N	[]	0	active	\N	pending	\N
1585416	\N	SERRA TRASPORTI E LOGISTICA S.R.L.	1156930958.0	01156930958	S.S.131 KM.100  LOC SA TURRITA, KM.100	SIAMAGGIORE	9070.0	OR	Sardegna	NaN	\N	8	2025-02-18	NaN	NaN	NaN	0783.33390	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.075322	f	f	\N	\N	[]	0	active	\N	pending	\N
1585423	\N	CONSULCOOP SOCIETA' COOPERATIVA A RESPONSABILITA' LIMITATA	649290954.0	00649290954	VIA XX SETTEMBRE, 25	ORISTANO	9170.0	OR	Sardegna	Italia	\N	4	2025-02-18	NaN	NaN	NaN	0783768749	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.078749	f	f	\N	\N	[]	0	active	\N	pending	\N
1585428	\N	S. E C. S.R.L.	1059570950.0	01059570950	VIA DEI MURATORI, 6 A	ORISTANO	9170.0	OR	Sardegna	Italia	\N	5	2025-02-18	NaN	NaN	NaN	348.1558671	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.082063	f	f	\N	\N	[]	0	active	\N	pending	\N
1585434	\N	ANTEA S.R.L.S.	1226050951.0	01226050951	VIA CAGLIARI, 387	ORISTANO	9170.0	OR	Sardegna	Italia	\N	6	2025-02-18	Codice Ateco: 66.22.00 - Attività di agenti e di intermediari delle Assicurazioni. #Luana	NaN	NaN	347.9342518	\N	NaN	["Giovanni Fulgheri"]	2025-07-03 20:34:35.085337	f	f	\N	\N	[]	0	active	\N	pending	\N
1585446	\N	CLOUD CONSULENTICA S.R.L.	3918900923.0	03918900923	VICO UMBERTO I, 1	ORISTANO	9170.0	OR	Sardegna	Italia	\N	6	2025-02-18	NaN	NaN	NaN	0783390594	\N	NaN	["Giovanni Fulgheri"]	2025-07-03 20:34:35.088524	f	f	\N	\N	[]	0	active	\N	pending	\N
1585452	\N	LEO VIRIDIS S.R.L.	1183540952.0	01183540952	VIA G.M . ANGIOJ, 8	ARBOREA	9092.0	OR	Sardegna	Italia	\N	3	2025-02-18	NaN	NaN	NaN	392 4815404	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.090943	f	f	\N	\N	[]	0	active	\N	pending	\N
1585488	\N	OHANA S.R.L.	1183410958.0	01183410958	VIA PORCELLA, 88	TERRALBA	9098.0	OR	Sardegna	Italia	\N	4	2025-02-18	NaN	NaN	NaN	0783462353	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.093184	f	f	\N	\N	[]	0	active	\N	pending	\N
1586249	\N	BANCA VALSABBINA	NaN	NaN	Via XXV Aprile, 8	Brescia	25121.0	Brescia	Lombardia	Italia	\N	0	2025-02-19	BANCA\nCodice Ateco: 64.19.1- Intermediazione monetaria di istituti monetari diverse dalle Banche centrali. #Luana	NaN	alberto.pievani@bancavalsabbina.com	NaN	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:35.096561	f	f	\N	\N	[]	0	active	\N	pending	\N
1586256	\N	INNPROJEKT FUTURE LAB SRL	2915140343.0	02915140343	STRADA LANGHIRANO, 136	PARMA	43124.0	PR	Emilia-romagna	Italia	\N	19	2025-02-19	NaN	NaN	NaN	0521 977500	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.100537	f	f	\N	\N	[]	0	active	\N	pending	\N
1586264	\N	SINERGIE S.R.L.	13060090159.0	13060090159	PIAZZA GUGLIELMO OBERDAN, 2/A	MILANO	20129.0	MI	Lombardia	Italia	\N	40	2025-02-19	NaN	www.twico.it/	NaN	0283450000	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.103908	f	f	\N	\N	[]	0	active	\N	pending	\N
1586267	\N	SG COMPANY SOCIETA' BENEFIT SPA E CON SIGLA  SG COMPANY S.B. SPA	9005800967.0	09005800967	PIAZZA GUGLIELMO OBERDAN, 2/A	MILANO	20129.0	MI	Lombardia	NaN	\N	8	2025-02-19	NaN	www.sg-holding.it	NaN	02-83450000	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.106828	f	f	\N	\N	[]	0	active	\N	pending	\N
1586269	\N	CENTRO SERVIZI S.E.F. S.R.L.	1502650995.0	01502650995	VIA VOLTA, 39 A	RAPALLO	16035.0	GE	Liguria	Italia	\N	9	2025-02-19	NaN	www.centroservizisef.it	NaN	0185234774	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.109492	f	f	\N	\N	[]	0	active	\N	pending	\N
1586276	\N	AUTOMOBILI VALENTINO SRL	10211480966.0	10211480966	VIA LUISA BATTISTOTTI SASSI, 6	MILANO	20133.0	MI	Lombardia	Italia	\N	5	2025-02-19	NaN	NaN	NaN	340.6762828	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.112181	f	f	\N	\N	[]	0	active	\N	pending	\N
1586287	\N	SUNSERVICE ENERGY SOLUTIONS S.R.L.	2374440903.0	02374440903	ZONA INDUSTRIALE PREDDA NIEDDA STRADA N. 39, 10	SASSARI	7100.0	SS	Sardegna	NaN	\N	27	2025-02-19	NaN	NaN	NaN	079.2600401	\N	NaN	["Fabio Aliboni"]	2025-07-03 20:34:35.114872	f	f	\N	\N	[]	0	active	\N	pending	\N
1586304	\N	SUNSERVICE S.R.L.	1998320905.0	01998320905	ZONA INDUSTRIALE PREDDA NIEDDA  STRADA  39, 10	SASSARI	7100.0	SS	Sardegna	Italia	\N	15	2025-02-19	NaN	www.sunservicesrl.it	NaN	800770219	\N	NaN	["Fabio Aliboni"]	2025-07-03 20:34:35.117233	f	f	\N	\N	[]	0	active	\N	pending	\N
1586314	\N	BENE S.R.L.	2026350997.0	02026350997	CORSO MARTINETTI, 4/6	GENOVA	16149.0	GE	Liguria	NaN	\N	17	2025-02-19	Codice Ateco: 32.99.1 - Fabbricazione di attrezzature ed articoli di vestiario protettivi di sicurezza. (Formazione, Antincendio, Disinfestazione, Impianti elettrici). #Luana	www.benesrl.it	NaN	0103-472316	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.120474	f	f	\N	\N	[]	0	active	\N	pending	\N
1586368	\N	GALUPPINI RAG. ROBERTO	NaN	NaN	Via Pietro Marone, 15	Brescia	25124.0	Brescia	Lombardia	Italia	\N	0	2025-02-19	Consulente del Lavoro	NaN	info@studiogaluppinicdl.it	+390308035273	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:35.12349	f	f	\N	\N	[]	0	active	\N	pending	\N
1588174	\N	P.R. COMMERCIALISTI RIUNITI SOCIETA' TRA PROFESSIONISTI S.R.L. IN SIGLA: P.R. COMMERCIALISTI RIUNITI S.T.P. S.R.L.	1374530457.0	01374530457	VIA DORSALE, 9	MASSA	54100.0	MS	Toscana	Italia	\N	5	2025-02-20	NaN	NaN	NaN	0585.793093	\N	NaN	["Fabio Aliboni"]	2025-07-03 20:34:35.127004	f	f	\N	\N	[]	0	active	\N	pending	\N
1588216	\N	DELLA PINA RENATO	695060459.0	DLLRNT64T27F023P	VIA MASSA AVENZA, 22	MASSA	54100.0	MS	Toscana	Italia	\N	14	2025-02-20	NaN	NaN	NaN	348.2341504	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.129869	f	f	\N	\N	[]	0	active	\N	pending	\N
1588225	\N	EFINEN SRL	1488660117.0	01488660117	PIAZZA CESARE BATTISTI, 38	LA SPEZIA	19121.0	SP	Liguria	Italia	\N	12	2025-02-20	NaN	www.illagora.com	NaN	340.0783586	\N	NaN	["Fabio Aliboni"]	2025-07-03 20:34:35.132567	f	f	\N	\N	[]	0	active	\N	pending	\N
1588230	\N	LUSARDI SAS DI LUSARDI ENRICO & FRATELLI	2426340101.0	02426340101	VIA GEIRATO, 83	GENOVA	16138.0	GE	Liguria	Italia	\N	56	2025-02-20	NaN	www.lusardilogistica.it	NaN	010.8355292	\N	NaN	["Fabio Aliboni"]	2025-07-03 20:34:35.135543	f	f	\N	\N	[]	0	active	\N	pending	\N
1588237	\N	PACINI TRADE S.R.L.	2304950468.0	02304950468	VIA PESCIATINA, 233	CAPANNORI	55013.0	LU	Toscana	Italia	\N	8	2025-02-20	NaN	www.pacinitrade.com	NaN	0583.928366	\N	NaN	["Fabio Aliboni"]	2025-07-03 20:34:35.138457	f	f	\N	\N	[]	0	active	\N	pending	\N
1588248	\N	CORAZZA LORENZO GABRIELE E C. S.A.S.	2155000181.0	02155000181	VIA PIERMARINI, 5	PAVIA	27100.0	PV	Lombardia	NaN	\N	8	2025-02-20	NaN	NaN	NaN	0382.571403	\N	NaN	["Fabio Aliboni"]	2025-07-03 20:34:35.142195	f	f	\N	\N	[]	0	active	\N	pending	\N
1588262	\N	BACCELLI LUCA	1310560113.0	BCCLCU68R06E463L	VIA A. ROMANA, 8/10	BRUGNATO	19020.0	SP	Liguria	Italia	\N	14	2025-02-20	Codice Ateco: 47.11.14 - Commercio al dettaglio di prodotti surgelati. #Luana	NaN	NaN	335.6906538	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.145441	f	f	\N	\N	[]	0	active	\N	pending	\N
1588266	\N	ROEMER GROUP DI MARCO BOZZA SAS	2636410215.0	02636410215	VIA MERCATO, 12	LAGUNDO	39022.0	BZ	Trentino-alto adige	NaN	\N	92	2025-02-20	NaN	www.roemerkeller.it	NaN	0473-446593	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.14867	f	f	\N	\N	[]	0	active	\N	pending	\N
1588272	\N	DALDOSS ELEVETRONIC S.P.A.	1654330222.0	01654330222	VIA AL DOS DE LA RODA, 18	PERGINE VALSUGANA	38057.0	TN	Trentino-alto adige	Italia	\N	61	2025-02-20	NaN	www.microliftdaldoss.it	NaN	0461518611	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.151386	f	f	\N	\N	[]	0	active	\N	pending	\N
1588284	\N	GEOTAG  S.R.L.	7119020969.0	07119020969	PIAZZA GUGLIELMO OBERDAN, 2/A	MILANO	20129.0	MI	Lombardia	Italia	\N	10	2025-02-20	NaN	www.geotagzone.it	NaN	0236265808	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.154119	f	f	\N	\N	[]	0	active	\N	pending	\N
1588286	\N	KALINTOUR S.R.L.	3635110756.0	03635110756	VIA CADORNA,	TRICASE	73039.0	LE	Puglia	Italia	\N	6	2025-02-20	NaN	www.kalintour.it	NaN	083 3543000	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.156895	f	f	\N	\N	[]	0	active	\N	pending	\N
1588293	\N	RDE TEAM S.R.L.	3321950739.0	03321950739	VIA SANTA LUCIA, 1	MANDURIA	74024.0	TA	Puglia	Italia	\N	16	2025-02-20	NaN	NaN	NaN	329.0537403	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.159257	f	f	\N	\N	[]	0	active	\N	pending	\N
1588312	\N	PUNTORICARICA S.R.L.	6025120483.0	06025120483	VIA SILVIO PELLICO, 11	LECCE	73100.0	LE	Puglia	Italia	\N	8	2025-02-20	NaN	www.puntoricarica.it	NaN	380.7823431	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.161578	f	f	\N	\N	[]	0	active	\N	pending	\N
1588323	\N	G.B.M. SYSTEM DI MUMMOLO DORA & C. S.A.S.	2041420270.0	02041420270	VIA A. DE GASPERI, 42/D	GRUARO	30020.0	VE	Veneto	Italia	\N	9	2025-02-20	Vendita Palmarini, Casse Automatiche e Software per il settore Ho.Re.Ca.	www.gbmsystem.it	NaN	0421773913	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.163964	f	f	\N	\N	[]	0	active	\N	pending	\N
1590969	\N	IMESA S.P.A.	246480263.0	00246480263	VIA DEGLI OLMI, 22	CESSALTO	31040.0	TV	Veneto	NaN	\N	112	2025-02-26	NaN	www.imesa.it	NaN	0421-468011	\N	Nord-Est	["Fabio Aliboni"]	2025-07-03 20:34:35.356725	f	f	\N	\N	[]	0	active	\N	pending	\N
1588328	\N	AL CANTINON DI MORO FABIO E C. S.N.C.	3913870279.0	03913870279	VIA OBERDAN, 14	CONCORDIA SAGITTARIA	30023.0	VE	Veneto	NaN	\N	5	2025-02-20	Ristorante - Hotel\nCodice Ateco: 56.10.11#Luana	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.167445	f	f	\N	\N	[]	0	active	\N	pending	\N
1588333	\N	CECCATO MOTORS S.R.L.	3044500241.0	03044500241	VIA VENEZIA, 17	PADOVA	35131.0	PD	Veneto	Italia	\N	186	2025-02-20	Vendita auto	www.ceccatomotors.com/	NaN	0498062600	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.170907	f	f	\N	\N	[]	0	active	\N	pending	\N
1588417	\N	D4U S.R.L.	1224820256.0	01224820256	VIA STRADA VECCHIA, 14	VODO CADORE	32040.0	BL	Veneto	Italia	\N	8	2025-02-20	Gestiscono appartamenti nella vallata del Cadore per privati e altre strutture	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.174227	f	f	\N	\N	[]	0	active	\N	pending	\N
1588441	\N	MEG SERVICE S.R.L.	2252290743.0	02252290743	CONTRADA PUCCIARRUTO -  LOTTO, 7	SAN PIETRO VERNOTICO	72027.0	BR	Puglia	Italia	\N	45	2025-02-21	NaN	www.megservice.eu	NaN	0831619229	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.177489	f	f	\N	\N	[]	0	active	\N	pending	\N
1588452	\N	S.I.A.P. SOCIETA' INDUSTRIALE ALBERGO DELLE PALME *S.R.L.	152310751.0	00152310751	VIA LEUCA, 90	LECCE	73100.0	LE	Puglia	Italia	\N	19	2025-02-21	NaN	www.hoteldellepalmelecce.it	NaN	0832347171	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.180318	f	f	\N	\N	[]	0	active	\N	pending	\N
1588456	\N	BASSANO HOTEL SAS DI DARIA CONTE & C.	3328860246.0	03328860246	CONTRA' CORTE S.EUSEBIO, 54	BASSANO DEL GRAPPA	36061.0	VI	Veneto	Italia	\N	16	2025-02-21	Codice Ateco: 55.01 - Servizi di alloggio di alberghi e simili (Hotel). #Luana	www.santeusebio.com	NaN	0424590318	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.182769	f	f	\N	\N	[]	0	active	\N	pending	\N
1588458	\N	CONSOLIDATI S.R.L.	2634790733.0	02634790733	VIA PER ORIA, 1	MANDURIA	74024.0	TA	Puglia	Italia	\N	6	2025-02-21	NaN	www.consolidati.it	NaN	0999735332	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.185424	f	f	\N	\N	[]	0	active	\N	pending	\N
1588459	\N	GRANDI VACANZE S.R.L.	1736010495.0	01736010495	VIA GIUSEPPE CACCIO', 11	PORTOFERRAIO	57037.0	LI	Toscana	Italia	\N	31	2025-02-21	NaN	www.enduroelba.com	NaN	0565918772	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.188412	f	f	\N	\N	[]	0	active	\N	pending	\N
1588462	\N	CALEMA S.R.L.	5124560755.0	05124560755	VIA GIOVANNI BOCCACCIO, 12	ARNESANO	73010.0	LE	Puglia	Italia	\N	2	2025-02-21	NaN	NaN	NaN	347.1477828	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.191654	f	f	\N	\N	[]	0	active	\N	pending	\N
1588493	\N	I. C. & E. S.R.L.	4598520759.0	04598520759	VIA AMEDEO SOMMOVIGO, 5	ROMA	155.0	RM	Lazio	NaN	\N	6	2025-02-21	NaN	NaN	NaN	06-87564328	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.195608	f	f	\N	\N	[]	0	active	\N	pending	\N
1588503	\N	PIEFFE S.R.L.	4313140289.0	04313140289	VIA A.CAVINATO, 12/B	CURTAROLO	35010.0	PD	Veneto	NaN	\N	37	2025-02-21	NaN	www.pieffe-srl.it	NaN	049.9620937	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.199162	f	f	\N	\N	[]	0	active	\N	pending	\N
1588515	\N	MD FRIGO SERVICE S.N.C. DI SCUDELER MAURO & C.	3291360273.0	03291360273	VIA MEDUNA, 17	SAN MICHELE AL TAGLIAMENTO	30020.0	VE	Veneto	Italia	\N	13	2025-02-21	NaN	www.mdfrigoservice.it	NaN	0431.43253	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.202356	f	f	\N	\N	[]	0	active	\N	pending	\N
1588521	\N	PALMARKET DI VIDOTTI EMANUELE & C. S.A.S.	1598200309.0	01598200309	VIA PLAINO, 30/32	PAGNACCO	33010.0	UD	Friuli-venezia giulia	Italia	\N	28	2025-02-21	NaN	www.palmarket-trade.com	NaN	0432.660143	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.204922	f	f	\N	\N	[]	0	active	\N	pending	\N
1588556	\N	GELARTE SRL	1412110114.0	01412110114	VIA AURELIA ANG. VIA DEL BRAVO, 261	CARRARA	54033.0	MS	Toscana	Italia	\N	19	2025-02-21	Somministrazione al pubblico con prestazione dei relativi servizi per la consumazione sul posto di bevande ed alimenti	www.gianpaolobassi.com	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.207539	f	f	\N	\N	[]	0	active	\N	pending	\N
1588585	\N	FISIOMED ITALIA SRL	846250322.0	00846250322	VIA CARDUCCI, 22	TRIESTE	34125.0	TS	Friuli-venezia giulia	NaN	\N	10	2025-02-20	NaN	www.fisiomedambulatori.it	NaN	040-660779	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.210886	f	f	\N	\N	[]	0	active	\N	pending	\N
1588598	\N	FARMACIA INTERNAZIONALE DI CONEGLIANO S.R.L.	5048210263.0	05048210263	VIALE ITALIA, 196	CONEGLIANO	31015.0	TV	Veneto	Italia	\N	15	2025-02-21	NaN	www.farmaciainternazionaleconegliano.it	NaN	0438-415554	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.214733	f	f	\N	\N	[]	0	active	\N	pending	\N
1588611	\N	SEASON S.R.L.	4481030270.0	04481030270	VIA DEL RASTRELLO, 15	PORTOGRUARO	30026.0	VE	Veneto	Italia	\N	49	2025-02-21	NaN	www.wunderbarbibione.it	NaN	NaN	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.218232	f	f	\N	\N	[]	0	active	\N	pending	\N
1588626	\N	POLTRONA EMME SRL	155610280.0	LNCMHL62R06B563Z	VIA FRATTINA, 28	CAMPODARSEGO	35011.0	PD	Veneto	Italia	\N	15	2025-02-21	Specializzati nella produzione di sedie, poltrone, divani e letti per hotel, navi e uffici	www.poltronaemme.com	NaN	049.9200966	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.221352	f	f	\N	\N	[]	0	active	\N	pending	\N
1588630	\N	RAMITOURS SRL	4046520245.0	04046520245	VIA MONTELLO, 104/C	MAROSTICA	36063.0	VI	Veneto	NaN	\N	8	2025-02-21	NaN	www.ramitours.it	NaN	0444-1322644	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.22455	f	f	\N	\N	[]	0	active	\N	pending	\N
1588641	\N	SALUS S.R.L.	2764580243.0	02633000282	VIA FERMI, 1	MAROSTICA	36063.0	VI	Veneto	NaN	\N	10	2025-02-21	NaN	www.salusservizi.it	NaN	0424-1910043	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.228123	f	f	\N	\N	[]	0	active	\N	pending	\N
1588670	\N	AUTOACCESSORIO POLESANO DI MUNERATO FABRIZIO & C. S.N.C.	986690295.0	00986690295	VIA DEL MERCANTE, 45/51	ROVIGO	45100.0	RO	Veneto	NaN	\N	14	2025-02-21	Codice Ateco: 45.32 - commercio al dettaglio di parti e accessori di autoveicoli. (Autoricambi). #Luana	www.autoaccessoriopolesano.it	NaN	0425-411155	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.231492	f	f	\N	\N	[]	0	active	\N	pending	\N
1588974	\N	BROTTER SRL	4345580247.0	04345580247	PIAZZA F. FILIPPI, 18	MAROSTICA	36063.0	VI	Veneto	NaN	\N	13	2025-02-24	NaN	www.brotter.it	NaN	0424-592363	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.235063	f	f	\N	\N	[]	0	active	\N	pending	\N
1588986	\N	LEO BET SRL	3990910246.0	03990910246	VIA LEONARDO DA VINCI, 5	MAROSTICA	36063.0	VI	Veneto	NaN	\N	12	2025-02-24	NaN	NaN	NaN	0424.77777	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.238646	f	f	\N	\N	[]	0	active	\N	pending	\N
1588993	\N	MAZARACK DI CONTE DENIS & C. S.N.C.	2444270272.0	02444270272	LOCALITA' STRADA BRUSSA, 51	CAORLE	30020.0	VE	Veneto	NaN	\N	48	2025-02-24	NaN	www.caseare.it	NaN	0421-217907	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.241917	f	f	\N	\N	[]	0	active	\N	pending	\N
1589012	\N	FARMACIA TONOLO DR. ALESSANDRO S.A.S.	4872590262.0	04872590262	VIA NAZIONALE, 2/F	SUSEGANA	31058.0	TV	Veneto	Italia	\N	14	2025-02-24	NaN	www.farmaqualita.it	NaN	0438-439468	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.245098	f	f	\N	\N	[]	0	active	\N	pending	\N
1589021	\N	STUDIO CERRONE & TARGA SRL	5128240289.0	05128240289	VIA TRENTO, 11	VILLAFRANCA PADOVANA	35010.0	PD	Veneto	Italia	\N	5	2025-02-24	NaN	NaN	NaN	049.8073929	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.24879	f	f	\N	\N	[]	0	active	\N	pending	\N
1589036	\N	MECCANICA SBABO SRL	543110241.0	00543110241	VIA IGNA, 19	CARRE'	36010.0	VI	Veneto	Italia	\N	31	2025-02-24	NaN	www.meccanicasbabo.it	NaN	0445.314988	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.252406	f	f	\N	\N	[]	0	active	\N	pending	\N
1589055	\N	GORETTI GOMME DI DREAS RICCARDO & C. - S.A.S.	107400327.0	00107400327	VIALE D'ANNUNZIO, 27/E	TRIESTE	34138.0	TS	Friuli-venezia giulia	Italia	\N	10	2025-02-24	Officina meccanica di riparazione auto	www.gorettigomme.eu	NaN	040-0642559	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.255506	f	f	\N	\N	[]	0	active	\N	pending	\N
1589064	\N	SOLUTIONS 600 S.R.L.	5385720288.0	05385720288	VIALE DELL INDUSTRIA, 23/A	PADOVA	35129.0	PD	Veneto	Italia	\N	5	2025-02-24	NaN	solutions600.it	NaN	0445.1813558	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.258147	f	f	\N	\N	[]	0	active	\N	pending	\N
1589070	\N	ASSICURATORE FACILE SRL - SOCIETA' BENEFIT	4019050246.0	04019050246	PIAZZA F. FILIPPI, 18	MAROSTICA	36063.0	VI	Veneto	Italia	\N	14	2025-02-24	Codice Ateco: 85.59.2 - Formazione e cosi di aggiornamento professionale. #Luana	www.assicuratorefacile.com	NaN	392.4157602	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.26078	f	f	\N	\N	[]	0	active	\N	pending	\N
1589215	\N	COBE S.R.L.	2756410300.0	02756410300	VIA CARDUCCI, 9	UDINE	33100.0	UD	Friuli-venezia giulia	Italia	\N	32	2025-02-24	NaN	NaN	NaN	0432.1610238	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.26362	f	f	\N	\N	[]	0	active	\N	pending	\N
1589416	\N	MOGENTALE S.R.L.	1880890247.0	01880890247	VIA LE VEGRE, 15	DUEVILLE	36031.0	VI	Veneto	Italia	\N	18	2025-02-24	NaN	www.mogentaleimpianti.com	NaN	0444594093	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.266905	f	f	\N	\N	[]	0	active	\N	pending	\N
1589420	\N	STUDIO DALL'OSTO S.R.L.	3376830240.0	03376830240	VIA PRA' BORDONI, 85/6	ZANE'	36010.0	VI	Veneto	Italia	\N	8	2025-02-24	NaN	www.dallosto-partners.it	NaN	0445314736	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.270092	f	f	\N	\N	[]	0	active	\N	pending	\N
1589427	\N	MJM ASSICURAZIONI SNC	3138320241.0	03138320241	VIA BATTAGLIONE VAL LEOGRA, 66	SCHIO	36015.0	VI	Veneto	NaN	\N	15	2025-02-24	NaN	www.mjmassicurazioni.it	NaN	0424-236579	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.272669	f	f	\N	\N	[]	0	active	\N	pending	\N
1589432	\N	INFINITECH SOCIETA' COOPERATIVA	3517970368.0	03517970368	VIA PASTRENGO, 25	CARPI	41012.0	MO	Emilia-romagna	NaN	\N	10	2025-02-24	NaN	www.r1studiodentistico.it	NaN	059-6228004	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.274904	f	f	\N	\N	[]	0	active	\N	pending	\N
1589437	\N	I.M.A.S. SRL	2086430242.0	00163080245	VIA VANZO NUOVO, 60	CAMISANO VICENTINO	36043.0	VI	Veneto	Italia	\N	13	2025-02-24	NaN	imassnc.it	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.277613	f	f	\N	\N	[]	0	active	\N	pending	\N
1589441	\N	STAMPO PRESS S.R.L.	2488610243.0	02488610243	VIA PONZIMIGLIO, 32	MONTEGALDA	36047.0	VI	Veneto	NaN	\N	8	2025-02-24	NaN	www.stampopress.com	NaN	0444-737086	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.281234	f	f	\N	\N	[]	0	active	\N	pending	\N
1589443	\N	NEDOR S.R.L.	3286190248.0	03286190248	VIA DEL PROGRESSO, 23	MONTICELLO CONTE OTTO	36010.0	VI	Veneto	Italia	\N	10	2025-02-24	NaN	NaN	NaN	0444.040042	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.284893	f	f	\N	\N	[]	0	active	\N	pending	\N
1589454	\N	GSOPEN SOFTWARE SRL	2638580205.0	02638580205	VIA ENRICO FERMI, 8 B	MANTOVA	46100.0	MN	Lombardia	NaN	\N	7	2025-02-24	NaN	www.gsopen.it	NaN	0376-1620371	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.288326	f	f	\N	\N	[]	0	active	\N	pending	\N
1590085	\N	AUTOFFICINA LOVISON DI LOVISON LUCA	5013040281.0	LVSLCU78S28C743F	VIA VITTORIO VENETO, 42	CURTAROLO	35010.0	PD	Veneto	NaN	\N	3	2025-02-24	Codice Ateco: 45.20.1 - Riparazioni Meccaniche Autoveicoli (Autofficina). #Luana	www.autofficinalovison.it	lovison.luca@upapec.it	049-557470	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.291445	f	f	\N	\N	[]	0	active	\N	pending	\N
1590101	\N	CARGERA S.R.L.	626540249.0	03775290152	VIA CENGELLE, 12/D	CASTELGOMBERTO	36070.0	VI	Veneto	Italia	\N	15	2025-02-24	NaN	www.cargera.it	NaN	0445-440119	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.294625	f	f	\N	\N	[]	0	active	\N	pending	\N
1590166	\N	FUTURA MED SRL	1265090959.0	01265090959	Via Luigi Manconi Passino, 30-32	Oristano	9170.0	Oristano	Sardegna	Italia	\N	0	2025-02-25	Poliambulatorio medico	NaN	medicidelbenessere@gmail.com	3478262146	\N	Centro	["Giovanni Fulgheri"]	2025-07-03 20:34:35.297709	f	f	\N	\N	[]	0	active	\N	pending	\N
1590167	\N	CLAUDIA GIOIELLERIE SRL	13374620964.0	13374620964	VIA MAZZINI 51 - 09170 - ORISTANO (OR)	Oristano	9170.0	Oristano	Sardegna	Italia	\N	0	2025-02-25	Gioielleria	NaN	veronica@gioiellerieclaudia.com	3887882473	\N	Centro	["Giovanni Fulgheri"]	2025-07-03 20:34:35.300724	f	f	\N	\N	[]	0	active	\N	pending	\N
1590174	\N	ZORZI SALOTTI S.N.C. DI ZORZI IVONE E C.	3435270289.0	03435270289	VIA BROSE, 19	SAN GIORGIO DELLE PERTICHE	35010.0	PD	Veneto	Italia	\N	17	2025-02-25	NaN	www.zorziarredamenti.it	NaN	04993011476	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.303379	f	f	\N	\N	[]	0	active	\N	pending	\N
1590196	\N	PR S.R.L.	3904900242.0	03904900242	VIA GORIZIA SS53, 4	BOLZANO VICENTINO	36050.0	VI	Veneto	Italia	\N	34	2025-02-25	NaN	www.beyfin.it/stazioni-di-servizio/	NaN	049.0991687	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.306608	f	f	\N	\N	[]	0	active	\N	pending	\N
1590341	\N	L.E.M.O. DI BERTOLLO FULVIO E GUARISE SEVERINO & C. - S.N.C.	874070246.0	00874070246	VIA PAPA PAOLO VI, 95	CASSOLA	36022.0	VI	Veneto	Italia	\N	8	2025-02-25	NaN	www.lemo.it	NaN	0424534187	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.309374	f	f	\N	\N	[]	0	active	\N	pending	\N
1590343	\N	CLIOS S.N.C. DI MADRASSI SANDRO E ROSSETTO OSVY	3731950246.0	03731950246	VIA CHEMIN PALMA, 44	MUSSOLENTE	36065.0	VI	Veneto	NaN	\N	17	2025-02-25	NaN	NaN	NaN	0424.568420	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.312374	f	f	\N	\N	[]	0	active	\N	pending	\N
1590351	\N	PAROLINI GIANNANTONIO S.P.A.	3236790238.0	03236790238	VIA GARIBALDI, 66	CASTELNUOVO DEL GARDA	37014.0	VR	Veneto	NaN	\N	69	2025-02-25	NaN	www.parolinigiannantoniospa.it	NaN	045-7595300	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.315101	f	f	\N	\N	[]	0	active	\N	pending	\N
1590353	\N	TEVERONE SRL	1248300251.0	01248300251	PIAZZA ROMA, 9	CHIES D'ALPAGO	32010.0	BL	Veneto	NaN	\N	18	2025-02-25	NaN	NaN	NaN	348.7726128	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.318408	f	f	\N	\N	[]	0	active	\N	pending	\N
1590355	\N	JOIN SERVICE S.R.L.	1459840292.0	01459840292	VIA TABAZZOTTO, 2	FRATTA POLESINE	45025.0	RO	Veneto	Italia	\N	16	2025-02-25	NaN	www.joinservicesrl.it	NaN	049 870 4427	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.321549	f	f	\N	\N	[]	0	active	\N	pending	\N
1590498	\N	AUTOSERVICE BERTINAZZI S.R.L.	4249820244.0	04249820244	VIA GORIZIA, 10	BOLZANO VICENTINO	36050.0	VI	Veneto	NaN	\N	14	2025-02-25	Codice Ateco: 45.20.2 - Riparazioni di carrozzerie di autoveicoli (Carrozzeria). #Luana	www.carrozzeriabertinazzi.it	NaN	0444-351059	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.324398	f	f	\N	\N	[]	0	active	\N	pending	\N
1590511	\N	STYLGROUP S.R.L.	4140510282.0	04140510282	VIA ANTONIO CECCON, 12	LOREGGIA	35010.0	PD	Veneto	Italia	\N	19	2025-02-25	NaN	www.stylgroup.it	NaN	049-5223038	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.327152	f	f	\N	\N	[]	0	active	\N	pending	\N
1590515	\N	ECON-TEST S.R.L. - SOCIETA' TRA PROFESSIONISTI	1427540297.0	01427540297	VIA TABAZZOTTO, 2	FRATTA POLESINE	45025.0	RO	Veneto	Italia	\N	6	2025-02-25	NaN	www.econ-test.it	NaN	0425668487	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.329668	f	f	\N	\N	[]	0	active	\N	pending	\N
1590519	\N	AL VIGORANTINO DI ZAMPIERI STEFANO	4834740286.0	ZMPSFN82T28G224E	PIAZZA UNITA' D'ITALIA, 1	VIGODARZERE	35010.0	PD	Veneto	Italia	\N	8	2025-02-25	Codice Ateco: 56.10.11 - Ristorazione con somministrazione (Ristorante) #Luana	www.vigorantino.it	NaN	049-5919133	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.332166	f	f	\N	\N	[]	0	active	\N	pending	\N
1590524	\N	MACRO S.A.S. DI SARTOR MARCO & MOCELLIN MARZIO	2351760240.0	02351760240	VIA SOLIGO, 2	CASTELFRANCO VENETO	31033.0	TV	Veneto	Italia	\N	12	2025-02-25	NaN	www.macro.it	NaN	0423.476484	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.334881	f	f	\N	\N	[]	0	active	\N	pending	\N
1590534	\N	SERIEMME SAS DI FRANCHIN M.	2440950240.0	02440950240	VIA G. ZAMBON, 28	CREAZZO	36051.0	VI	Veneto	Italia	\N	6	2025-02-25	NaN	seriemme.myb2b-online.it	NaN	0444371313	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.337053	f	f	\N	\N	[]	0	active	\N	pending	\N
1590890	\N	LOGISTICA PORDENONESE S.R.L.	1641600935.0	01641600935	VIA NUOVA DI CORVA, 82	PORDENONE	33170.0	PN	Friuli-venezia giulia	Italia	\N	71	2025-02-25	NaN	NaN	NaN	349.3518768	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.339977	f	f	\N	\N	[]	0	active	\N	pending	\N
1590898	\N	A.D. STUDIO S.R.L.	3082940242.0	03082940242	VIA MONTE GRAPPA, 6/L	THIENE	36016.0	VI	Veneto	NaN	\N	3	2025-02-26	Codice Ateco: 63.10.2 - Elaborazione Dati #Luana	NaN	NaN	340.6098403	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.343034	f	f	\N	\N	[]	0	active	\N	pending	\N
1590908	\N	INFORMATIC ALL S.R.L.	3890340288.0	03890340288	VIA TENTORI, 62/5	CAMPOSAMPIERO	35012.0	PD	Veneto	NaN	\N	11	2025-02-26	NaN	www.informaticall.it	NaN	041.9690622	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.346336	f	f	\N	\N	[]	0	active	\N	pending	\N
1590932	\N	RISTORANTE ALLA CATINA DI PALUMBO ANTONIO E CIOFFI VINCENZO S.N.C .	1731310932.0	01731310932	PIAZZA C.BENSO CONTE DI CAVOUR, 3	PORDENONE	33170.0	PN	Friuli-venezia giulia	Italia	\N	29	2025-02-26	NaN	NaN	NaN	0434520358	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.349181	f	f	\N	\N	[]	0	active	\N	pending	\N
1590958	\N	CONNETICAL S.R.L.	3522210271.0	03522210271	VIA BOFFALORA, 4	TREVIOLO	24048.0	BG	Lombardia	NaN	\N	8	2025-02-26	NaN	www.3psystem.net	NaN	347.8114934	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.351727	f	f	\N	\N	[]	0	active	\N	pending	\N
1590963	\N	PARISE DOMENICO S.R.L.	2839420243.0	02839420243	VIA GAZZO, 60	PIANEZZE	36060.0	VI	Veneto	NaN	\N	12	2025-02-26	NaN	www.cablaggiparise.it	NaN	0424.567708	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.354286	f	f	\N	\N	[]	0	active	\N	pending	\N
1590976	\N	OTTICA 2M S.R.L.	4213920269.0	04213920269	VIA FELTRINA NUOVA, 3	MONTEBELLUNA	31044.0	TV	Veneto	NaN	\N	22	2025-02-26	NaN	www.ottica-2m.it	NaN	0423-639742	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.359331	f	f	\N	\N	[]	0	active	\N	pending	\N
1590979	\N	MANES S.R.L.	1248490243.0	01248490243	VIA PECORI GIRALDI, 22	THIENE	36016.0	VI	Veneto	Italia	\N	12	2025-02-26	NaN	www.manes.it	NaN	0445-364368	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.362014	f	f	\N	\N	[]	0	active	\N	pending	\N
1591002	\N	SNACK & DRINK S.R.L.	703740456.0	00703740456	VIA CARLO SFORZA, 72/A	MONTIGNOSO	54038.0	MS	Toscana	Italia	\N	28	2025-02-26	NaN	www.snackedrink.it	NaN	0585348898	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.364624	f	f	\N	\N	[]	0	active	\N	pending	\N
1591007	\N	LAPE SRL	2696330410.0	02696330410	VIA MONTANELLI, 32	PESARO	61122.0	PS	Marche	NaN	\N	0	2025-02-26	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.367538	f	f	\N	\N	[]	0	active	\N	pending	\N
1591010	\N	TAGLIAGAMBE & ZILIO SRL	1344510506.0	01344510506	VIA TOSCANA, 23	PONTEDERA	56025.0	PI	Toscana	Italia	\N	19	2025-02-26	Progettazione e realizzazione di negozi, bar, ristoranti, pizzerie, laboratori e cucine.\nRegistratori di cassa e sistemi gestionali per bar e ristoranti.\nVendita attrezzature per negozi, forniture alberghiere.	www.tezgroup.it	NaN	0587 52325	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.37059	f	f	\N	\N	[]	0	active	\N	pending	\N
1591015	\N	DGNET S.R.L.	6305950484.0	06305950484	VIA PIANTANIDA, 12/2	FIRENZE	50127.0	FI	Toscana	Italia	\N	22	2025-02-26	Strategie di comunicazione e soluzioni internet.	www.official360.it	NaN	055 2344891	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.373485	f	f	\N	\N	[]	0	active	\N	pending	\N
1591031	\N	COMEX GROUP S.R.L.	1303060287.0	01303060287	VIA EUROPA UNITA, 19	LOREGGIA	35012.0	PD	Veneto	Italia	\N	5	2025-02-26	NaN	www.comexgroup.it	NaN	0499302774	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:35.375976	f	f	\N	\N	[]	0	active	\N	pending	\N
1591106	\N	2AUTOCENTRI LA STORTA SRLS	15567181001.0	15567181001	VIA DELLA STORTA, 918	ROMA	123.0	RM	Lazio	NaN	\N	4	2025-02-26	Codice Ateco: 45.20.1O Riparazioni Meccaniche Autoveicoli #Luana	NaN	NaN	06 3089 0386	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.378403	f	f	\N	\N	[]	0	active	\N	pending	\N
1591111	\N	ADS AUTOMATION SRL	2194060394.0	02194060394	VIA EZIO VANONI, 9	IMOLA	40026.0	BO	Emilia-romagna	Italia	\N	12	2025-02-26	Codice Ateco: 28.99.2 - Fabbricazione di robot industriali per usi molteplici (Automazione e robotica). #Luana	www.adsautomation.it	NaN	0542896901	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:35.380678	f	f	\N	\N	[]	0	active	\N	pending	\N
1591153	\N	CITY CAR S.R.L.	3137640409.0	03137640409	VIA MONDA, 29/A	FORLI'	47121.0	FO	Emilia-romagna	Italia	\N	13	2025-02-27	NaN	citycarforli.com	NaN	0543483718	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:35.383842	f	f	\N	\N	[]	0	active	\N	pending	\N
1591155	\N	TERMICA SISTEMI SRL	4163680236.0	04163680236	VIA SPAGNA, 16	VILLAFRANCA DI VERONA	37069.0	VR	Veneto	Italia	\N	16	2025-02-27	NaN	www.termicasistemi.it	NaN	045.8130096	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:35.386841	f	f	\N	\N	[]	0	active	\N	pending	\N
1591175	\N	GASTRONOMIA FONTEBASSO S.R.L.	3880070267.0	03880070267	VIA DELL'ARTIGIANATO, 18	MASERADA SUL PIAVE	31052.0	TV	Veneto	NaN	\N	14	2025-02-27	NaN	NaN	NaN	0422-777155	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.389383	f	f	\N	\N	[]	0	active	\N	pending	\N
1591189	\N	ERREBI TECHNOLOGY S.P.A.	1087860290.0	01087860290	VIA TARUFFI, 92-106	MARANELLO	41053.0	MO	Emilia-romagna	NaN	\N	47	2025-02-27	NaN	www.errebi.net	NaN	0425-51934	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.393554	f	f	\N	\N	[]	0	active	\N	pending	\N
1591196	\N	ACQUABIKE SRL	8678610968.0	08678610968	VIA VINCENZO MONTI, 5	MILANO	20123.0	MI	Lombardia	NaN	\N	4	2025-02-27	Codice Ateco: 96.04.10 - Servizi di centri per il benessere fisico (Centro estetico)#Luana	www.acquago.it	NaN	02-84253150	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:35.397549	f	f	\N	\N	[]	0	active	\N	pending	\N
1591201	\N	FARMACIA SOPRANA DELLA DOTT.SSA ALESSANDRA SOPRANA & C. S.A.S.	4673660231.0	04673660231	LARGO STAZIONE VECCHIA, 6	VERONA	37124.0	VR	Veneto	Italia	\N	9	2025-02-27	NaN	www.farmaciasoprana.it	NaN	045-941070	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:35.401344	f	f	\N	\N	[]	0	active	\N	pending	\N
1591232	\N	ROEMER GARDEN S.R.L.	3155100211.0	03155100211	PASSEGGIATA LUNGO PASSIRIO, 2	MERANO	39012.0	BZ	Trentino-alto adige	NaN	\N	29	2025-02-27	NaN	NaN	NaN	NaN	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:35.404851	f	f	\N	\N	[]	0	active	\N	pending	\N
1591240	\N	GIRAMA SERVICE S.R.L.	2791660216.0	02791660216	VIA MERCATO, 12	LAGUNDO	39022.0	BZ	Trentino-alto adige	NaN	\N	8	2025-02-27	NaN	NaN	NaN	0471.257376	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:35.407692	f	f	\N	\N	[]	0	active	\N	pending	\N
1591244	\N	MANDARAVA GROUP S.R.L.	2918890217.0	02918890217	VIA ALOIS KUPERION, 34	MERANO	39012.0	BZ	Trentino-alto adige	NaN	\N	8	2025-02-27	NaN	NaN	NaN	0471.933486	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:35.41068	f	f	\N	\N	[]	0	active	\N	pending	\N
1591246	\N	PRM SRL	3005430214.0	03005430214	VIA ALOIS KUPERION, 34	MERANO	39012.0	BZ	Trentino-alto adige	NaN	\N	8	2025-02-27	NaN	www.cavallinomerano.com	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.413345	f	f	\N	\N	[]	0	active	\N	pending	\N
1591247	\N	GROUPS MANUFACTORING S.R.L.	3817540234.0	03817540234	VIA MAGGI, 7	VERONA	37122.0	VR	Veneto	Italia	\N	6	2025-02-27	NaN	www.eastpower.it	NaN	0456 766975	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.417211	f	f	\N	\N	[]	0	active	\N	pending	\N
1591250	\N	POWERCOM EUROPE S.R.L.	2811260237.0	02811260237	VIA MAGGI, 7	VERONA	37122.0	VR	Veneto	Italia	\N	7	2025-02-27	NaN	www.pcm-ups.eu	NaN	045 6703564-208	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.420928	f	f	\N	\N	[]	0	active	\N	pending	\N
1591253	\N	CENTRO ESTETICO SERENA DI PENSIERINI SERENA	623820453.0	PNSSRN74P58B832N	VIA BONASCOLA, 35	CARRARA	54033.0	MS	Toscana	Italia	\N	5	2025-02-27	Centro estetico con 3 dipendenti.\nMatteo Dell' Orto ha già dato il benestare per procedere con Formazione 4.0 nonostante non ci sia un numero congruo, perché è stata presentata da un commercialista che collabora con noi.	www.gambesnelle.com	centroesteticoserena@gmail.com	0585-846000	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.423714	f	f	\N	\N	[]	0	active	\N	pending	\N
1591254	\N	JOL-AND S.R.L.	3584131209.0	03584131209	VIA DELL INDIPENDENZA, 65	BOLOGNA	40121.0	BO	Emilia-romagna	NaN	\N	10	2025-02-27	NaN	www.hoteldonatello.com	NaN	051-244776	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.42684	f	f	\N	\N	[]	0	active	\N	pending	\N
1591255	\N	ORTOPEDIA RUBBINI 1832 S.R.L.	3800531208.0	03800531208	VIA PORRETTANA, 148/3	BOLOGNA	40135.0	BO	Emilia-romagna	NaN	\N	5	2025-02-27	NaN	www.ortopediarubbini.com	NaN	051-225734	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:35.429886	f	f	\N	\N	[]	0	active	\N	pending	\N
1591261	\N	AP INFISSI S.R.L.	3349251201.0	03349251201	VIA GAGLIANI, 14-16	ZOLA PREDOSA	40069.0	BO	Emilia-romagna	Italia	\N	5	2025-02-27	Codice Ateco: 16.23.1 - Fabbricazione di porte e finestre in legno. (Infissi) #Luana	www.apinfissi.it	NaN	051-751663	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:35.433086	f	f	\N	\N	[]	0	active	\N	pending	\N
1591267	\N	CLIMART ZETA S.R.L.	3901360374.0	03901360374	VIA DELL' ARTIGIANO, 11	CASTENASO	40055.0	BO	Emilia-romagna	Italia	\N	27	2025-02-27	NaN	www.climartzeta.it	NaN	051-6053545	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:35.435745	f	f	\N	\N	[]	0	active	\N	pending	\N
1591272	\N	S.LLE BARRACCA S.N.C. DI GUAZZALOCA LEONARDO & C.	508750361.0	00508750361	VIA EMILIA, 41/F	ANZOLA DELL'EMILIA	40011.0	BO	Emilia-romagna	Italia	\N	9	2025-02-27	ID myWorld 808561	www.barracca.it	NaN	051733312	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.438554	f	f	\N	\N	[]	0	active	\N	pending	\N
1591283	\N	METALCUT SRL	3810810360.0	03810810360	VIA LAVACCHI, 1630	SAN FELICE SUL PANARO	41038.0	MO	Emilia-romagna	Italia	\N	6	2025-02-27	NaN	NaN	NaN	0535420295	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.441007	f	f	\N	\N	[]	0	active	\N	pending	\N
1591292	\N	PIZZERIA INSIEME SAS DI PIERORAZIO VINCENZO	2230090694.0	02230090694	VIA ICONICELLA, 8/13	LANCIANO	66034.0	CH	Abruzzo	Italia	\N	7	2025-02-27	NaN	linktr.ee/pizzeriainsieme	NaN	320.2762852	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.44337	f	f	\N	\N	[]	0	active	\N	pending	\N
1591300	\N	CIRENAICA RISTRUTTURAZIONI S.A.S. DI MESSANA ANGELO	2791741206.0	02791741206	VIA EMILIA, 27/A	ANZOLA DELL'EMILIA	40011.0	BO	Emilia-romagna	NaN	\N	9	2025-02-27	NaN	www.cirenaicaristrutturazioni.it	NaN	392.2275106	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:35.445556	f	f	\N	\N	[]	0	active	\N	pending	\N
1591352	\N	MC FRUTTA S.R.L.	1534460116.0	01534460116	VIA VARIANTE CISA, Snc	SARZANA	19038.0	SP	Liguria	Italia	\N	6	2025-02-28	Forniture ortofrutticole per la ristorazione	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.448081	f	f	\N	\N	[]	0	active	\N	pending	\N
1591367	\N	IPRATICO S.R.L.	3491030130.0	03491030130	CORSO MATTEOTTI, 5/H	LECCO	23900.0	LC	Lombardia	NaN	\N	40	2025-02-28	NaN	www.ipratico.com	NaN	0341-365830	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.450747	f	f	\N	\N	[]	0	active	\N	pending	\N
1591368	\N	WISHARE S.R.L.	13207800965.0	13207800965	VIA GIACOMO MATTEOTTI, 27/1	PESCHIERA BORROMEO	20068.0	MI	Lombardia	Italia	\N	0	2025-02-28	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.453677	f	f	\N	\N	[]	0	active	\N	pending	\N
1591369	\N	MUGELLO SISTEMI SAS DI GIGLI LUCA, SONIA & C.	3812930489.0	03812930489	VIALE GIOVANNI XXIII, 46 A	BORGO SAN LORENZO	50032.0	FI	Toscana	Italia	\N	2	2025-02-28	NaN	www.mugellosistemi.it	NaN	055-8456414	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.456795	f	f	\N	\N	[]	0	active	\N	pending	\N
1591370	\N	DATAITALIA S.R.L.	3368140483.0	03368140483	VIA RICCARDO ZANDONAI, 2	FIRENZE	50127.0	FI	Toscana	Italia	\N	15	2025-02-28	NaN	www.dataitaliasrl.it	NaN	055486661	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.459957	f	f	\N	\N	[]	0	active	\N	pending	\N
1591374	\N	GROS F4 DEI F.LLI PANCONI S.N.C.	60650454.0	00060650454	VIA LOTTIZZAZIONE,	MASSA	54100.0	MS	Toscana	Italia	\N	24	2025-02-28	NaN	www.grosf4.it	NaN	0585832816	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.462936	f	f	\N	\N	[]	0	active	\N	pending	\N
1591473	\N	DOLOMITI REAL ESTATE SRL	4747060277.0	04747060277	VIA BRUNO MADERNA, 7	VENEZIA	30174.0	VE	Veneto	NaN	\N	0	2025-02-28	Società di acquisizione e gestione di beni immobili con la collaborazione di D4U.	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.466087	f	f	\N	\N	[]	0	active	\N	pending	\N
1591483	\N	MIND INNOVATION SRL	1579590520.0	01579590520	VICOLO DELLA MANNA, 2	SIENA	53100.0	SI	Toscana	Italia	\N	0	2025-02-28	Start up	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.469038	f	f	\N	\N	[]	0	active	\N	pending	\N
1592271	\N	INTOFER S.R.L.	1920690201.0	01920690201	VIA BUSSOLENGO, 19/21	SONA	37060.0	VR	Veneto	Italia	\N	41	2025-03-03	NaN	www.intofer.it/	NaN	045 6348114	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.472188	f	f	\N	\N	[]	0	active	\N	pending	\N
1592278	\N	ADIGE VENDING S.A.S. DI MALAFFO DIEGO & C.	2654620232.0	02654620232	VIA GARIBALDI, 5/31	SAN GIOVANNI LUPATOTO	37057.0	VR	Veneto	Italia	\N	8	2025-03-03	Codice Ateco: 47.99.20 - Commercio effettuato per mezzo di distributori automatici. #Luana	www.adigevending.it	NaN	045.8753528	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.475306	f	f	\N	\N	[]	0	active	\N	pending	\N
1592737	\N	JEVA SRL	2606771208.0	02606771208	VIA EMILIA LEVANTE, 27	BOLOGNA	40137.0	BO	Emilia-romagna	NaN	\N	32	2025-03-03	NaN	oldbridgepub.it	NaN	051-490608	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.477948	f	f	\N	\N	[]	0	active	\N	pending	\N
1592740	\N	MASER IMPIANTI ELETTRICI S.R.L.	4796760231.0	04796760231	VIA DELLE PASQUE VERONESI, 7	BOVOLONE	37051.0	VR	Veneto	NaN	\N	11	2025-03-03	NaN	NaN	NaN	340.0625039	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.480877	f	f	\N	\N	[]	0	active	\N	pending	\N
1592743	\N	CARMA S.R.L.	1676180233.0	01676180233	VIA CA' NOVE,	SAN MARTINO BUON ALBERGO	37036.0	VR	Veneto	Italia	\N	37	2025-03-03	NaN	www.carma-vr.it	NaN	0459.94848	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.483263	f	f	\N	\N	[]	0	active	\N	pending	\N
1592747	\N	EDIL VITALIY S.R.L.	2872030982.0	02872030982	VIA GIOBERTI, 9	BOVEZZO	25073.0	BS	Lombardia	Italia	\N	49	2025-03-03	NaN	NaN	NaN	0302711352	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.486578	f	f	\N	\N	[]	0	active	\N	pending	\N
1592751	\N	LYCONET ITALIA S.R.L.	4616380236.0	04616380236	VIALE DEL LAVORO, 33	SAN MARTINO BUON ALBERGO	37036.0	VR	Veneto	NaN	\N	5	2025-03-03	NaN	NaN	NaN	366.9924407	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.48945	f	f	\N	\N	[]	0	active	\N	pending	\N
1592756	\N	B2B GROUP S.R.L.	10778970961.0	10778970961	VIA ERACLITO, 15/3	MILANO	20128.0	MI	Lombardia	Italia	\N	2	2025-03-03	NaN	NaN	NaN	331.5277721	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.492593	f	f	\N	\N	[]	0	active	\N	pending	\N
1592758	\N	S.T. SAFETY TECHNOLOGY S.R.L.	1744590389.0	01744590389	VIA A.TOSCANINI, 14	FERRARA	44124.0	FE	Emilia-romagna	NaN	\N	8	2025-03-03	NaN	www.dpr462.com	NaN	0532.753810	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.495656	f	f	\N	\N	[]	0	active	\N	pending	\N
1592764	\N	MYWORLD ITALIA S.R.L.	4565670231.0	04565670231	VIALE DEL LAVORO, 33	SAN MARTINO BUON ALBERGO	37036.0	VR	Veneto	Italia	\N	35	2025-03-03	NaN	NaN	NaN	0452080500	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.498781	f	f	\N	\N	[]	0	active	\N	pending	\N
1592767	\N	TUSCIA ENERGIA S.R.L.	2222820561.0	02222820561	CIRCONVALLAZIONE CLODIA, 163/167	ROMA	195.0	RM	Lazio	Italia	\N	6	2025-03-03	NaN	NaN	NaN	392.8661971	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.502119	f	f	\N	\N	[]	0	active	\N	pending	\N
1592792	\N	TERZA PILA S.R.L.	3517561209.0	03517561209	VIA UGO BASSI, 25	BOLOGNA	40123.0	BO	Emilia-romagna	Italia	\N	20	2025-03-03	NaN	NaN	NaN	339.4039539	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.504679	f	f	\N	\N	[]	0	active	\N	pending	\N
1592796	\N	COOPERATIVA SOCIALE INCONTRO - SOCIETA' COOPERATIVA ONLUS	368990958.0	00368990958	VIA CAGLIARI, 33	GONNOSTRAMATZA	9093.0	OR	Sardegna	NaN	\N	76	2025-03-03	NaN	www.coopincontro.it	NaN	0783-92576	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.507576	f	f	\N	\N	[]	0	active	\N	pending	\N
1592802	\N	IPV PACK S.R.L.	2121700351.0	02121700351	VIA INDUSTRIA E ARTIGIANATO, 2	CARMIGNANO DI BRENTA	35010.0	PD	Veneto	NaN	\N	61	2025-03-03	Produzione e nella lavorazione plastica e nella distribuzione di materiali di alta qualità per l’imballaggio del settore alimentare, pet food e industriale.	www.ipvpack.com	NaN	049-9431370	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.510472	f	f	\N	\N	[]	0	active	\N	pending	\N
1592819	\N	FASHION HAIR S.R.L.	1080090952.0	01080090952	VIA BRUNELLESCHI, 3/C	ORISTANO	9170.0	OR	Sardegna	Italia	\N	6	2025-03-03	NaN	NaN	NaN	0783212321	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.513213	f	f	\N	\N	[]	0	active	\N	pending	\N
1594466	\N	ESSEPI S.R.L.	1973920471.0	01973920471	VIA IV NOVEMBRE, 59	SERRAVALLE PISTOIESE	51034.0	PT	Toscana	NaN	\N	6	2025-03-04	NaN	www.essepizucchero.it	NaN	0573-929419	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.516074	f	f	\N	\N	[]	0	active	\N	pending	\N
1594562	\N	BOI AUTOMOBILI SRL	723170957.0	NaN	Via E. Ferrari,2	ORISTANO	9170.0	Oristano	Sardegna	Italia	\N	0	2025-03-05	Codice Ateco: 45.11.01 - Commercio al dettaglio di autoveicoli e autovetture. #Luana	https://www.boiautomobili.it/	info@boiautomobili.it	NaN	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.519215	f	f	\N	\N	[]	0	active	\N	pending	\N
1594566	\N	MISTRAL DI ALBERTO SANNA & C SRL	519680953.0	NaN	Via XX Settembre,34	Oristano	9170.0	Oristano	Sardegna	Italia	\N	0	2025-03-05	NaN	NaN	mistral@pec.it	347.6862273	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.522257	f	f	\N	\N	[]	0	active	\N	pending	\N
1594579	\N	SC. HI-FI S.R.L.	1247940958.0	NaN	Via Giosuè Carducci,10	Oristano	9170.0	Oristano	Sardegna	Italia	\N	0	2025-03-05	NaN	NaN	schifi.or@arubapec.it	348.3344783	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.52517	f	f	\N	\N	[]	0	active	\N	pending	\N
1594593	\N	TEK REF SRL	1088030950.0	01088030950	LOCALITA' FEURREDDA,	SIMAXIS	9088.0	OR	Sardegna	NaN	\N	7	2025-03-05	Il cliente (titolare d'azienda la Dottoressa Miriam Carboni con il socio marito Luca Pieri)\nAzienda produttrice di forni da pizza brevettati.	www.zio-ciro.com	NaN	0783-406005	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.528051	f	f	\N	\N	[]	0	active	\N	pending	\N
1594645	\N	FARMACIA DOTT.SSA FEDERICA DE VILLA	2949040923.0	DVLFRC72E66H118T	VIA PARROCCHIA, 1	QUARTU SANT'ELENA	9045.0	CA	Sardegna	NaN	\N	7	2025-03-05	NaN	www.farmaciadevillacagliari.it	NaN	070-825337	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.531036	f	f	\N	\N	[]	0	active	\N	pending	\N
1594653	\N	NEW FLOWERS SRLS	3757350925.0	03757350925	VIA ALGHERO, 120	QUARTU SANT'ELENA	9045.0	CA	Sardegna	NaN	\N	34	2025-03-05	NaN	m.facebook.com/flower-park-lounge-bar-109694757096666/	NaN	348.7055100	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.534336	f	f	\N	\N	[]	0	active	\N	pending	\N
1594657	\N	DE ROSA STEFANO	1494550112.0	DRSSFN81C02E463G	Via Porcale Superiore, 4	Riccò del Golfo di Spezia	19020.0	La Spezia	Liguria	Italia	\N	0	2025-03-05	Ditta individuale	NaN	drsstefa1@gmail.com	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.537588	f	f	\N	\N	[]	0	active	\N	pending	\N
1594659	\N	AGRICOLA CAMPIDANESE - SOCIETA' COOPERATIVA	1122780958.0	01122780958	VIA PIRELLI,	TERRALBA	9098.0	OR	Sardegna	NaN	\N	69	2025-03-05	Codice Ateco: 10.3 - Lavorazione e conservazione di frutta e ortaggi (azienda agricola)	www.lortodieleonora.com	NaN	0783-82218	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.54087	f	f	\N	\N	[]	0	active	\N	pending	\N
1594665	\N	QUATTRO P S.R.L.	715090957.0	00715090957	SS 131 KM, 100, .	SIAMAGGIORE	9070.0	OR	Sardegna	Italia	\N	13	2025-03-05	NaN	www.quattrop.it	NaN	0783.33095	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.544245	f	f	\N	\N	[]	0	active	\N	pending	\N
1594674	\N	AUTORICAMBI THARROS S.R.L.	1053300958.0	01053300958	VIA CAMPANIA, 160	ORISTANO	9170.0	OR	Sardegna	NaN	\N	5	2025-03-05	Codice Ateco: 45.32 - Commercio al dettaglio di parti e accessori di autoveicoli (Autoricambi). # Luana	NaN	NaN	393.9430078	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.548344	f	f	\N	\N	[]	0	active	\N	pending	\N
1594680	\N	CENTRO RIABILITATIVO ORTOPEDICO SARDO DI SECCI ROSINA E C. S.R.L.	1358140927.0	01358140927	VIA S'ARRULLONI, 10	QUARTU SANT'ELENA	9045.0	CA	Sardegna	NaN	\N	18	2025-03-05	NaN	www.centrocros.it	NaN	070.814085	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.552689	f	f	\N	\N	[]	0	active	\N	pending	\N
1594694	\N	CONGERA WILLIAM	3561410923.0	CNGWLM85S04B354I	CORSO VITTORIO EMANUELE II, 78	CAGLIARI	9124.0	CA	Sardegna	NaN	\N	15	2025-03-05	NaN	NaN	NaN	342 7484330	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.556893	f	f	\N	\N	[]	0	active	\N	pending	\N
1594699	\N	OBIETTIVO 50 S.R.L.	3693420923.0	03693420923	VIA GIUDICE COSTANTINO, 7/9	CAGLIARI	9131.0	CA	Sardegna	NaN	\N	17	2025-03-05	NaN	NaN	NaN	342.7484330	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:35.559566	f	f	\N	\N	[]	0	active	\N	pending	\N
1594701	\N	CENTRO BENESSERE SINERGIE DI GRAVERINI BARBARA & C.	1432500492.0	NaN	Viale Ugo Foscolo, 67	Livorno	57121.0	Livorno	Toscana	Italia	\N	0	2025-03-05	Centro Benessere	NaN	NaN	NaN	\N	Nord-Ovest	["Fabrizio Corbinelli"]	2025-07-03 20:34:35.562773	f	f	\N	\N	[]	0	active	\N	pending	\N
1594716	\N	BHT SRL	3372670368.0	03372670368	VIA DELL'ARTIGIANATO, 7/9	CAMPOSANTO	41031.0	MO	Emilia-romagna	Italia	\N	21	2025-03-05	Codice Ateco: 28.92.3 - Fabbricazione di macchine automatiche per la dosatura, la confezione e per l'imballaggio. (producono dosatori per polveri).#Luana	www.bhtsrl.com	NaN	0535-88211	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.566567	f	f	\N	\N	[]	0	active	\N	pending	\N
1594813	\N	SIMONI SHOP SRLS	3403901204.0	03403901204	VIA PESCHERIE VECCHIE, 3/B	BOLOGNA	40124.0	BO	Emilia-romagna	Italia	\N	22	2025-03-06	NaN	NaN	NaN	051 231843	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.570014	f	f	\N	\N	[]	0	active	\N	pending	\N
1594845	\N	IMPRESA EDILE PIVATO SRL	417350261.0	00417350261	VIA PER S. FLORIANO, 54	CASTELFRANCO VENETO	31033.0	TV	Veneto	NaN	\N	4	2025-03-06	NaN	www.costruzioniedilipivato.com	NaN	0423 484188	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.573604	f	f	\N	\N	[]	0	active	\N	pending	\N
1594851	\N	ENERGYGAS DI GOVONI CRISTIAN & ANTHONY SRL	2008320380.0	02008320380	VIA NAZIONALE, 148	MALALBERGO	40051.0	BO	Emilia-romagna	Italia	\N	8	2025-03-06	NaN	NaN	NaN	051.6601415	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.5771	f	f	\N	\N	[]	0	active	\N	pending	\N
1594855	\N	PALUMBO S.R.L.	1720170305.0	01720170305	VIA CENTRALE, 20/E	LIGNANO SABBIADORO	33054.0	UD	Friuli-venezia giulia	NaN	\N	29	2025-03-06	NaN	www.bellanapolilignano.it?utm_source=tripadvisor&utm_medium=referral	NaN	0431-71256	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.580788	f	f	\N	\N	[]	0	active	\N	pending	\N
1594863	\N	QUINTA PILA S.R.L.	3664601204.0	03664601204	VIA PORRETTANA, 148/3	BOLOGNA	40135.0	BO	Emilia-romagna	Italia	\N	20	2025-03-06	NaN	NaN	NaN	335.7284536	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.583577	f	f	\N	\N	[]	0	active	\N	pending	\N
1594871	\N	CENTRO RESIDENZIALE PER ANZIANI E ADULTI INABILI RUGGERI MARIA DI NARDINI ELISA	1453850453.0	NRDLSE83S65E463U	VIA FILIPPO GUERRIERI, 63	LICCIANA NARDI	54016.0	MS	Toscana	NaN	\N	8	2025-03-06	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.586524	f	f	\N	\N	[]	0	active	\N	pending	\N
1594872	\N	CIMSYSTEM S.R.L.	2833910967.0	02833910967	VIA MONFALCONE, 3	CINISELLO BALSAMO	20092.0	MI	Lombardia	Italia	\N	26	2025-03-05	NaN	www.cimsystem.com	amministrazione@cimsystem.com	0266014863	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.58915	f	f	\N	\N	[]	0	active	\N	pending	\N
1594876	\N	R.S. - S.R.L.	2909950798.0	02909950798	VIA GUGLIELMO PECORI GIRALDI, 7	MILANO	20139.0	MI	Lombardia	NaN	\N	2	2025-03-06	NaN	NaN	NaN	339.6913762	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.591849	f	f	\N	\N	[]	0	active	\N	pending	\N
1594877	\N	LAB SRL	11107810159.0	11107810159	VIA MONFALCONE, 3	CINISELLO BALSAMO	20092.0	MI	Lombardia	NaN	\N	15	2025-03-06	NaN	www.soloenduro.it	NaN	02 87213197	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.594276	f	f	\N	\N	[]	0	active	\N	pending	\N
1594883	\N	GREEN FOOD S.R.L.	8493690963.0	08493690963	VIA G. PECORI GIRALDI, 7	MILANO	20139.0	MI	Lombardia	Italia	\N	7	2025-03-06	NaN	NaN	NaN	339.691372	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.597892	f	f	\N	\N	[]	0	active	\N	pending	\N
1594886	\N	BIANCO MOTO DI BIANCO PATRIZIO	2269530040.0	BNCPRZ70R04D205R	VIA ADRIANO OLIVETTI, 12	CUNEO	12100.0	CN	Piemonte	Italia	\N	7	2025-03-05	Codice Ateco: 45.40.11 - commercio al dettaglio di motocicli e ciclomotori (concessionaria Moto). #Luana	www.biancomoto.com	NaN	0171-694373	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.601718	f	f	\N	\N	[]	0	active	\N	pending	\N
1594888	\N	MODO SRL	2490390362.0	02490390362	VIA XXV APRILE, 11	FIORANO MODENESE	41042.0	MO	Emilia-romagna	NaN	\N	6	2025-03-06	NaN	www.mhpmedia.it	NaN	0536-921157	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.604988	f	f	\N	\N	[]	0	active	\N	pending	\N
1594893	\N	HOTEL UNIVERSAL S.R.L.	1389140425.0	01389140425	LUNGOMARE MAMELI, 47, 47	SENIGALLIA	60010.0	AN	Marche	Italia	\N	33	2025-03-06	NaN	www.hoteluniversal.it	NaN	071 7927474	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.608141	f	f	\N	\N	[]	0	active	\N	pending	\N
1594894	\N	CATALANI & FRONTALINI S.R.L.	108200429.0	00108200429	VIA DEL CONSORZIO, 21	FALCONARA MARITTIMA	60015.0	AN	Marche	NaN	\N	13	2025-03-06	NaN	www.autocarrozzeriacf.it	NaN	071-9161362	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.611301	f	f	\N	\N	[]	0	active	\N	pending	\N
1594985	\N	NUOVA ZETA SRL	1600740185.0	01600740185	VIA MARCONI, 6	VIGEVANO	27029.0	PV	Lombardia	NaN	\N	28	2025-03-06	NaN	NaN	NaN	0381-78027	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.614757	f	f	\N	\N	[]	0	active	\N	pending	\N
1594986	\N	ZETA PIU' SRL	1601900184.0	01601900184	VIA MARCONI, 6	VIGEVANO	27029.0	PV	Lombardia	NaN	\N	12	2025-03-06	NaN	NaN	NaN	0381-72033	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.618204	f	f	\N	\N	[]	0	active	\N	pending	\N
1594991	\N	ALIDENT DEI DOTT. LUCCHESE E MANCIN S.R.L. - SOCIETA' TRA PROFESSIONISTI	2824311209.0	02824311209	STRADA MAGGIORE, 17/D	BOLOGNA	40125.0	BO	Emilia-romagna	NaN	\N	7	2025-03-06	Codice Ateco: 86.23.00 - Attività degli studi odontoiatrici (Studio Dentistico e Odontoiatrico). #Luana	NaN	NaN	051-268376	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.62165	f	f	\N	\N	[]	0	active	\N	pending	\N
1595055	\N	FRAUNASCELTA S.R.L.S.	4716800406.0	04716800406	VIA SEVERINO BOEZIO, 7	RIMINI	47924.0	RN	Emilia-romagna	Italia	\N	0	2025-03-07	La società si occupa di servizi di consulenza imprenditoriale e consulenza amministrativo-gestionale e pianificazione aziendale	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.62438	f	f	\N	\N	[]	0	active	\N	pending	\N
1595229	\N	EDIL VITALIY S.R.L.	NaN	NaN	Via Vincenzo Gioberti, 9	Bovezzo	25073.0	Brescia	Lombardia	Italia	\N	0	2025-03-09	Impresa di Costruzioni	NaN	NaN	NaN	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:35.626874	f	f	\N	\N	[]	0	active	\N	pending	\N
1595271	\N	G.S.V. DI MINARELLI MARCO & C. S.A.S.	1935370385.0	01935370385	VIA VERGA, 4	FERRARA	44124.0	FE	Emilia-romagna	Italia	\N	7	2025-03-10	NaN	NaN	NaN	348.3599450	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.62939	f	f	\N	\N	[]	0	active	\N	pending	\N
1595272	\N	CARROZZERIA MICHELINO S.R.L.	377060371.0	00377060371	VIA MICHELINO, 115	BOLOGNA	40127.0	BO	Emilia-romagna	Italia	\N	10	2025-03-10	NaN	www.carrozzeriamichelino.com	NaN	051-512016	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.63178	f	f	\N	\N	[]	0	active	\N	pending	\N
1595277	\N	LEGNANI UMBERTO S.R.L.	1625451206.0	03513990378	VIA MONALDO CALARI, 6	ANZOLA DELL'EMILIA	40011.0	BO	Emilia-romagna	NaN	\N	8	2025-03-10	NaN	www.legnani.it	NaN	051-735848	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.634075	f	f	\N	\N	[]	0	active	\N	pending	\N
1595280	\N	ATHENA S.R.L.	2360630996.0	02360630996	VICO DELLA CASANA, 63 R	GENOVA	16123.0	GE	Liguria	NaN	\N	12	2025-03-10	NaN	NaN	NaN	010-252513	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.63622	f	f	\N	\N	[]	0	active	\N	pending	\N
1595294	\N	ESSELLE SRLS	NaN	NaN	Via del Tombino, 7	Preseglie	25070.0	Brescia	Lombardia	Italia	\N	0	2025-03-10	Svolge un lavoro prettamente manuale e lavora per c/terzi.	NaN	info@essellelavorazioni.it	03651902051	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:35.638324	f	f	\N	\N	[]	0	active	\N	pending	\N
1595305	\N	YACHTLINE ARREDOMARE 1618  S.P.A.	1298310507.0	01298310507	VIALE REGINA MARGHERITA, 1	MILANO	20122.0	MI	Lombardia	Italia	\N	222	2025-03-10	NaN	www.yachtline1618.com	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.640327	f	f	\N	\N	[]	0	active	\N	pending	\N
1595307	\N	DAUREKA SRL	1623840509.0	01623840509	VIA ANTONIO GRAMSCI, 52	BIENTINA	56031.0	PI	Toscana	Italia	\N	6	2025-03-10	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.642441	f	f	\N	\N	[]	0	active	\N	pending	\N
1595310	\N	MINERVA S.R.L.	2319730996.0	02319730996	DISTACCO DI PIAZZA MARSALA, 2	GENOVA	16122.0	GE	Liguria	NaN	\N	8	2025-03-10	NaN	NaN	NaN	010.8376818	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.644445	f	f	\N	\N	[]	0	active	\N	pending	\N
1595313	\N	ANANDA S.R.L.	1780010490.0	01780010490	CORSO MATTEOTTI, 200/M	CECINA	57023.0	LI	Toscana	Italia	\N	7	2025-03-10	NaN	www.marcopostcecina.com	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.646542	f	f	\N	\N	[]	0	active	\N	pending	\N
1595314	\N	IACONO FABIO & C. S.N.C.	3389200100.0	03389200100	VIA NINO BIXIO, 13/15	GENOVA	16128.0	GE	Liguria	Italia	\N	10	2025-03-10	NaN	NaN	NaN	010 594132	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.648607	f	f	\N	\N	[]	0	active	\N	pending	\N
1595317	\N	MASALA S.R.L.S.	2043960497.0	02043960497	PIAZZA GUERRAZZI, 3	CECINA	57023.0	LI	Toscana	Italia	\N	7	2025-03-10	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.650888	f	f	\N	\N	[]	0	active	\N	pending	\N
1595320	\N	GENOVA MARKET DI FABIO IACONO & C. S.N.C.	1693540997.0	01693540997	VIA CAFFARO, 24-26 RR	GENOVA	16124.0	GE	Liguria	NaN	\N	10	2025-03-10	NaN	NaN	NaN	010.2091850	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.653248	f	f	\N	\N	[]	0	active	\N	pending	\N
1595328	\N	ENGAGE LABS SRL	2955090341.0	02955090341	VIA PERTINI, 13	FIDENZA	43036.0	PR	Emilia-romagna	NaN	\N	10	2025-03-10	NaN	NaN	NaN	+43 664 1305785	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.655384	f	f	\N	\N	[]	0	active	\N	pending	\N
1595333	\N	LIM S.R.L.	1410090458.0	01410090458	VIA ALFREDO CECI, 5	CARRARA	54033.0	MS	Toscana	Italia	\N	73	2025-03-10	NaN	www.littleitalybarbershop.it	NaN	0585624185	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.658488	f	f	\N	\N	[]	0	active	\N	pending	\N
1595338	\N	PISORNO AXICURA S.R.L.	1874670506.0	01874670506	VIA UMBERTO FORTI, 16	PISA	56121.0	PI	Toscana	Italia	\N	11	2025-03-10	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.661872	f	f	\N	\N	[]	0	active	\N	pending	\N
1595341	\N	FONTANA SERAFINO & FIGLIO S.R.L.	706570504.0	00706570504	VIA FRANCESCA, 384	SANTA MARIA A MONTE	56020.0	PI	Toscana	Italia	\N	11	2025-03-10	NaN	www.fontanaserafino.com	NaN	0587706324	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.664274	f	f	\N	\N	[]	0	active	\N	pending	\N
1595361	\N	MPR SRL	2015500503.0	02015500503	VIA DEL CHIASSATELLO, 96	PISA	56121.0	PI	Toscana	Italia	\N	22	2025-03-10	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.666527	f	f	\N	\N	[]	0	active	\N	pending	\N
1595365	\N	VSGS SRLS	2603080900.0	02603080900	VIA BRIGATA SASSARI  PS, SNC	OSILO	7033.0	SS	Sardegna	NaN	\N	23	2025-03-10	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.669261	f	f	\N	\N	[]	0	active	\N	pending	\N
1595368	\N	ESCHINI AUTO S.R.L.	1842150508.0	01842150508	VIA MARCELLO MALPIGHI, 12	PISA	56121.0	PI	Toscana	Italia	\N	77	2025-03-10	NaN	vw.eschiniauto.it	NaN	0587424472	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.672184	f	f	\N	\N	[]	0	active	\N	pending	\N
1595371	\N	RENATO LUPETTI S.R.L.	2316730502.0	02316730502	VIA GIAMBATTISTA MARINO, 5	PISA	56127.0	PI	Toscana	NaN	\N	25	2025-03-10	NaN	NaN	NaN	050-817025	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.67475	f	f	\N	\N	[]	0	active	\N	pending	\N
1595375	\N	ENGAGE IT SERVICES SRL	2761360342.0	02761360342	VIA PERTINI, 13	FIDENZA	43036.0	PR	Emilia-romagna	NaN	\N	6	2025-03-10	NaN	NaN	NaN	0524-332481	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.67708	f	f	\N	\N	[]	0	active	\N	pending	\N
1595380	\N	PASTICCERIA CAFFETTERIA DOLCI MAGIE SNC DI MIGNANI ROMINA SOLEDAD & C.	1121320111.0	01121320111	CORSO CAVOUR, 207-209	LA SPEZIA	10121.0	SP	Liguria	NaN	\N	15	2025-03-10	NaN	https://www.facebook.com/dolcimagie/	NaN	393.8086347	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.679565	f	f	\N	\N	[]	0	active	\N	pending	\N
1595397	\N	PYROGIOCHI ITALIA S.R.L.	2173640505.0	02173640505	VIA GELLO- VIA LOMBARDIA, 38	PONTEDERA	56025.0	PI	Toscana	Italia	\N	15	2025-03-10	NaN	www.pyrogiochi.com	NaN	0587296276	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.682775	f	f	\N	\N	[]	0	active	\N	pending	\N
1595400	\N	COOPERATIVA SOCIALE ALLE CASCINE	11097550153.0	11097550153	VIA DELLE CROCIATE, 6	SAN GIULIANO MILANESE	20098.0	MI	Lombardia	Italia	\N	47	2025-03-10	NaN	www.allecascine.com	NaN	0238241776	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.686516	f	f	\N	\N	[]	0	active	\N	pending	\N
1595406	\N	COOPERATIVA SOCIALE PROMOZIONE UMANA	7341700156.0	07341700156	VIA DELLE CROCIATE, 1	SAN GIULIANO MILANESE	20098.0	MI	Lombardia	Italia	\N	99	2025-03-10	NaN	www.promozioneumana.it	NaN	025279679	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.690071	f	f	\N	\N	[]	0	active	\N	pending	\N
1595420	\N	L.S. NORD S.R.L.	2525240301.0	02525240301	VIA CECLIS, 4/2	CHIUSAFORTE	33010.0	UD	Friuli-venezia giulia	Italia	\N	12	2025-03-10	Impresa Costruzioni Generali. Realizzazione ingegneria civile ed industriale (micropali, tiranti, opere in c.a.), strade, lavori idraulico-forestali	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.693721	f	f	\N	\N	[]	0	active	\N	pending	\N
1595492	\N	ART POLISH S.R.L.	2099980225.0	NaN	Via Provina 12/a	Trento	38123.0	Trento	Trentino-Alto Adige/Südtirol	Italia	\N	0	2025-03-10	NaN	https://www.artpolish.com/	christian@artpolish.com;artpolishsrl@pec.it	0461.824654	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.696958	f	f	\N	\N	[]	0	active	\N	pending	\N
1595510	\N	PINNA DANIELE	1150810958.0	PNNDNL88C08G113F	VIA GIOTTO 16 - 09170 - ORISTANO (OR)	Oristano	9170.0	Oristano	Sardegna	Italia	\N	0	2025-03-11	Toelettatura per animali con l'imminente lancio della Startup PETHAIR	NaN	giardinodeglianimali@tiscali.it	3494127844	\N	Centro	["Giovanni Fulgheri"]	2025-07-03 20:34:35.700186	f	f	\N	\N	[]	0	active	\N	pending	\N
1595528	\N	STUDIO 1 AUTOMAZIONI INDUSTRIALI SRL	2264720356.0	02264720356	VIA CA' DEL MIELE, 8	CASALGRANDE	42013.0	RE	Emilia-romagna	Italia	\N	20	2025-03-11	NaN	https://www.studio1srl.it/	NaN	0536851243	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.703473	f	f	\N	\N	[]	0	active	\N	pending	\N
1595572	\N	FERAL S.R.L.	1201850110.0	01201850110	VIA VENEZIA, LOCALITA' CERRI, SNC	FOLLO	19020.0	SP	Liguria	Italia	\N	23	2025-03-11	NaN	www.feralsp.com	NaN	328.8735770	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.706431	f	f	\N	\N	[]	0	active	\N	pending	\N
1595586	\N	CIFRA SAS DI BERTUCCELLI MARIA CINZIA	1124410455.0	01124410455	VIA DORSALE, 9	MASSA	54100.0	MS	Toscana	Italia	\N	5	2025-03-11	NaN	NaN	NaN	0585.793093	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.709899	f	f	\N	\N	[]	0	active	\N	pending	\N
1595596	\N	EDILCOMPONENTI S.R.L.	519290456.0	00519290456	VIALE GALILEO GALILEI, 32	CARRARA	54031.0	MS	Toscana	Italia	\N	9	2025-03-11	NaN	www.edilcomponenti.net	NaN	0585 51394	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.713061	f	f	\N	\N	[]	0	active	\N	pending	\N
1595751	\N	L' EXTRO DI ACCORDI MARCO	4902480237.0	NaN	Viale Martiri della Libertà, 60	CASALEONE	37052.0	VR	Veneto	NaN	\N	0	2025-03-11	NaN	NaN	lextro.shop@gmail.com	347.7614868	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.715658	f	f	\N	\N	[]	0	active	\N	pending	\N
1595787	\N	CSCA - SOCIETA' A RESPOSABILITA' LIMITATA	5089390966.0	05089390966	VIALE SAN BARTOLOMEO, 276	LA SPEZIA	19126.0	SP	Liguria	Italia	\N	28	2025-03-12	NaN	NaN	NaN	018.7503086	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.718097	f	f	\N	\N	[]	0	active	\N	pending	\N
1595788	\N	SCOTTO PNEUMATICI DI MASSIMO E ANDREA SCOTTO SOCIETA' IN NOME COLLETTIVO	190370999.0	02713640106	VIA PARMA, 384H	CHIAVARI	16043.0	GE	Liguria	Italia	\N	8	2025-03-12	NaN	www.scottopneumatici.it	NaN	0185-382043	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.720363	f	f	\N	\N	[]	0	active	\N	pending	\N
1595791	\N	PANETTERIA BALDINI DI FICERAI FRANCESCA	1104410459.0	FCRFNC77E67H501W	VIA DELLA CHIUSA, 47/A	SERAVEZZA	55047.0	LU	Toscana	Italia	\N	1	2025-03-12	NaN	NaN	NaN	393.9598503	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.722773	f	f	\N	\N	[]	0	active	\N	pending	\N
1595794	\N	PANETTERIA BALDINI S.R.L.	1174640456.0	01174640456	VIA PROVINCIALE VALLECCHIA, 93/L	PIETRASANTA	55045.0	LU	Toscana	Italia	\N	17	2025-03-12	NaN	NaN	NaN	393.9598503	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.725865	f	f	\N	\N	[]	0	active	\N	pending	\N
1595798	\N	LUSARDI S.R.L.	1593100348.0	01593100348	VIA STRINATA, 3	TORNOLO	43057.0	PR	Emilia-romagna	Italia	\N	11	2025-03-12	NaN	www.lusardisrl.it	NaN	0185469018	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.729019	f	f	\N	\N	[]	0	active	\N	pending	\N
1595809	\N	LEAF4LIFE SRL	4588350985.0	04588350985	VIA TRIESTE, 1	BOVEZZO	25073.0	BS	Lombardia	Italia	\N	0	2025-03-12	Commercio all'ingrosso e al dettaglio di profumi e cosmesi. L'azienda agricola produce canapa (nata nel 2021). La SRL (LEAF4LIFE) nasce nel 2024.	NaN	NaN	NaN	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:35.731949	f	f	\N	\N	[]	0	active	\N	pending	\N
1596144	\N	COIFFEUR VANNI DI OLIVETI GRAZIELLA E C. S.N.C.	183690999.0	02437950104	VIA TRIPOLI, 1	SANTA MARGHERITA LIGURE	16038.0	GE	Liguria	NaN	\N	10	2025-03-12	NaN	www.coiffeurvanni.com	NaN	0185-288072	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.734788	f	f	\N	\N	[]	0	active	\N	pending	\N
1596148	\N	AG FARMA S.R.L.	3788750929.0	03788750929	VIA SAN SEBASTIANO, 39	SAN SPERATE	9026.0	CA	Sardegna	Italia	\N	12	2025-03-12	Codice Ateco: 47.73.1 - Commercio al dettaglio di farmaci (Farmacia) #Luana	www.farmabellezza.it	NaN	0789 53805	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.737632	f	f	\N	\N	[]	0	active	\N	pending	\N
1596264	\N	XLR8  S.R.L.	4713520965.0	04713520965	VIA ANTONIO BORGESE, 14	MILANO	20154.0	MI	Lombardia	Italia	\N	8	2025-03-13	NaN	NaN	NaN	335 6265155	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.740602	f	f	\N	\N	[]	0	active	\N	pending	\N
1596270	\N	GELATERIA K2 DI PANNOZZO NICOLA S.A.S.	1133200996.0	01133200996	VIA ASILO MARIA TERESA, 12-14	SESTRI LEVANTE	16039.0	GE	Liguria	NaN	\N	8	2025-03-13	NaN	www.facebook.com/gelateriak2sestri/	NaN	018.544604	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.743769	f	f	\N	\N	[]	0	active	\N	pending	\N
1596400	\N	WELCOME WAY S.R.L.	1513330116.0	01513330116	VIA GIOVANNI PASCOLI, 19	LA SPEZIA	19124.0	SP	Liguria	Italia	\N	12	2025-03-13	NaN	www.terremarine.it	NaN	0187 1393370	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.747073	f	f	\N	\N	[]	0	active	\N	pending	\N
1596406	\N	LUIGINI ECOLOGIA SRL	1374240115.0	01374240115	VIA MONTESAGRO, 3	ARCOLA	19021.0	SP	Liguria	Italia	\N	19	2025-03-13	NaN	www.luigini.com	NaN	0187284266	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.750932	f	f	\N	\N	[]	0	active	\N	pending	\N
1596443	\N	TASSAN IMPIANTI SRL	515050326.0	00515050326	VIA CABOTO, 18/1	TRIESTE	34147.0	TS	Friuli-venezia giulia	NaN	\N	17	2025-03-13	La ditta Tassan si occupa della realizzazione di impianti idrotermosanitari, gas, climatizzazione, energie alternative, canne fumarie.	www.tassanimpianti.com	NaN	040-383886	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.754649	f	f	\N	\N	[]	0	active	\N	pending	\N
1596475	\N	NUOVA SICMI S.R.L.	2385810045.0	02385810045	VIA DEL BOGLIO, 4	MONTEZEMOLO	12070.0	CN	Piemonte	Italia	\N	118	2025-03-13	NaN	www.nuovasicmi.it	NaN	017.4901010	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.757739	f	f	\N	\N	[]	0	active	\N	pending	\N
1596499	\N	FRIGORGELO S.A.S. DI MANOLA CELERI & C.	1070630999.0	01070630999	VIA CESARE BATTISTI, 17	LAVAGNA	16033.0	GE	Liguria	NaN	\N	24	2025-03-13	NaN	NaN	NaN	0185-313307	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.760931	f	f	\N	\N	[]	0	active	\N	pending	\N
1596536	\N	SO.GE. S.R.L.	1334350459.0	01334350459	VIALE STAZIONE, 31	MASSA	54100.0	MS	Toscana	Italia	\N	81	2025-03-13	NaN	NaN	NaN	348.6086380	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.764258	f	f	\N	\N	[]	0	active	\N	pending	\N
1596539	\N	BISTRO' SRL	2393590993.0	02393590993	PIAZZA MATTEOTTI, 13	SESTRI LEVANTE	16039.0	GE	Liguria	NaN	\N	21	2025-03-13	Codice Ateco: 56.30.00 - Bar e altri esercizi simili senza cucina.	m.facebook.com/bistrosestrilevante/	NaN	347.5813966	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.767588	f	f	\N	\N	[]	0	active	\N	pending	\N
1596550	\N	U' PESCOU S.R.L.	1884040997.0	01884040997	VIA DANTE, 70	LAVAGNA	16033.0	GE	Liguria	NaN	\N	17	2025-03-13	NaN	NaN	NaN	328.7964058	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.771101	f	f	\N	\N	[]	0	active	\N	pending	\N
1596555	\N	AUTOCARROZZERIA LA TIRRENA S.N.C. DI GABRIELLI GIORGIO E GABRIELLI MARIA	2189240464.0	02189240464	VIA SARZANESE, 17	PIETRASANTA	55045.0	LU	Toscana	Italia	\N	2	2025-03-13	Codice Ateco: 45.20.2 - Riparazioni di carrozzerie di autoveicoli. (carrozzeria)	www.carrozzerialatirrena.com	NaN	0584792240	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.774436	f	f	\N	\N	[]	0	active	\N	pending	\N
1596560	\N	VIP AGENCY DI STEFANO POLO	738200328.0	PLOSFN65R05L424L	VIA UGO FOSCOLO, 17	TRIESTE	34129.0	TS	Friuli-venezia giulia	NaN	\N	3	2025-03-13	Azienda specializzata in realizzazioni grafiche.	www.vipagency.it	NaN	040.3499272	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.777971	f	f	\N	\N	[]	0	active	\N	pending	\N
1596561	\N	AGENZIA ATTORRESE DI PATRIZIA LIBERTINI, ARIANNA ATTORRESE & C. S .A.S.	2542090994.0	02542090994	PIAZZA DELLA VITTORIA, 6/14 B	GENOVA	16121.0	GE	Liguria	Italia	\N	2	2025-03-13	Codice Ateco: 66.22.00 - Attività delle agenzie e dei mediatori di assicurazione (Consulenti Assicurativi). #Luana	NaN	NaN	338.6398681	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.780803	f	f	\N	\N	[]	0	active	\N	pending	\N
1596572	\N	ACQUA PONICA	NaN	NaN	NaN	VERONA	37121.0	VR	Veneto	Italia	\N	0	2025-03-14	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.783642	f	f	\N	\N	[]	0	active	\N	pending	\N
1596573	\N	VALEVEND SRL	11190431004.0	NaN	Via di Pian Savelli, 126	ROMA	134.0	RM	Lazio	Italia	\N	0	2025-03-14	Dal 2011 Valevend è il punto di riferimento a Roma e in tutto il Lazio per i distributori automatici di bevande.\nVendita e noleggio Distributori automatici e macchine horeca. \nIngrosso di caffè in grani, cialde e capsule, snack e bevande per distributori automatici, macchine per la prima colazione e macchine a cialde e capsule	https://www.valevend.it/	valentino.paroncini@valevend.it	331.6919026	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.786746	f	f	\N	\N	[]	0	active	\N	pending	\N
1596789	\N	NEW KARISMA DI FALERI SAMANTA	1390490520.0	FLRSNT82T48A468Z	VIA PIAVE, 74	SINALUNGA	53048.0	SI	Toscana	NaN	\N	3	2025-03-14	NaN	NaN	NaN	328.1932034	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.790205	f	f	\N	\N	[]	0	active	\N	pending	\N
1596791	\N	MARCHETTI S.R.L.	1470080464.0	01470080464	VIA MASINI ANG. VIA ITALICA, 94	CAMAIORE	55040.0	LU	Toscana	Italia	\N	3	2025-03-14	NaN	NaN	NaN	0584913547	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.793081	f	f	\N	\N	[]	0	active	\N	pending	\N
1596793	\N	GASTRINI ROBERTO S.N.C. DI GASTRINI CHRISTIAN & C.	1758950990.0	01758950990	CORSO BUENOS AYRES, 114	LAVAGNA	16033.0	GE	Liguria	Italia	\N	9	2025-03-14	NaN	www.gastriniroberto.it	NaN	018.5300412	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.796058	f	f	\N	\N	[]	0	active	\N	pending	\N
1596796	\N	PRIMO VARCO S.A.S. DI ROBERTO MARTINI & C.	2570950903.0	02570950903	VIA GRAZIA DELEDDA, 58	SASSARI	7100.0	SS	Sardegna	NaN	\N	13	2025-03-14	NaN	NaN	NaN	347.4857101	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.798886	f	f	\N	\N	[]	0	active	\N	pending	\N
1596800	\N	FARMACIA BETTI DEL DOTT. BETTI CESARE	1160380521.0	BTTCSR54P05A468B	VIA GRAMSCI, 21	SINALUNGA	53048.0	SI	Toscana	Italia	\N	2	2025-03-14	NaN	www.farmaciabetticesare.it	NaN	0577-630212	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.801705	f	f	\N	\N	[]	0	active	\N	pending	\N
1596808	\N	HOTEL DUE TORRI SRL	1044410999.0	02701510584	VIA RAINUSSO, 3	SANTA MARGHERITA LIGURE	16038.0	GE	Liguria	NaN	\N	11	2025-03-14	NaN	www.hoteltigullio.eu	NaN	331.9092077	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.805321	f	f	\N	\N	[]	0	active	\N	pending	\N
1596810	\N	ROSAJE S.R.L.	2278650466.0	02278650466	VIA PESCIATINA, 2/A	CAPANNORI	55012.0	LU	Toscana	NaN	\N	10	2025-03-14	NaN	NaN	NaN	0583.546072	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.808391	f	f	\N	\N	[]	0	active	\N	pending	\N
1596812	\N	MEROPE S.A.S. DI SANTUCCI GIUSEPPE E C.	1140110451.0	01140110451	VIA GIUSEPPE ULIVI, 2/A	CARRARA	54033.0	MS	Toscana	Italia	\N	5	2025-03-14	NaN	www.meropessteakhouse.it	NaN	0585-776961	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.811082	f	f	\N	\N	[]	0	active	\N	pending	\N
1596813	\N	LUCA'S CAFFE' S.R.L.	1483820112.0	01483820112	VIA FONTEVIVO, 17	LA SPEZIA	19125.0	SP	Liguria	Italia	\N	13	2025-03-14	NaN	NaN	NaN	320.9375308	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.813865	f	f	\N	\N	[]	0	active	\N	pending	\N
1596818	\N	TUBI PLASTIC S.R.L.	1323550457.0	01323550457	VIALE XX SETTEMBRE, 177 F2	CARRARA	54033.0	MS	Toscana	Italia	\N	17	2025-03-14	NaN	NaN	NaN	0187694285	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.816447	f	f	\N	\N	[]	0	active	\N	pending	\N
1596824	\N	LA SUITE BEAUTY SPA DI SARA BERTANI	1316970456.0	BRTSRA87M65F023F	VIA MUTTINI ANGOLO VIA LUNENSE,	CARRARA	54033.0	MS	Toscana	NaN	\N	4	2025-03-14	NaN	NaN	NaN	340.3731841	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.818961	f	f	\N	\N	[]	0	active	\N	pending	\N
1596828	\N	CAST BOLZONELLA SRL	5160150289.0	05160150289	VIA AMERIGO VESPUCCI, 7	CAMPODARSEGO	35011.0	PD	Veneto	Italia	\N	17	2025-03-14	NaN	www.castbolzonella.it	NaN	049 8640809	\N	Nord-Ovest	["Pier Luigi Menin"]	2025-07-03 20:34:35.822025	f	f	\N	\N	[]	0	active	\N	pending	\N
1596834	\N	IMPIANTI PADOVA S.A.S. DI TIRANTI VALERIO & C.	5263800285.0	05263800285	VIA NATALE DALLE LASTE, 8	PADOVA	35126.0	PD	Veneto	Italia	\N	7	2025-03-14	NaN	www.impiantipadova.it	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.824273	f	f	\N	\N	[]	0	active	\N	pending	\N
1596841	\N	G.P.INOSSIDABILE S.R.L.	2386841205.0	02386841205	VIA ETTORE NARDI, 71	OZZANO DELL'EMILIA	40064.0	BO	Emilia-romagna	NaN	\N	3	2025-03-14	NaN	www.gpinossidabile.com	NaN	051-6511976	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.827202	f	f	\N	\N	[]	0	active	\N	pending	\N
1596844	\N	LIDI GROUP S.R.L.	1663010385.0	01663010385	VIA ROMEA, 15	COMACCHIO	44029.0	FE	Emilia-romagna	Italia	\N	16	2025-03-14	NaN	www.lidigroup.it	NaN	0533-327195	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.829387	f	f	\N	\N	[]	0	active	\N	pending	\N
1596849	\N	LIDI LIFE S.R.L.	1969210382.0	01969210382	STRADA STATALE ROMEA, 15	COMACCHIO	44029.0	FE	Emilia-romagna	Italia	\N	23	2025-03-14	NaN	NaN	NaN	348.8720893	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.831756	f	f	\N	\N	[]	0	active	\N	pending	\N
1596852	\N	C.M.I.T.  DI CRISTIANO MAZZONI E C. - S.N.C.	1350600118.0	01350600118	VIA FONTEVIVO,	LA SPEZIA	19125.0	SP	Liguria	NaN	\N	10	2025-03-14	NaN	NaN	NaN	320.9375308	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.83463	f	f	\N	\N	[]	0	active	\N	pending	\N
1596855	\N	ANDERLINI GIUSEPPE E FIGLI S.R.L.	3113361202.0	03113361202	VIA DE' CARRACCI, 14	CASALECCHIO DI RENO	40033.0	BO	Emilia-romagna	NaN	\N	8	2025-03-14	Codice Ateco: 43.22.01 - Installazione di impianti idraulici, di riscaldamento e di condizionamento dell'aria  (Termoidraulica). #Luana	www.viessmannbologna.it	NaN	051-4859593	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.837165	f	f	\N	\N	[]	0	active	\N	pending	\N
1596858	\N	HELLO SAILOR S.R.L.	12850001004.0	12850001004	VIALE JONIO, 312/314	ROMA	139.0	RM	Lazio	Italia	\N	39	2025-03-14	NaN	https://vintrobarandbites.business.site/	NaN	0687750461	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.839854	f	f	\N	\N	[]	0	active	\N	pending	\N
1596863	\N	ROMA VIA VENETO S.R.L.	13255071006.0	13255071006	VIA DELLA VITE, 5	ROMA	187.0	RM	Lazio	Italia	\N	0	2025-03-14	NaN	NaN	NaN	348.3520192	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.843051	f	f	\N	\N	[]	0	active	\N	pending	\N
1596870	\N	C.M.T. SRL	3786530364.0	03786530364	VIA DELL'INDUSTRIA, 2	SAN FELICE SUL PANARO	41038.0	MO	Emilia-romagna	Italia	\N	17	2025-03-14	NaN	NaN	NaN	053581359	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.846122	f	f	\N	\N	[]	0	active	\N	pending	\N
1596873	\N	MS IMPIANTI S.R.L.S.	15854021001.0	15854021001	VIA NETTUNO, 28	ALBANO LAZIALE	41.0	RM	Lazio	NaN	\N	8	2025-03-14	NaN	NaN	NaN	393.3824723	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.849361	f	f	\N	\N	[]	0	active	\N	pending	\N
1596874	\N	T-MOTION S.R.L.	2187850462.0	02187850462	VIA TORRACCIA, 15	PIETRASANTA	55045.0	LU	Toscana	NaN	\N	3	2025-03-14	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.852554	f	f	\N	\N	[]	0	active	\N	pending	\N
1596890	\N	MERONI S.R.L.	10138300966.0	10138300966	VIA PIOLA, 16	GIUSSANO	20833.0	MB	Lombardia	NaN	\N	6	2025-03-14	NaN	NaN	NaN	327.4773338	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.855989	f	f	\N	\N	[]	0	active	\N	pending	\N
1596893	\N	IMPRESA LUMACA S.R.L.	7706401002.0	07706401002	VIA DEI CANDIANO, 58	ROMA	148.0	RM	Lazio	NaN	\N	14	2025-03-14	NaN	NaN	NaN	348.9042240	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.859033	f	f	\N	\N	[]	0	active	\N	pending	\N
1596894	\N	IMMOBILIARE LUMACA S.R.L.	11134971008.0	11134971008	VIA DEI CANDIANO, 58	ROMA	148.0	RM	Lazio	NaN	\N	20	2025-03-14	NaN	NaN	NaN	348.9042240	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.862249	f	f	\N	\N	[]	0	active	\N	pending	\N
1596896	\N	ISO 2000 APPALTI S.R.L.	6334651004.0	06334651004	VIALE CORTINA D'AMPEZZO, 1	ROMA	135.0	RM	Lazio	NaN	\N	9	2025-03-14	NaN	NaN	NaN	06-3315111	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.86534	f	f	\N	\N	[]	0	active	\N	pending	\N
1596903	\N	ISO S.R.L.	10005200968.0	10005200968	VIA LUIGI ALAMANNI, 16.3	MILANO	20141.0	MI	Lombardia	Italia	\N	2	2025-03-14	NaN	www.isoproduzioni.it	NaN	0284214708	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.868279	f	f	\N	\N	[]	0	active	\N	pending	\N
1596907	\N	SICURA DOMUS SNC DI CERESA LUCA E COMMISARI DANIELE	5005060966.0	05005060966	VIALE ABRUZZI, 14N10	MILANO	20131.0	MI	Lombardia	Italia	\N	6	2025-03-14	NaN	www.sicuradomus.com	NaN	02-29520040	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:35.87134	f	f	\N	\N	[]	0	active	\N	pending	\N
1596909	\N	SWD COMPUTER S.R.L.	3419481209.0	03419481209	VIA EMILIA LEVANTE, 81/P	BOLOGNA	40139.0	BO	Emilia-romagna	Italia	\N	3	2025-03-14	NaN	www.swdcomputer.it	NaN	0515877781	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.874614	f	f	\N	\N	[]	0	active	\N	pending	\N
1596912	\N	JLB BOOKS S.A.S. DI SVAIZER NICOLA & C.	1506190220.0	01506190220	VIA SANT'ANDREA, 4/A	PRIMIERO SAN MARTINO DI CASTRO	38054.0	TN	Trentino-alto adige	Italia	\N	3	2025-03-14	NaN	www.jlbbooks.it	NaN	0439765413	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.877743	f	f	\N	\N	[]	0	active	\N	pending	\N
1596914	\N	MAROCCOLO SRL	4761490236.0	04761490236	VIA ROVEGGIA, 122/A	VERONA	37136.0	VR	Veneto	NaN	\N	5	2025-03-14	NaN	NaN	NaN	3338466918	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.88	f	f	\N	\N	[]	0	active	\N	pending	\N
1596915	\N	IL GABBIANO SOCIETA' COOPERATIVA SOCIALE DI SOLIDARIETA' IN SIGLA IL GABBIANO COOPERATIVA SOCIALE	1198620229.0	01198620229	VIA PROVINA, 20	TRENTO	38123.0	TN	Trentino-alto adige	NaN	\N	150	2025-03-14	NaN	NaN	NaN	0461 343501	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.882527	f	f	\N	\N	[]	0	active	\N	pending	\N
1596937	\N	CRAZY CAT CAFE' SRL	9000510967.0	09000510967	VIA TORRIANI NAPO, 5	MILANO	20124.0	MI	Lombardia	Italia	\N	14	2025-03-14	NaN	www.crazycatcafe.it	NaN	0284542739	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.885675	f	f	\N	\N	[]	0	active	\N	pending	\N
1598987	\N	HOLDING FIN.MA S.R.L.	3878721202.0	03878721202	Via Manin 7/B	Cento	44042.0	Ferrara	Emilia-Romagna	Italia	\N	1	2025-03-16	L'azienda si occupa di servizi professionali qualificati effettuati sia a beneficio di cose o beni, che a favore della persona, in particolare servizio di ritiro e trasporto di carcasse di animali di piccola, media, grande taglia; servizio funerario per animali domestici, compresa incinerazione, raccolta ceneri e consegna a domicilio delle ceneri in urna.	NaN	NaN	051.904252	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.888884	f	f	\N	\N	[]	0	active	\N	pending	\N
1599389	\N	MANSERVISI ENERGY SRL	4095431203.0	04095431203	Via Manin 7B	Cento	44042.0	Ferrara	Emilia-Romagna	Italia	\N	1	2025-03-16	Gestione di impianti di distribuzione di carburanti e relativi servizi accessori e la vendita all’ingrosso e al dettaglio di GPL domestico e per autotrazione.	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.891619	f	f	\N	\N	[]	0	active	\N	pending	\N
1600219	\N	L'OFFICINA DEL GUSTO S.R.L.	3194911206.0	03194911206	VIA CATALANI, 4	SAN GIOVANNI IN PERSICETO	40017.0	BO	Emilia-romagna	NaN	\N	18	2025-03-17	NaN	www.guidottiofficinadelgusto.com	NaN	051-822139	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.894608	f	f	\N	\N	[]	0	active	\N	pending	\N
1600221	\N	IN & OUT GIARDINI DI BELESOLO MATTEO	4029240233.0	BLSMTT83A12E349D	VIA FRESCADELLA,	CEREA	37053.0	VR	Veneto	NaN	\N	10	2025-03-17	NaN	NaN	NaN	349.5868478	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.897306	f	f	\N	\N	[]	0	active	\N	pending	\N
1600225	\N	MAROCCOLO STEFANO	1737380236.0	MRCSFN65C09H783N	VIA ROVEGGIA, 122/A	VERONA	37136.0	VR	Veneto	NaN	\N	11	2025-03-17	NaN	www.maroccolo.it	NaN	045-8250276	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.900381	f	f	\N	\N	[]	0	active	\N	pending	\N
1600237	\N	ESTETICA PIU' BELLA DI STANCO ANNA MARIA	4724450483.0	STNNMR67A71Z112E	VIA PONZANO, 50	EMPOLI	50053.0	FI	Toscana	Italia	\N	8	2025-03-17	NaN	www.esteticapiubella.it	NaN	0571-922078	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.904064	f	f	\N	\N	[]	0	active	\N	pending	\N
1600261	\N	PIUBELLA S.R.L.	6991180487.0	06991180487	VIA PONZANO, 50	EMPOLI	50053.0	FI	Toscana	Italia	\N	11	2025-03-17	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.907291	f	f	\N	\N	[]	0	active	\N	pending	\N
1600262	\N	GRUPPO INSIEME S.R.L.	2542390998.0	02542390998	MURA MURA DI SAN BERNARDINO, 20	GENOVA	16122.0	GE	Liguria	Italia	\N	40	2025-03-17	Rsa con software di gestione delle cartelle cliniche.\n# Sabrina	www.casariposodonguanella.it	NaN	010318077	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.911165	f	f	\N	\N	[]	0	active	\N	pending	\N
1600263	\N	M.P. FLOWERS SANREMO S.R.L.	1729140085.0	01729140085	VIA SAN FRANCESCO, 350	TAGGIA	18018.0	IM	Liguria	NaN	\N	15	2025-03-17	NaN	www.pizzomarzio.com	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.914629	f	f	\N	\N	[]	0	active	\N	pending	\N
1600269	\N	M.P. FLOWERS S.A.S. DI NASI ROSALBA & C.	1528260084.0	01528260084	VIA SAN FRANCESCO, 350	TAGGIA	18018.0	IM	Liguria	NaN	\N	15	2025-03-17	NaN	NaN	NaN	0184-550501	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.91813	f	f	\N	\N	[]	0	active	\N	pending	\N
1600276	\N	EGOZONA S.R.L.	1161790520.0	01161790520	LOC. SPADINO VIA PISANA, SNC	BARBERINO TAVARNELLE	50028.0	FI	Toscana	Italia	\N	8	2025-03-17	NaN	www.myegozona.it	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.920653	f	f	\N	\N	[]	0	active	\N	pending	\N
1600420	\N	ALLEO SRL	2959451200.0	NaN	Via, Confortino Crespellano, 5	Valsamoggia	40056.0	BOLOGNA	Emilia-Romagna	Italia	\N	0	2025-03-17	Produzione e vendita di crocchette e alimenti naturali per animali.	https://www.albacroc.it/	info@albacroc.com	051.736717	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.923168	f	f	\N	\N	[]	0	active	\N	pending	\N
1600424	\N	ARBURG S.R.L.	NaN	NaN	Via G.Di Vittorio 31B	PESCHIERA BORROMEO	20068.0	MI	Lombardia	Italia	\N	0	2025-03-17	Macchine per stampaggio a iniezione, produzione additiva, sistemi robotici, controllo di processo, digitalizzazione.\nPer la produzione di parti in plastica.\nCodice Ateco: 46.62 - Commercio all'ingrosso di macchine utensili. #Luana	https://www.arburg.com/en/	NaN	02.553799.1	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.926795	f	f	\N	\N	[]	0	active	\N	pending	\N
1600491	\N	ELETTRA SINCROTRONE TRIESTE S.C.P.A.	697920320.0	NaN	S.S.14 km 163,5 in Area Science Park	BASOVIZZA	34149.0	Trieste	Friuli-Venezia Giulia	Italia	\N	0	2025-03-18	Elettra Sincrotrone Trieste è un centro di ricerca multidisciplinare di eccellenza aperto alla comunità scientifica internazionale, specializzato nella generazione di luce di sincrotrone e di laser ad elettroni liberi di alta qualità e nelle sue applicazioni nelle scienze dei materiali e della vita.\n\nLa sua missione è di promuovere la crescita culturale, sociale ed economica tramite:\n\nLa ricerca di base e applicata\nIl trasferimento tecnologico e della conoscenza\nL'alta formazione tecnica, scientifica e gestionale\nLa creazione e il coordinamento di reti scientifiche nazionali e internazionali\n\n\nAnagrafe Nazionale Ricerche Cod. 51779CRP\nPartita IVA 00697920320	https://www.elettra.eu/it/index.html	info@elettra.eu	040.3758384	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.930038	f	f	\N	\N	[]	0	active	\N	pending	\N
1600498	\N	EDILIZIA PARISI DI MAZZURCO FRANCESCA	1268820865.0	MZZFNC88C60E536L	VIA ANTONINO BUTTAFUOCO, 31	LEONFORTE	94013.0	EN	Sicilia	NaN	\N	4	2025-03-18	NaN	https://edilizia-parisi-di-mazzurco-francesca.business.site/?utm_source=gmb&utm_medium=referral	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.933114	f	f	\N	\N	[]	0	active	\N	pending	\N
1604783	\N	DOCKS LANTERNA S.P.A.	2315050100.0	02315050100	VIA CORSICA, 21/6 A	GENOVA	16128.0	GE	Liguria	NaN	\N	82	2025-03-20	NaN	www.dockslanterna.com	NaN	010-581929	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.936103	f	f	\N	\N	[]	0	active	\N	pending	\N
1605008	\N	Sartori's Hotel	100810225.0	00100810225	Via Nazionale 33	Lavis	38015.0	Trento	Trentino-Alto Adige/Südtirol	Italia	\N	0	2025-03-20	NaN	https://sartorishotellavis.com-hotel.com/	info@sartorishotel.com	0461.246563	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.938713	f	f	\N	\N	[]	0	active	\N	pending	\N
1605009	\N	RISTORANTE BUCANEVE	NaN	NaN	NaN	Val di Sole	38020.0	Trento	Trentino Alto Adige	NaN	\N	0	2025-03-20	NaN	NaN	NaN	0463 974263	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.941302	f	f	\N	\N	[]	0	active	\N	pending	\N
1605112	\N	ZOPPI A. SRLS	2013150491.0	02013150491	VIA DELLA CAMMINATA OVEST, 26	BIBBONA	57020.0	LI	Toscana	Italia	\N	11	2025-03-21	NaN	NaN	NaN	0586 671077	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.943955	f	f	\N	\N	[]	0	active	\N	pending	\N
1606028	\N	Farolfi Arredamenti	3297470407.0	NaN	Via Figline, 3	Forlì	47122.0	Forlì-Cesena	Emilia-Romagna	Italia	\N	0	2025-03-23	Da oltre cinquant’anni la ditta FAROLFI produce artigianalmente mobili. Nati come produttori di mobili da cucina abbiamo poi allargato la nostra produzione agli arredi per l’ufficio, ospedali e case di riposo.	NaN	info@farolfiarredamenti.it	0543 551262	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.94699	f	f	\N	\N	[]	0	active	\N	pending	\N
1606032	\N	PIUMA S.R.L. UNIPERSONALE	1514370996.0	01514370996	VIA TABARCA, 64	GENOVA	16147.0	GE	Liguria	Italia	\N	1	2025-03-22	ID myWorld 8054734	www.facebook.com/ristorantepizzeriadellanno1000/?hc_ref=arscsbsi6apbictwzstj6bgsi9axksft9b0keqz	NaN	010 9990337	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:35.95015	f	f	\N	\N	[]	0	active	\N	pending	\N
1606034	\N	HOTEL ALLA ROCCA DI BONELLI VALENTINA	2413340221.0	BNLVNT83H49C372G	VIA ALPINI, 10	VILLE DI FIEMME	38099.0	TN	Trentino-alto adige	Italia	\N	6	2025-03-23	ID myWorld 8013984	www.hotelallarocca.com	NaN	0462-340321	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:35.953015	f	f	\N	\N	[]	0	active	\N	pending	\N
1606271	\N	DAVIDE RUSSO STUDIO DI FISIOTERAPIA	2226830996.0	RSSDVD90R26C621P	VIA SENATORE FEDERICO RICCI, 11	CASARZA LIGURE	16030.0	GE	Liguria	Italia	\N	0	2025-03-24	NaN	NaN	fisioterapia.russo@gmail.com	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.956503	f	f	\N	\N	[]	0	active	\N	pending	\N
1607110	\N	MOKAMO SRL	1921400220.0	NaN	Via della Cooperazione, 151	Trento	38123.0	Trento	Trentino-Alto Adige/Südtirol	Italia	\N	0	2025-03-25	Il profumo del caffè è parte della nostra famiglia fin dagli anni ’60, quando Oddene Merlin, poi fondatore dell’azienda,\nlavorava come rappresentante nel ramo del caffè. \nDalla passione per un prodotto che fa parte della tradizione dell’Italia stessa e che è parte\ndei rituali quotidiani di ognuno di noi, nasce la sua ricetta, la sua azienda e il suo marchio. BRAO Caffè nasce nel 1987.	https://braocaffe.it/	info@braocaffe.it	0461.915133	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.959464	f	f	\N	\N	[]	0	active	\N	pending	\N
1607140	\N	Studio Leonardi Seppi Commercialisti	2316630223.0	NaN	Via Don Leone Serafini, 54	Frazione Martignano	38121.0	Trento	Trentino Alto Adige	Italia	\N	0	2025-03-25	NaN	NaN	studio@lscommercialisti.it	0461.402225	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.962325	f	f	\N	\N	[]	0	active	\N	pending	\N
1611075	\N	Santi e Gualdi Servizi Assicurativi srl	2746010228.0	NaN	NaN	Trento	38121.0	Trento	Trentino-Alto Adige/Südtirol	Italia	\N	0	2025-03-26	NaN	NaN	NaN	NaN	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:35.964866	f	f	\N	\N	[]	0	active	\N	pending	\N
1651486	\N	TRAS SERVICE DI CAPPELLAZZO LUCA	1885970226.0	CPPLCU82A02L378A	VIA INNSBRUCK, 31	TRENTO	38121.0	TN	Trentino-alto adige	Italia	\N	26	2025-04-01	NaN	NaN	NaN	0461-993058	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.038072	f	f	\N	\N	[]	0	active	\N	pending	\N
1651491	\N	WE SPEED S.R.L.	2496360229.0	02496360229	VIA INNSBRUCK, 31	TRENTO	38121.0	TN	Trentino-alto adige	Italia	\N	17	2025-04-01	NaN	NaN	NaN	340 4713515	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.041404	f	f	\N	\N	[]	0	active	\N	pending	\N
1651497	\N	MUCINI S.R.L.	1543851206.0	01543851206	VIA MACERI, 2/C	SAN LAZZARO DI SAVENA	40068.0	BO	Emilia-romagna	Italia	\N	21	2025-04-01	NaN	NaN	NaN	051.6256674	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.044974	f	f	\N	\N	[]	0	active	\N	pending	\N
1651502	\N	ITECH SOLUZIONI S.R.L.	3771830407.0	03771830407	VIA S PANDOLFO MALATESTA, 69	RIMINI	47921.0	RN	Emilia-romagna	Italia	\N	8	2025-04-01	NaN	NaN	NaN	0543.775392	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.048663	f	f	\N	\N	[]	0	active	\N	pending	\N
1637318	\N	G.M.T. S.P.A.	4419830288.0	04419830288	VIA MOLINI, 40	SACCOLONGO	35030.0	PD	Veneto	Italia	\N	9	2025-03-26	G.M.T. S.p.A. è una Esco (Energy Service Company) certificata UNI CEI 11352, ISO 9001, UNI ISO 45001, ISO 14001 e UNI CEI EN 15900.\nL’azienda, che si colloca nel campo dell’efficienza energetica e della realizzazione di impianti da fonti rinnovabili, opera nel settore dal 2004. G.M.T. S.p.A. è attiva nello scenario nazionale nell’applicazione di tecnologie efficienti per l’uso razionale dell’energia al fine di ridurre i consumi energetici e concorrere al raggiungimento degli obiettivi previsti dall’Agenda ONU 2030.\n\nForniscono servizio per gli impianti fotovoltaici, sia chiavi in mano che installazione tramite terzi. Utilizzano pannelli Somencreaft.\n\nCollaborano con Schneider Electric, Somepar, ABB, AssoEquitalia, Avv. Bonafede, Confartigianato\nFanno consulenze 5.0, Conto Termico 3.0.\nIl 10 aprile inaugureranno la loro comunità energetica.\nHanno creato un'applicazione ( Zap-Grid ) che viene utilizzata da aim-agsm per l'installazione e la gestione delle colonnine di ricarica delle auto elettriche.\n\nZapGrid è l’anello di collegamento tra i gestori delle stazioni e-mobility e gli utilizzatori di autoveicoli elettrici. ZapGrid si occupa dell’invisibile processo che coniuga l’offerta e la domanda nel mondo della mobilità elettrica.\nGestione delle ricariche attraverso Mobile APP\nGestione di colonnine di ricarica di differenti produttori\nSoftware gestionale in cloud\nGestionale diversificato per gestori, manutentori e utenti finali\nSupervisione completa da remoto	www.gmtspa.com	NaN	0498075046	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.967486	f	f	\N	\N	[]	0	active	\N	pending	\N
1637979	\N	AVONI INDUSTRIAL SRL	3262870375.0	NaN	Via Bazzane 71	Calderara di Reno	40012.0	Bologna	Emilia-Romagna	Italia	\N	0	2025-03-26	La società AVONI Industrial viene fondata nel 1948 da Francesco Avoni come rappresentanza della Slanzi Motori. \nDalla fine degli anni ’70 diventa concessionaria Iveco Motors, ora FPT Industrial, leader mondiale nella progettazione e produzione di motori industriali.\nCodice Ateco: 46.6.99 - Commercio all'ingrosso di macchine e attrezzature per l'industria (progettazione e produzione di motori industriali). #Luana	https://avonisrl.it/	info@avonisrl.it	051.6462111	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:35.970109	f	f	\N	\N	[]	0	active	\N	pending	\N
1637981	\N	MOBILI ZANNI Srl	NaN	NaN	Via degli Orti, 30	Vobarno	25079.0	Brescia	Lombardia	Italia	\N	0	2025-03-26	Propongono mobili per la casa e l'ufficio personalizzati.	https://www.mobilizanni.it/storia-esperienza-settore-arredo/	info@mobilizanni.it	+39 0365597158	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:35.973569	f	f	\N	\N	[]	0	active	\N	pending	\N
1648293	\N	O.B.M. S.N.C. DI BOEDDU GIAN PIERO & C.	1476480916.0	01476480916	PIAZZA EMILIO LUSSU,	SAN TEODORO	8020.0	NU	Sardegna	Italia	\N	3	2025-03-26	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.976903	f	f	\N	\N	[]	0	active	\N	pending	\N
1648302	\N	PROGETTO VACANZE SNC DI BOEDDU GIAN PIERO & MARONGIU GIAN LUIGI	1412880914.0	01412880914	VIA DEGLI ASFODELI,	SAN TEODORO	8020.0	NU	Sardegna	Italia	\N	9	2025-03-27	NaN	NaN	amministrazioneprogettovacanze@gmail.com	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.980328	f	f	\N	\N	[]	0	active	\N	pending	\N
1648304	\N	FORMULA 4 S.R.L.	1632840912.0	01632840912	VIA GABRIELE D'ANNUNZIO,	SAN TEODORO	8020.0	NU	Sardegna	Italia	\N	2	2025-03-26	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.983139	f	f	\N	\N	[]	0	active	\N	pending	\N
1648306	\N	G.E.G. S.N.C. DI BOEDDU GIAN PIERO & C.	1453830919.0	01453830919	PIAZZA EMILIO LUSSU,	SAN TEODORO	8020.0	NU	Sardegna	Italia	\N	12	2025-03-27	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.985732	f	f	\N	\N	[]	0	active	\N	pending	\N
1648338	\N	CAMPING VAL RENDENA S.R.L.	1153960222.0	01153960222	VIA ALLE FONTANE, 8	PORTE DI RENDENA	38094.0	TN	Trentino-alto adige	Italia	\N	6	2025-03-28	ID myWorld 814115	www.campingvalrendena.com	NaN	0465801669	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:35.988348	f	f	\N	\N	[]	0	active	\N	pending	\N
1648533	\N	LA TERRAZZA DI FEDERICI PATRIK	4042540981.0	NaN	Via tre capitelli 149	Idro	25074.0	Brescia	Lombardia	Italia	\N	0	2025-03-29	Convenzionato myWorld codice ID 8053611	NaN	laterrazza.federici@gmail.com	036.5823393	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:35.991008	f	f	\N	\N	[]	0	active	\N	pending	\N
1648558	\N	ENERGIA E SERVIZI S.R.L.	1138260326.0	01138260326	STRADA DELLE SALINE, 30	MUGGIA	34015.0	TS	Friuli-venezia giulia	Italia	\N	19	2025-03-30	Energia e Servizi si occupa di realizzazione e risanamenti non distruttivi di impianti gas, fornitura, installazione e manutenzione di caldaie, centrali termiche, pompe di calore e climatizzatori. Risanamenti camini e condotte idrauliche.	NaN	info@energiaservizi.net	040232585	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:35.993912	f	f	\N	\N	[]	0	active	\N	pending	\N
1651129	\N	GEO INFISSI S.R.L.C.R.	1282930450.0	01282930450	VIALE XX SETTEMBRE, 150	CARRARA	54033.0	MS	Toscana	Italia	\N	5	2025-03-31	NaN	www.geoinfissi.it	NaN	0585733008	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.996883	f	f	\N	\N	[]	0	active	\N	pending	\N
1651149	\N	EDIL COLOR DI BORGHETTI CHRISTIAN	1192940458.0	BRGCRS81T29I449D	VIA GUIDO ROSS, 7/A	AULLA	54011.0	MS	Toscana	Italia	\N	13	2025-03-31	NaN	www.christianborghetti.it	christianborghetti@yahoo.it	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:35.999699	f	f	\N	\N	[]	0	active	\N	pending	\N
1651154	\N	Mavericks	NaN	NaN	Via Decumana, 12/1	Bologna	40133.0	Bologna	Emilia-Romagna	Italia	\N	0	2025-03-31	NaN	NaN	s.cavara@mavericksinbologna.com	NaN	\N	NaN	[]	2025-07-03 20:34:36.002322	f	f	\N	\N	[]	0	active	\N	pending	\N
1651155	\N	BELL'E PRONTO DI D'AMBROSIO PAOLA	1343260459.0	DMBPLA72E70E463W	VIA PARM, 18 A	CARRARA	54033.0	MS	Toscana	Italia	\N	1	2025-03-31	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.004767	f	f	\N	\N	[]	0	active	\N	pending	\N
1651413	\N	THE FACTORY S.R.L.	7538500724.0	07538500724	VIA EMANUELE MOL, 54A	BARI	70121.0	BA	Puglia	Italia	\N	4	2025-04-01	NaN	www.moscabianca.info	NaN	328.4122238	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.007358	f	f	\N	\N	[]	0	active	\N	pending	\N
1651416	\N	THEMA SERVIZI TURISTICI DI DE SANTIS RAFFAELE & C. *S.A.S.	2016690758.0	02016690758	SERRA ALIMINI, 1	OTRANTO	73028.0	LE	Puglia	Italia	\N	9	2025-04-01	NaN	www.borgodelisanti.it	NaN	08361946619	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.009747	f	f	\N	\N	[]	0	active	\N	pending	\N
1651426	\N	SPHERA LAB DI MARINO DONATEO	2610200756.0	DNTMRN69B13E979W	VIA SANTUARIO, 43	CARPIGNANO SALENTINO	73020.0	LE	Puglia	Italia	\N	10	2025-04-01	NaN	www.spheralab.it	NaN	08361956182	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.01203	f	f	\N	\N	[]	0	active	\N	pending	\N
1651437	\N	GOMMA SERVICE ADL S.R.L.	4552360754.0	04552360754	VIA FEDERICO II - ZONA PIP, 15/15 A	CAVALLINO	73020.0	LE	Puglia	Italia	\N	12	2025-04-01	NaN	NaN	NaN	0832 614040	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.014725	f	f	\N	\N	[]	0	active	\N	pending	\N
1651443	\N	H.G.V. ITALIA S.R.L.	1580930715.0	01580930715	VIA LEGNANO, 32	SAN SEVERO	71016.0	FG	Puglia	Italia	\N	9	2025-04-01	NaN	www.hgvitalia.it	NaN	0882228134	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.017691	f	f	\N	\N	[]	0	active	\N	pending	\N
1651457	\N	LA GATTA S.R.L.	5038910757.0	05038910757	VIA VITO FAZZI, 15	LECCE	73100.0	LE	Puglia	Italia	\N	21	2025-04-01	NaN	www.alexristorantelecce.it	NaN	320.8034258	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.019915	f	f	\N	\N	[]	0	active	\N	pending	\N
1651465	\N	ADRIATICO S.R.L.	1699140933.0	01699140933	VIA CADORE, 10	CHIONS	33083.0	PN	Friuli-venezia giulia	Italia	\N	42	2025-04-01	NaN	NaN	NaN	0434-639301	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.022473	f	f	\N	\N	[]	0	active	\N	pending	\N
1651471	\N	ADAPTA S.R.L.	1288080326.0	01288080326	VIA DEL CORONEO, 8	TRIESTE	34133.0	TS	Friuli-venezia giulia	Italia	\N	19	2025-04-01	NaN	www.adaptasrl.it	NaN	040-215900	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.024723	f	f	\N	\N	[]	0	active	\N	pending	\N
1651478	\N	ELITA SRL	2363030301.0	02363030301	VIALE SAN DANIELE, 92	TAVAGNACCO	33010.0	UD	Friuli-venezia giulia	Italia	\N	188	2025-04-01	NaN	www.elitasrl.com	NaN	0432.661208	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.026976	f	f	\N	\N	[]	0	active	\N	pending	\N
1651481	\N	BEW TECNOLOGIA ITALIANA S.R.L.	2664210305.0	02664210305	VIA LIBERO TEMOLO, 4	MILANO	20126.0	MI	Lombardia	Italia	\N	21	2025-04-01	NaN	NaN	NaN	0432.965172	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.034887	f	f	\N	\N	[]	0	active	\N	pending	\N
1651506	\N	SO.VE.T. SOCIETA' VETRARIA TREVIGIANA S.R.L	2014580266.0	02014580266	VIA EMILIO SALGARI, 1/A	RONCADE	31056.0	TV	Veneto	Italia	\N	38	2025-04-01	NaN	www.sovet.com	NaN	0422-848030	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.052734	f	f	\N	\N	[]	0	active	\N	pending	\N
1651510	\N	STEP IMPIANTI S.R.L.	885930321.0	00885930321	VIA FLAVIA, 130	TRIESTE	34147.0	TS	Friuli-venezia giulia	Italia	\N	85	2025-04-01	NaN	www.stepimpianti.it	NaN	0402820909	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.055899	f	f	\N	\N	[]	0	active	\N	pending	\N
1651527	\N	SIMOPARMA PACKAGING ITALIA S.R.L.	7263860962.0	07263860962	VIA DELLA TECNICA, 1	CASTEL GUELFO DI BOLOGNA	40023.0	BO	Emilia-romagna	Italia	\N	45	2025-04-01	NaN	www.technepackaging.com	NaN	0542 639901	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.059052	f	f	\N	\N	[]	0	active	\N	pending	\N
1651546	\N	PET SOLUTIONS S.P.A.	5177840286.0	05177840286	VIA G. MARCONI, 6	BORGORICCO	35010.0	PD	Veneto	Italia	\N	115	2025-04-01	NaN	NaN	NaN	049 9335901	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.061905	f	f	\N	\N	[]	0	active	\N	pending	\N
1651573	\N	FRIULBRAU S.R.L.	4718490271.0	04718490271	VIA MEDUNA, 23	SAN MICHELE AL TAGLIAMENTO	30028.0	VE	Veneto	Italia	\N	151	2025-04-01	NaN	NaN	NaN	0431430959	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.064778	f	f	\N	\N	[]	0	active	\N	pending	\N
1651576	\N	SYSTEMA S.P.A.	2036480289.0	02036480289	VIA SAN MARTINO,, 17/23	SANTA GIUSTINA IN COLLE	35010.0	PD	Veneto	Italia	\N	35	2025-04-01	NaN	www.systema.it/	NaN	049.9355663	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.06714	f	f	\N	\N	[]	0	active	\N	pending	\N
1651579	\N	RIGOTTI F.LLI S.R.L.	1977710225.0	01977710225	LOCALITA' LAGHETTI DI VELA, 7	TRENTO	38121.0	TN	Trentino-alto adige	Italia	\N	50	2025-04-01	NaN	www.autodemolizioni-rigotti-trento.it	NaN	0461.827574	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.070005	f	f	\N	\N	[]	0	active	\N	pending	\N
1651580	\N	CALVI IL SALUMIERE S.N.C. DI CALVI PAOLO GIULIO E C.	1505580181.0	01505580181	VIA XX SETTEMBRE, 12	BELGIOIOSO	27011.0	PV	Lombardia	Italia	\N	6	2025-04-01	NaN	NaN	NaN	0382969052	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.072874	f	f	\N	\N	[]	0	active	\N	pending	\N
1651582	\N	LONER S.R.L.	2048860221.0	02048860221	VIA SOLTERI, 4/2	TRENTO	38121.0	TN	Trentino-alto adige	Italia	\N	8	2025-04-01	NaN	NaN	NaN	0461096863	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.075722	f	f	\N	\N	[]	0	active	\N	pending	\N
1651583	\N	R.K. S.A.S. DI RONALD MASI & C.	3447331202.0	03447331202	VIA CHIESACCIA, 3	VALSAMOGGIA	40053.0	BO	Emilia-romagna	Italia	\N	9	2025-04-01	NaN	www.ristorantegiocondo.com	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.078757	f	f	\N	\N	[]	0	active	\N	pending	\N
1651588	\N	MC SERVIZI DI MASSIMILIANO CASCONE S.A.S.	9581210961.0	09581210961	VIA MARCONI, 1	TRENTO	38121.0	TN	Trentino-alto adige	Italia	\N	29	2025-04-01	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.081767	f	f	\N	\N	[]	0	active	\N	pending	\N
1651590	\N	CO.RA.PEL. S.R.L.	4766760286.0	04766760286	VIA UDINE, 2	VIGONZA	35010.0	PD	Veneto	Italia	\N	15	2025-04-01	NaN	www.corapel.com	NaN	049-8934087	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.08449	f	f	\N	\N	[]	0	active	\N	pending	\N
1651592	\N	OPERA GROUP S.R.L.	2860070362.0	02860070362	VIA MARTINELLA, 74	MARANELLO	41053.0	MO	Emilia-romagna	Italia	\N	164	2025-04-01	NaN	www.ceramicaopera.it	NaN	0536-9348357	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.087717	f	f	\N	\N	[]	0	active	\N	pending	\N
1651597	\N	MANGIAROTTI S.P.A.	1677330308.0	00481230266	VIA TIMAVO, 59	MONFALCONE	34074.0	GO	Friuli-venezia giulia	Italia	\N	216	2025-04-01	NaN	NaN	NaN	048125400	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.090679	f	f	\N	\N	[]	0	active	\N	pending	\N
1651600	\N	TAGLIARIOL DI TAGLIARIOL PIETRO E GIANNI S.A.S.	1248860932.0	01248860932	VIA DE LA COMINA, 19	PORDENONE	33170.0	PN	Friuli-venezia giulia	Italia	\N	8	2025-04-01	NaN	www.tagliariol.it	NaN	0434.551094	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.093377	f	f	\N	\N	[]	0	active	\N	pending	\N
1651605	\N	IL CIELO DI VITALE CORRADO & C. S.A.S.	2373061205.0	02373061205	VIA DEI FORNACIAI, 9/3	BOLOGNA	40129.0	BO	Emilia-romagna	Italia	\N	37	2025-04-01	NaN	www.polpetteecrescentine.com	NaN	051265416	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.096719	f	f	\N	\N	[]	0	active	\N	pending	\N
1651606	\N	LA LUNA DI CAPPELLETTI BIANCA E C. S.A.S.	3681650374.0	03681650374	VIA MASCARELLA, 4/B	BOLOGNA	40126.0	BO	Emilia-romagna	Italia	\N	55	2025-04-01	NaN	www.cantinabentivoglio.it	NaN	0512654160	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.099828	f	f	\N	\N	[]	0	active	\N	pending	\N
1651607	\N	LE STELLE DI BONESI FABIO & C. S.A.S.	3858500378.0	03858500378	VIA C. VIGHI, 33	BOLOGNA	40133.0	BO	Emilia-romagna	Italia	\N	23	2025-04-01	NaN	NaN	NaN	051-566401	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.102858	f	f	\N	\N	[]	0	active	\N	pending	\N
1651610	\N	GASTRONOMIA CUCINA AMICA	2920040041.0	PTSSRN78R68L219N	VIA C.A. DALLA CHIESA, 2/E	MANTA	12030.0	CN	Piemonte	Italia	\N	4	2025-04-01	NaN	NaN	NaN	017585049	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.105119	f	f	\N	\N	[]	0	active	\N	pending	\N
1651612	\N	GSG PORTE	2670910781.0	GRVGMM83T43G317A	VIA S.AGATA, 74	PAOLA	87027.0	CS	Calabria	Italia	\N	4	2025-04-01	NaN	NaN	NaN	0982 621851	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.107233	f	f	\N	\N	[]	0	active	\N	pending	\N
1651614	\N	CM ENERGY MARKET S.R.L.	3904251208.0	03904251208	VIA JOHN FITZGERALD KENNEDY, 16/A	ZOLA PREDOSA	40069.0	BO	Emilia-romagna	Italia	\N	5	2025-04-01	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.109479	f	f	\N	\N	[]	0	active	\N	pending	\N
1651616	\N	TERMOIDRAULICA CRISTOFORI S.R.L.	3061271205.0	03061271205	VIA JOHN FITZGERALD KENNEDY, 16/A	ZOLA PREDOSA	40069.0	BO	Emilia-romagna	Italia	\N	25	2025-04-01	NaN	NaN	NaN	051-435145	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.111698	f	f	\N	\N	[]	0	active	\N	pending	\N
1651618	\N	ORIZZONTE S.A.S. DI SCATOLETTI SERENA	13746501009.0	13746501009	VIA DEI CAPPELLARI, 88	ROMA	186.0	RM	Lazio	Italia	\N	2	2025-04-01	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.114397	f	f	\N	\N	[]	0	active	\N	pending	\N
1653141	\N	COMMEDIA S.R.L.	3689950271.0	03689950271	SESTIERE SAN MARCO, 4596/A	VENEZIA	30124.0	VE	Veneto	Italia	\N	19	2025-04-02	NaN	www.commediahotel.com	NaN	041 2770235	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.116904	f	f	\N	\N	[]	0	active	\N	pending	\N
1653175	\N	CREAZIONI EDITORIALI S.R.L.	8612690969.0	08612690969	VIA DOMENICO CIMAROSA, 3	MILANO	20144.0	MI	Lombardia	Italia	\N	12	2025-04-02	NaN	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.119535	f	f	\N	\N	[]	0	active	\N	pending	\N
1653771	\N	SUN&CO S.N.C. DI CAPONETTO FABIO E C.	2729150991.0	02729150991	VIA PRIVATA CIAN DE DRIA, 2	SAN COLOMBANO CERTENOLI	16040.0	GE	Liguria	Italia	\N	5	2025-04-03	Progettazione, manutenzione, installazione e riparazione impianti elettronici.	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.125569	f	f	\N	\N	[]	0	active	\N	pending	\N
1653800	\N	GEAL S.R.L.	2341330229.0	02341330229	VIA LIDORNO, 3	TRENTO	38123.0	TN	Trentino-alto adige	Italia	\N	18	2025-04-02	NaN	NaN	NaN	0461944344	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.128447	f	f	\N	\N	[]	0	active	\N	pending	\N
1653805	\N	VERA PIZZA S.N.C. DI SAMUEL FACECCHIA & TORALDO GABRIELE	4943380750.0	04943380750	VIA LAGO DI LESINA, 15	GALATINA	73013.0	LE	Puglia	Italia	\N	16	2025-04-03	NaN	NaN	NaN	0836-234401	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.131506	f	f	\N	\N	[]	0	active	\N	pending	\N
1653808	\N	RIATTIVA S.R.L.	1081350991.0	01081350991	VIA MARTIRI DELLA LIBERAZIONE, 51/2	CHIAVARI	16043.0	GE	Liguria	Italia	\N	10	2025-04-03	NaN	NaN	NaN	010-9641083	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.134867	f	f	\N	\N	[]	0	active	\N	pending	\N
1653815	\N	GELATERIA GEPI MARE S.A.S. DI MARIOTTO ROCCA GIANLUIGI & C.	2281160990.0	02281160990	VIA BOTTARO, 40	SANTA MARGHERITA LIGURE	16038.0	GE	Liguria	Italia	\N	18	2025-04-03	NaN	NaN	NaN	0185-697369	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.138068	f	f	\N	\N	[]	0	active	\N	pending	\N
1653819	\N	TRATTORIA BAR EDERA S.R.L.	2778070991.0	02778070991	LARGO SILVIO GANDOLFO, 1-1 A	GENOVA	16163.0	GE	Liguria	Italia	\N	10	2025-04-03	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.141289	f	f	\N	\N	[]	0	active	\N	pending	\N
1653837	\N	PROMOCOLOR S.R.L.	3522240278.0	03522240278	VIA DELL' INDUSTRIA, 22	SAN MICHELE AL TAGLIAMENTO	30028.0	VE	Veneto	Italia	\N	11	2025-04-03	NaN	www.ludovicozamarian.it	NaN	0431512122	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.144417	f	f	\N	\N	[]	0	active	\N	pending	\N
1664138	\N	IDROTECNOSARDA S.R.L.	1128910955.0	01128910955	VIA MARCEDDI' 32 - 09098 - TERRALBA (OR)	Terralba	9098.0	Oristano	Sardegna	Italia	\N	0	2025-04-07	Installazione di impianti idraulici, di riscaldamento e di condizionamento dell'aria (inclusa manutenzione e riparazione) in edifici o in altre opere di costruzione (432201)	NaN	idrotecnosarda@gmail.com	3492174634	\N	NaN	["Giovanni Fulgheri"]	2025-07-03 20:34:36.147657	f	f	\N	\N	[]	0	active	\N	pending	\N
1664152	\N	G INFISSI S.R.L.	2358690465.0	02358690465	VIA PER SANT'ALESSIO, 1609	LUCCA	55100.0	LU	Toscana	Italia	\N	7	2025-04-07	NaN	www.ginfissi.it	NaN	0583309777	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.150689	f	f	\N	\N	[]	0	active	\N	pending	\N
1664160	\N	ECOSERVIM SRL	1696870359.0	01696870359	VIA ARISTOTELE, 22	REGGIO EMILIA	42122.0	RE	Emilia-romagna	Italia	\N	45	2025-04-07	NaN	www.ecoservim.it	NaN	0522 430629	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.153718	f	f	\N	\N	[]	0	active	\N	pending	\N
1664164	\N	DAMAX S.R.L.	2296610906.0	02296610906	VIA REGINA ELENA, 62	OLBIA	7026.0	SS	Sardegna	Italia	\N	23	2025-04-07	Consulenza, escursioni ed eventi.\nGestione diretta ed indiretta di pubblici esercizi.\nInsegna: Pizzeria Creativa Terranostra.\nNoleggio mezzi marittimi e terrestri.\nServizi di logistica.	NaN	NaN	NaN	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.157077	f	f	\N	\N	[]	0	active	\N	pending	\N
1664166	\N	SARDINIAN CLUB S.N.C. DI GIUSEPPE MARRONE & MARCO MURA	2988270902.0	02988270902	PIAZZA MATTEOTTI, 1	OLBIA	7026.0	SS	Sardegna	Italia	\N	0	2025-04-07	Commercio al dettaglio di prodotti alimentari.\nEscursioni ed eventi.\nGestione di pubblici esercizi, stabilimenti balneari e strutture sportive.\nInsegna: The Wine Club.\nNoleggio di mezzi marittimi e terrestri.	NaN	NaN	NaN	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.161331	f	f	\N	\N	[]	0	active	\N	pending	\N
1664206	\N	VARPESCA S.R.L.	2468340902.0	02468340902	VIA DEI MANISCALCHI, 24	OLBIA	7026.0	SS	Sardegna	Italia	\N	17	2025-04-07	NaN	www.pescheriavarpescaolbia.it	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.164847	f	f	\N	\N	[]	0	active	\N	pending	\N
1664889	\N	BELLAMOLI GRANULATI S.P.A.	2998670232.0	02998670232	VIA CESARE BETTELONI, 4/A	GREZZANA	37023.0	VR	Veneto	Italia	\N	22	2025-04-07	NaN	www.folende.it	NaN	045-8650460	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.167759	f	f	\N	\N	[]	0	active	\N	pending	\N
1664890	\N	NACAR'S RESTAURANT DI VITTORIO NACAR	2341280507.0	NCRVTR95D26F839Y	VIA ROMA, 100	PONTEDERA	56025.0	PI	Toscana	Italia	\N	5	2025-04-07	NaN	NaN	NaN	379 1305546	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.170478	f	f	\N	\N	[]	0	active	\N	pending	\N
1664893	\N	COSTENARO ASSICURAZIONI S.R.L.	3496260245.0	03496260245	VIA S. PIO X, 58/2	CASSOLA	36022.0	VI	Veneto	Italia	\N	20	2025-04-07	NaN	www.costenaroassicurazioni.it	NaN	0424-382586	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.173332	f	f	\N	\N	[]	0	active	\N	pending	\N
1664896	\N	ZANINI BASSANO S.R.L.	1302360456.0	01302360456	VIA APRILIA, 2	MASSA	54100.0	MS	Toscana	Italia	\N	10	2025-04-07	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.176919	f	f	\N	\N	[]	0	active	\N	pending	\N
1664906	\N	MG SERVIZI S.R.L.	1739950333.0	01739950333	VIA TRIESTE, 25	CADEO	29010.0	PC	Emilia-romagna	Italia	\N	5	2025-04-07	NaN	NaN	NaN	0523-502091	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.180274	f	f	\N	\N	[]	0	active	\N	pending	\N
1664915	\N	CEGS	1614350336.0	01614350336	VIA EMILIA, 190	CADEO	29010.0	PC	Emilia-romagna	Italia	\N	181	2025-04-07	NaN	NaN	NaN	0523-502091	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.183849	f	f	\N	\N	[]	0	active	\N	pending	\N
1665066	\N	FREDIANI MARCO	1262260456.0	FRDMRC85E06F023S	Via Bigioni, 53/bis	Marina di Carrara	54033.0	MS	Toscana	Italia	\N	0	2025-04-08	NaN	NaN	marco.frediani@consulentidellavoropec.it	0585 787813	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.18839	f	f	\N	\N	[]	0	active	\N	pending	\N
1665134	\N	A.S.P. TECNOLOGIE S.R.L.	3586930285.0	03586930285	VIA PADRE NICOLINI, 29	CITTADELLA	35013.0	PD	Veneto	Italia	\N	21	2025-04-08	NaN	www.noveaudiovideo.it	NaN	049.9400779	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.192513	f	f	\N	\N	[]	0	active	\N	pending	\N
1665138	\N	SCHNEIDER RAFFAELE	1035520301.0	SCHRFL61B14L050M	STRADA STATALE 13 PONTEBBANA KM, 144 + 68	TARCENTO	33017.0	UD	Friuli-venezia giulia	Italia	\N	14	2025-04-08	NaN	www.entrate.it	NaN	0432-794213	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.194869	f	f	\N	\N	[]	0	active	\N	pending	\N
1665144	\N	PANIFICIO E PASTICCERIA MARCHETTI ITALO S.A.S. DI MARCHETTI ILARI A & C.	2366510465.0	02366510465	VIA EMILIA NORD, 1799	MASSAROSA	55040.0	LU	Toscana	Italia	\N	8	2025-04-08	NaN	www.marchettiitalo.it	NaN	0584-92165	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.197048	f	f	\N	\N	[]	0	active	\N	pending	\N
1665162	\N	IL GRATICOLATO SOCIETA' COOPERATIVA SOCIALE	2191560289.0	02191560289	VIA BUSON, 7	SAN GIORGIO DELLE PERTICHE	35010.0	PD	Veneto	Italia	\N	139	2025-04-08	NaN	www.ilgraticolato.com	NaN	0495747491	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.199125	f	f	\N	\N	[]	0	active	\N	pending	\N
1665163	\N	CODIAL S.R.L.	1730160908.0	01730160908	ZONA INDUSTRIALE PREDDA NIEDDA STRADA, 32	SASSARI	7100.0	SS	Sardegna	Italia	\N	12	2025-04-08	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.201247	f	f	\N	\N	[]	0	active	\N	pending	\N
1665168	\N	QUICK SERVICE S.R.L.	3786550248.0	03786550248	VIA RIVIERA CA' SETTE, 85	BASSANO DEL GRAPPA	36061.0	VI	Veneto	Italia	\N	45	2025-04-08	NaN	www.quickservicetrasporti.it	NaN	0424.592243	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.203576	f	f	\N	\N	[]	0	active	\N	pending	\N
1665181	\N	INLINEA S.R.L.	1569160508.0	01569160508	VIA ANNIBALE EVARISTO BRECCIA, 20	PISA	56121.0	PI	Toscana	Italia	\N	9	2025-04-08	NaN	www.inlineasrl.it	NaN	0508061310	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.205716	f	f	\N	\N	[]	0	active	\N	pending	\N
1665208	\N	ERREBI AMBIENTE S.R.L.	3212920247.0	03212920247	VIA ADIGE, 40	MONTICELLO CONTE OTTO	36010.0	VI	Veneto	Italia	\N	3	2025-04-08	Errebi Ambiente si occupa di seguire il cliente in ogni fase del progetto, partendo dall′analisi e della consulenza per la progettazione di impianti di produzione di energia, per arrivare all′installazione degli impianti stessi, fornendo supporto nella gestione delle pratiche autorizzative necessarie. Inoltre si occupa della fornitura ed installazione di nuovi impianti fotovoltaici e di climatizzazione, con ausilio di pompe di calore.	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.208708	f	f	\N	\N	[]	0	active	\N	pending	\N
1665255	\N	PR SERVIZI S.A.S. DI ROBERTO RE	2553250305.0	02553250305	CORTE TENENTE LORENZO BROSADOLA, 13	CIVIDALE DEL FRIULI	33043.0	UD	Friuli-venezia giulia	Italia	\N	4	2025-04-09	NaN	NaN	NaN	0432701529	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.211582	f	f	\N	\N	[]	0	active	\N	pending	\N
1665260	\N	OFFICINA DEL CARRELLO DI VIDONI GIUSEPPE SRL	1872940307.0	01872940307	VIA SLOVENIA, 2	UDINE	33100.0	UD	Friuli-venezia giulia	Italia	\N	71	2025-04-09	NaN	www.officinadelcarrello.it/	NaN	0432-600471	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.214461	f	f	\N	\N	[]	0	active	\N	pending	\N
1665263	\N	CHIMICA ECOLOGICA S.P.A.	1888870241.0	01888870241	VIA DELL'ARTIGIANATO, 13	VILLAVERLA	36030.0	VI	Veneto	Italia	\N	21	2025-04-09	NaN	NaN	NaN	0445-350252	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.217242	f	f	\N	\N	[]	0	active	\N	pending	\N
1665271	\N	NUOVA SABI SRL	3356200240.0	03356200240	VIA CA' BRUSA', 42	MAROSTICA	36063.0	VI	Veneto	Italia	\N	15	2025-04-09	NaN	www.sabi.it	NaN	0424-75222	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.220511	f	f	\N	\N	[]	0	active	\N	pending	\N
1665282	\N	RENOVA SRL	2674950460.0	02674950460	VIA SARZANESE, 17	PIETRASANTA	55045.0	LU	Toscana	Italia	\N	3	2025-04-09	Autocarrozzeria, autofficina meccanica, gommista ed elettrauto.\nNoleggio e vendita autovetture nuove ed usate.\nSoccorso stradale.\n# Sabrina	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.223352	f	f	\N	\N	[]	0	active	\N	pending	\N
1665315	\N	FAN srl	2614470223.0	NaN	Via Stella di Man, 45	Trento	38121.0	Trento	Trentino-Alto Adige/Südtirol	Italia	\N	0	2025-04-09	NaN	NaN	info@tentazionitrento.it	348.7191037	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.226345	f	f	\N	\N	[]	0	active	\N	pending	\N
1893808	\N	CAPPELLETTI MATTEO	CPPMTT75H28I726O	\N		\N	\N	\N	\N	IT		\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-18 20:18:49.361476	f	f	\N	\N	[]	0	active	\N	pending	\N
1665322	\N	FROST ITALY S.R.L.	2712010244.0	02712010244	VIA LAGO TRASIMENO, 46	SCHIO	36015.0	VI	Veneto	Italia	\N	20	2025-04-09	NaN	www.frostitaly.it	NaN	0445576772	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.229124	f	f	\N	\N	[]	0	active	\N	pending	\N
1665333	\N	SIEL SISTEMI ELETTRONICI S.R.L.	4370690242.0	04370690242	VIA ANTONIO MEUCCI, 13	ARCUGNANO	36057.0	VI	Veneto	Italia	\N	9	2025-04-09	NaN	NaN	NaN	339.7160758	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.232503	f	f	\N	\N	[]	0	active	\N	pending	\N
1665335	\N	MEKTRONIC S.R.L.	4211700242.0	04211700242	VIA MONTE CENGIO, 25	CORNEDO VICENTINO	36073.0	VI	Veneto	Italia	\N	6	2025-04-09	NaN	www.mektronic.it	NaN	0445-1810763	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.235881	f	f	\N	\N	[]	0	active	\N	pending	\N
1665338	\N	RISTORANTE ALBERGO IL BERSAGLIERE DI SERI ALESSIO & C. S.A.S.	715960522.0	00715960522	VIA ROMA, 10	ASCIANO	53041.0	SI	Toscana	Italia	\N	5	2025-04-09	NaN	www.hotellapace.net	NaN	0577710028	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.238919	f	f	\N	\N	[]	0	active	\N	pending	\N
1665342	\N	BRUNNEN INDUSTRIE S.R.L.	3788320244.0	03788320244	VIA MEUCCI, 18	BRENDOLA	36040.0	VI	Veneto	Italia	\N	10	2025-04-09	NaN	www.brunnenindustrie.com	NaN	0444-400248	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.241725	f	f	\N	\N	[]	0	active	\N	pending	\N
1665344	\N	TH.E S.R.L.	3450281203.0	03450281203	VIA SAN MARCO, 86	LUCCA	55100.0	LU	Toscana	Italia	\N	14	2025-04-09	NaN	www.the-engineering.com	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.244993	f	f	\N	\N	[]	0	active	\N	pending	\N
1665347	\N	TENUTA MARIANI	2259360465.0	NaN	Via Crocicchio, 519	Bozzano	55064.0	LU	Toscana	Italia	\N	0	2025-04-09	NaN	NaN	agriturismotenutamariani@pec.it	NaN	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.248525	f	f	\N	\N	[]	0	active	\N	pending	\N
1665349	\N	BERGAMIN S.R.L.	120040241.0	00120040241	VIA SAN SISTO, 31	SANDRIGO	36066.0	VI	Veneto	Italia	\N	81	2025-04-09	NaN	NaN	NaN	0444.659201	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.25185	f	f	\N	\N	[]	0	active	\N	pending	\N
1665351	\N	MOOD'S CLINIC SRL	10389470963.0	10389470963	VIA ANGELO BISI, 34	MILANO	20152.0	MI	Lombardia	Italia	\N	3	2025-04-09	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.25541	f	f	\N	\N	[]	0	active	\N	pending	\N
1665370	\N	Clique Srl	NaN	NaN	NaN	Trento	38121.0	Trento	Trentino-Alto Adige/Südtirol	Italia	\N	0	2025-04-09	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.258958	f	f	\N	\N	[]	0	active	\N	pending	\N
1668376	\N	DOLOMATIC S.r.l.	596840223.0	NaN	Via Segantini, 1	Lavis	38015.0	Trento	Trentino-Alto Adige/Südtirol	Italia	\N	0	2025-04-09	NaN	NaN	NaN	0461.246476	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.262233	f	f	\N	\N	[]	0	active	\N	pending	\N
1668378	\N	IGO DISTRIBUTION S.r.l.	1866880220.0	NaN	via Innsbruck, 24	Trento	38121.0	Trento	Trentino-Alto Adige/Südtirol	Italia	\N	0	2025-04-09	I.GO DISTRIBUTION importa da tutto il mondo e distribuisce articoli per bambini e articoli sportivi.\n\nNel 20/21/22 aveva 8 dipendenti che possono rientrare in Formazione 4.0\nIn ufficio tutti i dipendenti usano pc con software gestionali e in magazzino usano palmari.\nHa un App per gli agenti (20 in tutta Italia) ma sono a P.IVA\nGli agenti visualizzano magazzino e giacenze, raccolgono ordini e inviano in ufficio a Trento.\n\nHa ideato e progettato un sacco a pelo inpiuma per bambini e ha registrato il marchio di questo articolo.\n\nDal 2021 software gestionale LORO \n\nSconto merce e in fattura fino ad un 20%\n\nCommercialista Dott. Alessandro Dal Monego di Studio Dal Monego-Gottardi\n\nConsulente del lavoro At Work di Trento	https://igodistribution.it/	NaN	0461.233200	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.265408	f	f	\N	\N	[]	0	active	\N	pending	\N
1668399	\N	MARKET ALIMENTARE VERSILIA SRL	2223810462.0	02223810462	VIA SARZANESE, 7907	MASSAROSA	55054.0	LU	Toscana	Italia	\N	4	2025-04-10	NaN	NaN	NaN	0584998417	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.268559	f	f	\N	\N	[]	0	active	\N	pending	\N
1668406	\N	EHMILO SRL	4246770244.0	04246770244	VIA DAL PONTE, 96	TORRI DI QUARTESOLO	36040.0	VI	Veneto	Italia	\N	7	2025-04-10	NaN	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.271523	f	f	\N	\N	[]	0	active	\N	pending	\N
1668411	\N	MENINI ROMOLO NOLEGGI S.R.L.	1549060463.0	01549060463	VIA PROVINCIALE, 24	PESCAGLIA	55064.0	LU	Toscana	Italia	\N	10	2025-04-10	NaN	NaN	NaN	0583 38375	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.274235	f	f	\N	\N	[]	0	active	\N	pending	\N
1668412	\N	GASH S.P.A.	3518280247.0	03518280247	VIA DAL PONTE, 96	TORRI DI QUARTESOLO	36040.0	VI	Veneto	Italia	\N	162	2025-04-10	NaN	NaN	NaN	NaN	\N	NaN	[]	2025-07-03 20:34:36.276919	f	f	\N	\N	[]	0	active	\N	pending	\N
1668416	\N	OLEV SRL	3550750248.0	03550750248	VIA DEL PROGRESSO, 40	COLCERESA	36064.0	VI	Veneto	Italia	\N	29	2025-04-10	NaN	www.olevlight.com	NaN	0424411403	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.279583	f	f	\N	\N	[]	0	active	\N	pending	\N
1668417	\N	AURORA S.R.L.	1769810464.0	01769810464	VIA AURELIA NORD, 4	PIETRASANTA	55045.0	LU	Toscana	Italia	\N	3	2025-04-09	Commercio hardware al minuto e all' ingrosso.\nComputer discover come insegna.\n# Sabrina\nCodice Ateco: 47.41 - Commercio al dettaglio di computer, unità periferiche, software e attrezzature per ufficio in esercizi specializzati. # Luana	www.computerdiscover.com	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.28234	f	f	\N	\N	[]	0	active	\N	pending	\N
1676746	\N	LAB S.R.L.	2655250468.0	02655250468	VIA SAN MARTINO, 73	VIAREGGIO	55049.0	LU	Toscana	Italia	\N	13	2025-04-09	NaN	www.ristoranteamaro.com?utm_source=tripadvisor&utm_medium=referral	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.285526	f	f	\N	\N	[]	0	active	\N	pending	\N
1677447	\N	SIRMAN S.P.A.	270140288.0	00270140288	VIA VENEZIA, 2	CAMPO SAN MARTINO	35010.0	PD	Veneto	Italia	\N	167	2025-04-10	NaN	www.sirman.com	NaN	049.9698666	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.288422	f	f	\N	\N	[]	0	active	\N	pending	\N
1677450	\N	POLLI S.R.L.	783110257.0	00783110257	VIA ADDA, 7	FELTRE	32032.0	BL	Veneto	Italia	\N	17	2025-04-10	NaN	www.pollisrl.it	NaN	0439 302077	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.290709	f	f	\N	\N	[]	0	active	\N	pending	\N
1677453	\N	A C T I V A   S.R.L.	3578700266.0	03578700266	VIA VALLIO, 19/1	MONASTIER DI TREVISO	31050.0	TV	Veneto	Italia	\N	10	2025-04-10	NaN	www.activain.it	NaN	0422-898949	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.293303	f	f	\N	\N	[]	0	active	\N	pending	\N
1677455	\N	WEBCOOM S.R.L.	2365210448.0	02365210448	PIAZZA FELICE CAVALLOTTI, 4	ORTEZZANO	63851.0	FM	Marche	Italia	\N	7	2025-04-10	L' azienda si occupa di creare software gestionali per hotel.	www.scidoo.com	info@webcoom.com	0734 420002	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.29636	f	f	\N	\N	[]	0	active	\N	pending	\N
1677458	\N	FAIR S.R.L.	4408250282.0	04408250282	VIA ANTONIO GIOVANNI CAVINATO, 8/10	CURTAROLO	35010.0	PD	Veneto	Italia	\N	21	2025-04-10	NaN	www.fairsrlcarpenteria.com/	NaN	049-9620444	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.299467	f	f	\N	\N	[]	0	active	\N	pending	\N
1679201	\N	BARCO S.R.L.	2942180247.0	02942180247	VIA DEL LAVORO, 1	TRISSINO	36070.0	VI	Veneto	Italia	\N	27	2025-04-10	NaN	www.barcofratelli.it	NaN	0445.962207	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.302373	f	f	\N	\N	[]	0	active	\N	pending	\N
1685169	\N	FARMACIA RAVINA S.R.L.	2585470228.0	02585470228	VIA HERRSCHING, 1	TRENTO	38123.0	TN	Trentino-alto adige	Italia	\N	6	2025-04-10	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.304923	f	f	\N	\N	[]	0	active	\N	pending	\N
1685255	\N	B.S.J. MECCANICA S.R.L.	2052490238.0	02052490238	VIALE INDUSTRIA, 27	VERONELLA	37100.0	VR	Veneto	Italia	\N	22	2025-04-10	NaN	www.bsj-meccanica.it	NaN	0442480394	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.307251	f	f	\N	\N	[]	0	active	\N	pending	\N
1686473	\N	CALOR CLIMA DI PORTESAN GIUSEPPE ASSISTENZA RISCALDAMENTO	240250290.0	PRTGPP57B07H620Q	VIA LUIGI EINAUDI, 30	ROVIGO	45100.0	RO	Veneto	Italia	\N	13	2025-04-10	NaN	www.calorclima.it	NaN	0425-475404	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.309725	f	f	\N	\N	[]	0	active	\N	pending	\N
1686475	\N	INCARIM DI BONFIGLIO PAOLO GIACOMO & C. SNC	175530997.0	01029670104	VIA ALCIDE DE GASPERI, 48 C	CASARZA LIGURE	16030.0	GE	Liguria	Italia	\N	15	2025-04-10	NaN	NaN	NaN	0185 46545	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.312981	f	f	\N	\N	[]	0	active	\N	pending	\N
1713216	\N	CED SERVIZI IMPRESE S.A.S. DI UPENNINI IVANO  &  C.	1479510081.0	01479510081	VIA C. COLOMBO, 52/3	TAGGIA	18018.0	IM	Liguria	Italia	\N	3	2025-04-13	NaN	NaN	serviziced@gmail.com	0184 478121	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.405286	f	f	\N	\N	[]	0	active	\N	pending	\N
1686476	\N	T.P.A. IMPEX S.P.A.	1888190244.0	01888190244	PIAZZETTA ALBERE, 3/4	ROMANO D'EZZELINO	36060.0	VI	Veneto	Italia	\N	39	2025-04-10	L'azienda progetta e produce macchinari per la pulizia e la sanificazione degli ambienti lavorativi.#Luana	www.bigpower.net	NaN	0424832794	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.315851	f	f	\N	\N	[]	0	active	\N	pending	\N
1712767	\N	Winner Bar S.r.l.s.	2429140227.0	NaN	Via delle Orne, 7	Trento	38121.0	Trento	Trentino-Alto Adige/Südtirol	Italia	\N	0	2025-04-11	Inna è la titolare del TJ BAR\nE' Amministratrice unica senza busta paga.\nE' aperta dal 2015 a Trento.\nIl suo Commercialista è lo STUDIO DE CAMINADA di Trento che le segue anche le paghe.	NaN	inna.cioban@yahoo.it	375.6681770	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.318737	f	f	\N	\N	[]	0	active	\N	pending	\N
1712769	\N	TWINCAD S.R.L.	1346590290.0	01346590290	VIA GIACOMO MATTEOTTI, 1418/183	COSTA DI ROVIGO	45023.0	RO	Veneto	Italia	\N	18	2025-04-11	NaN	www.twincad.eu	NaN	0425.474167	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.32121	f	f	\N	\N	[]	0	active	\N	pending	\N
1712778	\N	TOSCOCELL S.R.L.	1561520477.0	01561520477	VIALE MONTALBANO, 3/B	SERRAVALLE PISTOIESE	51030.0	PT	Toscana	Italia	\N	6	2025-04-11	NaN	www.toscocell.com	NaN	0573 1941651	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.323747	f	f	\N	\N	[]	0	active	\N	pending	\N
1712781	\N	CARROZZERIA LA PERLA S.N.C. DI SALMASO STEFANO E C.	1128610290.0	01128610290	VIALE DELL'ARTIGIANATO, 31	ROVIGO	45100.0	RO	Veneto	Italia	\N	12	2025-04-11	NaN	NaN	NaN	0425-465228	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.326127	f	f	\N	\N	[]	0	active	\N	pending	\N
1712787	\N	SANTONI'S S.R.L.	2364860227.0	02364860227	VIA DEGLI ORTI, 19	TRENTO	38122.0	TN	Trentino-alto adige	Italia	\N	23	2025-04-11	Ristorante Orso Grigio	NaN	info@orso-grigio.it	0461 984400	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.328395	f	f	\N	\N	[]	0	active	\N	pending	\N
1712802	\N	CARBONI MIRIAM SRL	126659.0	01048420952	VIA THARROS 96 - 09170 - ORISTANO (OR)	Oristano	9170.0	Oristano	Sardegna	Italia	\N	0	2025-04-11	Società immobiliare (affittacamere e appartamenti)	NaN	carbonimiriam@gmail.com	3389834153	\N	Nord-Est	["Giovanni Fulgheri"]	2025-07-03 20:34:36.331211	f	f	\N	\N	[]	0	active	\N	pending	\N
1712806	\N	STUDIO MIRIAM CARBONI - S.T.P. A R.L.	1268960950.0	01268960950	VIA THARROS 96 - 09170 - ORISTANO (OR)	Oristano	9170.0	Oristano	Sardegna	Italia	\N	0	2025-04-11	Studio di Consulenza del lavoro	NaN	carbonimiriam@gmail.com	NaN	\N	Nord-Est	["Giovanni Fulgheri"]	2025-07-03 20:34:36.334465	f	f	\N	\N	[]	0	active	\N	pending	\N
1712808	\N	ISCHIETO RISTORANTE DI PIANIGIANI FIORENZO & C. S.N.C.	1124200526.0	01124200526	LOCALITA' ISCHIETO,	RAPOLANO TERME	53040.0	SI	Toscana	Italia	\N	2	2025-04-11	NaN	www.ischieto.it	NaN	0577 705025	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.338252	f	f	\N	\N	[]	0	active	\N	pending	\N
1712906	\N	F.LLI LENCIONI DI LENCIONI CESARE & C. S.N.C.	1414730463.0	01414730463	VIA PROVINCIALE, 13	CAMAIORE	55041.0	LU	Toscana	Italia	\N	8	2025-04-11	NaN	www.ristorantelemeraviglie.com	NaN	0584 951750	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.342283	f	f	\N	\N	[]	0	active	\N	pending	\N
1712912	\N	VALFUSSBETT S.R.L.	889900247.0	07855600156	VIA DELL'ARTIGIANATO, 6	VALDAGNO	36078.0	VI	Veneto	Italia	\N	64	2025-04-11	NaN	NaN	NaN	0445408888	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.346252	f	f	\N	\N	[]	0	active	\N	pending	\N
1712917	\N	LA GENTILE S.R.L.	1255070292.0	01255070292	VIA TANGENZIALE EST, 23	ROVIGO	45100.0	RO	Veneto	Italia	\N	12	2025-04-11	NaN	NaN	NaN	0425.28800	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.349037	f	f	\N	\N	[]	0	active	\N	pending	\N
1712919	\N	ELMEC S.R.L.	277490249.0	00277490249	VIA DELL'ARTIGIANATO, 34	CAMISANO VICENTINO	36043.0	VI	Veneto	Italia	\N	29	2025-04-11	NaN	www.elmec.biz	NaN	0444610746	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.351801	f	f	\N	\N	[]	0	active	\N	pending	\N
1712929	\N	RIVIERA SERVICE CENTER DI MATTEO AGROFOGLIO & C SAS	1189800087.0	01189800087	VIA VESCO, 2	SANREMO	18038.0	IM	Liguria	Italia	\N	10	2025-04-11	Installazione e manutenzione condizionatori.\n# Sabrina	NaN	NaN	0184 504233	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.354412	f	f	\N	\N	[]	0	active	\N	pending	\N
1712934	\N	INGROS'S FORNITURE S.R.L.	718830292.0	00718830292	VIA DEL MERCANTE, 42	ROVIGO	45100.0	RO	Veneto	Italia	\N	8	2025-04-11	NaN	www.ingrossforniture.it	NaN	0425-474904	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.357556	f	f	\N	\N	[]	0	active	\N	pending	\N
1712938	\N	CARPANO S.R.L.	2212680207.0	02212680207	VIA I MAGGIO, 15	MEDOLE	46046.0	MN	Lombardia	Italia	\N	11	2025-04-11	NaN	NaN	NaN	NaN	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:36.360582	f	f	\N	\N	[]	0	active	\N	pending	\N
1713074	\N	DSG AUTOMATION S.R.L.	2943490272.0	02943490272	VIA GIOVANNI XXIII, 48/3	CAMPONOGARA	30010.0	VE	Veneto	Italia	\N	11	2025-04-14	NaN	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.363786	f	f	\N	\N	[]	0	active	\N	pending	\N
1713151	\N	RO.MO.LO. SRL	2863070997.0	02863070997	VIALE BRIGATA BISAGNO, 14/24	GENOVA	16129.0	GE	Liguria	Italia	\N	0	2025-04-14	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.366777	f	f	\N	\N	[]	0	active	\N	pending	\N
1713156	\N	BI-DA SRL	1153630254.0	01153630254	VIA SANDI, 18	ALPAGO	32016.0	BL	Veneto	Italia	\N	6	2025-04-14	NaN	NaN	NaN	0437.46906	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.369783	f	f	\N	\N	[]	0	active	\N	pending	\N
1713162	\N	PIZZERIA PAPILLON SRL	5425160289.0	05425160289	VIA BORGO RUSTEGA, 65	CAMPOSAMPIERO	35012.0	PD	Veneto	Italia	\N	27	2025-04-14	NaN	NaN	NaN	0495790792	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.372351	f	f	\N	\N	[]	0	active	\N	pending	\N
1713163	\N	AL CASELLO S.A.S. DI DALLA BONA VALENTINO	2259020226.0	02259020226	VIA KLAGENFURT, 2	TRENTO	38121.0	TN	Trentino-alto adige	Italia	\N	10	2025-04-14	Codice Ateco: 56.10.11 - Ristorazione con Somministrazione (Bar Ristorante). #Luana	www.alcasello.com	NaN	0461 1919055	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.375255	f	f	\N	\N	[]	0	active	\N	pending	\N
1713165	\N	EFFEUNO S.R.L.	4216610289.0	04216610289	VIA IV NOVEMBRE, 6	LIMENA	35010.0	PD	Veneto	Italia	\N	35	2025-04-14	NaN	www.effeuno.biz	NaN	0492021090	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.377923	f	f	\N	\N	[]	0	active	\N	pending	\N
1713180	\N	FUN FACTORY DI CRIVELLARO DANIELA E C. - S.A.S.	1255790246.0	01255790246	VIA SAN GIUSEPPE, 12	PIANEZZE	36060.0	VI	Veneto	Italia	\N	10	2025-04-14	NaN	NaN	NaN	0424-476553	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.381369	f	f	\N	\N	[]	0	active	\N	pending	\N
1713181	\N	GIOVANNINI BIBITE SRL	102540523.0	00102540523	VIA ANTONIO MEUCCI, 15	CHIUSI	53043.0	SI	Toscana	Italia	\N	15	2025-04-14	NaN	www.giovanninibibite.com	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.384063	f	f	\N	\N	[]	0	active	\N	pending	\N
1713187	\N	OLSAR S.R.L.	2116280286.0	02116280286	VIA PIOVEGO, 103	SAN GIORGIO DELLE PERTICHE	35010.0	PD	Veneto	Italia	\N	35	2025-04-14	NaN	www.olsar.it	NaN	0499330159	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.387226	f	f	\N	\N	[]	0	active	\N	pending	\N
1713193	\N	BAMAX S.R.L.	600710263.0	00600710263	VIA CASTELLANA, 172	FONTE	31010.0	TV	Veneto	Italia	\N	36	2025-04-14	NaN	www.bamax.it	NaN	0423949941	\N	NaN	[]	2025-07-03 20:34:36.390283	f	f	\N	\N	[]	0	active	\N	pending	\N
1713196	\N	CONTITALIA SOCIETA' A RESPONSABILITA' LIMITATA	2959440344.0	02959440344	S.MARIA DEL TARO STR. PRIVAT, 2A/1	TORNOLO	43059.0	PR	Emilia-romagna	Italia	\N	12	2025-04-14	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.392913	f	f	\N	\N	[]	0	active	\N	pending	\N
1713199	\N	CF SERVIZI S.R.L.	8522150963.0	08522150963	CORSO MAGENTA, 56	MILANO	20123.0	MI	Lombardia	Italia	\N	4	2025-04-14	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.3955	f	f	\N	\N	[]	0	active	\N	pending	\N
1713208	\N	GATTAZZO S.R.L.	568080246.0	00568080246	VIA GIULIO NATTA, 30/32	BRENDOLA	36040.0	VI	Veneto	Italia	\N	11	2025-04-14	NaN	NaN	NaN	0444-676985	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:36.397739	f	f	\N	\N	[]	0	active	\N	pending	\N
1713213	\N	DSG ROBOTICS S.R.L.	5090010280.0	05090010280	VIA GIOVANNI XXIII, 48/4	CAMPONOGARA	30010.0	VE	Veneto	Italia	\N	11	2025-04-14	NaN	www.dsgrobotics.it	NaN	041-5158170	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.400086	f	f	\N	\N	[]	0	active	\N	pending	\N
1713215	\N	D4I SRL	5014800261.0	05014800261	PIAZZA EUROPA UNITA, 60	CASTELFRANCO VENETO	31033.0	TV	Veneto	Italia	\N	11	2025-04-14	NaN	www.d4i.it	NaN	0423-1855110	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.402648	f	f	\N	\N	[]	0	active	\N	pending	\N
1713222	\N	FARMACIA VALZOLDANA DELLA DOTT.SSA IDA TESSER	1156960252.0	TSSDIA69C66M089C	VIA ROMA, 112/114	VAL DI ZOLDO	32010.0	BL	Veneto	Italia	\N	4	2025-04-14	NaN	NaN	NaN	0437.796154	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.408036	f	f	\N	\N	[]	0	active	\N	pending	\N
1713227	\N	ENIMA SRL	1547460293.0	01547460293	VIA ALCIDE DE GASPERI, 385	FRATTA POLESINE	45025.0	RO	Veneto	Italia	\N	9	2025-04-14	NaN	NaN	NaN	0424.555187	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.410786	f	f	\N	\N	[]	0	active	\N	pending	\N
1713230	\N	HOTEL HELVETIA S.R.L. - UNIPERSONALE	1347300996.0	01347300996	PIAZZA DELLA NUNZIATA, 1	GENOVA	16124.0	GE	Liguria	Italia	\N	14	2025-04-14	NaN	www.hotelhelvetiagenova.it	NaN	010-2465468	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.413781	f	f	\N	\N	[]	0	active	\N	pending	\N
1713241	\N	PEPE NERO DI SERAFINI LUCA	1379560111.0	SRFLCU81D07E463S	VIA CALATAFIMI, 36	LA SPEZIA	19121.0	SP	Liguria	Italia	\N	15	2025-04-14	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.417047	f	f	\N	\N	[]	0	active	\N	pending	\N
1713265	\N	LA PIA CENTENARIA S.R.L.	1050220118.0	01050220118	VIA MAGENTA, 12	LA SPEZIA	19121.0	SP	Liguria	Italia	\N	32	2025-04-14	NaN	www.lapia.it	NaN	0187 620521;0187 739999	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.420028	f	f	\N	\N	[]	0	active	\N	pending	\N
1713268	\N	EDILMONTI DI FAMA' ROCCO	2102130461.0	FMARCC54P15E573L	VIA A. VOLTA, 32	VIAREGGIO	55049.0	LU	Toscana	Italia	\N	8	2025-04-14	NaN	www.edilmontiponteggi.com	NaN	0584937288	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.422701	f	f	\N	\N	[]	0	active	\N	pending	\N
1713274	\N	FININVI S.R.L.	2233180245.0	01993230240	VIA DEI COLLI, 54	BASSANO DEL GRAPPA	36061.0	VI	Veneto	Italia	\N	27	2025-04-14	NaN	www.ca-sette.it	NaN	0445860613	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.425051	f	f	\N	\N	[]	0	active	\N	pending	\N
1713277	\N	SERVIZI DELICATI SRL	3705630238.0	03705630238	VIA FRACAZZOLE, 1/D	VERONA	37100.0	VR	Veneto	Italia	\N	17	2025-04-14	NaN	NaN	NaN	045.6717587	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.427707	f	f	\N	\N	[]	0	active	\N	pending	\N
1713350	\N	NARDELLO STAMPI SRL	4275770289.0	04275770289	VIA A. VELO, 4	FONTANIVA	35014.0	PD	Veneto	Italia	\N	13	2025-04-15	NaN	www.nardellostampi.it	NaN	049-9696337	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.430342	f	f	\N	\N	[]	0	active	\N	pending	\N
1713352	\N	FAST S.P.A.	1538840982.0	01538840982	VIA GARGNA', 8	VESTONE	25078.0	BS	Lombardia	Italia	\N	81	2025-04-15	Fast (Fusioni Artistiche Soluzioni Tecniche) è un' Azienda di arredamento outdoor.	www.fastspa.com/	NaN	0365820522	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:36.433949	f	f	\N	\N	[]	0	active	\N	pending	\N
1713354	\N	SORIA COSTRUZIONI S.R.L.	6270150821.0	06270150821	VIA GIUSEPPE SUNSERI, 9	TERMINI IMERESE	90018.0	PA	Sicilia	Italia	\N	7	2025-04-15	NaN	NaN	NaN	392.8073938	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.436922	f	f	\N	\N	[]	0	active	\N	pending	\N
1713356	\N	COP ASFALTI GROUP S.R.L.	2573410350.0	02573410350	VIA L. A. MELEGARI, 29	REGGIO EMILIA	42124.0	RE	Emilia-romagna	Italia	\N	18	2025-04-15	NaN	NaN	NaN	0522533223	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.4396	f	f	\N	\N	[]	0	active	\N	pending	\N
1713365	\N	STUDIO ISCHIA S.A.S. DI BOTTURA ROSITA, FRAPPORTI MIRIAM, TESTI GIANFRANCO E C.	4285600237.0	04285600237	VIA MANZONI, 25	CASTELNUOVO DEL GARDA	37014.0	VR	Veneto	Italia	\N	10	2025-04-15	NaN	www.studioischiasas.it	NaN	0456461875	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.442764	f	f	\N	\N	[]	0	active	\N	pending	\N
1713369	\N	TESSILVENETA S.R.L.	3543430247.0	03543430247	VIA VALGADEN, 35/A	VALBRENTA	36029.0	VI	Veneto	Italia	\N	14	2025-04-15	NaN	www.tessilveneta.it	NaN	0424-92154	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.445614	f	f	\N	\N	[]	0	active	\N	pending	\N
1713373	\N	IMMOBILIARE DALLE VEDOVE S.R.L.	2415990239.0	02415990239	VIA MONTINI, 1/B	CASTELNUOVO DEL GARDA	37014.0	VR	Veneto	Italia	\N	6	2025-04-15	NaN	NaN	NaN	335.5492635	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.448407	f	f	\N	\N	[]	0	active	\N	pending	\N
1713405	\N	EURO HYGIENE S.R.L.	2722140247.0	02722140247	VIA TERMINON, 39/1	CASTEGNERO	36020.0	VI	Veneto	Italia	\N	14	2025-04-15	NaN	www.eurohygiene.it	NaN	0444-639347	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.451336	f	f	\N	\N	[]	0	active	\N	pending	\N
1713418	\N	PIZZERIA AL BACIO DI BERARDI MARIA GIANNA & C. S.N.C.	1111100119.0	01111100119	VIA AURELIA, 235	CASTELNUOVO MAGRA	19033.0	SP	Liguria	Italia	\N	2	2025-04-14	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.454009	f	f	\N	\N	[]	0	active	\N	pending	\N
1713421	\N	N.E.C. CHIUSURE S.R.L.	4442200285.0	04442200285	VIA TERGOL, 17/A	SANTA GIUSTINA IN COLLE	35010.0	PD	Veneto	Italia	\N	9	2025-04-15	NaN	www.chiusure-nec.it	NaN	049-9300123	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.456655	f	f	\N	\N	[]	0	active	\N	pending	\N
1713686	\N	TRINITY WINES & FOODS SOCIETA' A RESPONSABILITA' LIMITATA	2568830463.0	02568830463	VIA UGO FOSCOLO, 8	VIAREGGIO	55049.0	LU	Toscana	Italia	\N	8	2025-04-14	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.459345	f	f	\N	\N	[]	0	active	\N	pending	\N
1713997	\N	RISTORANTE DONATELLA	1608230460.0	NaN	Via Sarzanese Sud, 2.467	Quiesa	55054.0	LU	Toscana	Italia	\N	0	2025-04-15	NaN	NaN	NaN	0584 974547	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.462069	f	f	\N	\N	[]	0	active	\N	pending	\N
1714154	\N	AGRITURISMO LE POSCOLE AL CANTON DI CASTELLO ROSANNA, FANNI GASTONE, FANNI LORETTA, PERUZZI RENATO SOCIETA' AGRICOLA - S.S.	3313070249.0	03313070249	STRADA COMUNALE CANTON, 17	CASTELGOMBERTO	36070.0	VI	Veneto	Italia	\N	12	2025-04-15	Azienda Agricola con Ristorazione e 5 camere in affitto.	www.agriturismoleposcole.it	NaN	0445 940695	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.465155	f	f	\N	\N	[]	0	active	\N	pending	\N
1714162	\N	LOGILUSA S.A.S. DI SQUERI GABRIELE & C.	1873580995.0	01873580995	VIA PONTEVECCHIO, 36Q-36R	CARASCO	16042.0	GE	Liguria	Italia	\N	14	2025-04-15	NaN	NaN	NaN	01851761791	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.468389	f	f	\N	\N	[]	0	active	\N	pending	\N
1714184	\N	K.A.S.RAHMA S.R.L.	2436690990.0	02436690990	VIA NAZIONALE, 499	SESTRI LEVANTE	16039.0	GE	Liguria	Italia	\N	22	2025-04-14	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.471453	f	f	\N	\N	[]	0	active	\N	pending	\N
1714197	\N	SILBER S.A.S . DI MILONE MANRICO & C.	1203940992.0	01203940992	CORSO BUENOS AIRES, 75	CHIAVARI	16043.0	GE	Liguria	Italia	\N	5	2025-04-14	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.475039	f	f	\N	\N	[]	0	active	\N	pending	\N
1714199	\N	S.A.N.A. - S.R.L.	806550117.0	00806550117	VIA BOETTOLA, 24	SARZANA	19038.0	SP	Liguria	Italia	\N	43	2025-04-15	Ditta esperta nel campo dell'edilizia, impegnata da oltre 35 anni nel settore della gestione dei rifiuti, delle urbanizzazioni e dei lavori marittimi, offre un panorama di servizi dedicati alle specifiche esigenze della clientela.\n# Sabrina	NaN	NaN	0187-621382	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.478612	f	f	\N	\N	[]	0	active	\N	pending	\N
1714979	\N	ITALIANITY SRL	7189540961.0	07189540961	VIA SIMONE D'ORSENIGO, 5	MILANO	20135.0	MI	Lombardia	Italia	\N	24	2025-04-16	NaN	www.italianitycitymarket.it	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.482182	f	f	\N	\N	[]	0	active	\N	pending	\N
1714986	\N	MAGNA & SCAPPA S.R.L.	1515670113.0	01515670113	VIA SAPRI, 75	LA SPEZIA	19121.0	SP	Liguria	Italia	\N	6	2025-04-16	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.485608	f	f	\N	\N	[]	0	active	\N	pending	\N
1714991	\N	AZEROPRINT DI VOLPATO ANTONELLA	2198730240.0	VLPNNL66M62E970V	VIA LUCA DELLA ROBBI, 3/A	MAROSTICA	36063.0	VI	Veneto	Italia	\N	12	2025-04-16	NaN	NaN	NaN	0424-470859	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.489176	f	f	\N	\N	[]	0	active	\N	pending	\N
1714999	\N	GREENTEL S.R.L.	4720770280.0	04720770280	VIA FONTANEBIANCHE, 61	SANTA GIUSTINA IN COLLE	35010.0	PD	Veneto	Italia	\N	30	2025-04-16	NaN	NaN	NaN	049.5790557	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.49184	f	f	\N	\N	[]	0	active	\N	pending	\N
1715003	\N	IOZZELLI GROUP S.R.L.	5161660963.0	05161660963	VIA GALILEI GALILEO, 5	MILANO	20124.0	MI	Lombardia	Italia	\N	12	2025-04-16	NaN	www.yachtvela5terre.it	NaN	0187883253	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.494466	f	f	\N	\N	[]	0	active	\N	pending	\N
1715004	\N	MODELLERIA GRIGGIO S.R.L.	3301560284.0	03301560284	VIA SORRIVA, 42	VIGODARZERE	35010.0	PD	Veneto	Italia	\N	13	2025-04-16	NaN	www.modelleriagriggio.it	NaN	049-767240	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.497106	f	f	\N	\N	[]	0	active	\N	pending	\N
1715011	\N	PROMEGA  S.R.L.	2641760281.0	02641760281	VIA SPINETTI,, 2/B	VIGODARZERE	35010.0	PD	Veneto	Italia	\N	19	2025-04-16	NaN	NaN	NaN	049 8841045	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.499415	f	f	\N	\N	[]	0	active	\N	pending	\N
1715015	\N	ALBERGO IOLANDA SRL	195300991.0	02817880103	VIA LUISITO COSTA, 6	SANTA MARGHERITA LIGURE	16038.0	GE	Liguria	Italia	\N	14	2025-04-16	NaN	www.pastinehotels.com	NaN	0185-287512	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.502004	f	f	\N	\N	[]	0	active	\N	pending	\N
1715017	\N	ALBERGO FLORIDA S.N.C. DI NASSIVERA G. E M.	1218140307.0	01218140307	VIA DEL BOSCO, 13	LIGNANO SABBIADORO	33054.0	UD	Friuli-venezia giulia	Italia	\N	26	2025-04-16	NaN	www.hotelflorida.net	NaN	0431 70101	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.504595	f	f	\N	\N	[]	0	active	\N	pending	\N
1715029	\N	ROMITAL S.R.L.	4435460284.0	04435460284	VIA OLMO, 4	CAMPODARSEGO	35011.0	PD	Veneto	Italia	\N	34	2025-04-16	NaN	NaN	NaN	049.625023	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.507034	f	f	\N	\N	[]	0	active	\N	pending	\N
1715030	\N	IMMOBILIARE SAN GIUSEPPE SRL	1101600995.0	02817890102	VIA PRIVATA BELVEDERE, 10	SANTA MARGHERITA LIGURE	16038.0	GE	Liguria	Italia	\N	5	2025-04-16	NaN	www.hotelsantandrea.net	NaN	0185-293487	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.50962	f	f	\N	\N	[]	0	active	\N	pending	\N
1715037	\N	SCATOLIFICIO GLORIA S.R.L.	4145680247.0	04145680247	VIA CA' BENETTI, 5/6	BOLZANO VICENTINO	36050.0	VI	Veneto	Italia	\N	22	2025-04-16	NaN	www.scatolificiogloria.com	NaN	0444-595857	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.51247	f	f	\N	\N	[]	0	active	\N	pending	\N
1715077	\N	UNIONFLOR S.R.L.	1177410089.0	01177410089	REGIONE PRATI E PESCINE,	TAGGIA	18018.0	IM	Liguria	Italia	\N	11	2025-04-17	NaN	NaN	amministrazione@unionflor.com	0184-487472	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.515397	f	f	\N	\N	[]	0	active	\N	pending	\N
1715081	\N	TECNOHABITAT IMPIANTI S.R.L.	3211310101.0	03211310101	PIAZZA ALIMONDA, 1/1	GENOVA	16129.0	GE	Liguria	Italia	\N	15	2025-04-17	NaN	www.tecnohabitat.it	NaN	010311214	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.518515	f	f	\N	\N	[]	0	active	\N	pending	\N
1715082	\N	TECNOINGROS S.A.S. DI PASTORELLO GIOVANNI E C.	1379050287.0	01379050287	VIA MAESTRI DEL LAVORO, 14	VILLA DEL CONTE	35010.0	PD	Veneto	Italia	\N	30	2025-04-17	NaN	www.tecnoingros.com	NaN	0495794800	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.521418	f	f	\N	\N	[]	0	active	\N	pending	\N
1715087	\N	CARTOLANDIA DI DALL'OLIO ENNIO & C. S.N.C.	813690252.0	00813690252	VIA FELTRE, 45	SANTA GIUSTINA	32035.0	BL	Veneto	Italia	\N	7	2025-04-17	NaN	NaN	NaN	0437.889013	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.524591	f	f	\N	\N	[]	0	active	\N	pending	\N
1715092	\N	A.R.A. SRL	60410255.0	00060410255	VIA CULIADA, 208	FELTRE	32032.0	BL	Veneto	Italia	\N	25	2025-04-17	NaN	www.emporiodellauto.net	NaN	0439-305338	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.527842	f	f	\N	\N	[]	0	active	\N	pending	\N
1715104	\N	STUDIO SCIANDRA & ASSOCIATI	2159510995.0	02159510995	CORSO DANTE, 127	CHIAVARI	16043.0	GE	Liguria	Italia	\N	0	2025-04-17	NaN	www.commercialistagenova.it	accounting@studiosciandra.com	0185302210	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.530772	f	f	\N	\N	[]	0	active	\N	pending	\N
1715107	\N	FRIGOMEC S.R.L.	608790309.0	00608790309	VIA DEGLI ARTIGIANI OVEST, 5	LIGNANO SABBIADORO	33054.0	UD	Friuli-venezia giulia	Italia	\N	16	2025-04-17	NaN	www.frigomec.it	NaN	043170018	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.533558	f	f	\N	\N	[]	0	active	\N	pending	\N
1715119	\N	HOTEL RISTORANTE GIADA DI NICOLA CUOMO & C. S.R.L.	2024670248.0	02024670248	VIA NAZIONALE, 8/10	GRUMOLO DELLE ABBADESSE	36040.0	VI	Veneto	Italia	\N	66	2025-04-17	NaN	www.hotelristorantegiada.com	NaN	0444580057	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.536248	f	f	\N	\N	[]	0	active	\N	pending	\N
1715121	\N	ANANDA SRLS	1181500958.0	01181500958	Via Mazzini 73 Oristano	Oristano	9170.0	Oristano	Sardegna	Italia	\N	0	2025-04-17	Ottica Erdas\nCodice Ateco: 47.74.0 - Commercio al dettaglio di Articoli Medicali e Ortopedici (Ottica) #Luana	NaN	otticaerdas@alice.it	NaN	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.538859	f	f	\N	\N	[]	0	active	\N	pending	\N
1715221	\N	ALL'INFERNO DI D'AVANZO GIANLUCA E ANDREA S.N.C.	1176090114.0	01176090114	VIA LORENZO COSTA, 3	LA SPEZIA	19121.0	SP	Liguria	Italia	\N	13	2025-04-17	L'Osteria All'Inferno è il ristorante più antico di La Spezia.\nNasce nel 1905, all'interno di quelle che erano le cantine di un antico palazzo dell'ottocento, in centro città.\n# Sabrina	www.osteriainferno.it	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.541732	f	f	\N	\N	[]	0	active	\N	pending	\N
1715293	\N	FARA S.R.L.	2691290346.0	02691290346	STRADA PRIVAT, 2A/1	TORNOLO	43059.0	PR	Emilia-romagna	Italia	\N	37	2025-04-17	Il Grand Hotel Torre Fara è il punto di riferimento per coloro che desiderano avere un’ ampia gamma di servizi di alto livello a Chiavari. \nDotato di un Lounge & Bistrot con terrazza vista Portofino, di una piscina privata esterna e di un ristorante, l' hotel è attrezzato per soddisfare le esigenze di ogni tipologia di ospite.\n# Sabrina	www.torrefara.com	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.544727	f	f	\N	\N	[]	0	active	\N	pending	\N
1715313	\N	ALPI MARKET SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	1269040257.0	01269040257	VIA STAZIONE, 25	CALALZO DI CADORE	32042.0	BL	Veneto	Italia	\N	5	2025-04-17	Codice Ateco: commercio al dettaglio non specializzato di altri prodotti. #Luana	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.547853	f	f	\N	\N	[]	0	active	\N	pending	\N
1715314	\N	PLAYA S.R.L.	950370304.0	00950370304	LUNGOMARE TRIESTE, 128	LIGNANO SABBIADORO	33054.0	UD	Friuli-venezia giulia	Italia	\N	20	2025-04-17	NaN	www.playa.it	NaN	0431-71071	\N	NaN	[]	2025-07-03 20:34:36.550883	f	f	\N	\N	[]	0	active	\N	pending	\N
1715316	\N	COLORIFICIO TIRRENO TRADING S.R.L.	1477650111.0	01477650111	VIA GENOVA, 128	BOLANO	19020.0	SP	Liguria	Italia	\N	8	2025-04-17	NaN	NaN	NaN	0187-717878	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.553698	f	f	\N	\N	[]	0	active	\N	pending	\N
1715320	\N	CARTA DELTA S.R.L.	1369490295.0	01369490295	VIA PO VECCHIO, 9	PORTO VIRO	45014.0	RO	Veneto	Italia	\N	7	2025-04-17	NaN	NaN	NaN	0426-632916	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.557234	f	f	\N	\N	[]	0	active	\N	pending	\N
1715331	\N	FORPEN S.R.L.	215180282.0	00215180282	VIA 3 NOVEMBRE, 50	SAONARA	35020.0	PD	Veneto	Italia	\N	83	2025-04-17	NaN	www.forpen.it	NaN	049-640468	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.560352	f	f	\N	\N	[]	0	active	\N	pending	\N
1715336	\N	A.S.T.I. SUPERMERCATI S.R.L. DI PIRINA E RASPITZU	1694390905.0	01694390905	LOCALITA' PORTO ROTONDO - VILLAGGIO,	OLBIA	7026.0	SS	Sardegna	Italia	\N	14	2025-04-17	NaN	NaN	NaN	0789-34165	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.563579	f	f	\N	\N	[]	0	active	\N	pending	\N
1715342	\N	VALENTE S.R.L.	257760280.0	00257760280	VIA LUIGI GALVANI, 2/4	CAMPODARSEGO	35011.0	PD	Veneto	Italia	\N	41	2025-04-17	NaN	www.valentepali.com	NaN	049-5565855	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.566483	f	f	\N	\N	[]	0	active	\N	pending	\N
1715354	\N	ZINECO ARENA S.R.L.	4349330243.0	04349330243	VIA DEL PROGRESSO, 50	CASTELGOMBERTO	36070.0	VI	Veneto	Italia	\N	8	2025-04-17	NaN	NaN	NaN	331.7502900	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.569448	f	f	\N	\N	[]	0	active	\N	pending	\N
1715357	\N	H	NaN	NaN	NaN	NaN	\N	NaN	NaN	NaN	\N	0	2025-04-17	NaN	NaN	NaN	NaN	\N	NaN	[]	2025-07-03 20:34:36.571791	f	f	\N	\N	[]	0	active	\N	pending	\N
1715362	\N	STUDIO RIVELLI CONSULTING - S.R.L.	8087011006.0	08087011006	VIA PASQUALE GIUSEPPE ANTONIO, 40	ROMA	156.0	RM	Lazio	Italia	\N	13	2025-04-17	NaN	www.studiorivelli.it	NaN	0688643998	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.574014	f	f	\N	\N	[]	0	active	\N	pending	\N
1715657	\N	AZIENDA AGRICOLA DALLE RIVE S.S. SOCIETA' AGRICOLA	1330670249.0	01330670249	VIA VIVARO, 35	ZUGLIANO	36030.0	VI	Veneto	Italia	\N	4	2025-04-17	NaN	www.dallerive.it	NaN	0445330100	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.576671	f	f	\N	\N	[]	0	active	\N	pending	\N
1715666	\N	NICO S.A.S. DI  DONADEL PENNY E C.	4216490237.0	04216490237	VIALE DEI COLLI, 43	VERONA	37128.0	VR	Veneto	Italia	\N	14	2025-04-17	NaN	www.ristorantelacanonicaverona.it	NaN	045532666	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.579125	f	f	\N	\N	[]	0	active	\N	pending	\N
1715668	\N	NUOVADATA GRAFIX WIDE S.R.L.	3370940482.0	03370940482	VIA PIAN DELL'ISOLA, 53	RIGNANO SULL'ARNO	50067.0	FI	Toscana	Italia	\N	18	2025-04-17	NaN	www.ngwgroup.it	NaN	0558391325	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.581305	f	f	\N	\N	[]	0	active	\N	pending	\N
1715672	\N	ELETTRODELTA S.A.S. DI PENAZZATO MATTEO & C.	2429990274.0	02429990274	VIA GARIBALDI, 50/G	VIGONZA	35010.0	PD	Veneto	Italia	\N	7	2025-04-17	NaN	www.elettrodeltaimpianti.it	NaN	0499800399	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.583786	f	f	\N	\N	[]	0	active	\N	pending	\N
1715678	\N	AUTO MAGGIOLO S.R.L.	4315420283.0	04315420283	VIA ROMA, 87	CURTAROLO	35010.0	PD	Veneto	Italia	\N	10	2025-04-17	NaN	www.automaggiolo.it	NaN	049-557463	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.5865	f	f	\N	\N	[]	0	active	\N	pending	\N
1715682	\N	FUNSEVEN BIKES S.R.L.	2037400062.0	02037400062	VIA SAN FRANCESCO, 350	TAGGIA	18018.0	IM	Liguria	Italia	\N	1	2025-04-17	NaN	www.funseven.com	NaN	0184484242	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.58957	f	f	\N	\N	[]	0	active	\N	pending	\N
1715686	\N	DIQUIGIOVANNI TERMOIMPIANTI IL BAGNO S.R.L.	2363170248.0	02363170248	VIA MONTE VERLALDO, 30	CORNEDO VICENTINO	36073.0	VI	Veneto	Italia	\N	8	2025-04-17	NaN	www.ilbagno.net	NaN	0445-459322	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.5923	f	f	\N	\N	[]	0	active	\N	pending	\N
1715707	\N	FUNSEVEN TECNOLOGY SRL	1733150088.0	01733150088	VIA COLOMBO, 125	TAGGIA	18018.0	IM	Liguria	Italia	\N	8	2025-04-17	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.595399	f	f	\N	\N	[]	0	active	\N	pending	\N
1715712	\N	FABBRICA 5 S.R.L.	4491220283.0	04491220283	VIA PENGHE, 26	SELVAZZANO DENTRO	35030.0	PD	Veneto	Italia	\N	14	2025-04-17	NaN	www.fabbrica5.it	NaN	049-8976659	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.59861	f	f	\N	\N	[]	0	active	\N	pending	\N
1715717	\N	BOCCHI SUPERMERCATI S.N.C. DI BOCCHI PAOLA MASSIMO E FRANCESCO	42910281.0	00042910281	VIA ROMA, 38	CARMIGNANO DI BRENTA	35010.0	PD	Veneto	Italia	\N	15	2025-04-17	NaN	NaN	NaN	049-9430560	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.601976	f	f	\N	\N	[]	0	active	\N	pending	\N
1715771	\N	BLU INNOVATION MEDIA S.R.L.	1884850478.0	01884850478	VIA MARIOTTI, 190	PISTOIA	51100.0	PT	Toscana	Italia	\N	4	2025-04-18	NaN	www.eccellenzeintoscana.it	info@bluinnovationmedia.it	05739761970	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.604999	f	f	\N	\N	[]	0	active	\N	pending	\N
1716026	\N	AD LA FALEGNAMERIA S.R.L.	1378400459.0	01378400459	VIA GUIDO ROSSA,	AULLA	54011.0	MS	Toscana	Italia	\N	5	2025-04-18	NaN	NaN	adlafalegnameria@libero.it	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.608206	f	f	\N	\N	[]	0	active	\N	pending	\N
1716043	\N	1 BYTE S.R.L.	10132420968.0	10132420968	VIA CAMILLO FINOCCHIARO APRILE, 5	MILANO	20124.0	MI	Lombardia	Italia	\N	4	2025-04-17	1 Byte è un System Integrator leader nell’offerta di soluzioni informatiche e gestionali per le PMI. Azienda leader e all’avanguardia nel settore informatico.	www.1byte.it	NaN	0280889312	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.611484	f	f	\N	\N	[]	0	active	\N	pending	\N
1716049	\N	ZONAPRESTITI S.R.L.	1891400507.0	01891400507	VIA TOSCOROMAGNOLA, 177	PONTEDERA	56025.0	PI	Toscana	Italia	\N	47	2025-04-17	NaN	NaN	NaN	058758200	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.613974	f	f	\N	\N	[]	0	active	\N	pending	\N
1716061	\N	M.G.M. DI MOLARO MICHELE	4134410275.0	MLRMHL70B12Z614U	VIA BISSOLATI, 6	VENEZIA	30172.0	VE	Veneto	Italia	\N	1	2025-04-18	NaN	NaN	NaN	041-8220659	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.616366	f	f	\N	\N	[]	0	active	\N	pending	\N
1716067	\N	IMOIL S.R.L.	3024890737.0	03024890737	VIA G. PORZIO,	NAPOLI	80100.0	NaN	Campania	Italia	\N	40	2025-04-17	NaN	NaN	NaN	099-5315616	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.618657	f	f	\N	\N	[]	0	active	\N	pending	\N
1716068	\N	CONSORZIO STABILE PEDRON	4349510281.0	04349510281	VIA MARSARA, 4	VILLA DEL CONTE	35010.0	PD	Veneto	Italia	\N	16	2025-04-18	NaN	www.lefogliemestre.it	NaN	0499394008	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.62096	f	f	\N	\N	[]	0	active	\N	pending	\N
1716072	\N	SAND-BLAST DI VETTORATO DARIO ANTONIO	96250287.0	VTTDNT74M28B564S	VIA BOSCHI BASSI, 15	PIAZZOLA SUL BRENTA	35016.0	PD	Veneto	Italia	\N	8	2025-04-18	NaN	www.sandblastsabbiaturaveneto.it	NaN	049-5598018	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.623449	f	f	\N	\N	[]	0	active	\N	pending	\N
1716086	\N	DR. DENT SARZANA S.R.L.	1479330118.0	01479330118	VIA VARIANTE AURELIA, 100	SARZANA	19038.0	SP	Liguria	Italia	\N	7	2025-04-18	NaN	www.drdent.it	NaN	0187-914296	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.626116	f	f	\N	\N	[]	0	active	\N	pending	\N
1716088	\N	DAL BALCON S.R.L.	3952840241.0	03952840241	VIA DELLA TECNICA, 70	CAMISANO VICENTINO	36043.0	VI	Veneto	Italia	\N	12	2025-04-18	NaN	www.dalbalcon.eu	NaN	0444-1441554	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.62892	f	f	\N	\N	[]	0	active	\N	pending	\N
1716089	\N	TOMASI S.R.L.	2968140240.0	02968140240	VIA DELLA TECNICA, 108	CAMISANO VICENTINO	36043.0	VI	Veneto	Italia	\N	5	2025-04-18	NaN	NaN	NaN	0444-411381	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.631438	f	f	\N	\N	[]	0	active	\N	pending	\N
1716091	\N	MEDIA TRADE S.R.L. DENOMINAZIONE ABBREVIATA: M.TRADE S.R.L.	2603190923.0	02603190923	VIA PUCCINI, 70	CAGLIARI	9128.0	CA	Sardegna	Italia	\N	0	2025-04-18	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.63389	f	f	\N	\N	[]	0	active	\N	pending	\N
1716093	\N	ECOCLEAN ITALIA S.R.L.	2364210993.0	02364210993	VIA PARMA, 384/Q/R	CHIAVARI	16043.0	GE	Liguria	Italia	\N	54	2025-04-17	NaN	www.ecocleanitalia.com	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.636546	f	f	\N	\N	[]	0	active	\N	pending	\N
1716095	\N	TECNO GOMMA S.A.S. DI BETTARINI ENRICO & C.	1993870284.0	01993870284	VIA IV NOVEMBRE,, 18/20	LIMENA	35010.0	PD	Veneto	Italia	\N	12	2025-04-18	NaN	NaN	NaN	049-769539	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.639044	f	f	\N	\N	[]	0	active	\N	pending	\N
1716097	\N	ON CAFFE' SRL	9830290962.0	09830290962	VIA CERADINI GIULIO, 6	MILANO	20129.0	MI	Lombardia	Italia	\N	17	2025-04-17	NaN	www.oncaffe.com	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.641932	f	f	\N	\N	[]	0	active	\N	pending	\N
1716099	\N	HOTEL AURORA DI MAGI GIORGIO E C. S.N.C.	321000408.0	00321000408	VIA BRAMANTE, 2	MISANO ADRIATICO	47040.0	RN	Emilia-romagna	Italia	\N	7	2025-04-18	NaN	www.familyhotel.it	NaN	0541 615466	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.644997	f	f	\N	\N	[]	0	active	\N	pending	\N
1716104	\N	STUDIO BITONCI, MENDO & ASSOCIATI S.R.L.	2482430283.0	02482430283	VIA ANTENORE, 2	CITTADELLA	35013.0	PD	Veneto	Italia	\N	0	2025-04-18	NaN	NaN	NaN	049.9401570	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.64842	f	f	\N	\N	[]	0	active	\N	pending	\N
1716133	\N	C.R.C. CENTRO RICERCHE CLINICHE  S.R.L.	1260140502.0	01260140502	VIA BONANNO PISANO, 36	PISA	56126.0	PI	Toscana	Italia	\N	20	2025-04-18	NaN	www.centroricercheclinichepisa.com	NaN	050-503020	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.651882	f	f	\N	\N	[]	0	active	\N	pending	\N
1716134	\N	FO.G. SRL	1327310460.0	01327310460	VIA DELLA FORMICA, 805	LUCCA	55100.0	LU	Toscana	Italia	\N	45	2025-04-19	NaN	www.foglucca.com	NaN	0583 419545	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.65558	f	f	\N	\N	[]	0	active	\N	pending	\N
1716135	\N	KREDICI S.R.L.	2178850976.0	02178850976	VIA RIMINI, 7	PRATO	59100.0	PO	Toscana	Italia	\N	15	2025-04-19	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.65823	f	f	\N	\N	[]	0	active	\N	pending	\N
1716137	\N	KING BREAK S.A.S. DI C. FRONTORI	11425551006.0	11425551006	PIAZZALE CADUTI DELLA MONTAGNOLA, 53/54	ROMA	142.0	RM	Lazio	Italia	\N	3	2025-04-19	NaN	www.ilovecaffe.com	NaN	0689829307	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.66067	f	f	\N	\N	[]	0	active	\N	pending	\N
1716139	\N	WILD FOOD S.R.L.	6127490966.0	06127490966	PIAZZA PAPA GIOVANNI XXIII, 5	MEDIGLIA	20076.0	MI	Lombardia	Italia	\N	6	2025-04-18	NaN	NaN	NaN	02 43419324	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.663118	f	f	\N	\N	[]	0	active	\N	pending	\N
1718024	\N	CARROZZERIA FRISON 2 S.R.L.	5097370281.0	05097370281	VIA CONSELVANA GUIZZ, 57/A	PADOVA	35125.0	PD	Veneto	Italia	\N	11	2025-04-22	NaN	www.carrozzeriafrison.it	NaN	049-9935009	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.6656	f	f	\N	\N	[]	0	active	\N	pending	\N
1721056	\N	LOATO S.N.C. DI MORENO E MONICA & C.	1208410298.0	01208410298	VIA TRIESTE, 497	CEREGNANO	45010.0	RO	Veneto	Italia	\N	10	2025-04-22	NaN	NaN	NaN	392.9020006	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.668512	f	f	\N	\N	[]	0	active	\N	pending	\N
1724074	\N	SUNSER S.R.L.	14431881003.0	14431881003	VIA ENZO FERRARI, 91	CIAMPINO	43.0	RM	Lazio	Italia	\N	7	2025-04-22	NaN	www.sunser.it	NaN	067231523	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.671319	f	f	\N	\N	[]	0	active	\N	pending	\N
1724082	\N	SOGIN S.R.L.	1355641000.0	05096840581	VIA DI PIAN SAVELLI, 98	ROMA	134.0	RM	Lazio	Italia	\N	11	2025-04-22	NaN	NaN	NaN	06-71300245	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.674505	f	f	\N	\N	[]	0	active	\N	pending	\N
1724091	\N	IDEA SERVIZI TECNICI SRL	15087701007.0	15087701007	VIA LEONARDO DA VINCI, 12	POMEZIA	40.0	RM	Lazio	Italia	\N	2	2025-04-22	NaN	www.studioideapomezia.it	NaN	329.6683926	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.676985	f	f	\N	\N	[]	0	active	\N	pending	\N
1724111	\N	FALEGNAMERIA ARTIGIANA STERBINI SRL	6943301009.0	06943301009	VIA GUGLIELMO MILANA,	OLEVANO ROMANO	35.0	RM	Lazio	Italia	\N	14	2025-04-22	NaN	www.falegnameriasterbini.it	NaN	069564741	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.679668	f	f	\N	\N	[]	0	active	\N	pending	\N
1724127	\N	FILIPPINI UMBERTO & C. S.N.C.	3092370232.0	03092370232	VIA CHIESA, 45	GAZZO VERONESE	37060.0	VR	Veneto	Italia	\N	10	2025-04-22	NaN	www.filippinipetshop.it	NaN	044258001	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.682424	f	f	\N	\N	[]	0	active	\N	pending	\N
1724131	\N	ACQUA EWO S.R.L.	3349160360.0	03349160360	VIA VINCENZO MONTI, 47	VIGNOLA	41058.0	MO	Emilia-romagna	Italia	\N	6	2025-04-22	NaN	NaN	NaN	349.8131354	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.686011	f	f	\N	\N	[]	0	active	\N	pending	\N
1724138	\N	CANTIERE NAVALE AGOSTINELLI S.R.L.	13154741006.0	13154741006	VIA DELLA SCAFA, 45	FIUMICINO	54.0	RM	Lazio	Italia	\N	5	2025-04-22	NaN	NaN	NaN	3289538558	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.689106	f	f	\N	\N	[]	0	active	\N	pending	\N
1724150	\N	LA CURA MEDICAL SPA S.R.L.	1640670707.0	01640670707	VIA CONTE ROSSO, 1	CAMPOBASSO	86100.0	CB	Molise	Italia	\N	4	2025-04-22	NaN	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.692225	f	f	\N	\N	[]	0	active	\N	pending	\N
1724166	\N	MY VOICE SRL	1813600663.0	01813600663	VIA DEI FORNACIAI, 20	BOLOGNA	40129.0	BO	Emilia-romagna	Italia	\N	13	2025-04-22	NaN	www.my-voice.it	NaN	0542-35245	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.695437	f	f	\N	\N	[]	0	active	\N	pending	\N
1724170	\N	LIBERA ADV S.R.L.	4541780161.0	04541780161	VIA DON MILANI, 1	PALADINA	24030.0	BG	Lombardia	Italia	\N	9	2025-04-22	NaN	www.mecotech.it	NaN	035-460936	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.698326	f	f	\N	\N	[]	0	active	\N	pending	\N
1724172	\N	TORNADO SERVIZI SRLS	3013670595.0	03013670595	VIA GUIDO D'AREZZO, 5 C	CISTERNA DI LATINA	4012.0	LT	Lazio	Italia	\N	11	2025-04-22	La Tornado offre servizi logistici e consulenziali completi in ambito di trasporto di materiale biologico, con monitoraggio della temperatura e dei materiali trasportati.	www.tornadoservizi.com	m.pozzati@tornadoservice.com;info@tornadoservizi.com	0773.1483075	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.701429	f	f	\N	\N	[]	0	active	\N	pending	\N
1724173	\N	S.C.A.R. REFRIGERAZIONE S.R.L.	2677820967.0	09956290150	VIA PER CINISELLO, 24	NOVA MILANESE	20834.0	MB	Lombardia	Italia	\N	44	2025-04-22	NaN	www.scar-refrigerazione.it	NaN	0362-49191	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.704469	f	f	\N	\N	[]	0	active	\N	pending	\N
1724202	\N	REGGIANA GOURMET S.R.L.	2592260356.0	02592260356	VIA CADUTI DEL LAVORO SORBOLO, 30	SORBOLO MEZZANI	43058.0	PR	Emilia-romagna	Italia	\N	36	2025-04-22	NaN	www.reggianagourmet.com	NaN	0522957216	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.707477	f	f	\N	\N	[]	0	active	\N	pending	\N
1724213	\N	TORREFAZIONE CAFFE' ISOLA S.R.L.	2669420990.0	02669420990	FRAZIONE ISOLA, 29	ROVEGNO	16028.0	GE	Liguria	Italia	\N	2	2025-04-22	NaN	www.caffeisola.it	caffeisola@caffeisola.it	010-955029	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.710651	f	f	\N	\N	[]	0	active	\N	pending	\N
1724216	\N	CONNEXIA SOCIETA' BENEFIT SRL	12205240158.0	12205240158	VIA DE CASTILLIA GAETANO, 23	MILANO	20124.0	MI	Lombardia	Italia	\N	121	2025-04-22	NaN	www.connexia.com	NaN	028135541	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.713772	f	f	\N	\N	[]	0	active	\N	pending	\N
1724235	\N	CENTRO STUDI SAMO S.R.L.	3259561201.0	03259561201	VIA DEL FONDITORE, 12	BOLOGNA	40138.0	BO	Emilia-romagna	Italia	\N	1	2025-04-22	NaN	www.studiosamo.it	NaN	051.268212	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.716655	f	f	\N	\N	[]	0	active	\N	pending	\N
1724236	\N	DELISCA DI FRANCESCO DI VICINO S.A.S.	2422150462.0	02422150462	VIA COPPINO, 113	VIAREGGIO	55049.0	LU	Toscana	Italia	\N	6	2025-04-21	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.719579	f	f	\N	\N	[]	0	active	\N	pending	\N
1724275	\N	TANTOSVAGO S.R.L. SOCIETA' BENEFIT	8846400961.0	08846400961	VIA VILLA MIRABELLO, 6	MILANO	20125.0	MI	Lombardia	Italia	\N	43	2025-04-22	NaN	www.svago2x1.it	NaN	3297081006	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.722489	f	f	\N	\N	[]	0	active	\N	pending	\N
1724287	\N	OCREV SOCIETA' A RESPONSABILITA' LIMITATA FORMA ABBREVIATA  OCREV S.R.L.	1206650242.0	01206650242	VIA DELL'INDUSTRIA, 28	CASTELGOMBERTO	36070.0	VI	Veneto	Italia	\N	47	2025-04-22	NaN	www.ocrev.it	NaN	0445-440396	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.725585	f	f	\N	\N	[]	0	active	\N	pending	\N
1724297	\N	EUREKA S.R.L. - SOCIETA' BENEFIT	2326350226.0	02326350226	VIA KUFSTEIN, 1	TRENTO	38121.0	TN	Trentino-alto adige	Italia	\N	63	2025-04-22	NaN	www.eurekaitalia.eu	NaN	0461.1830154	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.728404	f	f	\N	\N	[]	0	active	\N	pending	\N
1726457	\N	SUZZARA CASA S.R.L.	2161010208.0	02161010208	VIA BARACCA, 2/B	SUZZARA	46029.0	MN	Lombardia	Italia	\N	5	2025-04-22	NaN	www.immobiliarebaratti.it	NaN	0376-536868	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.731075	f	f	\N	\N	[]	0	active	\N	pending	\N
1727076	\N	GIARDINO S.R.L.	3588380174.0	03588380174	VIA S. GOTTARDO, 34	PADERNO FRANCIACORTA	25050.0	BS	Lombardia	Italia	\N	19	2025-04-22	NaN	www.ristorantegiardino.it	NaN	030-657195	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.733913	f	f	\N	\N	[]	0	active	\N	pending	\N
1727081	\N	MEDIACY S.R.L.	4080820279.0	04080820279	VIA BORSANTI, 10	JESOLO	30016.0	VE	Veneto	Italia	\N	11	2025-04-22	NaN	www.4jesoloevents.it	NaN	0421972844	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.736761	f	f	\N	\N	[]	0	active	\N	pending	\N
1727088	\N	CONAD NORD OVEST SOCIETA' COOPERATIVA	1977130473.0	01977130473	VIA BURE VECCHIA NORD, 10	PISTOIA	51100.0	PT	Toscana	Italia	\N	510	2025-04-22	NaN	NaN	NaN	05739201	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.739868	f	f	\N	\N	[]	0	active	\N	pending	\N
1727090	\N	L'ITALIANA S.R.L.	4490800234.0	04490800234	VIA SERENISSIMA, 5	OPPEANO	37050.0	VR	Veneto	Italia	\N	12	2025-04-22	NaN	www.italianasrl.it	NaN	045-6859005	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.742575	f	f	\N	\N	[]	0	active	\N	pending	\N
1727098	\N	N.T.M. S.R.L.	3432700163.0	03432700163	VIA PRADELLA,	CAPRINO BERGAMASCO	24030.0	BG	Lombardia	Italia	\N	12	2025-04-22	Produttore e assemblatore di nastri trasportatori in rete metallica.\nI loro nastri sono destinati ai mercati delle industrie alimentari, vegetali, farmaceutiche, meccaniche, del vetro, dell’imballaggio e della pastorizzazione.	NaN	NaN	0354381286	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:36.745494	f	f	\N	\N	[]	0	active	\N	pending	\N
1727100	\N	BELLIN S.P.A.	1278210248.0	01278210248	VIA CARBON, 8	ORGIANO	36040.0	VI	Veneto	Italia	\N	35	2025-04-22	codice Ateco: 28.13 - Fabbricazione di altre pompe e compressori. #Luana	www.bellinpompe.com	NaN	0444874742	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.74934	f	f	\N	\N	[]	0	active	\N	pending	\N
1727204	\N	NARDI ELETTRONICA S.R.L.	2710060233.0	02710060233	STRADA DELLA SELVA,	SAN BONIFACIO	37047.0	VR	Veneto	Italia	\N	13	2025-04-23	NaN	www.nardielettronic.com	NaN	045-7660663	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.75277	f	f	\N	\N	[]	0	active	\N	pending	\N
1727209	\N	F.B. INGROS SERVICE SRL	1864280233.0	01864280233	VIA CAPITELLO, 10/B	SONA	37060.0	VR	Veneto	Italia	\N	7	2025-04-23	NaN	www.fbingros.com	NaN	045-8680139	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.756306	f	f	\N	\N	[]	0	active	\N	pending	\N
1727211	\N	NLG SRL	2765930223.0	02765930223	VIA PIAVE, 72	TRENTO	38122.0	TN	Trentino-alto adige	Italia	\N	0	2025-04-23	NaN	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.759861	f	f	\N	\N	[]	0	active	\N	pending	\N
1729198	\N	ODPIU' S.P.A.	5873390966.0	05873390966	VIA MASSENA ANDREA, 12/7	MILANO	20145.0	MI	Lombardia	Italia	\N	104	2025-04-23	NaN	www.officedistribution.eu	NaN	0291000029	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.762705	f	f	\N	\N	[]	0	active	\N	pending	\N
1730093	\N	SPIRALFLEX S.R.L.	701251209.0	04096940376	VIA OLIVIERO SIMONI, 3/D	ANZOLA DELL'EMILIA	40011.0	BO	Emilia-romagna	Italia	\N	25	2025-04-23	NaN	www.spiralflex.net	NaN	051733822	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.765609	f	f	\N	\N	[]	0	active	\N	pending	\N
1730096	\N	QUADRIFOGLIO E C. S.R.L.	1937650230.0	01937650230	VIALE DEL LAVORO, 26	POVEGLIANO VERONESE	37064.0	VR	Veneto	Italia	\N	12	2025-04-23	NaN	www.lavanderia-quadrifoglio.it	NaN	045-7971687	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.76863	f	f	\N	\N	[]	0	active	\N	pending	\N
1744398	\N	PRONTOFOODS - S.P.A.	297190175.0	00297190175	VIA BRANZE, 44	BRESCIA	25123.0	BS	Lombardia	Italia	\N	260	2025-05-05	NaN	www.ristora.it	NaN	030 96650	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.138492	f	f	\N	\N	[]	0	active	\N	pending	\N
1730101	\N	GALLI GIULIO CESARE & C. S.N.C.	4271920375.0	04271920375	VIA EGNAZIO DANTI, 3	BOLOGNA	40133.0	BO	Emilia-romagna	Italia	\N	11	2025-04-23	NaN	www.carrozzeriagalli.it	NaN	051-6145454	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.771494	f	f	\N	\N	[]	0	active	\N	pending	\N
1730103	\N	AUTOLAVAGGIO S. MARIA DI BERETTA FRANCO & C. S.N.C.	205620990.0	03132300108	VIA SANTA MARIA,	RAPALLO	16035.0	GE	Liguria	Italia	\N	3	2025-04-22	NaN	NaN	NaN	0185 264022	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.774673	f	f	\N	\N	[]	0	active	\N	pending	\N
1730110	\N	MARMOBON S.R.L.	122980238.0	00122980238	VIA DOMENICO DA LUGO, 19	GREZZANA	37023.0	VR	Veneto	Italia	\N	12	2025-04-23	NaN	www.marmobon.it	NaN	045-8801029	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.777857	f	f	\N	\N	[]	0	active	\N	pending	\N
1731132	\N	CEFALO S.R.L.	98670706.0	00098670706	VIA DUCA D'AOSTA, 49/C	CAMPOBASSO	86100.0	CB	Molise	Italia	\N	21	2025-04-23	NaN	www.enotecacefalo.com	NaN	0874-92000	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.780843	f	f	\N	\N	[]	0	active	\N	pending	\N
1735316	\N	LOVE SUSHI SRLS	2840640904.0	02840640904	VIA FRATELLI BANDIERA, 19	OLBIA	7026.0	SS	Sardegna	Italia	\N	1	2025-04-23	In attesa di feedbach da parte del cliente ,inserisco momentaneamente l'incarico di 24 mesi sui documenti dell'azienda. #FrancescaZ	NaN	lucah@ymail.com	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.783734	f	f	\N	\N	[]	0	active	\N	pending	\N
1735746	\N	SUSHI RESTAURANT SRLS	2862610900.0	02862610900	CORSO UMBERTO I, 38	OLBIA	7026.0	SS	Sardegna	Italia	\N	13	2025-04-23	In attesa di feedbach da parte del cliente ,inserisco momentaneamente l'incarico di 24 mesi sui documenti dell'azienda. #FrancescaZ	NaN	NaN	3889570188	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.786779	f	f	\N	\N	[]	0	active	\N	pending	\N
1736554	\N	RISTORANTE DA JARI S.N.C. DI TOSELLI JARI E C.	1573001201.0	01573001201	VIA ARCHIMEDE, 32	CASTEL SAN PIETRO TERME	40024.0	BO	Emilia-romagna	Italia	\N	4	2025-04-23	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.789648	f	f	\N	\N	[]	0	active	\N	pending	\N
1738998	\N	PERAZZOLI NICOLA	3418070235.0	PRZNCL72D13E512Z	VIA MAESTRI DEL LAVORO, 8	LEGNAGO	37045.0	VR	Veneto	Italia	\N	7	2025-04-23	NaN	www.perazzolinicola.it	postacertificata@pec.perazzolinicola.it;info@perazzolinicola.it	0442625970	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.792485	f	f	\N	\N	[]	0	active	\N	pending	\N
1739836	\N	RISTORANTE PIZZERIA DA PIETRO DI GIORDANO PIETRO	2635660026.0	GRDPTR69R21G230E	VIA REPUBBLICA, 63	BIELLA	13900.0	BI	Piemonte	Italia	\N	7	2025-04-22	NaN	www.ristorantepizzeriadapietro.it?utm_source=tripadvisor&utm_medium=referral	NaN	015-0990446	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.795336	f	f	\N	\N	[]	0	active	\N	pending	\N
1739927	\N	CARROZZERIA SCELZA S.R.L.	956540173.0	00956540173	VIA FLERO, 104	BRESCIA	25125.0	BS	Lombardia	Italia	\N	9	2025-04-23	NaN	www.carrozzeriascelza.com	NaN	030-8080388	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.798363	f	f	\N	\N	[]	0	active	\N	pending	\N
1740441	\N	GANDAL HOSPITALITY SRL (FAM)	4143800987.0	04143800987	VIA TOSCANINI, 2	CALVAGESE DELLA RIVIERA	25080.0	BS	Lombardia	Italia	\N	18	2025-04-23	NaN	www.famlifestyle.it	NaN	030-9120281	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.800867	f	f	\N	\N	[]	0	active	\N	pending	\N
1740442	\N	BUSI IMPIANTI S.R.L.	1916550385.0	01916550385	CORSO GUERCINO, 64/A	CENTO	44042.0	FE	Emilia-romagna	Italia	\N	6	2025-04-23	NaN	www.daikinferrara.com	NaN	0532790749	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.803333	f	f	\N	\N	[]	0	active	\N	pending	\N
1740444	\N	FRAUFA TECH S.R.L.	3585281201.0	03585281201	VIA CARPANELLI, 24/P	ANZOLA DELL'EMILIA	40011.0	BO	Emilia-romagna	Italia	\N	9	2025-04-23	NaN	www.fraufa.it	NaN	051-733372	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.805728	f	f	\N	\N	[]	0	active	\N	pending	\N
1740447	\N	Harley Davidson FAKE	NaN	NaN	NaN	Milano	20121.0	Milano	Lombardia	Italia	\N	0	2025-04-23	NaN	NaN	s.andrello@enduser-digitla.com	02123456	\N	NaN	[]	2025-07-03 20:34:36.808511	f	f	\N	\N	[]	0	active	\N	pending	\N
1740448	\N	Royal Enfield - FAKE	NaN	NaN	NaN	Milano	20121.0	Milano	Lombardia	Italia	\N	0	2025-04-23	NaN	NaN	NaN	NaN	\N	NaN	[]	2025-07-03 20:34:36.811553	f	f	\N	\N	[]	0	active	\N	pending	\N
1740449	\N	Ducati - FAKE	NaN	NaN	NaN	Milano	20121.0	Milano	Lombardia	Italia	\N	0	2025-04-23	NaN	NaN	NaN	NaN	\N	NaN	[]	2025-07-03 20:34:36.814289	f	f	\N	\N	[]	0	active	\N	pending	\N
1740550	\N	A.R.CON DI ALEBBI RIAN	3429261203.0	LBBRNI72A12B249D	VIA FILIPPO TURATI, 27	MOLINELLA	40062.0	BO	Emilia-romagna	Italia	\N	3	2025-04-24	NaN	www.arconcimiecosostenibili.it	NaN	347 8771705	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.81741	f	f	\N	\N	[]	0	active	\N	pending	\N
1740555	\N	PREVIA ASSICURA SRL	1499840112.0	01499840112	VIA DOMENICO CHIODO, 161	LA SPEZIA	19021.0	SP	Liguria	Italia	\N	6	2025-04-24	NaN	NaN	NaN	0187.23390	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.820663	f	f	\N	\N	[]	0	active	\N	pending	\N
1740560	\N	GP SRL	4065240238.0	04065240238	CORSO MILANO, 92/A	VERONA	37100.0	VR	Veneto	Italia	\N	2	2025-04-24	Infanzia Oggi	www.infanziaoggi.it	NaN	045-573234	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.823431	f	f	\N	\N	[]	0	active	\N	pending	\N
1740562	\N	SG PLUS S.R.L.	2185691207.0	02185691207	VIA EMILIO CASA, 7/2	PARMA	43121.0	PR	Emilia-romagna	Italia	\N	5	2025-04-24	NaN	NaN	NaN	0521-531711	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.826248	f	f	\N	\N	[]	0	active	\N	pending	\N
1740569	\N	PASINI GOMME DI PASINI ALESSANDRO	2176380174.0	PSNLSN70E23D940L	VIA GAVARDINA, 5	BEDIZZOLE	25081.0	BS	Lombardia	Italia	\N	7	2025-04-24	NaN	www.pasinigommedriver.com	NaN	030-6871952	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.828958	f	f	\N	\N	[]	0	active	\N	pending	\N
1740570	\N	ENERPETROLI S.R.L.	1310440563.0	01310440563	VIA IGINO GARBINI, 101	VITERBO	1100.0	VT	Lazio	Italia	\N	32	2025-04-24	NaN	www.enerpetroli.it	NaN	07612401	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.831598	f	f	\N	\N	[]	0	active	\N	pending	\N
1740573	\N	DESIDERIA 3 DI NIGRO GIANFRANCO E C. SNC	2508300361.0	02508300361	VIA DEI MARMORARI, 54	SPILAMBERTO	41057.0	MO	Emilia-romagna	Italia	\N	18	2025-04-24	NaN	NaN	NaN	059-782833	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.834396	f	f	\N	\N	[]	0	active	\N	pending	\N
1740601	\N	ARENA GLASS DI TUGUI LIVIU & C. S.N.C.	4091140238.0	04091140238	PIAZZA SANTA TOSCANA, 78	ZEVIO	37059.0	VR	Veneto	Italia	\N	9	2025-04-24	NaN	www.arenaglass.it	NaN	045-585478	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.837885	f	f	\N	\N	[]	0	active	\N	pending	\N
1740602	\N	CASEIFICIO PINI S.R.L.	3915690238.0	03915690238	VIA GEN. C. A. DALLA CHIESA, 27	SANGUINETTO	37058.0	VR	Veneto	Italia	\N	23	2025-04-24	NaN	www.caseificiopini.com	NaN	0442-81281	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.840794	f	f	\N	\N	[]	0	active	\N	pending	\N
1740604	\N	VELKA PETROLI S.R.L.	126130566.0	00126130566	VIA IGINO GARBINI, 101	VITERBO	1100.0	VT	Lazio	Italia	\N	4	2025-04-24	NaN	NaN	NaN	0766 855547	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.843397	f	f	\N	\N	[]	0	active	\N	pending	\N
1740606	\N	FOUR STARS PETROLEUM S.R.L.	7834501004.0	07834501004	VIA SORISO, 90	ROMA	166.0	RM	Lazio	Italia	\N	12	2025-04-24	NaN	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.845622	f	f	\N	\N	[]	0	active	\N	pending	\N
1740727	\N	TEAM ITALIA S.R.L.	2704210232.0	10368360151	VIA DELL'ARTIGIANATO, 21	SOMMACAMPAGNA	37066.0	VR	Veneto	Italia	\N	23	2025-04-24	NaN	www.teamitaliailluminazione.it	NaN	045-8581640	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.848587	f	f	\N	\N	[]	0	active	\N	pending	\N
1740729	\N	ZAFFANI CAR S.R.L.	3290700230.0	03290700230	VIA PORTOGALLO, 6	VILLAFRANCA DI VERONA	37069.0	VR	Veneto	Italia	\N	26	2025-04-24	NaN	NaN	NaN	045-7900636	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.851045	f	f	\N	\N	[]	0	active	\N	pending	\N
1740783	\N	D.D.I. DI MANTOAN ANDREA & C. S.N.C.	2020001208.0	02020001208	VIA DELLE QUERCE, 2	ANZOLA DELL'EMILIA	40011.0	BO	Emilia-romagna	Italia	\N	7	2025-04-24	NaN	www.ddidisinfestazioni.com	NaN	051-6704044	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.853904	f	f	\N	\N	[]	0	active	\N	pending	\N
1740785	\N	MACCAFERRI MARIO & C. SOCIETA' A RESPONSABILITA' LIMITATA ABBREVIABILE IN MACCAFERRI MARIO & C. S.R.L.	786800367.0	00786800367	VIA PUNTA, 28	CASTELFRANCO EMILIA	41013.0	MO	Emilia-romagna	Italia	\N	14	2025-04-24	NaN	NaN	NaN	059932079	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.857094	f	f	\N	\N	[]	0	active	\N	pending	\N
1740795	\N	Applied S.r.l.	3708811207.0	NaN	Via Speranza, 35	San Lazzaro di Savena	40068.0	Bologna	Emilia-Romagna	Italia	\N	0	2025-04-24	NaN	https://www.applied.it/it	NaN	051.5880083	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.860314	f	f	\N	\N	[]	0	active	\N	pending	\N
1740796	\N	V-SHAPE STORE DI YAO ASSOUMAN JEAN MARC	3947480368.0	YAOSMN91T31Z313H	VIA CANTONE, 49	NONANTOLA	41015.0	MO	Emilia-romagna	Italia	\N	1	2025-04-24	NaN	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.862725	f	f	\N	\N	[]	0	active	\N	pending	\N
1740802	\N	MGTM Avvocati Associati	NaN	NaN	Corso della Giovecca, 3	Ferrara	44121.0	Ferrara	Emilia-Romagna	Italia	\N	0	2025-04-24	NaN	https://www.mgtm.it/	segreteria@mgtm.it	0532.203388	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.865254	f	f	\N	\N	[]	0	active	\N	pending	\N
1740817	\N	CENTRO OTTICO ARNO S.A.S. DI ALESSIA ALESSANDRI & C.	2504531209.0	02504531209	VIA ARNO, 25/25 F	BOLOGNA	40139.0	BO	Emilia-romagna	Italia	\N	2	2025-04-25	NaN	NaN	coa.arno@libero.it	051.549758	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.867711	f	f	\N	\N	[]	0	active	\N	pending	\N
1740819	\N	GRUPPO PULITA S.R.L.	2732620428.0	02732620428	VIALE DON MINZONI, 20	JESI	60035.0	AN	Marche	Italia	\N	30	2025-04-25	Kreo Brico e Casa.\n# Sabrina	www.kreobricoecasa.it	NaN	0731 214797	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.870528	f	f	\N	\N	[]	0	active	\N	pending	\N
1740849	\N	NIPE SYSTEM S.R.L.	1580870226.0	01580870226	VIA DELLA COOPERAZIONE, 133/131	TRENTO	38123.0	TN	Trentino-alto adige	Italia	\N	9	2025-04-27	NaN	www.nipe.it	NaN	0461822488	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.873069	f	f	\N	\N	[]	0	active	\N	pending	\N
1740851	\N	DI DONFRANCESCO ROBERTA	823781208.0	DDNRRT63R67B413L	VIA GUERRAZZI, 30	BOLOGNA	40125.0	BO	Emilia Romagna	Italia	\N	0	2025-04-27	NaN	NaN	dottoressaroberta1@gmail.com	0517176133	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.876392	f	f	\N	\N	[]	0	active	\N	pending	\N
1740852	\N	SINESTESIA DI D'ISA ANTONIO	1907500381.0	DSINTN85L16A785K	CORSO GUERCINO, 61	CENTO	44042.0	FE	Emilia-romagna	Italia	\N	2	2025-04-27	NaN	NaN	NaN	347.1818911	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.879689	f	f	\N	\N	[]	0	active	\N	pending	\N
1740853	\N	OTTICA GARBOLINO S.N.C. DI PAOLO GARBOLINO & C.	9405330011.0	09405330011	VIA BUNIVA, 80	PINEROLO	10064.0	TO	Piemonte	Italia	\N	4	2025-04-27	NaN	www.otticagarbolino.com	NaN	0121-330409	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.883067	f	f	\N	\N	[]	0	active	\N	pending	\N
1740854	\N	CARDAMONE VERONICA	11980120015.0	CRDVNC81R47G674C	VIA VIGONE, 77/B	PINEROLO	10064.0	TO	Piemonte	Italia	\N	2	2025-04-27	NaN	NaN	NaN	379.2796633	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.886151	f	f	\N	\N	[]	0	active	\N	pending	\N
1740855	\N	ZOSTAN S.A.S. DI ZOLIN STEFANO E C.	3742100286.0	03742100286	VIA GIACINTO ANDREA LONGHIN, 131	PADOVA	35129.0	PD	Veneto	Italia	\N	11	2025-04-27	NaN	www.zostan.it	NaN	335.6185763	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:36.889296	f	f	\N	\N	[]	0	active	\N	pending	\N
1740857	\N	EYEOO SRL (GIULIETTI E GUERRA)	3799111202.0	03799111202	VIA DE MUSEI, 4	BOLOGNA	40124.0	BO	Emilia-romagna	Italia	\N	4	2025-04-27	NaN	www.otticabergomi.it	NaN	0510320175	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.892681	f	f	\N	\N	[]	0	active	\N	pending	\N
1741029	\N	BAR SPORT DI PITZALIS GIAN LUCA	1248500918.0	PTZGLC73T07D968B	VIA ROMA, 67	GENONI	8030.0	NU	Sardegna	Italia	\N	9	2025-04-28	NaN	NaN	NaN	0782-810021	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.89611	f	f	\N	\N	[]	0	active	\N	pending	\N
1741043	\N	DI.GI. DI GIANCARLO PIRAS E DIEGO ARESTI S.N.C.	1169340955.0	01169340955	VIA PIETRO RICCIO, 22	ORISTANO	9170.0	OR	Sardegna	Italia	\N	11	2025-04-28	NaN	NaN	NaN	3471970677	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.899506	f	f	\N	\N	[]	0	active	\N	pending	\N
1741051	\N	ALTSYS IMMOBILIARE S.N.C. DI UGO MELIS & C.	2694310927.0	02694310927	VIA DEL FANGARIO, 12	CAGLIARI	9122.0	CA	Sardegna	Italia	\N	12	2025-04-28	NaN	www.altsys.it	NaN	3926724955	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.902799	f	f	\N	\N	[]	0	active	\N	pending	\N
1741054	\N	DOMINIO  SARDEGNA S.R.L.	3797160920.0	03797160920	VIA MONTGOLFIER, 41 -43	SESTU	9028.0	CA	Sardegna	Italia	\N	9	2025-04-28	NaN	NaN	NaN	3481802615	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.906313	f	f	\N	\N	[]	0	active	\N	pending	\N
1741063	\N	JAGO 19 S.R.L.	3983940929.0	03983940929	VIA GIUSEPPE PERETTI, 11	CAGLIARI	9121.0	CA	Sardegna	Italia	\N	11	2025-04-28	NaN	NaN	NaN	3481802615	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.909895	f	f	\N	\N	[]	0	active	\N	pending	\N
1741064	\N	SALEHI CONSULTING SOCIETA' A RESPONSABILITA' LIMITATA IN SIGLA  SALEHI CONSULTING S.R.L.	9444111000.0	09444111000	VIA GUIDO BANTI, 34	ROMA	191.0	RM	Lazio	Italia	\N	5	2025-04-28	NaN	www.salehiconsulting.it	NaN	06 33221223	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.913732	f	f	\N	\N	[]	0	active	\N	pending	\N
1741066	\N	QUARTU STAGIONI S.R.L.	3705430928.0	03705430928	VIA GIUDICE COSTANTINO, 7/9	CAGLIARI	9131.0	CA	Sardegna	Italia	\N	6	2025-04-28	NaN	NaN	NaN	3481802615	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.917397	f	f	\N	\N	[]	0	active	\N	pending	\N
1741074	\N	PROXIENERGY S.R.L.	1180020958.0	01180020958	VIA DEL PORTO,	ORISTANO	9170.0	OR	Sardegna	Italia	\N	12	2025-04-28	NaN	www.proxienergy.com	NaN	0783-775073	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.920639	f	f	\N	\N	[]	0	active	\N	pending	\N
1741086	\N	STE.MO S.R.L	1289741009.0	04689020586	VIA DEL MANDRIONE,, 103	ROMA	181.0	RM	Lazio	Italia	\N	6	2025-04-28	NaN	NaN	NaN	06 7850235	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.923907	f	f	\N	\N	[]	0	active	\N	pending	\N
1741384	\N	DESSI' ALESSANDRA S.R.L.	3768460929.0	03768460929	VIA CALDERA, 21	MILANO	20153.0	MI	Lombardia	Italia	\N	15	2025-04-28	NaN	NaN	NaN	070-868963	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.927314	f	f	\N	\N	[]	0	active	\N	pending	\N
1741389	\N	SEXY IN THE CITY S.R.L.	3360760924.0	03360760924	VIALE REGINA MARGHERITA, 30	CAGLIARI	9124.0	CA	Sardegna	Italia	\N	16	2025-04-28	NaN	NaN	NaN	0707519248	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.93059	f	f	\N	\N	[]	0	active	\N	pending	\N
1741395	\N	RISTORANTE ADRIANA S.N.C. DEI F.LLI BENASSINI	1172780460.0	01172780460	VIA SARZANESE SUD, 1353	MASSAROSA	55054.0	LU	Toscana	Italia	\N	13	2025-04-28	NaN	www.ristoranteadriana.net	NaN	0584.93373	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.933946	f	f	\N	\N	[]	0	active	\N	pending	\N
1741408	\N	SOCIP S.R.L.	1533610505.0	01533610505	VIA GIUSEPPE RAVIZZA, 12	PISA	56121.0	PI	Toscana	Italia	\N	9	2025-04-28	NaN	NaN	NaN	05098393435	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.937345	f	f	\N	\N	[]	0	active	\N	pending	\N
1741411	\N	STALG DI V. PALLOTTA DI ROBERTO PALLOTTA	12109671003.0	PLLRRT46P04H501F	VIA DI CERVARA, 184-186	ROMA	155.0	RM	Lazio	Italia	\N	10	2025-04-28	NaN	www.stampaggiogomma.com	NaN	06 2294435	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.940481	f	f	\N	\N	[]	0	active	\N	pending	\N
1741416	\N	PASELLO TRATTAMENTI TERMICI S.R.L.	1912481205.0	01912481205	VIA TORRETT, 39/A	CALDERARA DI RENO	40012.0	BO	Emilia-romagna	Italia	\N	12	2025-04-28	NaN	www.pasello.com	NaN	051 728778	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.944023	f	f	\N	\N	[]	0	active	\N	pending	\N
1741418	\N	LORENZO PASTICCERIA & CAFFE'DI BALDINI LORENZO	2496670460.0	BLDLNZ89A10B832D	VIA GUGLIELMO OBERDAN, 123	CAMAIORE	55041.0	LU	Toscana	Italia	\N	11	2025-04-28	NaN	www.facebook.com/lorenzopasticceriaecaffe/?utm_source=tripadvisor&utm_medium=referral	NaN	333.4635073	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.947758	f	f	\N	\N	[]	0	active	\N	pending	\N
1741420	\N	DATI AUTOMOBILI DI DATI RENZO & C. S.R.L.	455190462.0	00455190462	VIA SARZANESE, 109	CAMAIORE	55041.0	LU	Toscana	Italia	\N	17	2025-04-28	NaN	www.datiautomobili.it	NaN	0584-914439	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.950384	f	f	\N	\N	[]	0	active	\N	pending	\N
1741421	\N	FENIMPRESE	NaN	NaN	Via Massarenti, 46/M	Bologna	40121.0	BO	Emilia-Romagna	Italia	\N	0	2025-04-28	NaN	NaN	segreteriageneralebologna@fenimprese.com	051 3514009	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.952929	f	f	\N	\N	[]	0	active	\N	pending	\N
1741425	\N	BUSSINELLO S.R.L.	2486460237.0	02486460237	VIA MONTANARA, 16	COLOGNOLA AI COLLI	37030.0	VR	Veneto	Italia	\N	24	2025-04-28	NaN	www.bussinellopetroli.it	NaN	045 7650666	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.955509	f	f	\N	\N	[]	0	active	\N	pending	\N
1741430	\N	FAB ARREDAMENTI DI ZANINI BARBARA	4312940234.0	ZNNBBR70H53I775J	VIA ANTONIO PIGAFETTA, 6	SAN BONIFACIO	37047.0	VR	Veneto	Italia	\N	1	2025-04-28	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.958841	f	f	\N	\N	[]	0	active	\N	pending	\N
1741434	\N	F.G. CENTER S.R.L.	1342610993.0	01342610993	VIA GIANCARLO FARINA, 1	CASARZA LIGURE	16030.0	GE	Liguria	Italia	\N	72	2025-04-27	NaN	NaN	NaN	0185 46010	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.962227	f	f	\N	\N	[]	0	active	\N	pending	\N
1741435	\N	BAGNO E DINTORNI DI FERRO CLAUDIO LORENZO	4575990967.0	FRRCDL73P30H264I	VIA F.LLI ROSSELLI, 48	PIEVE EMANUELE	20072.0	MI	Lombardia	Italia	\N	5	2025-04-28	NaN	NaN	NaN	02-90789459	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.965842	f	f	\N	\N	[]	0	active	\N	pending	\N
1741439	\N	AUTOFFICINA GWIMAR DI SLAWOMIR GWIZDON	1122810953.0	GWZSWM76H30Z127S	VIA PRADELLA,	ARBOREA	9092.0	OR	Sardegna	Italia	\N	6	2025-04-28	NaN	www.gwimar.it	NaN	NaN	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.970152	f	f	\N	\N	[]	0	active	\N	pending	\N
1741443	\N	ANTICA FARMACIA MASSAGLI DI MARCONCINI MAURO	2006080507.0	MRCMRA80C05G702V	PIAZZA S.MICHELE, 36	LUCCA	55100.0	LU	Toscana	Italia	\N	5	2025-04-28	NaN	NaN	NaN	0583-496067	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:36.974111	f	f	\N	\N	[]	0	active	\N	pending	\N
1741445	\N	I.SA.F Line Bagno S.r.l.	NaN	NaN	Via Balzella 71/B	Forlì	47121.0	Forlì-Cesena	Emilia-Romagna	Italia	\N	0	2025-04-28	Commercio all'ingrosso di apparecchi e accessori per impianti idraulici, di riscaldamento e di condizionamento	NaN	NaN	0543.724565	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.978367	f	f	\N	\N	[]	0	active	\N	pending	\N
1741448	\N	INNOVATECH SRL	3948470269.0	03948470269	VIA INDUSTRIE, 25	TREVIGNANO	31040.0	TV	Veneto	Italia	\N	11	2025-04-28	Azienda che produce stampi ad iniezione. Sono specializzati in stampi prototipo e di serie sia monocomponente che bicomponente con tecnologia rotativa, a traslazione, a lame, a cubo e sandwich.	www.innovatechsrl.it	NaN	0423606078	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:36.980911	f	f	\N	\N	[]	0	active	\N	pending	\N
1741451	\N	PASTICCERIA REGINA S.R.L.	2385600461.0	02385600461	VIA PAPA GIOVANNI XXIII, 7	LUCCA	55100.0	LU	Toscana	Italia	\N	14	2025-04-28	NaN	www.pasticceriareginalucca.it	NaN	0583954475	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:36.98371	f	f	\N	\N	[]	0	active	\N	pending	\N
1741497	\N	12OZ COFFEE JOINT S.R.L.	10097600968.0	10097600968	VIA BORGOGNA, 3	MILANO	20122.0	MI	Lombardia	Italia	\N	144	2025-04-29	Maria Silvia incontra in data 19 ottobre 2023  alla Fiera del Franchising di Milano allo Stand 12oz insieme a Stefano Andrello una ragazza dell'Azienda e le racconta chi siamo e cosa facciamo. Ci fornisce il biglietto da visita del Dott. Fabrizio Frombola e  viene inviata mail informativa EndUser	www.12ozcj.com	NaN	02.8051680	\N	Nord-Ovest	["Maria Silvia Gentile"]	2025-07-03 20:34:36.986455	f	f	\N	\N	[]	0	active	\N	pending	\N
1741548	\N	5 EMME INFORMATICA - S.P.A.	2041541000.0	08387500583	VIA GIORGIONE, 59-63	ROMA	147.0	RM	Lazio	Italia	\N	42	2025-04-29	NaN	NaN	NaN	0654224774	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.989349	f	f	\N	\N	[]	0	active	\N	pending	\N
1741551	\N	5PM ADVISORY SRL	12889950965.0	12889950965	VIALE CA GRANDA, 2/12	MILANO	20162.0	MI	Lombardia	Italia	\N	2	2025-04-29	27/11/2023 Info contatto nota di Maria Silvia\nMi collego in wm insieme a Stefano Andrello con Marzio Gasparini.\nLui e Mario Costa sono i fondatori di 5 PM Advisory, un'Azienda che si occupa di ICT GOVERNANCE, CHANGE MANAGEMENT, ADVISORY, PROJECT MANAGEMENT, SERVICE MANAGEMENT, PROCESS ARCHITECTURE, ORGANIZATION IMPROVEMENT e QUALITY MANAGEMENT\nSi occupano anche di Formazione (sono certificati) e hanno un accordo con l'Università di Varsavia\nIn Azienda sono in 5, i Soci sono 3:\nMario Costa\nMarzio Gasparini\nAlessandro Ricci\nAnna\nRaffaella\nTutti ex colleghi di Andrello. Sono interessati a far conoscere l'incentivo ai loro clienti.\n\nMantiene i contatti Stefano Andrello.	NaN	NaN	320.3676798	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.992586	f	f	\N	\N	[]	0	active	\N	pending	\N
1741557	\N	A.C.I.S.	NaN	NaN	Viale A. Ciamarra, 259	Roma	118.0	Roma	Lazio	Italia	\N	0	2025-04-29	La Sede Legale è a Roma\nLa Sede Operativa è a Rovigo nello Studio Kapacita del Dott. A. Pattaro. Via L. Einaudi, 72. Rovigo\nInformazioni sul contatto  16/02/2023\nDavide Facco, Presidente di ACIS collabora con il Dott. Alessandro Pattaro che ce lo ha presentato in quanto l'accordo di collaborazione con EndUser Italia verrà firmato a nome dell'Associazione	NaN	presidenza@confacis.it	0425.073692	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:36.996113	f	f	\N	\N	[]	0	active	\N	pending	\N
1741559	\N	ABBREVIA S.P.A.	1978010229.0	01978010229	VIA INNSBRUCK, 23	TRENTO	38121.0	TN	Trentino-alto adige	Italia	\N	36	2025-04-29	NaN	www.abbrevia.it/	NaN	04611920490	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:36.99941	f	f	\N	\N	[]	0	active	\N	pending	\N
1741595	\N	ALL INCLUSIVE S.R.L.	1250180955.0	01250180955	VIA MARCEDDI' 32 - 09098 - TERRALBA (OR)	Terralba	9098.0	Oristano	Sardegna	Italia	\N	0	2025-04-29	Attività commerciale di servizi telefonici e fotovoltaico.\nCodice Ateco: 47.42 - commercio al dettaglio di apparecchiature per le telecomunicazioni e la telefonia in esercizi specializzati. #Luana	NaN	allinclusivesrl.terralba@gmail.com	NaN	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.002943	f	f	\N	\N	[]	0	active	\N	pending	\N
1741602	\N	ACS DATA SYSTEMS S.P.A.	701430217.0	00701430217	VIA LUIGI NEGRELLI, 6	BOLZANO	39100.0	BZ	Trentino-alto adige	Italia	\N	336	2025-04-29	18/06/2024 Info contatto\nCristian Zini organizza wm con Alessia Lorenzetti Responsabile Ricerca e Sviluppo di ACS Data System SpA di Trento. Sono un IT Service Provider\nCi colleghiamo io e Max.\nSono ovviamente in pieno target per Formazione 4.0 che non conoscono e vogliono approfondire.\nFacendo parte della Provincia Autonoma di Bolzano si interessano e  usufruiscono solo di Bandi e incentivi a loro dedicati come territorio.\nFanno parte di FondiImpresa.\n\nDipendenti totali 474 divisi su 2 P.IVA\nACS 350 dipendenti\nINFO MINDS 130 dipendenti\n\nIn INFO MINDS realizzano Software\n\n80MIL di fatturato annuo	www.acs.it	NaN	0472272727	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.00651	f	f	\N	\N	[]	0	active	\N	pending	\N
1741605	\N	ADCONTRACT S.R.L.	2042000899.0	02042000899	VIA SALVATORE MONTEFORTE, 86	SIRACUSA	96100.0	SR	Sicilia	Italia	\N	1	2025-04-29	NaN	www.adcontract.net	NaN	0931.1851157	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.009227	f	f	\N	\N	[]	0	active	\N	pending	\N
1741619	\N	ADD VALUE S.R.L.	4962890234.0	04962890234	VIA MORGAGNI, 22	VERONA	37135.0	VR	Veneto	Italia	\N	146	2025-04-29	Codice Ateco: 62.01 - Sviluppo software. #Luana	NaN	NaN	045.8282711	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.012616	f	f	\N	\N	[]	0	active	\N	pending	\N
1741640	\N	HAPPILY S.R.L. SOCIETA' BENEFIT	2329160994.0	02329160994	VIALE PREMUDA, 46	MILANO	20129.0	MI	Lombardia	Italia	\N	20	2025-04-29	NaN	www.happily-welfare.it	NaN	010 2754104	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.015917	f	f	\N	\N	[]	0	active	\N	pending	\N
1741646	\N	HEDERA S.R.L.	12909981008.0	12909981008	VICOLO DORI, 7A	ROMA	186.0	RM	Lazio	Italia	\N	19	2025-04-29	NaN	NaN	NaN	06 69378379	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.019042	f	f	\N	\N	[]	0	active	\N	pending	\N
1741649	\N	HELIUM S.R.L.	2576010223.0	02576010223	VIA PARTELI, 19	ROVERETO	38068.0	TN	Trentino-alto adige	Italia	\N	101	2025-04-29	Fiera Horeca Bolzano.\n# Sabrina	NaN	NaN	04611560049	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.022408	f	f	\N	\N	[]	0	active	\N	pending	\N
1741650	\N	H	NaN	NaN	NaN	NaN	\N	NaN	NaN	NaN	\N	0	2025-04-29	NaN	NaN	NaN	NaN	\N	NaN	[]	2025-07-03 20:34:37.025359	f	f	\N	\N	[]	0	active	\N	pending	\N
1741652	\N	HIBRO S.R.L.	15631671003.0	15631671003	VIALE JONIO, 312/314	ROMA	139.0	RM	Lazio	Italia	\N	9	2025-04-29	NaN	NaN	NaN	06 87750461	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.028367	f	f	\N	\N	[]	0	active	\N	pending	\N
1741654	\N	HERZUM S.R.L.	1656040993.0	01656040993	VIA MARCO POLO, 5	RENDE	87036.0	CS	Calabria	Italia	\N	1	2025-04-29	NaN	NaN	NaN	0984 402818	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.031561	f	f	\N	\N	[]	0	active	\N	pending	\N
1741690	\N	AGENZIA VALBORMIDA DI LAMBROIA FRANCESCO	635420094.0	LMBFNC55H20E246F	VIA TRENTO E TRIESTE, 101	MILLESIMO	17017.0	SV	Liguria	Italia	\N	13	2025-04-30	NaN	NaN	NaN	0195282640	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.035024	f	f	\N	\N	[]	0	active	\N	pending	\N
1741703	\N	AGRITURISTICA LIGNANO S.R.L.	575580303.0	00575580303	VIA SABBIADORO, 1	LIGNANO SABBIADORO	33054.0	UD	Friuli-venezia giulia	Italia	\N	316	2025-04-30	NaN	www.adrialignano.it	NaN	0433775808	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.038892	f	f	\N	\N	[]	0	active	\N	pending	\N
1744391	\N	PROSCIUTTIFICIO WOLF SAURIS S.P.A.	671670305.0	00671670305	FRAZIONE SAURIS DI SOTTO, 88	SAURIS	33020.0	UD	Friuli-venezia giulia	Italia	\N	48	2025-05-06	NaN	www.wolfsauris.com	info@wolfsauris.it	0433 86054	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.135209	f	f	\N	\N	[]	0	active	\N	pending	\N
1741706	\N	AGRUSTI & C. S.R.L.	6177420723.0	06177420723	VIA TITO SCHIPA, 9	ALBEROBELLO	70011.0	BA	Puglia	Italia	\N	40	2025-04-30	10/10/2023 L'azienda è un ingrosso con anche e-commerce di Alberobello. \nVendono la qualunque, accessori, cancelleria, giocattoli,  brico, merceria, packaging....\nSono 78/80 dipendenti fissi più i commessi a chiamata per determinati periodi (estate, Natale, Pasqua) .\nDopo alcuni incontri decidono di non andare avanti.	www.agrusti.eu/	NaN	0804320011	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.042868	f	f	\N	\N	[]	0	active	\N	pending	\N
1741722	\N	AL VECCHIO PALAZZO S.R.L.	1530950987.0	01530950987	PIAZZA PASSERINI, 5	CASTO	25070.0	BS	Lombardia	Italia	\N	7	2025-04-30	Codice Ateco: 55.1 - Servizi di Alloggio di albberghi e simili  (Albergo Pizzeria Ristorante)	www.vecchiopalazzo.it	NaN	0365-88761	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.046901	f	f	\N	\N	[]	0	active	\N	pending	\N
1741733	\N	ALA SERVICE S.R.L.	4059940371.0	04059940371	VIA GOBETTI, 27	BOLOGNA	40129.0	BO	Emilia-romagna	Italia	\N	7	2025-04-30	Grossista di contattologia e accessori per ottici.Sono 7 dipendenti\nOgnuno ha la sua postazione pc da cui lavora quotidianamente per gestire gli ordini dei clienti, l'e-commerce e quella che è la routine lavorativa.\nHanno anche un laboratorio con strumenti per la riparazione degli occhiali.\nSono in fase di acquistare un nuovo macchinario, una mola che sarà 4.0	www.alaservice.com	NaN	051-366801	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.050597	f	f	\N	\N	[]	0	active	\N	pending	\N
1741738	\N	SCHNEIDER PAOLA & C. S.A.S.	1536310301.0	01536310301	FRAZIONE LATEIS, 3	SAURIS	33020.0	UD	Friuli-venezia giulia	Italia	\N	7	2025-04-30	NaN	www.riglar.it	NaN	0433-86049	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:37.054071	f	f	\N	\N	[]	0	active	\N	pending	\N
1741747	\N	ALBRICCI NOVE S.R.L.	11308170965.0	11308170965	VIA ALBERICO ALBRICCI, 9	MILANO	20122.0	MI	Lombardia	Italia	\N	1	2025-04-30	Non è presente nessun contatto telefonico e nessuna nota che possa far risalire allo storico.	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.057653	f	f	\N	\N	[]	0	active	\N	pending	\N
1741785	\N	AMAJOR S.P.A. SOCIETA' BENEFIT	2964610212.0	02964610212	VIA NOVENTANA, 192	NOVENTA PADOVANA	35027.0	PD	Veneto	Italia	\N	11	2025-04-30	NaN	www.amajorsb.com	info@amajorsb.com	049.9700548	\N	Nord-Ovest	["Pier Luigi Menin"]	2025-07-03 20:34:37.061167	f	f	\N	\N	[]	0	active	\N	pending	\N
1742086	\N	AMMINISTRAZIONI MAJ S.R.L.	2953180300.0	02953180300	CORSO DEGLI ALISEI, 29	LIGNANO SABBIADORO	33054.0	UD	Friuli-venezia giulia	Italia	\N	2	2025-04-30	NaN	NaN	majimmobiliare@gmail.com	0431.428896	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.065107	f	f	\N	\N	[]	0	active	\N	pending	\N
1742094	\N	ANALYSIS S.R.L. - SOFTWARE E RICERCA	1687751204.0	01687751204	VIA SALVATORE QUASIMODO, 44	CASTEL MAGGIORE	40013.0	BO	Emilia-romagna	Italia	\N	28	2025-04-30	NaN	www.qualiware.it	NaN	051-705598	\N	NaN	[]	2025-07-03 20:34:37.068802	f	f	\N	\N	[]	0	active	\N	pending	\N
1742112	\N	ANTI S.R.L.	2973330232.0	02973330232	LOCALITA' CANOVE C/O GRAND'AFFI,	AFFI	37010.0	VR	Veneto	Italia	\N	77	2025-04-30	NaN	NaN	NaN	0456269415	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.072627	f	f	\N	\N	[]	0	active	\N	pending	\N
1743978	\N	M.C.S. FACCHETTI S.R.L.	1987540984.0	01987540984	LOCALITA' BREDA, 3	MURA	25070.0	BS	Lombardia	Italia	\N	33	2025-05-05	Si occupa di Progettazione Tecnica e costruzione stampi per la pressofusione di leghe di alluminio e magnesio, thixomoulding e iniezione di materiale termoplastico.	www.mcsfacchetti.it	NaN	03658908200	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:37.076449	f	f	\N	\N	[]	0	active	\N	pending	\N
1743994	\N	HOME FOOD DI CARLUCCI GIULIA	4317810242.0	CRLGLI85R62L418X	VIA SILVIO PERAZZOLO, 22	MONTEFORTE D'ALPONE	37032.0	VR	Veneto	Italia	\N	4	2025-05-05	NaN	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.079708	f	f	\N	\N	[]	0	active	\N	pending	\N
1744015	\N	ASSICURAZIONI BELTRAME LUCA & LORANDI DARIO S.N.C.	1371810381.0	01371810381	VIA BARUFFALDI, 2/D	CENTO	44042.0	FE	Emilia-romagna	Italia	\N	11	2025-05-05	NaN	NaN	NaN	051.6859612	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.082995	f	f	\N	\N	[]	0	active	\N	pending	\N
1744017	\N	TEKNET S.R.L.	2860780168.0	02860780168	VIA CESARE BATTISTI, 17	TELGATE	24060.0	BG	Lombardia	Italia	\N	10	2025-05-05	Web Agency.\n# Sabrina	www.teknet.it	info@teknet.it	035 833621	\N	NaN	["Luca Sala"]	2025-07-03 20:34:37.085962	f	f	\N	\N	[]	0	active	\N	pending	\N
1744021	\N	ASTRA RESEARCH SRL	3168570368.0	03168570368	VIA GIORGIO PERLASCA, 25	MODENA	41126.0	MO	Emilia-romagna	Italia	\N	33	2025-05-05	NaN	www.astraresearch.it	NaN	0598635084	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.089209	f	f	\N	\N	[]	0	active	\N	pending	\N
1744023	\N	M.C.G. CONSULTING SRL	2724720996.0	02724720996	VIA CINQUE MAGGIO, 81C	GENOVA	16123.0	GE	Liguria	Italia	\N	15	2025-05-05	NaN	NaN	NaN	329.8503404	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.092572	f	f	\N	\N	[]	0	active	\N	pending	\N
1744039	\N	F & F GESTIONI S.R.L.	2608210403.0	02608210403	VIA COMANDINI, 39	CATTOLICA	47841.0	RN	Emilia-romagna	Italia	\N	190	2025-05-05	Oltre all' Hotel Cristallo di Cattolica, hanno preso in gestione anche l' Hotel Catullo di Verona.\n# Sabrina	www.hotelcristallocattolica.it	NaN	366 1589596	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.095891	f	f	\N	\N	[]	0	active	\N	pending	\N
1744042	\N	ATLANTIAS SRL	1221620956.0	01221620956	LUNGOMARE E. D'ARBOREA, 6	ORISTANO	9170.0	OR	Sardegna	Italia	\N	15	2025-05-05	NaN	NaN	NaN	347.5280187	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.099901	f	f	\N	\N	[]	0	active	\N	pending	\N
1744052	\N	AUTO 180 S.P.A.	10447170969.0	10447170969	VIA MONTEFELTRO, 6	MILANO	20156.0	MI	Lombardia	Italia	\N	6	2025-05-05	NaN	www.auto180.it	NaN	349.3957661	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.103056	f	f	\N	\N	[]	0	active	\N	pending	\N
1744092	\N	MOTORICAMBI 2000 S.R.L.	939340287.0	00939340287	VIA F.S. OROLOGIO,, 8	PADOVA	35129.0	PD	Veneto	Italia	\N	12	2025-05-05	NaN	www.motoricambi2000.com	NaN	049-775700	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.105904	f	f	\N	\N	[]	0	active	\N	pending	\N
1744100	\N	PRASCO SPA	5478570012.0	05478570012	VIA VOLPIANO, 53	LEINI'	10040.0	TO	Piemonte	Italia	\N	113	2025-05-05	NaN	www.prasco.net	NaN	011 9970444	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.108535	f	f	\N	\N	[]	0	active	\N	pending	\N
1744112	\N	PREVEN S.R.L.	3720991201.0	03720991201	VIA MARIO ALICATA, 9/D	MONTE SAN PIETRO	40050.0	BO	Emilia-romagna	Italia	\N	31	2025-05-05	NaN	www.maasbologna.it	NaN	051 729362	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.111211	f	f	\N	\N	[]	0	active	\N	pending	\N
1744247	\N	GRUBERIO VITTORIO	2075940235.0	GRBVTR68C29L781P	VIA SEZANO, 28	VERONA	37034.0	VR	Veneto	Italia	\N	24	2025-05-05	NaN	NaN	NaN	045551320	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.114142	f	f	\N	\N	[]	0	active	\N	pending	\N
1744250	\N	AZ.AGR.MONTETONDO DI MAGNABOSCO GINO E MARTA E TOLO MARIA PAOLA SOCIETA' AGRICOLA	2935770236.0	02935770236	VIA SAN LORENZO, 89	SOAVE	37038.0	VR	Veneto	Italia	\N	22	2025-05-05	NaN	www.montetondo.it	NaN	045-7680347	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.117278	f	f	\N	\N	[]	0	active	\N	pending	\N
1744325	\N	2 MA - SOCIETA' A RESPONSABILITA' LIMITATA	69280527.0	00069280527	VIA MARTIRI DELLA LIBERTA', 62	ASCIANO	53041.0	SI	Toscana	Italia	\N	7	2025-05-05	NaN	www.2ma.it	NaN	0577-718370	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.120501	f	f	\N	\N	[]	0	active	\N	pending	\N
1744363	\N	IVARS S.P.A.	549960987.0	00283530178	VIA GARGNA', 23/A	VESTONE	25078.0	BS	Lombardia	Italia	\N	129	2025-05-06	Azienda specializzata nella lavorazione di materie plastiche. Azienda specializzata su 3 linee:\n- Seating: componenti per sedie, dai piedini ai poggia testa, agli schienali;\n- Accessories: accessori per mobili;\n- Building: articoli per l'edilizia.	NaN	NaN	0365878801	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:37.124325	f	f	\N	\N	[]	0	active	\N	pending	\N
1744379	\N	PUBBLICITAS S.R.L.	2034890901.0	02034890901	ZONA INDUSTRIALE PREDDA NIEDDA STRADA 18,	SASSARI	7100.0	SS	Sardegna	Italia	\N	14	2025-05-06	NaN	www.pubblicitas.it	NaN	079 234965	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.128106	f	f	\N	\N	[]	0	active	\N	pending	\N
1744384	\N	PRSE S.R.L. SOCIETA' BENEFIT	3763120163.0	03763120163	VIA FORO BOARIO, 3	BERGAMO	24121.0	BG	Lombardia	Italia	\N	17	2025-05-06	NaN	www.prse-srl.com	NaN	0363032320	\N	Nord-Ovest	["Pier Luigi Menin"]	2025-07-03 20:34:37.131651	f	f	\N	\N	[]	0	active	\N	pending	\N
1744400	\N	CARROZZERIA AUTOSERVICE RIBANI S.R.L.	1679591204.0	NaN	VIA ALDO MORO 28-30-32	San Lazzaro di Savena	40068.0	Bologna	Emilia-Romagna	Italia	\N	0	2025-05-06	NaN	https://www.autoserviceribani.it/carrozzeria/	Info@autoserviceribani.It	051 625 6301	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.141463	f	f	\N	\N	[]	0	active	\N	pending	\N
1744402	\N	PROFILGLASS S.P.A.	706270410.0	00706270410	VIA MEDA, 28	FANO	61032.0	NaN	Marche	Italia	\N	918	2025-05-05	NaN	www.profilglass.it	NaN	0721 855525	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.144911	f	f	\N	\N	[]	0	active	\N	pending	\N
1744407	\N	PROBIOS S.R.L. SOCIETA' BENEFIT	1691980484.0	03230760583	VIA DEGLI OLMI, 13-15	CALENZANO	50041.0	FI	Toscana	Italia	\N	28	2025-05-05	Conosciuto nel 2023 a Bologna in occasione della Fiera.\n# Sabrina	www.biostock.it	NaN	055 8969434	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.148654	f	f	\N	\N	[]	0	active	\N	pending	\N
1744416	\N	PROEVO SRL	4973010285.0	04973010285	VIALE DELLA NAVIGAZIONE INTERN, 119	NOVENTA PADOVANA	35027.0	PD	Veneto	Italia	\N	17	2025-05-05	NaN	NaN	segreteria@proevosrl.it	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.151641	f	f	\N	\N	[]	0	active	\N	pending	\N
1744426	\N	BAGS4DREAMS S.R.L.	4904950286.0	04904950286	VIA GARIBALDI, 44	SAN MARTINO DI LUPARI	35018.0	PD	Veneto	Italia	\N	0	2025-05-06	Bags4Dreams è un rivoluzionario sistema di comunicazione in realtà aumentata che integra, potenziandoli, i tre principali e tradizionali metodi di comunicazione: carta, web e social/tv, finalizzato a valorizzare le peculiarità della tua azienda.\n\nAdotta questo sistema per la tua comunicazione aziendale. Realizziamo per la tua azienda: shopper in carta, biglietti da visita, brochure e depliant, rollup, mappe, menù e listini. Tutto interattivo per renderti unico in innovazione, creatività, originalità e bellezza.\n\nScarica gratuitamente l'App B4D da Google Play o Apple Store e i suoi contenuti, posiziona il tuo cellulare sopra una specifica immagine su un qualsiasi supporto cartaceo chiamata “tag”: proverai l'emozione del “toccare e tenere in mano” un oggetto dal quale emerge, come per incanto, una nuova realtà che fa vedere, udire e percepire sempre nuove sensazioni e vivere fantastiche storie in un crescendo continuo di stimoli e suggestioni. \nIdeale per un approccio innovativo nel campo della comunicazione d'impresa, grazie a un sistema che da una semplice immagine su materiale cartaceo genera emozioni ed interesse a beneficio dell'utente finale, consentendogli contemporaneamente di raggiungere in tempo reale i contatti e le informazioni per trasformarlo in potenziale cliente.	NaN	NaN	049-9461639	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.155293	f	f	\N	\N	[]	0	active	\N	pending	\N
1744430	\N	ERAS - S.R.L. ( Baia Flaminia Resort)	2208370417.0	02208370417	VIALE PARIGI, 8	PESARO	61121.0	NaN	Marche	Italia	\N	60	2025-05-06	NaN	NaN	NaN	07211722600	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.158481	f	f	\N	\N	[]	0	active	\N	pending	\N
1744446	\N	CASSANELLI CATIA ( Bar gelateria su di giri)	3664911207.0	CSSCTA72L69C107Q	VIA IV NOVEMBRE, 3 B-C	ANZOLA DELL'EMILIA	40011.0	BO	Emilia-romagna	Italia	\N	5	2025-05-06	NaN	NaN	NaN	339.7855128	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.161451	f	f	\N	\N	[]	0	active	\N	pending	\N
1744451	\N	GEPAM S.R.L.	1364060523.0	01364060523	VIA LELIO E FAUSTO SOCINO, 4	SIENA	53100.0	SI	Toscana	Italia	\N	2	2025-05-06	NaN	NaN	NaN	329 274 5579	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.164465	f	f	\N	\N	[]	0	active	\N	pending	\N
1744453	\N	SALVATORE BARBER SHOP DI SICILIANO SALVATORE	3566830786.0	SCLSVT70T06A773M	VIA SAN DONATO, 211	GRANAROLO DELL'EMILIA	40057.0	BO	Emilia-romagna	Italia	\N	1	2025-05-06	NaN	NaN	info@tallisciuupilu.it	347.5921750	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.167533	f	f	\N	\N	[]	0	active	\N	pending	\N
1744458	\N	BARRACCA OFFICE S.R.L.	3785910369.0	03785910369	VIA DEI SARTI, 2/4	CASTELFRANCO EMILIA	41013.0	MO	Emilia-romagna	Italia	\N	7	2025-05-06	NaN	www.barraccaoffice.it	NaN	059-926733	\N	NaN	[]	2025-07-03 20:34:37.169992	f	f	\N	\N	[]	0	active	\N	pending	\N
1744463	\N	BBYACHT SRL	2632000903.0	02632000903	VIA RICCARDO BELLI, 2	OLBIA	7026.0	SS	Sardegna	Italia	\N	0	2025-05-06	NaN	www.bbyacht.it	NaN	0789.34214	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.172328	f	f	\N	\N	[]	0	active	\N	pending	\N
1744466	\N	B C M - ILLUMINAZIONE - S.R.L. -	1512140466.0	01512140466	VIA G. PASTORE, 2	CAMAIORE	55041.0	LU	Toscana	Italia	\N	43	2025-05-06	NaN	www.bcmilluminazione.com	NaN	0584969578	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.174828	f	f	\N	\N	[]	0	active	\N	pending	\N
1744468	\N	BDF INDUSTRIES S.P.A.	3371360243.0	03371360243	VIALE DELL'INDUSTRIA, 40	VICENZA	36100.0	VI	Veneto	Italia	\N	182	2025-05-06	NaN	www.bdfindustriesgroup.com	NaN	0444286100	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.1774	f	f	\N	\N	[]	0	active	\N	pending	\N
1744472	\N	HUKO SRL	8603550966.0	08603550966	VIA DEL CONSORZIO AGRARIO, 3/D	CHIARI	25032.0	BS	Lombardia	Italia	\N	9	2025-05-05	Incontro in data 19 ottobre 2023 alla Fiera del Franchising di Milano Rossella e Melissa.\n# Sabrina	NaN	NaN	030 7000842	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.180046	f	f	\N	\N	[]	0	active	\N	pending	\N
1744474	\N	HOTELTURIST S.P.A.	1047360910.0	01620970903	VIA FORCELLINI EGIDIO, 150	PADOVA	35128.0	PD	Veneto	Italia	\N	156	2025-05-06	NaN	www.th-resorts.com	NaN	049 8033779	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.183015	f	f	\N	\N	[]	0	active	\N	pending	\N
1744481	\N	CITY HOUSE SRL	4029631209.0	04029631209	VIA CESARE BATTISTI, 9	BOLOGNA	40123.0	BO	Emilia-romagna	Italia	\N	7	2025-05-06	Hotel Verdemilia (Gruppo Blumen).\n# Sabrina	NaN	NaN	051 0493496	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.186082	f	f	\N	\N	[]	0	active	\N	pending	\N
1744483	\N	BELLE' ANTONIO SUCC.RI S.R.L.	555480458.0	00555480458	VIA FRASSINA, 30	CARRARA	54031.0	MS	Toscana	Italia	\N	9	2025-05-06	Società che svolge l'attività di FABBRICAZIONE DI PRODOTTI IN METALLO.\n\nNon in target per Formazione 4.0\nInteressati ai fondi interprofessionali.	www.belleantonio.it	NaN	0585-857208	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.188968	f	f	\N	\N	[]	0	active	\N	pending	\N
1744488	\N	ARABA FENICE S.R.L.	2143660518.0	02143660518	VIA AMMIRAGLIO BURZAGLI, 123	MONTEVARCHI	52025.0	AR	Toscana	Italia	\N	11	2025-05-04	Hotel Fontana Verde.\n# Sabrina	www.toscanaverde.com	NaN	0575 1842530	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.19235	f	f	\N	\N	[]	0	active	\N	pending	\N
1744492	\N	ALBERGO MAYER E SPLENDID DI MAYER GIUSEPPE E C. S.A.S.	625030986.0	01424930178	PIAZZA ULISSE PAPA, 10	DESENZANO DEL GARDA	25015.0	BS	Lombardia	Italia	\N	2	2025-05-05	NaN	www.hotelristorantegiada.com	NaN	030 9142253	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.195266	f	f	\N	\N	[]	0	active	\N	pending	\N
1744493	\N	BERARDI BULLONERIE S.R.L.	628991200.0	03512270376	VIA SAN CARLO, 1	CASTEL GUELFO DI BOLOGNA	40023.0	BO	Emilia-romagna	Italia	\N	263	2025-05-06	NaN	www.gberardi.com/	NaN	051739632	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.197874	f	f	\N	\N	[]	0	active	\N	pending	\N
1744497	\N	BEST TOOL S.R.L.	3129171207.0	03129171207	VIA ALFRED BERNHARD NOBEL, 28/D	OZZANO DELL'EMILIA	40064.0	BO	Emilia-romagna	Italia	\N	34	2025-05-06	NaN	www.besttool.it	NaN	051798580	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.200386	f	f	\N	\N	[]	0	active	\N	pending	\N
1745086	\N	BETACOM SRL	8482740019.0	08482740019	VIA NICOLA FABRIZI, 44	TORINO	10143.0	TO	Piemonte	Italia	\N	496	2025-05-07	NaN	www.betacom.it	NaN	366.6180947	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.203283	f	f	\N	\N	[]	0	active	\N	pending	\N
1745089	\N	BETTINI GROUP DI SEVERINO BETTINI	1355070325.0	BTTSRN66A12L424B	FRAZIONE DUINO, 67 R4	DUINO AURISINA	34011.0	TS	Friuli-venezia giulia	Italia	\N	1	2025-05-07	NaN	NaN	bettinigroup@pec.it	329.1779292	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.205852	f	f	\N	\N	[]	0	active	\N	pending	\N
1745092	\N	BEVANDE VERONA S.R.L.	578500233.0	00578500233	VIA MONTE COMUN, 41	SAN GIOVANNI LUPATOTO	37057.0	VR	Veneto	Italia	\N	34	2025-05-07	NaN	www.bevandeverona.it	NaN	045-9251999	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.208412	f	f	\N	\N	[]	0	active	\N	pending	\N
1745101	\N	BIASIBETTI S.N.C. DI BIASIBETTI FABIO E C.	406010280.0	00406010280	VIA A.VOLTA, 6	CAMPO SAN MARTINO	35010.0	PD	Veneto	Italia	\N	2	2025-05-07	NaN	NaN	NaN	049552169	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.210767	f	f	\N	\N	[]	0	active	\N	pending	\N
1745105	\N	BIOZETA FARM DI SALVATI GIUSEPPA E C. - S.A.S.	687571208.0	04001280371	VIA ANDREA COSTA, 8	GRANAROLO DELL'EMILIA	40057.0	BO	Emilia-romagna	Italia	\N	6	2025-05-07	NaN	www.gardelcosmetici.it	NaN	051-765232	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.213231	f	f	\N	\N	[]	0	active	\N	pending	\N
1745114	\N	BLUETENSOR S.R.L.	2525420226.0	02525420226	VIA MARINO STENICO, 26	TRENTO	38121.0	TN	Trentino-alto adige	Italia	\N	9	2025-05-07	Azienda conosciuta alla Fiera Tecnologie 4.0 5.0 di Vicenza	www.bluetensor.ai	NaN	0461-522551	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.215625	f	f	\N	\N	[]	0	active	\N	pending	\N
1745117	\N	BO.RI. S.R.L.	2514970371.0	02514970371	VIA DELLA FISICA, 5	SAN LAZZARO DI SAVENA	40068.0	BO	Emilia-romagna	Italia	\N	17	2025-05-07	NaN	www.bori.it	NaN	0516250676	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.217886	f	f	\N	\N	[]	0	active	\N	pending	\N
1745123	\N	BOMA 77 S.R.L.	5423150282.0	05423150282	VIA DEL CRISTO, 378	PADOVA	35127.0	PD	Veneto	Italia	\N	9	2025-05-07	NaN	NaN	NaN	049-0991513	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.220159	f	f	\N	\N	[]	0	active	\N	pending	\N
1745171	\N	BRAVA S.R.L.	1029310313.0	01029310313	VIA ENRICO FERMI, 37	CORMONS	34071.0	GO	Friuli-venezia giulia	Italia	\N	7	2025-05-07	Laboratorio di analisi sul vino.\n7 dipendenti ( 2 p. time, 3 tempo pieno, 2 soci a busta paga )	www.bravasrl.it	NaN	0481-61788	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.222326	f	f	\N	\N	[]	0	active	\N	pending	\N
1745176	\N	I MARINAI S.R.L.S.	2610760908.0	02610760908	VIA MARINA DI PORTOROTONDO, 5	OLBIA	7026.0	SS	Sardegna	Italia	\N	3	2025-05-06	NaN	www.imarinaiportorotondo.com	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.224629	f	f	\N	\N	[]	0	active	\N	pending	\N
1745178	\N	BRESSAN VALVOLE SRL	5155550261.0	05155550261	VIALE DELLA REPUBBLICA, 96	TREVISO	31100.0	TV	Veneto	Italia	\N	1	2025-05-07	Azienda di 2 soci e nessun dipendente.	NaN	NaN	335.7299701	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.227766	f	f	\N	\N	[]	0	active	\N	pending	\N
1745183	\N	ICIT-SOFTWARE SRL	2897140212.0	02897140212	VIA MARIE CURIE, 11-13	BOLZANO	39100.0	BZ	Trentino-alto adige	Italia	\N	7	2025-05-06	Fiera Horeca a Longarone.\n# Sabrina	www.borsadelsole.com	NaN	04711955210	\N	Nord-Ovest	["Pier Luigi Menin"]	2025-07-03 20:34:37.231085	f	f	\N	\N	[]	0	active	\N	pending	\N
1745187	\N	IDNOVA S.R.L.	2032460970.0	02032460970	VIA VIRGINIO, 306	MONTESPERTOLI	50025.0	FI	Toscana	Italia	\N	6	2025-05-06	NaN	www.idnova.it	NaN	0571-671284	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.234295	f	f	\N	\N	[]	0	active	\N	pending	\N
1745190	\N	IDROSERVICE S.R.L.	2090810389.0	02090810389	VIA FRATTINA, 28	VIGARANO MAINARDA	44049.0	FE	Emilia-romagna	Italia	\N	7	2025-05-07	NaN	NaN	NaN	0425 091821	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.237268	f	f	\N	\N	[]	0	active	\N	pending	\N
1745239	\N	BULLONERIE RIUNITE ROMAGNA S.P.A.	1270450404.0	01270450404	VIA INNOCENZO GOLFARELLI, 151	FORLI'	47122.0	FC	Emilia-romagna	Italia	\N	28	2025-05-08	NaN	www.bullonerieromagna.com	NaN	0543-723271	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.240264	f	f	\N	\N	[]	0	active	\N	pending	\N
1745248	\N	C QUADRA S.R.L.	9712770966.0	09712770966	VIA LIBERTA', 15	BIASSONO	20853.0	MB	Lombardia	Italia	\N	4	2025-05-08	C Quadra  Srl si occupa di lavorare con il clienti su progetti di innovazione digitale, affiancandogli le spese che derivano da vari investimenti, il recupero economico grazie a bandi e incentivi.	www.c-quadra.it	NaN	031.442174	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.243171	f	f	\N	\N	[]	0	active	\N	pending	\N
1745255	\N	C.A. BROKER S.R.L.	4238150371.0	04238150371	VIA LUIGI CARLO FARINI, 10	BOLOGNA	40124.0	BO	Emilia-romagna	Italia	\N	6	2025-05-08	NaN	www.cabrokersrl.it	NaN	051.6013276	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.246457	f	f	\N	\N	[]	0	active	\N	pending	\N
1745261	\N	C.E.D. - CENTRO ELABORAZIONE DATI S.R.L.	864100383.0	00864100383	VIA GENNARI,, 87/1	CENTO	44042.0	FE	Emilia-romagna	Italia	\N	6	2025-05-08	NaN	NaN	NaN	0516853784	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.24983	f	f	\N	\N	[]	0	active	\N	pending	\N
1745270	\N	CABLOTECH - S.R.L.	1686111202.0	01686111202	VIA UMBRIA, 6	CASTEL SAN PIETRO TERME	40024.0	BO	Emilia-romagna	Italia	\N	56	2025-05-08	NaN	www.cablotech.com	NaN	0516950935	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.252741	f	f	\N	\N	[]	0	active	\N	pending	\N
1745315	\N	MORINA AGRON E C. SNC	3323200984.0	03323200984	PIAZZETTA DELL ANFITEATRO, 10	TRENTO	38122.0	TN	Trentino-alto adige	Italia	\N	12	2025-05-07	Ristorante, pizzeria, lounge bar.\n# Sabrina	www.antiteatrotrento.it	anfiteatrotrento@gmail.com	0461 1485703	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.255473	f	f	\N	\N	[]	0	active	\N	pending	\N
1746271	\N	MAGURNO PIERLUIGI	3436280782.0	MGRPLG80C23A773R	VIA LAURO, 108	SCALEA	87029.0	CS	Calabria	Italia	\N	3	2025-05-08	NaN	NaN	NaN	348 5539669	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.258529	f	f	\N	\N	[]	0	active	\N	pending	\N
1746272	\N	PIGNO SRL	2497670469.0	NaN	Via delle Palme, 37	Lido di Camaiore	\N	LU	Toscana	Italia	\N	0	2025-05-08	NaN	NaN	osteriavignaccio@gmail.com	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.261838	f	f	\N	\N	[]	0	active	\N	pending	\N
1746339	\N	SE.GE.SA. SERVIZI E GESTIONI SOCIO ASSISTENZIALI - S.R.L.	3806910109.0	03806910109	VIA CERVETTO NINO, 38 B	GENOVA	16152.0	GE	Liguria	Italia	\N	96	2025-05-08	NaN	www.villaduchessadigalliera.com	NaN	010318077	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.264762	f	f	\N	\N	[]	0	active	\N	pending	\N
1746406	\N	MAM SRL	4534590247.0	04534590247	PIAZZA LIBERTA', 10	ARZIGNANO	36071.0	VI	Veneto	Italia	\N	0	2025-05-09	Società che gestisce Caffè Italiano ad Arzignano ( Vi )	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.268585	f	f	\N	\N	[]	0	active	\N	pending	\N
1746425	\N	B & R S.R.L.	3166420160.0	03166420160	VIA ANDREA FANTONI, 13	SERIATE	24068.0	BG	Lombardia	Italia	\N	22	2025-05-08	Pizza Grill.\n# Sabrina	www.birrificio-pizzagrill.it	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.272166	f	f	\N	\N	[]	0	active	\N	pending	\N
1746432	\N	PIZZEGHELLA E STEVAN S.R.L.	3549610230.0	03549610230	VIA ENRICO FERMI, 9	PESCANTINA	37026.0	VR	Veneto	Italia	\N	24	2025-05-08	NaN	www.stevanelevatori.it	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.275856	f	f	\N	\N	[]	0	active	\N	pending	\N
1746438	\N	PODERE PERETO DI BORDONI FRANCO	805480522.0	BRDFNC60S20M147K	LOCALITA' POD PERETO, 17	RAPOLANO TERME	53040.0	SI	Toscana	Italia	\N	36	2025-05-08	NaN	www.poderepereto.it	info@poderepereto.it	0577 704719	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.279364	f	f	\N	\N	[]	0	active	\N	pending	\N
1746442	\N	POIANO S.P.A.	641950233.0	00641950233	VIA FIORIA,	COSTERMANO	37010.0	VR	Veneto	Italia	\N	22	2025-05-08	Resort.\n# Sabrina	www.poiano.com	NaN	045 7200100	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.282662	f	f	\N	\N	[]	0	active	\N	pending	\N
1746443	\N	P.K. GROUP S.R.L.	4755020239.0	04755020239	VIA ROMA, 26	SOMMACAMPAGNA	37066.0	VR	Veneto	Italia	\N	0	2025-05-08	NaN	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.286293	f	f	\N	\N	[]	0	active	\N	pending	\N
1746516	\N	LA TORRE DI DOMENICO FOLLA & C.  S.A.S.	781850326.0	00781850326	STRADA PER LONGERA, 37	TRIESTE	34128.0	TS	Friuli-venezia giulia	Italia	\N	10	2025-05-12	NaN	NaN	latorrefolla@gmail.com	040 53582	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.289882	f	f	\N	\N	[]	0	active	\N	pending	\N
1746539	\N	CMD ROMA S.R.L. (Campo Marzio)	12794881008.0	12794881008	VIA FILIPPO CARUSO, 23	ROMA	173.0	RM	Lazio	Italia	\N	40	2025-05-12	24/06/2024 .AD di Campo Marzio è tale Stefano Di Veroli \nMassimiliano Salustri è la persona in Azienda (Responsabile vendite) con cui Guazzaloca ha parlato di Formazione 4.0 e EndUser. \nSalustri è di Roma.\nLa proprietà di Campo Marzio è Buffetti.	www.campomarzio.it	NaN	0668807877	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.292567	f	f	\N	\N	[]	0	active	\N	pending	\N
1746555	\N	CARPINOX  S.A.S. DI CESTA LUIGI & C.	925100240.0	00925100240	VIA GIBERTE, 2	SARCEDO	36030.0	VI	Veneto	Italia	\N	15	2025-05-12	L'azienda si occupa di lavorazione di Acciaio Inox e materiali di qualità superiore. Lavorano col mondo dell'Horeca ma per la maggiore con le case farmaceutiche ( es. Pfizer ).\nL'azienda è molto all'avanguardia con i macchinari e li cambia ad ammortamento terminato.\nInvestono molto in formazione del personale.	www.carpinox.eu	NaN	0445361224	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.295032	f	f	\N	\N	[]	0	active	\N	pending	\N
1746561	\N	EFFEKAPPA INVESTIMENTI S.R.L.	3088330273.0	03088330273	VIA NEGROPONTE, 13	VENEZIA	30126.0	VE	Veneto	Italia	\N	11	2025-05-12	Carraro Hotels	www.hotelvillaedera.com	NaN	041-731575	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.297433	f	f	\N	\N	[]	0	active	\N	pending	\N
1746597	\N	CARROZZERIA LA BETTOLA DI PADERNO MICHELE	4076550989.0	PDRMHL84C04B157K	VIA FRANCIACORTA, 1	RODENGO-SAIANO	25050.0	BS	Lombardia	Italia	\N	5	2025-05-12	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.299899	f	f	\N	\N	[]	0	active	\N	pending	\N
1746601	\N	CARTABIANCA S.R.L.	6492680480.0	06492680480	VIA PANCIATICHI, 49	FIRENZE	50127.0	FI	Toscana	Italia	\N	6	2025-05-12	NaN	www.cartabiancacafe.it	NaN	0553851176	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.302434	f	f	\N	\N	[]	0	active	\N	pending	\N
1746615	\N	HAGLEITNER HYGIENE CARTEMANI SRL	1785380161.0	01785380161	VIA JOSEF MARIA PERNTER, 9/A	EGNA	39044.0	BZ	Trentino-alto adige	Italia	\N	75	2025-05-12	NaN	NaN	NaN	0471052817	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.305999	f	f	\N	\N	[]	0	active	\N	pending	\N
1746885	\N	LO CHALET 95 S.R.L.	4821101005.0	04821101005	VIA VINCENZO TIZZANI, 100	ROMA	151.0	RM	Lazio	Italia	\N	57	2025-05-12	NaN	www.invilla-ricevimentieventi.it	NaN	0665790459	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.309549	f	f	\N	\N	[]	0	active	\N	pending	\N
1746915	\N	CASTIGLIA COSTRUZIONI INDUSTRIALI S.R.L.	1795270097.0	01795270097	VIA FORNACE VECCHIA, 21	CARCARE	17043.0	SV	Liguria	Italia	\N	25	2025-05-12	NaN	NaN	NaN	019.510165	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.313075	f	f	\N	\N	[]	0	active	\N	pending	\N
1746916	\N	IMMOBILIARE MAGGIOLINA S.A.S. DI GUARINO ZAVVARONE MARTINA & C.	1289900118.0	01289900118	CORSO NAZIONALE, 176	LA SPEZIA	19126.0	SP	Liguria	Italia	\N	4	2025-05-12	NaN	www.immobiliaremaggiolina.it	info@immobiliaremaggiolina.it	0187 510406	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.315691	f	f	\N	\N	[]	0	active	\N	pending	\N
1746921	\N	IDROTHERM 24 S.R.L.	2242280994.0	02242280994	VIA PIACENZA, 420	CHIAVARI	16043.0	GE	Liguria	Italia	\N	18	2025-05-12	NaN	www.idrotherm24.com	NaN	0185 697325	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.318703	f	f	\N	\N	[]	0	active	\N	pending	\N
1746927	\N	BALBINOT ANTONIO S.R.L.	2488960267.0	02488960267	VIA ROGGIA, 12	VIDOR	31020.0	TV	Veneto	Italia	\N	33	2025-05-12	Eges Calcestruzzi.\n# Sabrina	www.egessrl.it	amministrazione@egescalcestruzzi.it	0423 987321	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.321949	f	f	\N	\N	[]	0	active	\N	pending	\N
1749668	\N	Ne.s.c.e. Consulting Srl	10386620966.0	NaN	VIA ARCIVESCOVO CALABIANA 10	Milano	20139.0	Milano	Lombardia	Italia	\N	0	2025-05-13	NaN	https://www.nesce-consulting.it/	nesceconsulting@pec.it	NaN	\N	NaN	[]	2025-07-03 20:34:37.325253	f	f	\N	\N	[]	0	active	\N	pending	\N
1749671	\N	AMALI SRL	NaN	NaN	Via Stalingrado	Bologna	40121.0	Bologna	Emilia-Romagna	Italia	\N	0	2025-05-13	Borgo Mascarella.\n# Sabrina	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.328783	f	f	\N	\N	[]	0	active	\N	pending	\N
1749676	\N	CATTEL S.P.A.	3334710278.0	03334710278	VIA ETTORE MAJORANA, 11	NOVENTA DI PIAVE	30020.0	VE	Veneto	Italia	\N	131	2025-05-13	NaN	www.cattelcatering.it	NaN	0421350295	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.332322	f	f	\N	\N	[]	0	active	\N	pending	\N
1749722	\N	CBA LAB SOCIETA' A RESPONSABILITA LIMITATA O, IN FORMA ABBREVIATA , CBA LAB S.R.L	11854990964.0	11854990964	CORSO EUROPA, 15	MILANO	20122.0	MI	Lombardia	Italia	\N	0	2025-05-13	NaN	NaN	NaN	02.778061	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.335565	f	f	\N	\N	[]	0	active	\N	pending	\N
1749730	\N	ATLANTE S.R.L.	3970160234.0	03970160234	STRADA BRESCIANA, 14	VERONA	37139.0	VR	Veneto	Italia	\N	7	2025-05-13	NaN	www.centroatlanteverona.it	NaN	0452061676	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.339006	f	f	\N	\N	[]	0	active	\N	pending	\N
1749757	\N	NetLite snc	NaN	NaN	NaN	Trento	38121.0	Trento	Trentino-Alto Adige/Südtirol	Italia	\N	0	2025-05-13	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.341663	f	f	\N	\N	[]	0	active	\N	pending	\N
1749759	\N	CASOIN ONLINE SRL	4823660271.0	04823660271	VIA GIOVANNI GIOLITTI, 12	SANTA MARIA DI SALA	30036.0	VE	Veneto	Italia	\N	0	2025-05-13	Vendita online di prodotti alimentari tipici Veneti	https://www.casoinonline.it/	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.344969	f	f	\N	\N	[]	0	active	\N	pending	\N
1749777	\N	CENTRO IMPIANTI S.R.L.	2292130461.0	02292130461	VIA PROVINCIALE, 222	CAMAIORE	55041.0	LU	Toscana	Italia	\N	73	2025-05-14	NaN	www.centroimpianti.net	NaN	0584.1942411	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.348037	f	f	\N	\N	[]	0	active	\N	pending	\N
1749781	\N	IMPRESA EDILE S.G.B. DI SERRA GIOVANNI	3257870240.0	SRRGNN81A03G203S	LOCALITA' SOTTORIVA, 13	CASTELGOMBERTO	36070.0	VI	Veneto	Italia	\N	12	2025-05-14	NaN	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.351037	f	f	\N	\N	[]	0	active	\N	pending	\N
1749783	\N	CENTRO OTTICO ANZOLA S.R.L.	634521207.0	03537600375	VIA EMILIA, 83/B	ANZOLA DELL'EMILIA	40011.0	BO	Emilia-romagna	Italia	\N	5	2025-05-14	NaN	www.centriotticiassociati.it	NaN	051-731694	\N	Nord-Ovest	["Maria Silvia Gentile"]	2025-07-03 20:34:37.354105	f	f	\N	\N	[]	0	active	\N	pending	\N
1749784	\N	CENTRO OTTICO CREVALCORE DI CALAMELLI FEDERICO & C. S.A.S.	652111204.0	03702340377	VIA GIACOMO MATTEOTTI, 277	CREVALCORE	40014.0	BO	Emilia-romagna	Italia	\N	3	2025-05-14	NaN	www.centrootticocrevalcore.it	NaN	051.980665	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.357223	f	f	\N	\N	[]	0	active	\N	pending	\N
1749786	\N	CENTRO RADIODIAGNOSTICO BARBIERI SRL	1312411000.0	04844530586	VIA MORGAGNI GIOVANNI BATTISTA, 35	ROMA	161.0	RM	Lazio	Italia	\N	6	2025-05-14	NaN	NaN	NaN	06-44243138	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.360014	f	f	\N	\N	[]	0	active	\N	pending	\N
1749793	\N	DAMMICCO S.R.L.	7645460960.0	07645460960	VIA FRATELLI CERVI, 8	BUCCINASCO	20090.0	MI	Lombardia	Italia	\N	8	2025-05-14	NaN	www.dammicco.it	NaN	02-36592977	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.362785	f	f	\N	\N	[]	0	active	\N	pending	\N
1749809	\N	CENTRO SUB PORTOROTONDO SNC DI PATRIZIA MEDDA & C. POTRA' AVVALERSI DELLA RAGIONE SOCIALE ABBREVIATA CENTRO SUB PORTOROTONDO SNC	2347460921.0	02347460921	LOCALITA' MARINA DI PORTO ROTONDO,	OLBIA	7026.0	SS	Sardegna	Italia	\N	4	2025-05-14	NaN	www.csubportorotondo.com	NaN	0789-34869	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.365673	f	f	\N	\N	[]	0	active	\N	pending	\N
1749815	\N	CGM VERSE S.R.L.	12816830017.0	12816830017	CORSO UNIONE SOVIETICA, 612/3	TORINO	10135.0	TO	Piemonte	Italia	\N	4	2025-05-14	NaN	NaN	NaN	011.0898101	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.368256	f	f	\N	\N	[]	0	active	\N	pending	\N
1749817	\N	CHILEA RAPPRESENTANZE SRL	4860570235.0	04860570235	VIA WOLFGANG AMADEUS MOZART, 43	CAMPODARSEGO	35011.0	PD	Veneto	Italia	\N	3	2025-05-14	NaN	NaN	NaN	049.8594940	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.370867	f	f	\N	\N	[]	0	active	\N	pending	\N
1752463	\N	CISCRA S.P.A.	896271004.0	00448610584	VIA SAN MICHELE, 36	VILLANOVA DEL GHEBBO	45020.0	RO	Veneto	Italia	\N	107	2025-05-14	NaN	www.ciscra.com	NaN	0425-651230	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.373605	f	f	\N	\N	[]	0	active	\N	pending	\N
1752487	\N	CLEF S.R.L.	1616240238.0	01616240238	LUNGADIGE CAPULETI, 11	VERONA	37122.0	VR	Veneto	Italia	\N	7	2025-05-14	Omar è titolare di CLEF S.r.l. che ha 6/7 dipendenti e Presidente di LUNIKLEF un Associazione iscritta all'Albo delle Associazioni riconosciute con personalità giuridica del Veneto con 30/32 dipendenti.\nLe allieve della scuola o pagano la retta della scuola privata o se vengono dall'Associazione non pagano nulla perchè la Regione Veneto sovvenziona loro la retta.	www.clef.it	NaN	045-597080	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.376257	f	f	\N	\N	[]	0	active	\N	pending	\N
1752491	\N	CLIMA TECNIKA S.R.L.	1054590953.0	01054590953	VIA PARIGI,	ORISTANO	9170.0	OR	Sardegna	Italia	\N	4	2025-05-14	NaN	www.climatecnika.it	NaN	0783-351012	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.378868	f	f	\N	\N	[]	0	active	\N	pending	\N
1752504	\N	CMC VENTILAZIONE S.R.L.	1930890163.0	01930890163	VIA VIENNA, 46/48	VERDELLINO	24040.0	BG	Lombardia	Italia	\N	16	2025-05-14	CMC Ventilazione azienda di Bergamo che si occupa della sanificazione dell'aria attraverso un macchinario progettato da loro.\nHa 1 5 dipendenti	www.cmcventilazione.com	NaN	035883371	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.381197	f	f	\N	\N	[]	0	active	\N	pending	\N
1752510	\N	CMEV S.R.L.	2204680272.0	02204680272	VIA NAZIONALE, 122/C	MIRA	30034.0	VE	Veneto	Italia	\N	26	2025-05-14	NaN	www.cmev.it	NaN	041-4266495	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.383685	f	f	\N	\N	[]	0	active	\N	pending	\N
1752523	\N	CMZ DI ZANINI RINO & C. S.R.L.	3793550249.0	03793550249	VIA VIGARDOLETTO, 39	MONTICELLO CONTE OTTO	36010.0	VI	Veneto	Italia	\N	10	2025-05-14	NaN	www.cmz-zanini.com	NaN	0444.595365	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.385999	f	f	\N	\N	[]	0	active	\N	pending	\N
1752527	\N	CO.I.MA. - COSTRUZIONI IDRAULICHE MARANGONI - S.R.L.	1289660241.0	01289660241	VIA DELL'ARTIGIANATO, 71	CAMISANO VICENTINO	36043.0	VI	Veneto	Italia	\N	47	2025-05-14	NaN	www.impresacoima.it	NaN	0444413322	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.389086	f	f	\N	\N	[]	0	active	\N	pending	\N
1752537	\N	NINA MADAFFARI	8871930965.0	MDFNGB66C52Z401D	VIA SILVIO PELLICO, 10/18	CAPONAGO	20867.0	MB	Lombardia	Italia	\N	1	2025-05-14	Affianco le persone per far emergere i loro talenti. Accompagno professionisti a raggiungere obiettivi di business e di sviluppo e crescita personale. Nata in Canada, sono madrelingua inglese, con 25 anni di esperienza in multinazionali di cui 15 come Manager di Risorse Umane e Comunicazione Internazionale. Dal 2014 mi dedico sono freelance, lavoro con le aziende (PMI e Corporate) e clienti ambiziosi. Promuovo servizi di internazionalizzazione, la formazione divergente e disruptive, esperienziale (mind, body and emotion), Uniqueness Management per la gestione della diversità e uso la metodologia di Positive Intelligence arrivare al successo, felici, con un mindset positivo.	www.ninamadaffari.com	NaN	02-95745663	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.39258	f	f	\N	\N	[]	0	active	\N	pending	\N
1752645	\N	Guzzi - Fake	123456.0	NaN	NaN	Milano	20121.0	Milano	Lombardia	Italia	\N	0	2025-05-15	NaN	NaN	guzzi@guzzi.guzzi	NaN	\N	NaN	["Luca Sala"]	2025-07-03 20:34:37.396338	f	f	\N	\N	[]	0	active	\N	pending	\N
1752689	\N	COBUE S.S. SOC. AGR. DI CASTOLDI SIMONA MARIA ELSA E GILBERTO	5515020963.0	05515020963	VIA GIULIANO SALVIO, 7	MILANO	20146.0	MI	Lombardia	Italia	\N	14	2025-05-15	NaN	www.cobue.it	NaN	030.9108319	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.399406	f	f	\N	\N	[]	0	active	\N	pending	\N
1752697	\N	COFFEE COMPANY SPA	2440020242.0	02440020242	VIA DEL COMMERCIO, 1	VICENZA	36100.0	VI	Veneto	Italia	\N	27	2025-05-15	NaN	NaN	NaN	0444.348660	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.402795	f	f	\N	\N	[]	0	active	\N	pending	\N
1752707	\N	COMEC S.R.L.	1531640934.0	01531640934	CORSO ITALI, 55/A	PORCIA	33080.0	PN	Friuli-venezia giulia	Italia	\N	30	2025-05-15	NaN	www.comecpn.com	NaN	0434-921101	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.405994	f	f	\N	\N	[]	0	active	\N	pending	\N
1752711	\N	COMITEC OLEODINAMICA E PNEUMATICA S.R.L.	6172691005.0	06172691005	VIA GROELLANDI, 4/A	POMEZIA	40.0	RM	Lazio	Italia	\N	7	2025-05-15	NaN	www.comitecnet.it	NaN	06-916190	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.409063	f	f	\N	\N	[]	0	active	\N	pending	\N
1752715	\N	COMMUNICATION PRODUCTS S.R.L.	1137840995.0	01137840995	VIALE SERGIO KASMAN, 13	CHIAVARI	16043.0	GE	Liguria	Italia	\N	2	2025-05-15	NaN	www.altostile.it	NaN	0185-379483	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.411971	f	f	\N	\N	[]	0	active	\N	pending	\N
1752717	\N	COMPAGNONI FRANCO E C. S.N.C.	3296240173.0	03296240173	VIALE DE GASPERI, 179	FLERO	25020.0	BS	Lombardia	Italia	\N	6	2025-05-15	NaN	NaN	NaN	030-3455777	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.416065	f	f	\N	\N	[]	0	active	\N	pending	\N
1752722	\N	COMPIUTA S.R.L.	5375100285.0	05375100285	VIA A. ANFOSSI, 5	PADOVA	35131.0	PD	Veneto	Italia	\N	0	2025-05-15	27/10/2023  Fiera Tecnologie 4.0 5.0 Vicenza\nAzienda di software che crea i propri prodotti e fornisce servizi su misura per il settore dell'IoT industriale .\n\nIl loro più grande successo finora è Connhex , una suite IoT industriale per produttori di dispositivi.	NaN	NaN	049.5736664	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.420098	f	f	\N	\N	[]	0	active	\N	pending	\N
1752729	\N	B2CONNECT SOCIETA A RESPONSABILITA' LIMITATA START-UP INNOVATIVA - SOCIETA' BENEFIT	16225951009.0	16225951009	VIALE GIORGIO RIBOTTA, 11	ROMA	144.0	RM	Lazio	Italia	\N	25	2025-05-15	NaN	NaN	NaN	06.94506359	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.42435	f	f	\N	\N	[]	0	active	\N	pending	\N
1752739	\N	CONSORZIO INDUSTRIALE PROVINCIALE ORISTANESE	87530952.0	80003430958	VIA CARDUCCI, 21	ORISTANO	9170.0	OR	Sardegna	Italia	\N	1	2025-05-15	Non sono presenti contatti.	www.ciporistano.it	NaN	0783354616	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.428344	f	f	\N	\N	[]	0	active	\N	pending	\N
1752740	\N	CONSORZIO PER LA TUTELA DEI VINI VALPOLICELLA	2202330235.0	00648430239	VIA VALPOLICELLA, 57	SAN PIETRO IN CARIANO	37029.0	VR	Veneto	Italia	\N	10	2025-05-15	Il Consorzio ha 10 dipendenti è il Consorzio Tutela di tutte le realtà agricole della Valpolicella.\nI dipendenti utilizzano tutti Software gestionali Gepo e Regionali. hanno ovviamente un Data Base gestito dal personale dipendente e tutti i vari gestionali utilizzati in Contabilità e Amministrazione.	www.consorziovalpolicella.it	NaN	045.7703194	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.431978	f	f	\N	\N	[]	0	active	\N	pending	\N
1752788	\N	CONSULTECH SRL	3835271200.0	03835271200	VIA DEL TIPOGRAFO, 2	BOLOGNA	40138.0	BO	Emilia-romagna	Italia	\N	2	2025-05-16	Rubens è il commerciale di Consultech che fornisce i pc ad Ortopedia Malpighi.\nNerozzi ha bisogno di acquistare entro fine agosto 3 PC portatili:\n- 1 lo utilizzeranno 6/7 tecnici\n- 1 lo utilizzerà Stefano ad uso personale\n- 1 lo utilizzeranno 3 tecnici.	www.consultechmsp.com	NaN	05119901145	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.435877	f	f	\N	\N	[]	0	active	\N	pending	\N
1752812	\N	COOPERATIVA SOCIALE L'ORTO SOCIETA' COOPERATIVA SOCIALE IN SIGL A L'ORTO SOC. COOP. SOCIALE.	578401200.0	02441960370	VIA MARCONI, 2B	MINERBIO	40061.0	BO	Emilia-romagna	Italia	\N	42	2025-05-16	Informazioni Cooperativa\nCooperativa Sociale, fondata nel 1984, opera da quasi 40 anni nell'ambito della disabilità  e nel campo dell’agricoltura biologica. \n Presenti sul territorio di Minerbio (BO) con Casa “Alberto Subania”,  e a Vedrana di Budrio (BO) con Casa “Carlo Chiti”. In entrambe le sedi gestiamo un Centro Socio Riabilitativo Diurno ed un Gruppo Appartamento per persone con disabilità.\n Sul territorio di Molinella (BO), nella frazione di San Martino in Argine siamo presenti con il "Progetto Kairòs" struttura destinata a percorsi di autonomia  individuali e di piccolo gruppo.\n Con i nostri ospiti condividiamo l'obbiettivo di “Coltivare progetti di vita”, proponendo giorno per giorno attività riabilitative, lavorative, ricreative.\n Nell'azienda agricola insieme ai nostri ospiti coltiviamo e vendiamo nel nostro punto vendita cereali e ortaggi utilizzando tecniche e prassi  di lavoro rispettosi dell’ambiente,  seguendo la stagionalità e  il metodo biologico.	www.cooperativalorto.com	NaN	051-878169	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.438964	f	f	\N	\N	[]	0	active	\N	pending	\N
1752835	\N	OSAC3 DI SILVIO MINUZ & C. S.N.C. - S.T.P.	4418700276.0	04418700276	VIA STADIO, 23	PORTOGRUARO	30026.0	VE	Veneto	Italia	\N	18	2025-05-16	Società di Consulenza del Lavoro dei Andrea Moro, Al Cantinon. Referente Giulia Doretto.	NaN	NaN	0421276488	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.44206	f	f	\N	\N	[]	0	active	\N	pending	\N
1752860	\N	CORMACH S.R.L. CORREGGIO MACCHINE	1376060354.0	01376060354	VIA A. PIGNEDOLI, 2	CORREGGIO	42015.0	RE	Emilia-romagna	Italia	\N	16	2025-05-16	18/11/2023 Info contatto\nContatto preso in  Fiera a Bologna al Futur Motive .\nSi occupano di Tecnologia avanzata, alta qualità, efficace servizio alla clientela, flessibilità unica, e attenta formazione del personale in ambito di autofficine.	www.cormachsrl.com	NaN	0522-693587	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.445145	f	f	\N	\N	[]	0	active	\N	pending	\N
1752863	\N	COROFAR - COOPERATIVA DI SERVIZI ALLE FARMACIE - SOCIETA' COOPERATIVA	1296760406.0	01296760406	VIA TRAIANO IMPERATORE, 19	FORLI'	47122.0	FC	Emilia-romagna	Italia	\N	25	2025-05-16	NaN	NaN	NaN	0543-793211	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.448281	f	f	\N	\N	[]	0	active	\N	pending	\N
1752873	\N	OMC S.R.L.	3397660246.0	03397660246	VIA VALCHIAMPO, 70/A	MONTORSO VICENTINO	36050.0	VI	Veneto	Italia	\N	46	2025-05-16	Concessionaria con rivendita, noleggio e riparazione clienti	www.omc-srl.com	NaN	0444-623998	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.451085	f	f	\N	\N	[]	0	active	\N	pending	\N
1752874	\N	CROCE DEL VENTO S.R.L.	4724880234.0	04724880234	VIA DEL PONTAROL, 13	MARANO DI VALPOLICELLA	37020.0	VR	Veneto	Italia	\N	2	2025-05-16	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.453701	f	f	\N	\N	[]	0	active	\N	pending	\N
1752876	\N	CRV S.A.S DI MURARO DINO	3421930243.0	03421930243	VIA RIVIERA, 87	NANTO	36024.0	VI	Veneto	Italia	\N	3	2025-05-16	24/04 Incontro conoscitivo con Barbara Zigliotto\nDino Muraro è il titolare della società CRV sas.\nL'azienda si occupa di sistemi per la ristorazione e installo di macchinari compresi 4.0.\nHa cominciato a collaborare con Barbara passandogli qualche cliente e anche il suo commercialista.\nE' interessato collaborare con noi perché ci presenta alle aziende che stanno progettando rinnovamenti ed investimenti per farli rientrare nella 5.0.\nHa pochi dipendenti e quindi non potrà rientrare per formazione 4.0	www.crvsistemi.com	NaN	04441833683	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.456843	f	f	\N	\N	[]	0	active	\N	pending	\N
1752886	\N	CUSTOM BUSINESS SRL	13168470964.0	13168470964	VIA SARDEGNA, 21	MILANO	20146.0	MI	Lombardia	Italia	\N	1	2025-05-16	NaN	NaN	NaN	329.6493353	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.459646	f	f	\N	\N	[]	0	active	\N	pending	\N
1752888	\N	DUREGON SRL	5115060286.0	05115060286	VIALE DELL'ARTIGIANATO, 25	SANTA GIUSTINA IN COLLE	35010.0	PD	Veneto	Italia	\N	13	2025-05-16	NaN	www.duregonsoluzionielettriche.it	NaN	3403325611	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.463596	f	f	\N	\N	[]	0	active	\N	pending	\N
1753078	\N	LA MAGGIORE S.R.L.	451740310.0	00451740310	VIA GRADO, 63	MONFALCONE	34074.0	GO	Friuli-venezia giulia	Italia	\N	24	2025-05-19	La società gestisce al suo interno: un concessionario di vendita e manutenzione auto Renault dal 1972 a Gorizia e Monfalcone; una rivendita Italnolo con 2 punti vendita a Trieste e Monfalcone.\nSono in 4 soci e 21 dipendenti.\nStanno creando un nuovo Centro Sportivo di Padel e Calcietto a Monfalcone.	www.lamaggiore.it	NaN	0481-722035	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.466575	f	f	\N	\N	[]	0	active	\N	pending	\N
1753084	\N	DAKOTA GROUP S.A.S. DI ZENO CIPRIANI & C.	7971400960.0	07971400960	VIA PITAGORA, 3	AFFI	37010.0	VR	Veneto	Italia	\N	70	2025-05-19	Producono e distribuiscono prodotti per l'edilizia.\n\nHanno 3 Aziende:\n- Termoplast s.r.l. con 60 dipendenti (con Revisore interno)\n- Dakota s.a.s. con 60 dipendenti \n- Dovaro S.p.A. con 30 dipendenti	www.dakota.eu	NaN	0456284075	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.4701	f	f	\N	\N	[]	0	active	\N	pending	\N
1753109	\N	I DADI DI DEBORA DAFFINI	3503601209.0	DFFDBR72T42D969I	VIA DOMODOSSOLA, 1/C	BOLOGNA	40139.0	BO	Emilia-romagna	Italia	\N	2	2025-05-19	NaN	NaN	NaN	051 544285	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.473443	f	f	\N	\N	[]	0	active	\N	pending	\N
1753110	\N	DEA S.R.L.	2741811208.0	02741811208	VIA CATALDI, 1/5	SAN GIORGIO DI PIANO	40016.0	BO	Emilia-romagna	Italia	\N	12	2025-05-19	L'Azienda si occupa di noleggio e vendita di piattaforme aeree, gru ecc\nOffrono servizi di consulenza, manutenzione e formazione pre e post vendita.	www.deapiattaforme.com	NaN	051-0956148	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.476987	f	f	\N	\N	[]	0	active	\N	pending	\N
1753122	\N	DNA SPORT CONSULTING SRL	3682640234.0	03682640234	VIA BELLUNO, 22/A	VERONA	37133.0	VR	Veneto	Italia	\N	4	2025-05-19	NaN	www.dnasportconsulting.it	NaN	0458012816	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.48002	f	f	\N	\N	[]	0	active	\N	pending	\N
1753354	\N	DOMUS NOSTRA S.R.L.	2042111209.0	02042111209	VIA BRUNO BUOZZI, 59-61	CASTEL MAGGIORE	40013.0	BO	Emilia-romagna	Italia	\N	4	2025-05-20	In azienda ci sono 4 dipendenti + 2 soci a busta paga.\nUsano tecnologia solo Roberta (8 ore al giorno) e i 2 Soci ma saltuariamente in quanto sono sempre in cantiere.\nNessuna App per i 3 muratori che sono sempre in cantiere.\nNon ci sono le basi per iniziare pratica.	NaN	NaN	051711373	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.483478	f	f	\N	\N	[]	0	active	\N	pending	\N
1753358	\N	FOODBRAND S.P.A.	9069350966.0	09069350966	VIA G.A. AMADEO, 59	MILANO	20134.0	MI	Lombardia	Italia	\N	31	2025-05-20	NaN	www.doppiomalto.com	NaN	025063696	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.486595	f	f	\N	\N	[]	0	active	\N	pending	\N
1753359	\N	DUE SPIGA D'ORO SRL	4494370275.0	04494370275	VIA PADOVA, 174	VIGONOVO	30030.0	VE	Veneto	Italia	\N	14	2025-05-20	NaN	NaN	NaN	335.6602289	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.489449	f	f	\N	\N	[]	0	active	\N	pending	\N
1753397	\N	E - TEAM DI RIGHINI BRUNO & C. S.A.S.	1527250367.0	01527250367	VIA DEGLI ARTIGIANI, 25	MEDOLLA	41036.0	MO	Emilia-romagna	Italia	\N	22	2025-05-20	Progettazione di sistemi elettronici su misura;\nModifica e/o aggiornamento di sistemi esistenti con l’implementazione di nuove tecnologie;\nModifica e implementazione di software;\nProgettazione di banchi di collaudo;\nProgettazione di quadri elettrici di comando;\nProgrammazione di PLC.\nProduzione di circuiti elettronici in piccole e grandi serie;\n“Realizzazione di apparecchiature assemblate complete di elettronica e cablaggio elettrico;\nTrasformazione di cablaggi filari in circuiti elettronici e trasformazioni di circuiti elettronici tradizionali in circuiti SMD;\nRealizzazione di campionature e studi di fattibilità anche per piccole quantità.\nRealizzazione di cavi e cablaggi semplici e complessi;\nCreazione di interfacce e connessioni di potenza e segnali per i settori dell’automazione, elettromedicale, alimentare, agricolo e trasmissione dati;\nCreazione di cablaggi multi filari per distributori e macchinari;\nCreazione di cablaggi per la microelettronica, connettori militari o simili ad alta protezione ambientale, resinature e collaudo cavi;\nForniamo consulenze per l’impiego di cavi e delle connessioni.	www.eteamtecnology.it	NaN	0535411840	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.492367	f	f	\N	\N	[]	0	active	\N	pending	\N
1753401	\N	E.R. LUX S.R.L.	3637700406.0	03637700406	VIA CARTESIO, 27	FORLI'	47122.0	FC	Emilia-romagna	Italia	\N	41	2025-05-20	NaN	www.erlux.it	NaN	0543794413	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.495449	f	f	\N	\N	[]	0	active	\N	pending	\N
1753439	\N	O.M. PES. AMA. S.R.L.	2180450245.0	02180450245	VIA DELL'ECONOMIA, 4/B	CASTELGOMBERTO	36070.0	VI	Veneto	Italia	\N	7	2025-05-19	NaN	www.ompesama.com	info@ompesama.com	0445 440390	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.498443	f	f	\N	\N	[]	0	active	\N	pending	\N
1753444	\N	PERNIX S.R.L.	3245210277.0	03245210277	VIA PASCOLI, 42	QUARTO D'ALTINO	30020.0	VE	Veneto	Italia	\N	15	2025-05-19	NaN	www.pernixitalia.com	NaN	0422 780605	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.501362	f	f	\N	\N	[]	0	active	\N	pending	\N
1753447	\N	ECORISORSE S.R.L.	2559790759.0	02559790759	VIA FALCONE BORSELLINO, 6	LEQUILE	73010.0	LE	Puglia	Italia	\N	54	2025-05-20	NaN	NaN	NaN	0832638339	\N	Nord-Est	["Luigi Vitaletti"]	2025-07-03 20:34:37.504704	f	f	\N	\N	[]	0	active	\N	pending	\N
1753448	\N	PAYPRINT S.R.L.	3204920361.0	03204920361	VIA MONTI, 115	MODENA	41123.0	MO	Emilia-romagna	Italia	\N	9	2025-05-19	NaN	NaN	NaN	059 3365131	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.508145	f	f	\N	\N	[]	0	active	\N	pending	\N
1753452	\N	PAX ITALIA S.R.L.	8126950966.0	08126950966	VIA BO CARLO, N. 11	MILANO	20143.0	MI	Lombardia	Italia	\N	34	2025-05-19	NaN	www.paxitalia.com	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.511557	f	f	\N	\N	[]	0	active	\N	pending	\N
1753467	\N	ECOTECNICA *SRL	2051620751.0	02051620751	VIA PADRE DIEGO, 98	LEQUILE	73010.0	LE	Puglia	Italia	\N	363	2025-05-20	NaN	www.ecotecnicalecce.it	NaN	0832632491	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.514912	f	f	\N	\N	[]	0	active	\N	pending	\N
1753468	\N	PATROL VIGILANZA S.R.L.	3725620284.0	03725620284	VIA PORTOGALLO, 11/86	PADOVA	35127.0	PD	Veneto	Italia	\N	34	2025-05-20	NaN	NaN	NaN	049-6988163	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.51766	f	f	\N	\N	[]	0	active	\N	pending	\N
1753469	\N	EDILIMPIANTI TRIESTE S.R.L. - SOCIETA' BENEFIT	1254160326.0	01254160326	STRADA DI FIUME, 86	TRIESTE	34149.0	TS	Friuli-venezia giulia	Italia	\N	47	2025-05-20	NaN	www.edilimpiantitrieste.com	NaN	0409498145	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.520249	f	f	\N	\N	[]	0	active	\N	pending	\N
1753481	\N	EDILTECK SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	4190960981.0	04190960981	VIA SALISENI, 2 B	BAGOLINO	25072.0	BS	Lombardia	Italia	\N	1	2025-05-20	NaN	NaN	NaN	346.6946555	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.522899	f	f	\N	\N	[]	0	active	\N	pending	\N
1753509	\N	SERVI SRL	12481751001.0	12481751001	VIA CAMPOBELLO, 1/C	POMEZIA	40.0	RM	Lazio	Italia	\N	12	2025-05-20	NaN	www.attilioservipasticceria.com	NaN	06 9124150	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.525592	f	f	\N	\N	[]	0	active	\N	pending	\N
1753514	\N	EKOTEAM S.R.L.	4608780286.0	04608780286	VIA LEONARDO DA VINCI, 74	CAMPO SAN MARTINO	35010.0	PD	Veneto	Italia	\N	5	2025-05-20	Ekoteam Ambiente è un'azienda certificata ESCo (Società di Servizi Energetici) specializzata nell'installazione di impianti ad energia rinnovabile.\nL’obiettivo primario è individuare e quantificare le opportunità di risparmio energetico con impianti ad alta efficienza energetica.	www.ekoteam.it	NaN	049-5971871	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.528351	f	f	\N	\N	[]	0	active	\N	pending	\N
1753525	\N	ELI.MAR. S.R.L.	2348910460.0	02348910460	VIA DELLE PALME, 37	CAMAIORE	55041.0	LU	Toscana	Italia	\N	6	2025-05-20	Del contatto abbiamo solo il nominativo,mancano il recapito telefonico e l'indirizzo mail.	NaN	NaN	333.9606629	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.531409	f	f	\N	\N	[]	0	active	\N	pending	\N
1753529	\N	P	NaN	NaN	NaN	NaN	\N	NaN	NaN	NaN	\N	0	2025-05-20	NaN	NaN	NaN	NaN	\N	NaN	[]	2025-07-03 20:34:37.534283	f	f	\N	\N	[]	0	active	\N	pending	\N
1753532	\N	ELIXEA SRL	4407220245.0	04407220245	VIA LUDOVICO LAZZARO ZAMENHOF, 388	VICENZA	36100.0	VI	Veneto	Italia	\N	2	2025-05-20	NaN	NaN	NaN	346.0663166	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.53725	f	f	\N	\N	[]	0	active	\N	pending	\N
1753534	\N	ELLE EMME STUDIO S.R.L.	1989000383.0	01989000383	VIA FERRARESE, 30/A	CENTO	44042.0	FE	Emilia-romagna	Italia	\N	0	2025-05-20	ELLE EMME E' LO STUDIO DI LIDIA BALBONI COMMERCIALISTA DI CENTO (FE) CON LA QUALE ABBIAMO COLLABORAZIONE IN ESSERE.	NaN	NaN	0514682595	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.540975	f	f	\N	\N	[]	0	active	\N	pending	\N
1753755	\N	EN-GAS SRL	7478750966.0	07478750966	VIA FORTUNATO POSTIGLIONE, 46	MONCALIERI	10024.0	TO	Piemonte	Italia	\N	24	2025-05-21	NaN	www.engas.it	NaN	0119494844	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.543965	f	f	\N	\N	[]	0	active	\N	pending	\N
1753768	\N	ENJOY SYSTEM SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	3523161200.0	03523161200	VIA LARGA, 36	BOLOGNA	40138.0	BO	Emilia-romagna	Italia	\N	5	2025-05-21	Ha 1 Sede a Bologna e 1 a Roma ma garantisce servizi e consulenza su tutto il teritorio.\nSi occupa di:\nServizi informatici\nSviluppo applicazioni, siti, e-commerce\nConsulenza informatica\nAssistenza informatica (tramite contratti a scalare, a forfait, ricorrenti)\nSicurezza informatica (partner di F-Secure)\nInternet e telefonia  (partner WIND 3 a livello nazionale)\nFormazione\nCorsi di lingue\nDigitalizzazione\nCloud Computing\nVendita e noleggio\nLuce e gas (partner di Illumia)	NaN	NaN	0510549009	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.546448	f	f	\N	\N	[]	0	active	\N	pending	\N
1753777	\N	ENVICON MEDICAL S.R.L.	4121630232.0	04121630232	VIA FILIPPINI, 21/A	VERONA	37121.0	VR	Veneto	Italia	\N	9	2025-05-21	NaN	www.envicon.it	NaN	045-8012696	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.549097	f	f	\N	\N	[]	0	active	\N	pending	\N
1753781	\N	EPPINGER CAFFE' S.A.S DI SCAGGIANTE SEBASTIANO	1172180323.0	01172180323	VIA DANTE ALIGHIERI, 2	TRIESTE	34122.0	TS	Friuli-venezia giulia	Italia	\N	20	2025-05-21	NaN	www.eppingercaffe.it	NaN	393.0250969	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.552164	f	f	\N	\N	[]	0	active	\N	pending	\N
1753783	\N	ERARIO IMMOBILIARE S.R.L.	3292540733.0	03292540733	VIA PER LECCE KM 1,	MANDURIA	74024.0	TA	Puglia	Italia	\N	0	2025-05-21	Vendita attrezzature per HO.RE.CA. 4.0 e software da applicare alle attrezzature per interconnetterli.	NaN	NaN	335.8189522	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.555367	f	f	\N	\N	[]	0	active	\N	pending	\N
1753787	\N	ERRECI DI RINALDI CARMELO	4118030370.0	RNLCML61L16G288A	VIA ANDREA DEL VERROCCHIO, 12/U	BOLOGNA	40138.0	BO	Emilia-romagna	Italia	\N	1	2025-05-21	NaN	www.bebdicalabria.it	NaN	051-493859	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.558545	f	f	\N	\N	[]	0	active	\N	pending	\N
1753807	\N	STUDIO BARTOLINI BORGHI DALRIO FARIOLI	2873301200.0	02873301200	VIA GIOVANNI GOLDONI, 4	ANZOLA DELL'EMILIA	40011.0	BO	Emilia Romagna	Italia	\N	0	2025-05-21	NaN	www.etikasmart.it	NaN	051734268	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.562087	f	f	\N	\N	[]	0	active	\N	pending	\N
1753819	\N	EUROCERT S.P.A.	1358390431.0	01358390431	VIA TRIULZIANA, 10	SAN DONATO MILANESE	20097.0	MI	Lombardia	Italia	\N	108	2025-05-21	NaN	www.eurocert.it	NaN	051-6056380	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.564846	f	f	\N	\N	[]	0	active	\N	pending	\N
1753824	\N	EURODENT SRL	3112570233.0	03112570233	VIA CRESCINI, 15	SANT'AMBROGIO DI VALPOLICELLA	37010.0	VR	Veneto	Italia	\N	5	2025-05-21	NaN	www.studioeurodent.it	NaN	0456862751	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.567552	f	f	\N	\N	[]	0	active	\N	pending	\N
1753833	\N	ISILAB SRLS UNIPERSONALE	2441070741.0	02441070741	VIA ANTONIO PIGN, 43/A	SAN VITO DEI NORMANNI	72019.0	BR	Puglia	Italia	\N	3	2025-05-21	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.569925	f	f	\N	\N	[]	0	active	\N	pending	\N
1753949	\N	IL MARE DEL GELATO DI DANIELA DE FILIPPO SOCIETA' IN ACCOMANDITA SEMPLICE	11090521003.0	11090521003	VIA PIETRO ROSA, 27	ROMA	122.0	RM	Lazio	Italia	\N	2	2025-05-22	NaN	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.572483	f	f	\N	\N	[]	0	active	\N	pending	\N
1753952	\N	IL PANIFICIO FERRIGHI	1383060298.0	FRRMSO76A07A539Y	VIA FORNI, 10	ROVIGO	45100.0	RO	Veneto	Italia	\N	12	2025-05-22	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.575201	f	f	\N	\N	[]	0	active	\N	pending	\N
1753966	\N	ILCA TARGHE S.R.L.	495891202.0	00018180372	VIA BELLINI, 11	CASTENASO	40055.0	BO	Emilia-romagna	Italia	\N	40	2025-05-22	NaN	www.ilcatarghe.it	info@ilcatarghe.it	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.577701	f	f	\N	\N	[]	0	active	\N	pending	\N
1754023	\N	I	NaN	NaN	NaN	NaN	\N	NaN	NaN	NaN	\N	0	2025-05-22	NaN	NaN	NaN	NaN	\N	NaN	[]	2025-07-03 20:34:37.580271	f	f	\N	\N	[]	0	active	\N	pending	\N
1754050	\N	ALBANESE MARIANGELA	7449820963.0	LBNMNG68R67F205K	VIA TERAMO, 31	MILANO	20142.0	MI	Lombardia	Italia	\N	3	2025-05-22	Hanno aderito al fondo FONARCOM col seguente n. di matricola: 4990705059.\n# Sabrina	NaN	NaN	02 89778618	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.582996	f	f	\N	\N	[]	0	active	\N	pending	\N
1754068	\N	INFORMATICASERVICE S.R.L.	2270330265.0	02270330265	VIA ROMA, 17	SAN VENDEMIANO	31020.0	TV	Veneto	Italia	\N	7	2025-05-22	NaN	www.infoserv-online.com	NaN	043 8402099	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.585668	f	f	\N	\N	[]	0	active	\N	pending	\N
1754071	\N	ILLUMIA S.P.A.	2356770988.0	02356770988	VIA DE CARRACCI, 69/2	BOLOGNA	40129.0	BO	Emilia-romagna	Italia	\N	162	2025-05-22	Primo incontro a Desenzano durante una serata myWorld.\n# Sabrina	www.illumia.it	NaN	05119984159	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.588234	f	f	\N	\N	[]	0	active	\N	pending	\N
1754073	\N	INTEGRA DI ZANI MAURO	2250880982.0	ZNAMRA75M14B157A	VIA SANTELLO, 59	LUMEZZANE	25065.0	BS	Lombardia	Italia	\N	1	2025-05-22	Azienda conosciuta alla PMI Revolution di Bini.\nID myWorld 8027459.\n# Sabrina	www.integra.vision	NaN	030871944	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.590847	f	f	\N	\N	[]	0	active	\N	pending	\N
1754237	\N	ITA.PRO. S.R.L.	3755691007.0	03755691007	VIA ARDEATINA, 931	ROMA	178.0	RM	Lazio	Italia	\N	11	2025-05-23	NaN	www.itapro.it	NaN	06 2307840	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.593682	f	f	\N	\N	[]	0	active	\N	pending	\N
1754246	\N	ITALCHIM S.R.L.	3960230377.0	03960230377	VIA DEL MOBILIERE, 14	BOLOGNA	40138.0	BO	Emilia-romagna	Italia	\N	17	2025-05-23	NaN	www.italchim.com/	NaN	051-531108	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.597081	f	f	\N	\N	[]	0	active	\N	pending	\N
1754249	\N	IRIS INFORMATICA S.R.L.	4185240373.0	01570561207	VIA PONTEVECCHIO, 24	BOLOGNA	40139.0	BO	Emilia-romagna	Italia	\N	12	2025-05-23	NaN	www.irisinformatica.com	NaN	051 493641	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.600986	f	f	\N	\N	[]	0	active	\N	pending	\N
1754251	\N	BLUCHIARA S.R.L.	1303870198.0	01303870198	VIALE PO, 129	CREMONA	26100.0	CR	Lombardia	Italia	\N	10	2025-05-23	Irish Times Pub\nID myWorld: 809930.\n# Sabrina	www.birraegusto.it	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.604684	f	f	\N	\N	[]	0	active	\N	pending	\N
1754253	\N	JULIAN	NaN	NaN	Viale della Repubblica, 16	Bologna	40121.0	BO	Emilia-Romagna	Italia	\N	132	2025-05-23	The Dragon Pub.\n# Sabrina	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.608529	f	f	\N	\N	[]	0	active	\N	pending	\N
1754464	\N	F.I.S.A.R. - FEDERAZIONE ITALIANA SOMMELIER ALBERGATORI RISTORATO RI ASSOCIAZIONE DI PROMOZIONE SOCIALE	1111200505.0	80011750504	VIA DEI CONDOTTI, 16	SAN GIULIANO TERME	56017.0	PI	Toscana	Italia	\N	4	2025-05-23	F.I.S.A.R. - FEDERAZIONE ITALIANA SOMMELIER ALBERGATORI RISTORATORI ASSOCIAZIONE DI PROMOZIONE SOCIALE	NaN	NaN	050855880	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.611271	f	f	\N	\N	[]	0	active	\N	pending	\N
1754534	\N	KUWAIT PETROLEUM ITALIA S.P.A.	891951006.0	00435970587	VIALE DELL OCEANO INDIANO, 13	ROMA	144.0	RM	Lazio	Italia	\N	720	2025-05-23	NaN	NaN	NaN	0652088793	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.614183	f	f	\N	\N	[]	0	active	\N	pending	\N
1754537	\N	KAPACITA SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	1598770293.0	01598770293	VIA LUIGI EINAUDI, 72	ROVIGO	45100.0	RO	Veneto	Italia	\N	0	2025-05-23	NaN	NaN	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.61697	f	f	\N	\N	[]	0	active	\N	pending	\N
1754539	\N	KANBANBOX S.R.L.	4520390289.0	04520390289	VIA ZAMENHOF, 817	VICENZA	36100.0	VI	Veneto	Italia	\N	26	2025-05-23	NaN	www.kanbanbox.com	NaN	04441620653	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.619388	f	f	\N	\N	[]	0	active	\N	pending	\N
1754624	\N	EL.PA. SERVICE S.R.L.	2831190240.0	02831190240	VIA DEI LAGHI, 11	ALTAVILLA VICENTINA	36077.0	VI	Veneto	Italia	\N	6	2025-05-25	Produzione macchine per il settore conciario	www.elpaservice.com	NaN	0444-371306	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.622271	f	f	\N	\N	[]	0	active	\N	pending	\N
1754716	\N	KAESER COMPRESSORI - S.R.L.	3452440377.0	03452440377	VIA DEL FRESATORE, 5	BOLOGNA	40138.0	BO	Emilia-romagna	Italia	\N	152	2025-05-25	NaN	NaN	NaN	051 715747	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.625005	f	f	\N	\N	[]	0	active	\N	pending	\N
1754725	\N	K-TEAM S.R.L.	5841930489.0	05841930489	VIA DI PRATIGNONE, 39	CALENZANO	50041.0	FI	Toscana	Italia	\N	8	2025-05-26	NaN	www.kteamsrl.it	info@kteamsrl.it	055 8839908	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.627709	f	f	\N	\N	[]	0	active	\N	pending	\N
1754757	\N	LA CERTOSA S.R.L.	1351350523.0	01351350523	VIA CASSIA SUD, 122	SIENA	53100.0	SI	Toscana	Italia	\N	12	2025-05-26	NaN	NaN	NaN	0577-378202	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.630582	f	f	\N	\N	[]	0	active	\N	pending	\N
1754763	\N	L & M AUTOMATION S.R.L.	5416321007.0	05416321007	VIA TOR DEI SCHIAVI, 141	ROMA	172.0	RM	Lazio	Italia	\N	2	2025-05-26	NaN	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.633764	f	f	\N	\N	[]	0	active	\N	pending	\N
1754764	\N	F.A.B. S.R.L.	2798650160.0	02798650160	VIA DON LORENZO MILANI, 7	ZANICA	24050.0	BG	Lombardia	Italia	\N	3	2025-05-26	NaN	www.fabarredamenti.com	NaN	035670634	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.6371	f	f	\N	\N	[]	0	active	\N	pending	\N
1754769	\N	FAIRSGATE S.R.L.	3959901202.0	03959901202	VIA ISONZO, 26	CASALECCHIO DI RENO	40033.0	BO	Emilia-romagna	Italia	\N	1	2025-05-26	NaN	NaN	NaN	347.3420524	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.640421	f	f	\N	\N	[]	0	active	\N	pending	\N
1754770	\N	FAM S.R.L.	4599100759.0	04599100759	VIA FEDERICO II, ZONA PIP, 15/A	CAVALLINO	73020.0	LE	Puglia	Italia	\N	11	2025-05-26	NaN	NaN	NaN	329.0546820	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.644189	f	f	\N	\N	[]	0	active	\N	pending	\N
1754782	\N	LA LOGGIA RAMBALDI DI PIETRALUNGA UMBERTO  &  C. S.N.C.	3892770235.0	03892770235	PIAZZA PRINCIPE AMEDEO, 7	BARDOLINO	37011.0	VR	Veneto	Italia	\N	67	2025-05-26	NaN	www.laloggiarambaldi.it	NaN	045 5118881	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.647475	f	f	\N	\N	[]	0	active	\N	pending	\N
1754789	\N	LA ORANGE SRL	4596780231.0	04596780231	VIA ALBERTO DOMINUTTI, 2	VERONA	37135.0	VR	Veneto	Italia	\N	1	2025-05-26	NaN	www.laorange.it	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.650777	f	f	\N	\N	[]	0	active	\N	pending	\N
1754792	\N	HIPPOCRATES HOLDING S.P.A.	10264830968.0	10264830968	VIA MANZONI ALESSANDRO, 38	MILANO	20121.0	MI	Lombardia	Italia	\N	118	2025-05-26	Farmacia Capolaterra\nQuesta Farmacia fa parte di una holding di farmacie milanesi.\nHippocrates Holding S.p.A. Via Alessandro Manzoni 38, 20121 Milano	www.hippocratesholding.com/	NaN	0276006349	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.65355	f	f	\N	\N	[]	0	active	\N	pending	\N
1754795	\N	LA MAFALDINA S.A.S. DI GIORGIA FAULISI	5118620284.0	05118620284	VIA DEI VIVARINI, 22/A	PADOVA	35133.0	PD	Veneto	Italia	\N	14	2025-05-26	NaN	www.lamafaldina.it	NaN	049 6896801	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.656335	f	f	\N	\N	[]	0	active	\N	pending	\N
1754804	\N	FARMACIA MAURI DI ALLUIGI ALDO & C. SNC	2220190165.0	02220190165	VIA ROMA, 60	PONTE SAN PIETRO	24036.0	BG	Lombardia	Italia	\N	6	2025-05-26	NaN	www.farmaciamauri.it	NaN	035-462766	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.659834	f	f	\N	\N	[]	0	active	\N	pending	\N
1754805	\N	FARMACIA MODERNA-VASSALLO DEL DOTT.BOCCARDO	2035410469.0	BCCJHC54C22Z603H	VIA TABARRANI, 38	CAMAIORE	55041.0	LU	Toscana	Italia	\N	5	2025-05-26	NaN	NaN	NaN	0584.989114	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.663084	f	f	\N	\N	[]	0	active	\N	pending	\N
1754878	\N	FARMACIA SAN GIORGIO S.R.L.	14854581007.0	14854581007	VIA AMSTERDAM, 78 E 80	ROMA	144.0	RM	Lazio	Italia	\N	11	2025-05-27	NaN	www.farmacia.farm	NaN	0683778705	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.666171	f	f	\N	\N	[]	0	active	\N	pending	\N
1754896	\N	FARMACIA SPARGOLI DR. MARIO	2255380699.0	SPRMRA70C02H211R	VIA LANCIANO, 38	FRISA	66030.0	CH	Abruzzo	Italia	\N	4	2025-05-27	NaN	NaN	NaN	0872-58226	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.669264	f	f	\N	\N	[]	0	active	\N	pending	\N
1754959	\N	ELENA S.A.S. DI BRANDI NICOLAS E C.	2406180287.0	02406180287	VIA MONTEGROTTO,, 46	ABANO TERME	35031.0	PD	Veneto	Italia	\N	1	2025-05-27	La Vecchia Marina Pizzeria Verace.\n# Sabrina	NaN	NaN	049 5014804	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.672233	f	f	\N	\N	[]	0	active	\N	pending	\N
1754965	\N	FARMACIE NERI S.R.L.	1380620326.0	01380620326	VIA DANTE ALIGHIERI, 7	TRIESTE	34122.0	TS	Friuli-venezia giulia	Italia	\N	38	2025-05-27	NaN	NaN	NaN	040-631568	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.675235	f	f	\N	\N	[]	0	active	\N	pending	\N
1754966	\N	LABRENTA SRL	2454560240.0	02454560240	VIA DELL'INNOVAZIONE, 2	BREGANZE	36042.0	VI	Veneto	Italia	\N	100	2025-05-27	NaN	NaN	NaN	0445 300410	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.677982	f	f	\N	\N	[]	0	active	\N	pending	\N
1755009	\N	LE DELIZIE DI ALESSIA DI ALESSIA ROSSI E GIACOMO GRASSI S.N.C.	1141920452.0	01141920452	VIA DEI MILLE, 5	CARRARA	54036.0	MS	Toscana	Italia	\N	6	2025-05-27	NaN	NaN	NaN	0585 832825	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.680936	f	f	\N	\N	[]	0	active	\N	pending	\N
1755029	\N	LC FRUIT S.R.L.	1849810237.0	01849810237	VIA SAN BRIZIO, 73	MONTEFORTE D'ALPONE	37032.0	VR	Veneto	Italia	\N	11	2025-05-27	NaN	www.lcfruit.it	NaN	045 6175691	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.683924	f	f	\N	\N	[]	0	active	\N	pending	\N
1755031	\N	LAVANDERIA GIRASOLE SOCIETA' COOPERATIVA	1959490382.0	01959490382	STRADA STATALE ROMEA, 15	COMACCHIO	44029.0	FE	Emilia-romagna	Italia	\N	31	2025-05-27	NaN	NaN	info@lavanderiagirasole.com	0533 328271	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.686706	f	f	\N	\N	[]	0	active	\N	pending	\N
1755034	\N	FERROPOL COATING S.R.L.	3053820365.0	03053820365	VIA DELL'AGRICOLTURA, 280/H	SAN FELICE SUL PANARO	41038.0	MO	Emilia-romagna	Italia	\N	28	2025-05-27	NaN	www.ferropolcoating.it	NaN	053585430	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.689347	f	f	\N	\N	[]	0	active	\N	pending	\N
1755076	\N	FINTRIA S.R.L.	13132411003.0	13132411003	VIA DELLA MERCEDE, 11	ROMA	187.0	RM	Lazio	Italia	\N	14	2025-05-28	NaN	NaN	NaN	NaN	\N	Nord-Est	["Fabio Aliboni"]	2025-07-03 20:34:37.692214	f	f	\N	\N	[]	0	active	\N	pending	\N
1755088	\N	FLYTECH SRL	1043460250.0	01043460250	VIA DELL'ARTIGIANATO, 65	ALPAGO	32016.0	BL	Veneto	Italia	\N	24	2025-05-28	NaN	www.flytech.it	NaN	0437-989000	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.695185	f	f	\N	\N	[]	0	active	\N	pending	\N
1755497	\N	FOR J S.R.L.	1309350112.0	01309350112	VIALE ITALIA, 136	LA SPEZIA	19124.0	SP	Liguria	Italia	\N	11	2025-05-28	NaN	www.forj.it	NaN	0187620990	\N	Nord-Est	["Fabio Aliboni"]	2025-07-03 20:34:37.697992	f	f	\N	\N	[]	0	active	\N	pending	\N
1755504	\N	Dott. Giancarlo Garioni	NaN	NaN	NaN	NaN	\N	NaN	NaN	NaN	\N	0	2025-05-28	Commercialista e Revisore Legale	NaN	giancarlo.garioni@gmail.com	+393318422445	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:37.701381	f	f	\N	\N	[]	0	active	\N	pending	\N
1755521	\N	FRAC S.R.L.	972050231.0	00972050231	VIA PREALPI, 21/B	GREZZANA	37023.0	VR	Veneto	Italia	\N	137	2025-05-28	NaN	www.frac1948.it	NaN	045-8650309	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.704372	f	f	\N	\N	[]	0	active	\N	pending	\N
1755543	\N	FRAME ABOUT YOU - S.N.C. DI FRANCESCO ASARA & C.	8689561002.0	08689561002	VIA GROTTE MARIA, 1	FRASCATI	44.0	RM	Lazio	Italia	\N	1	2025-05-28	NaN	www.frameaboutyou.com	NaN	3351755398	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.707231	f	f	\N	\N	[]	0	active	\N	pending	\N
1755551	\N	F.LLI LOVATO S.R.L.	3084860232.0	03084860232	VIA ENZO FERRARI, 5	LEGNAGO	37045.0	VR	Veneto	Italia	\N	40	2025-05-28	NaN	www.fratellilovato.it/	NaN	0442627625	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.710273	f	f	\N	\N	[]	0	active	\N	pending	\N
1755594	\N	FRIGOMAR S.R.L.	168230993.0	00418400107	VIA VITTORIO VENETO 112-114-116, 112-114	CARASCO	16042.0	GE	Liguria	Italia	\N	32	2025-05-28	NaN	www.frigomar.com	NaN	0185384888	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.71365	f	f	\N	\N	[]	0	active	\N	pending	\N
1755886	\N	G.E.MA.R.C. DI BAGLIONI GIOVANNI E C. S.N.C.	3560061008.0	03560061008	VIA OBERDAN, 4	MONTE COMPATRI	77.0	RM	Lazio	Italia	\N	12	2025-05-28	NaN	NaN	NaN	069485310	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.717246	f	f	\N	\N	[]	0	active	\N	pending	\N
1756108	\N	AB SUITE S.R.L.	5309810264.0	05309810264	VIALE G. MAZZINI, 59/A	VALDOBBIADENE	31049.0	TV	Veneto	Italia	\N	4	2025-05-28	Si occupano, tramite un modo del tutto naturale e non invasivo, di contrastare i segni del tempo, come rughe, cedimento della pelle, contorno occhi.\nCodice Ateco: 96.02.02 - Servizi degli istituti di Bellezza #Luana	www@absuite.eu	NaN	+393519895907	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:37.72077	f	f	\N	\N	[]	0	active	\N	pending	\N
1756111	\N	F.LLI GAGGIOLI DI  ROBERTO, ANDREA E FABRIZIO GAGGIOLI S.N.C.	1623740568.0	01623740568	PIAZZA OBERDAN, 18	ACQUAPENDENTE	1021.0	VT	Lazio	Italia	\N	7	2025-05-28	Non ci sono note ,non ci sono numeri telefonici e del contatto ,\t\t\nAndrea Gaggioli, c'è solo il nome.	www.gaggiolisposi.it	NaN	NaN	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.72352	f	f	\N	\N	[]	0	active	\N	pending	\N
1756113	\N	LEEUS CONSULTING SRL	3884760368.0	03884760368	VIALE MONTE KOSICA, 1/2	MODENA	41121.0	MO	Emilia-romagna	Italia	\N	3	2025-05-28	NaN	www.leeusconsulting.it	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.726442	f	f	\N	\N	[]	0	active	\N	pending	\N
1756114	\N	SOCIETA' COOPERATIVA DI GARANZIA COLLETTIVA DEI FIDI TRA PICCOLE E MEDIE IMPRESE - GARANZIA ETICA	497380923.0	00497380923	VIA PIER LUIGI NERVI, 18	ELMAS	9030.0	CA	Sardegna	Italia	\N	111	2025-05-28	NaN	www.garanziaetica.it	NaN	070-7731880; 393.8562910	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.729269	f	f	\N	\N	[]	0	active	\N	pending	\N
1756143	\N	LEGNOSTILE DEI FRATELLI PLOZZER S.N.C. DI PLOZZER DANILO, ERMANNO E DARIO	1819880301.0	01819880301	FRAZIONE SAURIS DI SOPRA, 50/D	SAURIS	33020.0	UD	Friuli-venezia giulia	Italia	\N	3	2025-05-28	Producono infissi in legno.\n# Sabrina	www.legnostileplozzer.com	info@legnostileplozzer.com	0433 86252	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.732958	f	f	\N	\N	[]	0	active	\N	pending	\N
1756147	\N	AUGUSTA RATIO S.P.A.	7941160967.0	07941160967	VIA GIUSEPPE POZZONE, 5	MILANO	20121.0	MI	Lombardia	Italia	\N	54	2025-05-28	Levigas	www.levigas.it	NaN	02 89424756	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.736732	f	f	\N	\N	[]	0	active	\N	pending	\N
1756149	\N	LEODARI PUBBLICITA' S.R.L.	2087420242.0	02087420242	VIA MARCELLO BENEDETTO, 12	VICENZA	36100.0	VI	Veneto	Italia	\N	24	2025-05-28	NaN	leodari.com	NaN	0444 962233	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.740341	f	f	\N	\N	[]	0	active	\N	pending	\N
1757844	\N	GEMMO METALSIDER S.R.L.	1716690241.0	01716690241	VIA DELL'ARTIGIANATO, 8	NOVENTA VICENTINA	36025.0	VI	Veneto	Italia	\N	9	2025-05-29	NaN	www.gemmometalsider.it	NaN	0444-760552	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.74377	f	f	\N	\N	[]	0	active	\N	pending	\N
1757996	\N	GENERAL INTERIORS S.R.L.	1130340316.0	01130340316	VIA ANTONIO TAMBARIN, 9	RONCHI DEI LEGIONARI	34077.0	GO	Friuli-venezia giulia	Italia	\N	58	2025-05-29	NaN	www.generalinteriors.it	NaN	0481778221	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.747334	f	f	\N	\N	[]	0	active	\N	pending	\N
1758030	\N	GEO HYDRICA S.R.L.	2779920236.0	04269950376	VIA MURARI BRA', 49/C	VERONA	37136.0	VR	Veneto	Italia	\N	8	2025-05-29	15 marzo 2023\nIncontrato Michele Bertuzzi insieme ad Arianna in Azienda da lui.\nNon è tranquillo a partire con Formazione 4.0 ma chiede a Luigi se possiamo fargli consulenza in quanto vorrebbe fare un investimento sul Lago di Garda\nScrivo mail a Valeriano Clementi e li metto in contatto tra loro.	www.venber.it	NaN	045-9582423	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.750855	f	f	\N	\N	[]	0	active	\N	pending	\N
1758049	\N	GERICA S.R.L.	14422251000.0	14422251000	VIA PIAN DEL CECE, 7	CAMPAGNANO DI ROMA	63.0	RM	Lazio	Italia	\N	8	2025-05-29	NaN	NaN	NaN	338 5076519	\N	Nord-Est	["Luigi Vitaletti"]	2025-07-03 20:34:37.753838	f	f	\N	\N	[]	0	active	\N	pending	\N
1758057	\N	G.E.R.S. S.R.L.	2841180108.0	02841180108	VIA VITTORIO BOTTEGO, 1A/R	GENOVA	16149.0	GE	Liguria	Italia	\N	28	2025-05-29	NaN	www.gersgenova.it	NaN	010412580	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.756907	f	f	\N	\N	[]	0	active	\N	pending	\N
1758139	\N	G.& G. GESTIONE GLOBALE SINISTRI S.R.L.	11771431001.0	11771431001	LARGO DON GINO CESCHELLI, 9	ROMA	142.0	RM	Lazio	Italia	\N	6	2025-05-29	Contatto Roberto Garro ,senza cell. e mail.	NaN	NaN	06 5414397	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.760871	f	f	\N	\N	[]	0	active	\N	pending	\N
1758549	\N	TIPOGRAFIA A.G. DI BALDAZZI GIAN LUCA & C. S.N.C.	537131203.0	01176030375	VIA I MAGGIO, 35	GRANAROLO DELL'EMILIA	40057.0	BO	Emilia-romagna	Italia	\N	8	2025-05-29	NaN	NaN	NaN	0516058710	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.764894	f	f	\N	\N	[]	0	active	\N	pending	\N
1758566	\N	GLOBAL SERVICE CAR S.R.L.	4588881211.0	04588881211	VIA M. DE CERVANTES SAAVEDRA, 55/27	NAPOLI	80133.0	NaN	Campania	Italia	\N	6	2025-05-29	NaN	NaN	NaN	081.5228490	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.76847	f	f	\N	\N	[]	0	active	\N	pending	\N
1758576	\N	GLOBAL SOLAR S.R.L.	4666080280.0	04666080280	PIAZZETTA CURTE RODULO, 2	CURTAROLO	35010.0	PD	Veneto	Italia	\N	7	2025-05-29	NaN	www.globalsolar.it	NaN	0495791397	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.772457	f	f	\N	\N	[]	0	active	\N	pending	\N
1758581	\N	GM - GAVANELLI BROKER S.R.L.	3120451202.0	03120451202	CORSO GIUSEPPE GARIBALDI, 22/A	OZZANO DELL'EMILIA	40064.0	BO	Emilia-romagna	Italia	\N	5	2025-05-29	NaN	www.gavanellibroker.it	NaN	051-790305	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.775179	f	f	\N	\N	[]	0	active	\N	pending	\N
1758585	\N	GM LAB SRL	1482700455.0	01482700455	VIA DEL CAVATORE, 27	CARRARA	54033.0	MS	Toscana	Italia	\N	0	2025-05-29	NaN	NaN	NaN	334 3321002	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.777886	f	f	\N	\N	[]	0	active	\N	pending	\N
1758928	\N	LASER MECCANICA SRL	13958371000.0	13958371000	VIA NICOLA MARCHESE, 10	ROMA	141.0	RM	Lazio	Italia	\N	12	2025-05-29	NaN	www.lasermeccanica.it	NaN	06 9342569	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.780341	f	f	\N	\N	[]	0	active	\N	pending	\N
1758929	\N	GRAFICHE DALPIAZ S.R.L.	1357990223.0	01357990223	VIA RAGAZZI DEL '99, 15	TRENTO	38123.0	TN	Trentino-alto adige	Italia	\N	18	2025-05-29	NaN	www.grafichedalpiaz.com	NaN	0461913545	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.783102	f	f	\N	\N	[]	0	active	\N	pending	\N
1758933	\N	LANZI S.R.L.	1402020059.0	01402020059	VIA ASTI MARE, 36	AGLIANO TERME	14041.0	AT	Piemonte	Italia	\N	22	2025-05-29	NaN	www.lanzi.eu	NaN	0141 954541	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.785864	f	f	\N	\N	[]	0	active	\N	pending	\N
1758938	\N	ALI GROUP HOLDING S.R.L.	10123720962.0	10123720962	VIA GOBETTI, 2/A	CERNUSCO SUL NAVIGLIO	20063.0	MI	Lombardia	Italia	\N	1812	2025-05-29	Azienda conosciuta in Fiera Horeca Bolzano.\n# Sabrina	www.aligroup.it	NaN	02 921991	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.788289	f	f	\N	\N	[]	0	active	\N	pending	\N
1759034	\N	EZDIRECT S.R.L.	1164670455.0	01164670455	VIA NERINO GARBUIO,	MONTIGNOSO	54038.0	MS	Toscana	Italia	\N	9	2025-05-30	NaN	www.ezdirect.it	info@ezdirect.it	0585821330	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.79107	f	f	\N	\N	[]	0	active	\N	pending	\N
1759188	\N	GROUPAUTO ITALIA S .C. A R. L.	4781590965.0	04781590965	VIA CASSANESE, 224	SEGRATE	20054.0	MI	Lombardia	Italia	\N	9	2025-05-30	NaN	www.groupauto.it	NaN	02-2135751	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.793803	f	f	\N	\N	[]	0	active	\N	pending	\N
1759333	\N	GROWNNECTIA S.R.L.	13288871000.0	13288871000	VIA DI VALLE LUPARA, 10	ROMA	148.0	RM	Lazio	Italia	\N	2	2025-05-30	NaN	www.massimociaglia.me	NaN	0687738739	\N	Nord-Est	["Luigi Vitaletti"]	2025-07-03 20:34:37.796513	f	f	\N	\N	[]	0	active	\N	pending	\N
1759334	\N	GROWNET SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	8278580728.0	08278580728	VIA DELLA RESISTENZA, 188/B	BARI	70125.0	BA	Puglia	Italia	\N	0	2025-05-30	Grownet che poi è in realtà un gruppo di Aziende con Sede a Bari.\nSono fondamentalmente dei Commerciali in ambito tecnologico e offrono serivzi \n- in ambito tecnico IT con amministrazione di servizi informatici per le aziende.\n- sviluppo commerciale tramite agenzia che organizza il rapporto di vendita tra le mandanti e il cliente finale.\nCi raccontano che vivono di accordi e potrebbe interessargli un Accordo reciproco tra EndUser e Grownet visto che conoscono bene gli incentivi Industria 4.0 e si potrebbero proporre ai loro clienti.	www.grownet.it	NaN	0805940236	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.79964	f	f	\N	\N	[]	0	active	\N	pending	\N
1759337	\N	GRUPPO CIEMME SOCIETA' A RESPONSABILITA' LIMITATA	2915671206.0	02915671206	VIA DEI LAPIDARI C/O DE SIMONE, 19	BOLOGNA	40129.0	BO	Emilia-romagna	Italia	\N	2	2025-05-30	20/02/2024 Info contatto\nIncontro Simona e il suo compagno nel loro ufficio di Anzola dell'Emilia. \n\nL'ufficio di Anzola è la Sede Operativa della Società Ciemme e di Ttantto\nTitolare di Ciemme è il compagno di Simona, lei è chi gestisce le pr per lui e per TTANTTO di cui la titolare è lei.\n\nLavorano in simbiosi 3 Aziende:\nCiemme\nTtantto\nRegalami il tuo Sogno (società di Formazione dal 2008)\n\nSi occupano di assistenza, sviluppo Software e gestionali, consulenza, formazione, progettazione e realizzazione di soluzioni IS/ICT adatte alle richieste di ogni cliente\nLavorano in Emilia Romagna, Toscana, Marche, Lombardia, Piemonte. Ma potrebbero tranquillamente servire altre regioni.\n\nQuindi:\n2 Aziende\n2 Titolari\n2 Sedi legali\nSolo 2/3 dipendenti tutto il resto Collaboratori a P.IVA\nCreano e vendono con causale quello che meglio gli fa comodo nei 3 ambiti a loro concessi in modo da ricevere poi vantaggi, bonus ed agevolazioni.\n\nStanno uscendo tramite via legali da una brutta esperienza con Golden Group che gli ha promesso un ritorno tramite bandi/incentivi e altro che dopo alcuni anni non è arrivato e sono in causa perchè negli ultimi 2 Bandi Inail sono stati multati per causa di documentazione mancante nel progetto di richiesta ( documentazione presentata da Golden Group)\n\nCercano qualcun che li supporti mettendoli al corrente di bandi, concorsi, clic day, sovvenzioni statali, bonus e quant'altro per fare consulenza ai loro clienti a 360° dopo avergli venduto i loro servizi digitali.\n\nLe dico subito che noi non siamo Golden Group che trattiamo solo 4/5 incentivi BENE, ci occupiamo di Industria 4.0, 5.0, Nuova Sabatini, Patent Box e poco altro ma con poco portiamo tanto...\n\nChiede se possiamo creare Partnership dove la accompagnamo dai suoi clienti che al momento hanno richieste con le loro Aziende e gli portiamo consulenza e dove rientrano credito d'imposta tramite Formazione 4.0\nLe dico che dobbiamo andare da tutti i loro clienti a cui hanno venduto Software e qualsiasi altra cosa dal 2020 ad oggi...per portargli credito e nel 2025 ci torneremo per pratica sul 2024\n\nLe dico inoltre che riconosciamo 1 percentuale dall'1% al 1,5% in base ai volumi generati e il suo compagno mi dice grazie molto gentile a noi già basta che il nostro cliente sia contento e si ripaghi il nostro servizio anche solo in parte.\n\nMi parla di 2 clienti da andare a trovare a Parma sull'immediato\nClai con 500 dipendenti\nCooperativa con 2000 carrellisti\n\nRimaniamo che ci aggiorniamo per un paio di date settimana prossima per andare a Parma dai 2 clienti	www.gruppociemme.it	NaN	0514148901	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.8033	f	f	\N	\N	[]	0	active	\N	pending	\N
1759722	\N	O.E.M.A. DI MORELLI MARCO & C. -  S.N.C.	1725610404.0	01725610404	VIA LUIGI GALVANI, 30	FORLI'	47122.0	FC	Emilia-romagna	Italia	\N	14	2025-06-04	Il Gruppo comprende:\n-Oema Elettromeccanica\n-Oema Forniture\n-Italnolo.	www.oema.it	NaN	0543-721118	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.807421	f	f	\N	\N	[]	0	active	\N	pending	\N
1759744	\N	GRAVINA GEMMA	2670910781.0	GRVGMM83T43G317A	VIA S.AGATA, 74	PAOLA	87027.0	CS	Calabria	Italia	\N	4	2025-06-04	NaN	NaN	NaN	NaN	\N	NaN	[]	2025-07-03 20:34:37.810186	f	f	\N	\N	[]	0	active	\N	pending	\N
1759760	\N	GUESTNET S.R.L.	3142940216.0	03142940216	VIA DANTE, 24	BRESSANONE	39042.0	BZ	Trentino-alto adige	Italia	\N	6	2025-06-04	NaN	NaN	NaN	0472-940960	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.813442	f	f	\N	\N	[]	0	active	\N	pending	\N
1759762	\N	GRUPPO VILLA MARIA S.P.A  O ANCHE  G.V.M. S.P.A.	423510395.0	00423510395	CORSO GIUSEPPE GARIBALDI, 11	LUGO	48022.0	RA	Emilia-romagna	Italia	\N	5	2025-06-04	NaN	www.gvmpoint.it	NaN	0545909812	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.816853	f	f	\N	\N	[]	0	active	\N	pending	\N
1759901	\N	LOKALL DI GEMIGNANI ORIANO E C. - S.N.C.	1238840464.0	01238840464	VIA PER CAMAIORE, 24/B	PESCAGLIA	55060.0	LU	Toscana	Italia	\N	3	2025-06-04	NaN	www.lokall.it	NaN	0583.38479	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.819634	f	f	\N	\N	[]	0	active	\N	pending	\N
1759902	\N	LUBROMEC S.R.L.	3514070121.0	03514070121	VIA XX SETTEMBRE, 6	GALLARATE	21013.0	VA	Lombardia	Italia	\N	1	2025-06-04	NaN	www.lubromec.com	NaN	333.9797573	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.822739	f	f	\N	\N	[]	0	active	\N	pending	\N
1759903	\N	LICCI LOGISTICA S.R.L.	4131700231.0	04131700231	VIA LEONARDO DA VINCI, 8/B	ZEVIO	37059.0	VR	Veneto	Italia	\N	2	2025-06-04	Non ci sono contatti	NaN	NaN	045-7850232	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.825146	f	f	\N	\N	[]	0	active	\N	pending	\N
1759905	\N	LINO PERRON	1043320074.0	PRRLNI56P23A326S	FRAZIONE BREUIL-CERVINIA-LOC. CAMPETTO, 3	VALTOURNENCHE	11028.0	AO	Valle d'aosta	Italia	\N	5	2025-06-04	NaN	www.linosbar.com	NaN	339-1532023	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.827533	f	f	\N	\N	[]	0	active	\N	pending	\N
1759909	\N	LOGOTEC S.R.L.	1408010336.0	01408010336	VIA REGGI, 1/3	PIACENZA	29121.0	PC	Emilia-romagna	Italia	\N	17	2025-06-04	Del contatto abbiamo solo il nome  ,Roberto Marchionni.	www.logotec.it	NaN	0523499465	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.829866	f	f	\N	\N	[]	0	active	\N	pending	\N
1770214	\N	MAGNA GRECIA SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	5000540756.0	05000540756	VIALE DELL'UNIVERSITA', 65/B	LECCE	73100.0	LE	Puglia	Italia	\N	11	2025-06-06	NaN	NaN	NaN	393.2912005	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.832323	f	f	\N	\N	[]	0	active	\N	pending	\N
1771260	\N	MAIL DATE BUREAU S.R.L.	3796740235.0	03796740235	VIA STAFFALI, 10	VILLAFRANCA DI VERONA	37062.0	VR	Veneto	Italia	\N	29	2025-06-06	NaN	www.maildatebureau.com	NaN	045-986601	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.835536	f	f	\N	\N	[]	0	active	\N	pending	\N
1771269	\N	MARELLI AFTERMARKET ITALY S.P.A.	8396100011.0	08396100011	VIALE ALDO BORLETTI, 61/63	CORBETTA	20011.0	MI	Lombardia	Italia	\N	116	2025-06-06	NaN	www.magnetimarelli-parts-and-services.it	NaN	335 198 8570	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.838325	f	f	\N	\N	[]	0	active	\N	pending	\N
1771583	\N	MARCO VITA ASSICURAZIONI S.R.L.	2286210220.0	02286210220	VIA BRUNO DE FINETTI, 12	TRENTO	38123.0	TN	Trentino-alto adige	Italia	\N	4	2025-06-09	NaN	NaN	NaN	0461.912235	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.840654	f	f	\N	\N	[]	0	active	\N	pending	\N
1771589	\N	MARCOZZI S.R.L.	1621930443.0	01621930443	CONTRADA VALDASO, 47/A	CAMPOFILONE	63828.0	FM	Marche	Italia	\N	21	2025-06-09	NaN	www.marcozzidicampofilone.it	NaN	0734931725	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.843318	f	f	\N	\N	[]	0	active	\N	pending	\N
1771597	\N	MARMI LANZA SRL	2613470356.0	02613470356	VIA FRATELLI MANFREDI, 4	REGGIO EMILIA	42124.0	RE	Emilia-romagna	Italia	\N	29	2025-06-09	NaN	www.marmilanzasrl.com	NaN	045.6836054	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.845711	f	f	\N	\N	[]	0	active	\N	pending	\N
1771601	\N	GRAZIANO S.R.L.	12558130014.0	12558130014	VIA NIZZA, 69	TORINO	10125.0	TO	Piemonte	Italia	\N	28	2025-06-08	NaN	NaN	eliagraziano@gmail.com	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.848063	f	f	\N	\N	[]	0	active	\N	pending	\N
1771607	\N	MARMOFORNITURE GIORGI CARLO DI SCHIASSI ANDREA, ORSI DANIELE E SCHIASSI MASSIMO S.N.C.	1603821206.0	01603821206	VIA OSSOLA, 2	SAN GIORGIO DI PIANO	40016.0	BO	Emilia-romagna	Italia	\N	11	2025-06-09	NaN	www.marmoforniture.com	NaN	051-892780	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.851028	f	f	\N	\N	[]	0	active	\N	pending	\N
1771614	\N	MARSHYELLOW S.R.L.	3967790365.0	03967790365	VIA GIARDINI, 476/N	MODENA	41124.0	MO	Emilia-romagna	Italia	\N	0	2025-06-09	NaN	www.myfassaplus.com	NaN	392.9783724	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.85405	f	f	\N	\N	[]	0	active	\N	pending	\N
1771617	\N	MASCELLANI S.R.L.	1840791204.0	01840791204	VIA 2 GIUGNO, 10	ANZOLA DELL'EMILIA	40011.0	BO	Emilia-romagna	Italia	\N	19	2025-06-09	NaN	www.mascellani.com	NaN	051731201	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.857016	f	f	\N	\N	[]	0	active	\N	pending	\N
1771624	\N	MASELLI MISURE S.P.A.	885820159.0	00885820159	GALLERIA DEL CORSO, 2	MILANO	20122.0	MI	Lombardia	Italia	\N	79	2025-06-09	NaN	www.maselli.com	NaN	0276003558	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.860053	f	f	\N	\N	[]	0	active	\N	pending	\N
1771648	\N	MASI GLASS SRL	10162491004.0	10162491004	VIA LUCIO MARIANI, 45/C	ROMA	178.0	RM	Lazio	Italia	\N	6	2025-06-09	NaN	NaN	NaN	067231477	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.863145	f	f	\N	\N	[]	0	active	\N	pending	\N
1771654	\N	MASSIMO S.R.L.	2334780976.0	02334780976	VIA VALENTINI, 16	PRATO	59100.0	PO	Toscana	Italia	\N	21	2025-06-09	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.866176	f	f	\N	\N	[]	0	active	\N	pending	\N
1771696	\N	MEGASTORE SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	2534570466.0	02534570466	VIA PADULE, 135	PIETRASANTA	55045.0	LU	Toscana	Italia	\N	0	2025-06-09	NaN	www.megastoreshopping.com	NaN	349 3784495	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.87217	f	f	\N	\N	[]	0	active	\N	pending	\N
1771717	\N	METALTARGHE-SOCIETA A RESPONSABILITA LIMITATA	510311202.0	00451680375	VIA DEL SASSO, 7	PIANORO	40065.0	BO	Emilia-romagna	Italia	\N	18	2025-06-09	NaN	www.metaltarghe.it	NaN	051774134	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.874498	f	f	\N	\N	[]	0	active	\N	pending	\N
1771721	\N	MFM S.R.L.	2296350347.0	02296350347	VIALE FRATTI, 56	PARMA	43121.0	PR	Emilia-romagna	Italia	\N	1	2025-06-09	NaN	NaN	NaN	329.6515863	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.876918	f	f	\N	\N	[]	0	active	\N	pending	\N
1771759	\N	MODULGRAFICA FORLIVESE S.P.A.	880220405.0	00880220405	VIA CORRECCHIO, 8/A	FORLI'	47122.0	FC	Emilia-romagna	Italia	\N	14	2025-06-09	NaN	www.modulforlivese.it	NaN	0543720596	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.879474	f	f	\N	\N	[]	0	active	\N	pending	\N
1771763	\N	MODULO SEI S.R.L.	3200910366.0	03200910366	VIA PER SAN FELICE, 38/42	CAMPOSANTO	41031.0	MO	Emilia-romagna	Italia	\N	12	2025-06-09	NaN	www.modulosei.com	NaN	0535.87378	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.882298	f	f	\N	\N	[]	0	active	\N	pending	\N
1771770	\N	MONTEFARMACO OTC S.P.A.	12305380151.0	12305380151	VIA QUATTRO NOVEMBRE, 92	BOLLATE	20021.0	MI	Lombardia	Italia	\N	71	2025-06-09	NaN	montefarmaco.com	NaN	02-333091	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.886652	f	f	\N	\N	[]	0	active	\N	pending	\N
1771772	\N	MORANDI S.R.L.	6276300487.0	06276300487	VIA RICCARDO BORDONI, 5-5/A	CALENZANO	50041.0	FI	Toscana	Italia	\N	8	2025-06-09	NaN	NaN	NaN	0550602518	\N	Nord-Est	["Fabio Aliboni"]	2025-07-03 20:34:37.889634	f	f	\N	\N	[]	0	active	\N	pending	\N
1771774	\N	MOVENDO TECHNOLOGY SOCIETA' A RESPONSABILITA' LIMITATA IN FORMA ABBREVIATA MOVENDO TECHNOLOGY S.R.L.	2427220997.0	02427220997	VIA BOMBRINI, 13/10	GENOVA	16149.0	GE	Liguria	Italia	\N	19	2025-06-09	NaN	www.movendo.technology	NaN	010-0995700	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.893146	f	f	\N	\N	[]	0	active	\N	pending	\N
1771833	\N	MTS ONLINE GMBH	2566610214.0	02566610214	VIA ANTON PEINTNER, 4	VANDOIES	39030.0	BZ	Trentino-alto adige	Italia	\N	12	2025-06-10	NaN	www.t-mts.com	NaN	0471860336	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.895638	f	f	\N	\N	[]	0	active	\N	pending	\N
1771845	\N	M.V. S.R.L.	1913020200.0	01913020200	VIA FRATELLI CERVI, 7	GONZAGA	46023.0	MN	Lombardia	Italia	\N	22	2025-06-10	NaN	www.mvsrl.it	NaN	0376530441	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.898696	f	f	\N	\N	[]	0	active	\N	pending	\N
1771869	\N	N.C. AUTO S.R.L.	4340120403.0	04340120403	VIA BORGHINA, 22	FORLI'	47121.0	NaN	Emilia-romagna	Italia	\N	13	2025-06-10	NaN	www.ncautoforli.com	NaN	0543478082	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.901841	f	f	\N	\N	[]	0	active	\N	pending	\N
1771875	\N	WSM S.R.L.	9795370965.0	09795370965	VIA FILIPPO TURATI, 40	MILANO	20121.0	MI	Lombardia	Italia	\N	15	2025-06-10	NaN	www.negrifirman.com	NaN	02.50020500	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.904731	f	f	\N	\N	[]	0	active	\N	pending	\N
1771879	\N	PARADIGMA SOCIETA' COOPERATIVA	5157490870.0	05157490870	VIALE AFRICA, 31/E	CATANIA	95129.0	CT	Sicilia	Italia	\N	9	2025-06-10	NaN	NaN	NaN	095 5944020	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.907713	f	f	\N	\N	[]	0	active	\N	pending	\N
1771882	\N	PARADIGMA S.P.A.	5974540873.0	05974540873	VIALE AFRICA, 31	CATANIA	95129.0	CT	Sicilia	Italia	\N	25	2025-06-09	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:37.910662	f	f	\N	\N	[]	0	active	\N	pending	\N
1771900	\N	PLAYHOTEL S.R.L.	10990591009.0	10990591009	VIA LIMA, 7	ROMA	198.0	RM	Lazio	Italia	\N	329	2025-06-09	NaN	www.play-hotel.com	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.913254	f	f	\N	\N	[]	0	active	\N	pending	\N
1771914	\N	NEW MIND S.R.L. IN LIQUIDAZIONE	15415321007.0	15415321007	VIA MOSCA, 10	ROMA	142.0	RM	Lazio	Italia	\N	1	2025-06-10	NaN	www.new-mind.it	NaN	06696771	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.915664	f	f	\N	\N	[]	0	active	\N	pending	\N
1771930	\N	HEXADRIVE ENGINEERING SRL	5272020289.0	05272020289	VIA DEL CRISTO, 378	PADOVA	35127.0	PD	Veneto	Italia	\N	12	2025-06-10	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.91802	f	f	\N	\N	[]	0	active	\N	pending	\N
1771934	\N	NICO.FER  S.R.L.	878820232.0	00878820232	VIA TURBINA, 156	VERONA	37139.0	VR	Veneto	Italia	\N	19	2025-06-10	NaN	www.nicofer.it	NaN	0458518751	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.920452	f	f	\N	\N	[]	0	active	\N	pending	\N
1771945	\N	NOVAENERGY S.R.L.	6749230725.0	06749230725	SP 120 POLIGNANO-CASTELLANA, KM6+5,5	POLIGNANO A MARE	70044.0	BA	Puglia	Italia	\N	48	2025-06-10	NaN	www.nova-energy.it	NaN	0808875839	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.923058	f	f	\N	\N	[]	0	active	\N	pending	\N
1771953	\N	NOVAMAR S.N.C. DI MARTINI SERGIO E C.	4177600287.0	04177600287	VIA BOSCHETTI, 15	FONTANIVA	35014.0	PD	Veneto	Italia	\N	6	2025-06-10	NaN	www.novamar.it	NaN	0497382401	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.925849	f	f	\N	\N	[]	0	active	\N	pending	\N
1772941	\N	OMCN S.P.A.	1905830160.0	01905830160	VIA DIVISIONE TRIDENTINA, 23	VILLA DI SERIO	24020.0	BG	Lombardia	Italia	\N	217	2025-06-11	NaN	www.omcn.it/	NaN	0354234411	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.930213	f	f	\N	\N	[]	0	active	\N	pending	\N
1772949	\N	ONE4 S.R.L.	5664390969.0	05664390969	VIA MAPELLI, 13	MONZA	20900.0	MB	Lombardia	Italia	\N	47	2025-06-11	Non ci sono contatti.	www.one4.it	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.933133	f	f	\N	\N	[]	0	active	\N	pending	\N
1772953	\N	OPEN SERVICE S.R.L.	4025450232.0	04025450232	VIA ANGELO MESSEDAGLI, 32 A	VILLAFRANCA DI VERONA	37069.0	VR	Veneto	Italia	\N	8	2025-06-11	NaN	www.openservicevr.com	NaN	045.8960917	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.936139	f	f	\N	\N	[]	0	active	\N	pending	\N
1772955	\N	ORTECO - S.R.L.	593131204.0	03065630372	VIA 2 GIUGNO, 19	ANZOLA DELL'EMILIA	40011.0	BO	Emilia-romagna	Italia	\N	24	2025-06-11	NaN	NaN	NaN	051-731051	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.93868	f	f	\N	\N	[]	0	active	\N	pending	\N
1772958	\N	OPEN SOURCE MANAGEMENT S.R.L. IN BREVE OSM S.R.L.	3818030409.0	03818030409	VIA CADUTI DI AMOLA, 11/2	BOLOGNA	40132.0	BO	Emilia-romagna	Italia	\N	10	2025-06-11	NaN	www.osmpartner.com	NaN	0518490411	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.941181	f	f	\N	\N	[]	0	active	\N	pending	\N
1772959	\N	CASA DI CURA PRIVATA PROF. E.MONTANARI S.P.A.	413900408.0	00413900408	VIA ROMA, 7	MORCIANO DI ROMAGNA	47833.0	RN	Emilia-romagna	Italia	\N	159	2025-06-11	NaN	www.casadicuramontanari.it	NaN	0541988129	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.94439	f	f	\N	\N	[]	0	active	\N	pending	\N
1772965	\N	OSTERIA PERBACCO S.N.C. DI VENTURELLI MICHELE & C.	3502430238.0	03502430238	PIAZZA VITTORIO EMANUELE, 2	SANT'AMBROGIO DI VALPOLICELLA	37015.0	VR	Veneto	Italia	\N	25	2025-06-11	NaN	www.osteriaperbacco.net/?utm_source=tripadvisor&utm_medium=referral	NaN	392.0282743	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.947528	f	f	\N	\N	[]	0	active	\N	pending	\N
1773023	\N	OTTO SERVICE DI MENICI OTTORINO	1871490981.0	MNCTRN68D01L094G	VIA ADAMELLO, 13	TEMU'	25050.0	BS	Lombardia	Italia	\N	3	2025-06-12	NaN	www.ottoservice.it	NaN	0364-948011	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.95071	f	f	\N	\N	[]	0	active	\N	pending	\N
1773028	\N	PEDDIO SEBASTIANO COSTRUZIONI S.R.L. O, CON DENOMINAZIONE ABBREVI ATA P.S. COSTRUZIONI S.R.L.	3234350928.0	03234350928	VIA ELEONORA D'ARBOREA, 14	CAGLIARI	9125.0	CA	Sardegna	Italia	\N	12	2025-06-12	Non sono presenti contatti.	NaN	NaN	070663830	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.953667	f	f	\N	\N	[]	0	active	\N	pending	\N
1773030	\N	RADIO WELLNESS NETWORK S.R.L.	5131100280.0	05131100280	VIA ROMA, 340	VIGODARZERE	35010.0	PD	Veneto	Italia	\N	9	2025-06-12	NaN	www.radiowellness.it	NaN	0498276471	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.957314	f	f	\N	\N	[]	0	active	\N	pending	\N
1773064	\N	ADVERTISING RAMORINO ALESSANDRO	3413530175.0	RMRLSN65B17B157V	VIA SEMINARIO, 6C	BOTTICINO	25082.0	BS	Lombardia	Italia	\N	1	2025-06-12	NaN	www.looksonweb.com	NaN	030-8372688	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.960193	f	f	\N	\N	[]	0	active	\N	pending	\N
1773082	\N	RENO SUPERMERCATI S.R.L.	2695691200.0	02695691200	VIA DE NICOLA, 1	BOLOGNA	40132.0	BO	Emilia-romagna	Italia	\N	96	2025-06-12	NaN	NaN	NaN	335.7557932	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.962276	f	f	\N	\N	[]	0	active	\N	pending	\N
1773083	\N	WARDA S.R.L.	2834570216.0	02834570216	PASSEGGIATA DEL CARMINE, 2	PADOVA	35137.0	PD	Veneto	Italia	\N	13	2025-06-12	NaN	www.warda.it	NaN	3407644874	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.964432	f	f	\N	\N	[]	0	active	\N	pending	\N
1773086	\N	RIGHETTI S.R.L.	4486340237.0	04486340237	VIA DELLA MECCANICA, 20	VERONA	37139.0	VR	Veneto	Italia	\N	18	2025-06-12	NaN	www.righettivacuumlifters.com	NaN	045-7157621	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.966756	f	f	\N	\N	[]	0	active	\N	pending	\N
1773103	\N	COCCO & DESSI' S.R.L.	1126930955.0	01126930955	VIA TIRSO, 31	ORISTANO	9170.0	OR	Sardegna	Italia	\N	18	2025-06-12	NaN	www.coccoedessi.it	NaN	0783-252648	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:37.969181	f	f	\N	\N	[]	0	active	\N	pending	\N
1773117	\N	MOS S.R.L.	4267700989.0	04267700989	VIA PORTO VECCHIO, 28	DESENZANO DEL GARDA	25015.0	BS	Lombardia	Italia	\N	9	2025-06-12	NaN	NaN	NaN	0309143339	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.971506	f	f	\N	\N	[]	0	active	\N	pending	\N
1773120	\N	RISTORANTE CARUSO DI ACANFORA SALVATORE & C. S.A.S.	3507050379.0	03507050379	VIA DEL PARCO, 13	BOLOGNA	40138.0	BO	Emilia-romagna	Italia	\N	21	2025-06-12	NaN	NaN	NaN	051-531341	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.974473	f	f	\N	\N	[]	0	active	\N	pending	\N
1773124	\N	PIZZERIA ADA DI CUOMO MARIO & C. SNC	2368080244.0	02368080244	VIA TORROSSA, 6	CAMISANO VICENTINO	36043.0	VI	Veneto	Italia	\N	34	2025-06-12	NaN	www.adaristorante.com	NaN	0444-611541	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.977164	f	f	\N	\N	[]	0	active	\N	pending	\N
1773126	\N	ALBERGO VALCANOVER S.A.S. DI BIASI MARIA & C.	1497830222.0	01497830222	VIA DI MEZZOLAGO, 1	PERGINE VALSUGANA	38057.0	TN	Trentino-alto adige	Italia	\N	2	2025-06-12	NaN	NaN	NaN	0461548177	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.979467	f	f	\N	\N	[]	0	active	\N	pending	\N
1773137	\N	RSG STUDIO LEGALE ASSOCIATO RUFINI SANTI GRANATIERO	1736001205.0	01736001205	VIA MASSIMO D'AZEGLIO, 21	BOLOGNA	40123.0	BO	Emilia Romagna	Italia	\N	0	2025-06-12	NaN	www.studiolegalerlsg.it	NaN	0542643307	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.982218	f	f	\N	\N	[]	0	active	\N	pending	\N
1773141	\N	DE LUCA ROBERTO	3562820781.0	DLCRRT89L30A326X	VIA VITTORIO VENETO, 177	DIAMANTE	87023.0	CS	Calabria	Italia	\N	2	2025-06-12	NaN	NaN	NaN	349-6856744	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.984925	f	f	\N	\N	[]	0	active	\N	pending	\N
1773224	\N	S & H S.R.L.	4445500152.0	04445500152	VIA PRIMO MAGGIO, 0008	PESCHIERA BORROMEO	20068.0	MI	Lombardia	Italia	\N	30	2025-06-13	NaN	www.seh.it	NaN	02-55301618	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.987486	f	f	\N	\N	[]	0	active	\N	pending	\N
1773584	\N	RED COMPANY S.R.L.	10433410965.0	10433410965	VIA CALDERA, 21	MILANO	20153.0	MI	Lombardia	Italia	\N	0	2025-06-13	NaN	NaN	NaN	02-36743010	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.989984	f	f	\N	\N	[]	0	active	\N	pending	\N
1773592	\N	SALUMIFICIO DA PIAN S.R.L.	512940263.0	00512940263	VIA INTERNATI 1943-1945, 12	SILEA	31057.0	TV	Veneto	Italia	\N	11	2025-06-13	NaN	www.dapian.it	NaN	0422-362477	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:37.992869	f	f	\N	\N	[]	0	active	\N	pending	\N
1773676	\N	SALUMIFICIO F.LLI SCAPOCCHIN S.R.L.	4358920280.0	04358920280	VIA BELLINI, 12	PADOVA	35131.0	PD	Veneto	Italia	\N	15	2025-06-16	NaN	NaN	NaN	049 641642	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.996041	f	f	\N	\N	[]	0	active	\N	pending	\N
1773684	\N	SARDEX S.P.A.	3257760920.0	03257760920	VIA SANT'IGNAZIO, 16	SERRAMANNA	9038.0	CA	Sardegna	Italia	\N	39	2025-06-16	NaN	www.sardex.net	NaN	0703327433	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:37.999393	f	f	\N	\N	[]	0	active	\N	pending	\N
1773688	\N	GAR - BO SRL	3238711208.0	03238711208	VIA FOSSA CAVA, 3/6	BOLOGNA	40132.0	BO	Emilia-romagna	Italia	\N	19	2025-06-16	NaN	www.sartoriagastronomica.it	NaN	0510878872	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.002369	f	f	\N	\N	[]	0	active	\N	pending	\N
1773701	\N	SCANSOFT - SOCIETA' COOPERATIVA	3269340984.0	03269340984	PIAZZA MONSIGNOR ALMICI, 15	BRESCIA	25124.0	BS	Lombardia	Italia	\N	9	2025-06-16	NaN	www.archiviazioneotticascansoft.it	NaN	030-6950656	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.005095	f	f	\N	\N	[]	0	active	\N	pending	\N
1773706	\N	SCELL-IT ITALIA S.R.L.	3830831206.0	03830831206	VIA DELL ARCOVEGGIO, 74/2	BOLOGNA	40129.0	BO	Emilia-romagna	Italia	\N	3	2025-06-16	NaN	www.scellit.it	NaN	0510396060	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.008734	f	f	\N	\N	[]	0	active	\N	pending	\N
1773709	\N	SCHNEIDER ELECTRIC S.P.A.	2424870166.0	00509110011	VIA CIRCONVALLAZIONE EST, 1	STEZZANO	24040.0	BG	Lombardia	Italia	\N	1725	2025-06-16	NaN	www.schneider-electric.it	NaN	0354151111	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.012702	f	f	\N	\N	[]	0	active	\N	pending	\N
1773745	\N	BC SOFT S.R.L.	6837180634.0	06837180634	Via Augusto Majani, 2	Bologna	40121.0	BO	Emilia-Romagna	Italia	\N	207	2025-06-16	NaN	www.bcsoft.net	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.016238	f	f	\N	\N	[]	0	active	\N	pending	\N
1773753	\N	SERRAMENTI 82 BY FRANCESCHINI S.R.L.	11891261007.0	11891261007	VIA CANCELLIERA, 37/39	ARICCIA	40.0	RM	Lazio	Italia	\N	12	2025-06-16	NaN	NaN	NaN	06-93494003	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.018972	f	f	\N	\N	[]	0	active	\N	pending	\N
1773764	\N	CERTY  S.R.L.	3778590921.0	03778590921	PIAZZA ATTILIO DEFFENU, 12	CAGLIARI	9125.0	CA	Sardegna	Italia	\N	3	2025-06-16	Codice Ateco: 6312\n# Sabrina	www.certy.me	NaN	NaN	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:38.021878	f	f	\N	\N	[]	0	active	\N	pending	\N
1773766	\N	SHAMROCK SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	1339480772.0	01339480772	CONTRADA CANALDENTE,	TRICARICO	75019.0	MT	Basilicata	Italia	\N	1	2025-06-16	NaN	NaN	NaN	3476080293	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.024846	f	f	\N	\N	[]	0	active	\N	pending	\N
1773777	\N	BIOS MANAGEMENT S.R.L.	3029760042.0	03029760042	STRADA STATALE 231, 80/D	SANTA VITTORIA D'ALBA	12069.0	CN	Piemonte	Italia	\N	135	2025-06-16	NaN	www.biosmanagement.com	NaN	0172 1809800	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.027526	f	f	\N	\N	[]	0	active	\N	pending	\N
1773788	\N	SICUREZZA 1963 SRL	4603150238.0	04603150238	VIA MONTORIO, 34	VERONA	37131.0	VR	Veneto	Italia	\N	105	2025-06-16	UNICA PARTITA IVA\n\n157 dipendenti part-time ad oggi.\n\n1 gestionale comprato circa 1 anno e mezzo fa\n\nSicurezza e pulizie alberghiere.\n\nNel 2020 max 110 dipendenti part-time\nNel 2021 max 180 dipendenti part-time	www.sicurezza1963.it	NaN	045-8050095	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.030153	f	f	\N	\N	[]	0	active	\N	pending	\N
1773789	\N	QIPO S.R.L.	4078580042.0	04078580042	PIAZZA GIOLITTI, 8	BRA	12042.0	CN	Piemonte	Italia	\N	2	2025-06-16	NaN	NaN	NaN	0172 432493	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.032969	f	f	\N	\N	[]	0	active	\N	pending	\N
1773791	\N	SIDEROS ENGINEERING SOCIETA' A RESPONSABILITA' LIMITATA OPPURE: SIDEROS ENGINEERING S.R.L. O SIDEROS S.R.L.	746030337.0	00746030337	VIA I MAGGIO, 69	PODENZANO	29027.0	PC	Emilia-romagna	Italia	\N	37	2025-06-16	NaN	www.siderosengineering.com/	NaN	0523-521066	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.036449	f	f	\N	\N	[]	0	active	\N	pending	\N
1773801	\N	SIMECOM S.R.L.	1274520194.0	01274520194	VIA RAMPAZZINI, 7	CREMA	26013.0	CR	Lombardia	Italia	\N	63	2025-06-16	NaN	www.simecom.eu	NaN	0373231038	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.040288	f	f	\N	\N	[]	0	active	\N	pending	\N
1773802	\N	FOR-TOP SRL	4430190274.0	NaN	Strada I Zona Industriale, 46/a	Fosso'	\N	VE	Veneto	NaN	\N	0	2025-06-16	NaN	NaN	fortopsrl@pec.it	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.044296	f	f	\N	\N	[]	0	active	\N	pending	\N
1773803	\N	SIMONI SHOP SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	3403901204.0	03403901204	VIA PESCHERIE VECCHIE, 3/B	BOLOGNA	40124.0	BO	Emilia-romagna	Italia	\N	21	2025-06-16	NaN	NaN	NaN	051 231843	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.047965	f	f	\N	\N	[]	0	active	\N	pending	\N
1773873	\N	EXERTIS ENTERPRISE IT S.R.L.	4277360980.0	04277360980	VIA CIPRO, 1	BRESCIA	25124.0	BS	Lombardia	Italia	\N	3	2025-06-16	NaN	NaN	NaN	030 22193255	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:38.051773	f	f	\N	\N	[]	0	active	\N	pending	\N
1773900	\N	UPNOVA GROUP S.R.L.	8702030720.0	08702030720	VIA EX S.S.604 PER ALBEROBELLO, 26 Z.I	NOCI	70015.0	BA	Puglia	Italia	\N	6	2025-06-16	NaN	NaN	NaN	080 4978664	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.055182	f	f	\N	\N	[]	0	active	\N	pending	\N
1773983	\N	SOFTWAREONE ITALIA S.R.L.	6169220966.0	06169220966	CENTRO DIREZIONALE MILANOFIORI,	ASSAGO	20057.0	MI	Lombardia	Italia	\N	77	2025-06-17	Tramite Eye-Able rendono i siti accessibili ai disabili secondo la direttiva 82/2022.\n# Sabrina	NaN	NaN	0289455326	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.058365	f	f	\N	\N	[]	0	active	\N	pending	\N
1774020	\N	GLUE LABS SRL	14153921003.0	14153921003	PIAZZALE LUIGI STURZO, 15	ROMA	144.0	RM	Lazio	Italia	\N	9	2025-06-17	Pupau.\n# Sabrina	www.glue-labs.com	info@glue-labs.com	06 87811067	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.061471	f	f	\N	\N	[]	0	active	\N	pending	\N
1774029	\N	3X1010 S.R.L	2407220900.0	02407220900	CORSO GERMANO SOMMEILLER, 23	TORINO	10128.0	TO	Piemonte	Italia	\N	10	2025-06-17	NaN	www.3x1010.it	NaN	011-0163333	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:38.064164	f	f	\N	\N	[]	0	active	\N	pending	\N
1774031	\N	AI4WHAT S.R.L.	13139330016.0	13139330016	CORSO CASTELFIDARDO, 30/A	TORINO	10129.0	TO	Piemonte	Italia	\N	0	2025-06-17	Invia follow-up automatici in 30 secondi.\n# Sabrina	NaN	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:38.066676	f	f	\N	\N	[]	0	active	\N	pending	\N
1774036	\N	DIALOGSPHERE S.R.L.	4035650920.0	04035650920	VIA GRAZIA DELEDDA, 74	CAGLIARI	9127.0	CA	Sardegna	Italia	\N	10	2025-06-17	NaN	NaN	NaN	NaN	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:38.06912	f	f	\N	\N	[]	0	active	\N	pending	\N
1774119	\N	SINERGEST S.R.L.	1828190460.0	01828190460	VIA PESCIATIN, 91/A	CAPANNORI	55012.0	LU	Toscana	Italia	\N	24	2025-06-18	NaN	www.sinergest.com	NaN	0583378530	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:38.072062	f	f	\N	\N	[]	0	active	\N	pending	\N
1774123	\N	SINERGIA NET SRLS	4565150275.0	04565150275	PIAZZA LUIGI CADORNA, 8/1	VILLORBA	31020.0	TV	Veneto	Italia	\N	2	2025-06-18	NaN	www.sinergianet.it	NaN	0422-1916417	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.074376	f	f	\N	\N	[]	0	active	\N	pending	\N
1774139	\N	SINTESI S.R.L.	616500229.0	00616500229	VIA ALTO ADIGE, 170	TRENTO	38121.0	TN	Trentino-alto adige	Italia	\N	5	2025-06-18	NaN	www.sintesiservizi.com	NaN	0461968900	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.076631	f	f	\N	\N	[]	0	active	\N	pending	\N
1774160	\N	S.R.L. *SO.GE.RI. - SOCIETA' GESTIONE RISTORANTI	890870280.0	00890870280	VIA MARSILIO DA PADOVA,, 11/15	PADOVA	35139.0	PD	Veneto	Italia	\N	28	2025-06-18	NaN	NaN	NaN	0498760244	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.078828	f	f	\N	\N	[]	0	active	\N	pending	\N
1774265	\N	SOCIETA' COOPERATIVA -  E'CO - ECONOMIA E' COMUNITA'	14110851004.0	14110851004	VIA CESARE BARONIO, 61	ROMA	179.0	RM	Lazio	Italia	\N	0	2025-06-18	Non ci sono contatti.	NaN	NaN	346 3809214	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.081317	f	f	\N	\N	[]	0	active	\N	pending	\N
1774715	\N	SOL INVICTUS S.R.L.	2181060225.0	02181060225	VIA PIETRO PALEOCAPA, 4	MILANO	20121.0	MI	Lombardia	Italia	\N	2	2025-06-18	NaN	www.solinvictus.it	NaN	02-89959286	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.084893	f	f	\N	\N	[]	0	active	\N	pending	\N
1775205	\N	SOLUNIO SRL	2780740219.0	02780740219	VIA DEI CAMPI DELLA RIENZA, 46	BRUNICO	39031.0	BZ	Trentino-alto adige	Italia	\N	11	2025-06-18	NaN	NaN	NaN	0474-646057	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.087991	f	f	\N	\N	[]	0	active	\N	pending	\N
1775908	\N	ROYAL FOOD S.R.L.	2845450341.0	02845450341	STRADA LUIGI CARLO FARINI, 19/B	PARMA	43121.0	PR	Emilia-romagna	Italia	\N	42	2025-06-18	NaN	NaN	NaN	0521.1855966	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.090894	f	f	\N	\N	[]	0	active	\N	pending	\N
1776467	\N	MIFAST SRL	4760520231.0	04760520231	VIA LUCIANO MANARA, 4	VERONA	37135.0	VR	Veneto	Italia	\N	1	2025-06-18	NaN	NaN	NaN	339.6304500	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.093968	f	f	\N	\N	[]	0	active	\N	pending	\N
1886151	\N	STUDIO BORTOLETTO S.R.L.	03745440283	\N	VIA GERMANIA, 7	\N	\N	\N	\N	IT		\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-07 19:03:20.30779	f	f	\N	\N	[]	0	active	\N	pending	\N
1884580	\N	OTTICA SANTONA S.R.L.	00590410957	00590410957	Piazza Eleonora d'Arborea, 3	Oristano	9170.0	Oristano	Sardegna	Italia	Ottica interessata a :\nF40 perché ha 10 dipendenti che utilizzano CRM e macchinari quotidianamente.\n	0	2025-07-03	Ottica interessata a :\nF40 perche ha 10 dipendenti che utilizzano CRM e macchinari quotidianamente.\nPBX perche ha un data base molto con 40000 clienti registrati\nKHW sono due soci e la detassazione dei compensi da portarsi fuori è interessante.\nBND per dei bandi relativi a degli investimenti riguardanti opere murarie.	NaN	santona@santona.it	3396416307	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:38.37531	f	f	\N	\N	[]	0	active	\N	pending	\N
1884456	\N	EURID SERVICE S.R.L.          UNIPERSONALE	01837320504	01837320504	VIA AUGUSTO RIGHI, 26/28	PISA	56121.0	PI	Toscana	Italia	Mandano mail in autonomia.\nCodice Ateco: 629009.\n# Sabrina	3	2025-07-02	Mandano mail in autonomia.\nCodice Ateco: 629009.\n# Sabrina	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.372662	f	f	\N	\N	[]	0	active	\N	pending	\N
1884455	\N	ECOMATE S.R.L.	10841230963	10841230963	VIA DURINI, 27	MILANO	20122.0	MI	Lombardia	Italia	Codice Ateco: 6201.\n# Sabrina	2	2025-07-02	Codice Ateco: 6201.\n# Sabrina	www.ecomate.eu	NaN	0280896046	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.369874	f	f	\N	\N	[]	0	active	\N	pending	\N
1884444	\N	DRILLDOWN S.R.L.	12392590969	12392590969	VIALE ISONZO, 8	MILANO	20135.0	MI	Lombardia	Italia	Tuduu\nCodice Ateco: 6201.\n# Sabrina	0	2025-07-02	Tuduu\nCodice Ateco: 6201.\n# Sabrina	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.367275	f	f	\N	\N	[]	0	active	\N	pending	\N
1884442	\N	DEVPUNKS S.R.L.	12778070016	12778070016	VIA VINCENZO LANCIA, 31/20	TORINO	10141.0	TO	Piemonte	Italia	Codice Ateco: 620200.\n# Sabrina	1	2025-07-02	Codice Ateco: 620200.\n# Sabrina	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.364693	f	f	\N	\N	[]	0	active	\N	pending	\N
1884436	\N	DATASIS GROUP S.R.L.	02325530133	02325530133	VIA PAOLO VERONESE, 202	TORINO	10148.0	TO	Piemonte	Italia	Api robot che semplificano i processi e la comunicazione aziendale.\nCodice Ateco: 4651\n# Sabrina	2	2025-07-02	Api robot che semplificano i processi e la comunicazione aziendale.\nCodice Ateco: 4651\n# Sabrina	www.datasis.it	info@datasis.it	011 0658075	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.36223	f	f	\N	\N	[]	0	active	\N	pending	\N
1884431	\N	TECNICHE NUOVE S.P.A.	00753480151	00753480151	VIA ERITREA, 21	MILANO	20157.0	MI	Lombardia	Italia	Codice Ateco: 5814\n# Sabrina	101	2025-07-02	Codice Ateco: 5814\n# Sabrina	www.tecnichenuove.com	NaN	02 39090335	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.359639	f	f	\N	\N	[]	0	active	\N	pending	\N
1883801	\N	CROWD M ITALY S.R.L.	01169400320	01169400320	LARGO DON BONIFACIO, 1	TRIESTE	34125.0	TS	Friuli-venezia giulia	Italia	Codice Ateco: 7311\n# Sabrina	6	2025-06-30	Codice Ateco: 7311\n# Sabrina	www.1clickdonation.com	NaN	040 46063277	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.356883	f	f	\N	\N	[]	0	active	\N	pending	\N
1883800	\N	CO.M.MEDIA   S.R.L.	03485250751	03485250751	VIA DI PETTORANO, 22	LECCE	73100.0	LE	Puglia	Italia	Codice Ateco: 900101\n# Sabrina	19	2025-06-30	Codice Ateco: 900101\n# Sabrina	www.commediasrl.it	info@commediasrl.it	0832 228509	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.353225	f	f	\N	\N	[]	0	active	\N	pending	\N
1883799	\N	CODEPLOY S.R.L.	11873660010	11873660010	VIA SANTA TERESA, 23	TORINO	10121.0	TO	Piemonte	Italia	Codice Ateco: 620100\n# Sabrina	10	2025-06-30	Codice Ateco: 620100\n# Sabrina	www.codeploy.it	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.350007	f	f	\N	\N	[]	0	active	\N	pending	\N
1881673	\N	SWP SRL	04972000287	04972000287	VIA ROMETTA, 19	SAN MARTINO DI LUPARI	35018.0	PD	Veneto	Italia	L'azienda si occupa di Progettazione di macchinari posizionati di saldatura, verniciatura, quadri el	5	2025-06-20	L'azienda si occupa di Progettazione di macchinari posizionati di saldatura, verniciatura, quadri elettrici e montaggio.#Luana	https://www.sartoreweldingpositioner.com/	NaN	0499410065	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.147512	f	f	\N	\N	[]	0	active	\N	pending	\N
1881668	\N	SUSHIDB SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	15073611004	15073611004	VIALE TRASTEVERE, 209	ROMA	153.0	RM	Lazio	Italia	E' un amico di vecchia data di Luigi Vitaletti.\nE' il titolare di SUSHI DB\nCrea e sviluppa software 	2	2025-06-20	E' un amico di vecchia data di Luigi Vitaletti.\nE' il titolare di SUSHI DB\nCrea e sviluppa software e fornisce formazione.#Luana	www.sushidb.com	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.144316	f	f	\N	\N	[]	0	active	\N	pending	\N
1881661	\N	STYLPLEX SRL	05328330286	05328330286	VIA FORNACE I STRADA, 2	SAN GIORGIO DELLE PERTICHE	35010.0	PD	Veneto	Italia		19	2025-06-20	NaN	www.stylplex.it	NaN	049-8847078	\N	NaN	[]	2025-07-03 20:34:38.141462	f	f	\N	\N	[]	0	active	\N	pending	\N
1881648	\N	SEDIGIT SRL	02186830226	02186830226	VIA LIDORNO, 6	TRENTO	38123.0	TN	Trentino-alto adige	Italia		4	2025-06-20	NaN	NaN	NaN	0461917502	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.138727	f	f	\N	\N	[]	0	active	\N	pending	\N
1884757	\N	FORTGALE S.R.L.	10008370966	\N	CORSO BUENOS AIRES, 64	\N	\N	\N	\N	IT	Codice Ateco: 620909.\n# Sabrina	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-07 19:03:20.30779	f	f	\N	\N	[]	0	active	\N	pending	\N
1881546	\N	FISIOPRO S.R.L.	01919410496	01919410496	VIA LA SALA,	ROSIGNANO MARITTIMO	57016.0	LI	Toscana	Italia		5	2025-06-19	NaN	www.fisioproclinic.it	NaN	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:38.112371	f	f	\N	\N	[]	0	active	\N	pending	\N
1837536	\N	STUDIO CAVAGGIONI SOCIETA' CONSORTILE A RESPONSABILITA' LIMITATA	03594460234	03594460234	VIA PIRANDELLO, 3/N	SAN BONIFACIO	37047.0	VR	Veneto	Italia		9	2025-06-18	NaN	www.teatrochiabrera.it	NaN	0457612397	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.110001	f	f	\N	\N	[]	0	active	\N	pending	\N
1824389	\N	STOREIS S.R.L.	05113300288	05113300288	VIA CARLO LEONI, 7	PADOVA	35129.0	PD	Veneto	Italia		76	2025-06-18	NaN	www.store.is	NaN	0497386284	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.107478	f	f	\N	\N	[]	0	active	\N	pending	\N
1783490	\N	S.T.A.C. 2000 S.R.L.	01543011207	01543011207	VIA LEONARDO DA VINCI N.26/A-26/B, 28/A	ZOLA PREDOSA	40069.0	BO	Emilia-romagna	Italia	04/12/2024 Info contatto\nIn data odierna Angelo Golisano mi presenta Claudio Lolli, Titolare di STAC	1	2025-06-18	04/12/2024 Info contatto\nIn data odierna Angelo Golisano mi presenta Claudio Lolli, Titolare di STAC 2000 e associato FenImprese.\nAnche lui è interessato a fare rete come noi con le Aziende.\nGli racconto chi siamo e cosa facciamo.\nLa STAC 2000 si occupa di Noleggio Operativo, Erogatori d'acqua, Wine dispenser, Registratori di cassa e Palmari per ristoranti, pub, pizzerie, alberghi ecc\nGli racconto dell'incentivo Formazione 4.0 e mi dice che loro essendo tutti commerciali hanno solo 3 dipendenti ma mi propone subito una collaborazione per promuovere l'incentivo ai suoi clienti ristoranti.\nGli dico che è quello che solitamente facciamo con le Aziende come le sue.\nAnche lui paga il famoso "gettone" in contanti a chi gli trova clienti per il noleggio operativo dei suoi prodotti.\nGli parlo anche di Know How e la cosa sembra interessargli. Mi dice che dopo le feste, nel nuovo anno ne potremmo parlare con il suo Commercialista.\nInvio mail con brochure EndUser	www.stac2000.com	NaN	0516766407	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.104969	f	f	\N	\N	[]	0	active	\N	pending	\N
1779478	\N	VAPOUR ITALIA SRL	02956690305	02956690305	VIA STIRIA, 45	UDINE	33100.0	UD	Friuli-venezia giulia	Italia		7	2025-06-18	NaN	www.kiwivapor.com	NaN	0432 1452411	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.102232	f	f	\N	\N	[]	0	active	\N	pending	\N
1779446	\N	SPIGA D'ORO SRL	04494220272	04494220272	VIA PADOVA, 174	VIGONOVO	30030.0	VE	Veneto	Italia		19	2025-06-18	NaN	www.sartopasticceria.shop	NaN	335.6602289	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.099629	f	f	\N	\N	[]	0	active	\N	pending	\N
1779442	\N	GIESSE SCAMPOLI S.R.L.	02410180265	02410180265	VIA ARCHIMEDE, 7/9	NEGRAR DI VALPOLICELLA	37024.0	VR	Veneto	Italia	Giesse Scampoli è un'azienda che vende tessuti, sia al metro che a peso, e offre anche servizi di me	20	2025-06-18	Giesse Scampoli è un'azienda che vende tessuti, sia al metro che a peso, e offre anche servizi di merceria e accessori per il cucito. In particolare, vendono tessuti per abbigliamento, arredamento, tende e             hobbistica, oltre a macchine per cucire e cartamodelli.	NaN	NaN	0457514040	\N	Nord-Est	["Francesca De Vita"]	2025-07-03 20:34:38.096907	f	f	\N	\N	[]	0	active	\N	pending	\N
1653185	\N	AV Media Trend	NaN	NaN	NaN	Corsico	20094.0	Milano	Lombardia	Italia	Technology & Digital Innovation	0	2025-04-02	AI specialist company	NaN	info@avmediatrend.com	3476859801	\N	NaN	[]	2025-07-03 20:34:36.122558	t	t	AI/Machine Learning	esperti di AI, WEB3, BlockChain, comunicazione	[]	3	active	\N	pending	\N
1771658	\N	'MAST INDUSTRIA ITALIANA SRL''	10865581002.0	10865581002	VIA VARIANTE DI CANCELLIERA,	ARICCIA	72.0	RM	Lazio	Italia	\N	12	2025-06-09	NaN	www.lamaisondesessences.it	NaN	069343097	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:37.869663	f	f	\N	\N	[]	0	active	\N	in_progress	\N
1884740	\N	ERMASTUFF S.R.L.S.	02650810209	\N	VIA GUASTALLA, 9	\N	\N	\N	\N	IT	Codice Ateco: 731101.\n# Sabrina	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-07 19:03:20.30779	f	f	\N	\N	[]	0	active	\N	completed	\N
1881642	\N	STUDIO QUARENGHI S.R.L.	04274010984	04274010984	VIA TRIUMPLINA, 80	BRESCIA	25124.0	BS	Lombardia	Italia		12	2025-06-20	NaN	NaN	NaN	030.8774958	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.136037	f	f	\N	\N	[]	0	active	\N	pending	\N
1893348	\N	NEW STYLE S.R.L.	01469170466	\N	VIA PIETRA DEL CARDOSO, 2/4	\N	\N	\N	\N	IT		\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-18 20:18:49.361476	f	f	\N	\N	[]	0	active	\N	pending	\N
1889246	\N	SALARDI SISTEMI S.R.L.	03812230369	\N	VIA FERNANDO MALAVOLTI, 33	\N	\N	\N	\N	IT	Contatto del Dr. Zambello	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-18 20:18:49.361476	f	f	\N	\N	[]	0	active	\N	pending	\N
1888158	\N	EF STYLE HOTEL S.R.L.	04480810276	\N	VIA GOFFREDO MAMELI, 78	\N	\N	\N	\N	IT	Codice Ateco: 55.1 - Alberghi e strutture simili\n# Sabrina	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-18 20:18:49.361476	f	f	\N	\N	[]	0	active	\N	pending	\N
1888154	\N	EMC S.R.L.	01287710527	\N	VIA DELLA REPUBBLICA, 48	\N	\N	\N	\N	IT	Codice Ateco: 2612 (Fabbricazione schede elettroniche).\n# Sabrina	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-18 20:18:49.361476	f	f	\N	\N	[]	0	active	\N	pending	\N
1887463	\N	SEA SISTEMI SNC DI GIUSTI ANDREA E ROBERTO	01083550457	\N	VIA FRASSINA, 51	\N	\N	\N	\N	IT	Codice Ateco: 6201.\nPluripremiata per il software Mexal.\n# Sabrina	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-18 20:18:49.361476	f	f	\N	\N	[]	0	active	\N	pending	\N
1887390	\N	AMPEREONE S.R.L.	01332710860	\N	Via Patti, 12	\N	\N	\N	\N	IT	Codice Ateco non trovato, azienda costituita il 2 luglio.\n# Sabrina	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-18 20:18:49.361476	f	f	\N	\N	[]	0	active	\N	pending	\N
1887345	\N	GLUTENSENS SRL	13816120961	\N	VIALE PIAVE, 21	\N	\N	\N	\N	IT	Codice Ateco: 7211.\n# Sabrina	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-07 19:03:20.30779	f	f	\N	\N	[]	0	active	\N	pending	\N
1887342	\N	GREENBUBBLE AGENCY S.R.L.	02508830425	\N	VIA SPARAPANI, 153	\N	\N	\N	\N	IT	Codice Ateco: 6201.\n# Sabrina	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-07 19:03:20.30779	f	f	\N	\N	[]	0	active	\N	pending	\N
1884752	\N	FONDAZIONE PIEMONTE INNOVA	97634160010	\N	GALLERIA SAN FEDERICO, 54	\N	\N	\N	\N	IT	Codice Ateco: 7021.\n# Sabrina	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-07 19:03:20.30779	f	f	\N	\N	[]	0	active	\N	pending	\N
1884748	\N	FONDAZIONE RIDE2MED	13043300964	\N	VIALE DECUMANO, 36	\N	\N	\N	\N	IT	Codice Ateco: 7211.\n# Sabrina	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-07 19:03:20.30779	f	f	\N	\N	[]	0	active	\N	pending	\N
1884738	\N	EDO RADICI FELICI S.R.L.	01418440523	\N	VIALE EUROPA, 35	\N	\N	\N	\N	IT	Codice Ateco: 7211.\n# Sabrina	\N	\N	\N	\N	\N	\N	\N	\N	\N	2025-07-07 19:03:20.30779	f	f	\N	\N	[]	0	active	\N	pending	\N
1883797	\N	CODE THIS LAB S.R.L.	06367951214	06367951214	VIA PITTORE, 127	SAN GIORGIO A CREMANO	80046.0	NaN	Campania	Italia	Codice Ateco: 6201\nUn' unica piattaforma per tutte le attività aziendali.\n# Sabrina	11	2025-06-30	Codice Ateco: 6201\nUn' unica piattaforma per tutte le attività aziendali.\n# Sabrina	NaN	NaN	08119187653	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.346926	f	f	\N	\N	[]	0	active	\N	pending	\N
1883792	\N	CIRCLE PROJECT S.R.L.	02261420422	02261420422	VIA MERCANTINI, 8	JESI	60035.0	AN	Marche	Italia	Codice Ateco: 71122\n# Sabrina	4	2025-06-30	Codice Ateco: 71122\n# Sabrina	www.circleproject.it	NaN	0731 214668	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.344358	f	f	\N	\N	[]	0	active	\N	pending	\N
1883775	\N	CENTOFORM SRL	01523560389	01523560389	VIA NINO BIXIO, 11	CENTO	44042.0	FE	Emilia-romagna	Italia	Codice Ateco: 85592\n# Sabrina	30	2025-06-30	Codice Ateco: 85592\n# Sabrina	www.centoform.it	NaN	051 902332	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.34149	f	f	\N	\N	[]	0	active	\N	pending	\N
1883768	\N	ITALIAN QUALITY COMPANY S.R.L.	03332011208	03332011208	VIA DI CORTICELLA, 181/3	BOLOGNA	40128.0	BO	Emilia-romagna	Italia	Codice Ateco: 649910\nDigital badge (C-Box).\n# Sabrina	19	2025-06-30	Codice Ateco: 649910\nDigital badge (C-Box).\n# Sabrina	www.itaqua.it	NaN	051 4172555	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.338654	f	f	\N	\N	[]	0	active	\N	pending	\N
1883671	\N	COLLI DI BRUNO COLLI SAS DI MORO ALDO & C.		NaN	Strada Cebrosa, 104/b	Settimo Torinese	10036.0	Torino	Piemonte	Italia	Codice Ateco: 222	0	2025-06-30	Codice Ateco: 222	NaN	collisas@pec.it	NaN	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:38.336219	f	f	\N	\N	[]	0	active	\N	pending	\N
1883539	\N	BLUEGREEN STRATEGY S.R.L.	03002431207	03002431207	VIA ALDO MORO, 6/2	CASALECCHIO DI RENO	40033.0	BO	Emilia-romagna	Italia	Codice Ateco: 702209	3	2025-06-27	Codice Ateco: 702209	www.bluegreenstrategy.it	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.333614	f	f	\N	\N	[]	0	active	\N	pending	\N
1883527	\N	RANDIQUA SRL	11904020960	11904020960	VIA GIORGIO JAN, 12	MILANO	20129.0	MI	Lombardia	Italia	Codice Ateco: 014830\nBee My Help.\n# Sabrina	0	2025-06-27	Codice Ateco: 014830\nBee My Help.\n# Sabrina	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.330933	f	f	\N	\N	[]	0	active	\N	pending	\N
1883525	\N	BIORSAF S.R.L.	01684330531	01684330531	LOC. FERRO DI CAVALLO,	CASTELL'AZZARA	58034.0	GR	Toscana	Italia	Codice Ateco: 620100	3	2025-06-27	Codice Ateco: 620100	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.328514	f	f	\N	\N	[]	0	active	\N	pending	\N
1883521	\N	B2LOCAL SRL	16415321005	16415321005	CORSO PIERLUIGI, 23	PALESTRINA	36.0	RM	Lazio	Italia	Codice Ateco: 731102	2	2025-06-27	Codice Ateco: 731102	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.325787	f	f	\N	\N	[]	0	active	\N	pending	\N
1883467	\N	AXIO STUDIO S.R.L.	02393380502	02393380502	VIA ANGELO POLIZIANO, 6	SAN MINIATO	56028.0	PI	Toscana	Italia	Codice Ateco: 6201	2	2025-06-27	Codice Ateco: 6201	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.322549	f	f	\N	\N	[]	0	active	\N	pending	\N
1883463	\N	ART-ER  SCA	03786281208	03786281208	VIA PIERO GOBETTI, 101	BOLOGNA	40129.0	BO	Emilia-romagna	Italia		235	2025-06-27	NaN	www.art-er.it	NaN	051 6398094	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.318342	f	f	\N	\N	[]	0	active	\N	pending	\N
1883461	\N	AULAB S.R.L.	07647440721	07647440721	VIA GIOVANNI LATERZA, 61	BARI	70124.0	BA	Puglia	Italia	Codice Ateco: 6201	48	2025-06-27	Codice Ateco: 6201	www.aulab.it	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.313786	f	f	\N	\N	[]	0	active	\N	pending	\N
1883427	\N	AI GARAGE SRL	13638040967	13638040967	VIA STRADA PADANA SUPERIORE, 13	CERNUSCO SUL NAVIGLIO	20063.0	MI	Lombardia	Italia	Codice Ateco Principale: 52.21.50 - Gestione di parcheggi e autorimesse.\n\n Secondario: 52.21.90 - Al	0	2025-06-27	Codice Ateco Principale: 522150 e Secondari: 522190 e 960909	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.310524	f	f	\N	\N	[]	0	active	\N	pending	\N
1883418	\N	AGRI-E		NaN	Viale dell' Università, 16	Legnaro	35020.0	Padova	Veneto	Italia		4	2025-06-27	Codice Ateco: 015000	www.agri-e.it	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.307358	f	f	\N	\N	[]	0	active	\N	pending	\N
1883416	\N	AD CONSULTING SPA	03410070365	03410070365	VIA PASOLINI, 15	MODENA	41123.0	MO	Emilia-romagna	Italia	Codice Ateco 82.99.99 – Altri Servizi di Sostegno Alle Imprese. #FrancescaZ	88	2025-06-27	Codice Ateco: 829999	adcgroup.com/	NaN	059-7470674	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.304362	f	f	\N	\N	[]	0	active	\N	pending	\N
1883413	\N	MADBIT ENTERTAINMENT S.R.L.	03881520161	03881520161	VIA GEROLAMO ZANCHI, 22/C	BERGAMO	24126.0	BG	Lombardia	Italia	Codice Ateco: 5829	70	2025-06-27	Codice Ateco: 5829	www.fattureincloud.it	info@fattureincloud.it	035 0800099	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.301333	f	f	\N	\N	[]	0	active	\N	pending	\N
1883409	\N	ABIKOM		NaN	Via dei Terrazzieri, 2/3	Carpi	41012.0	Modena	Emilia-Romagna	Italia	Codice Ateco:  73.11.02 – Conduzione di campagne di marketing e altri servizi pubblicitari. #Frances	0	2025-06-27	Codice Ateco: 731102	NaN	info@abikom.it	059 5804286	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.297868	f	f	\N	\N	[]	0	active	\N	pending	\N
1883391	\N	ACCESSIWAY S.R.L.	12419990010	12419990010	VIA PIETRO MICCA, 20	TORINO	10122.0	TO	Piemonte	Italia	Codice Ateco - 47.91.11 -   Commercio al dettaglio di qualsiasi tipo di prodotto effettuato via inte	41	2025-06-27	Codice Ateco: 47911	www.accessiway.com	info@accessiway.com	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.294678	f	f	\N	\N	[]	0	active	\N	pending	\N
1883237	\N	FRATTIN GROUP SRL	02881940247	02881940247	VIA DELL'INDUSTRIA, 1	CASSOLA	36022.0	VI	Veneto	Italia		84	2025-06-26	NaN	www.frattin-auto.it	NaN	NaN	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:38.291185	f	f	\N	\N	[]	0	active	\N	pending	\N
1883225	\N	SA.I.T. S.P.A.	00297040172	00297040172	VIA ENRICO FERMI, 9/10	SALO'	25087.0	BS	Lombardia	Italia		33	2025-06-26	NaN	www.saitspa.it/	NaN	0365-520515	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:38.287712	f	f	\N	\N	[]	0	active	\N	pending	\N
1882983	\N	DOTT.ZANOLLI SRL	00213620230	00213620230	VIA CASA QUINDICI, 22	SOMMACAMPAGNA	37060.0	VR	Veneto	Italia		46	2025-06-25	NaN	www.zanolli.it	NaN	045-8581500	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.284359	f	f	\N	\N	[]	0	active	\N	pending	\N
1882980	\N	ZAINO FOODSERVICE S.R.L.	04091960288	04091960288	VIA DEL COMMERCIO VICOLO I, 2	MONTEGROTTO TERME	35036.0	PD	Veneto	Italia	Codice Ateco: 46.39.20 - Commercio all'ingrosso non specializzato di altri prodotti alimentari, beva	67	2025-06-25	NaN	www.altacucinaitaliana.shop	NaN	0498928980	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.281044	f	f	\N	\N	[]	0	active	\N	pending	\N
1882978	\N	ZIP-LINE SAURIS ZAHRE SOCIETA' A RESPONSABILITA' LIMITATA SEMPLIFICATA	02933020303	02933020303	SAURIS DI SOPR, 50/A	SAURIS	33020.0	UD	Friuli-venezia giulia	Italia	Codice Ateco - : 93.21 - Parchi di divertimento e parchi tematici. #FrancescaZ	11	2025-06-25	NaN	www.ziplinesauris.com	NaN	NaN	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.278183	f	f	\N	\N	[]	0	active	\N	pending	\N
1882977	\N	ZAHREBEER SOCIETA' SEMPLICE AGRICOLA	02760140307	02760140307	FRAZIONE SAURIS DI SOPRA, 50	SAURIS	33020.0	UD	Friuli-venezia giulia	Italia	Codice Ateco: 01.11.10 - Coltivazioni di cereali (escluso il riso). Azienda agricola, birrificio, os	6	2025-06-25	NaN	www.zahrebeer.com	NaN	0433-866314	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.275423	f	f	\N	\N	[]	0	active	\N	pending	\N
1882976	\N	ZIRONDELLI & REGAZZI S.R.L.	02109260378	02109260378	VIA NATALE SALIERI, 23/25 A	CASTEL SAN PIETRO TERME	40024.0	BO	Emilia-romagna	Italia	Codice Ateco: 43.21.01 - Installazione di impianti elettrici in edifici o in altre opere di costruzi	51	2025-06-25	NaN	www.zirondelliregazzi.it/	NaN	051-6948121	\N	NaN	["Maria Silvia Gentile"]	2025-07-03 20:34:38.272622	f	f	\N	\N	[]	0	active	\N	pending	\N
1882955	\N	ZUCCHETTI SPA	05006900962	05006900962	VIA SOLFERINO, 1	LODI	26900.0	LO	Lombardia	Italia	Codice Ateco: 62.01- Produzione di software non connesso all'edizione. # Luana	3126	2025-06-25	NaN	www.zucchettisoftware.it	NaN	03715942444	\N	NaN	["Pier Luigi Menin"]	2025-07-03 20:34:38.269945	f	f	\N	\N	[]	0	active	\N	pending	\N
1882952	\N	ZURICH ITALY BANK  S.P.A.	12025760963	12025760963	VIA BENIGNO CRESPI, 23	MILANO	20159.0	MI	Lombardia	Italia	Codice Ateco: 64.19.1  - Altre intermediazioni monetarie fornite da istituti diversi dalla banca cen	188	2025-06-25	NaN	NaN	NaN	02-59661	\N	Nord-Est	[]	2025-07-03 20:34:38.267068	f	f	\N	\N	[]	0	active	\N	pending	\N
1882402	\N	ANTONINO LIPARI DITTA		NaN	VIA ALESSANDRO PERTINI, 2/INT	CASALECCHIO DI RENO	40033.0	BO	Emilia Romagna	Italia	Wet Formazione.\n# Sabrina	0	2025-06-23	Wet Formazione.\n# Sabrina	NaN	antonio.lipari@wetmail.it	340 460 9677	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.264118	f	f	\N	\N	[]	0	active	\N	pending	\N
1882385	\N	WORKING STRATEGIES S.R.L.	02531860225	02531860225	VIA DEL LAVORO, 57	ISOLA DELLA SCALA	37063.0	VR	Veneto	Italia	Codice Ateco: 70.22.09 - Altre attività di consulenza imprenditoriale e altra consulenza amministrat	1	2025-06-23	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.260251	f	f	\N	\N	[]	0	active	\N	pending	\N
1882379	\N	WORLDLINE MERCHANT SERVICES ITALIA S.P.A.	05963231005	05963231005	VIA DEGLI ALDOBRANDESCHI, 300	ROMA	163.0	RM	Lazio	Italia	gestione pagamenti elettronici (pos). #Luana	177	2025-06-23	NaN	www.axepta.it	NaN	06 42007027	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.257654	f	f	\N	\N	[]	0	active	\N	pending	\N
1882371	\N	XTEAM SOFTWARE SOLUTIONS SRLS	01495570291	01495570291	VIA ROMA, 833	GIACCIANO CON BARUCHELLA	45020.0	RO	Veneto	Italia	Codice Ateco: 62.02 - Consulenza nel settore delle tecnologie dell'informatica (Software and Videoga	2	2025-06-23	NaN	www.xteamvr.com	NaN	NaN	\N	Nord-Ovest	["Pier Luigi Menin"]	2025-07-03 20:34:38.254957	f	f	\N	\N	[]	0	active	\N	pending	\N
1882355	\N	VNE S.P.A.	02480140462	02480140462	VIA BIAGIONI, 371	SERAVEZZA	55047.0	LU	Toscana	Italia	Fiera del Franchising di Milano 2023.\n# Sabrina\nCodice Ateco: 28.29.1 -  Fabbricazione di bilance e 	52	2025-06-23	Fiera del Franchising di Milano 2023.\n# Sabrina	www.vne.it	NaN	0584 768333	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.251906	f	f	\N	\N	[]	0	active	\N	pending	\N
1882249	\N	VLV CAPITAL SAGL		NaN	Viale Stefano Franscini, 16	Lugano - Ticino	6900.0	NaN	NaN	Svizzera	Fiera del Franchising\n# Sabrina\nPianificazione finanziaria, strategia aziendale, geo-marketing e ges	3	2025-06-23	Fiera del Franchising\n# Sabrina	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.249088	f	f	\N	\N	[]	0	active	\N	pending	\N
1882243	\N	VIMEK BAKERY AUTOMATION S.R.L.	04858490289	04858490289	STRADA DEL SANTO, 110/A	CADONEGHE	35010.0	PD	Veneto	Italia	Codice Ateco: 28.93.00 - Fabbricazione di macchine per l'industria alimentare delle bevande e del ta	24	2025-06-23	NaN	www.vimekbakery.com	NaN	0490963625	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.246413	f	f	\N	\N	[]	0	active	\N	pending	\N
1882240	\N	VILLA MATILDE S.S.	03028360612	03028360612	STRADA STATALE DOMITIANA, 18	CELLOLE	81030.0	CE	Campania	Italia	Codice Ateco: 01.21 - Coltivazione d'uva (viticultori). #Luana	35	2025-06-23	NaN	www.villamatilde.it	NaN	0823932914	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.243642	f	f	\N	\N	[]	0	active	\N	pending	\N
1882239	\N	VILLA SALUS ISTITUTO ELIOTERAPICO ORTOPEDICO S.R.L.	00391170404	00391170404	VIA PORTO PALOS, 93	RIMINI	47922.0	RN	Emilia-romagna	Italia	Codice Ateco: 86.10.1 - Ospedali e case di cura generici. #Luana	137	2025-06-23	NaN	NaN	NaN	054172077	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.240251	f	f	\N	\N	[]	0	active	\N	pending	\N
1882236	\N	VILLA STECCHINI RESORT SRL	04167410242	04167410242	VIA MOLINETTO, 2	ROMANO D'EZZELINO	36060.0	VI	Veneto	Italia	Codice Ateco: 55.1 - Alberghi e strutture simili. #Luana	10	2025-06-23	NaN	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.236446	f	f	\N	\N	[]	0	active	\N	pending	\N
1882235	\N	FARMACIA MADONNA PELLEGRINA DEL DR. OLDANI JACOPO NICOLO' ALESSANDRO QUALE TRUSTEE DEL TRUST LUBATTI	LDNJPN84D29E801Y	LDNJPN84D29E801Y	LARGO CANTELLI, 8	NOVARA	28100.0	NO	Piemonte	Italia	Codice Ateco: 47.73.1 - Commercio al dettaglio di farmaci. #Luana	10	2025-06-23	NaN	www.farmaciamadonnapellegrina.com	NaN	0321-491696	\N	Nord-Est	["Fabio Aliboni"]	2025-07-03 20:34:38.232682	f	f	\N	\N	[]	0	active	\N	pending	\N
1882232	\N	VIDEOTECNICA S.R.L.	02586550242	02586550242	VIA ZAMENHOF, 717	VICENZA	36100.0	VI	Veneto	Italia	codice ateco: 43.21.02 - Installazione di impianti elettronici (inclusa manutenzione e riparazione).	22	2025-06-23	NaN	www.videotecnica.com	NaN	0444 910005	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.229052	f	f	\N	\N	[]	0	active	\N	pending	\N
1882231	\N	VICO S.R.L.	00929370096	00929370096	CORSO STALINGRADO,, 50	CAIRO MONTENOTTE	17014.0	SV	Liguria	Italia		210	2025-06-23	NaN	NaN	NaN	019 5090381	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.225235	f	f	\N	\N	[]	0	active	\N	pending	\N
1882229	\N	VICEVERSA S.R.L.	11364640968	11364640968	VIA BERNARDO QUARANTA, 40	MILANO	20139.0	MI	Lombardia	Italia		18	2025-06-23	NaN	NaN	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.221465	f	f	\N	\N	[]	0	active	\N	pending	\N
1882219	\N	P-TREE CONSULTING S.R.L.	04418630960	04418630960	VIA ALEMANNI, 6	CUSANO MILANINO	20095.0	MI	Lombardia	Italia		0	2025-06-23	NaN	www.ptree.it	NaN	026132988	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.217626	f	f	\N	\N	[]	0	active	\N	pending	\N
1882216	\N	DALLA BRUNA S.R.L.	03656120239	03656120239	VIA GOFFREDO MAMELI, 166	VERONA	37124.0	VR	Veneto	Italia	trattoria	16	2025-06-23	trattoria	NaN	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.21359	f	f	\N	\N	[]	0	active	\N	pending	\N
1882182	\N	VERO SAPORE GRECO DUOMO S.R.L.	02473740229	02473740229	VIA DEL BRENNERO, 97	TRENTO	38121.0	TN	Trentino-alto adige	Italia		13	2025-06-23	NaN	www.verosaporegreco.com	NaN	NaN	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.209843	f	f	\N	\N	[]	0	active	\N	pending	\N
1882168	\N	TRASMINET S.A.S. DI DE ROSSI FEDERICO E DAMIANO E C.	03783060233	03783060233	VIA STANGA, 16	VERONA	37139.0	VR	Veneto	Italia		3	2025-06-23	NaN	www.trasminet.it	NaN	045-8905055	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.20597	f	f	\N	\N	[]	0	active	\N	pending	\N
1882160	\N	TRAMEC S.R.L.	03553380373	03553380373	CORSO VENEZIA, 36	MILANO	20121.0	MI	Lombardia	Italia		144	2025-06-23	NaN	www.tramec.it	NaN	051728935	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.202427	f	f	\N	\N	[]	0	active	\N	pending	\N
1882146	\N	TORREFAZIONE ARTIGIANALE DI BUGATTI N. & C. SAS	04022060984	04022060984	VIA RAGAZZI DEL '99, 51	LUMEZZANE	25065.0	BS	Lombardia	Italia		1	2025-06-23	NaN	NaN	NaN	030-3458261	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.198763	f	f	\N	\N	[]	0	active	\N	pending	\N
1882128	\N	TORINO FOOTBALL CLUB S.P.A. O, IN FORMA ABBREVIATA, TORINO F.C. S.P.A.	09012680014	09012680014	VIA GIAMBATTISTA  VIOTTI, 9	TORINO	10121.0	TO	Piemonte	Italia		210	2025-06-23	NaN	www.torinofc.it	NaN	011-19700348	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.195028	f	f	\N	\N	[]	0	active	\N	pending	\N
1881839	\N	VEYAL SRL	02636290286	02636290286	ZONA INDUSTRIALE TERZA STRADA, 8	PADOVA	35129.0	PD	Veneto	Italia		7	2025-06-23	NaN	www.veyal.com	NaN	049-80765512	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.191505	f	f	\N	\N	[]	0	active	\N	pending	\N
1881758	\N	VENETA COMPONENTI SRL		NaN	Viale delle Industrie, 23	Villafranca Padovana	35010.0	Padova	Veneto	Italia		0	2025-06-20	NaN	NaN	venetacomponenti@pec.it	049 9070540	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.188168	f	f	\N	\N	[]	0	active	\N	pending	\N
1881743	\N	THINKIN S.R.L.	02382990220	02382990220	VIA ANTONIO DA TRENTO, 8	TRENTO	38122.0	TN	Trentino-alto adige	Italia		10	2025-06-20	NaN	www.retailerin.com	NaN	0461.092165	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.184667	f	f	\N	\N	[]	0	active	\N	pending	\N
1881734	\N	TESTI GROUP SRL	00682520234	00682520234	VIA SAN PIERETTO, 4	RIVOLI VERONESE	37010.0	VR	Veneto	Italia	Codice Ateco -  23701 - segagione e lavorazione delle pietre e del marmo	56	2025-06-20	NaN	www.testigroup.com	NaN	045-6833333	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.182025	f	f	\N	\N	[]	0	active	\N	pending	\N
1881726	\N	L'IMMOBILIARE S.R.L.	00769550260	00769550260	VIA GIUSEPPE VERDI, 7	CORNUDA	31041.0	TV	Veneto	Italia	TERME DEI COLLI ASOLANI	22	2025-06-20	TERME DEI COLLI ASOLANI	www.termedeicolliasolani.it	NaN	0423-1990858	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.179317	f	f	\N	\N	[]	0	active	\N	pending	\N
1881717	\N	TECNOVATION S.A.S. DI MORTARI IGINO & C.	01815940935	01815940935	VIA SANT'ANTONIO ABATE, 16	PRAVISDOMINI	33076.0	PN	Friuli-venezia giulia	Italia	Tecnovation si distingue per la forte componente specialistica maturata in differenti settori nell’ 	2	2025-06-20	Tecnovation si distingue per la forte componente specialistica maturata in differenti settori nell’ ambito dell’industria metalmeccanica (stampi, stampaggio, costruzione impianti, linee di produzione) con focus particolare per le aziende che lavorano su commessa.	www.tecnovation.it	NaN	0434507536	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.17645	f	f	\N	\N	[]	0	active	\N	pending	\N
1881715	\N	TECNOVAP S.R.L.	03050560238	03050560238	VIA DEI SASSI, 1/A	PESCANTINA	37026.0	VR	Veneto	Italia		48	2025-06-20	NaN	www.tecnovap.it	NaN	045-6767252	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.17408	f	f	\N	\N	[]	0	active	\N	pending	\N
1881714	\N	TECNOSYSTEM RETAIL S.R.L.	04340810268	04340810268	VIA SACCONI, 1	MASER	31010.0	TV	Veneto	Italia		21	2025-06-20	NaN	www.tecnosystemretail.com	NaN	0423-55242	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.17152	f	f	\N	\N	[]	0	active	\N	pending	\N
1881709	\N	TECNERGA S.R.L.	02065020220	02065020220	VIA ROMA, 151	BORGO CHIESE	38083.0	TN	Trentino-alto adige	Italia		8	2025-06-20	NaN	www.tecnerga.com	NaN	0465-621794	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.168612	f	f	\N	\N	[]	0	active	\N	pending	\N
1881706	\N	TEAM DUEMILA S.R.L.	01339420505	01339420505	VIA FABRIZIO DE ANDRE', 6	SANTA CROCE SULL'ARNO	56029.0	PI	Toscana	Italia		51	2025-06-20	NaN	www.teamduemila.it/	NaN	057133733	\N	Nord-Ovest	["Fabio Aliboni"]	2025-07-03 20:34:38.165458	f	f	\N	\N	[]	0	active	\N	pending	\N
1881703	\N	UNIVERSAL STONE S.R.L.	03632920231	03632920231	LUNGADIGE DONATELLI, 5A	VERONA	37121.0	VR	Veneto	Italia	Marco Fasoli.\n# Sabrina	1	2025-06-20	Marco Fasoli.\n# Sabrina	www.universalstone.it	NaN	NaN	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.162628	f	f	\N	\N	[]	0	active	\N	pending	\N
1881694	\N	VALBRENTA SUOLE SRL IN LIQUIDAZIONE	04363940281	04363940281	PIAZZA C.A. DALLA CHIESA, 9	CURTAROLO	35010.0	PD	Veneto	Italia		15	2025-06-20	NaN	www.valbrentasuole.it	NaN	049-9450866	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.159495	f	f	\N	\N	[]	0	active	\N	pending	\N
1881686	\N	STAZIONE DI SERVIZIO DI DE LUCA VINCENZO & C. S.N.C.	02809930783	02809930783	CONTRADA LAGO, 129	BUONVICINO	87020.0	CS	Calabria	Italia		10	2025-06-20	NaN	NaN	NaN	349.6856744	\N	NaN	["Luigi Vitaletti"]	2025-07-03 20:34:38.156221	f	f	\N	\N	[]	0	active	\N	pending	\N
1881679	\N	VALBIA S.R.L.	04234720987	04234720987	VIA INDUSTRIALE, 30	LUMEZZANE	25065.0	BS	Lombardia	Italia	Gruppo Bonomi, sono in tutto tre aziende.\n# Sabrina	41	2025-06-19	Gruppo Bonomi, sono in tutto tre aziende.\n# Sabrina	www.valbia.it	NaN	030 8969411	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.152919	f	f	\N	\N	[]	0	active	\N	pending	\N
1881677	\N	SYNERGY SYSTEM SRL	01421910298	01421910298	VIA LUIGI EINAUDI, 36/15	ROVIGO	45100.0	RO	Veneto	Italia	12/2/24 -  Contatto per collaborazione (attività spazio).#Luana	0	2025-06-20	12/2/24 -  Contatto per collaborazione (attività spazio).#Luana	www.synergysystem.it	NaN	0425-474511	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.150375	f	f	\N	\N	[]	0	active	\N	pending	\N
1881640	\N	STUDIO PRITONI		NaN	Via Porrettana, 148/3	Bologna	40135.0	Bologna	Emilia-Romagna	Italia		0	2025-06-20	NaN	NaN	dr.a.pritoni@studiopritoni.it	051.6151741	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.133391	f	f	\N	\N	[]	0	active	\N	pending	\N
1881633	\N	NECCHIO ALESSANDRO	NCCLSN81A01A059H	NCCLSN81A01A059H	VIA SAN GIUSEPPE, 1	SELVAZZANO DENTRO	35030.0	PD	Veneto	Italia		0	2025-06-20	NaN	NaN	NaN	0498056445	\N	Nord-Est	["Pier Luigi Menin"]	2025-07-03 20:34:38.13068	f	f	\N	\N	[]	0	active	\N	pending	\N
1881595	\N	STUDIO ASSOCIATO MAZZONI & PARTNERS	03584721207	03584721207	VIA MARCO EMILIO LEPIDO, 218/3	BOLOGNA	40132.0	BO	Emilia Romagna	Italia		0	2025-06-19	NaN	NaN	NaN	051.405207	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.128097	f	f	\N	\N	[]	0	active	\N	pending	\N
1881582	\N	GHINATO & ASSOCIATI	02265260238	02265260238	VIA VALPOLICELLA, 20/A	VERONA	37124.0	VR	Veneto	Italia		0	2025-06-19	NaN	www.studioghinato.net	NaN	045.941155-045.941089	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.124897	f	f	\N	\N	[]	0	active	\N	pending	\N
1881580	\N	UNIDEA SRL	03164800983	03164800983	VIA MALTA, 12	BRESCIA	25124.0	BS	Lombardia	Italia		37	2025-06-19	NaN	www.unideassicurazioni.it	NaN	030 2427567	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.121485	f	f	\N	\N	[]	0	active	\N	pending	\N
1881579	\N	L'UNIONE SARDA S.P.A.	01687830925	01687830925	PIAZZETTA L'UNIONE SARDA, 24	CAGLIARI	9122.0	CA	Sardegna	Italia		100	2025-06-19	NaN	www.unionesarda.it	NaN	070 60131	\N	Nord-Ovest	["Giovanni Fulgheri"]	2025-07-03 20:34:38.118182	f	f	\N	\N	[]	0	active	\N	pending	\N
1881558	\N	STUDIO CRABILLI & MONARI S.R.L.	03705530370	03705530370	VIA RODOLFO AUDINOT, 34	BOLOGNA	40134.0	BO	Emilia-romagna	Italia		6	2025-06-19	NaN	www.studiocrabillimonari.it	NaN	051583978	\N	Nord-Est	["Maria Silvia Gentile"]	2025-07-03 20:34:38.115278	f	f	\N	\N	[]	0	active	\N	pending	\N
\.


--
-- Data for Name: contacts; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.contacts (id, company_id, nome, cognome, codice, indirizzo, citta, cap, provincia, regione, stato, ruolo_aziendale, email, telefono, sesso, sales_persons, note, sorgente, data_nascita, luogo_nascita, skype, codice_fiscale, created_at) FROM stdin;
c425bf31-4dc5-42c4-96c3-ec54d12d3c4b	\N	Matteo	Boieri	\N	\N	\N	\N	\N	\N	\N	Amministratore Delegato	matteo.boieri@autoveicolierzelli.it	320.4195926	\N	{}		Giorgio Vento	\N				\N
53c6d96a-cdb5-4dc9-8f16-aab774d2c793	1571424	Federico	Lolli	\N	\N	\N	\N	\N	\N	\N	Socio	f.lolli@rlslex.it	348.8711002	\N	{}		Maria Silvia Gentile	\N				\N
e9465c46-286e-404c-8033-56b4e7b5a3e2	\N	Alessandro	Ladu	\N	\N	\N	\N	\N	\N	\N	Referente	alessandro.ladu@laduservizi.com	3455913950	\N	{}			\N				\N
bd5a0ae3-c64c-4620-941c-0bc30baa471f	\N	Sandro	Pisanu	\N	\N	\N	\N	\N	\N	\N	13/02/2025 16:14:14			\N	{}	Fabio Aliboni		\N				\N
e365d3b4-83aa-4b3f-9b99-40a86d0f9dab	1569045	Maria Silvia	Gentile	\N	\N	\N	\N	\N	\N	\N	Area Manager	ms.gentile@enduser-italia.com	351 3864077	\N	{}			\N				\N
70a55c0a-579d-49e5-bf28-7aff08319fc7	1569045	Fabio	Aliboni	\N	\N	\N	\N	\N	\N	\N	Area Manager	f.aliboni@enduser-italia.com	378 3073508	\N	{}			\N				\N
b0e01de5-acc7-4daa-946c-3eea4ed55cc0	1569045	Pier Luigi	Menin	\N	\N	\N	\N	\N	\N	\N	Account Manager	p.menin@enduser-italia.com	351 3715381	\N	{}			\N				\N
14d01f3b-e7b1-4472-b2f6-6541135f6013	1569045	Giovanni	Fulgheri	\N	\N	\N	\N	\N	\N	\N	Account Manager	g.fulgheri@enduser-italia.com	346 8545437	\N	{}			\N				\N
308ab24b-3962-4b6d-a410-671fc9463eed	1569045	Francesca	De Vita	\N	\N	\N	\N	\N	\N	\N	Account Manager	f.devita@enduser-italia.com	333 8870772	\N	{}			\N				\N
9618e923-28eb-4fee-9999-dbecbf9e0661	1569045	Francesca	Zarfati	\N	\N	\N	\N	\N	\N	\N	Customer Care	f.zarfati@enduser-italia.com	378 3056160	\N	{}			\N				\N
ffc55006-12e0-4b7d-b9c8-1b8993ec4396	1569045	Francesco	Rainaldi	\N	\N	\N	\N	\N	\N	\N	Customer Care	f.rainaldi@enduser-italia.com	351 3704890	\N	{}			\N				\N
65d607d7-402d-4bee-9af7-5ffff13ed21b	1569045	Sabrina	Cristofanelli	\N	\N	\N	\N	\N	\N	\N	Customer Care	s.cristofanelli@enduser-italia.com	351 3001244	\N	{}			\N				\N
39b0e692-54fb-4586-a42a-fca163d4ca44	1569045	Barbara Mercedes	Romano	\N	\N	\N	\N	\N	\N	\N	Amministrazione	b.romano@enduser-italia.com	351 9581736	\N	{}			\N				\N
50dcbb80-9323-4ef0-b368-3a5f09e0b82f	1569045	Massimiliano	Ciotti	\N	\N	\N	\N	\N	\N	\N	Business Strategies	m.ciotti@enduser-italia.com	378 3073523;3482619045	\N	{}			\N				\N
87059e32-a343-4d07-a7af-9992575b788f	1569045	Candida	Persico	\N	\N	\N	\N	\N	\N	\N	HR &amp; Controller	c.persico@enduser-italia.com	378 3053717	\N	{}			\N				\N
db6f7151-5e0a-4779-969f-3d4bb30fdece	1584056	Elena	Bergero	\N	\N	\N	\N	\N	\N	\N	Revisore interno			\N	{}			\N				\N
87a0716e-dbc6-45a3-a5c7-b98c6a627b2e	\N	Carola	De Donno	\N	\N	\N	\N	\N	\N	\N	Revisore	carola.dedonno@studiodedonno.net		\N	{}			\N				\N
626b4336-8c25-467f-a9df-faad2ad099ec	\N	Federico	Gori	\N	\N	\N	\N	\N	\N	\N	Revisore	studiofgori@gmail.com		\N	{}			\N				\N
0b30208a-35bd-49ff-98ec-f51d759b3c69	1591370	Stefano	Ceccuti	\N	\N	\N	\N	\N	\N	\N	Commerciale	stefano.ceccuti@dataitaliasrl.it		\N	{}		Fiera Tirreno CT	\N				\N
604ffbe5-a49f-41d4-8ba3-6a2f278a77ca	\N	Barbara	Graverini	\N	\N	\N	\N	\N	\N	\N	Titolare	sinergie.livorno@gmail.com		\N	{}			\N				\N
\.


--
-- Data for Name: document_chunks; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.document_chunks (id, document_id, chunk_index, content_chunk, vector_id, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: document_chunks_v2; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.document_chunks_v2 (id, document_id, chunk_index, chunk_text, vector_id, created_at) FROM stdin;
6	4	0	Hotel Reputation Management Software Professionale | Rebyu AI Non hai tempo di rispondere alle recensioni? Rivoluziona il modo in cui gestisci le recensioni degli ospiti. Provalo gratis Rebyu è il primo reputation management software italiano basato sull'AI. Genera risposte personalizzate, migliora la tua reputazione online e ti fa risparmiare tempo. Prenota ora una demo personalizzata Distinguiti davvero con risposte brillanti e su misura, capaci di potenziare la tua reputazione online in modo tangibile. Mostra ai tuoi ospiti la tua professionalità, la tua attenzione ai dettagli e la tua capacità di gestire ogni situazione con risposte coinvolgenti e curate. Ogni risposta è un capolavoro Il segreto di Rebyu è nel prompt, scritto da esperti di comunicazione, marketing e Hospitality con la supervisione di Maurizio D’Atri, massimo esperto italiano di recensioni alberghiere. Ogni risposta è studiata per creare connessioni autentiche e durature con gli ospiti. Risposte uniche , con il tuo stile Dì addio alle risposte impersonali. Con un rapido settaggio iniziale, Rebyu apprende il tono di voce e lo stile distintivo del tuo brand. In pochi secondi generi risposte personalizzate e coerenti con l’identità della tua struttura. Guarda Rebyu in azione. Basta 1 minuto . Liberati dal peso delle recensioni e lascia che Rebyu lavori per te . Provalo gratis Prenota ora una demo personalizzata Funzionalità e caratteristiche tecniche Tutto su un’unica piattaforma Rebyu raccoglie automaticamente le recensioni da Booking.com, Google, TripAdvisor e Expedia, semplificando la gestione multicanale della reputazione online. 100 lingue Con la traduzione in tempo reale delle recensioni e delle risposte, Rebyu ti permette di comunicare con ospiti di ogni nazionalità. Obiettivi mirati Vuoi rispondere a una recensione ingiusta o valorizzare la tua destinazione? Rebyu ti consente di selezionare il tono e l’intento della risposta, oppure utilizzare preset professionali configurati da esperti. Dashboard intuitivaMonitora recensioni, valutazioni e velocità di risposta in un unico luogo. Gestione multi-accountPerfetta per strutture singole o catene. 5 account per struttura e possibilità di gestire più hotel da un unico account master: Rebyu si adatta alle esigenze di ogni team di lavoro. Notifiche personalizzateScegli se ricevere notifiche per tutte le recensioni o solo in determinati casi, comodamente via mail o Whatsapp. Scopri di più Costruisci una reputazione online impeccabile senza sforzo. Con Rebyu puoi. Risparmiare tempo Difenderti dalle recensioni negative Migliorare la tua reputazione online Salire nel ranking di Google Aumentare il tuo punteggio medio su tutte le piattaforme Aumentare le prenotazioni Fidelizzare gli ospiti Ecco cosa succede quando inizi a rispondere alle recensioni recensioni positive* + 0 % stella di rating* + 0 /2 prenotazioni* + 0 % entrate** + 0 % * Dopo 6 mesi, studio Harward Business Review** Dopo un anno, studio Harvard Business School Prenota una demo personalizzata e scopri come rivoluzionare la tua reputazione online. Provalo gratis Prenota ora una demo personalizzata I nostri consigli per far brillare la tua immagine online 4 Luglio 2025Gestire una catena di alberghi: come mantenere una comunicazione coerente tra più strutture 2 Luglio 2025Google My Business: l’arma segreta per le prenotazioni dirette del tuo hotel 30 Giugno 2025Revenue management e gestione delle recensioni: strategie vincenti per gli albergatori ✕Caratteristiche Pricing Partnership Blog FAQ Contattaci Acquista Provalo gratis Compila il form per iscriverti e ricevere il link di partecipazione. × Benvenuto in Rebyu! Riceverai a breve una mail con le tue credenziali di accesso. × Ti chiamiamo noi! Compila il form e un nostro consulente ti contatterà per avviare la tua demo personalizzata. La tua privacy è per noi molto importante. Consulta la Privacy Policy per conoscere la nostra politica sull'elaborazione dei dati che spiega le finalità per le quali useremo le informazioni personali. ×	06742664-61bd-4f2d-832a-8b5fd5786828	2025-07-07 17:13:45.391137
\.


--
-- Data for Name: kit_articoli; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.kit_articoli (id, kit_commerciale_id, articolo_id, quantita, obbligatorio, ordine) FROM stdin;
1	1	3	1	f	1
5	1	7	1	f	0
6	1	2	1	f	0
7	9	6	1	f	0
8	9	4	1	f	0
9	9	9	1	f	2
10	9	8	1	f	3
\.


--
-- Data for Name: kit_commerciali; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.kit_commerciali (id, nome, descrizione, articolo_principale_id, attivo, created_at) FROM stdin;
1	Kit Incarico 24 Mesi	Kit commerciale per Incarico 24 Mesi	2	t	2025-07-10 13:34:10.134718
2	Kit PMI Completo	Kit per PMI innovative	2	t	2025-07-10 13:43:05.951244
3	Kit PMI Digital Transformation	Kit commerciale per PMI Digital Transformation	\N	t	2025-07-10 17:28:39.085858
4	Kit Start Office Finance	Kit commerciale per Start Office Finance	10	t	2025-07-10 17:31:43.173565
5	Kit Start Office Digital	Kit commerciale per Start Office Digital	11	t	2025-07-10 17:31:54.344124
6	Kit Start Office Training	Kit commerciale per Start Office Training	13	t	2025-07-10 17:32:27.944322
8	Kit Start Office Sustainability	Kit commerciale per Start Office Sustainability	15	t	2025-07-17 14:28:38.23589
9	Kit Incarico Consulenza Strumenti Economico- Finanziari	Kit commerciale per Incarico Consulenza Strumenti Economico- Finanziari	17	t	2025-07-17 17:21:39.457195
\.


--
-- Data for Name: knowledge_documents; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.knowledge_documents (id, filename, content_type, file_size, content_hash, extracted_text, metadata, processed_at, company_id, uploaded_by, created_at, updated_at) FROM stdin;
d5c1acb8-3e07-4a95-8c94-cd0353f36f90	scraped_20250707_143745.html	\N	\N	\N	AI Infrastructure, Secure Networking, and Software Solutions - Cisco Skip to main content Skip to search Skip to footer Cisco.com Worldwide Products and Services Close Solutions Close Support Close Learn Close Why Cisco Close Partners Close Trials and demos How to buy Partners EN US Profile Log in Trials and demos MENU CLOSE How to buy Partners Profile Log in EN US Close Close Close Close Close AI architecture AI-ready smart switches Future-proof your network architecture with Cisco C9350 Series Smart Switches, which deliver security, scale, and flexibility purpose-built for an AI enterprise. Explore smart switches Register for a demo Catch up from Cisco Live Press release Powering the future of secure AI infrastructure Read about secure AI infrastructure Press release Unveiling secure network architecture to accelerate workplace AI transformation Read about workplace AI transformation Press release Transforming security for the agentic AI era, further fusing security into the network Read about security in the agentic AI era Press release Powering AI-ready data centers, from hyperscale to enterprise Read about AI-ready data centers Our most popular launches Hybrid Mesh Firewall Employ better enforcement points, smarter segmentation, and multi-vendor policy. Explore new capabilities Nexus Dashboard Gain end-to-end visibility across networks, GPUs, and AI tasks for proactive issue detection. Explore Nexus Dashboard AgenticOps Meet AI Canvas—where AgenticOps comes to life. Learn about AgenticOps Smart Switches Deploy new Cisco Smart Switches for the AI-powered enterprise. Explore new Smart Switches Wi-Fi for the AI Enterprise Deliver exceptional wireless performance for high-density venues. Explore wireless launches Splunk + Cisco ThousandEyes Unify views across application, infrastructure, and networking domains. Explore new integrations Show more Browse by technology Networking Security Observability Collaboration Computing AI View all products Why Cisco for the AI era Let's get started Only Cisco combines the power of the network with security, observability, and collaboration to help you thrive in the AI era. Explore trials and demos View buying options Hello, how can I help? Quick Links About CiscoContact UsCareersConnect with a partner Resources and Legal FeedbackHelpTerms & ConditionsPrivacy Cookies / Do not sell or share my personal data AccessibilityTrademarksSupply Chain TransparencyNewsroomSitemap © Cisco Systems, Inc.	{}	\N	\N	\N	2025-07-07 14:37:45.831119	2025-07-07 14:37:45.831119
528288ef-460c-4dfc-9dc5-cd96d44eec19	scraped_20250714_085550.html	\N	\N	\N	Herman Melville - Moby-Dick Availing himself of the mild, summer-cool weather that now reigned in these latitudes, and in preparation for the peculiarly active pursuits shortly to be anticipated, Perth, the begrimed, blistered old blacksmith, had not removed his portable forge to the hold again, after concluding his contributory work for Ahab's leg, but still retained it on deck, fast lashed to ringbolts by the foremast; being now almost incessantly invoked by the headsmen, and harpooneers, and bowsmen to do some little job for them; altering, or repairing, or new shaping their various weapons and boat furniture. Often he would be surrounded by an eager circle, all waiting to be served; holding boat-spades, pike-heads, harpoons, and lances, and jealously watching his every sooty movement, as he toiled. Nevertheless, this old man's was a patient hammer wielded by a patient arm. No murmur, no impatience, no petulance did come from him. Silent, slow, and solemn; bowing over still further his chronically broken back, he toiled away, as if toil were life itself, and the heavy beating of his hammer the heavy beating of his heart. And so it was.—Most miserable! A peculiar walk in this old man, a certain slight but painful appearing yawing in his gait, had at an early period of the voyage excited the curiosity of the mariners. And to the importunity of their persisted questionings he had finally given in; and so it came to pass that every one now knew the shameful story of his wretched fate. Belated, and not innocently, one bitter winter's midnight, on the road running between two country towns, the blacksmith half-stupidly felt the deadly numbness stealing over him, and sought refuge in a leaning, dilapidated barn. The issue was, the loss of the extremities of both feet. Out of this revelation, part by part, at last came out the four acts of the gladness, and the one long, and as yet uncatastrophied fifth act of the grief of his life's drama. He was an old man, who, at the age of nearly sixty, had postponedly encountered that thing in sorrow's technicals called ruin. He had been an artisan of famed excellence, and with plenty to do; owned a house and garden; embraced a youthful, daughter-like, loving wife, and three blithe, ruddy children; every Sunday went to a cheerful-looking church, planted in a grove. But one night, under cover of darkness, and further concealed in a most cunning disguisement, a desperate burglar slid into his happy home, and robbed them all of everything. And darker yet to tell, the blacksmith himself did ignorantly conduct this burglar into his family's heart. It was the Bottle Conjuror! Upon the opening of that fatal cork, forth flew the fiend, and shrivelled up his home. Now, for prudent, most wise, and economic reasons, the blacksmith's shop was in the basement of his dwelling, but with a separate entrance to it; so that always had the young and loving healthy wife listened with no unhappy nervousness, but with vigorous pleasure, to the stout ringing of her young-armed old husband's hammer; whose reverberations, muffled by passing through the floors and walls, came up to her, not unsweetly, in her nursery; and so, to stout Labor's iron lullaby, the blacksmith's infants were rocked to slumber. Oh, woe on woe! Oh, Death, why canst thou not sometimes be timely? Hadst thou taken this old blacksmith to thyself ere his full ruin came upon him, then had the young widow had a delicious grief, and her orphans a truly venerable, legendary sire to dream of in their after years; and all of them a care-killing competency.	{}	\N	\N	\N	2025-07-14 08:55:50.61741	2025-07-14 08:55:50.61741
6ffe2f6c-afb4-483e-8f51-cb6c30e131b3	scraped_20250714_123049.html	\N	\N	\N	GoogleGmailImagesConnexion Recherche avancéePublicitéSolutions d'entrepriseÀ propos de GoogleGoogle.fr© 2025 - Confidentialité - Conditions	{}	\N	\N	\N	2025-07-14 12:30:50.012904	2025-07-14 12:30:50.012904
8e629bc5-263b-4ec3-b364-e7e85f3b11b2	scraped_20250714_131813.html	\N	\N	\N	Profumi in Farmacia: profumi La Maison Des Essences Vai al contenuto principalePassa al footerBrandCertificazioni e qualitàPiramide OlfattivaProfumiProfumi DonnaProfumi UomoFamiglie OlfattiveProfumi florealiProfumi orientaliProfumi legnosiProfumi agrumatiProfumi fruttatiProfumi marini e acquaticiProfumi gourmandProfumi speziatiProfumi muschiatiProfumi aromaticiFarmaciePrivate LabelDealersContatti BrandCertificazioni e qualitàPiramide OlfattivaProfumiProfumi DonnaProfumi UomoFamiglie OlfattiveProfumi florealiProfumi orientaliProfumi legnosiProfumi agrumatiProfumi fruttatiProfumi marini e acquaticiProfumi gourmandProfumi speziatiProfumi muschiatiProfumi aromaticiFarmaciePrivate LabelDealersContatti 0 Cerca... Profumiin farmaciaPer uomo e donna nel formato tradizionale da 100 ml.Acquista subito online oppure provali in farmaciaProfumi in farmaciaLa linea di profumeria per Farmacie per uomo e donna La Maison Des Essences. Scopri tutta la qualità e la piacevolezza delle fragranze. 2 collezioni: le tradizionali confezioni da 100ml.Vai all'elenco farmacieElenco Farmacie La Maison Des EssencesProfumi donnaProfumi uomoProfumo 7915,90 €Aggiungi al carrello Profumo 7815,90 €Aggiungi al carrello Profumo 7715,90 €Aggiungi al carrello Profumo 7615,90 €Aggiungi al carrello Profumi in farmaciaLa Maison Des Essences è un marchio di profumi per Farmacia in vendita nelle migliori Farmacie italiane e online sul nostro sito.I profumi per Farmacia La Maison Des Essences sono fragranze distribuite sul mercato farmaceutico. Nascono dalle essenze scelte con cura dai mastri profumieri e sono sottoposte a test e analisi nei laboratori di produzione, così da assicurare non soltanto un vastissimo assortimento di fragranze maschili e femminili, ma anche la libertà di indossare il proprio profumo con tutta la sicurezza di un prodotto garantito e certificato.Qualità, sicurezza e convenienza sono le parole d’ordine per i prodotti de La Maison Des Essences: qualità nella scelta di fragranze ed essenze odorose, sicurezza garantita dai test e le analisi effettuate sui profumi, convenienza per incontrare le necessità di tutti coloro che sono in cerca di un profumo eccellente da abbinare al proprio corpo.Acquista i profumi da farmacia onlineProfumi in Farmacia? Ecco perché La Maison Des EssencesLa Maison Des Essences nasce con il preciso obiettivo di proporre una vasta selezione di profumi da farmacia femminili e maschili, garantendo l’eccellenza qualitativa nell’elaborazione delle fragranze e mantenendo, allo stesso tempo, prezzi di acquisto accessibili nella vendita al dettaglio. La Maison Des Essences è un marchio distribuito nelle Farmacie italiane da: MAST INDUSTRIA ITALIANA srl. L’impegno de La Maison Des Essences alla vendita di profumi in Farmacia, luogo deputato per eccellenza alla salute, dimostra la volontà di presentare una linea di profumeria di altissima qualità, sicura e testata per la pelle, ad un prezzo di vendita estremamente vantaggioso rispetto alle linee di profumeria tradizionale.Famiglie olfattiveScoprile famiglie olfattive!Piramide olfattivaScopri la piramide olfattiva!Seguici su FacebookSeguici su InstagramLa Maison des essencesMAST INDUSTRIA ITALIANA SRLVia Variante di Cancelliera snc - 00072 Ariccia, RMTelefono: +39 069342642 - Email: [email protected]P.IVA 10865581002InfoElenco farmacieContattiFamiglie olfattivePrivate LabelDealersCopyright © La Maison des EssencesPrivacy PolicyGestione ConsensiTermini & Condizioni My Agile Privacy✕Questo sito utilizza cookie tecnici e di profilazione. Puoi accettare, rifiutare o personalizzare i cookie premendo i pulsanti desiderati. Chiudendo questa informativa continuerai senza accettare. Inoltre, questo sito installa Google Analytics nella versione 4 (GA4), Facebook Remarketing con trasmissione di dati anonimi tramite proxy. Prestando il consenso, l'invio dei dati sarà effettuato in maniera anonima, tutelando così la tua privacy. AccettaRifiutaPersonalizzaGestisci il consenso ✕ Chiudi Impostazioni privacy Questo sito utilizza i cookie per migliorare la tua esperienza di navigazione su questo sito. Visualizza la Cookie Policy Visualizza l'Informativa Privacy My Agile Pixel – Google Analytics Sempre AbilitatoGoogle Analytics è un servizio di analisi web fornito da Google Ireland Limited (“Google”). Google Ireland Limited è di proprietà di Google LLC USA. Google utilizza i Dati Personali raccolti per tracciare ed esaminare l’uso di questo sito, compilare report sulle sue attività e condividerli con gli altri servizi sviluppati da Google.Per garantire una maggiore aderenza al GDPR in merito al trasferimento dei dati al di fuori dell'UE, è opportuno effettuare tale trasferimento esclusivamente in forma anonima. È importante sottolineare che la semplice anonimizzazione non offre un livello di protezione sufficiente per i dati personali esportati al di fuori dell'UE. Per questo motivo, i dati inviati a Google Analytics, e quindi potenzialmente visibili anche al di fuori dell'UE, potranno essere resi anonimi attraverso un sistema di proxy denominato My Agile Pixel. Questo sistema potrà sostituire i tuoi dati personali, come l'indirizzo IP, con informazioni anonime che non sono riconducibili alla tua persona. Di conseguenza, nel caso in cui avvenga un trasferimento di dati verso Paesi extra UE o negli Stati Uniti, non si tratterà dei tuoi dati personali, ma di dati anonimi.I dati inviati vengono collezionati per gli scopi di personalizzazione dell'esperienza e il tracciamento statistico. Trovi maggiori informazioni alla pagina "Ulteriori informazioni sulla modalità di trattamento delle informazioni personali da parte di Google".Consensi aggiuntivi: Ad Storage Ad Storage Definisce se i cookie relativi alla pubblicità possono essere letti o scritti da Google. Ad User Data Ad User Data Determina se i dati dell'utente possono essere inviati a Google per scopi pubblicitari. Ad Personalization Ad Personalization Controlla se la pubblicità personalizzata (ad esempio, il remarketing) può essere abilitata. Analytics Storage Analytics Storage Definisce se i cookie associati a Google Analytics possono essere letti o scritti. Google Tag Manager Sempre AbilitatoGoogle Tag Manager è un servizio di gestione dei tag fornito da Google Ireland Limited.I dati inviati vengono collezionati per gli scopi di personalizzazione dell'esperienza e il tracciamento statistico. Trovi maggiori informazioni alla pagina "Ulteriori informazioni sulla modalità di trattamento delle informazioni personali da parte di Google".Luogo del trattamento: Irlanda - Privacy Policy Google Fonts Google Fonts Google Fonts è un servizio per visualizzare gli stili dei caratteri di scrittura gestito da Google Ireland Limited e serve ad integrare tali contenuti all’interno delle proprie pagine.Luogo del trattamento: Irlanda - Privacy Policy My Agile Pixel – Facebook Remarketing My Agile Pixel – Facebook Remarketing Facebook Remarketing è un servizio di Remarketing e Behavioral Targeting fornito da Facebook Ireland Ltd. Questo servizio è usato per collegare l'attività di questo sito con il network di advertising Facebook.Per garantire una maggiore aderenza al GDPR in merito al trasferimento dei dati al di fuori dell'UE, è opportuno effettuare tale trasferimento esclusivamente in forma anonima. È importante sottolineare che la semplice anonimizzazione non offre un livello di protezione sufficiente per i dati personali esportati al di fuori dell'UE. Per questo motivo, i dati inviati a Google Analytics, e quindi potenzialmente visibili anche al di fuori dell'UE, potranno essere resi anonimi attraverso un sistema di proxy denominato My Agile Pixel. Questo sistema potrà sostituire i tuoi dati personali, come l'indirizzo IP, con informazioni anonime che non sono riconducibili alla tua persona. Di conseguenza, nel caso in cui avvenga un trasferimento di dati verso Paesi extra UE o negli Stati Uniti, non si tratterà dei tuoi dati personali, ma di dati anonimi.	{}	\N	\N	\N	2025-07-14 13:18:13.980122	2025-07-14 13:18:13.980122
772f9ae4-9f09-42af-9de3-be0f37c8cc5c	scraped_20250714_133047.html	\N	\N	\N	GoogleGmailImagesConnexion Recherche avancéePublicitéSolutions d'entrepriseÀ propos de GoogleGoogle.fr© 2025 - Confidentialité - Conditions	{}	\N	\N	\N	2025-07-14 13:30:47.203448	2025-07-14 13:30:47.203448
ad5db80f-5c5b-4708-aa2f-e3b023f7cb65	scraped_20250714_133742.html	\N	\N	\N	GitHub · Build and ship software on a single, collaborative platform · GitHub Skip to content Navigation Menu Toggle navigation Sign in Product GitHub Copilot Write better code with AI GitHub Models New Manage and compare prompts GitHub Advanced Security Find and fix vulnerabilities Actions Automate any workflow Codespaces Instant dev environments Issues Plan and track work Code Review Manage code changes Discussions Collaborate outside of code Code Search Find more, search less Explore Why GitHub All features Documentation GitHub Skills Blog Solutions By company size Enterprises Small and medium teams Startups Nonprofits By use case DevSecOps DevOps CI/CD View all use cases By industry Healthcare Financial services Manufacturing Government View all industries View all solutions Resources Topics AI DevOps Security Software Development View all Explore Learning Pathways Events & Webinars Ebooks & Whitepapers Customer Stories Partners Executive Insights Open Source GitHub Sponsors Fund open source developers The ReadME Project GitHub community articles Repositories Topics Trending Collections Enterprise Enterprise platform AI-powered developer platform Available add-ons GitHub Advanced Security Enterprise-grade security features Copilot for business Enterprise-grade AI features Premium Support Enterprise-grade 24/7 support Pricing Search or jump to... Search code, repositories, users, issues, pull requests... Search Clear Search syntax tips Provide feedback We read every piece of feedback, and take your input very seriously. Include my email address so I can be contacted Cancel Submit feedback Saved searches Use saved searches to filter your results more quickly Name Query To see all available qualifiers, see our documentation. Cancel Create saved search Sign in Sign up Resetting focus You signed in with another tab or window. Reload to refresh your session. You signed out in another tab or window. Reload to refresh your session. You switched accounts on another tab or window. Reload to refresh your session. Dismiss alert Build and ship software on a single, collaborative platformJoin the world’s most widely adopted AI-powered developer platform.Enter your emailSign up for GitHubTry GitHub CopilotGitHub featuresA demonstration animation of a code editor using GitHub Copilot Chat, where the user requests GitHub Copilot to refactor duplicated logic and extract it into a reusable function for a given code snippet.CodePlanCollaborateAutomateSecureCodeBuild code quickly and more securely with GitHub Copilot embedded throughout your workflows.GitHub is used byAccelerate performanceWith GitHub Copilot embedded throughout the platform, you can simplify your toolchain, automate tasks, and improve the developer experience.A Copilot chat window with extensions enabled. The user inputs the @ symbol to reveal a list of five Copilot Extensions. @Sentry is selected from the list, which shifts the window to a chat directly with that extension. There are three sample prompts at the bottom of the chat window, allowing the user to Get incident information, Edit status on incident, or List the latest issues. The last one is activated to send the prompt: @Sentry List the latest issues. The extension then lists several new issues and their metadata.Work 55% faster.Jump to footnote 1 Increase productivity with AI-powered coding assistance, including code completion, chat, and more.Explore GitHub CopilotDuolingo boosts developer speed by 25% with GitHub CopilotRead customer story2024 Gartner® Magic Quadrant™ for AI Code AssistantsRead reportAutomate any workflowOptimize your process with simple and secured CI/CD.A list of workflows displays a heading ‘45,167 workflow runs’ at the top. Below are five rows of completed workflows accompanied by their completion time and their duration formatted in minutes and seconds.Discover GitHub ActionsGet up and running in secondsStart building instantly with a comprehensive dev environment in the cloud.A GitHub Codespaces setup for the landing page of a game called OctoInvaders. On the left is a code editor with some HTML and Javascript files open. On the right is a live render of the page. In front of this split editor window is a screenshot of two active GitHub Codespaces environments with their branch names and a button to ‘Create codespace on main.’Check out GitHub CodespacesBuild on the goManage projects and chat with GitHub Copilot from anywhere.Two smartphone screens side by side. The left screen shows a Notification inbox, listing issues and pull requests from different repositories like TensorFlow and GitHub’s OctoArcade octoinvaders. The right screen shows a new conversation in GitHub Copilot chat.Download GitHub MobileIntegrate the tools you loveSync with 17,000+ integrations and a growing library of Copilot Extensions.A grid of fifty app tiles displays logos for integrations and extensions for companies like Stripe, Slack, and Docker. The tiles extend beyond the bounds of the image to indicate a wide array of apps. Visit GitHub MarketplaceBuilt-in application security where found means fixedUse AI to find and fix vulnerabilities—freeing your teams to ship more secure software faster.Apply fixes in seconds. Spend less time fixing vulnerabilities and more time building features with Copilot Autofix.Explore GitHub Advanced SecuritySolve security debt. Leverage AI-assisted security campaigns to reduce application vulnerabilities and zero-day attacks.Discover security campaignsDependencies you can depend on. Update vulnerable dependencies with supported fixes for breaking changes.Learn about DependabotYour secrets, your business: protected. Detect, prevent, and remediate leaked secrets across your organization.Read about secret scanning7x faster vulnerability fixes with GitHubJump to footnote 290% coverage of alert types in all supported languages with Copilot AutofixWork together, achieve moreCollaborate with your teams, use management tools that sync with your projects, and code from anywhere—all on a single, integrated platform.Your workflows, your way. Plan effectively with an adaptable spreadsheet that syncs with your work.Jump into GitHub Projects“It helps us onboard new software engineers and get them productive right away. We have all our source code, issues, and pull requests in one place... GitHub is a complete platform that frees us from menial tasks and enables us to do our best work.Fabian FaulhaberApplication manager at Mercedes-BenzKeep track of your tasksCreate issues and manage projects with tools that adapt to your code.Display of task tracking within an issue, showing the status of related sub-issues and their connection to the main issue.Explore GitHub IssuesShare ideas and ask questionsCreate space for open-ended conversations alongside your project.A GitHub Discussions thread where a GitHub user suggests a power-up idea involving Hubot revealing a path and protecting Mona. The post has received 5 upvotes and several reactions. Below, three other users add to the discussion, suggesting Hubot could provide different power-ups depending on levels and appreciating the collaboration idea.Discover GitHub DiscussionsReview code changes togetherCreate review processes that improve code quality and fit neatly into your workflow.Two code review approvals by helios-ackmore and amanda-knox, which are followed by three successful checks for ‘Build,’ ‘Test,’ and ‘Publish.’Learn about code reviewFund open source projectsBecome an open source partner and support the tools and libraries that power your work.A GitHub Sponsors popup displays ‘$15,000 a month’ with a progress bar showing 87% towards a $15,000 goal.Dive into GitHub SponsorsFrom startups to enterprises, GitHub scales with teams of any size in any industry.By industryBy sizeBy use caseBy industryTechnologyFigma streamlines development and strengthens securityRead customer storyAutomotiveMercedes-Benz standardizes source code and automates onboardingRead customer storyFinancial servicesMercado Libre cuts coding time by 50%Read customer storyExplore customer storiesView all solutionsMillions of developers and businesses call GitHub homeWhether you’re scaling your development process or just learning how to code, GitHub is where you belong. Join the world’s most widely adopted AI-powered developer platform to build the technologies that redefine what’s possible.Enter your emailSign up for GitHubTry GitHub CopilotFootnotesSurvey: The AI wave continues to grow on software development teams, 2024.This 7X times factor is based on data from the industry’s longest running analysis of fix rates Veracode State of Software Security 2023, which cites the average time to fix 50% of flaws as 198 days vs. GitHub’s fix rates of 72% of flaws with in 28 days which is at a minimum of 7X faster when compared. Site-wide Links Subscribe to our developer newsletter Get tips, technical guides, and best practices. Twice a month. Subscribe Product Features Enterprise Copilot AI Security Pricing Team Resources Roadmap Compare GitHub Platform Developer API Partners Education GitHub CLI GitHub Desktop GitHub Mobile Support Docs Community Forum Professional Services Premium Support Skills Status Contact GitHub Company About Why GitHub Customer stories Blog The ReadME Project Careers Newsroom Inclusion Social Impact Shop © 2025 GitHub, Inc. Terms Privacy (Updated 02/2024)02/2024 Sitemap What is Git? Manage cookies Do not share my personal information GitHub on LinkedIn Instagram GitHub on Instagram GitHub on YouTube GitHub on X TikTok GitHub on TikTok Twitch GitHub on Twitch GitHub’s organization on GitHub You can’t perform that action at this time.	{}	\N	\N	\N	2025-07-14 13:37:42.304432	2025-07-14 13:37:42.304432
a9fb921a-7c66-441e-8985-5b00327a7765	scraped_20250714_134117.html	\N	\N	\N	1 Byte: specialisti dell'IT | 1 Byte Salta al contenuto Toggle NavigationMSPLavora con noiAssistenzaToggle Navigation02 80 88 93 12ContattaciMenuHomeChi SiamoCloudITCyber SecurityBlogPortale Assistenza02 80 88 93 12ContattaciToggle NavigationHomeChi SiamoCloudITCyber SecurityBlogPortale Assistenza Il futuro della tua attività inizia quiAnalizziamo le esigenze dei nostri clienti e proponiamo soluzioni Richiedi un contatto 1 Byte: specialisti dell’IT1 Byte2023-05-01T19:20:21+02:00 Come lavoriamoAnalisi delle esigenzeL’analisi è fondamentale per capire le esigenze del cliente IT AssessmentL’analisi dell’infrastruttura informatica esistente La proposta di ProgettoLa presentazione del progetto e del preventivo Delivery di progettoLa fase operativa Rilascio dei servizi e go live!La fase conclusiva di consegna Specialisti del cloudIl nostro team è noto per: Esperienza tecnicaCapacità di migrazione dei datiSupporto post Go LiveLe nostre partnernershipRichiedi una consulenzaUfficio Via Camillo Finocchiaro Aprile, 5 20124 Milano (MI) Contatti info@1byte.it Orari Lunedì – Venerdì: 09:00 – 18:00 Close product quick view× Titolo Soluzioni Informatiche Software Gestionali Accesso rapidoCloudITCyber SecurityBlogMSPLavora con noiAssistenza1 Byte SrlVia Camillo Finocchiaro Aprile, 5 20124 Milano (MI) P.IVA 10132420968 (+39) 02 80 88 93 12info@1byte.it© 2025 • 1 Byte Srl Torna in alto Page load link	{}	\N	\N	\N	2025-07-14 13:41:17.118544	2025-07-14 13:41:17.118544
2cd273c9-6923-4534-92f0-0344c9dac387	scraped_20250714_134646.html	\N	\N	\N	Home - 12oz: Street coffee for people on the move Home Coffee&Drinks Food Franchising Store Locator News Home12oz_Admin2025-06-25T12:29:21+02:00 Frozen Coffee Corri a provarlo Street coffee for people on the move Coffee&Drinks Il meglio dello street coffee Un ottimo caffè e non solo: un’ampia gamma bevande caffeine based calde e fredde, da portare sempre con te, per immergerti nella giungla cittadina o partire per un lungo viaggio. Get your perfect boost! Food Sweet&Savoury Una selezione di squisiti dolci americani da gustare assieme alle bevande, assieme a una selezione di bagel, wrap e bowls per accontentare ogni gusto. Non ti è già venuta fame? News Curiosità e ultime novità Vuoi approfondire la tua conoscenza sul mondo del caffè? Vuoi conoscere le ultime novità del mondo 12oz? Vuoi aggiornarti sulle nuove aperture vicine a te? Leggi le ultime news Dove siamo Trova lo store più vicino a te Siamo presenti in Italia e all’estero con numerosi punti vendita e sicuramente anche vicino a te! Cerca subito il 12oz più vicino tramite il nostro store locator. Vieni a trovarci Apri il tuo 12oz Un retail format in grande crescita, caratterizzato da basso CAPEX e veloce ritorno sull’investimento. Perché non approfondire? Scopri di più INSTAGRAM12oz.streetcoffee SEGUICI » KEEP IN TOUCH Facebook Instagram Linkedin Tiktok Informazioni Aziendali Privacy Policy Cookie Policy GESTIONE COOKIE ©Copyright 2022-23. 12 OZ All Rights Reserved | P.IVA10097600968 NAVIGAZIONELINGUAHome Coffee&Drinks Food Franchising Store Locator News Gestisci Consenso Cookie Utilizziamo i cookie per personalizzare contenuti ed annunci, per fornire funzionalità dei social media e per analizzare il nostro traffico. Condividiamo inoltre informazioni sul modo in cui gli utenti utilizzano il nostro sito con i nostri partner che si occupano di analisi dei dati web, pubblicità e social media, i quali potrebbero combinarle con altre informazioni che ha fornito loro o che hanno raccolto dal suo utilizzo dei loro servizi. Continuando a navigare il sito si accetta l'utilizzo dei cookie. Funzionale Funzionale Sempre attivo I cookie necessari contribuiscono a rendere fruibile il sito web abilitandone funzionalità di base quali la navigazione sulle pagine e l'accesso alle aree protette del sito. Il sito web non è in grado di funzionare correttamente senza questi cookie. Preferenze Preferenze L'archiviazione tecnica o l'accesso sono necessari per lo scopo legittimo di memorizzare le preferenze che non sono richieste dall'abbonato o dall'utente. Statistiche Statistiche L'archiviazione tecnica o l'accesso che viene utilizzato esclusivamente per scopi statistici. I cookie statistici aiutano i proprietari del sito web a capire come i visitatori interagiscono con i siti raccogliendo e trasmettendo informazioni in forma anonima. Marketing Marketing L'archiviazione tecnica o l'accesso sono necessari per creare profili di utenti per inviare pubblicità, o per tracciare l'utente su un sito web o su diversi siti web per scopi di marketing simili. Gestisci opzioni Gestisci servizi Gestisci {vendor_count} fornitori Per saperne di più su questi scopi Accetta Nega Visualizza le preferenze Salva preferenze Visualizza le preferenze {title} {title} {title} Gestisci consenso	{}	\N	\N	\N	2025-07-14 13:46:46.910766	2025-07-14 13:46:46.910766
\.


--
-- Data for Name: milestone_task_templates; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.milestone_task_templates (id, milestone_id, nome, descrizione, ordine, durata_stimata_ore, ruolo_responsabile, obbligatorio, tipo_task, checklist_template, created_at) FROM stdin;
\.


--
-- Data for Name: milestones; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.milestones (id, opportunity_id, title, start_date, due_date, auto_generate_tickets, warning_days, escalation_days, template_data, commessa_id, tipo_commessa_id, stato, percentuale_completamento, sla_hours, data_inizio, data_fine_prevista, data_fine_effettiva, descrizione, created_by, workflow_milestone_id, articolo_id) FROM stdin;
\.


--
-- Data for Name: modelli_task; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.modelli_task (id, nome, descrizione, descrizione_operativa, sla_hours, ordine, is_required, milestone_id, tipo_commessa_id, created_at, updated_at, sla_giorni, warning_giorni, escalation_giorni, priorita) FROM stdin;
\.


--
-- Data for Name: modelli_ticket; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.modelli_ticket (id, nome, descrizione) FROM stdin;
\.


--
-- Data for Name: opportunities; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.opportunities (id, company_id, commessa_id, title, description, status, created_at) FROM stdin;
\.


--
-- Data for Name: order_rows; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.order_rows (id, ord_id, art_id, quantity, row_status, completion_percentage, ticket_id, task_id, custom_specs, notes, row_order, metadata, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.orders (id, cst_id, ord_date, ord_description, status, created_by, assigned_to, notes, internal_notes, metadata, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: partner; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.partner (id, nome, ragione_sociale, partita_iva, email, telefono, sito_web, indirizzo, note, attivo, created_at, updated_at) FROM stdin;
1	AV Media Trend	AVMT di Stefano Andrello	14209320960	info@avmedniatrend.com	+393476859801	avm,ediatrend.com	via Monte Grappa 13, 20094 Corsico (MI)		t	2025-07-17 16:51:43.744692	2025-07-17 16:51:43.744692
\.


--
-- Data for Name: partner_servizi; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.partner_servizi (id, partner_id, articolo_id, prezzo_partner, note, created_at) FROM stdin;
1	1	14	\N		2025-07-17 16:55:34.921378
\.


--
-- Data for Name: processing_queue; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.processing_queue (id, job_type, job_data, status, error_message, created_at, processed_at) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.roles (id, name, description, permissions, is_system_role, created_at) FROM stdin;
1	admin	Administrator with full access	{"all": true}	t	2025-07-04 08:17:07.092173
2	manager	Manager with team oversight	{"read": ["all"], "admin": ["users"], "write": ["tickets", "tasks"]}	t	2025-07-04 08:17:07.092173
3	operator	Standard operator	{"read": ["tickets", "tasks"], "write": ["tasks"]}	t	2025-07-04 08:17:07.092173
4	viewer	Read-only access	{"read": ["tickets", "tasks"]}	t	2025-07-04 08:17:07.092173
\.


--
-- Data for Name: sales_opportunities; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.sales_opportunities (id, sales_manager_id, sales_manager_type, cliente, company_id, data_apertura, stato_opportunita, valore_opportunita, created_at, tipo_opportunita, nome_opportunita, nuovo_cliente, origine_opportunita, data_presa_carico, delta_giorni, data_primo_appuntamento, fase_opportunita, percentuale_successo, data_presentazione_offerta, azione_da_fare, data_ultimo_aggiornamento, previsione_chiusura_mese, data_chiusura, note, riferimenti, priorita) FROM stdin;
\.


--
-- Data for Name: scraped_companies; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.scraped_companies (id, scraped_content_id, company_name, description, sector, company_size, website, email, phone, address_street, address_city, address_zip, address_country, partita_iva, social_media, services_offered, products_offered, confidence_score, data_completeness, matched_company_id, integration_status, extracted_at, last_updated) FROM stdin;
\.


--
-- Data for Name: scraped_contacts; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.scraped_contacts (id, scraped_content_id, full_name, first_name, last_name, email, phone, "position", department, linkedin_url, other_social, company_name, company_website, confidence_score, data_source, matched_contact_id, integration_status, extracted_at, company_id) FROM stdin;
\.


--
-- Data for Name: scraped_content; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.scraped_content (id, website_id, page_url, page_title, content_type, content_hash, raw_html, cleaned_text, structured_data, extraction_method, confidence_score, language, knowledge_document_id, rag_processed, rag_processing_status, rag_processing_error, scraped_at, processed_at, url, title, company_id) FROM stdin;
\.


--
-- Data for Name: scraped_documents_v2; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.scraped_documents_v2 (id, url, domain, title, content, content_hash, status, scraped_at, vectorized, vector_chunks_count, error_message, company_id) FROM stdin;
4	https://www.rebyu.ai/	www.rebyu.ai	Hotel Reputation Management Software Professionale | Rebyu AI	Hotel Reputation Management Software Professionale | Rebyu AI Non hai tempo di rispondere alle recensioni? Rivoluziona il modo in cui gestisci le recensioni degli ospiti. Provalo gratis Rebyu è il primo reputation management software italiano basato sull'AI. Genera risposte personalizzate, migliora la tua reputazione online e ti fa risparmiare tempo. Prenota ora una demo personalizzata Distinguiti davvero con risposte brillanti e su misura, capaci di potenziare la tua reputazione online in modo tangibile. Mostra ai tuoi ospiti la tua professionalità, la tua attenzione ai dettagli e la tua capacità di gestire ogni situazione con risposte coinvolgenti e curate. Ogni risposta è un capolavoro Il segreto di Rebyu è nel prompt, scritto da esperti di comunicazione, marketing e Hospitality con la supervisione di Maurizio D’Atri, massimo esperto italiano di recensioni alberghiere. Ogni risposta è studiata per creare connessioni autentiche e durature con gli ospiti. Risposte uniche , con il tuo stile Dì addio alle risposte impersonali. Con un rapido settaggio iniziale, Rebyu apprende il tono di voce e lo stile distintivo del tuo brand. In pochi secondi generi risposte personalizzate e coerenti con l’identità della tua struttura. Guarda Rebyu in azione. Basta 1 minuto . Liberati dal peso delle recensioni e lascia che Rebyu lavori per te . Provalo gratis Prenota ora una demo personalizzata Funzionalità e caratteristiche tecniche Tutto su un’unica piattaforma Rebyu raccoglie automaticamente le recensioni da Booking.com, Google, TripAdvisor e Expedia, semplificando la gestione multicanale della reputazione online. 100 lingue Con la traduzione in tempo reale delle recensioni e delle risposte, Rebyu ti permette di comunicare con ospiti di ogni nazionalità. Obiettivi mirati Vuoi rispondere a una recensione ingiusta o valorizzare la tua destinazione? Rebyu ti consente di selezionare il tono e l’intento della risposta, oppure utilizzare preset professionali configurati da esperti. Dashboard intuitivaMonitora recensioni, valutazioni e velocità di risposta in un unico luogo. Gestione multi-accountPerfetta per strutture singole o catene. 5 account per struttura e possibilità di gestire più hotel da un unico account master: Rebyu si adatta alle esigenze di ogni team di lavoro. Notifiche personalizzateScegli se ricevere notifiche per tutte le recensioni o solo in determinati casi, comodamente via mail o Whatsapp. Scopri di più Costruisci una reputazione online impeccabile senza sforzo. Con Rebyu puoi. Risparmiare tempo Difenderti dalle recensioni negative Migliorare la tua reputazione online Salire nel ranking di Google Aumentare il tuo punteggio medio su tutte le piattaforme Aumentare le prenotazioni Fidelizzare gli ospiti Ecco cosa succede quando inizi a rispondere alle recensioni recensioni positive* + 0 % stella di rating* + 0 /2 prenotazioni* + 0 % entrate** + 0 % * Dopo 6 mesi, studio Harward Business Review** Dopo un anno, studio Harvard Business School Prenota una demo personalizzata e scopri come rivoluzionare la tua reputazione online. Provalo gratis Prenota ora una demo personalizzata I nostri consigli per far brillare la tua immagine online 4 Luglio 2025Gestire una catena di alberghi: come mantenere una comunicazione coerente tra più strutture 2 Luglio 2025Google My Business: l’arma segreta per le prenotazioni dirette del tuo hotel 30 Giugno 2025Revenue management e gestione delle recensioni: strategie vincenti per gli albergatori ✕Caratteristiche Pricing Partnership Blog FAQ Contattaci Acquista Provalo gratis Compila il form per iscriverti e ricevere il link di partecipazione. × Benvenuto in Rebyu! Riceverai a breve una mail con le tue credenziali di accesso. × Ti chiamiamo noi! Compila il form e un nostro consulente ti contatterà per avviare la tua demo personalizzata. La tua privacy è per noi molto importante. Consulta la Privacy Policy per conoscere la nostra politica sull'elaborazione dei dati che spiega le finalità per le quali useremo le informazioni personali. ×	e6822900611a7a0ce8c7b2cc7d70b432	completed	2025-07-07 17:13:45.381877	t	1	\N	\N
\.


--
-- Data for Name: scraped_websites; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.scraped_websites (id, url, domain, title, description, scraping_frequency, max_depth, follow_external_links, respect_robots_txt, status, last_scraped, next_scrape_scheduled, company_name, partita_iva, sector, country, created_at, updated_at, created_by, robots_txt_content, success_count, error_count, last_error_message, company_id) FROM stdin;
33	https://httpbin.org/html	httpbin.org	No title	\N	weekly	1	f	t	completed	2025-07-14 08:55:50.61741	\N	\N	\N	\N	IT	2025-07-14 08:55:50.61741	2025-07-14 08:55:50.61741	\N	\N	0	0	\N	\N
30	https://www.rebyu.ai/	www.rebyu.ai	Hotel Reputation Management Software Professionale | Rebyu AI	\N	weekly	1	f	t	completed	2025-07-07 14:26:37.349682	\N	\N	\N	\N	IT	2025-07-07 14:26:37.349682	2025-07-07 14:26:37.349682	\N	\N	0	0	\N	\N
32	https://www.cisco.com	www.cisco.com	AI Infrastructure, Secure Networking, and Software Solutions - Cisco	\N	weekly	1	f	t	completed	2025-07-07 14:37:45.831119	\N	\N	\N	\N	IT	2025-07-07 14:37:45.831119	2025-07-07 14:37:45.831119	\N	\N	0	0	\N	\N
34	https://google.com	google.com	Google	\N	weekly	1	f	t	completed	2025-07-14 12:30:50.012904	\N	\N	\N	\N	IT	2025-07-14 12:30:50.012904	2025-07-14 12:30:50.012904	\N	\N	0	0	\N	\N
35	https://www.lamaisondesessences.it	www.lamaisondesessences.it	Profumi in Farmacia: profumi La Maison Des Essences	\N	weekly	1	f	t	completed	2025-07-14 13:18:13.980122	\N	\N	\N	\N	IT	2025-07-14 13:18:13.980122	2025-07-14 13:18:13.980122	\N	\N	0	0	\N	\N
38	https://www.google.com	www.google.com	Google	\N	weekly	1	f	t	completed	2025-07-14 13:30:47.203448	\N	\N	\N	\N	IT	2025-07-14 13:30:47.203448	2025-07-14 13:30:47.203448	\N	\N	0	0	\N	\N
41	https://www.github.com	www.github.com	GitHub · Build and ship software on a single, collaborative platform · GitHub	\N	weekly	1	f	t	completed	2025-07-14 13:37:42.304432	\N	\N	\N	\N	IT	2025-07-14 13:37:42.304432	2025-07-14 13:37:42.304432	\N	\N	0	0	\N	\N
44	https://www.1byte.it	www.1byte.it	1 Byte: specialisti dell'IT | 1 Byte	\N	weekly	1	f	t	completed	2025-07-14 13:41:17.118544	\N	\N	\N	\N	IT	2025-07-14 13:41:17.118544	2025-07-14 13:41:17.118544	\N	\N	0	0	\N	\N
46	https://www.12ozcj.com	www.12ozcj.com	Home - 12oz: Street coffee for people on the move	\N	weekly	1	f	t	completed	2025-07-14 13:46:46.910766	\N	\N	\N	\N	IT	2025-07-14 13:46:46.910766	2025-07-14 13:46:46.910766	\N	\N	0	0	\N	\N
\.


--
-- Data for Name: scraping_jobs; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.scraping_jobs (id, website_id, job_type, status, priority, started_at, completed_at, duration_seconds, pages_scraped, content_extracted, contacts_found, companies_found, rag_documents_created, error_message, retry_count, max_retries, scraping_config, created_at, created_by, results_summary) FROM stdin;
\.


--
-- Data for Name: servizi_commessa; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.servizi_commessa (id, commessa_id, articolo_id, kit_articolo_id, owner_servizio_id, stato, quantita, prezzo_unitario, sconto_percentuale, valore_totale, data_inizio, data_fine_prevista, data_fine_effettiva, note, metadata, created_at, ord_id) FROM stdin;
\.


--
-- Data for Name: sla_tracking; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.sla_tracking (id, entity_type, entity_id, sla_deadline, warning_sent_at, escalation_sent_at, completed_at, is_breached, breach_duration, created_at) FROM stdin;
\.


--
-- Data for Name: system_health; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.system_health (id, service_name, status, details, checked_at) FROM stdin;
\.


--
-- Data for Name: task_aggiuntivi; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.task_aggiuntivi (id, ticket_id, milestone_id, parent_task_id, nome, descrizione, assigned_to, created_by, stato, priorita, data_scadenza, ore_stimate, motivo_aggiunta, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.tasks (id, ticket_id, milestone_id, title, description, status, due_date, assigned_to, created_at, modello_task_id, sla_hours, sla_deadline, estimated_hours, actual_hours, checklist, task_metadata, parent_task_id, company_id, commessa_id, descrizione_operativa, workflow_milestone_id, task_template_id, is_aggiuntivo, priorita, sla_giorni, warning_giorni, escalation_giorni, warning_deadline, escalation_deadline) FROM stdin;
\.


--
-- Data for Name: tasks_global; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.tasks_global (id, tsk_code, tsk_description, tsk_type, tsk_category, created_at, sla_giorni, warning_giorni, escalation_giorni, priorita) FROM stdin;
6	Firma Incarico	riceviamo la firma dell'incarico da parte del cliente	template	generale	2025-07-18 14:47:17.831618	7	2	1	normale
5	Predisposizione Incarico	viene predisposto l'incarico per l'invio	template	delivery	2025-07-18 14:46:39.12601	2	1	1	normale
7	Invio Mail di Benvenuto	invio mail di benvento secondo il seguente modello:\n...	template	generale	2025-07-18 14:47:43.095888	2	1	1	normale
3	Invio Incarico	con yousign inviare incarico al cliente	template	generale	2025-07-18 13:40:20.669938	2	1	1	normale
\.


--
-- Data for Name: ticket_rows; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.ticket_rows (id, tck_id, tsk_id, wkf_row_id, tsk_status, tsk_assigned_to, tsk_start_date, tsk_due_date, tsk_completed_date, tsk_notes, tsk_order, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.tickets (id, company_id, title, description, status, priority, created_at, created_by, opportunity_id, modello_ticket_id, milestone_id, sla_deadline, metadata, commessa_id, assigned_to, activity_id, articolo_id, workflow_milestone_id) FROM stdin;
\.


--
-- Data for Name: tipi_commesse; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.tipi_commesse (id, nome, codice, descrizione, sla_default_hours, template_milestones, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: tipologie_servizi; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.tipologie_servizi (id, nome, descrizione, colore, icona, attivo, created_at) FROM stdin;
1	Finanziario	Servizi di consulenza finanziaria e fiscale	#10B981	💰	t	2025-07-17 15:53:26.269419
2	Digitale	Servizi di trasformazione digitale e tecnologia	#3B82F6	💻	t	2025-07-17 15:53:26.269419
3	Business	Consulenza strategica e sviluppo business	#8B5CF6	📊	t	2025-07-17 15:53:26.269419
4	Formazione	Corsi e training aziendali	#F59E0B	🎓	t	2025-07-17 15:53:26.269419
5	Marketing	Servizi di marketing e comunicazione	#EF4444	📢	t	2025-07-17 15:53:26.269419
6	Legale	Consulenza legale e compliance	#6B7280	⚖️	t	2025-07-17 15:53:26.269419
7	varie ed eventuali	varie	#3B82F6	🎨	t	2025-07-17 17:10:40.057427
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.users (id, username, email, password_hash, role, created_at, name, surname, first_name, last_name, permissions, is_active, last_login, must_change_password, crm_id, google_id, google_credentials, auto_sync_enabled, last_sync_at) FROM stdin;
2e82079c-fbca-46a9-87af-adf309661b93	l.vitaletti@enduser-italia.com	l.vitaletti@enduser-italia.com	$2a$06$gzjklaYRRO1UnXsUP/O1D.eWJE/G8inrWa/ecstwCcNLqdezCJ1q6	admin	2025-07-07 18:30:29.265834	Luigi	Vitaletti	Luigi	Vitaletti	{}	t	\N	t	120278	\N	\N	f	\N
0074f4da-e4c5-4500-9548-21db041d3551	g.fulgheri@enduser-italia.com	g.fulgheri@enduser-italia.com	$2a$06$WgDZxOPHT7T5HRpeZSqXauyVtqhOUW9nRW35yIMJzKBJQz7P7HhLK	account_manager	2025-07-07 18:30:29.265834	Giovanni	Fulgheri	Giovanni	Fulgheri	{}	t	\N	t	120456	\N	\N	f	\N
0fd89ea8-5e1d-4dc5-92ac-8ed2a97e13c4	ms.gentile@enduser-italia.com	ms.gentile@enduser-italia.com	$2b$12$u4i70p5iqZJBjH26RvTiHemyTERmUKzG8HyiHR.KCSr2ohqf8R8eG	area_manager	2025-07-07 18:30:29.265834	Maria Silvia	Gentile	Maria Silvia	Gentile	{}	t	\N	f	120325	\N	\N	f	\N
8068e0e3-6f92-42d9-9c1b-eef6ba4dd0a0	f.aliboni@enduser-italia.com	f.aliboni@enduser-italia.com	$2a$06$X6r7GXbejnemLVDAUVCqr.Wcb./8nAytjlFLmyfHOh/EsB.3jO.p.	area_manager	2025-07-07 18:30:29.265834	Fabio	Aliboni	Fabio	Aliboni	{}	t	\N	t	120396	\N	\N	f	\N
52f651f0-386b-4c0b-8548-2605fbe863f9	f.zarfati@enduser-italia.com	f.zarfati@enduser-italia.com	$2a$06$gaLIF8M87qtBAaAH50muMOaNflycnKFgqNd9cnWXqcwEzdrUXFQQa	operator	2025-07-07 18:30:29.265834	Francesca	Zarfati	Francesca	Zarfati	{}	t	\N	t	120436	\N	\N	f	\N
62a66ee6-5a40-4cf3-9ba3-3488ed128621	c.persico@enduser-italia.com	c.persico@enduser-italia.com	$2b$12$PAwd7w2a2fO1kZn.RFbbceocemW0Es9snpwAV2og1beFJI3i192I2	admin	2025-07-04 17:48:39.96651	\N	\N	Candida	Persico	{}	t	\N	f	\N	\N	\N	f	\N
2ffdbe6d-0d90-4e7f-bf8d-d45d50ee625f	b.romano@enduser-italia.com	b.romano@enduser-italia.com	$2b$12$xlkY2nnpNSoUzrXB/yWuVeefKn2foes1Dxo53NXTW2fSafp0YjK6q	operator	2025-07-07 18:30:29.265834	Barbara Mercedes	Romano	Barbara Mercedes	Romano	{}	t	\N	t	120385	\N	\N	f	\N
684a0437-4127-47b6-b364-eadd4519613a	admin@intelligence.ai	admin@intelligence.ai	$2b$12$hashed_password	admin	2025-07-07 18:30:29.265834	Admin	System	Admin	System	{}	t	\N	t	\N	\N	\N	f	\N
96538adf-a127-4cc3-b0a6-13460b39d290	s.andrello@enduser-italia.com	s.andrello@enduser-italia.com	$2b$12$7bSMzOaqQjFESiC40nPNeeqIN53uZWJ3aQy6fVaI.QoaPFQc0cQ2W	admin	2025-07-04 12:28:45.354647	Stefano	Andrello	Stefano	Andrello	{"admin": true, "view_all": true, "manage_users": true}	t	2025-07-19 10:12:28.410926	f	\N	116978385808104719445	{"token": "ya29.a0AS3H6Nwm2AvURM-3msX0LROthNl6sAHudyyfiR4SUd5XtDdXFjznsy8ixzDzQM4NLa4Io-PXMYMIeXM-b1UZDXymZQwVwBXQ9nUnK27ED-vDPpnYrM-pK2rHB2667etuzuvNfIVxS-TecZxNEQkZTatshvBekuyRUyC-LNYuaCgYKAekSARQSFQHGX2MiorEDFZ_AHSQQUAstjC_Vbg0175", "refresh_token": "1//03yXcIuhgsR16CgYIARAAGAMSNwF-L9IrtIuu6HkqVsAzp3qphyXBTCCj4xyMK_PuWaoP3hYHkmh6chW4ZGNDqP0r-iUusJuBghY", "token_uri": "https://oauth2.googleapis.com/token", "client_id": "678912816966-kd32h942iqf9dlhsvha54o5fjb6kicj5.apps.googleusercontent.com", "client_secret": "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", "scopes": ["openid", "email", "profile", "https://www.googleapis.com/auth/spreadsheets.readonly"], "expiry": null}	t	2025-07-19 10:12:28.410932
f8e43528-6009-440f-8303-03decd74d640	s.cristofanelli@enduser-italia.com	s.cristofanelli@enduser-italia.com	$2a$06$05ytsa8itvxlHNjE8Ucr8OEwXZgVm9P1/sOyksD5u5I4PTX5rXaxy	operator	2025-07-07 18:30:29.265834	Sabrina	Cristofanelli	Sabrina	Cristofanelli	{}	t	\N	t	121788	\N	\N	f	\N
87613854-451e-4443-93d2-1df74efe9a62	p.menin@enduser-italia.com	p.menin@enduser-italia.com	$2a$06$QMzHIGNRV.2COHb./AJYJ.pqTFdQCmClgrWzba85AkoU9Qrf.v.Fi	account_manager	2025-07-07 18:30:29.265834	Pier Luigi	Menin	Pier Luigi	Menin	{}	t	\N	t	120723	\N	\N	f	\N
1e897c91-9045-4ada-92a0-46f48d44683c	ai@enduser-digital.com	ai@enduser-digital.com	$2a$06$3z4LEh36lG3wVUwINymBU.G6W1iwYUXd3H2gVuOyCQO/NZDAFH7JS	admin	2025-07-07 18:30:29.265834	AI		AI		{}	t	\N	t	123166	\N	\N	f	\N
a240bc71-b712-4769-afc4-c02a27ea0ae6	f.devita@enduser-italia.com	f.devita@enduser-italia.com	$2a$06$8IrcuaqWqJimOpNsCWWT8epsVNTMRRYdYeyreto9A5D7MTURZgSZG	account_manager	2025-07-07 18:30:29.265834	Francesca	De Vita	Francesca	De Vita	{}	t	\N	t	120965	\N	\N	f	\N
9a3e6412-4494-43bc-b9a9-ca498ef0c6d8	f.corbinelli@enduser-italia.com	f.corbinelli@enduser-italia.com	$2a$06$clZyiKnCF9CcPSqGUGWJCeDdUIrb98di.PI1EQDxn9pExSXSjkmZa	account_manager	2025-07-07 18:30:29.265834	Fabrizio	Corbinelli	Fabrizio	Corbinelli	{}	t	\N	t	122209	\N	\N	f	\N
2d568f82-5c64-427e-981d-a4ce630d41d6	l.loi@enduser-italia.com	l.loi@enduser-italia.com	$2b$12$zs.0JKN6Kw/07f.UQ1D4IurRaDqW3M5E/xP.HNH6a5cjZmMnJeCH6	operator	2025-07-18 07:12:04.389352	Luana	Loi	Luana	Loi	{}	t	\N	f	\N	\N	\N	f	\N
3fe2798a-5b7a-4b21-8283-516e6644fb74	l.sala@enduser-italia.com	l.sala@enduser-italia.com	$2b$12$ui3yTuXoYh3AEX/1AGa0AOeaBdvZUFIDbuDUU8WkLTCHCOQbcsRai	admin	2025-07-07 18:30:29.265834	Luca	Sala	Luca	Sala	{}	t	2025-07-18 07:15:33.339851	f	121791	\N	\N	f	\N
\.


--
-- Data for Name: wkf_rows; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.wkf_rows (id, wkf_id, tsk_id, mls_id, tsk_position, tsk_sla_hours, tsk_order, tsk_mandatory, created_at) FROM stdin;
\.


--
-- Data for Name: workflow_milestones; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.workflow_milestones (id, workflow_template_id, nome, descrizione, ordine, durata_stimata_giorni, sla_giorni, warning_giorni, escalation_giorni, tipo_milestone, auto_generate_tickets, created_at) FROM stdin;
\.


--
-- Data for Name: workflow_templates; Type: TABLE DATA; Schema: public; Owner: intelligence_user
--

COPY public.workflow_templates (id, articolo_id, nome, descrizione, durata_stimata_giorni, ordine, attivo, created_at, wkf_code, wkf_description) FROM stdin;
1	2	Workflow Incarico 24 Mesi	Workflow automaticamente generato per Incarico 24 Mesi	30	0	t	2025-07-23 07:41:36.095873	WKF_I24	Workflow per gestione Incarico 24 Mesi
\.


--
-- Name: activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.activities_id_seq', 1, false);


--
-- Name: articoli_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.articoli_id_seq', 17, true);


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 1, false);


--
-- Name: document_chunks_v2_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.document_chunks_v2_id_seq', 6, true);


--
-- Name: kit_articoli_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.kit_articoli_id_seq', 10, true);


--
-- Name: kit_commerciali_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.kit_commerciali_id_seq', 9, true);


--
-- Name: milestone_task_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.milestone_task_templates_id_seq', 1, false);


--
-- Name: order_number_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.order_number_seq', 1000, false);


--
-- Name: order_rows_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.order_rows_id_seq', 1, false);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.orders_id_seq', 1, false);


--
-- Name: partner_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.partner_id_seq', 1, true);


--
-- Name: partner_servizi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.partner_servizi_id_seq', 1, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.roles_id_seq', 4, true);


--
-- Name: sales_opportunities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.sales_opportunities_id_seq', 1, false);


--
-- Name: scraped_companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.scraped_companies_id_seq', 1, false);


--
-- Name: scraped_contacts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.scraped_contacts_id_seq', 1, false);


--
-- Name: scraped_content_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.scraped_content_id_seq', 1, false);


--
-- Name: scraped_documents_v2_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.scraped_documents_v2_id_seq', 4, true);


--
-- Name: scraped_websites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.scraped_websites_id_seq', 46, true);


--
-- Name: scraping_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.scraping_jobs_id_seq', 1, false);


--
-- Name: servizi_commessa_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.servizi_commessa_id_seq', 1, false);


--
-- Name: sla_tracking_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.sla_tracking_id_seq', 1, false);


--
-- Name: task_aggiuntivi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.task_aggiuntivi_id_seq', 1, false);


--
-- Name: tasks_global_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.tasks_global_id_seq', 13, true);


--
-- Name: ticket_rows_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.ticket_rows_id_seq', 1, false);


--
-- Name: tipologie_servizi_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.tipologie_servizi_id_seq', 7, true);


--
-- Name: wkf_rows_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.wkf_rows_id_seq', 1, false);


--
-- Name: workflow_milestones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.workflow_milestones_id_seq', 1, false);


--
-- Name: workflow_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: intelligence_user
--

SELECT pg_catalog.setval('public.workflow_templates_id_seq', 1, true);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


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
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


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
-- Name: commesse commesse_codice_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.commesse
    ADD CONSTRAINT commesse_codice_key UNIQUE (codice);


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
-- Name: document_chunks_v2 document_chunks_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.document_chunks_v2
    ADD CONSTRAINT document_chunks_v2_pkey PRIMARY KEY (id);


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
-- Name: knowledge_documents knowledge_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.knowledge_documents
    ADD CONSTRAINT knowledge_documents_pkey PRIMARY KEY (id);


--
-- Name: milestone_task_templates milestone_task_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.milestone_task_templates
    ADD CONSTRAINT milestone_task_templates_pkey PRIMARY KEY (id);


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
-- Name: opportunities opportunities_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT opportunities_pkey PRIMARY KEY (id);


--
-- Name: order_rows order_rows_ord_id_art_id_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.order_rows
    ADD CONSTRAINT order_rows_ord_id_art_id_key UNIQUE (ord_id, art_id);


--
-- Name: order_rows order_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.order_rows
    ADD CONSTRAINT order_rows_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: partner partner_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.partner
    ADD CONSTRAINT partner_pkey PRIMARY KEY (id);


--
-- Name: partner_servizi partner_servizi_partner_id_articolo_id_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.partner_servizi
    ADD CONSTRAINT partner_servizi_partner_id_articolo_id_key UNIQUE (partner_id, articolo_id);


--
-- Name: partner_servizi partner_servizi_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.partner_servizi
    ADD CONSTRAINT partner_servizi_pkey PRIMARY KEY (id);


--
-- Name: processing_queue processing_queue_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.processing_queue
    ADD CONSTRAINT processing_queue_pkey PRIMARY KEY (id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sales_opportunities sales_opportunities_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.sales_opportunities
    ADD CONSTRAINT sales_opportunities_pkey PRIMARY KEY (id);


--
-- Name: scraped_companies scraped_companies_company_name_website_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_companies
    ADD CONSTRAINT scraped_companies_company_name_website_key UNIQUE (company_name, website);


--
-- Name: scraped_companies scraped_companies_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_companies
    ADD CONSTRAINT scraped_companies_pkey PRIMARY KEY (id);


--
-- Name: scraped_contacts scraped_contacts_email_company_name_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_contacts
    ADD CONSTRAINT scraped_contacts_email_company_name_key UNIQUE (email, company_name);


--
-- Name: scraped_contacts scraped_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_contacts
    ADD CONSTRAINT scraped_contacts_pkey PRIMARY KEY (id);


--
-- Name: scraped_content scraped_content_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_content
    ADD CONSTRAINT scraped_content_pkey PRIMARY KEY (id);


--
-- Name: scraped_content scraped_content_website_id_page_url_content_hash_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_content
    ADD CONSTRAINT scraped_content_website_id_page_url_content_hash_key UNIQUE (website_id, page_url, content_hash);


--
-- Name: scraped_documents_v2 scraped_documents_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_documents_v2
    ADD CONSTRAINT scraped_documents_v2_pkey PRIMARY KEY (id);


--
-- Name: scraped_websites scraped_websites_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_websites
    ADD CONSTRAINT scraped_websites_pkey PRIMARY KEY (id);


--
-- Name: scraped_websites scraped_websites_url_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_websites
    ADD CONSTRAINT scraped_websites_url_key UNIQUE (url);


--
-- Name: scraping_jobs scraping_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraping_jobs
    ADD CONSTRAINT scraping_jobs_pkey PRIMARY KEY (id);


--
-- Name: servizi_commessa servizi_commessa_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.servizi_commessa
    ADD CONSTRAINT servizi_commessa_pkey PRIMARY KEY (id);


--
-- Name: sla_tracking sla_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.sla_tracking
    ADD CONSTRAINT sla_tracking_pkey PRIMARY KEY (id);


--
-- Name: system_health system_health_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.system_health
    ADD CONSTRAINT system_health_pkey PRIMARY KEY (id);


--
-- Name: task_aggiuntivi task_aggiuntivi_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.task_aggiuntivi
    ADD CONSTRAINT task_aggiuntivi_pkey PRIMARY KEY (id);


--
-- Name: tasks_global tasks_global_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tasks_global
    ADD CONSTRAINT tasks_global_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: ticket_rows ticket_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.ticket_rows
    ADD CONSTRAINT ticket_rows_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: tipi_commesse tipi_commesse_codice_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tipi_commesse
    ADD CONSTRAINT tipi_commesse_codice_key UNIQUE (codice);


--
-- Name: tipi_commesse tipi_commesse_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tipi_commesse
    ADD CONSTRAINT tipi_commesse_pkey PRIMARY KEY (id);


--
-- Name: tipologie_servizi tipologie_servizi_nome_key; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tipologie_servizi
    ADD CONSTRAINT tipologie_servizi_nome_key UNIQUE (nome);


--
-- Name: tipologie_servizi tipologie_servizi_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tipologie_servizi
    ADD CONSTRAINT tipologie_servizi_pkey PRIMARY KEY (id);


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
-- Name: wkf_rows wkf_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.wkf_rows
    ADD CONSTRAINT wkf_rows_pkey PRIMARY KEY (id);


--
-- Name: workflow_milestones workflow_milestones_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.workflow_milestones
    ADD CONSTRAINT workflow_milestones_pkey PRIMARY KEY (id);


--
-- Name: workflow_templates workflow_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.workflow_templates
    ADD CONSTRAINT workflow_templates_pkey PRIMARY KEY (id);


--
-- Name: idx_ai_conversations_company; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_ai_conversations_company ON public.ai_conversations USING btree (company_id);


--
-- Name: idx_ai_conversations_conversation; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_ai_conversations_conversation ON public.ai_conversations USING btree (conversation_id);


--
-- Name: idx_ai_conversations_user; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_ai_conversations_user ON public.ai_conversations USING btree (user_id);


--
-- Name: idx_articoli_responsabile; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_articoli_responsabile ON public.articoli USING btree (responsabile_user_id);


--
-- Name: idx_bi_cache_expires; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_bi_cache_expires ON public.bi_cache USING btree (expires_at);


--
-- Name: idx_bi_cache_key; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_bi_cache_key ON public.bi_cache USING btree (cache_key);


--
-- Name: idx_commesse_client; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_commesse_client ON public.commesse USING btree (client_id);


--
-- Name: idx_commesse_codice; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_commesse_codice ON public.commesse USING btree (codice);


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
-- Name: idx_document_chunks_document; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_document_chunks_document ON public.document_chunks USING btree (document_id);


--
-- Name: idx_document_chunks_vector; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_document_chunks_vector ON public.document_chunks USING btree (vector_id);


--
-- Name: idx_kit_articoli_articolo; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_kit_articoli_articolo ON public.kit_articoli USING btree (articolo_id);


--
-- Name: idx_kit_articoli_kit; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_kit_articoli_kit ON public.kit_articoli USING btree (kit_commerciale_id);


--
-- Name: idx_knowledge_documents_company; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_knowledge_documents_company ON public.knowledge_documents USING btree (company_id);


--
-- Name: idx_knowledge_documents_hash; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_knowledge_documents_hash ON public.knowledge_documents USING btree (content_hash);


--
-- Name: idx_knowledge_documents_processed; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_knowledge_documents_processed ON public.knowledge_documents USING btree (processed_at);


--
-- Name: idx_milestone_task_templates_milestone; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_milestone_task_templates_milestone ON public.milestone_task_templates USING btree (milestone_id);


--
-- Name: idx_milestones_commessa; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_milestones_commessa ON public.milestones USING btree (commessa_id);


--
-- Name: idx_milestones_tipo_commessa; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_milestones_tipo_commessa ON public.milestones USING btree (tipo_commessa_id);


--
-- Name: idx_order_rows_article; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_order_rows_article ON public.order_rows USING btree (art_id);


--
-- Name: idx_order_rows_order; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_order_rows_order ON public.order_rows USING btree (ord_id);


--
-- Name: idx_order_rows_status; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_order_rows_status ON public.order_rows USING btree (row_status);


--
-- Name: idx_order_rows_task; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_order_rows_task ON public.order_rows USING btree (task_id);


--
-- Name: idx_order_rows_ticket; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_order_rows_ticket ON public.order_rows USING btree (ticket_id);


--
-- Name: idx_orders_assigned; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_orders_assigned ON public.orders USING btree (assigned_to);


--
-- Name: idx_orders_customer; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_orders_customer ON public.orders USING btree (cst_id);


--
-- Name: idx_orders_date; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_orders_date ON public.orders USING btree (ord_date);


--
-- Name: idx_orders_status; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_orders_status ON public.orders USING btree (status);


--
-- Name: idx_processing_queue_status; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_processing_queue_status ON public.processing_queue USING btree (status);


--
-- Name: idx_processing_queue_type; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_processing_queue_type ON public.processing_queue USING btree (job_type);


--
-- Name: idx_sales_opportunities_data_chiusura; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_sales_opportunities_data_chiusura ON public.sales_opportunities USING btree (data_chiusura);


--
-- Name: idx_sales_opportunities_nuovo_cliente; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_sales_opportunities_nuovo_cliente ON public.sales_opportunities USING btree (nuovo_cliente);


--
-- Name: idx_sales_opportunities_tipo; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_sales_opportunities_tipo ON public.sales_opportunities USING btree (tipo_opportunita);


--
-- Name: idx_scraped_companies_name; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_companies_name ON public.scraped_companies USING btree (company_name);


--
-- Name: idx_scraped_companies_partita_iva; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_companies_partita_iva ON public.scraped_companies USING btree (partita_iva);


--
-- Name: idx_scraped_companies_sector; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_companies_sector ON public.scraped_companies USING btree (sector);


--
-- Name: idx_scraped_contacts_company; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_contacts_company ON public.scraped_contacts USING btree (company_name);


--
-- Name: idx_scraped_contacts_email; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_contacts_email ON public.scraped_contacts USING btree (email);


--
-- Name: idx_scraped_contacts_integration; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_contacts_integration ON public.scraped_contacts USING btree (integration_status);


--
-- Name: idx_scraped_content_hash; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_content_hash ON public.scraped_content USING btree (content_hash);


--
-- Name: idx_scraped_content_knowledge_doc; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_content_knowledge_doc ON public.scraped_content USING btree (knowledge_document_id);


--
-- Name: idx_scraped_content_rag_status; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_content_rag_status ON public.scraped_content USING btree (rag_processed);


--
-- Name: idx_scraped_content_type; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_content_type ON public.scraped_content USING btree (content_type);


--
-- Name: idx_scraped_content_website; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_content_website ON public.scraped_content USING btree (website_id);


--
-- Name: idx_scraped_websites_domain; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_websites_domain ON public.scraped_websites USING btree (domain);


--
-- Name: idx_scraped_websites_next_scrape; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_websites_next_scrape ON public.scraped_websites USING btree (next_scrape_scheduled);


--
-- Name: idx_scraped_websites_partita_iva; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_websites_partita_iva ON public.scraped_websites USING btree (partita_iva);


--
-- Name: idx_scraped_websites_status; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraped_websites_status ON public.scraped_websites USING btree (status);


--
-- Name: idx_scraping_jobs_started; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraping_jobs_started ON public.scraping_jobs USING btree (started_at);


--
-- Name: idx_scraping_jobs_status; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_scraping_jobs_status ON public.scraping_jobs USING btree (status);


--
-- Name: idx_servizi_commessa_articolo; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_servizi_commessa_articolo ON public.servizi_commessa USING btree (articolo_id);


--
-- Name: idx_servizi_commessa_commessa; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_servizi_commessa_commessa ON public.servizi_commessa USING btree (commessa_id);


--
-- Name: idx_servizi_commessa_owner; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_servizi_commessa_owner ON public.servizi_commessa USING btree (owner_servizio_id);


--
-- Name: idx_sla_tracking_deadline; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_sla_tracking_deadline ON public.sla_tracking USING btree (sla_deadline);


--
-- Name: idx_system_health_checked; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_system_health_checked ON public.system_health USING btree (checked_at);


--
-- Name: idx_system_health_service; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_system_health_service ON public.system_health USING btree (service_name);


--
-- Name: idx_task_aggiuntivi_parent; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_task_aggiuntivi_parent ON public.task_aggiuntivi USING btree (parent_task_id);


--
-- Name: idx_task_aggiuntivi_ticket; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_task_aggiuntivi_ticket ON public.task_aggiuntivi USING btree (ticket_id);


--
-- Name: idx_tasks_commessa; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_tasks_commessa ON public.tasks USING btree (commessa_id);


--
-- Name: idx_tasks_global_code; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_tasks_global_code ON public.tasks_global USING btree (tsk_code);


--
-- Name: idx_tasks_modello; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_tasks_modello ON public.tasks USING btree (modello_task_id);


--
-- Name: idx_tasks_parent; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_tasks_parent ON public.tasks USING btree (parent_task_id);


--
-- Name: idx_tasks_sla; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_tasks_sla ON public.tasks USING btree (sla_deadline);


--
-- Name: idx_ticket_rows_status; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_ticket_rows_status ON public.ticket_rows USING btree (tsk_status);


--
-- Name: idx_ticket_rows_tck; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_ticket_rows_tck ON public.ticket_rows USING btree (tck_id);


--
-- Name: idx_ticket_rows_tsk; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_ticket_rows_tsk ON public.ticket_rows USING btree (tsk_id);


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
-- Name: idx_users_auto_sync; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_users_auto_sync ON public.users USING btree (auto_sync_enabled);


--
-- Name: idx_users_google_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_users_google_id ON public.users USING btree (google_id);


--
-- Name: idx_wkf_rows_mls; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_wkf_rows_mls ON public.wkf_rows USING btree (mls_id);


--
-- Name: idx_wkf_rows_tsk; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_wkf_rows_tsk ON public.wkf_rows USING btree (tsk_id);


--
-- Name: idx_wkf_rows_wkf; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_wkf_rows_wkf ON public.wkf_rows USING btree (wkf_id);


--
-- Name: idx_workflow_milestones_template; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_workflow_milestones_template ON public.workflow_milestones USING btree (workflow_template_id);


--
-- Name: ix_activities_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX ix_activities_id ON public.activities USING btree (id);


--
-- Name: ix_business_cards_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX ix_business_cards_id ON public.business_cards USING btree (id);


--
-- Name: ix_document_chunks_v2_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX ix_document_chunks_v2_id ON public.document_chunks_v2 USING btree (id);


--
-- Name: ix_opportunities_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX ix_opportunities_id ON public.opportunities USING btree (id);


--
-- Name: ix_scraped_documents_v2_id; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX ix_scraped_documents_v2_id ON public.scraped_documents_v2 USING btree (id);


--
-- Name: ix_scraped_documents_v2_url; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE UNIQUE INDEX ix_scraped_documents_v2_url ON public.scraped_documents_v2 USING btree (url);


--
-- Name: tasks trigger_calculate_task_sla_deadlines; Type: TRIGGER; Schema: public; Owner: intelligence_user
--

CREATE TRIGGER trigger_calculate_task_sla_deadlines BEFORE INSERT OR UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.calculate_task_sla_deadlines();


--
-- Name: order_rows trigger_order_rows_updated_at; Type: TRIGGER; Schema: public; Owner: intelligence_user
--

CREATE TRIGGER trigger_order_rows_updated_at BEFORE UPDATE ON public.order_rows FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: orders trigger_orders_updated_at; Type: TRIGGER; Schema: public; Owner: intelligence_user
--

CREATE TRIGGER trigger_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();


--
-- Name: order_rows trigger_update_order_status; Type: TRIGGER; Schema: public; Owner: intelligence_user
--

CREATE TRIGGER trigger_update_order_status AFTER INSERT OR DELETE OR UPDATE ON public.order_rows FOR EACH ROW EXECUTE FUNCTION public.update_order_status();


--
-- Name: knowledge_documents update_knowledge_documents_updated_at; Type: TRIGGER; Schema: public; Owner: intelligence_user
--

CREATE TRIGGER update_knowledge_documents_updated_at BEFORE UPDATE ON public.knowledge_documents FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: scraped_companies update_scraped_companies_updated_at; Type: TRIGGER; Schema: public; Owner: intelligence_user
--

CREATE TRIGGER update_scraped_companies_updated_at BEFORE UPDATE ON public.scraped_companies FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: scraped_websites update_scraped_websites_updated_at; Type: TRIGGER; Schema: public; Owner: intelligence_user
--

CREATE TRIGGER update_scraped_websites_updated_at BEFORE UPDATE ON public.scraped_websites FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: activities activities_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: ai_conversations ai_conversations_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.ai_conversations
    ADD CONSTRAINT ai_conversations_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: articoli articoli_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli
    ADD CONSTRAINT articoli_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partner(id);


--
-- Name: articoli articoli_tipo_commessa_legacy_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli
    ADD CONSTRAINT articoli_tipo_commessa_legacy_id_fkey FOREIGN KEY (tipo_commessa_legacy_id) REFERENCES public.tipi_commesse(id);


--
-- Name: articoli articoli_tipologia_servizio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli
    ADD CONSTRAINT articoli_tipologia_servizio_id_fkey FOREIGN KEY (tipologia_servizio_id) REFERENCES public.tipologie_servizi(id);


--
-- Name: audit_log audit_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


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
    ADD CONSTRAINT commesse_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


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
-- Name: contacts contacts_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id) ON DELETE CASCADE;


--
-- Name: document_chunks document_chunks_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.document_chunks
    ADD CONSTRAINT document_chunks_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.knowledge_documents(id) ON DELETE CASCADE;


--
-- Name: document_chunks_v2 document_chunks_v2_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.document_chunks_v2
    ADD CONSTRAINT document_chunks_v2_document_id_fkey FOREIGN KEY (document_id) REFERENCES public.scraped_documents_v2(id);


--
-- Name: articoli fk_articoli_responsabile; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli
    ADD CONSTRAINT fk_articoli_responsabile FOREIGN KEY (responsabile_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: kit_articoli kit_articoli_articolo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.kit_articoli
    ADD CONSTRAINT kit_articoli_articolo_id_fkey FOREIGN KEY (articolo_id) REFERENCES public.articoli(id);


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
-- Name: knowledge_documents knowledge_documents_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.knowledge_documents
    ADD CONSTRAINT knowledge_documents_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: milestone_task_templates milestone_task_templates_milestone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.milestone_task_templates
    ADD CONSTRAINT milestone_task_templates_milestone_id_fkey FOREIGN KEY (milestone_id) REFERENCES public.workflow_milestones(id) ON DELETE CASCADE;


--
-- Name: milestones milestones_articolo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.milestones
    ADD CONSTRAINT milestones_articolo_id_fkey FOREIGN KEY (articolo_id) REFERENCES public.articoli(id);


--
-- Name: milestones milestones_commessa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.milestones
    ADD CONSTRAINT milestones_commessa_id_fkey FOREIGN KEY (commessa_id) REFERENCES public.commesse(id);


--
-- Name: milestones milestones_opportunity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.milestones
    ADD CONSTRAINT milestones_opportunity_id_fkey FOREIGN KEY (opportunity_id) REFERENCES public.opportunities(id) ON DELETE CASCADE;


--
-- Name: milestones milestones_tipo_commessa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.milestones
    ADD CONSTRAINT milestones_tipo_commessa_fkey FOREIGN KEY (tipo_commessa_id) REFERENCES public.tipi_commesse(id) ON DELETE CASCADE;


--
-- Name: milestones milestones_workflow_milestone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.milestones
    ADD CONSTRAINT milestones_workflow_milestone_id_fkey FOREIGN KEY (workflow_milestone_id) REFERENCES public.workflow_milestones(id);


--
-- Name: modelli_task modelli_task_milestone_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.modelli_task
    ADD CONSTRAINT modelli_task_milestone_fkey FOREIGN KEY (milestone_id) REFERENCES public.milestones(id) ON DELETE CASCADE;


--
-- Name: modelli_task modelli_task_tipo_commessa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.modelli_task
    ADD CONSTRAINT modelli_task_tipo_commessa_fkey FOREIGN KEY (tipo_commessa_id) REFERENCES public.tipi_commesse(id) ON DELETE CASCADE;


--
-- Name: opportunities opportunities_commessa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT opportunities_commessa_id_fkey FOREIGN KEY (commessa_id) REFERENCES public.commesse(id);


--
-- Name: opportunities opportunities_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT opportunities_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: order_rows order_rows_art_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.order_rows
    ADD CONSTRAINT order_rows_art_id_fkey FOREIGN KEY (art_id) REFERENCES public.articoli(id);


--
-- Name: order_rows order_rows_ord_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.order_rows
    ADD CONSTRAINT order_rows_ord_id_fkey FOREIGN KEY (ord_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_rows order_rows_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.order_rows
    ADD CONSTRAINT order_rows_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id);


--
-- Name: order_rows order_rows_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.order_rows
    ADD CONSTRAINT order_rows_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: orders orders_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: orders orders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: orders orders_cst_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_cst_id_fkey FOREIGN KEY (cst_id) REFERENCES public.companies(id);


--
-- Name: partner_servizi partner_servizi_articolo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.partner_servizi
    ADD CONSTRAINT partner_servizi_articolo_id_fkey FOREIGN KEY (articolo_id) REFERENCES public.articoli(id) ON DELETE CASCADE;


--
-- Name: partner_servizi partner_servizi_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.partner_servizi
    ADD CONSTRAINT partner_servizi_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.partner(id) ON DELETE CASCADE;


--
-- Name: sales_opportunities sales_opportunities_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.sales_opportunities
    ADD CONSTRAINT sales_opportunities_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: sales_opportunities sales_opportunities_sales_manager_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.sales_opportunities
    ADD CONSTRAINT sales_opportunities_sales_manager_id_fkey FOREIGN KEY (sales_manager_id) REFERENCES public.users(id);


--
-- Name: scraped_companies scraped_companies_scraped_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_companies
    ADD CONSTRAINT scraped_companies_scraped_content_id_fkey FOREIGN KEY (scraped_content_id) REFERENCES public.scraped_content(id) ON DELETE CASCADE;


--
-- Name: scraped_contacts scraped_contacts_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_contacts
    ADD CONSTRAINT scraped_contacts_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: scraped_contacts scraped_contacts_scraped_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_contacts
    ADD CONSTRAINT scraped_contacts_scraped_content_id_fkey FOREIGN KEY (scraped_content_id) REFERENCES public.scraped_content(id) ON DELETE CASCADE;


--
-- Name: scraped_content scraped_content_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_content
    ADD CONSTRAINT scraped_content_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: scraped_content scraped_content_knowledge_document_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_content
    ADD CONSTRAINT scraped_content_knowledge_document_id_fkey FOREIGN KEY (knowledge_document_id) REFERENCES public.knowledge_documents(id);


--
-- Name: scraped_content scraped_content_website_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_content
    ADD CONSTRAINT scraped_content_website_id_fkey FOREIGN KEY (website_id) REFERENCES public.scraped_websites(id) ON DELETE CASCADE;


--
-- Name: scraped_documents_v2 scraped_documents_v2_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_documents_v2
    ADD CONSTRAINT scraped_documents_v2_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: scraped_websites scraped_websites_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraped_websites
    ADD CONSTRAINT scraped_websites_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: scraping_jobs scraping_jobs_website_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.scraping_jobs
    ADD CONSTRAINT scraping_jobs_website_id_fkey FOREIGN KEY (website_id) REFERENCES public.scraped_websites(id) ON DELETE CASCADE;


--
-- Name: servizi_commessa servizi_commessa_articolo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.servizi_commessa
    ADD CONSTRAINT servizi_commessa_articolo_id_fkey FOREIGN KEY (articolo_id) REFERENCES public.articoli(id);


--
-- Name: servizi_commessa servizi_commessa_commessa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.servizi_commessa
    ADD CONSTRAINT servizi_commessa_commessa_id_fkey FOREIGN KEY (commessa_id) REFERENCES public.commesse(id) ON DELETE CASCADE;


--
-- Name: servizi_commessa servizi_commessa_kit_articolo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.servizi_commessa
    ADD CONSTRAINT servizi_commessa_kit_articolo_id_fkey FOREIGN KEY (kit_articolo_id) REFERENCES public.kit_articoli(id);


--
-- Name: servizi_commessa servizi_commessa_owner_servizio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.servizi_commessa
    ADD CONSTRAINT servizi_commessa_owner_servizio_id_fkey FOREIGN KEY (owner_servizio_id) REFERENCES public.users(id);


--
-- Name: task_aggiuntivi task_aggiuntivi_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.task_aggiuntivi
    ADD CONSTRAINT task_aggiuntivi_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: task_aggiuntivi task_aggiuntivi_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.task_aggiuntivi
    ADD CONSTRAINT task_aggiuntivi_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: task_aggiuntivi task_aggiuntivi_milestone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.task_aggiuntivi
    ADD CONSTRAINT task_aggiuntivi_milestone_id_fkey FOREIGN KEY (milestone_id) REFERENCES public.milestones(id);


--
-- Name: task_aggiuntivi task_aggiuntivi_parent_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.task_aggiuntivi
    ADD CONSTRAINT task_aggiuntivi_parent_task_id_fkey FOREIGN KEY (parent_task_id) REFERENCES public.tasks(id);


--
-- Name: task_aggiuntivi task_aggiuntivi_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.task_aggiuntivi
    ADD CONSTRAINT task_aggiuntivi_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: tasks tasks_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: tasks tasks_commessa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_commessa_fkey FOREIGN KEY (commessa_id) REFERENCES public.commesse(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: tasks tasks_milestone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_milestone_id_fkey FOREIGN KEY (milestone_id) REFERENCES public.milestones(id);


--
-- Name: tasks tasks_modello_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_modello_task_id_fkey FOREIGN KEY (modello_task_id) REFERENCES public.modelli_task(id) ON DELETE SET NULL;


--
-- Name: tasks tasks_parent_task_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_parent_task_id_fkey FOREIGN KEY (parent_task_id) REFERENCES public.tasks(id);


--
-- Name: tasks tasks_task_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_task_template_id_fkey FOREIGN KEY (task_template_id) REFERENCES public.milestone_task_templates(id);


--
-- Name: tasks tasks_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id) ON DELETE CASCADE;


--
-- Name: tasks tasks_workflow_milestone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_workflow_milestone_id_fkey FOREIGN KEY (workflow_milestone_id) REFERENCES public.workflow_milestones(id);


--
-- Name: ticket_rows ticket_rows_tck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.ticket_rows
    ADD CONSTRAINT ticket_rows_tck_id_fkey FOREIGN KEY (tck_id) REFERENCES public.tickets(id);


--
-- Name: ticket_rows ticket_rows_tsk_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.ticket_rows
    ADD CONSTRAINT ticket_rows_tsk_assigned_to_fkey FOREIGN KEY (tsk_assigned_to) REFERENCES public.users(id);


--
-- Name: ticket_rows ticket_rows_tsk_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.ticket_rows
    ADD CONSTRAINT ticket_rows_tsk_id_fkey FOREIGN KEY (tsk_id) REFERENCES public.tasks_global(id);


--
-- Name: ticket_rows ticket_rows_wkf_row_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.ticket_rows
    ADD CONSTRAINT ticket_rows_wkf_row_id_fkey FOREIGN KEY (wkf_row_id) REFERENCES public.wkf_rows(id);


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
-- Name: wkf_rows wkf_rows_mls_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.wkf_rows
    ADD CONSTRAINT wkf_rows_mls_id_fkey FOREIGN KEY (mls_id) REFERENCES public.workflow_milestones(id);


--
-- Name: wkf_rows wkf_rows_tsk_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.wkf_rows
    ADD CONSTRAINT wkf_rows_tsk_id_fkey FOREIGN KEY (tsk_id) REFERENCES public.tasks_global(id);


--
-- Name: wkf_rows wkf_rows_wkf_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.wkf_rows
    ADD CONSTRAINT wkf_rows_wkf_id_fkey FOREIGN KEY (wkf_id) REFERENCES public.workflow_templates(id);


--
-- Name: workflow_milestones workflow_milestones_workflow_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.workflow_milestones
    ADD CONSTRAINT workflow_milestones_workflow_template_id_fkey FOREIGN KEY (workflow_template_id) REFERENCES public.workflow_templates(id) ON DELETE CASCADE;


--
-- Name: workflow_templates workflow_templates_articolo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.workflow_templates
    ADD CONSTRAINT workflow_templates_articolo_id_fkey FOREIGN KEY (articolo_id) REFERENCES public.articoli(id);


--
-- PostgreSQL database dump complete
--

