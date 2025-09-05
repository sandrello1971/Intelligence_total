import React, { useState, useEffect } from 'react';

interface WikiCategory {
  id: string;
  name: string;
  description?: string;
}

interface WikiStats {
  totalPages: number;
  totalCategories: number;
  recentUpdates: number;
}

const WikiPage: React.FC = () => {
  const [currentTab, setCurrentTab] = useState(0);
  const [categories, setCategories] = useState<WikiCategory[]>([]);
  const [stats, setStats] = useState<WikiStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Simula caricamento dati
    setTimeout(() => {
      setCategories([
        { id: '1', name: 'Generale', description: 'Informazioni generali' },
        { id: '2', name: 'Procedure', description: 'Procedure operative' }
      ]);
      setStats({
        totalPages: 45,
        totalCategories: 8,
        recentUpdates: 12
      });
      setLoading(false);
    }, 1000);
  }, []);

  if (loading) {
    return (
      <div style={{ padding: '40px', textAlign: 'center' }}>
        <div>Caricamento...</div>
      </div>
    );
  }

  return (
    <div style={{ padding: '20px', maxWidth: '1200px', margin: '0 auto' }}>
      <div style={{ marginBottom: '30px' }}>
        <h1>📚 Wiki Aziendale</h1>
        <p>Base di conoscenza e documentazione del team</p>
      </div>

      {/* Stats */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '20px', marginBottom: '30px' }}>
        <div style={{ background: '#f8f9fa', padding: '20px', borderRadius: '8px', textAlign: 'center' }}>
          <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#007bff' }}>{stats?.totalPages}</div>
          <div style={{ color: '#666', fontSize: '14px' }}>Pagine totali</div>
        </div>
        <div style={{ background: '#f8f9fa', padding: '20px', borderRadius: '8px', textAlign: 'center' }}>
          <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#28a745' }}>{stats?.totalCategories}</div>
          <div style={{ color: '#666', fontSize: '14px' }}>Categorie</div>
        </div>
        <div style={{ background: '#f8f9fa', padding: '20px', borderRadius: '8px', textAlign: 'center' }}>
          <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#ffc107' }}>{stats?.recentUpdates}</div>
          <div style={{ color: '#666', fontSize: '14px' }}>Aggiornamenti recenti</div>
        </div>
      </div>

      {/* Navigation Tabs */}
      <div style={{ borderBottom: '1px solid #dee2e6', marginBottom: '20px' }}>
        <div style={{ display: 'flex', gap: '20px' }}>
          <button
            onClick={() => setCurrentTab(0)}
            style={{
              padding: '10px 15px',
              border: 'none',
              background: currentTab === 0 ? '#007bff' : 'transparent',
              color: currentTab === 0 ? 'white' : '#666',
              borderRadius: '4px 4px 0 0',
              cursor: 'pointer'
            }}
          >
            📄 Pagine
          </button>
          <button
            onClick={() => setCurrentTab(1)}
            style={{
              padding: '10px 15px',
              border: 'none',
              background: currentTab === 1 ? '#007bff' : 'transparent',
              color: currentTab === 1 ? 'white' : '#666',
              borderRadius: '4px 4px 0 0',
              cursor: 'pointer'
            }}
          >
            📂 Categorie
          </button>
          <button
            onClick={() => setCurrentTab(2)}
            style={{
              padding: '10px 15px',
              border: 'none',
              background: currentTab === 2 ? '#007bff' : 'transparent',
              color: currentTab === 2 ? 'white' : '#666',
              borderRadius: '4px 4px 0 0',
              cursor: 'pointer'
            }}
          >
            🔍 Ricerca
          </button>
        </div>
      </div>

      {/* Tab Content */}
      <div>
        {currentTab === 0 && (
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h2>Pagine Wiki</h2>
              <button style={{ padding: '8px 16px', backgroundColor: '#28a745', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>
                ➕ Nuova Pagina
              </button>
            </div>
            <div style={{ border: '1px solid #dee2e6', borderRadius: '8px', padding: '20px', textAlign: 'center', color: '#666' }}>
              📄 Lista pagine wiki in sviluppo
            </div>
          </div>
        )}

        {currentTab === 1 && (
          <div>
            <h2>Categorie</h2>
            <div style={{ display: 'grid', gap: '15px' }}>
              {categories.map((category) => (
                <div key={category.id} style={{ border: '1px solid #dee2e6', borderRadius: '8px', padding: '15px' }}>
                  <h3 style={{ margin: '0 0 5px 0' }}>{category.name}</h3>
                  <p style={{ margin: 0, color: '#666', fontSize: '14px' }}>{category.description}</p>
                </div>
              ))}
            </div>
          </div>
        )}

        {currentTab === 2 && (
          <div>
            <h2>Ricerca</h2>
            <div style={{ marginBottom: '20px' }}>
              <input
                type="text"
                placeholder="🔍 Cerca nella wiki..."
                style={{ width: '100%', padding: '12px', border: '1px solid #dee2e6', borderRadius: '4px', fontSize: '16px' }}
              />
            </div>
            <div style={{ border: '1px solid #dee2e6', borderRadius: '8px', padding: '20px', textAlign: 'center', color: '#666' }}>
              🔍 Funzione di ricerca in sviluppo
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default WikiPage;
