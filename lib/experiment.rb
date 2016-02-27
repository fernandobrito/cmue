# Module to handle the entire experiment flow
# HTTP should be restless, so we keep state in cookies
module Experiment
  class InvalidState < Exception ; end

  # Class methods
  class << self

    # Start the experiment:
    #  * select the random pairs
    #  * store start time
    def start(session)
      # Clear stored session
      session.clear

      # Convert pairs into hash with evaluation result
      pairs = {}
      DatasetManager.generate_pairs.each do |pair|
        pairs.store(pair, nil)
      end

      session[:startedAt] = Time.now.to_s
      session[:pairs] = pairs
    end

    # Return how many percent (0 to 1) of the pairs have been evaluated
    def get_progress(session)
      raise InvalidState, 'Experiment not started' if session[:pairs].nil?

      total = session[:pairs].size
      done = session[:pairs].select{ |key, value| value != nil }.size

      done / total.to_f
    end

    # Select the next pair that has not been evaluated yet
    def select_next_pair(session)
      raise InvalidState, 'Experiment not started' if session[:pairs].nil?

      not_evaluated = session[:pairs].select{ |key, value| value.nil? }

      if not_evaluated.size > 0
        not_evaluated.first.first
      else
        nil
      end
    end

    # Save the result of an evaluation
    def save_evaluation(session, pair, evaluation)
      session[:pairs].store(pair, evaluation)
    end

    # Finish the experiment:
    #  * store ending time
    #  * clear cookies
    def finish(session)
      endedAt = Time.now.to_s
      puts session[:startedAt]

      session.clear
    end
  end
end