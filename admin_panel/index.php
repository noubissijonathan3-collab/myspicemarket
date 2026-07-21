<?php
/**
 * Admin Panel — Entry Point
 * 
 * When a user opens the admin panel URL, this file decides where to send
 * them based on their authentication status.
 */

require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/auth/session.php';

if (session_is_logged_in()) {
    header('Location: ' . admin_url('pages/dashboard/dashboard.php'));
} else {
    header('Location: ' . admin_url('auth/login.php'));
}
exit;
