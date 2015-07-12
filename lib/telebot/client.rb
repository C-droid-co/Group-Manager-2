# Implemented:
# * getMe
# * getUpdates
# * sendMessage
# * sendPhoto
# * forwardMessage
# * sendAudio
#
# REMAINING:
# * sendDocument
# * sendSticker
# * sendVideo
# * sendLocation
# * sendChatAction
# * getUserProfilePhotos
# * setWebhook

module Telebot
  class Client
    API_URL = "https://api.telegram.org".freeze

    def initialize(token, adapter: :net_http)
      @token = token

      @faraday = Faraday.new(API_URL) do |conn|
        conn.request :multipart
        conn.request :url_encoded
        conn.response :json, :content_type => /\bjson$/
        conn.adapter adapter
      end
    end

    # A simple method for testing your bot's auth token. Requires no parameters.
    # Returns basic information about the bot in form of a User object.
    #
    # @return [Telebot::User]
    def get_me
      result = call(:getMe)
      User.new(result)
    end

    # Use this method to receive incoming updates using long polling.
    # An Array of Update objects is returned.
    #
    # Note:
    # 1. This method will not work if an outgoing webhook is set up.
    # 2. In order to avoid getting duplicate updates, recalculate offset after each server response.
    #
    # @param offset [Integer]
    #   Identifier of the first update to be returned.
    #   Must be greater by one than the highest among the identifiers of
    #   previously received updates. By default, updates starting with the
    #   earliest unconfirmed update are returned. An update is considered
    #   confirmed as soon as getUpdates is called with an offset higher
    #   than its update_id.
    # @param limit [Integer]
    #   Limits the number of updates to be retrieved. Values between 1—100 are accepted.
    #   Defaults to 100
    # @param timeout [Integer]
    #   Timeout in seconds for long polling. Defaults to 0, i.e. usual short polling.
    #
    # @return [Array<Telebot::Update>]
    def get_updates(offset: nil, limit: nil, timeout: nil)
      result = call(:getUpdates, offset: offset, limit: limit, timeout: timeout)
      result.map { |update_hash| Update.new(update_hash) }
    end

    # Send text message.
    #
    # @param chat_id [Integer] Unique identifier for the message recipient - User or GroupChat id
    # @param text [String] Text of the message to be sent
    # @param disable_web_page_preview [Boolean] Disables link previews for links in this message
    # @param reply_to_message_id [Integer] If the message is a reply, ID of the original message
    # @param reply_markup [ReplyKeyboardMarkup, ReplyKeyboardHide, ForceReply] Additional interface options
    #
    # @return [Telebot::Message]
    def send_message(chat_id:, text:, disable_web_page_preview: false, reply_to_message_id: nil, reply_markup: nil)
      result = call(:sendMessage,
        chat_id: chat_id,
        text: text,
        disable_web_page_preview: disable_web_page_preview,
        reply_to_message_id: reply_to_message_id,
        reply_markup: reply_markup
      )
      Message.new(result)
    end

    # Use this method to forward messages of any kind.
    #
    # @param chat_id [Integer] Unique identifier for the message recipient - User or GroupChat id
    # @param from_chat_id [Integer] Unique identifier for the chat where the original message was sent - User or GroupChat id
    # @param message_id [Integer] Unique message identifier
    #
    # @return [Telebot::Message]
    def forward_message(chat_id:, from_chat_id:, message_id:)
      result = call(:forwardMessage, chat_id: chat_id, from_chat_id: from_chat_id, message_id: message_id)
      Message.new(result)
    end

    # Send a picture.
    #
    # @param chat_id [Integer] Unique identifier for the message recipient - User or GroupChat id
    # @param photo [InputFile, String] Photo to send. You can either pass a
    #   file_id as String to resend a photo that is already on the Telegram servers,
    #   or upload a new photo using multipart/form-data.
    # @param caption [String] Photo caption (may also be used when resending photos by file_id)
    # @param reply_to_message_id [Integer] If the message is a reply, ID of the original message
    # @param reply_markup [ReplyKeyboardMarkup, ReplyKeyboardHide, ForceReply] Additional interface options
    #
    # @return [Telebot::Message]
    def send_photo(chat_id:, photo:, caption: nil, reply_to_message_id: nil, reply_markup: nil)
      result = call(:sendPhoto, chat_id: chat_id, photo: photo, caption: caption, reply_to_message_id: reply_to_message_id, reply_markup: reply_markup)
      Message.new(result)
    end

    # Use this method to send audio files, if you want Telegram clients to
    # display the file as a playable voice message. For this to work, your
    # audio must be in an .ogg file encoded with OPUS (other formats may be sent as Document)
    #
    # @param chat_id [Integer]
    # @param audio [Telebot::InputFile, String] Audio file to send (file or file_id)
    # @param reply_to_message_id [Integer] If the message is a reply, ID of the original message
    # @param reply_markup [ReplyKeyboardMarkup, ReplyKeyboardHide, ForceReply] Additional interface options
    #
    # @return [Telebot::Message]
    def send_audio(chat_id:, audio:, reply_to_message_id: nil, reply_markup: nil)
      result = call(:sendAudio, chat_id: chat_id, audio: audio, reply_to_message_id: reply_to_message_id, reply_markup: reply_markup)
      Message.new(result)
    end



    private def call(method_name, params = {})
      path = "/bot#{@token}/#{method_name}"
      faraday_response = @faraday.post(path, params)
      response = Response.new(faraday_response.body)

      if response.ok
        response.result
      else
        error = Error.new(response.description, response.error_code)
        fail(error)
      end
    end
  end
end