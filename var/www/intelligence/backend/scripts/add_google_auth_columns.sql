-- Migrazione: Aggiunta colonne per autenticazione Google
-- Data: 2025-08-17

BEGIN;

-- Backup prima della migrazione (informativo)
\echo 'Adding Google authentication columns to users table...'

-- Aggiungi colonne per Google Auth
ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS google_credentials TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS auto_sync_enabled BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_sync_at TIMESTAMP WITHOUT TIME ZONE;

-- Aggiungi indici per performance
CREATE INDEX IF NOT EXISTS idx_users_google_id ON users(google_id);
CREATE INDEX IF NOT EXISTS idx_users_auto_sync ON users(auto_sync_enabled);

-- Verifica le colonne aggiunte
\echo 'Verifying new columns...'
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name IN ('google_id', 'google_credentials', 'auto_sync_enabled', 'last_sync_at')
ORDER BY column_name;

COMMIT;

\echo 'Google authentication columns added successfully!'
