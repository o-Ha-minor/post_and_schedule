<template>
    <div class="fixed inset-0 bg-black bg-opacity-30 flex items-center justify-center z-50">
      <div class="bg-white p-6 rounded-lg shadow-lg w-96 max-h-[90vh] overflow-y-auto">
        <h2 class="text-xl font-bold mb-4">
          {{ taskData?.id ? "タスクを編集" : "新規タスク" }}
        </h2>
  
        <form @submit.prevent="saveTask">
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">タイトル</label>
            <input 
              v-model="form.title" 
              type="text" 
              class="border border-gray-300 p-2 w-full rounded focus:outline-none focus:ring-2 focus:ring-blue-500" 
              required 
              placeholder="タスク名を入力"
            />
          </div>
  
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">詳細</label>
            <textarea 
              v-model="form.description" 
              class="border border-gray-300 p-2 w-full rounded focus:outline-none focus:ring-2 focus:ring-blue-500" 
              rows="3"
              placeholder="タスクの詳細を入力（任意）"
            ></textarea>
          </div>
  
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">期限</label>
            <input
              v-model="form.due_date"
              type="date"
              class="border border-gray-300 p-2 w-full rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div class="mb-4" v-if="form.due_date">
            <label class="flex items-center space-x-2">
                <input
                v-model="form.create_event"
                type="checkbox"
                class="rounded border-gray-300 focus:ring-2 focus:ring-blue-500"
                />
                <span class="text-sm font-medium">カレンダーにイベントとして追加する</span>
            </label>
            <p class="text-xs text-gray-500 mt-1">
                チェックすると、期限日にイベントが作成されます
            </p>
          </div>
  
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">優先度</label>
            <select
              v-model="form.priority" 
              class="border border-gray-300 p-2 w-full rounded focus:outline-none focus:ring-2 focus:ring-blue-500"   
            >
              <option value="">選択してください</option>
              <option value="low">低</option>
              <option value="medium">中</option>
              <option value="high">高</option>
            </select>
          </div>
  
          <div class="mb-4">
            <label class="block text-sm font-medium mb-1">カテゴリ</label>
            <input
              v-model="form.category"
              type="text"
              class="border border-gray-300 p-2 w-full rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="カテゴリを入力（任意）"
            />
          </div>
  
          <div class="mb-4" v-if="groups && groups.length > 0">
            <label class="block text-sm font-medium mb-1">グループ</label>
            <select
              v-model="form.group_id"
              class="border border-gray-300 p-2 w-full rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">グループを選択してください</option>
              <option v-for="group in groups" :key="group.id" :value="group.id">
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
              type="submit" 
              class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
              :disabled="!form.title.trim()"
            >
              {{ loading ? '保存中...' : '保存' }}
            </button>
            <button @click="deleteEvent" class="px-3 py-1 bg-red-500 text-white rounded">
              削除
            </button>
          </div>
        </form>
      </div>
    </div>
  </template>
  
  <script>
  import axios from "axios";
  
  export default {
    name: 'TaskForm',
    props: { 
      taskData: {
        type: Object,
        default: null
      },
      groups: {
        type: Array,
        default: () => []
      }
    },
    emits: ['close', 'saved'],
    data() {
      return {
        form: {
          title: "",
          description: "",
          due_date: "",
          priority: "",
          category: "",
          group_id: "",
          create_event: false
        },
        loading: false
      };
    },
    watch: {
      taskData: {
        handler(newTaskData) {
          console.log('TaskData changed:', newTaskData);
          this.resetForm();
          if (newTaskData) {
            this.initializeForm(newTaskData);
          }
        },
        immediate: true,
        deep: true
      }
    },
    methods: {
      resetForm() {
        this.form = {
          title: "",
          description: "",
          due_date: "",
          priority: "",
          category: "",
          group_id: "",
          create_event: false
        };
      },
      
      initializeForm(taskData) {
        console.log('Initializing form with:', taskData);
        
        this.form.title = taskData.title || "";
        this.form.description = taskData.description || "";
        this.form.due_date = taskData.due_date ? this.formatDateForInput(taskData.due_date) : "";
        this.form.priority = taskData.priority || "";
        this.form.category = taskData.category || "";
        this.form.group_id = taskData.group_id || "";
        
        console.log('Form initialized:', this.form);
      },
      
      formatDateForInput(dateInput) {
        try {
          if (!dateInput) return '';
          
          const date = new Date(dateInput);
          if (isNaN(date.getTime())) {
            console.warn('Invalid date:', dateInput);
            return '';
          }
          
          // YYYY-MM-DD形式で返す（date input用）
          const year = date.getFullYear();
          const month = String(date.getMonth() + 1).padStart(2, '0');
          const day = String(date.getDate()).padStart(2, '0');
          
          return `${year}-${month}-${day}`;
        } catch (error) {
          console.error('Date formatting error:', error, dateInput);
          return '';
        }
      },
      
      async saveTask() {
        this.loading = true;
        
        try {
          // バリデーション
          if (!this.form.title.trim()) {
            alert('タイトルを入力してください。');
            return;
          }
          
          // サーバー側で期待される形式でデータを送信
          const taskPayload = {
            title: this.form.title.trim(),
            description: this.form.description.trim(),
            due_date: this.form.due_date || null,
            priority: this.form.priority || null,
            category: this.form.category.trim() || null,
            group_id: this.form.group_id || null,
            create_event: this.form.create_event
          };
          
          console.log('Saving task:', taskPayload);
          
          let response;
          if (this.taskData?.id) {
            // 編集の場合
            response = await axios.put(`/tasks/${this.taskData.id}`, { task: taskPayload });
          } else {
            // 新規作成の場合
            response = await axios.post("/tasks", { task: taskPayload });
          }
          
          console.log('Save response:', response.data);
          this.$emit("saved");
          this.$emit("close");
          
        } catch (error) {
          console.error('タスク保存エラー:', error);
          
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
        } finally {
          this.loading = false;
        }
      }
    }
  };
  </script>