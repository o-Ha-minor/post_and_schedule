<template>
    <div class="p-4 bg-white shadow rounded">
      <h2 class="text-xl font-bold mb-2">{{ eventData.title }}</h2>
      <p class="text-gray-600 mb-1">
        開始: {{ formatDate(eventData.start) }}
      </p>
      <p class="text-gray-600 mb-1">
        終了: {{ formatDate(eventData.end) }}
      </p>
      <p class="mb-4">{{ eventData.description }}</p>
      <div class="flex space-x-2">
        <button @click="$emit('edit')" class="px-3 py-1 bg-blue-500 text-white rounded">
          編集
        </button>
        <button @click="deleteEvent" class="px-3 py-1 bg-red-500 text-white rounded">
          削除
        </button>
      </div>
    </div>
  </template>
  
  <script>
  import axios from "axios";
  
  export default {
    props: {
      eventData: { type: Object, required: true },
    },
    methods: {
      formatDate(date) {
        return new Date(date).toLocaleString();
      },
      async deleteEvent() {
        if (confirm("削除してもよろしいですか？")) {
          await axios.delete(`/events/${this.eventData.id}.json`);
          this.$emit("deleted");
        }
      },
    },
  };
  </script>
  