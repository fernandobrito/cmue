require 'csv'

module DatasetManager
  INPUT_FOLDER = File.join(File.dirname(__FILE__), '..', 'input')

  NUMBER_OF_COMMITS = 10
  RATIO_INTRA = 0.67

  # Class methods
  class << self

    # Generate pairs of random commits
    # @return [Array] array of arrays. [[[project, commit], [project, commitB]], ...]
    def generate_pairs
      # Read rows
      rows = read_rows

      # Shuffle them
      rows.shuffle!

      # Create empty pairs array
      pairs = []

      # Generate intra pairs
      number_of_intra_cluster = NUMBER_OF_COMMITS * RATIO_INTRA
      pairs = pairs | generate_intra_cluster_pairs(rows, number_of_intra_cluster)

      # Generate inter pairs
      number_of_inter_cluster = NUMBER_OF_COMMITS - number_of_intra_cluster
      pairs = pairs | generate_inter_cluster_pairs(rows, number_of_inter_cluster)

      # Return the array
      pairs[0..10].shuffle
    end

    protected

    # Read input file
    # @return [Array] [[project_name, commit_id, cluster], ... ]
    def read_rows
      rows = []  # start with an empty array

      # File.open(File.join(INPUT_FOLDER, 'real_dataset.csv')).each_line do |line|
      #   rows.push line
      # end

      CSV.foreach(File.join(INPUT_FOLDER, 'real_dataset.csv'), headers: true) do |row|
        # Regex to extract project name (account/project) and commit ID
        project_name, commit_id = row['CommitURL'].match(/github\.com\/(.*\/.*)\/.*\/(.*)/).captures

        # Cluster
        cluster = row['Cluster'].sub('cluster', '')

        rows << [project_name, commit_id, cluster]
      end

      rows
    end

    # Generate intra cluster pairs
    def generate_intra_cluster_pairs(rows, amount)
      # Same cluster
      generate_generic_pairs(rows, amount) { |c1, c2| c1[2] == c2[2] }
    end

    # Generate inter cluster pairs
    def generate_inter_cluster_pairs(rows, amount)
      # Different cluster
      generate_generic_pairs(rows, amount) { |c1, c2| c1[2] != c2[2] }
    end

    # Generate pairs according to criteria passed on block
    def generate_generic_pairs(rows, amount, &block)
      # Output array
      pairs = []

      # While we are not there
      while (pairs.size < amount)
        # Get the first commit
        commit = rows.pop

        # Look for another commit with same cluster number
        same_cluster_commits = rows.select{ |c| block.call(c, commit) }

        # If there are candidates, pick the first one
        if (same_cluster_commits.size > 0)
          other_commit = same_cluster_commits.first
          rows.delete(other_commit)

          pairs << [commit, other_commit]

          # Otherwise, ignore this commit and try again
        else
          next
        end
      end

      pairs
    end
  end
end