require 'sprout'
# Optionally load gems from a server other than rubyforge:
# set_sources 'http://gems.projectsprouts.org'
sprout 'as3'

############################################
# Configure your Project Model
project_model :model do |m|
  m.project_name            = 'rioflashclient2'
  m.language                = 'as3'
  m.compiler_gem_name       = 'sprout-flex4sdk-tool'
  m.background_color        = '#FFFFFF'
  m.width                   = 640
  m.height                  = 400
  # m.use_fdb               = true
  # m.use_fcsh              = true
  # m.preprocessor          = 'cpp -D__DEBUG=false -P - - | tail -c +3'
  # m.preprocessed_path     = '.preprocessed'
  # m.src_dir               = 'src'
  # m.lib_dir               = 'lib'
  # m.swc_dir               = 'lib'
  # m.bin_dir               = 'bin'
  # m.test_dir              = 'test'
  # m.doc_dir               = 'doc'
  # m.asset_dir             = 'assets'
  # m.compiler_gem_version  = '>= 4.0.0'
  # m.source_path           << "#{m.lib_dir}/somelib"
  # m.libraries             << :corelib
  
  m.source_path             << "#{m.lib_dir}/bulkloader-rev-282"
  m.library_path            << 'assets/player_assets.swc'
  m.library_path            << 'lib/OSMF.swc'
  m.library_path            << 'lib/tweener_v1.33.74.swc'
  m.library_path            << 'lib/corelib.swc'
end

Dir['tasks/**/*.rake'].each { |file| load file }

desc 'Compile and debug the application'
debug :compile_and_debug do |t|
  t.debug                                 = true
  t.input                                 = 'src/Main.as'
  t.strict                                = false
  t.define_conditional                    << "CONFIG::LOGGING,false"
  t.define_conditional                    << "CONFIG::FLASH_10_1,false"
  t.static_link_runtime_shared_libraries  = true
end

namespace :test do
  desc 'Starts the test server'
  task :start_server do
    puts "Starting test server test server..."
    system("./test_server.rb &")
  end

  desc 'Copies the fixtures to bin directory'
  task :create_fixtures_symlink do
    require 'fileutils'
    root_dir = File.expand_path(File.dirname(__FILE__))
    source_dir = File.join(root_dir, 'test', 'fixtures')
    symlink = File.join(root_dir, 'bin')
    
    FileUtils.ln_sf source_dir, symlink
  end

  desc 'Compile run the test harness'
  unit :runner => [:start_server, :create_fixtures_symlink] do |t|
    t.debug                                 = true
    t.input                                 = 'test/runner/TestRunner.as'
    t.library_path                          << 'test/lib/flexunit-aircilistener-4.1.0.swc'
    t.library_path                          << 'test/lib/flexunit-cilistener-4.1.0.swc'
    t.library_path                          << 'test/lib/flexunit-core-as3-4.1.0.swc'
    t.library_path                          << 'test/lib/flexunit-uilistener-4.1.0.swc'
    t.default_size                          = '640 400'
    t.static_link_runtime_shared_libraries  = true
  end
end

desc 'Runs both test server and test runner'
task :test => 'test:runner' do
  root_dir = File.expand_path(File.dirname(__FILE__))
  if File.exist?(File.join(root_dir, 'tests_failed.txt'))
    exit 1
  else
    exit 0
  end
end

desc 'Compile the optimized deployment'
deploy :compile do |t|
 t.input                                 = 'src/Main.as'
 t.strict                                = true
 t.define_conditional                    << "CONFIG::LOGGING,false"
 t.define_conditional                    << "CONFIG::FLASH_10_1,false"
 t.static_link_runtime_shared_libraries  = true
end

desc 'Create documentation'
document :doc

desc 'Compile a SWC file'
swc :swc

desc 'Compile and run the test harness for CI'
ci :ci => ['test:start_server', 'test:create_fixtures_symlink'] do |t|
  t.input                                 = 'test/runner/TestRunner.as'
  t.library_path                          << 'test/lib/flexunit-aircilistener-4.1.0.swc'
  t.library_path                          << 'test/lib/flexunit-cilistener-4.1.0.swc'
  t.library_path                          << 'test/lib/flexunit-core-as3-4.1.0.swc'
  t.library_path                          << 'test/lib/flexunit-uilistener-4.1.0.swc'
  t.default_size                          = '640 400'
  t.static_link_runtime_shared_libraries  = true
end

task :cruise => :ci do
  root_dir = File.expand_path(File.dirname(__FILE__))
  if File.exist?(File.join(root_dir, 'tests_failed.txt'))
    exit 1
  else
    exit 0
  end
end

# set up the default rake task
task :default => :debug
