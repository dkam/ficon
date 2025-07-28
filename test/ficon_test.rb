#require 'rubygems'
require 'debug'

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
  SiteTests << { html: %Q{<meta name="msapplication-TileImage" content="/win8-tile-144.png"/><meta name="msapplication-TileColor" content="#00aced"/>}, value: 'https://site.com/win8-tile-144.png' }

  PageTests = []
  PageTests << { html: %Q{<meta property="og:image" content="https://www.facebook.com/images/fb_icon_325x325.png" />},        value: 'https://www.facebook.com/images/fb_icon_325x325.png'           }


class FiconTest < Minitest::Test
  ENV['FICON_DB']=File.join( File.dirname(__FILE__), 'test.db')
  def test_html_chunks
    SiteTests.each do |t|
      result = Ficon.site_images('https://site.com', Nokogiri::HTML(t[:html]) )[0]
      assert result&.url == t[:value], "Seaching |#{t[:html]}| expected #{t[:value]}, got #{result}" 
    end
    PageTests.each do |t|
      result = Ficon.page_images('https://site.com', Nokogiri::HTML(t[:html]) )[0]
      assert result&.url == t[:value], "Seaching |#{t[:html]}| expected #{t[:value]}, got #{result}" 
    end
  end

  def test_tile_color_extraction
    html = %Q{<meta name="msapplication-TileImage" content="/win8-tile-144.png"/><meta name="msapplication-TileColor" content="#00aced"/>}
    result = Ficon.site_images('https://site.com', Nokogiri::HTML(html))[0]
    assert_equal 'https://site.com/win8-tile-144.png', result.url
    assert_equal '#00aced', result.tile_color
  end

  def test_custom_user_agent
    # Test default user agent
    ficon_default = Ficon.new('https://example.com')
    assert_match(/^FiconBot\/0\.\d+/, ficon_default.user_agent)
    
    # Test custom user agent
    custom_agent = 'MyApp/1.0 (Custom Bot)'
    ficon_custom = Ficon.new('https://example.com', user_agent: custom_agent)
    assert_equal custom_agent, ficon_custom.user_agent
    
    # Test user agent can be changed after initialization
    ficon_custom.user_agent = 'Changed/2.0'
    assert_equal 'Changed/2.0', ficon_custom.user_agent
  end
end
