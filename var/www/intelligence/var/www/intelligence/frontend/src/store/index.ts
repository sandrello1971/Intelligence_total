import { configureStore } from '@reduxjs/toolkit';
import { useDispatch, useSelector, TypedUseSelectorHook } from 'react-redux';
import articlesReducer from './articlesSlice';

// Mock reducer per auth se non esiste
const authSlice = {
  name: 'auth',
  initialState: { user: null, token: null, isAuthenticated: false },
  reducers: {}
};

export const store = configureStore({
  reducer: {
    articles: articlesReducer,
    auth: (state = authSlice.initialState) => state,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;
