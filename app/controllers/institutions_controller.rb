class InstitutionsController < ApplicationController

  before_action :signed_in_user
  before_action :admin_user, only: [:index, :destroy]
  before_action :same_institution_user, only: [:show, :edit, :update]

  ##
  # Responds to GET /institutions/:id/assessment-report
  #
  def assessment_report
    @institution = Institution.find(params[:institution_id])

    @location_assessment_sections = Assessment.find_by_key('location').
        assessment_sections.order(:index)
    @non_assessed_locations = @institution.locations.order(:name).
        select{ |l| l.assessment_question_responses.length < 1 }
    @non_assessed_resources = @institution.resources.order(:name).
        select{ |r| r.assessment_question_responses.length < 1 }
    @stats = @institution.assessed_item_statistics
    @all_assessed_items = @institution.all_assessed_items
    @institution_formats = @institution.resources.collect{ |r| r.format }.
        select{ |f| f }.uniq{ |f| f.id }
    @collections = @institution.resources.
        where(resource_type: ResourceType::COLLECTION)

    @chart_data = []
    (0..9).each do |i|
      sql = "SELECT COUNT(resources.id) AS count "\
          "FROM resources "\
          "LEFT JOIN locations ON locations.id = resources.location_id "\
          "LEFT JOIN repositories ON repositories.id = locations.repository_id "\
          "WHERE repositories.institution_id = #{@institution.id} "\
          "AND resources.assessment_score >= #{i * 0.1} "\
          "AND resources.assessment_score < #{(i + 1) * 0.1} "
      @chart_data << ActiveRecord::Base.connection.execute(sql).
          map{ |r| r['count'].to_i }.first
    end

    respond_to do |format|
      format.html
      format.pdf do
        # http://prawnpdf.org/manual.pdf
        pdf = Prawn::Document.new(
            info: {
                Title: "PSAP Assessment Report: #{@institution.name}",
                Author: current_user.full_name,
                #Subject: "My Subject",
                #Keywords: "test metadata ruby pdf dry",
                Creator: "Preservation Self-Assessment Program (PSAP)",
                Producer: "Prawn",
                CreationDate: Time.now
            })

        font = 'Helvetica'
        h1_size = 18
        h2_size = 16
        pdf.default_leading 2

        # heading
        pdf.font font, style: :bold
        pdf.text 'PSAP Assessment Report', size: h1_size
        pdf.font font, style: :normal
        pdf.text @institution.name
        pdf.text Time.now.strftime('%B %-d, %Y'), size: 10
        pdf.stroke_horizontal_rule
        pdf.move_down 20

        # institution overview
        pdf.font font, style: :bold
        pdf.text 'Institution', size: h2_size
        pdf.font font, style: :normal

        # chart
        prawn_bar_chart(pdf, @chart_data)

        # locations summary
        pdf.start_new_page
        pdf.font font, style: :bold
        pdf.text 'Locations', size: h2_size
        pdf.font font, style: :normal

        # resources overview
        pdf.start_new_page
        pdf.font font, style: :bold
        pdf.text 'Resources', size: h2_size
        pdf.font font, style: :normal

        # collections overview
        pdf.start_new_page
        pdf.font font, style: :bold
        pdf.text 'Collections', size: h2_size
        pdf.font font, style: :normal

        pdf.number_pages '<page>', { start_count_at: 2,
                                     page_filter: lambda{ |pg| pg != 1 },
                                     at: [pdf.bounds.right - 50, 0],
                                     align: :right,
                                     size: 12 }

        send_data pdf.render, filename: 'assessment_report.pdf',
                  type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  def create
    command = CreateAndJoinInstitutionCommand.new(
        institution_params, current_user, request.remote_ip)
    @institution = command.object
    @assessment_sections = Assessment.find_by_key('institution').
        assessment_sections.order(:index)
    begin
      command.execute
    rescue ValidationError
      render 'new'
    rescue => e
      flash[:error] = "#{e}"
      render 'new'
    else
      flash[:success] = "The institution \"#{@institution.name}\" has been "\
        "created. An administrator has been notified and will review your "\
        "request to join it momentarily,"
      redirect_to dashboard_path
    end
  end

  def destroy
    @institution = Institution.find(params[:id])
    command = DeleteInstitutionCommand.new(@institution, current_user,
                                           request.remote_ip)
    begin
      command.execute
    rescue => e
      flash[:error] = "#{e}"
      redirect_to institution_url(@institution)
    else
      flash[:success] = "Institution \"#{@institution.name}\" deleted."
      redirect_to institutions_url
    end
  end

  def edit
    @institution = Institution.find(params[:id])
    @assessment_sections = Assessment.find_by_key('institution').
        assessment_sections.order(:index)
  end

  def events
    @institution = Institution.find(params[:institution_id])
    @events = Event.
        joins('LEFT JOIN events_institutions ON events_institutions.event_id = events.id').
        joins('LEFT JOIN events_repositories ON events_repositories.event_id = events.id').
        joins('LEFT JOIN events_locations ON events_locations.event_id = events.id').
        joins('LEFT JOIN events_resources ON events_resources.event_id = events.id').
        where('events_institutions.institution_id = ? '\
        'OR events_repositories.repository_id IN (?) '\
        'OR events_locations.location_id IN (?)'\
        'OR events_resources.resource_id IN (?)',
              @institution.id,
              @institution.repositories.map { |repo| repo.id },
              @institution.repositories.map { |repo| repo.locations.map { |loc| loc.id } }.flatten.compact,
              @institution.repositories.map { |repo| repo.locations.map {
                  |loc| loc.resources.map { |res| res.id } } }.flatten.compact).
        order(created_at: :desc).
        limit(20)
  end

  def index
    @institutions = Institution.order(:name).paginate(
        page: params[:page],
        per_page: Psap::Application.config.results_per_page)
  end

  def new
    @institution = Institution.new
    @assessment_sections = Assessment.find_by_key('institution').
        assessment_sections.order(:index)
  end

  ##
  # Responds to GET /institutions/:id/repositories
  #
  def repositories
    @institution = Institution.find(params[:institution_id])
    @repositories = @institution.repositories.order(:name).
        paginate(page: params[:page],
                 per_page: Psap::Application.config.results_per_page)
  end

  ##
  # Responds to GET /institutions/:id/resources
  #
  def resources
    @institution = Institution.find(params[:institution_id])
    # show only top-level resources
    @resources = @institution.resources.where(parent_id: nil).order(:name).
        paginate(page: params[:page],
                 per_page: Psap::Application.config.results_per_page)
  end

  def show
    @institution = Institution.find(params[:id])

    respond_to do |format|
      format.csv do
        #response.headers['Content-Disposition'] =
        #    "attachment; filename=\"#{@institution.name.parameterize}\""
        render text: @institution.resources_as_csv
      end
      format.html do
        @assessment_sections = Assessment.find_by_key('institution').
            assessment_sections.order(:index)
        @repositories = @institution.repositories.order(:name).
            paginate(page: params[:page],
                     per_page: Psap::Application.config.results_per_page)
        render 'repositories'
      end
    end
  end

  def update
    @institution = Institution.find(params[:id])
    command = UpdateInstitutionCommand.new(@institution, institution_params,
                                           current_user, request.remote_ip)
    @assessment_sections = Assessment.find_by_key('institution').
        assessment_sections.order(:index)
    begin
      command.execute
    rescue ValidationError
      render 'edit'
    rescue => e
      flash[:error] = "#{e}"
      render 'edit'
    else
      flash[:success] = "Institution \"#{@institution.name}\" updated."
      redirect_to edit_institution_url(@institution)
    end
  end

  def users
    @institution = Institution.find(params[:institution_id])
    @institution_users = @institution.users.where(confirmed: true).order(:last_name)
  end

  private

  ##
  # @param doc Prawn::Document
  # @param data Array of numbers corresponding to columns
  # @param height integer
  # @return void
  #
  def prawn_bar_chart(doc, data, height = 200)
    x_margin = 20
    label_size = 8
    label_height = doc.height_of('bla', size: label_size)
    bar_width = (doc.bounds.right - x_margin) / 11
    y_max = nil # will be computed later
    y_increments = 11
    y_increment = data.max / y_increments - label_height - label_height / y_increments

    # draw axes
    doc.stroke_color 'a0a0a0'
    doc.stroke do
      doc.dash([4], phase: 0)
      doc.vertical_line doc.cursor.to_i - height, doc.cursor.to_i, at: x_margin
      doc.horizontal_line x_margin, doc.bounds.right, at: doc.cursor.to_i - height
    end

    # draw y axis labels
    doc.move_down y_increment

    def step_size(range, target_steps)
      ln10 = Math.log(10)
      temp_step = range / target_steps

      mag = (Math.log(temp_step) / ln10).floor
      mag_pow = 10**mag

      mag_msd = (temp_step / mag_pow + 0.5).round

      if mag_msd > 5.0
        mag_msd = 10.0
      elsif mag_msd > 2.0
        mag_msd = 5.0
      elsif mag_msd > 1.0
        mag_msd = 2.0
      end
      mag_msd * mag_pow
    end

    increment = step_size(data.max, y_increments)

    y_increments.downto(0).each do |i|
      doc.text "#{(i * increment).round}", size: label_size
      doc.move_down y_increment
    end

    # draw x axis labels & bars
    data.each_with_index do |score, i|
      doc.draw_text "#{(i * 10)}", size: label_size,
                    at: [x_margin + bar_width / 2 + i * bar_width, doc.cursor.to_i]
      if score > 0
        #doc.rectangle [x_margin + i * bar_width, doc.cursor.to_i + label_height],
        #          bar_width, (score / data.max) * height
        doc.rectangle [x_margin + i * bar_width, doc.cursor.to_i + label_height + (score / data.max) * height],
                  bar_width, (score / data.max) * height
        doc.fill
      end
    end
  end

  def same_institution_user
    # Normal users can only edit their own institution. Administrators can edit
    # any institution.
    institution = Institution.find(params[:id])
    redirect_to(root_url) unless
        institution.users.include?(current_user) || current_user.is_admin?
  end

  def institution_params
    params.require(:institution).permit(:name, :address1, :address2, :city,
                                        :state, :postal_code, :country, :url,
                                        :description, :email).tap do |whitelisted|
      # AQRs don't use Rails' nested params format, and will require additional
      # processing
      whitelisted[:assessment_question_responses] =
          params[:institution][:assessment_question_responses] if
          params[:institution][:assessment_question_responses]
    end
  end

end
