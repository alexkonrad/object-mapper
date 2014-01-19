require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    new_objects = results.map do |result|
      self.new(result)
    end

    new_objects
  end
end

class SQLObject < MassObject
  def self.table_name=(table_name)
    @table_name = table_name.underscore.pluralize
  end

  def self.table_name
    @table_name ||= self.to_s.underscore.pluralize
  end

  def self.all
    query = <<-SQL
        SELECT #{table_name}.*
        FROM #{table_name}
        SQL

    parse_all(DBConnection.execute(query))
  end

  def self.find(id)
    query = <<-SQL
    SELECT #{table_name}.*
    FROM #{table_name}
    WHERE id = #{id}
    SQL

    parse_all(DBConnection.execute(query)).first
  end

  def initialize(params = {})
    super(params)
  end

  def insert
    table_name = self.class.table_name
    query = <<-SQL
    INSERT INTO #{table_name} (#{column_values[1..-1].join(', ')})
    VALUES (#{(["?"] * (attribute_values.count-1)).join(", ")})
    SQL

    DBConnection.execute(query, *attribute_values[1..-1])

    self.id = DBConnection.last_insert_row_id
  end

  def save
    self.id ? update : insert
  end

  def update
    table_name = self.class.table_name
    query = <<-SQL
    UPDATE #{table_name}
    SET #{(0...column_values[1..-1].count).map {|i| "#{column_values[1..-1][i]} = ?"}.join(", ")}
    WHERE id = ?
    SQL

    DBConnection.execute(query, *attribute_values[1..-1], attribute_values[0])
  end

  def column_values
    self.class.attributes.map { |col| col.to_s.gsub(":","") }
  end

  def attribute_values
    self.class.attributes.map { |var| self.send(var) }
  end
end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.plural /^(ox)$/i, '\1en'
  inflect.plural 'human', 'humans'
  inflect.singular /^(ox)en/i, '\1'
  inflect.irregular 'person', 'people'
  inflect.uncountable %w( fish sheep )
end