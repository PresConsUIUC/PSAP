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

  def breadcrumbs(items) # TODO: use this more
    items = [items] if items.kind_of?(String)
    crumb = '<ol class="breadcrumb">'
    items.each_with_index do |item, index|
      if index == items.length - 1
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
    countries = [
        'United States of America', 'Afghanistan', 'Albania', 'Algeria',
        'American Samoa', 'Andorra', 'Angola', 'Anguilla', 'Antigua & Barbuda',
        'Argentina', 'Armenia', 'Aruba', 'Australia', 'Austria', 'Azerbaijan',
        'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium',
        'Belize', 'Benin', 'Bermuda', 'Bhutan', 'Bolivia', 'Bonaire',
        'Bosnia & Herzegovina', 'Botswana', 'Brazil',
        'British Indian Ocean Ter', 'Brunei', 'Bulgaria', 'Burkina Faso',
        'Burundi', 'Cambodia', 'Cameroon', 'Canada', 'Canary Islands',
        'Cape Verde', 'Cayman Islands', 'Central African Republic',
        'Chad', 'Channel Islands', 'Chile', 'China', 'Christmas Island',
        'Cocos Island', 'Colombia', 'Comoros', 'Congo', 'Cook Islands',
        'Costa Rica', 'Cote D\'Ivoire', 'Croatia', 'Cuba', 'Curacao', 'Cyprus',
        'Czech Republic', 'Democratic People\'s Republic of Korea',
        'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic', 'East Timor',
        'Ecuador', 'Egypt', 'El Salvador', 'Equatorial Guinea',
        'Equatorial Guinea', 'Eritrea', 'Estonia', 'Ethiopia',
        'Falkland Islands', 'Faroe Islands', 'Fiji', 'Finland', 'France',
        'French Guiana', 'French Polynesia', 'French Southern Ter',
        'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana', 'Gibraltar',
        'Great Britain', 'Greece', 'Greenland', 'Grenada', 'Guadeloupe',
        'Guam', 'Guatemala', 'Guinea', 'Guyana', 'Haiti', 'Hawaii', 'Honduras',
        'Honduras', 'Hong Kong', 'Hungary', 'Iceland', 'India', 'Indonesia',
        'Iran', 'Iraq', 'Ireland', 'Isle of Man', 'Israel', 'Italy', 'Jamaica',
        'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kiribati', 'Kuwait',
        'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia',
        'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Macau',
        'Macedonia', 'Madagascar', 'Malaysia', 'Malawi', 'Maldives', 'Mali',
        'Malta', 'Marshall Islands', 'Martinique', 'Mauritania', 'Mauritius',
        'Mayotte', 'Mexico', 'Midway Islands', 'Moldova', 'Monaco', 'Mongolia',
        'Montserrat', 'Morocco', 'Mozambique', 'Myanmar', 'Nambia', 'Nauru',
        'Nepal', 'Netherland Antilles', 'Netherlands', 'Nevis', 'New Caledonia',
        'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'Niue',
        'Norfolk Island', 'Norway', 'Oman', 'Pakistan', 'Palau Island',
        'Palestine', 'Panama', 'Papua New Guinea', 'Paraguay', 'Peru',
        'Philippines', 'Pitcairn Island', 'Poland', 'Portugal', 'Puerto Rico',
        'Qatar', 'Republic of Montenegro', 'Republic of Serbia', 'Reunion',
        'Romania', 'Russia', 'Rwanda', 'St. Barthelemy', 'St. Eustatius',
        'St. Helena', 'St. Kitts-Nevis', 'St. Lucia', 'St. Maarten',
        'St. Pierre & Miquelon', 'St. Vincent & Grenadines', 'Saipan', 'Samoa',
        'Samoa American', 'San Marino', 'Sao Tome & Principe', 'Saudi Arabia',
        'Senegal', 'Serbia', 'Seychelles', 'Sierra Leone', 'Singapore',
        'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia', 'South Africa',
        'South Korea', 'Spain', 'Sri Lanka', 'Sudan', 'Suriname', 'Swaziland',
        'Sweden', 'Switzerland', 'Syria', 'Tahiti', 'Taiwan', 'Tajikistan',
        'Tanzania', 'Thailand', 'Togo', 'Tokelau', 'Tonga', 'Trinidad & Tobago',
        'Tunisia', 'Turkey', 'Turkmenistan', 'Turks & Caicos Is', 'Tuvalu',
        'Uganda', 'Ukraine', 'United Arab Emirates', 'United Kingdom',
        'Uruguay', 'Uzbekistan', 'Vanuatu', 'Vatican City State', 'Venezuela',
        'Vietnam', 'Virgin Islands (British)', 'Virgin Islands (USA)',
        'Wake Island', 'Wallis & Futana Is', 'Yemen', 'Zaire' 'Zambia',
        'Zimbabwe'
    ]
    countries.map{ |c| [c, c] }
  end

  ##
  # @param entity Some entity: Institution, Location, etc.
  # @param title Optional title for a tooltip
  #
  def entity_icon(entity, title = '')
    # https://fortawesome.github.io/Font-Awesome/icons/
    class_ = ''
    if entity.kind_of?(Institution) or entity == Institution
      class_ = 'fa-university'
    elsif entity.kind_of?(Location) or entity == Location
      class_ = 'fa-map-marker'
    elsif entity.kind_of?(Repository) or entity == Repository
      class_ = 'fa-building-o'
    elsif entity.kind_of?(Resource)
      if entity.resource_type == ResourceType::COLLECTION
        class_ = 'fa-folder-open-o'
      elsif entity.format
        case entity.format.format_class
          when FormatClass::AV
            class_ = 'fa-film'
          when FormatClass::IMAGE
            class_ = 'fa-picture-o'
          when FormatClass::UNBOUND_PAPER
            class_ = 'fa-file-text-o'
          when FormatClass::BOUND_PAPER
            class_ = 'fa-book'
        end
      else
        class_ = 'fa-cube'
      end
    elsif entity == Resource
      class_ = 'fa-cube'
    elsif entity.kind_of?(User) or entity == User
      class_ = 'fa-user'
    end
    raw("<i class=\"psap-entity-icon fa #{class_}\" "\
    "aria-hidden=\"true\" title=\"#{title}\"></i>")
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
