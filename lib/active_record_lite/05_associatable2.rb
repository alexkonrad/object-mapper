require_relative '04_associatable'

# Phase V
module Associatable
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
