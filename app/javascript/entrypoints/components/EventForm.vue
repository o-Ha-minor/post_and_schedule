<template>
  <div class="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-50">
    <div class="bg-white p-6 rounded-lg shadow-lg w-96 max-h-[90vh] overflow-y-auto">
      <h2 class="text-xl font-bold mb-4">
        {{ eventData?.id ? "イベントを編集" : "新規イベント" }}
      </h2>

      <form @submit.prevent="saveEvent">
        <div class="mb-4">
          <label class="block text-sm font-medium mb-1">タイトル</label>
          <input 
            v-model="form.title" 
            type="text" 
            class="border border-gray-300 p-2 w-full rounded focus:outline-none focus:ring-2 focus:ring-blue-500" 
            required 
            placeholder="イベントタイトルを入力"
          />
        </div>

        <div class="mb-4">
          <label class="block text-sm font-medium mb-1">開始日時</label>
          <input 
            v-model="form.start" 
            type="datetime-local" 
            class="border border-gray-300 p-2 w-full rounded focus:outline-none focus:ring-2 focus:ring-blue-500" 
            required 
          />
        </div>

        <div class="mb-4">
          <label class="block text-sm font-medium mb-1">終了日時</label>
          <input 
            v-model="form.end" 
            type="datetime-local" 
            class="border border-gray-300 p-2 w-full rounded focus:outline-none focus:ring-2 focus:ring-blue-500" 
            required 
          />
        </div>

        <div class="mb-4">
          <label class="block text-sm font-medium mb-1">詳細</label>
          <textarea 
            v-model="form.description" 
            class="border border-gray-300 p-2 w-full rounded focus:outline-none focus:ring-2 focus:ring-blue-500" 
            rows="3"
            placeholder="イベントの詳細を入力（任意）"
          ></textarea>
        </div>

        <div class="mb-4">
          <label class="block text-sm font-medium mb-1">グループ</label>
          <select
            v-model="form.group_id"
            class="border border-gray-300 p-2 w-full rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          >
            <option value="">グループを選択</option>
            <option v-for="group in availableGroups" :key="group.id" :value="group.id">
              {{ group.name }}
            </option>
          </select>
        </div>


        <div class="flex justify-end gap-2 mt-6">
          <button 
            type="button" 
            @click="$emit('close')" 
            class="px-4 py-2 bg-gray-300 text-gray-700 rounded hover:bg-gray-400 transition-colors"
          >
            キャンセル
          </button>
          <button 
            v-if="eventData?.id" 
            type="button" 
            @click="deleteEvent" 
            class="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 transition-colors"
          >
            削除
          </button>
          <button 
            type="submit" 
            class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
            :disabled="!form.title || !form.start || !form.end"
          >
            保存
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  props: { 
    eventData: {
      type: Object,
      default: null
    },
    groups: {
      type: Array,
      default: () => []
    }
  },
  emits: ['close', 'saved', 'deleted'],
  data() {
    return {
      form: {
        title: "",
        start: "",
        end: "",
        description: "",
        group_id: ""
      },
      localGroups: []  // propsと区別するためにlocalGroupsに変更
    };
  },
  
  computed: {
    // 利用可能なグループ（propsを優先、なければlocalGroupsを使用）
    availableGroups() {
      return this.groups && this.groups.length > 0 ? this.groups : this.localGroups;
    }
  },

  async mounted() {
    // propsでgroupsが渡されていない場合のみAPIからfetch
    if (!this.groups || this.groups.length === 0) {
      await this.fetchGroups();
    }
    
    // イベントデータが渡されている場合はフォームを初期化
    if (this.eventData) {
      this.initializeForm(this.eventData);
    }
    
    console.log('Available groups:', this.availableGroups);
    console.log("props.groups:", this.groups);
    console.log("fetched localGroups:", this.localGroups);
  },

  watch: {
    eventData: {
      handler(newEventData) {
        console.log('EventData changed:', newEventData);
        this.resetForm();
        if (newEventData) {
          this.initializeForm(newEventData);
        }
      },
      immediate: true,
      deep: true
    },
    'form.start'(newStart) {
      if (newStart && this.form.end && new Date(newStart) > new Date(this.form.end)) {
        const startDate = new Date(newStart);
        startDate.setHours(startDate.getHours() + 1);
        this.form.end = this.formatDateForInput(startDate);
      }
    }
  },

  methods: {
    async deleteEvent() {
        if (confirm("削除してもよろしいですか？")) {
          await axios.delete(`/events/${this.eventData.id}.json`);
          this.$emit("deleted");
        }
      },
    // グループを取得するメソッドを追加
    async fetchGroups() {
      try {
        const response = await axios.get("/groups.json");
        this.localGroups = response.data;
        console.log("Fetched groups:", this.localGroups);
      } catch (error) {
        console.error("グループ取得エラー:", error);
        this.localGroups = [];
      }
    },

    resetForm() {
      this.form = {
        title: "",
        start: "",
        end: "",
        description: "",
        group_id: ""
      };
    },
    
    initializeForm(eventData) {
      console.log('Initializing form with:', eventData);
      
      this.form.title = eventData.title || "";
      this.form.description = eventData.description || "";
      this.form.group_id = eventData.group_id || "";
      
      if (eventData.start) {
        this.form.start = this.formatDateForInput(eventData.start);
      } else {
        const now = new Date();
        now.setMinutes(0, 0, 0);
        this.form.start = this.formatDateForInput(now);
      }
      
      if (eventData.end) {
        this.form.end = this.formatDateForInput(eventData.end);
      } else {
        const startDate = new Date(this.form.start);
        if (!isNaN(startDate.getTime())) {
          startDate.setHours(startDate.getHours() + 1);
          this.form.end = this.formatDateForInput(startDate);
        }
      }
      
      console.log('Form initialized:', this.form);
    },
    
    formatDateForInput(dateInput) {
      try {
        let date;
        
        if (!dateInput) {
          return '';
        }
        
        if (typeof dateInput === 'string') {
          if (dateInput.length === 10) {
            date = new Date(dateInput + 'T00:00:00');
          } else {
            date = new Date(dateInput);
          }
        } else {
          date = new Date(dateInput);
        }
        
        if (isNaN(date.getTime())) {
          console.warn('Invalid date:', dateInput);
          return '';
        }
        
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        
        return `${year}-${month}-${day}T${hours}:${minutes}`;
      } catch (error) {
        console.error('Date formatting error:', error, dateInput);
        return '';
      }
    },
    
    async saveEvent() {
      try {
        if (!this.form.title.trim()) {
          alert('タイトルを入力してください。');
          return;
        }
        
        if (!this.form.start || !this.form.end) {
          alert('開始日時と終了日時を入力してください。');
          return;
        }
        
        const startDate = new Date(this.form.start);
        const endDate = new Date(this.form.end);
        
        if (startDate >= endDate) {
          alert('終了日時は開始日時より後に設定してください。');
          return;
        }
        
        const eventPayload = {
          title: this.form.title.trim(),
          start: this.form.start,
          end: this.form.end,
          description: this.form.description,
          group_id: this.form.group_id,
        };

        let response;
        if (this.eventData?.id) {
          response = await axios.put(`/events/${this.eventData.id}.json`, { event: eventPayload });
        } else {
          response = await axios.post("/events.json", { event: eventPayload });
        }
        
        console.log('Save response:', response.data);
        this.$emit("saved");
        this.$emit("close");
      } catch (error) {
        console.error('イベント保存エラー:', error);
        
        if (error.response) {
          console.error('Response status:', error.response.status);
          console.error('Response data:', error.response.data);
          
          if (error.response.data && error.response.data.errors) {
            const errors = error.response.data.errors;
            alert('エラー: ' + Object.values(errors).flat().join(', '));
          } else if (error.response.status === 422) {
            alert('入力データに問題があります。内容を確認してください。');
          } else if (error.response.status === 500) {
            alert('サーバーエラーが発生しました。しばらく時間をおいて再度お試しください。');
          } else {
            alert('保存に失敗しました。もう一度お試しください。');
          }
        } else {
          alert('ネットワークエラーが発生しました。接続を確認してください。');
        }
      }
    }
  }
};
</script>