class StatsController < ApplicationController
  def project_liked
    project = Project.find(params[:id])

    resp = Facebook.new.like_stats( project_url(project) )

    puts resp.inspect
    project.total_likes = resp[0][1]
    project.save

    render :nothing => true
  end

  def clip_liked
    clip = Clip.find(params[:id])

    resp = Facebook.new.like_stats( clip_url(clip) )

    puts resp.inspect
    clip.total_likes = resp[0][1]
    clip.save

    render :nothing => true
  end

  def project_shared
    project = Project.find(params[:id])

    project.total_shared += 1
    project.save
    
    render :nothing => true
  end

  def clip_shared
    clip = Clip.find(params[:id])

    clip.total_shared += 1
    clip.save

    render :nothing => true
  end
end
