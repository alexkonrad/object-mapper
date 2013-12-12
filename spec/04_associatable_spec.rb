require 'active_record_lite/04_associatable'

describe "Associatable" do
  before(:each) { DBConnection.reset }
  after(:each) { DBConnection.reset }

  before(:all) do
    class Cat < SQLObject
      my_attr_accessible :id, :name, :owner_id
      my_attr_accessor :id, :name, :owner_id

      belongs_to(
        :human,
        :class_name => "Human",
        :primary_key => :id,
        :foreign_key => :owner_id
      )

      has_one_through :house, :human, :house
    end

    class Human < SQLObject
      self.table_name = "humans"
      my_attr_accessible :id, :fname, :lname, :house_id
      my_attr_accessor :id, :fname, :lname, :house_id

      has_many :cats, :foreign_key => :owner_id
      belongs_to :house
    end

    class House < SQLObject
      my_attr_accessible :id, :address, :house_id
      my_attr_accessor :id, :address, :house_id

      has_many :humans
    end
  end

  let(:cat) { Cat.find(1) }
  let(:human) { Human.find(1) }

  describe "#belongs_to" do
    it "adds association as method" do
      cat.methods.should include(:human)
      human.methods.should include(:house)
    end

    it "adds an association that returns correct type" do
      cat.human.should be_instance_of(Human)
      human.house.should be_instance_of(House)
    end
  end

  describe "#has_many" do
    it "association as method" do
      human.methods.should include(:cats)
    end

    it "adds an association that returns correct type" do
      human.cats.first.should be_instance_of(Cat)
    end
  end
end
