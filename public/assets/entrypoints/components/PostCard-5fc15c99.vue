<!-- PostCard.vue -->
<script setup>
const props = defineProps({
  post: Object,
  currentUserId: Number
})

const formattedDate = (dateStr) => {
  return new Date(dateStr).toLocaleString("ja-JP")
}
</script>

<template>
  <div class="bg-indigo-50 rounded-lg p-4 shadow-sm">
    <div class="flex justify-between items-center mb-2" v-if="post.user">
      <a :href="`/users/${post.user.id}`" class="font-semibold text-indigo-600 hover:underline">
        {{ post.user.name }}
      </a>
      <span class="text-xs text-gray-400">{{ formattedDate(post.created_at) }}</span>
    </div>

    <p class="text-gray-700 mb-2">
      <a :href="`/api/posts/${post.id}`" class="hover:underline">
        {{ post.content }}
      </a>
    </p>

    <div v-if="post.image_url" class="mt-2">
      <img :src="post.image_url" alt="post image" class="h-40 w-auto rounded-md object-cover" />
    </div>

    <span class="text-xs text-gray-500">{{ post.likes_count }} いいね！</span>
  </div>
</template>
