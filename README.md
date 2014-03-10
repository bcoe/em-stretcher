Em::Stretcher
=============

An EventMachine port of [Stretcher](https://github.com/PoseBiz/stretcher) (a Fast, Elegant, ElasticSearch client.).

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
