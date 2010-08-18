require 'sprout'
# Optionally load gems from a server other than rubyforge:
# set_sources 'http://gems.projectsprouts.org'
sprout 'as3'

############################################
# Configure your Project Model
project_model :model do |m|
  m.project_name            = 'rioflashclient2'
  m.language                = 'as3'
  m.libraries               << :flexunit4as
  m.compiler_gem_name       = 'sprout-flex4sdk-tool'
  # m.background_color      = '#FFFFFF'
  # m.width                 = 500
  # m.height                = 344
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
end

# desc 'Compile and debug the application'
# debug :debug

desc 'Compile and debug the application'
debug :debug do |t|
  t.input                                 = 'src/Main.as'
  t.strict                                = false
  t.define_conditional                    << "CONFIG::LOGGING,false"
  t.define_conditional                    << "CONFIG::FLASH_10_1,false"
  t.static_link_runtime_shared_libraries  = true
end

desc 'Compile run the test harness'
unit :test do |t|
  t.input                                 = 'test/FlexUnitApplication.as'
  t.library_path                          << 'lib/FlexUnitTestRunner_rb.swc'
  t.library_path                          << 'lib/flexunitextendedAS.swc'
  t.default_size                          = '530 340'
  t.static_link_runtime_shared_libraries  = true
end

desc 'Compile the optimized deployment'
deploy :deploy do |t|
 t.input                                 = 'src/Main.as'
 t.strict                                = false
 t.define_conditional                    << "CONFIG::LOGGING,false"
 t.define_conditional                    << "CONFIG::FLASH_10_1,false"
 t.static_link_runtime_shared_libraries  = true
end

desc 'Create documentation'
document :doc

desc 'Compile a SWC file'
swc :swc

desc 'Compile and run the test harness for CI'
ci :cruise

# set up the default rake task
task :default => :debug
