<?php
/**
 * Administrator Management Page
 *
 * CRUD management for admin users: add, edit, delete admins.
 * Includes role-based badges and self-deletion protection.
 */

$currentPage = 'admins';
$pageTitle   = 'Administrators';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt = session_get_jwt();
$adminsData  = api_request('GET', API_ADMIN_ADMINS, null, $jwt);
$admins      = $adminsData['body']['admins'] ?? $adminsData['body'] ?? [];
$totalAdmins = $adminsData['body']['total'] ?? count($admins);
$superAdmins = 0;
$recentAdditions = 0;
$now = new DateTime();
$currentAdminId = $admin['id'] ?? $admin['_id'] ?? '';

foreach ($admins as $a) {
    if (($a['role'] ?? '') === 'super_admin') $superAdmins++;
    $createdAt = $a['createdAt'] ?? null;
    if ($createdAt) {
        $created = new DateTime($createdAt);
        $diff = $now->diff($created);
        if ($diff->days < 7) $recentAdditions++;
    }
}

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
                            <div class="stat-label">Total Admins</div>
                            <div class="stat-value" style="color:#0d6efd;" data-count="<?php echo $totalAdmins; ?>"><?php echo $totalAdmins; ?></div>
                        </div>
                        <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-shield-lock"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#ffc107,#e0a800);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Super Admins</div>
                            <div class="stat-value" style="color:#e0a800;" data-count="<?php echo $superAdmins; ?>"><?php echo $superAdmins; ?></div>
                        </div>
                        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-shield-check"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#198754,#0d6e3f);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Recent Additions</div>
                            <div class="stat-value" style="color:#198754;" data-count="<?php echo $recentAdditions; ?>"><?php echo $recentAdditions; ?></div>
                            <div class="stat-change up"><i class="bi bi-clock"></i> last 7 days</div>
                        </div>
                        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="bi bi-person-plus"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#0dcaf0,#0aa2c0);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Your Role</div>
                            <div class="stat-value" style="color:#0aa2c0;font-size:1.1rem;"><?php echo ucfirst(str_replace('_', ' ', $admin['role'] ?? 'admin')); ?></div>
                        </div>
                        <div class="stat-icon bg-info bg-opacity-10 text-info"><i class="bi bi-person-badge"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Admins Table -->
        <div class="msm-card animate-in">
            <div class="table-toolbar">
                <h6 class="mb-0 fw-bold">All Administrators</h6>
                <button class="btn btn-sm btn-msm" onclick="openAddAdminModal()">
                    <i class="bi bi-plus-lg me-1"></i> Add Admin
                </button>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0 msm-table">
                    <thead class="table-light">
                        <tr>
                            <th>Admin</th>
                            <th>Email</th>
                            <th>Role</th>
                            <th>Joined</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="adminsTableBody">
                        <?php if (empty($admins)): ?>
                        <tr>
                            <td colspan="5">
                                <div class="empty-state py-4">
                                    <i class="bi bi-shield-lock"></i>
                                    <p>No administrators found.</p>
                                </div>
                            </td>
                        </tr>
                        <?php else: ?>
                        <?php foreach ($admins as $a): ?>
                        <?php
                            $aId    = $a['_id'] ?? $a['id'] ?? '';
                            $aName  = $a['fullName'] ?? 'Unknown';
                            $aEmail = $a['email'] ?? '';
                            $aRole  = $a['role'] ?? 'admin';
                            $aJoined = $a['createdAt'] ?? '';
                            $isSuperAdmin = $aRole === 'super_admin';
                            $isSelf = ($aId === $admin['_id'] ?? '') || ($aId === $admin['id'] ?? '');
                            $initials = strtoupper(substr($aName, 0, 1));
                            $colors = ['#6f42c1','#dc3545','#0d6efd','#ffc107','#198754'];
                            $colorIdx = crc32($aId) % count($colors);
                        ?>
                        <tr data-admin-id="<?php echo htmlspecialchars($aId); ?>">
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="activity-avatar-placeholder" style="width:36px;height:36px;font-size:0.75rem;background:<?php echo $colors[$colorIdx]; ?>;">
                                        <?php echo $initials; ?>
                                    </div>
                                    <div>
                                        <span class="fw-semibold" style="font-size:0.85rem;"><?php echo htmlspecialchars($aName); ?></span>
                                        <?php if ($isSelf): ?>
                                            <span class="badge bg-info bg-opacity-10 text-info ms-1" style="font-size:0.6rem;">You</span>
                                        <?php endif; ?>
                                    </div>
                                </div>
                            </td>
                            <td class="text-muted small"><?php echo htmlspecialchars($aEmail); ?></td>
                            <td>
                                <span class="badge <?php echo $isSuperAdmin ? 'bg-warning text-dark' : 'bg-primary'; ?> badge-status">
                                    <?php echo $isSuperAdmin ? 'Super Admin' : 'Admin'; ?>
                                </span>
                            </td>
                            <td class="text-muted small"><?php echo $aJoined ? date('d M Y', strtotime($aJoined)) : 'N/A'; ?></td>
                            <td class="text-end">
                                <div class="d-flex gap-1 justify-content-end">
                                    <button class="btn btn-sm btn-outline-primary" onclick="editAdmin('<?php echo htmlspecialchars($aId); ?>')" title="Edit">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                    <?php if (!$isSelf): ?>
                                    <button class="btn btn-sm btn-outline-danger" onclick="deleteAdmin('<?php echo htmlspecialchars($aId); ?>', '<?php echo htmlspecialchars(addslashes($aName)); ?>')" title="Delete">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                    <?php else: ?>
                                    <button class="btn btn-sm btn-outline-secondary" disabled title="Cannot delete yourself">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                    <?php endif; ?>
                                </div>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Add Admin Modal -->
