require 'active_record_lite/03_searchable'

describe "searchable" do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Cat < SQLObject
      my_attr_accessor :id, :name, :owner_id
      my_attr_accessible :id, :name, :owner_id
    end

    class Human < SQLObject
      self.table_name = "humans"

      my_attr_accessor :id, :fname, :lname, :house_id
      my_attr_accessible :id, :fname, :lname, :house_id
    end
  end

  describe "#where" do
    it "returns correct cat" do
      cat = Cat.where(:name => "Breakfast")[0]
      cat.name.should == "Breakfast"
    end

    it "returns correct human" do
      human = Human.where(:fname => "Matt", :house_id => 1)[0]
      human.fname.should == "Matt"
    end
  end
end
