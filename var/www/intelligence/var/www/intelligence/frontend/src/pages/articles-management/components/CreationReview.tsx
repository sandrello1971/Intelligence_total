import React, { useState } from 'react';
import { useAppDispatch, useAppSelector } from '../../../store';

const CreationReview: React.FC = () => {
  const dispatch = useAppDispatch();
  const { 
    selectedType, 
    articleForm, 
    kitComposition,
    loading 
  } = useAppSelector((state) => state.articles);

  const [showJsonPreview, setShowJsonPreview] = useState(false);
  const [acceptTerms, setAcceptTerms] = useState(false);

  const formatCurrency = (value: number) => {
    return new Intl.NumberFormat('it-IT', {
      style: 'currency',
      currency: 'EUR'
    }).format(value);
  };

  const calculateKitTotal = () => {
    if (selectedType !== 'kit_commerciale' || !kitComposition?.selectedArticles) {
      return 0;
    }
    
    return kitComposition.selectedArticles.reduce((total, item) => {
      const originalPrice = item.prezzo_originale || 0;
      const discount = item.sconto_percentuale || 0;
      const discountedPrice = originalPrice * (1 - discount / 100);
      return total + (discountedPrice * item.quantita);
    }, 0);
  };

  const getCreationPayload = () => {
    const basePayload = {
      tipo: selectedType,
      codice: articleForm?.codice,
      nome: articleForm?.nome,
      descrizione: articleForm?.descrizione,
      tipo_prodotto: articleForm?.tipo_prodotto,
      attivo: articleForm?.attivo !== false,
      sla_default_hours: articleForm?.sla_default_hours,
      template_milestones: articleForm?.template_milestones
    };

    if (selectedType === 'kit_commerciale') {
      return {
        ...basePayload,
        articoli: kitComposition?.selectedArticles?.map((item, index) => ({
          articolo_id: item.articolo_id,
          quantita: item.quantita,
          obbligatorio: item.obbligatorio,
          ordine: index,
          sconto_percentuale: item.sconto_percentuale || 0,
          note: item.note || ''
        })) || []
      };
    } else {
      return {
        ...basePayload,
        prezzo_base: articleForm?.prezzo_base,
        durata_mesi: articleForm?.durata_mesi
      };
    }
  };

  const getValidationIssues = () => {
    const issues: string[] = [];
    
    if (!articleForm?.codice?.trim()) {
      issues.push('Codice mancante');
    }
    
    if (!articleForm?.nome?.trim()) {
      issues.push('Nome mancante');
    }
    
    if (selectedType === 'kit_commerciale') {
      if (!kitComposition?.selectedArticles || kitComposition.selectedArticles.length === 0) {
        issues.push('Nessun articolo selezionato per il kit');
      }
    } else {
      if (!articleForm?.prezzo_base || articleForm.prezzo_base <= 0) {
        issues.push('Prezzo base non valido');
      }
    }
    
    return issues;
  };

  const validationIssues = getValidationIssues();
  const canCreate = validationIssues.length === 0 && acceptTerms;

  return (
    <div className="creation-review" style={{ padding: '20px', maxWidth: '800px', margin: '0 auto' }}>
      <div className="review-header" style={{ marginBottom: '30px', textAlign: 'center' }}>
        <h2>✅ Revisione Finale</h2>
        <p>Controlla attentamente tutti i dettagli prima di creare l'elemento.</p>
      </div>

      <div className="review-content">
        {/* Basic Information */}
        <div className="review-section" style={{ marginBottom: '25px', border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
          <div className="section-header" style={{ display: 'flex', alignItems: 'center', marginBottom: '15px' }}>
            <span className="section-icon" style={{ fontSize: '20px', marginRight: '10px' }}>📋</span>
            <h3 className="section-title">Informazioni di Base</h3>
          </div>
          <div className="section-content">
            <div className="info-grid" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px' }}>
              <div className="info-row">
                <span className="info-label" style={{ fontWeight: 'bold' }}>Tipo:</span>
                <span className="info-value">
                  <span className="type-badge" style={{ padding: '4px 8px', backgroundColor: '#e9ecef', borderRadius: '4px' }}>
                    {selectedType === 'kit_commerciale' ? '📦 Kit Commerciale' : 
                     selectedType === 'composito' ? '🔧 Articolo Composito' : 
                     '📄 Articolo Semplice'}
                  </span>
                </span>
              </div>
              
              <div className="info-row highlight" style={{ backgroundColor: '#fff3cd', padding: '8px', borderRadius: '4px' }}>
                <span className="info-label" style={{ fontWeight: 'bold' }}>Codice:</span>
                <code className="code-display" style={{ backgroundColor: '#f8f9fa', padding: '2px 4px', borderRadius: '3px' }}>
                  {selectedType === 'kit_commerciale' ? 'KIT-' : 'ART-'}{articleForm?.codice}
                </code>
              </div>
              
              <div className="info-row highlight" style={{ backgroundColor: '#fff3cd', padding: '8px', borderRadius: '4px' }}>
                <span className="info-label" style={{ fontWeight: 'bold' }}>Nome:</span>
                <span className="info-value">{articleForm?.nome}</span>
              </div>
              
              <div className="info-row">
                <span className="info-label" style={{ fontWeight: 'bold' }}>Tipologia:</span>
                <span className="info-value">{articleForm?.tipo_prodotto || 'Non specificata'}</span>
              </div>
              
              <div className="info-row">
                <span className="info-label" style={{ fontWeight: 'bold' }}>Stato:</span>
                <span className={`status-badge ${articleForm?.attivo !== false ? 'active' : 'inactive'}`} style={{ 
                  padding: '4px 8px', 
                  borderRadius: '4px',
                  backgroundColor: articleForm?.attivo !== false ? '#d4edda' : '#f8d7da',
                  color: articleForm?.attivo !== false ? '#155724' : '#721c24'
                }}>
                  {articleForm?.attivo !== false ? '✅ Attivo' : '❌ Inattivo'}
                </span>
              </div>
            </div>
            
            {articleForm?.descrizione && (
              <div className="description-preview" style={{ marginTop: '15px' }}>
                <h4>Descrizione:</h4>
                <p className="description-text" style={{ backgroundColor: '#f8f9fa', padding: '10px', borderRadius: '4px', fontStyle: 'italic' }}>
                  {articleForm.descrizione}
                </p>
              </div>
            )}
          </div>
        </div>

        {/* Pricing or Kit Information */}
        {selectedType !== 'kit_commerciale' ? (
          <div className="review-section" style={{ marginBottom: '25px', border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
            <div className="section-header" style={{ display: 'flex', alignItems: 'center', marginBottom: '15px' }}>
              <span className="section-icon" style={{ fontSize: '20px', marginRight: '10px' }}>💰</span>
              <h3 className="section-title">Informazioni Prezzo</h3>
            </div>
            <div className="pricing-info">
              <div className="info-row highlight" style={{ backgroundColor: '#fff3cd', padding: '8px', borderRadius: '4px', marginBottom: '10px' }}>
                <span className="info-label" style={{ fontWeight: 'bold' }}>Prezzo Base:</span>
                <span className="info-value" style={{ fontSize: '18px', fontWeight: 'bold' }}>{formatCurrency(articleForm?.prezzo_base || 0)}</span>
              </div>
              {articleForm?.durata_mesi && (
                <div className="info-row" style={{ marginBottom: '8px' }}>
                  <span className="info-label" style={{ fontWeight: 'bold' }}>Durata:</span>
                  <span className="info-value">{articleForm.durata_mesi} mesi</span>
                </div>
              )}
              {articleForm?.sla_default_hours && (
                <div className="info-row">
                  <span className="info-label" style={{ fontWeight: 'bold' }}>SLA Standard:</span>
                  <span className="info-value">{articleForm.sla_default_hours} ore</span>
                </div>
              )}
            </div>
          </div>
        ) : (
          <div className="review-section" style={{ marginBottom: '25px', border: '1px solid #ddd', padding: '20px', borderRadius: '8px' }}>
            <div className="section-header" style={{ display: 'flex', alignItems: 'center', marginBottom: '15px' }}>
              <span className="section-icon" style={{ fontSize: '20px', marginRight: '10px' }}>📦</span>
              <h3 className="section-title">Composizione Kit</h3>
            </div>
            <div className="kit-composition-summary">
              <div className="kit-stats" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '20px' }}>
                <div className="kit-stat">
                  <span className="stat-label" style={{ fontWeight: 'bold' }}>Articoli totali:</span>
                  <span className="stat-value">{kitComposition?.selectedArticles?.length || 0}</span>
                </div>
                <div className="kit-stat highlight" style={{ backgroundColor: '#fff3cd', padding: '8px', borderRadius: '4px' }}>
                  <span className="stat-label" style={{ fontWeight: 'bold' }}>Prezzo totale:</span>
                  <span className="stat-value" style={{ fontSize: '18px', fontWeight: 'bold' }}>{formatCurrency(calculateKitTotal())}</span>
                </div>
              </div>

              {kitComposition?.selectedArticles && kitComposition.selectedArticles.length > 0 && (
                <div className="articles-preview">
                  <h4>Articoli inclusi:</h4>
                  <div className="articles-list">
                    {kitComposition.selectedArticles.map((item, index) => (
                      <div key={index} className="article-preview-item" style={{ border: '1px solid #eee', padding: '10px', marginBottom: '8px', borderRadius: '4px' }}>
                        <div className="article-preview-header" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                          <div style={{ display: 'flex', alignItems: 'center' }}>
                            <span className="article-order" style={{ backgroundColor: '#007bff', color: 'white', padding: '2px 6px', borderRadius: '50%', fontSize: '12px', marginRight: '10px' }}>{index + 1}.</span>
                            <span className="article-name" style={{ fontWeight: 'bold' }}>{item.articolo_nome}</span>
                          </div>
                          <div className="article-badges">
                            {item.obbligatorio && <span className="badge required" style={{ backgroundColor: '#dc3545', color: 'white', padding: '2px 6px', borderRadius: '12px', fontSize: '10px', marginLeft: '5px' }}>Obbligatorio</span>}
                            {item.quantita > 1 && <span className="badge quantity" style={{ backgroundColor: '#28a745', color: 'white', padding: '2px 6px', borderRadius: '12px', fontSize: '10px', marginLeft: '5px' }}>×{item.quantita}</span>}
                          </div>
                        </div>
                        <div className="article-preview-details" style={{ display: 'flex', justifyContent: 'space-between', marginTop: '5px' }}>
                          <span className="article-code" style={{ color: '#666', fontSize: '12px' }}>{item.articolo_codice}</span>
                          <span className="article-price" style={{ fontWeight: 'bold', color: '#007bff' }}>
                            {formatCurrency((item.prezzo_originale || 0) * (1 - (item.sconto_percentuale || 0) / 100) * item.quantita)}
                          </span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Validation Issues */}
        {validationIssues.length > 0 && (
          <div className="validation-issues" style={{ backgroundColor: '#f8d7da', border: '1px solid #f5c6cb', padding: '15px', borderRadius: '4px', marginBottom: '20px' }}>
            <div className="issues-header" style={{ display: 'flex', alignItems: 'center', marginBottom: '10px' }}>
              <span className="issues-icon" style={{ marginRight: '10px' }}>⚠️</span>
              <h3 style={{ color: '#721c24', margin: 0 }}>Problemi da Risolvere</h3>
            </div>
            <ul className="issues-list" style={{ margin: 0, paddingLeft: '20px' }}>
              {validationIssues.map((issue, index) => (
                <li key={index} className="issue-item" style={{ color: '#721c24' }}>{issue}</li>
              ))}
            </ul>
          </div>
        )}

        {/* JSON Preview */}
        <div className="json-preview-section" style={{ marginBottom: '20px' }}>
          <button
            className="btn btn-outline btn-sm"
            onClick={() => setShowJsonPreview(!showJsonPreview)}
            style={{ padding: '8px 16px', border: '1px solid #6c757d', backgroundColor: 'transparent', borderRadius: '4px', cursor: 'pointer' }}
          >
            {showJsonPreview ? '🔼' : '🔽'} Mostra Payload JSON
          </button>
          
          {showJsonPreview && (
            <div className="json-preview" style={{ marginTop: '10px' }}>
              <pre className="json-code" style={{ backgroundColor: '#f8f9fa', padding: '15px', border: '1px solid #dee2e6', borderRadius: '4px', overflow: 'auto', fontSize: '12px' }}>
                {JSON.stringify(getCreationPayload(), null, 2)}
              </pre>
            </div>
          )}
        </div>

        {/* Terms and Conditions */}
        <div className="terms-section" style={{ marginBottom: '20px' }}>
          <label className="terms-checkbox" style={{ display: 'flex', alignItems: 'center', cursor: 'pointer' }}>
            <input
              type="checkbox"
              checked={acceptTerms}
              onChange={(e) => setAcceptTerms(e.target.checked)}
              style={{ marginRight: '10px' }}
            />
            <span className="checkbox-text">
              Ho verificato tutti i dati e confermo la creazione dell'elemento.
            </span>
          </label>
        </div>

        {/* Creation Summary */}
        <div className="creation-summary">
          <div className="summary-card" style={{ border: '2px solid #007bff', padding: '20px', borderRadius: '8px', backgroundColor: '#f8f9ff' }}>
            <div className="summary-header" style={{ marginBottom: '15px' }}>
              <h3 style={{ margin: 0, display: 'flex', alignItems: 'center' }}>
                {selectedType === 'kit_commerciale' ? '📦' : '📄'} 
                Riepilogo Creazione
              </h3>
            </div>
            <div className="summary-content">
              <div className="summary-main" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <strong style={{ fontSize: '18px' }}>{articleForm?.nome}</strong>
                  <div className="summary-code" style={{ color: '#666', fontSize: '14px' }}>
                    {selectedType === 'kit_commerciale' ? 'KIT-' : 'ART-'}{articleForm?.codice}
                  </div>
                </div>
                <div className="summary-price" style={{ fontSize: '20px', fontWeight: 'bold', color: '#007bff' }}>
                  {selectedType === 'kit_commerciale' 
                    ? formatCurrency(calculateKitTotal())
                    : formatCurrency(articleForm?.prezzo_base || 0)
                  }
                </div>
              </div>
            </div>
            
            {validationIssues.length === 0 && acceptTerms && (
              <div className="ready-indicator" style={{ marginTop: '15px', textAlign: 'center', color: '#28a745', fontWeight: 'bold' }}>
                ✅ Pronto per la creazione
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default CreationReview;
