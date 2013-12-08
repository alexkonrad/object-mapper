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

    commands.each { |command| puts command; `#{command}` }
    DBConnection.open(CATS_DB_FILE)
  end

  before(:all) do
    class Cat < SQLObject
      set_table_name("cats")

      my_attr_accessor(:id, :name, :owner_id)
      my_attr_accessible(:id, :name, :owner_id)
    end

    class Human < SQLObject
      set_table_name("humans")

      my_attr_accessor(:id, :fname, :lname, :house_id)
      my_attr_accessible(:id, :fname, :lname, :house_id)
    end
  end

  it "#find finds objects by id" do
    c = Cat.find(1)
    expect(c).not_to be_nil
  end

  it "#saves saves changes to an object" do
    h = Human.find(1)
    n = h.fname
    h.fname = SecureRandom.urlsafe_base64(16)
    h.save
    n.should_not == Human.find(1).fname
  end
end
