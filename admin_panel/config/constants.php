<?php
/**
 * Application Constants
 * 
 * Fixed values used throughout the admin panel.
 */

/* ─── Pagination ──────────────────────────────────────── */
define('DEFAULT_PAGE',      1);
define('ITEMS_PER_PAGE',    20);
define('MAX_PAGE_LINKS',    5);

/* ─── Default Images ──────────────────────────────────── */
define('DEFAULT_AVATAR',      'assets/images/default-avatar.png');
define('DEFAULT_PRODUCT_IMG', 'assets/images/default-product.png');
define('DEFAULT_MEAL_IMG',    'assets/images/default-meal.png');
define('LOGO_PATH',           'assets/images/logo.png');

/* ─── Order Statuses ──────────────────────────────────── */
define('ORDER_PENDING',     'pending');
define('ORDER_CONFIRMED',   'confirmed');
define('ORDER_PREPARING',   'preparing');
define('ORDER_SHIPPED',     'shipped');
define('ORDER_DELIVERED',   'delivered');
define('ORDER_CANCELLED',   'cancelled');

/* ─── User Roles ──────────────────────────────────────── */
define('ROLE_ADMIN',    'admin');
define('ROLE_CUSTOMER', 'customer');

/* ─── Flash / Alert Keys ──────────────────────────────── */
define('ALERT_SUCCESS', 'success');
define('ALERT_ERROR',   'error');
define('ALERT_WARNING', 'warning');
define('ALERT_INFO',    'info');
