module Stretcher
  # Represents an index  scoped to a specific type.
  # Generally should be instantiated via Index#type(name).
  class IndexType
    # Retrieves the document by ID.
    # Normally this returns the contents of _source, however, if the 'raw' flag is passed in, it will return the full response hash.
    # Returns nil if the document does not exist.
    # 
    # The :fields argument can either be a csv String or an Array. e.g. [:field1,'field2] or "field1,field2".
    # If the fields parameter is passed in those fields are returned instead of _source.
    #
    # If, you include _source as a field, along with other fields you MUST set the raw flag to true to 
    # receive both fields and _source. Otherwise, only _source will be returned
    def get(id, options={})      
      request(:get, id, options)
        .bind! do |res|
          res._source || res.fields
        end
    end
  end
end
