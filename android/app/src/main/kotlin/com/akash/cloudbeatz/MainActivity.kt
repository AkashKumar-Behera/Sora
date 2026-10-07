package com.akash.cloudbeatz

import android.app.SearchManager
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import com.ryanheise.audioservice.AudioServiceActivity

class MainActivity : AudioServiceActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleVoiceIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleVoiceIntent(intent)
    }

    private fun handleVoiceIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        if (action == "android.media.action.MEDIA_PLAY_FROM_SEARCH" ||
            action == Intent.ACTION_SEARCH ||
            action == "com.google.android.gms.actions.SEARCH_ACTION") {
            
            val query = intent.getStringExtra(SearchManager.QUERY) 
                ?: intent.getStringExtra("query")
                ?: intent.getStringExtra("android.intent.extra.focus")
                ?: ""

            if (query.isNotEmpty()) {
                val deepLinkUri = Uri.parse("cloudbeatz://play?songName=" + Uri.encode(query))
                intent.data = deepLinkUri
            }
        }
    }
}
