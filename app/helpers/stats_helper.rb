require "httparty"

module StatsHelper

end

class Facebook
  include HTTParty
  base_uri "http://api.facebook.com"

  def like_stats(urls=[])
    urls = [urls] if not urls.instance_of? Array

    options = {
        :query => {
            :method => "links.getStats",
            :urls => urls.join(",")
        }
    }
    resp = self.class.get("/restserver.php", options)

    require 'ap'
    ap resp

    stats = resp["links_getStats_response"]
    stats = [stats] if not stats.instance_of? Array

    stats.collect do |stat|
      info = stat["link_stat"]
      [ info["url"], info["like_count"].to_i ]
    end
  end

end

class ShareThis
  include HTTParty
  base_uri "http://rest.sharethis.com/reach"

  def total_shared(url)
    options = {
        :query => {
            :url => url,
            :pub_key => C.sharethis.publisher,
            :access_key => C.sharethis.access_key
        }
    }
    resp = self.class.get("/getUrlInfo.php", options)

    require 'ap'
    ap resp

    begin
      resp["total"]["inbound"]
    rescue
      nil
    end
  end
end