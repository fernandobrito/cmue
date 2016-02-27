Cmue::App.controllers :evaluations do
  get :new do
    begin
      next_pair = Experiment::select_next_pair(session)

      if (next_pair)
        session[:current_pair] = next_pair
        @progress = Experiment::get_progress(session) * 100

        render 'evaluations/new'
      else
        render 'evaluations/_finished'
      end

    # Invalid state
    rescue Experiment::InvalidState
      redirect url(:sessions, :new)
    end

    # @page1 = Net::HTTP.get(URI('https://github.com/saltlab/Pangor/commit/1452e304de38855f2a88270b3cacc7bbcb685a47#files'))
    # @page2 = Net::HTTP.get(URI('https://github.com/saltlab/Pangor/commit/4a072334f78298812abb7ca1ccdb4285c837f48c#files'))
  end

  post :create do
    pair = session[:current_pair]
    evaluation = params[:evaluation]

    Experiment::save_evaluation(session, pair, evaluation)

    redirect url(:evaluations, :new)
  end

end
