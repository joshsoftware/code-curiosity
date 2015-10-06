class TeamsController < ApplicationController

  def index
    @teams = Team.all.asc(:name)
    @devs  = GITHUB.orgs.teams.all_members(ORG_TEAM_ID).map(&:login)
    @repos = Repository.fetch_remote_repos.map(&:name)
  end

  def create
    @team = Team.create_with_members(params[:team])
  end

  def update
    team = Team.find(params[:id])
    team.add_repos(params[:repos])
    render nothing: true
  end

  def destroy
    @team = Team.find(params[:id])
    @team.destroy
  end
end
