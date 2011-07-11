
require 'rubygems'
require 'test/unit'
require 'mocha'
require 'fileutils'

require File.expand_path('rails_setup', File.dirname(__FILE__))

require 'active_support/test_case'
require 'action_controller/test_case'
require 'action_controller/test_process' unless Rails.version >= '3.0.0'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '../lib')
require 'simple_captcha'

ActiveRecord::Migration.verbose = false # quiet down the migration engine
