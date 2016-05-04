class OrganizationsController < ApplicationController
  include OrganizationHelper

  before_action :authenticate_user!, except: [:show]
  before_action :find_org, except: [:index, :show]

  def index
    @orgs = current_user.organizations
    redirect_back
  end

  def edit
  end

  def update
    if @org.update_attributes(org_params)
      redirect_to organization_path(@org)
    else
      render :edit
    end
  end

  def show
    @org = Organization.find(params[:id])

    if @org
      render :show , layout: current_user ? 'application' : 'public'
    else
      redirect_back
    end
  end

  def commits
    @commits = @org.commits
                   .where(round: current_round)
                   .order(commit_date: :desc )
                   .page(params[:page])
                   .per(20)
  end

  def activities
    @activities = @org.activities
                      .where(round: current_round)
                      .order(commented_on: :desc )
                      .page(params[:page])
                      .per(20)
  end

  private

  def org_params
    params.fetch(:organization).permit(:name, :website, :email, :company, :description)
  end

end
