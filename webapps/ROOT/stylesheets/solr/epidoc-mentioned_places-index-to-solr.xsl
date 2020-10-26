<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of mentioned places in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:div[@type='edition']//tei:placeName" group-by="concat(@ref,'-',normalize-unicode(@nymRef,'NFD'),'-',@type)">
        <xsl:variable name="ref-id" select="normalize-unicode(substring-after(@ref, '#'),'NFD')"/>
        <xsl:variable name="ref" select="document('../../content/xml/authority/places.xml')//tei:place[@xml:id=$ref-id]"/>
        <xsl:variable name="nymRef-id" select="normalize-unicode(substring-after(@nymRef, '#'),'NFD')"/>
        <xsl:variable name="nymRef" select="document('../../content/xml/authority/places.xml')//tei:place//tei:placeName[.=$nymRef-id]"/>
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:choose>
              <xsl:when test="$ref">
                <xsl:choose>
                  <xsl:when test="$ref//tei:placeName[@xml:lang='en']"><xsl:value-of select="$ref//tei:placeName[@xml:lang='en'][1]" /></xsl:when>
                  <xsl:when test="$ref//tei:placeName[@xml:lang='la']"><xsl:value-of select="$ref//tei:placeName[@xml:lang='la'][1]" /></xsl:when>
                  <xsl:otherwise><xsl:value-of select="$ref//tei:placeName[1]" /></xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$ref-id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_item_sort_name">
            <xsl:choose>
              <xsl:when test="$nymRef">
                <xsl:value-of select="$nymRef" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$nymRef-id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_ethnic">
            <xsl:choose>
              <xsl:when test="@type='ethnic'">
                <xsl:text>Ethnic</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>Toponym</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_external_resource">
            <xsl:value-of select="$ref/tei:idno" />
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:placeName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
