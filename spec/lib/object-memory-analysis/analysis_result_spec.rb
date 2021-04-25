require 'object-memory-analyzer/analysis_result'

describe ObjectMemoryAnalyzer::AnalysisResult do
  describe '#aggregate' do
    it 'sums stuff by class' do
      klass = Class.new
      test_obj = klass.new

      expect(subject.self_by_class[klass]).to be 0
      subject.aggregate(test_obj, 123, 456)
      expect(subject.self_by_class[klass]).to be 123
      expect(subject.total_by_class[klass]).to be 456
    end

    it 'keeps track of memory sizes for the given object' do
      klass = Class.new
      test_obj_1 = klass.new
      test_obj_2 = klass.new

      expect(subject.self_by_object_id[test_obj_1.object_id]).to be nil
      subject.aggregate(test_obj_1, 123, 456)
      expect(subject.self_by_object_id[test_obj_1.object_id]).to be 123
      expect(subject.total_by_object_id[test_obj_1.object_id]).to be 456

      expect(subject.self_by_object_id[test_obj_2.object_id]).to be nil
      subject.aggregate(test_obj_2, 234, 567)
      expect(subject.self_by_object_id[test_obj_2.object_id]).to be 234
      expect(subject.total_by_object_id[test_obj_2.object_id]).to be 567
    end
  end
end
