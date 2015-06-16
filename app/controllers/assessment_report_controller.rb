class AssessmentReportController < ApplicationController

  include PrawnCharting

  before_action :signed_in_user

  ##
  # Responds to GET /institutions/:id/assessment-report
  # Add a .pdf extension to get a PDF. Optionally, pass one of the following
  # ?section= parameters to get just that section: preservation, storage,
  # resources, collections
  #
  def index
    @institution = current_user.institution

    if [nil, 'storage'].include?(params[:section])
      @location_assessment_sections = Assessment.find_by_key('location').
          assessment_sections.order(:index)
    end
    if [nil, 'collections'].include?(params[:section])
      @collections = @institution.resources.
          where(resource_type: Resource::Type::COLLECTION)
      @collection_chart_datas = {}
      @collections.each do |collection|
        sub_collections = collection.all_children.select{ |r|
          r.resource_type == Resource::Type::COLLECTION }
        sub_collections << collection
        parent_ids = sub_collections.map{ |r| r.id }.join(', ')
        data = []
        (0..9).each do |i|
          sql = "SELECT COUNT(resources.id) AS count "\
          "FROM resources "\
          "WHERE resources.parent_id IN (#{parent_ids}) "\
          "AND resources.assessment_score >= #{i * 0.1} "\
          "AND resources.assessment_score < #{(i + 1) * 0.1} "\
          "AND resources.assessment_score > 0.00001 " # virtually all of these will be non-assessed
          data << ActiveRecord::Base.connection.execute(sql).
              map{ |r| r['count'].to_i }.first
        end
        @collection_chart_datas[collection.id] = data
      end
    end
    if [nil, 'resources'].include?(params[:section])
      @institution_formats = @institution.resources.collect{ |r| r.format }.
          select{ |f| f }.uniq{ |f| f.id }
      @resource_chart_data = []
      (0..9).each do |i|
        sql = "SELECT COUNT(resources.id) AS count "\
            "FROM resources "\
            "LEFT JOIN locations ON locations.id = resources.location_id "\
            "LEFT JOIN repositories ON repositories.id = locations.repository_id "\
            "WHERE repositories.institution_id = #{@institution.id} "\
            "AND resources.assessment_score >= #{i * 0.1} "\
            "AND resources.assessment_score < #{(i + 1) * 0.1} "\
            "AND resources.assessment_score > 0.00001 " # virtually all of these will be non-assessed
        @resource_chart_data << ActiveRecord::Base.connection.execute(sql).
            map{ |r| r['count'].to_i }.first
      end
    end

    respond_to do |format|
      format.html { @stats = @institution.assessed_item_statistics }
      format.pdf do
        case params[:section]
          when 'preservation'
            pdf = pdf_preservation_assessment_report(
                nil, @institution, current_user)
          when 'storage'
            pdf = pdf_storage_assessment_report(
                nil, @institution, current_user, @location_assessment_sections)
          when 'resources'
            pdf = pdf_resources_assessment_report(
                nil, @institution, current_user, @institution_formats,
                @resource_chart_data)
          when 'collections'
            pdf = pdf_collections_assessment_report(
                nil, @institution, current_user, @collections,
                @collection_chart_datas)
          else
            pdf = pdf_assessment_report(@institution, current_user,
                                        @resource_chart_data,
                                        @collection_chart_datas,
                                        @location_assessment_sections,
                                        @institution_formats, @collections)
        end
        send_data pdf.render, filename: 'assessment_report.pdf',
                  type: 'application/pdf', disposition: 'inline'
      end
    end
  end

end
