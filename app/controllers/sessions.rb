Cmue::App.controllers :sessions do
  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get '/example' do
  #   'Hello world!'
  # end
  
  get :new do
    Experiment.start(session)
    render 'sessions/new'
  end

  post :create do
    redirect url(:evaluations, :new)
  end

  delete :destroy do
    render :html, "Session: #{session.inspect}"
  end

end
