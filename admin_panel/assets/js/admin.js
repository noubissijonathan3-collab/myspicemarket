/**
 * My SpiceMarket Admin Panel — Core JavaScript
 *
 * Shared helpers: AJAX wrapper, toast integration, sidebar toggle,
 * search, notifications, animated counters, chart initialization.
 */

var MSM = MSM || {};

/* ─── AJAX helper ─────────────────────────────────────── */
MSM.ajax = function(method, url, data, onSuccess, onError) {
    var xhr = new XMLHttpRequest();
    xhr.open(method, url, true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
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
            if (onError) onError({ message: 'Invalid server response.' });
        }
    };
    xhr.onerror = function() {
        if (onError) onError({ message: 'Network error.' });
    };
    if (data) {
        var params = Object.keys(data).map(function(k) {
            return encodeURIComponent(k) + '=' + encodeURIComponent(data[k]);
        }).join('&');
        xhr.send(params);
    } else {
        xhr.send();
    }
};

/* ─── AJAX JSON helper (for API calls) ────────────────── */
MSM.apiGet = function(url, onSuccess, onError) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.setRequestHeader('Accept', 'application/json');
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
            if (onError) onError({ message: 'Invalid server response.' });
        }
    };
    xhr.onerror = function() { if (onError) onError({ message: 'Network error.' }); };
    xhr.send();
};

/* ─── Sidebar toggle (mobile) ─────────────────────────── */
MSM.toggleSidebar = function() {
    var sidebar = document.getElementById('adminSidebar') || document.querySelector('.admin-sidebar');
    var overlay = document.getElementById('sidebarOverlay');
    if (sidebar) sidebar.classList.toggle('show');
    if (overlay) overlay.classList.toggle('show');
};

/* ─── Close dropdowns on outside click ────────────────── */
document.addEventListener('click', function(e) {
    document.querySelectorAll('.dropdown-menu.show').forEach(function(d) {
        if (!d.parentElement.contains(e.target)) d.classList.remove('show');
    });
    var sr = document.querySelector('.search-results-dropdown');
    if (sr && !sr.parentElement.contains(e.target)) sr.classList.remove('show');
});

/* ─── Dropdown toggle ─────────────────────────────────── */
MSM.toggleDropdown = function(id) {
    var el = document.getElementById(id);
    if (!el) return;
    var isOpen = el.classList.contains('show');
    document.querySelectorAll('.notification-dropdown.show, .profile-dropdown.show').forEach(function(d) {
        d.classList.remove('show');
    });
    if (!isOpen) el.classList.add('show');
};

/* ─── Confirm action ──────────────────────────────────── */
MSM.confirm = function(message, onConfirm) {
    if (window.confirm(message)) onConfirm();
};

/* ─── Format currency ─────────────────────────────────── */
MSM.formatCurrency = function(amount) {
    return new Intl.NumberFormat('fr-CM').format(amount) + ' FCFA';
};

/* ─── Format date ─────────────────────────────────────── */
MSM.formatDate = function(dateStr) {
    var d = new Date(dateStr);
    return d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
};
MSM.formatDateTime = function(dateStr) {
    var d = new Date(dateStr);
    return d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
};

/* ─── Time ago helper ─────────────────────────────────── */
MSM.timeAgo = function(dateStr) {
    var now = new Date();
    var then = new Date(dateStr);
    var diff = Math.floor((now - then) / 1000);
    if (diff < 60) return 'Just now';
    if (diff < 3600) return Math.floor(diff / 60) + 'm ago';
    if (diff < 86400) return Math.floor(diff / 3600) + 'h ago';
    if (diff < 604800) return Math.floor(diff / 86400) + 'd ago';
    return MSM.formatDate(dateStr);
};

/* ─── Truncate text ───────────────────────────────────── */
MSM.truncate = function(str, len) {
    if (!str) return '';
    return str.length > len ? str.substring(0, len) + '...' : str;
};

/* ─── Animated Counter ────────────────────────────────── */
MSM.animateCounter = function(el, target, duration) {
    duration = duration || 1200;
    var startTime = null;

    function step(timestamp) {
        if (!startTime) startTime = timestamp;
        var progress = Math.min((timestamp - startTime) / duration, 1);
        var eased = 1 - Math.pow(1 - progress, 3);
        var current = Math.floor(eased * target);
        el.textContent = current.toLocaleString();
        if (progress < 1) requestAnimationFrame(step);
        else el.textContent = target.toLocaleString();
    }
    requestAnimationFrame(step);
};

