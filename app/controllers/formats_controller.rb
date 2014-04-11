class FormatsController < ApplicationController

  before_action :signed_in_user, :admin_user

  helper_method :sort_column, :sort_direction

  def create
    @format = Format.new(format_params)

    if @format.save
      flash[:success] = "The format \"#{@format.name}\" has been created."
      redirect_to formats_url
    else
      render 'new'
    end
  end

  def destroy
    format = Format.find(params[:id])
    name = format.name
    format.destroy
    flash[:success] = "Format \"#{name}\" deleted."
    redirect_to formats_path
  end

  def edit
    @format = Format.find(params[:id])
  end

  def index
    @formats = Format.where('name LIKE ?', "%#{params[:q]}%").
        order("#{sort_column} #{sort_direction}")
  end

  def new
    @format = Format.new
  end

  def show
    @format = Format.find(params[:id])
  end

  def update
    @format = Format.find(params[:id])
    if @format.update_attributes(format_params)
      flash[:success] = "Format \"#{@format.name}\" updated."
      redirect_to @format
    else
      render 'edit'
    end
  end

  private

  def format_params
    params.require(:format).permit(:name, :score, :obsolete)
  end

  def sort_column
    Format.column_names.include?(params[:sort]) ? params[:sort] : 'name'
  end

end
