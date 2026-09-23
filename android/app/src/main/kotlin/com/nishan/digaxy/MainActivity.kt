package com.nishan.digaxy

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.googlemaps.GoogleMapsPlugin

class MainActivity : FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		GeneratedPluginRegistrant.registerWith(flutterEngine)
		if (!flutterEngine.plugins.has(GoogleMapsPlugin::class.java)) {
			flutterEngine.plugins.add(GoogleMapsPlugin())
		}
	}
}
