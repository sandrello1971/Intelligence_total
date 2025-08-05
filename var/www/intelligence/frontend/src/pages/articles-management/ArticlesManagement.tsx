import React, { useState, useEffect } from 'react';

interface Articolo {
  id: number;
  codice: string;
  nome: string;
  descrizione?: string;
  tipo_prodotto: string;
  prezzo_base?: number;
  durata_mesi?: number;
  attivo: boolean;
  created_at?: string;
  responsabile_display_name?: string;
}

interface Kit {
  id: number;
  nome: string;
  descrizione: string;
  attivo: boolean;
  created_at: string;
  articoli: any[];
}

const ArticlesManagement: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'articoli' | 'kit'>('articoli');
  const [articoli, setArticoli] = useState<Articolo[]>([]);
  const [kits, setKits] = useState<Kit[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setLoading(true);
    try {
      // Fetch articoli
      const articoliResponse = await fetch('/api/v1/articles/');
      const articoliData = await articoliResponse.json();
      
      // Fetch kit
      const kitsResponse = await fetch('/api/v1/kit-commerciali/');
      const kitsData = await kitsResponse.json();
      
      if (articoliData.success) {
        setArticoli(articoliData.articles || []);
      }
      
      if (kitsData.success) {
        setKits(kitsData.kit_commerciali || []);
      }
      
      if (!articoliData.success && !kitsData.success) {
        setError('Errore nel caricamento dei dati');
      }
    } catch (err) {
      setError('Errore di connessione');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteArticolo = async (id: number, nome: string) => {
    if (!confirm(`Confermi la cancellazione dell'articolo "${nome}"?`)) return;
    alert('🔄 Eliminazione articoli - API da implementare');
  };

  const handleDeleteKit = async (id: number, nome: string) => {
    if (!confirm(`Confermi la cancellazione del kit "${nome}"?`)) return;
    
    try {
      const response = await fetch(`/api/v1/kit-commerciali/${id}`, {
        method: 'DELETE'
      });
      const data = await response.json();
      
      if (data.success) {
        alert('✅ Kit eliminato con successo');
        fetchData();
      } else {
        alert('❌ Errore nella cancellazione');
      }
    } catch (err) {
      alert('❌ Errore di connessione');
    }
  };

  if (loading) {
    return (
      <div style={{ padding: '20px', textAlign: 'center' }}>
        <div>🔄 Caricamento dati...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ padding: '20px', textAlign: 'center', color: 'red' }}>
        <div>❌ {error}</div>
        <button onClick={fetchData} style={{ marginTop: '10px', padding: '8px 16px', backgroundColor: '#007bff', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer' }}>
          🔄 Riprova
        </button>
      </div>
    );
  }

  const articoliSemplici = articoli.filter(a => a.tipo_prodotto === 'semplice');
  const articoliCompositi = articoli.filter(a => a.tipo_prodotto === 'composito');

  return (
    <div style={{ padding: '20px', maxWidth: '1200px', margin: '0 auto' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ margin: '0 0 5px 0' }}>🛠️ Gestione Articoli e Kit</h1>
          <p style={{ margin: 0, color: '#666', fontSize: '16px' }}>
            Visualizzazione completa di articoli singoli, compositi e kit commerciali
          </p>
        </div>
        
        <div style={{ display: 'flex', gap: '12px' }}>
          <button onClick={fetchData} style={{ padding: '10px 16px', backgroundColor: '#6c757d', color: 'white', border: 'none', borderRadius: '6px', cursor: 'pointer', fontSize: '14px' }}>
            🔄 Aggiorna
          </button>
          <button onClick={() => alert('✨ Wizard Creazione - In sviluppo')} style={{ padding: '12px 24px', backgroundColor: '#007bff', color: 'white', border: 'none', borderRadius: '6px', cursor: 'pointer', fontSize: '16px', fontWeight: '600' }}>
            ✨ Nuovo Elemento
          </button>
        </div>
      </div>

      {/* Stats Overview */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '15px', marginBottom: '30px' }}>
        <div style={{ background: '#e3f2fd', padding: '15px', borderRadius: '8px', textAlign: 'center' }}>
          <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#1976d2' }}>{articoliSemplici.length}</div>
          <div style={{ color: '#1976d2', fontWeight: '500', fontSize: '14px' }}>Articoli Semplici</div>
        </div>
        <div style={{ background: '#f3e5f5', padding: '15px', borderRadius: '8px', textAlign: 'center' }}>
          <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#7b1fa2' }}>{articoliCompositi.length}</div>
          <div style={{ color: '#7b1fa2', fontWeight: '500', fontSize: '14px' }}>Articoli Compositi</div>
        </div>
        <div style={{ background: '#e8f5e8', padding: '15px', borderRadius: '8px', textAlign: 'center' }}>
          <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#388e3c' }}>{kits.length}</div>
          <div style={{ color: '#388e3c', fontWeight: '500', fontSize: '14px' }}>Kit Commerciali</div>
        </div>
        <div style={{ background: '#fff3e0', padding: '15px', borderRadius: '8px', textAlign: 'center' }}>
          <div style={{ fontSize: '24px', fontWeight: 'bold', color: '#f57c00' }}>{articoli.filter(a => a.attivo).length}</div>
          <div style={{ color: '#f57c00', fontWeight: '500', fontSize: '14px' }}>Elementi Attivi</div>
        </div>
      </div>

      {/* Tabs */}
      <div style={{ borderBottom: '1px solid #dee2e6', marginBottom: '25px' }}>
        <div style={{ display: 'flex', gap: '0' }}>
          <button
            onClick={() => setActiveTab('articoli')}
            style={{
              padding: '12px 24px',
              border: 'none',
              background: activeTab === 'articoli' ? '#007bff' : 'transparent',
              color: activeTab === 'articoli' ? 'white' : '#666',
              borderRadius: '6px 6px 0 0',
              cursor: 'pointer',
              fontWeight: '500',
              borderBottom: activeTab === 'articoli' ? '2px solid #007bff' : '2px solid transparent'
            }}
          >
            📄 Articoli ({articoli.length})
          </button>
          <button
            onClick={() => setActiveTab('kit')}
            style={{
              padding: '12px 24px',
              border: 'none',
              background: activeTab === 'kit' ? '#007bff' : 'transparent',
              color: activeTab === 'kit' ? 'white' : '#666',
              borderRadius: '6px 6px 0 0',
              cursor: 'pointer',
              fontWeight: '500',
              borderBottom: activeTab === 'kit' ? '2px solid #007bff' : '2px solid transparent'
            }}
          >
            📦 Kit Commerciali ({kits.length})
          </button>
        </div>
      </div>

      {/* Tab Content */}
      {activeTab === 'articoli' && (
        <div>
          <h2 style={{ marginBottom: '20px' }}>📄 Articoli</h2>
          
          {/* Articoli Semplici */}
          <div style={{ marginBottom: '30px' }}>
            <h3 style={{ color: '#1976d2', marginBottom: '15px' }}>🔹 Articoli Semplici ({articoliSemplici.length})</h3>
            <div style={{ display: 'grid', gap: '12px' }}>
              {articoliSemplici.map((articolo) => (
                <div key={articolo.id} style={{ border: '1px solid #ddd', borderRadius: '8px', padding: '15px', background: articolo.attivo ? '#fff' : '#f5f5f5' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start' }}>
                    <div style={{ flex: 1 }}>
                      <h4 style={{ margin: '0 0 5px 0', color: '#333' }}>
                        <span style={{ fontFamily: 'monospace', backgroundColor: '#f0f0f0', padding: '2px 6px', borderRadius: '3px', marginRight: '8px', fontSize: '12px' }}>
                          {articolo.codice}
                        </span>
                        {articolo.nome}
                      </h4>
                      {articolo.descrizione && <p style={{ margin: '0 0 8px 0', color: '#666', fontSize: '14px' }}>{articolo.descrizione}</p>}
                      <div style={{ display: 'flex', gap: '12px', fontSize: '13px', color: '#666' }}>
                        {articolo.prezzo_base && <span>💰 €{articolo.prezzo_base}</span>}
                        {articolo.durata_mesi && <span>⏱️ {articolo.durata_mesi} mesi</span>}
                        {articolo.responsabile_display_name && <span>👤 {articolo.responsabile_display_name}</span>}
                      </div>
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span style={{ padding: '4px 8px', borderRadius: '12px', fontSize: '11px', fontWeight: '500', background: articolo.attivo ? '#e8f5e8' : '#ffecb3', color: articolo.attivo ? '#2e7d32' : '#f57c00' }}>
                        {articolo.attivo ? '✅ Attivo' : '⚠️ Inattivo'}
                      </span>
                      <button onClick={() => alert(`📝 Modifica "${articolo.nome}" - In sviluppo`)} style={{ padding: '4px 8px', backgroundColor: '#17a2b8', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '11px' }}>
                        ✏️
                      </button>
                      <button onClick={() => handleDeleteArticolo(articolo.id, articolo.nome)} style={{ padding: '4px 8px', backgroundColor: '#dc3545', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '11px' }}>
                        🗑️
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Articoli Compositi */}
          <div>
            <h3 style={{ color: '#7b1fa2', marginBottom: '15px' }}>🔸 Articoli Compositi ({articoliCompositi.length})</h3>
            <div style={{ display: 'grid', gap: '12px' }}>
              {articoliCompositi.map((articolo) => (
                <div key={articolo.id} style={{ border: '1px solid #ddd', borderRadius: '8px', padding: '15px', background: articolo.attivo ? '#fff' : '#f5f5f5' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start' }}>
                    <div style={{ flex: 1 }}>
                      <h4 style={{ margin: '0 0 5px 0', color: '#333' }}>
                        <span style={{ fontFamily: 'monospace', backgroundColor: '#f0f0f0', padding: '2px 6px', borderRadius: '3px', marginRight: '8px', fontSize: '12px' }}>
                          {articolo.codice}
                        </span>
                        {articolo.nome}
                      </h4>
                      {articolo.descrizione && <p style={{ margin: '0 0 8px 0', color: '#666', fontSize: '14px' }}>{articolo.descrizione}</p>}
                      <div style={{ display: 'flex', gap: '12px', fontSize: '13px', color: '#666' }}>
                        <span style={{ color: '#7b1fa2', fontWeight: '500' }}>🔸 Composito</span>
                        {articolo.responsabile_display_name && <span>👤 {articolo.responsabile_display_name}</span>}
                      </div>
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <span style={{ padding: '4px 8px', borderRadius: '12px', fontSize: '11px', fontWeight: '500', background: articolo.attivo ? '#e8f5e8' : '#ffecb3', color: articolo.attivo ? '#2e7d32' : '#f57c00' }}>
                        {articolo.attivo ? '✅ Attivo' : '⚠️ Inattivo'}
                      </span>
                      <button onClick={() => alert(`📝 Modifica "${articolo.nome}" - In sviluppo`)} style={{ padding: '4px 8px', backgroundColor: '#17a2b8', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '11px' }}>
                        ✏️
                      </button>
                      <button onClick={() => handleDeleteArticolo(articolo.id, articolo.nome)} style={{ padding: '4px 8px', backgroundColor: '#dc3545', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '11px' }}>
                        🗑️
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {activeTab === 'kit' && (
        <div>
          <h2 style={{ marginBottom: '20px' }}>📦 Kit Commerciali</h2>
          <div style={{ display: 'grid', gap: '15px' }}>
            {kits.map((kit) => (
              <div key={kit.id} style={{ border: '1px solid #ddd', borderRadius: '8px', padding: '20px', background: kit.attivo ? '#fff' : '#f5f5f5' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'start', marginBottom: '10px' }}>
                  <div style={{ flex: 1 }}>
                    <h3 style={{ margin: '0 0 5px 0', color: '#333' }}>{kit.nome}</h3>
                    <p style={{ margin: '0', color: '#666', fontSize: '14px' }}>{kit.descrizione}</p>
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <span style={{ padding: '4px 12px', borderRadius: '12px', fontSize: '12px', fontWeight: '500', background: kit.attivo ? '#e8f5e8' : '#ffecb3', color: kit.attivo ? '#2e7d32' : '#f57c00' }}>
                      {kit.attivo ? '✅ Attivo' : '⚠️ Inattivo'}
                    </span>
                    <button onClick={() => alert(`📝 Modifica kit "${kit.nome}" - In sviluppo`)} style={{ padding: '6px 12px', backgroundColor: '#17a2b8', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '12px' }}>
                      ✏️ Modifica
                    </button>
                    <button onClick={() => handleDeleteKit(kit.id, kit.nome)} style={{ padding: '6px 12px', backgroundColor: '#dc3545', color: 'white', border: 'none', borderRadius: '4px', cursor: 'pointer', fontSize: '12px' }}>
                      🗑️ Elimina
                    </button>
                  </div>
                </div>
                
                {kit.articoli.length > 0 ? (
                  <div>
                    <div style={{ fontWeight: '500', marginBottom: '8px', color: '#555' }}>
                      Articoli inclusi ({kit.articoli.length}):
                    </div>
                    <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
                      {kit.articoli.map((articolo) => (
                        <div key={articolo.id} style={{ background: '#f0f0f0', padding: '6px 12px', borderRadius: '16px', fontSize: '13px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                          <span style={{ fontWeight: '500' }}>{articolo.articolo_codice}</span>
                          <span>{articolo.articolo_nome}</span>
                          {articolo.quantita > 1 && <span style={{ color: '#666' }}>×{articolo.quantita}</span>}
                          {articolo.obbligatorio && <span style={{ color: '#d32f2f', fontSize: '10px' }}>●</span>}
                        </div>
                      ))}
                    </div>
                  </div>
                ) : (
                  <div style={{ color: '#999', fontStyle: 'italic' }}>📭 Nessun articolo configurato</div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Footer Status */}
      <div style={{ marginTop: '30px', background: '#d4edda', border: '1px solid #c3e6cb', borderRadius: '8px', padding: '20px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '10px' }}>
          <span style={{ fontSize: '20px' }}>🎯</span>
          <h3 style={{ margin: 0, color: '#155724' }}>Sistema Integrato Attivo</h3>
        </div>
        <p style={{ margin: 0, color: '#155724' }}>
          ✅ Articoli Semplici: {articoliSemplici.length} | ✅ Articoli Compositi: {articoliCompositi.length} | ✅ Kit Commerciali: {kits.length} | 🔄 CRUD Parziale
        </p>
      </div>
    </div>
  );
};

export default ArticlesManagement;
