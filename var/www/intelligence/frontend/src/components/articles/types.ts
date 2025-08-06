export interface TipologiaServizio {
  id: number;
  nome: string;
  descrizione: string;
  colore: string;
  icona: string;
  attivo: boolean;
}

export interface Partner {
  id: number;
  nome: string;
  ragione_sociale?: string;
  email?: string;
  telefono?: string;
  attivo: boolean;
  servizi_count: number;
}

export interface ModelloTicket {
  id: string;
  nome: string;
  descrizione: string;
  priority: string;
  sla_hours: number;
  is_active: boolean;
}

export interface User {
  id: string;
  display_name: string;
  role: string;
}

export interface ArticleFormData {
  codice: string;
  nome: string;
  descrizione: string;
  tipo_prodotto: 'semplice' | 'composito';
  prezzo_base?: number;
  durata_mesi?: number;
  tipologia_servizio_id?: number;
  partner_id?: number;
  responsabile_user_id?: string;
  modello_ticket_id?: string;
}
