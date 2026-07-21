<?php
/**
 * Customers Management Page
 *
 * Full-featured customer management with search, filtering, pagination,
 * status toggling, and detailed profile view modal.
 */

$currentPage = 'customers';
$pageTitle   = 'Customers';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt = session_get_jwt();
$customersData = api_request('GET', API_ADMIN_CUSTOMERS, null, $jwt);
$customers     = $customersData['body']['customers'] ?? $customersData['body'] ?? [];
$totalCustomers = $customersData['body']['total'] ?? count($customers);
$newThisMonth  = 0;
$verifiedCount = 0;
$activeToday   = 0;
$now           = new DateTime();

foreach ($customers as $c) {
    $createdAt = $c['createdAt'] ?? null;
    if ($createdAt) {
        $created = new DateTime($createdAt);
        if ($created->format('Y-m') === $now->format('Y-m')) {
            $newThisMonth++;
        }
    }
    if (!empty($c['isVerified'])) {
        $verifiedCount++;
    }
}

$verifiedPct = $totalCustomers > 0 ? round(($verifiedCount / $totalCustomers) * 100) : 0;

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
            <div class="navbar-brand-text">
                <span><?php echo $pageTitle; ?></span>
            </div>
        </div>
        <div class="navbar-right">
            <div style="position:relative;">
                <button class="navbar-icon-btn" onclick="MSM.toggleDropdown('notifDropdown')" title="Notifications">
                    <i class="bi bi-bell"></i>
                </button>
                <div class="notification-dropdown" id="notifDropdown">
                    <div class="notif-header">
                        <h6>Notifications</h6>
                    </div>
                    <div class="notif-list">
                        <div class="notif-item">
                            <div class="notif-content">
                                <div class="notif-title">All caught up!</div>
                                <div class="notif-msg">No new notifications.</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div style="position:relative;">
                <img src="<?php echo htmlspecialchars($adminAvatar); ?>"
                     alt="Admin" class="profile-avatar"
                     onerror="this.src='https://ui-avatars.com/api/?name=<?php echo urlencode($adminName); ?>&background=198754&color=fff&size=36'"
                     onclick="MSM.toggleDropdown('profileDropdown')">
                <div class="profile-dropdown" id="profileDropdown">
                    <div style="padding:0.75rem 1rem;border-bottom:1px solid var(--msm-border);">
                        <div style="font-weight:600;font-size:0.85rem;"><?php echo htmlspecialchars($adminName); ?></div>
                        <div style="font-size:0.75rem;color:var(--msm-muted);"><?php echo htmlspecialchars($adminEmail); ?></div>
                    </div>
                    <a href="<?php echo admin_url('auth/logout.php'); ?>" class="logout-link"><i class="bi bi-box-arrow-right"></i> Logout</a>
                </div>
            </div>
        </div>
    </div>

    <div class="p-4">
        <!-- Stat Cards -->
        <div class="row g-3 mb-4">
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#0d6efd,#0b5ed7);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Total Customers</div>
                            <div class="stat-value" style="color:#0d6efd;" data-count="<?php echo $totalCustomers; ?>"><?php echo number_format($totalCustomers); ?></div>
                        </div>
                        <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-people"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#198754,#0d6e3f);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Active Today</div>
                            <div class="stat-value" style="color:#198754;" data-count="<?php echo $activeToday; ?>"><?php echo $activeToday; ?></div>
                        </div>
                        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="bi bi-person-check"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#0dcaf0,#0aa2c0);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">New This Month</div>
                            <div class="stat-value" style="color:#0dcaf0;" data-count="<?php echo $newThisMonth; ?>"><?php echo $newThisMonth; ?></div>
                        </div>
                        <div class="stat-icon bg-info bg-opacity-10 text-info"><i class="bi bi-person-plus"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#ffc107,#e0a800);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Verified %</div>
                            <div class="stat-value" style="color:#e0a800;" data-count="<?php echo $verifiedPct; ?>"><?php echo $verifiedPct; ?>%</div>
                        </div>
                        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-patch-check"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Customers Table -->
        <div class="msm-card animate-in">
            <div class="table-toolbar">
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <h6 class="mb-0 fw-bold">All Customers</h6>
                    <div class="d-flex gap-1">
                        <button class="table-filter-btn active" data-filter="all" onclick="filterCustomers('all', this)">All</button>
                        <button class="table-filter-btn" data-filter="active" onclick="filterCustomers('active', this)">Active</button>
                        <button class="table-filter-btn" data-filter="suspended" onclick="filterCustomers('suspended', this)">Suspended</button>
                    </div>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <div class="input-group input-group-sm" style="width:220px;">
                        <span class="input-group-text bg-light border-end-0"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control border-start-0 bg-light" id="customerSearch" placeholder="Search customers..." oninput="searchCustomers()">
                    </div>
                </div>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0 msm-table">
                    <thead class="table-light">
                        <tr>
                            <th>Customer</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Status</th>
                            <th>Joined</th>
                            <th>Orders</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="customersTableBody">
                        <?php if (empty($customers)): ?>
                        <tr>
                            <td colspan="7">
                                <div class="empty-state py-4">
                                    <i class="bi bi-people"></i>
                                    <p>No customers found.</p>
                                </div>
                            </td>
                        </tr>
                        <?php else: ?>
                        <?php foreach ($customers as $c): ?>
                        <?php
                            $cId    = $c['_id'] ?? $c['id'] ?? '';
                            $cName  = $c['fullName'] ?? 'Unknown';
                            $cEmail = $c['email'] ?? '';
                            $cPhone = $c['phone'] ?? 'N/A';
                            $cVerified = !empty($c['isVerified']);
                            $cJoined   = $c['createdAt'] ?? '';
                            $cOrders   = $c['orderCount'] ?? $c['totalOrders'] ?? 0;
                            $initials  = strtoupper(substr($cName, 0, 1));
                            $colors    = ['#198754','#0d6efd','#ffc107','#dc3545','#6f42c1','#0dcaf0'];
                            $colorIdx  = crc32($cId) % count($colors);
                        ?>
                        <tr data-customer-id="<?php echo htmlspecialchars($cId); ?>" data-verified="<?php echo $cVerified ? '1' : '0'; ?>">
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="activity-avatar-placeholder" style="width:36px;height:36px;font-size:0.75rem;background:<?php echo $colors[$colorIdx]; ?>;">
                                        <?php echo $initials; ?>
                                    </div>
                                    <span class="fw-semibold" style="font-size:0.85rem;"><?php echo htmlspecialchars($cName); ?></span>
                                </div>
                            </td>
                            <td class="text-muted small"><?php echo htmlspecialchars($cEmail); ?></td>
                            <td class="text-muted small"><?php echo htmlspecialchars($cPhone); ?></td>
                            <td>
                                <span class="badge <?php echo $cVerified ? 'bg-success' : 'bg-warning text-dark'; ?> badge-status">
                                    <?php echo $cVerified ? 'Active' : 'Suspended'; ?>
                                </span>
                            </td>
                            <td class="text-muted small"><?php echo $cJoined ? date('d M Y', strtotime($cJoined)) : 'N/A'; ?></td>
                            <td><span class="fw-semibold"><?php echo $cOrders; ?></span></td>
                            <td class="text-end">
                                <div class="d-flex gap-1 justify-content-end">
                                    <button class="btn btn-sm btn-outline-primary" onclick="viewCustomer('<?php echo htmlspecialchars($cId); ?>')" title="View Details">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <button class="btn btn-sm <?php echo $cVerified ? 'btn-outline-warning' : 'btn-outline-success'; ?>" onclick="toggleCustomerStatus('<?php echo htmlspecialchars($cId); ?>', <?php echo $cVerified ? 'true' : 'false'; ?>)" title="<?php echo $cVerified ? 'Suspend' : 'Activate'; ?>">
                                        <i class="bi <?php echo $cVerified ? 'bi-pause-circle' : 'bi-play-circle'; ?>"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
            <div class="d-flex justify-content-between align-items-center p-3 border-top" id="paginationArea">
                <div class="text-muted small" id="customerCount"><?php echo count($customers); ?> customer(s)</div>
                <nav>
                    <ul class="pagination pagination-sm mb-0" id="customersPagination"></ul>
                </nav>
            </div>
        </div>
    </div>
