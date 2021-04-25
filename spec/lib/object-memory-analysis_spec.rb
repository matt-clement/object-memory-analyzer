require 'object-memory-analyzer'

describe ObjectMemoryAnalyzer do
  describe '#analyze_objects' do
    it 'aggregates the result for all objects' do
      test_objects = Array.new(10) { |index| "foo_#{index}" }
      test_string = "blahblahblah"
      test_objects << test_string
      test_objects << []
      test_objects << {}

      result = subject.analyze_objects(test_objects)

      expect(result.self_by_class[String]).to eq 440
      expect(result.total_by_class[String]).to eq 440

      expect(result.self_by_class[Array]).to eq 40
      expect(result.total_by_class[Array]).to eq 40

      expect(result.self_by_class[Hash]).to eq 40
      expect(result.total_by_class[Hash]).to eq 40

      expect(result.self_by_object_id[test_string.object_id]).to eq 40
      expect(result.total_by_object_id[test_string.object_id]).to eq 40
    end
  end

  describe '#analyze_object' do
    it 'does the thing' do
      test_object = 'foo'

      result = subject.analyze_object(test_object)

      expect(result.self_by_object_id[test_object.object_id]).to be 40
    end

    it 'includes the size of instance variables' do
      test_class = Class.new
      test_object = test_class.new
      test_object.instance_variable_set(:@foo, 'foo')

      result = subject.analyze_object(test_object)

      expect(result.self_by_object_id[test_object.object_id]).to be 40
      expect(result.total_by_object_id[test_object.object_id]).to be 80
    end

    it 'includes the size of array elements' do
      test_object = Array.new(10) { |index| "foo_#{index}" }

      result = subject.analyze_object(test_object)

      expect(result.self_by_object_id[test_object.object_id]).to be 120
      expect(result.self_by_class[test_object.class]).to be 120
      expect(result.total_by_object_id[test_object.object_id]).to be 520
      expect(result.total_by_class[test_object.class]).to be 520
    end

    it 'includes the size of hash entries' do
      test_object = {
        foo: 'foo',
        bar: 'bar',
      }

      result = subject.analyze_object(test_object)

      expect(result.self_by_object_id[test_object.object_id]).to be 168
      expect(result.self_by_class[test_object.class]).to be 168
      expect(result.total_by_object_id[test_object.object_id]).to be 328
      expect(result.total_by_class[test_object.class]).to be 328
    end
  end
end
