Em::Stretcher
=============

An EventMachine port of [Stretcher](https://github.com/PoseBiz/stretcher) (a Fast, Elegant, ElasticSearch client.)

Indexes
-------

**Creating an Index**

```ruby
require 'eventmachine'
require "em-stretcher"

EM.run do
  server = EM::Stretcher::Server.new

  server.index('my-index').create
    .callback do |result|
      p result
    end
    .errback do |err|
      p err
    end
end
```

**Deleting an Index**

```ruby
server.index('my-index').delete
	.callback do |result|
	  p result
	end
	.errback do |err|
	  p err
	end
```

Mappings
--------

**Creating a Mapping**

```ruby
mapping = {
  :article => {
    properties: {
      title: { :type => :string }
    }
  }
}

server.index('my-index')
	.type('article')
	.put_mapping(mapping)
	.callback do |result|
		p result
	end
	.errback do |err|
		p err
	end
```

Indexing Documents
------------------

```ruby
id = 33

server.index('my-index')
  .type(mapping_name)
  .put(id, { title: "My Document with the id #{id}" })
  .callback do |response|
    p response
  end
  .errback do |err|
  	p err
  end
```

Searching for Documents
-----------------------

```ruby
server.index('my-index').type('articles')
	.search(size: 50, query: { "query_string" => { "query" => "*" } })
	.documents
	.callback do |r|
		p r
	end
```

When One Thing Leads to Another
-------------------------------

EM::Stretcher uses [Deferrable Gratification](https://github.com/samstokes/deferrable_gratification) for chaining together dependent requests.

Here's a great example of when this comes into play:

* You index several hundred documents in parallel.
* You want to perform a search on the index, with all the documents present.

Here's how you can pull this off with Deferrable Gratification:

```ruby
# Index some documents in parallel.
(0..50).each do |i|
	server.index('my-index')
	  .type('articles')
	  .put(i, { title: "title #{i}" })
	  .callback do |response|
	    p response
	  end
end

# First we wait for the indexing to finish.
server.index('my-index').refresh
	.bind! do

	  # Then we perform the search.
	  server.index('my-index').type('articles')
	    .search(size: 50, query: { "query_string" => { "query" => "*" } })
	    .documents
	    .callback do |r|
	      p r # all 50 results should have been returned.
	    end
	end
```

## Installation

Add this line to your application's Gemfile:

    gem 'em-stretcher'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install em-stretcher

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( http://github.com/bcoe/em-stretcher/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
