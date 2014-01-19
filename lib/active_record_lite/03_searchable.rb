require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    table_name = self.table_name
    where = params.keys.select { |col| p attributes.include?(col) }
    where = where.map { |col| "#{col.to_s} = ?" }.join(" AND ")
    query = <<-SQL
    SELECT *
    FROM #{table_name}
    WHERE #{where}
    SQL
    parse_all(DBConnection.execute(query, *params.values))
  end
end

class SQLObject
  extend Searchable
end
