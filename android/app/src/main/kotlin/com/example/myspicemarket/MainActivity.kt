package com.example.myspicemarket

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.myspicemarket/imagepicker"
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "pickImage") {
                pendingResult = result
                val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                    type = "image/*"
                    addCategory(Intent.CATEGORY_OPENABLE)
                }
                startActivityForResult(intent, IMAGE_PICK_REQUEST)
            } else {
                result.notImplemented()
            }
        }
    }

    @Deprecated("Use ActivityResultLauncher")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == IMAGE_PICK_REQUEST) {
            handleImageResult(data?.data)
        }
    }

    private fun handleImageResult(uri: Uri?) {
        if (uri == null) {
            pendingResult?.success(null)
            pendingResult = null
            return
        }
        try {
            val tempDir = File(cacheDir, "image_picker")
            tempDir.mkdirs()
            val tempFile = File.createTempFile("upload_", ".jpg", tempDir)

            val inputStream = contentResolver.openInputStream(uri)
            val bitmap = BitmapFactory.decodeStream(inputStream)
            inputStream?.close()

            if (bitmap == null) {
                pendingResult?.error("DECODE_ERROR", "Failed to decode image", null)
                pendingResult = null
                return
            }

            val maxSize = 512
            val scale = minOf(maxSize.toFloat() / bitmap.width, maxSize.toFloat() / bitmap.height, 1f)
            val outBitmap = if (scale < 1f) {
                Bitmap.createScaledBitmap(bitmap, (bitmap.width * scale).toInt(), (bitmap.height * scale).toInt(), true)
            } else {
                bitmap
            }

            FileOutputStream(tempFile).use { output ->
                outBitmap.compress(Bitmap.CompressFormat.JPEG, 60, output)
            }

            if (outBitmap !== bitmap) outBitmap.recycle()
            bitmap.recycle()

            pendingResult?.success(tempFile.absolutePath)
        } catch (e: Exception) {
            pendingResult?.error("PICK_ERROR", e.message, null)
        }
        pendingResult = null
    }

    companion object {
        private const val IMAGE_PICK_REQUEST = 1001
    }
}
