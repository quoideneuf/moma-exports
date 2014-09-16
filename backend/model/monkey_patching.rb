# This should be removed in versions 
# 1.0.10 and above. See: 
# https://github.com/archivesspace/archivesspace/issues/68

ASpaceExport::StreamHandler.class_eval do
  def stream_out(doc, fragments, y, depth=0)
    xml_text = doc.to_xml(:encoding => 'utf-8')
    return if xml_text.empty?
    xml_text.force_encoding('utf-8')
    queue = xml_text.split(":aspace_section")

    xml_string = fragments.substitute_fragments(queue.shift)
    raise "Undereferenced Fragment: #{xml_string}" if xml_string =~ /:aspace_fragment/
    y << xml_string

    while queue.length > 0
      next_section = queue.shift
      next_id = next_section.slice!(/^_(\w+)_/).gsub(/_/, '')
      next_fragments = ASpaceExport::RawXMLHandler.new
      doc_frag = Nokogiri::XML::DocumentFragment.parse ""
      Nokogiri::XML::Builder.with(doc_frag) do |xml|
        @sections[next_id].call(xml, next_fragments)
      end
      stream_out(doc_frag, next_fragments, y, depth + 1)

      if next_section && !next_section.empty?
        y << fragments.substitute_fragments(next_section)
      end
    end
  end
end
