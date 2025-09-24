<template>
    <div class="min-h-screen bg-gray-50 py-8">
      <div class="max-w-6xl mx-auto px-4">
        <div class="mb-8">
          <h1 class="text-3xl font-bold text-gray-900 mb-2">ユーザー一覧</h1>
          <p class="text-gray-600">コミュニティのメンバーを見つけましょう</p>
        </div>
        
        <!-- 検索バー -->
        <div class="mb-6">
          <div class="relative max-w-md">
            <input
              v-model="searchQuery"
              type="text"
              placeholder="ユーザー名で検索..."
              class="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
            >
            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
          </div>
        </div>
  
        <!-- ユーザーグリッド -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          <div
            v-for="user in filteredUsers"
            :key="user.id"
            class="bg-white rounded-xl shadow-md hover:shadow-lg transition-shadow duration-300 p-6"
          >
            <!-- プロフィール画像 -->
            <div class="flex flex-col items-center">
              <div class="relative">
                <img
                  :src="user.image_url || '/user_images/default_image.png'"
                  :alt="`${user.name}のプロフィール画像`"
                  class="w-20 h-20 rounded-full object-cover border-4 border-indigo-100"
                >
                <!-- オンライン状態インジケーター（必要に応じて） -->
                <div class="absolute bottom-1 right-1 w-4 h-4 bg-green-400 rounded-full border-2 border-white"></div>
              </div>
              
              <!-- ユーザー情報 -->
              <div class="mt-4 text-center">
                <h3 class="text-lg font-semibold text-gray-900 truncate">{{ user.name }}</h3>
                <p class="text-sm text-gray-500 mt-1">
                  参加日: {{ formatDate(user.created_at) }}
                </p>
              </div>
  
              <!-- 統計情報 -->
              <div class="mt-4 flex space-x-4 text-center">
                <div>
                  <div class="text-lg font-bold text-indigo-600">{{ user.posts_count || 0 }}</div>
                  <div class="text-xs text-gray-500">投稿</div>
                </div>
                <div>
                  <div class="text-lg font-bold text-indigo-600">{{ user.groups_count || 0 }}</div>
                  <div class="text-xs text-gray-500">グループ</div>
                </div>
              </div>
  
              <!-- アクションボタン -->
              <div class="mt-4 w-full">
                <router-link
                  :to="`/users/${user.id}`"
                  class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200 text-center block"
                >
                  プロフィール表示
                </router-link>
              </div>
            </div>
          </div>
        </div>
  
        <!-- ユーザーが見つからない場合 -->
        <div v-if="filteredUsers.length === 0" class="text-center py-12">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
          </svg>
          <h3 class="mt-2 text-lg font-medium text-gray-900">ユーザーが見つかりません</h3>
          <p class="mt-1 text-gray-500">検索条件を変更してみてください</p>
        </div>
      </div>
    </div>
  </template>
  
  <script>
import axios from 'axios'

  export default {
    name: 'UserIndex',
    props: {
      initialUsers: {
        type: Array,
        default: () => []
      }
    },
    data() {
      return {
        users: this.initialUsers,
        searchQuery: ''
      }
    },
    computed: {
      filteredUsers() {
        if (!this.searchQuery) {
          return this.users
        }
        return this.users.filter(user => 
          user.name.toLowerCase().includes(this.searchQuery.toLowerCase())
        )
      }
    },
    async mounted() {
      if (this.users.length === 0) {
        await this.fetchUsers()
      }
    },
    methods: {
      async fetchUsers() {
        try {
          const response = await axios.get('/api/users')
          this.users = response.data
        } catch (error) {
          console.error('ユーザー取得エラー:', error)
        }
      },
      formatDate(dateString) {
        return new Date(dateString).toLocaleDateString('ja-JP', {
          year: 'numeric',
          month: 'short',
          day: 'numeric'
        })
      }
    }
  }
  </script>