<?php
/**
 * Agents Management Page
 *
 * CRUD management for both Delivery Agents and Preparation Agents.
 * Admin can register, edit, toggle status, and delete agents.
 */

$currentPage = 'agents';
$pageTitle   = 'Agents';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt = session_get_jwt();
$agentsData = api_request('GET', API_ADMIN_AGENTS, null, $jwt);
$agents     = $agentsData['body'] ?? [];

$deliveryCount = 0;
$prepCount     = 0;
$activeCount   = 0;

foreach ($agents as $a) {
    if (($a['role'] ?? '') === 'deliveryAgent') $deliveryCount++;
    if (($a['role'] ?? '') === 'preparationAgent') $prepCount++;
    $activeDel = $a['activeDeliveries'] ?? $a['activePrepOrders'] ?? 0;
    if ($activeDel > 0) $activeCount++;
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
                            <div class="stat-label">Total Agents</div>
                            <div class="stat-value" style="color:#0d6efd;" data-count="<?php echo count($agents); ?>"><?php echo count($agents); ?></div>
                        </div>
                        <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-people-fill"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#198754,#0d6e3f);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Delivery Agents</div>
                            <div class="stat-value" style="color:#198754;" data-count="<?php echo $deliveryCount; ?>"><?php echo $deliveryCount; ?></div>
                        </div>
                        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="bi bi-truck"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#ffc107,#e0a800);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Preparation Agents</div>
                            <div class="stat-value" style="color:#e0a800;" data-count="<?php echo $prepCount; ?>"><?php echo $prepCount; ?></div>
                        </div>
                        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-kitchen-set"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3 animate-in">
                <div class="stat-card">
                    <div class="stat-accent" style="background:linear-gradient(90deg,#0dcaf0,#0aa2c0);"></div>
                    <div class="d-flex align-items-center justify-content-between mt-1">
                        <div>
                            <div class="stat-label">Currently Active</div>
                            <div class="stat-value" style="color:#0aa2c0;" data-count="<?php echo $activeCount; ?>"><?php echo $activeCount; ?></div>
                        </div>
                        <div class="stat-icon bg-info bg-opacity-10 text-info"><i class="bi bi-lightning"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Agents Table -->
        <div class="msm-card animate-in">
            <div class="table-toolbar">
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <h6 class="mb-0 fw-bold">All Agents</h6>
                    <div class="d-flex gap-1">
                        <button class="table-filter-btn active" data-filter="all" onclick="filterAgents('all', this)">All</button>
                        <button class="table-filter-btn" data-filter="deliveryAgent" onclick="filterAgents('deliveryAgent', this)">Delivery</button>
                        <button class="table-filter-btn" data-filter="preparationAgent" onclick="filterAgents('preparationAgent', this)">Preparation</button>
                    </div>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <div class="input-group input-group-sm" style="width:220px;">
                        <span class="input-group-text bg-light border-end-0"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control border-start-0 bg-light" id="agentSearch" placeholder="Search agents..." oninput="searchAgents()">
                    </div>
                    <button class="btn btn-sm btn-msm" onclick="openAddAgentModal()">
                        <i class="bi bi-plus-lg me-1"></i> Add Agent
                    </button>
                </div>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0 msm-table">
                    <thead class="table-light">
                        <tr>
                            <th>Agent</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Role</th>
                            <th>Status</th>
                            <th>Active</th>
                            <th>Completed</th>
                            <th>Joined</th>
                            <th class="text-end">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="agentsTableBody">
                        <?php if (empty($agents)): ?>
                        <tr>
                            <td colspan="9">
                                <div class="empty-state py-4">
                                    <i class="bi bi-people-fill"></i>
                                    <p>No agents found. Add your first agent to get started.</p>
                                </div>
                            </td>
                        </tr>
                        <?php else: ?>
                        <?php foreach ($agents as $a): ?>
                        <?php
                            $aId       = $a['_id'] ?? $a['id'] ?? '';
                            $aName     = $a['fullName'] ?? 'Unknown';
                            $aEmail    = $a['email'] ?? '';
                            $aPhone    = $a['phone'] ?? 'N/A';
                            $aRole     = $a['role'] ?? 'deliveryAgent';
                            $aVerified = !empty($a['isVerified']);
                            $aJoined   = $a['createdAt'] ?? '';
                            $aActive   = $a['activeDeliveries'] ?? $a['activePrepOrders'] ?? 0;
                            $aCompleted = $a['completedDeliveries'] ?? $a['completedPrepOrders'] ?? 0;
                            $initials  = strtoupper(substr($aName, 0, 1));
                            $colors    = ['#198754','#0d6efd','#ffc107','#dc3545','#6f42c1','#0dcaf0'];
                            $colorIdx  = crc32($aId) % count($colors);
                            $isDelivery = $aRole === 'deliveryAgent';
                        ?>
                        <tr data-agent-id="<?php echo htmlspecialchars($aId); ?>" data-role="<?php echo $aRole; ?>">
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <?php if (!empty($a['profileImage'])): ?>
                                    <img src="<?php echo MSM_BACKEND_URL . '/' . ltrim($a['profileImage'], '/'); ?>" 
                                         alt="<?php echo htmlspecialchars($aName); ?>" 
                                         class="activity-avatar-placeholder" 
                                         style="width:36px;height:36px;object-fit:cover;"
                                         onerror="this.style.display='none';this.nextElementSibling.style.display='flex';">
                                    <div class="activity-avatar-placeholder" style="width:36px;height:36px;font-size:0.75rem;background:<?php echo $colors[$colorIdx]; ?>;display:none;">
                                        <?php echo $initials; ?>
                                    </div>
                                    <?php else: ?>
                                    <div class="activity-avatar-placeholder" style="width:36px;height:36px;font-size:0.75rem;background:<?php echo $colors[$colorIdx]; ?>;">
                                        <?php echo $initials; ?>
                                    </div>
                                    <?php endif; ?>
                                    <span class="fw-semibold" style="font-size:0.85rem;"><?php echo htmlspecialchars($aName); ?></span>
                                </div>
                            </td>
                            <td class="text-muted small"><?php echo htmlspecialchars($aEmail); ?></td>
                            <td class="text-muted small"><?php echo htmlspecialchars($aPhone); ?></td>
                            <td>
                                <span class="badge <?php echo $isDelivery ? 'bg-success' : 'bg-warning text-dark'; ?> badge-status">
                                    <i class="bi <?php echo $isDelivery ? 'bi-truck' : 'bi-kitchen-set'; ?> me-1"></i>
                                    <?php echo $isDelivery ? 'Delivery' : 'Preparation'; ?>
                                </span>
                            </td>
                            <td>
                                <span class="badge <?php echo $aVerified ? 'bg-success' : 'bg-secondary'; ?> badge-status">
                                    <?php echo $aVerified ? 'Active' : 'Inactive'; ?>
                                </span>
                            </td>
                            <td><span class="fw-semibold"><?php echo $aActive; ?></span></td>
                            <td><span class="fw-semibold"><?php echo $aCompleted; ?></span></td>
                            <td class="text-muted small"><?php echo $aJoined ? date('d M Y', strtotime($aJoined)) : 'N/A'; ?></td>
                            <td class="text-end">
                                <div class="d-flex gap-1 justify-content-end">
                                    <button class="btn btn-sm btn-outline-primary" onclick="editAgent('<?php echo htmlspecialchars($aId); ?>')" title="Edit">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                    <button class="btn btn-sm <?php echo $aVerified ? 'btn-outline-warning' : 'btn-outline-success'; ?>" onclick="toggleAgentStatus('<?php echo htmlspecialchars($aId); ?>', <?php echo $aVerified ? 'true' : 'false'; ?>)" title="<?php echo $aVerified ? 'Deactivate' : 'Activate'; ?>">
                                        <i class="bi <?php echo $aVerified ? 'bi-pause-circle' : 'bi-play-circle'; ?>"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger" onclick="deleteAgent('<?php echo htmlspecialchars($aId); ?>', '<?php echo htmlspecialchars(addslashes($aName)); ?>')" title="Delete">
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
                <div class="text-muted small" id="agentCount"><?php echo count($agents); ?> agent(s)</div>
            </div>
        </div>
    </div>
</div>

<!-- Add Agent Modal -->
<div class="modal fade" id="addAgentModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-header border-0">
                <h6 class="modal-title fw-bold"><i class="bi bi-person-plus text-success me-2"></i>Register New Agent</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body pt-0">
                <form id="addAgentForm" onsubmit="submitAddAgent(event)">
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Agent Type *</label>
                        <select class="form-select" id="addAgentRole" required onchange="onRoleChange(this.value)">
                            <option value="">Select type...</option>
                            <option value="deliveryAgent">Delivery Agent</option>
                            <option value="preparationAgent">Preparation Agent</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Full Name *</label>
                        <input type="text" class="form-control" id="addAgentName" required placeholder="e.g. Paul Nji" minlength="2">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Email Address *</label>
                        <input type="email" class="form-control" id="addAgentEmail" required placeholder="agent@example.com">
                    </div>
                    <div class="row g-3">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold small">Phone Number *</label>
                            <input type="tel" class="form-control" id="addAgentPhone" required placeholder="+237 6XX XXX XXX">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold small">Password *</label>
                            <input type="password" class="form-control" id="addAgentPassword" required placeholder="Min 6 characters" minlength="6">
                        </div>
                    </div>
                    <div id="roleDescription" class="alert alert-light small mb-3" style="display:none;border:1px dashed #dee2e6;"></div>
                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-sm btn-msm" id="addAgentBtn">
                            <i class="bi bi-check-lg me-1"></i> Register Agent
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Edit Agent Modal -->
<div class="modal fade" id="editAgentModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-header border-0">
                <h6 class="modal-title fw-bold"><i class="bi bi-pencil-square text-primary me-2"></i>Edit Agent</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body pt-0">
                <form id="editAgentForm" onsubmit="submitEditAgent(event)">
                    <input type="hidden" id="editAgentId">
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Agent Type</label>
                        <select class="form-select" id="editAgentRole" disabled>
                            <option value="deliveryAgent">Delivery Agent</option>
                            <option value="preparationAgent">Preparation Agent</option>
                        </select>
                        <div class="form-text">Agent type cannot be changed after creation.</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Full Name</label>
                        <input type="text" class="form-control" id="editAgentName" required minlength="2">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-semibold small">Email Address</label>
                        <input type="email" class="form-control" id="editAgentEmail" required>
                    </div>
                    <div class="row g-3">
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold small">Phone Number</label>
                            <input type="tel" class="form-control" id="editAgentPhone">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label fw-semibold small">New Password <small class="text-muted">(leave blank to keep)</small></label>
                            <input type="password" class="form-control" id="editAgentPassword" placeholder="Min 6 characters" minlength="6">
                        </div>
                    </div>
                    <div class="d-flex justify-content-end gap-2 mt-4">
                        <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-sm btn-msm" id="editAgentBtn">
                            <i class="bi bi-check-lg me-1"></i> Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Toggle Status Modal -->
<div class="modal fade" id="toggleAgentStatusModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-body text-center p-4">
                <div class="mb-3" id="toggleAgentStatusIcon"></div>
                <h6 class="fw-bold" id="toggleAgentStatusTitle"></h6>
                <p class="text-muted small mb-0" id="toggleAgentStatusMsg"></p>
            </div>
            <div class="modal-footer border-0 pt-0 justify-content-center">
                <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-sm btn-msm" id="toggleAgentStatusConfirm">Confirm</button>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteAgentModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--msm-radius);border:none;">
            <div class="modal-body text-center p-4">
                <div class="bg-danger bg-opacity-10 text-danger d-inline-flex align-items-center justify-content-center mb-3" style="width:56px;height:56px;border-radius:50%;font-size:1.5rem;">
                    <i class="bi bi-trash"></i>
                </div>
                <h6 class="fw-bold">Delete Agent?</h6>
                <p class="text-muted small mb-0">This will permanently remove <strong id="deleteAgentName"></strong> from the system.</p>
            </div>
            <div class="modal-footer border-0 pt-0 justify-content-center">
                <button type="button" class="btn btn-sm btn-light" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-sm btn-danger" id="deleteAgentConfirm">
                    <i class="bi bi-trash me-1"></i> Delete
                </button>
            </div>
        </div>
    </div>
</div>

<script>
var MSM_JWT = '<?php echo $jwt; ?>';
var AGENTS_RAW = <?php echo json_encode($agents); ?>;
var API_AGENTS = '<?php echo API_ADMIN_AGENTS; ?>';
var currentFilter = 'all';

function onRoleChange(val) {
    var el = document.getElementById('roleDescription');
    if (val === 'deliveryAgent') {
        el.style.display = 'block';
        el.innerHTML = '<i class="bi bi-truck text-success me-1"></i> <strong>Delivery Agent</strong> &mdash; Handles order delivery to customers, communicates via chat/call during the delivery phase.';
    } else if (val === 'preparationAgent') {
        el.style.display = 'block';
        el.innerHTML = '<i class="bi bi-kitchen-set text-warning me-1"></i> <strong>Preparation Agent</strong> &mdash; Prepares spice orders in the kitchen, communicates via chat/call during the preparation phase.';
    } else {
        el.style.display = 'none';
    }
}

function getFilteredAgents() {
    var search = (document.getElementById('agentSearch').value || '').toLowerCase();
    return AGENTS_RAW.filter(function(a) {
        var matchSearch = !search ||
            (a.fullName || '').toLowerCase().indexOf(search) > -1 ||
            (a.email || '').toLowerCase().indexOf(search) > -1 ||
            (a.phone || '').toLowerCase().indexOf(search) > -1;
        var matchFilter = currentFilter === 'all' || a.role === currentFilter;
        return matchSearch && matchFilter;
    });
}

function renderAgentTable(agents) {
    var tbody = document.getElementById('agentsTableBody');
    var colors = ['#198754','#0d6efd','#ffc107','#dc3545','#6f42c1','#0dcaf0'];
    if (!agents.length) {
        tbody.innerHTML = '<tr><td colspan="9"><div class="empty-state py-4"><i class="bi bi-people-fill"></i><p>No agents match your criteria.</p></div></td></tr>';
        document.getElementById('agentCount').textContent = '0 agent(s)';
        return;
    }
    var html = '';
    agents.forEach(function(a) {
        var id = a._id || a.id || '';
        var name = a.fullName || 'Unknown';
        var email = a.email || '';
        var phone = a.phone || 'N/A';
        var role = a.role || 'deliveryAgent';
        var verified = !!a.isVerified;
        var joined = a.createdAt ? new Date(a.createdAt).toLocaleDateString('en-GB',{day:'2-digit',month:'short',year:'numeric'}) : 'N/A';
        var active = a.activeDeliveries || a.activePrepOrders || 0;
        var completed = a.completedDeliveries || a.completedPrepOrders || 0;
        var isDelivery = role === 'deliveryAgent';
        var initial = name.charAt(0).toUpperCase();
        var colorIdx = 0;
        for (var i = 0; i < id.length; i++) colorIdx += id.charCodeAt(i);
        colorIdx = colorIdx % colors.length;

        html += '<tr data-agent-id="' + id + '" data-role="' + role + '">';
        html += '<td><div class="d-flex align-items-center gap-2">';
        html += '<div class="activity-avatar-placeholder" style="width:36px;height:36px;font-size:0.75rem;background:' + colors[colorIdx] + ';">' + initial + '</div>';
        html += '<span class="fw-semibold" style="font-size:0.85rem;">' + MSM.truncate(name, 30) + '</span></div></td>';
        html += '<td class="text-muted small">' + MSM.truncate(email, 28) + '</td>';
        html += '<td class="text-muted small">' + phone + '</td>';
        html += '<td><span class="badge ' + (isDelivery ? 'bg-success' : 'bg-warning text-dark') + ' badge-status"><i class="bi ' + (isDelivery ? 'bi-truck' : 'bi-kitchen-set') + ' me-1"></i>' + (isDelivery ? 'Delivery' : 'Preparation') + '</span></td>';
        html += '<td><span class="badge ' + (verified ? 'bg-success' : 'bg-secondary') + ' badge-status">' + (verified ? 'Active' : 'Inactive') + '</span></td>';
        html += '<td><span class="fw-semibold">' + active + '</span></td>';
        html += '<td><span class="fw-semibold">' + completed + '</span></td>';
        html += '<td class="text-muted small">' + joined + '</td>';
        html += '<td class="text-end"><div class="d-flex gap-1 justify-content-end">';
        html += '<button class="btn btn-sm btn-outline-primary" onclick="editAgent(\'' + id + '\')" title="Edit"><i class="bi bi-pencil"></i></button>';
        html += '<button class="btn btn-sm ' + (verified ? 'btn-outline-warning' : 'btn-outline-success') + '" onclick="toggleAgentStatus(\'' + id + '\', ' + verified + ')" title="' + (verified ? 'Deactivate' : 'Activate') + '"><i class="bi ' + (verified ? 'bi-pause-circle' : 'bi-play-circle') + '"></i></button>';
        html += '<button class="btn btn-sm btn-outline-danger" onclick="deleteAgent(\'' + id + '\', \'' + name.replace(/'/g, "\\'") + '\')" title="Delete"><i class="bi bi-trash"></i></button>';
        html += '</div></td></tr>';
    });
    tbody.innerHTML = html;
    document.getElementById('agentCount').textContent = agents.length + ' agent(s)';
}

function filterAgents(filter, btn) {
    currentFilter = filter;
    document.querySelectorAll('.table-filter-btn').forEach(function(b) { b.classList.remove('active'); });
    btn.classList.add('active');
    renderAgentTable(getFilteredAgents());
}

var searchTimer = null;
function searchAgents() {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(function() { renderAgentTable(getFilteredAgents()); }, 250);
}

function openAddAgentModal() {
    document.getElementById('addAgentForm').reset();
    document.getElementById('roleDescription').style.display = 'none';
    new bootstrap.Modal(document.getElementById('addAgentModal')).show();
}

function submitAddAgent(e) {
    e.preventDefault();
    var role     = document.getElementById('addAgentRole').value;
    var name     = document.getElementById('addAgentName').value.trim();
    var email    = document.getElementById('addAgentEmail').value.trim();
    var phone    = document.getElementById('addAgentPhone').value.trim();
    var password = document.getElementById('addAgentPassword').value;

    if (!role) { showToast('error', 'Please select an agent type.'); return; }
    if (password.length < 6) { showToast('error', 'Password must be at least 6 characters.'); return; }

    var btn = document.getElementById('addAgentBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

    fetch(API_AGENTS, {
        method: 'POST',
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ fullName: name, email: email, phone: phone, password: password, role: role })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        if (res._id || (res.message && res.message.toLowerCase().indexOf('already') > -1)) {
            if (res._id) {
                bootstrap.Modal.getInstance(document.getElementById('addAgentModal')).hide();
                showToast('success', 'Agent registered successfully.');
                setTimeout(function() { location.reload(); }, 800);
            } else {
                showToast('error', res.message || 'Failed to register agent.');
            }
        } else {
            showToast('error', res.message || 'Failed to register agent.');
        }
    })
    .catch(function() {
        showToast('error', 'Network error. Please try again.');
    })
    .finally(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-check-lg me-1"></i> Register Agent';
    });
}

