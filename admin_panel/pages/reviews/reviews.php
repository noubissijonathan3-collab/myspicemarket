<?php
$currentPage = 'reviews';
$pageTitle   = 'Reviews';

require_once __DIR__ . '/../../auth/auth_check.php';

include __DIR__ . '/../../includes/header.php';
include __DIR__ . '/../../includes/sidebar.php';
include __DIR__ . '/../../includes/loader.php';
?>
<!-- Sidebar Overlay -->
<div class="sidebar-overlay" id="sidebarOverlay" onclick="MSM.toggleSidebar()"></div>

<div class="admin-content">
    <div class="admin-navbar">
        <div class="navbar-left">
            <button class="btn btn-sm d-lg-none" onclick="MSM.toggleSidebar()" style="font-size:1.2rem;color:var(--msm-muted);">
                <i class="bi bi-list"></i>
            </button>
            <div class="navbar-brand-text"><span>Reviews</span></div>
        </div>
        <div class="navbar-search d-none d-md-block">
            <i class="bi bi-search search-icon"></i>
            <input type="text" class="form-control" id="globalSearch" placeholder="Search meals, customers, orders..." autocomplete="off">
            <span class="search-kbd">Ctrl+K</span>
            <div class="search-results-dropdown" id="searchResults"></div>
        </div>
        <div class="navbar-right">
            <div style="position:relative;">
                <button class="navbar-icon-btn" onclick="MSM.toggleDropdown('notifDropdown')">
                    <i class="bi bi-bell"></i>
                </button>
                <div class="notification-dropdown" id="notifDropdown">
                    <div class="notif-header">
                        <h6>Notifications</h6>
                        <a href="<?php echo admin_url('pages/notifications/notifications.php'); ?>" class="text-decoration-none small">View All</a>
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
                    <a href="<?php echo admin_url('pages/profile/profile.php'); ?>"><i class="bi bi-person"></i> Profile</a>
                    <a href="<?php echo admin_url('pages/settings/settings.php'); ?>"><i class="bi bi-gear"></i> Settings</a>
                    <div class="dropdown-divider"></div>
                    <a href="<?php echo admin_url('auth/logout.php'); ?>" class="logout-link"><i class="bi bi-box-arrow-right"></i> Logout</a>
                </div>
            </div>
        </div>
    </div>

    <div class="welcome-section animate-in">
        <h3><i class="bi bi-star text-warning me-2"></i>Reviews Management</h3>
        <p>View and moderate customer reviews across all meals.</p>
    </div>

    <div class="row g-3 mb-4" id="reviewStatsContainer">
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#0d6efd,#0b5ed7);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Total Reviews</div>
                        <div class="stat-value" style="color:#0d6efd;" id="statTotalReviews">0</div>
                    </div>
                    <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-chat-quote"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#ffc107,#e0a800);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Average Rating</div>
                        <div class="stat-value" style="color:#e0a800;" id="statAvgRating">0</div>
                        <div class="stat-change"><span id="statAvgStars"></span></div>
                    </div>
                    <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-star-half"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#198754,#0d6e3f);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">5-Star Reviews</div>
                        <div class="stat-value" style="color:#198754;" id="statFiveStar">0</div>
                    </div>
                    <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="bi bi-star-fill"></i></div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3 animate-in">
            <div class="stat-card">
                <div class="stat-accent" style="background:linear-gradient(90deg,#0dcaf0,#0aa2c0);"></div>
                <div class="d-flex align-items-center justify-content-between mt-1">
                    <div>
                        <div class="stat-label">Reviews This Week</div>
                        <div class="stat-value" style="color:#0dcaf0;" id="statThisWeek">0</div>
                    </div>
                    <div class="stat-icon bg-info bg-opacity-10 text-info"><i class="bi bi-calendar-week"></i></div>
                </div>
            </div>
        </div>
    </div>

    <div class="msm-card">
        <div class="table-toolbar">
            <h6 class="mb-0 fw-bold">All Reviews</h6>
            <div class="d-flex align-items-center gap-2 flex-wrap">
                <select class="form-select form-select-sm" id="filterRating" style="width:130px;" onchange="loadReviews()">
                    <option value="">All Ratings</option>
                    <option value="5">5 Stars</option>
                    <option value="4">4 Stars</option>
                    <option value="3">3 Stars</option>
                    <option value="2">2 Stars</option>
                    <option value="1">1 Star</option>
                </select>
            </div>
        </div>
        <div class="table-responsive">
            <table class="table msm-table align-middle mb-0" id="reviewsTable">
                <thead class="table-light">
                    <tr>
                        <th style="width:32px;"></th>
                        <th>User</th>
                        <th>Meal</th>
                        <th>Rating</th>
                        <th>Comment</th>
                        <th>Verified</th>
                        <th>Date</th>
                        <th style="width:100px;">Actions</th>
                    </tr>
                </thead>
                <tbody id="reviewsTableBody">
                    <tr>
                        <td colspan="8">
                            <div class="empty-state py-5">
                                <div class="spinner-border text-success mb-3" role="status"></div>
                                <p>Loading reviews...</p>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="modal fade" id="viewReviewModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="bi bi-star text-warning me-2"></i>Review Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="viewReviewModalBody">
                <div class="text-center py-4"><div class="spinner-border text-success"></div></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="deleteReviewModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title text-danger"><i class="bi bi-exclamation-triangle me-2"></i>Delete Review</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center py-4">
                <div class="mb-3"><i class="bi bi-trash text-danger" style="font-size:3rem;opacity:.5;"></i></div>
                <p class="mb-1">Are you sure you want to permanently delete this review?</p>
                <p class="small text-muted" id="deleteReviewInfo">This action cannot be undone.</p>
            </div>
            <div class="modal-footer border-0 justify-content-center">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-danger px-4" id="confirmDeleteReview">Delete</button>
            </div>
        </div>
    </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3" id="toastContainer" style="z-index:9999;"></div>

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
            if (xhr.status >= 200 && xhr.status < 300) {
                if (onSuccess) onSuccess(res);
            } else {
                if (onError) onError(res);
            }
        } catch (e) {
            if (onError) onError({ message: 'Invalid response.' });
        }
    };
    xhr.onerror = function() { if (onError) onError({ message: 'Network error.' }); };
    xhr.send(body ? JSON.stringify(body) : null);
}

