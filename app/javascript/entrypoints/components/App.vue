<template>
  <div>
    <!-- 認証チェック中のローディング -->
    <div v-if="!authStore.initialized" class="min-h-screen flex items-center justify-center">
      <div class="text-center">
        <div class="animate-spin rounded-full h-32 w-32 border-b-2 border-indigo-600 mx-auto"></div>
        <p class="mt-4 text-gray-600">読み込み中...</p>
      </div>
    </div>
    
    <!-- メインコンテンツ -->
    <div v-else>
      <Header 
        :is-logged-in="authStore.isLoggedIn"
        :current-user-id="authStore.currentUserId"
        :current-user-name="authStore.currentUserName"
        @logout="handleLogout"
      />
      
      <main class="pt-16">
        <router-view 
          :key="$route.fullPath"
          :is-logged-in="authStore.isLoggedIn"
          :current-user-id="authStore.currentUserId"
          :current-user-name="authStore.currentUserName"
          :groups="authStore.groups"
        />
      </main>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import Header from './Header.vue'

const authStore = useAuthStore()
const router = useRouter()

onMounted(async () => {
  // アプリ起動時に認証状態をチェック
  await authStore.checkAuth()
})

const handleLogout = async () => {
  const result = await authStore.logout()
  if (result.success) {
    router.push('/')
  }
}
</script>