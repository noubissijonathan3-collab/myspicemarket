<?php
$currentPage = 'meals';
$pageTitle   = 'Meals';
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
            <input type="text" class="form-control" id="globalSearch" placeholder="Search meals..." autocomplete="off">
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
                            <div class="stat-label">Total Meals</div>
                            <div class="stat-value text-success" id="statTotal">—</div>
                        </div>
                        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="bi bi-cup-hot"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#0d6efd,#0b5ed7);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Categories</div>
                            <div class="stat-value" style="color:#0d6efd;" id="statCats">—</div>
                        </div>
                        <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-tags"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#ffc107,#e0a800);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Popular</div>
                            <div class="stat-value" style="color:#e0a800;" id="statPopular">—</div>
                        </div>
                        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-star-fill"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#dc3545,#b02a37);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Total Favorites</div>
                            <div class="stat-value" style="color:#dc3545;" id="statFavs">—</div>
                        </div>
                        <div class="stat-icon bg-danger bg-opacity-10 text-danger"><i class="bi bi-heart-fill"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Meals Table Card -->
        <div class="msm-card p-0 animate-in">
            <div class="table-toolbar">
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <h6 class="mb-0 fw-bold">All Meals</h6>
                    <span class="badge bg-secondary" id="totalCount">0</span>
                </div>
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <div class="input-group input-group-sm" style="width:220px;">
                        <span class="input-group-text bg-transparent"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control" id="searchInput" placeholder="Search meals...">
                    </div>
                    <select class="form-select form-select-sm" id="categoryFilter" style="width:160px;">
                        <option value="">All Categories</option>
                    </select>
                    <button class="btn btn-sm btn-msm" onclick="Meals.openAddModal()">
                        <i class="bi bi-plus-lg me-1"></i> Add Meal
                    </button>
                </div>
            </div>

            <!-- Skeleton Loader -->
            <div id="skeletonLoader">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light"><tr><th>Image</th><th>Name</th><th>Category</th><th>Prep Time</th><th>Difficulty</th><th>Servings</th><th>Status</th><th>Actions</th></tr></thead>
                    <tbody>
                        <?php for ($i = 0; $i < 8; $i++): ?>
                        <tr>
                            <td><div class="skeleton" style="width:44px;height:44px;border-radius:8px;"></div></td>
                            <td><div class="skeleton" style="width:120px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:80px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:60px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:60px;height:22px;border-radius:6px;"></div></td>
                            <td><div class="skeleton" style="width:30px;height:14px;"></div></td>
                            <td><div class="skeleton" style="width:50px;height:22px;border-radius:6px;"></div></td>
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
                            <th>Prep Time</th>
                            <th>Difficulty</th>
                            <th>Servings</th>
                            <th>Status</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="mealsTableBody"></tbody>
                </table>
            </div>

            <!-- Empty State -->
            <div id="emptyState" style="display:none;">
                <div class="empty-state py-5">
                    <i class="bi bi-cup-hot"></i>
                    <p>No meals found.</p>
                    <button class="btn btn-sm btn-msm mt-2" onclick="Meals.openAddModal()">
                        <i class="bi bi-plus-lg me-1"></i> Add First Meal
                    </button>
                </div>
            </div>

            <!-- Pagination -->
            <div class="d-flex align-items-center justify-content-between p-3 border-top" id="paginationWrap" style="display:none;">
                <div class="small text-muted" id="paginationInfo">Showing 0 meals</div>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="paginationLinks"></ul>
                </nav>
            </div>
        </div>
    </div>
</div>

