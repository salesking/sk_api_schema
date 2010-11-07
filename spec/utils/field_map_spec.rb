require 'spec/spec_helper'

describe SKApi::Utils::FieldMap do

  before :each do
    @loc_obj = LocalContact.new
    @rem_obj = RemoteContact.new()
    @map = SKApi::Utils::FieldMap.new(@loc_obj, @rem_obj, map_hash)
  end

  it "should create a mapping" do    
    @map.outdated?.should be_false # both objects are empty
  end

  it "should find outdated fields" do      
    @loc_obj.firstname = 'theo'
    @map.outdated?.should be_true
    @map.outdated.first[:loc_key].should == :firstname    
  end

  it "should update outdated remote fields" do
    @loc_obj.firstname = 'theo'
    @map.update_remote_outdated
    @rem_obj.first_name.should == @loc_obj.firstname
    # test logging
   @map.log.should_not be_empty
  end

  it "should update outdated local fields" do
    @rem_obj.first_name = 'Heinz'
    @map.update_local_outdated
    @rem_obj.first_name.should == @loc_obj.firstname
    @map.log.length.should == 1
  end
#  it "should update outdated local fields" do
#    @rem_obj.first_name = 'Heinz'
#    @map.outdated?
#    @map.update_local_outdated
#    @rem_obj.first_name.should == @loc_obj.firstname
#  end

  def map_hash
    [
      {:loc_key => :firstname,  :rem_key => :first_name},
      {:loc_key => :street,     :rem_key => :address1},
      {:loc_key => :postcode,   :rem_key => :zip},
      {:loc_key => :city,       :rem_key => :city},
      {:loc_key => :gender,     :rem_key => :gender, :trans => { :obj=>'TransferFunctions',
                                                                :loc_trans => 'set_local_gender',
                                                                :rem_trans => 'set_remote_gender'}
      }
    ]
  end

end

class RemoteContact
  attr_accessor :first_name, :address1, :zip, :city, :gender
end
class LocalContact
  attr_accessor :firstname, :street, :postcode, :city, :gender
end

class TransferFunctions
  def self.set_local_gender(remote_val)
    return 'male' if remote_val == 'm'
    return 'female' if remote_val == 'f'
  end
  def self.set_remote_gender(local_val)
    return 'm' if local_val == 'male'
    return 'f' if local_val == 'female'
  end
end