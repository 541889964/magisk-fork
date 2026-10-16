package com.topjohnwu.magisk.ui.screen
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun SuperuserScreen() {
    Column(Modifier.fillMaxSize().padding(16.dp)) {
        Text("Superuser", style = MaterialTheme.typography.headlineMedium)
        Text("接入 core 业务逻辑", style = MaterialTheme.typography.bodyMedium)
    }
}
