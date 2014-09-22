require 'rake/testtask'

Rake::TestTask.new do |t|
  require 'pry'

  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