/* ─── Initialize animated counters on page ────────────── */
MSM.initCounters = function() {
    document.querySelectorAll('[data-count]').forEach(function(el) {
        var target = parseInt(el.getAttribute('data-count'), 10);
        if (!isNaN(target) && target > 0) MSM.animateCounter(el, target);
    });
};

/* ─── Global Search ───────────────────────────────────── */
MSM.initSearch = function(searchUrl) {
    var input = document.getElementById('globalSearch');
    var dropdown = document.getElementById('searchResults');
    if (!input || !dropdown) return;

    var debounceTimer = null;

    input.addEventListener('input', function() {
        clearTimeout(debounceTimer);
        var q = input.value.trim();
        if (q.length < 2) { dropdown.classList.remove('show'); return; }
        debounceTimer = setTimeout(function() {
            MSM.apiGet(searchUrl + '?q=' + encodeURIComponent(q), function(res) {
                MSM.renderSearchResults(res, dropdown);
            }, function() { dropdown.classList.remove('show'); });
        }, 300);
    });

    input.addEventListener('focus', function() {
        if (input.value.trim().length >= 2) dropdown.classList.add('show');
    });
};

MSM.renderSearchResults = function(data, dropdown) {
    var html = '';
    var hasResults = false;

    if (data.meals && data.meals.length) {
        hasResults = true;
        html += '<div class="search-group-title">Meals</div>';
        data.meals.forEach(function(m) {
            html += '<a class="search-item" href="#">'
                + '<div class="search-item-meta"><div class="search-item-title">' + MSM.truncate(m.name, 40) + '</div>'
                + '<div class="search-item-sub">' + (m.categoryId ? m.categoryId.name : 'Meal') + '</div></div></a>';
        });
    }
    if (data.customers && data.customers.length) {
        hasResults = true;
        html += '<div class="search-group-title">Customers</div>';
        data.customers.forEach(function(c) {
            html += '<a class="search-item" href="#">'
                + '<div class="search-item-meta"><div class="search-item-title">' + MSM.truncate(c.fullName, 40) + '</div>'
                + '<div class="search-item-sub">' + (c.email || '') + '</div></div></a>';
        });
    }
    if (data.orders && data.orders.length) {
        hasResults = true;
        html += '<div class="search-group-title">Orders</div>';
        data.orders.forEach(function(o) {
            html += '<a class="search-item" href="#">'
                + '<div class="search-item-meta"><div class="search-item-title">#' + (o._id ? o._id.slice(-6) : '') + '</div>'
                + '<div class="search-item-sub">' + (o.userId ? o.userId.fullName : 'Order') + ' &mdash; ' + MSM.formatCurrency(o.total || 0) + '</div></div></a>';
        });
    }

    if (!hasResults) html = '<div class="search-empty"><i class="bi bi-search d-block mb-2" style="font-size:1.5rem;opacity:0.3;"></i>No results found</div>';

    dropdown.innerHTML = html;
    dropdown.classList.add('show');
};

/* ─── Greeting based on time of day ───────────────────── */
MSM.getGreeting = function() {
    var h = new Date().getHours();
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
};

MSM.initGreeting = function() {
    var el = document.getElementById('welcomeGreeting');
    if (el) el.textContent = MSM.getGreeting();
};

/* ─── Pagination helper ────────────────────────────────── */
MSM.pagination = {
    render: function(containerId, currentPage, totalPages, onPageClick) {
        var el = document.getElementById(containerId);
        if (!el) return;
        var html = '';
        html += '<div class="admin-pagination">';
        html += '<div class="page-info">Page ' + currentPage + ' of ' + totalPages + '</div>';
        html += '<div class="page-buttons">';
        html += '<button class="page-btn" ' + (currentPage <= 1 ? 'disabled' : '') + ' data-page="' + (currentPage - 1) + '"><i class="bi bi-chevron-left"></i></button>';
        var start = Math.max(1, currentPage - 2);
        var end = Math.min(totalPages, currentPage + 2);
        if (start > 1) {
            html += '<button class="page-btn" data-page="1">1</button>';
            if (start > 2) html += '<span class="page-btn" style="border:none;width:auto;">...</span>';
        }
        for (var i = start; i <= end; i++) {
            html += '<button class="page-btn ' + (i === currentPage ? 'active' : '') + '" data-page="' + i + '">' + i + '</button>';
        }
        if (end < totalPages) {
            if (end < totalPages - 1) html += '<span class="page-btn" style="border:none;width:auto;">...</span>';
            html += '<button class="page-btn" data-page="' + totalPages + '">' + totalPages + '</button>';
        }
        html += '<button class="page-btn" ' + (currentPage >= totalPages ? 'disabled' : '') + ' data-page="' + (currentPage + 1) + '"><i class="bi bi-chevron-right"></i></button>';
        html += '</div></div>';
        el.innerHTML = html;
        el.querySelectorAll('.page-btn[data-page]').forEach(function(btn) {
            btn.addEventListener('click', function() {
                var page = parseInt(this.dataset.page);
                if (!isNaN(page) && page >= 1 && page <= totalPages) onPageClick(page);
            });
        });
    }
};

