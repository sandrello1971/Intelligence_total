import React, { useState } from 'react';

interface Filters {
  search: string;
  attivo: boolean | null;
  tipo_prodotto: string;
  tipo_elemento: 'all' | 'articles' | 'kits';
  prezzo_min: number | null;
  prezzo_max: number | null;
  data_creazione_da: string;
  data_creazione_a: string;
}

interface ArticlesFiltersProps {
  filters: Filters;
  tipologie: any[];
  partners: any[];
  onFiltersChange: (filters: Partial<Filters>) => void;
}

const ArticlesFilters: React.FC<ArticlesFiltersProps> = ({
  filters,
  tipologie,
  partners,
  onFiltersChange,
}) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [tempFilters, setTempFilters] = useState(filters);

  const handleInputChange = (field: keyof Filters, value: any) => {
    const newFilters = { ...tempFilters, [field]: value };
    setTempFilters(newFilters);
    onFiltersChange({ [field]: value });
  };

  const handleApplyFilters = () => {
    onFiltersChange(tempFilters);
    setIsExpanded(false);
  };

  const handleResetFilters = () => {
    const resetFilters: Filters = {
      search: '',
      attivo: null,
      tipo_prodotto: '',
      tipo_elemento: 'all',
      prezzo_min: null,
      prezzo_max: null,
      data_creazione_da: '',
      data_creazione_a: '',
    };
    setTempFilters(resetFilters);
    onFiltersChange(resetFilters);
  };

  const getActiveFiltersCount = () => {
    let count = 0;
    if (filters.search) count++;
    if (filters.attivo !== null) count++;
    if (filters.tipo_prodotto) count++;
    if (filters.tipo_elemento !== 'all') count++;
    if (filters.prezzo_min !== null) count++;
    if (filters.prezzo_max !== null) count++;
    if (filters.data_creazione_da) count++;
    if (filters.data_creazione_a) count++;
    return count;
  };

  const activeFiltersCount = getActiveFiltersCount();

  return (
    <div className="articles-filters">
      {/* Main Filter Bar */}
      <div className="filters-main">
        <div className="filters-left">
          {/* Search */}
          <div className="filter-group search-group">
            <div className="search-input-wrapper">
              <input
                type="text"
                placeholder="🔍 Cerca articoli o kit..."
                value={filters.search}
                onChange={(e) => handleInputChange('search', e.target.value)}
                className="search-input"
              />
              {filters.search && (
                <button
                  className="clear-search"
                  onClick={() => handleInputChange('search', '')}
                >
                  ✕
                </button>
              )}
            </div>
          </div>

          {/* Quick Filters */}
          <div className="filter-group quick-filters">
            <select
              value={filters.tipo_elemento}
              onChange={(e) => handleInputChange('tipo_elemento', e.target.value)}
              className="filter-select"
            >
              <option value="all">🔍 Tutti</option>
              <option value="articles">📄 Solo Articoli</option>
              <option value="kits">📦 Solo Kit</option>
            </select>
          </div>

          <div className="filter-group">
            <select
              value={filters.attivo === null ? '' : filters.attivo.toString()}
              onChange={(e) => handleInputChange('attivo', e.target.value === '' ? null : e.target.value === 'true')}
              className="filter-select"
            >
              <option value="">🔄 Tutti gli stati</option>
              <option value="true">✅ Solo Attivi</option>
              <option value="false">❌ Solo Inattivi</option>
            </select>
          </div>
        </div>

        <div className="filters-right">
          {/* Advanced Filters Toggle */}
          <button
            className={`btn btn-outline filters-toggle ${isExpanded ? 'active' : ''}`}
            onClick={() => setIsExpanded(!isExpanded)}
          >
            ⚙️ Filtri Avanzati
            {activeFiltersCount > 0 && (
              <span className="filters-badge">{activeFiltersCount}</span>
            )}
          </button>

          {/* Reset Filters */}
          {activeFiltersCount > 0 && (
            <button
              className="btn btn-outline btn-reset"
              onClick={handleResetFilters}
            >
              🔄 Reset
            </button>
          )}
        </div>
      </div>

      {/* Advanced Filters Panel */}
      {isExpanded && (
        <div className="filters-advanced">
          <div className="advanced-header">
            <h3>⚙️ Filtri Avanzati</h3>
            <button
              className="close-advanced"
              onClick={() => setIsExpanded(false)}
            >
              ✕
            </button>
          </div>

          <div className="advanced-content">
            <div className="filters-row">
              {/* Product Type */}
              <div className="filter-group">
                <label className="filter-label">Tipologia Prodotto</label>
                <select
                  value={tempFilters.tipo_prodotto}
                  onChange={(e) => setTempFilters(prev => ({ ...prev, tipo_prodotto: e.target.value }))}
                  className="filter-select"
                >
                  <option value="">Tutte le tipologie</option>
                  {(tipologie || []).map((tipo) => (
                    <option key={tipo.id} value={tipo.nome}>
                      {tipo.nome}
                    </option>
                  ))}
                </select>
              </div>

              {/* Price Range */}
              <div className="filter-group">
                <label className="filter-label">Fascia di Prezzo</label>
                <div className="price-range">
                  <input
                    type="number"
                    placeholder="Min €"
                    value={tempFilters.prezzo_min || ''}
                    onChange={(e) => setTempFilters(prev => ({ 
                      ...prev, 
                      prezzo_min: e.target.value ? parseFloat(e.target.value) : null 
                    }))}
                    className="price-input"
                  />
                  <span className="price-separator">-</span>
                  <input
                    type="number"
                    placeholder="Max €"
                    value={tempFilters.prezzo_max || ''}
                    onChange={(e) => setTempFilters(prev => ({ 
                      ...prev, 
                      prezzo_max: e.target.value ? parseFloat(e.target.value) : null 
                    }))}
                    className="price-input"
                  />
                </div>
              </div>

              {/* Date Range */}
              <div className="filter-group">
                <label className="filter-label">Data Creazione</label>
                <div className="date-range">
                  <input
                    type="date"
                    value={tempFilters.data_creazione_da}
                    onChange={(e) => setTempFilters(prev => ({ ...prev, data_creazione_da: e.target.value }))}
                    className="date-input"
                  />
                  <span className="date-separator">-</span>
                  <input
                    type="date"
                    value={tempFilters.data_creazione_a}
                    onChange={(e) => setTempFilters(prev => ({ ...prev, data_creazione_a: e.target.value }))}
                    className="date-input"
                  />
                </div>
              </div>
            </div>

            {/* Saved Filters */}
            <div className="saved-filters">
              <label className="filter-label">Filtri Salvati</label>
              <div className="saved-filters-list">
                <button className="saved-filter-btn">
                  💾 Articoli Attivi Alto Valore
                </button>
                <button className="saved-filter-btn">
                  💾 Kit Commerciali Completi
                </button>
                <button className="saved-filter-btn">
                  💾 Prodotti Creati Questo Mese
                </button>
                <button className="saved-filter-btn btn-outline">
                  ➕ Salva Filtro Corrente
                </button>
              </div>
            </div>

            {/* Advanced Actions */}
            <div className="advanced-actions">
              <button
                className="btn btn-secondary"
                onClick={handleResetFilters}
              >
                🔄 Reset Tutto
              </button>
              <button
                className="btn btn-primary"
                onClick={handleApplyFilters}
              >
                ✅ Applica Filtri
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Active Filters Summary */}
      {activeFiltersCount > 0 && (
        <div className="active-filters-summary">
          <div className="summary-header">
            <span className="summary-title">
              🏷️ Filtri Attivi ({activeFiltersCount})
            </span>
          </div>
          <div className="active-filters-list">
            {filters.search && (
              <div className="active-filter">
                <span className="filter-type">Ricerca:</span>
                <span className="filter-value">"{filters.search}"</span>
                <button onClick={() => handleInputChange('search', '')}>✕</button>
              </div>
            )}
            {filters.attivo !== null && (
              <div className="active-filter">
                <span className="filter-type">Stato:</span>
                <span className="filter-value">{filters.attivo ? 'Attivo' : 'Inattivo'}</span>
                <button onClick={() => handleInputChange('attivo', null)}>✕</button>
              </div>
            )}
            {filters.tipo_elemento !== 'all' && (
              <div className="active-filter">
                <span className="filter-type">Tipo:</span>
                <span className="filter-value">
                  {filters.tipo_elemento === 'articles' ? 'Articoli' : 'Kit'}
                </span>
                <button onClick={() => handleInputChange('tipo_elemento', 'all')}>✕</button>
              </div>
            )}
            {filters.tipo_prodotto && (
              <div className="active-filter">
                <span className="filter-type">Tipologia:</span>
                <span className="filter-value">{filters.tipo_prodotto}</span>
                <button onClick={() => handleInputChange('tipo_prodotto', '')}>✕</button>
              </div>
            )}
            {(filters.prezzo_min !== null || filters.prezzo_max !== null) && (
              <div className="active-filter">
                <span className="filter-type">Prezzo:</span>
                <span className="filter-value">
                  €{filters.prezzo_min || 0} - €{filters.prezzo_max || '∞'}
                </span>
                <button onClick={() => {
                  handleInputChange('prezzo_min', null);
                  handleInputChange('prezzo_max', null);
                }}>✕</button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default ArticlesFilters;
