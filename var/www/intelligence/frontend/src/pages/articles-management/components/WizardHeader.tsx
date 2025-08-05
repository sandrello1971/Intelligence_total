import React from 'react';

interface WizardHeaderProps {
  currentStep: string;
  steps: string[];
  selectedType?: string;
}

const WizardHeader: React.FC<WizardHeaderProps> = ({
  currentStep,
  steps,
  selectedType,
}) => {
  const stepConfig = {
    type: {
      title: 'Tipo di Elemento',
      description: 'Scegli se creare un articolo singolo o un kit commerciale',
      icon: '🎯'
    },
    config: {
      title: 'Configurazione',
      description: 'Imposta i dettagli principali dell\'elemento',
      icon: '⚙️'
    },
    'kit-composition': {
      title: 'Composizione Kit',
      description: 'Seleziona e organizza gli articoli nel kit',
      icon: '📦'
    },
    review: {
      title: 'Revisione',
      description: 'Controlla e conferma la creazione',
      icon: '✅'
    }
  };

  const getCurrentStepIndex = () => {
    return steps.indexOf(currentStep);
  };

  const getStepStatus = (step: string, index: number) => {
    const currentIndex = getCurrentStepIndex();
    
    if (index < currentIndex) return 'completed';
    if (index === currentIndex) return 'active';
    return 'pending';
  };

  const getTypeIcon = () => {
    if (!selectedType) return '❓';
    switch (selectedType) {
      case 'semplice':
        return '📄';
      case 'kit_commerciale':
        return '📦';
      case 'composito':
        return '🔧';
      default:
        return '❓';
    }
  };

  const getTypeLabel = () => {
    if (!selectedType) return 'Non selezionato';
    switch (selectedType) {
      case 'semplice':
        return 'Articolo Semplice';
      case 'kit_commerciale':
        return 'Kit Commerciale';
      case 'composito':
        return 'Articolo Composito';
      default:
        return selectedType;
    }
  };

  return (
    <div className="wizard-header">
      {/* Header Info */}
      <div className="wizard-info">
        <div className="wizard-title">
          <h1>
            <span className="title-icon">✨</span>
            Creazione Nuovo Elemento
          </h1>
          {selectedType && (
            <div className="selected-type">
              <span className="type-icon">{getTypeIcon()}</span>
              <span className="type-label">{getTypeLabel()}</span>
            </div>
          )}
        </div>
        
        <div className="current-step-info">
          <div className="step-main">
            <span className="step-icon">{stepConfig[currentStep as keyof typeof stepConfig]?.icon || '❓'}</span>
            <div className="step-details">
              <h2 className="step-title">
                {stepConfig[currentStep as keyof typeof stepConfig]?.title || 'Step'}
              </h2>
              <p className="step-description">
                {stepConfig[currentStep as keyof typeof stepConfig]?.description || ''}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Progress Bar */}
      <div className="wizard-progress">
        <div className="progress-container">
          {steps.map((step, index) => {
            const status = getStepStatus(step, index);
            const config = stepConfig[step as keyof typeof stepConfig];
            
            return (
              <div
                key={step}
                className={`progress-step ${status}`}
              >
                {/* Step Circle */}
                <div className="step-circle">
                  {status === 'completed' ? (
                    <span className="step-check">✓</span>
                  ) : (
                    <span className="step-number">{index + 1}</span>
                  )}
                </div>

                {/* Step Label */}
                <div className="step-label">
                  <div className="step-name">{config?.title || step}</div>
                  {status === 'active' && (
                    <div className="step-status">In corso...</div>
                  )}
                </div>

                {/* Connector Line */}
                {index < steps.length - 1 && (
                  <div className={`step-connector ${index < getCurrentStepIndex() ? 'completed' : ''}`}>
                    <div className="connector-line"></div>
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {/* Progress Percentage */}
        <div className="progress-summary">
          <div className="progress-text">
            Progresso: {getCurrentStepIndex() + 1} di {steps.length} step completati
          </div>
          <div className="progress-bar">
            <div 
              className="progress-fill"
              style={{ 
                width: `${((getCurrentStepIndex() + 1) / steps.length) * 100}%` 
              }}
            ></div>
          </div>
          <div className="progress-percentage">
            {Math.round(((getCurrentStepIndex() + 1) / steps.length) * 100)}%
          </div>
        </div>
      </div>

      {/* Navigation Breadcrumb */}
      <div className="wizard-breadcrumb">
        <div className="breadcrumb-items">
          <span className="breadcrumb-item">🏠 Dashboard</span>
          <span className="breadcrumb-separator">›</span>
          <span className="breadcrumb-item">📦 Gestione Articoli</span>
          <span className="breadcrumb-separator">›</span>
          <span className="breadcrumb-item active">✨ Creazione Elemento</span>
        </div>

        {/* Quick Actions */}
        <div className="header-actions">
          <button className="btn btn-sm btn-outline" title="Salva come bozza">
            💾 Salva Bozza
          </button>
          <button className="btn btn-sm btn-outline" title="Guida">
            ❓ Guida
          </button>
        </div>
      </div>

      {/* Step Tips */}
      {currentStep && (
        <div className="step-tips">
          <div className="tip-icon">💡</div>
          <div className="tip-content">
            {currentStep === 'type' && (
              <div>
                <strong>Suggerimento:</strong> Gli articoli semplici sono ideali per servizi singoli, 
                mentre i kit commerciali permettono di raggruppare più servizi con sconti e offerte speciali.
              </div>
            )}
            {currentStep === 'config' && (
              <div>
                <strong>Suggerimento:</strong> Assicurati di inserire un codice univoco e una descrizione chiara. 
                Questi dati saranno visibili ai clienti e utilizzati per la fatturazione.
              </div>
            )}
            {currentStep === 'kit-composition' && (
              <div>
                <strong>Suggerimento:</strong> Puoi trascinare gli articoli per riordinarli. 
                Gli articoli obbligatori saranno sempre inclusi, quelli opzionali possono essere scelti dal cliente.
              </div>
            )}
            {currentStep === 'review' && (
              <div>
                <strong>Suggerimento:</strong> Controlla attentamente tutti i dettagli prima di creare l'elemento. 
                Potrai sempre modificarlo successivamente dalla gestione articoli.
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default WizardHeader;
