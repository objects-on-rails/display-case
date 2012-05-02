require 'ERB'

task :gemspec do
  gemspec_template = IO.read('display-case.gemspec.erb')
  
  File.open('display-case.gemspec', 'w') do |gemspec_file|  
    gemspec = ERB.new(gemspec_template).result(binding)
    gemspec_file.puts gemspec 
  end
end