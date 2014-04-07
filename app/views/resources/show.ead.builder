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
    xml.eadid('countrycode' => 'US') {
      xml.filedesc {
        xml.titlestmt {
          xml.titleproper(@resource.name)
          xml.author(@resource.user.full_name, 'id' => @resource.user.username)
        }
      }
      xml.profiledesc {
        xml.creation {
          xml.text! 'This profile was generated using the Preservation '\
          'Self-Assessment Program (PSAP) on'; xml.date(
              Time.now.strftime('%Y-%m-%d'),
              'normal' => Time.now.strftime('%Y-%m-%d'),
              'type' => 'source');
          xml.text! '.'
        }
      }
    }
  }
  xml.archdesc('level' => @resource.resource_type == ResourceType::ITEM ? 'item' : 'collection') {
    xml.did {
      xml.repository(
          'label' => @institution.name,
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
          }
        end
        xml.extref(
            @institution.url,
            'xlink:href' => @institution.url
        )
      }
      if @institution.language
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
      if @resource.year
        xml.unitdate(@resource.year,
            'normal' => "#{@resource.year}/#{@resource.year}",
            'type' => @resource.readable_date_type.downcase
        )
      elsif @resource.begin_year && @resource.end_year
        xml.unitdate("#{@resource.begin_year}/#{@resource.end_year}",
            'normal' => "#{@resource.begin_year}/#{@resource.end_year}",
            'type' => @resource.readable_date_type.downcase
        )
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
      # if physical description is split into parts then physdesc element will repeat
    }
    xml.controlaccess {
      xml.subject('test', 'source' => 'local') # TODO: (10) fix
    }
    if @resource.parent
      xml.dsc {
        xml.c(
            'id' => "psap_#{@resource.parent.id}",
            'level' => 'collection'
        ) {
          xml.did {
            xml.unittitle(@resource.parent.name)
            xml.unitid(@resource.parent.local_identifier)
            if @resource.parent.year
              xml.unitdate(@resource.parent.year,
                  'normal' => "#{@resource.parent.year}/#{@resource.parent.year}",
                  'type' => @resource.parent.readable_date_type.downcase
              )
            elsif @resource.parent.begin_year && @resource.parent.end_year
              xml.unitdate("#{@resource.parent.begin_year}/#{@resource.parent.end_year}",
                  'normal' => "#{@resource.parent.begin_year}/#{@resource.parent.end_year}",
                  'type' => @resource.parent.readable_date_type.downcase
              )
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
              if child.year
                xml.unitdate(child.year,
                    'normal' => "#{child.year}/#{child.year}",
                    'type' => child.readable_date_type.downcase
                )
              elsif child.begin_year && child.end_year
                xml.unitdate("#{child.begin_year}/#{child.end_year}",
                    'normal' => "#{child.begin_year}/#{child.end_year}",
                    'type' => child.readable_date_type.downcase
                )
              end
            }
          }
        end
      }
    end
  }
}
