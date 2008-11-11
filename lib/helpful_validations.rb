# HelpfulValidations

module HelpfulValidations
  def self.included( base )
    base.send( :include, ClassMethods::ValidationHelpers::InstanceMethods )
    base.extend( ClassMethods::ValidationHelpers::ClassMethods )
  end

  module ClassMethods
    module ValidationHelpers
      module InstanceMethods
        def attribute_is_valid?( attribute )
          attributes_are_valid?( attribute )
        end

        def attributes_are_valid?( *attributes )
          valid?

          attributes.all? do | attribute |
            errors[ attribute ].nil?
          end
        end
      end
      
      module ClassMethods
        def attributes_are_valid?( attributes = {} )
          return true if attributes.empty?
          model = self.new( attributes )
          model.attributes_are_valid?( *attributes.keys )
        end
      end
    end
  end
end