<!-- Add/Edit Meal Modal -->
<div class="modal fade" id="mealModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-header border-bottom-0 pb-0">
                <h5 class="modal-title fw-bold" id="mealModalTitle">Add Meal</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form id="mealForm" enctype="multipart/form-data">
                    <input type="hidden" id="mealId" value="">
                    <div class="row g-3">
                        <div class="col-md-8">
                            <label class="form-label fw-semibold">Meal Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="mealName" required placeholder="e.g. Ndolé Special">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Category <span class="text-danger">*</span></label>
                            <select class="form-select" id="mealCategory" required>
                                <option value="">Select category</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Description</label>
                            <textarea class="form-control" id="mealDescription" rows="3" placeholder="Describe the meal..."></textarea>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Preparation Time (min)</label>
                            <input type="number" class="form-control" id="mealPrepTime" min="1" placeholder="30">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Difficulty</label>
                            <select class="form-select" id="mealDifficulty">
                                <option value="Easy">Easy</option>
                                <option value="Medium" selected>Medium</option>
                                <option value="Hard">Hard</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Servings</label>
                            <input type="number" class="form-control" id="mealServings" min="1" value="2" placeholder="2">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold">Popular</label>
                            <div class="form-check form-switch mt-2">
                                <input class="form-check-input" type="checkbox" id="mealPopular">
                                <label class="form-check-label" for="mealPopular">Mark as popular</label>
                            </div>
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-semibold">Meal Image</label>
                            <div class="d-flex align-items-start gap-3">
                                <div id="mealImagePreviewContainer" style="width:100px;height:100px;border:2px dashed var(--msm-border);border-radius:10px;display:flex;align-items:center;justify-content:center;overflow:hidden;flex-shrink:0;background:#f8f9fa;">
                                    <i class="bi bi-image text-muted" id="mealImagePreviewIcon" style="font-size:1.5rem;"></i>
                                    <img id="mealImagePreviewImg" src="" alt="" style="display:none;width:100%;height:100%;object-fit:cover;">
                                </div>
                                <div>
                                    <input type="file" class="form-control" id="mealImageFile" accept="image/*" style="font-size:0.85rem;">
                                    <div class="form-text">JPEG, PNG, WebP or GIF. Max 5MB.</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer border-top-0 pt-0">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-msm" id="mealSubmitBtn" onclick="Meals.save()">
                    <span id="mealSubmitText">Save Meal</span>
                    <span id="mealSubmitSpinner" class="spinner-border spinner-border-sm d-none" role="status"></span>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Manage Ingredients Modal -->
