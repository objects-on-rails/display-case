require 'erb'

task 'gemspec' do
  gemspec_template = IO.read('display_case.gemspec.erb')
  
  File.open('display_case.gemspec', 'w') do |gemspec_file|  
    gemspec = ERB.new(gemspec_template).result(binding)
    gemspec_file.puts gemspec 
  end
end
