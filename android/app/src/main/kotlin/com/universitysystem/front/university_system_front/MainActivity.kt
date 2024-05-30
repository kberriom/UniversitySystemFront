package com.universitysystem.front.university_system_front

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Disable splash screen fade out animation to avoid flicker
            splashScreen.setOnExitAnimationListener {splashScreenView -> splashScreenView.remove()}
        }
        super.onCreate(savedInstanceState)
    }
}
