module RailsI18nManager
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    include ActiveSortOrder

    scope :multi_search, ->(full_str){ 
      if full_str.present?
        rel = self

        full_str.split(' ').each do |q|
          rel = rel.search(q)
        end

        next rel
      end
    }

  end
end
