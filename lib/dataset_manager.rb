module DatasetManager
  INPUT_FOLDER = File.join(File.dirname(__FILE__), '..', 'input')

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

      # While we still have at least 2 rows
      while (rows.size >= 2)
        # Get the rows
        row1 = rows.pop.strip
        row2 = rows.pop.strip

        # Get the project and the commit IDs
        project1 = row1.split(',')[0]
        commit1 = row1.split(',')[1]

        project2 = row2.split(',')[0]
        commit2 = row2.split(',')[1]

        # Populate the pairs array
        pairs << [[project1, commit1], [project2, commit2]]
      end

      # Return the array
      pairs
    end

    protected

    # Read input file and return array with rows
    def read_rows
      rows = []  # start with an empty array

      File.open(File.join(INPUT_FOLDER, 'dataset.csv')).each_line do |line|
        rows.push line
      end

      rows
    end
  end
end