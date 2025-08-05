import React from 'react';

interface Article {
  id: number;
  nome: string;
  attivo: boolean;
  tipo_prodotto?: string;
  prezzo_base?: number;
}

interface Kit {
  id: number;
  nome: string;
  attivo: boolean;
  articoli_count?: number;
}

interface ArticlesStatsProps {
  articles: Article[];
  kits: Kit[];
}

const ArticlesStats: React.FC<ArticlesStatsProps> = ({ articles, kits }) => {
  // Articles statistics
  const activeArticles = articles.filter(a => a.attivo).length;
  const inactiveArticles = articles.length - activeArticles;
  
  const articlesWithPrice = articles.filter(a => a.prezzo_base && a.prezzo_base > 0);
  const avgPrice = articlesWithPrice.length > 0 
    ? articlesWithPrice.reduce((sum, a) => sum + (a.prezzo_base || 0), 0) / articlesWithPrice.length
    : 0;

  // Kits statistics
  const activeKits = kits.filter(k => k.attivo).length;
  const inactiveKits = kits.length - activeKits;
  
  const totalKitArticles = kits.reduce((sum, k) => sum + (k.articoli_count || 0), 0);
  const avgArticlesPerKit = kits.length > 0 ? totalKitArticles / kits.length : 0;

  // Product types distribution
  const typeDistribution = articles.reduce((acc, article) => {
    const type = article.tipo_prodotto || 'Non specificato';
    acc[type] = (acc[type] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);

  const StatCard: React.FC<{
    title: string;
    value: string | number;
    subtitle?: string;
    icon: string;
    trend?: 'up' | 'down' | 'stable';
    color?: 'primary' | 'success' | 'warning' | 'danger' | 'info';
  }> = ({ title, value, subtitle, icon, trend, color = 'primary' }) => (
    <div className={`stat-card stat-card-${color}`}>
      <div className="stat-header">
        <div className="stat-icon">{icon}</div>
        {trend && (
          <div className={`stat-trend trend-${trend}`}>
            {trend === 'up' ? '📈' : trend === 'down' ? '📉' : '➖'}
          </div>
        )}
      </div>
      <div className="stat-content">
        <div className="stat-value">{value}</div>
        <div className="stat-title">{title}</div>
        {subtitle && <div className="stat-subtitle">{subtitle}</div>}
      </div>
    </div>
  );

  return (
    <div className="articles-stats">
      <div className="stats-header">
        <h2>📊 Statistiche Generali</h2>
        <div className="stats-period">
          <select className="period-selector">
            <option value="all">Tutto il periodo</option>
            <option value="month">Ultimo mese</option>
            <option value="quarter">Ultimo trimestre</option>
            <option value="year">Ultimo anno</option>
          </select>
        </div>
      </div>

      {/* Main Stats Grid */}
      <div className="stats-grid">
        {/* Articles Section */}
        <div className="stats-section">
          <h3 className="section-title">📄 Articoli</h3>
          <div className="stats-row">
            <StatCard
              title="Totale Articoli"
              value={articles.length}
              icon="📄"
              color="primary"
            />
            <StatCard
              title="Articoli Attivi"
              value={activeArticles}
              subtitle={`${((activeArticles / articles.length) * 100 || 0).toFixed(1)}%`}
              icon="✅"
              color="success"
            />
            <StatCard
              title="Articoli Inattivi"
              value={inactiveArticles}
              subtitle={`${((inactiveArticles / articles.length) * 100 || 0).toFixed(1)}%`}
              icon="❌"
              color="warning"
            />
            <StatCard
              title="Prezzo Medio"
              value={`€${avgPrice.toFixed(2)}`}
              subtitle={`${articlesWithPrice.length} con prezzo`}
              icon="💰"
              color="info"
            />
          </div>
        </div>

        {/* Kits Section */}
        <div className="stats-section">
          <h3 className="section-title">📦 Kit Commerciali</h3>
          <div className="stats-row">
            <StatCard
              title="Totale Kit"
              value={kits.length}
              icon="📦"
              color="primary"
            />
            <StatCard
              title="Kit Attivi"
              value={activeKits}
              subtitle={`${((activeKits / kits.length) * 100 || 0).toFixed(1)}%`}
              icon="✅"
              color="success"
            />
            <StatCard
              title="Kit Inattivi"
              value={inactiveKits}
              subtitle={`${((inactiveKits / kits.length) * 100 || 0).toFixed(1)}%`}
              icon="❌"
              color="warning"
            />
            <StatCard
              title="Media Articoli/Kit"
              value={avgArticlesPerKit.toFixed(1)}
              subtitle={`${totalKitArticles} articoli totali`}
              icon="🔢"
              color="info"
            />
          </div>
        </div>
      </div>

      {/* Distribution Charts */}
      <div className="stats-charts">
        <div className="chart-section">
          <h3 className="section-title">📈 Distribuzione per Tipologia</h3>
          <div className="distribution-chart">
            {Object.entries(typeDistribution).map(([type, count]) => {
              const percentage = (count / articles.length) * 100;
              return (
                <div key={type} className="distribution-item">
                  <div className="distribution-label">
                    <span className="type-name">{type}</span>
                    <span className="type-count">{count}</span>
                  </div>
                  <div className="distribution-bar">
                    <div 
                      className="distribution-fill"
                      style={{ width: `${percentage}%` }}
                    ></div>
                  </div>
                  <div className="distribution-percentage">
                    {percentage.toFixed(1)}%
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="stats-actions">
          <h3 className="section-title">⚡ Azioni Rapide</h3>
          <div className="action-buttons">
            <button className="action-btn">
              <span className="action-icon">📊</span>
              <span className="action-text">Report Dettagliato</span>
            </button>
            <button className="action-btn">
              <span className="action-icon">📤</span>
              <span className="action-text">Esporta Dati</span>
            </button>
            <button className="action-btn">
              <span className="action-icon">🔄</span>
              <span className="action-text">Sincronizza</span>
            </button>
            <button className="action-btn">
              <span className="action-icon">⚙️</span>
              <span className="action-text">Configurazioni</span>
            </button>
          </div>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="recent-activity">
        <h3 className="section-title">🕒 Attività Recente</h3>
        <div className="activity-list">
          <div className="activity-item">
            <div className="activity-icon">📄</div>
            <div className="activity-content">
              <div className="activity-text">Nuovo articolo creato</div>
              <div className="activity-time">2 ore fa</div>
            </div>
          </div>
          <div className="activity-item">
            <div className="activity-icon">📦</div>
            <div className="activity-content">
              <div className="activity-text">Kit "Pacchetto Premium" modificato</div>
              <div className="activity-time">5 ore fa</div>
            </div>
          </div>
          <div className="activity-item">
            <div className="activity-icon">✅</div>
            <div className="activity-content">
              <div className="activity-text">3 articoli attivati</div>
              <div className="activity-time">1 giorno fa</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ArticlesStats;
