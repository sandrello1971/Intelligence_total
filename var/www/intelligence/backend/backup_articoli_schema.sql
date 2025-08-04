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
-- Name: articoli id; Type: DEFAULT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli ALTER COLUMN id SET DEFAULT nextval('public.articoli_id_seq'::regclass);


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
-- Name: idx_articoli_responsabile; Type: INDEX; Schema: public; Owner: intelligence_user
--

CREATE INDEX idx_articoli_responsabile ON public.articoli USING btree (responsabile_user_id);


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
-- Name: articoli fk_articoli_responsabile; Type: FK CONSTRAINT; Schema: public; Owner: intelligence_user
--

ALTER TABLE ONLY public.articoli
    ADD CONSTRAINT fk_articoli_responsabile FOREIGN KEY (responsabile_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

