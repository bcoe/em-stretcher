require "spec_helper"

describe EventMachine::Stretcher::Server do

  DeferrableModule = RSpec::EM.async_steps do
    def execute(object, method, &callback)
      deferrable = object.send(method)

      deferrable.callback do |result|
        @success = result
        callback.call
      end

      deferrable.errback do |err|
        @error = err
        callback.call
      end
    end

    def sucess_should_have_key(key, &callback)
      @success.has_key?(key).should == true
      @success = nil
      callback.call
    end

    def success_key_equals(key, expected, &callback)
      @success[key].should == expected
      @success = nil
      callback.call
    end

    def error_response_should_contain(expected, &callback)
      @error.http_response.should =~ /#{expected}/
      @error = nil
      callback.call
    end
  end
    
  include DeferrableModule

  before(:all) { reset_index }
  
  let(:server) { EventMachine::Stretcher::Server.new }

  describe "index" do
    it "can delete an index" do
      index = server.index(TESTING_INDEX_NAME)
      execute(index, :delete)
      sucess_should_have_key :ok
      execute(index, :status)
      error_response_should_contain 'IndexMissingException'
    end
  end

end
