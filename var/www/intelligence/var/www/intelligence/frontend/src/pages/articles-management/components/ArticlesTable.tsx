import React, { useState } from 'react';

interface BaseItem {
  id: number;
  nome: string;
  descrizione?: string;
  attivo: boolean;
  created_at?: string;
  type: 'article' | 'kit';
}

interface Article extends BaseItem {
  type: 'article';
  codice: string;
  tipo_prodotto?: string;
  prezzo_base?: number;
}

interface Kit extends BaseItem {
  type: 'kit';
  articolo_principale_id?: number;
  articoli?: any[];
  articoli_count?: number;
}

interface ArticlesTableProps {
  items: (Article | Kit)[];
  tipologie: any[];
  partners: any[];
  onEdit: (item: Article | Kit) => void;
  onDelete: (item: Article | Kit) => void;
}

const ArticlesTable: React.FC<ArticlesTableProps> = ({
  items,
  tipologie,
  partners,
  onEdit,
  onDelete,
}) => {
  const [sortField, setSortField] = useState<string>('nome');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('asc');
  const [selectedItems, setSelectedItems] = useState<number[]>([]);

  const handleSort = (field: string) => {
    if (sortField === field) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortField(field);
      setSortDirection('asc');
    }
  };

  const sortedItems = [...items].sort((a, b) => {
    let aValue = a[sortField as keyof BaseItem];
    let bValue = b[sortField as keyof BaseItem];
    
    if (typeof aValue === 'string') aValue = aValue.toLowerCase();
    if (typeof bValue === 'string') bValue = bValue.toLowerCase();
    
    if (aValue < bValue) return sortDirection === 'asc' ? -1 : 1;
    if (aValue > bValue) return sortDirection === 'asc' ? 1 : -1;
    return 0;
  });

  const toggleSelectItem = (id: number) => {
    setSelectedItems(prev => 
      prev.includes(id) 
        ? prev.filter(itemId => itemId !== id)
        : [...prev, id]
    );
  };

  const toggleSelectAll = () => {
    setSelectedItems(
      selectedItems.length === items.length 
        ? [] 
        : items.map(item => item.id)
    );
  };

  const getTypeIcon = (item: Article | Kit) => {
    return item.type === 'article' ? '📄' : '📦';
  };

  const getTypeLabel = (item: Article | Kit) => {
    if (item.type === 'article') {
      return (item as Article).tipo_prodotto || 'Articolo';
    }
    return 'Kit Commerciale';
  };

  return (
    <div className="articles-table-container">
      {/* Bulk Actions */}
      {selectedItems.length > 0 && (
        <div className="bulk-actions">
          <span className="selection-count">
            {selectedItems.length} elementi selezionati
          </span>
          <button className="btn btn-sm btn-outline">
            📋 Duplica
          </button>
          <button className="btn btn-sm btn-outline">
            🔄 Cambia Stato
          </button>
          <button className="btn btn-sm btn-danger">
            🗑️ Elimina Selezionati
          </button>
        </div>
      )}

      {/* Table */}
      <div className="table-wrapper">
        <table className="articles-table">
          <thead>
            <tr>
              <th className="select-column">
                <input
                  type="checkbox"
                  checked={selectedItems.length === items.length && items.length > 0}
                  onChange={toggleSelectAll}
                />
              </th>
              <th 
                className={`sortable ${sortField === 'type' ? `sorted-${sortDirection}` : ''}`}
                onClick={() => handleSort('type')}
              >
                Tipo
              </th>
              <th 
                className={`sortable ${sortField === 'nome' ? `sorted-${sortDirection}` : ''}`}
                onClick={() => handleSort('nome')}
              >
                Nome
              </th>
              <th>Dettagli</th>
              <th 
                className={`sortable ${sortField === 'attivo' ? `sorted-${sortDirection}` : ''}`}
                onClick={() => handleSort('attivo')}
              >
                Stato
              </th>
              <th>Azioni</th>
            </tr>
          </thead>
          <tbody>
            {sortedItems.map((item) => (
              <tr 
                key={`${item.type}-${item.id}`}
                className={`table-row ${selectedItems.includes(item.id) ? 'selected' : ''}`}
              >
                {/* Select */}
                <td>
                  <input
                    type="checkbox"
                    checked={selectedItems.includes(item.id)}
                    onChange={() => toggleSelectItem(item.id)}
                  />
                </td>

                {/* Type */}
                <td className="type-cell">
                  <div className="type-indicator">
                    <span className="type-icon">{getTypeIcon(item)}</span>
                    <span className="type-label">{getTypeLabel(item)}</span>
                  </div>
                </td>

                {/* Name */}
                <td className="name-cell">
                  <div className="item-name">
                    <strong>{item.nome}</strong>
                    {item.descrizione && (
                      <p className="item-description">{item.descrizione}</p>
                    )}
                  </div>
                </td>

                {/* Details */}
                <td className="details-cell">
                  {item.type === 'article' ? (
                    <div className="article-details">
                      <span className="detail-item">
                        🏷️ {(item as Article).codice}
                      </span>
                      {(item as Article).prezzo_base && (
                        <span className="detail-item">
                          💰 €{(item as Article).prezzo_base}
                        </span>
                      )}
                    </div>
                  ) : (
                    <div className="kit-details">
                      <span className="detail-item">
                        📦 {(item as Kit).articoli_count || 0} articoli
                      </span>
                    </div>
                  )}
                </td>

                {/* Status */}
                <td className="status-cell">
                  <span className={`status-badge ${item.attivo ? 'active' : 'inactive'}`}>
                    {item.attivo ? '✅ Attivo' : '❌ Inattivo'}
                  </span>
                </td>

                {/* Actions */}
                <td className="actions-cell">
                  <div className="action-buttons">
                    <button
                      className="btn btn-sm btn-outline"
                      onClick={() => onEdit(item)}
                      title="Modifica"
                    >
                      ✏️
                    </button>
                    <button
                      className="btn btn-sm btn-outline"
                      onClick={() => console.log('View details:', item)}
                      title="Dettagli"
                    >
                      👁️
                    </button>
                    <button
                      className="btn btn-sm btn-danger"
                      onClick={() => onDelete(item)}
                      title="Elimina"
                    >
                      🗑️
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {/* Empty State */}
        {items.length === 0 && (
          <div className="empty-state">
            <div className="empty-icon">📭</div>
            <h3>Nessun elemento trovato</h3>
            <p>Non ci sono articoli o kit che corrispondono ai filtri selezionati.</p>
            <button className="btn btn-primary">
              ➕ Crea il primo elemento
            </button>
          </div>
        )}
      </div>

      {/* Table Footer */}
      <div className="table-footer">
        <div className="table-info">
          Mostrando {sortedItems.length} di {items.length} elementi
        </div>
        <div className="table-pagination">
          {/* Pagination controls can be added here */}
        </div>
      </div>
    </div>
  );
};

export default ArticlesTable;
