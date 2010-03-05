require 'pathname'

task :package do
  jruby_home = Pathname.new ENV_JAVA['jruby.home']
  jruby_home = jruby_home.readlink while jruby.symlink?
  puts "TODO: zip up everything that #{jruby_home} needs to run this app."
end
