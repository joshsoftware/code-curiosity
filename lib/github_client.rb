class GithubClient
  class << self

    attr_accessor :client

    def init(options = {})
      self.client = Github.new(options)
    end

    def repo(owner, repo_name)
      @client.repos.get(owner, repo_name)
    rescue
      nil
    end
  end
end
