module ObjectMemoryAnalyzer
  class AnalysisResult
    attributes = %i[
      self_by_class
      self_by_object_id
      total_by_class
      total_by_object_id
    ]

    attr_reader *attributes

    def initialize
      self.self_by_class = Hash.new(0)
      self.self_by_object_id = {}
      self.total_by_class = Hash.new(0)
      self.total_by_object_id = {}
    end

    def aggregate(obj, self_byte_size, total_byte_size)
      self_by_class[obj.class] += self_byte_size
      self_by_object_id[obj.object_id] = self_byte_size

      total_by_class[obj.class] += total_byte_size
      total_by_object_id[obj.object_id] = total_byte_size

      self
    end

    private

    attr_writer *attributes
  end
end
