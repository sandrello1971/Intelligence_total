import React, { useState, useEffect } from 'react';
import { useAppDispatch, useAppSelector } from '../../../store';

interface KitArticleItem {
  id?: number;
  articolo_id: number;
  articolo_nome?: string;
  articolo_codice?: string;
  quantita: number;
  obbligatorio: boolean;
  ordine: number;
  prezzo_originale?: number;
  sconto_percentuale?: number;
  note?: string;
}

const KitComposition: React.FC = () => {
  const dispatch = useAppDispatch();
  const { kitComposition, articles } = useAppSelector((state) => state.articles);
  
  const [availableArticles, setAvailableArticles] = useState(articles || []);
  const [selectedArticles, setSelectedArticles] = useState<KitArticleItem[]>(kitComposition?.selectedArticles || []);
  const [searchTerm, setSearchTerm] = useState('');
  const [showAddModal, setShowAddModal] = useState(false);

  useEffect(() => {
    if (articles) {
      const selectedIds = selectedArticles.map(item => item.articolo_id);
      setAvailableArticles(articles.filter(article => !selectedIds.includes(article.id)));
    }
  }, [selectedArticles, articles]);

  const handleAddArticle = (articleId: number) => {
    const article = articles?.find(a => a.id === articleId);
    if (!article) return;

    const newItem: KitArticleItem = {
      articolo_id: articleId,
      articolo_nome: article.nome,
      articolo_codice: article.codice,
      quantita: 1,
      obbligatorio: false,
      ordine: selectedArticles.length,
      prezzo_originale: article.prezzo_base || 0,
      sconto_percentuale: 0,
      note: ''
    };

    const newSelectedArticles = [...selectedArticles, newItem];
    setSelectedArticles(newSelectedArticles);
    setShowAddModal(false);
  };

  const handleRemoveArticle = (index: number) => {
    const newSelectedArticles = selectedArticles.filter((_, i) => i !== index);
    const reorderedArticles = newSelectedArticles.map((item, i) => ({ ...item, ordine: i }));
    setSelectedArticles(reorderedArticles);
  };

  const handleUpdateArticle = (index: number, field: keyof KitArticleItem, value: any) => {
    const newSelectedArticles = [...selectedArticles];
    newSelectedArticles[index] = { ...newSelectedArticles[index], [field]: value };
    setSelectedArticles(newSelectedArticles);
  };

  const calculateTotalPrice = () => {
    return selectedArticles.reduce((total, item) => {
      const originalPrice = item.prezzo_originale || 0;
      const discount = item.sconto_percentuale || 0;
      const discountedPrice = originalPrice * (1 - discount / 100);
      return total + (discountedPrice * item.quantita);
    }, 0);
  };

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('it-IT', {
      style: 'currency',
      currency: 'EUR'
    }).format(value);
  };

  const filteredAvailableArticles = availableArticles.filter(article =>
    article.nome?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    article.codice?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="kit-composition" style={{ padding: '20px' }}>
      <div className="composition-header">
        <h2>📦 Composizione Kit</h2>
        <p>Seleziona e organizza gli articoli che faranno parte del kit.</p>
      </div>

      <div className="composition-content" style={{ display: 'flex', gap: '20px', marginTop: '20px' }}>
        {/* Available Articles Panel */}
        <div className="available-articles-panel" style={{ flex: 1, border: '1px solid #ddd', padding: '15px', borderRadius: '8px' }}>
          <div className="panel-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
            <h3>📄 Articoli Disponibili</h3>
            <button 
              className="btn btn-sm btn-primary"
              onClick={() => setShowAddModal(true)}
              style={{ padding: '5px 10px', backgroundColor: '#007bff', color: 'white', border: 'none', borderRadius: '4px' }}
            >
              ➕ Aggiungi
            </button>
          </div>

          <div className="search-box" style={{ marginBottom: '15px' }}>
            <input
              type="text"
              placeholder="🔍 Cerca articoli..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{ width: '100%', padding: '8px', border: '1px solid #ddd', borderRadius: '4px' }}
            />
          </div>

          <div className="articles-list">
            {filteredAvailableArticles.map((article) => (
              <div 
                key={article.id} 
                className="article-item"
                onClick={() => handleAddArticle(article.id)}
                style={{ 
                  border: '1px solid #eee', 
                  padding: '10px', 
                  marginBottom: '8px', 
                  borderRadius: '4px', 
                  cursor: 'pointer',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center'
                }}
              >
                <div className="article-info">
                  <div className="article-name" style={{ fontWeight: 'bold' }}>{article.nome}</div>
                  <div className="article-code" style={{ color: '#666', fontSize: '12px' }}>{article.codice}</div>
                  {article.prezzo_base && (
                    <div className="article-price" style={{ color: '#007bff' }}>{formatCurrency(article.prezzo_base)}</div>
                  )}
                </div>
                <div className="add-button">➕</div>
              </div>
            ))}
            
            {filteredAvailableArticles.length === 0 && (
              <div className="empty-state" style={{ textAlign: 'center', padding: '20px', color: '#666' }}>
                <div className="empty-icon">📭</div>
                <p>Nessun articolo disponibile</p>
              </div>
            )}
          </div>
        </div>

        {/* Selected Articles Panel */}
        <div className="selected-articles-panel" style={{ flex: 1, border: '1px solid #ddd', padding: '15px', borderRadius: '8px' }}>
          <div className="panel-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '15px' }}>
            <h3>📦 Articoli nel Kit ({selectedArticles.length})</h3>
            <div className="kit-summary">
              <strong>Totale: {formatCurrency(calculateTotalPrice())}</strong>
            </div>
          </div>

          <div className="selected-articles-list">
            {selectedArticles.map((item, index) => (
              <div key={`${item.articolo_id}-${index}`} className="selected-article-item" style={{ border: '1px solid #eee', padding: '12px', marginBottom: '10px', borderRadius: '4px' }}>
                <div className="article-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                  <span className="item-order" style={{ backgroundColor: '#007bff', color: 'white', padding: '2px 6px', borderRadius: '50%', fontSize: '12px' }}>{index + 1}</span>
                  <h4 className="article-name" style={{ margin: 0, flex: 1, marginLeft: '10px' }}>{item.articolo_nome}</h4>
                  <button 
                    className="remove-button"
                    onClick={() => handleRemoveArticle(index)}
                    style={{ background: 'none', border: 'none', color: '#dc3545', cursor: 'pointer', fontSize: '16px' }}
                  >
                    ✕
                  </button>
                </div>
                
                <div className="article-code" style={{ color: '#666', fontSize: '12px', marginBottom: '10px' }}>{item.articolo_codice}</div>

                <div className="article-config" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '10px', marginBottom: '10px' }}>
                  <div className="config-group">
                    <label style={{ fontSize: '12px', color: '#666' }}>Quantità:</label>
                    <input
                      type="number"
                      min="1"
                      value={item.quantita}
                      onChange={(e) => handleUpdateArticle(index, 'quantita', parseInt(e.target.value) || 1)}
                      style={{ width: '100%', padding: '4px', border: '1px solid #ddd', borderRadius: '4px' }}
                    />
                  </div>

                  <div className="config-group">
                    <label style={{ fontSize: '12px', color: '#666' }}>Sconto %:</label>
                    <input
                      type="number"
                      min="0"
                      max="100"
                      value={item.sconto_percentuale || 0}
                      onChange={(e) => handleUpdateArticle(index, 'sconto_percentuale', parseFloat(e.target.value) || 0)}
                      style={{ width: '100%', padding: '4px', border: '1px solid #ddd', borderRadius: '4px' }}
                    />
                  </div>

                  <div className="config-group checkbox-group">
                    <label style={{ fontSize: '12px', display: 'flex', alignItems: 'center', gap: '5px' }}>
                      <input
                        type="checkbox"
                        checked={item.obbligatorio}
                        onChange={(e) => handleUpdateArticle(index, 'obbligatorio', e.target.checked)}
                      />
                      Obbligatorio
                    </label>
                  </div>
                </div>

                <div className="price-calculation" style={{ backgroundColor: '#f8f9fa', padding: '8px', borderRadius: '4px' }}>
                  <div className="price-row total" style={{ display: 'flex', justifyContent: 'space-between', fontWeight: 'bold' }}>
                    <span>Prezzo finale:</span>
                    <span>{formatCurrency((item.prezzo_originale || 0) * (1 - (item.sconto_percentuale || 0) / 100) * item.quantita)}</span>
                  </div>
                </div>
              </div>
            ))}

            {selectedArticles.length === 0 && (
              <div className="empty-state" style={{ textAlign: 'center', padding: '40px', color: '#666' }}>
                <div className="empty-icon" style={{ fontSize: '48px', marginBottom: '10px' }}>📦</div>
                <h3>Kit vuoto</h3>
                <p>Aggiungi articoli dalla lista a sinistra.</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default KitComposition;
