// app/javascript/entrypoints/stores/auth.js
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
      try {
        const response = await fetch('/api/auth/check', {
          headers: {
            'Accept': 'application/json',
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content
          }
        })

        if (response.ok) {
          const data = await response.json()
          this.setUser(data.user, data.groups)
        } else {
          this.clearAuth()
        }
      } catch (error) {
        console.error('認証チェックエラー:', error)
        this.clearAuth()
      } finally {
        this.initialized = true
      }
    },

    async login(credentials) {
      const toast = useToast()
      
      try {
        const response = await fetch('/api/auth/login', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content
          },
          body: JSON.stringify(credentials)
        })

        const data = await response.json()

        if (response.ok && data.success) {
          this.setUser(data.user, data.groups)
          toast.success(data.message)
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
        const formData = new FormData()
        Object.keys(userData).forEach(key => {
          if (userData[key] !== null) {
            formData.append(`user[${key}]`, userData[key])
          }
        })

        const response = await fetch('/api/auth/register', {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content
          },
          body: formData
        })

        const data = await response.json()

        if (response.ok && data.success) {
          this.setUser(data.user, data.groups)
          toast.success(data.message)
          return { success: true }
        } else {
          toast.error(data.message || '登録に失敗しました')
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
        const response = await fetch('/api/auth/logout', {
          method: 'DELETE',
          headers: {
            'Accept': 'application/json',
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]')?.content
          }
        })

        if (response.ok) {
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