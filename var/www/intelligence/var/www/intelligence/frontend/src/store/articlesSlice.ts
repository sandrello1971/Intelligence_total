import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';

// Types
interface Article {
  id: number;
  codice: string;
  nome: string;
  descrizione: string;
  tipo_prodotto: 'semplice' | 'composito';
  prezzo_base?: number;
  durata_mesi?: number;
  attivo: boolean;
  tipologia_servizio_id?: number;
  partner_id?: number;
  created_at: string;
}

interface KitCommerciale {
  id: number;
  nome: string;
  descrizione: string;
  articolo_principale_id?: number;
  attivo: boolean;
  created_at: string;
  articoli_inclusi: KitArticolo[];
}

interface KitArticolo {
  id: number;
  articolo_id: number;
  quantita: number;
  obbligatorio: boolean;
  ordine: number;
  partner_id?: number;
  modello_ticket_id?: string;
  note?: string;
  articolo?: Article;
}

interface TipologiaServizio {
  id: number;
  nome: string;
  descrizione: string;
  colore: string;
  icona: string;
  attivo: boolean;
}

interface Partner {
  id: number;
  nome: string;
  ragione_sociale?: string;
  attivo: boolean;
}

interface ArticlesState {
  // Data
  articles: Article[];
  kits: KitCommerciale[];
  tipologie: TipologiaServizio[];
  partners: Partner[];
  
  // Creation Wizard State
  wizardStep: 'type' | 'config' | 'kit-composition' | 'review';
  selectedType: 'semplice' | 'kit_commerciale' | null;
  
  // Form Data
  articleForm: {
    codice: string;
    nome: string;
    descrizione: string;
    tipo_prodotto: 'semplice' | 'composito';
    prezzo_base?: number;
    durata_mesi?: number;
    tipologia_servizio_id?: number;
    partner_id?: number;
  };
  
  // Kit Composition
  kitComposition: {
    selectedArticles: number[];
    articlesConfig: Record<number, {
      quantita: number;
      obbligatorio: boolean;
      ordine: number;
      partner_id?: number;
      note?: string;
    }>;
  };
  
  // UI State
  loading: {
    articles: boolean;
    creating: boolean;
    kits: boolean;
    tipologie: boolean;
    partners: boolean;
  };
  
  error: string | null;
  
  // Filters
  filters: {
    search: string;
    tipologia: number | null;
    partner: number | null;
    attivo: boolean | null;
  };
}

const initialState: ArticlesState = {
  articles: [],
  kits: [],
  tipologie: [],
  partners: [],
  wizardStep: 'type',
  selectedType: null,
  articleForm: {
    codice: '',
    nome: '',
    descrizione: '',
    tipo_prodotto: 'semplice',
  },
  kitComposition: {
    selectedArticles: [],
    articlesConfig: {},
  },
  loading: {
    articles: false,
    creating: false,
    kits: false,
    tipologie: false,
    partners: false,
  },
  error: null,
  filters: {
    search: '',
    tipologia: null,
    partner: null,
    attivo: null,
  },
};

// Async Thunks
export const fetchArticles = createAsyncThunk(
  'articles/fetchArticles',
  async (_, { getState }) => {
    const state = getState() as { auth: { token: string } };
    const response = await fetch('/api/v1/articles/', {
      headers: {
        'Authorization': `Bearer ${state.auth.token}`,
      },
    });
    
    if (!response.ok) throw new Error('Failed to fetch articles');
    const data = await response.json();
    return data.articles || [];
  }
);

export const fetchKits = createAsyncThunk(
  'articles/fetchKits',
  async (_, { getState }) => {
    const state = getState() as { auth: { token: string } };
    const response = await fetch('/api/v1/kit-commerciali/', {
      headers: {
        'Authorization': `Bearer ${state.auth.token}`,
      },
    });
    
    if (!response.ok) throw new Error('Failed to fetch kits');
    const data = await response.json();
    return data.kit_commerciali || [];
  }
);

