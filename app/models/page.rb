class Page < ActiveRecord::Base

  CONTACT_US = "contact_us"
  CONTACT_ADDRESS = "contact_address"
  ABOUT = "about"
  FAQ = "faq"
  TERMS = "terms"
  PRIVACY = "privacy"

  ALL = [
    CONTACT_US,
    CONTACT_ADDRESS,
    ABOUT,
    FAQ,
    TERMS,
    PRIVACY
  ]
  
  def content_in_html
    content_in_markdown.to_html
  end

  def content_in_markdown
    RDiscount.new(self.content, :generate_toc)
  end

  def content_in_html_with_toc
    md = content_in_markdown
    [md.to_html, md.toc_content.force_encoding("UTF-8")]
  end
end
