import { ArticleFormData } from '../components/articles/types';

export const getArticles = async (search = '') => {
  const searchParam = search ? `?search=${encodeURIComponent(search)}` : '';
  const response = await fetch(`/api/v1/articles/${searchParam}`);
  const data = await response.json();
  if (!data.success) throw new Error('Errore nel fetch articoli');
  return data.articles;
};

export const createArticle = async (formData: ArticleFormData) => {
  const response = await fetch('/api/v1/articles/', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(formData),
  });
  const data = await response.json();
  if (!data.success) throw new Error(data.detail || 'Creazione fallita');
  return data;
};

export const updateArticle = async (id: number, formData: ArticleFormData) => {
  const response = await fetch(`/api/v1/articles/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(formData),
  });
  const data = await response.json();
  if (!data.success) throw new Error(data.detail || 'Aggiornamento fallito');
  return data;
};

export const deleteArticle = async (id: number) => {
  const response = await fetch(`/api/v1/articles/${id}`, {
    method: 'DELETE',
  });
  const data = await response.json();
  if (!data.success) throw new Error(data.detail || 'Eliminazione fallita');
  return data;
};

export const toggleArticleStatus = async (article: any) => {
  const response = await fetch(`/api/v1/articles/${article.id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ ...article, attivo: !article.attivo }),
  });
  const data = await response.json();
  if (!data.success) throw new Error(data.detail || 'Aggiornamento stato fallito');
  return data;
};

export const getTipologieServizi = async () => {
  const response = await fetch('/api/v1/tipologie-servizi/?attivo=true');
  const data = await response.json();
  if (!data.success) throw new Error('Errore nel fetch tipologie');
  return data.tipologie;
};

export const getPartner = async () => {
  const response = await fetch('/api/v1/partner/?attivo=true');
  const data = await response.json();
  if (!data.success) throw new Error('Errore nel fetch partner');
  return data.partner;
};

export const getAvailableUsers = async () => {
  const response = await fetch('/api/v1/articles/users-disponibili');
  const data = await response.json();
  if (!data.success) throw new Error('Errore nel fetch utenti');
  return data.users;
};

export const getModelliTicket = async () => {
  const response = await fetch('/api/v1/templates/ticket-templates', {
    headers: {
      'Authorization': `Bearer ${localStorage.getItem('token')}`,
      'Content-Type': 'application/json',
    },
  });
  if (!response.ok) throw new Error('Errore HTTP nei modelli ticket');
  const data = await response.json();
  return data;
};
