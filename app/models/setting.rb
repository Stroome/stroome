class Setting < ActiveRecord::Base

  CONTACT_EMAIL = "contact_email"

  def self.get(name, default_value=nil)
    if setting = self.find_by_name(name)
      setting.value
    else
      default_value
    end
  end
  
end
