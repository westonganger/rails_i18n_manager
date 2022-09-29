module RailsI18nManager
  class CustomFormBuilder < ActionView::Helpers::FormBuilder

    ALLOWED_OPTIONS = [
      :value,
      :name,
      :label,
      :field_wrapper_html,
      :label_wrapper_html,
      :label_html,
      :input_wrapper_html,
      :input_html,
      :required,
      :required_text,
      :help_text,
      :errors,
      :field_layout,
      :view_mode,

      ### SELECT OPTIONS
      :collection,
      :selected,
      :disabled,
      :prompt,
      :include_blank,
    ].freeze

    def error_notification
      @template.render "rails_i18n_manager/form_builder/error_notification", {f: self}
    end

    def view_field(label:, value:, **options)
      field(nil, type: :view, **options.merge(label: label, value: value, view_mode: true))
    end

    def field(method, type:, **options)
      type = type.to_sym

      options = _transform_options(options, method)

      if options[:view_mode]
        return _view_field(method, type, options)
      end

      invalid_options = options.keys - ALLOWED_OPTIONS
      if invalid_options.any?

        raise "Invalid options provided: #{invalid_options.join(", ")}"
      end

      if [:select, :textarea].exclude?(type)
        options[:input_html][:type] = type.to_s
      end

      case type
      when :select
        options[:collection] = _fetch_required_option(:collection, options)

        options = _transform_select_options(options, method)
      when :checkbox
        options = _transform_checkbox_options(options, method)
      else
        if !options[:input_html].has_key?(:value)
          options[:input_html][:value] = object.send(method)
        end
      end

      @template.render("rails_i18n_manager/form_builder/basic_field", {
        f: self,
        method: method,
        type: type,
        options: options,
      })
    end

    private

    def _view_field(method, type, options)
      options[:input_html][:class] ||= ""
      options[:input_html][:class].concat(" form-control-plaintext").strip!
      options[:input_html][:readonly] = true
      options[:input_html][:type] = "text"
      options[:input_html].delete(:name)

      if !options[:input_html].has_key?(:value)
        options[:input_html][:value] = _determine_display_value(method, type, options)
      end

      @template.render("rails_i18n_manager/form_builder/basic_field", {
        f: self,
        method: method,
        type: :view,
        options: options,
      })
    end

    def _defaults
      @_defaults ||= (@template.instance_variable_get(:@_custom_form_for_defaults) || {}).deep_symbolize_keys!
    end

    def _attr_presence_required?(attr)
      if attr && object.respond_to?(attr)
        (@object.try(:klass) || @object.class).validators_on(attr).any?{|x| x.kind.to_sym == :presence }
      end
    end

    def _fetch_required_option(key, options)
      if !options.has_key?(key)
        raise ArgumentError.new("Missing required option :#{key}")
      end
      options[key]
    end

    def _determine_display_value(method, type, options)
      case type
      when :checkbox
        options[:input_html]&.has_key?(:checked) ? options[:input_html][:checked] : @object.send(method)
      when :select
        if options.has_key?(:selected)
          val = options[:selected]
        else
          if options[:input_html].has_key?(:value)
            val = options[:input_html].delete(:value)
          else
            val = object.send(method)
          end
        end

        selected_opt = options[:collection].detect { |opt|
          val == (opt.is_a?(Array) ? opt[1] : opt)
        }

        selected_opt.is_a?(Array) ? selected_opt[0] : selected_opt
      else
        options[:input_html]&.has_key?(:value) ? options[:value] : @object.send(method)
      end
    end

    def _transform_options(options, method)
      options.deep_symbolize_keys!

      options = _defaults.merge(options)

      options[:label] = options.has_key?(:label) ? options[:label] : method.to_s.titleize

      options[:field_wrapper_html] ||= {}
      options[:label_wrapper_html] ||= {}
      options[:label_html] ||= {}
      options[:input_wrapper_html] ||= {}
      options[:input_html] ||= {}

      ### Shortcuts for some input_html arguments
      [:value, :name].each do |key|
        if options.has_key?(key) && !options[:input_html].has_key?(key)
          options[:input_html][key] = options[key]
        end
      end

      options[:field_wrapper_html][:class] ||= ""
      options[:field_wrapper_html][:class].concat(" form-group").strip!

      if !options.has_key?(:field_layout)
        options[:field_layout] = :vertical
      end
      options[:field_layout] = options[:field_layout].to_sym

      options[:required] = options.has_key?(:required) ? options[:required] : _attr_presence_required?(method)

      options[:required_text] ||= "*"

      options[:field_wrapper_html][:class].concat(" #{method}_field").strip!

      if method && !options.has_key?(:errors)
        options[:errors] = @object.errors[method]
      end

      if options[:errors].present?
        options[:input_html][:class] ||= ""
        options[:input_html][:class].concat(" is-invalid")
      end

      options
    end

    def _transform_select_options(options, method)
      if !options.has_key?(:selected)
        if options[:input_html].has_key?(:value)
          options[:selected] = options[:input_html].delete(:value)
        else
          options[:selected] = object.send(method)
        end
      end

      if options[:disabled].is_a?(TrueClass) && !options[:input_html].has_key?(:disabled)
        options.delete(:disabled)
        options[:input_html][:disabled] = true
      end

      options
    end

    def _transform_checkbox_options(options, method)
      if options[:input_html].has_key?(:value) && !options[:input_html].has_key?(:checked)
        options[:input_html][:checked] = (object.send(method) == options[:input_html][:value])
      elsif @object.class.respond_to?(:columns_hash) && @object.class.columns_hash[method]&.type == :boolean
        if !options[:input_html].has_key?(:checked)
          if options[:input_html].has_key?(:value)
            options[:input_html][:checked] = (options[:input_html][:value] == true)
          else
            options[:input_html][:checked] = (object.send(method) == true)
          end
        end

        if !options[:input_html].has_key?(:value)
          options[:input_html][:value] = "1"
        end
      end

      options
    end

  end
end
