Cmue::App.controllers :evaluations do
  before do
    @name = session[:name]
  end

  get :new do
    begin
      next_pair = Experiment::select_next_pair(session)

      if (next_pair)
        session[:current_pair] = next_pair
        @progress = Experiment::get_progress(session) * 100

        # Splat operator. Pass project and commit id as separate arguments
        @commit1 = CommitManager::get(*next_pair[0])
        @commit2 = CommitManager::get(*next_pair[1])

        @session = session

        render 'evaluations/new'
      else
        render 'evaluations/_finished'
      end

    # Invalid state
    rescue Experiment::InvalidState
      redirect url(:sessions, :new)
    end
  end

  post :create do
    pair = session[:current_pair]
    evaluation = [params['bug-similarity'], params['repair-similarity']]

    Experiment::save_evaluation(session, pair, evaluation)

    redirect url(:evaluations, :new)
  end

end
