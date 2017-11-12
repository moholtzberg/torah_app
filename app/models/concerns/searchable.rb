module Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    def search(filtering_params)
      results = self.where(nil)
      filtering_params.each do |key, value|
        results = results.where("#{key} LIKE ?","%#{value}%") if value.present? &&
                                                                 self.column_names.include?(key)
      end
      results
    end
  end
end
