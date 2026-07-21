<?php
$currentPage = 'promotions';
$pageTitle   = 'Promotions';

require_once __DIR__ . '/../../auth/auth_check.php';

include __DIR__ . '/../../includes/header.php';
include __DIR__ . '/../../includes/sidebar.php';
include __DIR__ . '/../../includes/loader.php';
?>
<div class="sidebar-overlay" id="sidebarOverlay" onclick="MSM.toggleSidebar()"></div>

<div class="admin-content">
    <div class="admin-navbar">
        <div class="navbar-left">
            <button class="btn btn-sm d-lg-none" onclick="MSM.toggleSidebar()" style="font-size:1.2rem;color:var(--msm-muted);">
                <i class="bi bi-list"></i>
            </button>
            <div class="navbar-brand-text"><span>Promotions</span></div>
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

    <div class="welcome-section animate-in">
        <h3><i class="bi bi-megaphone text-warning me-2"></i>Promotions Management</h3>
        <p>Create and manage discount promotions and coupon codes.</p>
    </div>

    <div class="row g-3 mb-4" id="promoStatsContainer">
        <div class="col-sm-6 col-xl-4 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#198754,#0d6e3f);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Active Promotions</div>
                        <div class="stat-value" style="color:#198754;" id="statActivePromos">0</div>
                    </div>
                    <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="bi bi-megaphone"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-4 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#0d6efd,#0b5ed7);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Total Promotions</div>
                        <div class="stat-value" style="color:#0d6efd;" id="statTotalPromos">0</div>
                    </div>
                    <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-ticket"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-4 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#dc3545,#b02a37);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Expired</div>
                        <div class="stat-value" style="color:#dc3545;" id="statExpiredPromos">0</div>
                    </div>
                    <div class="stat-icon bg-danger bg-opacity-10 text-danger"><i class="bi bi-clock-history"></i></div>
                </div>
            </div>
        </div>
    </div>

    <div class="msm-card">
        <div class="table-toolbar">
            <h6 class="mb-0 fw-bold">All Promotions</h6>
            <div class="d-flex align-items-center gap-2 flex-wrap">
                <input type="text" class="form-control form-control-sm" id="promoSearch" placeholder="Search code..." style="width:180px;" onkeyup="filterPromos()">
                <button class="btn btn-sm btn-msm" onclick="openAddPromoModal()"><i class="bi bi-plus-lg me-1"></i>Add Promotion</button>
            </div>
        </div>
        <div class="table-responsive">
            <table class="table msm-table align-middle mb-0" id="promotionsTable">
                <thead class="table-light">
                    <tr>
                        <th>Code</th>
                        <th>Description</th>
                        <th>Discount</th>
                        <th>Type</th>
                        <th>Min Order</th>
                        <th>Valid Period</th>
                        <th>Active</th>
                        <th style="width:130px;">Actions</th>
                    </tr>
                </thead>
                <tbody id="promotionsTableBody">
                    <tr>
                        <td colspan="8">
                            <div class="empty-state py-5">
                                <div class="spinner-border text-success mb-3" role="status"></div>
                                <p>Loading promotions...</p>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="modal fade" id="promoModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
            <form id="promoForm" onsubmit="return savePromo(event)">
                <div class="modal-header">
                    <h5 class="modal-title" id="promoModalTitle"><i class="bi bi-ticket me-2"></i>Add Promotion</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="promoId">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Code <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="promoCode" required placeholder="e.g. SPICY20">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Type <span class="text-danger">*</span></label>
                            <select class="form-select" id="promoType">
                                <option value="percentage">Percentage</option>
                                <option value="fixed">Fixed</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Description</label>
                            <textarea class="form-control" id="promoDescription" rows="2" placeholder="Brief description..."></textarea>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Discount <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="number" class="form-control" id="promoDiscount" required min="0" step="any" placeholder="20">
                                <span class="input-group-text" id="discountLabel">%</span>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Min Order Amount</label>
                            <input type="number" class="form-control" id="promoMinOrder" min="0" step="any" placeholder="0">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Status</label>
                            <div class="form-check form-switch mt-2">
                                <input class="form-check-input" type="checkbox" id="promoActive" checked>
                                <label class="form-check-label" for="promoActive">Active</label>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Valid From</label>
                            <input type="date" class="form-control" id="promoValidFrom">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Valid To</label>
                            <input type="date" class="form-control" id="promoValidTo">
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-msm" id="promoSaveBtn">Save Promotion</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="deletePromoModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title text-danger"><i class="bi bi-exclamation-triangle me-2"></i>Delete Promotion</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center py-4">
                <div class="mb-3"><i class="bi bi-trash text-danger" style="font-size:3rem;opacity:.5;"></i></div>
                <p class="mb-1">Delete promotion <strong id="deletePromoCodeLabel">—</strong>?</p>
                <p class="small text-muted">This action cannot be undone.</p>
            </div>
            <div class="modal-footer border-0 justify-content-center">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger px-4" id="confirmDeletePromo">Delete</button>
            </div>
        </div>
    </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3" id="promoToastContainer" style="z-index:9999;"></div>

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
            if (xhr.status >= 200 && xhr.status < 300) { if (onSuccess) onSuccess(res); }
            else { if (onError) onError(res); }
        } catch (e) { if (onError) onError({message:'Invalid response.'}); }
    };
    xhr.onerror = function() { if (onError) onError({message:'Network error.'}); };
    xhr.send(body ? JSON.stringify(body) : null);
}

