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

        def method_missing( method_name, *args, &block )
          if match = method_name.to_s.match( /^(\w+)_is_valid\?$/ )
            attribute = match[ 1 ]
            value = args.first

            raise "Uknown attribute: #{ attribute }" unless column_names.include?( attribute )
            raise ArgumentError, "Value for attribute not given" if args.empty?
            
            return attributes_are_valid?( attribute => value )
          end

          super
        end
      end
    end
  end
end
