require "rails_i18n_manager/engine"
require "rails_i18n_manager/config"

module RailsI18nManager

  def self.config(&block)
    c = RailsI18nManager::Config

    if block_given?
      block.call(c)
    else
      return c
    end
  end

  # def self.with_fresh_i18n_load_paths(load_paths, &block)
  #   prev_load_path = I18n.load_path

  #   I18n.load_path = load_paths
  #   I18n.backend.reload!

  #   block.call
  # ensure
  #   I18n.load_path = prev_load_path
  #   I18n.backend.reload!
  # end

  def self.fetch_flattened_dot_notation_keys(translations_hash)
    keys = []

    translations_hash.each do |_locale, h|
      h.each do |k,v|
        _recursive_fetch_keys(list: keys, key: k, val: v)
      end
    end

    return keys.uniq
  end

  def self._recursive_fetch_keys(list:, key:, val:, prev_dot_notation_key: nil)
    if prev_dot_notation_key
      dot_notation_key = [prev_dot_notation_key, key].compact.join(".")
    else
      dot_notation_key = key
    end

    if val.is_a?(Hash)
      val.each do |inner_key, inner_val|
        _recursive_fetch_keys(list: list, key: inner_key, val: inner_val, prev_dot_notation_key: dot_notation_key)
      end
    else
      list << dot_notation_key
    end
  end

  def self.hash_deep_set(hash, keys_array, val)
    if !hash.is_a?(::Hash)
      raise TypeError.new("Invalid object passed to #{__method__}, must be a Hash")
    end

    keys_array[0...-1].inject(hash){|result, key|
      if !result[key].is_a?(Hash)
        result[key] = {}
      end

      result[key]
    }.send(:[]=, keys_array.last, val)

    return hash
  end

end
