require "spec_helper"

describe EventMachine::Stretcher::Server do
    
  include DeferrableModule

  before(:all) { reset_index }
  
  let(:server) { EventMachine::Stretcher::Server.new }

  describe "index" do
    it "can delete an index" do
      index = server.index(TESTING_INDEX_NAME)
      execute(index, :delete)
      execute(index, :status)
      error_response_should_contain 'IndexMissingException'
    end

    it "can create an index" do
      index = server.index(TESTING_INDEX_NAME)
      execute(index, :delete)
      execute(index, :create, {
        :settings => {
          :number_of_shards => 3,
          :number_of_replicas => 0 
        }
      })
      execute(index, :status)
      success_key_should_have_value([:_shards, :total], 3)
    end
  end

end
