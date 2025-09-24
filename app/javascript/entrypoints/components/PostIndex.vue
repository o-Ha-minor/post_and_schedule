<template>
    <div class="min-h-screen bg-gray-50">
  
      <!-- 新規投稿フォーム（ログイン時のみ） -->
      <div v-if="isLoggedIn" class="max-w-3xl mx-auto mt-8 p-6 bg-white rounded-xl shadow-md">
        <h2 class="text-xl font-semibold mb-4 text-gray-800">新しい話題を投稿</h2>
        <form @submit.prevent="submitPost" class="space-y-4">
          <textarea v-model="newPost.content" 
                    placeholder="今日の話題を書こう..." 
                    rows="4"
                    class="w-full border-gray-300 rounded-md p-3 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"></textarea>
  
          <div class="flex flex-col space-y-4 sm:flex-row sm:items-center sm: space-y-0 sm:space-x-4">
            <select v-model="newPost.groupId" class="border-gray-300 rounded-md p-2 flex-1"required>
              <option value="" disabled>グループを選択</option>
              <option v-for="group in groups" :key="group.id" :value="group.id">
                {{ group.name }}
              </option>
            </select>

            <input type="file" @change="onFileChange"
            accept="image/*"
            class="text-sm text-gray-500 flex-1" />

            <button type="submit" 
                    :disabled="!newPost.content.trim() || !newPost.groupId"
                    class="bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2 px-4 
                           rounded-lg transition w-full sm:w-auto">
              投稿する
            </button>
          </div>
          <!-- エラーメッセージ表示 -->
          <div v-if="errorMessage" class="text-red-500 text-sm mt-2">
            {{ errorMessage }}
          </div>
        </form>
      </div>

      <!-- ログインしていない場合のメッセージ -->
      <div v-else class="max-w-3xl mx-auto mt-8 p-6 bg-yellow-50 rounded-xl border border-yellow-200">
        <p class="text-yellow-800">投稿するにはログインが必要です。</p>
      </div>
  
      <!-- 投稿一覧 -->
      <div class="max-w-5xl mx-auto mt-8 px-4 pb-8">
        <h2 class="text-2xl font-bold mb-6 text-gray-800">投稿一覧</h2>
        
        <!-- 投稿がない場合のメッセージ -->
        <div v-if="posts.length === 0" class="text-center py-12 bg-white rounded-lg shadow">
          <p class="text-gray-500">まだ投稿がありません。</p>
        </div>
        
        <!-- 投稿グリッド -->
        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <PostCard
            v-for="post in posts"
            :key="post.id"
            :post="post"
            :current-user-id="currentUserId"
            @click-post="goToPostDetail"
            @click-user="goToUserDetail"
          />
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from 'vue'
  import PostCard from './PostCard.vue'
  import { useToast } from 'vue-toastification'
  import { useRouter } from 'vue-router'
import axios from 'axios'
  const router = useRouter()


  
  const props = defineProps({
    isLoggedIn: Boolean,
    currentUserId: [Number, String],
    currentUserName: String,
    groups: {
      type: Array,
      default: () => []
    },
    initialPosts: {
      type: Array,
      default: () => []
    }
  })

  const toast = useToast()
  const posts = ref([...props.initialPosts])
  const newPost = ref({ content: '', image: null, groupId: '' })
  const errorMessage = ref('')

  // 初期データが設定されていない場合の処理
  onMounted(async() => {
    console.log('Groups from props:', props.groups)
    if (props.initialPosts && props.initialPosts.length > 0) {
      posts.value = [...props.initialPosts]
    } else {
    // 投稿一覧を取得
    await fetchPosts()
    }
  })

  // 投稿一覧を取得
const fetchPosts = async () => {
  try {
    const response = await axios.get('/api/posts', {
      headers: {
        'Accept': 'application/json',
        'X-CSRF-Token': getCsrfToken()
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      posts.value = data.data || data.posts || []
    }
  } catch (error) {
    console.error('投稿の取得に失敗しました:', error)
    toast.error('投稿の取得に失敗しました')
  }
}

  // CSRFトークン取得関数
  const getCsrfToken = () => {
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
    if (!token) {
      console.error('CSRFトークンが見つかりません')
    }
    return token || ''
  }

  const submitPost = async () => {
    errorMessage.value = ''
    
    // バリデーション
    if (!newPost.value.content.trim()) {
      errorMessage.value = '内容を入力してください'
      return
    }
    
    if (!newPost.value.groupId) {
      errorMessage.value = 'グループを選択してください'
      return
    }

    const formData = new FormData()
    formData.append('post[content]', newPost.value.content.trim())
    formData.append('post[group_id]', newPost.value.groupId)
  
    if (newPost.value.image) {
      formData.append('post[image]', newPost.value.image)
    }

    try {
      const response = await axios.post('/api/posts', {
        method: 'POST',
        headers: { 
          'X-CSRF-Token': getCsrfToken(),
          'Accept': 'application/json'
        },
        body: formData
      })
    
      const data = await response.json()
      console.log('Response:', { status: response.status, data })
    
    
    if (response.ok && data.success) {
        const newPostData = data.data || data.post
        if (newPostData) {
          posts.value.unshift(newPostData)

          toast.success(data.message || '投稿しました！')

           // フォームをリセット
          newPost.value = { content: '', image: null, groupId: '' }
          const fileInput = document.querySelector('input[type="file"]')
          if (fileInput) fileInput.value = ''

          router.push({ name: 'PostDetail', params: { id: newPostData.id } })
      }
      
      errorMessage.value = ''
    } else {
      // エラー処理
      errorMessage.value = data.message || data.errors?.join(', ') || '投稿に失敗しました'
      toast.error(errorMessage.value)
    }
  } catch (err) {
    console.error('投稿エラー:', err)
    errorMessage.value = 'ネットワークエラーが発生しました'
    toast.error('投稿に失敗しました')
  }
}

  const onFileChange = (event) => {
    const file = event.target.files[0]
  if (file) {
    // ファイルサイズチェック (5MB以下)
    if (file.size > 5 * 1024 * 1024) {
      toast.error('ファイルサイズは5MB以下にしてください')
      event.target.value = ''
      return
    }
    newPost.value.image = file
  }
  }

  // 投稿詳細ページに遷移
  const goToPostDetail = (postId) => {
    router.push({ name: 'PostDetail', params: { id: postId } })
  }

  // ユーザー詳細ページに遷移
  const goToUserDetail = (userId) => {
    router.push({ name: 'UserDetail', params: { id: userId } })
  }
  
  </script>

  <style scoped>
  /* フォーム要素のフォーカススタイル */
  textarea:focus,
  select:focus {
    outline: none;
    box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
  }
  </style>