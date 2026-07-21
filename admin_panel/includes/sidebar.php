<?php
/**
 * Sidebar Navigation
 *
 * Reusable sidebar with grouped navigation, notification badges,
 * and collapse behavior. The active page is highlighted based on $currentPage.
 */

$currentPage = $currentPage ?? 'dashboard';

$navGroups = [
    'Overview' => [
        ['page' => 'dashboard',   'icon' => 'bi-speedometer2',  'label' => 'Dashboard',   'href' => admin_url('pages/dashboard/dashboard.php')],
    ],
    'Catalog' => [
        ['page' => 'meals',       'icon' => 'bi-cup-hot',       'label' => 'Meals',        'href' => admin_url('pages/meals/meals.php')],
        ['page' => 'products',    'icon' => 'bi-box-seam',      'label' => 'Products',     'href' => admin_url('pages/products/products.php')],
        ['page' => 'categories',  'icon' => 'bi-tags',          'label' => 'Categories',   'href' => admin_url('pages/categories/categories.php')],
        ['page' => 'ingredients', 'icon' => 'bi-basket',        'label' => 'Ingredients',  'href' => admin_url('pages/ingredients/ingredients.php')],
        ['page' => 'inventory',   'icon' => 'bi-clipboard-data','label' => 'Inventory',    'href' => admin_url('pages/inventory/inventory.php')],
    ],
    'Commerce' => [
        ['page' => 'orders',      'icon' => 'bi-cart-check',    'label' => 'Orders',       'href' => admin_url('pages/orders/orders.php'), 'badge' => $pendingOrdersBadge ?? ''],
        ['page' => 'deliveries',  'icon' => 'bi-bicycle',       'label' => 'Deliveries',   'href' => admin_url('pages/deliveries/deliveries.php')],
        ['page' => 'tracking',    'icon' => 'bi-geo-alt',        'label' => 'Live Tracking', 'href' => admin_url('pages/deliveries/tracking.php')],
        ['page' => 'payments',    'icon' => 'bi-credit-card',   'label' => 'Payments',     'href' => admin_url('pages/payments/payments.php')],
    ],
    'Engagement' => [
        ['page' => 'customers',   'icon' => 'bi-people',        'label' => 'Customers',    'href' => admin_url('pages/users/users.php')],
        ['page' => 'reviews',     'icon' => 'bi-star',          'label' => 'Reviews',      'href' => admin_url('pages/reviews/reviews.php')],
        ['page' => 'favorites',   'icon' => 'bi-heart',         'label' => 'Favorites',    'href' => admin_url('pages/favorites/favorites.php')],
    ],
    'Marketing' => [
        ['page' => 'promotions',  'icon' => 'bi-megaphone',     'label' => 'Promotions',   'href' => admin_url('pages/promotions/promotions.php')],
        ['page' => 'coupons',     'icon' => 'bi-ticket-perforated','label' => 'Coupons',    'href' => admin_url('pages/coupons/coupons.php')],
        ['page' => 'notifications','icon' => 'bi-bell',          'label' => 'Notifications','href' => admin_url('pages/notifications/notifications.php')],
    ],
    'Management' => [
        ['page' => 'admins',      'icon' => 'bi-shield-lock',   'label' => 'Admins',       'href' => admin_url('pages/admins/admins.php')],
        ['page' => 'reports',     'icon' => 'bi-graph-up-arrow','label' => 'Reports',      'href' => admin_url('pages/reports/reports.php')],
        ['page' => 'settings',    'icon' => 'bi-gear',          'label' => 'Settings',     'href' => admin_url('pages/settings/settings.php')],
        ['page' => 'profile',     'icon' => 'bi-person-circle', 'label' => 'My Profile',   'href' => admin_url('pages/profile/profile.php')],
    ],
];
?>

<aside class="admin-sidebar" id="adminSidebar">
    <div class="sidebar-brand">
        <i class="bi bi-fire"></i>
        <span class="sidebar-brand-text"><?php echo APP_NAME; ?></span>
    </div>

    <div class="py-2">
    <?php foreach ($navGroups as $groupName => $items): ?>
        <div class="sidebar-nav-group"><?php echo $groupName; ?></div>
        <ul class="sidebar-nav">
            <?php foreach ($items as $item): ?>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === $item['page'] ? 'active' : ''; ?>"
                   href="<?php echo $item['href']; ?>">
                    <i class="bi <?php echo $item['icon']; ?>"></i>
                    <span><?php echo $item['label']; ?></span>
                    <?php if (!empty($item['badge'])): ?>
                        <span class="nav-badge"><?php echo $item['badge']; ?></span>
                    <?php endif; ?>
                </a>
            </li>
            <?php endforeach; ?>
        </ul>
    <?php endforeach; ?>
    </div>

    <!-- Logout at bottom -->
    <div style="padding:0.75rem 1rem;margin-top:auto;border-top:1px solid rgba(255,255,255,0.06);">
        <a href="<?php echo admin_url('auth/logout.php'); ?>" class="nav-link" style="color:#ef4444;padding:0.55rem 0.75rem;border-radius:8px;display:flex;align-items:center;gap:0.6rem;font-size:0.85rem;">
            <i class="bi bi-box-arrow-right" style="width:20px;text-align:center;"></i>
            <span>Logout</span>
        </a>
    </div>
</aside>
