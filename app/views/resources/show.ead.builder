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
          'id' => "psap_repository_#{@institution.id}" # TODO: is this right?
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
      xml.langmaterial('label' => 'Language') {
        xml.language('English', 'langcode' => 'eng') # TODO: put institution language here
      }
      xml.unittitle(@resource.name, 'label' => 'Title')
      xml.unitid('sample ID', # TODO: fix this
          'id' => "psap_#{@resource.id}",
          'label' => 'Identifier, local'
      )
      xml.origination('label' => 'Creator') {
        xml.corpname('Sample Source', 'source' => 'local') # TODO: fix this
      }
      xml.unitdate( # TODO: type="bulk" or type="inclusive" as appropriate
          'normal' => '9999/9999',
          'type' => 'inclusive'
      )
      xml.physloc(@resource.location.name, 'label' => 'Location')
      xml.abstract('Sample Description', 'label' => 'Abstract/Summary') # TODO: fix this
      xml.physdesc {
        xml.extent('Sample Extent', 'label' => 'Extent') # TODO: fix this
        xml.extent('Other Extent', 'label' => 'Extent')
      }
      # if physical description is split into parts then physdesc element will repeat
    }
    xml.controlaccess {
      xml.subject('test', 'source' => 'local') # TODO: fix this
    }
    if @resource.parent
      xml.dsc {
        xml.c(
            'id' => "psap_#{@resource.parent.id}",
            'level' => 'collection'
        ) {
          xml.did {
            xml.unittitle(@resource.parent.name)
            xml.unitid('Sample') # TODO: fix this
            xml.unitdate(9999,
                         'normal' => '9999/9999',
                         'type' => 'inclusive'
            )
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
              xml.unitid('Sample') # TODO: fix this
              xml.unitdate(9999,
                           'normal' => '9999/9999',
                           'type' => 'inclusive'
              )
            }
          }
        end
      }
    end
  }
}
