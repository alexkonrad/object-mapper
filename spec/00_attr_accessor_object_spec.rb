require '00_attr_accessor_object'

describe AttrAccessorObject do
  before(:all) do
    class MyAttrAccessorObject < AttrAccessorObject
      my_attr_accessor :x, :y
    end
  end

  subject(:obj) { MyAttrAccessorObject.new }

  it "#my_attr_accessor should add #x and #y" do
    obj.should respond_to(:x)
    obj.should respond_to(:y)
  end

  it "#my_attr_accessor should add #x= and #y=" do
    obj.should respond_to(:x=)
    obj.should respond_to(:y=)
  end

  it "#my_attr_accessor methods should get and set" do
    obj.x = "xxx"
    obj.y = "yyy"

    obj.x.should eq("xxx")
    obj.y.should eq("yyy")
  end
end
