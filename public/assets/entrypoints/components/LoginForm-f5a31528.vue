<!-- LoginForm.vue -->
<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center py-6 px-4 sm:px-6 lg:px-8">
    <div class="max-w-md w-full space-y-8">
      <div>
        <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
          ログインしましょう
        </h2>
      </div>

      <!-- エラーメッセージ -->
      <div v-if="errorMessage" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative">
        {{ errorMessage }}
      </div>

      <!-- 成功メッセージ -->
      <div v-if="successMessage" class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative">
        {{ successMessage }}
      </div>

      <form class="mt-8 space-y-6" @submit.prevent="handleLogin">
        <div class="rounded-md shadow-sm space-y-4">
          <div>
            <label for="name" class="block text-sm font-medium text-gray-700 mb-1">
              ユーザー名
            </label>
            <input
              id="name"
              v-model="loginForm.name"
              type="text"
              required
              class="relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-lg focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
              placeholder="ユーザー名を入力"
            >
          </div>
          <div>
            <label for="password" class="block text-sm font-medium text-gray-700 mb-1">
              パスワード
            </label>
            <input
              id="password"
              v-model="loginForm.password"
              type="password"
              required
              class="relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-lg focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm"
              placeholder="パスワードを入力"
            >
          </div>
        </div>

        <div>
          <button
            type="submit"
            :disabled="isLoading"
            class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors duration-200"
          >
            {{ isLoading ? 'ログイン中...' : 'ログイン' }}
          </button>
        </div>

        <div class="text-center">
          <router-link to="/users/new" class="text-indigo-600 hover:text-indigo-800 text-sm font-medium">
            アカウントをお持ちでない方はこちら
          </router-link>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const loginForm = reactive({
  name: '',
  password: ''
})
const isLoading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const router = useRouter()
const authStore = useAuthStore()

const handleLogin = async () => {
  console.log('Sending login request:', loginForm);
  if (isLoading.value) return
  isLoading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  try {
    const result = await authStore.login(loginForm);
    if (result.success) {
      router.push('/');
    } else {
      errorMessage.value = result.message || 'ログインに失敗しました';
    }
  } catch (error) {
    console.error('ログインエラー:', error);
  } finally {
    isLoading.value = false;
  }
}
</script>
