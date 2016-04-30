require 'spec_helper'

describe SK::Api::Schema do
  context 'reading' do

    before :each do
      SK::Api::Schema.registry_reset
    end

    it "should provide schema path" do
      File.exists?(SK::Api::Schema.path).should be
    end

    it "should read json schema file" do
      schema = SK::Api::Schema.read(:invoice, 'v1.0')
      schema[:title].should == 'invoice'
      schema[:type].should == 'object'
      schema['properties'].should be_a Hash
      schema['properties']['id']['identity'].should == true
    end

    it "should read json schema file with simple version" do
      schema = SK::Api::Schema.read(:invoice, '1.0')
      schema[:title].should == 'invoice'
      schema[:type].should == 'object'
      schema['properties'].should be_a Hash
      schema['properties']['id']['identity'].should == true
    end

    it "should read all json schemas" do
      schemas = SK::Api::Schema.read_all('1.0')

      file_path = File.join(File.dirname(__FILE__), '../json', 'v1.0', '*.json')
      # just check file count
      schemas.length.should == Dir.glob( file_path ).length
    end

    it "reads v2 json schemas" do
      schemas = SK::Api::Schema.read_all('2.0')

      file_path = File.join(File.dirname(__FILE__), '../json', 'v2.0', '*.json')
      # just check file count
      schemas.length.should == Dir.glob( file_path ).length
    end

    it "should raise error if version folder does not exist" do
      lambda{
        SK::Api::Schema.read(:invoice, 'v3.0')
      }.should raise_error
    end

    it "should raise error if schema file does not exist" do
      lambda{
        SK::Api::Schema.read(:nope, 'v1.0')
      }.should raise_error
    end

    it "should add schema to registry" do
      SK::Api::Schema.read(:credit_note, 'v1.0')
      File.should_not_receive(:open)
      SK::Api::Schema.read(:credit_note, 'v1.0')
    end

  end

  context 'object parsing' do

    before :each do
      @invoice =  Invoice.new
      @invoice.id = 'some-uuid'
      @invoice.title = 'Your Invoice'
      @invoice.number = '911'

      @client =  Client.new
      @client.id = 'some-uuid'
      @client.organisation = 'Dirty Food Inc.'
      @client.number = '911'

      @item =  LineItem.new
      @item.id = 'some-uuid'
      @item.type = 'LineItem'
      @item.name = 'Pork Chops'
      @item.description = 'Yummi Pork chopped by mexian emigrants'
      @item.position = 1
      @item.price_single = 0.99
    end

    it "should parse object with empty relations from schema" do
      obj_hash = SK::Api::Schema.to_hash_from_schema(@invoice, 'v1.0')
      #   {"invoice"=>{"number"=>"911", "line_items"=>[], "archived_pdf"=>nil, "title"=>"Your Invoice", "date"=>nil, "id"=>"some-uuid", "client"=>nil, "due_date"=>nil}}
      obj_hash.keys.sort.should == ["invoice", "links"]
      obj_hash['invoice'].should include( "number"=>"911","line_items"=>[],"archived_pdf"=>nil,"id"=>"some-uuid", "title"=>"Your Invoice" )
      client_obj_hash = SK::Api::Schema.to_hash_from_schema(@client, 'v1.0')
      client_obj_hash.keys.sort.should == ["client", "links"]
      client_obj_hash['client'].should include("number"=>"911", "addresses"=>[], "id"=>"some-uuid", "organisation"=>"Dirty Food Inc.", "last_name"=>nil)
    end

    it "should parse object with relations from schema" do
      @invoice.line_items = [@item]
      @invoice.client = @client
      obj_hash = SK::Api::Schema.to_hash_from_schema(@invoice, 'v1.0')
      obj_hash["invoice"]['client']['client'].should == {"number"=>"911", "addresses"=>[], "id"=>"some-uuid", "organisation"=>"Dirty Food Inc.", "last_name"=>nil}
      obj_hash["invoice"]["client"]['links'].should_not be_nil
      obj_hash["invoice"]["line_items"].should == [ {"line_item"=>{"name"=>"Pork Chops", "position"=>1, "type"=>"LineItem",
                                                    "id"=>"some-uuid", "description"=>"Yummi Pork chopped by mexian emigrants", "price_single"=>0.99}}]
    end

    it "should parse object given fields" do
      @invoice.line_items = [@item]
      @invoice.client = @client
      fields = %w(id title client)
      obj_hash = SK::Api::Schema.to_hash_from_schema(@invoice, 'v1.0', :fields=>fields)
      obj_hash["invoice"]['client']['client'].should == {"number"=>"911", "addresses"=>[], "id"=>"some-uuid", "organisation"=>"Dirty Food Inc.", "last_name"=>nil}
      obj_hash["invoice"]["client"]['links'].should_not be_nil
      obj_hash["invoice"].keys.sort.should == fields.sort
    end

    it "should use different class name as object hash key" do
      @invoice.line_items = [@item]
      @invoice.client = @client
      obj_hash = SK::Api::Schema.to_hash_from_schema(@invoice, 'v1.0', :class_name=>:document)
      schema = SK::Api::Schema.read(:document, 'v1.0')
      # check included fields, which should not be all fields from schema since our dummy invoice object does not responds_to all
      intersect_keys = schema['properties'].keys & obj_hash["document"].keys
      intersect_keys.sort.should == obj_hash["document"].keys.sort
    end
  end

  context 'hash cleaning' do

    it "should kick readonly properties" do
      props = {'id'=>'some id', 'archived_pdf'=>'some val', 'number'=>'1234' }
      SK::Api::Schema.clean_hash!(:invoice, props, 'v1.0')
      props.keys.should == ['number']

      props1 = {:id =>'some id', :archived_pdf =>'some val', :number =>'1234' }
      SK::Api::Schema.clean_hash!(:invoice, props1, 'v1.0')
      props1.keys.should == [:number]
    end

    it "should convert string properties" do
      props = {'title'=>4711, 'number'=>1234 }
      SK::Api::Schema.clean_hash!(:invoice, props, 'v1.0')
      props['title'].should == "4711"
      props['number'].should == "1234"
    end

    it "should keep some properties" do
      props = {'id'=>'some id', 'number'=>1234 }
      SK::Api::Schema.clean_hash!(:invoice, props, 'v1.0', :keep=>['id'])
      props['id'].should == "some id"
    end

  end
end

################################################################################
# virtual classes used in test
class Invoice
  attr_accessor :id, :title, :description, :number, :date, :due_date,
                :line_items, :archived_pdf, :items,
                :client, :contact
end

class LineItem
  attr_accessor :id, :name, :description, :position, :price_single, :type
end

class Client
  attr_accessor :id, :organisation, :last_name, :number, :addresses
end
