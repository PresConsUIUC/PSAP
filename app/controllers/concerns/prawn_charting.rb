##
# Provides methods used by InstitutionsController to assist in creating PDFs
# with Prawn. Requires the 'prawn' and 'prawn-table' gems.
#
# Prawn documentation:
# http://prawnpdf.org/manual.pdf
# http://prawnpdf.org/prawn-table-manual.pdf
#
module PrawnCharting
  extend ActiveSupport::Concern
  include AssessmentQuestionsHelper

  def pdf_assessment_report(institution, user, institution_data,
                            location_assessment_sections, all_assessed_items,
                            institution_formats, collections)
    pdf = Prawn::Document.new(
        info: {
            Title: "PSAP Assessment Report: #{institution.name}",
            Author: user.full_name,
            #Subject: "My Subject",
            #Keywords: "test metadata ruby pdf dry",
            Creator: "Preservation Self-Assessment Program (PSAP)",
            Producer: "Prawn",
            CreationDate: Time.now
        })

    font = 'Helvetica'
    h1_size = 18
    h2_size = 16
    h3_size = 14
    pdf.default_leading 2
    page_width = pdf.bounds.right

    # heading
    pdf.font font, style: :bold
    pdf.text 'PSAP Assessment Report', size: h1_size
    pdf.font font, style: :normal
    pdf.text institution.name
    pdf.text Time.now.strftime('%B %-d, %Y'), size: 10
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    # institution overview
    pdf.font font, style: :bold
    pdf.text 'Institution', size: h2_size
    pdf.font font, style: :normal

    if institution.assessment_question_responses.any?
      pdf.text "Score: #{(institution.assessment_score * 100).round}"

      data = []
      institution.assessment_section_scores.each do |section_id, score|
        section = AssessmentSection.find(section_id)
        data << [ section.name, (score * 100).round,
                  assessment_score_characterization(score) ]
      end
      pdf.table(data, cell_style: { border_lines: [:dotted] })
    end

    # locations summary
    pdf.start_new_page
    pdf.font font, style: :bold
    pdf.text 'Storage Environments', size: h2_size
    pdf.font font, style: :normal
    pdf.move_down 20

    if institution.locations.any?
      data = []
      row = ['Location']
      location_assessment_sections.each do |section|
        row << section.name
      end
      row << 'Overall'
      data << row

      institution.locations.order(:name).each do |location|
        if location.assessment_question_responses.any?
          row = [ location.name ]
          location.assessment_section_scores.each do |section_id, score|
            row << (score * 100).round
          end
          row << (location.assessment_score * 100).round
          data << row
        end
      end

      pdf.table(data, cell_style: { border_lines: [:dotted] })
    else
      pdf.text 'No locations have been assessed yet.'
    end

    # resources overview
    pdf.start_new_page
    pdf.font font, style: :bold
    pdf.text 'Resources', size: h2_size
    pdf.font font, style: :normal
    pdf.move_down 20

    pdf.text "#{institution.resources.length} total items"
    pdf.text "#{all_assessed_items.length} items assessed"
    if institution_formats.any?
      pdf.text "Formats present:"
      pdf.indent 10 do
        institution_formats.each do |format|
          pdf.text "• #{format.name}"
        end
      end
    end
    pdf.move_down 20

    bar_chart(pdf, institution_data, page_width, 200)

    # collections overview
    pdf.start_new_page
    pdf.font font, style: :bold
    pdf.text 'Collections', size: h2_size
    pdf.font font, style: :normal
    pdf.move_down 20

    num_displayed_collections = 0
    if collections.any?
      collections.each do |collection|
        all_assessed_items = collection.all_assessed_items
        if all_assessed_items.any?
          num_displayed_collections += 1

          pdf.font font, style: :bold
          pdf.text collection.name, size: h3_size
          pdf.font font, style: :normal
          pdf.move_down 10

          # left column
          y_pos = pdf.cursor
          col_height = pdf.bounds.top / 2 - pdf.height_of('bla', size: h2_size) -
              pdf.height_of('bla', size: h3_size) * 2
          pdf.bounding_box([0, y_pos], width: page_width / 2, height: col_height) do
            pdf.text "Assessment: #{AssessmentType::name_for_type(collection.assessment_type)}"
            pdf.text "#{all_assessed_items.length} items assessed"
            pdf.text "Assessed by:"
            all_assessed_items.sort{ |x,y| x.updated_at <=> y.updated_at }.
                uniq{ |r| r.user_id }.each do |item|
              pdf.indent 10 do
                pdf.text "• #{item.user.full_name}"
              end
            end
            pdf.text "Last assessed: #{
            all_assessed_items.sort{ |x,y| x.updated_at <=> y.updated_at }.
                last.updated_at.strftime('%B %d, %Y')}"
            pdf.text "Formats present:"
            collection.all_assessed_items.collect{ |r| r.format }.uniq{ |f| f.id }.each do |format|
              pdf.indent 10 do
                pdf.text "• #{format.name}"
              end
            end
            pdf.move_down 10

            stats = collection.assessed_item_statistics
            data = [
                [ 'Average/Mean', (stats[:median] * 100).round ],
                [ 'Median', (stats[:median] * 100).round ],
                [ 'High', (stats[:high] * 100).round ],
                [ 'Low', (stats[:low] * 100).round ]
            ]
            pdf.table(data, cell_style: { border_lines: [:dotted] })
            pdf.move_down 10

            if collection.resource_notes.any?
              collection.resource_notes.each do |note|
                pdf.text note.value
              end
            end
            #pdf.stroke_bounds
          end

          # right column
          pdf.bounding_box([page_width / 2, y_pos],
                           width: page_width / 2, height: col_height) do
            data = [2, 0, 11, 18, 16, 8, 11, 13, 3, 1] # TODO: use real data
            bar_chart(pdf, data,
                      pdf.bounds.right, col_height / 1.2)
            #pdf.stroke_bounds
          end

          if num_displayed_collections % 2 == 0 # display 2 collections per page
            pdf.start_new_page
          end
        end
      end
    else
      pdf.text 'This institution has no collections.'
    end

    pdf.number_pages '<page>', { start_count_at: 2,
                                 page_filter: lambda{ |pg| pg != 1 },
                                 at: [page_width - 50, 0],
                                 align: :right,
                                 size: 10 }
    pdf
  end

  private

  ##
  # @param pdf Prawn::Document
  # @param data Array of 10 column values
  # @param width integer
  # @param height integer
  # @return void
  #
  def bar_chart(pdf, data, width, height)
    x_margin = 20
    label_size = 8
    label_height = pdf.height_of('bla', size: label_size)
    bar_spacing = width / 50
    bar_width = width / 10 - bar_spacing
    target_num_steps = 11

    # draw axes
    origin = [x_margin, pdf.cursor.to_i - height]
    pdf.stroke_color 'a0a0a0'
    pdf.stroke do
      pdf.vertical_line origin[1], origin[1] + height, at: origin[0]
      pdf.horizontal_line origin[0], width - origin[0], at: origin[1]
    end

    def step_size(range, target_steps)
      temp_step = range.to_f / target_steps.to_f
      mag = Math.log10(temp_step).floor
      mag_pow = (10**mag).to_f
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

    # draw y axis labels
    step_size = step_size(data.max, target_num_steps)
    num_steps = (data.max.to_f / step_size.to_f).ceil
    step_spacing = height / num_steps
    0.upto(num_steps).each do |i|
      label_text = "#{(i * step_size).round}"
      label_width = pdf.width_of(label_text, size: label_size)
      pdf.draw_text label_text, size: label_size,
                    at: [x_margin - label_width - label_height / 2,
                         origin[1] + step_spacing * i]
    end

    # draw x axis labels & bars
    data.each_with_index do |score, i|
      range_start = i * 10
      range_end = (i == data.length - 1) ? 100 : ((i + 1) * 10) - 1
      label_text = "#{range_start}-#{range_end}"
      label_width = pdf.width_of(label_text, size: label_size)
      pdf.draw_text label_text, size: label_size, width: label_width,
                    at: [origin[0] + i * bar_width + (bar_width - label_width) / 2 + i * bar_spacing - x_margin * (i.to_f / num_steps.to_f),
                         origin[1] - label_height]
      if score > 0
        pdf.fill_color '0000d0'
        pdf.fill_rectangle [origin[0] + i * bar_width + i * bar_spacing - x_margin * (i.to_f / num_steps.to_f),
                            origin[1] + (score.to_f / data.max.to_f) * height],
                           bar_width, (score.to_f / data.max.to_f) * height
        pdf.fill_color '000000'
      end
    end

    origin[1] -= label_height * 1.5
    pdf.text_box 'Assessment Score Range',
             at: origin, width: width, size: label_size, align: :center
  end

end
