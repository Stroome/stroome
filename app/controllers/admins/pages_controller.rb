class Admins::PagesController < ApplicationController
  before_filter :authenticate_admin!
  layout "admin"

  # GET /admins/pages
  # GET /admins/pages.xml
  def index
    @pages = Page.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
    end
  end

  # GET /admins/pages/1
  # GET /admins/pages/1.xml
  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /admins/pages/new
  # GET /admins/pages/new.xml
  def new
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  # GET /admins/pages/1/edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /admins/pages
  # POST /admins/pages.xml
  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        format.html { redirect_to(admins_page_url(@page), :notice => 'Page was successfully created.') }
        format.xml  { render :xml => @page, :status => :created, :location => admins_page_url(@page) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admins/pages/1
  # PUT /admins/pages/1.xml
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        format.html { redirect_to(admins_page_url(@page), :notice => 'Page was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admins/pages/1
  # DELETE /admins/pages/1.xml
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to(admins_pages_url) }
      format.xml  { head :ok }
    end
  end
end
