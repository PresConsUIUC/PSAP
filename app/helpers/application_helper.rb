module ApplicationHelper

  def bootstrap_class_for flash_type
    case flash_type.to_sym
      when :success
        'alert-success'
      when :error
        'alert-danger'
      when :alert
        'alert-block'
      when :notice
        'alert-info'
      else
        flash_type.to_s
    end
  end

  def breadcrumb(*items) # TODO: use this more
    crumb = '<ol class="breadcrumb">'
    items.each_with_index do |item, index|
      if index == items.length
        crumb += '<li class="active">'
      else
        crumb += '<li>'
      end
      if item.is_a?(Hash)
        crumb += link_to(truncate(item.keys[0], length: 50), item.values[0])
      else
        crumb += truncate(item, length: 50)
      end
      crumb += '</li>'
    end
    crumb += '</ol>'
    raw(crumb)
  end

  def countries_for_select
    [['United States of America', 'United States of America'],
     ['Afghanistan', 'Afghanistan'],
     ['Albania', 'Albania'],
     ['Algeria', 'Algeria'],
     ['American Samoa', 'American Samoa'],
     ['Andorra', 'Andorra'],
     ['Angola', 'Angola'],
     ['Anguilla', 'Anguilla'],
     ['Antigua & Barbuda', 'Antigua & Barbuda'],
     ['Argentina', 'Argentina'],
     ['Armenia', 'Armenia'],
     ['Aruba', 'Aruba'],
     ['Australia', 'Australia'],
     ['Austria', 'Austria'],
     ['Azerbaijan', 'Azerbaijan'],
     ['Bahamas', 'Bahamas'],
     ['Bahrain', 'Bahrain'],
     ['Bangladesh', 'Bangladesh'],
     ['Barbados', 'Barbados'],
     ['Belarus', 'Belarus'],
     ['Belgium', 'Belgium'],
     ['Belize', 'Belize'],
     ['Benin', 'Benin'],
     ['Bermuda', 'Bermuda'],
     ['Bhutan', 'Bhutan'],
     ['Bolivia', 'Bolivia'],
     ['Bonaire', 'Bonaire'],
     ['Bosnia & Herzegovina', 'Bosnia & Herzegovina'],
     ['Botswana', 'Botswana'],
     ['Brazil', 'Brazil'],
     ['British Indian Ocean Ter', 'British Indian Ocean Ter'],
     ['Brunei', 'Brunei'],
     ['Bulgaria', 'Bulgaria'],
     ['Burkina Faso', 'Burkina Faso'],
     ['Burundi', 'Burundi'],
     ['Cambodia', 'Cambodia'],
     ['Cameroon', 'Cameroon'],
     ['Canada', 'Canada'],
     ['Canary Islands', 'Canary Islands'],
     ['Cape Verde', 'Cape Verde'],
     ['Cayman Islands', 'Cayman Islands'],
     ['Central African Republic', 'Central African Republic'],
     ['Chad', 'Chad'],
     ['Channel Islands', 'Channel Islands'],
     ['Chile', 'Chile'],
     ['China', 'China'],
     ['Christmas Island', 'Christmas Island'],
     ['Cocos Island', 'Cocos Island'],
     ['Colombia', 'Colombia'],
     ['Comoros', 'Comoros'],
     ['Congo', 'Congo'],
     ['Cook Islands', 'Cook Islands'],
     ['Costa Rica', 'Costa Rica'],
     ['Cote D\'Ivoire', 'Cote D\'Ivoire'],
     ['Croatia', 'Croatia'],
     ['Cuba', 'Cuba'],
     ['Curaco', 'Curacao'],
     ['Cyprus', 'Cyprus'],
     ['Czech Republic', 'Czech Republic'],
     ['Democratic People\'s Republic of Korea', 'Democratic People\'s Republic of Korea'],
     ['Denmark', 'Denmark'],
     ['Djibouti', 'Djibouti'],
     ['Dominica', 'Dominica'],
     ['Dominican Republic', 'Dominican Republic'],
     ['East Timor', 'East Timor'],
     ['Ecuador', 'Ecuador'],
     ['Egypt', 'Egypt'],
     ['El Salvador', 'El Salvador'],
     ['Equatorial Guinea', 'Equatorial Guinea'],
     ['Eritrea', 'Eritrea'],
     ['Estonia', 'Estonia'],
     ['Ethiopia', 'Ethiopia'],
     ['Falkland Islands', 'Falkland Islands'],
     ['Faroe Islands', 'Faroe Islands'],
     ['Fiji', 'Fiji'],
     ['Finland', 'Finland'],
     ['France', 'France'],
     ['French Guiana', 'French Guiana'],
     ['French Polynesia', 'French Polynesia'],
     ['French Southern Ter', 'French Southern Ter'],
     ['Gabon', 'Gabon'],
     ['Gambia', 'Gambia'],
     ['Georgia', 'Georgia'],
     ['Germany', 'Germany'],
     ['Ghana', 'Ghana'],
     ['Gibraltar', 'Gibraltar'],
     ['Great Britain', 'Great Britain'],
     ['Greece', 'Greece'],
     ['Greenland', 'Greenland'],
     ['Grenada', 'Grenada'],
     ['Guadeloupe', 'Guadeloupe'],
     ['Guam', 'Guam'],
     ['Guatemala', 'Guatemala'],
     ['Guinea', 'Guinea'],
     ['Guyana', 'Guyana'],
     ['Haiti', 'Haiti'],
     ['Hawaii', 'Hawaii'],
     ['Honduras', 'Honduras'],
     ['Hong Kong', 'Hong Kong'],
     ['Hungary', 'Hungary'],
     ['Iceland', 'Iceland'],
     ['India', 'India'],
     ['Indonesia', 'Indonesia'],
     ['Iran', 'Iran'],
     ['Iraq', 'Iraq'],
     ['Ireland', 'Ireland'],
     ['Isle of Man', 'Isle of Man'],
     ['Israel', 'Israel'],
     ['Italy', 'Italy'],
     ['Jamaica', 'Jamaica'],
     ['Japan', 'Japan'],
     ['Jordan', 'Jordan'],
     ['Kazakhstan', 'Kazakhstan'],
     ['Kenya', 'Kenya'],
     ['Kiribati', 'Kiribati'],
     ['Kuwait', 'Kuwait'],
     ['Kyrgyzstan', 'Kyrgyzstan'],
     ['Laos', 'Laos'],
     ['Latvia', 'Latvia'],
     ['Lebanon', 'Lebanon'],
     ['Lesotho', 'Lesotho'],
     ['Liberia', 'Liberia'],
     ['Libya', 'Libya'],
     ['Liechtenstein', 'Liechtenstein'],
     ['Lithuania', 'Lithuania'],
     ['Luxembourg', 'Luxembourg'],
     ['Macau', 'Macau'],
     ['Macedonia', 'Macedonia'],
     ['Madagascar', 'Madagascar'],
     ['Malaysia', 'Malaysia'],
     ['Malawi', 'Malawi'],
     ['Maldives', 'Maldives'],
     ['Mali', 'Mali'],
     ['Malta', 'Malta'],
     ['Marshall Islands', 'Marshall Islands'],
     ['Martinique', 'Martinique'],
     ['Mauritania', 'Mauritania'],
     ['Mauritius', 'Mauritius'],
     ['Mayotte', 'Mayotte'],
     ['Mexico', 'Mexico'],
     ['Midway Islands', 'Midway Islands'],
     ['Moldova', 'Moldova'],
     ['Monaco', 'Monaco'],
     ['Mongolia', 'Mongolia'],
     ['Montserrat', 'Montserrat'],
     ['Morocco', 'Morocco'],
     ['Mozambique', 'Mozambique'],
     ['Myanmar', 'Myanmar'],
     ['Nambia', 'Nambia'],
     ['Nauru', 'Nauru'],
     ['Nepal', 'Nepal'],
     ['Netherland Antilles', 'Netherland Antilles'],
     ['Netherlands', 'Netherlands'],
     ['Nevis', 'Nevis'],
     ['New Caledonia', 'New Caledonia'],
     ['New Zealand', 'New Zealand'],
     ['Nicaragua', 'Nicaragua'],
     ['Niger', 'Niger'],
     ['Nigeria', 'Nigeria'],
     ['Niue', 'Niue'],
     ['Norfolk Island', 'Norfolk Island'],
     ['Norway', 'Norway'],
     ['Oman', 'Oman'],
     ['Pakistan', 'Pakistan'],
     ['Palau Island', 'Palau Island'],
     ['Palestine', 'Palestine'],
     ['Panama', 'Panama'],
     ['Papua New Guinea', 'Papua New Guinea'],
     ['Paraguay', 'Paraguay'],
     ['Peru', 'Peru'],
     ['Phillipines', 'Philippines'],
     ['Pitcairn Island', 'Pitcairn Island'],
     ['Poland', 'Poland'],
     ['Portugal', 'Portugal'],
     ['Puerto Rico', 'Puerto Rico'],
     ['Qatar', 'Qatar'],
     ['Republic of Montenegro', 'Republic of Montenegro'],
     ['Republic of Serbia', 'Republic of Serbia'],
     ['Reunion', 'Reunion'],
     ['Romania', 'Romania'],
     ['Russia', 'Russia'],
     ['Rwanda', 'Rwanda'],
     ['St. Barthelemy', 'St. Barthelemy'],
     ['St. Eustatius', 'St. Eustatius'],
     ['St. Helena', 'St. Helena'],
     ['St. Kitts-Nevis', 'St. Kitts-Nevis'],
     ['St. Lucia', 'St. Lucia'],
     ['St. Maarten', 'St. Maarten'],
     ['St. Pierre & Miquelon', 'St. Pierre & Miquelon'],
     ['St. Vincent & Grenadines', 'St. Vincent & Grenadines'],
     ['Saipan', 'Saipan'],
     ['Samoa', 'Samoa'],
     ['Samoa American', 'Samoa American'],
     ['San Marino', 'San Marino'],
     ['Sao Tome & Principe', 'Sao Tome & Principe'],
     ['Saudi Arabia', 'Saudi Arabia'],
     ['Senegal', 'Senegal'],
     ['Serbia', 'Serbia'],
     ['Seychelles', 'Seychelles'],
     ['Sierra Leone', 'Sierra Leone'],
     ['Singapore', 'Singapore'],
     ['Slovakia', 'Slovakia'],
     ['Slovenia', 'Slovenia'],
     ['Solomon Islands', 'Solomon Islands'],
     ['Somalia', 'Somalia'],
     ['South Africa', 'South Africa'],
     ['South Korea', 'South Korea'],
     ['Spain', 'Spain'],
     ['Sri Lanka', 'Sri Lanka'],
     ['Sudan', 'Sudan'],
     ['Suriname', 'Suriname'],
     ['Swaziland', 'Swaziland'],
     ['Sweden', 'Sweden'],
     ['Switzerland', 'Switzerland'],
     ['Syria', 'Syria'],
     ['Tahiti', 'Tahiti'],
     ['Taiwan', 'Taiwan'],
     ['Tajikistan', 'Tajikistan'],
     ['Tanzania', 'Tanzania'],
     ['Thailand', 'Thailand'],
     ['Togo', 'Togo'],
     ['Tokelau', 'Tokelau'],
     ['Tonga', 'Tonga'],
     ['Trinidad & Tobago', 'Trinidad & Tobago'],
     ['Tunisia', 'Tunisia'],
     ['Turkey', 'Turkey'],
     ['Turkmenistan', 'Turkmenistan'],
     ['Turks & Caicos Is', 'Turks & Caicos Is'],
     ['Tuvalu', 'Tuvalu'],
     ['Uganda', 'Uganda'],
     ['Ukraine', 'Ukraine'],
     ['United Arab Erimates', 'United Arab Emirates'],
     ['United Kingdom', 'United Kingdom'],
     ['Uruguay', 'Uruguay'],
     ['Uzbekistan', 'Uzbekistan'],
     ['Vanuatu', 'Vanuatu'],
     ['Vatican City State', 'Vatican City State'],
     ['Venezuela', 'Venezuela'],
     ['Vietnam', 'Vietnam'],
     ['Virgin Islands (British)', 'Virgin Islands (British)'],
     ['Virgin Islands (USA)', 'Virgin Islands (USA)'],
     ['Wake Island', 'Wake Island'],
     ['Wallis & Futana Is', 'Wallis & Futana Is'],
     ['Yemen', 'Yemen'],
     ['Zaire', 'Zaire'],
     ['Zambia', 'Zambia'],
     ['Zimbabwe', 'Zimbabwe']]
  end

  ##
  # Works with retina.js. When using instead of retina_image_tag, you have
  # to add a "data-at2x" to your <img> tag.
  #
  def retina_image_path(name_at_1x)
    asset_path(name_at_1x.gsub(%r{\.\w+$}, '@2x\0'))
  end

  ##
  # Works with retina.js
  #
  def retina_image_tag(name_at_1x, options={})
    image_tag(name_at_1x,
              options.merge('data-at2x' => retina_image_path(name_at_1x)))
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == 'asc') ? 'desc' : 'asc'
    link_to title, {sort: column, direction: direction}, {class: css_class}
  end

end