function editAgent(id) {
    var agent = AGENTS_RAW.find(function(a) { return (a._id || a.id) === id; });
    if (!agent) return;
    document.getElementById('editAgentId').value = id;
    document.getElementById('editAgentRole').value = agent.role || 'deliveryAgent';
    document.getElementById('editAgentName').value = agent.fullName || '';
    document.getElementById('editAgentEmail').value = agent.email || '';
    document.getElementById('editAgentPhone').value = agent.phone || '';
    document.getElementById('editAgentPassword').value = '';
    new bootstrap.Modal(document.getElementById('editAgentModal')).show();
}

function submitEditAgent(e) {
    e.preventDefault();
    var id       = document.getElementById('editAgentId').value;
    var name     = document.getElementById('editAgentName').value.trim();
    var email    = document.getElementById('editAgentEmail').value.trim();
    var phone    = document.getElementById('editAgentPhone').value.trim();
    var password = document.getElementById('editAgentPassword').value;

    var body = { fullName: name, email: email, phone: phone };
    if (password && password.length >= 6) body.password = password;

    var btn = document.getElementById('editAgentBtn');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

    fetch(API_AGENTS + '/' + id, {
        method: 'PUT',
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify(body)
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        bootstrap.Modal.getInstance(document.getElementById('editAgentModal')).hide();
        showToast('success', 'Agent updated successfully.');
        setTimeout(function() { location.reload(); }, 800);
    })
    .catch(function() {
        showToast('error', 'Failed to update agent.');
    })
    .finally(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-check-lg me-1"></i> Save Changes';
    });
}