<div class="modal fade" id="addAdminModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-header border-0">
                <h6 class="modal-title fw-bold"><i class="bi bi-person-plus text-success me-2"></i>Add New Admin</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body pt-0">
                <form id="addAdminForm" onsubmit="submitAddAdmin(event)">
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Full Name</label>
                        <input type="text" class="form-control" id="addFullName" required placeholder="e.g. John Doe" minlength="2">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Email Address</label>
                        <input type="email" class="form-control" id="addEmail" required placeholder="admin@example.com">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Password</label>
                        <input type="password" class="form-control" id="addPassword" required placeholder="Min 6 characters" minlength="6">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Confirm Password</label>
                        <input type="password" class="form-control" id="addConfirmPassword" required placeholder="Re-enter password" minlength="6">
                    </div>
                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-sm btn-msm" id="addAdminBtn">
                            <i class="bi bi-check-lg me-1"></i> Create Admin
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Edit Admin Modal -->
<div class="modal fade" id="editAdminModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-header border-0">
                <h6 class="modal-title fw-bold"><i class="bi bi-pencil-square text-primary me-2"></i>Edit Admin</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body pt-0">
                <form id="editAdminForm" onsubmit="submitEditAdmin(event)">
                    <input type="hidden" id="editAdminId">
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Full Name</label>
                        <input type="text" class="form-control" id="editFullName" required minlength="2">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Email Address</label>
                        <input type="email" class="form-control" id="editEmail" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Role</label>
                        <select class="form-select" id="editRole">
                            <option value="admin">Admin</option>
                            <option value="super_admin">Super Admin</option>
                        </select>
                    </div>
                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-sm btn-msm" id="editAdminBtn">
                            <i class="bi bi-check-lg me-1"></i> Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteAdminModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-body text-center p-4">
                <div class="bg-danger bg-opacity-10 text-danger d-inline-flex align-items-center justify-content-center mb-3" style="width:56px;height:56px;border-radius:50%;font-size:1.5rem;">
                    <i class="bi bi-trash"></i>
                </div>
                <h6 class="fw-bold">Delete Admin?</h6>
                <p class="text-muted small mb-0">This will permanently remove <strong id="deleteAdminName"></strong> from the admin panel.</p>
            </div>
            <div class="modal-footer border-0 pt-0 justify-content-center">
                <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-sm btn-danger" id="deleteAdminConfirm">
                    <i class="bi bi-trash me-1"></i> Delete
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var MSM_JWT = '<?php echo $jwt; ?>';
var ADMINS_RAW = <?php echo json_encode($admins); ?>;
var API_ADMINS = '<?php echo API_ADMIN_ADMINS; ?>';
var CURRENT_ADMIN_ID = '<?php echo htmlspecialchars($admin['_id'] ?? $admin['id'] ?? ''); ?>';
var pendingDeleteId = null;

