require_relative "../lib/telebot"
require 'pp'

def fixture(file_name)
  File.expand_path("../fixtures/#{file_name}", __FILE__)
end

token = ENV['TOKEN']
bot = Telebot::Bot.new(token)

bot.run do |client, message|
  puts "#{message.from.first_name}: #{message.text}"

  case message.text
  when /get_me/
    info = client.get_me
    client.send_message(chat_id: message.chat.id, text: info.inspect)
  when /send_message/
    client.send_message(chat_id: message.chat.id, text: "You said: #{message.text}")
  when /send_photo/
    file = Telebot::InputFile.new(fixture("bender_pic.jpg"), 'image/jpeg')
    client.send_photo(chat_id: message.chat.id, photo: file)
  when /forward_message/
    client.forward_message(chat_id: message.chat.id, from_chat_id: message.chat.id, message_id: message.message_id)
  when /send_audio/
    client.send_message(chat_id: message.chat.id, text: "Let me say 'Hi' in Esperanto.")
    file = Telebot::InputFile.new(fixture("saluton_amiko.ogg"))
    client.send_audio(chat_id: message.chat.id, audio: file)
  else
    client.send_message(chat_id: message.chat.id, text: "Unknown command")
  end
end
