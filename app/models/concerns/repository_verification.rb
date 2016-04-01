module RepositoryVerification
  extend ActiveSupport::Concern

  class_methods do

    def github_url(source_uri)
      uri = source_uri.to_s.sub(/\.git$/, '')
      "#{GithubClient::URL}/#{uri}"
    end

    def build_from_github(url)
      owner, name = url.to_s.sub(/\.git$/, '').split('/')[-2..-1]
      return nil if owner.blank? or name.blank?

      info = GithubClient.repo(owner, name)
      return nil if info.blank?

      repo = Repository.new({
        name: info.name,
        owner: info.owner.login,
        source_url: info.html_url,
        description: info.description,
        watchers: info.watchers,
        forks: info.forks,
        languages: [info.language],
        gh_id: info.id,
        ssh_url: info.ssh_url
      })
    end

    def verify_repo()
    end

  end
end