</div>

<!-- View Customer Modal -->
<div class="modal fade" id="viewCustomerModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-header border-0 pb-0">
                <h6 class="modal-title fw-bold">Customer Details</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body pt-0" id="customerDetailBody">
                <div class="text-center py-4">
                    <div class="spinner-border text-success" role="status"><span class="visually-hidden">Loading...</span></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Toggle Status Confirmation Modal -->
<div class="modal fade" id="toggleStatusModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-body text-center p-4">
                <div class="mb-3" id="toggleStatusIcon"></div>
                <h6 class="fw-bold" id="toggleStatusTitle"></h6>
                <p class="text-muted small mb-0" id="toggleStatusMsg"></p>
            </div>
            <div class="modal-footer border-0 pt-0 justify-content-center">
                <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-sm btn-msm" id="toggleStatusConfirm">Confirm</button>
            </div>
        </div>
    </div>
</div>

<script>
var MSM_JWT = '<?php echo $jwt; ?>';
var CUSTOMERS_RAW = <?php echo json_encode($customers); ?>;
var currentFilter = 'all';
var currentPage = 1;
var perPage = 10;

function getFilteredCustomers() {
    var search = (document.getElementById('customerSearch').value || '').toLowerCase();
    return CUSTOMERS_RAW.filter(function(c) {
        var matchSearch = !search ||
            (c.fullName || '').toLowerCase().indexOf(search) > -1 ||
            (c.email || '').toLowerCase().indexOf(search) > -1 ||
            (c.phone || '').toLowerCase().indexOf(search) > -1;
        var matchFilter = currentFilter === 'all' ||
            (currentFilter === 'active' && c.isVerified) ||
            (currentFilter === 'suspended' && !c.isVerified);
        return matchSearch && matchFilter;
    });
}

