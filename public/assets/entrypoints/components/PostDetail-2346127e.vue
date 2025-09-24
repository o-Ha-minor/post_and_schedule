<!-- app/javascript/entrypoints/components/PostDetail.vue -->
<template>
  <!-- postが来るまでのガード -->
  <div v-if="post" class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-3xl mx-auto bg-white rounded-xl shadow-md p-6 space-y-6">
      <!-- 投稿者情報 -->
      <div class="flex items-center space-x-4 border-b pb-4">
        <img
          v-if="post.user && post.user.image_url"
          :src="post.user.image_url"
          alt="User Avatar"
          class="h-16 w-16 rounded-full object-cover"
        />
        <div>
          <a :href="`/users/${post.user.id}`" class="text-lg font-semibold text-indigo-600 hover:underline">
            {{ post.user.name }}
          </a>
          <p class="text-sm text-gray-500">{{ formattedDate(post.updated_at) }}</p>
        </div>
      </div>
      <!-- 表示モード -->
    <div v-if="!isEditing">
      <h2 class="text-xl font-bold">{{ post.title }}</h2>
      <p class="text-gray-700">{{ post.content }}</p>
      <img v-if="post.image_url" :src="post.image_url" class="w-64 rounded my-2" />
        <div class="flex items-center">
          <button @click="isEditing = true"
                  class="px-4 py-2 bg-indigo-500 hover:bg-indigo-600 rounded-md text-white mx-2">
            編集する
          </button>
          <!-- 投稿者本人のみ 削除 -->
          <div v-if="isOwner" class="flex space-x-3">
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
          { key: 'title', label: 'タイトル', type: 'text' },
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
      <div class="bg-indigo-50 p-4 rounded-lg">
        <h3 class="font-semibold text-indigo-700 mb-2">コンシェルジュのひとこと</h3>
        <p class="text-gray-700 mb-2">{{ post.ai_comment || "解析中..." }}</p>
        <p class="text-sm text-gray-500">感情判定: {{ post.sentiment || "解析中..." }}</p>
        <p class="text-sm text-gray-500">信頼度スコア: {{ post.sentiment_score ? post.sentiment_score.toFixed(3) : "-" }}</p>
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
import { useRouter } from 'vue-router';
import axios from 'axios';

const props = defineProps({
  postId: Number,
  currentUserId: Number,
  initialPostData: Object
})

const post = ref(props.initialPostData || null)
const newComment = ref("")
const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

const isOwner = computed(() =>
  post.value && props.currentUserId === post.value.user.id
)

const formattedDate = (d) => new Date(d).toLocaleString("ja-JP")

const isEditing = ref(false)

onMounted(async () => {
  if (!post.value && props.postId) {
    const res = await fetch(`/posts/${props.postId}.json`, { headers: { Accept: "application/json" }})
    post.value = await res.json()
  }
})

const toggleLike = async () => {
  if (!post.value) return
  try {
    if (post.value.liked && post.value.like_id) {
      // unlike
      const res = await fetch(`/likes/${post.value.like_id}`, {
        method: 'DELETE',
        headers: { 'X-CSRF-Token': csrfToken, Accept: 'application/json' }
      })
      if (res.ok) {
        const data = await res.json()
        post.value.liked = false
        post.value.like_id = null
        post.value.likes_count = data.likes_count
      }
    } else {
      // like
      const res = await fetch(`/likes`, {
        method: 'POST',
        headers: { 'X-CSRF-Token': csrfToken, 'Content-Type': 'application/json', Accept: 'application/json' },
        body: JSON.stringify({ post_id: post.value.id })
      })
      if (res.ok) {
        const data = await res.json()
        post.value.liked = true
        post.value.like_id = data.id
        post.value.likes_count = data.likes_count
      }
    }
  } catch (e) {
    console.error(e)
  }
}



/** 編集へ遷移 */
const editPost = () => {
  if (!post.value) return
  const router = useRouter();
  router.push({ name: 'PostEdit', params: { id: post.value.id } });
}

/** 削除 */
const deletePost = async () => {
  if (!post.value) return
  if (!confirm("この投稿を削除します。よろしいですか？")) return
  try {
    const res = await fetch(`/api/posts/${post.value.id}`, {
      method: "DELETE",
      headers: { "X-CSRF-Token": csrfToken, Accept: "application/json" }
    })
    if (res.ok) {
      const data = await res.json()
      alert(data.message || "削除しました")
      const router = useRouter();
      router.push('/posts');
    } else {
      console.error("削除失敗:", await res.text())
    }
  } catch (e) {
    console.error("deletePost error:", e)
  }
}

/** コメント作成 */
const submitComment = async () => {
  if (!post.value || !newComment.value.trim()) return
  try {
    const res = await fetch(`/api/posts/${post.value.id}/comments`, {
      method: 'POST',
      headers: { 'X-CSRF-Token': csrfToken, 'Content-Type': 'application/json', Accept: 'application/json' },
      body: JSON.stringify({ comment: { content: newComment.value } })
    })
    if (res.ok) {
      const comment = await res.json()
      post.value.comments = [comment, ...(post.value.comments || [])]
      newComment.value = ""
    } else {
      console.error('comment error', await res.json())
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
    const res = await fetch(`/api/posts/${post.value.id}/comments/${commentId}`, {
      method: "DELETE",
      headers: { "X-CSRF-Token": csrfToken, Accept: "application/json" }
    })
    if (res.ok) {
      post.value.comments = (post.value.comments || []).filter(c => c.id !== commentId)
    }
  } catch (e) {
    console.error("deleteComment error:", e)
  }
}


</script>
