// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
document.addEventListener('DOMContentLoaded', function () {
    const menuButton = document.getElementById('menu-button');
    const menu = document.getElementById('menu');
  
    menuButton.addEventListener('click', function () {
      // メニューの表示/非表示を切り替え
      if (menu.style.display === 'block') {
        menu.style.display = 'none';
      } else {
        menu.style.display = 'block';
      }
    });
  });
  