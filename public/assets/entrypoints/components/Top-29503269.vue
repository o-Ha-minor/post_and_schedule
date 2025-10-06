<template>
   <div class="bg-sky-50 min-h-screen flex flex-col items-center py-5">
        <h1 class="text-indigo-800 text-3xl text-center font-extrabold mb-2">Post-Them </h1>
        <h2 class="text-lg text-gray-600 mb-8 text-center">こんにちは</h2>
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-6 w-full max-w-3xl px-4">
            <router-link to="/events" class="group bg-white shadow-lg rounded-2xl p-6 flex flex-col 
                items-center shadow-2xl transition transform hover:-translate-y-1 hover:scale-105"
                active-class="bg-indigo-100 text-indigo-600">
                <img :src="eventsUrl" class="h-16 w-16 mb-3" />
                <span class="text-gray-800 font-midium group-hover:text-indigo-600">
                スケジュール</span>
            </router-link>
            <router-link to="/posts" class="group bg-white shadow-lg rounded-2xl p-6 flex flex-col 
                items-center shadow-2xl transition transform hover:-translate-y-1 hover:scale-105"
                active-class="bg-indigo-100 text-indigo-600">
                <img :src="postsUrl" class="h-16 w-16 mb-3" />
                <span class="text-gray-800 font-midium group-hover:text-indigo-600">
                    投稿</span>
            </router-link>
            <router-link to="/tasks" class="group bg-white shadow-lg rounded-2xl p-6 flex flex-col 
                items-center shadow-2xl transition transform hover:-translate-y-1 hover:scale-105"
                active-class="bg-indigo-100 text-indigo-600">
                <img :src="tasksUrl" class="h-16 w-16 mb-3" />
                <span class="text-gray-800 font-midium group-hover:text-indigo-600">
                    タスク</span>
            </router-link>
        </div>
    </div>
</template>

<script>
    // Viteが管理する画像をインポート
    import eventsImage from '../../images/schedule.png'
    import postsImage from '../../images/chat.png'
    import tasksImage from '../../images/do.png'

    export default {
        name: 'Top',
        props: ['isLoggedIn', 'currentUserId', 'currentUserName'],
        data() {
            return {
                showMobileMenu: false,
                eventsUrl: eventsImage,
                postsUrl: postsImage,
                tasksUrl: tasksImage
            }
        }
    }
    
</script>