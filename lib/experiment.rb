# Module to handle the entire experiment flow
# HTTP should be restless, so we keep state in cookies
module Experiment
  class InvalidState < Exception ; end

  # Start the experiment:
  #  * select the random pairs
  #  * store start time
  def self.start(session)
    session.clear

    session[:startedAt] = Time.now.to_s
    session[:pairs] = { ['1', '2'] => nil, ['3', '4'] => nil }
  end

  # Return how many percent (0 to 1) of the pairs have been evaluated
  def self.get_progress(session)
    raise InvalidState, 'Experiment not started' if session[:pairs].nil?

    total = session[:pairs].size
    done = session[:pairs].select{ |key, value| value != nil }.size

    done / total.to_f
  end

  # Select the next pair that has not been evaluated yet
  def self.select_next_pair(session)
    raise InvalidState, 'Experiment not started' if session[:pairs].nil?

    not_evaluated = session[:pairs].select{ |key, value| value.nil? }

    if not_evaluated.size > 0
      not_evaluated.first.first
    else
      nil
    end
  end

  # Save the result of an evaluation
  def self.save_evaluation(session, pair, evaluation)
    session[:pairs].store(pair, evaluation)
  end

  # Finish the experiment:
  #  * store ending time
  #  * clear cookies
  def self.finish(session)
    endedAt = Time.now.to_s
    puts session[:startedAt]

    session.clear
  end
end