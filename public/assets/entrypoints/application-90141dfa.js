import { createApp } from 'vue'
import Header from './components/Header.vue'
import Top from './components/Top.vue'
import PostIndex from './components/PostIndex.vue'
import PostDetail from './components/PostDetail.vue'
import Calendar from './components/Calendar.vue'
import "../styles/application.css"

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
    const initialEvents = JSON.parse(calendarElement.dataset.initialPosts || "[]")

    calendarElement.__vue_app__ = createApp(Calendar, {
      isLoggedIn,
      currentUserId,
      currentUserName,
      groups,
      initialEvents
    }).mount(CalendarElement)
  }
}

// 初回ロード
mountHeader()
mountTop()
mountPostIndex()
mountPostDetail()
mountCalendar()

// Turbo ページ遷移時
document.addEventListener('turbo:load', () => {
  mountHeader()
  mountTop()
  mountPostIndex()
  mountPostDetail()
  mountCalendar()
})

