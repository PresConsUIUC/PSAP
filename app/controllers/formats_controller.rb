class FormatsController < ApplicationController

  before_action :signed_in_user
  before_action :admin_user, except: :index

  def create
    command = CreateFormatCommand.new(format_params, current_user,
                                      request.remote_ip)
    @format = command.object
    begin
      command.execute
    rescue ValidationError
      render 'new'
    rescue => e
      flash[:error] = "#{e}"
      render 'new'
    else
      flash[:success] = "Format \"#{@format.name}\" created."
      redirect_to formats_url
    end
  end

  def destroy
    @format = Format.find(params[:id])
    command = DeleteFormatCommand.new(@format, current_user, request.remote_ip)
    begin
      command.execute
    rescue => e
      flash[:error] = "#{e}"
      redirect_to format_path(@format)
    else
      flash[:success] = "Format \"#{@format.name}\" deleted."
      redirect_to formats_path
    end
  end

  def edit
    @format = Format.find(params[:id])
  end

  def index
    respond_to do |format|
      format.js { # ajax search field on /formats
        if params[:q].length > 0
          @format_count = Format.where('name LIKE ?', "%#{params[:q]}%").length
          @formats = Format.where('name LIKE ?', "%#{params[:q]}%").
              order(:name)
        else
          @format_count = Format.all.length
          @formats = Format.where('parent_id IS NULL').order(:name)
        end
      }
      format.json { # dependent select menus in assessment form
        render json: Format.where(format_class: params[:format_class_id]).
            where(parent_id: params[:parent_id]).
            order(:name)
      }
      format.html { # /formats
        @format_count = Format.all.length
        @formats = Format.where('parent_id IS NULL').order(:name)
      }
    end
  end

  def new
    @format = Format.new
    @format.temperature_ranges << TemperatureRange.create(min_temp_f: 0,
                                                          max_temp_f: 100,
                                                          score: 1)
  end

  def show
    @format = Format.find(params[:id])
    @events = @format.events.order(created_at: :desc)
  end

  def update
    @format = Format.find(params[:id])
    command = UpdateFormatCommand.new(@format, format_params, current_user,
                                      request.remote_ip)
    begin
      command.execute
    rescue ValidationError
      render 'edit'
    rescue => e
      flash[:error] = "#{e}"
      render 'edit'
    else
      flash[:success] = "Format \"#{@format.name}\" updated."
      redirect_to @format
    end
  end

  private

  def format_params
    params.require(:format).permit(:format_class, :name, :score, :parent_id,
                                   temperature_ranges_attributes: [:id,
                                                                   :min_temp_f,
                                                                   :max_temp_f,
                                                                   :score])
  end

end
