class FormatsController < ApplicationController

  before_action :signed_in_user
  before_action :admin_user, only: :show

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

  def show
    @format = Format.find(params[:id])
    @events = @format.events.order(created_at: :desc)
  end

end
