<?php
$currentPage = 'ingredients';
$pageTitle   = 'Ingredients';
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
            <input type="text" class="form-control" id="globalSearch" placeholder="Search ingredients..." autocomplete="off">
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
                            <div class="stat-label">Total Ingredients</div>
                            <div class="stat-value text-success" id="statTotal">—</div>
                        </div>
                        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="bi bi-basket"></i></div>
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

        <!-- Stock Overview Cards -->
        <div class="row g-3 mb-4">
            <div class="col-12 animate-in">
                <div class="msm-card p-3">
                    <h6 class="fw-bold mb-3"><i class="bi bi-graph-up text-primary me-2"></i>Stock Levels Overview</h6>
                    <div id="stockOverviewContent">
                        <div class="d-flex gap-3 mb-2">
                            <div class="skeleton" style="width:100%;height:24px;border-radius:6px;"></div>
                        </div>
                        <div class="d-flex gap-3 mb-2">
                            <div class="skeleton" style="width:100%;height:24px;border-radius:6px;"></div>
                        </div>
                        <div class="d-flex gap-3 mb-2">
                            <div class="skeleton" style="width:100%;height:24px;border-radius:6px;"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Ingredients Table Card -->
        <div class="msm-card p-0 animate-in">
            <div class="table-toolbar">
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <h6 class="mb-0 fw-bold">Ingredients Inventory</h6>
                    <span class="badge bg-secondary" id="totalCount">0</span>
                </div>
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <div class="input-group input-group-sm" style="width:220px;">
                        <span class="input-group-text bg-transparent"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control" id="searchInput" placeholder="Search ingredients...">
                    </div>
                    <select class="form-select form-select-sm" id="categoryFilter" style="width:160px;">
                        <option value="">All Categories</option>
                    </select>
                    <select class="form-select form-select-sm" id="stockFilter" style="width:140px;">
                        <option value="">All Stock</option>
                        <option value="out">Out of Stock</option>
                        <option value="low">Low Stock</option>
                        <option value="in">In Stock</option>
                    </select>
                    <select class="form-select form-select-sm" id="sortFilter" style="width:140px;">
                        <option value="name">Name A-Z</option>
                        <option value="name_desc">Name Z-A</option>
                        <option value="stock_low">Stock: Low to High</option>
                        <option value="stock_high">Stock: High to Low</option>
                        <option value="price_low">Price: Low to High</option>
                        <option value="price_high">Price: High to Low</option>
                    </select>
                    <button class="btn btn-sm btn-msm" onclick="Ingredients.openAddModal()">
                        <i class="bi bi-plus-lg me-1"></i> Add Ingredient
                    </button>
                </div>
            </div>

            <!-- Skeleton Loader -->
            <div id="skeletonLoader">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light"><tr><th>Image</th><th>Name</th><th>Category</th><th>Unit</th><th>Price</th><th>Stock</th><th>Level</th><th>Actions</th></tr></thead>
                    <tbody>
                        <?php for ($i = 0; $i < 8; $i++): ?>
                        <tr>
                            <td><div class="skeleton" style="width:44px;height:44px;border-radius:8px;"></div></td>
                            <td><div class="skeleton" style="width:120px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:80px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:40px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:70px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:40px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:100px;height:8px;border-radius:4px;"></div></td>
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
                            <th>Unit</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Level</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="ingredientsTableBody"></tbody>
                </table>
            </div>

            <!-- Empty State -->
            <div id="emptyState" style="display:none;">
                <div class="empty-state py-5">
                    <i class="bi bi-basket"></i>
                    <p>No ingredients found.</p>
                    <button class="btn btn-sm btn-msm mt-2" onclick="Ingredients.openAddModal()">
                        <i class="bi bi-plus-lg me-1"></i> Add First Ingredient
                    </button>
                </div>
            </div>

            <!-- Pagination -->
            <div class="d-flex align-items-center justify-content-between p-3 border-top" id="paginationWrap" style="display:none;">
                <div class="small text-muted" id="paginationInfo">Showing 0 ingredients</div>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="paginationLinks"></ul>
                </nav>
            </div>
        </div>
    </div>
