class AssessmentQuestionImporter

  ##
  # @param pathname [String] Pathname of the spreadsheet containing assessment
  #                          question data.
  #
  def initialize(pathname)
    @xls = Roo::Spreadsheet.open(pathname)
  end

  def import_all
    import_formats # Formats have to be imported before assessment questions.
    import_assessment_questions
  end

  private

  ##
  # Imports assessment questions only. Only assessment questions that do not
  # already exist in the database (based on their QID) are imported.
  #
  def import_assessment_questions
    # Location & Institution assessment questions
    puts 'Importing resource assessment questions...'

    aq_sheets = %w(Resource-Paper-Unbound Resource-Photo Resource-AV
        Resource-Paper-Bound Resource-Objects)
    aq_sheets.each do |sheet|
      @xls.sheet(sheet).each_with_index do |row, index|
        if index > 0 and row[7].present? # skip header & trailing rows
          # Skip assessment questions that have already been imported.
          next if AssessmentQuestion.find_by_qid(row[6].to_i)

          properties = {
              qid: row[6].to_i,
              name: row[7].strip,
              question_type: (row[14].present? and row[14].downcase == 'checkboxes') ?
                  AssessmentQuestion::Type::CHECKBOX : AssessmentQuestion::Type::RADIO,
              index: index,
              weight: row[11].to_f,
              help_text: row[8] ? row[8].strip : nil,
              advanced_help_page: row[9] ? row[9].strip.gsub('.html', '') : nil,
              advanced_help_anchor: row[10] ? row[10].strip : nil
          }
          resource_assessment = Assessment.find_by_key('resource')
          case row[5][0..2].strip.downcase
            when 'use'
              properties[:assessment_section] =
                  AssessmentSection.find_by(name: 'Use | Access',
                                            assessment: resource_assessment)
            when 'sto'
              properties[:assessment_section] =
                  AssessmentSection.find_by(name: 'Storage | Container',
                                            assessment: resource_assessment)
            else
              properties[:assessment_section] =
                  AssessmentSection.find_by(name: 'Condition',
                                            assessment: resource_assessment)
          end

          unless row[12].blank? or row[12].to_s.include?('TBD') or row[13].blank?
            properties[:parent] = AssessmentQuestion.find_by_qid(row[12].to_i)
            properties[:enabling_assessment_question_options] = []
            row[13].split(';').map(&:strip).each do |dep|
              eaqo = properties[:parent].assessment_question_options.where(name: dep)[0]
              if eaqo
                properties[:enabling_assessment_question_options] << eaqo
              else
                puts 'AQO error: QID ' + row[10].to_s + ': ' + dep
              end
            end
          end

          properties[:formats] = Format.where('fid IN (?)',
                                          row[4].to_s.split(';').map{ |f| f.strip.to_i })

          question = AssessmentQuestion.new(properties)
          question.assessment_question_options.build(
              name: row[15], index: 0, value: row[16]) if row[15].present? and row[16].present?
          question.assessment_question_options.build(
              name: row[17], index: 1, value: row[18]) if row[17].present? and row[18].present?
          question.assessment_question_options.build(
              name: row[19], index: 2, value: row[20]) if row[19].present? and row[20].present?
          question.assessment_question_options.build(
              name: row[21], index: 3, value: row[22]) if row[21].present? and row[22].present?
          question.assessment_question_options.build(
              name: row[23], index: 4, value: row[24]) if row[23].present? and row[24].present?
          question.assessment_question_options.build(
              name: row[25], index: 5, value: row[26]) if row[25].present? and row[26].present?

          puts "Importing question ID #{question.qid}"
          question.save!
        end
      end
    end

    # Location & Institution assessment questions
    puts 'Importing location & institution assessment questions...'
    aq_sheets = %w(Location Institution)
    aq_sheets.each do |sheet|
      @xls.sheet(sheet).each_with_index do |row, index|
        if index > 0 and row[2].present? # skip header & trailing rows
          # Skip assessment questions that have already been imported.
          next if AssessmentQuestion.find_by_qid(row[1].to_i)

          properties = {
              qid: row[1].to_i,
              name: row[2].strip,
              question_type: AssessmentQuestion::Type::RADIO,
              index: index,
              weight: row[6].to_f,
              help_text: row[3] ? row[3].strip : nil,
              advanced_help_page: row[4] ? row[4].strip.gsub('.html', '') : nil,
              advanced_help_anchor: row[5] ? row[5].strip : nil
          }
          institution_assessment = Assessment.find_by_key('institution')
          location_assessment = Assessment.find_by_key('location')
          case row[0][0..2].strip.downcase
            when 'col'
              properties[:assessment_section] =
                  AssessmentSection.find_by(name: 'Collection Planning',
                                            assessment: institution_assessment)
            when 'dis'
              properties[:assessment_section] =
                  AssessmentSection.find_by(name: 'Disaster Recovery',
                                            assessment: institution_assessment)
            when 'env'
              properties[:assessment_section] =
                  AssessmentSection.find_by(name: 'Environment',
                                            assessment: location_assessment)
            when 'eme'
              properties[:assessment_section] =
                  AssessmentSection.find_by(name: 'Emergency Preparedness',
                                            assessment: location_assessment)
            when 'mat'
              properties[:assessment_section] =
                  AssessmentSection.find_by(name: 'Material Inspection',
                                            assessment: institution_assessment)
            when 'pla'
              properties[:assessment_section] =
                  AssessmentSection.find_by(name: 'Playback Equipment',
                                            assessment: institution_assessment)
            when 'sec'
              properties[:assessment_section] =
                  AssessmentSection.find_by(name: 'Security',
                                            assessment: institution_assessment)
            when 'use'
              properties[:assessment_section] =
                  AssessmentSection.find_by(name: 'Use | Access',
                                            assessment: institution_assessment)
          end

          unless row[9].blank? or row[8].blank?
            properties[:parent] = AssessmentQuestion.find_by_qid(row[7].to_i)
            properties[:enabling_assessment_question_options] = []
            row[8].split(';').map(&:strip).each do |dep|
              eaqo = properties[:parent].assessment_question_options.where(name: dep)[0]
              if eaqo
                properties[:enabling_assessment_question_options] << eaqo
              else
                puts 'AQO error: QID ' + row[7].to_s + ': ' + dep
              end
            end
          end

          question = AssessmentQuestion.new(properties)
          question.assessment_question_options.build(
              name: row[9], index: 0, value: row[10]) if row[9]
          question.assessment_question_options.build(
              name: row[11], index: 1, value: row[12]) if row[11]
          question.assessment_question_options.build(
              name: row[13], index: 2, value: row[14]) if row[13]
          question.assessment_question_options.build(
              name: row[15], index: 3, value: row[16]) if row[15]
          question.assessment_question_options.build(
              name: row[17], index: 4, value: row[18]) if row[17]

          puts "Importing question ID #{question.qid}"
          question.save!
        end
      end
    end
  end

  ##
  # Imports formats only. Only formats that do not already exist in the
  # database (based on their FID) are imported.
  #
  def import_formats
    sheet = @xls.sheet('Format Scores')
    sheet.each_with_index do |row, i|
      if i > 0 # skip header row
        name = parent = nil
        (2..5).reverse_each do |col|
          if name.blank? and !row[col].blank?
            name = row[col]
            if col > 2 # find its parent FID by iterating backwards
              (0..i).reverse_each do |j|
                if sheet.row(j)[col].blank?
                  parent = Format.find_by_fid(sheet.row(j)[1])
                  break
                end
              end
            else
              parent = nil
            end
          end
        end
        if name.present? and !Format.find_by_fid(row[1])
          format = Format.new(
              fid: row[1],
              name: name,
              format_class: FormatClass::class_for_name(row[0]),
              parent: parent,
              score: row[6],
              collection_id_guide_page: row[7],
              collection_id_guide_anchor: row[8])
          if row[9].present? # temperature ranges
            min_temps = row[9].split(',')
            max_temps = row[10].split(',')
            temp_scores = row[11].split(',')
            min_temps.each_with_index do |min_temp, i|
              format.temperature_ranges.build(
                  min_temp_f: i == 0 ? nil : min_temp.strip.to_i,
                  max_temp_f: i == max_temps.length - 1 ? nil : max_temps[i].strip.to_i,
                  score: temp_scores[i].strip.to_f)
            end
          end
          if row[12].present? # relative humidity ranges
            min_rhs = row[12].split(',')
            max_rhs = row[13].split(',')
            rh_scores = row[14].split(',')
            min_rhs.each_with_index do |min_rh, i|
              format.humidity_ranges.build(
                  min_rh: min_rh.strip.to_i,
                  max_rh: max_rhs[i].strip.to_i,
                  score: rh_scores[i].strip.to_f)
            end
          end

          puts "Importing format ID #{format.fid}"
          format.save!
        end
      end
    end

    # Format Vector Groups & Ink/Media Types
    @xls.sheet('InkMedia Scores').each_with_index do |row, i|
      next if i == 0 # skip header row
      unless FormatInkMediaType.find_by_name(row[0])
        FormatInkMediaType.create!(name: row[0], score: row[4])
      end
    end

    # Format Support Types
    @xls.sheet('Support Scores').each_with_index do |row, i|
      next if i == 0 # skip header row
      unless FormatSupportType.find_by_name(row[0])
        FormatSupportType.create!(name: row[0], score: row[4])
      end
    end
  end

end
