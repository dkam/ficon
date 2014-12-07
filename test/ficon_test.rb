require 'rubygems'

require 'test/unit'

PathHere = File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(PathHere, "..", "lib")

require 'ficon'

  Tests = []
  Tests << { html: %Q{<meta name="msapplication-TileImage" content="https://s.yimg.com/pw/images/favicon-msapplication-tileimage.png"/> }, value: 'https://s.yimg.com/pw/images/favicon-msapplication-tileimage.png' }
  Tests << { html: %Q{<link rel="shortcut icon" type="image/ico" href="https://s.yimg.com/pw/favicon.ico"> }, value: 'https://s.yimg.com/pw/favicon.ico' }
  Tests << { html: %Q{<link href="/apple-touch-icon.png" rel="apple-touch-icon-precomposed">}, value: '/apple-touch-icon.png' }
  Tests << { html: %Q{<link rel="shortcut icon" href="/wp-content/themes/torrentfreakredux/assets/img/icons/favicon.png">}, value: '/wp-content/themes/torrentfreakredux/assets/img/icons/favicon.png' }
  Tests << { html: %Q{<link rel="apple-touch-icon-precomposed" href="/wp-content/themes/torrentfreakredux/assets/img/icons/57.png">}, value: '/wp-content/themes/torrentfreakredux/assets/img/icons/57.png' }
  Tests << { html: %Q{<link rel="apple-touch-icon-precomposed" sizes="114x114" href="/wp-content/themes/torrentfreakredux/assets/img/icons/114.png">}, value: '/wp-content/themes/torrentfreakredux/assets/img/icons/114.png' }
  Tests << { html: %Q{<link rel="apple-touch-icon-precomposed" sizes="72x72" href="/wp-content/themes/torrentfreakredux/assets/img/icons/72.png">}, value: '/wp-content/themes/torrentfreakredux/assets/img/icons/72.png' }
  Tests << { html: %Q{<link rel="apple-touch-icon-precomposed" sizes="144x144" href="/wp-content/themes/torrentfreakredux/assets/img/icons/144.png">}, value: '/wp-content/themes/torrentfreakredux/assets/img/icons/144.png' }
  Tests << { html: %Q{<link rel="shortcut icon" href="/favicon.png">}, value: '/favicon.png' }
  Tests << { html: %Q{<link rel="shortcut icon" href="favicon.ico" />}, value: '/favicon.ico'           }
  Tests << { html: %Q{<link rel="apple-touch-icon" href="/apple-touch-icon.png">}, value: '/apple-touch-icon.png' }
  Tests << { html: %Q{<link rel="shortcut icon" href="http://example.com/myicon.ico" />}, value: 'http://example.com/myicon.ico' }
  Tests << { html: %Q{<link rel="icon" href="http://example.com/image.ico" />}, value: 'http://example.com/image.ico' }
  Tests << { html: %Q{<link rel="icon" type="image/vnd.microsoft.icon" href="http://example.com/image.ico" />}, value: 'http://example.com/image.ico' }
  Tests << { html: %Q{<link rel="icon" type="image/png" href="http://example.com/image.png" />}, value: 'http://example.com/image.png' }
  Tests << { html: %Q{<link rel="icon" type="image/gif"  href="http://example.com/image.gif" />}, value: 'http://example.com/image.gif' }
  Tests << { html: %Q{<link rel="icon" type="image/x-icon" href="http://example.com/image.ico"/>}, value: 'http://example.com/image.ico' }
  Tests << { html: %Q{<link rel="shortcut icon" href="https://fbstatic-a.akamaihd.net/rsrc.php/yl/r/H3nktOa7ZMg.ico" />}, value: 'https://fbstatic-a.akamaihd.net/rsrc.php/yl/r/H3nktOa7ZMg.ico' }
  Tests << { html: %Q{<meta property="og:image" content="https://www.facebook.com/images/fb_icon_325x325.png" />}, value: 'https://www.facebook.com/images/fb_icon_325x325.png'           }


class FiconTest < Test::Unit::TestCase
  def test_html_chunks
    Tests.each do |t|
      result = Ficon.from_page( t[:html] )[0]
      assert result == t[:value], "Seaching |#{t[:html]}| expected #{t[:value]}, got #{result}" 
    end
  end
end
