import React from 'react';
import { ArticleFormData, TipologiaServizio, Partner, User, ModelloTicket } from './types';

interface Props {
  formData: ArticleFormData;
  setFormData: (formData: ArticleFormData) => void;
  tipologie: TipologiaServizio[];
  partnerFiltrati: Partner[];
  availableUsers: User[];
  modelliTicket: ModelloTicket[];
  show: boolean;
  onClose: () => void;
  onSubmit: () => void;
}

const EditArticleModal: React.FC<Props> = ({
  formData,
  setFormData,
  tipologie = [],
  partnerFiltrati = [],
  availableUsers = [],
  modelliTicket = [],
  show,
  onClose,
  onSubmit
}) => {
  if (!show) return null;

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  return (
    <div className="modal">
      <div className="modal-content">
        <h2>✏️ Modifica Articolo</h2>

        <input
          type="text"
          name="nome"
          value={formData.nome}
          onChange={handleChange}
          placeholder="Nome"
        />

        <select name="tipologia_id" value={formData.tipologia_id} onChange={handleChange}>
          <option value="">Seleziona tipologia</option>
          {tipologie.map(t => (
            <option key={t.id} value={t.id}>{t.nome}</option>
          ))}
        </select>

        <select name="partner_id" value={formData.partner_id} onChange={handleChange}>
          <option value="">Seleziona partner</option>
          {partnerFiltrati.map(p => (
            <option key={p.id} value={p.id}>{p.nome}</option>
          ))}
        </select>

        <select name="user_id" value={formData.user_id} onChange={handleChange}>
          <option value="">Assegna utente</option>
          {availableUsers.map(user => (
            <option key={user.id} value={user.id}>{user.full_name}</option>
          ))}
        </select>

        <select name="modello_ticket_id" value={formData.modello_ticket_id} onChange={handleChange}>
          <option value="">Seleziona Modello Ticket</option>
          {modelliTicket.map(m => (
            <option key={m.id} value={m.id}>{m.nome}</option>
          ))}
        </select>

        <div className="modal-actions">
          <button className="btn btn-secondary" onClick={onClose}>Annulla</button>
          <button className="btn btn-primary" onClick={onSubmit}>Salva</button>
        </div>
      </div>
    </div>
  );
};

export default EditArticleModal;
