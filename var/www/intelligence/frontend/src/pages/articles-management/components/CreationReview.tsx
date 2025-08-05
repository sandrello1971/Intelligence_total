import React from 'react';
import { useAppSelector } from '../../../store';

const CreationReview: React.FC = () => {
 const { 
   selectedType, 
   articleForm, 
   kitComposition, 
   articles, 
   tipologie, 
   partners 
 } = useAppSelector((state) => state.articles);
 
 const selectedArticlesWithDetails = kitComposition.selectedArticles
   .map(articleId => {
     const article = articles.find(a => a.id === articleId);
     const config = kitComposition.articlesConfig[articleId];
     return article ? { article, config } : null;
   })
   .filter(Boolean)
   .sort((a, b) => (a!.config.ordine || 0) - (b!.config.ordine || 0));
 
 const getTipologiaById = (id?: number) => {
   return tipologie.find(t => t.id === id);
 };
 
 const getPartnerById = (id?: number) => {
   return partners.find(p => p.id === id);
 };
 
 const calculateKitTotal = () => {
   return selectedArticlesWithDetails.reduce((sum, item) => {
     const articlePrice = item!.article.prezzo_base || 0;
     const quantity = item!.config.quantita || 1;
     return sum + (articlePrice * quantity);
   }, 0);
 };
 
 const tipologia = getTipologiaById(articleForm.tipologia_servizio_id);
 const partner = getPartnerById(articleForm.partner_id);
 
 return (
   <div className="creation-review">
     <div className="step-header">
       <h2>👀 Riepilogo e Conferma</h2>
       <p>Verifica tutti i dati prima di creare {selectedType === 'semplice' ? "l'articolo" : 'il kit commerciale'}</p>
     </div>
     
     <div className="review-content">
       {/* Main Article/Kit Info */}
       <div className="review-section">
         <div className="section-header">
           <h3>
             {selectedType === 'semplice' ? '📄 Articolo' : '📦 Kit Commerciale'}
           </h3>
           <span className="type-badge">
             {selectedType === 'semplice' ? 'Semplice' : 'Composito'}
           </span>
         </div>
         
         <div className="info-grid">
           <div className="info-row">
             <span className="label">Codice:</span>
             <span className="value code">{articleForm.codice}</span>
           </div>
           <div className="info-row">
             <span className="label">Nome:</span>
             <span className="value">{articleForm.nome}</span>
           </div>
           {articleForm.descrizione && (
             <div className="info-row full">
               <span className="label">Descrizione:</span>
               <span className="value description">{articleForm.descrizione}</span>
             </div>
           )}
           {tipologia && (
             <div className="info-row">
               <span className="label">Tipologia:</span>
               <span className="value tipologia" style={{ color: tipologia.colore }}>
                 {tipologia.icona} {tipologia.nome}
               </span>
             </div>
           )}
           {partner && (
             <div className="info-row">
               <span className="label">Partner:</span>
               <span className="value">🤝 {partner.nome}</span>
             </div>
           )}
           {articleForm.prezzo_base && (
             <div className="info-row">
               <span className="label">Prezzo base:</span>
               <span className="value price">€{articleForm.prezzo_base}</span>
             </div>
           )}
           {articleForm.durata_mesi && (
             <div className="info-row">
               <span className="label">Durata:</span>
               <span className="value">{articleForm.durata_mesi} mesi</span>
             </div>
           )}
         </div>
       </div>
       
       {/* Kit Composition (only for kits) */}
       {selectedType === 'kit_commerciale' && selectedArticlesWithDetails.length > 0 && (
         <div className="review-section">
           <div className="section-header">
             <h3>🧩 Composizione Kit</h3>
             <span className="count-badge">
               {selectedArticlesWithDetails.length} articoli
             </span>
           </div>
           
           <div className="kit-articles-list">
             {selectedArticlesWithDetails.map((item, index) => {
               const { article, config } = item!;
               const articleTipologia = getTipologiaById(article.tipologia_servizio_id);
               const articlePartner = getPartnerById(config.partner_id || article.partner_id);
               
               return (
                 <div key={article.id} className="kit-article-item">
                   <div className="item-header">
                     <div className="item-order">#{index + 1}</div>
                     <div className="item-info">
                       <span className="item-code">{article.codice}</span>
                       <span className="item-name">{article.nome}</span>
                     </div>
                     <div className="item-badges">
                       {config.obbligatorio && (
                         <span className="badge required">Obbligatorio</span>
                       )}
                       {config.quantita > 1 && (
                         <span className="badge quantity">Qty: {config.quantita}</span>
                       )}
                     </div>
                   </div>
                   
                   <div className="item-details">
                     {articleTipologia && (
                       <div className="detail-item">
                         <span className="detail-label">Tipologia:</span>
                         <span className="detail-value" style={{ color: articleTipologia.colore }}>
                           {articleTipologia.icona} {articleTipologia.nome}
                         </span>
                       </div>
                     )}
                     
                     {articlePartner && (
                       <div className="detail-item">
                         <span className="detail-label">Partner:</span>
                         <span className="detail-value">🤝 {articlePartner.nome}</span>
                       </div>
                     )}
                     
                     {article.prezzo_base && (
                       <div className="detail-item">
                         <span className="detail-label">Prezzo:</span>
                         <span className="detail-value price">
                           €{article.prezzo_base}
                           {config.quantita > 1 && (
                             <> x {config.quantita} = €{(article.prezzo_base * config.quantita).toFixed(2)}</>
                           )}
                         </span>
                       </div>
                     )}
                     
                     {config.note && (
                       <div className="detail-item full">
                         <span className="detail-label">Note:</span>
                         <span className="detail-value note">{config.note}</span>
                       </div>
                     )}
                   </div>
                 </div>
               );
             })}
           </div>
           
           {/* Kit Summary */}
           <div className="kit-summary-review">
             <div className="summary-grid">
               <div className="summary-item">
                 <span className="summary-label">Articoli totali:</span>
                 <span className="summary-value">{selectedArticlesWithDetails.length}</span>
               </div>
               <div className="summary-item">
                 <span className="summary-label">Obbligatori:</span>
                 <span className="summary-value">
                   {selectedArticlesWithDetails.filter(item => item!.config.obbligatorio).length}
                 </span>
               </div>
               <div className="summary-item">
                 <span className="summary-label">Opzionali:</span>
                 <span className="summary-value">
                   {selectedArticlesWithDetails.filter(item => !item!.config.obbligatorio).length}
                 </span>
               </div>
               {calculateKitTotal() >
0 && (
                 <div className="summary-item total">
                   <span className="summary-label">Prezzo totale stimato:</span>
                   <span className="summary-value price">€{calculateKitTotal().toFixed(2)}</span>
                 </div>
               )}
             </div>
           </div>
         </div>
       )}
       
       {/* Actions Summary */}
       <div className="review-section">
         <div className="section-header">
           <h3>⚡ Azioni che verranno eseguite</h3>
         </div>
         
         <div className="actions-list">
           <div className="action-item">
             <span className="action-icon">📄</span>
             <span className="action-text">
               Creazione articolo "<strong>{articleForm.nome}</strong>" con codice "<strong>{articleForm.codice}</strong>"
             </span>
           </div>
           
           {selectedType === 'kit_commerciale' && (
             <>
               <div className="action-item">
                 <span className="action-icon">📦</span>
                 <span className="action-text">
                   Creazione kit commerciale collegato all'articolo principale
                 </span>
               </div>
               
               {selectedArticlesWithDetails.map((item, index) => (
                 <div key={item!.article.id} className="action-item sub-action">
                   <span className="action-icon">🔗</span>
                   <span className="action-text">
                     Aggiunta articolo "<strong>{item!.article.nome}</strong>" al kit
                     {item!.config.quantita > 1 && <> (quantità: {item!.config.quantita})</>}
                     {item!.config.obbligatorio && <> come <strong>obbligatorio</strong></>}
                   </span>
                 </div>
               ))}
             </>
           )}
         </div>
       </div>
       
       {/* Warning/Info Messages */}
       <div className="review-messages">
         {selectedType === 'kit_commerciale' && selectedArticlesWithDetails.length === 0 && (
           <div className="message warning">
             <span className="message-icon">⚠️</span>
             <span className="message-text">
               Attenzione: Stai creando un kit senza articoli inclusi. 
               Potrai aggiungerli successivamente dalla gestione kit.
             </span>
           </div>
         )}
         
         {selectedType === 'kit_commerciale' && 
          selectedArticlesWithDetails.every(item => !item!.config.obbligatorio) && 
          selectedArticlesWithDetails.length > 0 && (
           <div className="message info">
             <span className="message-icon">ℹ️</span>
             <span className="message-text">
               Tutti gli articoli del kit sono opzionali. 
               I clienti potranno scegliere liberamente quali includere.
             </span>
           </div>
         )}
         
         {!articleForm.prezzo_base && (
           <div className="message info">
             <span className="message-icon">💰</span>
             <span className="message-text">
               Nessun prezzo base impostato. 
               Potrai definirlo successivamente nella gestione prezzi.
             </span>
           </div>
         )}
       </div>
     </div>
   </div>
 );
};

export default CreationReview;
