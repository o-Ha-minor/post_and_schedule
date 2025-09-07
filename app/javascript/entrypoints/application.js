import { createApp } from 'vue'
import Header from './components/Header.vue'
import Top from './components/Top.vue'
import PostIndex from './components/PostIndex.vue'
import PostDetail from './components/PostDetail.vue'
import Calendar from './components/Calendar.vue'
import TaskList from './components/TaskList.vue'
import UserIndex from './components/UserIndex.vue'
import UserDetail from './components/UserDetail.vue'
import axios from 'axios'
import "../styles/application.css"


const token = document.querySelector('[name="csrf-token"]').getAttribute('content')
axios.defaults.headers.common['X-CSRF-Token'] = token
axios.defaults.headers.common['Accept'] = 'application/json'
axios.defaults.headers.common['Content-Type'] = 'application/json'

// Turbo に対応してヘッダーを再マウント
const mountHeader = () => {
  const headerElement = document.getElementById('vue-header')
  if (headerElement && !headerElement.__vue_app__) {
    const isLoggedIn = headerElement.dataset.loggedIn === "true"
    const currentUserId = headerElement.dataset.userId
    const currentUserName = headerElement.dataset.userName
    headerElement.__vue_app__ = createApp(Header, {
      isLoggedIn,
      currentUserId,
      currentUserName
    }).mount(headerElement)
  }
}

const mountTop = () => {
  const topElement = document.getElementById('vue-top')
  if (topElement && !topElement.__vue_app__) {
    topElement.__vue_app__ = createApp(Top).mount(topElement)
  }
}

const mountPostIndex = () => {
  const postindexElement = document.getElementById('vue-postindex')
  if (postindexElement && !postindexElement.__vue_app__) {
    const isLoggedIn = postindexElement.dataset.isLoggedIn === "true"
    const currentUserId = postindexElement.dataset.currentUserId
    const currentUserName = postindexElement.dataset.currentUserName
    const groups = JSON.parse(postindexElement.dataset.groups || "[]")
    const initialPosts = JSON.parse(postindexElement.dataset.initialPosts || "[]")

    postindexElement.__vue_app__ = createApp(PostIndex, {
      isLoggedIn,
      currentUserId,
      currentUserName,
      groups,
      initialPosts
    }).mount(postindexElement)
  }
}

const mountPostDetail = () => {
  const postdetailElement = document.getElementById('vue-postdetail')
  if (postdetailElement && !postdetailElement.__vue_app__) {
    const currentUserId = Number(postdetailElement.dataset.currentUserId)
    const postId = Number(postdetailElement.dataset.postId)
    const initialPostData = JSON.parse(postdetailElement.dataset.postData || '{}')

    postdetailElement.__vue_app__ = createApp(PostDetail, {
      currentUserId,
      postId,
      initialPostData
    }).mount(postdetailElement)
  }
}

const mountCalendar = () => {
  const calendarElement = document.getElementById('vue-calendar')
  if (calendarElement && !calendarElement.__vue_app__) {
    const isLoggedIn = calendarElement.dataset.isLoggedIn === "true"
    const currentUserId = calendarElement.dataset.currentUserId
    const currentUserName = calendarElement.dataset.currentUserName
    const groups = JSON.parse(calendarElement.dataset.groups || "[]")
    const initialEvents = JSON.parse(calendarElement.dataset.initialEvents || "[]")

    calendarElement.__vue_app__ = createApp(Calendar, {
      isLoggedIn,
      currentUserId,
      currentUserName,
      groups,
      initialEvents
    }).mount(calendarElement)
  }
}

const mountTaskList = () => {
  const tasklistElement = document.getElementById('vue-tasklist')
  if (tasklistElement && !tasklistElement.__vue_app__) {
    const isLoggedIn = tasklistElement.dataset.isLoggedIn === "true"
    const currentUserId = tasklistElement.dataset.currentUserId
    const currentUserName = tasklistElement.dataset.currentUserName
    const groups = JSON.parse(tasklistElement.dataset.groups || "[]")
    const initialTasks = JSON.parse(tasklistElement.dataset.initialTasks || "[]")
    const initialCompletedTasks = JSON.parse(tasklistElement.dataset.initialCompletedTasks || "[]")

    tasklistElement.__vue_app__ = createApp(TaskList, {
      isLoggedIn,
      currentUserId,
      currentUserName,
      groups,
      initialTasks,
      initialCompletedTasks
    }).mount(tasklistElement)
  }
}

const mountUserIndex = () => {
  const userIndexElement = document.getElementById('vue-userindex')
  if (userIndexElement && !userIndexElement.__vue_app__) {
    try {
      const users = JSON.parse(userIndexElement.dataset.users || '[]')
      const currentUserId = userIndexElement.dataset.currentUserId
      
      console.log('Mounting UserIndex with:', { users, currentUserId }) // デバッグ用

      userIndexElement.__vue_app__ = createApp(UserIndex, {
        initialUsers: users,
        currentUserId
      }).mount(userIndexElement)
      
      console.log('UserIndex mounted successfully') // デバッグ用
    } catch (error) {
      console.error('Error mounting UserIndex:', error)
    }
  }
}
const mountUserDetail = () => {
  const element = document.getElementById('vue-userdetail')
  console.log('UserDetail element:', element)
  
  if (element && !element.__vue_app__) {
    try {
      const userId = element.dataset.userId
      const currentUserId = element.dataset.currentUserId
      const rawUserData = element.dataset.initialUserData || '{}'

      // まず文字列をそのままログ出力
      console.log('Raw initialUserData string:', rawUserData)

      // JSON.parse を安全に試す
      let userData = {}
      try {
        userData = JSON.parse(rawUserData)
      } catch (parseError) {
        console.error('JSON parse error for initialUserData:', parseError)
        console.warn('Parsing failed string:', rawUserData)
      }

      console.log('Parsed UserDetail data:', { userId, currentUserId, userData })
      
      element.__vue_app__ = createApp(UserDetail, {
        userId,
        currentUserId,
        initialUserData: userData
      }).mount(element)
      
      console.log('UserDetail mounted!')
    } catch (error) {
      console.error('UserDetail mount error:', error)
    }
  }
}
// 初回ロード
mountHeader()
mountTop()
mountPostIndex()
mountPostDetail()
mountCalendar()
mountTaskList()
mountUserIndex()
mountUserDetail()

// Turbo ページ遷移時
document.addEventListener('turbo:load', () => {
  mountHeader()
  mountTop()
  mountPostIndex()
  mountPostDetail()
  mountCalendar()
  mountTaskList()
  mountUserIndex()
  mountUserDetail()
})

