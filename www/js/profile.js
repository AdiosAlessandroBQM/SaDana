document.addEventListener('DOMContentLoaded', () => {
    const currentUser = UserManager.getCurrentUser();
    if (!currentUser) {
        window.location.href = 'index.html';
        return;
    }

    function loadProfile() {
        const user = UserManager.getById(currentUser.id);
        if (!user) return;

        document.getElementById('profileName').textContent = user.name;
        document.getElementById('profileUsername').textContent = user.username;
        document.getElementById('editName').value = user.name;
        document.getElementById('editUsername').value = user.username;

        if (user.createdAt) {
            const joinDate = new Date(user.createdAt);
            document.getElementById('statJoinDate').textContent = joinDate.toLocaleDateString('id-ID', { month: 'short', year: 'numeric' });
        }

        // Load stats
        const userTransactions = TransactionManager.getAll().filter(t => t.cashier === user.username);
        const todayTransactions = TransactionManager.getToday().filter(t => t.cashier === user.username);
        document.getElementById('statTodayTrans').textContent = todayTransactions.length;
        document.getElementById('statTotalTrans').textContent = userTransactions.length;
    }

    document.getElementById('profileForm').addEventListener('submit', (e) => {
        e.preventDefault();
        const newName = document.getElementById('editName').value;
        if (UserManager.update(currentUser.id, { name: newName }).success) {
            Utils.showAlert('Profil berhasil diperbarui', 'success');
            // Update name in sidebar immediately
            document.getElementById('userName').textContent = newName;
        } else {
            Utils.showAlert('Gagal memperbarui profil', 'danger');
        }
    });

    document.getElementById('passwordForm').addEventListener('submit', (e) => {
        e.preventDefault();
        const oldPassword = document.getElementById('oldPassword').value;
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;

        if (newPassword !== confirmPassword) {
            return Utils.showAlert('Password baru tidak cocok!', 'danger');
        }
        if (newPassword.length < 6) {
            return Utils.showAlert('Password baru minimal 6 karakter', 'warning');
        }

        const result = UserManager.changePassword(currentUser.id, oldPassword, newPassword);
        if (result.success) {
            Utils.showAlert('Password berhasil diubah', 'success');
            document.getElementById('passwordForm').reset();
        } else {
            Utils.showAlert(result.message, 'danger');
        }
    });

    loadProfile();
});
