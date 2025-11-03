<template>
  <div class="bg-gray-50 rounded-lg p-4 shadow-sm">
    <div class="flex justify-between items-center mb-2">
      <router-link to="`/users/${comment.user.id}`" class="font-semibold text-indigo-600 hover:underline">
        {{ comment.user.name }}
      </router-link>
      <span class="text-xs text-gray-400">{{ formattedDate(comment.created_at) }}</span>
    </div>
    <p class="text-gray-700 mb-2">{{ comment.content }}</p>

    <div v-if="comment.image_url" class="mt-2">
      <img :src="comment.image_url" alt="comment image" class="h-12 w-12 rounded-md object-cover" />
    </div>

    <div v-if="comment.user.id === currentUserId" class="mt-2">
      <button
        @click="$emit('delete')"
        class="text-sm text-red-500 hover:text-red-700"
      >
        ×削除
      </button>
    </div>
  </div>
</template>

<script setup>
import router from '../../router';

const props = defineProps({
  comment: Object,
  currentUserId: Number
})

const formattedDate = (dateStr) => new Date(dateStr).toLocaleString("ja-JP")
</script>
