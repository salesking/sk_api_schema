require 'spec/spec_helper'

describe SK::Api::Schema do

  it "should read json schema file" do
    schema = SK::Api::Schema.read(:invoice, 'v1.0')
    schema[:title].should == 'invoice'
    schema[:type].should == 'object'
    schema['properties'].should be_a Hash
    schema['properties']['id']['identity'].should be_true
  end

  it "should read json schema file with simple version" do
    schema = SK::Api::Schema.read(:invoice, '1.0')
    schema[:title].should == 'invoice'
    schema[:type].should == 'object'
    schema['properties'].should be_a Hash
    schema['properties']['id']['identity'].should be_true
  end

  it "should read all json schemas" do
    schemas = SK::Api::Schema.read_all('1.0')
    
    file_path = File.join(File.dirname(__FILE__), '../json', 'v1.0', '*.json')
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

end

describe SK::Api::Schema, 'object parsing' do

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
    @item.name = 'Pork Chops'
    @item.description = 'Yummi Pork chopped by mexian emigrants'
    @item.position = 1
    @item.price_single = 0.99
  end

  it "should parse object with empty relations from schema" do
    obj_hash = SK::Api::Schema.to_hash_from_schema(@invoice, 'v1.0')
    #   {"invoice"=>{"number"=>"911", "line_items"=>[], "archived_pdf"=>nil, "title"=>"Your Invoice", "date"=>nil, "id"=>"some-uuid", "client"=>nil, "due_date"=>nil}}
    obj_hash.keys.should == ["invoice", "links"]
    obj_hash['invoice'].should include( "number"=>"911","line_items"=>[],"archived_pdf"=>nil,"id"=>"some-uuid", "title"=>"Your Invoice" )
    client_obj_hash = SK::Api::Schema.to_hash_from_schema(@client, 'v1.0')
    client_obj_hash.keys.should == ["client", "links"]
    client_obj_hash['client'].should include("number"=>"911", "addresses"=>[], "id"=>"some-uuid", "organisation"=>"Dirty Food Inc.", "last_name"=>nil)
  end

  it "should parse object with relations from schema" do
    @invoice.line_items = [@item]
    @invoice.client = @client
    obj_hash = SK::Api::Schema.to_hash_from_schema(@invoice, 'v1.0')
    obj_hash["invoice"]['client']['client'].should == {"number"=>"911", "addresses"=>[], "id"=>"some-uuid", "organisation"=>"Dirty Food Inc.", "last_name"=>nil}
    obj_hash["invoice"]["client"]['links'].should == []
    obj_hash["invoice"]["line_items"].should == [ {'links'=>[], "line_item"=>{"name"=>"Pork Chops", "position"=>1, \
                                       "id"=>"some-uuid", "description"=>"Yummi Pork chopped by mexian emigrants", "price_single"=>0.99}}]
  end

end

################################################################################
# virtual classes used in test
class Invoice
  attr_accessor :id, :title, :description, :number, :date, :due_date, :line_items, :client, :archived_pdf
end

class LineItem
  attr_accessor :id, :name, :description, :position, :price_single
end
class Client
  attr_accessor :id, :organisation, :last_name, :number, :addresses
end