require 'active_record_lite/04_associatable'

describe "AssocParams" do
  describe "BelongsToOptions" do
    it "provides defaults" do
      options = BelongsToOptions.new("house")

      expect(options.foreign_key).to eq(:house_id)
      expect(options.other_class_name).to eq("House")
      expect(options.primary_key).to eq(:id)
    end

    it "allows overrides" do
      options = BelongsToOptions.new("owner", {
          :foreign_key => :human_id,
          :other_class_name => "Human",
          :primary_key => :human_id
        })

      expect(options.foreign_key).to eq(:human_id)
      expect(options.other_class_name).to eq("Human")
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe "HasManyOptions" do
    it "provides defaults" do
      options = HasManyOptions.new("cats", "Human")

      expect(options.foreign_key).to eq(:human_id)
      expect(options.other_class_name).to eq("Cat")
      expect(options.primary_key).to eq(:id)
    end

    it "allows overrides" do
      options = HasManyOptions.new("cats", "Human", {
          :foreign_key => :owner_id,
          :other_class_name => "Kitten",
          :primary_key => :human_id
        })

      expect(options.foreign_key).to eq(:owner_id)
      expect(options.other_class_name).to eq("Kitten")
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe "AssocParams" do
    before(:all) do
      class Cat < SQLObject
      end

      class Human < SQLObject
        self.table_name = "humans"
      end
    end

    it "#other_class returns class of associated object" do
      options = BelongsToOptions.new("human")
      expect(options.other_class).to eq(Human)
      expect(options.other_table).to eq("humans")

      options = HasManyOptions.new("cats", "Human")
      expect(options.other_class).to eq(Cat)
      expect(options.other_table).to eq("cats")
    end
  end
end

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
      expect(cat).to respond_to(:human)
      expect(human).to respond_to(:house)
    end

    it "adds an association that returns correct type" do
      cat.human.should be_instance_of(Human)
      human.house.should be_instance_of(House)
    end
  end

  describe "#has_many" do
    it "association as method" do
      expect(human).to respond_to(:cats)
    end

    it "adds an association that returns correct type" do
      human.cats.first.should be_instance_of(Cat)
    end
  end
end
