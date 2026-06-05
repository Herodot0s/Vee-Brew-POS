package io.flutter.plugin.localization;

import android.content.Context;
import android.content.res.Configuration;
import android.os.Build;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.systemchannels.LocalizationChannel;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class LocalizationPlugin {
  @NonNull private final Context context;
  @NonNull private final LocalizationChannel localizationChannel;

  public LocalizationPlugin(
      @NonNull Context context, @NonNull LocalizationChannel localizationChannel) {
    this.context = context;
    this.localizationChannel = localizationChannel;
  }

  @Nullable
  @SuppressWarnings("deprecation")
  public Locale resolveNativeLocale(@Nullable List<Locale> supportedLocales) {
    if (supportedLocales == null || supportedLocales.isEmpty()) {
      return null;
    }

    // Android improved the localization resolution algorithms after API 24 (7.0, Nougat).
    // LanguageRange and Locale.lookup was added in API 26.
    if (Build.VERSION.SDK_INT >= 26) {
      try {
        List<Object> languageRanges = new ArrayList<>();
        Object localeList = context.getResources().getConfiguration().getClass().getMethod("getLocales").invoke(context.getResources().getConfiguration());
        int localeCount = (int) localeList.getClass().getMethod("size").invoke(localeList);
        
        Class<?> languageRangeClass = Class.forName("java.util.Locale$LanguageRange");
        java.lang.reflect.Constructor<?> langRangeConstructor = languageRangeClass.getConstructor(String.class);
        
        for (int index = 0; index < localeCount; ++index) {
          Locale locale = (Locale) localeList.getClass().getMethod("get", int.class).invoke(localeList, index);
          String fullRange = locale.getLanguage();
          if (!locale.getScript().isEmpty()) {
            fullRange += "-" + locale.getScript();
          }
          if (!locale.getCountry().isEmpty()) {
            fullRange += "-" + locale.getCountry();
          }
          languageRanges.add(langRangeConstructor.newInstance(fullRange));
          languageRanges.add(langRangeConstructor.newInstance(locale.getLanguage()));
          languageRanges.add(langRangeConstructor.newInstance(locale.getLanguage() + "-*"));
        }
        
        Locale platformResolvedLocale = (Locale) Locale.class.getMethod("lookup", List.class, java.util.Collection.class)
            .invoke(null, languageRanges, supportedLocales);
        if (platformResolvedLocale != null) {
          return platformResolvedLocale;
        }
        return supportedLocales.get(0);
      } catch (Exception e) {
        // Fallback to legacy/API 24
      }
    }

    if (Build.VERSION.SDK_INT >= 24) {
      try {
        Object localeList = context.getResources().getConfiguration().getClass().getMethod("getLocales").invoke(context.getResources().getConfiguration());
        int size = (int) localeList.getClass().getMethod("size").invoke(localeList);
        for (int index = 0; index < size; ++index) {
          Locale preferredLocale = (Locale) localeList.getClass().getMethod("get", int.class).invoke(localeList, index);
          // Look for exact match.
          for (Locale locale : supportedLocales) {
            if (preferredLocale.equals(locale)) {
              return locale;
            }
          }
          // Look for exact language only match.
          for (Locale locale : supportedLocales) {
            if (preferredLocale.getLanguage().equals(locale.toLanguageTag())) {
              return locale;
            }
          }
          // Look for any locale with matching language.
          for (Locale locale : supportedLocales) {
            if (preferredLocale.getLanguage().equals(locale.getLanguage())) {
              return locale;
            }
          }
        }
        return supportedLocales.get(0);
      } catch (Exception e) {
        // Fallback to legacy
      }
    }

    // Legacy locale resolution (API < 24)
    Locale preferredLocale = context.getResources().getConfiguration().locale;
    if (preferredLocale != null) {
      // Look for exact match.
      for (Locale locale : supportedLocales) {
        if (preferredLocale.equals(locale)) {
          return locale;
        }
      }
      // Look for exact language only match.
      for (Locale locale : supportedLocales) {
        if (preferredLocale.getLanguage().equals(locale.toString())) {
          return locale;
        }
      }
    }
    return supportedLocales.get(0);
  }

  @SuppressWarnings("deprecation")
  public void sendLocalesToFlutter(@NonNull Configuration config) {
    List<Locale> locales = new ArrayList<>();
    if (Build.VERSION.SDK_INT >= 24) {
      try {
        Object localeList = config.getClass().getMethod("getLocales").invoke(config);
        int size = (int) localeList.getClass().getMethod("size").invoke(localeList);
        for (int i = 0; i < size; i++) {
          Locale locale = (Locale) localeList.getClass().getMethod("get", int.class).invoke(localeList, i);
          locales.add(locale);
        }
      } catch (Exception e) {
        locales.add(config.locale);
      }
    } else {
      locales.add(config.locale);
    }
    localizationChannel.sendLocales(locales);
  }

  @NonNull
  public static Locale localeFromString(@NonNull String localeString) {
    localeString = localeString.replace('_', '-');
    String parts[] = localeString.split("-", -1);
    String languageCode = parts[0];
    String scriptCode = "";
    String countryCode = "";
    int index = 1;
    if (parts.length > index && parts[index].length() == 4) {
      scriptCode = parts[index];
      index++;
    }
    if (parts.length > index && parts[index].length() >= 2 && parts[index].length() <= 3) {
      countryCode = parts[index];
      index++;
    }
    return new Locale(languageCode, countryCode, scriptCode);
  }
}
