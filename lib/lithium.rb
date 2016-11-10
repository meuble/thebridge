require 'httparty'

module Lithium
  def self.get_lithium_posts(data)
    result = HTTParty.get("http://talk.sonymobile.com//api/2.0/search?q=#{ERB::Util.url_encode("SELECT subject, body, id, view_href FROM messages WHERE subject MATCHES \"#{data}\"")}",
        :headers => { 'Content-Type' => 'application/json' } )

    if result["data"] && result["data"]["size"] > 0 && result["data"]["items"]
      result["data"]["items"][0..3]
    else
      []
    end
  end
end