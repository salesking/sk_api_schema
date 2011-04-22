require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'
module SK
  module Api
    class Schema

      class << self

        # class var remembering already read-in schema's
        # {
        #   'v1.0'=>{
        #     :invoice =>{schema}
        #     :credit_note =>{schema}
        #   }
        # }
        # === Return
        #<Hash{String=>Hash{Symbol=>HashWithIndifferentAccess}}>::
        def registry
          @registry ||={}
        end
        
        def registry_reset
          @registry = nil
        end
        # Read a schema with a given version and return it as hash
        # See ../json folder for available schema's and versions
        # === Parameter
        # schema<String|Symbol>::name of the schema, available ones are in json directory
        # version<String>:: version to read, the folder name where the schema is in.
        # Can be used without v-prefix
        # === Return
        # <HashWithIndifferentAccess>:: schema as hash
        def read(schema, version)
          schema = schema.to_sym
          return registry[version][schema] if registry[version] && registry[version][schema]
          # prefix version with v1.0 of v is not present
          v = (version =~ /^v/) ? version : "v#{version}"
          registry[v] = {} unless registry[v]
          # read schema from file
          file_path = File.join(File.dirname(__FILE__), '../json', v, "#{schema}.json")
          plain_data = File.open(file_path, 'r'){|f| f.read}
          # remember & return
          registry[v][schema] = ActiveSupport::JSON.decode(plain_data).with_indifferent_access
        end

        # Read all available schemas from a given version(folder) and return
        # them as array
        # See ../json folder for available schema's and versions
        # === Parameter
        # schema<String|Symbol>:: version to read, equals json/foldername v1.0 or
        # use without prefix 1.0
        # === Return
        # Array[<HashWithIndifferentAccess>]:: array of schemas as hash
        def read_all(version)
          schemas = []
          v = (version =~ /^v/) ? version : "v#{version}"
          registry[v] = {} unless registry[v]
          file_path = File.join(File.dirname(__FILE__), '../json', v, '*.json')
          Dir.glob( file_path ).each do |file|
            schema_name = File.basename(file, ".json").to_sym
            schemas << read(schema_name, v)
          end
          schemas
        end

        # Create a Hash with the available (api)object attributes defined in the
        # according schema properties. This is the meat of the
        # object-to-api-markup workflow
        #
        # === Example
        #  obj = Invoice.new(:title =>'hello world', :number=>'4711')
        #
        #  obj_hash = SK::Api::Schema.to_hash_from_schema(obj, 'v1.0') 
        #   => { 'invoice' =>{'title'=>'hello world', 'number'=>'4711' } }
        #
        #  obj_hash = SK::Api::Schema.to_hash_from_schema(obj, 'v1.0', :fields=>['title'])
        #   => { 'invoice' =>{'title'=>'hello world' } }
        #
        #  obj_hash = SK::Api::Schema.to_hash_from_schema(obj, 'v1.0', :class_name=>:document)
        #   => { 'document' =>{'title'=>'hello world' } }
        #   
        # === Parameter
        # obj<Object>:: An ruby object which is returned as hash
        # version<String>:: the schema version, must be a valid folder name see
        # #self.read
        # opts<Hash{Symbol=>Mixed} >:: additional options
        # 
        # ==== Parameter opts
        # class_name<String|Symbol>:: Name of the class to use as hash key. Should be
        # a lowered, underscored name and it MUST have an existing schema file.
        # Use it to override the default, which is obj.class.name
        # fields<Array[String]>:: Fields/properties to return. If not set all
        # schema's properties are used.
        #
        # === Return
        # <Hash{String=>{String=>Mixed}}>:: The object as hash:
        # { invoice =>{'title'=>'hello world', 'number'=>''4711 } }
        def to_hash_from_schema(obj, version, opts={})
          fields = opts[:fields]
          # get objects class name without inheritance
          real_class_name = obj.class.name.split('::').last.underscore
          class_name =  opts[:class_name] || real_class_name
          data = {}
          # get schema
          schema = read(class_name, version)
          # iterate over the defined schema fields
          schema['properties'].each do |field, prop|
            next if fields && !fields.include?(field)
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
          hsh = { "#{class_name}" => data }
          #add links if present
          real_class_schema = read(real_class_name, version)
          links = parse_links(obj, real_class_schema)
          links && hsh['links'] = links
          # return hash
          hsh
        end

        # Parse the link section of the schema by replacing {id} in urls
        # === Returns
        # <Array[Hash{String=>String}]>::
        # <nil>:: no links present
        def parse_links(obj, schema)
          links = []
          schema['links'] && schema['links'].each do |link|
            links << { 'rel' => link['rel'], 'href' => link['href'].gsub(/\{id\}/, obj.id) }
          end
          links.uniq
          # return links only if not empty
          links.empty? ? nil : links
        end

      end # class methods
    end
  end
end