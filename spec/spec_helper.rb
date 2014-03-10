require "rspec"
require "rspec/em"

require_relative '../lib/stretcher'

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
