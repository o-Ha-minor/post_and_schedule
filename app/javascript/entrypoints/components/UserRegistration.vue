<template>
    <div class="min-h-screen bg-gray-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div class="max-w-md w-full space-y-8">
        <div>
          <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
            アカウントを作成
          </h2>
        </div>
        
        <!-- エラーメッセージ -->
        <div v-if="errors.length > 0" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative">
          <ul class="list-disc list-inside space-y-1">
            <li v-for="error in errors" :key="error">{{ error }}</li>
          </ul>
        </div>
        
        <!-- 成功メッセージ -->
        <div v-if="successMessage" class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative">
          {{ successMessage }}
        </div>
  
        <form class="mt-8 space-y-6" @submit.prevent="handleRegistration">
          <div class="rounded-md shadow-sm space-y-4">
            <div>
              <label for="name" class="block text-sm font-medium text-gray-700 mb-1">
                Name（ユーザー名）
              </label>
              <input
                id="name"
                v-model="registrationForm.name"
                type="text"
                required
                class="relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-lg focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                :class="{ 'border-red-500': fieldErrors.name }"
                placeholder="ユーザー名を入力"
              >
            </div>
            <div>
              <label for="email" class="block text-sm font-medium text-gray-700 mb-1">
                E-mail（メールアドレス）
              </label>
              <input
                id="email"
                v-model="registrationForm.email"
                type="email"
                required
                class="relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-lg focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                :class="{ 'border-red-500': fieldErrors.email }"
                placeholder="メールアドレスを入力"
              >
            </div>
            <div>
              <label for="password" class="block text-sm font-medium text-gray-700 mb-1">
                Password（パスワード）
              </label>
              <input
                id="password"
                v-model="registrationForm.password"
                type="password"
                required
                class="relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-lg focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                :class="{ 'border-red-500': fieldErrors.password }"
                placeholder="パスワードを入力"
              >
            </div>
            <div>
              <label for="password_confirmation" class="block text-sm font-medium text-gray-700 mb-1">
                パスワード確認
              </label>
              <input
                id="password_confirmation"
                v-model="registrationForm.password_confirmation"
                type="password"
                required
                class="relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-lg focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
                :class="{ 'border-red-500': passwordMismatch }"
                placeholder="パスワードを再入力"
              >
              <p v-if="passwordMismatch" class="text-red-500 text-xs mt-1">
                パスワードが一致しません
              </p>
            </div>
          </div>
  
          <div>
            <button
              type="submit"
              :disabled="isLoading || passwordMismatch"
              class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors duration-200"
            >
              {{ isLoading ? 'アカウント作成中...' : 'Please get it!(アカウント作成)' }}
            </button>
          </div>
  
          <div class="text-center">
            <a href="/users/login_form" class="text-indigo-600 hover:text-indigo-800 text-sm font-medium">
              既にアカウントをお持ちの方はこちら
            </a>
          </div>
        </form>
      </div>
    </div>
  </template>
  
  <script>
export default {
  name: 'UserRegistration',
  data() {
    return {
      registrationForm: {
        name: '',
        email: '',
        password: '',
        password_confirmation: ''
      },
      isLoading: false,
      errors: [],
      successMessage: '',
      fieldErrors: {}
    }
  },
  computed: {
    passwordMismatch() {
      return (
        this.registrationForm.password !== this.registrationForm.password_confirmation &&
        this.registrationForm.password_confirmation !== ''
      )
    }
  },
  methods: {
    async handleRegistration() {
      this.isLoading = true
      this.errors = []
      this.successMessage = ''
      this.fieldErrors = {}

      // クライアントサイドバリデーション
      if (this.passwordMismatch) {
        this.errors.push('パスワードが一致しません')
        this.isLoading = false
        return
      }

      try {
        const response = await fetch('/api/users', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            user: {
              name: this.registrationForm.name,
              email: this.registrationForm.email,
              password: this.registrationForm.password,
              password_confirmation: this.registrationForm.password_confirmation
            }
          })
        })

        const data = await response.json()

        if (response.ok) {
          this.successMessage = '登録が完了しました！'
          console.log("ユーザー登録成功", data)
          this.$router.push({ path: '/', query: { success: '登録が完了しました！' } })
        } else {
          this.errors = data.errors || ['登録に失敗しました']
          console.error("ユーザー登録失敗", data.errors)
        }
      } catch (err) {
        console.error("通信エラー", err)
        this.errors = ['通信に失敗しました']
      } finally {
        this.isLoading = false
      }
    }
  }
}
</script>
