module RailsI18nManager
  module GoogleTranslate

    def self.translate(text, from:, to:)
      api_key = RailsI18nManager.config.google_translate_api_key

      if !SUPPORTED_LOCALES.include?(to.to_s) || Rails.env.test? || (api_key.blank? && Rails.env.development?)
        return false
      end

      if text.include?("<") && text.include?(">")
        ### Dont translate any HTML strings
        return false
      end

      translated_text = EasyTranslate.translate(text, from: from, to: to, key: api_key)

      if translated_text.present?
        ### Replace single quote html entity with single quote character
        translated_text = translated_text.gsub("&#39;", "'")

        if to.to_s == "es"
          translated_text = translated_text.gsub("% {", " %{").strip
        end

        return translated_text
      end
    end

    ### List retrieved from Google Translate (2022)
    SUPPORTED_LOCALES = ["af", "am", "ar", "az", "be", "bg", "bn", "bs", "ca", "ceb", "co", "cs", "cy", "da", "de", "el", "en", "eo", "es", "et", "eu", "fa", "fi", "fr", "fy", "ga", "gd", "gl", "gu", "ha", "haw", "he", "hi", "hmn", "hr", "ht", "hu", "hy", "id", "ig", "is", "it", "iw", "ja", "jw", "ka", "kk", "km", "kn", "ko", "ku", "ky", "la", "lb", "lo", "lt", "lv", "mg", "mi", "mk", "ml", "mn", "mr", "ms", "mt", "my", "ne", "nl", "no", "ny", "or", "pa", "pl", "ps", "pt", "ro", "ru", "rw", "sd", "si", "sk", "sl", "sm", "sn", "so", "sq", "sr", "st", "su", "sv", "sw", "ta", "te", "tg", "th", "tk", "tl", "tr", "tt", "ug", "uk", "ur", "uz", "vi", "xh", "yi", "yo", "zh", "zh-CN", "zh-TW", "zu"].freeze

  end
end
