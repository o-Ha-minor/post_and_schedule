/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{erb,haml,html,slim}",
    "./app/javascript/**/*.{js,vue,ts}",
    "./config/initializers/simple_form_tailwind.rb",
    "./lib/tasks/**/*.rake"
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          900: '#1e3a8a',
        }
      },
      fontFamily: {
        'hira': ['ヒラギノ角ゴシック', 'sans-serif'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}