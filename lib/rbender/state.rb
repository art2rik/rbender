class RBender::State
  def initialize(message, api, session, &state_block)
    @message          = message
    @api              = api
    @session          = session
    @chat_id          = @session[:chat_id]
    @methods          = RBender::Methods.new(message, api, session)
    @state_block      = state_block

    @keyboard                = nil

    @inline_keyboards_blocks = {}
    @after_block             = nil
    @before_block            = nil
    @text_block              = nil
    @helpers_block           = nil
    @helpers_global_block    = nil
    @pre_checkout_block      = nil
    @checkout_block          = nil
    @shipping_block          = nil
    @photo_block             = nil
    @contact_block           = nil

    @commands_blocks = {}
  end

  def get_keyboard
    @keyboard
  end

  def message
    @message
  end

  # Invokes states and processes user's input
  def invoke
    case message
    when Telegram::Bot::Types::CallbackQuery
      process_callback
    when Telegram::Bot::Types::Message
      if @message.text
        if @message.text[0] == '/' and @message.text != '/start'
          process_command(@message.text)
        else
          process_text_message
        end
      elsif @message.successful_payment
        process_checkout
      elsif @message.contact
        process_contact
      elsif @message.photo
        process_photo
      end
    when Telegram::Bot::Types::Document
      if @message.photo
        process_photo
      end
    when Telegram::Bot::Types::PreCheckoutQuery
      process_pre_checkout
    when Telegram::Bot::Types::ShippingQuery
      process_shipping
    else
      raise "This type isn't available: #{message.class}"
    end
  end

  def process_pre_checkout
    instance_exec(@message, &@pre_checkout_block)
  end

  def process_checkout
    instance_exec(@message.successful_payment, &@checkout_block)
  end

  def process_shipping
    instance_exec(@message.shipping_query, &@shipping_block)
  end

  # @param command String
  def process_command(command_line)
    splitted = command_line.split(" ")
    command  = splitted[0]
    splitted.delete_at 0
    params = splitted

    if @commands_blocks.include? command
      instance_exec(params, &@commands_blocks[command])
    end
  end

  def process_photo
    instance_exec(message.photo, &@photo_block) unless @photo_block.nil?
  end

  def process_contact
    instance_exec(message.contact, &@contact_block) unless @contact_block.nil?
  end

  # Process if message is just text
  def process_text_message
    unless @keyboard.nil? # if state has keyboard
      @keyboard.instance_eval(&@helpers_block) unless @helpers_block.nil?
      @keyboard.instance_eval(&@helpers_global_block) unless @helpers_global_block.nil?
      build_keyboard

      @keyboard.markup_final.each do |btn, final_btn|
        if message.text == final_btn
          instance_exec(&@keyboard.actions[btn]) # Process keyboard action
          return
        end
      end
    end

    unless @text_block.nil?  # Else process text action
      instance_exec(@message.text, &@text_block)
    end
  end

  # Process if message is inline keyboard callback
  def process_callback
    keyboard_name, action = @message.data.split(RBender::CALLBACK_SPLITTER)
    keyboard              = @inline_keyboards_blocks[keyboard_name.to_sym]
    keyboard.instance_eval(&@helpers_block) unless @helpers_block.nil?
    keyboard.invoke unless keyboard.nil?

    unless keyboard.nil?
      if keyboard.buttons_actions[action]
        instance_eval(&keyboard.buttons_actions[action])
      else
        raise "There is no action called '#{action}'"
      end
    else
      edit_message_text text: ":)"
    end
  end

  def build
    instance_exec(&@state_block)
  end

  def build_keyboard
    @keyboard.build(@session)
  end

  def invoke_keyboard
    @api.send_message(chat_id:      @chat_id,
                      text:         @keyboard.response,
                      reply_markup: @keyboard.markup_tg)
  end

  def invoke_before
    instance_eval(&@before_block)
  end

  def has_after?
    @after_block.nil? ? false : true
  end

  def has_before?
    @before_block.nil? ? false : true
  end

  def invoke_after
    instance_eval(&@after_block)
  end

  def has_keyboard?
    @keyboard.nil? ? false : true
  end

  public

  # adds inline keyboard
  def keyboard_inline(inline_keyboard_name, &inline_keyboard_block)
    @inline_keyboards_blocks[inline_keyboard_name] = RBender::KeyboardInline.new(inline_keyboard_name,
                                                                                 @message,
                                                                                 @session,
                                                                                 inline_keyboard_block)
  end

  #before hook
  def before(&action)
    if @before_block.nil?
      @before_block = action
    else
      raise 'Too many before hooks!'
    end
  end

  #after hook
  def after(&action)
    if @after_block.nil?
      @after_block = action
    else
      raise 'Too many after hooks!'
    end
  end

  # Text callbacks
  def text(&action)
    if @text_block.nil?
      @text_block = action
    else
      raise 'Too many text processors!'
    end
  end

  def keyboard(&keyboard_block)
    if @is_global
      raise 'Global state doesn\'t support :keyboard method'
    end
    @keyboard         = RBender::Keyboard.new(@message)
    @keyboard.session = @session
    @keyboard.instance_eval(&keyboard_block)
  end

  #initialize helper methods
  def helpers(&helpers_block)
    if @helpers_block
      @helpers_global_block = helpers_block
    else
      @helpers_block = helpers_block
    end

    instance_eval(&helpers_block)
  end

  def photo(&block)
    if @photo_action.nil?
      @photo_block = block
    else
      raise 'Image block already defined'
    end
  end

  alias image photo
  alias picture photo

  def contact(&block)
    if @contact_block.nil?
      @contact_block = block
    else
      raise 'Contact block already defined'
    end
  end

  def command(command, &action)
    if @commands_blocks.include? command
      raise "Command #{command} already exists"
    else
      if command[0] == '/'
        @commands_blocks[command] = action
      else
        raise "Command should be started from slash symbol (/)"
      end
    end
  end


  def method_missing(m, *args, &block)
    if RBender::Methods.method_defined? m
      if block_given?
        if args.empty?
          return @methods.send(m, &block)
        else
          args = args[0] if args.count == 1
          return @methods.send(m, args, &block)
        end
      else
        if args.empty?
          return @methods.send(m)
        else
          args = args[0] if args.count == 1
          return @methods.send(m, args)
        end
      end
    else
      raise NoMethodError, "Method #{m} is missing"
    end
  end

  # Returns Inline keyboard object by name
  def inline_markup(name)
    raise "Keyboard #{name} doesn't exists!" unless @inline_keyboards_blocks.member? name
    kb = @inline_keyboards_blocks[name]
    kb.instance_eval(&@helpers_block) unless @helpers_block.nil?
    kb.instance_eval(&@helpers_global_block) unless @helpers_global_block.nil?
    kb.build
    kb.markup_tg
  end

  def pre_checkout(&block)
    if @pre_checkout_block.nil?
      @pre_checkout_block = block
    else
      raise 'Too many pre_checkout actions'
    end
  end

  alias pre_checkout_query pre_checkout

  def checkout(&block)
    if @checkout_block.nil?
      @checkout_block = block
    else
      raise 'Too many pre_checkout actions'
    end
  end

  alias successful_payment checkout
  alias payment checkout

  def shipping(&block)
    @shipping_block = block
  end
end

