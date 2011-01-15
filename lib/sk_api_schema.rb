require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'
module SK
  module Api
    class Schema

      class << self
        # Read a schema with a given version and return it as hash
        # See ../json folder for available schema's and versions
        # === Parameter
        # schema<String|Symbol>::name of the schema, available ones are in json directory
        # version<String>:: version to read, this is the folder name where the schema is in.
        # === Return
        # <HashWithIndifferentAccess>:: schema as hash
        def read(schema, version)
          # prefix version with v1.0 of v is not present
          v = (version =~ /^v/) ? version : "v#{version}"
          file_path = File.join(File.dirname(__FILE__), '../json', v, "#{schema}.json")
          plain_data = File.open(file_path, 'r'){|f| f.read}
          ActiveSupport::JSON.decode(plain_data).with_indifferent_access
        end

        # Read all available schemas from a given version(folder) and return
        # them as array
        # See ../json folder for available schema's and versions
        # === Parameter
        # schema<String|Symbol>::name of the schema, available ones are in json directory
        # === Return
        # Array[<HashWithIndifferentAccess>]:: array of schemas as hash
        def read_all(version)
          schemas = []
          v = (version =~ /^v/) ? version : "v#{version}"
          file_path = File.join(File.dirname(__FILE__), '../json', v, '*.json')
          Dir.glob( file_path ).each do |file|
            schema = File.open(file, 'r'){|f| f.read}
            schemas << ActiveSupport::JSON.decode(schema).with_indifferent_access
          end
          schemas
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
        # obj<Object>:: An ruby object which is returned as hash
        # version<String>:: the schema version, must be a valid folder name see #self.read
        #
        # === Return
        # <Hash{String=>{String=>Mixed}}>:: The object as hash:
        # { invoice =>{'title'=>'hello world', 'number'=>''4711 } }
        def to_hash_from_schema(obj, version)
          # get objects class name without inheritance
          obj_class_name =  obj.class.name.split('::').last.underscore
          # init data hash
          data = {}
          # get schema
          schema = read(obj_class_name, version)
          # iterate over the defined schema fields
          schema['properties'].each do |field, prop|
            if prop['type'] == 'array'
              data[field] = [] # always set an empty array
              if rel_objects = obj.send( field )
                rel_objects.each do |rel_obj|
                  # call related objects to_hash_from_schema method ex:
                  # data[:client][:addresses] << SKApi::Models::Address.to_hash_from_schema(object)
                  data[field] << to_hash_from_schema(rel_obj, version)
                end
              end
            elsif prop['type'] == 'object' # a singular related object
              data[field] = nil # always set empty val
              if rel_obj = obj.send( field )
                #dont nest field to prevent => client=>{client=>{data} }
                data[field] = to_hash_from_schema(rel_obj, version)
              end
            else # a simple field is only added if the object knows it
              data[field] = obj.send(field) if obj.respond_to?(field.to_sym)
            end
          end
          #add links
          { obj_class_name => data,
            'links' =>  parse_links(obj, schema)
          }
        end

        # Parse the link section of the schema by replacing {id} in urls
        # === Returns
        # <Array[Hash{String=>String}]>::
        def parse_links(obj, schema)
          links = []
          schema['links'] && schema['links'].each do |link|
            links << { 'rel' => link['rel'], 'href' => link['href'].gsub(/\{id\}/, obj.id) }
          end
          links.uniq
        end

      end # class methods
    end
  end
end