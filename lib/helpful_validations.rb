# HelpfulValidations

module HelpfulValidations
  def self.included( base )
    base.send( :include, ClassMethods::ValidationHelpers::InstanceMethods )
    base.extend( ClassMethods::ValidationHelpers::ClassMethods )
  end

  module ClassMethods
    module ValidationHelpers
      module InstanceMethods
        def attribute_is_valid?( field )
          valid? # run the validations
          errors[ field ].nil?
        end
      end
      
      module ClassMethods
        def attributes_are_valid?( fields = {} )
          return true if fields.empty?
          model = self.new( fields )
          model.valid? # run the validations
          
          fields.all? do | field, value |
            model.errors[ field ].nil?
          end
        end
      end
    end
  end
end
