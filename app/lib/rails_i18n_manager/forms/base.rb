module RailsI18nManager
  module Forms
    class Base
      include ActiveModel::Validations

      def initialize(attrs={})
        attrs ||= {}

        attrs.each do |k,v|
          self.send("#{k}=", v) ### Use send so that it checks that attr_accessor has already defined the method so its a valid attribute
        end
      end

      def to_key
        nil
      end

      def model_name
        sanitized_class_name = self.class.name.to_s.gsub("Forms::", '').gsub(/Form$/, '')
        ActiveModel::Name.new(self, self.class.superclass, sanitized_class_name)
      end

    end
  end
end
