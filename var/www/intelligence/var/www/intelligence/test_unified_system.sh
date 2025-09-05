#!/bin/bash
echo "🧪 Test Sistema Unificato Articoli + Kit"
echo "========================================"

# Test backend endpoints
echo "🔍 Testing backend APIs..."

# 1. Health check
echo "1. Health check..."
curl -s http://localhost:8000/health && echo " ✅" || echo " ❌"

# 2. Articles API
echo "2. Articles API..."
curl -s http://localhost:8000/api/v1/articles/ | head -c 100 && echo " ✅" || echo " ❌"

# 3. Kit Commerciali API
echo "3. Kit Commerciali API..."
curl -s http://localhost:8000/api/v1/kit-commerciali/ | head -c 100 && echo " ✅" || echo " ❌"

# 4. Tipologie Servizi API
echo "4. Tipologie Servizi API..."
curl -s http://localhost:8000/api/v1/tipologie-servizi/ | head -c 100 && echo " ✅" || echo " ❌"

# 5. Partner API
echo "5. Partner API..."
curl -s http://localhost:8000/api/v1/partner/ | head -c 100 && echo " ✅" || echo " ❌"

echo ""
echo "🔍 Testing frontend..."

# 6. Frontend build
echo "6. Frontend build test..."
cd /var/www/intelligence/frontend
npm run build >/dev/null 2>&1 && echo " ✅ Build successful" || echo " ❌ Build failed"

# 7. Check files
echo "7. Files check..."
[ -f "src/store/index.ts" ] && echo " ✅ Redux store" || echo " ❌ Redux store missing"
[ -f "src/pages/articles-management/ArticlesManagement.tsx" ] && echo " ✅ Main page" || echo " ❌ Main page missing"
[ -f "src/pages/articles-management/components/KitComposition.tsx" ] && echo " ✅ Kit composer" || echo " ❌ Kit composer missing"

echo ""
echo "📊 System Status:"
echo "- Backend: $(curl -s http://localhost:8000/health >/dev/null 2>&1 && echo 'Running ✅' || echo 'Stopped ❌')"
echo "- Frontend: $(lsof -ti:3000 >/dev/null 2>&1 && echo 'Running ✅' || echo 'Stopped ❌')"
echo "- Database: $(PGPASSWORD=intelligence_pass psql -h localhost -U intelligence_user -d intelligence -c 'SELECT 1;' >/dev/null 2>&1 && echo 'Connected ✅' || echo 'Disconnected ❌')"

echo ""
echo "🎯 Ready to test unified articles + kit creation!"
echo "Navigate to: http://localhost:3000/articoli"
