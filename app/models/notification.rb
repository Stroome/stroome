class Notification < ActiveRecord::Base
  belongs_to :user

  STATUS_READONLY = "readonly"
  STATUS_PROMPT = "prompt"

  EVENT_UPDATED_STATUS = "stroome.notification.updated.status"


  def self.new_prompt(user, title, description, token, prompt_action_options)
    entry = self.new
    entry.status = STATUS_PROMPT
    
    entry.user = user
    entry.title = title
    entry.description = description
    entry.token = token
    entry.prompt_action_options = prompt_action_options

    entry
  end

  def self.create_prompt(user, title, description, token, prompt_action_options)
    entry = self.new_prompt(user, title, description, token, prompt_action_options)
    entry.save

    entry
  end

  def self.new_readonly(user, title, description)
    entry = self.new
    entry.status = STATUS_READONLY

    entry.user = user
    entry.title = title
    entry.description = description

    entry
  end



  
  def prompt_action_options=(options)
    self.prompt_actions = ActiveSupport::JSON.encode(options)
  end

  def prompt_action_options
    ActiveSupport::JSON.decode(self.prompt_actions)
  end

  def status_readonly?
    self.status == STATUS_READONLY
  end

  def status_prompt?
    self.status == STATUS_PROMPT
  end

  def notify_status_updated
    ActiveSupport::Notifications.instrument(EVENT_UPDATED_STATUS,
          :token => self.token,
          :status => self.status
    )
  end
end
