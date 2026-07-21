<?php
/**
 * Live Agent Tracking Map
 *
 * Real-time map showing all active delivery agents using
 * Leaflet.js + OpenStreetMap + Socket.IO.
 */

$currentPage = 'tracking';
$pageTitle   = 'Live Agent Tracking';

require_once __DIR__ . '/../../auth/auth_check.php';
require_once __DIR__ . '/../../api/auth_api.php';

$jwt = session_get_jwt();

include __DIR__ . '/../../includes/header.php';
include __DIR__ . '/../../includes/sidebar.php';
include __DIR__ . '/../../includes/loader.php';
?>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin="" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
<script src="https://cdn.socket.io/4.7.5/socket.io.min.js"></script>

<style>
    #trackingMap { width: 100%; height: calc(100vh - 180px); min-height: 500px; border-radius: var(--msm-radius); z-index: 1; }
    .tracking-sidebar { width: 320px; max-height: calc(100vh - 180px); overflow-y: auto; }
    .agent-card { padding: 0.75rem; border-radius: var(--msm-radius); background: var(--msm-bg); margin-bottom: 0.5rem; cursor: pointer; transition: all 0.2s; border: 2px solid transparent; }
    .agent-card:hover, .agent-card.active { border-color: var(--msm-primary); }
    .agent-card .agent-name { font-weight: 600; font-size: 0.85rem; }
    .agent-card .agent-meta { font-size: 0.75rem; color: var(--msm-muted); }
    .pulse-dot { width: 12px; height: 12px; border-radius: 50%; background: var(--msm-primary); position: relative; display: inline-block; }
    .pulse-dot::after { content: ''; position: absolute; inset: -4px; border-radius: 50%; border: 2px solid var(--msm-primary); animation: pulse-ring 1.5s ease-out infinite; }
    @keyframes pulse-ring { 0% { opacity: 1; transform: scale(1); } 100% { opacity: 0; transform: scale(2); } }
    .live-badge { display: inline-flex; align-items: center; gap: 4px; font-size: 0.7rem; font-weight: 600; color: #198754; }
    .live-badge::before { content: ''; width: 6px; height: 6px; border-radius: 50%; background: #198754; animation: pulse-dot-anim 1s infinite; }
    @keyframes pulse-dot-anim { 0%, 100% { opacity: 1; } 50% { opacity: 0.4; } }
    .agent-popup { font-family: 'Inter', sans-serif; }
    .agent-popup .popup-name { font-weight: 700; font-size: 0.9rem; margin-bottom: 4px; }
    .agent-popup .popup-meta { font-size: 0.78rem; color: #666; }
    .connection-indicator { position: fixed; bottom: 20px; right: 20px; z-index: 1000; padding: 8px 16px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
    .connection-indicator.connected { background: #d4edda; color: #155724; }
    .connection-indicator.disconnected { background: #f8d7da; color: #721c24; }
</style>

<div class="sidebar-overlay" id="sidebarOverlay" onclick="MSM.toggleSidebar()"></div>

<div class="admin-content">
    <div class="admin-navbar">
        <div class="navbar-left">
            <button class="btn btn-sm d-lg-none" onclick="MSM.toggleSidebar()" style="font-size:1.2rem;color:var(--msm-muted);">
                <i class="bi bi-list"></i>
            </button>
            <div class="navbar-brand-text"><span><?php echo $pageTitle; ?></span></div>
            <span class="live-badge ms-2" id="liveIndicator" style="display:none;">LIVE</span>
        </div>
        <div class="navbar-right">
            <button class="btn btn-sm btn-outline-secondary me-2" id="btnRefreshAgents" title="Refresh Agents">
                <i class="bi bi-arrow-clockwise"></i>
            </button>
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

    <div class="d-flex gap-3" style="height:calc(100vh - 130px);">
        <div class="tracking-sidebar d-none d-lg-block">
            <div class="msm-card p-3">
                <div class="d-flex align-items-center justify-content-between mb-3">
                    <h6 class="mb-0 fw-bold"><i class="bi bi-people me-2"></i>Active Agents</h6>
                    <span class="badge bg-success" id="agentCount">0</span>
                </div>
                <div id="agentList">
                    <div class="text-center py-4 text-muted">
                        <div class="spinner-border spinner-border-sm text-success"></div>
                        <p class="small mt-2 mb-0">Connecting...</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="flex-grow-1">
            <div id="trackingMap"></div>
        </div>
    </div>
</div>

<div class="connection-indicator disconnected" id="connectionStatus">
    <i class="bi bi-wifi-off me-1"></i> Disconnected
</div>

<script>
(function() {
    var JWT = '<?php echo addslashes($jwt); ?>';
    var API_URL = '<?php echo API_BACKEND_URL; ?>';
    var TRACKING_ACTIVE_URL = '<?php echo API_TRACKING_ACTIVE; ?>';

    var map = L.map('trackingMap', { zoomControl: false }).setView([4.0511, 9.7679], 13);
    L.control.zoom({ position: 'topright' }).addTo(map);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors',
        maxZoom: 19,
    }).addTo(map);

    var storeIcon = L.divIcon({
        html: '<div style="background:#198754;width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;border:3px solid white;box-shadow:0 2px 8px rgba(0,0,0,0.3);"><i class="bi bi-shop" style="color:white;font-size:14px;"></i></div>',
        iconSize: [28, 28],
        iconAnchor: [14, 14],
        className: ''
    });

    L.marker([4.0511, 9.7679], { icon: storeIcon }).addTo(map).bindPopup('<div class="agent-popup"><div class="popup-name">My SpiceMarket Store</div><div class="popup-meta">Central Hub - Douala</div></div>');

    var agentMarkers = {};
    var agentPaths = {};
    var agents = {};
    var selectedAgentId = null;

    function createAgentIcon(vehicleType, heading) {
        var color = vehicleType === 'Car' ? '#0d6efd' : vehicleType === 'Scooter' ? '#ffc107' : '#198754';
        var iconClass = vehicleType === 'Car' ? 'bi-car-front-fill' : vehicleType === 'Scooter' ? 'bi-scooter' : 'bi-bicycle';
        var rot = heading ? 'transform:rotate(' + heading + 'deg);' : '';
        return L.divIcon({
            html: '<div style="background:' + color + ';width:38px;height:38px;border-radius:50%;display:flex;align-items:center;justify-content:center;border:3px solid white;box-shadow:0 2px 8px rgba(0,0,0,0.35);' + rot + '"><i class="bi ' + iconClass + '" style="color:white;font-size:17px;"></i></div>',
            iconSize: [38, 38],
            iconAnchor: [19, 19],
            className: ''
        });
    }

    function updateAgentMarker(agent) {
        var id = agent._id;
        var pos = [agent.latitude, agent.longitude];
        var vehicle = (agent.agent && agent.agent.vehicleType) || 'Bike';
        var name = (agent.agent && agent.agent.fullName) || 'Agent';
        var phone = (agent.agent && agent.agent.phone) || '';
        var speed = agent.speed ? Math.round(agent.speed * 3.6) + ' km/h' : 'N/A';
        var eta = agent.estimatedArrival ? Math.round(agent.estimatedArrival / 60000) + ' min' : 'N/A';
        var dist = agent.remainingDistance ? (agent.remainingDistance > 1000 ? (agent.remainingDistance / 1000).toFixed(1) + ' km' : Math.round(agent.remainingDistance) + ' m') : 'N/A';
        var status = agent.status || '';
        var timeAgo = MSM.timeAgo(agent.timestamp);

        if (agentMarkers[id]) {
            agentMarkers[id].setLatLng(pos);
            agentMarkers[id].setIcon(createAgentIcon(vehicle, agent.heading));
        } else {
            var marker = L.marker(pos, { icon: createAgentIcon(vehicle, agent.heading) }).addTo(map);
            marker.bindPopup(
                '<div class="agent-popup">' +
                '<div class="popup-name">' + name + '</div>' +
                '<div class="popup-meta">' +
                '<i class="bi bi-telephone me-1"></i>' + phone + '<br>' +
                '<i class="bi bi-speedometer me-1"></i>' + speed + '<br>' +
                '<i class="bi bi-signpost-2 me-1"></i>' + dist + ' remaining<br>' +
                '<i class="bi bi-clock me-1"></i>ETA: ' + eta + '<br>' +
                '<span class="badge bg-primary" style="font-size:0.7rem;">' + status.replace(/_/g, ' ') + '</span>' +
                '</div></div>',
                { maxWidth: 240 }
            );
            marker.on('click', function() { selectAgent(id); });
            agentMarkers[id] = marker;
        }

        if (!agentPaths[id]) {
            agentPaths[id] = L.polyline([], { color: '#198754', weight: 3, opacity: 0.5, dashArray: '6,8' }).addTo(map);
        }
        var latlngs = agentPaths[id].getLatLngs();
        if (latlngs.length === 0 || latlngs[latlngs.length - 1].lat !== pos[0] || latlngs[latlngs.length - 1].lng !== pos[1]) {
            latlngs.push(L.latLng(pos[0], pos[1]));
            if (latlngs.length > 100) latlngs.shift();
            agentPaths[id].setLatLngs(latlngs);
        }

        agents[id] = agent;
    }

    function removeStaleAgents(activeIds) {
        Object.keys(agentMarkers).forEach(function(id) {
            if (activeIds.indexOf(id) === -1) {
                map.removeLayer(agentMarkers[id]);
                delete agentMarkers[id];
                if (agentPaths[id]) { map.removeLayer(agentPaths[id]); delete agentPaths[id]; }
                delete agents[id];
            }
        });
    }

    function renderAgentList() {
        var ids = Object.keys(agents);
        document.getElementById('agentCount').textContent = ids.length;

        if (ids.length === 0) {
            document.getElementById('agentList').innerHTML = '<div class="text-center py-4 text-muted"><i class="bi bi-geo-alt fs-2"></i><p class="small mt-2 mb-0">No active agents nearby</p></div>';
            return;
        }

        var html = '';
        ids.forEach(function(id) {
            var a = agents[id];
            var name = (a.agent && a.agent.fullName) || 'Agent';
            var vehicle = (a.agent && a.agent.vehicleType) || 'Bike';
            var phone = (a.agent && a.agent.phone) || '';
            var speed = a.speed ? Math.round(a.speed * 3.6) + ' km/h' : 'N/A';
            var eta = a.estimatedArrival ? Math.round(a.estimatedArrival / 60000) + ' min' : 'N/A';
            var status = (a.status || '').replace(/_/g, ' ');
            var colors = { 'Car': '#0d6efd', 'Scooter': '#ffc107', 'Bike': '#198754' };
            var color = colors[vehicle] || '#198754';
            var isActive = selectedAgentId === id;

            html += '<div class="agent-card' + (isActive ? ' active' : '') + '" data-id="' + id + '" onclick="window.TTracking.selectAgent(\'' + id + '\')">';
            html += '<div class="d-flex align-items-center gap-2">';
            html += '<div class="pulse-dot" style="background:' + color + ';"></div>';
            html += '<div class="flex-grow-1">';
            html += '<div class="agent-name">' + name + '</div>';
            html += '<div class="agent-meta"><i class="bi bi-telephone me-1"></i>' + phone + '</div>';
            html += '</div>';
            html += '<div class="text-end">';
            html += '<div class="badge bg-light text-dark" style="font-size:0.65rem;">' + vehicle + '</div>';
            html += '<div class="agent-meta mt-1">' + speed + '</div>';
            html += '</div>';
            html += '</div>';
            html += '<div class="d-flex justify-content-between align-items-center mt-2">';
            html += '<span class="badge bg-primary" style="font-size:0.65rem;">' + status + '</span>';
            html += '<span class="agent-meta"><i class="bi bi-clock me-1"></i>ETA ' + eta + '</span>';
            html += '</div>';
            html += '</div>';
        });
        document.getElementById('agentList').innerHTML = html;
    }

    window.TTracking = {
        selectAgent: function(id) {
            selectedAgentId = id;
            var agent = agents[id];
            if (agent && agentMarkers[id]) {
                map.setView([agent.latitude, agent.longitude], 16);
                agentMarkers[id].openPopup();
            }
            renderAgentList();
        }
    };

    function setConnected(connected) {
        var el = document.getElementById('connectionStatus');
        var live = document.getElementById('liveIndicator');
        if (connected) {
            el.className = 'connection-indicator connected';
            el.innerHTML = '<i class="bi bi-wifi me-1"></i> Connected';
            live.style.display = 'inline-flex';
        } else {
            el.className = 'connection-indicator disconnected';
            el.innerHTML = '<i class="bi bi-wifi-off me-1"></i> Disconnected';
            live.style.display = 'none';
        }
    }

    function loadActiveAgents() {
        fetch(TRACKING_ACTIVE_URL, {
            headers: { 'Accept': 'application/json', 'Authorization': 'Bearer ' + JWT }
        })
        .then(function(r) { return r.json(); })
        .then(function(data) {
            var activeIds = [];
            if (Array.isArray(data)) {
                data.forEach(function(agent) {
                    updateAgentMarker(agent);
                    activeIds.push(agent._id);
                });
                removeStaleAgents(activeIds);
                renderAgentList();

                if (activeIds.length > 0) {
                    var bounds = L.latLngBounds(data.map(function(a) { return [a.latitude, a.longitude]; }));
                    bounds.extend([4.0511, 9.7679]);
                    map.fitBounds(bounds, { padding: [50, 50], maxZoom: 15 });
                }
            }
        })
        .catch(function(err) {
            console.error('Failed to load active agents:', err);
        });
    }

    var socket = io(API_URL, {
        transports: ['websocket', 'polling'],
        reconnection: true,
        reconnectionDelay: 1000,
        auth: { token: JWT }
    });

    socket.on('connect', function() { setConnected(true); loadActiveAgents(); });
    socket.on('disconnect', function() { setConnected(false); });

    socket.on('location:updated', function(data) {
        if (data && data.latitude && data.longitude) {
            updateAgentMarker(data);
            renderAgentList();
        }
    });

    socket.on('agent:location', function(data) {
        if (data && data.latitude && data.longitude) {
            updateAgentMarker(data);
            renderAgentList();
        }
    });

    document.getElementById('btnRefreshAgents').addEventListener('click', function() { loadActiveAgents(); });

    loadActiveAgents();
    setInterval(loadActiveAgents, 30000);
})();
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
