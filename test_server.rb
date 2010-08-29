#!/usr/bin/env ruby

require 'logger'
require 'socket'
require 'fileutils'
require 'rubygems'
require 'active_support/core_ext'
require 'ruby-debug'

class TestServer < TCPServer
  PORT = 22222
  TESTS_FAILED_FILE = 'tests_failed.txt'
  LOG_FILE = 'test_server.log'
  
  attr_accessor :logger
  attr_accessor :client
  attr_accessor :report
  
  def initialize
    configure_logger    
    logger.info 'Starting test server...'
    clean
    configure_signals
    super(PORT)
  end
  
  def configure_logger
    FileUtils.touch LOG_FILE
    File.truncate LOG_FILE, 0
    
    self.logger = Logger.new LOG_FILE
    logger.level = Logger::INFO
  end
  
  def clean
    logger.info 'Cleaning test failure file'
    FileUtils.rm_f TESTS_FAILED_FILE
  end
  
  def configure_signals
    trap 'SIGINT' do
      quit
    end
  end
  
  def start!
    wait_for_client
    
    while has_more_data?
      handle_client
    end
    
    logger.info 'Tests finished, quitting.'
  rescue SignalException
    quit 0, 'server execution interrupted by user.'
  rescue SystemExit
    quit 0, 'server execution interrupted by user.'
  rescue Exception => e
    logger.error "An error happened while accepting clients: #{e}\n#{e.backtrace.join("\n")}"
    quit 1
  end
  
  def quit(exit_code=0, message=nil)
    logger.warn "Quitting: #{message}" if message
    exit exit_code
  end
  
  def wait_for_client
    logger.info 'Waiting for client...'
    self.client = accept
    @has_more_data = true
    logger.info 'Client accepted.'
    create_report
  end
  
  def handle_client
    receive_response
  end
  
  def create_report
    self.report = Report.new
  end
  
  def receive_response
    response = client.gets
    if response.present?
      parse(response)
    else
      quit(0, 'client disconnected.')
    end
  end
  
  def parse(response)
    data = ActiveSupport::JSON.decode(response)
    case data['type']
    when 'test'
      parse_test(data)
    when 'results'
      parse_results(data)
    else
      logger.warn "Received unknown message: #{response}"
    end
  end
  
  def parse_test(data)
    report.tests << data
    
    if (data['status'] == 'success')
      logger.info "Test passed: #{data['name']}"
    else
      logger.error "Test #{data['status']}: #{data['name']}"
    end
  end
  
  def parse_results(data)
    report.results.merge!(data)
    
    logger.info "Tests finished in #{data['elapsed_time'].to_f/1000} seconds: #{data['test_count']} tests, #{data['failures_count']} failed, #{data['ignored_count']} ignored."
    
    logger.info "Creating report..."
    report.save!
    
    create_failed_file if report.failed?
    @has_more_data = false
  end
  
  def create_failed_file
    logger.info "Tests failed, creating failed file."
    FileUtils.touch TESTS_FAILED_FILE
  end
  
  def has_more_data?
    @has_more_data
  end
end

class Report
  REPORT_FILE = 'test_report.txt'
  
  attr_accessor :tests
  attr_accessor :results
  
  def initialize
    self.tests = []
    self.results = { 'successful' => false }
  end
  
  def save!
    open REPORT_FILE, 'wb' do |file|
      save_tests(file)
      save_results(file)
    end
  end
  
  def save_tests(file)
    tests.each do |test|
      send("save_#{test['status']}_test", file, test)
    end
  end
  
  def save_success_test(file, test)
    file.puts " * #{test['name']}"
  end
  
  def save_failure_test(file, test)
    file.puts " F #{test['name']}"
    save_backtrace(file, test)
  end
  
  def save_error_test(file, test)
    file.puts " E #{test['name']}"
    save_backtrace(file, test)
  end
  
  def save_backtrace(file, test)
    file.puts "   ===  Backtrace: #{test['message']}"
    test['backtrace'].each do |backtrace|
      file.puts "     #{backtrace}"
    end
    file.puts
  end
  
  def save_results(file)
    file.puts "=" * 80

    if success?
      file.puts " Tests finished successfully in #{results['elapsed_time'].to_f/1000} seconds."
    else
      file.puts " Tests failed in #{results['elapsed_time'].to_f/1000} seconds."
    end

    file.puts " #{results['test_count']} tests, #{results['failures_count']} failed, #{results['ignored_count']} ignored"
  end
  
  def failed?
    not success?
  end
  
  def success?
    results['successful']
  end
end

server = TestServer.new
server.start!
