import React, { useState, useMemo } from 'react';
import { useAppDispatch, useAppSelector } from '../../../store';
import { 
 toggleArticleSelection, 
 updateKitArticleConfig,
 reorderKitArticles 
} from '../../../store/articlesSlice';

const KitComposition: React.FC = () => {
 const dispatch = useAppDispatch();
 const { 
   articles, 
   kitComposition, 
   tipologie, 
   partners,
   articleForm 
 } = useAppSelector((state) => state.articles);
 
 const [searchTerm, setSearchTerm] = useState('');
 const [tipologiaFilter, setTipologiaFilter] = useState<number | null>(null);
 const [partnerFilter, setPartnerFilter] = useState<number | null>(null);
 
 // Filtered available articles
 const availableArticles = useMemo(() => {
   return articles.filter(article => {
     // Don't show inactive articles
     if (!article.attivo) return false;
     
     // Search filter
     if (searchTerm && !article.nome.toLowerCase().includes(searchTerm.toLowerCase()) &&
         !article.codice.toLowerCase().includes(searchTerm.toLowerCase())) {
       return false;
     }
     
     // Tipologia filter
     if (tipologiaFilter && article.tipologia_servizio_id !== tipologiaFilter) {
       return false;
     }
     
     // Partner filter
     if (partnerFilter && article.partner_id !== partnerFilter) {
       return false;
     }
     
     return true;
   });
 }, [articles, searchTerm, tipologiaFilter, partnerFilter]);
 
 // Selected articles with details
 const selectedArticlesWithDetails = useMemo(() => {
   return kitComposition.selectedArticles
     .map(articleId => {
       const article = articles.find(a => a.id === articleId);
       const config = kitComposition.articlesConfig[articleId];
       return article ? { article, config } : null;
     })
     .filter(Boolean)
     .sort((a, b) => (a!.config.ordine || 0) - (b!.config.ordine || 0));
 }, [kitComposition.selectedArticles, kitComposition.articlesConfig, articles]);
 
 const handleArticleToggle = (articleId: number) => {
   dispatch(toggleArticleSelection(articleId));
 };
 
 const handleConfigUpdate = (articleId: number, field: string, value: any) => {
   dispatch(updateKitArticleConfig({
     articleId,
     config: { [field]: value }
   }));
 };
 
 const moveArticle = (articleId: number, direction: 'up' | 'down') => {
   const currentIndex = kitComposition.selectedArticles.indexOf(articleId);
   if (currentIndex === -1) return;
   
   const newIndex = direction === 'up' ? currentIndex - 1 : currentIndex + 1;
   if (newIndex < 0 || newIndex >= kitComposition.selectedArticles.length) return;
   
   const newOrder = [...kitComposition.selectedArticles];
   [newOrder[currentIndex], newOrder[newIndex]] = [newOrder[newIndex], newOrder[currentIndex]];
   
   dispatch(reorderKitArticles(newOrder));
 };
 
 const getTipologiaById = (id?: number) => {
   return tipologie.find(t => t.id === id);
 };
 
 const getPartnerById = (id?: number) => {
   return partners.find(p => p.id === id);
 };
 
 const calculateKitTotals = () => {
   const totalPrice = selectedArticlesWithDetails.reduce((sum, item) => {
     const articlePrice = item!.article.prezzo_base || 0;
     const quantity = item!.config.quantita || 1;
     return sum + (articlePrice * quantity);
   }, 0);
   
   const totalArticles = selectedArticlesWithDetails.length;
   const obligatoryCount = selectedArticlesWithDetails.filter(item => item!.config.obbligatorio).length;
   
   return { totalPrice, totalArticles, obligatoryCount };
 };
 
 const { totalPrice, totalArticles, obligatoryCount } = calculateKitTotals();
 
 return (
   <div className="kit-composition">
     <div className="step-header">
       <h2>🧩 Composizione Kit: {articleForm.nome}</h2>
       <p>Seleziona e configura gli articoli che faranno parte del kit commerciale</p>
     </div>
     
     <div className="composition-layout">
       {/* Left Panel: Available Articles */}
       <div className="available-articles-panel">
         <div className="panel-header">
           <h3>📋 Articoli Disponibili</h3>
           <span className="articles-count">{availableArticles.length} articoli</span>
         </div>
         
         {/* Filters */}
         <div className="articles-filters">
           <div className="filter-group">
             <input
               type="text"
               placeholder="🔍 Cerca articoli..."
               value={searchTerm}
               onChange={(e) => setSearchTerm(e.target.value)}
               className="filter-input"
             />
           </div>
           
           <div className="filter-row">
             <select
               value={tipologiaFilter || ''}
               onChange={(e) => setTipologiaFilter(e.target.value ? parseInt(e.target.value) : null)}
               className="filter-select"
             >
               <option value="">Tutte le tipologie</option>
               {tipologie.map(tip => (
                 <option key={tip.id} value={tip.id}>
                   {tip.icona} {tip.nome}
                 </option>
               ))}
             </select>
             
             <select
               value={partnerFilter || ''}
               onChange={(e) => setPartnerFilter(e.target.value ? parseInt(e.target.value) : null)}
               className="filter-select"
             >
               <option value="">Tutti i partner</option>
               {partners.filter(p => p.attivo).map(partner => (
                 <option key={partner.id} value={partner.id}>
                   {partner.nome}
                 </option>
               ))}
             </select>
           </div>
         </div>
         
         {/* Articles List */}
         <div className="articles-list">
           {availableArticles.map(article => {
             const isSelected = kitComposition.selectedArticles.includes(article.id);
             const tipologia = getTipologiaById(article.tipologia_servizio_id);
             const partner = getPartnerById(article.partner_id);
             
             return (
               <div
                 key={article.id}
                 className={`article-card ${isSelected ? 'selected' : ''}`}
                 onClick={() => handleArticleToggle(article.id)}
               >
                 <div className="article-header">
                   <div className="article-info">
                     <span className="article-code">{article.codice}</span>
                     <span className="article-name">{article.nome}</span>
                   </div>
                   <div className="selection-indicator">
                     {isSelected ? '✅' : '⚪'}
                   </div>
                 </div>
                 
                 {article.descrizione && (
                   <p className="article-description">{article.descrizione}</p>
                 )}
                 
                 <div className="article-meta">
                   {tipologia && (
                     <span className="meta-tag tipologia" style={{ color: tipologia.colore }}>
                       {tipologia.icona} {tipologia.nome}
                     </span>
                   )}
                   {partner && (
                     <span className="meta-tag partner">
                       🤝 {partner.nome}
                     </span>
                   )}
                   {article.prezzo_base && (
                     <span className="meta-tag price">
                       💰 €{article.prezzo_base}
                     </span>
                   )}
                 </div>
               </div>
             );
           })}
           
           {availableArticles.length === 0 && (
             <div className="empty-state">
               <div className="empty-icon">📭</div>
               <p>Nessun articolo trovato</p>
               <small>Modifica i filtri per vedere più risultati</small>
             </div>
           )}
         </div>
       </div>
       
       {/* Right Panel: Selected Articles Configuration */}
       <div className="selected-articles-panel">
         <div className="panel-header">
           <h3>📦 Articoli nel Kit</h3>
           <div className="kit-stats">
             <span className="stat">{totalArticles} articoli</span>
             <span className="stat">{obligatoryCount} obbligatori</span>
             {totalPrice > 0 && <span className="stat">€{totalPrice.toFixed(2)}</span>}
           </div>
         </div>
         
         {selectedArticlesWithDetails.length > 0 ? (
           <div className="selected-articles-list">
             {selectedArticlesWithDetails.map((item, index) => {
               const { article, config } = item!;
               const tipologia = getTipologiaById(article.tipologia_servizio_id);
               
               return (
                 <div key={article.id} className="selected-article-card">
                   <div className="article-header">
                     <div className="article-info">
                       <span className="article-code">{article.codice}</span>
                       <span className="article-name">{article.nome}</span>
                     </div>
                     
                     <div className="article-actions">
                       <button
                         className="btn-icon"
                         onClick={() => moveArticle(article.id, 'up')}
                         disabled={index === 0}
                         title="Sposta su"
                       >
                         ⬆️
                       </button>
                       <button
                         className="btn-icon"
                         onClick={() => moveArticle(article.id, 'down')}
                         disabled={index === selectedArticlesWithDetails.length - 1}
                         title="Sposta giù"
                       >
                         ⬇️
                       </button>
                       <button
                         className="btn-icon remove"
                         onClick={() => handleArticleToggle(article.id)}
                         title="Rimuovi dal kit"
                       >
                         🗑️
                       </button>
                     </div>
                   </div>
                   
                   {tipologia && (
                     <div className="article-tipologia">
                       <span style={{ color: tipologia.colore }}>
                         {tipologia.icona} {tipologia.nome}
                       </span>
                     </div>
                   )}
                   
                   <div className="article-config">
                     <div className="config-row">
                       <div className="config-field">
                         <label>Quantità</label>
                         <input
                           type="number"
                           min="1"
                           max="99"
                           value={config.quantita}
                           onChange={(e) => handleConfigUpdate(
                             article.id, 
                             'quantita', 
                             parseInt(e.target.value) || 1
                           )}
                           className="config-input small"
                         />
                       </div>
                       
                       <div className="config-field">
                         <label className="checkbox-label">
                           <input
                             type="checkbox"
                             checked={config.obbligatorio}
                             onChange={(e) => handleConfigUpdate(
                               article.id, 
                               'obbligatorio', 
                               e.target.checked
                             )}
                           />
                           <span className="checkbox-text">Obbligatorio</span>
                         </label>
                       </div>
                     </div>
                     
                     <div className="config-row">
                       <div className="config-field full">
                         <label>Partner Specifico</label>
                         <select
                           value={config.partner_id || ''}
                           onChange={(e) => handleConfigUpdate(
                             article.id, 
                             'partner_id', 
                             e.target.value ? parseInt(e.target.value) : undefined
                           )}
                           className="config-select"
                         >
                           <option value="">Usa partner principale</option>
                           {partners.filter(p => p.attivo).map(partner => (
                             <option key={partner.id} value={partner.id}>
                               {partner.nome}
                             </option>
                           ))}
                         </select>
                       </div>
                     </div>
                     
                     <div className="config-row">
                       <div className="config-field full">
                         <label>Note</label>
                         <textarea
                           value={config.note || ''}
                           onChange={(e) => handleConfigUpdate(
                             article.id, 
                             'note', 
                             e.target.value
                           )}
                           placeholder="Note specifiche per questo articolo nel kit..."
                           className="config-textarea"
                           rows={2}
                         />
                       </div>
                     </div>
                     
                     {article.prezzo_base && (
                       <div className="article-pricing">
                         <span className="price-label">Prezzo unitario:</span>
                         <span className="price-value">€{article.prezzo_base}</span>
                         {config.quantita > 1 && (
                           <>
                             <span className="price-calc">x {config.quantita} =</span>
                             <span className="price-total">€{(article.prezzo_base * config.quantita).toFixed(2)}</span>
                           </>
                         )}
                       </div>
                     )}
                   </div>
                 </div>
               );
             })}
           </div>
         ) : (
           <div className="empty-selection">
             <div className="empty-icon">📦</div>
             <h4>Nessun articolo selezionato</h4>
             <p>Clicca sugli articoli a sinistra per aggiungerli al kit</p>
           </div>
         )}
         
         {/* Kit Summary */}
         {selectedArticlesWithDetails.length > 0 && (
           <div className="kit-summary">
             <h4>📊 Riepilogo Kit</h4>
             <div className="summary-stats">
               <div className="summary-row">
                 <span>Articoli totali:</span>
                 <span className="value">{totalArticles}</span>
               </div>
               <div className="summary-row">
                 <span>Articoli obbligatori:</span>
                 <span className="value">{obligatoryCount}</span>
               </div>
               <div className="summary-row">
                 <span>Articoli opzionali:</span>
                 <span className="value">{totalArticles - obligatoryCount}</span>
               </div>
               {totalPrice > 0 && (
                 <div className="summary-row total">
                   <span>Prezzo totale stimato:</span>
                   <span className="value price">€{totalPrice.toFixed(2)}</span>
                 </div>
               )}
             </div>
           </div>
         )}
       </div>
     </div>
   </div>
 );
};

export default KitComposition;
