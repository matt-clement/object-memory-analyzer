require_relative "lib/object-memory-analyzer/version"

Gem::Specification.new do |s|
  s.name = 'object-memory-analyzer'
  s.version = ObjectMemoryAnalyzer::VERSION
  s.summary = "A tool to analyze the memory usage of objects"
  s.description = "A tool to analyze the memory usage of objects"
  s.authors = ["Matthew Clement"]
  s.email = 'clement.matthewp@gmail.com'
  s.files = [
    "lib/object-memory-analyzer.rb",
    "lib/object-memory-analyzer/analysis_result.rb",
    "lib/object-memory-analyzer/version.rb",
  ]
  s.homepage = 'https://github.com/matt-clement/object-memory-analyzer'
  s.license = 'MIT'
end
