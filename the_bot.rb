require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'telegram-bot-ruby'
  gem 'ruby-openai'
  gem 'dotenv'
end

require 'telegram/bot'
require 'openai'
require 'dotenv/load'

chatgpt = OpenAI::Client.new(access_token: ENV['OPENAI_TOKEN'])

Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
  bot.listen do |message|
    p "user with id #{message.from.id} reached"

    return unless message.from.id == ENV['TELEGRAM_USER_ID']

    case message.text
    when '/start'
      p 'started'
      bot.api.send_message(chat_id: message.chat.id, text: "On")
    when '/stop'
      p 'stopped'
      bot.api.send_message(chat_id: message.chat.id, text: "Off")
    else
      p 'message received'

      chatgpt_response = chatgpt.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: message.text}],
          temperature: 0.7,
        })
      bot.api.send_message(chat_id: message.chat.id, text: chatgpt_response.dig("choices", 0, "message", "content"))
    end
  end
end
