require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    eval(class_name)
  end

  def table_name
    class_name.underscore.pluralize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @name = name
    @foreign_key = options[:foreign_key] || (name.to_s + "_id").underscore.to_sym
    @class_name  = options[:class_name]  || name.to_s.camelcase.singularize
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @name, @self_class_name = name, self_class_name
    @foreign_key = options[:foreign_key] || (self_class_name + "_id").underscore.to_sym
    @class_name  = options[:class_name]  || name.to_s.camelcase.singularize
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    belongs_to_options = BelongsToOptions.new(name, options)

    # method to return an object from the database
    define_method(name.to_s) do
      foreign_table = belongs_to_options.class_name.underscore.pluralize
      query = <<-SQL
      SELECT #{foreign_table}.*
      FROM #{foreign_table}
      WHERE id = ?
      SQL

      foreign_key = self.send(belongs_to_options.foreign_key)
      p DBConnection.execute(query, foreign_key)
      objects = eval(belongs_to_options.class_name).parse_all(DBConnection.execute(query, foreign_key))
      objects[0]
    end

  end

  def has_many(name, options = {})
    has_many_options = HasManyOptions.new(name, self.name, options)

    # method to return an object from the database
    define_method(name.to_s) do
      foreign_table = has_many_options.class_name.underscore.pluralize
      foreign_key = has_many_options.foreign_key.to_s
      query = <<-SQL
      SELECT #{foreign_table}.*
      FROM #{foreign_table}
      WHERE #{foreign_key} = ?
      SQL

      primary_key = self.send(has_many_options.primary_key)
      p DBConnection.execute(query, primary_key)
      objects = eval(has_many_options.class_name).parse_all(DBConnection.execute(query, primary_key))
      objects
    end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
  # Mixin Associatable here...
end
