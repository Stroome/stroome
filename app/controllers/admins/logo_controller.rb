require 'fileutils'

class Admins::LogoController < ApplicationController
  before_filter :authenticate_admin!
  layout "admin"
  respond_to :html

  LOGO_FILE_PATH = Rails.root.join("public", "images", "logo.png").to_s

  LOGO_WEB_PATH = [ "/images", "logo.png"].join("/")

  def edit
    @logo_path = LOGO_WEB_PATH
  end

  def update
    uploaded_io = params[:logo]

    FileUtils.cp(LOGO_FILE_PATH, LOGO_FILE_PATH + backup_file_postfix)

    File.open(LOGO_FILE_PATH, 'wb') do |file|
      file.write(uploaded_io.read)
    end

    redirect_to admins_logo_path, :notice => "New logo was successfully uploaded."
  end

  private
  def backup_file_postfix
    "_#{ Time.now.strftime("%Y%m%d%H%M%S%3N") }_backup"
  end
  
end