var pendingToggleAgentId = null;
function toggleAgentStatus(id, isVerified) {
    pendingToggleAgentId = id;
    var modal = new bootstrap.Modal(document.getElementById('toggleAgentStatusModal'));
    var iconEl = document.getElementById('toggleAgentStatusIcon');
    var titleEl = document.getElementById('toggleAgentStatusTitle');
    var msgEl = document.getElementById('toggleAgentStatusMsg');
    var confirmBtn = document.getElementById('toggleAgentStatusConfirm');

    if (isVerified) {
        iconEl.innerHTML = '<div class="bg-warning bg-opacity-10 text-warning d-inline-flex align-items-center justify-content-center" style="width:56px;height:56px;border-radius:50%;font-size:1.5rem;"><i class="bi bi-pause-circle"></i></div>';
        titleEl.textContent = 'Deactivate Agent?';
        msgEl.textContent = 'This agent will not be able to log in or receive new tasks.';
        confirmBtn.className = 'btn btn-sm btn-warning';
    } else {
        iconEl.innerHTML = '<div class="bg-success bg-opacity-10 text-success d-inline-flex align-items-center justify-content-center" style="width:56px;height:56px;border-radius:50%;font-size:1.5rem;"><i class="bi bi-play-circle"></i></div>';
        titleEl.textContent = 'Activate Agent?';
        msgEl.textContent = 'This agent will regain full access to their account.';
        confirmBtn.className = 'btn btn-sm btn-msm';
    }
    modal.show();
}

