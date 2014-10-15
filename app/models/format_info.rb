class FormatInfo < ActiveRecord::Base

  def to_param
    format_category
  end

end
