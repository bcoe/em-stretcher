require "spec_helper"

describe EventMachine::Stretcher::Server do

  DeferrableModule = RSpec::EM.async_steps do
    def execute(object, method, &resume)
      deferrable = object.send(method)

      deferrable.callback do |result|
        @success = result
        resume.call
      end
    end

    def sucess_should_have_key(key, &callback)
      @success.has_key?(key).should == true
      callback.call
    end
  end
    
  include DeferrableModule

  before(:all) { reset_index }
  
  let(:server) { EventMachine::Stretcher::Server.new }
  
  describe "get requests" do
    it "handles a simple get request" do
      execute(server, :status)
      sucess_should_have_key('_shards')
    end
  end
end
