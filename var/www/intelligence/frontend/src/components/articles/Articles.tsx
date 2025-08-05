import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Box, Typography, CircularProgress, IconButton, Tooltip, Dialog, DialogTitle, DialogActions, Button } from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import { useSelector } from 'react-redux';
import { RootState } from '../../store';

interface Articolo {
  id: number;
  nome: string;
  descrizione?: string;
}

const Articles: React.FC = () => {
  const [articoli, setArticoli] = useState<Articolo[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [deleteDialog, setDeleteDialog] = useState<{ open: boolean, id: number | null }>({ open: false, id: null });

  const token = useSelector((state: RootState) => state.auth.token);

  const fetchArticoli = async () => {
    try {
      const res = await axios.get('/api/v1/articles/', {
        headers: { Authorization: `Bearer ${token}` },
      });
      setArticoli(res.data);
    } catch (err: any) {
      setError('Errore nel recupero articoli.');
    } finally {
      setLoading(false);
    }
  };

  const deleteArticolo = async (id: number) => {
    try {
      await axios.delete(`/api/v1/articles/${id}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setArticoli((prev) => prev.filter((a) => a.id !== id));
    } catch (err: any) {
      alert('Errore nella cancellazione');
    } finally {
      setDeleteDialog({ open: false, id: null });
    }
  };

  useEffect(() => {
    fetchArticoli();
  }, []);

  if (loading) return <Box p={2}><CircularProgress /></Box>;
  if (error) return <Box p={2}><Typography color="error">{error}</Typography></Box>;
  if (articoli.length === 0) return <Box p={2}><Typography>Nessun articolo disponibile.</Typography></Box>;

  return (
    <Box p={2}>
      <Typography variant="h6">📦 Articoli</Typography>
      {articoli.map((articolo) => (
        <Box key={articolo.id} display="flex" alignItems="center" justifyContent="space-between" my={1} p={1} border={1} borderRadius={1}>
          <Box>
            <Typography fontWeight="bold">{articolo.nome}</Typography>
            {articolo.descrizione && <Typography variant="body2">{articolo.descrizione}</Typography>}
          </Box>
          <Tooltip title="Elimina articolo">
            <IconButton color="error" onClick={() => setDeleteDialog({ open: true, id: articolo.id })}>
              <DeleteIcon />
            </IconButton>
          </Tooltip>
        </Box>
      ))}

      <Dialog open={deleteDialog.open} onClose={() => setDeleteDialog({ open: false, id: null })}>
        <DialogTitle>Confermi la cancellazione?</DialogTitle>
        <DialogActions>
          <Button onClick={() => setDeleteDialog({ open: false, id: null })}>Annulla</Button>
          <Button color="error" onClick={() => deleteArticolo(deleteDialog.id!)}>Elimina</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default Articles;
