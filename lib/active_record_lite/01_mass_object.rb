require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  my_attr_accessor :attributes

  def self.my_attr_accessible(*new_attributes)
    @attributes ||= []
    new_attributes.each do |attr, val|
      instance_variable_set("@#{attr}", val)
      @attributes << attr
    end
  end

  def self.attributes
    raise "must not call #attributes on MassObject directly" if self == MassObject
    @attributes ||= []
    #instance_variables.map {|var| var.to_s.gsub("@","").to_sym}
  end

  def initialize(params = {})
    params.keys.each do |key|
      if self.class.attributes.include?(key.to_sym)
        instance_variable_set("@#{key.to_s}", params[key])
      else
        raise "mass assignment to unregistered attribute 'z'"
      end
    end
  end
end
