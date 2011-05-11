class PagesController < ApplicationController
  def home
  end

  def contact
  end

  def about
    @content, ignored = content_and_toc_for_page(Page::ABOUT)
  end

  def faq
    @content, @toc  = content_and_toc_for_page(Page::FAQ)
  end

  def terms
    @content, @toc = content_and_toc_for_page(Page::TERMS)
  end

  def privacy
    @content, @toc = content_and_toc_for_page(Page::PRIVACY)
  end

  private
  def content_and_toc_for_page(title)
    page = Page.find_by_title(title)
    page.content_in_html_with_toc
  end

end