function showToast(msg, type) {
    type = type || 'success';
    var bg = type === 'danger' ? 'bg-danger' : type === 'warning' ? 'bg-warning text-dark' : 'bg-success';
    var icon = type === 'danger' ? 'bi-x-circle' : type === 'warning' ? 'bi-exclamation-circle' : 'bi-check-circle';
    var container = document.getElementById('toastContainer');
    var el = document.createElement('div');
    el.className = 'toast align-items-center text-white border-0 ' + bg;
    el.setAttribute('role', 'alert');
    el.innerHTML = '<div class="d-flex"><div class="toast-body"><i class="bi ' + icon + ' me-2"></i>' + msg + '</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>';
    container.appendChild(el);
    var t = new bootstrap.Toast(el, { autohide: true, delay: 4000 });
    t.show();
    el.addEventListener('hidden.bs.toast', function() { el.remove(); });
}

function escapeHtml(s) {
    if (!s) return '';
    var d = document.createElement('div');
    d.appendChild(document.createTextNode(s));
    return d.innerHTML;
}

function starsHtml(rating) {
    var h = '';
    for (var i = 1; i <= 5; i++) {
        if (i <= rating) h += '<i class="bi bi-star-fill text-warning"></i>';
        else if (i - 0.5 <= rating) h += '<i class="bi bi-star-half text-warning"></i>';
        else h += '<i class="bi bi-star text-warning" style="opacity:.35;"></i>';
    }
    return h;
}

function loadReviews() {
    var url = '<?php echo API_ADMIN_REVIEWS; ?>';
    var filter = document.getElementById('filterRating').value;
    if (filter) url += '?rating=' + filter;

    var tbody = document.getElementById('reviewsTableBody');
    tbody.innerHTML = '<tr><td colspan="8"><div class="text-center py-5"><div class="spinner-border text-success mb-3" role="status"></div><p>Loading...</p></div></td></tr>';

    apiFetch('GET', url, null, function(data) {
        var reviews = data.data || data.reviews || (Array.isArray(data) ? data : []);
        renderReviews(reviews);
    }, function() {
        tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state py-5"><i class="bi bi-exclamation-circle text-danger"></i><p>Failed to load reviews.</p></div></td></tr>';
    });
}

