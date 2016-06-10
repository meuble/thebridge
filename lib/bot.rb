require 'HTTParty'
require "./lib/user.rb"
require "./lib/lithium.rb"

module Bot
  def self.handle_messages(messenger_params)
    messenger_params["entry"][0]["messaging"].each do |message|
      unless message["message"].nil?
        ap message["message"]
        ap "lets respond to #{message["sender"]["id"]}"
        user = User.where(:sender_id => message["sender"]["id"]).first || User.create(:sender_id => message["sender"]["id"])
        ap user
        ap message["message"]["text"]
        if user.bot_finished? || message["message"]["text"].downcase == "customer service"
          user.update_attributes(:bot_finished => true)
        else
          items = Lithium::get_lithium_posts(message["message"]["text"])
          send_structured_message(message["sender"]["id"], items)
        end
        if user.bot_finished? && message["message"]["text"].downcase == "community bot"
          user.update_attributes(:bot_finished => false)
        end
      else
        if message["postback"] && message["postback"]["payload"].downcase == "agent"
          send_message(message["sender"]["id"], "We need you to actualy say it. Can you type ‘customer service’, please ?")
        end
      end
    end
  end

  def self.send_structured_message(recipient, data)
    elements = []
    if data.size <= 0
      elements = [{
        :title => "We are sorry !",
        :subtitle => "There is no posts related to your question.",
          :buttons => [{
            :type => "web_url",
            :url => "https://linc4.stage.lithium.com/t5/forums/postpage",
            :title => "Ask the community !"
          }, agent_button]
        }]
    else
      elements = data.inject([]) do |acc, i|
        acc << {
          :title => i["subject"],
          :subtitle => (remove_html_tags(i["body"]) || "")[0..80],
          :buttons => [{
            :type => "web_url",
            :url => "#{i["view_href"]}",
            :title => "Read it !"
          }, {
            :type => "web_url",
            :url => "https://linc4.stage.lithium.com/t5/forums/postpage",
            :title => "Ask the community !"
          }, agent_button]
        }
        acc
      end
    end

    body = {
      :recipient => {
        "id" => recipient
      },
      :message => {
        :attachment => {
          :type => "template",
          :payload => {
            :template_type => "generic",
            :elements => elements
          }
        }
      }
    }

    ap body
    post_message(body)
  end

  def self.agent_button
    {
      :type => "postback",
      :payload => "agent",
      :title => "Need help ?"
    }
  end

  def self.remove_html_tags(s)
    re = /<("[^"]*"|'[^']*'|[^'">])*>/
    s.gsub!(re, '')
    s.gsub!("&nbsp;", ' ')
  end

  def self.send_message(recipient, data)
    body = {
      :recipient => {
        "id" => recipient
      },
      :message => {
        "text" => data
      }
    }
    ap body

    post_message(body)
  end

  def self.post_message(body)
    HTTParty.post("https://graph.facebook.com/v2.6/me/messages?access_token=#{Setting.config["page_token"]}",
        :body => body.to_json,
        :headers => { 'Content-Type' => 'application/json' } )
  end
end