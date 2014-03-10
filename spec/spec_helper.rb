require "rspec"
require "rspec/em"

require_relative '../lib/em-stretcher'

TESTING_INDEX_NAME = 'em::stretcher:testing'

# Helper to reset ElasticSearch index for tests.
def reset_index
  server = Stretcher::Server.new
  i = server.index(TESTING_INDEX_NAME)
  begin
    i.delete
  rescue Stretcher::RequestError::NotFound
  end
  server.refresh
  i.create({
    :settings => {
      :number_of_shards => 1,
      :number_of_replicas => 0
    }
  })
  # Why do both? Doesn't hurt, and it fixes some races
  server.refresh
  i.refresh
  
  attempts_left = 40
  
  # Sometimes the index isn't instantly available
  loop do
    idx_metadata = server.cluster.request(:get, :state)[:metadata][:indices][i.name]
    i_state =  idx_metadata[:state]
    
    break if i_state == 'open'
    
    if attempts_left < 1
        raise "Bad index state! #{i_state}. Metadata: #{idx_metadata}" 
    end

    sleep 0.1
    attempts_left -= 1
  end
end

# async assertions for EventMachine specs.
DeferrableModule = RSpec::EM.async_steps do
  def execute(object, method, *args, &callback)
    deferrable = if args
      object.send(method, *args)
    else
      object.send(method)
    end

    # Search results have their deferrable
    # on the documents key.
    if deferrable.respond_to?(:documents)
      deferrable = deferrable.results
    end

    deferrable.callback do |result|
      @success = result
      callback.call
    end

    deferrable.errback do |err|
      @error = err
      callback.call
    end
  end

  # recursively look for a matching key and value in hash.
  def success_key_should_have_value(key, expected, &callback)
    # walk the hash structure.
    key = [*key]
    while key.count > 0
      @success = @success.send(key.shift)
    end

    @success.should == expected
    @success = nil
    callback.call
  end

  # confirm count of result set.
  def success_result_count_should_equal(expected, &callback)
    @success.count.should == expected
    @success = nil
    callback.call
  end

  # look for substring in error http_response.
  def error_response_should_contain(expected, &callback)
    @error.http_response.should =~ /#{expected}/
    @error = nil
    callback.call
  end
end
