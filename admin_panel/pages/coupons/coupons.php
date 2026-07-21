<?php
$currentPage = 'coupons';
$pageTitle   = 'Coupons';

require_once __DIR__ . '/../../auth/auth_check.php';

include __DIR__ . '/../../includes/header.php';
include __DIR__ . '/../../includes/sidebar.php';
include __DIR__ . '/../../includes/loader.php';
?>
<div class="sidebar-overlay" id="sidebarOverlay" onclick="MSM.toggleSidebar()"></div>

<div class="admin-content">
    <div class="admin-navbar">
        <div class="navbar-left">
            <button class="btn btn-sm d-lg-none" onclick="MSM.toggleSidebar()" style="font-size:1.2rem;color:var(--msm-muted);"><i class="bi bi-list"></i></button>
            <div class="navbar-brand-text"><span>Coupons</span></div>
        </div>
        <div class="navbar-search d-none d-md-block">
            <i class="bi bi-search search-icon"></i>
            <input type="text" class="form-control" id="globalSearch" placeholder="Search meals, customers, orders..." autocomplete="off">
            <span class="search-kbd">Ctrl+K</span>
            <div class="search-results-dropdown" id="searchResults"></div>
        </div>
        <div class="navbar-right">
            <div style="position:relative;">
                <button class="navbar-icon-btn" onclick="MSM.toggleDropdown('notifDropdown')"><i class="bi bi-bell"></i></button>
                <div class="notification-dropdown" id="notifDropdown">
                    <div class="notif-header"><h6>Notifications</h6><a href="<?php echo admin_url('pages/notifications/notifications.php'); ?>" class="text-decoration-none small">View All</a></div>
                    <div class="notif-list"><div class="notif-item"><div class="notif-content"><div class="notif-title">All caught up!</div><div class="notif-msg">No new notifications.</div></div></div></div>
                </div>
            </div>
            <div style="position:relative;">
                <img src="<?php echo htmlspecialchars($adminAvatar); ?>" alt="Admin" class="profile-avatar" onerror="this.src='https://ui-avatars.com/api/?name=<?php echo urlencode($adminName); ?>&background=198754&color=fff&size=36'" onclick="MSM.toggleDropdown('profileDropdown')">
                <div class="profile-dropdown" id="profileDropdown">
                    <div style="padding:0.75rem 1rem;border-bottom:1px solid var(--msm-border);"><div style="font-weight:600;font-size:0.85rem;"><?php echo htmlspecialchars($adminName); ?></div><div style="font-size:0.75rem;color:var(--msm-muted);"><?php echo htmlspecialchars($adminEmail); ?></div></div>
                    <a href="<?php echo admin_url('pages/profile/profile.php'); ?>"><i class="bi bi-person"></i> Profile</a>
                    <a href="<?php echo admin_url('pages/settings/settings.php'); ?>"><i class="bi bi-gear"></i> Settings</a>
                    <div class="dropdown-divider"></div>
                    <a href="<?php echo admin_url('auth/logout.php'); ?>" class="logout-link"><i class="bi bi-box-arrow-right"></i> Logout</a>
                </div>
            </div>
        </div>
    </div>

    <div class="welcome-section animate-in d-flex align-items-center justify-content-between">
        <div>
            <h3><i class="bi bi-ticket-perforated text-warning me-2"></i>Coupons Management</h3>
            <p>Promotions displayed as visual coupon cards. Manage discount codes from here.</p>
            <a href="<?php echo admin_url('pages/promotions/promotions.php'); ?>" class="btn btn-sm btn-msm-outline mt-1"><i class="bi bi-megaphone me-1"></i>Go to Promotions</a>
        </div>
        <button class="btn btn-sm btn-msm" onclick="openAddCouponModal()"><i class="bi bi-plus-lg me-1"></i>New Coupon</button>
    </div>

    <div class="mb-3">
        <div class="d-flex gap-2 flex-wrap align-items-center">
            <button class="btn btn-sm <?php echo strpos($_SERVER['REQUEST_URI'] ?? '', 'layout=table') !== false ? 'btn-msm' : 'btn-msm-outline'; ?>" onclick="setLayout('table')" id="layoutTableBtn"><i class="bi bi-list-ul me-1"></i>Table</button>
            <button class="btn btn-sm <?php echo strpos($_SERVER['REQUEST_URI'] ?? '', 'layout=table') === false ? 'btn-msm' : 'btn-msm-outline'; ?>" onclick="setLayout('cards')" id="layoutCardsBtn"><i class="bi bi-grid-3x3 me-1"></i>Cards</button>
            <input type="text" class="form-control form-control-sm" id="couponSearch" placeholder="Search coupons..." style="width:200px;" onkeyup="loadCoupons()">
        </div>
    </div>

    <div id="couponsView" class="animate-in">
        <div class="msm-card" id="couponsTableView">
            <div class="table-toolbar"><h6 class="mb-0 fw-bold">All Coupons</h6></div>
            <div class="table-responsive">
                <table class="table msm-table align-middle mb-0">
                    <thead class="table-light">
                        <tr>
                            <th>Code</th>
                            <th>Description</th>
                            <th>Discount</th>
                            <th>Type</th>
                            <th>Min Order</th>
                            <th>Valid</th>
                            <th>Active</th>
                            <th style="width:120px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="couponsTableBody">
                        <tr><td colspan="8"><div class="empty-state py-5"><div class="spinner-border text-success mb-3" role="status"></div><p>Loading coupons...</p></div></td></tr>
                    </tbody>
                </table>
            </div>
        </div>
        <div id="couponsCardsView" style="display:none;">
            <div class="row g-3" id="couponsCardsContainer"></div>
        </div>
    </div>
