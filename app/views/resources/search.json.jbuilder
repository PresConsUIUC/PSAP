json.resources @resources do |resource|
  json.psap_id resource.id
  json.local_identifier resource.local_identifier
  json.name resource.name
  json.assessment_score_percent resource.effective_assessment_score
  json.assessment_type Assessment::Type::name_for_type(resource.assessment_type)
  json.location resource.location.name
  json.resource_type resource.readable_resource_type
  json.parent_psap_id resource.parent.id if resource.parent
  json.format resource.format.name if resource.format
  json.format_ink_media_type resource.format_ink_media_type.name if resource.format_ink_media_type
  json.format_support_type resource.format_support_type.name if resource.format_support_type
  json.significance resource.readable_significance
  json.language resource.language.english_name if resource.language
  json.rights resource.rights
  json.description resource.description
  json.creators do
    json.array! resource.creators.map{ |c| c.name }
  end
  json.dates do
    json.array! resource.resource_dates.map{ |d| d.as_dublin_core_string }
  end
  json.subjects do
    json.array! resource.subjects.map{ |s| s.name }
  end
  json.extents do
    json.array! resource.extents.map{ |e| e.name }
  end
  json.notes do
    json.array! resource.resource_notes.map{ |n| n.value }
  end
  json.created resource.created_at.iso8601
  json.updated resource.updated_at.iso8601

  json.assessment_questions resource.assessment_question_responses do |response|
    json.qid response.assessment_question.qid
    json.question response.assessment_question.name
    json.response response.assessment_question_option.name
    json.score response.assessment_question_option.value.to_f
  end
end
