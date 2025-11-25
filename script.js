// =================== MOBILE MENU TOGGLE ===================
function toggleMenu() {
  const menu = document.querySelector(".menu-links");
  const icon = document.querySelector(".hamburger-icon");

  menu.classList.toggle("open");
  icon.classList.toggle("open");
}

const hamburgerIcon = document.querySelector(".hamburger-icon");
if (hamburgerIcon) {
  hamburgerIcon.addEventListener("click", toggleMenu);
}

function closeMenu(event) {
  const menu = document.querySelector(".menu-links");
  const icon = document.querySelector(".hamburger-icon");

  if (!menu.contains(event.target) && !icon.contains(event.target)) {
    menu.classList.remove("open");
    icon.classList.remove("open");
  }
}
document.addEventListener("click", closeMenu);

// =================== DARK MODE TOGGLE ===================
const themeToggle = document.getElementById('theme-toggle');
const themeToggleMobile = document.getElementById('theme-toggle-mobile');

function setThemeFromStorage() {
  if (localStorage.getItem('theme') === 'dark') {
    document.body.classList.add('dark-mode');
  } else {
    document.body.classList.remove('dark-mode');
  }
}
setThemeFromStorage();

function toggleTheme() {
  document.body.classList.toggle('dark-mode');
  if (document.body.classList.contains('dark-mode')) {
    localStorage.setItem('theme', 'dark');
  } else {
    localStorage.setItem('theme', 'light');
  }
}

if (themeToggle) {
  themeToggle.addEventListener('click', toggleTheme);
}
if (themeToggleMobile) {
  themeToggleMobile.addEventListener('click', toggleTheme);
}

// =================== SECTION TOGGLE (About, Experience, Contact, Certification, Projects) ===================
document.querySelectorAll(".toggle-btn").forEach(button => {
  button.addEventListener("click", () => {
    const sectionContent = button.nextElementSibling; // assumes button is followed by content div
    sectionContent.classList.toggle("active");

    // Change button icon/text (optional)
    if (sectionContent.classList.contains("active")) {
      button.innerHTML = button.dataset.title + " ▲"; // expanded
    } else {
      button.innerHTML = button.dataset.title + " ▼"; // collapsed
    }
  });
});
