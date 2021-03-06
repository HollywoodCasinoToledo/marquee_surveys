Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
   root 'patrons#home'

   get 'questions/:id'													=> 'questions#show'

   get 'confirm'																=> 'surveys#confirm'

   post 'responses'															=> 'responses#create'
   post 'comments'															=> 'comments#create'

   get 'admin'																	=> 'admin#access'
   post 'admin'																	=> 'admin#authenticate'
   get 'admin/control_panel'										=> 'admin#control_panel'
   get 'admin/survey'														=> 'admin#edit_survey'
   get 'admin/archive'													=> 'admin#archive'

   get 'admin/category/new'											=> 'categories#new'
   post 'admin/category/new'										=> 'categories#create'

   get 'admin/question/new'											=> 'questions#new'
   post 'admin/question/new'										=> 'questions#create'
   get 'admin/question/:id/edit'								=> 'questions#edit'
   patch 'admin/question/:id/edit'							=> 'questions#update'
   get 'admin/question/:id/move'								=> 'questions#move'
   get 'admin/question/:id/parent'							=> 'questions#parent'

   get 'admin/answer/new'												=> 'answers#new'
   post 'admin/answer/new'											=> 'answers#create'
   get 'admin/answer/:id/edit'									=> 'answers#edit'
   patch 'admin/answer/:id/edit'								=> 'answers#update'

   get 'admin/results/:id'											=> 'admin#results'

  # Example of regular route:
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
