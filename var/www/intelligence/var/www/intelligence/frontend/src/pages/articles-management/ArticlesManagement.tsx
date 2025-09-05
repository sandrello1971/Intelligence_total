import React, { useEffect, useState } from 'react';
import ArticlesTable from './components/ArticlesTable';
import EditArticleModal from '../../components/articles/EditArticleModal';
import CreateArticleModal from '../../components/articles/CreateArticleModal';
import {
  fetchArticles,
  fetchTipologieServizi,
  fetchPartners,
  fetchAvailableUsers,
  fetchTicketTemplates
} from '../../api/articles-api'; // Adatta se serve

import { ArticleFormData, TipologiaServizio, Partner, User, ModelloTicket } from '../../components/articles/types';

const ArticlesManagement: React.FC = () => {
  const [items, setItems] = useState<ArticleFormData[]>([]);
  const [tipologie, setTipologie] = useState<TipologiaServizio[]>([]);
  const [partners, setPartners] = useState<Partner[]>([]);
  const [availableUsers, setAvailableUsers] = useState<User[]>([]);
  const [modelliTicket, setModelliTicket] = useState<ModelloTicket[]>([]);

  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [selectedItem, setSelectedItem] = useState<ArticleFormData | null>(null);

  const loadData = async () => {
    try {
      const [articles, tipi, partnerList, users, ticketTemplates] = await Promise.all([
        fetchArticles(),
        fetchTipologieServizi(),
        fetchPartners(),
        fetchAvailableUsers(),
        fetchTicketTemplates()
      ]);
      setItems(articles);
      setTipologie(tipi);
      setPartners(partnerList);
      setAvailableUsers(users);
      setModelliTicket(ticketTemplates);
    } catch (error) {
      console.error('Errore nel fetch dati iniziali:', error);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleEdit = (item: ArticleFormData) => {
    setSelectedItem(item);
    setShowEditModal(true);
  };

  const handleDelete = async (item: ArticleFormData) => {
    if (confirm(`Sei sicuro di voler eliminare "${item.nome}"?`)) {
      // await deleteArticle(item.id);
      setItems(prev => prev.filter(i => i.id !== item.id));
    }
  };

  const handleUpdateArticle = async () => {
    if (selectedItem) {
      // await updateArticle(selectedItem.id, selectedItem);
      setShowEditModal(false);
      loadData();
    }
  };

  const handleCreateArticle = async (newItem: ArticleFormData) => {
    // await createArticle(newItem);
    setShowCreateModal(false);
    loadData();
  };

  return (
    <div className="articles-management-page">
      <div className="header">
        <h1>📦 Gestione Articoli e Kit</h1>
        <button className="btn btn-primary" onClick={() => setShowCreateModal(true)}>
          ➕ Nuovo Articolo
        </button>
      </div>

      <ArticlesTable
        items={items}
        tipologie={tipologie}
        partners={partners}
        onEdit={handleEdit}
        onDelete={handleDelete}
      />

      {showEditModal && selectedItem && (
        <EditArticleModal
          show={showEditModal}
          onClose={() => setShowEditModal(false)}
          onSubmit={handleUpdateArticle}
          formData={selectedItem}
          setFormData={setSelectedItem}
          tipologie={tipologie}
          partnerFiltrati={partners}
          availableUsers={availableUsers}
          modelliTicket={modelliTicket}
        />
      )}

      {showCreateModal && (
        <CreateArticleModal
          show={showCreateModal}
          onClose={() => setShowCreateModal(false)}
          onSubmit={handleCreateArticle}
          tipologie={tipologie}
          partnerFiltrati={partners}
          availableUsers={availableUsers}
          modelliTicket={modelliTicket}
        />
      )}
    </div>
  );
};

export default ArticlesManagement;
