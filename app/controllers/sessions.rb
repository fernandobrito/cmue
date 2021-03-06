require 'json'

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
    render 'sessions/new'
  end

  post :create do
    Experiment.start(session)
    session[:name] = params[:name]

    redirect url(:evaluations, :new, intro: 1)
  end

  delete :destroy do
    results = Experiment.finish(session)

    Mailer::send_results(results[:name], results.to_json)

    # render :html, results.to_json
    redirect url(:sessions, :new)
  end

end
