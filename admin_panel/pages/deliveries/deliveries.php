<?php
/**
 * Riders / Delivery Management Page
 *
 * CRUD management for delivery riders: add, edit, delete, toggle availability.
 * Includes vehicle type badges, rating display, and stats.
 */

$currentPage = 'deliveries';
$pageTitle   = 'Riders';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt = session_get_jwt();
$ridersData  = api_request('GET', API_ADMIN_RIDERS, null, $jwt);
$riders      = $ridersData['body']['riders'] ?? $ridersData['body'] ?? [];
$totalRiders = $ridersData['body']['total'] ?? count($riders);
$availableCount = 0;
$totalDeliveries = 0;
$ratingSum = 0;
$ratingCount = 0;

foreach ($riders as $r) {
    if (!empty($r['isAvailable'])) $availableCount++;
    $totalDeliveries += ($r['totalDeliveries'] ?? 0);
    if (!empty($r['rating']) && $r['rating'] > 0) {
        $ratingSum += $r['rating'];
        $ratingCount++;
    }
}
$onDelivery = max(0, $totalRiders - $availableCount);
$avgRating = $ratingCount > 0 ? round($ratingSum / $ratingCount, 1) : 0;

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
            <div class="navbar-brand-text"><span><?php echo $pageTitle; ?></span></div>
        </div>
        <div class="navbar-right">
            <div style="position:relative;">
                <button class="navbar-icon-btn" onclick="MSM.toggleDropdown('notifDropdown')" title="Notifications">
                    <i class="bi bi-bell"></i>
                </button>
                <div class="notification-dropdown" id="notifDropdown">
                    <div class="notif-header"><h6>Notifications</h6></div>
                    <div class="notif-list">
                        <div class="notif-item"><div class="notif-content"><div class="notif-title">All caught up!</div></div></div>
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
                            <div class="stat-label">Total Riders</div>
                            <div class="stat-value" style="color:#0d6efd;" data-count="<?php echo $totalRiders; ?>"><?php echo $totalRiders; ?></div>
                        </div>
                        <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-bicycle"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#198754,#0d6e3f);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Available</div>
                            <div class="stat-value" style="color:#198754;" data-count="<?php echo $availableCount; ?>"><?php echo $availableCount; ?></div>
                        </div>
                        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="bi bi-check-circle"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#ffc107,#e0a800);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">On Delivery</div>
                            <div class="stat-value" style="color:#e0a800;" data-count="<?php echo $onDelivery; ?>"><?php echo $onDelivery; ?></div>
                        </div>
                        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-truck"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#0dcaf0,#0aa2c0);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Avg Rating</div>
                            <div class="stat-value" style="color:#0aa2c0;">
                                <?php echo $avgRating; ?> <small style="font-size:0.7rem;color:var(--msm-muted);">/ 5</small>
                            </div>
                        </div>
                        <div class="stat-icon bg-info bg-opacity-10 text-info"><i class="bi bi-star"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Riders Table -->
        <div class="msm-card animate-in">
            <div class="table-toolbar">
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <h6 class="mb-0 fw-bold">All Riders</h6>
                </div>
                <button class="btn btn-sm btn-msm" onclick="openAddRiderModal()">
                    <i class="bi bi-plus-lg me-1"></i> Add Rider
                </button>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0 msm-table">
                    <thead class="table-light">
                        <tr>
                            <th>Rider</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Vehicle</th>
                            <th>Available</th>
                            <th>Deliveries</th>
                            <th>Rating</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="ridersTableBody">
                        <?php if (empty($riders)): ?>
                        <tr>
                            <td colspan="8">
                                <div class="empty-state py-4">
                                    <i class="bi bi-bicycle"></i>
                                    <p>No riders found. Add your first rider to get started.</p>
                                </div>
                            </td>
                        </tr>
                        <?php else: ?>
                        <?php foreach ($riders as $r): ?>
                        <?php
                            $rId         = $r['_id'] ?? $r['id'] ?? '';
                            $rName       = $r['fullName'] ?? 'Unknown';
                            $rEmail      = $r['email'] ?? '';
                            $rPhone      = $r['phone'] ?? 'N/A';
                            $rVehicle    = $r['vehicleType'] ?? 'Bike';
                            $rAvailable  = !empty($r['isAvailable']);
                            $rDeliveries = $r['totalDeliveries'] ?? 0;
                            $rRating     = $r['rating'] ?? 0;
                            $initials    = strtoupper(substr($rName, 0, 1));
                            $colors      = ['#dc3545','#198754','#0d6efd','#ffc107','#6f42c1','#0dcaf0'];
                            $colorIdx    = crc32($rId) % count($colors);
                            $vehicleBadge = $rVehicle === 'Car' ? 'bg-primary' : ($rVehicle === 'Scooter' ? 'bg-warning text-dark' : 'bg-success');
                        ?>
                        <tr data-rider-id="<?php echo htmlspecialchars($rId); ?>">
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="activity-avatar-placeholder" style="width:36px;height:36px;font-size:0.75rem;background:<?php echo $colors[$colorIdx]; ?>;">
                                        <?php echo $initials; ?>
                                    </div>
                                    <span class="fw-semibold" style="font-size:0.85rem;"><?php echo htmlspecialchars($rName); ?></span>
                                </div>
                            </td>
                            <td class="text-muted small"><?php echo htmlspecialchars($rEmail); ?></td>
                            <td class="text-muted small"><?php echo htmlspecialchars($rPhone); ?></td>
                            <td>
                                <span class="badge <?php echo $vehicleBadge; ?> badge-status">
                                    <i class="bi <?php echo $rVehicle === 'Car' ? 'bi-car-front' : ($rVehicle === 'Scooter' ? 'bi-scooter' : 'bi-bicycle'); ?> me-1"></i>
                                    <?php echo htmlspecialchars($rVehicle); ?>
                                </span>
                            </td>
                            <td>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" role="switch" <?php echo $rAvailable ? 'checked' : ''; ?>
                                           onchange="toggleAvailability('<?php echo htmlspecialchars($rId); ?>', this.checked)" title="Toggle availability">
                                </div>
                            </td>
                            <td><span class="fw-semibold"><?php echo $rDeliveries; ?></span></td>
                            <td>
                                <div class="d-flex align-items-center gap-1">
                                    <?php for ($s = 1; $s <= 5; $s++): ?>
                                        <i class="bi bi-star<?php echo $s <= round($rRating) ? '-fill' : ''; ?>" style="color:#ffc107;font-size:0.7rem;"></i>
                                    <?php endfor; ?>
                                    <span class="text-muted small ms-1"><?php echo $rRating; ?></span>
                                </div>
                            </td>
                            <td class="text-end">
                                <div class="d-flex gap-1 justify-content-end">
                                    <button class="btn btn-sm btn-outline-primary" onclick="editRider('<?php echo htmlspecialchars($rId); ?>')" title="Edit">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger" onclick="deleteRider('<?php echo htmlspecialchars($rId); ?>', '<?php echo htmlspecialchars(addslashes($rName)); ?>')" title="Delete">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
            <div class="d-flex justify-content-between align-items-center p-3 border-top">
                <div class="text-muted small"><?php echo count($riders); ?> rider(s) total</div>
            </div>
        </div>
    </div>
