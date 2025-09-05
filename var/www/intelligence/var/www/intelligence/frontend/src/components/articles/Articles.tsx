import React, { useState, useEffect } from 'react';
import './Articles.css';
import ArticleRow from './ArticleRow';
import CreateArticleModal from './CreateArticleModal';
import EditArticleModal from './EditArticleModal';

import {
  getArticles,
  createArticle,
  updateArticle,
  deleteArticle,
  toggleArticleStatus,
  getTipologieServizi,
  getPartner,
  getAvailableUsers,
  getModelliTicket,
} from '../../services/articlesApi';

import {
  ArticleFormData,
  Article,
  TipologiaServizio,
  Partner,
  ModelloTicket,
  User,
} from './types';

const Articles: React.FC = () => {
  const [articles, setArticles] = useState<Article[]>([]);
  const [tipologie, setTipologie] = useState<TipologiaServizio[]>([]);
  const [partner, setPartner] = useState<Partner[]>([]);
  const [partnerFiltrati, setPartnerFiltrati] = useState<Partner[]>([]);
  const [availableUsers, setAvailableUsers] = useState<User[]>([]);
  const [modelliTicket, setModelliTicket] = useState<ModelloTicket[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showEditModal, setShowEditModal] = useState(false);
  const [editingArticle, setEditingArticle] = useState<Article | null>(null);

  const [formData, setFormData] = useState<ArticleFormData>({
    codice: '',
    nome: '',
    descrizione: '',
    tipo_prodotto: 'semplice',
  });

  const fetchAllArticles = async (search = '') => {
    try {
      const results = await getArticles(search);
      setArticles(results);
    } catch (err) {
      console.error('Errore fetch articoli', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchInitialData = async () => {
    try {
      const [tipologie, partner, users, modelli] = await Promise.all([
        getTipologieServizi(),
        getPartner(),
        getAvailableUsers(),
        getModelliTicket(),
      ]);
      setTipologie(tipologie);
      setPartner(partner);
      setAvailableUsers(users);
      setModelliTicket(modelli);
    } catch (err) {
      console.error('Errore nel fetch iniziale:', err);
    }
  };

  const createNewArticle = async () => {
    try {
      await createArticle(formData);
      setShowCreateModal(false);
      setFormData({
        codice: '',
        nome: '',
        descrizione: '',
        tipo_prodotto: 'semplice',
        responsabile_user_id: '',
      });
      fetchAllArticles(searchTerm);
      alert('✅ Articolo creato con successo');
    } catch (err) {
      console.error(err);
      alert('❌ Errore durante la creazione');
    }
  };

  const updateExistingArticle = async () => {
    if (!editingArticle) return;
    try {
      await updateArticle(editingArticle.id, formData);
      setShowEditModal(false);
      setEditingArticle(null);
      fetchAllArticles(searchTerm);
      alert('✅ Articolo aggiornato con successo');
    } catch (err) {
      console.error(err);
      alert('❌ Errore durante aggiornamento');
    }
  };

  const deleteExistingArticle = async (article: Article) => {
    if (!window.confirm(`Confermi eliminazione di ${article.nome}?`)) return;
    try {
      await deleteArticle(article.id);
      fetchAllArticles(searchTerm);
      alert('✅ Articolo eliminato');
    } catch (err) {
      console.error(err);
      alert('❌ Errore durante eliminazione');
    }
  };

  const toggleStatus = async (article: Article) => {
    try {
      await toggleArticleStatus(article);
      fetchAllArticles(searchTerm);
    } catch (err) {
      console.error(err);
      alert('❌ Errore durante cambio stato');
    }
  };

  const openEditModal = (article: Article) => {
    setEditingArticle(article);
    setFormData({
      codice: article.codice,
      nome: article.nome,
      descrizione: article.descrizione,
      tipo_prodotto: article.tipo_prodotto,
      prezzo_base: article.prezzo_base,
      durata_mesi: article.durata_mesi,
      responsabile_user_id: article.responsabile_user_id || '',
      tipologia_servizio_id: article.tipologia_servizio_id,
      partner_id: article.partner_id,
      modello_ticket_id: article.modello_ticket_id,
    });
    setShowEditModal(true);
  };

  const openCreateModal = () => {
    setFormData({
      codice: '',
      nome: '',
      descrizione: '',
      tipo_prodotto: 'semplice',
      responsabile_user_id: '',
    });
    setPartnerFiltrati(partner);
    setShowCreateModal(true);
  };

  useEffect(() => {
    const delayedSearch = setTimeout(() => {
      fetchAllArticles(searchTerm);
    }, 300);
    return () => clearTimeout(delayedSearch);
  }, [searchTerm]);

  useEffect(() => {
    fetchAllArticles();
    fetchInitialData();
  }, []);

  const filteredArticles = articles.filter((article) =>
    article.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
    article.codice.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getTipologiaById = (id?: number) => tipologie.find((t) => t.id === id);
  const getPartnerById = (id?: number) => partner.find((p) => p.id === id);

  if (loading) {
    return (
      <div className="articles-container">
        <div className="loading">
          <div className="loading-spinner"></div>
          Caricamento articoli...
        </div>
      </div>
    );
  }

  return (
    <div className="articles-container">
      <div className="articles-header">
        <div className="articles-title">
          <h1>📄 Gestione Articoli</h1>
          <p>Gestisci i tuoi prodotti e servizi con tipologie e partner</p>
        </div>
        <button className="btn btn-primary" onClick={openCreateModal}>
          ➕ Nuovo Articolo
        </button>
      </div>

      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-number">{articles.length}</div>
          <div className="stat-label">Totali</div>
        </div>
        <div className="stat-card">
          <div className="stat-number">{articles.filter((a) => a.attivo).length}</div>
          <div className="stat-label">Attivi</div>
        </div>
        <div className="stat-card">
          <div className="stat-number">{articles.filter((a) => a.tipo_prodotto === 'semplice').length}</div>
          <div className="stat-label">Servizi</div>
        </div>
        <div className="stat-card">
          <div className="stat-number">{articles.filter((a) => a.tipo_prodotto === 'composito').length}</div>
          <div className="stat-label">Kit Commerciali</div>
        </div>
      </div>

      <div className="search-section">
        <div className="search-input-container">
          <input
            type="text"
            placeholder="🔍 Cerca per codice o nome..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
        </div>
      </div>

      <div className="articles-table-container">
        <table className="articles-table">
          <thead>
            <tr>
              <th>Codice</th>
              <th>Nome</th>
              <th>Tipo</th>
              <th>Tipologia</th>
              <th>Partner</th>
              <th>Prezzo Base</th>
              <th>Durata</th>
              <th>Stato</th>
              <th>Azioni</th>
            </tr>
          </thead>
          <tbody>
            {filteredArticles.map((article) => (
              <ArticleRow
                key={article.id}
                article={article}
                tipologia={getTipologiaById(article.tipologia_servizio_id)}
                partner={getPartnerById(article.partner_id)}
                onEdit={() => openEditModal(article)}
                onDelete={() => deleteExistingArticle(article)}
                onToggleStatus={() => toggleStatus(article)}
              />
            ))}
          </tbody>
        </table>
      </div>

      <CreateArticleModal
        show={showCreateModal}
        onClose={() => setShowCreateModal(false)}
        onSubmit={createNewArticle}
        formData={formData}
        setFormData={setFormData}
        tipologie={tipologie}
        partnerFiltrati={partnerFiltrati}
        availableUsers={availableUsers}
        modelliTicket={modelliTicket}
      />

      <EditArticleModal
        show={showEditModal}
        onClose={() => setShowEditModal(false)}
        onSubmit={updateExistingArticle}
        formData={formData}
        setFormData={setFormData}
        tipologie={tipologie}
        partnerFiltrati={partnerFiltrati}
        availableUsers={availableUsers}
        modelliTicket={modelliTicket}
      />
    </div>
  );
};

export default Articles;
