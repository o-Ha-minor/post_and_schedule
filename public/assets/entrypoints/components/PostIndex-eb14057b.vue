<template>
    <div class="min-h-screen bg-gray-50">
  
      <!-- 新規投稿フォーム（ログイン時のみ） -->
      <div v-if="isLoggedIn" class="max-w-3xl mx-auto mt-8 p-6 bg-white rounded-xl shadow-md">
        <h2 class="text-xl font-semibold mb-4 text-gray-800">新しい話題を投稿</h2>
        <form @submit.prevent="submitPost" class="space-y-4">
          <textarea v-model="newPost.content" 
                    placeholder="今日の話題を書こう..." 
                    class="w-full border-gray-300 rounded-md p-3 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"></textarea>
  
          <div class="flex items-center space-x-4">
            <select v-model="newPost.groupId" class="border-gray-300 rounded-md p-2">
              <option disabled value="">グループを選択</option>
              <option v-for="group in groups" :key="group.id" :value="group.id">
                {{ group.name }}
              </option>
            </select>

            <input type="file" @change="onFileChange" class="text-sm text-gray-500" />

            <button type="submit" 
                    class="bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2 px-4 rounded-lg transition">
              投稿する
            </button>
          </div>
        </form>
      </div>
  
      <!-- 投稿一覧 -->
      <div class="max-w-5xl mx-auto mt-8 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <PostCard
          v-for="post in posts"
          :key="post.id"
          :post="post"
          :current-user-id="currentUserId"
        />
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from 'vue'
  import PostCard from './PostCard.vue'
  import { useRouter } from 'vue-router'
  
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

  const posts = ref([...props.initialPosts])
  const newPost = ref({ content: '', image: null, groupId: '' })

  // 初期データが設定されていない場合の処理
  onMounted(() => {
    if (props.initialPosts && props.initialPosts.length > 0) {
      posts.value = [...props.initialPosts]
    }
  })

  const submitPost = async () => {
    if (!newPost.value.content || !newPost.value.groupId) return;

    const formData = new FormData()
    formData.append("post[content]", newPost.value.content)
    formData.append("post[group_id]", newPost.value.groupId)
    if (newPost.value.image) {
      formData.append("post[image]", newPost.value.image)
    }
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    try {
      const response = await fetch("/posts", {
        method: "POST",
        headers: { "X-CSRF-Token": csrfToken, "Accept": "application/json" },
        body: formData
      })
      
      if (response.redirected) {
        const router = useRouter();
        router.push(response.url);
      } else {
        const data = await response.json()
        if (data) {
          posts.value.unshift(data) // Vueの配列を更新
          newPost.value.content = ""
          newPost.value.image = null
          newPost.value.groupId = ""
        }
      }
    } catch (err) {
      console.error("投稿失敗:", err)
    }
  }

  const onFileChange = (event) => {
    newPost.value.image = event.target.files[0]
  }
  
  </script>
  