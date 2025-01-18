module RailsI18nManager
  module ApplicationHelper

    def custom_form_for(*args, **options, &block)
      options[:builder] = CustomFormBuilder
      if options.has_key?(:defaults)
        @_custom_form_for_defaults = options.delete(:defaults)
      end
      form_for(*args, options, &block)
    end

    def custom_fields_for(*args, **options, &block)
      options[:builder] = CustomFormBuilder
      if options.has_key?(:defaults)
        @_custom_form_for_defaults = options.delete(:defaults)
      end
      fields_for(*args, options, &block)
    end

    def breadcrumb_item(title, url=nil)
      if url.nil?
        %Q(<span class="breadcrumb-item">#{title}</span>).html_safe
      else
        %Q(<span class="breadcrumb-item"><a href="#{url}">#{title}</a></span>).html_safe
      end
    end

    def sort_link(attr_name, label=nil)
      if label.blank?
        label = attr_name.to_s.titleize
      end

      direction = params[:direction].present? && params[:direction].casecmp?("asc") ? 'desc' : 'asc'

      link_to label, params.to_unsafe_h.merge(sort: attr_name, direction: direction)
    end

    def nav_link(name, url, html_options={}, &block)
      url = url_for(url)

      if html_options.has_key?(:active)
        active = html_options.delete(:active)
      elsif url == (url.include?("?") ? request.fullpath : request.path)
        active = true
      end

      html_options[:class] ||= ""

      html_options[:class] += " nav-link"

      if active
        html_options[:class] += " active"
      end

      html_options[:class].strip!

      content_tag(:li, class: "nav-item #{'active' if active}".strip) do
        link_to(name, url, html_options) + (
          if block_given?
            content_tag(:ul) do
              capture(&block)
            end
          end
        )
      end
    end

  end
end
