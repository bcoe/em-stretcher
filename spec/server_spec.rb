require "spec_helper"

describe EventMachine::Stretcher::Server do
    
  include DeferrableModule

  before(:all) { reset_index }
  before(:each) { execute(type, :put_mapping, mapping) }
  
  let(:server) { EventMachine::Stretcher::Server.new }
  let(:index) { server.index(TESTING_INDEX_NAME) }
  let(:type) { index.type(mapping_name) }
  let(:mapping_name) { :article }
  let(:mapping) do
    {
      mapping_name => {
        properties: {
          title: { :type => :string }
        }
      }
    }
  end
  let(:document) do 
    {title: 'hello world!' }
  end

  describe "index" do
    it "can delete an index" do
      execute(index, :delete)
      execute(index, :status)
      error_response_should_contain 'IndexMissingException'
    end

    it "can create an index" do
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

  context "creating mappings" do
    it "can create a mapping" do
      type = index.type(mapping_name)
      execute(type, :put_mapping, mapping)
      execute(index, :get_mapping)

      success_key_should_have_value([
        TESTING_INDEX_NAME.to_sym,
        mapping_name
      ], { "properties" => { "title" => { "type"=>"string" } } })
    end
  end

  context "documents" do
    it "can index a document" do
      execute(type, :put, 1, document)
      execute(index, :refresh)
      execute(type, :search)
      success_result_count_should_equal(1)
    end

    it "can fetch a document by its id" do
      execute(type, :put, 1, document)
      execute(index, :refresh)
      execute(type, :get, 1)

      success_key_should_have_value(:title, 'hello world!')
    end

    it "should return a 404 if document is not found" do
      execute(type, :get, 2)

      error_response_should_contain '404'
    end

    it "can delete a document" do
      execute(type, :put, 1, document)
      execute(index, :refresh)
      execute(type, :delete, 1, document)
      execute(index, :refresh)

      execute(type, :search)
      success_result_count_should_equal(0)
    end
  end

  describe "search" do
    it "returns a document if query matches title" do
      execute(type, :put, 1, document)
      execute(index, :refresh)
      execute(type, :search, query: { "query_string" => { "query" => "hello world" } })

      success_result_count_should_equal(1)
    end

    it "does not return a document if query does not match title" do
      execute(type, :put, 1, document)
      execute(index, :refresh)
      execute(type, :search, query: { "query_string" => { "query" => "zebra" } })

      success_result_count_should_equal(0)
    end
  end

end
