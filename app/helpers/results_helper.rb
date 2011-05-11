module ResultsHelper
  SORT_OPTIONS_FOR_BROWSE = [
    ['Most Recent', 'recent'],
    ['Top Rated', 'rating'],
    ['Most Viewed', 'views']
  ]

  SORT_OPTIONS_FOR_MY_PROJECTS = [
    ['Most Recent', 'recent'],
    ['A - Z', 'az'],
    ['Z - A', 'za'],
    ['Most Viewed', 'views']
  ]

  def custom_order_by(solr, sort_type )
     case sort_type
      when 'recent' then solr.order_by(:updated_at, :desc)
      when 'rating' then solr.order_by(:rating, :desc)
      when 'az'     then solr.order_by(:title, :asc)
      when 'za'     then solr.order_by(:title, :desc)
      when 'views'  then solr.order_by(:total_views, :desc)
      else solr.order_by(:updated_at, :desc)
    end
  end

  DEFAULT_ALPHABET_OPTION = 'az'

  ALPHABET_OPTIONS = [
    ['A - Z', 'az'],
    ['A - L', 'al'],
    ['M - R', 'mr'],
    ['S - Z', 'sz']
  ]
  def limit_by_alphabet(solr, alpha_set)
    case alpha_set
      when 'az' then solr.with(:title_alphabet).between('a'..'z')
      when 'al' then solr.with(:title_alphabet).between('a'..'l')
      when 'mr' then solr.with(:title_alphabet).between('m'..'r')
      when 'sz' then solr.with(:title_alphabet).between('s'..'z')
      else solr.with(:title_alphabet).between('a'..'z')
    end
  end

  ### Projects
  
  def with_matching_rights_to_access_project(solr, current_user)
    user_id = current_user ? current_user.id : -1
    user_group_ids = current_user ? current_user.group_ids : [-1]

    solr.any_of do
        with(:visibility, Project::VISIBILITY_PUBLIC)
        all_of do
          with(:visibility, Project::VISIBILITY_PRIVATE)
          with(:member_ids, [user_id])
        end
        all_of do
          with(:visibility, Project::VISIBILITY_PRIVATE)
          with(:user_id, [user_id])
        end
        all_of do
          with(:visibility, Project::VISIBILITY_PRIVATE)
          with(:group_ids).any_of(user_group_ids)
        end unless user_group_ids.blank?
      end
  end


  def my_project_index_browse(current_user_id, params)
    that = self
    Project.search do
      with(:user_id, current_user_id)
      with(:topic_ids).any_of( params[:topic_ids] ) if not params[:topic_ids].empty?
      that.custom_order_by(self, params[:sort] )
      paginate(:page => params[:page], :per_page => params[:per_page])
    end
  end


  def project_index_search(params, current_user)
    that = self
    Project.search do
      keywords( params[:q] )
      with(:topic_ids).any_of( params[:topic_ids] ) if not params[:topic_ids].empty?
      that.with_matching_rights_to_access_project(self, current_user)
      that.custom_order_by(self, params[:sort] )
      paginate(:page => params[:page], :per_page => params[:per_page])
    end
  end

  def user_latest_projects(owner, current_user)
    that = self
    Project.search do
      with(:user_id, owner.id)
      that.with_matching_rights_to_access_project(self, current_user)
      order_by(:updated_at, :desc)
    end.results
  end

  def latest_projects(current_user, limit=20)
    that = self
    Project.search do
      that.with_matching_rights_to_access_project(self, current_user)
      order_by(:updated_at, :desc)
      paginate(:page => 1, :per_page => limit)
    end.results
  end

  def more_projects_from_owner(project, current_user, params)
    that = self
    owner = project.user_id
    this_project = project

    Project.search do
      without(this_project)
      with(:user_id, owner)
      that.with_matching_rights_to_access_project(self, current_user)
      order_by(:updated_at, :desc)
      paginate(:page => params[:page], :per_page => params[:per_page])
    end
  end

  def more_projects_like_this(project, current_user, params)
    that = self

    project.more_like_this do
      that.with_matching_rights_to_access_project(self, current_user)
      paginate(:page => params[:page], :per_page => params[:per_page])
    end
    
  end


  ### Clips
  
  def clip_index_search(params)
    that = self
    Clip.search do
      keywords( params[:q] )
      with(:topic_ids).any_of( params[:topic_ids] ) if not params[:topic_ids].empty?
      that.custom_order_by(self, params[:sort] )
      paginate(:page => params[:page], :per_page => params[:per_page])
    end
  end


  ### Profiles

  def profile_index_search(params)
    that = self
    User.search do
      keywords( params[:q] )
      with(:topic_ids).any_of( params[:topic_ids] ) if not params[:topic_ids].empty?
      that.limit_by_alphabet(self, params[:alpha] ) if params[:q].blank?
      that.custom_order_by(self, (params[:q].blank? ? "az" : params[:sort]) ) # when browse, ignore sorting, use a-z sort
      paginate(:page => params[:page], :per_page => params[:per_page])
    end
  end


  ### Groups

  def user_group_index_browse(user_id, params)
    that = self
    Group.search do
      any_of do
        with(:owner_id, user_id)
        with(:member_ids, [user_id])
      end
      that.limit_by_alphabet(self, params[:alpha] ) unless params[:alpha].nil?
      order_by(:title, :asc)
      paginate(:page => params[:page], :per_page => params[:per_page])
    end
  end

  def my_group_index_browse(current_user_id, params)
    that = self
    Group.search do
      any_of do
        with(:owner_id, current_user_id)

        with(:member_ids, [current_user_id])
      end
      that.limit_by_alphabet(self, params[:alpha] ) unless params[:alpha].nil?
      order_by(:title, :asc)
      paginate(:page => params[:page], :per_page => params[:per_page])
    end
  end

  def recommended_group_browse(topic_ids, current_user_id, exclude_group_ids, params)
    that = self
    Group.search do
      without(:owner_id, current_user_id)
      without(:id).any_of(exclude_group_ids) unless exclude_group_ids.blank?

      if topic_ids.blank?
        with(:topic_ids).any_of( [0] ) # force return no results
      else
        with(:topic_ids).any_of( topic_ids )
      end
      that.limit_by_alphabet(self, params[:alpha] ) unless params[:alpha].nil?
      order_by(:title, :asc)
      paginate(:page => params[:page], :per_page => params[:per_page])
    end
  end

  def group_index_search(current_user_id, params)
    that = self
    Group.search do
      keywords( params[:q] )
      with(:topic_ids).any_of( params[:topic_ids] ) if not params[:topic_ids].empty?
      that.limit_by_alphabet(self, params[:alpha] ) if params[:q].blank?
      that.custom_order_by(self, (params[:q].blank? ? "az" : params[:sort]) ) # when browse, ignore sorting, use a-z sort
      paginate(:page => params[:page], :per_page => params[:per_page])
    end
  end

end
