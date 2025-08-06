import React from 'react';
import { ArticleFormData, TipologiaServizio, Partner, ModelloTicket, User } from './types';

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
  tipologie,
  partnerFiltrati,
  availableUsers,
  modelliTicket,
  show,
  onClose,
  onSubmit
}) => {
  if (!show) return null;

  return (
    <div className="modal-overlay">
      <div className="modal">
        <div className="modal-header">
          <h2>✏️ Modifica Articolo</h2>
          <button className="modal-close" onClick={onClose}>✕</button>
        </div>
        <div className="modal-body">
          <div className="form-group">
            <label>Codice *</label>
            <input
              type="text"
              value={formData.codice}
              onChange={(e) => setFormData({ ...formData, codice: e.target.value })}
              maxLength={10}
            />
          </div>
          <div className="form-group">
            <label>Nome *</label>
            <input
              type="text"
              value={formData.nome}
              onChange={(e) => setFormData({ ...formData, nome: e.target.value })}
            />
          </div>
          <div className="form-group">
            <label>Descrizione</label>
            <textarea
              value={formData.descrizione}
              onChange={(e) => setFormData({ ...formData, descrizione: e.target.value })}
              rows={3}
            />
          </div>
          <div className="form-row">
            <div className="form-group">
              <label>Tipo Prodotto *</label>
              <select
                value={formData.tipo_prodotto}
                onChange={(e) => setFormData({ ...formData, tipo_prodotto: e.target.value as 'semplice' | 'composito' })}
              >
                <option value="semplice">🔹 Servizio</option>
                <option value="composito">🔸 Kit Commerciale</option>
              </select>
            </div>
            <div className="form-group">
              <label>Tipologia Servizio</label>
              <select
                value={formData.tipologia_servizio_id || ''}
                onChange={(e) => setFormData({ ...formData, tipologia_servizio_id: e.target.value ? parseInt(e.target.value) : undefined })}
              >
                <option value="">Seleziona tipologia...</option>
                {tipologie.map(t => (
                  <option key={t.id} value={t.id}>{t.icona} {t.nome}</option>
                ))}
              </select>
            </div>
          </div>
          <div className="form-row">
            <div className="form-group">
              <label>Partner</label>
              <select
                value={formData.partner_id || ''}
                onChange={(e) => setFormData({ ...formData, partner_id: e.target.value ? parseInt(e.target.value) : undefined })}
              >
                <option value="">Seleziona partner...</option>
                {partnerFiltrati.map(p => (
                  <option key={p.id} value={p.id}>{p.nome} ({p.servizi_count} servizi)</option>
                ))}
              </select>
            </div>
            <div className="form-group">
              <label>Responsabile</label>
              <select
                value={formData.responsabile_user_id || ''}
                onChange={(e) => setFormData({ ...formData, responsabile_user_id: e.target.value || undefined })}
              >
                <option value="">Seleziona responsabile...</option>
                {availableUsers.map(user => (
                  <option key={user.id} value={user.id}>{user.display_name} ({user.role})</option>
                ))}
              </select>
            </div>
          </div>
          <div className="form-group">
            <label>Template Ticket</label>
            <select
              value={formData.modello_ticket_id || ''}
              onChange={(e) => setFormData({ ...formData, modello_ticket_id: e.target.value || undefined })}
            >
              <option value="">Nessun template...</option>
              {modelliTicket.map(m => (
                <option key={m.id} value={m.id}>{m.nome} (SLA: {m.sla_hours}h)</option>
              ))}
            </select>
          </div>
          <div className="form-row">
            <div className="form-group">
              <label>Prezzo Base (€)</label>
              <input
                type="number"
                value={formData.prezzo_base || ''}
                onChange={(e) => setFormData({ ...formData, prezzo_base: parseFloat(e.target.value) || undefined })}
                step="0.01"
              />
            </div>
            <div className="form-group">
              <label>Durata (mesi)</label>
              <input
                type="number"
                value={formData.durata_mesi || ''}
                onChange={(e) => setFormData({ ...formData, durata_mesi: parseInt(e.target.value) || undefined })}
              />
            </div>
          </div>
        </div>
        <div className="modal-footer">
          <button className="btn btn-secondary" onClick={onClose}>Annulla</button>
          <button className="btn btn-primary" onClick={onSubmit} disabled={!formData.codice || !formData.nome}>
            Salva Modifiche
          </button>
        </div>
      </div>
    </div>
  );
};

export default EditArticleModal;
