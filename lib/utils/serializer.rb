module SKApi
  module Utils
    # Mixed into Resources::Base providing to_hash and to_json serialisation for
    # SKApi Resources.
    # Inside SalesKing this serialising is used to render the output.
    # f.ex. in the clients api controller
    #   => SKApi::Resources::Client.to_json(a_client)
    # This way you can keep your API client up to date by using the resources and
    # relying on  SKApi::Resources::Client.schema
    module Serializer
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        
        def schema_to_hash

        end

        # Create a Hash with the available (api)object attributes defined in api_fields.
        #
        # ==== Parameter
        # obj<object>:. An ruby object which is returned as hash
        def to_hash_from_schema(obj)
          # first set the root node to the objects class name as symbol
          obj_class_name =  obj.class.name.split('::').last.underscore
#          obj_class_name = obj.class.to_s.underscore.to_sym
          data = { obj_class_name => {} }
          # iterate over the defined api fields hash
          self.schema_props.each do |field, props| 
            if props['type'] == 'array'
              # always set the field, so the user can expect an empty array
              data[obj_class_name][field] = []    
              if rel_objects = obj.send( field )
                rel_objects.each do |rel_obj|
                  # setup scope for related class
                  klass = "SKApi::Resources::#{rel_obj.class}".constantize
                  # call related objects to_hash_from_schema method ex: data[:client][:addresses] << SKApi::Models::Address.to_hash_from_schema(object)
                  data[obj_class_name][field] << klass.to_hash_from_schema(rel_obj)
                end
              end
            elsif props['type'] == 'object'     # a singular resource TODO should we add an empty object?
              if rel_obj = obj.send( field )
                klass = "SKApi::Resources::#{rel_obj.class}".constantize
                # ex: data['invoice']['client'] = SKApi::Models::Client.to_hash_from_schema(client)
                data[obj_class_name][field] = klass.to_hash_from_schema(rel_obj)
              end
              else # a simple field which can be directly called, only added of objects know its
              data[obj_class_name][field] = obj.send(field) if obj.respond_to?(field.to_sym)
            end
          end
          data
        end

        def to_json(obj)
          data = self.to_hash_from_schema(obj)
#          data[:links] = self.api_links
          ActiveSupport::JSON.encode(data)
        end

      end #ClassMethods

    end #mixin
  end #utils
end #SKApi