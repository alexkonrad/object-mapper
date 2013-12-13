require 'active_record_lite/05_associatable2'

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
end
