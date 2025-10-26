<!-- app/javascript/entrypoints/components/UserDetail.vue -->
<template>
  <div class="min-h-screen bg-gray-50 py-8">
    <div class="max-w-4xl mx-auto px-4">
      <!-- ユーザー情報カード -->
      <div class="bg-white rounded-xl shadow-lg p-8 mb-8">
        <div class="flex flex-col md:flex-row items-center md:items-start space-y-6 md:space-y-0 md:space-x-8">
          <!-- プロフィール画像 -->
          <div class="flex-shrink-0">
            <div v-if="editMode" class="space-y-4">
              <img
                :src="user.image_url || '/user_images/default_image.png'"
                :alt="`${user.name}のプロフィール画像`"
                class="w-32 h-32 rounded-full object-cover border-4 border-indigo-100"
              >
              <input
                ref="imageInput"
                type="file"
                accept="image/*"
                @change="handleImageChange"
                class="text-sm text-gray-500"
              >
            </div>
            <img
              v-else
              :src="user.image_url || '/user_images/default_image.png'"
              :alt="`${user.name}のプロフィール画像`"
              class="w-32 h-32 rounded-full object-cover border-4 border-indigo-100"
            >
          </div>
          
          <!-- ユーザー情報 -->
          <div class="flex-grow text-center md:text-left">
            <!-- 編集モード -->
            <div v-if="editMode" class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">ユーザー名</label>
                <input
                  v-model="editUser.name"
                  type="text"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                >
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">メールアドレス</label>
                <input
                  v-model="editUser.email"
                  type="email"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
                >
              </div>
              <div class="flex space-x-2">
                <button
                  @click="saveProfile"
                  :disabled="saving"
                  class="bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200 disabled:opacity-50"
                >
                  {{ saving ? '保存中...' : '保存' }}
                </button>
                <button
                  @click="cancelEdit"
                  class="bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200"
                >
                  キャンセル
                </button>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">AIキャラクター</label>
                <div class="grid grid-cols-3 gap-3">
                  <div 
                    v-for="avatar in aiAvatars" 
                    :key="avatar.name" 
                    class="cursor-pointer p-2 rounded-lg border"
                    :class="avatar.name === selectedAvatar ? 'border-indigo-500 bg-indigo-50' : 'border-gray-300'"
                    @click="selectAvatar(avatar)"
                  >
                    <img :src="avatar.url" class="w-20 h-20 object-cover rounded-lg mx-auto" />
                    <p class="text-center text-sm mt-1 text-gray-700">{{ avatar.display_name.replace('.png','') }}</p>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 表示モード -->
            <div v-else>
              <h1 class="text-3xl font-bold text-gray-900 mb-2">{{ user.name }}</h1>
              <p class="text-gray-600 mb-4">
                参加日: {{ formatDate(user.created_at) }}
              </p>
              
              <!-- 統計情報 -->
              <div class="flex justify-center md:justify-start space-x-8">
                <div class="text-center">
                  <div class="text-2xl font-bold text-indigo-600">{{ user.posts?.length || 0 }}</div>
                  <div class="text-sm text-gray-500">投稿</div>
                </div>
                <div class="text-center">
                  <div class="text-2xl font-bold text-indigo-600">{{ user.groups?.length || 0 }}</div>
                  <div class="text-sm text-gray-500">グループ</div>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 編集・削除ボタン（自分のプロフィールの場合） -->
          <div v-if="isOwnProfile && !editMode" class="flex-shrink-0">
            <button
              @click="startEdit"
              class="bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-6 rounded-lg transition-colors duration-200"
            >
              プロフィール編集
            </button>
          </div>

          <div v-if="isOwnProfile && !editMode" class="flex space-x-3">
            <button @click="deleteUser" class="px-4 py-2 bg-indigo-500 hover:bg-indigo-600 rounded-md text-white">
              削除
            </button>
          </div>
        </div>
      </div>
      
      <!-- グループ管理（自分のプロフィールの場合） -->
      <div  class="bg-white rounded-xl shadow-lg p-8 mb-8">
        <div class="flex items-center justify-between mb-6">
          <h2 class="text-2xl font-bold text-gray-900">グループ管理</h2>
          <button v-if="isOwnProfile"
            @click="showCreateGroupModal = true"
            class="bg-green-600 hover:bg-green-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200"
          >
            新しいグループを作成
          </button>
        </div>
        
        <div v-if="user.groups && user.groups.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div
            v-for="group in user.groups"
            :key="group.id"
            class="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow duration-200"
          >
            <div class="flex items-start justify-between mb-2">
              <h3 class="font-semibold text-gray-900">{{ group.name }}</h3>
              <button
                @click="viewGroupDetail(group)"
                class="text-indigo-600 hover:text-indigo-800 text-sm font-medium"
              >
                詳細
              </button>
            </div>
            <p class="text-gray-600 text-sm mb-3">{{ group.description }}</p>
            <div class="text-xs text-gray-500">
              メンバー: {{ group.members_count || 0 }}人
            </div>
          </div>
        </div>
        <div v-else class="text-center py-8">
          <p class="text-gray-500">参加しているグループがありません</p>
        </div>
      </div>
      
      <!-- 投稿一覧 -->
      <div class="bg-white rounded-xl shadow-lg p-8">
        <h2 class="text-2xl font-bold text-gray-900 mb-6">投稿一覧</h2>
        
        <div v-if="user.posts && user.posts.length > 0" class="space-y-6">
          <div
            v-for="post in user.posts"
            :key="post.id"
            class="border-b border-gray-200 pb-6 last:border-b-0"
          >
            <div class="flex items-start space-x-4">
              <img
                :src="user.image_url || '/user_images/default_image.png'"
                :alt="`${user.name}のプロフィール画像`"
                class="w-12 h-12 rounded-full object-cover"
              >
              <div class="flex-grow">
                <div class="flex items-center space-x-2 mb-2">
                  <h3 class="font-semibold text-gray-900">{{ user.name }}</h3>
                  <span class="text-gray-500 text-sm">{{ formatDate(post.created_at) }}</span>
                </div>
                <div class="text-gray-700 whitespace-pre-wrap">{{ post.content }}</div>
                <div class="mt-3 flex items-center space-x-4">
                  <span class="text-sm text-gray-500">
                    {{ post.likes_count || 0 }} いいね
                  </span>
                  <router-link
                    :to="{ name: 'PostDetail', params: { id: post.id } }"
                    class="text-indigo-600 hover:text-indigo-800 text-sm font-medium"
                    >
                     詳細を見る
                   </router-link>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div v-else class="text-center py-12">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h4m1 8l-4-4H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-3l-4 4z" />
          </svg>
          <h3 class="mt-2 text-lg font-medium text-gray-900">投稿がありません</h3>
          <p class="mt-1 text-gray-500">まだ投稿がありません</p>
        </div>
      </div>
    </div>

    <!-- グループ作成モーダル -->
    <div v-if="showCreateGroupModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-8 max-w-md w-full mx-4">
        <h3 class="text-lg font-bold text-gray-900 mb-4">新しいグループを作成</h3>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">グループ名</label>
            <input
              v-model="newGroup.name"
              type="text"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="グループ名を入力"
            >
          </div>
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">説明</label>
            <textarea
              v-model="newGroup.description"
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500"
              placeholder="グループの説明を入力"
            ></textarea>
          </div>
        </div>
        <div class="flex space-x-2 mt-6">
          <button
            @click="createGroup"
            :disabled="!newGroup.name.trim() || creatingGroup"
            class="flex-1 bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200 disabled:opacity-50"
          >
            {{ creatingGroup ? '作成中...' : '作成' }}
          </button>
          <button
            @click="cancelCreateGroup"
            class="flex-1 bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-4 rounded-lg transition-colors duration-200"
          >
            キャンセル
          </button>
        </div>
      </div>
    </div>

    <!-- グループ詳細モーダル -->
    <div v-if="selectedGroup" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg p-8 max-w-2xl w-full mx-4 max-h-96 overflow-y-auto">
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-bold text-gray-900">{{ selectedGroup.name }}</h3>
          <div class="flex space-x-2 mt-4">
            <button
              v-if="!isMember"
              @click="joinGroup"
              class="bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-4 rounded-lg"
            >
              グループに参加
            </button>
            <button
              v-else
              @click="leaveGroup"
              class="bg-red-600 hover:bg-red-700 text-white font-medium py-2 px-4 rounded-lg"
            >
              グループから脱退
            </button>
          </div>
          <button
            @click="closeGroupDetail"
            class="text-gray-500 hover:text-gray-700"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <p class="text-gray-600 mb-4">{{ selectedGroup.description }}</p>
        <p class="text-sm text-gray-500 mb-4">メンバー数: {{ selectedGroup.members_count }}人</p>
        
        <div v-if="groupMembers.length > 0">
          <h4 class="font-semibold text-gray-900 mb-2">メンバー</h4>
          <div class="space-y-2">
            <div
              v-for="member in groupMembers"
              :key="member.id"
              class="flex items-center space-x-3 p-2 bg-gray-50 rounded-lg"
            >
              <img
                :src="member.image_url || '/user_images/default_image.png'"
                :alt="`${member.name}のプロフィール画像`"
                class="w-8 h-8 rounded-full object-cover"
              >
              <span class="text-gray-900">{{ member.name }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios'

export default {
  name: 'UserDetail',
  props: {
    initialUserData: {
      type: Object,
      default: () => ({})
    },
    currentUserId: {
      type: [String, Number],
      default: null
    }
  },
  data() {
    return {
      user: this.initialUserData,
      editMode: false,
      editUser: {},
      saving: false,
      showCreateGroupModal: false,
      newGroup: { name: '', description: '' },
      creatingGroup: false,
      selectedGroup: null,
      groupMembers: [],
      isMember: false,
      aiAvatars: [],
      selectedAvatar: null 
    }
  },
  computed: {
    isOwnProfile() {
      return this.currentUserId && Number(this.currentUserId) === Number(this.user.id)
    }
  },
  async mounted() {
    // ユーザー情報が空の場合、APIから取得
    if (!this.user.id) {
      await this.fetchUser()
      await this.loadAiAvatars()
    }
  },
  methods: {
    async fetchUser() {
      try {
        const userId = this.$route.params.id
        const response = await axios.get(`/api/users/${userId}`)
        this.user = response.data.data
        if (response.data && response.data.success !== false) {
          this.user = response.data.data || {}
        } else {
          this.user = {}
          console.error('ユーザー取得: server returned error', response.data)
        }
      } catch (error) {
        console.error('ユーザー情報取得エラー:', error)
      }
    },
    
    startEdit() {
      this.editMode = true
      this.editUser = {
        name: this.user.name,
        email: this.user.email || ''
      }
    },
    async saveProfile() {
      this.saving = true
      try {
        const formData = new FormData()
        formData.append('user[name]', this.editUser.name)
        formData.append('user[email]', this.editUser.email)
        
        if (this.$refs.imageInput?.files[0]) {
          formData.append('user[image]', this.$refs.imageInput.files[0])
        }
        
        const response = await axios.patch(`/api/users/${this.user.id}`, formData)
        if (response.data && response.data.success !== false) {
          const updatedUser = response.data.data
          this.user = response.data.data || this.user
          this.editMode = false
          alert('プロフィールが更新されました')
        } else {
          const errorData = response.data || {}
          alert('更新に失敗しました: ' + (errorData.errors || ['エラーが発生しました']).join(', '))
        }
      } catch (error) {
        console.error('プロフィール更新エラー:', error)
        alert('更新中にエラーが発生しました')
      } finally {
        this.saving = false
      }
    },
    
    cancelEdit() {
      this.editMode = false
      this.editUser = {}
    },
    
    handleImageChange(event) {
      const file = event.target.files[0]
      if (file) {
        const reader = new FileReader()
        reader.onload = (e) => {
          // プレビュー用（実際の更新は保存時）
        }
        reader.readAsDataURL(file)
      }
    },
    
    cancelCreateGroup() {
      this.showCreateGroupModal = false
      this.newGroup = { name: '', description: '' }
    },
    
    async createGroup() {
      this.creatingGroup = true
      try {
        const response = await axios.post('/api/groups', {
          group: {
              name: this.newGroup.name,
              description: this.newGroup.description
            }
          })
        
        if (response.status === 200 && response.data) {
          const newGroup = response.data.data
          this.user.groups = this.user.groups || []
          this.user.groups.push({
            ...newGroup,
            members_count: 1
          })
          this.showCreateGroupModal = false
          this.newGroup = { name: '', description: '' }
          alert('グループが作成されました')
        } else {
          alert('グループの作成に失敗しました')
        }
      } catch (error) {
        console.error('グループ作成エラー:', error)
        alert('作成中にエラーが発生しました')
      } finally {
        this.creatingGroup = false
      }
    },
    
    async viewGroupDetail(group) {
      this.selectedGroup = group
      try {
        const response = await axios.get(`/api/groups/${group.id}`)
        if (response.data && response.data.success !== false) {
          const groupData = response.data.data || {}
          this.selectedGroup = groupData
          this.groupMembers = groupData.users || []
          this.selectedGroup.members_count = this.groupMembers.length
          this.isMember = this.groupMembers.some(u => Number(u.id) === Number(this.currentUserId))
        } else {
          console.error('グループ取得エラー:', response)
          this.selectedGroup = group
          this.groupMembers = []
          this.isMember = false
        }
      } catch (error) {
        console.error('グループメンバー取得エラー:', error)
        this.selectedGroup = group
        this.groupMembers = []
        this.isMember = false
      }
    },
    
    closeGroupDetail() {
      this.selectedGroup = null
      this.groupMembers = []
    },
    
    formatDate(dateString) {
      return new Date(dateString).toLocaleDateString('ja-JP', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      })
    },
    async joinGroup() {
      try {
        const response = await axios.post(`/api/groups/${this.selectedGroup.id}/join`)
        if (response.data && response.data.success !== false) {
          await this.viewGroupDetail({ id: this.selectedGroup.id })
        } else {
          console.error('join failed', response.data)
        }
      } catch (error) {
        console.error('グループ参加エラー:', error)
      }
    },

    async leaveGroup() {
      try {
        const response = await axios.delete(`/api/groups/${this.selectedGroup.id}/leave`)
        if (response.data && response.data.success !== false) {
          await this.viewGroupDetail({ id: this.selectedGroup.id })
        } else {
          console.error('leave failed', response.data)
        }
      } catch (error) {
        console.error('グループ脱退エラー:', error)
      }
    },
    async deleteUser () {
      if (!confirm("このアカウントを削除します。よろしいですか？")) return;
      try {
        const response = await axios.delete(`/api/users/${this.user.id}`);
        if (response.data && response.data.success !== false) {
          alert("アカウントを削除しました");
          this.$router.push('/');
        } else {
          const error = response.data || {}
          alert("削除に失敗しました: " + (error.error || "不明なエラー"));
        }
      } catch (err) {
        console.error("削除エラー:", err);
        alert("削除中にエラーが発生しました");
      }
    },
    async loadAiAvatars() {
      try {
        const res = await axios.get('/api/ai_images')
        this.aiAvatars = res.data.data.avatars
      } catch (err) {
        console.error('AI画像一覧取得エラー:', err)
      }
    },
    async selectAvatar(avatar) {
      this.selectedAvatar = avatar.name
      try {
        const avatarName = avatar.name.endsWith('.png') ? avatar.name : `${avatar.name}.png`
        await axios.patch('/api/users/update_ai_images', { avatar_name: avatarName })
        alert('キャラクターを変更しました')
      } catch (err) {
        console.error('キャラ更新エラー:', err)
        alert('変更に失敗しました')
      }
    }
  }
}



</script>