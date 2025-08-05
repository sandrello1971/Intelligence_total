import React, { useState, useEffect } from 'react';
import { useAppDispatch, useAppSelector } from '../../../store';
import { updateArticleForm } from '../../../store/articlesSlice';

const ArticleConfiguration: React.FC = () => {
  const dispatch = useAppDispatch();
  const { articleForm, selectedType, tipologie } = useAppSelector((state) => state.articles);
  
  const [formData, setFormData] = useState(articleForm);
  const [validationErrors, setValidationErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    setFormData(articleForm);
  }, [articleForm]);

  const handleInputChange = (field: string, value: any) => {
    const newFormData = { ...formData, [field]: value };
    setFormData(newFormData);
    dispatch(updateArticleForm(newFormData));
    
    // Clear validation error when user starts typing
    if (validationErrors[field]) {
      setValidationErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  const validateForm = () => {
    const errors: Record<string, string> = {};
    
    if (!formData.codice?.trim()) {
      errors.codice = 'Il codice è obbligatorio';
    } else if (formData.codice.length < 3) {
      errors.codice = 'Il codice deve essere di almeno 3 caratteri';
    }
    
    if (!formData.nome?.trim()) {
      errors.nome = 'Il nome è obbligatorio';
    } else if (formData.nome.length < 5) {
      errors.nome = 'Il nome deve essere di almeno 5 caratteri';
    }
    
    if (selectedType !== 'kit_commerciale' && formData.prezzo_base && formData.prezzo_base < 0) {
      errors.prezzo_base = 'Il prezzo non può essere negativo';
    }
    
    if (formData.durata_mesi && formData.durata_mesi < 1) {
      errors.durata_mesi = 'La durata deve essere di almeno 1 mese';
    }
    
    setValidationErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const getFieldLabel = (field: string) => {
    const labels: Record<string, string> = {
      codice: selectedType === 'kit_commerciale' ? 'Codice Kit' : 'Codice Articolo',
      nome: selectedType === 'kit_commerciale' ? 'Nome Kit' : 'Nome Articolo',
      descrizione: 'Descrizione',
      tipo_prodotto: 'Tipologia Prodotto',
      prezzo_base: selectedType === 'kit_commerciale' ? 'Prezzo Kit' : 'Prezzo Base',
      durata_mesi: 'Durata (mesi)',
      sla_default_hours: 'SLA Standard (ore)',
      template_milestones: 'Template Milestone',
      attivo: 'Stato'
    };
    return labels[field] || field;
  };

  const formatCurrency = (value: number | undefined) => {
    return value ? new Intl.NumberFormat('it-IT', {
      style: 'currency',
      currency: 'EUR'
    }).format(value) : '€0,00';
  };

  const FormField: React.FC<{
    label: string;
    error?: string;
    required?: boolean;
    children: React.ReactNode;
  }> = ({ label, error, required, children }) => (
    <div className={`form-field ${error ? 'has-error' : ''}`}>
      <label className="field-label">
        {label}
        {required && <span className="required-asterisk">*</span>}
      </label>
      {children}
      {error && <div className="field-error">{error}</div>}
    </div>
  );

  return (
    <div className="article-configuration">
      <div className="config-header">
        <h2>⚙️ Configurazione {selectedType === 'kit_commerciale' ? 'Kit Commerciale' : 'Articolo'}</h2>
        <p>Compila i dettagli principali per il tuo {selectedType === 'kit_commerciale' ? 'kit' : 'articolo'}.</p>
      </div>

      <div className="config-form">
        <div className="form-sections">
          {/* Basic Information */}
          <div className="form-section">
            <h3 className="section-title">📋 Informazioni di Base</h3>
            <div className="section-content">
              <div className="form-row">
                <FormField 
                  label={getFieldLabel('codice')} 
                  error={validationErrors.codice}
                  required
                >
                  <div className="input-with-prefix">
                    <span className="input-prefix">
                      {selectedType === 'kit_commerciale' ? 'KIT-' : 'ART-'}
                    </span>
                    <input
                      type="text"
                      value={formData.codice || ''}
                      onChange={(e) => handleInputChange('codice', e.target.value.toUpperCase())}
                      placeholder="ES: SEO001"
                      className="form-input"
                      maxLength={20}
                    />
                  </div>
                  <div className="field-hint">
                    Codice univoco per identificare l'elemento nel sistema
                  </div>
                </FormField>

                <FormField 
                  label={getFieldLabel('nome')} 
                  error={validationErrors.nome}
                  required
                >
                  <input
                    type="text"
                    value={formData.nome || ''}
                    onChange={(e) => handleInputChange('nome', e.target.value)}
                    placeholder={selectedType === 'kit_commerciale' ? 'Es: Kit SEO Completo' : 'Es: Consulenza SEO'}
                    className="form-input"
                    maxLength={200}
                  />
                  <div className="field-hint">
                    Nome commerciale visibile ai clienti
                  </div>
                </FormField>
              </div>

              <FormField label={getFieldLabel('descrizione')}>
                <textarea
                  value={formData.descrizione || ''}
                  onChange={(e) => handleInputChange('descrizione', e.target.value)}
                  placeholder="Descrizione dettagliata dell'elemento..."
                  className="form-textarea"
                  rows={4}
                  maxLength={1000}
                />
                <div className="field-hint">
                  Descrizione che apparirà nei preventivi e documenti
                </div>
              </FormField>
            </div>
          </div>

          {/* Product Configuration */}
          <div className="form-section">
            <h3 className="section-title">🔧 Configurazione Prodotto</h3>
            <div className="section-content">
              <div className="form-row">
                <FormField label={getFieldLabel('tipo_prodotto')}>
                  <select
                    value={formData.tipo_prodotto || ''}
                    onChange={(e) => handleInputChange('tipo_prodotto', e.target.value)}
                    className="form-select"
                  >
                    <option value="">Seleziona tipologia...</option>
                    {tipologie.map((tipo) => (
                      <option key={tipo.id} value={tipo.nome}>
                        {tipo.nome}
                      </option>
                    ))}
                    <option value="consulenza">Consulenza</option>
                    <option value="sviluppo">Sviluppo</option>
                    <option value="marketing">Marketing</option>
                    <option value="supporto">Supporto</option>
                    <option value="formazione">Formazione</option>
                  </select>
                </FormField>

                <FormField label="Stato">
                  <div className="toggle-switch">
                    <input
                      type="checkbox"
                      id="attivo-toggle"
                      checked={formData.attivo !== false}
                      onChange={(e) => handleInputChange('attivo', e.target.checked)}
                    />
                    <label htmlFor="attivo-toggle" className="toggle-label">
                      <span className="toggle-slider"></span>
                      <span className="toggle-text">
                        {formData.attivo !== false ? '✅ Attivo' : '❌ Inattivo'}
                      </span>
                    </label>
                  </div>
                </FormField>
              </div>
            </div>
          </div>

          {/* Pricing & Duration */}
          {selectedType !== 'kit_commerciale' && (
            <div className="form-section">
              <h3 className="section-title">💰 Prezzi e Durata</h3>
              <div className="section-content">
                <div className="form-row">
                  <FormField 
                    label={getFieldLabel('prezzo_base')} 
                    error={validationErrors.prezzo_base}
                  >
                    <div className="input-with-suffix">
                      <input
                        type="number"
                        value={formData.prezzo_base || ''}
                        onChange={(e) => handleInputChange('prezzo_base', parseFloat(e.target.value) || null)}
                        placeholder="0.00"
                        className="form-input"
                        min="0"
                        step="0.01"
                      />
                      <span className="input-suffix">€</span>
                    </div>
                    <div className="field-hint">
                      Prezzo base dell'articolo (IVA esclusa)
                    </div>
                  </FormField>

                  <FormField 
                    label={getFieldLabel('durata_mesi')} 
                    error={validationErrors.durata_mesi}
                  >
                    <div className="input-with-suffix">
                      <input
                        type="number"
                        value={formData.durata_mesi || ''}
                        onChange={(e) => handleInputChange('durata_mesi', parseInt(e.target.value) || null)}
                        placeholder="1"
                        className="form-input"
                        min="1"
                        max="120"
                      />
                      <span className="input-suffix">mesi</span>
                    </div>
                    <div className="field-hint">
                      Durata stimata per il completamento
                    </div>
                  </FormField>
                </div>
              </div>
            </div>
          )}

          {/* Service Level & Templates */}
          <div className="form-section">
            <h3 className="section-title">⏱️ SLA e Template</h3>
            <div className="section-content">
              <div className="form-row">
                <FormField label={getFieldLabel('sla_default_hours')}>
                  <div className="input-with-suffix">
                    <input
                      type="number"
                      value={formData.sla_default_hours || ''}
                      onChange={(e) => handleInputChange('sla_default_hours', parseInt(e.target.value) || null)}
                      placeholder="24"
                      className="form-input"
                      min="1"
                      max="8760"
                    />
                    <span className="input-suffix">ore</span>
                  </div>
                  <div className="field-hint">
                    Tempo di risposta standard per questo servizio
                  </div>
                </FormField>

                <FormField label={getFieldLabel('template_milestones')}>
                  <textarea
                    value={formData.template_milestones || ''}
                    onChange={(e) => handleInputChange('template_milestones', e.target.value)}
                    placeholder="Es: Analisi iniziale, Implementazione, Test, Go-live"
                    className="form-textarea"
                    rows={3}
                    maxLength={2000}
                  />
                  <div className="field-hint">
                    Template delle fasi standard per questo tipo di servizio
                  </div>
                </FormField>
              </div>
            </div>
          </div>
        </div>

        {/* Preview Card */}
        <div className="form-preview">
          <h3 className="preview-title">👁️ Anteprima</h3>
          <div className="preview-card">
            <div className="preview-header">
              <div className="preview-icon">
                {selectedType === 'kit_commerciale' ? '📦' : '📄'}
              </div>
              <div className="preview-info">
                <h4 className="preview-name">
                  {formData.nome || 'Nome non specificato'}
                </h4>
                <p className="preview-code">
                  {selectedType === 'kit_commerciale' ? 'KIT-' : 'ART-'}{formData.codice || 'CODICE'}
                </p>
              </div>
              <div className="preview-status">
                <span className={`status-badge ${formData.attivo !== false ? 'active' : 'inactive'}`}>
                  {formData.attivo !== false ? '✅' : '❌'}
                </span>
              </div>
            </div>

            <div className="preview-content">
              {formData.descrizione && (
                <p className="preview-description">{formData.descrizione}</p>
              )}
              
              <div className="preview-details">
                {formData.tipo_prodotto && (
                  <div className="detail-item">
                    <span className="detail-label">Tipologia:</span>
                    <span className="detail-value">{formData.tipo_prodotto}</span>
                  </div>
                )}
                
                {selectedType !== 'kit_commerciale' && formData.prezzo_base && (
                  <div className="detail-item">
                    <span className="detail-label">Prezzo:</span>
                    <span className="detail-value">{formatCurrency(formData.prezzo_base)}</span>
                  </div>
                )}
                
                {formData.durata_mesi && (
                  <div className="detail-item">
                    <span className="detail-label">Durata:</span>
                    <span className="detail-value">{formData.durata_mesi} mesi</span>
                  </div>
                )}
                
                {formData.sla_default_hours && (
                  <div className="detail-item">
                    <span className="detail-label">SLA:</span>
                    <span className="detail-value">{formData.sla_default_hours}h</span>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Form Validation Summary */}
      {Object.keys(validationErrors).length > 0 && (
        <div className="validation-summary">
          <div className="summary-icon">⚠️</div>
          <div className="summary-content">
            <h4>Correggere i seguenti errori:</h4>
            <ul>
              {Object.entries(validationErrors).map(([field, error]) => (
                <li key={field}>{error}</li>
              ))}
            </ul>
          </div>
        </div>
      )}
    </div>
  );
};

export default ArticleConfiguration;
