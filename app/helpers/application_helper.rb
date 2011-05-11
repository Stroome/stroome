module ApplicationHelper

  def project_path_by_current_user(project, current_user)
    project.project_owner?(current_user) ? manage_project_path(project) : project_path(project)
  end

  def page_title(title, title_in_page=nil)
    content_for :title, title
    content_tag "h2", (title_in_page.nil? ? title : title_in_page)
  end

  def to_short_mins(seconds)
    seconds ||= 0
    
    total_minutes = seconds / 1.minutes
    seconds_in_last_minute = seconds - total_minutes.minutes.seconds
    "#{total_minutes}:#{seconds_in_last_minute.to_s.rjust(2, '0')}"
  end

  def to_mins(seconds)
    to_short_mins(seconds) + " mins"
  end

  def date(time)
    time.strftime("%m/%d/%Y")
  end

  def short_date(time)
    time.strftime("%m/%y")
  end

  def my_project_topic_links(topics)
      topic_links(topics, lambda {|args| my_projects_path(args) })
  end

  def project_topic_links(topics)
    topic_links(topics, lambda {|args| projects_path(args) })
  end

  def group_topic_links(topics)
    topic_links(topics, lambda {|args| groups_path(args) })
  end

  def clip_topic_links(topics)
    topic_links(topics, lambda {|args| clips_path(args) })
  end

  def project_tag_links(tags)
    tag_links(tags, lambda {|args| projects_path(args) })
  end

  def clip_tag_links(tags)
    tag_links(tags, lambda {|args| clips_path(args) })
  end

  def topic_links(topics, build_path)
    topic_with_links = topics.collect do |topic|
      link_to( topic.label, build_path.call("topic_ids[]" => topic.id) )
    end
    raw( topic_with_links.join(", ") )
  end

  def tag_links(tags_s, build_path)
    return '' if tags_s.blank?
    tags = tags_s.split(",").
        collect{ |n| n.strip }.
        reject{ |n| n.blank? }.
        compact()

    tags_with_links = tags.collect do |tag|
      link_to( tag, build_path.call("q" => tag) )
    end
    raw ( tags_with_links.join(", ") )
  end

end
