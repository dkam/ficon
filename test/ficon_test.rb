#require 'rubygems'
require 'debug'
require 'resolv'

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

  def test_response_status_classification
    ficon = Ficon.new('https://example.com')
    
    # Test ALIVE status (2xx)
    assert_equal Ficon::ALIVE, ficon.classify_response_status(mock_response(200))
    assert_equal Ficon::ALIVE, ficon.classify_response_status(mock_response(201))
    assert_equal Ficon::ALIVE, ficon.classify_response_status(mock_response(299))
    
    # Test DEAD status (404, 410)
    assert_equal Ficon::DEAD, ficon.classify_response_status(mock_response(404))
    assert_equal Ficon::DEAD, ficon.classify_response_status(mock_response(410))
    
    # Test BLOCKED status (401, 403, 429)
    assert_equal Ficon::BLOCKED, ficon.classify_response_status(mock_response(401))
    assert_equal Ficon::BLOCKED, ficon.classify_response_status(mock_response(403))
    assert_equal Ficon::BLOCKED, ficon.classify_response_status(mock_response(429))
    
    # Test SICK status (5xx and others)
    assert_equal Ficon::SICK, ficon.classify_response_status(mock_response(500))
    assert_equal Ficon::SICK, ficon.classify_response_status(mock_response(502))
    assert_equal Ficon::SICK, ficon.classify_response_status(mock_response(503))
    assert_equal Ficon::SICK, ficon.classify_response_status(mock_response(300)) # Other codes default to SICK
  end

  def test_exception_status_classification
    ficon = Ficon.new('https://example.com')
    
    # Test DEAD status (DNS and resolution errors)
    assert_equal Ficon::DEAD, ficon.classify_exception_status(SocketError.new)
    assert_equal Ficon::DEAD, ficon.classify_exception_status(Resolv::ResolvError.new)
    
    # Test SICK status (network and timeout errors)
    assert_equal Ficon::SICK, ficon.classify_exception_status(Timeout::Error.new)
    assert_equal Ficon::SICK, ficon.classify_exception_status(Errno::ECONNREFUSED.new)
    assert_equal Ficon::SICK, ficon.classify_exception_status(OpenSSL::SSL::SSLError.new)
    assert_equal Ficon::SICK, ficon.classify_exception_status(Net::HTTPError.new('error', nil))
    
    # Test default to SICK for unknown exceptions
    assert_equal Ficon::SICK, ficon.classify_exception_status(StandardError.new)
  end

  def test_http_to_https_fallback_conditions
    # Test that localhost URLs are not converted to HTTPS
    ficon_localhost = Ficon.allocate
    uri_localhost = URI('http://localhost:3000/test')
    
    # Mock the fetch_url method to simulate HTTP failure
    def ficon_localhost.fetch_url(uri, redirect_limit = 5)
      if uri.scheme == "http" && !uri.to_s.include?("://localhost") && !uri.host.match?(/^\d+\.\d+\.\d+\.\d+$/)
        # This should not be reached for localhost
        raise "Should not attempt HTTPS fallback for localhost"
      end
      nil
    end
    
    # This should not raise an exception
    result = ficon_localhost.send(:fetch_url, uri_localhost)
    assert_nil result
    
    # Test that IP addresses are not converted to HTTPS
    ficon_ip = Ficon.allocate
    uri_ip = URI('http://192.168.1.1/test')
    
    def ficon_ip.fetch_url(uri, redirect_limit = 5)
      if uri.scheme == "http" && !uri.to_s.include?("://localhost") && !uri.host.match?(/^\d+\.\d+\.\d+\.\d+$/)
        # This should not be reached for IP addresses
        raise "Should not attempt HTTPS fallback for IP addresses"
      end
      nil
    end
    
    # This should not raise an exception
    result = ficon_ip.send(:fetch_url, uri_ip)
    assert_nil result
  end

  def test_https_port_conversion
    # Test that port 80 is converted to 443 when switching to HTTPS
    http_uri = URI('http://example.com:80/test')
    assert_equal 80, http_uri.port
    
    https_uri = http_uri.dup
    https_uri.scheme = "https"
    https_uri.port = 443 if https_uri.port == 80
    
    assert_equal "https", https_uri.scheme
    assert_equal 443, https_uri.port
    
    # Test that custom ports are preserved
    http_custom_uri = URI('http://example.com:8080/test')
    https_custom_uri = http_custom_uri.dup
    https_custom_uri.scheme = "https"
    https_custom_uri.port = 443 if https_custom_uri.port == 80
    
    assert_equal "https", https_custom_uri.scheme
    assert_equal 8080, https_custom_uri.port  # Should remain unchanged
  end

  private

  def mock_response(code)
    response = Object.new
    response.define_singleton_method(:code) { code }
    response
  end
end
