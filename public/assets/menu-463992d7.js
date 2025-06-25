document.addEventListener('DOMContentLoaded', function () {
    const menuButton = document.getElementById('menu-button');
    const menu = document.getElementById('menu');
  
    if (menuButton && menu) {
      menuButton.addEventListener('click', function () {
        menu.style.display = menu.style.display === 'block' ? 'none' : 'block';
      });
    }
  });
  