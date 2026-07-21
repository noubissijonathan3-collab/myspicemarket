<!-- Reusable Full-Screen Loader -->
<div id="app-loader" class="app-loader" style="display:none;">
    <div class="loader-wrapper">
        <div class="spinner-border text-success" role="status">
            <span class="visually-hidden">Loading…</span>
        </div>
        <p class="loader-text mt-3">Please wait…</p>
    </div>
</div>

<style>
.app-loader {
    position: fixed;
    inset: 0;
    z-index: 9999;
    background: rgba(255,255,255,0.85);
    display: flex;
    align-items: center;
    justify-content: center;
    backdrop-filter: blur(2px);
}
.loader-wrapper { text-align: center; }
.loader-text { color: #198754; font-weight: 500; }
</style>

<script>
function showLoader(msg) {
    var el = document.getElementById('app-loader');
    if (msg) el.querySelector('.loader-text').textContent = msg;
    el.style.display = 'flex';
}
function hideLoader() {
    document.getElementById('app-loader').style.display = 'none';
}
</script>