function renderReviews(reviews) {
    var tbody = document.getElementById('reviewsTableBody');

    if (!reviews || reviews.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8"><div class="empty-state py-5"><i class="bi bi-star"></i><p>No reviews found.</p><span class="text-muted" style="font-size:0.82rem;">Adjust your filters or check back later.</span></div></td></tr>';
        updateStats([]);
        return;
    }

    updateStats(reviews);

    var h = '';
    reviews.forEach(function(r) {
        var userName = (r.userId && (r.userId.fullName || r.userId.name)) || 'Anonymous';
        var userEmail = (r.userId && r.userId.email) || '';
        var userAvatar = (r.userId && (r.userId.profileImage || r.userId.avatar)) || '';
        var mealName = (r.mealId && r.mealId.name) || 'Deleted Meal';
        var mealImage = (r.mealId && r.mealId.image) || '';
        var avatarHtml = userAvatar ? '<img src="' + msmImgUrl(userAvatar) + '" style="width:32px;height:32px;border-radius:50%;object-fit:cover;" alt="avatar">' : '<div class="activity-avatar-placeholder" style="width:32px;height:32px;font-size:0.7rem;background:#198754;">' + escapeHtml(userName.charAt(0).toUpperCase()) + '</div>';
        var mealImgHtml = mealImage ? '<img src="' + msmImgUrl(mealImage) + '" style="width:36px;height:36px;border-radius:8px;object-fit:cover;" alt="meal">' : '<div style="width:36px;height:36px;border-radius:8px;background:var(--msm-bg);display:flex;align-items:center;justify-content:center;font-size:0.85rem;"><i class="bi bi-cup-hot" style="color:var(--msm-muted);"></i></div>';

        h += '<tr>';
        h += '<td><div class="form-check"><input class="form-check-input" type="checkbox" value="' + (r._id || r.id) + '"></div></td>';
        h += '<td><div class="d-flex align-items-center gap-2"><div class="flex-shrink-0">' + avatarHtml + '</div><div><div style="font-weight:500;font-size:0.85rem;">' + escapeHtml(userName) + '</div><div style="font-size:0.72rem;color:var(--msm-muted);">' + escapeHtml(userEmail) + '</div></div></div></td>';
        h += '<td><div class="d-flex align-items-center gap-2"><div class="flex-shrink-0">' + mealImgHtml + '</div><span style="font-size:0.82rem;">' + escapeHtml(mealName) + '</span></div></td>';
        h += '<td><div class="d-flex align-items-center gap-1" style="white-space:nowrap;">' + starsHtml(r.rating || 0) + '<span class="ms-1 small text-muted" style="font-size:0.7rem;">(' + (r.rating || 0) + ')</span></div></td>';
        h += '<td><span style="font-size:0.82rem;">' + escapeHtml(MSM.truncate(r.comment || r.title || 'No comment', 70)) + '</span></td>';
        h += '<td>' + (r.verifiedPurchase ? '<span class="badge badge-status bg-success"><i class="bi bi-check-circle-fill me-1" style="font-size:0.6rem;"></i>Verified</span>' : '<span class="badge badge-status bg-secondary bg-opacity-25 text-muted">No</span>') + '</td>';
        h += '<td style="font-size:0.78rem;color:var(--msm-muted);white-space:nowrap;">' + MSM.timeAgo(r.createdAt) + '</td>';
        h += '<td><div class="d-flex gap-1"><button class="btn btn-sm btn-outline-info" onclick="viewReview(\'' + r._id + '\')" title="View"><i class="bi bi-eye"></i></button><button class="btn btn-sm btn-outline-danger" onclick="confirmDeleteReview(\'' + r._id + '\', \'Review\')" title="Delete"><i class="bi bi-trash"></i></button></div></td>';
        h += '</tr>';
    });
    tbody.innerHTML = h;
}