function showToast(msg, type) {
    type = type || 'success';
    var bg = type==='danger'?'bg-danger':type==='warning'?'bg-warning text-dark':'bg-success';
    var icon = type==='danger'?'bi-x-circle':type==='warning'?'bi-exclamation-circle':'bi-check-circle';
    var c = document.getElementById('promoToastContainer');
    var el = document.createElement('div');
    el.className = 'toast align-items-center text-white border-0 '+bg;
    el.setAttribute('role','alert');
    el.innerHTML = '<div class="d-flex"><div class="toast-body"><i class="bi '+icon+' me-2"></i>'+ msg +'</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>';
    c.appendChild(el);
    var t = new bootstrap.Toast(el,{autohide:true,delay:4000});
    t.show();
    el.addEventListener('hidden.bs.toast',function(){el.remove();});
}

function escapeHtml(s) {
    if (!s) return '';
    var d = document.createElement('div');
    d.appendChild(document.createTextNode(s));
    return d.innerHTML;
}

var allPromos = [];

function loadPromotions() {
    var tbody = document.getElementById('promotionsTableBody');
    tbody.innerHTML = '<tr><td colspan="8"><div class="text-center py-5"><div class="spinner-border text-success mb-3" role="status"></div><p>Loading...</p></div></td></tr>';

    apiFetch('GET', '<?php echo API_ADMIN_PROMOTIONS; ?>', null, function(data) {
        var list = data.data || data.promotions || (Array.isArray(data) ? data : []);
        if (list && list.length && list[0]._id === undefined && list[0].id === undefined) {
            list = data;
        }
        allPromos = list;
        filterPromos();
    }, function() {
        tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state py-5"><i class="bi bi-exclamation-circle text-danger"></i><p>Failed to load promotions.</p></div></td></tr>';
    });
}

function filterPromos() {
    var q = (document.getElementById('promoSearch').value || '').toLowerCase();
    var filtered = allPromos;
    if (q) {
        filtered = allPromos.filter(function(p) {
            return (p.code && p.code.toLowerCase().indexOf(q) !== -1);
        });
    }
    renderPromotions(filtered);
}

