class FormatsController < ApplicationController

  before_action :signed_in_user
  before_action :admin_user, only: :show

  def index
    respond_to do |format|
      format.js { # ajax search field on /formats
        if params[:q].length > 0
          @format_count = Format.where('LOWER(name) LIKE ?', "%#{params[:q].downcase}%").length
          @formats = Format.where('LOWER(name) LIKE ?', "%#{params[:q].downcase}%").
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

    sql = 'SELECT institutions.id AS inst_id, COUNT(institutions.id) AS count '\
    'FROM institutions '\
    'LEFT JOIN repositories ON repositories.institution_id = institutions.id '\
    'LEFT JOIN locations ON locations.repository_id = repositories.id '\
    'LEFT JOIN resources ON resources.location_id = locations.id '\
    'LEFT JOIN formats ON formats.id = resources.format_id '\
    "WHERE format_id = #{@format.id} "\
    'GROUP BY institutions.id '\
    'ORDER BY count DESC'
    @institution_counts = ActiveRecord::Base.connection.execute(sql).
        map{ |row| { institution: Institution.find(row['inst_id']),
                     count: row['count'] } }
  end

end
