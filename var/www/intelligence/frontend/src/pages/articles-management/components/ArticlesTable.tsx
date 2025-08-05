import React from 'react';

interface TipologiaServizio {
  id: number;
  nome: string;
  icona: string;
  colore: string;
}

interface Partner {
  id: number;
  nome: string;
}

interface TableItem {
  id: number;
  codice?: string;
  nome: string;
  descrizione?: string;
  attivo: boolean;
  tipo_prodotto?: 'semplice' | 'composito';
  tipologia_servizio_id?: number;
  partner_id?: number;
  prezzo_base?: number;
  durata_mesi?: number;
  created_at: string;
  type: 'article' | 'kit';
  articoli_inclusi?: any[];
}

interface ArticlesTableProps {
  items: TableItem[];
  tipologie: TipologiaServizio[];
  partners: Partner[];
  onEdit: (item: TableItem) => void;
  onDelete: (item: TableItem) => void;
}

const ArticlesTable: React.FC<ArticlesTableProps> = ({
  items,
  tipologie,
  partners,
  onEdit,
  onDelete,
}) => {
  const getTipologiaById = (id?: number) => {
    return tipologie.find(t => t.id === id);
  };
  
  const getPartnerById = (id?: number) => {
    return partners.find(p => p.id === id);
  };
  
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('it-IT', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    });
  };
  
  const handleDelete = (item: TableItem) => {
    const itemType = item.type === 'article' ? 'articolo' : 'kit commerciale';
    const message = `Sei sicuro di voler eliminare ${itemType} "${item.nome}"?`;
    
    if (window.confirm(message)) {
      onDelete(item);
    }
  };
  
  if (items.length === 0) {
    return (
      <div className="articles-table-container">
        <div className="empty-state">
          <div className="empty-icon">📋</div>
          <h3>Nessun elemento trovato</h3>
          <p>Non ci sono articoli o kit che corrispondono ai filtri selezionati</p>
        </div>
      </div>
    );
  }
  
  return (
    <div className="articles-table-container">
      <div className="table-header">
        <h3>📋 Articoli e Kit ({items.length})</h3>
        <div className="table-controls">
          <button className="btn-export">
            📤 Esporta
          </button>
        </div>
      </div>
      
      <div className="table-wrapper">
        <table className="articles-table">
          <thead>
            <tr>
              <th>Tipo</th>
              <th>Codice</th>
              <th>Nome</th>
              <th>Tipologia</th>
              <th>Partner</th>
              <th>Prezzo</th>
              <th>Durata</th>
              <th>Stato</th>
              <th>Creato</th>
              <th>Azioni</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item) => {
              const tipologia = getTipologiaById(item.tipologia_servizio_id);
              const partner = getPartnerById(item.partner_id);
              
              return (
                <tr key={`${item.type}-${item.id}`} className={`table-row ${!item.attivo ? 'inactive' : ''}`}>
                  <td>
                    <div className="type-cell">
                      <span className="type-icon">
                        {item.type === 'article' 
                          ? (item.tipo_prodotto === 'composito' ? '📦' : '📄')
                          : '📦'}
                      </span>
                      <span className="type-text">
                        {item.type === 'article' 
                          ? (item.tipo_prodotto === 'composito' ? 'Kit' : 'Articolo')
                          : 'Kit'}
                      </span>
                      {item.type === 'kit' && item.articoli_inclusi && (
                        <span className="articles-count">
                          {item.articoli_inclusi.length} art.
                        </span>
                      )}
                    </div>
                  </td>
                  
                  <td>
                    <span className="code">{item.codice || '---'}</span>
                  </td>
                  
                  <td>
                    <div className="name-cell">
                      <span className="name">{item.nome}</span>
                      {item.descrizione && (
                        <span className="description" title={item.descrizione}>
                          {item.descrizione.length > 50 
                            ? `${item.descrizione.substring(0, 50)}...` 
                            : item.descrizione}
                        </span>
                      )}
                    </div>
                  </td>
                  
                  <td>
                    {tipologia ? (
                      <span 
                        className="tipologia-tag"
                        style={{ 
                          backgroundColor: `${tipologia.colore}20`,
                          color: tipologia.colore,
                          border: `1px solid ${tipologia.colore}40`
                        }}
                      >
                        {tipologia.icona} {tipologia.nome}
                      </span>
                    ) : (
                      <span className="no-data">---</span>
                    )}
                  </td>
                  
                  <td>
                    {partner ? (
                      <span className="partner-tag">
                        🤝 {partner.nome}
                      </span>
                    ) : (
                      <span className="no-data">---</span>
                    )}
                  </td>
                  
                  <td>
                    {item.prezzo_base ? (
                      <span className="price">€{item.prezzo_base.toFixed(2)}</span>
                    ) : (
                      <span className="no-data">---</span>
                    )}
                  </td>
                  
                  <td>
                    {item.durata_mesi ? (
                      <span className="duration">{item.durata_mesi} mesi</span>
                    ) : (
                      <span className="no-data">---</span>
                    )}
                  </td>
                  
                  <td>
                    <span className={`status-badge ${item.attivo ? 'active' : 'inactive'}`}>
                      {item.attivo ? '✅ Attivo' : '❌ Inattivo'}
                    </span>
                  </td>
                  
                  <td>
                    <span className="date">{formatDate(item.created_at)}</span>
                  </td>
                  
                  <td>
                    <div className="actions">
                      <button
                        className="btn-action edit"
                        onClick={() => onEdit(item)}
                        title="Modifica"
                      >
                        ✏️
                      </button>
                      <button
                        className="btn-action delete"
                        onClick={() => handleDelete(item)}
                        title="Elimina"
                      >
                        🗑️
                      </button>
                      <button
                        className="btn-action view"
                        title="Visualizza dettagli"
                      >
                        👁️
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ArticlesTable;
