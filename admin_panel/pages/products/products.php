<?php
$currentPage = 'products';
$pageTitle   = 'Products';
require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt = session_get_jwt();

include __DIR__ . '/../../includes/header.php';
include __DIR__ . '/../../includes/sidebar.php';
include __DIR__ . '/../../includes/loader.php';
?>

<div class="sidebar-overlay" id="sidebarOverlay" onclick="MSM.toggleSidebar()"></div>

<div class="admin-content">
    <!-- TOP NAVBAR -->
    <div class="admin-navbar">
        <div class="navbar-left">
            <button class="btn btn-sm d-lg-none" onclick="MSM.toggleSidebar()" style="font-size:1.2rem;color:var(--msm-muted);">
                <i class="bi bi-list"></i>
            </button>
            <div class="navbar-brand-text"><span><?php echo $pageTitle; ?></span></div>
        </div>
        <div class="navbar-search d-none d-md-block">
            <i class="bi bi-search search-icon"></i>
            <input type="text" class="form-control" id="globalSearch" placeholder="Search products..." autocomplete="off">
            <span class="search-kbd">Ctrl+K</span>
            <div class="search-results-dropdown" id="searchResults"></div>
        </div>
        <div class="navbar-right">
            <div style="position:relative;">
                <button class="navbar-icon-btn" onclick="MSM.toggleDropdown('notifDropdown')" title="Notifications">
                    <i class="bi bi-bell"></i>
                </button>
                <div class="notification-dropdown" id="notifDropdown">
                    <div class="notif-header"><h6>Notifications</h6></div>
                    <div class="notif-list">
                        <div class="notif-item"><div class="notif-content"><div class="notif-title">All caught up!</div><div class="notif-msg">No new notifications.</div></div></div>
                    </div>
                </div>
            </div>
            <div style="position:relative;">
                <img src="<?php echo htmlspecialchars($adminAvatar); ?>" alt="Admin" class="profile-avatar"
                     onerror="this.src='https://ui-avatars.com/api/?name=<?php echo urlencode($adminName); ?>&background=198754&color=fff&size=36'"
                     onclick="MSM.toggleDropdown('profileDropdown')">
                <div class="profile-dropdown" id="profileDropdown">
                    <div style="padding:0.75rem 1rem;border-bottom:1px solid var(--msm-border);">
                        <div style="font-weight:600;font-size:0.85rem;"><?php echo htmlspecialchars($adminName); ?></div>
                        <div style="font-size:0.75rem;color:var(--msm-muted);"><?php echo htmlspecialchars($adminEmail); ?></div>
                    </div>
                    <a href="<?php echo admin_url('pages/profile/profile.php'); ?>"><i class="bi bi-person"></i> Profile</a>
                    <a href="<?php echo admin_url('pages/settings/settings.php'); ?>"><i class="bi bi-gear"></i> Settings</a>
                    <div class="dropdown-divider" style="border-top:1px solid var(--msm-border);"></div>
                    <a href="<?php echo admin_url('auth/logout.php'); ?>" class="logout-link"><i class="bi bi-box-arrow-right"></i> Logout</a>
                </div>
            </div>
        </div>
    </div>

    <!-- PAGE CONTENT -->
    <div class="p-3 p-md-4">
        <!-- Stats Row -->
        <div class="row g-3 mb-4">
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#198754,#0d6e3f);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Total Products</div>
                            <div class="stat-value text-success" id="statTotal">—</div>
                        </div>
                        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="bi bi-box-seam"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#0d6efd,#0b5ed7);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">In Stock</div>
                            <div class="stat-value" style="color:#0d6efd;" id="statInStock">—</div>
                        </div>
                        <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-check-circle"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#ffc107,#e0a800);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Low Stock</div>
                            <div class="stat-value" style="color:#e0a800;" id="statLowStock">—</div>
                        </div>
                        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-exclamation-triangle"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#dc3545,#b02a37);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Out of Stock</div>
                            <div class="stat-value" style="color:#dc3545;" id="statOutOfStock">—</div>
                        </div>
                        <div class="stat-icon bg-danger bg-opacity-10 text-danger"><i class="bi bi-x-circle"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Products Table Card -->
        <div class="msm-card p-0 animate-in">
            <div class="table-toolbar">
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <h6 class="mb-0 fw-bold">All Products</h6>
                    <span class="badge bg-secondary" id="totalCount">0</span>
                </div>
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <div class="input-group input-group-sm" style="width:220px;">
                        <span class="input-group-text bg-transparent"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control" id="searchInput" placeholder="Search products...">
                    </div>
                    <select class="form-select form-select-sm" id="categoryFilter" style="width:160px;">
                        <option value="">All Categories</option>
                    </select>
                    <button class="btn btn-sm btn-msm" onclick="Products.openAddModal()">
                        <i class="bi bi-plus-lg me-1"></i> Add Product
                    </button>
                </div>
            </div>

            <!-- Skeleton Loader -->
            <div id="skeletonLoader">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light"><tr><th>Image</th><th>Name</th><th>Category</th><th>Price</th><th>Stock</th><th>Status</th><th>Actions</th></tr></thead>
                    <tbody>
                        <?php for ($i = 0; $i < 8; $i++): ?>
                        <tr>
                            <td><div class="skeleton" style="width:44px;height:44px;border-radius:8px;"></div></td>
                            <td><div class="skeleton" style="width:120px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:80px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:70px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:40px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:60px;height:22px;border-radius:6px;"></div></td>
                            <td><div class="skeleton" style="width:60px;height:28px;border-radius:6px;"></div></td>
                        </tr>
                        <?php endfor; ?>
                    </tbody>
                </table>
            </div>

            <!-- Actual Table -->
            <div class="table-responsive" id="tableContent" style="display:none;">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Image</th>
                            <th>Name</th>
                            <th>Category</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Status</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="productsTableBody"></tbody>
                </table>
            </div>

            <!-- Empty State -->
            <div id="emptyState" style="display:none;">
                <div class="empty-state py-5">
                    <i class="bi bi-box-seam"></i>
                    <p>No products found.</p>
                    <button class="btn btn-sm btn-msm mt-2" onclick="Products.openAddModal()">
                        <i class="bi bi-plus-lg me-1"></i> Add First Product
                    </button>
                </div>
            </div>

            <!-- Pagination -->
            <div class="d-flex align-items-center justify-content-between p-3 border-top" id="paginationWrap" style="display:none;">
                <div class="small text-muted" id="paginationInfo">Showing 0 products</div>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="paginationLinks"></ul>
                </nav>
            </div>
        </div>
    </div>
