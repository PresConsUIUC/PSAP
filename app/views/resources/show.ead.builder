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
      xml.comment! 'TODO: (1) Is this ID OK? (It\'s just the database ID)'
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
      xml.origination('label' => 'Creator') {
        xml.comment! 'TODO: (5) Are we going to distinguish between companies and people? i.e. Is the assessment going to have a "creator type" pulldown or somesuch?'
        xml.corpname('Sample Company', 'source' => 'local')
        xml.persname('Sample Person',
                     'source' => 'local',
                     'normal' => 'Sample Person'
        )
      }
      xml.comment! 'TODO: (6) type="bulk" or type="inclusive" as appropriate; how to determine?'
      xml.comment! 'TODO: (7) Any special format to this date?'
      xml.unitdate(
          'normal' => '1889/1889',
          'type' => 'inclusive'
      )
      xml.physloc(@resource.location.name, 'label' => 'Location')
      xml.abstract(@resource.description, 'label' => 'Abstract/Summary')
      xml.physdesc {
        xml.comment! 'TODO: (9) Extent will be a property of Resource/Assessment for inclusion here, correct?'
        xml.extent('Sample Extent', 'label' => 'Extent')
        xml.extent('Other Extent', 'label' => 'Extent')
      }
      # if physical description is split into parts then physdesc element will repeat
    }
    xml.controlaccess {
      xml.comment! 'TODO: (10) tags: subjects, associated person [creator], etc. Will these be entered into the resource assessment for inclusion here?'
      xml.subject('test', 'source' => 'local')
    }
    if @resource.parent
      xml.dsc {
        xml.c(
            'id' => "psap_#{@resource.parent.id}",
            'level' => 'collection'
        ) {
          xml.did {
            xml.unittitle(@resource.parent.name)
            xml.comment! 'TODO: (12) is this the same concept as /archdesc/did/unitdate above?'
            xml.unitdate(9999,
            xml.unitid(@resource.local_identifier)
                         'normal' => '1889/1889',
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
              xml.comment! 'TODO: (12) is this the same concept as /archdesc/did/unitdate above?'
              xml.unitdate(9999,
              xml.unitid(@resource.local_identifier)
                           'normal' => '1889/1889',
                           'type' => 'inclusive'
              )
            }
          }
        end
      }
    end
  }
}
