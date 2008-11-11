# HelpfulValidations

module HelpfulValidations
  DYNAMIC_VALIDATION_METHODS_REGEX = /^(\w+)_is_valid\?$/

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

        def method_missing( method_name, *args, &block )
          if match = method_name.to_s.match( DYNAMIC_VALIDATION_METHODS_REGEX )
            attribute = match[ 1 ]
            raise "Unknown attribute: #{ attribute }" unless respond_to?( attribute )
            return attribute_is_valid?( attribute )
          end

          super
        end
      end
      
      module ClassMethods
        def validates( *args ) 
          raise ArgumentError, "Block not given." unless block_given?
          options = args.last.is_a?( Hash ) ? args.pop : {}
          error_message = options[ :message ] || "is invalid"
          
          validates_each( *args ) do | record, attribute, value |
            unless yield( value )
              record.errors.add( attribute, error_message )
            end
          end
        end

        def attributes_are_valid?( attributes = {} )
          return true if attributes.empty?
          model = self.new( attributes )
          model.attributes_are_valid?( *attributes.keys )
        end

        def method_missing( method_name, *args, &block )
          if match = method_name.to_s.match( DYNAMIC_VALIDATION_METHODS_REGEX )
            attribute = match[ 1 ]
            value = args.first

            raise "Uknown attribute: #{ attribute }" unless respond_to?( attribute )
            raise ArgumentError, "Value for attribute not given" if args.empty?
            
            return attributes_are_valid?( attribute => value )
          end

          super
        end
      end
    end
  end
end
