<template>
    <header class="bg-indigo-800 shadow-sm border-gray-200 sticky top-8 z-50">
        <div class="max-w-9xl mx-auto px-3 sm:px-5 lg:px-8">
            <div class="flex justify-between h-14">
                <!-- ロゴ部分 -->
                <div class="flex items-center space-x-1">
                    <a href="/" class="hover:opacity-80 transition-opacity">
                        <!-- Viteで管理される画像を正しくインポート -->
                        <img :src="logoUrl" alt="Post-Them" class="rounded-md h-12 w-auto" />
                    </a>
                </div>

                <!-- ナビゲーション -->
                <nav class="hidden md:flex space-x-8">
                    <ul class="flex items-center space-x-6">
                        <li v-if="isLoggedIn">
                            <a :href="`/users/${currentUserId}`" 
                                class="text-green-100 hover:text-primary-600 px-3 py-2 rounded-md text-sm font-medium transition-colors duration-200">
                                {{ currentUserName }}
                            </a>
                        </li>
                        <li v-if="isLoggedIn">
                            <a href="/users" 
                                class="text-green-100 hover:text-primary-600 px-3 py-2 rounded-md text-sm font-medium transition-colors duration-200">
                                ユーザ一覧
                            </a>
                        </li>
                        <li v-if="isLoggedIn">
                            <button @click="logout" 
                                    class="text-green-100 hover:text-primary-600 px-3 py-2 rounded-md text-sm font-medium transition-colors duration-200">
                                ログアウト
                            </button>
                        </li>
                        <li v-if="!isLoggedIn">
                            <a href="/about" 
                                class="text-green-100 hover:text-primary-600 px-3 py-2 rounded-md text-sm font-medium transition-colors duration-200">
                                アプリについて
                            </a>
                        </li>
                        <li v-if="!isLoggedIn">
                            <a href="/users/new" 
                                class="text-green-100 hover:text-primary-600 px-3 py-2 rounded-md text-sm font-medium transition-colors duration-200">
                                登録
                            </a>
                        </li>
                        <li v-if="!isLoggedIn">
                            <a href="/login" 
                                class="text-green-100 hover:text-primary-600 px-3 py-2 rounded-md text-sm font-medium transition-colors duration-200">
                                ログイン
                            </a>
                        </li>
                    </ul>
                </nav>

                <!-- モバイルメニューボタン -->
                <div class="md:hidden">
                    <button type="button"
                        @click="toggleMobileMenu"
                        class="text-green-100 hover:text-primary-600 p-2 rounded-md">
                            <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                            </svg>
                    </button>
                </div>
            </div>
        </div>
        <!-- モバイルメニュー -->
        <div v-show="showMobileMenu" class="md:hidden">
            <div class="bg-slate-200 px-2 pt-2 pb-3 space-y-1 border-t border-gray-200">
                <a v-if="isLoggedIn" :href="`/users/${currentUserId}`" 
                    class="block text-indigo-800 hover:text-primary-600 px-3 py-2 rounded-md text-base font-medium">
                    {{ currentUserName }}
                </a>
                <a v-if="isLoggedIn" href="/users" 
                    class="block text-indigo-800 hover:text-primary-600 px-3 py-2 rounded-md text-base font-medium">
                    ユーザ一覧
                </a>
                <button v-if="isLoggedIn" @click="logout" 
                        class="block text-indigo-800 hover:text-primary-600 px-3 py-2 rounded-md text-base font-medium bg-transparent border-0 cursor-pointer w-full text-left">
                    ログアウト
                </button>
                <a v-if="!isLoggedIn" href="/about" 
                    class="block text-indigo-800 hover:text-primary-600 px-3 py-2 rounded-md text-base font-medium">
                    アプリについて
                </a>
                <a v-if="!isLoggedIn" href="/users/new" 
                    class="block text-indigo-800 hover:text-primary-600 px-3 py-2 rounded-md text-base font-medium">
                    登録
                </a>
                <a v-if="!isLoggedIn" href="/login" 
                    class="block text-indigo-800 hover:text-primary-600 px-3 py-2 rounded-md text-base font-medium">
                    ログイン
                </a>
            </div>
        </div>
    </header>
</template>

<script>
    // Viteが管理する画像をインポート
    import logoImage from '../../images/logo_Post-them.png'

    export default {
        name: 'Header',
        props: ['isLoggedIn', 'currentUserId', 'currentUserName'],
        data() {
            return {
                showMobileMenu: false,
                logoUrl: logoImage
            }
        },
        methods: {
            toggleMobileMenu() {
                this.showMobileMenu = !this.showMobileMenu
            },
            logout() {
                const form = document.createElement('form')
                form.method = 'POST'
                form.action = '/logout'

                // CSRFトークン
                const csrfToken = document.querySelector('meta[name="csrf-token"]').content
                const csrfInput = document.createElement('input')
                csrfInput.type = 'hidden'
                csrfInput.name = 'authenticity_token'
                csrfInput.value = csrfToken
                form.appendChild(csrfInput)

                document.body.appendChild(form)
                form.submit()
                console.log('Logout clicked')
            }
        }
    }
</script>