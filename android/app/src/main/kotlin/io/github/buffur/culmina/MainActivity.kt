package io.github.buffur.culmina

import android.content.Intent
import android.content.res.Configuration
import android.content.res.Resources
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // S2.4 (ADR-017 §6): capture files are opened for metadata without a copy.
    private var documents: MetadataDocumentChannel? = null
    private var launch: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Owner, 2026-10-23 (second brief): the whole launch gesture is shown
        // before the app opens, and Flutter plays it (LaunchGate). The splash
        // only shows the still mark; it leaves at Flutter's first frame, which
        // draws the same mark in the same place, and then Dart is told the
        // Flutter mark is the one on screen, so the gesture starts where the
        // user can see it. The window behind Flutter carries the same mark
        // until the app is shown, so a frame between the two never lacks it.
        window.setBackgroundDrawableResource(launchBackground(storedTheme()))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { view ->
                view.remove()
                launch?.invokeMethod("splashGone", null)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        documents = MetadataDocumentChannel(this, messenger)
        // lib/data/services/launch_channel.dart
        launch = MethodChannel(messenger, LAUNCH_CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "appShown" -> {
                        // The launch is over: a plain window behind Flutter, so
                        // a later surface change can never show the mark.
                        window.setBackgroundDrawable(ColorDrawable(appBackground(storedTheme())))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
        // The app's appearance and field mode for the next launch
        // (lib/data/services/splash_theme_channel.dart).
        MethodChannel(messenger, SPLASH_THEME_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setTheme") {
                setSplashTheme(call.arguments as? String)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    /** Stores the theme for the next launch's window, and on Android 13+
     *  for its splash; earlier splashes follow the system's dark mode. */
    private fun setSplashTheme(name: String?) {
        getSharedPreferences(PREFS, MODE_PRIVATE).edit().putString(THEME_KEY, name).apply()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return
        val theme = when (name) {
            "light" -> R.style.CulminaSplash_Light
            "dark" -> R.style.CulminaSplash_Dark
            "field" -> R.style.CulminaSplash_Field
            else -> Resources.ID_NULL
        }
        splashScreen.setSplashScreenTheme(theme)
    }

    private fun storedTheme(): String =
        getSharedPreferences(PREFS, MODE_PRIVATE).getString(THEME_KEY, null) ?: "system"

    private fun systemDark(): Boolean =
        (resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) ==
            Configuration.UI_MODE_NIGHT_YES

    private fun launchBackground(theme: String): Int = when (theme) {
        "light" -> R.drawable.launch_background_light
        "dark" -> R.drawable.launch_background_dark
        "field" -> R.drawable.launch_background_field
        else -> R.drawable.launch_background
    }

    private fun appBackground(theme: String): Int = when (theme) {
        "field" -> Color.BLACK
        "light" -> LIGHT
        "dark" -> DARK
        else -> if (systemDark()) DARK else LIGHT
    }

    private companion object {
        const val LAUNCH_CHANNEL = "io.github.buffur.culmina/launch"
        const val SPLASH_THEME_CHANNEL = "io.github.buffur.culmina/splash_theme"
        const val PREFS = "culmina_launch"
        const val THEME_KEY = "theme"
        // AppColors.lightBackground / darkBackground.
        val LIGHT = Color.rgb(0xFF, 0xFF, 0xFF)
        val DARK = Color.rgb(0x19, 0x19, 0x19)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        documents?.dispose()
        documents = null
        launch?.setMethodCallHandler(null)
        launch = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (documents?.onActivityResult(requestCode, resultCode, data) == true) return
        super.onActivityResult(requestCode, resultCode, data)
    }
}
