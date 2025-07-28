require "open-uri"
require "nokogiri"
require "uri"
require "addressable/uri"
require "debug"

require_relative "ficon/version"
require_relative "ficon/image"
require_relative "ficon/cache"

class Ficon
  attr_reader :site
  def initialize(uri)
    @uri = Addressable::URI.heuristic_parse(uri)
    @site = {}
    process
  end

  def doc
    cache = Cache.new(@uri)

    @data ||= cache.data

    if @data.nil?
      @data = URI.open(@uri)
      cache.data = @data.read.force_encoding("UTF-8")
      cache.etag = @data.meta["etag"] if @data.respond_to?(:meta)
      cache.not_before = @data.meta["last-modified"] if @data.respond_to?(:meta)
      @data.rewind
    end

    @doc ||= Nokogiri::HTML(@data)
    @doc
  rescue OpenURI::HTTPError, SocketError => e
    puts "OpenURI:  #{e.inspect}"
    nil
  rescue TypeError => e
    if /^http/.match?(uri.to_s)
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
    <<~REPORT
      Site icon: #{@site[:images].first}
      Page icon: #{@site[:page_images].first}
      Page title: #{@site[:title]}
      Page description: #{@site[:description]}
      Canonical URL: #{@site[:canonical]}
    REPORT
  end

  def site_icons
    @site[:images]
  end

  def page_images
    @site[:page_images]
  end

  def title
    @site[:title]
  end

  def description
    @site[:description]
  end

  def other_page_data
    @site[:title] = doc.at_xpath("//meta[@property='og:title']/@content")&.value || @doc.at_xpath("//title")&.text&.strip
    @site[:description] = doc.at_xpath("//meta[@property='og:description']/@content")&.value
    canonical = doc.at_xpath("//link[@rel='canonical']/@href")&.value
    @site[:canonical] = canonical unless canonical == @url
  end

  def self.site_images(uri, doc)
    results = []

    paths = "//meta[@name='msapplication-TileImage']|//link[@type='image/ico' or @type='image/vnd.microsoft.icon']|//link[@rel='icon' or @rel='shortcut icon' or @rel='apple-touch-icon-precomposed' or @rel='apple-touch-icon']"
    results += doc.xpath(paths).collect { |e| e.values.select { |v| v =~ /\.png$|\.jpg$|\.gif$|\.ico$|\.svg$|\.ico\?\d*$/ } }.flatten.collect { |v| (v[/^http/] || v[/^\//]) ? v : "/" + v }

    results.collect { |result| normalise(uri, result) }.uniq.collect { |i| Image.new(i) }.sort_by(&:area).reverse
  end

  def self.page_images(uri, doc)
    doc.xpath("//meta[@property='og:image']")
      .collect { |e| e.values.select { |v| v =~ /\.png$|\.jpg$|\.gif$|\.ico$|\.svg$|\.ico\?\d*$/ } }.flatten
      .collect { |v| (v[/^http/] || v[/^\//]) ? v : "/" + v }.collect { |result| normalise(uri, result) }.uniq.collect { |i| Image.new(i) }.sort_by(&:area).reverse
  end

  def self.normalise(base, candidate)
    parsed_candidate = URI(candidate)
    base = URI(base) unless base.is_a? URI

    parsed_candidate.host = base.host if parsed_candidate.host.nil?      # Set relative URLs to absolute
    parsed_candidate.scheme = base.scheme if parsed_candidate.scheme.nil?  # Set the schema if missing

    parsed_candidate.to_s
  end
end
