class DashboardController < ApplicationController

  def repositories
    @repos = Repository.fetch_remote_repos.as_json(only: [:name, :description, :watchers])
  end
end