</div>

<!-- Add Rider Modal -->
<div class="modal fade" id="addRiderModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-header border-0">
                <h6 class="modal-title fw-bold"><i class="bi bi-person-plus text-success me-2"></i>Add New Rider</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body pt-0">
                <form id="addRiderForm" onsubmit="submitAddRider(event)">
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Full Name</label>
                        <input type="text" class="form-control" id="addRiderName" required placeholder="e.g. Paul Nji" minlength="2">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Email Address</label>
                        <input type="email" class="form-control" id="addRiderEmail" required placeholder="rider@example.com">
                    </div>
                    <div class="row g-3">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold small">Phone Number</label>
                            <input type="tel" class="form-control" id="addRiderPhone" required placeholder="+237 6XX XXX XXX">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold small">Vehicle Type</label>
                            <select class="form-select" id="addRiderVehicle" required>
                                <option value="Bike">Bike</option>
                                <option value="Car">Car</option>
                                <option value="Scooter">Scooter</option>
                            </select>
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Password</label>
                        <input type="password" class="form-control" id="addRiderPassword" required placeholder="Min 6 characters" minlength="6">
                    </div>
                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-sm btn-msm" id="addRiderBtn">
                            <i class="bi bi-check-lg me-1"></i> Create Rider
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Edit Rider Modal -->
<div class="modal fade" id="editRiderModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-header border-0">
                <h6 class="modal-title fw-bold"><i class="bi bi-pencil-square text-primary me-2"></i>Edit Rider</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body pt-0">
                <form id="editRiderForm" onsubmit="submitEditRider(event)">
                    <input type="hidden" id="editRiderId">
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Full Name</label>
                        <input type="text" class="form-control" id="editRiderName" required minlength="2">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Email Address</label>
                        <input type="email" class="form-control" id="editRiderEmail" required>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold small">Phone Number</label>
                            <input type="tel" class="form-control" id="editRiderPhone" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold small">Vehicle Type</label>
                            <select class="form-select" id="editRiderVehicle" required>
                                <option value="Bike">Bike</option>
                                <option value="Car">Car</option>
                                <option value="Scooter">Scooter</option>
                            </select>
                        </div>
                    </div>
                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-sm btn-msm" id="editRiderBtn">
                            <i class="bi bi-check-lg me-1"></i> Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteRiderModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-body text-center p-4">
                <div class="bg-danger bg-opacity-10 text-danger d-inline-flex align-items-center justify-content-center mb-3" style="width:56px;height:56px;border-radius:50%;font-size:1.5rem;">
                    <i class="bi bi-trash"></i>
                </div>
                <h6 class="fw-bold">Delete Rider?</h6>
                <p class="text-muted small mb-0">This will permanently remove <strong id="deleteRiderName"></strong> from the system.</p>
            </div>
            <div class="modal-footer border-0 pt-0 justify-content-center">
                <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-sm btn-danger" id="deleteRiderConfirm">
                    <i class="bi bi-trash me-1"></i> Delete
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var MSM_JWT = '<?php echo $jwt; ?>';
var RIDERS_RAW = <?php echo json_encode($riders); ?>;
var API_RIDERS = '<?php echo API_ADMIN_RIDERS; ?>';
var pendingDeleteRiderId = null;

