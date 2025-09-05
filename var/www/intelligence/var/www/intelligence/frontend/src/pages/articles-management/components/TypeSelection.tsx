import React from 'react';
import { useAppDispatch, useAppSelector } from '../../../store';
import { setSelectedType } from '../../../store/articlesSlice';

const TypeSelection: React.FC = () => {
  const dispatch = useAppDispatch();
  const { selectedType } = useAppSelector((state) => state.articles);

  const typeOptions = [
    {
      id: 'semplice',
      title: 'Articolo Semplice',
      description: 'Un singolo servizio o prodotto con prezzo fisso',
      icon: '📄',
      features: [
        'Gestione semplice e veloce',
        'Prezzo fisso configurabile',
        'Template milestone predefiniti',
        'SLA personalizzabili'
      ],
      bestFor: 'Servizi standard, consulenze singole, prodotti semplici',
      examples: ['Consulenza SEO', 'Setup WordPress', 'Analisi competitor'],
      color: 'blue'
    },
    {
      id: 'kit_commerciale',
      title: 'Kit Commerciale',
      description: 'Pacchetto di più articoli con prezzi e condizioni speciali',
      icon: '📦',
      features: [
        'Raggruppa più servizi',
        'Prezzi scontati o bundle',
        'Articoli obbligatori e opzionali',
        'Gestione partner e commissioni'
      ],
      bestFor: 'Pacchetti promozionali, offerte complete, bundle di servizi',
      examples: ['Pacchetto Digital Marketing', 'Suite Completa SEO', 'Startup Package'],
      color: 'green'
    },
    {
      id: 'composito',
      title: 'Articolo Composito',
      description: 'Servizio complesso composto da sub-servizi configurabili',
      icon: '🔧',
      features: [
        'Configurazione avanzata',
        'Sub-servizi personalizzabili',
        'Workflow complessi',
        'Automazioni integrate'
      ],
      bestFor: 'Servizi enterprise, progetti complessi, soluzioni personalizzate',
      examples: ['Trasformazione Digitale', 'Piattaforma E-commerce Custom', 'Sistema CRM'],
      color: 'purple'
    }
  ];

  const handleTypeSelect = (typeId: string) => {
    dispatch(setSelectedType(typeId));
  };

  const getSelectionClass = (typeId: string) => {
    return `type-option ${selectedType === typeId ? 'selected' : ''}`;
  };

  return (
    <div className="type-selection">
      <div className="selection-header">
        <h2>🎯 Che tipo di elemento vuoi creare?</h2>
        <p>Scegli il tipo più adatto alle tue esigenze. Potrai sempre cambiare la configurazione successivamente.</p>
      </div>

      <div className="type-options">
        {typeOptions.map((option) => (
          <div
            key={option.id}
            className={`${getSelectionClass(option.id)} type-${option.color}`}
            onClick={() => handleTypeSelect(option.id)}
          >
            {/* Header */}
            <div className="option-header">
              <div className="option-icon">{option.icon}</div>
              <div className="option-title">
                <h3>{option.title}</h3>
                <p>{option.description}</p>
              </div>
              <div className="option-selector">
                <div className="radio-button">
                  {selectedType === option.id && <div className="radio-dot"></div>}
                </div>
              </div>
            </div>

            {/* Features */}
            <div className="option-features">
              <h4>✨ Caratteristiche principali:</h4>
              <ul>
                {option.features.map((feature, index) => (
                  <li key={index}>
                    <span className="feature-check">✓</span>
                    {feature}
                  </li>
                ))}
              </ul>
            </div>

            {/* Best For */}
            <div className="option-best-for">
              <h4>🎯 Ideale per:</h4>
              <p>{option.bestFor}</p>
            </div>

            {/* Examples */}
            <div className="option-examples">
              <h4>💡 Esempi:</h4>
              <div className="examples-list">
                {option.examples.map((example, index) => (
                  <span key={index} className="example-tag">
                    {example}
                  </span>
                ))}
              </div>
            </div>

            {/* Selection Overlay */}
            {selectedType === option.id && (
              <div className="selection-overlay">
                <div className="selection-badge">
                  <span className="badge-icon">✓</span>
                  <span className="badge-text">Selezionato</span>
                </div>
              </div>
            )}
          </div>
        ))}
      </div>

      {/* Comparison Table */}
      <div className="type-comparison">
        <h3>📊 Confronto Rapido</h3>
        <div className="comparison-table">
          <table>
            <thead>
              <tr>
                <th>Caratteristica</th>
                <th>📄 Semplice</th>
                <th>📦 Kit</th>
                <th>🔧 Composito</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Facilità di creazione</td>
                <td className="rating high">🟢 Alta</td>
                <td className="rating medium">🟡 Media</td>
                <td className="rating low">🔴 Bassa</td>
              </tr>
              <tr>
                <td>Flessibilità prezzi</td>
                <td className="rating low">🔴 Bassa</td>
                <td className="rating high">🟢 Alta</td>
                <td className="rating high">🟢 Alta</td>
              </tr>
              <tr>
                <td>Gestione complessa</td>
                <td className="rating low">🔴 Minima</td>
                <td className="rating medium">🟡 Media</td>
                <td className="rating high">🟢 Massima</td>
              </tr>
              <tr>
                <td>Automazioni</td>
                <td className="rating medium">🟡 Base</td>
                <td className="rating medium">🟡 Avanzate</td>
                <td className="rating high">🟢 Complete</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      {/* Help Section */}
      <div className="type-help">
        <div className="help-card">
          <div className="help-icon">❓</div>
          <div className="help-content">
            <h4>Non sei sicuro della scelta?</h4>
            <p>
              Inizia con un <strong>Articolo Semplice</strong> se stai creando il tuo primo elemento. 
              Potrai sempre convertirlo in un Kit o Composito successivamente.
            </p>
            <button className="btn btn-sm btn-outline">
              📚 Guida Dettagliata
            </button>
          </div>
        </div>

        <div className="help-stats">
          <h4>📈 Statistiche utilizzo:</h4>
          <div className="usage-stats">
            <div className="stat-item">
              <span className="stat-icon">📄</span>
              <span className="stat-label">Semplici</span>
              <span className="stat-value">65%</span>
            </div>
            <div className="stat-item">
              <span className="stat-icon">📦</span>
              <span className="stat-label">Kit</span>
              <span className="stat-value">25%</span>
            </div>
            <div className="stat-item">
              <span className="stat-icon">🔧</span>
              <span className="stat-label">Compositi</span>
              <span className="stat-value">10%</span>
            </div>
          </div>
        </div>
      </div>

      {/* Selection Summary */}
      {selectedType && (
        <div className="selection-summary">
          <div className="summary-content">
            <div className="summary-icon">
              {typeOptions.find(t => t.id === selectedType)?.icon}
            </div>
            <div className="summary-text">
              <strong>Tipo selezionato:</strong> {typeOptions.find(t => t.id === selectedType)?.title}
            </div>
            <button 
              className="btn btn-sm btn-outline"
              onClick={() => dispatch(setSelectedType(''))}
            >
              🔄 Cambia
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default TypeSelection;