</div>

<!-- Add/Edit Ingredient Modal -->
<div class="modal fade" id="ingredientModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title fw-bold" id="ingredientModalTitle">Add Ingredient</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="ingredientForm" enctype="multipart/form-data">
                    <input type="hidden" id="ingredientId" value="">
                    <div class="row g-3">
                        <div class="col-md-8">
                            <label class="form-label fw-semibold">Ingredient Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="ingName" required placeholder="e.g. Fresh Ginger" list="ingCategorySuggestions">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Category <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="ingCategory" required placeholder="e.g. Spices" list="ingCatSuggestions">
                            <datalist id="ingCatSuggestions"></datalist>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Price (FCFA) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="ingPrice" required min="0" placeholder="0">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Stock <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="ingStock" required min="0" placeholder="0">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Unit</label>
                            <select class="form-select" id="ingUnit">
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
                            <label class="form-label fw-semibold">Available</label>
                            <div class="form-check form-switch mt-2">
                                <input class="form-check-input" type="checkbox" id="ingAvailable" checked>
                                <label class="form-check-label" for="ingAvailable">In stock</label>
                            </div>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Description</label>
                            <textarea class="form-control" id="ingDescription" rows="3" placeholder="Optional description..."></textarea>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Ingredient Image</label>
                            <div class="d-flex align-items-start gap-3">
                                <div id="ingImagePreviewContainer" style="width:100px;height:100px;border:2px dashed var(--msm-border);border-radius:10px;display:flex;align-items:center;justify-content:center;overflow:hidden;flex-shrink:0;background:#f8f9fa;">
                                    <i class="bi bi-image text-muted" id="ingImagePreviewIcon" style="font-size:1.5rem;"></i>
                                    <img id="ingImagePreviewImg" src="" alt="" style="display:none;width:100%;height:100%;object-fit:cover;">
                                </div>
                                <div>
                                    <input type="file" class="form-control" id="ingImageFile" accept="image/*" style="font-size:0.85rem;">
                                    <div class="form-text">JPEG, PNG, WebP or GIF. Max 5MB.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer border-top-0 pt-0">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-msm" id="ingSubmitBtn" onclick="Ingredients.save()">
                    <span id="ingSubmitText">Save Ingredient</span>
                    <span id="ingSubmitSpinner" class="spinner-border spinner-border-sm d-none" role="status"></span>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteIngModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-body text-center p-4">
                <div style="width:56px;height:56px;border-radius:50%;background:#fef2f2;display:flex;align-items:center;justify-content:center;margin:0 auto 1rem;">
                    <i class="bi bi-trash text-danger" style="font-size:1.5rem;"></i>
                </div>
                <h6 class="fw-bold mb-2">Delete Ingredient?</h6>
                <p class="text-muted small mb-0">This action cannot be undone.</p>
            </div>
            <div class="modal-footer border-top-0 justify-content-center pt-0 pb-3">
                <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger btn-sm" id="confirmDeleteIngBtn" onclick="Ingredients.confirmDelete()">
                    <span id="deleteIngBtnText">Delete</span>
                    <span id="deleteIngBtnSpinner" class="spinner-border spinner-border-sm d-none" role="status"></span>
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var Ingredients = (function() {
    var API_BASE = '<?php echo API_FOODSTUFFS; ?>';
    var allIngredients = [];
    var filteredIngredients = [];
    var categories = [];
    var currentPage = 1;
    var perPage = <?php echo PER_PAGE; ?>;
    var totalPages = 1;
    var deleteTargetId = null;
    var editingId = null;
    var ingredientModal = null;
    var deleteModal = null;

    function init() {
        ingredientModal = new bootstrap.Modal(document.getElementById('ingredientModal'));
        deleteModal = new bootstrap.Modal(document.getElementById('deleteIngModal'));

        document.getElementById('searchInput').addEventListener('input', debounce(applyFilters, 300));
        document.getElementById('categoryFilter').addEventListener('change', applyFilters);
        document.getElementById('stockFilter').addEventListener('change', applyFilters);
        document.getElementById('sortFilter').addEventListener('change', applyFilters);
        document.getElementById('ingImageFile').addEventListener('change', previewImage);

        document.getElementById('ingredientModal').addEventListener('hidden.bs.modal', function() {
            resetForm();
        });

        loadIngredients();
    }

    function debounce(fn, ms) {
        var timer;
        return function() {
            clearTimeout(timer);
            timer = setTimeout(fn, ms);
        };
    }

    function loadIngredients() {
        fetch(API_BASE + '?limit=200', {
            headers: { 'Accept': 'application/json' }
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            allIngredients = data.products || [];
            extractCategories();
            updateStats();
            applyFilters();
            renderStockOverview();
        })
        .catch(function() {
            showToast('error', 'Failed to load ingredients.');
            showEmptyState();
        });
    }

    function extractCategories() {
        var cats = {};
        allIngredients.forEach(function(p) {
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

        var dl = document.getElementById('ingCatSuggestions');
        dl.innerHTML = '';
        categories.forEach(function(c) {
            var opt = document.createElement('option');
            opt.value = c;
            dl.appendChild(opt);
        });
    }

    function updateStats() {
        var total = allIngredients.length;
        var inStock = allIngredients.filter(function(p) { return (p.stock || 0) > 10; }).length;
        var lowStock = allIngredients.filter(function(p) { return (p.stock || 0) > 0 && (p.stock || 0) <= 10; }).length;
        var outOfStock = allIngredients.filter(function(p) { return (p.stock || 0) <= 0; }).length;

        document.getElementById('statTotal').textContent = total.toLocaleString();
        document.getElementById('statInStock').textContent = inStock.toLocaleString();
        document.getElementById('statLowStock').textContent = lowStock.toLocaleString();
        document.getElementById('statOutOfStock').textContent = outOfStock.toLocaleString();
        document.getElementById('totalCount').textContent = total;
    }

    function renderStockOverview() {
        var container = document.getElementById('stockOverviewContent');
        if (allIngredients.length === 0) {
            container.innerHTML = '<div class="text-muted small text-center py-2">No ingredients to display.</div>';
            return;
        }

        var maxStock = Math.max.apply(null, allIngredients.map(function(p) { return p.stock || 0; }));
        if (maxStock === 0) maxStock = 1;

        var topItems = allIngredients.slice().sort(function(a, b) { return (b.stock || 0) - (a.stock || 0); }).slice(0, 8);
        var html = '<div class="row g-2">';
        topItems.forEach(function(item) {
            var stock = item.stock || 0;
            var pct = Math.min(100, (stock / Math.max(maxStock, 1)) * 100);
            var barClass = stock <= 0 ? 'critical' : (stock <= 10 ? 'low' : 'good');
            var unit = item.unit || 'kg';
            html += '<div class="col-sm-6 col-md-4 col-lg-3">' +
                '<div class="d-flex align-items-center gap-2 mb-1">' +
                    '<span class="small fw-semibold text-truncate" style="max-width:100px;">' + escapeHtml(item.name || '') + '</span>' +
                    '<span class="badge bg-' + (barClass === 'critical' ? 'danger' : barClass === 'low' ? 'warning' : 'success') + '" style="font-size:0.6rem;">' + stock + ' ' + escapeHtml(unit) + '</span>' +
                '</div>' +
                '<div class="stock-progress">' +
                    '<div class="stock-bar ' + barClass + '" style="width:' + pct + '%;"></div>' +
                '</div>' +
            '</div>';
        });
        html += '</div>';
        container.innerHTML = html;
    }

    function applyFilters() {
        var query = document.getElementById('searchInput').value.toLowerCase().trim();
        var catFilter = document.getElementById('categoryFilter').value;
        var stockFilter = document.getElementById('stockFilter').value;
        var sortVal = document.getElementById('sortFilter').value;

        filteredIngredients = allIngredients.filter(function(p) {
            var matchSearch = !query || (p.name && p.name.toLowerCase().indexOf(query) !== -1) ||
                              (p.category && p.category.toLowerCase().indexOf(query) !== -1) ||
                              (p.description && p.description.toLowerCase().indexOf(query) !== -1);
            var matchCat = !catFilter || p.category === catFilter;

            var stock = p.stock || 0;
            var matchStock = true;
            if (stockFilter === 'out') matchStock = stock <= 0;
            else if (stockFilter === 'low') matchStock = stock > 0 && stock <= 10;
            else if (stockFilter === 'in') matchStock = stock > 10;

            return matchSearch && matchCat && matchStock;
        });

        filteredIngredients.sort(function(a, b) {
            switch (sortVal) {
                case 'name': return (a.name || '').localeCompare(b.name || '');
                case 'name_desc': return (b.name || '').localeCompare(a.name || '');
                case 'stock_low': return (a.stock || 0) - (b.stock || 0);
                case 'stock_high': return (b.stock || 0) - (a.stock || 0);
                case 'price_low': return (a.price || 0) - (b.price || 0);
                case 'price_high': return (b.price || 0) - (a.price || 0);
                default: return 0;
            }
        });

        totalPages = Math.max(1, Math.ceil(filteredIngredients.length / perPage));
        if (currentPage > totalPages) currentPage = 1;
        renderTable();
        renderPagination();
    }

    function renderTable() {
        var tbody = document.getElementById('ingredientsTableBody');
        var start = (currentPage - 1) * perPage;
        var pageItems = filteredIngredients.slice(start, start + perPage);

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
            var unit = escapeHtml(p.unit || 'kg');
            var price = (p.price || 0).toLocaleString();
            var stock = p.stock || 0;
            var img = p.image || '';
            var imgHtml = img
                ? '<img src="' + msmImgUrl(img) + '" alt="" style="width:44px;height:44px;border-radius:8px;object-fit:cover;">'
                : '<div style="width:44px;height:44px;border-radius:8px;background:var(--msm-bg);display:flex;align-items:center;justify-content:center;color:var(--msm-muted);"><i class="bi bi-basket"></i></div>';

            var stockBadge = '';
            if (stock <= 0) stockBadge = '<span class="badge bg-danger badge-status">Out of Stock</span>';
            else if (stock <= 10) stockBadge = '<span class="badge bg-warning text-dark badge-status">' + stock + '</span>';
            else stockBadge = '<span class="badge bg-success badge-status">' + stock + '</span>';

            var maxDisplay = 50;
            var pct = Math.min(100, (stock / maxDisplay) * 100);
            var barClass = stock <= 0 ? 'critical' : (stock <= 10 ? 'low' : 'good');

            var levelHtml = '<div class="d-flex align-items-center gap-2">' +
                '<div class="stock-progress flex-grow-1" style="min-width:80px;">' +
                    '<div class="stock-bar ' + barClass + '" style="width:' + pct + '%;"></div>' +
                '</div>' +
                '<span class="small text-muted">' + stock + '</span>' +
            '</div>';

            html += '<tr class="animate-in">' +
                '<td>' + imgHtml + '</td>' +
                '<td><span class="fw-semibold">' + name + '</span></td>' +
                '<td><span class="text-muted">' + cat + '</span></td>' +
                '<td><span class="text-muted small">' + unit + '</span></td>' +
                '<td class="fw-semibold">' + price + ' <small class="text-muted">FCFA</small></td>' +
                '<td>' + stockBadge + '</td>' +
                '<td style="min-width:130px;">' + levelHtml + '</td>' +
                '<td class="text-end">' +
                    '<button class="btn btn-sm btn-outline-primary me-1" onclick="Ingredients.openEditModal(\'' + id + '\')" title="Edit"><i class="bi bi-pencil"></i></button>' +
                    '<button class="btn btn-sm btn-outline-danger" onclick="Ingredients.openDeleteModal(\'' + id + '\')" title="Delete"><i class="bi bi-trash"></i></button>' +
                '</td>' +
            '</tr>';
        });
        tbody.innerHTML = html;

        var showing = Math.min(start + perPage, filteredIngredients.length);
        document.getElementById('paginationInfo').textContent = 'Showing ' + (filteredIngredients.length > 0 ? start + 1 : 0) + '-' + showing + ' of ' + filteredIngredients.length + ' ingredients';
    }

    function renderPagination() {
        var links = document.getElementById('paginationLinks');
        if (totalPages <= 1) { links.innerHTML = ''; return; }

        var html = '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') + '">' +
            '<a class="page-link" href="#" onclick="Ingredients.goToPage(' + (currentPage - 1) + ');return false;"><i class="bi bi-chevron-left"></i></a></li>';

        var startPage = Math.max(1, currentPage - 2);
        var endPage = Math.min(totalPages, currentPage + 2);

        if (startPage > 1) {
            html += '<li class="page-item"><a class="page-link" href="#" onclick="Ingredients.goToPage(1);return false;">1</a></li>';
            if (startPage > 2) html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
        }

        for (var i = startPage; i <= endPage; i++) {
            html += '<li class="page-item ' + (i === currentPage ? 'active' : '') + '">' +
                '<a class="page-link" href="#" onclick="Ingredients.goToPage(' + i + ');return false;">' + i + '</a></li>';
        }

        if (endPage < totalPages) {
            if (endPage < totalPages - 1) html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
            html += '<li class="page-item"><a class="page-link" href="#" onclick="Ingredients.goToPage(' + totalPages + ');return false;">' + totalPages + '</a></li>';
        }

        html += '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '">' +
            '<a class="page-link" href="#" onclick="Ingredients.goToPage(' + (currentPage + 1) + ');return false;"><i class="bi bi-chevron-right"></i></a></li>';

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
        document.getElementById('ingredientModalTitle').textContent = 'Add Ingredient';
        document.getElementById('ingSubmitText').textContent = 'Save Ingredient';
        ingredientModal.show();
    }

    function openEditModal(id) {
        var p = allIngredients.find(function(item) { return (item._id || item.id) === id; });
        if (!p) return;

        editingId = id;
        document.getElementById('ingredientModalTitle').textContent = 'Edit Ingredient';
        document.getElementById('ingSubmitText').textContent = 'Update Ingredient';
        document.getElementById('ingredientId').value = id;
        document.getElementById('ingName').value = p.name || '';
        document.getElementById('ingCategory').value = p.category || '';
        document.getElementById('ingPrice').value = p.price || '';
        document.getElementById('ingStock').value = p.stock || '';
        document.getElementById('ingUnit').value = p.unit || 'kg';
        document.getElementById('ingDescription').value = p.description || '';
        document.getElementById('ingAvailable').checked = p.isAvailable !== false;

        var previewImg = document.getElementById('ingImagePreviewImg');
        var previewIcon = document.getElementById('ingImagePreviewIcon');
        if (p.image) {
            previewImg.src = msmImgUrl(p.image);
            previewImg.style.display = 'block';
            previewIcon.style.display = 'none';
        } else {
            previewImg.style.display = 'none';
            previewIcon.style.display = 'block';
        }

        ingredientModal.show();
    }

    function openDeleteModal(id) {
        deleteTargetId = id;
        deleteModal.show();
    }

    function save() {
        var name = document.getElementById('ingName').value.trim();
        var category = document.getElementById('ingCategory').value.trim();
        var price = document.getElementById('ingPrice').value;
        var stock = document.getElementById('ingStock').value;

        if (!name || !category || price === '' || stock === '') {
            showToast('warning', 'Please fill in all required fields.');
            return;
        }

        var payload = {
            name: name,
            category: category,
            price: parseFloat(price),
            stock: parseInt(stock),
            unit: document.getElementById('ingUnit').value,
            description: document.getElementById('ingDescription').value.trim(),
            isAvailable: document.getElementById('ingAvailable').checked
        };

        var imageFile = document.getElementById('ingImageFile').files[0];

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
        var url = editingId ? API_BASE + '/' + editingId : API_BASE;
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
                showToast('success', editingId ? 'Ingredient updated successfully.' : 'Ingredient created successfully.');
                ingredientModal.hide();
                loadIngredients();
            } else {
                showToast('error', res.body.message || 'Failed to save ingredient.');
            }
        })
        .catch(function() {
            setSubmitLoading(false);
            showToast('error', 'Network error. Please try again.');
        });
    }

    function submitWithImage(fd) {
        setSubmitLoading(true);
        var url = editingId ? API_BASE + '/' + editingId : API_BASE;
        var method = editingId ? 'PUT' : 'POST';

        fetch(url, {
            method: method,
            body: fd
        })
        .then(function(r) { return r.json().then(function(body) { return { status: r.status, body: body }; }); })
        .then(function(res) {
            setSubmitLoading(false);
            if (res.status >= 200 && res.status < 300) {
                showToast('success', editingId ? 'Ingredient updated successfully.' : 'Ingredient created successfully.');
                ingredientModal.hide();
                loadIngredients();
            } else {
                showToast('error', res.body.message || 'Failed to save ingredient.');
            }
        })
        .catch(function() {
            setSubmitLoading(false);
            showToast('error', 'Network error. Please try again.');
        });
    }

    function confirmDelete() {
        if (!deleteTargetId) return;
        document.getElementById('deleteIngBtnText').textContent = '';
        document.getElementById('deleteIngBtnSpinner').classList.remove('d-none');

        fetch(API_BASE + '/' + deleteTargetId, {
            method: 'DELETE',
            headers: { 'Accept': 'application/json' }
        })
        .then(function(r) {
            document.getElementById('deleteIngBtnText').textContent = 'Delete';
            document.getElementById('deleteIngBtnSpinner').classList.add('d-none');
            if (r.status >= 200 && r.status < 300) {
                showToast('success', 'Ingredient deleted successfully.');
                deleteModal.hide();
                loadIngredients();
            } else {
                return r.json().then(function(body) {
                    showToast('error', body.message || 'Failed to delete ingredient.');
                });
            }
        })
        .catch(function() {
            document.getElementById('deleteIngBtnText').textContent = 'Delete';
            document.getElementById('deleteIngBtnSpinner').classList.add('d-none');
            showToast('error', 'Network error. Please try again.');
        });
    }

    function resetForm() {
        document.getElementById('ingredientForm').reset();
        document.getElementById('ingredientId').value = '';
        document.getElementById('ingAvailable').checked = true;
        document.getElementById('ingImagePreviewImg').style.display = 'none';
        document.getElementById('ingImagePreviewIcon').style.display = 'block';
        editingId = null;
    }

    function setSubmitLoading(loading) {
        var btn = document.getElementById('ingSubmitBtn');
        var text = document.getElementById('ingSubmitText');
        var spinner = document.getElementById('ingSubmitSpinner');
        btn.disabled = loading;
        text.textContent = editingId ? (loading ? 'Updating...' : 'Update Ingredient') : (loading ? 'Saving...' : 'Save Ingredient');
        spinner.classList.toggle('d-none', !loading);
    }

    function showEmptyState() {
        document.getElementById('skeletonLoader').style.display = 'none';
        document.getElementById('tableContent').style.display = 'none';
        document.getElementById('emptyState').style.display = 'block';
        document.getElementById('stockOverviewContent').innerHTML = '<div class="text-muted small text-center py-2">No ingredients to display.</div>';
    }

    function previewImage() {
        var file = this.files[0];
        if (!file) return;
        var reader = new FileReader();
        reader.onload = function(e) {
            var img = document.getElementById('ingImagePreviewImg');
            var icon = document.getElementById('ingImagePreviewIcon');
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
