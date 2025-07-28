require "net/http"
require "fastimage"
require "json"

class Ficon
  class Image
    attr_reader :url, :size, :area, :tile_color
    def initialize(url, tile_color = nil)
      @url = url
      @tile_color = tile_color
      c = Cache.new(@url)
      cached_size = Cache.new(url).data
      @size = cached_size ? JSON.parse(cached_size) : FastImage.size(url)
      c.data = @size.to_json if @size
      @area = @size&.inject(&:*) || 0
    end

    def to_s
      result = @url.to_s + " (#{@size})"
      result += " [#{@tile_color}]" if @tile_color
      result
    end
  end
end
