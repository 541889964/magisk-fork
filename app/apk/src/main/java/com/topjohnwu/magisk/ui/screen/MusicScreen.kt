package com.topjohnwu.magisk.ui.screen

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.topjohnwu.magisk.ui.music.MusicTrack

@Composable
fun MusicScreen() {
    var tracks by remember { mutableStateOf<List<MusicTrack>>(emptyList()) }
    var now by remember { mutableStateOf<MusicTrack?>(null) }
    var playing by remember { mutableStateOf(false) }

    Column(Modifier.fillMaxSize()) {
        Button(onClick = {}, modifier = Modifier.fillMaxWidth().padding(16.dp)) {
            Icon(Icons.Default.Search, null); Spacer(Modifier.width(8.dp)); Text("扫描本地音乐")
        }
        now?.let { t ->
            Card(Modifier.fillMaxWidth().padding(horizontal = 16.dp)) {
                Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                    Column(Modifier.weight(1f)) {
                        Text(t.title, style = MaterialTheme.typography.titleMedium)
                        Text(t.artist, style = MaterialTheme.typography.bodySmall)
                    }
                    IconButton(onClick = { playing = !playing }) {
                        Icon(if (playing) Icons.Default.Pause else Icons.Default.PlayArrow, null)
                    }
                    IconButton(onClick = {}) { Icon(Icons.Default.SkipNext, null) }
                    IconButton(onClick = {}) { Icon(Icons.Default.Stop, null) }
                }
            }
        }
        LazyColumn(Modifier.weight(1f)) {
            items(tracks, key = { it.id }) { t ->
                ListItem(headlineContent = { Text(t.title) }, supportingContent = { Text(t.artist) },
                    modifier = Modifier.clickable { now = t; playing = true })
                HorizontalDivider()
            }
        }
    }
}
