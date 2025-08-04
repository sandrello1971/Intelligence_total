-- =====================================================
-- WIKI DATABASE SCHEMA EXTENSION
-- Intelligence HUB v5.0 - Wiki Implementation
-- =====================================================

-- 1. ESTENSIONE TABELLE ESISTENTI
ALTER TABLE knowledge_documents 
ADD COLUMN IF NOT EXISTS wiki_page_id INTEGER,
ADD COLUMN IF NOT EXISTS is_wiki_content BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS wiki_category VARCHAR(100),
ADD COLUMN IF NOT EXISTS content_type VARCHAR(50) DEFAULT 'document';

-- 2. TABELLA PRINCIPALE WIKI PAGES
CREATE TABLE IF NOT EXISTS wiki_pages (
    id SERIAL PRIMARY KEY,
    slug VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    content_markdown TEXT,
    content_html TEXT,
    excerpt TEXT,
    
    source_document_id INTEGER REFERENCES knowledge_documents(id),
    
    category VARCHAR(100),
    tags TEXT[],
    
    status VARCHAR(50) DEFAULT 'draft',
    published_at TIMESTAMP,
    
    author_id VARCHAR(100),
    editor_id VARCHAR(100),
    
    meta_description VARCHAR(500),
    search_keywords TEXT,
    
    view_count INTEGER DEFAULT 0,
    last_viewed_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 3. TABELLA SEZIONI WIKI
CREATE TABLE IF NOT EXISTS wiki_sections (
    id SERIAL PRIMARY KEY,
    page_id INTEGER REFERENCES wiki_pages(id) ON DELETE CASCADE,
    
    section_title VARCHAR(255),
    content_markdown TEXT,
    content_html TEXT,
    section_order INTEGER DEFAULT 0,
    section_level INTEGER DEFAULT 1,
    
    vector_chunk_ids JSONB,
    section_type VARCHAR(50) DEFAULT 'text',
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4. TABELLA CATEGORIE WIKI
CREATE TABLE IF NOT EXISTS wiki_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INTEGER REFERENCES wiki_categories(id),
    
    sort_order INTEGER DEFAULT 0,
    color VARCHAR(7),
    icon VARCHAR(50),
    page_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. INDICI
CREATE INDEX IF NOT EXISTS idx_wiki_pages_slug ON wiki_pages(slug);
CREATE INDEX IF NOT EXISTS idx_wiki_pages_status ON wiki_pages(status);
CREATE INDEX IF NOT EXISTS idx_wiki_pages_category ON wiki_pages(category);
CREATE INDEX IF NOT EXISTS idx_wiki_sections_page_id ON wiki_sections(page_id);

-- 6. TRIGGER AUTO-UPDATE
CREATE OR REPLACE FUNCTION update_wiki_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS wiki_pages_updated_at ON wiki_pages;
CREATE TRIGGER wiki_pages_updated_at 
BEFORE UPDATE ON wiki_pages 
FOR EACH ROW EXECUTE FUNCTION update_wiki_updated_at();

-- 7. DATI INIZIALI
INSERT INTO wiki_categories (name, slug, description) VALUES 
('Generale', 'generale', 'Documentazione generale'),
('Tecnica', 'tecnica', 'Documentazione tecnica'),
('Procedure', 'procedure', 'Procedure operative'),
('FAQ', 'faq', 'Domande frequenti')
ON CONFLICT (slug) DO NOTHING;
