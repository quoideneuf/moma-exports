# This corrects a problem with the way finding aid titles
# are mapped to EAD, and should be unnecessary in versions
# later than 1.0.9

EADSerializer.class_eval do

  def serialize_eadheader(data, xml, fragments)
    eadheader_atts = {:findaidstatus => data.finding_aid_status,
      :repositoryencoding => "iso15511",
      :countryencoding => "iso3166-1",
      :dateencoding => "iso8601",
      :langencoding => "iso639-2b"}.reject{|k,v| v.nil? || v.empty?}

    xml.eadheader(eadheader_atts) {

      eadid_atts = {:countrycode => data.repo.country,
        :url => data.ead_location,
        :mainagencycode => data.mainagencycode}.reject{|k,v| v.nil? || v.empty?}
      
      xml.eadid(eadid_atts) {
        xml.text data.ead_id
      }

      xml.filedesc {

        xml.titlestmt {

          titleproper = ""
          titleproper += "#{data.finding_aid_title} " if data.finding_aid_title
          titleproper += "#{data.title}" if ( data.title && titleproper.empty? )
          titleproper += "<num>#{(0..3).map{|i| data.send("id_#{i}")}.compact.join('.')}</num>"
          xml.titleproper (fragments << titleproper)
            
          xml.author data.finding_aid_author unless data.finding_aid_author.nil?
          xml.sponsor data.finding_aid_sponsor unless data.finding_aid_sponsor.nil?
        }
        
        unless data.finding_aid_edition_statement.nil?
          xml.editionstmt {
            xml.p data.finding_aid_edition_statement
          }
        end

        xml.publicationstmt {
          xml.publisher data.repo.name

          if data.repo.image_url
            xml.p {
              xml.extref ({"xlink:href" => data.repo.image_url,
                            "xlink:actuate" => "onLoad",
                            "xlink:show" => "embed",
                            "xlink:linktype" => "simple"})
            }
          end

          unless data.addresslines.empty?
            xml.address {
              data.addresslines.each do |line|
                xml.addressline line
              end
            }
          end
        }

        if (val = data.finding_aid_series_statement)
          xml.seriesstmt {
            if val.strip.start_with?('<')
              xml.text (fragments << val)
            else
              xml.p (fragments << val)
            end
          }
        end
      }

      xml.profiledesc {
        creation = "This finding aid was produced using ArchivesSpace on <date>#{Time.now}</date>."
        xml.creation (fragments << creation)

        if (val = data.finding_aid_language)
          xml.langusage (fragments << val)
        end

        if (val = data.descrules)
          xml.descrules val
        end
      }

      if data.finding_aid_revision_date || data.finding_aid_revision_description
        xml.revisiondesc {
          if data.finding_aid_revision_description && data.finding_aid_revision_description.strip.start_with?('<')
            xml.text (fragments << data.finding_aid_revision_description)
          else
            xml.change {
              xml.date (fragments << data.finding_aid_revision_date) if data.finding_aid_revision_date
              xml.item (fragments << data.finding_aid_revision_description) if data.finding_aid_revision_description
            }
          end
        }
      end
    }
  end
end
