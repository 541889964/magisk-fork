package com.topjohnwu.magisk.ui.component

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.unit.dp

data class NavItem(val route: String, val label: String, val icon: ImageVector)

val navItems = listOf(
    NavItem("home", "状态", Icons.Default.Shield),
    NavItem("modules", "模块", Icons.Default.Extension),
    NavItem("superuser", "超级用户", Icons.Default.Key),
    NavItem("music", "音乐", Icons.Default.MusicNote),
    NavItem("settings", "设置", Icons.Default.Settings))

@Composable
fun AdaptiveNavigation(currentRoute: String?, onNavigate: (String) -> Unit,
                       content: @Composable (PaddingValues) -> Unit) {
    if (LocalConfiguration.current.screenWidthDp >= 600) {
        Row(Modifier.fillMaxSize()) {
            NavigationRail(containerColor = MaterialTheme.colorScheme.surfaceVariant) {
                Spacer(Modifier.height(24.dp))
                navItems.forEach { item ->
                    NavigationRailItem(
                        selected = currentRoute == item.route,
                        onClick = { onNavigate(item.route) },
                        icon = { Icon(item.icon, item.label) },
                        label = { Text(item.label) },
                        alwaysShowLabel = true)
                }
            }
            Box(Modifier.weight(1f)) { content(PaddingValues(0.dp)) }
        }
    } else {
        Scaffold(bottomBar = {
            NavigationBar {
                navItems.forEach { item ->
                    NavigationBarItem(
                        selected = currentRoute == item.route,
                        onClick = { onNavigate(item.route) },
                        icon = { Icon(item.icon, item.label) },
                        label = { Text(item.label) })
                }
            }
        }) { p -> content(p) }
    }
}
