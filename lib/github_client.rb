class GithubClient
  URL = 'https://github.com'

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

    def repos
      @client.repos.get(ownder)
    end

    def user(name)
      @client.users.get(user: name)
    end
  end
end
