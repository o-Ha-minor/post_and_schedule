// app/javascript/entrypoints/router/index.js
import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../entrypoints/stores/auth'

// コンポーネントの動的インポート
const Top = () => import('../entrypoints/components/Top.vue')
const PostIndex = () => import('../entrypoints//components/PostIndex.vue')
const PostDetail = () => import('../entrypoints//components/PostDetail.vue')
const UserIndex = () => import('../entrypoints//components/UserIndex.vue')
const UserDetail = () => import('../entrypoints//components/UserDetail.vue')
const UserRegistration = () => import('../entrypoints//components/UserRegistration.vue')
const LoginForm = () => import('../entrypoints//components/LoginForm.vue')
const Calendar = () => import('../entrypoints//components/Calendar.vue')
const TaskList = () => import('../entrypoints//components/TaskList.vue')
const GroupDetail = () => import('../entrypoints//components/GroupDetail.vue')

const routes = [
  {
    path: '/',
    name: 'Top',
    component: Top
  },
  {
    path: '/posts',
    name: 'PostIndex',
    component: PostIndex,
    meta: { requiresAuth: true }
  },
  {
    path: '/posts/:id',
    name: 'PostDetail',
    component: PostDetail,
    meta: { requiresAuth: true },
    props: route => ({ 
      postId: Number(route.params.id) 
    })
  },
  {
    path: '/users',
    name: 'UserIndex',
    component: UserIndex,
    meta: { requiresAuth: true }
  },
  {
    path: '/users/:id',
    name: 'UserDetail',
    component: UserDetail,
    meta: { requiresAuth: true },
    props: route => ({ 
      userId: Number(route.params.id) 
    })
  },
  {
    path: '/users/new',
    name: 'UserRegistration',
    component: UserRegistration,
    meta: { requiresGuest: true }
  },
  {
    path: '/login',
    name: 'Login',
    component: LoginForm,
    meta: { requiresGuest: true }
  },
  {
    path: '/events',
    name: 'Calendar',
    component: Calendar,
    meta: { requiresAuth: true }
  },
  {
    path: '/tasks',
    name: 'TaskList',
    component: TaskList,
    meta: { requiresAuth: true }
  },
  {
    path: '/groups/:id',
    name: 'GroupDetail',
    component: GroupDetail,
    meta: { requiresAuth: true },
    props: route => ({ 
      groupId: Number(route.params.id) 
    })
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    redirect: '/'
  }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

router.beforeEach(async (to, from, next) => {
    const authStore = useAuthStore()
    
    // 認証状態をチェック
    if (!authStore.initialized) {
      await authStore.checkAuth()
    }
  
    // ログインが必要なページ
    if (to.meta.requiresAuth && !authStore.isLoggedIn) {
      next({ name: 'Login' })
      return
    }
  
    // ゲスト専用ページ（ログイン済みユーザーはアクセス不可）
    if (to.meta.requiresGuest && authStore.isLoggedIn) {
      next({ name: 'Top' })
      return
    }
  
    next()
  })
export default router
