// src/api/articles-api.ts
import axios from 'axios';
import { Article, TipologiaServizio, Partner, ModelloTicket, User } from '../types';

const API_BASE = '/api/v1';

export const fetchArticles = async (): Promise<Article[]> => {
  const response = await axios.get(`${API_BASE}/articles`);
  return response.data;
};

export const fetchTipologieServizi = async (): Promise<TipologiaServizio[]> => {
  const response = await axios.get(`${API_BASE}/tipologie-servizi?attivo=true`);
  return response.data;
};

export const fetchPartners = async (): Promise<Partner[]> => {
  const response = await axios.get(`${API_BASE}/partner?attivo=true`);
  return response.data;
};

export const fetchAvailableUsers = async (): Promise<User[]> => {
  const response = await axios.get(`${API_BASE}/articles/users-disponibili`);
  return response.data;
};

export const fetchTicketTemplates = async (): Promise<ModelloTicket[]> => {
  const response = await axios.get(`${API_BASE}/templates/ticket-templates`);
  return response.data;
};
