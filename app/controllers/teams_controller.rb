class TeamsController < ApplicationController

  def index
    @teams = Team.all.asc(:name)
    @devs  = GITHUB.orgs.teams.all_members(ORG_TEAM_ID).map(&:login)
  end

  def create
    @team = Team.create_with_members(params[:team])
  end

  def destroy
    @team = Team.find(params[:id])
    @team.destroy
  end
end
