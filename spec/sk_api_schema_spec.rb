require 'spec/spec_helper'

describe SK::Api::Schema do

  it "should read json schema file" do
    schema = SK::Api::Schema.read(:invoice, 'v1.0')
    schema[:title].should == 'invoice'
    schema[:type].should == 'object'
    schema['properties'].should be_a Hash
    schema['properties']['id']['identity'].should be_true
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

  it "should parse object without relations from schema" do
    obj_hash = SK::Api::Schema.to_hash_from_schema(@invoice, 'v1.0')
    obj_hash.should == {"invoice"=>{"number"=>"911", "line_items"=>[], "title"=>"Your Invoice", "id"=>"some-uuid", "date"=>nil, "client"=>nil, "due_date"=>nil}}
    client_obj_hash = SK::Api::Schema.to_hash_from_schema(@client, 'v1.0')
    client_obj_hash.should == {"client"=>{"number"=>"911", "addresses"=>[], "id"=>"some-uuid", "organisation"=>"Dirty Food Inc.", "last_name"=>nil}}
  end

  it "should parse object with relations from schema" do
    @invoice.line_items = [@item]
    @invoice.client = @client
    obj_hash = SK::Api::Schema.to_hash_from_schema(@invoice, 'v1.0')
    obj_hash.should == {"invoice"=>{"number"=>"911", "line_items"=>[{"line_item"=>{"position"=>1, "name"=>"Pork Chops", "id"=>"some-uuid", "description"=>"Yummi Pork chopped by mexian emigrants", "price_single"=>0.99}}], "title"=>"Your Invoice", "id"=>"some-uuid", "date"=>nil, "client"=>{"client"=>{"number"=>"911", "addresses"=>[], "id"=>"some-uuid", "organisation"=>"Dirty Food Inc.", "last_name"=>nil}}, "due_date"=>nil}}
  end

end

################################################################################
# virtual classes used in test
class Invoice
  attr_accessor :id, :title, :description, :number, :date, :due_date, :line_items, :client
end

class LineItem
  attr_accessor :id, :name, :description, :position, :price_single
end
class Client
  attr_accessor :id, :organisation, :last_name, :number, :addresses
end