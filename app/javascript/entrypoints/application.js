import { createApp } from 'vue'
import Header from './components/Header.vue'
import Top from './components/Top.vue'
import PostIndex from './components/PostIndex.vue'
import PostDetail from './components/PostDetail.vue'
import Calendar from './components/Calendar.vue'
import TaskList from './components/TaskList.vue'
import UserIndex from './components/UserIndex.vue'
import UserDetail from './components/UserDetail.vue'
import LoginForm from './components/LoginForm.vue'
import UserRegistration from './components/UserRegistration.vue'
import GroupDetail from './components/GroupDetail.vue'
import axios from 'axios'
import "../styles/application.css"

const token = document.querySelector('[name="csrf-token"]').getAttribute('content')
axios.defaults.headers.common['X-CSRF-Token'] = token
axios.defaults.headers.common['Accept'] = 'application/json'
axios.defaults.headers.common['Content-Type'] = 'application/json'

// HTMLエスケープをデコードしてからJSONパース（共通関数）
const decodeAndParseJSON = (data, fallback = []) => {
  try {
    const decoded = data
      .replace(/&quot;/g, '"')
      .replace(/&#x27;/g, "'")
      .replace(/&amp;/g, '&')
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .trim();
    return decoded ? JSON.parse(decoded) : fallback
  } catch (error) {
    console.error('JSON parse error:', error)
    return fallback
  }
}

// 共通のマウント関数
const mountComponent = (elementId, component, propsFactory = null) => {
  const element = document.getElementById(elementId)
  if (element && !element.__vue_app__) {
    try {
      const props = propsFactory ? propsFactory(element) : {}
      element.__vue_app__ = createApp(component, props).mount(element)
      console.log(`${component.name || elementId} mounted successfully`)
    } catch (error) {
      console.error(`Error mounting ${component.name || elementId}:`, error)
    }
  }
}

// 各コンポーネントのprops生成関数
const componentConfigs = {
  'vue-header': {
    component: Header,
    propsFactory: (el) => ({
      isLoggedIn: el.dataset.loggedIn === "true",
      currentUserId: el.dataset.userId,
      currentUserName: el.dataset.userName
    })
  },
  
  'vue-top': {
    component: Top
  },
  
  'vue-postindex': {
    component: PostIndex,
    propsFactory: (el) => ({
      isLoggedIn: el.dataset.isLoggedIn === "true",
      currentUserId: el.dataset.currentUserId,
      currentUserName: el.dataset.currentUserName,
      groups: JSON.parse(el.dataset.groups || "[]"),
      initialPosts: JSON.parse(el.dataset.initialPosts || "[]")
    })
  },
  
  'vue-postdetail': {
    component: PostDetail,
    propsFactory: (el) => ({
      currentUserId: Number(el.dataset.currentUserId),
      postId: Number(el.dataset.postId),
      initialPostData: JSON.parse(el.dataset.postData || '{}')
    })
  },
  
  'vue-calendar': {
    component: Calendar,
    propsFactory: (el) => ({
      isLoggedIn: el.dataset.isLoggedIn === "true",
      currentUserId: el.dataset.currentUserId,
      currentUserName: el.dataset.currentUserName,
      groups: JSON.parse(el.dataset.groups || "[]"),
      initialEvents: JSON.parse(el.dataset.initialEvents || "[]")
    })
  },
  
  'vue-tasklist': {
    component: TaskList,
    propsFactory: (el) => ({
      isLoggedIn: el.dataset.isLoggedIn === "true",
      currentUserId: el.dataset.currentUserId,
      currentUserName: el.dataset.currentUserName,
      groups: decodeAndParseJSON(el.dataset.groups || "[]"),
      initialTasks: decodeAndParseJSON(el.dataset.initialTasks || "[]"),
      initialCompletedTasks: decodeAndParseJSON(el.dataset.initialCompletedTasks || "[]")
    })
  },
  
  'vue-userindex': {
    component: UserIndex,
    propsFactory: (el) => ({
      initialUsers: decodeAndParseJSON(el.dataset.users || '[]'),
      currentUserId: el.dataset.currentUserId
    })
  },
  
  'vue-userdetail': {
    component: UserDetail,
    propsFactory: (el) => ({
      userId: el.dataset.userId,
      currentUserId: el.dataset.currentUserId,
      initialUserData: decodeAndParseJSON(el.dataset.initialUserData, {})
    })
  },
  
  'vue-login-form': {
    component: LoginForm
  },
  
  'vue-user-registration': {
    component: UserRegistration
  },

  'vue-groupdetail': {
    component: GroupDetail,
    propsFactory: (el) => ({
      groupId: Number(el.dataset.groupId),
      currentUserId: Number(el.dataset.currentUserId)
    })
  }
}

// 全コンポーネントをマウントする関数
const mountAllComponents = () => {
  Object.entries(componentConfigs).forEach(([elementId, config]) => {
    mountComponent(elementId, config.component, config.propsFactory)
  })
}

// 初回ロード時とTurboページ遷移時に実行
mountAllComponents()
document.addEventListener('turbo:load', mountAllComponents)