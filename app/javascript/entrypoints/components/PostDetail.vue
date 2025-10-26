<!-- app/javascript/entrypoints/components/PostDetail.vue -->
<template>
  <!-- postが来るまでのガード -->
  <div v-if="post" class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-3xl mx-auto bg-white rounded-xl shadow-md p-6 space-y-6">
      <!-- 投稿者情報 -->
      <div class="flex items-center space-x-4 border-b pb-4">
        <img
          v-if="post.user.image_url"
          :src="post.user?.image_url"
          alt="User Avatar"
          class="h-16 w-16 rounded-full object-cover"
        />
        <div>
          <router-link
            v-if="post.user.id"
            :to="`/users/${post.user.id}`"
            class="text-lg font-semibold text-indigo-600 hover:underline"
          >
            {{ post.user.name }}
          </router-link>
          <p class="text-sm text-gray-500">{{ formattedDate(post.updated_at) }}</p>
        </div>
      </div>
      <!-- 表示モード -->
      <div v-if="!isEditing">
        <p class="text-gray-700">{{ post.content }}</p>
        <img v-if="post.image_url" :src="post.image_url" class="w-64 rounded my-2" />
        <div v-if="isOwner" class="flex items-center">
          <button @click="isEditing = true"
                  class="px-4 py-2 bg-indigo-500 hover:bg-indigo-600 rounded-md text-white mx-2">
            編集する
          </button>
          <!-- 投稿者本人のみ 削除 -->
          <div class="flex space-x-3">
            <button @click="deletePost" class="px-4 py-2 bg-indigo-500 hover:bg-indigo-600 rounded-md text-white">
              削除
            </button>
          </div>
        </div>
      </div>

      <!-- 編集モード -->
      <div v-else>
        <FormComponent
          :fields="[
            { key: 'content', label: '本文', type: 'textarea' },
            { key: 'image', label: '画像', type: 'image' }
          ]"
          :record="post"
          @submit="savePost"
        />

        <button @click="isEditing = false"
                class="bg-gray-400 text-white px-3 py-1 rounded mt-2">
          キャンセル
        </button>
      </div>
      <div>
        <!-- いいね -->
        <div class="flex items-center space-x-4">
          <span class="text-sm text-gray-600">{{ post.likes_count || 0 }} いいね！</span>
          <button
            @click="toggleLike"
            class="px-4 py-2 rounded-md text-white"
            :class="post.liked ? 'bg-indigo-500 hover:bg-indigo-600' : 'bg-pink-500 hover:bg-pink-600'"
          >
            {{ post.liked ? 'いいね解除' : 'いいね' }}
          </button>
        </div>
      </div>



      <!-- AIコメント -->
      <div class="bg-indigo-50 p-4 rounded-lg flex items-start space-x-4">
        <img
          v-if="aiImageUrl"
          :src="aiImageUrl"
          alt="AIキャラ"
          class="w-40 h-40 rounded-full object-cover border-2 border-indigo-200"
        />
        <div>
          <h3 class="font-semibold text-indigo-700 mb-2">今日のひとこと</h3>
          <p class="text-gray-700 mb-2">{{ post.ai_comment || "解析中..." }}</p>
          <p class="text-sm text-gray-500">感情判定: {{ post.sentiment || "解析中..." }}</p>
          <p class="text-sm text-gray-500">信頼度スコア: {{ post.sentiment_score ? post.sentiment_score.toFixed(3) : "-" }}</p>
        </div>
      </div>

      <!-- コメントフォーム -->
      <div>
        <h3 class="text-lg font-semibold mb-2">コメントを加える</h3>
        <form @submit.prevent="submitComment" class="space-y-3">
          <input
            v-model="newComment"
            type="text"
            placeholder="コメントを入力..."
            class="w-full border-gray-300 rounded-md p-2 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
          />
          <button type="submit" class="bg-indigo-500 hover:bg-indigo-600 text-white px-4 py-2 rounded-md">
            コメントする
          </button>
        </form>
      </div>

      <!-- コメント一覧 -->
      <div v-if="post.comments && post.comments.length > 0" class="space-y-4 mt-6">
        <CommentCard
          v-for="comment in post.comments"
          :key="comment.id"
          :comment="comment"
          :current-user-id="currentUserId"
          @delete="deleteComment(comment.id)"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from "vue"
