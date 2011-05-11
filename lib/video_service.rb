require 'kaltura'

class VideoService
  @cfg

  def initialize(cfg)
    @cfg = cfg
  end

  def new_client(session=nil)
    config = Kaltura::Configuration.new(@cfg.partner_id)
    client = Kaltura::Client.new(config)
    client.ks = session

    client
  end

  def new_admin_session(user_id)
    config = Kaltura::Configuration.new(@cfg.partner_id)
    client = Kaltura::Client.new(config)
    client.session_service.start(@cfg.admin_secret, user_id, Kaltura::Constants::SessionType::ADMIN)
  end

  def new_read_session(user_id)
    config = Kaltura::Configuration.new(@cfg.partner_id)
    client = Kaltura::Client.new(config)
    client.session_service.start(@cfg.user_secret, user_id, Kaltura::Constants::SessionType::USER)
  end

  def new_edit_session(user_id)
    config = Kaltura::Configuration.new(@cfg.partner_id)
    client = Kaltura::Client.new(config)
    client.session_service.start(@cfg.user_secret, user_id, Kaltura::Constants::SessionType::USER,
                                 @cfg.partner_id, @cfg.session_expiry, 'edit:*')
  end

  def get_video_mix(video_id, client)
    client.mixing_service.get(video_id)
  end

  def get_clips_used_in_video_mix(video_id, client)
    entries = client.mixing_service.get_ready_media_entries(video_id) || []
    entries.select { |entry| entry.media_type == Kaltura::Constants::Media::Type::VIDEO }
  end

  
end