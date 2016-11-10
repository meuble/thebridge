require 'httparty'
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
        if message["message"]["text"]
          if user.bot_finished? || message["message"]["text"].downcase == "customer service"
            user.update_attributes(:bot_finished => true)
          else
            items = Lithium::get_lithium_posts(message["message"]["text"])
            send_structured_message(message["sender"]["id"], items)
          end
          if user.bot_finished? && message["message"]["text"].downcase == "community bot"
            user.update_attributes(:bot_finished => false)
          end
        end
      else
        user = User.where(:sender_id => message["sender"]["id"]).first || User.create(:sender_id => message["sender"]["id"])
        ap user
        
        if message["postback"] && message["postback"]["payload"].downcase == "stop_bot"
          user.update_attributes(:bot_finished => true)
          send_message(message["sender"]["id"], "Ok, my job is done. Now you'll be talking a Sony agent.")
        end
        if message["postback"] && message["postback"]["payload"].downcase == "start_bot"
          user.update_attributes(:bot_finished => false)
          send_message(message["sender"]["id"], "Just ask me any question, I will search through the Community for you.")
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
            :url => "https://talk.sonymobile.com//t5/forums/postpage",
            :title => "Ask the community !"
          }]
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
            :url => "https://talk.sonymobile.com///t5/forums/postpage",
            :title => "Ask the community !"
          }]
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

  def self.set_persistent_menu
    body = {
      :setting_type => "call_to_actions",
      :thread_state => "existing_thread",
      :call_to_actions => [
         {
           :type => "postback",
           :title => "Ask the Community Bot",
           :payload => "start_bot"
         },
         {
           :type => "postback",
           :title => "Ask a Sony agent",
           :payload => "stop_bot"
         },
         {
           :type => "web_url",
           :title => "Visit Sony support community",
           :url => "http://talk.sonymobile.com/"
         }
       ]
    }
    HTTParty.post("https://graph.facebook.com/v2.6/me/thread_settings?access_token=#{Setting.config["page_token"]}",
        :body => body.to_json,
        :headers => { 'Content-Type' => 'application/json' } )
    
  end
  
  def self.set_start_message
    body = {
      :setting_type => "greeting",
      :greeting => {
        :text => "Welcome to Sony for Customer ! How can I help you ?\nWhy don't you start by asking our bot for community content ?"
      }
    }
    HTTParty.post("https://graph.facebook.com/v2.6/me/thread_settings?access_token=#{Setting.config["page_token"]}",
        :body => body.to_json,
        :headers => { 'Content-Type' => 'application/json' } )
  end
  
  def self.set_call_to_action
    body = {
      :setting_type => "call_to_actions",
      :thread_state => "new_thread",
      :call_to_actions => [
        {
          :type => "postback",
          :title => "Start the bot",
          :payload => "START_BOT"
        }
      ]
    }
      HTTParty.post("https://graph.facebook.com/v2.6/me/thread_settings?access_token=#{Setting.config["page_token"]}",
          :body => body.to_json,
          :headers => { 'Content-Type' => 'application/json' } )
      
  end
    
end