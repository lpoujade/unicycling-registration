Workspace::Application.routes.draw do

  scope "(:locale)" do
    resources :registrant_groups, :except => [:new] do
      collection do
        get :list
      end
      member do
        get :address_labels
      end
    end

    namespace :printing do
      namespace :race_recording do
        get :blank
        get :instructions
      end
      resources :competitions, :only => [] do
        member do
          get :announcer
          get :heat_recording
          get :two_attempt_recording
          get :results
        end
      end
      resources :events, :only => [] do
        member do
          get :results
        end
      end
    end

    # ADMIN (for use in Setting up the system)
    #
    #
    resources :age_group_types, :except => [:show] do
      resources :age_group_entries, :only => [:index, :create]
    end
    resources :age_group_entries, :except => [:index, :create]

    resources :permissions, :only => [:index] do
      collection do
        put :set_role
      end
    end


    namespace :admin do
      resources :payments, :only => [:index, :new, :create]  do
        collection do
          get :onsite_pay_new
          post :adjust_payment_choose
          post :onsite_pay_confirm
          post :onsite_pay_create
          post :refund_choose
          post :refund_create
        end
      end

      namespace :export do
        get :index

        # NEW routes
        get :download_event_configuration
        post :upload_event_configuration
        get :download_registrants
        post :upload_registrants
        get :download_time_results
        post :upload_time_results
        get :download_ucp_sql
        get :download_payment_details

        # OLD routes
        get :download_data
        get :download_configuration
        post :upload
        get :download_events
      end
    end

    resources :standard_skill_entries, :only => [:index] do
      collection do
        get :upload_file
        post :upload
      end
    end
    resources :standard_skill_routines, :only => [] do
      collection do
        get :download_file
      end
    end

    #### For Registration creation purposes
    ###

    resources :expense_groups

    resources :expense_items, :except => [:new, :show] do
      member do
        get :details
      end
    end

    resources :refunds, :only => [:show]

    resources :payments, :except => [:index] do
      collection do
        get :summary
        post :notification
        get :success
      end

      member do
        post :fake_complete
      end
    end

    resources :registration_periods

    resources :combined_competitions do
      resources :combined_competition_entries, except: [:show]
    end

    resources :event_choices, :except => [:index, :create, :new]

    resources :events, :except => [:index, :new, :create] do
      resources :event_choices, :only => [:index, :create]
      resources :event_categories, :only => [:index, :create]
      collection do
        get 'judging'

        get 'summary'
      end
      member do
        post :create_chief
        delete :destroy_chief
      end
      resources :competitions, :only => [:index, :new, :create]
    end
    resources :event_categories, :except => [:index, :create, :new] do
      member do
        get :sign_ups
      end
    end

    resources :categories, :except => [:new, :show] do
      resources :events, :only => [:index, :create]
    end

    # backwards-compatible URL
    get '/registrants/:id/items', to: redirect('/registrants/%{id}/registrant_expense_items')

    resources :registrants do
      #admin
      collection do
        get :bag_labels
        get :show_all
        get :email
        post :send_email
      end
      member do
        post :undelete
        get :reg_fee
        put :update_reg_fee
      end

      #normal user
      collection do
        get :all
        get :empty_waiver
      end
      member do
        get :waiver
      end
      resources :registrant_expenses, :only => [:new, :destroy]
      resources :registrant_expense_items, :only => [:index, :create, :destroy]
      resources :standard_skill_routines, :only => [:index, :create]
      resources :payments, :only => [:index]
      resources :songs, :only => [:index, :create]
    end

    resources :songs, :only => [:edit, :update, :destroy] do
      member do
        get :add_file
        get :file_complete
      end
    end

    resources :standard_skill_routines, :only => [:show, :index] do
      resources :standard_skill_routine_entries, :only => [:destroy, :create]
    end
    resources :standard_skill_entries, :only => [:index]

    # for AJAX use:
    resources :registrant_expenses, :only => [] do
      collection do
        post 'single'
      end
    end

    resources :event_configurations, :except => [:show] do
      collection do
        post 'admin'
        post 'super_admin'
        post 'normal'
      end
      member do
        get 'logo'
      end
    end

    get "welcome/help"
    post "welcome/feedback"
    get "welcome/confirm"

    devise_for :users, :controllers => { :registrations => "registrations" }

    resources :users, :only => [] do
      resources :registrants, :only => [:index]
      resources :payments, :only => [:index]
      resources :additional_registrant_accesses, :only => [:index, :new, :create] do
        collection do
          get :invitations
        end
      end
      resources :competition, :only => [] do
        resources :import_results, :only => [:index, :create] do
          collection do
            post :import_csv
            post :import_lif
            post :publish_to_competition
            delete :destroy_all
          end
        end
      end
      resources :award_labels, :shallow => true, :except => [:new, :show] do
        collection do
          post :create_labels
          get :expert_labels
          get :normal_labels
          delete :destroy_all
        end
      end
    end
    resources :additional_registrant_accesses, :only => [] do
      member do
        put :accept_readonly
        delete :decline
      end
    end
    resources :import_results, :only => [:edit, :update, :destroy]

    ###############################################
    ### For event-data-gathering/reporting purposes
    ###############################################

    resources :competitors, :only => [:edit, :update, :destroy] do
      resources :members, :shallow => true, :only => [:create, :destroy]
    end

    resources :competitions, :except => [:index, :create, :new] do
      member do
        post :set_places
        get :export_scores
        # view scores
        get :scores

        post :lock
        delete :lock
        delete :destroy_results
      end
      resources :competitors, :only => [:index, :new, :create] do
        collection do
          post :add
          post :add_all
          delete :destroy_all
        end
      end

      resources :judges,      :only => [:index, :new, :create, :destroy] do
        collection do
          post :create_normal
          post :create_race_official
          post :copy_judges
        end
      end
      resources :time_results, :only => [:index, :create] do
        collection do
          get :final_candidates
        end
      end
      resources :lane_assignments, :only => [:index, :create]
      resources :external_results, :shallow => true, :except => [:new, :show]
    end
    resources :lane_assignments, :except => [:new, :index, :create, :show]

    resources :time_results, :except => [:index, :new, :show, :create]

    resources :judges, :only => [:update] do
      collection do
        get :chiefs
      end
      resources :competitors, :only => [] do
        resources :scores, :only => [:new, :edit, :create, :update]

        # display chosen competitors current scores, and update them
        resources :standard_scores, :only => [:new, :create]
        resources :distance_attempts, :only => [:new, :create]
        resources :boundary_scores
      end

      #choose the desired competitor to add scores to
      resources :scores, :only => [:index]
      resources :standard_scores, :only => [:index]
      resources :distance_attempts, :only => [:index] do
        collection do
          get :list
        end
      end
      resources :street_scores, :only => [:index, :create, :destroy]
    end
    resources :distance_attempts, :only => [:update, :destroy]

  end


  mount RailsAdmin::Engine => '/rails_admin', :as => 'rails_admin'

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
  get '/:locale' => 'welcome#index' # to match /en  to send to /en/welcome
  root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
