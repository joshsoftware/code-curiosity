class Admin::SponsorsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @sponsors = Sponsor.all.page(params[:page])
  end

  def show
    sponsor = Sponsor.find(params[:id])
    @budgets = sponsor.budgets
  end

  def new
    @sponsor = Sponsor.new
    @sponsor.budgets.build
  end

  def create
    @sponsor = Sponsor.new(sponsor_params)
    if @sponsor.save
      flash[:success] = "Sponsor Created Successfully!"
      redirect_to admin_sponsors_path
    else
      flash[:error] = @sponsor.errors.full_messages.join(',')
      render :new
    end
  end

  def edit
    @sponsor = Sponsor.find(params[:id])
  end

  def update
    @sponsor = Sponsor.find(params[:id])
    if @sponsor.update(sponsor_params)
      flash[:success] = "Sponsor Updated Successfully!"
      redirect_to admin_sponsors_path
    else
      flash[:error] = @sponsor.errors.full_messages.join(',')
      render :edit
    end
  end

  def destroy
    Sponsor.find(params[:id]).destroy
    @sponsors = Sponsor.all.page(params[:page])

    flash[:success] = "Sponsor Destroyed Successfully!"
    render :index
  end

  private

  def sponsor_params
    params.require(:sponsor).permit(:name, :is_individual, 
                                    budgets_attributes: 
                                    [:id, :start_date, :end_date, :amount, :is_all_repos, :_destroy, repository_ids: []] )
  end
end