document.getElementById('toggleAgentStatusConfirm').addEventListener('click', function() {
    if (!pendingToggleAgentId) return;
    var btn = this;
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

    fetch(API_AGENTS + '/' + pendingToggleAgentId, {
        method: 'PUT',
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ isVerified: !AGENTS_RAW.find(function(a) { return (a._id || a.id) === pendingToggleAgentId; }).isVerified })
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        bootstrap.Modal.getInstance(document.getElementById('toggleAgentStatusModal')).hide();
        showToast('success', 'Agent status updated.');
        setTimeout(function() { location.reload(); }, 800);
    })
    .catch(function() {
        showToast('error', 'Failed to update status.');
    })
    .finally(function() {
        btn.disabled = false;
        btn.textContent = 'Confirm';
    });
});

var pendingDeleteAgentId = null;
function deleteAgent(id, name) {
    pendingDeleteAgentId = id;
    document.getElementById('deleteAgentName').textContent = name;
    new bootstrap.Modal(document.getElementById('deleteAgentModal')).show();
}

document.getElementById('deleteAgentConfirm').addEventListener('click', function() {
    if (!pendingDeleteAgentId) return;
    var btn = this;
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

    fetch(API_AGENTS + '/' + pendingDeleteAgentId, {
        method: 'DELETE',
        headers: { 'Authorization': 'Bearer ' + MSM_JWT, 'Accept': 'application/json' }
    })
    .then(function(r) { return r.json(); })
    .then(function(res) {
        bootstrap.Modal.getInstance(document.getElementById('deleteAgentModal')).hide();
        showToast('success', 'Agent deleted successfully.');
        setTimeout(function() { location.reload(); }, 800);
    })
    .catch(function() {
        showToast('error', 'Failed to delete agent.');
    })
    .finally(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="bi bi-trash me-1"></i> Delete';
    });
});

document.addEventListener('DOMContentLoaded', function() {
    MSM.initCounters();
    renderAgentTable(AGENTS_RAW);
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>