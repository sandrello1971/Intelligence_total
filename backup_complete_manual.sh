#!/bin/bash
set -e
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_FILE="./backup_manual_$DATE.log"
SOURCE_DIR="/var/www/intelligence"

echo "🔄 Completamento backup manuale" | tee -a "$LOG_FILE"

# Salta i permessi problematici e continua con il resto
find "$SOURCE_DIR" -type f -name "*.sql" -readable -exec cp --parents {} . \; 2>>"$LOG_FILE" || true

# Continua con gli altri file
find "$SOURCE_DIR" -type f \( -name 'Dockerfile*' -o -name 'docker-compose*' \) -exec cp --parents {} . \; 2>>"$LOG_FILE" || true

# Requirements
find "$SOURCE_DIR" -type f \( -name 'requirements*.txt' -o -name 'package.json' \) -exec cp --parents {} . \; 2>>"$LOG_FILE" || true

echo "✅ Backup manuale completato" | tee -a "$LOG_FILE"
