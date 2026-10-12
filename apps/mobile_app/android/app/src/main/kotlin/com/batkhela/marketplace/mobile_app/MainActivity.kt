package com.batkhela.marketplace.mobile_app

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "batkhela/location"
    private val LOCATION_PERMISSION_REQ_CODE = 4401
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getCurrentLocation") {
                    handleGetCurrentLocation(result)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun handleGetCurrentLocation(result: MethodChannel.Result) {
        val fineGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED
        val coarseGranted = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        if (!fineGranted && !coarseGranted) {
            pendingResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ),
                LOCATION_PERMISSION_REQ_CODE
            )
            return
        }

        resolveHardwareLocation(result)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == LOCATION_PERMISSION_REQ_CODE) {
            val res = pendingResult
            pendingResult = null
            if (res != null) {
                val granted = grantResults.isNotEmpty() &&
                    grantResults.any { it == PackageManager.PERMISSION_GRANTED }
                if (granted) {
                    resolveHardwareLocation(res)
                } else {
                    res.error("PERMISSION_DENIED", "Location permission denied by user", null)
                }
            }
        }
    }

    @Suppress("MissingPermission")
    private fun resolveHardwareLocation(result: MethodChannel.Result) {
        try {
            val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            val providers = listOf(
                LocationManager.GPS_PROVIDER,
                LocationManager.NETWORK_PROVIDER,
                LocationManager.PASSIVE_PROVIDER
            )

            var bestLocation: Location? = null
            for (provider in providers) {
                if (locationManager.isProviderEnabled(provider)) {
                    val loc = locationManager.getLastKnownLocation(provider)
                    if (loc != null) {
                        if (bestLocation == null || loc.accuracy < bestLocation!!.accuracy) {
                            bestLocation = loc
                        }
                    }
                }
            }

            if (bestLocation != null) {
                result.success(
                    mapOf(
                        "lat" to bestLocation!!.latitude,
                        "lng" to bestLocation!!.longitude,
                        "accuracy" to bestLocation!!.accuracy.toDouble(),
                        "bearing" to bestLocation!!.bearing.toDouble()
                    )
                )
                return
            }

            // Request fresh single fix from active provider with 4.5s timeout
            val activeProvider = when {
                locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) -> LocationManager.GPS_PROVIDER
                locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER) -> LocationManager.NETWORK_PROVIDER
                else -> null
            }

            if (activeProvider == null) {
                result.error("GPS_DISABLED", "Location services disabled", null)
                return
            }

            var replied = false
            val handler = Handler(Looper.getMainLooper())
            val listener = object : LocationListener {
                override fun onLocationChanged(loc: Location) {
                    if (!replied) {
                        replied = true
                        locationManager.removeUpdates(this)
                        result.success(
                            mapOf(
                                "lat" to loc.latitude,
                                "lng" to loc.longitude,
                                "accuracy" to loc.accuracy.toDouble(),
                                "bearing" to loc.bearing.toDouble()
                            )
                        )
                    }
                }
                override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
                override fun onProviderEnabled(provider: String) {}
                override fun onProviderDisabled(provider: String) {}
            }

            locationManager.requestLocationUpdates(
                activeProvider,
                0L,
                0f,
                listener,
                Looper.getMainLooper()
            )

            handler.postDelayed({
                if (!replied) {
                    replied = true
                    locationManager.removeUpdates(listener)
                    result.error("TIMEOUT", "GPS fix timeout", null)
                }
            }, 4500L)
        } catch (e: Exception) {
            result.error("LOCATION_ERROR", e.message, null)
        }
    }
}

