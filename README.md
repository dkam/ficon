# Ficon

Find all the icons for a given URL.  Favicons, og:image etc and return them in as a list.

## Installation

Add this line to your application's Gemfile:

    gem 'ficon'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ficon

## Usage

    irb(main)> Ficon.from_uri "https://facebook.com"
    => ["https://www.facebook.com/images/fb_icon_325x325.png", "https://fbstatic-a.akamaihd.net/rsrc.php/yV/r/hzMapiNYYpW.ico", "https://www.facebook.com/favicon.ico"]

Or form the shell:

    $ ficon https://booko.info/9780748109999
    Site icon: https://booko.info/favicon-196x196.png([196, 196])
    Page icon: https://covers.booko.com.au/9780748109999.jpg([1488, 2338])
    Page title: Prices for Consider Phlebas by Iain M. Banks
    Page description: Prices (including delivery) for Consider Phlebas by Iain M. Banks range from $12.40 at Blackwell's up to $12.99.

## Contributing

1. Fork it ( https://github.com/dkam/ficon/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
