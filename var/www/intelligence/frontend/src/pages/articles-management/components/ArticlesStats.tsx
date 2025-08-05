import React from 'react';

interface Article {
  id: number;
  attivo: boolean;
  tipo_prodotto: 'semplice' | 'composito';
  prezzo_base?: number;
}

interface KitCommerciale {
  id: number;
  attivo: boolean;
  articoli_inclusi?: any[];
}

interface ArticlesStatsProps {
  articles: Article[];
  kits: KitCommerciale[];
}

const ArticlesStats: React.FC<ArticlesStatsProps> = ({ articles, kits }) => {
  const stats = {
    totalArticles: articles.length,
    activeArticles: articles.filter(a => a.attivo).length,
    simpleArticles: articles.filter(a => a.tipo_prodotto === 'semplice').length,
    totalKits: kits.length,
    activeKits: kits.filter(k => k.attivo).length,
    avgPrice: articles.reduce((sum, a) => sum + (a.prezzo_base || 0), 0) / articles.filter(a => a.prezzo_base).length || 0,
    totalKitArticles: kits.reduce((sum, k) => sum + (k.articoli_inclusi?.length || 0), 0),
  };
  
  return (
    <div className="articles-stats">
      <div className="stats-grid">
        <div className="stat-card primary">
          <div className="stat-icon">📄</div>
          <div className="stat-content">
            <div className="stat-number">{stats.totalArticles}</div>
            <div className="stat-label">Articoli Totali</div>
            <div className="stat-sublabel">{stats.activeArticles} attivi</div>
          </div>
        </div>
        
        <div className="stat-card secondary">
          <div className="stat-icon">📦</div>
          <div className="stat-content">
            <div className="stat-number">{stats.totalKits}</div>
            <div className="stat-label">Kit Commerciali</div>
            <div className="stat-sublabel">{stats.activeKits} attivi</div>
          </div>
        </div>
        
        <div className="stat-card tertiary">
          <div className="stat-icon">🧩</div>
          <div className="stat-content">
            <div className="stat-number">{stats.totalKitArticles}</div>
            <div className="stat-label">Articoli in Kit</div>
            <div className="stat-sublabel">Totali inclusi</div>
          </div>
        </div>
        
        <div className="stat-card quaternary">
          <div className="stat-icon">💰</div>
          <div className="stat-content">
            <div className="stat-number">
              {stats.avgPrice > 0 ? `€${stats.avgPrice.toFixed(0)}` : '---'}
            </div>
            <div className="stat-label">Prezzo Medio</div>
            <div className="stat-sublabel">Per articolo</div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ArticlesStats;
