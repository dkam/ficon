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

## Todo

When returning a win8-tile, should probably test if there's a colour assocaited with it. EG, twitter returns:

````html
<meta name="msapplication-TileImage" content="//abs.twimg.com/favicons/win8-tile-144.png"/>
<meta name="msapplication-TileColor" content="#00aced"/>
````


## Contributing

1. Fork it ( https://github.com/[my-github-username]/ficon/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
