require 'object-memory-analyzer/analyzer'
require 'objspace'

module ObjectMemoryAnalyzer
  def self.analyze_objects(objects)
    Analyzer.new.analyze_objects(objects)
  end

  def self.analyze_object(object)
    Analyzer.new.analyze_object(object)
  end
end
