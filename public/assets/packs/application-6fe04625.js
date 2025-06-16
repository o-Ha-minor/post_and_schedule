/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
require("@rails/ujs").start()
require("jquery").start()
require("bootstrap").start()
require("@rails/activestorage").start()
require("channels").
require_tree .
console.log('')
import Rails from 'rails-ujs'
import "@hotwired/turbo-rails"
Rails.start()

document.addEventListener('DOMContentLoaded', () => {
  const calendarEl = document.getElementById('calendar');

  const calendar = new Calendar(calendarEl, {
    plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin],
    initialView: 'dayGridMonth',
    events: '/events', // Railsからデータを取得
    selectable: true,
    editable: true,
    eventClick: function(info) {
      alert(`イベント: ${info.event.title}`);
    },
    dateClick: function(info) {
      alert(`選択した日付: ${info.dateStr}`);
    }
  });

  calendar.render();
});
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require jquery
//= require moment
//= require_tree 


document.addEventListener('DOMContentLoaded', () => {
  const calendarEl = document.getElementById('calendar');

  if (calendarEl) { // カレンダー要素が存在する場合のみ実行
    const calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin],
      initialView: 'dayGridMonth',
      events: '/events', // Railsのルートからデータを取得
      selectable: true,
      editable: true,
      eventClick: function(info) {
        alert(`イベント: ${info.event.title}`);
      },
      dateClick: function(info) {
        alert(`選択した日付: ${info.dateStr}`);
      }
    });

    calendar.render();
  } else {
    console.error('カレンダー要素が見つかりませんでした');
  }
});

