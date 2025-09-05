#!/bin/bash
echo "🚀 Setup Pagina Unificata Articoli + Kit Commerciali"
echo "===================================================="

# 1. Backup esistente
echo "1. Creating backup..."
cp -r src src.backup-unified-articles-$(date +%Y%m%d_%H%M%S)

# 2. Install dipendenze Redux
echo "2. Installing Redux dependencies..."
npm install @reduxjs/toolkit react-redux @types/react-redux

# 3. Verifica struttura
echo "3. Verifying structure..."
echo "✅ Store:" && ls -la src/store/ 2>/dev/null || echo "❌ Store missing"
echo "✅ Pages:" && ls -la src/pages/articles-management/ 2>/dev/null || echo "❌ Articles management missing"
echo "✅ Components:" && ls -la src/pages/articles-management/components/ 2>/dev/null || echo "❌ Components missing"

# 4. Build test
echo "4. Testing build..."
npm run build && echo "✅ Build successful" || echo "❌ Build failed"

echo ""
echo "🎯 Next Steps:"
echo "1. npm start - per avviare il dev server"
echo "2. Vai su http://localhost:3000/articoli"
echo "3. Testa il flusso di creazione kit commerciali"

echo ""
echo "🔧 URLs importanti:"
echo "- Frontend: http://localhost:3000/articoli"
echo "- Backend API: http://localhost:8000/docs"
echo "- Health check: http://localhost:8000/health"