export const fetchTipologie = createAsyncThunk(
  'articles/fetchTipologie',
  async (_, { getState }) => {
    const state = getState() as { auth: { token: string } };
    const response = await fetch('/api/v1/tipologie-servizi/', {
      headers: {
        'Authorization': `Bearer ${state.auth.token}`,
      },
    });
    
    if (!response.ok) throw new Error('Failed to fetch tipologie');
    const data = await response.json();
    return data.tipologie || [];
  }
);

export const fetchPartners = createAsyncThunk(
  'articles/fetchPartners',
  async (_, { getState }) => {
    const state = getState() as { auth: { token: string } };
    const response = await fetch('/api/v1/partner/', {
      headers: {
        'Authorization': `Bearer ${state.auth.token}`,
      },
    });
    
    if (!response.ok) throw new Error('Failed to fetch partners');
    const data = await response.json();
    return data.partner || [];
  }
);

export const createArticleOrKit = createAsyncThunk(
  'articles/createArticleOrKit',
  async (_, { getState }) => {
    const state = getState() as { articles: ArticlesState; auth: { token: string } };
    const { articleForm, selectedType, kitComposition } = state.articles;
    
    // Prima crea l'articolo base
    const articleResponse = await fetch('/api/v1/articles/', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${state.auth.token}`,
      },
      body: JSON.stringify({
        ...articleForm,
        tipo_prodotto: selectedType === 'kit_commerciale' ? 'composito' : 'semplice',
      }),
    });
    
    if (!articleResponse.ok) throw new Error('Failed to create article');
    const articleData = await articleResponse.json();
    
    // Se è un kit, crea anche il kit commerciale
    if (selectedType === 'kit_commerciale') {
      const kitResponse = await fetch('/api/v1/kit-commerciali/', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${state.auth.token}`,
        },
        body: JSON.stringify({
          nome: articleForm.nome,
          descrizione: articleForm.descrizione,
          articolo_principale_id: articleData.article.id,
          attivo: true,
        }),
      });
      
      if (!kitResponse.ok) throw new Error('Failed to create kit');
      const kitData = await kitResponse.json();
      
      // Aggiungi gli articoli al kit
      for (const articleId of kitComposition.selectedArticles) {
        const config = kitComposition.articlesConfig[articleId] || {
          quantita: 1,
          obbligatorio: false,
          ordine: 0,
        };
        
        await fetch('/api/v1/kit-articoli/', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${state.auth.token}`,
          },
          body: JSON.stringify({
            kit_commerciale_id: kitData.kit.id,
            articolo_id: articleId,
            ...config,
          }),
        });
      }
      
      return { type: 'kit', data: kitData.kit };
    }
    
    return { type: 'article', data: articleData.article };
  }
);

const articlesSlice = createSlice({
  name: 'articles',
  initialState,
  reducers: {
    // Wizard Navigation
    setWizardStep: (state, action: PayloadAction<ArticlesState['wizardStep']>) => {
      state.wizardStep = action.payload;
    },
    setSelectedType: (state, action: PayloadAction<'semplice' | 'kit_commerciale'>) => {
      state.selectedType = action.payload;
    },
    nextWizardStep: (state) => {
      const steps: ArticlesState['wizardStep'][] = ['type', 'config', 'kit-composition', 'review'];
      const currentIndex = steps.indexOf(state.wizardStep);
      if (currentIndex < steps.length - 1) {
        state.wizardStep = steps[currentIndex + 1];
      }
    },
    prevWizardStep: (state) => {
      const steps: ArticlesState['wizardStep'][] = ['type', 'config', 'kit-composition', 'review'];
      const currentIndex = steps.indexOf(state.wizardStep);
      if (currentIndex > 0) {
        state.wizardStep = steps[currentIndex - 1];
      }
    },
    
    // Form Management
    updateArticleForm: (state, action: PayloadAction<Partial<ArticlesState['articleForm']>>) => {
      state.articleForm = { ...state.articleForm, ...action.payload };
    },
    
    // Kit Composition
    toggleArticleSelection: (state, action: PayloadAction<number>) => {
      const articleId = action.payload;
      const index = state.kitComposition.selectedArticles.indexOf(articleId);
      
      if (index > -1) {
        // Remove
        state.kitComposition.selectedArticles.splice(index, 1);
        delete state.kitComposition.articlesConfig[articleId];
      } else {
        // Add
        state.kitComposition.selectedArticles.push(articleId);
        state.kitComposition.articlesConfig[articleId] = {
          quantita: 1,
          obbligatorio: false,
          ordine: state.kitComposition.selectedArticles.length - 1,
        };
      }
    },
    
    updateKitArticleConfig: (state, action: PayloadAction<{
      articleId: number;
      config: Partial<ArticlesState['kitComposition']['articlesConfig'][number]>;
    }>) => {
      const { articleId, config } = action.payload;
      if (state.kitComposition.articlesConfig[articleId]) {
        state.kitComposition.articlesConfig[articleId] = {
          ...state.kitComposition.articlesConfig[articleId],
          ...config,
        };
      }
    },
    
    reorderKitArticles: (state, action: PayloadAction<number[]>) => {
      state.kitComposition.selectedArticles = action.payload;
      // Update ordine in config
      action.payload.forEach((articleId, index) => {
        if (state.kitComposition.articlesConfig[articleId]) {
          state.kitComposition.articlesConfig[articleId].ordine = index;
        }
      });
    },
    
    // Reset
    resetWizard: (state) => {
      state.wizardStep = 'type';
      state.selectedType = null;
      state.articleForm = {
        codice: '',
        nome: '',
        descrizione: '',
        tipo_prodotto: 'semplice',
      };
      state.kitComposition = {
        selectedArticles: [],
        articlesConfig: {},
      };
    },
    
    // Filters
    updateFilters: (state, action: PayloadAction<Partial<ArticlesState['filters']>>) => {
      state.filters = { ...state.filters, ...action.payload };
    },
    
    clearError: (state) => {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // Fetch Articles
      .addCase(fetchArticles.pending, (state) => {
        state.loading.articles = true;
      })
      .addCase(fetchArticles.fulfilled, (state, action) => {
        state.loading.articles = false;
        state.articles = action.payload;
      })
      .addCase(fetchArticles.rejected, (state, action) => {
        state.loading.articles = false;
        state.error = action.error.message || 'Failed to fetch articles';
      })
      
      // Fetch Kits
      .addCase(fetchKits.pending, (state) => {
        state.loading.kits = true;
      })
      .addCase(fetchKits.fulfilled, (state, action) => {
        state.loading.kits = false;
        state.kits = action.payload;
      })
      .addCase(fetchKits.rejected, (state, action) => {
        state.loading.kits = false;
        state.error = action.error.message || 'Failed to fetch kits';
      })
      
      // Fetch Tipologie
      .addCase(fetchTipologie.fulfilled, (state, action) => {
        state.tipologie = action.payload;
      })
      
      // Fetch Partners
      .addCase(fetchPartners.fulfilled, (state, action) => {
        state.partners = action.payload;
      })
      
      // Create Article/Kit
      .addCase(createArticleOrKit.pending, (state) => {
        state.loading.creating = true;
        state.error = null;
      })
      .addCase(createArticleOrKit.fulfilled, (state, action) => {
        state.loading.creating = false;
        if (action.payload.type === 'article') {
          state.articles.push(action.payload.data);
        } else {
          state.kits.push(action.payload.data);
        }
        // Reset wizard
        state.wizardStep = 'type';
        state.selectedType = null;
        state.articleForm = {
          codice: '',
          nome: '',
          descrizione: '',
          tipo_prodotto: 'semplice',
        };
        state.kitComposition = {
          selectedArticles: [],
          articlesConfig: {},
        };
      })
      .addCase(createArticleOrKit.rejected, (state, action) => {
        state.loading.creating = false;
        state.error = action.error.message || 'Failed to create article/kit';
      });
  },
});

export const {
  setWizardStep,
  setSelectedType,
  nextWizardStep,
  prevWizardStep,
  updateArticleForm,
  toggleArticleSelection,
  updateKitArticleConfig,
  reorderKitArticles,
  resetWizard,
  updateFilters,
  clearError,
} = articlesSlice.actions;

export default articlesSlice.reducer;
