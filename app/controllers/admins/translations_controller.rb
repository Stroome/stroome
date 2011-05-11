class Admins::TranslationsController < ApplicationController
  before_filter :authenticate_admin!
  layout "admin"
  respond_to :html

  def index
    @translations = Translation.paginate(:page => params[:page])

    respond_with @translations
  end

  def show
    @translation = Translation.find(params[:id])

    respond_with @translation
  end

  def edit
    @translation = Translation.find(params[:id])

    respond_with @translation
  end

  def update
    @translation = Translation.find(params[:id])

    respond_to do |format|
      if @translation.update_attributes(params[:translation])
        format.html { redirect_to(admins_translation_url(@translation), :notice => "Label was successfully updated.")}
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @translation = Translation.find(params[:id])
    @translation.destroy

    respond_with @translation, :location => admins_translations_url
  end
end
