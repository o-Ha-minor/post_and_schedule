<template>
    <form @submit.prevent="handleSubmit" class="space-y-4">
      <div v-for="field in fields" :key="field.key" class="flex flex-col">
        <label class="font-semibold mb-1">{{ field.label }}</label>
  
        <!-- 入力タイプごとに切り替え -->
        <input v-if="field.type === 'text'"
               v-model="form[field.key]"
               type="text"
               class="border rounded p-2" />
  
        <textarea v-if="field.type === 'textarea'"
                  v-model="form[field.key]"
                  class="border rounded p-2"></textarea>
  
        <input v-if="field.type === 'date'"
               v-model="form[field.key]"
               type="date"
               class="border rounded p-2" />
  
        <!-- プレビュー付きの画像アップロード -->
        <div v-if="field.type === 'image'" class="flex flex-col gap-2">
          <input type="file" @change="onFileChange(field.key, $event)" />
          <img v-if="form.preview[field.key]" 
               :src="form.preview[field.key]" 
               class="w-32 h-32 object-cover rounded" />
        </div>
      </div>
  
      <button type="submit"
              class="bg-indigo-600 text-white px-4 py-2 rounded shadow">
        保存する
      </button>
    </form>
  </template>
  
  <script setup>
  import { reactive } from "vue"
  
  const props = defineProps({
    fields: { type: Array, required: true },
    record: { type: Object, required: false, default: () => ({}) }
  })
  const emits = defineEmits(["submit"])
  
  // フォーム状態
  const form = reactive({
    ...props.record,
    preview: {}
  })
  
  const onFileChange = (key, event) => {
    const file = event.target.files[0]
    if (file) {
      form[key] = file
      form.preview[key] = URL.createObjectURL(file)
    }
  }
  
  const handleSubmit = () => {
    emits("submit", form)
  }
  </script>
  