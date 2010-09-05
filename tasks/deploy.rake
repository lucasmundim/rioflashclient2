require 'ruby-debug'

module Helpers
  def self.replace(string, key, value)
    string.gsub!("${#{key}}", value.to_s)
  end

  def self.flashvars
    flashvars = ['${flashvars}']
    flashvars << "environment=#{ENV['PLAYER_ENV']}" if ENV['PLAYER_ENV']
    flashvars << "#{ENV['FLASH_VARS']}" if ENV['FLASH_VARS']
    flashvars.join('&')
  end

  def self.generate_html_from_template(debug=false)
    template = File.read(File.join(root, 'html-template', 'index.template.html'))
    replace(template, :width, 640)
    replace(template, :height, 400)
    replace(template, :application, 'Main')
    replace(template, :swf, debug ? 'player-debug' : 'player')
    replace(template, :flashvars, flashvars)
    template
  end
  
  def self.write_template_file(debug=false)
    template = generate_html_from_template(debug)
    open(File.join(root, 'bin', 'index.html'), 'wb') do |file|
      file.write(template)
    end
  end
  
  def self.root
    File.expand_path('..', File.dirname(__FILE__))
  end
end

desc 'Cleans bin dir'
task :clean_bin do
  FileUtils.rm_rf Dir[File.join(Helpers.root, 'bin', '**', '*')]
end

desc 'Generate HTML file from template in html-template for debug'
task :generate_html_debug do
  Helpers.write_template_file(true)
end

desc 'Generate HTML file from template in html-template'
task :generate_html do
  Helpers.write_template_file
end

desc 'Copies template assets to bin dir'
task :copy_assets do
  #source_dirs = [:images, :javascripts, :stylesheets].map { |dir| File.join(Helpers.root, 'html-template', dir.to_s) }
  #destination_dir = File.join(Helpers.root, 'bin')
  #FileUtils.cp_r source_dirs, destination_dir
end

desc 'Copies templates assets and generates HTML file for debug'
task :assets_debug => [:copy_assets, :generate_html_debug]

desc 'Copies templates assets and generates HTML file for debug'
task :assets => [:copy_assets, :generate_html]

desc 'Compiles Player SWF and generate necessary assets for development environment'
task :debug => [:clean_bin, :clean_bin, :assets_debug, :compile_and_debug]

desc 'Compiles Player SWF and generate necessary assets for production environment'
task :deploy => [:clean_bin, :assets, :compile]
