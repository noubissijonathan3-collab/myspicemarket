<?php
/**
 * API Configuration
 * 
 * Base URL and endpoint helpers for the Node.js + Express backend.
 */

define('API_BASE_URL', 'http://localhost:5000/api');
define('API_BACKEND_URL', 'http://localhost:5000');

/* ─── Auth Endpoints ──────────────────────────────────── */
define('API_AUTH_ADMIN_LOGIN',    API_BASE_URL . '/auth/admin/login');
define('API_AUTH_ADMIN_PROFILE',  API_BASE_URL . '/auth/admin/profile');
define('API_AUTH_LOGOUT',         API_BASE_URL . '/auth/logout');
define('API_AUTH_ME',             API_BASE_URL . '/auth/me');

/* ─── Admin Endpoints ─────────────────────────────────── */
define('API_ADMIN_DASHBOARD',    API_BASE_URL . '/admin/dashboard');
define('API_ADMIN_PRODUCTS',     API_BASE_URL . '/admin/products');
define('API_ADMIN_CATEGORIES',   API_BASE_URL . '/admin/categories');
define('API_ADMIN_ORDERS',       API_BASE_URL . '/admin/orders');
define('API_ADMIN_CUSTOMERS',    API_BASE_URL . '/admin/customers');
define('API_ADMIN_RIDERS',       API_BASE_URL . '/admin/riders');
define('API_ADMIN_REVIEWS',      API_BASE_URL . '/admin/reviews');
define('API_ADMIN_PROMOTIONS',   API_BASE_URL . '/admin/promotions');
define('API_ADMIN_REPORTS',      API_BASE_URL . '/admin/reports');
define('API_ADMIN_SETTINGS',     API_BASE_URL . '/admin/settings');
define('API_ADMIN_ADMINS',       API_BASE_URL . '/admin/admins');
define('API_ADMIN_SEARCH',       API_BASE_URL . '/admin/search');
define('API_ADMIN_FAVORITES',    API_BASE_URL . '/admin/favorites');
define('API_ADMIN_NOTIFICATIONS',API_BASE_URL . '/admin/notifications');
define('API_ADMIN_MEAL_INGREDIENTS', API_BASE_URL . '/admin/meals');
define('API_TRACKING_ACTIVE',       API_BASE_URL . '/tracking/active');
define('API_TRACKING_AGENT',        API_BASE_URL . '/tracking/agent');
define('API_TRACKING_ORDER',        API_BASE_URL . '/tracking/order');

function api_admin_meal_ingredients_url(string $mealId): string {
    return API_ADMIN_MEAL_INGREDIENTS . '/' . $mealId . '/ingredients';
}

/* ─── Public Endpoints ────────────────────────────────── */
define('API_CATEGORIES',         API_BASE_URL . '/categories');
define('API_MEALS',              API_BASE_URL . '/meals');
define('API_FOODSTUFFS',         API_BASE_URL . '/foodstuffs');
define('API_BANNERS',            API_BASE_URL . '/banners');
define('API_NOTIFICATIONS',      API_BASE_URL . '/notifications');

/* ─── Dynamic Endpoint Helpers ────────────────────────── */
function api_admin_product_url($id = null) {
    return $id ? API_ADMIN_PRODUCTS . '/' . $id : API_ADMIN_PRODUCTS;
}
function api_admin_category_url($id = null) {
    return $id ? API_ADMIN_CATEGORIES . '/' . $id : API_ADMIN_CATEGORIES;
}
function api_admin_order_url($id = null) {
    return $id ? API_ADMIN_ORDERS . '/' . $id : API_ADMIN_ORDERS;
}
function api_admin_customer_url($id = null) {
    return $id ? API_ADMIN_CUSTOMERS . '/' . $id : API_ADMIN_CUSTOMERS;
}
function api_admin_rider_url($id = null) {
    return $id ? API_ADMIN_RIDERS . '/' . $id : API_ADMIN_RIDERS;
}
function api_admin_review_url($id = null) {
    return $id ? API_ADMIN_REVIEWS . '/' . $id : API_ADMIN_REVIEWS;
}
function api_admin_promotion_url($id = null) {
    return $id ? API_ADMIN_PROMOTIONS . '/' . $id : API_ADMIN_PROMOTIONS;
}
function api_admin_admin_url($id = null) {
    return $id ? API_ADMIN_ADMINS . '/' . $id : API_ADMIN_ADMINS;
}
function api_foodstuff_url($id = null) {
    return $id ? API_FOODSTUFFS . '/' . $id : API_FOODSTUFFS;
}
function api_meal_url($id = null) {
    return $id ? API_MEALS . '/' . $id : API_MEALS;
}
