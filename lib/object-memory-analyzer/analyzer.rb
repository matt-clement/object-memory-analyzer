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
      self_owned_object_ids = Set.new
      self_owned_object_ids << self.object_id
      referenced_objects(self, recurse: true).each do |object|
        self_owned_object_ids << object.object_id
      end
      self.self_owned_object_ids = self_owned_object_ids
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

    attr_writer *attributes

    def get_full_size(obj, result, seen)
      if result.total_by_object_id.key?(obj.object_id)
        return result.total_by_object_id[obj.object_id]
      elsif self_owned_object_ids.include?(obj.object_id)
        return 0
      end

      self_byte_size = ObjectSpace.memsize_of(obj)
      total_byte_size = self_byte_size

      seen << obj.object_id
      referenced_objects(obj).each do |referenced_object|
        referenced_object_id = referenced_object.object_id
        if !seen.include?(referenced_object_id)
          seen << referenced_object_id
          total_byte_size += get_full_size(referenced_object, result, seen)
        end
      end

      result.aggregate(obj, self_byte_size, total_byte_size)
      total_byte_size
    end

    def referenced_objects(object, seen: Set.new, recurse: false)
      Enumerator.new do |y|
        object.instance_variables.each do |instance_variable_name|
          referenced_object = object.instance_variable_get(instance_variable_name)
          next if seen.include?(referenced_object.object_id)
          seen << referenced_object.object_id
          y << referenced_object
          referenced_objects(referenced_object, seen: seen, recurse: recurse).each { |x| y << x } if recurse
        end
        if object.is_a?(Array) || object.is_a?(Hash)
          object.each do |item|
            next if seen.include?(item.object_id)
            seen << item.object_id
            y << item
            referenced_objects(item, seen: seen, recurse: recurse).each { |x| y << x } if recurse
          end
        end
      end
    end
  end
end
