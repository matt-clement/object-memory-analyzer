require 'objspace'

module ObjectMemoryAnalyzer
  extend self

  def get_full_size(obj, seen = Set.new)
    byte_size = ObjectSpace.memsize_of(obj)
    seen << obj.object_id
    obj.instance_variables.each do |instance_variable_name|
      referenced_object = obj.instance_variable_get(instance_variable_name)
      referenced_object_id = referenced_object.object_id
      if !seen.include?(referenced_object_id)
        seen << referenced_object_id
        byte_size += get_full_size(referenced_object, seen)
      end
    end

    # There is most definitely a better way of doing this. However, enumerable
    # objects can be infinite or input streams that may hang forever. I have
    # limited this to Arrays and Hashes for now to keep things simple.
    if obj.is_a?(Array) || obj.is_a?(Hash)
      obj.each { |item| byte_size += get_full_size(item, seen) }
    end
    byte_size
  end
end
