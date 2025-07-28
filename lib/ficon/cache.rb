require "sqlite3"

class Ficon
  class Cache
    def initialize(url)
      @url = url.to_s
      Cache.setup_cache(db) if db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='urls'").length == 0
    end

    def db
      _db = SQLite3::Database.new Cache.db_file
      _db.busy_timeout = 1000
      _db
    end

    def data
      db.execute("select data from urls where url=? limit 1", @url).first&.first
    end

    def data=(_value)
      db.execute("INSERT OR IGNORE INTO urls (url, data) VALUES (?, ?)", [@url, _value])
      db.execute("UPDATE urls SET data=? WHERE url=?", [_value, @url])
    end

    def etag
      db.execute("select etag from urls where url=? limit 1", @url).first&.first
    end

    def etag=(_value)
      db.execute("INSERT OR IGNORE INTO urls (url, etag) VALUES (?, ?)", [@url, _value])
      db.execute("UPDATE urls SET etag=? WHERE url=?", [_value, @url])
    end

    def not_before
      db.execute("select not_before from urls where url=? limit 1", @url).first&.first
    end

    def not_before=(_value)
      db.execute("INSERT OR IGNORE INTO urls (url, not_before) VALUES (?, ?)", [@url, _value])
      db.execute("UPDATE urls SET not_before=? WHERE url=?", [_value, @url])
    end

    def self.db_file
      if ENV["FICON_DB"].nil?
        File.expand_path("~/.ficon.db")
      else
        ENV["FICON_DB"]
      end
    end

    def self.setup_cache(db)
      db.execute("CREATE TABLE urls(url, etag, not_before, data)")
      db.execute("CREATE UNIQUE INDEX `url` ON `urls` (`url`)")
    end
  end
end
