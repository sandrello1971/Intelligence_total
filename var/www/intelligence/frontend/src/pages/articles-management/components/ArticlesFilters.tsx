import React from 'react';

interface TipologiaServizio {
  id: number;
  nome: string;
  icona: string;
  attivo: boolean;
}

interface Partner {
  id: number;
  nome: string;
  attivo: boolean;
}

interface ArticlesFiltersProps {
  filters: {
    search: string;
    tipologia: number | null;
    partner: number | null;
    attivo: boolean | null;
  };
  tipologie: TipologiaServizio[];
  partners: Partner[];
  onFiltersChange: (filters: any) => void;
}

const ArticlesFilters: React.FC<ArticlesFiltersProps> = ({
  filters,
  tipologie,
  partners,
  onFiltersChange,
}) => {
  const handleFilterChange = (field: string, value: any) => {
    onFiltersChange({ [field]: value });
  };
  
  const clearAllFilters = () => {
    onFiltersChange({
      search: '',
      tipologia: null,
      partner: null,
      attivo: null,
    });
  };
  
  const hasActiveFilters = filters.search || filters.tipologia || filters.partner || filters.attivo !== null;
  
  return (
    <div className="articles-filters">
      <div className="filters-header">
        <h3>🔍 Filtri e Ricerca</h3>
        {hasActiveFilters && (
          <button className="btn-clear-filters" onClick={clearAllFilters}>
            🗑️ Pulisci filtri
          </button>
        )}
      </div>
      
      <div className="filters-grid">
        {/* Search */}
        <div className="filter-group search">
          <input
            type="text"
            placeholder="🔍 Cerca per nome, codice o descrizione..."
            value={filters.search}
            onChange={(e) => handleFilterChange('search', e.target.value)}
            className="filter-input search-input"
          />
        </div>
        
        {/* Status Filter */}
        <div className="filter-group">
          <label>Stato</label>
          <select
            value={filters.attivo === null ? '' : filters.attivo.toString()}
            onChange={(e) => handleFilterChange('attivo', 
              e.target.value === '' ? null : e.target.value === 'true')}
            className="filter-select"
          >
            <option value="">Tutti gli stati</option>
            <option value="true">✅ Solo attivi</option>
            <option value="false">❌ Solo inattivi</option>
          </select>
        </div>
        
        {/* Tipologia Filter */}
        <div className="filter-group">
          <label>Tipologia</label>
          <select
            value={filters.tipologia || ''}
            onChange={(e) => handleFilterChange('tipologia', 
              e.target.value ? parseInt(e.target.value) : null)}
            className="filter-select"
          >
            <option value="">Tutte le tipologie</option>
            {tipologie.filter(t => t.attivo).map(tipologia => (
              <option key={tipologia.id} value={tipologia.id}>
                {tipologia.icona} {tipologia.nome}
              </option>
            ))}
          </select>
        </div>
        
        {/* Partner Filter */}
        <div className="filter-group">
          <label>Partner</label>
          <select
            value={filters.partner || ''}
            onChange={(e) => handleFilterChange('partner', 
              e.target.value ? parseInt(e.target.value) : null)}
            className="filter-select"
          >
            <option value="">Tutti i partner</option>
            {partners.filter(p => p.attivo).map(partner => (
              <option key={partner.id} value={partner.id}>
                🤝 {partner.nome}
              </option>
            ))}
          </select>
        </div>
      </div>
      
      {/* Active Filters Display */}
      {hasActiveFilters && (
        <div className="active-filters">
          <span className="active-filters-label">Filtri attivi:</span>
          
          {filters.search && (
            <span className="filter-tag">
              🔍 "{filters.search}"
              <button onClick={() => handleFilterChange('search', '')}>×</button>
            </span>
          )}
          
          {filters.attivo !== null && (
            <span className="filter-tag">
              {filters.attivo ? '✅ Attivi' : '❌ Inattivi'}
              <button onClick={() => handleFilterChange('attivo', null)}>×</button>
            </span>
          )}
          
          {filters.tipologia && (
            <span className="filter-tag">
              {tipologie.find(t => t.id === filters.tipologia)?.icona} {tipologie.find(t => t.id === filters.tipologia)?.nome}
              <button onClick={() => handleFilterChange('tipologia', null)}>×</button>
            </span>
          )}
          
          {filters.partner && (
            <span className="filter-tag">
              🤝 {partners.find(p => p.id === filters.partner)?.nome}
              <button onClick={() => handleFilterChange('partner', null)}>×</button>
            </span>
          )}
        </div>
      )}
    </div>
  );
};

export default ArticlesFilters;