function renderPromotions(list) {
    var tbody = document.getElementById('promotionsTableBody');

    if (!list || list.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state py-5"><i class="bi bi-ticket"></i><p>No promotions found.</p><span class="text-muted" style="font-size:0.82rem;">Click "Add Promotion" to create one.</span></div></td></tr>';
        updatePromoStats(list || []);
        return;
    }

    updatePromoStats(list);

    var h = '';
    var now = new Date();

    list.forEach(function(p) {
        var isActive = p.isActive !== false && p.isActive !== 'false';
        var isExpired = p.validTo && new Date(p.validTo) < now;

        var validFrom = p.validFrom ? MSM.formatDate(p.validFrom) : 'N/A';
        var validTo = p.validTo ? MSM.formatDate(p.validTo) : 'N/A';
        var discount = p.type === 'fixed'
            ? MSM.formatCurrency(Number(p.discountPercent || 0))
            : (Number(p.discountPercent || 0) + '%');
        var typeBadge = p.type === 'fixed'
            ? '<span class="badge badge-status bg-primary">Fixed</span>'
            : '<span class="badge badge-status bg-warning text-dark">Percentage</span>';
        var minOrder = p.minOrderAmount ? '≥ ' + MSM.formatCurrency(p.minOrderAmount) : 'None';
        var activeToggle = '<div class="form-check form-switch m-0"><input class="form-check-input promo-toggle" type="checkbox" ' + (isExpired ? '' : (isActive ? 'checked' : '')) + ' data-id="' + p._id + '" ' + (isExpired ? 'disabled' : '') + '></div>';

        var periodText = '<span style="font-size:0.75rem;">' + validFrom + '<br>to ' + validTo + '</span>';
        if (isExpired) {
            periodText += ' <span class="badge badge-status bg-danger ms-1" style="font-size:0.6rem;">Expired</span>';
        }

        h += '<tr>';
        h += '<td><strong style="font-size:0.85rem;">' + escapeHtml(p.code) + '</strong></td>';
        h += '<td style="font-size:0.82rem;max-width:200px;"><span class="text-truncate d-inline-block" style="max-width:200px;">' + escapeHtml(p.description || '-') + '</span></td>';
        h += '<td style="font-weight:600;font-size:0.9rem;">' + discount + '</td>';
        h += '<td>' + typeBadge + '</td>';
        h += '<td style="font-size:0.8rem;">' + minOrder + '</td>';
        h += '<td>' + periodText + '</td>';
        h += '<td>' + activeToggle + '</td>';
        h += '<td><div class="d-flex gap-1"><button class="btn btn-sm btn-outline-warning" onclick="openEditPromo(\'' + p._id + '\')" title="Edit"><i class="bi bi-pencil"></i></button><button class="btn btn-sm btn-outline-danger" onclick="confirmDeletePromo(\'' + p._id + '\', \'' + escapeHtml(p.code) + '\')" title="Delete"><i class="bi bi-trash"></i></button></div></td>';
        h += '</tr>';
    });
    tbody.innerHTML = h;

    document.querySelectorAll('.promo-toggle').forEach(function(toggle) {
        toggle.addEventListener('change', function() {
            togglePromoStatus(this);
        });
    });
}

function updatePromoStats(list) {
    var total = list.length;
    var active = 0;
    var expired = 0;
    var now = new Date();
    list.forEach(function(p) {
        var isActive = p.isActive !== false && p.isActive !== 'false';
        var isExpired = p.validTo && new Date(p.validTo) < now;
        if (isActive && !isExpired) active++;
        if (isExpired) expired++;
    });

    animateStat2('statTotalPromos', total);
    animateStat2('statActivePromos', active);
    animateStat2('statExpiredPromos', expired);
}

function animateStat2(id, target) {
    var el = document.getElementById(id);
    if (!el) return;
    var current = parseInt(el.textContent.replace(/[^0-9]/g, '')) || 0;
    var startTime = null;
    var duration = 800;
    function step(ts) {
        if (!startTime) startTime = ts;
        var p = Math.min((ts-startTime) / duration, 1);
        var eased = 1 - Math.pow(1-p, 3);
        el.textContent = Math.floor(eased * target);
        if (p < 1 && target > 0) requestAnimationFrame(step);
    }
    if (target > 0) requestAnimationFrame(step);
    else el.textContent = target;
}

function openAddPromoModal() {
    document.getElementById('promoForm').reset();
    document.getElementById('promoId').value = '';
    document.getElementById('promoModalTitle').textContent = 'Add Promotion';
    document.getElementById('promoSaveBtn').textContent = 'Save Promotion';
    document.getElementById('promoActive').checked = true;
    document.getElementById('discountLabel').textContent = '%';
    document.getElementById('promoType').onchange = function() {
        document.getElementById('discountLabel').textContent = this.value === 'fixed' ? 'FCFA' : '%';
    };
    new bootstrap.Modal(document.getElementById('promoModal')).show();
}

var promoIdToDelete = null;