import CommentCard from "./CommentCard.vue"
import FormComponent from "./FormComponent.vue"
import { useRouter, useRoute } from 'vue-router';
import axios from "axios";

const props = defineProps({
  postId: Number,
  currentUserId: Number,
  initialPostData: Object
})

const post = ref(props.initialPostData || null)
const newComment = ref("")
const isOwner = computed(() =>
  post.value?.user && props.currentUserId === post.value.user.id
)
const formattedDate = (d) => new Date(d).toLocaleString("ja-JP")
const isEditing = ref(false)
const router = useRouter();
const route = useRoute();

onMounted(async () => {
  if (!post.value && props.postId) {
    try {
      const response = await axios.get(`/api/posts/${props.postId}`)
      if (response.data) {
        const responseData = response.data
        if (responseData.success && responseData.data) {
          post.value = responseData.data
        }
      }
      if (route.query.from === 'new_post') {
      toast.success('投稿が完了しました！')
      }
    } catch (error) {
      toast.error("ネットワークエラー:", error)
    }
  }
})

const toggleLike = async () => {
  if (!post.value) return
  try {
    if (post.value.liked && post.value.like_id) {
      // unlike
      const response = await axios.delete(`/api/likes/${post.value.like_id}`)
      if (response.data) {
        post.value.liked = false
        post.value.like_id = null
        post.value.likes_count = response.data.likes_count
      }
    } else {
      // like
      const response = await axios.post('/api/likes', {
        post_id: post.value.id
      })
      if (response.data) {
        post.value.liked = true
        post.value.like_id = response.data.id
        post.value.likes_count = response.data.likes_count
      }
    }
  } catch (e) {
    console.error(e)
  }
}

/** 投稿削除 */
const deletePost = async () => {
  if (!post.value) return
  if (!confirm("この投稿を削除します。よろしいですか？")) return
  try {
    await axios.delete(`/api/posts/${post.value.id}`);
    router.push({ name: 'PostIndex' });
    } catch (e) {
    console.error("deletePost error:", e)
  }
}

/** コメント作成 */
const submitComment = async () => {
  if (!post.value || !newComment.value.trim()) return
  try {
    const response = await axios.post(`/api/posts/${post.value.id}/comments`, {
      comment: { content: newComment.value }
    })
    if (response.data) {
      const comment = response.data
      post.value.comments = [comment, ...(post.value.comments || [])]
      newComment.value = ""
    }
  } catch (e) {
    console.error(e)
  }
}

/** コメント削除 */
const deleteComment = async (commentId) => {
  if (!post.value) return
  if (!confirm("コメントを削除します。よろしいですか？")) return
  try {
    const response = await axios.delete(`/api/posts/${post.value.id}/comments/${commentId}`)
    if (response.data) {
      post.value.comments = (post.value.comments || []).filter(c => c.id !== commentId)
    }
  } catch (e) {
    console.error("deleteComment error:", e)
  }
}

/** 投稿編集保存 */
const savePost = async (updated) => {
  try {
    const formData = new FormData()
    formData.append("post[content]", updated.content)
    if (updated.image) formData.append("post[image]", updated.image)

    const response = await axios.patch(`/api/posts/${post.value.id}`, formData)
    if (response.data) {
      post.value = response.data.data
      isEditing.value = false
    }
    router.push({ name: 'PostIndex' });
  } catch (err) {
    console.error("network error", err)
  }
}

const aiImageUrl = ref(null)
const currentUser = ref(null) // もしログインユーザーを表示するなら

onMounted(async () => {
  try {
    // ユーザーのAIキャラ取得
    const userRes = await axios.get(`/api/users/${currentUser.value?.id || 3}`)
    const aiCharacter = userRes.data.data.ai_character || 'tanuki'

    // AI画像URL生成API呼び出し
    const res = await axios.get('/api/ai_images/generate_image_url')
    aiImageUrl.value = res.data.data.image_url || `/ai_images/${aiCharacter}_neutral.png`

  } catch (err) {
    console.error('AI画像URL取得エラー:', err)
  }
  
})
</script>
