<?php
/**
 * Login Processor
 * 
 * Receives credentials from login.php via AJAX, validates them against
 * the Node.js backend, stores the JWT in the PHP session, and returns
 * a JSON response.  No HTML output.
 */

header('Content-Type: application/json');

require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/constants.php';
require_once __DIR__ . '/session.php';
require_once __DIR__ . '/../api/auth_api.php';

/* ─── Only accept POST ────────────────────────────────── */
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed.']);
    exit;
}

/* ─── Collect & sanitise input ────────────────────────── */
$email    = trim($_POST['email']    ?? '');
$password = $_POST['password']      ?? '';
$remember = ($_POST['remember_me'] ?? '0') === '1';

/* ─── Validate ────────────────────────────────────────── */
if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['success' => false, 'message' => 'Please enter a valid email address.']);
    exit;
}

if ($password === '') {
    echo json_encode(['success' => false, 'message' => 'Password is required.']);
    exit;
}

/* ─── Call backend API ────────────────────────────────── */
$response = auth_api_login($email, $password);

if ($response === null) {
    echo json_encode(['success' => false, 'message' => 'Unable to reach the server. Please try again later.']);
    exit;
}

/* ─── Process response ────────────────────────────────── */
$success = $response['success'] ?? false;

if (!$success) {
    $message = $response['message'] ?? 'Invalid email or password.';
    echo json_encode(['success' => false, 'message' => $message]);
    exit;
}

/* ─── Extract data ────────────────────────────────────── */
$jwt  = $response['token'] ?? $response['jwt'] ?? '';
$user = $response['user']  ?? $response['admin'] ?? [];

if (empty($jwt)) {
    echo json_encode(['success' => false, 'message' => 'Authentication failed. No token received.']);
    exit;
}

/* ─── Verify role is admin ────────────────────────────── */
$role = $user['role'] ?? '';
if ($role !== ROLE_ADMIN) {
    echo json_encode(['success' => false, 'message' => 'Access denied. This account is not an administrator.']);
    exit;
}

/* ─── Create session ──────────────────────────────────── */
session_set_admin([
    'id'           => $user['_id']     ?? $user['id'] ?? '',
    'fullName'     => $user['fullName'] ?? $user['name'] ?? 'Administrator',
    'email'        => $user['email']    ?? $email,
    'role'         => $role,
    'profileImage' => $user['profileImage'] ?? $user['avatar'] ?? '',
], $jwt);

/* ─── Remember-me cookie ──────────────────────────────── */
if ($remember) {
    require_once __DIR__ . '/remember_me.php';
    remember_me_set($user['_id'] ?? $user['id'] ?? '', $jwt);
}

/* ─── Success ─────────────────────────────────────────── */
echo json_encode([
    'success'  => true,
    'message'  => 'Login successful.',
    'redirect' => admin_url('pages/dashboard/dashboard.php'),
]);
