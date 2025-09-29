<!-- /app/javascript/entrypoints/components/GroupDetail.vue -->
<template>
    <div>
      <h2>{{ group.name }}</h2>
      <p>{{ group.description }}</p>
      <p>メンバー数: {{ group.members_count }}</p>
  
      <button 
        v-if="!isMember" 
        @click="joinGroup"
        class="px-3 py-2 bg-blue-500 text-white rounded">
        グループに参加
      </button>
  
      <button 
        v-else 
        @click="leaveGroup"
        class="px-3 py-2 bg-red-500 text-white rounded">
        グループから脱退
      </button>
    </div>
  </template>
  
  <script setup>
  import axios from "axios";
import { ref, onMounted } from "vue";
  
  const props = defineProps({
    groupId: Number,
    currentUserId: Number
  });
  
  const group = ref({});
  const isMember = ref(false);
  
  // グループ詳細取得
  const fetchGroup = async () => {
    const response = await axios.get(`/groups/${props.groupId}.json`);
    group.value = data;
    // 自分が含まれているか確認
    isMember.value = response.users.some(u => u.id === props.currentUserId);
  };
  
  // 参加処理
  const joinGroup = async () => {
    await axios.post(`/groups/${props.groupId}/join.json`);
    if (response.data) {
      await fetchGroup(); // 再取得して反映
    }
  };
  
  // 脱退処理
  const leaveGroup = async () => {
    await axios.delete(`/api/groups/${props.groupId}/leave.json`);
    if (response.data) {
      await fetchGroup();
    }
  };
  
  onMounted(fetchGroup);
  </script>
  