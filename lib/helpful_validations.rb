# HelpfulValidations

module HelpfulValidations
  def self.included( base )
    base.extend( ClassMethods::ValidationHelpers )
  end

  module ClassMethods
    module ValidationHelpers
      def fields_are_valid?( fields )
        model = self.new( fields )
        model.valid? # to run the validations
        
        fields.all? do | field, value |
          model.errors[ field ].nil?
        end
      end
    end
  end
end
