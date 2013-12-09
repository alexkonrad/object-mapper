require_relative '../00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  def self.my_attr_accessible(*new_attributes)
    # make sure all attributes are stored in symbol format
    new_attributes = new_attributes.map(&:to_sym)
    self.attributes.concat(new_attributes)
  end

  def self.attributes
    if self == MassObject
      raise "must not call #attributes on MassObject directly"
    end

    @attributes ||= []
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      # make sure to convert keys to symbols
      attr_name = attr_name.to_sym
      if self.class.attributes.include?(attr_name)
        self.send("#{attr_name}=", value)
      else
        raise "mass assignment to unregistered attribute '#{attr_name}'"
      end
    end
  end
end
