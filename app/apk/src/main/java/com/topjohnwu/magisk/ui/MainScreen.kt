package com.topjohnwu.magisk.ui

import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.compose.*
import com.topjohnwu.magisk.ui.component.*
import com.topjohnwu.magisk.ui.screen.*

@Composable
fun MainScreen() {
    val nc = rememberNavController()
    val bs by nc.currentBackStackEntryAsState()
    val cur = bs?.destination?.route
    CustomBackground {
        AdaptiveNavigation(cur, { r ->
            if (cur != r) nc.navigate(r) {
                popUpTo(nc.graph.startDestinationId) { saveState = true }
                launchSingleTop = true; restoreState = true
            }
        }) { p ->
            NavHost(nc, "home", Modifier.padding(p)) {
                composable("home") { HomeScreen() }
                composable("modules") { ModulesScreen() }
                composable("superuser") { SuperuserScreen() }
                composable("music") { MusicScreen() }
                composable("settings") { SettingsScreen() }
            }
        }
    }
}