</div>

<!-- Add/Edit Product Modal -->
<div class="modal fade" id="productModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title fw-bold" id="productModalTitle">Add Product</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="productForm" enctype="multipart/form-data">
                    <input type="hidden" id="productId" value="">
                    <div class="row g-3">
                        <div class="col-md-8">
                            <label class="form-label fw-semibold">Product Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="productName" required placeholder="e.g. Fresh Tomatoes">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Category <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="productCategory" required placeholder="e.g. Vegetables" list="categorySuggestions">
                            <datalist id="categorySuggestions"></datalist>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Price (FCFA) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="productPrice" required min="0" placeholder="0">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Stock <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="productStock" required min="0" placeholder="0">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Unit</label>
                            <select class="form-select" id="productUnit">
                                <option value="kg">Kilogram (kg)</option>
                                <option value="g">Gram (g)</option>
                                <option value="l">Liter (l)</option>
                                <option value="ml">Milliliter (ml)</option>
                                <option value="piece">Piece</option>
                                <option value="pack">Pack</option>
                                <option value="bag">Bag</option>
                                <option value="bottle">Bottle</option>
                                <option value="box">Box</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Availability</label>
                            <div class="form-check form-switch mt-2">
                                <input class="form-check-input" type="checkbox" id="productAvailable" checked>
                                <label class="form-check-label" for="productAvailable">Available</label>
                            </div>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Description</label>
                            <textarea class="form-control" id="productDescription" rows="3" placeholder="Optional product description..."></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Product Image</label>
                            <div class="d-flex align-items-start gap-3">
                                <div id="imagePreviewContainer" style="width:100px;height:100px;border:2px dashed var(--msm-border);border-radius:10px;display:flex;align-items:center;justify-content:center;overflow:hidden;flex-shrink:0;background:#f8f9fa;">
                                    <i class="bi bi-image text-muted" id="imagePreviewIcon" style="font-size:1.5rem;"></i>
                                    <img id="imagePreviewImg" src="" alt="" style="display:none;width:100%;height:100%;object-fit:cover;">
                                </div>
                                <div>
                                    <input type="file" class="form-control" id="productImage" accept="image/*" style="font-size:0.85rem;">
                                    <div class="form-text">JPEG, PNG, WebP or GIF. Max 5MB.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer border-top-0 pt-0">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-msm" id="productSubmitBtn" onclick="Products.save()">
                    <span id="productSubmitText">Save Product</span>
                    <span id="productSubmitSpinner" class="spinner-border spinner-border-sm d-none" role="status"></span>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-body text-center p-4">
                <div style="width:56px;height:56px;border-radius:50%;background:#fef2f2;display:flex;align-items:center;justify-content:center;margin:0 auto 1rem;">
                    <i class="bi bi-trash text-danger" style="font-size:1.5rem;"></i>
                </div>
                <h6 class="fw-bold mb-2">Delete Product?</h6>
                <p class="text-muted small mb-0">This action cannot be undone.</p>
            </div>
            <div class="modal-footer border-top-0 justify-content-center pt-0 pb-3">
                <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger btn-sm" id="confirmDeleteBtn" onclick="Products.confirmDelete()">
                    <span id="deleteBtnText">Delete</span>
                    <span id="deleteBtnSpinner" class="spinner-border spinner-border-sm d-none" role="status"></span>
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var Products = (function() {
    var API_BASE = '<?php echo API_FOODSTUFFS; ?>';
    var API_URL  = '<?php echo API_FOODSTUFFS; ?>';
    var allProducts = [];
    var filteredProducts = [];
    var categories = [];
    var currentPage = 1;
    var perPage = <?php echo PER_PAGE; ?>;
    var totalPages = 1;
    var deleteTargetId = null;
    var editingId = null;
    var productModal = null;
    var deleteModal = null;

    function init() {
        productModal = new bootstrap.Modal(document.getElementById('productModal'));
        deleteModal = new bootstrap.Modal(document.getElementById('deleteModal'));

        document.getElementById('searchInput').addEventListener('input', debounce(applyFilters, 300));
        document.getElementById('categoryFilter').addEventListener('change', applyFilters);
        document.getElementById('productImage').addEventListener('change', previewImage);

        document.getElementById('productModal').addEventListener('hidden.bs.modal', function() {
            resetForm();
        });

        loadProducts();
    }

    function debounce(fn, ms) {
        var timer;
        return function() {
            clearTimeout(timer);
            timer = setTimeout(fn, ms);
        };
    }

    function loadProducts() {
        fetchProducts(function(data) {
            allProducts = data.products || [];
            extractCategories();
            applyFilters();
            updateStats(data);
        });
    }

    function fetchProducts(callback) {
        fetch(API_URL + '?limit=100', {
            headers: { 'Accept': 'application/json' }
        })
        .then(function(r) { return r.json(); })
        .then(function(res) { callback(res); })
        .catch(function() {
            showToast('error', 'Failed to load products.');
            showEmptyState();
        });
    }

    function extractCategories() {
        var cats = {};
        allProducts.forEach(function(p) {
            var cat = p.category || '';
            if (cat) cats[cat] = true;
        });
        categories = Object.keys(cats).sort();
        var sel = document.getElementById('categoryFilter');
        var currentVal = sel.value;
        sel.innerHTML = '<option value="">All Categories</option>';
        categories.forEach(function(c) {
            var opt = document.createElement('option');
            opt.value = c;
            opt.textContent = c;
            sel.appendChild(opt);
        });
        sel.value = currentVal;

        var dl = document.getElementById('categorySuggestions');
        dl.innerHTML = '';
        categories.forEach(function(c) {
            var opt = document.createElement('option');
            opt.value = c;
            dl.appendChild(opt);
        });
    }

    function applyFilters() {
        var query = document.getElementById('searchInput').value.toLowerCase().trim();
        var catFilter = document.getElementById('categoryFilter').value;

        filteredProducts = allProducts.filter(function(p) {
            var matchSearch = !query || (p.name && p.name.toLowerCase().indexOf(query) !== -1) ||
                              (p.category && p.category.toLowerCase().indexOf(query) !== -1) ||
                              (p.description && p.description.toLowerCase().indexOf(query) !== -1);
            var matchCat = !catFilter || p.category === catFilter;
            return matchSearch && matchCat;
        });

        totalPages = Math.max(1, Math.ceil(filteredProducts.length / perPage));
        if (currentPage > totalPages) currentPage = 1;
        renderTable();
        renderPagination();
    }

    function updateStats(data) {
        var total = allProducts.length;
        var inStock = allProducts.filter(function(p) { return (p.stock || 0) > 0; }).length;
        var lowStock = allProducts.filter(function(p) { return (p.stock || 0) > 0 && (p.stock || 0) <= 10; }).length;
        var outOfStock = total - inStock;

        document.getElementById('statTotal').textContent = total.toLocaleString();
        document.getElementById('statInStock').textContent = inStock.toLocaleString();
        document.getElementById('statLowStock').textContent = lowStock.toLocaleString();
        document.getElementById('statOutOfStock').textContent = outOfStock.toLocaleString();
        document.getElementById('totalCount').textContent = total;
    }

    function renderTable() {
        var tbody = document.getElementById('productsTableBody');
        var start = (currentPage - 1) * perPage;
        var pageItems = filteredProducts.slice(start, start + perPage);

        if (pageItems.length === 0) {
            document.getElementById('tableContent').style.display = 'none';
            document.getElementById('skeletonLoader').style.display = 'none';
            document.getElementById('emptyState').style.display = 'block';
            document.getElementById('paginationWrap').style.display = 'none';
            return;
        }

        document.getElementById('skeletonLoader').style.display = 'none';
        document.getElementById('emptyState').style.display = 'none';
        document.getElementById('tableContent').style.display = 'block';
        document.getElementById('paginationWrap').style.display = 'flex';

        var html = '';
        pageItems.forEach(function(p) {
            var id = p._id || p.id || '';
            var name = escapeHtml(p.name || 'Untitled');
            var cat = escapeHtml(p.category || '—');
            var price = (p.price || 0).toLocaleString();
            var stock = p.stock || 0;
            var unit = escapeHtml(p.unit || 'kg');
            var available = p.isAvailable !== false;
            var img = p.image || '';
            var imgHtml = img
                ? '<img src="' + msmImgUrl(img) + '" alt="" style="width:44px;height:44px;border-radius:8px;object-fit:cover;">'
                : '<div style="width:44px;height:44px;border-radius:8px;background:var(--msm-bg);display:flex;align-items:center;justify-content:center;color:var(--msm-muted);"><i class="bi bi-image"></i></div>';

            var stockBadge = '';
            if (stock <= 0) stockBadge = '<span class="badge bg-danger badge-status">Out</span>';
            else if (stock <= 10) stockBadge = '<span class="badge bg-warning text-dark badge-status">Low: ' + stock + '</span>';
            else stockBadge = '<span class="badge bg-success badge-status">' + stock + '</span>';

            var statusBadge = available
                ? '<span class="badge bg-success badge-status">Available</span>'
                : '<span class="badge bg-secondary badge-status">Unavailable</span>';

            html += '<tr class="animate-in">' +
                '<td>' + imgHtml + '</td>' +
                '<td><span class="fw-semibold">' + name + '</span></td>' +
                '<td><span class="text-muted">' + cat + '</span></td>' +
                '<td class="fw-semibold">' + price + ' <small class="text-muted">FCFA</small></td>' +
                '<td>' + stockBadge + ' <small class="text-muted">' + unit + '</small></td>' +
                '<td>' + statusBadge + '</td>' +
                '<td class="text-end">' +
                    '<button class="btn btn-sm btn-outline-primary me-1" onclick="Products.openEditModal(\'' + id + '\')" title="Edit"><i class="bi bi-pencil"></i></button>' +
                    '<button class="btn btn-sm btn-outline-danger" onclick="Products.openDeleteModal(\'' + id + '\')" title="Delete"><i class="bi bi-trash"></i></button>' +
                '</td>' +
            '</tr>';
        });
        tbody.innerHTML = html;

        var showing = Math.min(start + perPage, filteredProducts.length);
        document.getElementById('paginationInfo').textContent = 'Showing ' + (filteredProducts.length > 0 ? start + 1 : 0) + '-' + showing + ' of ' + filteredProducts.length + ' products';
    }

    function renderPagination() {
        var links = document.getElementById('paginationLinks');
        if (totalPages <= 1) { links.innerHTML = ''; return; }

        var html = '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') + '">' +
            '<a class="page-link" href="#" onclick="Products.goToPage(' + (currentPage - 1) + ');return false;"><i class="bi bi-chevron-left"></i></a></li>';

        var startPage = Math.max(1, currentPage - 2);
        var endPage = Math.min(totalPages, currentPage + 2);

        if (startPage > 1) {
            html += '<li class="page-item"><a class="page-link" href="#" onclick="Products.goToPage(1);return false;">1</a></li>';
            if (startPage > 2) html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
        }

        for (var i = startPage; i <= endPage; i++) {
            html += '<li class="page-item ' + (i === currentPage ? 'active' : '') + '">' +
                '<a class="page-link" href="#" onclick="Products.goToPage(' + i + ');return false;">' + i + '</a></li>';
        }

        if (endPage < totalPages) {
            if (endPage < totalPages - 1) html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
            html += '<li class="page-item"><a class="page-link" href="#" onclick="Products.goToPage(' + totalPages + ');return false;">' + totalPages + '</a></li>';
        }

        html += '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '">' +
            '<a class="page-link" href="#" onclick="Products.goToPage(' + (currentPage + 1) + ');return false;"><i class="bi bi-chevron-right"></i></a></li>';

        links.innerHTML = html;
    }

    function goToPage(page) {
        if (page < 1 || page > totalPages) return;
        currentPage = page;
        renderTable();
        renderPagination();
    }

    function openAddModal() {
        editingId = null;
        resetForm();
        document.getElementById('productModalTitle').textContent = 'Add Product';
        document.getElementById('productSubmitText').textContent = 'Save Product';
        productModal.show();
    }

    function openEditModal(id) {
        var p = allProducts.find(function(item) { return (item._id || item.id) === id; });
        if (!p) return;

        editingId = id;
        document.getElementById('productModalTitle').textContent = 'Edit Product';
        document.getElementById('productSubmitText').textContent = 'Update Product';
        document.getElementById('productId').value = id;
        document.getElementById('productName').value = p.name || '';
        document.getElementById('productCategory').value = p.category || '';
        document.getElementById('productPrice').value = p.price || '';
        document.getElementById('productStock').value = p.stock || '';
        document.getElementById('productUnit').value = p.unit || 'kg';
        document.getElementById('productDescription').value = p.description || '';
        document.getElementById('productAvailable').checked = p.isAvailable !== false;

        var previewImg = document.getElementById('imagePreviewImg');
        var previewIcon = document.getElementById('imagePreviewIcon');
        if (p.image) {
            previewImg.src = msmImgUrl(p.image);
            previewImg.style.display = 'block';
            previewIcon.style.display = 'none';
        } else {
            previewImg.style.display = 'none';
            previewIcon.style.display = 'block';
        }

        productModal.show();
    }

    function openDeleteModal(id) {
        deleteTargetId = id;
        deleteModal.show();
    }

    function save() {
        var name = document.getElementById('productName').value.trim();
        var category = document.getElementById('productCategory').value.trim();
        var price = document.getElementById('productPrice').value;
        var stock = document.getElementById('productStock').value;

        if (!name || !category || price === '' || stock === '') {
            showToast('warning', 'Please fill in all required fields.');
            return;
        }

        var payload = {
            name: name,
            category: category,
            price: parseFloat(price),
            stock: parseInt(stock),
            unit: document.getElementById('productUnit').value,
            description: document.getElementById('productDescription').value.trim(),
            isAvailable: document.getElementById('productAvailable').checked
        };

        var imageFile = document.getElementById('productImage').files[0];

        if (imageFile) {
            if (imageFile.size > 5 * 1024 * 1024) {
                showToast('warning', 'Image must be under 5MB.');
                return;
            }
            var fd = new FormData();
            Object.keys(payload).forEach(function(k) { fd.append(k, payload[k]); });
            fd.append('image', imageFile);
            submitWithImage(fd);
        } else {
            submitJson(payload);
        }
    }

    function submitJson(payload) {
        setSubmitLoading(true);
        var url = editingId ? API_URL + '/' + editingId : API_URL;
        var method = editingId ? 'PUT' : 'POST';

        fetch(url, {
            method: method,
            headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
            body: JSON.stringify(payload)
        })
        .then(function(r) { return r.json().then(function(body) { return { status: r.status, body: body }; }); })
        .then(function(res) {
            setSubmitLoading(false);
            if (res.status >= 200 && res.status < 300) {
                showToast('success', editingId ? 'Product updated successfully.' : 'Product created successfully.');
                productModal.hide();
                loadProducts();
            } else {
                showToast('error', res.body.message || 'Failed to save product.');
            }
        })
        .catch(function() {
            setSubmitLoading(false);
            showToast('error', 'Network error. Please try again.');
        });
    }

    function submitWithImage(fd) {
        setSubmitLoading(true);
        var url = editingId ? API_URL + '/' + editingId : API_URL;
        var method = editingId ? 'PUT' : 'POST';

        fetch(url, {
            method: method,
            body: fd
        })
        .then(function(r) { return r.json().then(function(body) { return { status: r.status, body: body }; }); })
        .then(function(res) {
            setSubmitLoading(false);
            if (res.status >= 200 && res.status < 300) {
                showToast('success', editingId ? 'Product updated successfully.' : 'Product created successfully.');
                productModal.hide();
                loadProducts();
            } else {
                showToast('error', res.body.message || 'Failed to save product.');
            }
        })
        .catch(function() {
            setSubmitLoading(false);
            showToast('error', 'Network error. Please try again.');
        });
    }

    function confirmDelete() {
        if (!deleteTargetId) return;
        document.getElementById('deleteBtnText').textContent = '';
        document.getElementById('deleteBtnSpinner').classList.remove('d-none');

        fetch(API_URL + '/' + deleteTargetId, {
            method: 'DELETE',
            headers: { 'Accept': 'application/json' }
        })
        .then(function(r) {
            document.getElementById('deleteBtnText').textContent = 'Delete';
            document.getElementById('deleteBtnSpinner').classList.add('d-none');
            if (r.status >= 200 && r.status < 300) {
                showToast('success', 'Product deleted successfully.');
                deleteModal.hide();
                loadProducts();
            } else {
                return r.json().then(function(body) {
                    showToast('error', body.message || 'Failed to delete product.');
                });
            }
        })
        .catch(function() {
            document.getElementById('deleteBtnText').textContent = 'Delete';
            document.getElementById('deleteBtnSpinner').classList.add('d-none');
            showToast('error', 'Network error. Please try again.');
        });
    }

    function resetForm() {
        document.getElementById('productForm').reset();
        document.getElementById('productId').value = '';
        document.getElementById('productAvailable').checked = true;
        document.getElementById('imagePreviewImg').style.display = 'none';
        document.getElementById('imagePreviewIcon').style.display = 'block';
        editingId = null;
    }

    function setSubmitLoading(loading) {
        var btn = document.getElementById('productSubmitBtn');
        var text = document.getElementById('productSubmitText');
        var spinner = document.getElementById('productSubmitSpinner');
        btn.disabled = loading;
        text.textContent = editingId ? (loading ? 'Updating...' : 'Update Product') : (loading ? 'Saving...' : 'Save Product');
        spinner.classList.toggle('d-none', !loading);
    }

    function showEmptyState() {
        document.getElementById('skeletonLoader').style.display = 'none';
        document.getElementById('tableContent').style.display = 'none';
        document.getElementById('emptyState').style.display = 'block';
    }

    function previewImage() {
        var file = this.files[0];
        if (!file) return;
        var reader = new FileReader();
        reader.onload = function(e) {
            var img = document.getElementById('imagePreviewImg');
            var icon = document.getElementById('imagePreviewIcon');
            img.src = e.target.result;
            img.style.display = 'block';
            icon.style.display = 'none';
        };
        reader.readAsDataURL(file);
    }

    function escapeHtml(str) {
        if (!str) return '';
        var div = document.createElement('div');
        div.appendChild(document.createTextNode(str));
        return div.innerHTML;
    }

    document.addEventListener('DOMContentLoaded', init);

    return {
        openAddModal: openAddModal,
        openEditModal: openEditModal,
        openDeleteModal: openDeleteModal,
        confirmDelete: confirmDelete,
        save: save,
        goToPage: goToPage
    };
})();
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
