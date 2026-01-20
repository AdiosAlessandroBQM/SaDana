document.addEventListener('DOMContentLoaded', () => {
    let currentTransactions = [];

    const transactionsList = document.getElementById('transactionsList');
    const detailModal = document.getElementById('detailModal');
    const detailContent = document.getElementById('detailContent');

    function loadTransactions(startDate = null, endDate = null) {
        let transactions = TransactionManager.getAll();
        if (startDate && endDate) {
            transactions = TransactionManager.getByDateRange(startDate, endDate);
        }

        transactions.sort((a, b) => new Date(b.date) - new Date(a.date));
        currentTransactions = transactions;

        displayTransactions(transactions);
        updateStats(transactions);
    }

    function displayTransactions(transactions) {
        if (transactions.length === 0) {
            transactionsList.innerHTML = '<div class="empty-state">Tidak ada transaksi ditemukan.</div>';
            return;
        }
        transactionsList.innerHTML = transactions.map(t => `
            <div class="transaction-card" data-id="${t.id}">
                <div class="transaction-header">
                    <div>
                        <div class="transaction-id">#${t.id}</div>
                        <div class="transaction-meta">${Utils.formatDate(t.date)}</div>
                        <div class="transaction-meta">Kasir: ${t.cashier} • ${t.items.length} item</div>
                    </div>
                    <div class="transaction-total">${Utils.formatCurrency(t.total)}</div>
                </div>
            </div>
        `).join('');
    }

    function updateStats(transactions) {
        const totalRevenue = TransactionManager.getTotalRevenue(transactions);
        const totalCount = transactions.length;
        const avgTransaction = totalCount > 0 ? totalRevenue / totalCount : 0;

        document.getElementById('totalRevenue').textContent = Utils.formatCurrency(totalRevenue);
        document.getElementById('totalTransactions').textContent = totalCount;
        document.getElementById('avgTransaction').textContent = Utils.formatCurrency(avgTransaction);
    }

    transactionsList.addEventListener('click', (e) => {
        const card = e.target.closest('.transaction-card');
        if (card) {
            showDetail(parseInt(card.dataset.id));
        }
    });

    function showDetail(id) {
        const transaction = currentTransactions.find(t => t.id === id);
        if (!transaction) return;
        detailContent.innerHTML = `
            <div class="receipt">
                <div class="receipt-info" style="text-align: left;">
                    <div><span>No. Transaksi:</span> <strong>#${transaction.id}</strong></div>
                    <div><span>Tanggal:</span> <strong>${Utils.formatDate(transaction.date)}</strong></div>
                    <div><span>Kasir:</span> <strong>${transaction.cashier}</strong></div>
                </div>
                <div class="receipt-items"></div>
                 <div class="receipt-total">
                    <div class="receipt-item"><strong>TOTAL</strong><strong>${Utils.formatCurrency(transaction.total)}</strong></div>
                </div>
            </div>
        `;
        const itemsContainer = detailContent.querySelector('.receipt-items');
        transaction.items.forEach(item => {
            itemsContainer.innerHTML += `<div class="receipt-item"><span>${item.name} x${item.qty}</span><span>${Utils.formatCurrency(item.price * item.qty)}</span></div>`;
        });
        detailModal.classList.add('active');
    }

    document.getElementById('closeDetailBtn').addEventListener('click', () => detailModal.classList.remove('active'));

    // Filter buttons
    document.getElementById('todayBtn').addEventListener('click', () => {
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const tomorrow = new Date(today); tomorrow.setDate(tomorrow.getDate() + 1);
        loadTransactions(today, tomorrow);
    });
    document.getElementById('weekBtn').addEventListener('click', () => {
        const end = new Date(); const start = new Date(); start.setDate(start.getDate() - 7);
        loadTransactions(start, end);
    });
    document.getElementById('monthBtn').addEventListener('click', () => {
        const end = new Date(); const start = new Date(); start.setDate(start.getDate() - 30);
        loadTransactions(start, end);
    });
    document.getElementById('allBtn').addEventListener('click', () => loadTransactions());
    document.getElementById('filterBtn').addEventListener('click', () => {
        const startDate = new Date(document.getElementById('startDate').value);
        const endDate = new Date(document.getElementById('endDate').value);
        endDate.setHours(23, 59, 59, 999);
        if (isNaN(startDate.getTime()) || isNaN(endDate.getTime())) {
            return Utils.showAlert('Pilih tanggal yang valid', 'warning');
        }
        loadTransactions(startDate, endDate);
    });

    loadTransactions(); // Initial load
});