function updateStats(reviews) {
    var total = reviews.length;
    var sum = 0;
    var fiveCount = 0;
    var weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    var weekCount = 0;

    reviews.forEach(function(r) {
        var rating = r.rating || 0;
        sum += rating;
        if (rating === 5) fiveCount++;
        if (r.createdAt && new Date(r.createdAt) >= weekAgo) weekCount++;
    });

    var avg = total > 0 ? (sum / total) : 0;

    document.getElementById('statTotalReviews').textContent = total;
    document.getElementById('statAvgRating').innerHTML = Number(avg).toFixed(1) + ' <small style="font-size:0.7rem;color:var(--msm-muted);">/ 5</small>';
    document.getElementById('statAvgStars').innerHTML = starsHtml(Math.round(avg));
    document.getElementById('statFiveStar').textContent = fiveCount;
    document.getElementById('statThisWeek').textContent = weekCount;

    animateStat('statTotalReviews', total);
    animateStat('statFiveStar', fiveCount);
    animateStat('statThisWeek', weekCount);
}

var animationFlags = {};

function animateStat(id, target) {
    var el = document.getElementById(id);
    if (!el) return;
    var current = parseInt(el.textContent.replace(/[^0-9]/g, '')) || 0;
    var duration = 800;
    var startTime = null;
    function step(ts) {
        if (!startTime) startTime = ts;
        var progress = Math.min((ts - startTime) / duration, 1);
        var eased = 1 - Math.pow(1 - progress, 3);
        var val = Math.floor(eased * target);
        el.textContent = val.toLocaleString();
        if (target > 0 && progress < 1) requestAnimationFrame(step);
    }
    if (target > 0) requestAnimationFrame(step);
}

var _reviewIdToDelete = null;

function confirmDeleteReview(id, name) {
    _reviewIdToDelete = id;
    document.getElementById('deleteReviewInfo').textContent = 'You are about to permanently delete this review.';
    var modal = new bootstrap.Modal(document.getElementById('deleteReviewModal'));
    modal.show();
}

document.getElementById('confirmDeleteReview').addEventListener('click', function() {
    if (!_reviewIdToDelete) return;
    var id = _reviewIdToDelete;
    var url = '<?php echo API_ADMIN_REVIEWS; ?>/' + id;
    var btn = document.getElementById('confirmDeleteReview');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Deleting...';

    apiFetch('DELETE', url, null, function() {
        bootstrap.Modal.getInstance(document.getElementById('deleteReviewModal')).hide();
        showToast('Review deleted successfully.');
        loadReviews();
        btn.disabled = false;
        btn.textContent = 'Delete';
        _reviewIdToDelete = null;
    }, function(err) {
        showToast(err && err.message ? err.message : 'Failed to delete review.', 'danger');
        btn.disabled = false;
        btn.textContent = 'Delete';
    });
});

function viewReview(id) {
    var url = '<?php echo API_ADMIN_REVIEWS; ?>/' + id;

    var body = document.getElementById('viewReviewModalBody');
    body.innerHTML = '<div class="text-center py-5"><div class="spinner-border text-success mb-3"></div><p>Loading review...</p></div>';
    var modal = new bootstrap.Modal(document.getElementById('viewReviewModal'));
    modal.show();

    apiFetch('GET', url, null, function(r) {
        var review = r.data || r;
        renderReviewDetail(review, body);
    }, function() {
        body.innerHTML = '<div class="empty-state py-5"><i class="bi bi-exclamation-circle text-danger"></i><p>Failed to load review details.</p></div>';
    });
}

