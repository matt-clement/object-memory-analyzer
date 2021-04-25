require 'object-memory-analyzer/analysis_result'
require 'objspace'

module ObjectMemoryAnalyzer
  extend self

  def analyze_objects(objects)
    result = ObjectMemoryAnalyzer::AnalysisResult.new
    seen = Set.new

    objects.each { |object| get_full_size(object, result, seen) }

    result
  end

  def analyze_object(object)
    result = ObjectMemoryAnalyzer::AnalysisResult.new
    seen = Set.new

    get_full_size(object, result, seen)

    result
  end

  private

  def get_full_size(obj, result, seen)
    self_byte_size = ObjectSpace.memsize_of(obj)
    total_byte_size = self_byte_size

    seen << obj.object_id
    obj.instance_variables.each do |instance_variable_name|
      referenced_object = obj.instance_variable_get(instance_variable_name)
      referenced_object_id = referenced_object.object_id
      if !seen.include?(referenced_object_id)
        seen << referenced_object_id
        total_byte_size += get_full_size(referenced_object, result, seen)
      end
    end

    # There is most definitely a better way of doing this. However, enumerable
    # objects can be infinite or input streams that may hang forever. I have
    # limited this to Arrays and Hashes for now to keep things simple.
    if obj.is_a?(Array) || obj.is_a?(Hash)
      obj.each { |item| total_byte_size += get_full_size(item, result, seen) }
    end
    result.aggregate(obj, self_byte_size, total_byte_size)
    total_byte_size
  end
end
