document.addEventListener('DOMContentLoaded', () => {
    let cart = [];

    const productsGrid = document.getElementById('productsGrid');
    const searchInput = document.getElementById('searchInput');

    function getProductIcon(category) {
        const icons = { 'Makanan': '🍜', 'Minuman': '🥤', 'Snack': '🍿', 'Sembako': '🌾' };
        return icons[category] || '📦';
    }

    function loadProducts(searchTerm = '') {
        const products = ProductManager.getAll();
        const filtered = products.filter(p => p.name.toLowerCase().includes(searchTerm.toLowerCase()));

        if (filtered.length === 0) {
            productsGrid.innerHTML = '<div class="empty-state">Tidak ada produk ditemukan.</div>';
            return;
        }

        productsGrid.innerHTML = filtered.map(p => `
            <div class="product-card" data-id="${p.id}">
                <div class="product-icon">${getProductIcon(p.category)}</div>
                <div class="product-name">${p.name}</div>
                <div class="product-price">${Utils.formatCurrency(p.price)}</div>
                <div class="product-stock">Stok: ${p.stock}</div>
            </div>
        `).join('');
    }

    productsGrid.addEventListener('click', (e) => {
        const card = e.target.closest('.product-card');
        if (card) {
            addToCart(parseInt(card.dataset.id));
        }
    });

    function addToCart(productId) {
        const product = ProductManager.getById(productId);
        if (!product || product.stock < 1) {
            return Utils.showAlert('Stok produk habis!', 'warning');
        }

        const cartItem = cart.find(item => item.productId === productId);
        if (cartItem) {
            if (cartItem.qty >= product.stock) {
                return Utils.showAlert('Stok tidak mencukupi!', 'warning');
            }
            cartItem.qty++;
        } else {
            cart.push({ productId, name: product.name, price: product.price, qty: 1, maxStock: product.stock });
        }
        updateCart();
    }

    function updateCart() {
        const cartItemsDiv = document.getElementById('cartItems');
        const cartTotalDiv = document.getElementById('cartTotal');
        const checkoutBtn = document.getElementById('checkoutBtn');

        if (cart.length === 0) {
            cartItemsDiv.innerHTML = '<div class="empty-cart"><div class="empty-cart-icon">🛒</div><p>Keranjang kosong</p></div>';
            cartTotalDiv.style.display = 'none';
            checkoutBtn.disabled = true;
            return;
        }

        cartItemsDiv.innerHTML = cart.map((item, index) => `
            <div class="cart-item">
                <div class="cart-item-details">
                    <span class="cart-item-name">${item.name}</span>
                    <span class="cart-item-subtotal">${Utils.formatCurrency(item.price * item.qty)}</span>
                </div>
                <div class="cart-item-controls">
                    <button class="qty-btn" data-index="${index}" data-change="-1">-</button>
                    <span class="qty-display">${item.qty}</span>
                    <button class="qty-btn" data-index="${index}" data-change="1">+</button>
                    <button class="cart-item-remove" data-index="${index}">×</button>
                </div>
            </div>
        `).join('');

        const total = cart.reduce((sum, item) => sum + (item.price * item.qty), 0);
        document.getElementById('grandTotal').textContent = Utils.formatCurrency(total);
        cartTotalDiv.style.display = 'block';
        checkoutBtn.disabled = false;
    }

    cartItemsDiv.addEventListener('click', (e) => {
        if (e.target.matches('.qty-btn')) {
            const index = parseInt(e.target.dataset.index);
            const change = parseInt(e.target.dataset.change);
            updateQuantity(index, change);
        } else if (e.target.matches('.cart-item-remove')) {
            const index = parseInt(e.target.dataset.index);
            removeFromCart(index);
        }
    });

    function updateQuantity(index, change) {
        const item = cart[index];
        if (!item) return;
        const newQty = item.qty + change;
        if (newQty < 1) {
            removeFromCart(index);
        } else if (newQty > item.maxStock) {
            Utils.showAlert('Stok tidak mencukupi!', 'warning');
        } else {
            item.qty = newQty;
            updateCart();
        }
    }

    function removeFromCart(index) {
        cart.splice(index, 1);
        updateCart();
    }

    document.getElementById('clearCartBtn').addEventListener('click', () => {
        if (cart.length > 0 && Utils.confirm('Kosongkan keranjang?')) {
            cart = [];
            updateCart();
        }
    });

    document.getElementById('checkoutBtn').addEventListener('click', () => {
        if (cart.length === 0) return;
        const total = cart.reduce((sum, item) => sum + (item.price * item.qty), 0);
        const transaction = { items: cart, total };
        const result = TransactionManager.add(transaction);
        if (result.success) {
            showReceipt(result.transaction);
            cart = [];
            updateCart();
            loadProducts(); // Refresh stock
        }
    });
    
    function showReceipt(transaction) {
        const receiptContent = document.getElementById('receiptContent');
        const now = new Date();
        receiptContent.innerHTML = `
            <div class="receipt">
                 <div class="receipt-header">
                    <div class="receipt-title">🏪 WARUNG ANDA</div>
                    <p>Jl. Merdeka No. 1, Jakarta</p>
                </div>
                <div class="receipt-info">
                    <div><span>No:</span> #${transaction.id}</div>
                    <div><span>Kasir:</span> ${transaction.cashier}</div>
                    <div><span>Tanggal:</span> ${now.toLocaleDateString('id-ID')} ${now.toLocaleTimeString('id-ID')}</div>
                </div>
                <div class="receipt-items"></div>
            </div>
        `;
        const itemsContainer = receiptContent.querySelector('.receipt-items');
        transaction.items.forEach(item => {
            itemsContainer.innerHTML += `<div class="receipt-item"><span>${item.name} (${item.qty}x)</span><span>${Utils.formatCurrency(item.price * item.qty)}</span></div>`;
        });
        receiptContent.querySelector('.receipt').innerHTML += `
            <div class="receipt-total">
                <div class="receipt-item"><strong>TOTAL</strong><strong>${Utils.formatCurrency(transaction.total)}</strong></div>
            </div>
            <div class="receipt-footer">Terima Kasih!</div>
        `;
        document.getElementById('receiptModal').classList.add('active');
    }

    document.getElementById('printBtn').addEventListener('click', () => window.print());
    document.getElementById('closeReceiptBtn').addEventListener('click', () => document.getElementById('receiptModal').classList.remove('active'));
    document.getElementById('newTransactionBtn').addEventListener('click', () => document.getElementById('receiptModal').classList.remove('active'));

    searchInput.addEventListener('input', (e) => loadProducts(e.target.value));

    loadProducts();
    updateCart();
});
