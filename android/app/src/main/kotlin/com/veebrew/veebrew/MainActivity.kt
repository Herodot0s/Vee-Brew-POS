package com.veebrew.veebrew

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    companion object {
        init {
            android.util.Log.e("VeebrewMainActivity", "MainActivity companion init started. SDK_INT is: " + android.os.Build.VERSION.SDK_INT)
            try {
                Class.forName("android.os.LocaleList")
                android.util.Log.e("VeebrewMainActivity", "LocaleList exists, not modifying SDK_INT")
            } catch (e: ClassNotFoundException) {
                android.util.Log.e("VeebrewMainActivity", "LocaleList does not exist! Spoofed device detected.")
                if (android.os.Build.VERSION.SDK_INT >= 24) {
                    try {
                        val field = android.os.Build.VERSION::class.java.getField("SDK_INT")
                        field.isAccessible = true
                        android.util.Log.e("VeebrewMainActivity", "Successfully retrieved SDK_INT field")
                        
                        var modifiersField: java.lang.reflect.Field? = null
                        try {
                            modifiersField = java.lang.reflect.Field::class.java.getDeclaredField("accessFlags")
                            android.util.Log.e("VeebrewMainActivity", "Found accessFlags field")
                        } catch (e1: NoSuchFieldException) {
                            try {
                                modifiersField = java.lang.reflect.Field::class.java.getDeclaredField("modifiers")
                                android.util.Log.e("VeebrewMainActivity", "Found modifiers field")
                            } catch (e2: NoSuchFieldException) {
                                android.util.Log.e("VeebrewMainActivity", "Neither accessFlags nor modifiers found")
                            }
                        }
                        
                        if (modifiersField != null) {
                            modifiersField.isAccessible = true
                            modifiersField.setInt(field, field.modifiers and java.lang.reflect.Modifier.FINAL.inv())
                            android.util.Log.e("VeebrewMainActivity", "Cleared FINAL modifier")
                        }
                        
                        field.set(null, 22)
                        android.util.Log.e("VeebrewMainActivity", "Successfully set SDK_INT to 22. New SDK_INT: " + android.os.Build.VERSION.SDK_INT)
                    } catch (ex: Exception) {
                        android.util.Log.e("VeebrewMainActivity", "Failed to modify SDK_INT", ex)
                    }
                }
            }
        }
    }
}