function openEditPromo(id) {
    var p = allPromos.find(function(x) { return x._id === id || x.id === id; });
    if (!p) { showToast('Promotion not found.', 'warning'); return; }

    document.getElementById('promoForm').reset();
    document.getElementById('promoId').value = id;
    document.getElementById('promoCode').value = p.code || '';
    document.getElementById('promoDescription').value = p.description || '';
    document.getElementById('promoDiscount').value = p.discountPercent || 0;
    document.getElementById('promoType').value = p.type || 'percentage';
    document.getElementById('promoMinOrder').value = p.minOrderAmount || 0;
    document.getElementById('promoActive').checked = p.isActive !== false && p.isActive !== 'false';
    document.getElementById('promoValidFrom').value = p.validFrom ? p.validFrom.substring(0,10) : '';
    document.getElementById('promoValidTo').value = p.validTo ? p.validTo.substring(0,10) : '';
    document.getElementById('promoModalTitle').textContent = 'Edit Promotion';
    document.getElementById('promoSaveBtn').textContent = 'Update Promotion';
    document.getElementById('discountLabel').textContent = p.type === 'fixed' ? 'FCFA' : '%';

    document.getElementById('promoType').onchange = function() {
        document.getElementById('discountLabel').textContent = this.value === 'fixed' ? 'FCFA' : '%';
    };

    new bootstrap.Modal(document.getElementById('promoModal')).show();
}

function savePromo(e) {
    e.preventDefault();
    var id = document.getElementById('promoId').value;
    var isEdit = !!id;

    var data = {
        code: document.getElementById('promoCode').value.trim(),
        description: document.getElementById('promoDescription').value.trim(),
        discountPercent: parseFloat(document.getElementById('promoDiscount').value) || 0,
        type: document.getElementById('promoType').value,
        minOrderAmount: parseFloat(document.getElementById('promoMinOrder').value) || 0,
        isActive: document.getElementById('promoActive').checked
    };
    var vf = document.getElementById('promoValidTo').value;
    if (vf) data.validTo = vf;

    var btn = document.getElementById('promoSaveBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Saving...';

    var method = isEdit ? 'PUT' : 'POST';
    var url = isEdit ? '<?php echo API_ADMIN_PROMOTIONS; ?>/' + id : '<?php echo API_ADMIN_PROMOTIONS; ?>';

    apiFetch(method, url, data, function() {
        bootstrap.Modal.getInstance(document.getElementById('promoModal')).hide();
        showToast(isEdit ? 'Promotion updated successfully.' : 'Promotion created successfully.');
        loadPromotions();
        btn.disabled = false;
        btn.textContent = isEdit ? 'Update Promotion' : 'Save Promotion';
    }, function(err) {
        showToast(err && err.message ? err.message : 'Failed to save promotion.', 'danger');
        btn.disabled = false;
        btn.textContent = isEdit ? 'Update Promotion' : 'Save Promotion';
    });

    return false;
}

function confirmDeletePromo(id, code) {
    promoIdToDelete = id;
    document.getElementById('deletePromoCodeLabel').textContent = code;
    new bootstrap.Modal(document.getElementById('deletePromoModal')).show();
}

document.getElementById('confirmDeletePromo').addEventListener('click', function() {
    if (!promoIdToDelete) return;
    var id = promoIdToDelete;
    var url = '<?php echo API_ADMIN_PROMOTIONS; ?>/' + id;
    var btn = document.getElementById('confirmDeletePromo');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Deleting...';

    apiFetch('DELETE', url, null, function() {
        bootstrap.Modal.getInstance(document.getElementById('deletePromoModal')).hide();
        showToast('Promotion deleted successfully.');
        loadPromotions();
        btn.disabled = false;
        btn.textContent = 'Delete';
        promoIdToDelete = null;
    }, function(err) {
        showToast(err && err.message ? err.message : 'Failed to delete promotion.', 'danger');
        btn.disabled = false;
        btn.textContent = 'Delete';
    });
});

function togglePromoStatus(toggle) {
    var id = toggle.getAttribute('data-id');
    var active = toggle.checked;

    apiFetch('PUT', '<?php echo API_ADMIN_PROMOTIONS; ?>/' + id, { isActive: active }, function() {
        showToast(active ? 'Promotion activated.' : 'Promotion deactivated.');
    }, function(err) {
        toggle.checked = !active;
        showToast(err && err.message ? err.message : 'Failed to update status.', 'danger');
    });
}

document.addEventListener('DOMContentLoaded', function() {
    loadPromotions();
    MSM.initSearch('<?php echo API_ADMIN_SEARCH; ?>');
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
