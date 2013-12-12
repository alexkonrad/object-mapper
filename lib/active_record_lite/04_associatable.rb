require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :other_class_name,
    :primary_key,
  )

  def other_class
    @other_class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :foreign_key => "#{name}_id".to_sym,
      :other_class_name => name.to_s.camelcase,
      :primary_key => :id
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{self_class_name.underscore}_id".to_sym,
      :other_class_name => name.to_s.singularize.camelcase,
      :primary_key => :id
    }

    defaults.keys.each do |key|
      self.send("#{key}=", options[key] || defaults[key])
    end
  end
end

# Phase IVb
module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]

      key_val = self.send(options.foreign_key)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          *
        FROM
          #{options.other_table}
        WHERE
          #{options.other_table}.#{options.primary_key} = ?
      SQL

      options.other_class.parse_all(results).first
    end
  end
end

# Phase IVb
module Associatable
  def has_many(name, options = {})
    self.assoc_options[name] =
      HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]

      key_val = self.send(options.primary_key)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          *
        FROM
          #{options.other_table}
        WHERE
          #{options.other_table}.#{options.foreign_key} = ?
      SQL

      options.other_class.parse_all(results)
    end
  end
end

# Phase IVc
module Associatable
  # Go back and modify `belongs_to`/`has_many` to store params in
  # `::assoc_options`.
  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options =
        through_options.other_class.assoc_options[source_name]

      through_table = through_options.other_table
      through_pk = through_options.primary_key
      through_fk = through_options.foreign_key

      source_table = source_options.other_table
      source_pk = source_options.primary_key
      source_fk = source_options.foreign_key

      key_val = self.send(through_fk)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
        WHERE
          #{through_table}.#{through_pk} = ?
      SQL

      source_options.other_class.parse_all(results).first
    end
  end
end

class SQLObject
  extend Associatable
end
