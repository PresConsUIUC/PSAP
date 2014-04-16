class FormatsController < ApplicationController

  before_action :signed_in_user, :admin_user

  helper_method :sort_column, :sort_direction

  def create
    command = CreateFormatCommand.new(format_params, current_user,
                                      request.remote_ip)
    @format = command.object
    begin
      command.execute
      flash[:success] = "Format \"#{@format.name}\" created."
      redirect_to formats_url
    rescue
      render 'new'
    end
  end

  def destroy
    @format = Format.find(params[:id])
    command = DeleteFormatCommand.new(@format, current_user, request.remote_ip)
    begin
      command.execute
      flash[:success] = "Format \"#{@format.name}\" deleted."
    rescue => e
      flash[:error] = "#{e}"
    ensure
      redirect_to formats_path
    end
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
    command = UpdateFormatCommand.new(@format, format_params, current_user,
                                      request.remote_ip)
    begin
      command.execute
      flash[:success] = "Format \"#{@format.name}\" updated."
      redirect_to @format
    rescue
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
