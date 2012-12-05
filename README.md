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

*NOTE* this extension assumes that all product dimensions are in
centimetres, with weights in kilograms.

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

## Padding

Depending on how you actually fulfil the shipments, you might like to
add some padding to the ETA days provided by Temando. This allows you
to better manage customer expectations.

In this case, you have three fields to tweak:

* `Minimum ETA` - the minimum days it will take to ship and deliver. The
days provided will never be less than this value.
* `Pad Minimum` - The number of days to pad the "Minimum ETA" by.
* `Pad Maximum` - the number of days to pad the "Maximum ETA" by.

For example, if you know it's always going to take at least 3 days to
get an order boxed up before you can ship it, you might set each of the
"pad" values to 3 days, turning a quote for 1-3 days into 4-6 days.

Another example is where you know there are frequently delays with your
usual shipping provider. In this case, you might set the minimum ETA to
5, and set each of the padding values to 2. If temando offers a quote at
1-2 days, this will turn into 5-7.

In this case, the lowest number is forced by the minimum eta setting.
The highest number is forced to the same value (as it's under 5) and
then padded by 2.

## Customisations

To simplify all the options for feeding product data to Temando, you can
define the `Spree::Variant#populate_temando_item` method, which will be
called back after the Variant has been turned into a Temando Item.

A few examples are included below to give you a hint at the
possibilities.

### Shipping Optimisations

The temando API allows for items to be identified as eligible for
optimisation (ie. they can be grouped together in a defined packaging
size), or ineligible for optimisation (ie. already packed and can't be
combined).

Because there are numerous different ways you might want to implement
this logic in your site, you must calculate this from the
`Spree::Variant#populate_temando_item` callback.

```ruby
module VariantDecorator

  def populate_temando_item(item)
    item.packaging_optimization = %w( Bundle Free ).include?(product.shipping_category.try(:name)) ? "Y" : "N"

    item
  end

end
Spree::Variant.send(:include, VariantDecorator)
```

The above example assumes that you're using a shipping category to
decide, and products in the "Bundle" or "Free" categories are
optimisable.

### Packaging Types

A similar situation arises with the shipping packaging. Because
different shipping methods are defined against different packaging types
(eg. parcels, pallets, etc) you often need to drive these from the
product categories.

To do this, you can adjust the Item returned by and set the correct
`shipping_packaging`. (See the Temando API for details on valid values).

The Temando gem defaults to `Parcel` packaging type if nothing is
explicitly set.

```ruby
module VariantDecorator

  def populate_temando_item(item)
    case product.shipping_category.try(:name)
    when 'Pallet'
      item.shipping_packaging = 'Pallet'
      item.pallet_type        = 'Plain'
      item.pallet_nature      = 'Not Required'
    when 'Box'
      item.shipping_packaging = 'Box'
    else
      item.shipping_packaging = 'Parcel'
    end

    item
  end

end
Spree::Variant.send(:include, VariantDecorator)
```

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