</div>

<div class="modal fade" id="couponModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
            <form id="couponForm" onsubmit="return saveCoupon(event)">
                <div class="modal-header">
                    <h5 class="modal-title" id="couponModalTitle"><i class="bi bi-ticket me-2"></i>Add Coupon</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="couponId">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Code <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="couponCode" required placeholder="e.g. SAVE15">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Type <span class="text-danger">*</span></label>
                            <select class="form-select" id="couponType">
                                <option value="percentage">Percentage</option>
                                <option value="fixed">Fixed</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Description</label>
                            <textarea class="form-control" id="couponDescription" rows="2"></textarea>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Discount <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="number" class="form-control" id="couponDiscount" required min="0" step="any">
                                <span class="input-group-text" id="couponDiscountLabel">%</span>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Min Order</label>
                            <input type="number" class="form-control" id="couponMinOrder" min="0" step="any">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Active</label>
                            <div class="form-check form-switch mt-2">
                                <input class="form-check-input" type="checkbox" id="couponActive" checked>
                                <label class="form-check-label" for="couponActive">Enabled</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Valid From</label>
                            <input type="date" class="form-control" id="couponValidFrom">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Valid To</label>
                            <input type="date" class="form-control" id="couponValidTo">
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-msm" id="couponSaveBtn">Save Coupon</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="deleteCouponModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title text-danger"><i class="bi bi-exclamation-triangle me-2"></i>Delete Coupon</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center py-4">
                <div class="mb-3"><i class="bi bi-trash text-danger" style="font-size:3rem;opacity:.5;"></i></div>
                <p class="mb-1">Delete coupon <strong id="deleteCouponLabel">—</strong>?</p>
                <p class="small text-muted">This action cannot be undone.</p>
            </div>
            <div class="modal-footer border-0 justify-content-center">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger px-4" id="confirmDeleteCoupon">Delete</button>
            </div>
        </div>
    </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3" id="couponToastContainer" style="z-index:9999;"></div>

<script>
var MSM_JWT = '<?php echo session_get_jwt(); ?>';

function apiFetch(method, url, body, onSuccess, onError) {
    var xhr = new XMLHttpRequest();
    xhr.open(method, url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.setRequestHeader('Authorization', 'Bearer ' + MSM_JWT);
    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) return;
        try {
            var res = JSON.parse(xhr.responseText);
            if (xhr.status >= 200 && xhr.status < 300) { if (onSuccess) onSuccess(res); } else { if (onError) onError(res); }
        } catch(e) { if (onError) onError({message:'Invalid response.'}); }
    };
    xhr.onerror = function() { if (onError) onError({message:'Network error.'}); };
    xhr.send(body ? JSON.stringify(body) : null);
}

function showToast(msg, type) {
    type = type || 'success';
    var bg = type === 'danger' ? 'bg-danger' : type === 'warning' ? 'bg-warning text-dark' : 'bg-success';
    var icon = type === 'danger' ? 'bi-x-circle' : type === 'warning' ? 'bi-exclamation-circle' : 'bi-check-circle';
    var c = document.getElementById('couponToastContainer');
    var el = document.createElement('div');
    el.className = 'toast align-items-center text-white border-0 ' + bg;
    el.setAttribute('role', 'alert');
    el.innerHTML = '<div class="d-flex"><div class="toast-body"><i class="bi ' + icon + ' me-2"></i>' + msg + '</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>';
    c.appendChild(el);
    var t = new bootstrap.Toast(el, {autohide:true,delay:4000});
    t.show();
    el.addEventListener('hidden.bs.toast',function(){el.remove();});
}

