document.addEventListener('DOMContentLoaded', () => {
    // --- Sidebar & User Dropdown --- //
    const sidebar = document.getElementById('sidebar');
    const userInfoBtn = document.getElementById('userInfoBtn');
    const userDropdown = document.getElementById('userDropdown');
    const userNameDisplay = document.getElementById('userName');
    const dropdownLogoutBtn = document.getElementById('dropdownLogout');
    const mainContent = document.querySelector('.main-content');

    // Mobile menu button
    if (mainContent) {
        const menuBtn = document.createElement('button');
        menuBtn.innerHTML = '☰';
        menuBtn.className = 'btn btn-secondary mobile-menu-btn';
        menuBtn.style.position = 'fixed';
        menuBtn.style.top = '1rem';
        menuBtn.style.left = '1rem';
        menuBtn.style.zIndex = '1001';
        menuBtn.style.display = 'none'; // Initially hidden
        document.body.appendChild(menuBtn);

        menuBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            sidebar.classList.toggle('active');
        });
    }

    if (UserManager.isLoggedIn()) {
        const currentUser = UserManager.getCurrentUser();
        if (userNameDisplay) {
            userNameDisplay.textContent = currentUser.name;
        }

        // Toggle user dropdown
        if (userInfoBtn && userDropdown) {
            userInfoBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                userDropdown.classList.toggle('active');
            });
        }

        // Logout
        if (dropdownLogoutBtn) {
            dropdownLogoutBtn.addEventListener('click', () => {
                if (confirm('Apakah Anda yakin ingin logout?')) {
                    UserManager.logout();
                    window.location.href = 'index.html';
                }
            });
        }
    } else {
        // If not on login page and not logged in, redirect
        if (!window.location.pathname.endsWith('index.html')) {
            window.location.href = 'index.html';
        }
    }

    // Close dropdowns when clicking outside
    document.addEventListener('click', (e) => {
        if (userDropdown && !userDropdown.contains(e.target) && !userInfoBtn.contains(e.target)) {
            userDropdown.classList.remove('active');
        }
        if (sidebar && mainContent && !sidebar.contains(e.target) && sidebar.classList.contains('active')) {
             sidebar.classList.remove('active');
        }
    });
});
