class DashboardController < ApplicationController

  def repositories
    @repos = GITHUB.orgs.teams.list_repos(ORG_TEAM_ID).as_json(only: [:name, :description, :watchers])
  end
end
