import React from 'react';
import { useAppDispatch, useAppSelector } from '../../../store';
import { updateArticleForm } from '../../../store/articlesSlice';

const ArticleConfiguration: React.FC = () => {
 const dispatch = useAppDispatch();
 const { 
   articleForm, 
   selectedType, 
   tipologie, 
   partners 
 } = useAppSelector((state) => state.articles);
 
 const handleInputChange = (field: string, value: any) => {
   dispatch(updateArticleForm({ [field]: value }));
 };
 
 return (
   <div className="article-configuration">
     <div className="step-header">
       <h2>⚙️ Configurazione {selectedType === 'semplice' ? 'Articolo' : 'Kit'}</h2>
       <p>Inserisci i dati principali per {selectedType === 'semplice' ? "l'articolo" : 'il kit commerciale'}</p>
     </div>
     
     <div className="config-form">
       <div className="form-grid">
         {/* Codice e Nome */}
         <div className="form-row">
           <div className="form-group">
             <label className="required">Codice *</label>
             <input
               type="text"
               value={articleForm.codice}
               onChange={(e) => handleInputChange('codice', e.target.value)}
               placeholder="es. ART001"
               className="form-input"
             />
             <small className="form-hint">Codice identificativo univoco</small>
           </div>
           
           <div className="form-group">
             <label className="required">Nome *</label>
             <input
               type="text"
               value={articleForm.nome}
               onChange={(e) => handleInputChange('nome', e.target.value)}
               placeholder={selectedType === 'semplice' ? 'es. Consulenza Marketing' : 'es. Kit Digital Marketing'}
               className="form-input"
             />
             <small className="form-hint">Nome commerciale del {selectedType === 'semplice' ? 'servizio' : 'kit'}</small>
           </div>
         </div>
         
         {/* Descrizione */}
         <div className="form-group full-width">
           <label>Descrizione</label>
           <textarea
             value={articleForm.descrizione}
             onChange={(e) => handleInputChange('descrizione', e.target.value)}
             placeholder={selectedType === 'semplice' 
               ? 'Descrizione dettagliata del servizio...' 
               : 'Descrizione del kit e dei servizi inclusi...'}
             className="form-textarea"
             rows={3}
           />
         </div>
         
         {/* Tipologia e Partner */}
         <div className="form-row">
           <div className="form-group">
             <label>Tipologia Servizio</label>
             <select
               value={articleForm.tipologia_servizio_id || ''}
               onChange={(e) => handleInputChange('tipologia_servizio_id', 
                 e.target.value ? parseInt(e.target.value) : undefined)}
               className="form-select"
             >
               <option value="">Seleziona tipologia...</option>
               {tipologie.map(tip => (
                 <option key={tip.id} value={tip.id}>
                   {tip.icona} {tip.nome}
                 </option>
               ))}
             </select>
           </div>
           
           <div className="form-group">
             <label>Partner Principale</label>
             <select
               value={articleForm.partner_id || ''}
               onChange={(e) => handleInputChange('partner_id', 
                 e.target.value ? parseInt(e.target.value) : undefined)}
               className="form-select"
             >
               <option value="">Nessun partner...</option>
               {partners.filter(p => p.attivo).map(partner => (
                 <option key={partner.id} value={partner.id}>
                   {partner.nome}
                 </option>
               ))}
             </select>
           </div>
         </div>
         
         {/* Prezzo e Durata */}
         <div className="form-row">
           <div className="form-group">
             <label>Prezzo Base (€)</label>
             <input
               type="number"
               step="0.01"
               min="0"
               value={articleForm.prezzo_base || ''}
               onChange={(e) => handleInputChange('prezzo_base', 
                 e.target.value ? parseFloat(e.target.value) : undefined)}
               placeholder="0.00"
               className="form-input"
             />
             <small className="form-hint">Prezzo base in euro</small>
           </div>
           
           <div className="form-group">
             <label>Durata (mesi)</label>
             <input
               type="number"
               min="1"
               value={articleForm.durata_mesi || ''}
               onChange={(e) => handleInputChange('durata_mesi', 
                 e.target.value ? parseInt(e.target.value) : undefined)}
               placeholder="12"
               className="form-input"
             />
             <small className="form-hint">Durata prevista in mesi</small>
           </div>
         </div>
       </div>
       
       {/* Preview Card */}
       <div className="config-preview">
         <h4>📋 Anteprima</h4>
         <div className="preview-card">
           <div className="preview-header">
             <span className="preview-code">{articleForm.codice || 'CODICE'}</span>
             <span className="preview-type">
               {selectedType === 'semplice' ? '📄 Articolo' : '📦 Kit'}
             </span>
           </div>
           <h5>{articleForm.nome || 'Nome articolo'}</h5>
           <p>{articleForm.descrizione || 'Descrizione non inserita'}</p>
           <div className="preview-details">
             {articleForm.prezzo_base && (
               <span className="preview-price">💰 €{articleForm.prezzo_base}</span>
             )}
             {articleForm.durata_mesi && (
               <span className="preview-duration">⏱️ {articleForm.durata_mesi} mesi</span>
             )}
           </div>
         </div>
       </div>
     </div>
   </div>
 );
};

export default ArticleConfiguration;