<div class="modal fade" id="ingredientsModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-header border-0 pb-0">
                <div>
                    <h5 class="modal-title fw-bold"><i class="bi bi-list-check text-success me-2"></i>Manage Ingredients</h5>
                    <small class="text-muted" id="ingMealName"></small>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <!-- Add Ingredient Form -->
                <div class="msm-card mb-3" style="border:1px dashed var(--msm-border);background:#f9fafb;">
                    <div class="card-body p-3">
                        <h6 class="fw-bold mb-3" style="font-size:0.85rem;"><i class="bi bi-plus-circle me-1 text-success"></i>Add Ingredient</h6>
                        <div class="row g-2 align-items-end">
                            <div class="col-md-4">
                                <label class="form-label" style="font-size:0.78rem;">Ingredient *</label>
                                <div class="d-flex align-items-center gap-2">
                                    <div id="ingImagePreview" style="width:36px;height:36px;border-radius:6px;background:var(--msm-bg);display:flex;align-items:center;justify-content:center;flex-shrink:0;overflow:hidden;">
                                        <i class="bi bi-image text-muted" id="ingImageIcon" style="font-size:0.9rem;"></i>
                                        <img id="ingImageImg" src="" alt="" style="display:none;width:100%;height:100%;object-fit:cover;">
                                    </div>
                                    <select class="form-select form-select-sm flex-grow-1" id="ingFoodstuff" required></select>
                                </div>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label" style="font-size:0.78rem;">Quantity *</label>
                                <input type="number" class="form-control form-control-sm" id="ingQuantity" min="0" step="any" required placeholder="0">
                            </div>
                            <div class="col-md-2">
                                <label class="form-label" style="font-size:0.78rem;">Unit</label>
                                <select class="form-select form-select-sm" id="ingUnit">
                                    <option value="g">g</option>
                                    <option value="kg">kg</option>
                                    <option value="ml">ml</option>
                                    <option value="L">L</option>
                                    <option value="piece">piece</option>
                                    <option value="pieces">pieces</option>
                                    <option value="cups">cups</option>
                                    <option value="tsp">tsp</option>
                                    <option value="tbsp">tbsp</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label" style="font-size:0.78rem;">Order</label>
                                <input type="number" class="form-control form-control-sm" id="ingOrder" min="0" value="0" placeholder="0">
                            </div>
                            <div class="col-md-2">
                                <label class="form-label" style="font-size:0.78rem;">Price (FCFA)</label>
                                <input type="number" class="form-control form-control-sm" id="ingPrice" min="0" step="any" placeholder="Optional">
                            </div>
                        </div>
                        <div class="row g-2 mt-1">
                            <div class="col-auto">
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" id="ingOptional">
                                    <label class="form-check-label" style="font-size:0.78rem;" for="ingOptional">Optional</label>
                                </div>
                            </div>
                            <div class="col-auto">
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" id="ingModifiable" checked>
                                    <label class="form-check-label" style="font-size:0.78rem;" for="ingModifiable">Customer can modify</label>
                                </div>
                            </div>
                            <div class="col-auto ms-auto">
                                <button class="btn btn-sm btn-success" id="addIngBtn" onclick="Meals.addIngredient()">
                                    <i class="bi bi-plus-lg me-1"></i>Add
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Ingredients List -->
                <div class="msm-card">
                    <div class="p-3 border-bottom d-flex align-items-center justify-content-between">
                        <h6 class="mb-0 fw-bold" style="font-size:0.85rem;"><i class="bi bi-list-ul me-1"></i>Assigned Ingredients (<span id="ingCount">0</span>)</h6>
                        <div class="d-flex gap-2">
                            <span class="badge bg-success" style="font-size:0.7rem;" id="ingStockBadge"></span>
                        </div>
                    </div>
                    <div id="ingredientsList" style="max-height:360px;overflow-y:auto;">
                        <div class="empty-state py-4">
                            <i class="bi bi-basket"></i>
                            <p>No ingredients assigned yet.</p>
                            <p class="small text-muted">Add ingredients using the form above.</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-top-0 pt-0">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteMealModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-body text-center p-4">
                <div style="width:56px;height:56px;border-radius:50%;background:#fef2f2;display:flex;align-items:center;justify-content:center;margin:0 auto 1rem;">
                    <i class="bi bi-trash text-danger" style="font-size:1.5rem;"></i>
                </div>
                <h6 class="fw-bold mb-2">Delete Meal?</h6>
                <p class="text-muted small mb-0">This action cannot be undone.</p>
            </div>
            <div class="modal-footer border-top-0 justify-content-center pt-0 pb-3">
                <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger btn-sm" id="confirmDeleteMealBtn" onclick="Meals.confirmDelete()">
                    <span id="deleteMealBtnText">Delete</span>
                    <span id="deleteMealBtnSpinner" class="spinner-border spinner-border-sm d-none" role="status"></span>
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var MSM_JWT = '<?php echo htmlspecialchars($jwt, ENT_QUOTES, 'UTF-8'); ?>';
var Meals = (function() {
    var API_BASE = '<?php echo API_ADMIN_PRODUCTS; ?>';
    var allMeals = [];
    var filteredMeals = [];
    var categories = [];
    var currentPage = 1;
    var perPage = <?php echo PER_PAGE; ?>;
    var totalPages = 1;
    var deleteTargetId = null;
    var editingId = null;
    var mealModal = null;
    var deleteModal = null;
    var ingredientsModal = null;
    var currentIngMealId = null;
    var allFoodstuffs = [];
    var currentIngredients = [];

    function init() {
        mealModal = new bootstrap.Modal(document.getElementById('mealModal'));
        deleteModal = new bootstrap.Modal(document.getElementById('deleteMealModal'));
        ingredientsModal = new bootstrap.Modal(document.getElementById('ingredientsModal'));

        document.getElementById('searchInput').addEventListener('input', debounce(applyFilters, 300));
        document.getElementById('categoryFilter').addEventListener('change', applyFilters);
        document.getElementById('mealImageFile').addEventListener('change', previewImage);

        document.getElementById('mealModal').addEventListener('hidden.bs.modal', function() {
            resetForm();
        });

        loadCategories(function() {
            loadMeals();
        });
        loadFoodstuffs();

        document.getElementById('ingFoodstuff').addEventListener('change', function() {
            var opt = this.options[this.selectedIndex];
            if (opt && opt.dataset.unit) document.getElementById('ingUnit').value = opt.dataset.unit;
            var imgEl = document.getElementById('ingImageImg');
            var iconEl = document.getElementById('ingImageIcon');
            if (opt && opt.dataset.image) {
                imgEl.src = msmImgUrl(opt.dataset.image);
                imgEl.style.display = 'block';
                iconEl.style.display = 'none';
            } else {
                imgEl.style.display = 'none';
                iconEl.style.display = 'block';
            }
        });
    }

    function debounce(fn, ms) {
        var timer;
        return function() {
            clearTimeout(timer);
            timer = setTimeout(fn, ms);
        };
    }

    function loadCategories(callback) {
        fetch('<?php echo API_ADMIN_CATEGORIES; ?>', {
            headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + MSM_JWT }
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            categories = Array.isArray(data) ? data : (data.body || data.categories || []);
            populateCategorySelects();
            if (callback) callback();
        })
        .catch(function() {
            if (callback) callback();
        });
    }

    function populateCategorySelects() {
        var filterSel = document.getElementById('categoryFilter');
        var filterVal = filterSel.value;
        filterSel.innerHTML = '<option value="">All Categories</option>';

        var formSel = document.getElementById('mealCategory');
        var formVal = formSel.value;
        formSel.innerHTML = '<option value="">Select category</option>';

        categories.forEach(function(c) {
            var name = c.name || '';
            var type = c.type || '';
            if (type === 'meal' || type === 'both') {
                var opt1 = document.createElement('option');
                opt1.value = c._id || c.id || name;
                opt1.textContent = name;
                filterSel.appendChild(opt1);

                var opt2 = document.createElement('option');
                opt2.value = c._id || c.id || name;
                opt2.textContent = name;
                formSel.appendChild(opt2);
            }
        });

        filterSel.value = filterVal;
        formSel.value = formVal;
    }

    function loadMeals() {
        fetch(API_BASE, {
            headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + MSM_JWT }
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            allMeals = Array.isArray(data) ? data : (data.meals || data.products || data.body || []);
            updateStats();
            applyFilters();
        })
        .catch(function() {
            showToast('error', 'Failed to load meals.');
            showEmptyState();
        });
    }

    function updateStats() {
        var total = allMeals.length;
        var catSet = {};
        var popular = 0;
        var favs = 0;

        allMeals.forEach(function(m) {
            var catName = '';
            if (m.categoryId && typeof m.categoryId === 'object') {
                catName = m.categoryId.name || '';
            } else if (m.categoryId) {
                catName = m.categoryId;
            }
            if (catName) catSet[catName] = true;
            if (m.isPopular) popular++;
            favs += (m.favoritesCount || 0);
        });

        document.getElementById('statTotal').textContent = total.toLocaleString();
        document.getElementById('statCats').textContent = Object.keys(catSet).length;
        document.getElementById('statPopular').textContent = popular;
        document.getElementById('statFavs').textContent = favs.toLocaleString();
        document.getElementById('totalCount').textContent = total;
    }

    function applyFilters() {
        var query = document.getElementById('searchInput').value.toLowerCase().trim();
        var catFilter = document.getElementById('categoryFilter').value;

        filteredMeals = allMeals.filter(function(m) {
            var name = (m.name || '').toLowerCase();
            var desc = (m.description || '').toLowerCase();
            var catName = getCatName(m);
            var matchSearch = !query || name.indexOf(query) !== -1 || desc.indexOf(query) !== -1 || catName.toLowerCase().indexOf(query) !== -1;
            var matchCat = !catFilter || (m.categoryId && (m.categoryId === catName || (typeof m.categoryId === 'object' && (m.categoryId._id === catFilter || m.categoryId.id === catFilter))));
            if (!matchCat && catFilter) {
                matchCat = m.categoryId === catFilter || catName === catFilter;
            }
            return matchSearch && matchCat;
        });

        totalPages = Math.max(1, Math.ceil(filteredMeals.length / perPage));
        if (currentPage > totalPages) currentPage = 1;
        renderTable();
        renderPagination();
    }

    function getCatName(m) {
        if (m.categoryId && typeof m.categoryId === 'object') return m.categoryId.name || '';
        return m.categoryId || '';
    }

    function getCatId(m) {
        if (m.categoryId && typeof m.categoryId === 'object') return m.categoryId._id || m.categoryId.id || '';
        return m.categoryId || '';
    }

    function renderTable() {
        var tbody = document.getElementById('mealsTableBody');
        var start = (currentPage - 1) * perPage;
        var pageItems = filteredMeals.slice(start, start + perPage);

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
        pageItems.forEach(function(m) {
            var id = m._id || m.id || '';
            var name = escapeHtml(m.name || 'Untitled');
            var catName = escapeHtml(getCatName(m) || '—');
            var prepTime = m.preparationTime || '—';
            var difficulty = m.difficulty || 'Medium';
            var servings = m.servings || '—';
            var isPopular = m.isPopular;
            var img = m.image || '';
            var imgHtml = img
                ? '<img src="' + msmImgUrl(img) + '" alt="" style="width:44px;height:44px;border-radius:8px;object-fit:cover;">'
                : '<div style="width:44px;height:44px;border-radius:8px;background:var(--msm-bg);display:flex;align-items:center;justify-content:center;color:var(--msm-muted);"><i class="bi bi-cup-hot"></i></div>';

            var diffColors = { Easy: 'bg-success', Medium: 'bg-warning text-dark', Hard: 'bg-danger' };
            var diffBadge = '<span class="badge ' + (diffColors[difficulty] || 'bg-secondary') + ' badge-status">' + escapeHtml(difficulty) + '</span>';

            var popBadge = isPopular
                ? '<span class="badge bg-warning text-dark badge-status"><i class="bi bi-star-fill me-1"></i>Popular</span>'
                : '<span class="text-muted small">—</span>';

            html += '<tr class="animate-in">' +
                '<td>' + imgHtml + '</td>' +
                '<td><span class="fw-semibold">' + name + '</span></td>' +
                '<td><span class="text-muted">' + catName + '</span></td>' +
                '<td><span class="text-muted">' + prepTime + ' min</span></td>' +
                '<td>' + diffBadge + '</td>' +
                '<td class="text-center">' + servings + '</td>' +
                '<td>' + popBadge + '</td>' +
                '<td class="text-end">' +
                    '<button class="btn btn-sm btn-outline-success me-1" onclick="Meals.openIngredients(\'' + id + '\', \'' + name + '\')" title="Manage Ingredients"><i class="bi bi-list-check"></i></button>' +
                    '<button class="btn btn-sm btn-outline-primary me-1" onclick="Meals.openEditModal(\'' + id + '\')" title="Edit"><i class="bi bi-pencil"></i></button>' +
                    '<button class="btn btn-sm btn-outline-danger" onclick="Meals.openDeleteModal(\'' + id + '\')" title="Delete"><i class="bi bi-trash"></i></button>' +
                '</td>' +
            '</tr>';
        });
        tbody.innerHTML = html;

        var showing = Math.min(start + perPage, filteredMeals.length);
        document.getElementById('paginationInfo').textContent = 'Showing ' + (filteredMeals.length > 0 ? start + 1 : 0) + '-' + showing + ' of ' + filteredMeals.length + ' meals';
    }

    function renderPagination() {
        var links = document.getElementById('paginationLinks');
        if (totalPages <= 1) { links.innerHTML = ''; return; }

        var html = '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') + '">' +
            '<a class="page-link" href="#" onclick="Meals.goToPage(' + (currentPage - 1) + ');return false;"><i class="bi bi-chevron-left"></i></a></li>';

        var startPage = Math.max(1, currentPage - 2);
        var endPage = Math.min(totalPages, currentPage + 2);

        if (startPage > 1) {
            html += '<li class="page-item"><a class="page-link" href="#" onclick="Meals.goToPage(1);return false;">1</a></li>';
            if (startPage > 2) html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
        }

        for (var i = startPage; i <= endPage; i++) {
            html += '<li class="page-item ' + (i === currentPage ? 'active' : '') + '">' +
                '<a class="page-link" href="#" onclick="Meals.goToPage(' + i + ');return false;">' + i + '</a></li>';
        }

        if (endPage < totalPages) {
            if (endPage < totalPages - 1) html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
            html += '<li class="page-item"><a class="page-link" href="#" onclick="Meals.goToPage(' + totalPages + ');return false;">' + totalPages + '</a></li>';
        }

        html += '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '">' +
            '<a class="page-link" href="#" onclick="Meals.goToPage(' + (currentPage + 1) + ');return false;"><i class="bi bi-chevron-right"></i></a></li>';

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
        document.getElementById('mealModalTitle').textContent = 'Add Meal';
        document.getElementById('mealSubmitText').textContent = 'Save Meal';
        mealModal.show();
    }

    function openEditModal(id) {
        var m = allMeals.find(function(item) { return (item._id || item.id) === id; });
        if (!m) return;

        editingId = id;
        document.getElementById('mealModalTitle').textContent = 'Edit Meal';
        document.getElementById('mealSubmitText').textContent = 'Update Meal';
        document.getElementById('mealId').value = id;
        document.getElementById('mealName').value = m.name || '';
        document.getElementById('mealDescription').value = m.description || '';
        document.getElementById('mealPrepTime').value = m.preparationTime || '';
        document.getElementById('mealDifficulty').value = m.difficulty || 'Medium';
        document.getElementById('mealServings').value = m.servings || 2;
        document.getElementById('mealPopular').checked = !!m.isPopular;

        var catId = getCatId(m);
        if (catId) {
            var formSel = document.getElementById('mealCategory');
            var hasOption = false;
            for (var i = 0; i < formSel.options.length; i++) {
                if (formSel.options[i].value === catId) { hasOption = true; break; }
            }
            if (!hasOption) {
                var opt = document.createElement('option');
                opt.value = catId;
                opt.textContent = getCatName(m);
                formSel.appendChild(opt);
            }
            formSel.value = catId;
        }

        var previewImg = document.getElementById('mealImagePreviewImg');
        var previewIcon = document.getElementById('mealImagePreviewIcon');
        if (m.image) {
            previewImg.src = msmImgUrl(m.image);
            previewImg.style.display = 'block';
            previewIcon.style.display = 'none';
        } else {
            previewImg.style.display = 'none';
            previewIcon.style.display = 'block';
        }

        mealModal.show();
    }

    function openDeleteModal(id) {
        deleteTargetId = id;
        deleteModal.show();
    }

    function save() {
        var name = document.getElementById('mealName').value.trim();
        var categoryId = document.getElementById('mealCategory').value;

        if (!name) {
            showToast('warning', 'Please enter a meal name.');
            return;
        }

        var payload = {
            name: name,
            description: document.getElementById('mealDescription').value.trim(),
            categoryId: categoryId,
            preparationTime: parseInt(document.getElementById('mealPrepTime').value) || 30,
            difficulty: document.getElementById('mealDifficulty').value,
            servings: parseInt(document.getElementById('mealServings').value) || 2,
            isPopular: document.getElementById('mealPopular').checked
        };

        var imageFile = document.getElementById('mealImageFile').files[0];

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
                showToast('success', editingId ? 'Meal updated successfully.' : 'Meal created successfully.');
                mealModal.hide();
                loadMeals();
            } else {
                showToast('error', res.body.message || 'Failed to save meal.');
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
                showToast('success', editingId ? 'Meal updated successfully.' : 'Meal created successfully.');
                mealModal.hide();
                loadMeals();
            } else {
                showToast('error', res.body.message || 'Failed to save meal.');
            }
        })
        .catch(function() {
            setSubmitLoading(false);
            showToast('error', 'Network error. Please try again.');
        });
    }

    function confirmDelete() {
        if (!deleteTargetId) return;
        document.getElementById('deleteMealBtnText').textContent = '';
        document.getElementById('deleteMealBtnSpinner').classList.remove('d-none');

        fetch(API_BASE + '/' + deleteTargetId, {
            method: 'DELETE',
            headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + MSM_JWT }
        })
        .then(function(r) {
            document.getElementById('deleteMealBtnText').textContent = 'Delete';
            document.getElementById('deleteMealBtnSpinner').classList.add('d-none');
            if (r.status >= 200 && r.status < 300) {
                showToast('success', 'Meal deleted successfully.');
                deleteModal.hide();
                loadMeals();
            } else {
                return r.json().then(function(body) {
                    showToast('error', body.message || 'Failed to delete meal.');
                });
            }
        })
        .catch(function() {
            document.getElementById('deleteMealBtnText').textContent = 'Delete';
            document.getElementById('deleteMealBtnSpinner').classList.add('d-none');
            showToast('error', 'Network error. Please try again.');
        });
    }

    function resetForm() {
        document.getElementById('mealForm').reset();
        document.getElementById('mealId').value = '';
        document.getElementById('mealImagePreviewImg').style.display = 'none';
        document.getElementById('mealImagePreviewIcon').style.display = 'block';
        editingId = null;
    }

    function setSubmitLoading(loading) {
        var btn = document.getElementById('mealSubmitBtn');
        var text = document.getElementById('mealSubmitText');
        var spinner = document.getElementById('mealSubmitSpinner');
        btn.disabled = loading;
        text.textContent = editingId ? (loading ? 'Updating...' : 'Update Meal') : (loading ? 'Saving...' : 'Save Meal');
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
            var img = document.getElementById('mealImagePreviewImg');
            var icon = document.getElementById('mealImagePreviewIcon');
            img.src = e.target.result;
            img.style.display = 'block';
            icon.style.display = 'none';
        };
        reader.readAsDataURL(file);
    }

    function loadFoodstuffs() {
        fetch('<?php echo API_FOODSTUFFS; ?>?limit=500', {
            headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + MSM_JWT }
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            allFoodstuffs = Array.isArray(data) ? data : (data.products || data.foodstuffs || data.items || data.body || []);
            var sel = document.getElementById('ingFoodstuff');
            sel.innerHTML = '<option value="">Select ingredient...</option>';
            allFoodstuffs.forEach(function(f) {
                if (f.isAvailable !== false) {
                    sel.innerHTML += '<option value="' + f._id + '" data-unit="' + (f.unit || 'piece') + '" data-price="' + (f.price || 0) + '" data-image="' + escapeHtml(f.image || '') + '">' + escapeHtml(f.name) + '</option>';
                }
            });
        })
        .catch(function() {});
    }

    function openIngredients(mealId, mealName) {
        currentIngMealId = mealId;
        document.getElementById('ingMealName').textContent = mealName;
        currentIngredients = [];
        renderIngredientsList();
        loadMealIngredients(mealId);
        ingredientsModal.show();
    }

    function loadMealIngredients(mealId) {
        var url = '<?php echo API_ADMIN_MEAL_INGREDIENTS; ?>/' + mealId + '/ingredients';
        fetch(url, {
            headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + MSM_JWT }
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            currentIngredients = Array.isArray(data) ? data : [];
            renderIngredientsList();
        })
        .catch(function() {
            currentIngredients = [];
            renderIngredientsList();
        });
    }

    function renderIngredientsList() {
        var container = document.getElementById('ingredientsList');
        document.getElementById('ingCount').textContent = currentIngredients.length;

        var totalOptional = currentIngredients.filter(function(i) { return i.isOptional; }).length;
        var totalRequired = currentIngredients.length - totalOptional;
        document.getElementById('ingStockBadge').textContent = totalRequired + ' required · ' + totalOptional + ' optional';

        if (currentIngredients.length === 0) {
            container.innerHTML = '<div class="empty-state py-4"><i class="bi bi-basket"></i><p>No ingredients assigned yet.</p><p class="small text-muted">Add ingredients using the form above.</p></div>';
            return;
        }

        var sorted = currentIngredients.slice().sort(function(a, b) { return (a.displayOrder || 0) - (b.displayOrder || 0); });
        var h = '';
        sorted.forEach(function(ing) {
            var fs = ing.foodstuffId || {};
            var name = escapeHtml(fs.name || 'Unknown');
            var unit = escapeHtml(ing.unit || 'g');
            var qty = ing.quantity || 0;
            var price = ing.defaultPrice != null ? ing.defaultPrice : (fs.price || 0);
            var order = ing.displayOrder || 0;
            var optional = ing.isOptional;
            var modifiable = ing.isModifiable !== false;
            var stock = fs.stock || 0;
            var lowStock = stock < qty;

            var badges = '';
            if (optional) badges += '<span class="badge bg-info text-dark" style="font-size:0.6rem;">Optional</span> ';
            else badges += '<span class="badge bg-success" style="font-size:0.6rem;">Required</span> ';
            if (!modifiable) badges += '<span class="badge bg-secondary" style="font-size:0.6rem;">Locked</span> ';

            h += '<div class="d-flex align-items-center gap-2 p-3 border-bottom" style="font-size:0.82rem;">';
            h += '<div class="d-flex align-items-center gap-1" style="min-width:28px;color:var(--msm-muted);font-size:0.7rem;">#' + order + '</div>';
            h += '<div style="flex:1;">';
            h += '<div class="d-flex align-items-center gap-2">';
            h += '<span class="fw-semibold">' + name + '</span>';
            h += badges;
            if (lowStock) h += '<span class="badge bg-danger" style="font-size:0.6rem;">Low Stock</span>';
            h += '</div>';
            h += '<div class="text-muted" style="font-size:0.75rem;">';
            h += '<strong>' + qty + ' ' + unit + '</strong>';
            if (price > 0) h += ' · ' + price.toLocaleString() + ' FCFA';
            h += '</div>';
            h += '</div>';
            h += '<div class="d-flex gap-1">';
            h += '<button class="btn btn-sm btn-outline-primary" onclick="Meals.editIngredient(\'' + ing._id + '\')" title="Edit"><i class="bi bi-pencil" style="font-size:0.7rem;"></i></button>';
            h += '<button class="btn btn-sm btn-outline-danger" onclick="Meals.removeIngredient(\'' + ing._id + '\')" title="Remove"><i class="bi bi-trash" style="font-size:0.7rem;"></i></button>';
            h += '</div>';
            h += '</div>';
        });
        container.innerHTML = h;
    }

    function addIngredient() {
        var foodstuffId = document.getElementById('ingFoodstuff').value;
        var quantity = parseFloat(document.getElementById('ingQuantity').value);
        var unit = document.getElementById('ingUnit').value;
        var displayOrder = parseInt(document.getElementById('ingOrder').value) || 0;
        var defaultPrice = document.getElementById('ingPrice').value;
        var isOptional = document.getElementById('ingOptional').checked;
        var isModifiable = document.getElementById('ingModifiable').checked;

        if (!foodstuffId) { showToast('error', 'Please select an ingredient.'); return; }
        if (!quantity || quantity <= 0) { showToast('error', 'Please enter a valid quantity.'); return; }

        var btn = document.getElementById('addIngBtn');
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

        var payload = {
            foodstuffId: foodstuffId,
            quantity: quantity,
            unit: unit,
            displayOrder: displayOrder,
            isOptional: isOptional,
            isModifiable: isModifiable
        };
        if (defaultPrice !== '' && defaultPrice != null) payload.defaultPrice = parseFloat(defaultPrice);

        var url = '<?php echo API_ADMIN_MEAL_INGREDIENTS; ?>/' + currentIngMealId + '/ingredients';
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer ' + MSM_JWT },
            body: JSON.stringify(payload)
        })
        .then(function(r) { return r.json().then(function(body) { return { status: r.status, body: body }; }); })
        .then(function(res) {
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-plus-lg me-1"></i>Add';
            if (res.status >= 200 && res.status < 300) {
                showToast('success', 'Ingredient added.');
                document.getElementById('ingQuantity').value = '';
                document.getElementById('ingPrice').value = '';
                document.getElementById('ingOrder').value = '0';
                document.getElementById('ingOptional').checked = false;
                document.getElementById('ingModifiable').checked = true;
                loadMealIngredients(currentIngMealId);
            } else {
                showToast('error', res.body.message || 'Failed to add ingredient.');
            }
        })
        .catch(function() {
            btn.disabled = false;
            btn.innerHTML = '<i class="bi bi-plus-lg me-1"></i>Add';
            showToast('error', 'Network error.');
        });
    }

    function editIngredient(id) {
        var ing = currentIngredients.find(function(i) { return i._id === id; });
        if (!ing) return;
        var fs = ing.foodstuffId || {};

        var newQty = prompt('Quantity (' + (ing.unit || 'g') + '):', ing.quantity);
        if (newQty === null) return;
        newQty = parseFloat(newQty);
        if (isNaN(newQty) || newQty <= 0) { showToast('error', 'Invalid quantity.'); return; }

        var newOrder = prompt('Display order:', ing.displayOrder || 0);
        if (newOrder === null) return;
        newOrder = parseInt(newOrder) || 0;

        var newPrice = prompt('Default price (FCFA, leave blank to keep ' + (fs.price || 0) + '):', ing.defaultPrice != null ? ing.defaultPrice : '');
        if (newPrice === null) return;
        var payload = { quantity: newQty, displayOrder: newOrder };
        if (newPrice !== '' && newPrice != null) payload.defaultPrice = parseFloat(newPrice);

        var url = '<?php echo API_ADMIN_MEAL_INGREDIENTS; ?>/' + currentIngMealId + '/ingredients/' + id;
        fetch(url, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer ' + MSM_JWT },
            body: JSON.stringify(payload)
        })
        .then(function(r) { return r.json().then(function(body) { return { status: r.status, body: body }; }); })
        .then(function(res) {
            if (res.status >= 200 && res.status < 300) {
                showToast('success', 'Ingredient updated.');
                loadMealIngredients(currentIngMealId);
            } else {
                showToast('error', res.body.message || 'Failed to update.');
            }
        })
        .catch(function() { showToast('error', 'Network error.'); });
    }

    function removeIngredient(id) {
        if (!confirm('Remove this ingredient from the meal?')) return;
        var url = '<?php echo API_ADMIN_MEAL_INGREDIENTS; ?>/' + currentIngMealId + '/ingredients/' + id;
        fetch(url, {
            method: 'DELETE',
            headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + MSM_JWT }
        })
        .then(function(r) {
            if (r.status >= 200 && r.status < 300) {
                showToast('success', 'Ingredient removed.');
                loadMealIngredients(currentIngMealId);
            } else {
                return r.json().then(function(body) { showToast('error', body.message || 'Failed.'); });
            }
        })
        .catch(function() { showToast('error', 'Network error.'); });
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
        openIngredients: openIngredients,
        confirmDelete: confirmDelete,
        addIngredient: addIngredient,
        editIngredient: editIngredient,
        removeIngredient: removeIngredient,
        save: save,
        goToPage: goToPage
    };
})();
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
