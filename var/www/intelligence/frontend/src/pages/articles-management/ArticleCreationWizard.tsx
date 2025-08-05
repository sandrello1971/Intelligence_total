import './ArticleCreationWizard.css';
import React from 'react';
import { useAppDispatch, useAppSelector } from '../../store';
import {
  setWizardStep,
  nextWizardStep,
  prevWizardStep,
  createArticleOrKit,
} from '../../store/articlesSlice';
import WizardHeader from './components/WizardHeader';
import TypeSelection from './components/TypeSelection';
import ArticleConfiguration from './components/ArticleConfiguration';
import KitComposition from './components/KitComposition';
import CreationReview from './components/CreationReview';

interface ArticleCreationWizardProps {
  onComplete: () => void;
  onCancel: () => void;
}

const ArticleCreationWizard: React.FC<ArticleCreationWizardProps> = ({
  onComplete,
  onCancel,
}) => {
  const dispatch = useAppDispatch();
  const {
    wizardStep,
    selectedType,
    articleForm,
    kitComposition,
    loading,
  } = useAppSelector((state) => state.articles);
  
  const canProceed = () => {
    switch (wizardStep) {
      case 'type':
        return !!selectedType;
      case 'config':
        return !!(articleForm.codice && articleForm.nome);
      case 'kit-composition':
        return selectedType !== 'kit_commerciale' || kitComposition.selectedArticles.length > 0;
      case 'review':
        return true;
      default:
        return false;
    }
  };
  
  const handleNext = () => {
    if (wizardStep === 'config' && selectedType === 'semplice') {
      // Skip kit composition for simple articles
      dispatch(setWizardStep('review'));
    } else if (wizardStep === 'review') {
      // Create the article/kit
      dispatch(createArticleOrKit()).then(() => {
        onComplete();
      });
    } else {
      dispatch(nextWizardStep());
    }
  };
  
  const handlePrev = () => {
    if (wizardStep === 'review' && selectedType === 'semplice') {
      // Skip back to config for simple articles
      dispatch(setWizardStep('config'));
    } else {
      dispatch(prevWizardStep());
    }
  };
  
  const renderStepContent = () => {
    switch (wizardStep) {
      case 'type':
        return <TypeSelection />;
      case 'config':
        return <ArticleConfiguration />;
      case 'kit-composition':
        return <KitComposition />;
      case 'review':
        return <CreationReview />;
      default:
        return null;
    }
  };
  
  const shouldShowKitComposition = selectedType === 'kit_commerciale';
  const steps = shouldShowKitComposition 
    ? ['type', 'config', 'kit-composition', 'review']
    : ['type', 'config', 'review'];
  
  return (
    <div className="creation-wizard">
      <div className="wizard-container">
        <WizardHeader
          currentStep={wizardStep}
          steps={steps}
          selectedType={selectedType}
        />
        
        <div className="wizard-content">
          {renderStepContent()}
        </div>
        
        <div className="wizard-footer">
          <div className="footer-actions">
            <button
              className="btn btn-secondary"
              onClick={onCancel}
            >
              ❌ Annulla
            </button>
            
            <div className="navigation-buttons">
              {wizardStep !== 'type' && (
                <button
                  className="btn btn-outline"
                  onClick={handlePrev}
                  disabled={loading.creating}
                >
                  ← Indietro
                </button>
              )}
              
              <button
                className="btn btn-primary"
                onClick={handleNext}
                disabled={!canProceed() || loading.creating}
              >
                {loading.creating ? (
                  <>
                    <span className="loading-spinner small"></span>
                    Creazione...
                  </>
                ) : wizardStep === 'review' ? (
                  '✅ Crea'
                ) : (
                  'Avanti →'
                )}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ArticleCreationWizard;