function escapeHtml(s) {
    if (!s) return '';
    var d = document.createElement('div');
    d.appendChild(document.createTextNode(s));
    return d.innerHTML;
}

var allCoupons = [];

function loadCoupons() {
    var loading = '<tr><td colspan="8"><div class="text-center py-5"><div class="spinner-border text-success mb-3" role="status"></div><p>Loading...</p></div></td></tr>';
    document.getElementById('couponsTableBody').innerHTML = loading;

    apiFetch('GET', '<?php echo API_ADMIN_PROMOTIONS; ?>', null, function(data) {
        var list = data.data || data.promotions || (Array.isArray(data) ? data : []);
        allCoupons = list;
        renderCoupons();
    }, function() {
        document.getElementById('couponsTableBody').innerHTML = '<tr><td colspan="8"><div class="empty-state py-5"><i class="bi bi-exclamation-circle text-danger"></i><p>Failed to load coupons.</p></div></td></tr>';
    });
}

function renderCoupons() {
    var q = (document.getElementById('couponSearch').value || '').toLowerCase();
    var filtered = q ? allCoupons.filter(function(c) { return (c.code||'').toLowerCase().indexOf(q) !== -1 || (c.description||'').toLowerCase().indexOf(q) !== -1; }) : allCoupons;

    renderTable(filtered);
    renderCards(filtered);
}

function renderTable(list) {
    var tbody = document.getElementById('couponsTableBody');
    if (!list || list.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state py-5"><i class="bi bi-ticket"></i><p>No coupons found.</p></div></td></tr>';
        return;
    }
    var now = new Date();
    var h = '';
    list.forEach(function(p) {
        var isExpired = p.validTo && new Date(p.validTo) < now;
        var discount = p.type === 'fixed' ? MSM.formatCurrency(Number(p.discountPercent||0)) : (Number(p.discountPercent||0)+'%');
        var typeBadge = p.type === 'fixed' ? '<span class="badge badge-status bg-primary">Fixed</span>' : '<span class="badge badge-status bg-warning text-dark">%</span>';
        var vf = p.validFrom ? MSM.formatDate(p.validFrom) : '-';
        var vt = p.validTo ? MSM.formatDate(p.validTo) : '-';
        var activeLabel = p.isActive !== false && p.isActive !== 'false' ? '<span class="badge badge-status bg-success">Active</span>' : '<span class="badge badge-status bg-secondary">Inactive</span>';
        if (isExpired) activeLabel = '<span class="badge badge-status bg-danger">Expired</span>';

        h += '<tr>';
        h += '<td><div class="d-flex align-items-center gap-2"><strong>' + escapeHtml(p.code) + '</strong><button class="btn btn-sm btn-msm-outline py-0 px-1" onclick="copyCode(\''+escapeHtml(p.code)+'\')" title="Copy code"><i class="bi bi-clipboard" style="font-size:0.7rem;"></i></button></div></td>';
        h += '<td style="font-size:0.82rem;">' + escapeHtml(p.description||'-') + '</td><td style="font-weight:600;">' + discount + '</td>';
        h += '<td>' + typeBadge + '</td><td style="font-size:0.8rem;">' + (p.minOrderAmount ? MSM.formatCurrency(p.minOrderAmount) : 'None') + '</td>';
        h += '<td style="font-size:0.75rem;">' + vf + ' — ' + vt + '</td>';
        h += '<td>' + activeLabel + '</td>';
        h += '<td><div class="d-flex gap-1"><button class="btn btn-sm btn-outline-warning" onclick="openEditCoupon(\''+p._id+'\')"><i class="bi bi-pencil"></i></button><button class="btn btn-sm btn-outline-danger" onclick="confirmDeleteCoupon(\''+p._id+'\',\''+escapeHtml(p.code)+'\')"><i class="bi bi-trash"></i></button></div></td></tr>';
    });
    tbody.innerHTML = h;
}

