package com.topjohnwu.magisk.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

private val Light = lightColorScheme(
    primary = Color(0xFF1B5E20), onPrimary = Color(0xFFFFFFFF),
    background = Color(0xFFF8F9FA), onBackground = Color(0xFF1A1C19),
    surface = Color(0xFFFFFFFF), onSurface = Color(0xFF1A1C19),
    surfaceVariant = Color(0xFFE8EAED), onSurfaceVariant = Color(0xFF44474A))
private val Dark = darkColorScheme(
    primary = Color(0xFF7DD17F), onPrimary = Color(0xFF00390D),
    background = Color(0xFF1A1C19), onBackground = Color(0xFFE2E3DD),
    surface = Color(0xFF1E201D), onSurface = Color(0xFFE2E3DD))

@Composable
fun MagiskTheme(dark: Boolean = isSystemInDarkTheme(), content: @Composable () -> Unit) {
    val cs = when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val c = LocalContext.current
            if (dark) dynamicDarkColorScheme(c) else dynamicLightColorScheme(c)
        }
        dark -> Dark
        else -> Light
    }
    MaterialTheme(colorScheme = cs, content = content)
}
