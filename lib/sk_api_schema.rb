require 'activesupport'

module SK
  module Api
    class Schema

      # Read a schema with a given version and return it as hash
      # See ../json folder for available schema's and versions
      # === Parameter
      # schema<String|Symbol>::name of the schema, available ones are in json directory
      # version<String>:: version to read, this is the folder name where the schema is in.
      def self.read(schema, version)
        file_path = File.join(File.dirname(__FILE__), '../json', version, "#{schema}.json")
        plain_data = File.open(file_path, 'r'){|f| f.read}
        ActiveSupport::JSON.decode(plain_data)
      end

      # Create a Hash with the available (api)object attributes defined in
      # schema properties.
      # 
      # === Example
      #  obj = Invoice.new(:title =>'hello world', :number=>'4711')
      #  obj_hash = Sk::Api::Schema.to_hash_from_schema(obj, 'v1.0')
      #
      #  obj_hash => { invoice =>{'title'=>'hello world', 'number'=>'4711' } }
      #
      # === Parameter
      # obj<Object>:. An ruby object which is returned as hash
      # version<String>:. An ruby object which is returned as hash
      # === Return
      # <Hash{String=>{String=>Mixed}}>:: The object as hash:
      # { invoice =>{'title'=>'hello world', 'number'=>''4711 } }
      def self.to_hash_from_schema(obj, version)
        # get objects class name without inheritance
        obj_class_name =  obj.class.name.split('::').last.underscore
        # init data hash
        data = {}
        # get schema
        schema = self.read(obj_class_name, version)
        # iterate over the defined schema fields
        schema['properties'].each do |field, prop|
          if prop['type'] == 'array'
            # always set an empty array
            data[field] = []
            if rel_objects = obj.send( field )
              rel_objects.each do |rel_obj|
                # call related objects to_hash_from_schema method ex: data[:client][:addresses] << SKApi::Models::Address.to_hash_from_schema(object)
                data[field] << self.to_hash_from_schema(rel_obj, version)
              end
            end
          elsif prop['type'] == 'object'     # a singular related object
            data[field] = nil
            if rel_obj = obj.send( field )
              data[field] = self.to_hash_from_schema(rel_obj, version)
            end
          else # a simple field is only added if objects know its
            data[field] = obj.send(field) if obj.respond_to?(field.to_sym)
          end
        end        
        { obj_class_name => data }
      end

    end
  end
end