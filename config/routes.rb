MOCK::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "users/registrations", :sessions => "users/sessions" }

  # You can have the root of your site routed with "root"
  root 'pages#home'

  get  'datasets/new' => 'datasets#new',    :as => :new_dataset
  get  'datasets' => 'datasets#index',  :as => :datasets
  get  'datasets/:id' => 'datasets#show',   :as => :dataset
  post 'datasets/create' => 'datasets#create', :as => :create_dataset
  delete 'datasets/:id/destroy' => 'datasets#destroy', :as => :destroy_dataset


  get  'runs/new' => 'runs#new', :as => :new_run
  get  'runs' => 'runs#index', :as => :runs
  get  'runs/complete' => 'runs#complete'
  get  'runs/:id' => 'runs#show', :as => :run
  post 'runs/create' => 'runs#create', :as => :create_run
  delete 'runs/:id/destroy' => 'runs#destroy', :as => :destroy_run

  get 'runs/:id/controls' => 'control_solutions#index', :as => :control_solutions
  get 'runs/:id/solutions' => 'solutions#index', :as => :solutions

  get 'solutions/:id' => 'solutions#show', :as => :solution

  get 'clusters/:id' => 'clusters#show', :as => :cluster

  get 'evidence_accumulation_solution/:id' => 'evidence_accumulation_solutions#show', :as => :evidence_accumulation_solution

  get 'mds_solutions/:id' => 'mds_solutions#show', :as => :mds_solution
  get 'mds_datasets/:id' => 'mds_datasets#show', :as => :mds_dataset

  resources :clusters

  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

end
