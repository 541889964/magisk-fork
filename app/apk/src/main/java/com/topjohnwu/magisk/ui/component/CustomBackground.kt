package com.topjohnwu.magisk.ui.component

import android.net.Uri
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import coil.compose.rememberAsyncImagePainter

object BackgroundState {
    var backgroundUri by mutableStateOf<Uri?>(null)
    var blurRadius by mutableStateOf(12f)
    var darkOverlay by mutableStateOf(0.25f)
}

@Composable
fun CustomBackground(content: @Composable () -> Unit) {
    val uri = BackgroundState.backgroundUri
    Box(Modifier.fillMaxSize()) {
        if (uri != null) {
            Image(painter = rememberAsyncImagePainter(uri), contentDescription = null,
                modifier = Modifier.fillMaxSize().blur(BackgroundState.blurRadius.dp),
                contentScale = ContentScale.Crop)
            Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = BackgroundState.darkOverlay)))
        }
        content()
    }
}
