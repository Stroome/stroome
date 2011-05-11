class ContactsController < ApplicationController
  def new
    page = Page.find_by_title(Page::CONTACT_US)
    @contact_us = page.content_in_html

    page = Page.find_by_title(Page::CONTACT_ADDRESS)
    @contact_address = page.content_in_html
  end

  def create
    entry = ContactUs.new(params)

    ContactUsMailer.submit_question(entry).deliver

    render "thankyou.html.erb"

  end
end

class ContactUs
  attr_accessor :username, :first_name, :last_name, :question, :email
  
  def initialize(params)
    @username = params[:username]
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @question = params[:question]
    @email = params[:email]
  end
end