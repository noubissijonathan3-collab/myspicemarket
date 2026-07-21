<?php
$currentPage = 'categories';
$pageTitle   = 'Categories';
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
            <input type="text" class="form-control" id="globalSearch" placeholder="Search categories..." autocomplete="off">
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
                            <div class="stat-label">Total Categories</div>
                            <div class="stat-value text-success" id="statTotal">—</div>
                        </div>
                        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="bi bi-tags"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#0d6efd,#0b5ed7);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Active</div>
                            <div class="stat-value" style="color:#0d6efd;" id="statActive">—</div>
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
                            <div class="stat-label">Meal Categories</div>
                            <div class="stat-value" style="color:#e0a800;" id="statMeal">—</div>
                        </div>
                        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-cup-hot"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#6f42c1,#5a32a3);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Grocery Categories</div>
                            <div class="stat-value" style="color:#6f42c1;" id="statGrocery">—</div>
                        </div>
                        <div class="stat-icon" style="background:rgba(111,66,193,0.1);color:#6f42c1;"><i class="bi bi-basket"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Categories Table Card -->
        <div class="msm-card p-0 animate-in">
            <div class="table-toolbar">
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <h6 class="mb-0 fw-bold">All Categories</h6>
                    <span class="badge bg-secondary" id="totalCount">0</span>
                </div>
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <div class="input-group input-group-sm" style="width:220px;">
                        <span class="input-group-text bg-transparent"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control" id="searchInput" placeholder="Search categories...">
                    </div>
                    <select class="form-select form-select-sm" id="typeFilter" style="width:140px;">
                        <option value="">All Types</option>
                        <option value="meal">Meal</option>
                        <option value="grocery">Grocery</option>
                        <option value="both">Both</option>
                    </select>
                    <select class="form-select form-select-sm" id="statusFilter" style="width:140px;">
                        <option value="">All Status</option>
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                    </select>
                    <button class="btn btn-sm btn-msm" onclick="Categories.openAddModal()">
                        <i class="bi bi-plus-lg me-1"></i> Add Category
                    </button>
                </div>
            </div>

            <!-- Skeleton Loader -->
            <div id="skeletonLoader">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light"><tr><th>Image</th><th>Name</th><th>Type</th><th>Sort Order</th><th>Status</th><th>Products</th><th>Actions</th></tr></thead>
                    <tbody>
                        <?php for ($i = 0; $i < 6; $i++): ?>
                        <tr>
                            <td><div class="skeleton" style="width:44px;height:44px;border-radius:8px;"></div></td>
                            <td><div class="skeleton" style="width:120px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:60px;height:22px;border-radius:6px;"></div></td>
                            <td><div class="skeleton" style="width:30px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:60px;height:22px;border-radius:6px;"></div></td>
                            <td><div class="skeleton" style="width:20px;height:14px;"></div></td>
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
                            <th>Description</th>
                            <th>Type</th>
                            <th>Sort Order</th>
                            <th>Status</th>
                            <th>Products</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="categoriesTableBody"></tbody>
                </table>
            </div>

            <!-- Empty State -->
            <div id="emptyState" style="display:none;">
                <div class="empty-state py-5">
                    <i class="bi bi-tags"></i>
                    <p>No categories found.</p>
                    <button class="btn btn-sm btn-msm mt-2" onclick="Categories.openAddModal()">
                        <i class="bi bi-plus-lg me-1"></i> Add First Category
                    </button>
                </div>
            </div>

            <!-- Pagination -->
            <div class="d-flex align-items-center justify-content-between p-3 border-top" id="paginationWrap" style="display:none;">
                <div class="small text-muted" id="paginationInfo">Showing 0 categories</div>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="paginationLinks"></ul>
                </nav>
            </div>
        </div>
    </div>
</div>

