# Patch search results to play nice with deferrables.
module Stretcher
  # Conveniently represents elastic search results in a more compact fashion
  #
  # Available properties:
  #
  # * raw : The raw response from elastic search
  # * total : The total number of matched docs
  # * facets : the facets hash
  # * results : The hit results with _id merged in to _source
  class SearchResults
    # Returns a 'prettier' version of elasticsearch results
    # Also aliased as +docs+
    # This will:
    #
    # 1. Return either '_source' or 'fields' as the base of the result
    # 2. Merge any keys beginning with a '_' into it as well (such as '_score')
    # 3. Copy the 'highlight' field into '_highlight'
    #
    def documents
      raw_plain.bind! do |result|
        result.hits.hits.map do |hit|
          doc = extract_source(hit)
          copy_underscores(hit, doc)
          copy_highlight(hit, doc)
          doc
        end
      end
    end
    alias_method :docs, :documents
  end
end
