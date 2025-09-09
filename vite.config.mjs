import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    vue()
  ],
  css: {
    postcss: './postcss.config.js', // PostCSS設定を指定
  },
  server: {
    hmr: {
      port: 3036
    }
  },
  build: {
    rollupOptions: {
      external: ['@hotwired/turbo-rails']
    }
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'app/javascript')
    }
  }
})