function renderCards(list) {
    var container = document.getElementById('couponsCardsContainer');
    var cardsView = document.getElementById('couponsCardsView');
    if (!container) return;
    if (!list || list.length === 0) {
        container.innerHTML = '<div class="col-12"><div class="empty-state py-5"><i class="bi bi-ticket"></i><p>No coupons found.</p></div></div>';
        return;
    }
    var now = new Date();
    var h = '';
    list.forEach(function(p) {
        var isExpired = p.validTo && new Date(p.validTo) < now;
        var isActive = (!isExpired) && p.isActive !== false && p.isActive !== 'false';
        var discount = p.type === 'fixed' ? MSM.formatCurrency(Number(p.discountPercent||0)) : (Number(p.discountPercent||0)+'% OFF');
        var bgClass = isActive ? 'border-success' : 'border-secondary';
        var statusBadge = isExpired ? '<span class="badge bg-danger" style="font-size:0.65rem;">EXPIRED</span>' : (isActive ? '<span class="badge bg-success" style="font-size:0.65rem;">ACTIVE</span>' : '<span class="badge bg-secondary" style="font-size:0.65rem;">INACTIVE</span>');

        h += '<div class="col-md-6 col-xl-4">';
        h += '<div class="card border-0 shadow-sm h-100 animate-in" style="border-radius:16px;background:linear-gradient(135deg,#ffffff,#f8f9fa);border-left:4px solid var(--msm-primary) !important;">';
        h += '<div class="card-body p-3">';
        h += '<div class="d-flex justify-content-between align-items-start mb-2">';
        h += '<div><div class="d-flex align-items-center gap-2"><span style="font-family:monospace;font-size:1rem;font-weight:800;letter-spacing:1px;">' + escapeHtml(p.code) + '</span>' + statusBadge + '</div><div style="font-size:0.8rem;color:var(--msm-muted);">' + escapeHtml(p.description||'') + '</div></div>';
        h += '<div class="text-end"><div style="font-size:1.2rem;font-weight:800;color:var(--msm-primary);">' + discount + '</div></div></div>';
        h += '<div class="d-flex justify-content-between align-items-center mt-2">';
        h += '<div><span class="text-muted" style="font-size:0.7rem;">Min: ' + (p.minOrderAmount ? MSM.formatCurrency(p.minOrderAmount) : 'None') + '</span><br><span class="text-muted" style="font-size:0.7rem;">' + (p.validFrom ? MSM.formatDate(p.validFrom) : '') + ' → ' + (p.validTo ? MSM.formatDate(p.validTo) : '∞') + '</span></div>';
        h += '<div class="d-flex gap-1"><button class="btn btn-sm btn-outline-success py-1 px-2" onclick="copyCode(\''+escapeHtml(p.code)+'\')"><i class="bi bi-clipboard"></i></button>';
        h += '<button class="btn btn-sm btn-outline-warning py-1 px-2" onclick="openEditCoupon(\''+p._id+'\')"><i class="bi bi-pencil"></i></button>';
        h += '<button class="btn btn-sm btn-outline-danger py-1 px-2" onclick="confirmDeleteCoupon(\''+p._id+'\',\''+escapeHtml(p.code)+'\')"><i class="bi bi-trash"></i></button>';
        h += '</div></div></div></div></div>';
    });
    container.innerHTML = h;
}

function copyCode(code) {
    if (!navigator.clipboard) {
        var ta = document.createElement('textarea');
        ta.value = code;
        document.body.appendChild(ta);
        ta.select();
        document.execCommand('copy');
        ta.remove();
    } else {
        navigator.clipboard.writeText(code);
    }
    showToast('Code "' + code + '" copied to clipboard.');
}

function setLayout(type) {
    var tableView = document.getElementById('couponsTableView');
    var cardsView = document.getElementById('couponsCardsView');
    var tableBtn = document.getElementById('layoutTableBtn');
    var cardsBtn = document.getElementById('layoutCardsBtn');
    if (tableView && cardsView) {
        if (type === 'table') {
            tableView.style.display = '';
            cardsView.style.display = 'none';
            tableBtn.className = 'btn btn-sm btn-msm';
            cardsBtn.className = 'btn btn-sm btn-msm-outline';
        } else {
            tableView.style.display = 'none';
            cardsView.style.display = '';
            tableBtn.className = 'btn btn-sm btn-msm-outline';
            cardsBtn.className = 'btn btn-sm btn-msm';
        }
    }
}

function openAddCouponModal() {
    document.getElementById('couponForm').reset();
    document.getElementById('couponId').value = '';
    document.getElementById('couponModalTitle').textContent = 'Add Coupon';
    document.getElementById('couponSaveBtn').textContent = 'Save Coupon';
    document.getElementById('couponActive').checked = true;
    document.getElementById('couponDiscountLabel').textContent = '%';
    document.getElementById('couponType').onchange = function() { document.getElementById('couponDiscountLabel').textContent = this.value === 'fixed' ? 'FCFA' : '%'; };
    new bootstrap.Modal(document.getElementById('couponModal')).show();
}

