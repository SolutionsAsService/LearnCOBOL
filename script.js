// Script to handle theme switching
document.addEventListener('DOMContentLoaded', () => {
    const themeSwitcher = document.getElementById('theme-switcher');

    // Check if the theme is already saved in localStorage
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme) {
        document.body.classList.add(savedTheme);
    }

    // Toggle the theme when the button is clicked
    themeSwitcher.addEventListener('click', () => {
        // Toggle 'light-mode' class
        document.body.classList.toggle('light-mode');

        // Save the current theme in localStorage
        if (document.body.classList.contains('light-mode')) {
            localStorage.setItem('theme', 'light-mode');
        } else {
            localStorage.setItem('theme', '');
        }
    });
});
