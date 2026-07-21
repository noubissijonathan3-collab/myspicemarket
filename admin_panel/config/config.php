<?php
/**
 * My SpiceMarket Admin Panel — General Configuration
 * 
 * Centralizes application-wide settings: site identity, session behaviour,
 * upload limits, environment flags, and path helpers.
 */

/* ─── Environment ─────────────────────────────────────── */
define('APP_ENV',        'development');            // development | production
define('APP_DEBUG',      true);

/* ─── Site Identity ───────────────────────────────────── */
define('APP_NAME',       'My SpiceMarket');
define('APP_TITLE',      'My SpiceMarket Admin');
define('APP_VERSION',    '1.0.0');
define('APP_URL',        'http://admin.myspicemarket.local');

/* ─── Paths ───────────────────────────────────────────── */
define('ROOT_PATH',      dirname(__DIR__));
define('CONFIG_PATH',    ROOT_PATH . '/config');
define('INCLUDES_PATH',  ROOT_PATH . '/includes');
define('AUTH_PATH',      ROOT_PATH . '/auth');
define('PAGES_PATH',     ROOT_PATH . '/pages');
define('ASSETS_PATH',    ROOT_PATH . '/assets');
define('UPLOADS_PATH',   ROOT_PATH . '/uploads');
define('COMPONENTS_PATH',ROOT_PATH . '/components');
define('LAYOUTS_PATH',   ROOT_PATH . '/layouts');

/* ─── Session ─────────────────────────────────────────── */
define('SESSION_LIFETIME',       3600);   // 1 hour  (seconds)
define('SESSION_INACTIVITY',     1800);   // 30 min  idle timeout
define('REMEMBER_ME_DURATION',   604800); // 7 days  (seconds)

/* ─── Upload Limits ───────────────────────────────────── */
define('MAX_UPLOAD_SIZE',  5 * 1024 * 1024);  // 5 MB
define('ALLOWED_IMAGES',   ['image/jpeg', 'image/png', 'image/webp', 'image/gif']);

/* ─── Pagination ──────────────────────────────────────── */
define('PER_PAGE',  20);

/* ─── Currency ────────────────────────────────────────── */
define('CURRENCY',      'FCFA');
define('CURRENCY_CODE', 'XAF');

/* ─── Timezone ────────────────────────────────────────── */
date_default_timezone_set('Africa/Douala');

/* ─── Error Reporting (dev only) ──────────────────────── */
if (APP_DEBUG) {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
} else {
    error_reporting(0);
    ini_set('display_errors', 0);
}

/* ─── Helper: base URL for a given relative path ──────── */
function admin_url(string $path = ''): string
{
    return rtrim(APP_URL, '/') . '/' . ltrim($path, '/');
}

/* ─── Helper: asset URL ──────────────────────────────── */
function asset_url(string $path = ''): string
{
    return admin_url('assets/' . ltrim($path, '/'));
}

/* ─── Helper: backend image URL ─────────────────────── */
function img_url(?string $path): string
{
    if (!$path || $path === '') return '';
    if (str_starts_with($path, 'http://') || str_starts_with($path, 'https://')) return $path;
    return API_BACKEND_URL . '/' . ltrim($path, '/');
}
