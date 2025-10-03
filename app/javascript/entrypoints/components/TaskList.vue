<template>
    <div class="container mx-auto p-6">
      <div class="bg-white rounded-lg shadow-md p-6">
        <!-- ヘッダー -->
        <div class="flex justify-between items-center mb-6">
          <h1 class="text-2xl font-bold text-gray-900">タスク管理</h1>
          <button
            @click="showForm = true"
            class="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 flex items-center gap-2"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
            </svg>
            新しいタスク
          </button>
        </div>
  
        <!-- 未完了のタスク -->
        <div class="mb-8">
          <h2 class="text-xl font-semibold text-gray-800 mb-4">未完了のタスク</h2>
          <div v-if="tasks.length === 0" class="text-gray-500 text-center py-8">
            未完了のタスクがありません
          </div>
          <div v-else class="space-y-3">
            <div
              v-for="task in tasks"
              :key="task.id"
              class="flex items-center justify-between p-4 border border-gray-200 rounded-lg hover:bg-gray-50"
            >
              <div class="flex-1">
                <h3 class="font-medium text-gray-900">{{ task.title }}</h3>
                <div class="text-sm text-gray-500 mt-1">
                  <span v-if="task.category" class="mr-4">カテゴリ: {{ task.category }}</span>
                  <span v-if="task.due_date" class="mr-4">期限: {{ formatDate(task.due_date) }}</span>
                  <span v-if="task.priority" class="inline-flex px-2 py-1 text-xs font-semibold rounded-full"
                        :class="getPriorityColor(task.priority)">
                    {{ getPriorityText(task.priority) }}
                  </span>
                </div>
              </div>
              <div class="flex space-x-2">
                <button
                  @click="editTask(task)"
                  class="px-3 py-1 text-sm bg-yellow-100 text-yellow-800 rounded hover:bg-yellow-200"
                >
                  編集
                </button>
                <button
                  @click="completeTask(task)"
                  class="px-3 py-1 text-sm bg-green-100 text-green-800 rounded hover:bg-green-200"
                >
                  完了
                </button>
                <button
                  @click="deleteTask(task)"
                  class="px-3 py-1 text-sm bg-red-100 text-red-800 rounded hover:bg-red-200"
                >
                  削除
                </button>
              </div>
            </div>
          </div>
        </div>
  
        <!-- 完了済みのタスク -->
        <div>
          <h2 class="text-xl font-semibold text-gray-800 mb-4">完了済みのタスク</h2>
          <div v-if="completedTasks.length === 0" class="text-gray-500 text-center py-8">
            完了済みのタスクがありません
          </div>
          <div v-else class="space-y-3">
            <div
              v-for="task in completedTasks"
              :key="task.id"
              class="flex items-center justify-between p-4 border border-gray-200 rounded-lg bg-gray-50"
            >
              <div class="flex-1">
                <h3 class="font-medium text-gray-600 line-through">{{ task.title }}</h3>
                <div class="text-sm text-gray-500 mt-1">
                  <span v-if="task.completed_at">完了日時: {{ formatDateTime(task.completed_at) }}</span>
                </div>
              </div>
              <button
                @click="deleteTask(task)"
                class="px-3 py-1 text-sm bg-red-100 text-red-800 rounded hover:bg-red-200"
              >
                削除
              </button>
            </div>
          </div>
        </div>
      </div>
  
      <!-- タスクフォーム -->
      <TaskForm
        v-if="showForm"
        :taskData="selectedTask"
        :groups="groups"
        @close="closeForm"
        @saved="handleTaskSaved"
      />
    </div>
  </template>
  
  <script>
  import axios from 'axios'
  import TaskForm from './TaskForm.vue'
  
  export default {
    name: 'TaskList',
    components: {
      TaskForm
    },
    props: {
      isLoggedIn: {
        type: Boolean,
        default: false
      },
      currentUserId: {
        type: String,
        default: ''
      },
      currentUserName: {
        type: String,
        default: ''
      },
      groups: {
        type: Array,
        default: () => []
      },
      initialTasks: {
        type: Array,
        default: () => []
      },
      initialCompletedTasks: {
        type: Array,
        default: () => []
      }
    },
    data() {
      return {
        tasks: [],
        completedTasks: [],
        showForm: false,
        selectedTask: null
      }
    },
    async mounted() {
      // 初期データがある場合は使用、なければAPIから取得
      if (this.initialTasks.length > 0 || this.initialCompletedTasks.length > 0) {
        this.tasks = this.initialTasks
        this.completedTasks = this.initialCompletedTasks
      } else {
        await this.fetchTasks()
      }
    },
    methods: {
      async fetchTasks() {
        try {
          const response = await axios.get('/api/tasks.json')
          this.tasks = response.data.tasks || []
          this.completedTasks = response.data.completed_tasks || []
        } catch (error) {
          console.error('タスクの取得に失敗しました:', error)
          this.tasks = []
          this.completedTasks = []
        }
      },
  
      editTask(task) {
        this.selectedTask = task
        this.showForm = true
      },
  
      async completeTask(task) {
        try {
          await axios.patch(`/api/tasks/${task.id}`, {task: { status: "completed" }})
          await this.fetchTasks() // タスク一覧を再取得
        } catch (error) {
          console.error('タスクの完了に失敗しました:', error)
          alert('タスクの完了に失敗しました')
        }
      },
  
      async deleteTask(task) {
        if (!confirm('このタスクを削除しますか？')) {
          return
        }
  
        try {
          await axios.delete(`/api/tasks/${task.id}`)
          await this.fetchTasks() // タスク一覧を再取得
        } catch (error) {
          console.error('タスクの削除に失敗しました:', error)
          alert('タスクの削除に失敗しました')
        }
      },
  
      closeForm() {
        this.showForm = false
        this.selectedTask = null
      },
  
      async handleTaskSaved() {
        await this.fetchTasks() // タスク一覧を再取得
        this.closeForm()
      },
  
      formatDate(dateString) {
        if (!dateString) return ''
        const date = new Date(dateString)
        return date.toLocaleDateString('ja-JP')
      },
  
      formatDateTime(dateString) {
        if (!dateString) return ''
        const date = new Date(dateString)
        return date.toLocaleString('ja-JP')
      },
  
      getPriorityColor(priority) {
        switch (priority) {
          case 'high':
            return 'bg-red-100 text-red-800'
          case 'medium':
            return 'bg-yellow-100 text-yellow-800'
          case 'low':
            return 'bg-green-100 text-green-800'
          default:
            return 'bg-gray-100 text-gray-800'
        }
      },
  
      getPriorityText(priority) {
        switch (priority) {
          case 'high':
            return '高'
          case 'medium':
            return '中'
          case 'low':
            return '低'
          default:
            return '未設定'
        }
      }
    }
  }
  </script>