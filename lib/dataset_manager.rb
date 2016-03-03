require 'csv'

module DatasetManager
  INPUT_FOLDER = File.join(File.dirname(__FILE__), '..', 'input')

  CONTROL_SEED = 1

  NUMBER_OF_COMMITS_CONTROL = 10
  NUMBER_OF_COMMITS_RANDOM = 20
  RATIO_INTRA = 0.5

  # Class methods
  class << self

    # Generate pairs of random commits
    # @return [Array] array of arrays. [[[project, commit], [project, commitB]], ...]
    def generate_pairs
      # Read rows
      rows = read_rows

      # Create empty pairs array
      pairs = []

      # CONTROL GROUP:
      # Random for control group
      random = Random.new(CONTROL_SEED)

      # Generate intra pairs
      number_of_intra_cluster = NUMBER_OF_COMMITS_CONTROL * RATIO_INTRA
      pairs = pairs | generate_intra_cluster_pairs(rows, number_of_intra_cluster, random)

      # Generate inter pairs
      number_of_inter_cluster = NUMBER_OF_COMMITS_CONTROL - number_of_intra_cluster
      pairs = pairs | generate_inter_cluster_pairs(rows, number_of_inter_cluster, random)


      # RANDOM GROUP:
      # Generate intra pairs
      number_of_intra_cluster = NUMBER_OF_COMMITS_RANDOM * RATIO_INTRA
      pairs = pairs | generate_intra_cluster_pairs(rows, number_of_intra_cluster, Random.new())

      # Generate inter pairs
      number_of_inter_cluster = NUMBER_OF_COMMITS_RANDOM - number_of_intra_cluster
      pairs = pairs | generate_inter_cluster_pairs(rows, number_of_inter_cluster, Random.new())

      # Return the array
      pairs.shuffle
      # pairs
    end

    protected

    # Read input file
    # @return [Array] [[project_name, commit_id, cluster], ... ]
    def read_rows
      rows = []  # start with an empty array

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
    def generate_intra_cluster_pairs(rows, amount, random)
      # Same cluster
      generate_generic_pairs(rows, amount, random) { |c1, c2| c1[2] == c2[2] }
    end

    # Generate inter cluster pairs
    def generate_inter_cluster_pairs(rows, amount, random)
      # Different cluster
      generate_generic_pairs(rows, amount, random) { |c1, c2| c1[2] != c2[2] }
    end

    # Generate pairs according to criteria passed on block
    def generate_generic_pairs(rows, amount, random,  &block)
      # Output array
      pairs = []

      # While we are not there
      while (pairs.size < amount)
        # Initialize variable
        found = false

        # Shuffle array
        rows.shuffle!(random: random)

        # Get the first commit
        commitA = rows.first

        # Look for another commit matching condition
        rows[1..-1].each do |commitB|
            if block.call(commitA, commitB)

              # To make sure [A, B] and [B, A] are added, we sort
              pairs << [commitA, commitB].sort
              pairs.uniq!

              found = true
              break
            end
        end

        # Stop infinite loops
        break unless found
      end

      pairs
    end
  end
end