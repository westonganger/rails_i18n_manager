module RailsI18nManager
  module GoogleTranslate
    require 'easy_translate'

    def self.translate(text, from:, to:)
      api_key = RailsI18nManager.config.google_translate_api_key

      if !supported_locales.include?(to.to_s) || Rails.env.test? || (api_key.blank? && Rails.env.development?)
        return false
      end

      if text.include?("<") && text.include?(">")
        ### Dont translate any HTML strings
        return nil
      end

      translation = EasyTranslate.translate(text, from: from, to: to, key: api_key)

      if translation
        str = translation.to_s

        if str.present?
          ### Replace single quote html entity with single quote character
          str = str.gsub("&#39;", "'")

          if to.to_s == "es"
            str = str.gsub("% {", " %{").strip
          end

          return str
        end
      end
    end

    ### List retrieved from Google Translate (2022)
    @@supported_locales = ["af", "am", "ar", "az", "be", "bg", "bn", "bs", "ca", "ceb", "co", "cs", "cy", "da", "de", "el", "en", "eo", "es", "et", "eu", "fa", "fi", "fr", "fy", "ga", "gd", "gl", "gu", "ha", "haw", "he", "hi", "hmn", "hr", "ht", "hu", "hy", "id", "ig", "is", "it", "iw", "ja", "jw", "ka", "kk", "km", "kn", "ko", "ku", "ky", "la", "lb", "lo", "lt", "lv", "mg", "mi", "mk", "ml", "mn", "mr", "ms", "mt", "my", "ne", "nl", "no", "ny", "or", "pa", "pl", "ps", "pt", "ro", "ru", "rw", "sd", "si", "sk", "sl", "sm", "sn", "so", "sq", "sr", "st", "su", "sv", "sw", "ta", "te", "tg", "th", "tk", "tl", "tr", "tt", "ug", "uk", "ur", "uz", "vi", "xh", "yi", "yo", "zh", "zh-CN", "zh-TW", "zu"].freeze
    mattr_reader :supported_locales

    ### FOR official client
    # require "google/cloud/translate/v2" ### Offical Google Translate with API Key
    # def self.client
    #   @@client ||= begin
    #     api_key = RailsI18nManager.config.google_translate_api_key
    #     if Rails.env.test? || (api_key.blank? && Rails.env.development?)
    #       ### Skip Client
    #       nil
    #     else
    #       Google::Cloud::Translate::V2.new(key: api_key)
    #     end
    #   end
    # end
    # def self.supported_locales
    #   @@suported_locales ||= begin
    #     if client
    #       @@supported_locales = client.languages.map{|x| x.code}
    #     else
    #       []
    #     end
    #   end
    # end
    # def self.translate(text, from:, to:)
    #   if client
    #    begin
    #       translation = client.translate(text, from: from, to: to)
    #     rescue Google::Cloud::InvalidArgumentError
    #       ### Error usually caused by an unsupported locale
    #       return nil
    #     end
    #   end
    # end

  end
end
