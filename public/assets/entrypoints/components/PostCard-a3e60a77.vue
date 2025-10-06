<!-- PostCard.vue -->
<script setup>
const props = defineProps({
  post: Object,
  currentUserId: Number
})

const emit = defineEmits(['click-post', 'click-user'])

const formattedDate = (dateStr) => {
  return new Date(dateStr).toLocaleString("ja-JP")
}

const handleCardClick = () => {
  emit('click-post', props.post.id)
}

const handleUserClick = (event) => {
  event.stopPropagation() // カードクリックイベントの伝播を停止
  emit('click-user', props.post.user.id)
}

</script>

<template>
  <div class="bg-indigo-50 rounded-lg p-4 shadow-sm cursor-pointer hover:bg-indigo-100 transition-colors"
       @click="handleCardClick">
    <div class="flex justify-between items-center mb-2" v-if="post.user">
      <button 
        @click="handleUserClick"
        class="font-semibold text-indigo-600 hover:underline cursor-pointer text-left"
      >
        {{ post.user.name }}
      </button>
      <span class="text-xs text-gray-400">{{ formattedDate(post.created_at) }}</span>
    </div>

    <p class="text-gray-700 mb-2">
        {{ post.content }}
    </p>

    <div v-if="post.image_url" class="mt-2">
      <img :src="post.image_url" alt="post image" class="h-40 w-auto rounded-md object-cover" />
    </div>

    <span class="text-xs text-gray-500">{{ post.likes_count }} いいね！</span>
  </div>
</template>