/* ─── AJAX JSON helper (for POST/PUT with JSON body) ───── */
MSM.apiPost = function(url, method, data, onSuccess, onError) {
    var xhr = new XMLHttpRequest();
    xhr.open(method, url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.setRequestHeader('Accept', 'application/json');
    if (typeof MSM_JWT !== 'undefined' && MSM_JWT) {
        xhr.setRequestHeader('Authorization', 'Bearer ' + MSM_JWT);
    }
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
            if (onError) onError({ message: 'Invalid server response.' });
        }
    };
    xhr.onerror = function() { if (onError) onError({ message: 'Network error.' }); };
    if (data) {
        xhr.send(JSON.stringify(data));
    } else {
        xhr.send();
    }
};

/* ─── Delete helper with confirmation ──────────────────── */
MSM.deleteItem = function(url, itemName, onSuccess) {
    MSM.confirm('Are you sure you want to delete "' + itemName + '"? This action cannot be undone.', function() {
        MSM.apiPost(url, 'DELETE', null, function(res) {
            showToast('success', itemName + ' deleted successfully.');
            if (onSuccess) onSuccess();
        }, function(err) {
            showToast('error', err.message || 'Failed to delete.');
        });
    });
};

/* ─── Toggle status helper ─────────────────────────────── */
MSM.toggleStatus = function(url, label, onSuccess) {
    MSM.apiPost(url, 'PUT', {}, function(res) {
        showToast('success', label + ' status updated.');
        if (onSuccess) onSuccess(res);
    }, function(err) {
        showToast('error', err.message || 'Failed to update status.');
    });
};

/* ─── Format number with suffix (K, M) ─────────────────── */
MSM.formatCompact = function(num) {
    if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
    if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
    return num.toLocaleString();
};

/* ─── Generate avatar HTML from name ───────────────────── */
MSM.avatar = function(name, size, bgColor) {
    var initial = (name || 'U').charAt(0).toUpperCase();
    var colors = ['#198754', '#0d6efd', '#ffc107', '#dc3545', '#6f42c1', '#0dcaf0', '#fd7e14'];
    var bg = bgColor || colors[name ? name.charCodeAt(0) % colors.length : 0];
    var s = size || 40;
    return '<div class="avatar-placeholder" style="width:' + s + 'px;height:' + s + 'px;font-size:' + (s * 0.4) + 'px;background:' + bg + ';">' + initial + '</div>';
};

/* ─── Stars HTML helper ────────────────────────────────── */
MSM.stars = function(rating, maxStars) {
    maxStars = maxStars || 5;
    var html = '<span class="rating-display">';
    for (var i = 1; i <= maxStars; i++) {
        html += '<i class="bi bi-star' + (i <= rating ? '-fill' : '') + '"></i>';
    }
    html += '</span>';
    return html;
};

/* ─── Badge helper ─────────────────────────────────────── */
MSM.badge = function(text, variant) {
    return '<span class="badge ' + (variant || 'bg-secondary') + ' badge-status">' + text + '</span>';
};

/* ─── Empty state helper ───────────────────────────────── */
MSM.emptyState = function(icon, message) {
    return '<div class="empty-state py-4"><i class="bi ' + (icon || 'bi-inbox') + '"></i><p>' + (message || 'No data available.') + '</p></div>';
};

/* ─── Loading skeleton rows ────────────────────────────── */
MSM.skeletonRows = function(cols, rows) {
    rows = rows || 5;
    cols = cols || 5;
    var html = '';
    for (var r = 0; r < rows; r++) {
        html += '<tr>';
        for (var c = 0; c < cols; c++) {
            html += '<td><div class="skeleton" style="height:16px;width:' + (60 + Math.random() * 40) + '%;"></div></td>';
        }
        html += '</tr>';
    }
    return html;
};

/* ─── Initialize on DOM ready ─────────────────────────── */
document.addEventListener('DOMContentLoaded', function() {
    MSM.initCounters();
    MSM.initGreeting();
});