function openAddAdminModal() {
    document.getElementById('addAdminForm').reset();
    new bootstrap.Modal(document.getElementById('addAdminModal')).show();
}

function submitAddAdmin(e) {
    e.preventDefault();
    var name = document.getElementById('addFullName').value.trim();
    var email = document.getElementById('addEmail').value.trim();
    var password = document.getElementById('addPassword').value;
    var confirm = document.getElementById('addConfirmPassword').value;

    if (password !== confirm) {
        showToast('error', 'Passwords do not match.');
        return;
    }
    if (password.length < 6) {
        showToast('error', 'Password must be at least 6 characters.');
        return;
    }

    var btn = document.getElementById('addAdminBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

    fetch(API_ADMINS, {
        method: 'POST',
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ fullName: name, email: email, password: password })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        if (res.message && res.message.toLowerCase().indexOf('created') > -1 || res._id || res.admin) {
            bootstrap.Modal.getInstance(document.getElementById('addAdminModal')).hide();
            showToast('success', 'Admin created successfully.');
            setTimeout(function() { location.reload(); }, 800);
        } else {
            showToast('error', res.message || 'Failed to create admin.');
        }
    })
    .catch(function() {
        showToast('error', 'Network error. Please try again.');
    })
    .finally(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-check-lg me-1"></i> Create Admin';
    });
}

function editAdmin(id) {
    var admin = ADMINS_RAW.find(function(a) { return (a._id || a.id) === id; });
    if (!admin) return;
    document.getElementById('editAdminId').value = id;
    document.getElementById('editFullName').value = admin.fullName || '';
    document.getElementById('editEmail').value = admin.email || '';
    document.getElementById('editRole').value = admin.role || 'admin';
    new bootstrap.Modal(document.getElementById('editAdminModal')).show();
}

function submitEditAdmin(e) {
    e.preventDefault();
    var id = document.getElementById('editAdminId').value;
    var name = document.getElementById('editFullName').value.trim();
    var email = document.getElementById('editEmail').value.trim();
    var role = document.getElementById('editRole').value;

    var btn = document.getElementById('editAdminBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

    fetch(API_ADMINS + '/' + id, {
        method: 'PUT',
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ fullName: name, email: email, role: role })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        bootstrap.Modal.getInstance(document.getElementById('editAdminModal')).hide();
        showToast('success', 'Admin updated successfully.');
        setTimeout(function() { location.reload(); }, 800);
    })
    .catch(function() {
        showToast('error', 'Failed to update admin.');
    })
    .finally(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-check-lg me-1"></i> Save Changes';
    });
}

function deleteAdmin(id, name) {
    pendingDeleteId = id;
    document.getElementById('deleteAdminName').textContent = name;
    new bootstrap.Modal(document.getElementById('deleteAdminModal')).show();
}

document.getElementById('deleteAdminConfirm').addEventListener('click', function() {
    if (!pendingDeleteId) return;
    var btn = this;
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

    fetch(API_ADMINS + '/' + pendingDeleteId, {
        method: 'DELETE',
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Accept': 'application/json' }
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        bootstrap.Modal.getInstance(document.getElementById('deleteAdminModal')).hide();
        showToast('success', 'Admin deleted successfully.');
        setTimeout(function() { location.reload(); }, 800);
    })
    .catch(function() {
        showToast('error', 'Failed to delete admin.');
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