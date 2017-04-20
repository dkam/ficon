require 'open-uri'
require 'nokogiri'
require 'uri'
require "ostruct"
require 'addressable/uri'
require 'byebug'

require_relative 'ficon/version'
require_relative 'ficon/image'
require_relative 'ficon/cache'

module Ficon
  class Site

    attr_reader :site
    def initialize(uri)
      @uri = Addressable::URI.heuristic_parse(uri)
      @site = OpenStruct.new
      process
    end

    def doc
      cache = Cache.new(@uri)

      @data ||= cache.data 
      
      if @data.nil?
        @data =  open(@uri)
        cache.data       = @data.read.force_encoding('UTF-8')
        cache.etag       = @data.meta['etag']           if @data.respond_to?(:meta)
        cache.not_before = @data.meta['last-modified']  if @data.respond_to?(:meta)
        @data.rewind
      end
      
      @doc  ||= Nokogiri::HTML(@data)
      return @doc
    rescue OpenURI::HTTPError, SocketError => e
      puts "OpenURI:  #{e.inspect}"
      return nil
    rescue TypeError  => e
      if  uri.to_s =~ /^http/
        puts "#{e.inspect}"
        puts "#{e.backtrace.join('\n')}"
      else
        puts "Please prepend http:// or https:// to the URL" 
      end
      return nil
    rescue RuntimeError => e
      puts "#{e.message}"
      return nil
    end


    def process
      @site.images      = Site.site_images(@uri, doc)||[]
      @site.page_images = Site.page_images(@uri, doc)||[]
      other_page_data
    end

    def report
      r  = "Site icon: #{@site.images.first.to_s}\n"
      r += "Page icon: #{@site.page_images.first.to_s}\n"
      r += "Page title: #{@site.title}\n"
      r += "Page description: #{@site.description}\n"
      r += "Canonical URL: #{@site.canonical}\n"

      return r
    end

    def site_icons
      @site.images
    end

    def page_images
      @site.page_images
    end

    def other_page_data
      @site.title       = doc.at_xpath("//meta[@property='og:title']/@content")&.value ||  @doc.at_xpath("//title")&.text&.strip
      @site.description = doc.at_xpath("//meta[@property='og:description']/@content")&.value
      canonical   = doc.at_xpath("//link[@rel='canonical']/@href")&.value
      @site.canonical   = canonical unless canonical == @url
    end

    def self.site_images(uri, doc, site=nil)
      results = []

      paths = "//meta[@name='msapplication-TileImage']|//link[@type='image/ico' or @type='image/vnd.microsoft.icon']|//link[@rel='icon' or @rel='shortcut icon' or @rel='apple-touch-icon-precomposed' or @rel='apple-touch-icon']"
      results += doc.xpath(paths).collect {|e| e.values.select {|v|  v =~ /\.png$|\.jpg$|\.gif$|\.ico$|\.svg$|\.ico\?\d*$/ }}.flatten.collect {|v| v[/^http/] || v[/^\//]  ? v : '/' + v  }

      results =  results.collect {|result| normalise(uri, result)}.uniq.collect {|i| Image.new(i) }.sort {|a,b| a.area <=> b.area }.reverse
    end

    def self.page_images(uri, doc, site=nil)
      doc.xpath("//meta[@property='og:image']").
        collect {|e| e.values.select {|v|  v =~ /\.png$|\.jpg$|\.gif$|\.ico$|\.svg$|\.ico\?\d*$/ }}.flatten.
        collect {|v| v[/^http/] || v[/^\//]  ? v : '/' + v  }.collect {|result| normalise(uri, result)}.uniq.collect {|i| Image.new(i)}.sort {|a, b| a.area <=> b.area }.reverse
    end

    def self.normalise(base, candidate)
        parsed_candidate = URI(candidate); 
        base = URI(base) unless base.is_a? URI
        
        parsed_candidate.host   = base.host if parsed_candidate.host.nil?      # Set relative URLs to absolute
        parsed_candidate.scheme = base.scheme if parsed_candidate.scheme.nil?  # Set the schema if missing

        parsed_candidate.to_s
    end


  end
end 
