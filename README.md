# Object Mapper
Object-relational mapping library implementing ActiveRecord-style SQL interface and model associations using Ruby metaprogramming techniques.

## Features
### Object attributes
#### `attr_accessor`
```ruby
define_method(name) do
  instance_variable_get("@#{name}")
end
define_method(name.to_s + "=") do |val|
  instance_variable_set("@#{name}", val)
end
```

#### `attr_accessible`
```ruby
@attributes ||= []
new_attributes.each do |attr, val|
  instance_variable_set("@#{attr}", val)
  @attributes << attr
end
```

### SQL Interface

#### `all`, `find`
```ruby
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
```

#### `insert`, `update`
```ruby
def insert
  table_name = self.class.table_name
  query = <<-SQL
  INSERT INTO #{table_name} (#{column_values[1..-1].join(', ')})
  VALUES (#{(["?"] * (attribute_values.count-1)).join(", ")})
  SQL

  DBConnection.execute(query, *attribute_values[1..-1])

  self.id = DBConnection.last_insert_row_id
end
```
```ruby
def update
  table_name = self.class.table_name
  query = <<-SQL
  UPDATE #{table_name}
  SET #{(0...column_values[1..-1].count).map {|i| "#{column_values[1..-1][i]} = ?"}.join(", ")}
  WHERE id = ?
  SQL

  DBConnection.execute(query, *attribute_values[1..-1], attribute_values[0])
end
```

#### `where`
```ruby
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
```
### Associations
#### `belongs_to`
```ruby
def belongs_to(name, options = {})
  belongs_to_options = BelongsToOptions.new(name, options)
  @assoc_options ||= {}
  @assoc_options[name] = belongs_to_options

  # method to return an object from the database
  define_method(name.to_s) do
    foreign_table = belongs_to_options.class_name.underscore.pluralize
    query = <<-SQL
    SELECT #{foreign_table}.*
    FROM #{foreign_table}
    WHERE id = ?
    SQL

    foreign_key = self.send(belongs_to_options.foreign_key)
    DBConnection.execute(query, foreign_key)
    objects = eval(belongs_to_options.class_name).parse_all(DBConnection.execute(query, foreign_key))
    objects[0]
  end
end
```
#### `has_many`
```ruby
def has_many(name, options = {})
  has_many_options = HasManyOptions.new(name, self.name, options)
  @assoc_options ||= {}
  @assoc_options[name] = has_many_options
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
    DBConnection.execute(query, primary_key)
    objects = eval(has_many_options.class_name).parse_all(DBConnection.execute(query, primary_key))
    objects
  end
end
```

#### `has_one_through`
```ruby
def has_one_through(name, through_name, source_name)
  define_method(name) do
    self.send(through_name).send(source_name)
  end
end
```