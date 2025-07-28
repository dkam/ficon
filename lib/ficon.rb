require "net/http"
require "nokogiri"
require "uri"
require "addressable/uri"
require "debug"

require_relative "ficon/version"
require_relative "ficon/image"
require_relative "ficon/cache"

class Ficon
  attr_reader :site, :final_uri
  attr_accessor :user_agent

  def initialize(uri, user_agent: nil)
    @uri = Addressable::URI.heuristic_parse(uri)
    @final_uri = @uri
    @site = {}
    @user_agent = user_agent || "Ficon/#{VERSION} (Ruby icon finder; https://github.com/dkam/ficon)"
    process
  end

  def doc
    # First try to fetch to determine final URL
    response = fetch_url(@uri) unless @data
    return nil if response.nil? && @data.nil?

    # Use final URL for caching
    cache = Cache.new(@final_uri)

    @data ||= cache.data

    if @data.nil? && response
      @data = response.body.force_encoding("UTF-8")
      cache.data = @data
      cache.etag = response["etag"] if response["etag"]
      cache.not_before = response["last-modified"] if response["last-modified"]
    end

    @doc ||= Nokogiri::HTML(@data)
    @doc
  rescue Net::HTTPError, SocketError => e
    puts "HTTP Error: #{e.inspect}"
    nil
  rescue TypeError => e
    if /^http/.match?(@uri.to_s)
      puts "#{e.inspect}"
      puts "#{e.backtrace.join('\n')}"
    else
      puts "Please prepend http:// or https:// to the URL"
    end
    nil
  rescue RuntimeError => e
    puts "#{e.message}"
    nil
  end

  def process
    @site[:images] = self.class.site_images(@uri, doc) || []
    @site[:page_images] = self.class.page_images(@uri, doc) || []
    other_page_data
    nil
  end

  def report
    report_lines = []
    report_lines << "Site icon: #{@site[:images].first}"
    report_lines << "Page icon: #{@site[:page_images].first}"
    report_lines << "Page title: #{@site[:title]}"
    report_lines << "Page description: #{@site[:description]}"
    report_lines << "Final URL: #{@final_uri}" if @final_uri.to_s != @uri.to_s
    report_lines << "Canonical URL: #{@site[:canonical]}" if @site[:canonical]
    report_lines.join("\n") + "\n"
  end

  def site_icons = @site[:images]

  def site_icon = site_icons&.first

  def page_images = @site[:page_images]

  def page_image = page_images&.first

  def title = @site[:title]

  def description = @site[:description]

  def other_page_data
    @site[:title] = doc.at_xpath("//meta[@property='og:title']/@content")&.value || @doc.at_xpath("//title")&.text&.strip
    @site[:description] = doc.at_xpath("//meta[@property='og:description']/@content")&.value
    canonical = doc.at_xpath("//link[@rel='canonical']/@href")&.value
    @site[:canonical] = canonical unless canonical == @url
  end

  def self.site_images(uri, doc)
    results = []

    # Get tile color for Windows tiles
    tile_color = doc.at_xpath("//meta[@name='msapplication-TileColor']/@content")&.value

    paths = "//meta[@name='msapplication-TileImage']|//link[@type='image/ico' or @type='image/vnd.microsoft.icon']|//link[@rel='icon' or @rel='shortcut icon' or @rel='apple-touch-icon-precomposed' or @rel='apple-touch-icon']"
    results += doc.xpath(paths).collect { |e| e.values.select { |v| v =~ /\.png$|\.jpg$|\.gif$|\.ico$|\.svg$|\.ico\?\d*$/ } }.flatten.collect { |v| (v[/^http/] || v[/^\//]) ? v : "/" + v }

    results.collect { |result| normalise(uri, result) }.uniq.collect do |url|
      # Check if this is a tile image to pass the color
      is_tile = doc.at_xpath("//meta[@name='msapplication-TileImage' and @content='#{url}' or @content='#{url.sub(uri.to_s, "")}']")
      Image.new(url, is_tile ? tile_color : nil)
    end.sort_by(&:area).reverse
  end

  def self.page_images(uri, doc)
    doc.xpath("//meta[@property='og:image']")
      .collect { |e| e.values.reject(&:empty?) }.flatten
      .collect { |v| (v[/^http/] || v[/^\//]) ? v : "/" + v }.collect { |result| normalise(uri, result) }.uniq.collect { |i| Image.new(i) }.sort_by(&:area).reverse
  end

  def self.normalise(base, candidate)
    parsed_candidate = URI(candidate)
    base = URI(base) unless base.is_a? URI

    parsed_candidate.host = base.host if parsed_candidate.host.nil?      # Set relative URLs to absolute
    parsed_candidate.scheme = base.scheme if parsed_candidate.scheme.nil?  # Set the schema if missing

    parsed_candidate.to_s
  end

  private

  def fetch_url(uri, redirect_limit = 5)
    uri = URI(uri) unless uri.is_a?(URI)

    raise "Too many redirects" if redirect_limit <= 0

    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.read_timeout = 10
      http.open_timeout = 5
      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = @user_agent
      response = http.request(request)

      case response
      when Net::HTTPRedirection
        location = response["location"]
        if location
          new_uri = URI.join(uri.to_s, location)
          @final_uri = Addressable::URI.parse(new_uri.to_s)
          return fetch_url(new_uri, redirect_limit - 1)
        end
      else
        @final_uri = Addressable::URI.parse(uri.to_s)
      end

      response
    end
  rescue Net::HTTPError, SocketError, Timeout::Error => e
    puts "Failed to fetch #{uri}: #{e.inspect}"
    nil
  end
end
