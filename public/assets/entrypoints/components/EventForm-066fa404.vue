<template>
    <div class="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center">
      <div class="bg-white p-6 rounded-lg shadow-lg w-96">
        <h2 class="text-xl font-bold mb-4">
          {{ eventData?.id ? "イベントを編集" : "新規イベント" }}
        </h2>
  
        <form @submit.prevent="saveEvent">
          <div class="mb-2">
            <label class="block text-sm">タイトル</label>
            <input v-model="form.title" type="text" class="border p-1 w-full rounded" required />
          </div>
  
          <div class="mb-2">
            <label class="block text-sm">開始日時</label>
            <input v-model="form.start" type="datetime-local" class="border p-1 w-full rounded" required />
          </div>
  
          <div class="mb-2">
            <label class="block text-sm">終了日時</label>
            <input v-model="form.end" type="datetime-local" class="border p-1 w-full rounded" required />
          </div>
  
          <div class="mb-2">
            <label class="block text-sm">詳細</label>
            <textarea v-model="form.description" class="border p-1 w-full rounded"></textarea>
          </div>
  
          <div class="flex justify-end gap-2 mt-4">
            <button type="button" @click="$emit('close')" class="px-3 py-1 bg-gray-300 rounded">キャンセル</button>
            <button type="submit" class="px-3 py-1 bg-blue-600 text-white rounded">保存</button>
          </div>
        </form>
      </div>
    </div>
  </template>
  
  <script>
  import axios from "axios";
  
  export default {
    props: { eventData: Object },
    data() {
      return {
        form: {
          title: this.eventData?.title || "",
          start: this.eventData?.start || "",
          end: this.eventData?.end || "",
          description: this.eventData?.description || "",
        },
      };
    },
    methods: {
      async saveEvent() {
        if (this.eventData?.id) {
          await axios.put(`/events/${this.eventData.id}.json`, { event: this.form });
        } else {
          await axios.post("/events.json", { event: this.form });
        }
        this.$emit("saved");
        this.$emit("close");
      },
    },
  };
  </script>
  