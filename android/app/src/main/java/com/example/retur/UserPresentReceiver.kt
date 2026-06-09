package com.example.retur

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Refreshes the widgets when the user unlocks the phone, so data is fresh right when they're
 * about to look at the home screen. Registered statically in the manifest.
 */
class UserPresentReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_USER_PRESENT) {
            refreshWidgetsNow(context)
        }
    }
}
