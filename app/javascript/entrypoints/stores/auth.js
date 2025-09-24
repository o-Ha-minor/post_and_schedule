// app/javascript/entrypoints/stores/auth.js
import axios from 'axios';
import { defineStore } from 'pinia'
import { useToast } from 'vue-toastification'

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
        const response = await axios.get('/api/auth/check', { withCredentials: true });
        if (response.data.success) {
          this.setUser(response.data.message, response.data.groups);
        } 
      }catch (error) {
        console.error('Check auth error:', error);
      } finally {
        this.initialized = true;
      }
    },
    setUser(user, groups) {
      this.user = user;
      this.groups = groups;
      this.isLoggedIn = true;
    },
  
    async login(credentials) {
      const toast = useToast()
      
      try {
        const response = await axios.post('/api/auth/login', credentials, {
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },withCredentials: true,
        })
        if (response.data.success) {
          this.setUser(response.data.user, response.data.groups)
          toast.success(response.data.message)
          return { success: true }
        } else {
          toast.error(data.message || 'ログインに失敗しました')
          return { success: false, message: data.message }
        }
      } catch (error) {
        console.error('ログインエラー:', error)
        toast.error('ネットワークエラーが発生しました')
        return { success: false, message: 'ネットワークエラー' }
      }
    },

    async register(userData) {
      const toast = useToast()
      
      try {
        const response = await axios.post('/api/auth/register', { user: userData }, {
          headers: {
            'Accept': 'application/json',
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content
          },withCredentials: true,
        })
        if (response.data.success) {
          this.setUser(response.data.user, response.data.groups)
          toast.success(response.data.message)
          return { success: true }
        } else {
          toast.error(response.data.message || '登録に失敗しました')
          return { success: false, errors: data.errors }
        }
      } catch (error) {
        console.error('登録エラー:', error)
        toast.error('ネットワークエラーが発生しました')
        return { success: false, message: 'ネットワークエラー' }
      }
    },

    async logout() {
      const toast = useToast()
      
      try {
        const response = await axios.delete('/api/auth/logout',{
          headers: {
            'Accept': 'application/json',
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content,
            withCredentials: true
          }
        })

        if (response.data.success) {
          const data = await response.json()
          this.clearAuth()
          toast.success(data.message)
          return { success: true }
        }
      } catch (error) {
        console.error('ログアウトエラー:', error)
      }
      
      // エラーが発生してもログアウト状態にする
      this.clearAuth()
      toast.info('ログアウトしました')
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
        this.user = { ...this.user, ...userData }
      }
    }
  }
})