<!-- Add/Edit Category Modal -->
<div class="modal fade" id="categoryModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title fw-bold" id="categoryModalTitle">Add Category</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="categoryForm" enctype="multipart/form-data">
                    <input type="hidden" id="categoryId" value="">
                    <div class="row g-3">
                        <div class="col-md-8">
                            <label class="form-label fw-semibold">Category Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="catName" required placeholder="e.g. Traditional Soups">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Type <span class="text-danger">*</span></label>
                            <select class="form-select" id="catType" required>
                                <option value="meal">Meal</option>
                                <option value="grocery">Grocery</option>
                                <option value="both">Both</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Description</label>
                            <textarea class="form-control" id="catDescription" rows="3" placeholder="Optional description..."></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Sort Order</label>
                            <input type="number" class="form-control" id="catSortOrder" min="0" value="0" placeholder="0">
                            <div class="form-text">Lower numbers appear first.</div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Status</label>
                            <div class="form-check form-switch mt-2">
                                <input class="form-check-input" type="checkbox" id="catActive" checked>
                                <label class="form-check-label" for="catActive">Active</label>
                            </div>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Category Image</label>
                            <div class="d-flex align-items-start gap-3">
                                <div id="catImagePreviewContainer" style="width:100px;height:100px;border:2px dashed var(--msm-border);border-radius:10px;display:flex;align-items:center;justify-content:center;overflow:hidden;flex-shrink:0;background:#f8f9fa;">
                                    <i class="bi bi-image text-muted" id="catImagePreviewIcon" style="font-size:1.5rem;"></i>
                                    <img id="catImagePreviewImg" src="" alt="" style="display:none;width:100%;height:100%;object-fit:cover;">
                                </div>
                                <div>
                                    <input type="file" class="form-control" id="catImageFile" accept="image/*" style="font-size:0.85rem;">
                                    <div class="form-text">JPEG, PNG, WebP or GIF. Max 5MB.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer border-top-0 pt-0">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-msm" id="catSubmitBtn" onclick="Categories.save()">
                    <span id="catSubmitText">Save Category</span>
                    <span id="catSubmitSpinner" class="spinner-border spinner-border-sm d-none" role="status"></span>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteCatModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-body text-center p-4">
                <div style="width:56px;height:56px;border-radius:50%;background:#fef2f2;display:flex;align-items:center;justify-content:center;margin:0 auto 1rem;">
                    <i class="bi bi-trash text-danger" style="font-size:1.5rem;"></i>
                </div>
                <h6 class="fw-bold mb-2">Delete Category?</h6>
                <p class="text-muted small mb-0">This will remove the category permanently. Meals using it will become uncategorized.</p>
            </div>
            <div class="modal-footer border-top-0 justify-content-center pt-0 pb-3">
                <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger btn-sm" id="confirmDeleteCatBtn" onclick="Categories.confirmDelete()">
                    <span id="deleteCatBtnText">Delete</span>
                    <span id="deleteCatBtnSpinner" class="spinner-border spinner-border-sm d-none" role="status"></span>
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var MSM_JWT = '<?php echo htmlspecialchars($jwt, ENT_QUOTES, 'UTF-8'); ?>';
var Categories = (function() {
    var API_BASE = '<?php echo API_ADMIN_CATEGORIES; ?>';
    var allCategories = [];
    var filteredCategories = [];
    var currentPage = 1;
    var perPage = <?php echo PER_PAGE; ?>;
    var totalPages = 1;
    var deleteTargetId = null;
    var editingId = null;
    var catModal = null;
    var deleteModal = null;

    function init() {
        catModal = new bootstrap.Modal(document.getElementById('categoryModal'));
        deleteModal = new bootstrap.Modal(document.getElementById('deleteCatModal'));

        document.getElementById('searchInput').addEventListener('input', debounce(applyFilters, 300));
        document.getElementById('typeFilter').addEventListener('change', applyFilters);
        document.getElementById('statusFilter').addEventListener('change', applyFilters);
        document.getElementById('catImageFile').addEventListener('change', previewImage);

        document.getElementById('categoryModal').addEventListener('hidden.bs.modal', function() {
            resetForm();
        });

        loadCategories();
    }

    function debounce(fn, ms) {
        var timer;
        return function() {
            clearTimeout(timer);
            timer = setTimeout(fn, ms);
        };
    }

    function loadCategories() {
        fetch(API_BASE, {
            headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + MSM_JWT }
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            allCategories = Array.isArray(data) ? data : (data.categories || data.body || []);
            updateStats();
            applyFilters();
        })
        .catch(function() {
            showToast('error', 'Failed to load categories.');
            showEmptyState();
        });
    }

    function updateStats() {
        var total = allCategories.length;
        var active = allCategories.filter(function(c) { return c.isActive !== false; }).length;
        var mealCats = allCategories.filter(function(c) { return c.type === 'meal' || c.type === 'both'; }).length;
        var groceryCats = allCategories.filter(function(c) { return c.type === 'grocery' || c.type === 'both'; }).length;

        document.getElementById('statTotal').textContent = total;
        document.getElementById('statActive').textContent = active;
        document.getElementById('statMeal').textContent = mealCats;
        document.getElementById('statGrocery').textContent = groceryCats;
        document.getElementById('totalCount').textContent = total;
    }

    function applyFilters() {
        var query = document.getElementById('searchInput').value.toLowerCase().trim();
        var typeFilter = document.getElementById('typeFilter').value;
        var statusFilter = document.getElementById('statusFilter').value;

        filteredCategories = allCategories.filter(function(c) {
            var name = (c.name || '').toLowerCase();
            var desc = (c.description || '').toLowerCase();
            var matchSearch = !query || name.indexOf(query) !== -1 || desc.indexOf(query) !== -1;
            var matchType = !typeFilter || c.type === typeFilter;
            var matchStatus = !statusFilter || (statusFilter === 'active' ? c.isActive !== false : c.isActive === false);
            return matchSearch && matchType && matchStatus;
        });

        filteredCategories.sort(function(a, b) {
            return (a.sortOrder || 0) - (b.sortOrder || 0);
        });

        totalPages = Math.max(1, Math.ceil(filteredCategories.length / perPage));
        if (currentPage > totalPages) currentPage = 1;
        renderTable();
        renderPagination();
    }

    function renderTable() {
        var tbody = document.getElementById('categoriesTableBody');
        var start = (currentPage - 1) * perPage;
        var pageItems = filteredCategories.slice(start, start + perPage);

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
        pageItems.forEach(function(c) {
            var id = c._id || c.id || '';
            var name = escapeHtml(c.name || 'Untitled');
            var desc = escapeHtml(MSM.truncate(c.description || '', 60));
            var type = c.type || 'meal';
            var sortOrder = c.sortOrder || 0;
            var isActive = c.isActive !== false;
            var productCount = c.productCount || 0;
            var img = c.image || '';
            var imgHtml = img
                ? '<img src="' + msmImgUrl(img) + '" alt="" style="width:44px;height:44px;border-radius:8px;object-fit:cover;">'
                : '<div style="width:44px;height:44px;border-radius:8px;background:var(--msm-bg);display:flex;align-items:center;justify-content:center;color:var(--msm-muted);"><i class="bi bi-tag"></i></div>';

            var typeBadgeMap = {
                meal: 'bg-primary',
                grocery: 'bg-purple',
                both: 'bg-info text-dark'
            };
            var typeBadge = '<span class="badge ' + (typeBadgeMap[type] || 'bg-secondary') + ' badge-status">' + escapeHtml(type.charAt(0).toUpperCase() + type.slice(1)) + '</span>';

            var statusBadge = isActive
                ? '<span class="badge bg-success badge-status">Active</span>'
                : '<span class="badge bg-secondary badge-status">Inactive</span>';

            html += '<tr class="animate-in">' +
                '<td>' + imgHtml + '</td>' +
                '<td><span class="fw-semibold">' + name + '</span></td>' +
                '<td><span class="text-muted small">' + (desc || '—') + '</span></td>' +
                '<td>' + typeBadge + '</td>' +
                '<td class="text-center">' + sortOrder + '</td>' +
                '<td>' + statusBadge + '</td>' +
                '<td class="text-center"><span class="badge bg-light text-dark">' + productCount + '</span></td>' +
                '<td class="text-end">' +
                    '<button class="btn btn-sm btn-outline-primary me-1" onclick="Categories.openEditModal(\'' + id + '\')" title="Edit"><i class="bi bi-pencil"></i></button>' +
                    '<button class="btn btn-sm btn-outline-danger" onclick="Categories.openDeleteModal(\'' + id + '\')" title="Delete"><i class="bi bi-trash"></i></button>' +
                '</td>' +
            '</tr>';
        });
        tbody.innerHTML = html;

        var showing = Math.min(start + perPage, filteredCategories.length);
        document.getElementById('paginationInfo').textContent = 'Showing ' + (filteredCategories.length > 0 ? start + 1 : 0) + '-' + showing + ' of ' + filteredCategories.length + ' categories';
    }

    function renderPagination() {
        var links = document.getElementById('paginationLinks');
        if (totalPages <= 1) { links.innerHTML = ''; return; }

        var html = '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') + '">' +
            '<a class="page-link" href="#" onclick="Categories.goToPage(' + (currentPage - 1) + ');return false;"><i class="bi bi-chevron-left"></i></a></li>';

        var startPage = Math.max(1, currentPage - 2);
        var endPage = Math.min(totalPages, currentPage + 2);

        if (startPage > 1) {
            html += '<li class="page-item"><a class="page-link" href="#" onclick="Categories.goToPage(1);return false;">1</a></li>';
            if (startPage > 2) html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
        }

        for (var i = startPage; i <= endPage; i++) {
            html += '<li class="page-item ' + (i === currentPage ? 'active' : '') + '">' +
                '<a class="page-link" href="#" onclick="Categories.goToPage(' + i + ');return false;">' + i + '</a></li>';
        }

        if (endPage < totalPages) {
            if (endPage < totalPages - 1) html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
            html += '<li class="page-item"><a class="page-link" href="#" onclick="Categories.goToPage(' + totalPages + ');return false;">' + totalPages + '</a></li>';
        }

        html += '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '">' +
            '<a class="page-link" href="#" onclick="Categories.goToPage(' + (currentPage + 1) + ');return false;"><i class="bi bi-chevron-right"></i></a></li>';

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
        document.getElementById('categoryModalTitle').textContent = 'Add Category';
        document.getElementById('catSubmitText').textContent = 'Save Category';
        catModal.show();
    }

    function openEditModal(id) {
        var c = allCategories.find(function(item) { return (item._id || item.id) === id; });
        if (!c) return;

        editingId = id;
        document.getElementById('categoryModalTitle').textContent = 'Edit Category';
        document.getElementById('catSubmitText').textContent = 'Update Category';
        document.getElementById('categoryId').value = id;
        document.getElementById('catName').value = c.name || '';
        document.getElementById('catType').value = c.type || 'meal';
        document.getElementById('catDescription').value = c.description || '';
        document.getElementById('catSortOrder').value = c.sortOrder || 0;
        document.getElementById('catActive').checked = c.isActive !== false;

        var previewImg = document.getElementById('catImagePreviewImg');
        var previewIcon = document.getElementById('catImagePreviewIcon');
        if (c.image) {
            previewImg.src = msmImgUrl(c.image);
            previewImg.style.display = 'block';
            previewIcon.style.display = 'none';
        } else {
            previewImg.style.display = 'none';
            previewIcon.style.display = 'upload';
        }

        catModal.show();
    }

    function openDeleteModal(id) {
        deleteTargetId = id;
        deleteModal.show();
    }

    function save() {
        var name = document.getElementById('catName').value.trim();
        var type = document.getElementById('catType').value;

        if (!name) {
            showToast('warning', 'Please enter a category name.');
            return;
        }

        var payload = {
            name: name,
            type: type,
            description: document.getElementById('catDescription').value.trim(),
            sortOrder: parseInt(document.getElementById('catSortOrder').value) || 0,
            isActive: document.getElementById('catActive').checked
        };

        var imageFile = document.getElementById('catImageFile').files[0];

        if (imageFile) {
            if (imageFile.size > 5 * 1024 * 1024) {
                showToast('warning', 'Image must be under 5MB.');
                return;
            }
            var fd = new FormData();
            Object.keys(payload).forEach(function(k) {
                fd.append(k, typeof payload[k] === 'boolean' ? (payload[k] ? 'true' : 'false') : payload[k]);
            });
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
            headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer ' + MSM_JWT },
            body: JSON.stringify(payload)
        })
        .then(function(r) { return r.json().then(function(body) { return { status: r.status, body: body }; }); })
        .then(function(res) {
            setSubmitLoading(false);
            if (res.status >= 200 && res.status < 300) {
                showToast('success', editingId ? 'Category updated successfully.' : 'Category created successfully.');
                catModal.hide();
                loadCategories();
            } else {
                showToast('error', res.body.message || 'Failed to save category.');
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
            headers: { 'Authorization': 'Bearer ' + MSM_JWT },
            body: fd
        })
        .then(function(r) { return r.json().then(function(body) { return { status: r.status, body: body }; }); })
        .then(function(res) {
            setSubmitLoading(false);
            if (res.status >= 200 && res.status < 300) {
                showToast('success', editingId ? 'Category updated successfully.' : 'Category created successfully.');
                catModal.hide();
                loadCategories();
            } else {
                showToast('error', res.body.message || 'Failed to save category.');
            }
        })
        .catch(function() {
            setSubmitLoading(false);
            showToast('error', 'Network error. Please try again.');
        });
    }

    function confirmDelete() {
        if (!deleteTargetId) return;
        document.getElementById('deleteCatBtnText').textContent = '';
        document.getElementById('deleteCatBtnSpinner').classList.remove('d-none');

        fetch(API_BASE + '/' + deleteTargetId, {
            method: 'DELETE',
            headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + MSM_JWT }
        })
        .then(function(r) {
            document.getElementById('deleteCatBtnText').textContent = 'Delete';
            document.getElementById('deleteCatBtnSpinner').classList.add('d-none');
            if (r.status >= 200 && r.status < 300) {
                showToast('success', 'Category deleted successfully.');
                deleteModal.hide();
                loadCategories();
            } else {
                return r.json().then(function(body) {
                    showToast('error', body.message || 'Failed to delete category.');
                });
            }
        })
        .catch(function() {
            document.getElementById('deleteCatBtnText').textContent = 'Delete';
            document.getElementById('deleteCatBtnSpinner').classList.add('d-none');
            showToast('error', 'Network error. Please try again.');
        });
    }

    function resetForm() {
        document.getElementById('categoryForm').reset();
        document.getElementById('categoryId').value = '';
        document.getElementById('catActive').checked = true;
        document.getElementById('catSortOrder').value = 0;
        document.getElementById('catImagePreviewImg').style.display = 'none';
        document.getElementById('catImagePreviewIcon').style.display = 'block';
        editingId = null;
    }

    function setSubmitLoading(loading) {
        var btn = document.getElementById('catSubmitBtn');
        var text = document.getElementById('catSubmitText');
        var spinner = document.getElementById('catSubmitSpinner');
        btn.disabled = loading;
        text.textContent = editingId ? (loading ? 'Updating...' : 'Update Category') : (loading ? 'Saving...' : 'Save Category');
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
            var img = document.getElementById('catImagePreviewImg');
            var icon = document.getElementById('catImagePreviewIcon');
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
