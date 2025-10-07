// app/javascript/entrypoints/application.js
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './components/App.vue'
import router from '../router/index.js' 
import Toast from "vue-toastification"
import "vue-toastification/dist/index.css"
import { useToast } from 'vue-toastification'
import axios from 'axios'
import "../styles/application.css"

const app = createApp(App);
const pinia = createPinia();

app.use(pinia);
app.use(router);
app.use(Toast, {
  position: "top-right",
  timeout: 3000,
  closeOnClick: true,
  pauseOnFocusLoss: true,
  pauseOnHover: true,
  draggable: true,
  draggablePercent: 0.6,
  showCloseButtonOnHover: false,
  hideProgressBar: false,
  closeButton: "button",
  icon: true,
  rtl: false
});

const toast = useToast();

const setupAxios = () => {
  const token = document.querySelector('[name="csrf-token"]')?.getAttribute('content')
  if (token) {
    axios.defaults.headers.common['X-CSRF-Token'] = token
  }
  axios.defaults.headers.common['Accept'] = 'application/json'

  // レスポンスインターセプター
  axios.interceptors.response.use(
    response => {
      // 成功時のトースト表示
      if (response.data?.message && response.data?.success !== false) {
        toast.success(response.data.message)
      }
      return response
    },
    error => {
      const toast = useToast();
      const originalRequest = error.config || {};

      if (error.response?.status === 401) {
        if (originalRequest.skipAuthRedirect || (originalRequest.url && originalRequest.url.includes('/api/auth/check'))){
          return Promise.reject(error)
        }
        // 認証エラー
        toast.error("ログインが必要です")
        router.push({ name: 'Login', query: { redirect: router.currentRoute.value.fullPath } })
      } else if (error.response?.status === 403) {
        // 権限エラー
        toast.error("アクセス権限がありません")
      } else if (error.response?.data?.message) {
        // サーバーからのエラーメッセージ
        toast.error(error.response.data.message)
      } else if (error.response?.data?.errors) {
        // バリデーションエラー
        const errors = Array.isArray(error.response.data.errors) 
          ? error.response.data.errors 
          : Object.values(error.response.data.errors).flat()
        errors.forEach(err => toast.error(err))
      } else {
        // その他のエラー
        toast.error("サーバーエラーが発生しました")
      }
      return Promise.reject(error);
    }
  );
};

setupAxios()

document.addEventListener('DOMContentLoaded', () => {
  const appElement = document.getElementById('app');
  if (appElement) {
    app.mount('#app');
    console.log('SPA application mounted successfully');
  } else {
    console.error('SPA application not initialized: #app element not found');
  }
});

// CSRFトークンの更新（必要に応じて）
const updateCSRFToken = () => {
  const token = document.querySelector('[name="csrf-token"]')?.getAttribute('content')
  if (token && axios.defaults.headers.common['X-CSRF-Token'] !== token) {
    axios.defaults.headers.common['X-CSRF-Token'] = token
  }
};

// ページ変更時にCSRFトークンを更新
router.afterEach(() => {
  updateCSRFToken()
});