function renderReviewDetail(r, body) {
    var userName = (r.userId && (r.userId.fullName || r.userId.name)) || 'Anonymous';
    var userEmail = (r.userId && r.userId.email) || '';
    var userAvatar = (r.userId && (r.userId.profileImage || r.userId.avatar)) || '';
    var mealName = (r.mealId && r.mealId.name) || 'Deleted Meal';
    var mealImage = (r.mealId && r.mealId.image) || '';
    var avatarHtml = userAvatar ? '<img src="' + msmImgUrl(userAvatar) + '" style="width:48px;height:48px;border-radius:50%;object-fit:cover;">' : '<div style="width:48px;height:48px;border-radius:50%;background:#198754;color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;">' + escapeHtml(userName.charAt(0).toUpperCase()) + '</div>';

    var catHtml = '';
    var c = r.categoryRatings || {};
    var catNames = Object.keys(c);
    if (catNames.length > 0) {
        catHtml = '<div class="mt-3"><h6 class="mb-2 fw-semibold" style="font-size:0.8rem;">Rating Breakdown</h6><div class="d-flex flex-wrap gap-3">';
        var catColor = ['#198754','#0d6efd','#ffc107','#dc3545','#6f42c1','#0dcaf0'];
        catNames.forEach(function(k, i) {
            catHtml += '<div class="text-center px-2 py-1 rounded border" style="font-size:0.75rem;flex:1;min-width:60px;"><div style="font-weight:600;color:' + catColor[i % catColor.length] + ';">' + escapeHtml(k) + '</div><div>' + starsHtml(c[k]) + '</div></div>';
        });
        catHtml += '</div></div>';
    }

    var imagesHtml = '';
    var images = r.images || [];
    if (images.length > 0) {
        imagesHtml = '<div class="mt-3"><h6 class="mb-2 fw-semibold" style="font-size:0.8rem;">Images</h6><div class="d-flex gap-2 flex-wrap">';
        images.forEach(function(img) {
            imagesHtml += '<a href="' + msmImgUrl(img) + '" target="_blank"><img src="' + msmImgUrl(img) + '" style="width:80px;height:80px;border-radius:8px;object-fit:cover;border:1px solid var(--msm-border);" alt="review image"></a>';
        });
        imagesHtml += '</div></div>';
    }

    var rating = r.rating || 0;

    var h = '';
    h += '<div class="d-flex align-items-start gap-3 pb-3 border-bottom mb-3">';
    h += avatarHtml;
    h += '<div><div style="font-weight:600;">' + escapeHtml(userName) + '</div><div style="font-size:0.75rem;color:var(--msm-muted);">' + escapeHtml(userEmail) + '</div></div></div>';

    h += '<div class="d-flex align-items-center gap-3 pb-3 border-bottom mb-3">';
    h += (mealImage ? '<img src="' + msmImgUrl(mealImage) + '" style="width:48px;height:48px;border-radius:8px;object-fit:cover;">' : '<div style="width:48px;height:48px;border-radius:8px;background:var(--msm-bg);display:flex;align-items:center;justify-content:center;"><i class="bi bi-cup-hot" style="color:var(--msm-muted);font-size:1.2rem;"></i></div>');
    h += '<div><div style="font-weight:600;">' + escapeHtml(mealName) + '</div><div style="font-size:0.75rem;color:var(--msm-muted);">Product review</div></div>';
    h += '</div>';

    h += '<div class="mb-2 d-flex align-items-center gap-2">' + starsHtml(rating) + '<span class="badge badge-status bg-warning text-dark">' + rating + '/5</span></div>';

    if (r.verifiedPurchase) {
        h += '<span class="badge badge-status bg-success mb-2"><i class="bi bi-patch-check-fill me-1"></i>Verified Purchase</span>';
    }

    if (r.title) {
        h += '<h5 class="mt-2">' + escapeHtml(r.title) + '</h5>';
    }
    if (r.comment) {
        h += '<p style="font-size:0.88rem;line-height:1.6;color:#444;" class="mb-0">' + escapeHtml(r.comment) + '</p>';
    }

    h += catHtml;
    h += imagesHtml;

    if (r.reply && r.reply.text) {
        h += '<div class="mt-3 p-3 rounded" style="background:#f0faf5;border-left:3px solid var(--msm-primary);">';
        h += '<div class="fw-semibold mb-1" style="font-size:0.8rem;">Reply</div>';
        h += '<p class="mb-1" style="font-size:0.85rem;">' + escapeHtml(r.reply.text) + '</p>';
        h += '<div style="font-size:0.72rem;color:var(--msm-muted);">' + (r.reply.createdAt ? MSM.formatDate(r.reply.createdAt) : '') + '</div></div>';
    }

    if (r.helpfulCount !== undefined) {
        h += '<div class="mt-2 text-muted small"><i class="bi bi-hand-thumbs-up me-1"></i>' + r.helpfulCount + ' found helpful</div>';
    }

    h += '<div class="mt-3 text-muted small">Submitted: ' + (r.createdAt ? MSM.formatDateTime(r.createdAt) : 'N/A') + '</div>';

    body.innerHTML = h;
}

document.addEventListener('DOMContentLoaded', function() {
    loadReviews();
    MSM.initSearch('<?php echo API_ADMIN_SEARCH; ?>');
});
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