function openAddRiderModal() {
    document.getElementById('addRiderForm').reset();
    new bootstrap.Modal(document.getElementById('addRiderModal')).show();
}

function submitAddRider(e) {
    e.preventDefault();
    var name = document.getElementById('addRiderName').value.trim();
    var email = document.getElementById('addRiderEmail').value.trim();
    var phone = document.getElementById('addRiderPhone').value.trim();
    var vehicle = document.getElementById('addRiderVehicle').value;
    var password = document.getElementById('addRiderPassword').value;

    if (password.length < 6) {
        showToast('error', 'Password must be at least 6 characters.');
        return;
    }

    var btn = document.getElementById('addRiderBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

    fetch(API_RIDERS, {
        method: 'POST',
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ fullName: name, email: email, phone: phone, vehicleType: vehicle, password: password })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        if (res.message && res.message.toLowerCase().indexOf('created') > -1 || res._id || res.rider) {
            bootstrap.Modal.getInstance(document.getElementById('addRiderModal')).hide();
            showToast('success', 'Rider created successfully.');
            setTimeout(function() { location.reload(); }, 800);
        } else {
            showToast('error', res.message || 'Failed to create rider.');
        }
    })
    .catch(function() {
        showToast('error', 'Network error. Please try again.');
    })
    .finally(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-check-lg me-1"></i> Create Rider';
    });
}

function editRider(id) {
    var rider = RIDERS_RAW.find(function(r) { return (r._id || r.id) === id; });
    if (!rider) return;
    document.getElementById('editRiderId').value = id;
    document.getElementById('editRiderName').value = rider.fullName || '';
    document.getElementById('editRiderEmail').value = rider.email || '';
    document.getElementById('editRiderPhone').value = rider.phone || '';
    document.getElementById('editRiderVehicle').value = rider.vehicleType || 'Bike';
    new bootstrap.Modal(document.getElementById('editRiderModal')).show();
}

function submitEditRider(e) {
    e.preventDefault();
    var id = document.getElementById('editRiderId').value;
    var name = document.getElementById('editRiderName').value.trim();
    var email = document.getElementById('editRiderEmail').value.trim();
    var phone = document.getElementById('editRiderPhone').value.trim();
    var vehicle = document.getElementById('editRiderVehicle').value;

    var btn = document.getElementById('editRiderBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

    fetch(API_RIDERS + '/' + id, {
        method: 'PUT',
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ fullName: name, email: email, phone: phone, vehicleType: vehicle })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        bootstrap.Modal.getInstance(document.getElementById('editRiderModal')).hide();
        showToast('success', 'Rider updated successfully.');
        setTimeout(function() { location.reload(); }, 800);
    })
    .catch(function() {
        showToast('error', 'Failed to update rider.');
    })
    .finally(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-check-lg me-1"></i> Save Changes';
    });
}

function toggleAvailability(id, isAvailable) {
    fetch(API_RIDERS + '/' + id, {
        method: 'PUT',
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ isAvailable: isAvailable })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        showToast('success', 'Availability updated.');
    })
    .catch(function() {
        showToast('error', 'Failed to update availability.');
        setTimeout(function() { location.reload(); }, 500);
    });
}

function deleteRider(id, name) {
    pendingDeleteRiderId = id;
    document.getElementById('deleteRiderName').textContent = name;
    new bootstrap.Modal(document.getElementById('deleteRiderModal')).show();
}

document.getElementById('deleteRiderConfirm').addEventListener('click', function() {
    if (!pendingDeleteRiderId) return;
    var btn = this;
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

    fetch(API_RIDERS + '/' + pendingDeleteRiderId, {
        method: 'DELETE',
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Accept': 'application/json' }
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        bootstrap.Modal.getInstance(document.getElementById('deleteRiderModal')).hide();
        showToast('success', 'Rider deleted successfully.');
        setTimeout(function() { location.reload(); }, 800);
    })
    .catch(function() {
        showToast('error', 'Failed to delete rider.');
    })
    .finally(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-trash me-1"></i> Delete';
    });
});

document.addEventListener('DOMContentLoaded', function() {
    MSM.initCounters();
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>