require "ficon/version"

require 'open-uri'
require 'nokogiri'
require 'uri'
require 'net/http'

module Ficon
  def self.from_uri(_uri)

    uri = nil
    doc = nil

    begin
      require 'addressable/uri'
      uri = Addressable::URI.heuristic_parse(_uri)
    rescue LoadError
      uri = URI(_uri)
    end

    begin
      data = open(uri)
      doc = Nokogiri::HTML(data)

      uri = data.base_uri 

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

    results = from_page(doc).collect {|result| normalise(uri, result) }.uniq

    results.concat( from_probes(uri, results) )

    return results
  end

  def self.from_probes(uri, already_found=[])
    
    # Check if root domain redirects before probing, striping path - eg http://www.apple.com.au/ -> http://www.apple.com/au/

    probe = Net::HTTP.new(uri.host).request_head("/")
    if probe.code == "301" || probe.code == "302"
      uri = URI(probe.header["Location"])
      uri.path = ""
    end

    results = []
    guesses = ["/favicon.ico", "/favicon.png"]

    guesses.each do |guess|
      uri.path = guess
      unless already_found.include?( uri.to_s )
        results <<  uri.to_s  if( Net::HTTP.new(uri.host).request_head(uri.path).header.code == "200")
      end
    end

    return results
  end

  def self.from_page(page)
    doc = nil
    if page.is_a? String
      doc = Nokogiri::HTML(page) 
    elsif page.is_a? Nokogiri::HTML::Document
      doc = page 
    else
      raise ArgumentError 
    end

    doc.xpath("//meta[@property='og:image']|//meta[@name='msapplication-TileImage']|//link[@type='image/ico' or @type='image/vnd.microsoft.icon']|//link[@rel='icon' or @rel='shortcut icon' or @rel='apple-touch-icon-precomposed' or @rel='apple-touch-icon']").collect {|e| e.values.select {|v|  v =~ /\.png$|\.jpg$|\.gif$|\.ico$|\.svg$/ }}.flatten

  end

  def self.normalise(base, candidate)
      parsed_candidate = URI(candidate); 
      
      parsed_candidate.host   = base.host if parsed_candidate.host.nil?      # Set relative URLs to absolute
      parsed_candidate.scheme = base.scheme if parsed_candidate.scheme.nil?  # Set the schema if missing

      parsed_candidate.to_s
  end
end