function renderCustomerTable(customers) {
    var tbody = document.getElementById('customersTableBody');
    var colors = ['#198754','#0d6efd','#ffc107','#dc3545','#6f42c1','#0dcaf0'];
    if (!customers.length) {
        tbody.innerHTML = '<tr><td colspan="7"><div class="empty-state py-4"><i class="bi bi-people"></i><p>No customers match your criteria.</p></div></td></tr>';
        document.getElementById('customerCount').textContent = '0 customer(s)';
        document.getElementById('customersPagination').innerHTML = '';
        return;
    }
    var total = customers.length;
    var totalPages = Math.ceil(total / perPage);
    if (currentPage > totalPages) currentPage = totalPages;
    var start = (currentPage - 1) * perPage;
    var pageItems = customers.slice(start, start + perPage);
    var html = '';
    pageItems.forEach(function(c) {
        var id = c._id || c.id || '';
        var name = c.fullName || 'Unknown';
        var email = c.email || '';
        var phone = c.phone || 'N/A';
        var verified = !!c.isVerified;
        var joined = c.createdAt ? new Date(c.createdAt).toLocaleDateString('en-GB',{day:'2-digit',month:'short',year:'numeric'}) : 'N/A';
        var orders = c.orderCount || c.totalOrders || 0;
        var initial = name.charAt(0).toUpperCase();
        var colorIdx = 0;
        for (var i = 0; i < id.length; i++) colorIdx += id.charCodeAt(i);
        colorIdx = colorIdx % colors.length;
        html += '<tr data-customer-id="' + id + '" data-verified="' + (verified ? '1' : '0') + '">';
        html += '<td><div class="d-flex align-items-center gap-2">';
        html += '<div class="activity-avatar-placeholder" style="width:36px;height:36px;font-size:0.75rem;background:' + colors[colorIdx] + ';">' + initial + '</div>';
        html += '<span class="fw-semibold" style="font-size:0.85rem;">' + MSM.truncate(name, 30) + '</span></div></td>';
        html += '<td class="text-muted small">' + MSM.truncate(email, 28) + '</td>';
        html += '<td class="text-muted small">' + phone + '</td>';
        html += '<td><span class="badge ' + (verified ? 'bg-success' : 'bg-warning text-dark') + ' badge-status">' + (verified ? 'Active' : 'Suspended') + '</span></td>';
        html += '<td class="text-muted small">' + joined + '</td>';
        html += '<td><span class="fw-semibold">' + orders + '</span></td>';
        html += '<td class="text-end"><div class="d-flex gap-1 justify-content-end">';
        html += '<button class="btn btn-sm btn-outline-primary" onclick="viewCustomer(\'' + id + '\')" title="View Details"><i class="bi bi-eye"></i></button>';
        html += '<button class="btn btn-sm ' + (verified ? 'btn-outline-warning' : 'btn-outline-success') + '" onclick="toggleCustomerStatus(\'' + id + '\', ' + verified + ')" title="' + (verified ? 'Suspend' : 'Activate') + '"><i class="bi ' + (verified ? 'bi-pause-circle' : 'bi-play-circle') + '"></i></button>';
        html += '</div></td></tr>';
    });
    tbody.innerHTML = html;
    document.getElementById('customerCount').textContent = total + ' customer(s)';
    renderPagination(totalPages);
}

