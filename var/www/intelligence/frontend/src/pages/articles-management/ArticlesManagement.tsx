import React, { useState, useEffect } from 'react';
import { useAppDispatch, useAppSelector } from '../../store';
import {
  fetchArticles,
  fetchKits,
  fetchTipologie,
  fetchPartners,
  resetWizard,
  updateFilters,
} from '../../store/articlesSlice';
import ArticleCreationWizard from './ArticleCreationWizard';
import ArticlesTable from './components/ArticlesTable';
import ArticlesStats from './components/ArticlesStats';
import ArticlesFilters from './components/ArticlesFilters';
import './ArticlesManagement.css';

const ArticlesManagement: React.FC = () => {
  const dispatch = useAppDispatch();
  const {
    articles,
    kits,
    tipologie,
    partners,
    loading,
    error,
    filters,
  } = useAppSelector((state) => state.articles);
  
  const [viewMode, setViewMode] = useState<'list' | 'create'>('list');
  
  useEffect(() => {
    // Load initial data
    dispatch(fetchArticles());
    dispatch(fetchKits());
    dispatch(fetchTipologie());
    dispatch(fetchPartners());
  }, [dispatch]);
  
  const handleCreateNew = () => {
    dispatch(resetWizard());
    setViewMode('create');
  };
  
  const handleCancelCreation = () => {
    dispatch(resetWizard());
    setViewMode('list');
  };
  
  const handleCreationComplete = () => {
    setViewMode('list');
    // Refresh data
    dispatch(fetchArticles());
    dispatch(fetchKits());
  };
  
  const combinedItems = [
    ...articles.map(article => ({ ...article, type: 'article' as const })),
    ...kits.map(kit => ({ ...kit, type: 'kit' as const })),
  ];
  
  const filteredItems = combinedItems.filter(item => {
    if (filters.search && !item.nome.toLowerCase().includes(filters.search.toLowerCase())) {
      return false;
    }
    if (filters.attivo !== null && item.attivo !== filters.attivo) {
      return false;
    }
    return true;
  });
  
  if (loading.articles || loading.kits) {
    return (
      <div className="articles-management loading">
        <div className="loading-spinner">
          <div className="spinner"></div>
          <p>Caricamento dati...</p>
        </div>
      </div>
    );
  }
  
  return (
    <div className="articles-management">
      {viewMode === 'list' ? (
        <>
          {/* Header */}
          <div className="articles-header">
            <div className="header-content">
              <div className="title-section">
                <h1>🛍️ Gestione Articoli e Kit</h1>
                <p>Crea e gestisci articoli singoli e kit commerciali</p>
              </div>
              <button
                className="btn btn-primary btn-create"
                onClick={handleCreateNew}
              >
                ➕ Crea Nuovo
              </button>
            </div>
          </div>
          
          {/* Stats */}
          <ArticlesStats
            articles={articles}
            kits={kits}
          />
          
          {/* Filters */}
          <ArticlesFilters
            filters={filters}
            tipologie={tipologie}
            partners={partners}
            onFiltersChange={(newFilters) => dispatch(updateFilters(newFilters))}
          />
          
          {/* Error Display */}
          {error && (
            <div className="error-banner">
              <span className="error-icon">⚠️</span>
              <span>{error}</span>
              <button onClick={() => dispatch({ type: 'articles/clearError' })}>
                ✕
              </button>
            </div>
          )}
          
          {/* Table */}
          <ArticlesTable
            items={filteredItems}
            tipologie={tipologie}
            partners={partners}
            onEdit={(item) => console.log('Edit:', item)}
            onDelete={(item) => console.log('Delete:', item)}
          />
        </>
      ) : (
        <ArticleCreationWizard
          onComplete={handleCreationComplete}
          onCancel={handleCancelCreation}
        />
      )}
    </div>
  );
};

export default ArticlesManagement;
