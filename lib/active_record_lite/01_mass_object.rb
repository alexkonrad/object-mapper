require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  def self.my_attr_accessible(*new_attributes)
    # ...
  end

  def self.attributes
    # ...
  end

  def initialize(params = {})
    # ...
  end
end
