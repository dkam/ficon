require 'open-uri'
require 'fastimage'

module Ficon
  class Image
    require 'fastimage'

    attr_reader :url, :size, :area
    def initialize(url)
      @url = url
      c = Cache.new(@url)
      @size = Cache.new(url).data || FastImage.size(url)
      c.data = @size
      @area = @size&.inject(&:*) || 0
    end

    def to_s
      @url.to_s +  "(#{@size})"
    end
  end
end
