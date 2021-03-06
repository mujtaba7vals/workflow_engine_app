Rails.application.routes.draw do
  # Routes accessible with subdomain
  constraints(subdomain: /.+/) do
    resources :projects do
      member do
        get 'project_users'
        get 'new_team_for_project'
        patch 'add_team_to_project'
        delete 'remove_team_from_project'
        get 'new_user_for_project'
        patch 'add_user_to_project'
        delete 'remove_user_from_project'
      end
      resources :issues, except: %i[index] do
        member do
          patch :update_status
          delete :delete_document_attachment
          patch :add_document_attachment
        end
      end
    end

    resources :issues, only: [] do
      collection do
        get :filter
      end

      resources :comments, only: %i[create edit update destroy]
      resources :watchers, only: %i[create destroy] do
        collection do
          get :administrate
        end
      end
    end
    get '/issues', to: 'issues#all'

    resources :teams do
      member do
        get 'new_user_for_team'
        patch 'add_user_to_team'
        delete 'remove_user_from_team'
      end
    end
    get '/search', to: 'search#search'

    get '', to: 'companies#index'
    resources :invites
    get 'project/filters', to: 'projects#filters'
  end

  # Routes accessible without subdomain
  constraints(subdomain: '') do
    get '/users/sign_in', to: 'home#sign_in'
    post '/user/companies', to: 'home#user_companies', as: 'user_companies'

    get '/about', to: 'home#about'
    get '/contact_us', to: 'home#contact_us'
    root 'home#index'
  end
  devise_for :users
  constraints(subdomain: /.+/) do
    resources :users, only: %i[index show update edit destroy] do
      collection do
        get 'filters'
        get 'make_owner_page'
        patch 'make_owner'
      end
    end
  end
  get '/invites/confirm_request', to: 'invites#confirm_request', as: 'confirm_request'
  post '/invites/create_staff_user', to: 'invites#create_staff_user', as: 'create_staff_user'
  match '*unmatched', to: 'application#route_not_found', via: :all
end
