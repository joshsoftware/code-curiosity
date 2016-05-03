class OrganizationsController < ApplicationController
  include OrganizationHelper

  before_action :authenticate_user!
  before_action :find_org, except: [:index]

  def index
    @orgs = current_user.organizations
    redirect_to :back
  end

  def show
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

  private

  def org_params
    params.fetch(:organization).permit(:name, :github_handle, :website, :contact, :description)
  end

end
