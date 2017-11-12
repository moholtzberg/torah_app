module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(filtering_params)
      results = self.where(nil)
      filtering_params.each do |key, value|
        if value == true || value == "true"
          results = results.public_send(key)
        elsif value.present? && value != "false"
          results = results.public_send(key, value)
        end
      end
      results
    end
  end
end
