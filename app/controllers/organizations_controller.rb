class OrganizationsController < ApplicationController
  include OrganizationHelper
  include JudgesActions

  before_action :authenticate_user!, except: [:show]
  before_action :authenticate_org!, except: [:index, :show]
  before_action :find_resource, only: [:rate, :comment, :comments]

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

    respond_to do |format|
      format.html { render 'judging/commits' }
      format.js { render 'judging/commits' }
    end
  end

  def activities
    @activities = @org.activities
                      .where(round: current_round)
                      .order(commented_on: :desc )
                      .page(params[:page])
                      .per(20)

    respond_to do |format|
      format.html { render 'judging/activities' }
      format.js { render 'judging/activities' }
    end
  end

  private

  def org_params
    params.fetch(:organization).permit(:name, :website, :email, :company, :description)
  end

  def find_resource
    @resource = if params[:type] == 'commits'
                 @org.commits.where(id: params[:resource_id]).first
               else
                 @org.activities.where(id: params[:resource_id]).first
               end

    unless @resource
      render nothing: true, status: 404
    end

    if params[:rating].to_i > @resource.max_rating
      render nothing: true, status: 401
    end
  end

end
