<?php
/**
 * Flash Alert Renderer
 * 
 * Displays session-based flash messages (success, error, warning, info).
 * Include this file in header.php so alerts show on every page load.
 */

require_once __DIR__ . '/../auth/session.php';

$flashTypes = ['success', 'error', 'warning', 'info'];
$bootstrapMap = [
    'success' => 'alert-success',
    'error'   => 'alert-danger',
    'warning' => 'alert-warning',
    'info'    => 'alert-info',
];
$iconMap = [
    'success' => 'bi-check-circle-fill',
    'error'   => 'bi-exclamation-triangle-fill',
    'warning' => 'bi-exclamation-circle-fill',
    'info'    => 'bi-info-circle-fill',
];
?>

<div id="alert-container" class="position-fixed top-0 end-0 p-3" style="z-index:10000; min-width:320px;">
<?php foreach ($flashTypes as $type): ?>
    <?php $message = session_get_flash($type); ?>
    <?php if ($message): ?>
    <div class="alert <?php echo $bootstrapMap[$type]; ?> alert-dismissible fade show shadow-sm" role="alert">
        <i class="bi <?php echo $iconMap[$type]; ?> me-2"></i>
        <?php echo htmlspecialchars($message); ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
    <?php endif; ?>
<?php endforeach; ?>
</div>

<script>
/**
 * Programmatic alert helper — call from JS:
 *   showToast('success', 'Saved!');
 */
function showToast(type, message) {
    var container = document.getElementById('alert-container');
    var map = { success:'alert-success', error:'alert-danger', warning:'alert-warning', info:'alert-info' };
    var icons = { success:'bi-check-circle-fill', error:'bi-exclamation-triangle-fill', warning:'bi-exclamation-circle-fill', info:'bi-info-circle-fill' };

    var div = document.createElement('div');
    div.className = 'alert ' + (map[type] || 'alert-info') + ' alert-dismissible fade show shadow-sm';
    div.setAttribute('role', 'alert');
    div.innerHTML = '<i class="bi ' + (icons[type] || 'bi-info-circle-fill') + ' me-2"></i>' + message +
                    '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>';
    container.appendChild(div);

    setTimeout(function() {
        bootstrap.Alert.getOrCreateInstance(div).close();
    }, 5000);
}
</script>
