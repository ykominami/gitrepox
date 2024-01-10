# frozen_string_literal: true

# require_relative 'loggerx'
require_relative "gitrepox/cli"
require_relative "gitrepox/version"

require_relative "gitrepox/gitrepox"
require_relative "gitrepox/gitrepoxgroup"
require_relative "gitrepox/util"
require_relative "gitrepox/gsession"

# require 'debug'

module Gitrepox
  class Error < StandardError; end
  # Your code goes here...
end
