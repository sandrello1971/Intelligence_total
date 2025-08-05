import React from 'react';
import { useAppDispatch, useAppSelector } from '../../../store';
import { setSelectedType } from '../../../store/articlesSlice';

const TypeSelection: React.FC = () => {
  const dispatch = useAppDispatch();
  const { selectedType } = useAppSelector((state) => state.articles);
  
  const handleTypeSelect = (type: 'semplice' | 'kit_commerciale') => {
    dispatch(setSelectedType(type));
  };
  
  return (
    <div className="type-selection">
      <div className="step-header">
        <h2>🎯 Seleziona il tipo di articolo</h2>
        <p>Scegli se creare un articolo singolo o un kit commerciale</p>
      </div>
      
      <div className="type-cards">
        <div
          className={`type-card ${selectedType === 'semplice' ? 'selected' : ''}`}
          onClick={() => handleTypeSelect('semplice')}
        >
          <div className="card-icon">📄</div>
          <h3>Articolo Semplice</h3>
          <p>Un singolo prodotto o servizio</p>
          <div className="card-features">
            <div className="feature">✅ Configurazione rapida</div>
            <div className="feature">✅ Prezzo e durata definiti</div>
            <div className="feature">✅ Associazione partner</div>
          </div>
        </div>
        
        <div
          className={`type-card ${selectedType === 'kit_commerciale' ? 'selected' : ''}`}
          onClick={() => handleTypeSelect('kit_commerciale')}
        >
          <div className="card-icon">📦</div>
          <h3>Kit Commerciale</h3>
          <p>Un insieme di articoli raggruppati</p>
          <div className="card-features">
            <div className="feature">✅ Più articoli inclusi</div>
            <div className="feature">✅ Articoli opzionali/obbligatori</div>
            <div className="feature">✅ Ordinamento personalizzabile</div>
            <div className="feature">✅ Partner per articolo</div>
          </div>
        </div>
      </div>
      
      {selectedType && (
        <div className="selection-summary">
          <div className="summary-content">
            <span className="summary-icon">
              {selectedType === 'semplice' ? '📄' : '
</span>
           <span className="summary-text">
             Hai selezionato: <strong>
               {selectedType === 'semplice' ? 'Articolo Semplice' : 'Kit Commerciale'}
             </strong>
           </span>
         </div>
       </div>
     )}
   </div>
 );
};

export default TypeSelection;
📦'}
           </span>
           <span className="summary-text">
             Hai selezionato: <strong>
               {selectedType === 'semplice' ? 'Articolo Semplice' : 'Kit Commerciale'}
             </strong>
           </span>
         </div>
       </div>
     )}
   </div>
 );
};

export default TypeSelection;
