require 'active_record_lite/02_sql_object'
require 'securerandom'

describe SQLObject do
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

  it "::set_table_name sets table name" do
    expect(Human.table_name).to eq("humans")
  end

  it "::table_name generates default name" do
    expect(Cat.table_name).to eq("cats")
  end

  it "::parse_all turns an array of hashes into objects" do
    hashes = [
      { :name => "cat1", :owner_id => 1 },
      { :name => "cat2", :owner_id => 2 }
    ]

    cats = Cat.parse_all(hashes)
    expect(cats.length).to eq(2)
    hashes.each_index do |i|
      expect(cats[i].name).to eq(hashes[i][:name])
      expect(cats[i].owner_id).to eq(hashes[i][:owner_id])
    end
  end

  it "::all returns all the cats" do
    cats = Cat.all

    cats.all? { |cat| expect(cat).to be_instance_of(Cat) }
    expect(cats.count).to eq(2)
  end

  it "#attribute_values returns array of values" do
    cat = Cat.new(:id => 123, :name => "cat1", :owner_id => 1)

    expect(cat.attribute_values).to eq([123, "cat1", 1])
  end

  it "::find finds objects by id" do
    c = Cat.find(1)

    expect(c).not_to be_nil
    expect(c.name).to eq("Breakfast")
  end

  it "#insert inserts a new record" do
    cat = Cat.new(:name => "Gizmo", :owner_id => 1)
    cat.insert

    expect(Cat.all.count).to eq(3)
  end

  it "#insert sets the id" do
    cat = Cat.new(:name => "Gizmo", :owner_id => 1)
    cat.insert

    expect(cat.id).to_not be_nil
  end

  it "#update changes attributes" do
    human = Human.find(2)

    human.fname = "Matthew"
    human.lname = "von Rubens"
    human.update

    # pull the human again
    human = Human.find(2)
    expect(human.fname).to eq("Matthew")
    expect(human.lname).to eq("von Rubens")
  end

  it "#save calls save/update as appropriate" do
    human = Human.new
    expect(human).to receive(:insert)
    human.save

    human = Human.find(1)
    expect(human).to receive(:update)
    human.save
  end
end
