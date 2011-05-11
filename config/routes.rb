Stroome::Application.routes.draw do

  namespace :admins do resources :settings end

  ################
  # public

  # Devise stuff
  devise_for :users, :controllers => {
      :passwords => "users/passwords",
      :registrations => 'users/registrations',
      :sessions => 'users/sessions',
      :omniauth_callbacks => 'users/omniauth_callbacks'
  }

  resources :comments do
    member do
      get "delete"
    end
  end

  resources :clips do
    member do
      get 'more_like_this'
      get 'more_from_owner'
      post 'rate'
    end

    #resources :comments
  end
  match '/clips/:clip_id/comment_list', :to => "comments#clip_list", :as => "clip_comment_list"
  match '/clips/:clip_id/comments', :to => 'comments#clip_comments', :as => "clip_comments", :via => :get
  match '/clips/:clip_id/comments', :to => 'comments#create', :as => "clip_comments", :via => :post


  resources :projects do
    member do
      get "summary"
      get 'manage'
      get 'basic_editor'
      get 'advanced_editor'
      get 'video_saved'
      get 'more_like_this'
      get 'more_from_owner'
      post 'rate'
      get "comment_widget"
    end

    #resources :comments
  end
  match '/projects/:project_id/comment_list', :to => "comments#project_list", :as => "project_comment_list"
  match '/projects/:project_id/comments', :to => 'comments#project_comments', :as => "project_comments", :via => :get
  match '/projects/:project_id/comments', :to => 'comments#create', :as => "project_comments", :via => :post
  
  match '/my_projects', :to => 'projects#my_index', :as => 'my_projects'

  if FBT.enable_activity_stream

    match '/profiles/:user_id/activities', :to => "activities#user_stream", :as => "user_activities", :via => :get
    match '/groups/:group_id/activities', :to => "activities#group_stream", :as => "group_activities", :via => :get

    match '/my_follow_stream', :to => "activities#my_follow_stream", :as => "my_follow_stream", :via => :get

    match '/profiles/:user_id/follow', :to => "follows#follow_user", :as => "follow_user", :via => :post
    match '/profiles/:user_id/unfollow', :to => "follows#unfollow_user", :as => "unfollow_user", :via => :post
    match '/groups/:group_id/follow', :to => "follows#follow_group", :as => "follow_group", :via => :post
    match '/groups/:group_id/unfollow', :to => "follows#unfollow_group", :as => "unfollow_group", :via => :post

  end

  if FBT.enable_group
    resources :groups do
      collection do
        get 'pending_activity_stream'
        get 'recommended'
      end
      member do
        post 'join'
        post 'unjoin'
        post 'request_join'
      end
    end
    match '/groups/:group_id/comment_list', :to => "comments#group_list", :as => "group_comment_list"
    match '/groups/:group_id/comments', :to => 'comments#group_comments', :as => "group_comments", :via => :get
    match '/groups/:group_id/comments', :to => 'comments#create', :as => "group_comments", :via => :post


    match '/my_groups', :to => 'groups#my_index', :as => 'my_groups'
    match '/groups/:group_id/members', :to => 'group_members#index', :as => 'group_members', :via => :get
    match '/group_members/:id/delete', :to => 'group_members#delete', :as => 'delete_group_member', :via => :get
    match '/group_members/:id', :to => 'group_members#destroy', :as => 'group_member', :via => :delete
    match '/profiles/:user_id/groups', :to => 'groups#user_index', :as => 'user_groups', :via => :get

    match "/groups/:group_id/invite", :to => "invite_others#new", :as => "invite_to_group", :via => :get
    match "/groups/:group_id/invite", :to => "invite_others#invite_join_group", :as => "invite_join_group", :via => :post
    match "/groups/:group_id/invite/search", :to => "invite_others#search", :as => "invite_to_group_search",:via => :get
    match "/groups/:group_id/invite/email",  :to => "invite_others#email",  :as => "invite_to_group_email", :via => :get
    match "/groups/:group_id/invite/email",  :to => "invite_others#email_join_group",  :as => "email_join_group", :via => :post

    match "/projects/:project_id/groups", :to => "project_groups#index", :as => "project_groups"
    resources :project_groups do
      member do
        get "delete"
      end
    end

    match "/groups/:group_id/projects", :to => "group_projects#index", :as => "group_projects", :via => :get
    match "/groups/:group_id/projects/reply", :to => "group_projects#reply", :as => "reply_group_projects", :via => :post
    match "/group_projects/:id", :to => "group_projects#destroy", :as => "group_project", :via => :delete
  end
  
  resources :profiles

  resources :inbin_clip_refs do
    member do
      get "delete"
      post "use"
    end
  end
  match "/projects/:project_id/clip_bin", :to => "inbin_clip_refs#project_clip_bin", :as => "project_clip_bin"
  match "/users/:user_id/clip_bin", :to => "inbin_clip_refs#user_clip_bin", :as => "user_clip_bin"

  match '/users/check_username', :to => 'users/registration_callbacks#check_username'
  match '/users/check_email', :to => 'users/registration_callbacks#check_email'

  match '/dashboard', :to => 'dashboard#show', :via => :get, :as => 'user_root'

  match '/change_password', :to => 'change_password#edit', :via => :get
  match '/change_password', :to => 'change_password#update', :via => :put

  match '/', :to => "pages#home"
  match '/about', :to => "pages#about"
  match '/faq', :to => "pages#faq"
  match '/terms', :to => "pages#terms"
  match '/privacy', :to => "pages#privacy"

  match "/contact", :to => "contacts#new", :as => "contact_us"
  match "/contact/create", :to => "contacts#create", :as => "submit_question"

  match "/projects/:id/liked", :to => "stats#project_liked", :as => "project_liked"
  match "/clips/:id/liked", :to => "stats#clip_liked", :as => "clip_liked"
  match "/projects/:id/shared", :to => "stats#project_shared", :as => "project_shared"
  match "/clips/:id/shared", :to => "stats#clip_shared", :as => "clip_shared"

  match "/projects/:project_id/members", :to => "project_members#project_members", :as => "project_members"
  resources :project_members do
    member do
      get "delete"
    end
  end

  if FBT.enable_project_invite_user
    match "/projects/:project_id/invite", :to => "invite_others#new", :as => "invite_to_project", :via => :get
    match "/projects/:project_id/invite", :to => "invite_others#invite_join_project", :as => "invite_join_project", :via => :post
    match "/projects/:project_id/invite/search", :to => "invite_others#search", :as => "invite_to_project_search",:via => :get
    match "/projects/:project_id/invite/email",  :to => "invite_others#email",  :as => "invite_to_project_email", :via => :get
    match "/projects/:project_id/invite/email",  :to => "invite_others#email_join_project",  :as => "email_join_project", :via => :post

  end

  match "/notifications", :to => "user_notifications#index", :as => "user_notifications", :via => :get
  match "/notifications/:id", :to => "user_notifications#update", :as => "user_notification", :via => :post


  ################
  # admin

  devise_for :admins, :controllers => {
      :sessions => "admins/sessions",
      :passwords => "admins/passwords",
      :registrations => "admins/registrations",
  }

  namespace :admins do
    root :to => "dashboard#show"
    resources :users do
      member do
        post "reset_password"
      end
    end
    resources :comments, :translations, :topics, :pages
    match "/logo", :to => "logo#edit", :via => :get, :as => 'logo'
    match "/logo", :to => "logo#update", :via => :put, :as => 'logo'
  end







  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "pages#home"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
