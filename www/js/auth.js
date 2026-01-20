document.addEventListener('DOMContentLoaded', () => {
    if (UserManager.isLoggedIn()) {
        window.location.href = 'dashboard.html';
        return;
    }

    const loginForm = document.getElementById('loginForm');
    const registerForm = document.getElementById('registerForm');
    const showRegisterBtn = document.getElementById('showRegister');
    const showLoginBtn = document.getElementById('showLogin');

    showRegisterBtn.addEventListener('click', (e) => {
        e.preventDefault();
        loginForm.classList.add('form-hidden');
        registerForm.classList.remove('form-hidden');
    });

    showLoginBtn.addEventListener('click', (e) => {
        e.preventDefault();
        registerForm.classList.add('form-hidden');
        loginForm.classList.remove('form-hidden');
    });

    loginForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const username = document.getElementById('loginUsername').value;
        const password = document.getElementById('loginPassword').value;
        const result = UserManager.login(username, password);

        if (result.success) {
            Utils.showAlert('Login berhasil! Menuju dashboard...', 'success');
            setTimeout(() => { window.location.href = 'dashboard.html'; }, 1000);
        } else {
            Utils.showAlert(result.message, 'danger');
        }
    });

    registerForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const name = document.getElementById('registerName').value;
        const username = document.getElementById('registerUsername').value;
        const password = document.getElementById('registerPassword').value;
        const confirmPassword = document.getElementById('registerConfirmPassword').value;

        if (password !== confirmPassword) {
            Utils.showAlert('Password tidak cocok!', 'danger');
            return;
        }
        if (password.length < 6) {
            Utils.showAlert('Password minimal 6 karakter!', 'danger');
            return;
        }

        const result = UserManager.register(username, password, name);

        if (result.success) {
            Utils.showAlert('Pendaftaran berhasil! Silakan login.', 'success');
            registerForm.reset();
            setTimeout(() => {
                registerForm.classList.add('form-hidden');
                loginForm.classList.remove('form-hidden');
            }, 1500);
        } else {
            Utils.showAlert(result.message, 'danger');
        }
    });
});
