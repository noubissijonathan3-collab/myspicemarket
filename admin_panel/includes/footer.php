    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Chart.js (for dashboard charts) -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>

    <!-- Custom Admin JS -->
    <script src="<?php echo asset_url('js/admin.js'); ?>"></script>

    <?php if (isset($extraJs)): ?>
        <?php foreach ($extraJs as $js): ?>
            <script src="<?php echo asset_url($js); ?>"></script>
        <?php endforeach; ?>
    <?php endif; ?>

    <!-- Auto-dismiss flash alerts after 5 seconds -->
    <script>
    document.querySelectorAll('.alert-dismissible').forEach(function(el) {
        setTimeout(function() {
            var bsAlert = bootstrap.Alert.getOrCreateInstance(el);
            bsAlert.close();
        }, 5000);
    });
    var MSM_BACKEND_URL = '<?php echo API_BACKEND_URL; ?>';
    function msmImgUrl(path) {
        if (!path) return '';
        if (path.indexOf('http://') === 0 || path.indexOf('https://') === 0) return path;
        return MSM_BACKEND_URL + '/' + path.replace(/^\/+/, '');
    }
    </script>
</body>
</html>
