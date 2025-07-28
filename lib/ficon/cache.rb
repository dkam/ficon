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

    def status
      db.execute("select status from urls where url=? limit 1", @url).first&.first
    end

    def status=(_value)
      db.execute("INSERT OR IGNORE INTO urls (url, status) VALUES (?, ?)", [@url, _value])
      db.execute("UPDATE urls SET status=? WHERE url=?", [_value, @url])
    end

    def retry_count
      db.execute("select retry_count from urls where url=? limit 1", @url).first&.first || 0
    end

    def retry_count=(_value)
      db.execute("INSERT OR IGNORE INTO urls (url, retry_count) VALUES (?, ?)", [@url, _value])
      db.execute("UPDATE urls SET retry_count=? WHERE url=?", [_value, @url])
    end

    def last_attempt
      db.execute("select last_attempt from urls where url=? limit 1", @url).first&.first
    end

    def last_attempt=(_value)
      db.execute("INSERT OR IGNORE INTO urls (url, last_attempt) VALUES (?, ?)", [@url, _value])
      db.execute("UPDATE urls SET last_attempt=? WHERE url=?", [_value, @url])
    end

    def self.db_file
      if ENV["FICON_DB"].nil?
        File.expand_path("~/.ficon.db")
      else
        ENV["FICON_DB"]
      end
    end

    def self.setup_cache(db)
      db.execute("CREATE TABLE urls(url, etag, not_before, data, status, retry_count, last_attempt)")
      db.execute("CREATE UNIQUE INDEX `url` ON `urls` (`url`)")
    end

    def self.clear_cache
      File.delete(db_file) if File.exist?(db_file)
    end
  end
end
