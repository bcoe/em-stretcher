require "ostruct"
require "stretcher"
require "eventmachine"
require "deferrable_gratification"
require "em-http-request"
require "em/stretcher/server"
require "em/stretcher/version"
require "em/stretcher/search_results"
require "em/stretcher/index_type"

module EventMachine
  module Stretcher
    # Your code goes here...
  end
end

# Enchance deferrables with bind functionality.
DG.enhance_all_deferrables!
DG.enhance! EventMachine::HttpClient
