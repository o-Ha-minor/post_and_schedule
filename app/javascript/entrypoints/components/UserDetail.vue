<template>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-4xl mx-auto px-4">
      <!-- ユーザー情報カード -->
      <div class="bg-white rounded-xl shadow-lg p-8 mb-8">
        <div class="flex flex-col md:flex-row items-center md:items-start space-y-6 md:space-y-0 md:space-x-8">
          <!-- プロフィール画像 -->
          <div class="flex-shrink-0">
            <img
              :src="user.image_url || '/user_images/default_image.png'"
              :alt="`${user.name}のプロフィール画像`"
              class="w-32 h-32 rounded-full object-cover border-4 border-indigo-100"
            >
          </div>
          
          <!-- ユーザー情報 -->
          <div class="flex-grow text-center md:text-left">
            <h1 class="text-3xl font-bold text-gray-900 mb-2">{{ user.name }}</h1>
            <p class="text-gray-600 mb-4">
              参加日: {{ formatDate(user.created_at) }}
            </p>
            
            <!-- 統計情報 -->
            <div class="flex justify-center md:justify-start space-x-8">
              <div class="text-center">
                <div class="text-2xl font-bold text-indigo-600">{{ user.posts?.length || 0 }}</div>
                <div class="text-sm text-gray-500">投稿</div>
              </div>
              <div class="text-center">
                <div class="text-2xl font-bold text-indigo-600">{{ user.groups?.length || 0 }}</div>
                <div class="text-sm text-gray-500">グループ</div>
              </div>
            </div>
          </div>
          
          <!-- 編集ボタン（自分のプロフィールの場合） -->
          <div v-if="isOwnProfile" class="flex-shrink-0">
            <a
              :href="`/users/${user.id}/edit`"
              class="bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-6 rounded-lg transition-colors duration-200"
            >
              プロフィール編集
            </a>
          </div>
        </div>
      </div>
      
      <!-- 投稿一覧 -->
      <div class="bg-white rounded-xl shadow-lg p-8">
        <h2 class="text-2xl font-bold text-gray-900 mb-6">投稿一覧</h2>
        
        <div v-if="user.posts && user.posts.length > 0" class="space-y-6">
          <div
            v-for="post in user.posts"
            :key="post.id"
            class="border-b border-gray-200 pb-6 last:border-b-0"
          >
            <div class="flex items-start space-x-4">
              <img
                :src="user.image_url || '/user_images/default_image.png'"
                :alt="`${user.name}のプロフィール画像`"
                class="w-12 h-12 rounded-full object-cover"
              >
              <div class="flex-grow">
                <div class="flex items-center space-x-2 mb-2">
                  <h3 class="font-semibold text-gray-900">{{ user.name }}</h3>
                  <span class="text-gray-500 text-sm">{{ formatDate(post.created_at) }}</span>
                </div>
                <div class="text-gray-700 whitespace-pre-wrap">{{ post.content }}</div>
                <div class="mt-3 flex items-center space-x-4">
                  <span class="text-sm text-gray-500">
                    {{ post.likes_count || 0 }} いいね
                  </span>
                  <a
                    :href="`/posts/${post.id}`"
                    class="text-indigo-600 hover:text-indigo-800 text-sm font-medium"
                  >
                    詳細を見る
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div v-else class="text-center py-12">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z" />
          </svg>
          <h3 class="mt-2 text-lg font-medium text-gray-900">投稿がありません</h3>
          <p class="mt-1 text-gray-500">まだ投稿がありません</p>
        </div>
      </div>
      
      <div v-if="user.groups && user.groups.length > 0" class="bg-white rounded-xl shadow-lg p-8">
          <h2 class="text-2xl font-bold text-gray-900 mb-6">参加グループ</h2>
          
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div
              v-for="group in user.groups"
              :key="group.id"
              class="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow duration-200"
            >
              <div class="flex items-start justify-between mb-2">
                <h3 class="font-semibold text-gray-900">{{ group.name }}</h3>
                <a
                  :href="`/groups/${group.id}`"
                  class="text-indigo-600 hover:text-indigo-800 text-sm font-medium"
                >
                  詳細
                </a>
              </div>
              <p class="text-gray-600 text-sm mb-3">{{ group.description }}</p>
              <div class="text-xs text-gray-500">
                メンバー: {{ group.members_count || 0 }}人
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
</template>

<script>
export default {
  name: 'UserDetail',
  props: {
    initialUserData: {
      type: Object,
      default: () => ({})
    },
    currentUserId: {
      type: [String, Number],
      default: null
    }
  },
  data() {
    return {
      user: this.initialUserData
    }
  },
  computed: {
    isOwnProfile() {
      return this.currentUserId && Number(this.currentUserId) === Number(this.user.id)
    }
  },
  async mounted() {
    // ユーザー情報が空の場合、APIから取得
    if (!this.user.id) {
      await this.fetchUser()
    }
  },
  methods: {
    async fetchUser() {
      try {
        const userId = window.location.pathname.split('/').pop()
        const response = await fetch(`/users/${userId}.json`)
        if (response.ok) {
          this.user = await response.json()
        }
      } catch (error) {
        console.error('ユーザー情報取得エラー:', error)
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