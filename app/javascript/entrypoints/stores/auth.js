// app/javascript/entrypoints/stores/auth.js
import axios from 'axios';
import { defineStore } from 'pinia'
import { useToast } from 'vue-toastification';

const Toast = useToast();

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    isLoggedIn: false,
    initialized: false,
    groups: []
  }),

  getters: {
    currentUserId: (state) => state.user?.id,
    currentUserName: (state) => state.user?.name,
    currentUserImageUrl: (state) => state.user?.image_url
  },

  actions: {
    async checkAuth() {
      console.log('Checking auth...');
      try {
        const response = await axios.get('/api/auth/check', { withCredentials: true, skipAuthRedirect: true });
        if (response.data.success) {
          this.setUser(response.data.data.user, response.data.data.groups);
        } else {
          this.clearAuth();
        }
      }catch (error) {
        if  (error.response?.status === 401){
          this.clearAuth();
        } else {
          console.error('Check auth error:', error);
        }
      } finally {
        this.initialized = true;
      }
    },

    async login(credentials) {
      try {
        const response = await axios.post('/api/auth/login', credentials, { withCredentials: true });
        if (response.data.success) {
          this.setUser(response.data.data.user, response.data.data.groups);
          return { success: true };
        } else {
          return { success: false, message: response.data.message };
        }
      } catch (error) {
        console.error('ログインエラー:', error);
        return { success: false, message: 'ネットワークエラー' };
      }
    },

    async register(userData) {
      try {
        const response = await axios.post('/api/auth/register', { user: userData }, {
          withCredentials: true,
        })

        const isSuccess = (typeof response.data?.success !== 'undefined')
         ? response.data.success
         : (response.status >= 200 && response.status < 300 && !!response.data?.data?.user);

        if (isSuccess) {
          this.setUser(response.data.data.user, response.data.data.groups || [])
          return { success: true }
        } else {

          return { success: false, errors: response.data?.errors || [response.data?.message || '登録に失敗しました'] }
        }
      } catch (error) {
        console.error('登録エラー:', error)
        return { success: false, message: 'ネットワークエラー' }
      }
    },

    async logout() {  
      try {
        const response = await axios.delete('/api/auth/logout',{
            withCredentials: true
          }
        ,)

        if (response.data.success) {
          this.clearAuth()
          return { success: true }
        }
      } catch (error) {
        console.error('ログアウトエラー:', error)
      }
      
      // エラーが発生してもログアウト状態にする
      this.clearAuth()
      return { success: true }
    },

    setUser(user, groups = []) {
      this.user = user
      this.groups = groups
      this.isLoggedIn = true
    },

    clearAuth() {
      this.user = null
      this.groups = []
      this.isLoggedIn = false
    },

    updateUser(userData) {
      if (this.user) {
        this.user = { ...this.user, ...userData };
      }
    }
  }
});
