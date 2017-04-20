#require 'rubygems'
require 'byebug'

require "minitest/autorun"

PathHere = File.dirname(__FILE__)
$LOAD_PATH.unshift File.join(PathHere, "..", "lib")

require 'ficon'

  SiteTests = []
  SiteTests << { html: %Q{<meta name="msapplication-TileImage" content="https://s.yimg.com/pw/images/favicon-msapplication-tileimage.png"/> }, value: 'https://s.yimg.com/pw/images/favicon-msapplication-tileimage.png' }
  SiteTests << { html: %Q{<link rel="shortcut icon" type="image/ico" href="https://s.yimg.com/pw/favicon.ico"> },                              value: 'https://s.yimg.com/pw/favicon.ico' }
  SiteTests << { html: %Q{<link href="/apple-touch-icon.png" rel="apple-touch-icon-precomposed">},                                             value: 'https://site.com/apple-touch-icon.png' }
  SiteTests << { html: %Q{<link rel="shortcut icon" href="/wp-content/themes/torrentfreakredux/assets/img/icons/favicon.png">},                value: 'https://site.com/wp-content/themes/torrentfreakredux/assets/img/icons/favicon.png' }
  SiteTests << { html: %Q{<link rel="apple-touch-icon-precomposed" href="/wp-content/themes/torrentfreakredux/assets/img/icons/57.png">},      value: 'https://site.com/wp-content/themes/torrentfreakredux/assets/img/icons/57.png' }
  SiteTests << { html: %Q{<link rel="apple-touch-icon-precomposed" sizes="114x114" href="/wp-content/themes/torrentfreakredux/assets/img/icons/114.png">}, value: 'https://site.com/wp-content/themes/torrentfreakredux/assets/img/icons/114.png' }
  SiteTests << { html: %Q{<link rel="apple-touch-icon-precomposed" sizes="72x72" href="/wp-content/themes/torrentfreakredux/assets/img/icons/72.png">},    value: 'https://site.com/wp-content/themes/torrentfreakredux/assets/img/icons/72.png' }
  SiteTests << { html: %Q{<link rel="apple-touch-icon-precomposed" sizes="144x144" href="/wp-content/themes/torrentfreakredux/assets/img/icons/144.png">}, value: 'https://site.com/wp-content/themes/torrentfreakredux/assets/img/icons/144.png' }
  SiteTests << { html: %Q{<link rel="shortcut icon" href="/favicon.png">},                                                    value: 'https://site.com/favicon.png'                 }
  SiteTests << { html: %Q{<link rel="shortcut icon" href="favicon.ico" />},                                                   value: 'https://site.com/favicon.ico'                 }
  SiteTests << { html: %Q{<link rel="apple-touch-icon" href="/apple-touch-icon.png">},                                        value: 'https://site.com/apple-touch-icon.png'        }
  SiteTests << { html: %Q{<link rel="shortcut icon" href="http://example.com/myicon.ico" />},                                 value: 'http://example.com/myicon.ico'}
  SiteTests << { html: %Q{<link rel="icon" href="http://example.com/image.ico" />},                                           value: 'http://example.com/image.ico' }
  SiteTests << { html: %Q{<link rel="icon" type="image/vnd.microsoft.icon" href="http://example.com/image.ico" />},           value: 'http://example.com/image.ico' }
  SiteTests << { html: %Q{<link rel="icon" type="image/png" href="http://example.com/image.png" />},                          value: 'http://example.com/image.png' }
  SiteTests << { html: %Q{<link rel="icon" type="image/gif"  href="http://example.com/image.gif" />},                         value: 'http://example.com/image.gif' }
  SiteTests << { html: %Q{<link rel="icon" type="image/x-icon" href="http://example.com/image.ico"/>},                        value: 'http://example.com/image.ico' }
  SiteTests << { html: %Q{<link rel="shortcut icon" href="https://fbstatic-a.akamaihd.net/rsrc.php/yl/r/H3nktOa7ZMg.ico" />}, value: 'https://fbstatic-a.akamaihd.net/rsrc.php/yl/r/H3nktOa7ZMg.ico' }
  SiteTests << { html: %Q{<link rel="icon" type="image/vnd.microsoft.icon" href="/viconline/img/favicon.ico?1393375504" />},  value: 'https://site.com/viconline/img/favicon.ico?1393375504' }
  SiteTests << { html: %Q{<link rel="shortcut icon" type="image/x-icon" href="/viconline/img/favicon.ico?1393375504" />},     value: 'https://site.com/viconline/img/favicon.ico?1393375504'    }

  PageTests = []
  PageTests << { html: %Q{<meta property="og:image" content="https://www.facebook.com/images/fb_icon_325x325.png" />},        value: 'https://www.facebook.com/images/fb_icon_325x325.png'           }


class FiconTest < Minitest::Test
  include Ficon
  ENV['FICON_DB']=File.join( File.dirname(__FILE__), 'test.db')
  def test_html_chunks
    SiteTests.each do |t|
      result = Site.site_images('https://site.com', Nokogiri::HTML(t[:html]) )[0]
      assert result&.url == t[:value], "Seaching |#{t[:html]}| expected #{t[:value]}, got #{result}" 
    end
    PageTests.each do |t|
      result = Site.page_images('https://site.com', Nokogiri::HTML(t[:html]) )[0]
      assert result&.url == t[:value], "Seaching |#{t[:html]}| expected #{t[:value]}, got #{result}" 
    end
  end
end
