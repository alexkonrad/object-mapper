require 'active_record_lite/01_mass_object'

# Use these if you like.
describe MassObject do
  before(:all) do
    class EmptyMassObject < MassObject
    end

    class MyMassObject < MassObject
      my_attr_accessor :x, :y
      my_attr_accessible :x, :y
    end
  end

  it "::attributes starts out empty" do
    EmptyMassObject.attributes.should be_empty
  end

  it "::attriburtes cannot be called directly on MassObject" do
    expect {
      MassObject.attributes
    }.to raise_error("must not call #attributes on MassObject directly")
  end

  it "::my_attr_accessible sets self.attributes" do
    MyMassObject.attributes.should eq([:x, :y])
  end

  it "#initialize performs mass-assignment" do
    obj = MyMassObject.new(:x => "xxx", :y => "yyy")

    obj.x.should eq("xxx")
    obj.y.should eq("yyy")
  end

  it "#initialize doesn't mind string keys" do
    obj = MyMassObject.new("x" => "xxx", "y" => "yyy")

    obj.x.should eq("xxx")
    obj.y.should eq("yyy")
  end

  it "#initialize rejects unregistered keys" do
    expect {
      obj = MyMassObject.new(:z => "zzz")
    }.to raise_error("mass assignment to unregistered attribute 'z'")
  end
end
