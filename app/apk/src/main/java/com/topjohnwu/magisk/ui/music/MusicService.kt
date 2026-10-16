package com.topjohnwu.magisk.ui.music

import android.app.*
import android.content.ContentUris
import android.content.Intent
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.provider.MediaStore
import androidx.core.app.NotificationCompat

data class MusicTrack(val id: Long, val title: String, val artist: String, val uri: Uri)

class MusicService : Service() {
    private var mp: MediaPlayer? = null
    private var cur: MusicTrack? = null
    private var list = mutableListOf<MusicTrack>()
    private var idx = 0

    override fun onBind(i: Intent?): IBinder? = null
    override fun onCreate() { super.onCreate(); startForeground(1, notif("准备就绪")) }

    fun scanLocalMusic(): List<MusicTrack> {
        val t = mutableListOf<MusicTrack>()
        val proj = arrayOf(MediaStore.Audio.Media._ID, MediaStore.Audio.Media.TITLE, MediaStore.Audio.Media.ARTIST)
        contentResolver.query(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, proj,
            "${MediaStore.Audio.Media.DURATION} > 30000", null,
            "${MediaStore.Audio.Media.TITLE} ASC")?.use { c ->
            val i = c.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val ti = c.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val ar = c.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            while (c.moveToNext()) {
                val id = c.getLong(i)
                t.add(MusicTrack(id, c.getString(ti) ?: "未知", c.getString(ar) ?: "未知",
                    ContentUris.withAppendedId(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, id)))
            }
        }
        return t
    }

    fun play(tr: MusicTrack) {
        mp?.release()
        mp = MediaPlayer().apply {
            setDataSource(this@MusicService, tr.uri)
            setOnCompletionListener { next() }
            prepare(); start()
        }
        cur = tr; upd("播放: ${tr.title}")
    }
    fun pause() { mp?.pause(); upd("已暂停") }
    fun resume() { mp?.start(); upd("播放: ${cur?.title}") }
    fun stop() { mp?.stop(); mp?.release(); mp = null; stopForeground(true) }
    fun next() { if (list.isNotEmpty()) { idx = (idx + 1) % list.size; play(list[idx]) } }
    fun setPlaylist(t: List<MusicTrack>) { list = t.toMutableList() }

    private fun notif(s: String): Notification {
        val cid = "music_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager)
                .createNotificationChannel(NotificationChannel(cid, "音乐", NotificationManager.IMPORTANCE_LOW))
        }
        return NotificationCompat.Builder(this, cid).setContentTitle("Magisk 音乐")
            .setContentText(s).setSmallIcon(android.R.drawable.ic_media_play).setOngoing(true).build()
    }
    private fun upd(s: String) {
        (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).notify(1, notif(s))
    }
}
