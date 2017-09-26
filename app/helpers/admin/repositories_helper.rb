module Admin::RepositoriesHelper

  def check_boolean(str)
    str == "true"
  end

  def child_count(id)
    repos = @forks_repos_count.to_a.select{ |r| r['_id'] == id}
    repos[0]['count'] unless repos.empty?
  end
end

