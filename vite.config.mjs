import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import ViteRubyPlugin from 'vite-plugin-ruby'
import path from 'path'

export default defineConfig({
  plugins: [
    ViteRubyPlugin(),
    vue()
  ],
  css: {
    postcss: './postcss.config.js', // PostCSS設定を指定
  },
  server: {
    host: 'localhost', // localhostに変更
    port: 3036,
    hmr: {
      port: 3036,
      host: 'localhost' // localhostに変更
    }
  },
  base: `/`,
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'app/javascript')
    }
  }
});
