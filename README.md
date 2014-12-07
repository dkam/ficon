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

    $ ficon https://facebook.com
    https://www.facebook.com/images/fb_icon_325x325.png
    https://fbstatic-a.akamaihd.net/rsrc.php/yV/r/hzMapiNYYpW.ico
    https://www.facebook.com/favicon.ico
    

## Contributing

1. Fork it ( https://github.com/dkam/ficon/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
