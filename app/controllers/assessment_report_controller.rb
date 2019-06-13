class AssessmentReportController < ApplicationController

  include PrawnCharting

  before_action :signed_in_user
  before_action :check_xhr, except: :index

  ##
  # Responds to GET /institutions/:id/assessment-report
  # Add a .pdf extension to get a PDF. Optionally, pass one of the following
  # ?section= parameters to get just that section: preservation, storage,
  # resources, collections
  #
  def index
    compile_preservation_data

    respond_to do |format|
      format.html
      format.pdf do
        case params[:section]
        when 'preservation'
          compile_preservation_data
          pdf = pdf_preservation_assessment_report(
              nil, @institution, current_user)
        when 'storage'
          compile_storage_data
          pdf = pdf_storage_assessment_report(
              nil, @institution, current_user, @location_assessment_sections)
        when 'resources'
          compile_resources_data
          pdf = pdf_resources_assessment_report(
              nil, @institution, current_user, @institution_formats,
              @resource_chart_data)
        when 'collections'
          compile_collections_data
          pdf = pdf_collections_assessment_report(
              nil, @institution, current_user, @collections,
              @collection_chart_datas)
        else
          compile_preservation_data
          compile_resources_data
          compile_storage_data
          compile_collections_data
          pdf = pdf_assessment_report(@institution,
                                      current_user,
                                      @resource_chart_data,
                                      @collection_chart_datas,
                                      @location_assessment_sections,
                                      @institution_formats,
                                      @collections)
        end
        send_data pdf.render, filename: 'assessment_report.pdf',
                  type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  ##
  # Responds to GET /assessment-report/preservation
  #
  def preservation_section
    compile_preservation_data
    render partial: 'assessment_report/preservation_section'
  end

  ##
  # Responds to GET /assessment-report/storage
  #
  def storage_section
    compile_storage_data
    render partial: 'assessment_report/storage_section'
  end

  ##
  # Responds to GET /assessment-report/resources
  #
  def resources_section
    compile_resources_data
    render partial: 'assessment_report/resources_section'
  end

  ##
  # Responds to GET /assessment-report/collections
  #
  def collections_section
    compile_collections_data
    render partial: 'assessment_report/collections_section'
  end

  private

  def check_xhr
    render plain: 'Not Acceptable', status: :not_acceptable unless request.xhr?
  end

  def compile_collections_data
    @institution = current_user.institution
    # Compile a map with the following structure:
    # {
    #     (collection ID): [
    #         # of resources scored 0-10
    #         # of resources scored 10-20
    #         # of resources scored 20-30
    #         ...
    #         # of resources scored 90-100
    #     ]
    # }
    @collections = @institution.resources.
        where(resource_type: Resource::Type::COLLECTION)
    @collection_chart_datas = {}
    @collections.each do |collection|
      sub_collections = collection.all_children.select{ |r|
        r.resource_type == Resource::Type::COLLECTION }
      sub_collections << collection
      parent_ids = sub_collections.pluck(:id).join(', ')
      data = []
      10.times do |i|
        sql = "SELECT COUNT(resources.id) AS count "\
          "FROM resources "\
          "WHERE resources.parent_id IN (#{parent_ids}) "\
          "AND resources.assessment_score >= #{i * 0.1} "\
          "AND resources.assessment_score < #{(i + 1) * 0.1} "\
          "AND resources.assessment_score > 0.00001 " # virtually all of the 0s will be non-assessed
        data << ActiveRecord::Base.connection.execute(sql).
            map{ |r| r['count'].to_i }.first
      end
      @collection_chart_datas[collection.id] = data
    end
  end

  def compile_preservation_data
    @institution = current_user.institution
  end

  def compile_resources_data
    @institution = current_user.institution
    format_ids = @institution.resources
                     .pluck(:format_id)
                     .select(&:present?)
    @institution_formats = Format.where('id IN (?)', format_ids)
    @resource_chart_data = []
    10.times do |i|
      sql = "SELECT COUNT(resources.id) AS count "\
            "FROM resources "\
            "LEFT JOIN locations ON locations.id = resources.location_id "\
            "LEFT JOIN repositories ON repositories.id = locations.repository_id "\
            "WHERE repositories.institution_id = #{@institution.id} "\
            "AND resources.assessment_score >= #{i * 0.1} "\
            "AND resources.assessment_score < #{(i + 1) * 0.1} "\
            "AND resources.assessment_score > 0.00001 " # virtually all of the 0s will be non-assessed
      @resource_chart_data << ActiveRecord::Base.connection.execute(sql).
          map{ |r| r['count'].to_i }.first
    end
    @stats = @institution.assessed_item_statistics
  end

  def compile_storage_data
    @institution = current_user.institution
    @location_assessment_sections = Assessment.find_by_key('location').
        assessment_sections.order(:index)
  end

end
