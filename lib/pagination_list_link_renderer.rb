class PaginationListLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer

  def to_html
    html = pagination.map do |item|
      item.is_a?(Fixnum) ?
        page_number(item) :
        send(item)
    end.join(@options[:separator])

    html = "<span class=\"m-r-20\">PAGE #{current_page} OF #{total_pages}</span> " + html

    @options[:container] ? html_container(html) : html
  end

  def previous_page
    previous_or_next_page(
      @collection.previous_page,
      current_page != 1 ? @options[:previous_label] : '',
      'previous_page'
    )
  end
  
  def next_page
    previous_or_next_page(
      @collection.next_page,
      current_page != total_pages ? @options[:next_label] : '',
      'next_page'
    )
  end

end