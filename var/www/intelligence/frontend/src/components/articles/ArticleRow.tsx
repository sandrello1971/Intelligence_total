import React from 'react';

interface TipologiaServizio {
  id: number;
  nome: string;
  descrizione: string;
  colore: string;
  icona: string;
}

interface Partner {
  id: number;
  nome: string;
  email?: string;
}

interface Article {
  id: number;
  codice: string;
  nome: string;
  descrizione?: string;
  tipo_prodotto: 'semplice' | 'composito';
  prezzo_base?: number;
  durata_mesi?: number;
  attivo: boolean;
  tipologia_servizio_id?: number;
  partner_id?: number;
}

interface Props {
  article: Article;
  tipologia?: TipologiaServizio;
  partner?: Partner;
  onEdit: () => void;
  onDelete: () => void;
}

const ArticleRow: React.FC<Props> = ({ article, tipologia, partner, onEdit, onDelete }) => {
  return (
    <tr key={article.id}>
      <td>
        <span className="article-code">{article.codice}</span>
      </td>
      <td>
        <div className="article-name">
          <strong>{article.nome}</strong>
          {article.descrizione && (
            <div className="article-description">{article.descrizione}</div>
          )}
        </div>
      </td>
      <td>
        <span className={`type-badge ${article.tipo_prodotto}`}>
          {article.tipo_prodotto === 'semplice' ? '🔹 Servizio' : '🔸 Kit Commerciale'}
        </span>
      </td>
      <td>
        {tipologia ? (
          <span
            className="tipologia-badge"
            style={{ backgroundColor: tipologia.colore + '20', color: tipologia.colore }}
          >
            {tipologia.icona} {tipologia.nome}
          </span>
        ) : (
          <span className="no-data">Non specificata</span>
        )}
      </td>
      <td>
        {partner ? (
          <div className="partner-info">
            <strong>{partner.nome}</strong>
            {partner.email && (
              <div className="partner-email">{partner.email}</div>
            )}
          </div>
        ) : (
          <span className="no-data">Nessun partner</span>
        )}
      </td>
      <td>
        {article.prezzo_base ? `€ ${article.prezzo_base}` : '-'}
      </td>
      <td>
        {article.durata_mesi ? `${article.durata_mesi} mesi` : '-'}
      </td>
      <td>
        <span className={`status-badge ${article.attivo ? 'active' : 'inactive'}`}>
          {article.attivo ? '✅ Attivo' : '❌ Inattivo'}
        </span>
      </td>
      <td>
        <div className="actions">
          <button
            className="btn btn-secondary btn-sm"
            onClick={onEdit}
            title="Modifica"
          >
            ✏️
          </button>
          <button
            className="btn btn-danger btn-sm"
            onClick={onDelete}
            title="Elimina"
          >
            🗑️
          </button>
        </div>
      </td>
    </tr>
  );
};

export default ArticleRow;
