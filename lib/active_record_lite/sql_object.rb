require 'active_support/inflector'

require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Associatable
  extend Searchable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT *
        FROM #{table_name}
    SQL

    parse_all(results)
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT *
        FROM #{table_name}
       WHERE id = ?
    SQL

    parse_all(results).first
  end

  def save
    if id.nil?
      create
    else
      update
    end
  end

  private
  def attribute_values
    self.class.attributes.map { |attr| self.send(attr) }
  end

  def create
    attr_names = self.class.attributes.join(", ")
    question_marks = (["?"] * self.class.attributes.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{attr_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.attributes.map { |attr| "#{attr} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE #{self.class.table_name}
         SET #{set_line}
       WHERE id = ?
    SQL
  end
end
