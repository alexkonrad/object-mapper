require 'active_record_lite/02_sql_object'
require 'securerandom'

# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
ROOT_FOLDER = File.join(File.dirname(__FILE__), "..")
CATS_SQL_FILE = File.join(ROOT_FOLDER, "cats.sql")
CATS_DB_FILE = File.join(ROOT_FOLDER, "cats.db")

describe SQLObject do
  before(:each) do
    commands = [
      "rm #{CATS_DB_FILE}",
      "cat #{CATS_SQL_FILE} | sqlite3 #{CATS_DB_FILE}"
    ]

    commands.each { |command| `#{command}` }
    DBConnection.open(CATS_DB_FILE)
  end

  before(:all) do
    class Cat < SQLObject
      my_attr_accessor(:id, :name, :owner_id)
      my_attr_accessible(:id, :name, :owner_id)
    end

    class Human < SQLObject
      self.table_name = "humans"

      my_attr_accessor(:id, :fname, :lname, :house_id)
      my_attr_accessible(:id, :fname, :lname, :house_id)
    end
  end

  it "::set_table_name sets table name" do
    expect(Human.table_name).to eq("humans")
  end

  it "::table_name generates default name" do
    expect(Cat.table_name).to eq("cats")
  end

  it "::all returns all the cats" do
    cats = Cat.all

    cats.all? { |cat| expect(cat).to be_instance_of(Cat) }
    expect(cats.count).to eq(2)
  end

  it "::find finds objects by id" do
    c = Cat.find(1)

    expect(c).not_to be_nil
    expect(c.name).to eq("Breakfast")
  end

  it "#create inserts a new record" do
    cat = Cat.new(:name => "Gizmo", :owner_id => 1)
    cat.create

    expect(Cat.all.count).to eq(3)
  end

  it "#create sets the id" do
    cat = Cat.new(:name => "Gizmo", :owner_id => 1)
    cat.create

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
    expect(human).to receive(:create)
    human.save

    human = Human.find(1)
    expect(human).to receive(:update)
    human.save
  end
end
