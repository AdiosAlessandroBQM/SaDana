document.addEventListener('DOMContentLoaded', () => {
    let editingProductId = null;

    const modal = document.getElementById('productModal');
    const modalTitle = document.getElementById('modalTitle');
    const productForm = document.getElementById('productForm');
    const tbody = document.getElementById('productsTableBody');
    const searchInput = document.getElementById('searchInput');
    const categoryFilter = document.getElementById('categoryFilter');

    function loadProducts() {
        const searchTerm = searchInput.value;
        const category = categoryFilter.value;

        const products = ProductManager.getAll();
        const filtered = products.filter(p => 
            p.name.toLowerCase().includes(searchTerm.toLowerCase()) && 
            (!category || p.category === category)
        );

        if (filtered.length === 0) {
            tbody.innerHTML = `<tr><td colspan="6" class="text-center text-muted p-xl">Tidak ada produk ditemukan</td></tr>`;
            return;
        }

        tbody.innerHTML = filtered.map(p => {
            const stockStatus = p.stock < 10 ? '<span class="badge badge-danger">⚠️ Stok Menipis</span>' : '<span class="badge badge-success">✓ Stok Aman</span>';
            return `
                <tr>
                    <td><strong>${p.name}</strong></td>
                    <td>${p.category}</td>
                    <td>${Utils.formatCurrency(p.price)}</td>
                    <td><strong>${p.stock}</strong></td>
                    <td>${stockStatus}</td>
                    <td>
                        <div class="action-buttons">
                            <button class="btn btn-sm btn-secondary btn-edit" data-id="${p.id}">✏️</button>
                            <button class="btn btn-sm btn-danger btn-delete" data-id="${p.id}">🗑️</button>
                        </div>
                    </td>
                </tr>
            `;
        }).join('');
    }
    
    tbody.addEventListener('click', (e) => {
        const editBtn = e.target.closest('.btn-edit');
        if (editBtn) {
            editProduct(parseInt(editBtn.dataset.id));
        }
        const deleteBtn = e.target.closest('.btn-delete');
        if (deleteBtn) {
            deleteProduct(parseInt(deleteBtn.dataset.id));
        }
    });

    document.getElementById('addProductBtn').addEventListener('click', () => {
        editingProductId = null;
        modalTitle.textContent = 'Tambah Produk';
        productForm.reset();
        modal.classList.add('active');
    });

    function editProduct(id) {
        const product = ProductManager.getById(id);
        if (!product) return;
        editingProductId = id;
        modalTitle.textContent = 'Edit Produk';
        document.getElementById('productId').value = product.id;
        document.getElementById('productName').value = product.name;
        document.getElementById('productCategory').value = product.category;
        document.getElementById('productPrice').value = product.price;
        document.getElementById('productStock').value = product.stock;
        modal.classList.add('active');
    }

    function deleteProduct(id) {
        const product = ProductManager.getById(id);
        if (!Utils.confirm(`Hapus produk "${product.name}"?`)) return;
        if (ProductManager.delete(id).success) {
            Utils.showAlert('Produk berhasil dihapus', 'success');
            loadProducts();
        }
    }

    productForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const productData = { name: document.getElementById('productName').value, category: document.getElementById('productCategory').value, price: parseInt(document.getElementById('productPrice').value), stock: parseInt(document.getElementById('productStock').value) };
        const result = editingProductId ? ProductManager.update(editingProductId, productData) : ProductManager.add(productData);
        if (result.success) {
            Utils.showAlert(editingProductId ? 'Produk berhasil diupdate' : 'Produk berhasil ditambahkan', 'success');
            closeModal();
            loadProducts();
        }
    });

    function closeModal() {
        modal.classList.remove('active');
        productForm.reset();
        editingProductId = null;
    }

    document.getElementById('closeModalBtn').addEventListener('click', closeModal);
    document.getElementById('cancelBtn').addEventListener('click', closeModal);

    searchInput.addEventListener('input', loadProducts);
    categoryFilter.addEventListener('change', loadProducts);

    loadProducts();
});