var couponIdToDelete = null;

function openEditCoupon(id) {
    var p = allCoupons.find(function(x) { return x._id === id || x.id === id; });
    if (!p) { showToast('Coupon not found.', 'warning'); return; }
    document.getElementById('couponForm').reset();
    document.getElementById('couponId').value = id;
    document.getElementById('couponCode').value = p.code || '';
    document.getElementById('couponDescription').value = p.description || '';
    document.getElementById('couponDiscount').value = p.discountPercent || 0;
    document.getElementById('couponType').value = p.type || 'percentage';
    document.getElementById('couponMinOrder').value = p.minOrderAmount || 0;
    document.getElementById('couponActive').checked = p.isActive !== false && p.isActive !== 'false';
    document.getElementById('couponValidFrom').value = p.validFrom ? p.validFrom.substring(0,10) : '';
    document.getElementById('couponValidTo').value = p.validTo ? p.validTo.substring(0,10) : '';
    document.getElementById('couponModalTitle').textContent = 'Edit Coupon';
    document.getElementById('couponSaveBtn').textContent = 'Update Coupon';
    document.getElementById('couponDiscountLabel').textContent = p.type === 'fixed' ? 'FCFA' : '%';
    document.getElementById('couponType').onchange = function() { document.getElementById('couponDiscountLabel').textContent = this.value === 'fixed' ? 'FCFA' : '%'; };
    new bootstrap.Modal(document.getElementById('couponModal')).show();
}

function saveCoupon(e) {
    e.preventDefault();
    var id = document.getElementById('couponId').value;
    var isEdit = !!id;
    var data = {
        code: document.getElementById('couponCode').value.trim(),
        description: document.getElementById('couponDescription').value.trim(),
        discountPercent: parseFloat(document.getElementById('couponDiscount').value) || 0,
        type: document.getElementById('couponType').value,
        minOrderAmount: parseFloat(document.getElementById('couponMinOrder').value) || 0,
        isActive: document.getElementById('couponActive').checked
    };
    var vf = document.getElementById('couponValidFrom').value;
    if (vf) data.validFrom = vf;
    var vt = document.getElementById('couponValidTo').value;
    if (vt) data.validTo = vt;

    var btn = document.getElementById('couponSaveBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Saving...';

    var method = isEdit ? 'PUT' : 'POST';
    var url = isEdit ? '<?php echo API_ADMIN_PROMOTIONS; ?>/' + id : '<?php echo API_ADMIN_PROMOTIONS; ?>';

    apiFetch(method, url, data, function() {
        bootstrap.Modal.getInstance(document.getElementById('couponModal')).hide();
        showToast(isEdit ? 'Coupon updated.' : 'Coupon created.');
        loadCoupons();
        btn.disabled = false;
        btn.textContent = isEdit ? 'Update Coupon' : 'Save Coupon';
    }, function(err) {
        showToast(err && err.message ? err.message : 'Failed to save coupon.', 'danger');
        btn.disabled = false;
        btn.textContent = isEdit ? 'Update Coupon' : 'Save Coupon';
    });
    return false;
}

function confirmDeleteCoupon(id, code) {
    couponIdToDelete = id;
    document.getElementById('deleteCouponLabel').textContent = code;
    new bootstrap.Modal(document.getElementById('deleteCouponModal')).show();
}

document.getElementById('confirmDeleteCoupon').addEventListener('click', function() {
    if (!couponIdToDelete) return;
    var id = couponIdToDelete;
    var url = '<?php echo API_ADMIN_PROMOTIONS; ?>/' + id;
    var btn = document.getElementById('confirmDeleteCoupon');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Deleting...';
    apiFetch('DELETE', url, null, function() {
        bootstrap.Modal.getInstance(document.getElementById('deleteCouponModal')).hide();
        showToast('Coupon deleted.');
        loadCoupons();
        btn.disabled = false;
        btn.textContent = 'Delete';
        couponIdToDelete = null;
    }, function(err) {
        showToast(err && err.message ? err.message : 'Failed to delete.', 'danger');
        btn.disabled = false;
        btn.textContent = 'Delete';
    });
});

document.addEventListener('DOMContentLoaded', function() {
    loadCoupons();
    MSM.initSearch('<?php echo API_ADMIN_SEARCH; ?>');
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
