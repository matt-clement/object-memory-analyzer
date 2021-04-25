require 'object-memory-analyzer/analysis_result'

module ObjectMemoryAnalyzer
  class Analyzer
    attributes = %i[result seen self_owned_object_ids]

    attr_reader *attributes

    def initialize
      self.result = AnalysisResult.new
      self.seen = Set.new

      # Exclude objects owned by the analyzer from being analyzed.
      # This prevents a problem where we would try to modify a hash while
      # iterating over it, which raises an error.
      self.self_owned_object_ids = Set.new
      self_owned_object_ids << self.object_id
      self_owned_object_ids << self_owned_object_ids.object_id
      self_owned_object_ids << result.object_id
      self_owned_object_ids << result.self_by_class.object_id
      self_owned_object_ids << result.self_by_object_id.object_id
      self_owned_object_ids << result.total_by_class.object_id
      self_owned_object_ids << result.total_by_object_id.object_id
      self_owned_object_ids << seen.object_id
      self_owned_object_ids << seen.instance_variable_get(:@hash).object_id
    end

    def analyze_objects(objects)
      objects.each { |object| analyze_object(object) }
      result
    end

    def analyze_object(object)
      get_full_size(object, result, seen)
      result
    end

    private

    def get_full_size(obj, result, seen)
      if result.total_by_object_id.key?(obj.object_id)
        return result.total_by_object_id[obj.object_id]
      elsif self_owned_object_ids.include?(obj.object_id)
        return 0
      end

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

    attr_writer *attributes
  end
end
