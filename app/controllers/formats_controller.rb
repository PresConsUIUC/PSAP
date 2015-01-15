class FormatsController < ApplicationController

  before_action :signed_in_user
  before_action :admin_user, only: :show

  def index
    respond_to do |format|
      format.json do # dependent select menus in assessment form
        render json: Format.where(format_class: params[:format_class_id]).
            where(parent_id: params[:parent_id]).
            order(:name)
      end
      format.html do # /formats
        @format_count = Format.all.length
        @formats = Format.where('parent_id IS NULL').order(:name)
      end
    end
  end

  def show
    @format = Format.find(params[:id])
    @humidity_ranges = @format.humidity_ranges.order('min_rh NULLS FIRST')
    @temperature_ranges = @format.temperature_ranges.
        order('min_temp_f NULLS FIRST')

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
