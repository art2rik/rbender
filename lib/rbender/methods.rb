require 'faraday'

class RBender::Methods

  def initialize(message, api, session)
    @message = message
    @api     = api
    @session = session
  end

  #--------------
  # User methods
  #--------------

  # Set message user gets while keyboard has invoked
  def set_response(new_response)
    @keyboard.set_response(new_response)
  end

  # Returns session hash
  def session
    @session
  end

  # Returns message object
  def message
    case @message
    when Telegram::Bot::Types::CallbackQuery
      @message.message
    when Telegram::Bot::Types::Message
      @message
    else
      @message
    end
  end

  def chat_id
    message().chat.id
  end

  def switch(state_to)
    @session[:state] = state_to
  end

  #--------------
  # API METHODS
  #--------------
  # Hides inline keyboard
  # Must be called from any inline keyboard state

  def send_message(text:,
                   chat_id: chat_id(),
                   parse_mode: nil,
                   disable_web_page_preview: nil,
                   disable_notification: nil,
                   reply_to_message_id: nil,
                   reply_markup: nil)

    if text.strip.empty?
      raise "A text can't be empty or consists of space symbols only"
    end
    @api.send_message chat_id:                  chat_id,
                      text:                     text,
                      disable_web_page_preview: disable_web_page_preview,
                      disable_notification:     disable_notification,
                      reply_to_message_id:      reply_to_message_id,
                      parse_mode:               parse_mode,
                      reply_markup:             reply_markup
  end

  def edit_message_text(inline_message_id: nil,
                        text:,
                        chat_id: chat_id(),
                        message_id: message().message_id,
                        parse_mode: nil,
                        disable_web_page_preview: nil,
                        reply_markup: nil)
    if text.strip.empty?
      raise "A text can't be empty or consists of space symbols only"
    end
    @api.edit_message_text chat_id:                  chat_id,
                           message_id:               message_id,
                           text:                     text,
                           inline_message_id:        inline_message_id,
                           parse_mode:               parse_mode,
                           disable_web_page_preview: disable_web_page_preview,
                           reply_markup:             reply_markup
  end

  def edit_message_caption(inline_message_id: nil,
                           caption: nil,
                           chat_id: chat_id(),
                           message_id: message().message_id,
                           reply_markup: nil)
    if text.strip.empty?
      raise "A text can't be empty or consists of space symbols only"
    end
    @api.edit_message_text chat_id:           chat_id,
                           message_id:        message_id,
                           caption:           caption,
                           inline_message_id: inline_message_id,
                           reply_markup:      reply_markup
  end

  def edit_message_reply_markup(chat_id: chat_id(),
                                message_id: message().message_id,
                                inline_message_id: nil,
                                reply_markup: nil)
    @api.edit_message_reply_markup chat_id:           chat_id,
                                   message_id:        message_id,
                                   inline_message_id: inline_message_id,
                                   reply_markup:      reply_markup
  end

  def answer_callback_query(callback_query_id: @message.id,
                            text: nil,
                            show_alert: nil,
                            url: nil,
                            cache_time: nil)
    @api.answer_callback_query(callback_query_id: callback_query_id,
                               text: text,
                               show_alert: show_alert,
                               url: url,
                               cache_time: cache_time)
  end

  def delete_message(chat_id: chat_id(),
                     message_id: message().message_id)
    @api.delete_message(chat_id:    chat_id,
                        message_id: message_id)
  end


  def get_file(file_id:)
    result = @api.get_file(file_id: file_id)
    result['ok'] ? result['result'] : nil
  end

  def get_file_path(file_id:)
    result = @api.get_file(file_id: file_id)
    result['ok'] ? result['result']['file_path'] : nil
  end

  def get_me()
    @api.get_me
  end

  def forward_message(chat_id:,
                      from_chat_id: chat_id(),
                      disable_notification: false,
                      message_id:)
    @api.forward_message(chat_id:              chat_id,
                         from_chat_id:         from_chat_id,
                         disable_notification: disable_notification,
                         message_id:           message_id)
  end

  def send_photo(chat_id: chat_id(),
                 photo:,
                 caption: nil,
                 disable_notification: false,
                 reply_to_message_id: nil,
                 reply_markup: nil)
    @api.send_photo(chat_id:              chat_id,
                    photo:                photo,
                    caption:              caption,
                    disable_notification: disable_notification,
                    reply_to_message_id:  reply_to_message_id,
                    reply_markup:         reply_markup)
  end

  def send_audio(chat_id: chat_id(),
                 audio:,
                 caption: nil,
                 duration: nil,
                 performer: nil,
                 title: nil,
                 disable_notification: false,
                 reply_to_message_id: nil,
                 reply_markup: nil)

    @api.send_audio(chat_id:              chat_id,
                    audio:                audio,
                    caption:              caption,
                    duration:             duration,
                    performer:            performer,
                    title:                title,
                    disable_notification: disable_notification,
                    reply_to_message_id:  reply_to_message_id,
                    reply_markup:         reply_markup)
  end

  def send_media_group(chat_id: chat_id(),
                       media:,
                       disable_notification: nil,
                       reply_to_message_id: nil)
    @api.send_media_group(chat_id:              chat_id,
                          media:                media,
                          disable_notification: disable_notification,
                          reply_to_message_id:  reply_to_message_id)
  end

  def send_document(chat_id: chat_id(),
                    document:,
                    caption: nil,
                    disable_notification: false,
                    reply_to_message_id: nil,
                    reply_markup: nil)
    @api.send_document(chat_id:              chat_id,
                       document:             document,
                       caption:              caption,
                       disable_notification: disable_notification,
                       reply_to_message_id:  reply_to_message_id,
                       reply_markup:         reply_markup)
  end

  def send_sticker(chat_id: chat_id(),
                   sticker:,
                   caption: nil,
                   disable_notification: false,
                   reply_to_message_id: nil,
                   reply_markup: nil)
    @api.send_sticker(chat_id:              chat_id,
                      sticker:              sticker,
                      caption:              caption,
                      disable_notification: disable_notification,
                      reply_to_message_id:  reply_to_message_id,
                      reply_markup:         reply_markup)
  end

  def send_video(chat_id: chat_id(),
                 video:,
                 width: nil,
                 height: nil,
                 caption: nil,
                 duration: nil,
                 disable_notification: false,
                 reply_to_message_id: nil,
                 reply_markup: nil)
    @api.send_video(chat_id:              chat_id,
                    video:                video,
                    width:                width,
                    height:               height,
                    caption:              caption,
                    duration:             duration,
                    disable_notification: disable_notification,
                    reply_to_message_id:  reply_to_message_id,
                    reply_markup:         reply_markup)
  end

  def send_voice(chat_id: chat_id(),
                 voice:,
                 caption: nil,
                 duration: nil,
                 disable_notification: false,
                 reply_to_message_id: nil,
                 reply_markup: nil)

    @api.send_voice(chat_id:              chat_id,
                    voice:                voice,
                    caption:              caption,
                    duration:             duration,
                    disable_notification: disable_notification,
                    reply_to_message_id:  reply_to_message_id,
                    reply_markup:         reply_markup)
  end

  def send_video_note(chat_id: chat_id(),
                      video_note:,
                      length: nil,
                      duration: nil,
                      disable_notification: false,
                      reply_to_message_id: nil,
                      reply_markup: nil)
    @api.send_video_note(chat_id:              chat_id,
                         video_note:           video_note,
                         length:               length,
                         duration:             duration,
                         disable_notification: disable_notification,
                         reply_to_message_id:  reply_to_message_id,
                         reply_markup:         reply_markup)
  end

  def send_location(chat_id: chat_id(),
                    latitude:,
                    longitude:,
                    disable_notification: false,
                    reply_to_message_id: nil,
                    reply_markup: nil)

    @api.send_location(chat_id:              chat_id,
                       latitude:             latitude,
                       longitude:            longitude,
                       disable_notification: disable_notification,
                       reply_to_message_id:  reply_to_message_id,
                       reply_markup:         reply_markup)
  end

  def send_venue(chat_id: chat_id(),
                 latitude:,
                 longitude:,
                 title:,
                 address:,
                 foursquare_id: nil,
                 disable_notification: false,
                 reply_to_message_id: nil,
                 reply_markup: nil)

    @api.send_venue(chat_id:              chat_id,
                    latitude:             latitude,
                    longitude:            longitude,
                    title:                title,
                    address:              address,
                    foursquare_id:        foursquare_id,
                    disable_notification: disable_notification,
                    reply_to_message_id:  reply_to_message_id,
                    reply_markup:         reply_markup)
  end

  def send_contact(chat_id: chat_id(),
                   phone_number:,
                   first_name:,
                   last_name: nil,
                   disable_notification: false,
                   reply_to_message_id: nil,
                   reply_markup: nil)

    @api.send_contact(chat_id:              chat_id,
                      phone_number:         phone_number,
                      first_name:           first_name,
                      last_name:            last_name,
                      disable_notification: disable_notification,
                      reply_to_message_id:  reply_to_message_id,
                      reply_markup:         reply_markup)
  end

  def send_chat_action(chat_id: chat_id(),
                       action:)
    @api.send_chat_action(chat_id: chat_id,
                          action:  action)
  end

  def get_user_profile_photos(chat_id: chat_id(),
                              offset: nil,
                              limit: nil)
    @api.get_user_profile_photos(chat_id: chat_id,
                                 offset:  offset,
                                 limit:   limit)
  end

  def kick_chat_member(chat_id:,
                       user_id:)
    @api.kick_chat_member(chat_id: chat_id,
                          user_id: user_id)
  end

  def unban_chat_member(chat_id:,
                        user_id:)
    @api.unban_chat_member(chat_id: chat_id,
                           user_id: user_id)
  end

  def leave_chat(chat_id:)
    @api.leave_chat(chat_id: chat_id)
  end

  def get_chat(chat_id:)
    @api.get_chat(chat_id: chat_id)
  end

  def get_chat_administrators(chat_id:)
    @api.get_chat_administrators(chat_id: chat_id)
  end

  def get_chat_members_count(chat_id:)
    @api.get_chat_members_count(chat_id: chat_id)
  end

  def get_chat_member(chat_id:, user_id:)
    @api.get_chat_member(chat_id: chat_id,
                         user_id: user_id)
  end

  def upload_file(file_path)
    full_path = "#{Dir.pwd}/public/#{file_path}"
    Faraday::UploadIO.new(full_path, "multipart/form-data")
  end

  alias file upload_file
  alias upload upload_file

  def download_file(file_path:, to:)
    url   = 'https://api.telegram.org/file/bot'
    token = RBender::ConfigHandler.token
    path  = Dir.pwd + "/public/#{to}"


    http_conn = Faraday.new do |builder|
      builder.adapter(Faraday.default_adapter)
    end

    response = http_conn.get "#{url}#{token}/#{file_path}"

    dir = File.dirname(path)

    unless File.directory?(dir)
      FileUtils.mkdir_p(dir)
    end

    File.open(path, 'wb') { |fp| fp.write(response.body) }
  end

  alias download download_file

  def send_invoice(chat_id: chat_id(), title:, description:,
                   payload:, provider_token:, start_parameter:, currency:,
                   prices:, provider_data: nil, photo_url: nil, photo_size: nil,
                   photo_width: nil, need_name: nil, need_phone_number: nil, need_email: nil,
                   need_shipping_address:, send_phone_number_to_provider: nil, send_email_to_provider: nil,
                   is_flexible: nil, disable_notification: nil, reply_to_message_id: nil, reply_markup: nil)

    @api.send_invoice(chat_id:                       chat_id,
                      title:                         title,
                      description:                   description,
                      payload:                       payload,
                      provider_token:                provider_token,
                      start_parameter:               start_parameter,
                      currency:                      currency,
                      prices:                        prices, provider_data: provider_data,
                      photo_url:                     photo_url,
                      photo_size:                    photo_size,
                      photo_width:                   photo_width,
                      need_name:                     need_name,
                      need_phone_number:             need_phone_number,
                      need_email:                    need_email,
                      need_shipping_address:         need_shipping_address,
                      send_phone_number_to_provider: send_phone_number_to_provider,
                      send_email_to_provider:        send_email_to_provider,
                      is_flexible:                   is_flexible,
                      disable_notification:          disable_notification,
                      reply_to_message_id:           reply_to_message_id,
                      reply_markup:                  reply_markup)
  end

  def answer_shipping_query(shipping_query_id:, ok:,
                            shipping_options: nil, error_message: nil)
    @api.answer_shipping_query(shipping_query_id: shipping_query_id,
                               shipping_options:  shipping_options,
                               error_message:     error_message,
                               ok:                ok)
  end

  def answer_pre_checkout_query(pre_checkout_query_id: message().id, ok:, error_message: nil)
    @api.answer_pre_checkout_query(pre_checkout_query_id: pre_checkout_query_id,
                                   error_message:         error_message,
                                   ok:                    ok)
  end
end

