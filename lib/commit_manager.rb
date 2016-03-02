module CommitManager
  HTML_FOLDER = File.join(File.dirname(__FILE__), '..', 'public', 'commits')

  # Class methods
  class << self

    def get(project, commit_id, cluster)
      path = generate_file_path(project, commit_id)

      # If file does not exist, retrieve and store it
      if ! File.exists?(path)
        # Download it
        page = download(project, commit_id)

        # Create folder
        dirname = File.dirname(path)
        unless File.directory?(dirname)
          FileUtils.mkdir_p(dirname)
        end

        # Save file
        File.open(path, 'w') do |file|
          file.write(remove_js(page).force_encoding("UTF-8"))
        end
      end

      return generate_public_path(project, commit_id)
    end

  protected
    def download(project, commit_id)
      Net::HTTP.get(URI(generate_url(project, commit_id)))
    end

    def generate_url(project, commit_id)
      "https://github.com/#{project}/commit/#{commit_id}#files"
    end

    def generate_file_path(project, commit_id)
      File.join(HTML_FOLDER, project, commit_id + '.html')
    end

    # Public, relative path, to be used in iframe
    def generate_public_path(project, commit_id)
      File.join('/', 'commits', project, commit_id + '.html')
    end

    # Remove imported JavaScript files from the HTML to remove
    #  the iframe verification
    def remove_js(string)
      string.gsub(/(https:.*js)/, '')
    end
  end
end