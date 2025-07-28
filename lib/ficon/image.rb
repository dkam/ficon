require "open-uri"
require "fastimage"
require "json"

class Ficon
  class Image
    require "fastimage"

    attr_reader :url, :size, :area
    def initialize(url)
      @url = url
      c = Cache.new(@url)
      cached_size = Cache.new(url).data
      @size = cached_size ? JSON.parse(cached_size) : FastImage.size(url)
      c.data = @size.to_json if @size
      @area = @size&.inject(&:*) || 0
    end

    def to_s
      @url.to_s + " (#{@size})"
    end
  end
end
