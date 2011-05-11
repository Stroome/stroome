class Admins::SettingsController < ApplicationController
  before_filter :authenticate_admin!
  layout "admin"
  
  # GET /admins/settings
  # GET /admins/settings.xml
  def index
    @settings = Setting.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @settings }
    end
  end

  # GET /admins/settings/1
  # GET /admins/settings/1.xml
  def show
    @setting = Setting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @setting }
    end
  end

  # GET /admins/settings/new
  # GET /admins/settings/new.xml
  def new
    @setting = Setting.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @setting }
    end
  end

  # GET /admins/settings/1/edit
  def edit
    @setting = Setting.find(params[:id])
  end

  # POST /admins/settings
  # POST /admins/settings.xml
  def create
    @setting = Setting.new(params[:admins_setting])

    respond_to do |format|
      if @setting.save
        format.html { redirect_to(@setting, :notice => 'Setting was successfully created.') }
        format.xml  { render :xml => @setting, :status => :created, :location => @setting }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admins/settings/1
  # PUT /admins/settings/1.xml
  def update
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update_attributes(params[:admins_setting])
        format.html { redirect_to(@setting, :notice => 'Setting was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admins/settings/1
  # DELETE /admins/settings/1.xml
  def destroy
    @setting = Setting.find(params[:id])
    @setting.destroy

    respond_to do |format|
      format.html { redirect_to(settings_url) }
      format.xml  { head :ok }
    end
  end
end
