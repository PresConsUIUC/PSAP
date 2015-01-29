# Eliminates whitespace
# xml = Builder::XmlMarkup.new

xml.instruct!
xml.ead(
    'xmlns' => 'urn:isbn:1-931666-22-9',
    'xmlns:xlink' => 'http://www.w3.org/1999/xlink',
    'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
    'xsi:schemaLocation' => 'urn:isbn:1-931666-22-9 http://www.loc.gov/ead/ead.xsd'
) {
  xml.eadheader(
      'langencoding' => 'iso639-2b',
      'repositoryencoding' => 'iso15511',
      'countryencoding' => 'iso3166-1',
      'dateencoding' => 'iso8601'
  ) {
    xml.eadid('countrycode' => 'US')
    xml.filedesc {
      xml.titlestmt {
        xml.titleproper("PSAP Resource Profile: #{@resource.name}")
        xml.author(@resource.user.full_name, 'id' => @resource.user.username)
      }
    }
    xml.profiledesc {
      xml.creation {
        xml.text! 'This profile was generated using the Preservation '\
        'Self-Assessment Program (PSAP) on '; xml.date(
            Time.now.strftime('%Y-%m-%d'),
            'normal' => Time.now.strftime('%Y-%m-%d'),
            'type' => 'source');
        xml.text! '.'
      }
    }
  }
  xml.archdesc('level' => @resource.resource_type == ResourceType::ITEM ? 'item' : 'collection') {
    xml.did {
      xml.repository(
          'label' => 'Institution/Subunit',
          'id' => "psap_repository_#{@institution.id}"
      ) {
        xml.corpname(@institution.name)
        if @institution.address1 && @institution.city && @institution.state
          xml.address {
            if @institution.address1
              xml.addressline(@institution.address1)
            end
            if @institution.address2
              xml.addressline(@institution.address2)
            end
            if @institution.city && @institution.state && @institution.postal_code
              xml.addressline("#{@institution.city} "\
                "#{@institution.state} #{@institution.postal_code}")
            end
            if @institution.email
              xml.addressline(@institution.email)
            end
          }
        elsif @institution.email
          xml.address {
            xml.addressline(@institution.email)
          }
        end
        if @institution.url
          xml.extref(
              @institution.url,
              'xlink:href' => @institution.url
          )
        end
      }
      if @resource.language
        xml.langmaterial('label' => 'Language') {
          xml.language(@resource.language.english_name,
                       'langcode' => @resource.language.iso639_2_code)
        }
      elsif @institution.language
        xml.langmaterial('label' => 'Language') {
          xml.language(@institution.language.english_name,
                       'langcode' => @institution.language.iso639_2_code)
        }
      end
      xml.unittitle(@resource.name, 'label' => 'Title')
      xml.unitid(@resource.local_identifier,
          'id' => "psap_#{@resource.id}",
          'label' => 'Identifier, local'
      )
      if @resource.creators.any?
        xml.origination('label' => 'Creator') {
          for creator in @resource.creators
            if creator.creator_type == CreatorType::PERSON
              xml.persname(creator.name,
                           'source' => 'local',
                           'normal' => creator.name
              )
            elsif creator.creator_type == CreatorType::COMPANY
              xml.corpname(creator.name, 'source' => 'local')
            end
          end
        }
      end
      for date in @resource.resource_dates
        if date.year
          xml.unitdate(date.year,
                       'normal' => "#{date.year}/#{date.year}",
                       'type' => 'inclusive'
          )
        elsif date.begin_year && date.end_year
          xml.unitdate("#{date.begin_year}-#{date.end_year}",
                       'normal' => "#{date.begin_year}/#{date.end_year}",
                       'type' => date.readable_date_type.downcase
          )
        end
      end
      xml.physloc(@resource.location.name, 'label' => 'Location')
      xml.abstract(@resource.description, 'label' => 'Abstract/Summary')
      if @resource.extents.any?
        xml.physdesc {
          for extent in @resource.extents
            xml.extent(extent.name, 'label' => 'Extent')
          end
        }
      end
    }
    if @resource.creators.any? || @resource.subjects.any? # TODO: controlled subject vocab from ArchivesSpace (see template EAD)
      xml.controlaccess {
        for creator in @resource.creators
          if creator.creator_type == CreatorType::PERSON
            xml.persname(creator.name,
                         'source' => 'local',
                         'normal' => creator.name
            )
          elsif creator.creator_type == CreatorType::COMPANY
            xml.corpname(creator.name, 'source' => 'local')
          end
        end
        for subject in @resource.subjects
          xml.subject(subject.name, 'source' => 'local')
        end
      }
    end
    if @resource.parent
      xml.dsc {
        xml.c(
            'id' => "psap_#{@resource.parent.id}",
            'level' => 'collection'
        ) {
          xml.did {
            xml.unittitle(@resource.parent.name)
            xml.unitid(@resource.parent.local_identifier)
            for date in @resource.parent.resource_dates
              if date.year
                xml.unitdate(date.year,
                             'normal' => "#{date.year}/#{date.year}",
                             'type' => 'inclusive'
                )
              elsif date.begin_year && date.end_year
                xml.unitdate("#{date.begin_year}/#{date.end_year}",
                             'normal' => "#{date.begin_year}/#{date.end_year}",
                             'type' => date.readable_date_type.downcase
                )
              end
            end
          }
        }
      }
    elsif @resource.children.any?
      xml.dsc {
        for child in @resource.children
          xml.c(
              'id' => "psap_#{child.id}",
              'level' => 'item'
          ) {
            xml.did {
              xml.unittitle(child.name)
              xml.unitid(child.local_identifier)
              for date in child.resource_dates
                if date.year
                  xml.unitdate(date.year,
                      'normal' => "#{date.year}/#{date.year}",
                      'type' => 'inclusive'
                  )
                elsif date.begin_year && date.end_year
                  xml.unitdate("#{date.begin_year}/#{date.end_year}",
                      'normal' => "#{date.begin_year}/#{date.end_year}",
                      'type' => date.readable_date_type.downcase
                  )
                end
              end
            }
          }
        end
      }
    end
  }
}
