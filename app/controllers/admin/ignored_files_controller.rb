class Admin::IgnoredFilesController < ApplicationController
  include IgnoredFileHelper
  
  before_action :authenticate_user!
  before_action :authenticate_admin!
  before_action :find_ignored_file, except: [:index, :new, :create]

  def index
    @status = params[:ignored] ? params[:ignored] : false
    
    @ignored_files = FileToBeIgnored.where(:ignored => @status, name: /#{params[:query]}/).page(params[:page]) 

    if request.xhr?
      respond_to do|format|
        format.js
      end
    end
  end

  def new
    @ignored_file = FileToBeIgnored.new
  end

  def create
    @ignored_file = FileToBeIgnored.new(files_params)
    if @ignored_file.save
      redirect_to admin_ignored_files_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @ignored_file.update_attributes(files_params)
      redirect_to admin_ignored_files_path
    else
      render :edit
    end
  end

  def search
    if params[:q].blank?
      redirect_to admin_ignored_files_path
      return
    end

    @ignored_files = FileToBeIgnored.where(name: /#{params[:q]}/).order(name: :asc)
    @ignored_files = @ignored_files.page(1)
    render :index
  end

  def destroy
    @ignored_file.destroy
    flash[:success] = "Deleted Successfully"
    redirect_to admin_ignored_files_path
  end

  private

  def files_params
    params.fetch(:file_to_be_ignored).permit(:name, :programming_language, :ignored)
  end

end
