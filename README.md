# SpreeTemando

`spree_temando` adds support to Spree to calculate a shipping quote
using [Temando](https://www.temando.com).

## Installation

Add this line to your application's Gemfile:

    gem 'spree_temando'

And then execute:

    $ bundle
    $ rake spree_temando:install:migrations
    $ rake db:migrate

Or install it yourself as:

    $ gem install spree_temando

Finally, in an initializer, set up your authentication keys :

```ruby
Temando::Api::Base.config.username = ENV['TEMANDO_USERNAME']
Temando::Api::Base.config.password = ENV['TEMANDO_PASSWORD']
```

## Usage

The extension adds a new Shipping calculator.

Add a new Shipping Method from the Spree Admin (under Configuration >
Shipping Methods), and you can set the relevant calculator type to
`Temando`.

There are a few options you must fill out :

* `Origin Suburb` - the suburb you will be shipping from.
* `Origin Postcode` - the postcode you will be shipping from.
* `Express` - select this to find the fastest & cheapest shipping quote.

It is possible to create multiple calculators with different settings -
for example, a "Regular" method with Express disabled, and an "Express"
method with Express enabled.

In the calculations, the extension always attempts to find the cheapest
quote, but when `Express` is selected, only the quotes with the smallest
`maximum_eta` are considered.

It's important to note that all products in the cart must have their
dimensions filled out (height, length, depth, weight), otherwise Temando
will not be able to quote.

## Notes

The extension only makes requests to the Temando API when the order
changes in some way - either address details, line items, or the like.
This ensures that a customer going back and forth between the Address
and Delivery pages does not bombard the Temando API with spurious
requests.

However, each time the calculator is used *does* cause another request.
For example, the example of two shipping methods above will cause two
requests to the API for the relevant quotes, even though they expect the
same data.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