function renderPagination(totalPages) {
    var pg = document.getElementById('customersPagination');
    if (totalPages <= 1) { pg.innerHTML = ''; return; }
    var html = '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') + '"><a class="page-link" href="#" onclick="goPage(' + (currentPage - 1) + ');return false;"><i class="bi bi-chevron-left"></i></a></li>';
    for (var i = 1; i <= totalPages; i++) {
        if (totalPages > 7 && i > 2 && i < totalPages - 1 && Math.abs(i - currentPage) > 1) {
            if (i === 3 || i === totalPages - 2) html += '<li class="page-item disabled"><span class="page-link">...</span></li>';
            continue;
        }
        html += '<li class="page-item ' + (i === currentPage ? 'active' : '') + '"><a class="page-link" href="#" onclick="goPage(' + i + ');return false;">' + i + '</a></li>';
    }
    html += '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '"><a class="page-link" href="#" onclick="goPage(' + (currentPage + 1) + ');return false;"><i class="bi bi-chevron-right"></i></a></li>';
    pg.innerHTML = html;
}

function goPage(p) {
    currentPage = p;
    renderCustomerTable(getFilteredCustomers());
}

function filterCustomers(filter, btn) {
    currentFilter = filter;
    currentPage = 1;
    document.querySelectorAll('.table-filter-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    renderCustomerTable(getFilteredCustomers());
}

var searchTimer = null;
function searchCustomers() {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(function() {
        currentPage = 1;
        renderCustomerTable(getFilteredCustomers());
    }, 250);
}

function viewCustomer(id) {
    var modal = new bootstrap.Modal(document.getElementById('viewCustomerModal'));
    var body = document.getElementById('customerDetailBody');
    body.innerHTML = '<div class="text-center py-4"><div class="spinner-border text-success" role="status"><span class="visually-hidden">Loading...</span></div></div>';
    modal.show();

    fetch(API_ADMIN_CUSTOMERS + '/' + id, {
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Accept': 'application/json' }
    })
    .then(function(r) { return r.json(); })
    .then(function(c) {
        var name = c.fullName || 'Unknown';
        var email = c.email || 'N/A';
        var phone = c.phone || 'N/A';
        var verified = !!c.isVerified;
        var joined = c.createdAt ? new Date(c.createdAt).toLocaleDateString('en-GB',{day:'2-digit',month:'long',year:'numeric'}) : 'N/A';
        var orders = c.orderCount || c.totalOrders || 0;
        var addr = c.address || {};
        var addrStr = [addr.street, addr.quarter, addr.city, addr.landmark].filter(Boolean).join(', ') || 'No address provided';
        var initial = name.charAt(0).toUpperCase();
        var colors = ['#198754','#0d6efd','#ffc107','#dc3545','#6f42c1'];
        var color = colors[Math.abs(id.charCodeAt(0)) % colors.length];

        var html = '<div class="text-center mb-3">';
        html += '<div class="activity-avatar-placeholder mx-auto" style="width:64px;height:64px;font-size:1.5rem;background:' + color + ';">' + initial + '</div>';
        html += '<h6 class="fw-bold mt-2 mb-0">' + MSM.truncate(name, 40) + '</h6>';
        html += '<span class="badge ' + (verified ? 'bg-success' : 'bg-warning text-dark') + ' badge-status">' + (verified ? 'Active Account' : 'Suspended Account') + '</span>';
        html += '</div>';
        html += '<div class="row g-3 mt-1">';
        html += '<div class="col-6"><div class="text-muted small mb-1">Email</div><div class="fw-semibold small">' + MSM.truncate(email, 25) + '</div></div>';
        html += '<div class="col-6"><div class="text-muted small mb-1">Phone</div><div class="fw-semibold small">' + phone + '</div></div>';
        html += '<div class="col-6"><div class="text-muted small mb-1">Total Orders</div><div class="fw-semibold small">' + orders + '</div></div>';
        html += '<div class="col-6"><div class="text-muted small mb-1">Joined</div><div class="fw-semibold small">' + joined + '</div></div>';
        html += '<div class="col-12"><div class="text-muted small mb-1">Address</div><div class="fw-semibold small">' + addrStr + '</div></div>';
        html += '</div>';
        body.innerHTML = html;
    })
    .catch(function() {
        body.innerHTML = '<div class="empty-state py-3"><i class="bi bi-exclamation-triangle"></i><p>Failed to load customer details.</p></div>';
    });
}

var pendingToggleId = null;
function toggleCustomerStatus(id, isVerified) {
    pendingToggleId = id;
    var modal = new bootstrap.Modal(document.getElementById('toggleStatusModal'));
    var iconEl = document.getElementById('toggleStatusIcon');
    var titleEl = document.getElementById('toggleStatusTitle');
    var msgEl = document.getElementById('toggleStatusMsg');
    var confirmBtn = document.getElementById('toggleStatusConfirm');

    if (isVerified) {
        iconEl.innerHTML = '<div class="bg-warning bg-opacity-10 text-warning d-inline-flex align-items-center justify-content-center" style="width:56px;height:56px;border-radius:50%;font-size:1.5rem;"><i class="bi bi-pause-circle"></i></div>';
        titleEl.textContent = 'Suspend Customer?';
        msgEl.textContent = 'This customer will no longer be able to place orders.';
        confirmBtn.className = 'btn btn-sm btn-warning';
    } else {
        iconEl.innerHTML = '<div class="bg-success bg-opacity-10 text-success d-inline-flex align-items-center justify-content-center" style="width:56px;height:56px;border-radius:50%;font-size:1.5rem;"><i class="bi bi-play-circle"></i></div>';
        titleEl.textContent = 'Activate Customer?';
        msgEl.textContent = 'This customer will regain full access to their account.';
        confirmBtn.className = 'btn btn-sm btn-msm';
    }
    modal.show();
}

document.getElementById('toggleStatusConfirm').addEventListener('click', function() {
    if (!pendingToggleId) return;
    var btn = this;
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

    fetch(API_ADMIN_CUSTOMERS + '/' + pendingToggleId + '/toggle-status', {
        method: 'PUT',
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Content-Type': 'application/json', 'Accept': 'application/json' }
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        bootstrap.Modal.getInstance(document.getElementById('toggleStatusModal')).hide();
        showToast('success', 'Customer status updated successfully.');
        setTimeout(function() { location.reload(); }, 800);
    })
    .catch(function() {
        showToast('error', 'Failed to update customer status. Please try again.');
    })
    .finally(function() {
        btn.disabled = false;
        btn.textContent = 'Confirm';
    });
});

var API_ADMIN_CUSTOMERS = '<?php echo API_ADMIN_CUSTOMERS; ?>';

document.addEventListener('DOMContentLoaded', function() {
    MSM.initCounters();
    renderCustomerTable(CUSTOMERS_RAW);
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>