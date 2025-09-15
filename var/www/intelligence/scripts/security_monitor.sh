#!/bin/bash
# Intelligence Security Monitor
# Controlla tentativi di accesso sospetti

LOG_FILE="/var/log/intelligence_security.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Controlla tentativi di accesso PostgreSQL falliti
PG_FAILURES=$(sudo tail -100 /var/log/postgresql/postgresql-*.log | grep -c "FATAL.*authentication failed")

# Controlla accessi SSH falliti
SSH_FAILURES=$(sudo tail -100 /var/log/auth.log | grep -c "Failed password")

# Log risultati
echo "[$DATE] PG_failures: $PG_FAILURES, SSH_failures: $SSH_FAILURES" >> $LOG_FILE

# Alert se troppe failure
if [ $PG_FAILURES -gt 5 ] || [ $SSH_FAILURES -gt 10 ]; then
    echo "[$DATE] 🚨 SECURITY ALERT: Too many failures detected!" >> $LOG_FILE
fi
