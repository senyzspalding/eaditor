<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ead="urn:isbn:1-931666-22-9" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:arch="http://purl.org/archival/vocab/arch#" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xhv="http://www.w3.org/1999/xhtml/vocab#" xmlns:xml="http://www.w3.org/XML/1998/namespace" xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
	exclude-result-prefixes="mods ead xlink" version="2.0">

	<!-- url params -->
	<xsl:param name="path" select="substring-before(substring-after(doc('input:request')/request/request-url, 'id/'), '.rdf')"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	
	<xsl:template match="/">
		<xsl:apply-templates select="/content/*[not(local-name()='config')]"/>
	</xsl:template>

	<xsl:template match="mods:mods|ead:ead">
		<rdf:RDF>
			<xsl:choose>
				<xsl:when test="namespace-uri()='http://www.loc.gov/mods/v3'">
					<xsl:call-template name="mods-content"/>
				</xsl:when>
				<xsl:when test="namespace-uri()='urn:isbn:1-931666-22-9'">
					<xsl:call-template name="ead-content"/>
				</xsl:when>
			</xsl:choose>
		</rdf:RDF>
	</xsl:template>

	<!-- ***************** EAD-TO-RDF ******************-->
	<xsl:template name="ead-content">
		<arch:Collection rdf:about="{$url}id/{$path}">
			<!-- title, creator, abstract, etc. -->
			<xsl:choose>
				<!-- apply templates for immediate did if the child is a component-->
				<xsl:when test="child::ead:c">
					<xsl:apply-templates select="ead:c/ead:did"/>
				</xsl:when>
				<!-- otherwise apply template only to the archdesc/did-->
				<xsl:otherwise>
					<xsl:apply-templates select="ead:archdesc/ead:did"/>
				</xsl:otherwise>
			</xsl:choose>
			
			
			<!-- controlled vocabulary -->
			<xsl:apply-templates select="descendant::ead:subject[@authfilenumber]|descendant::ead:genreform[@authfilenumber]|descendant::ead:geogname[@authfilenumber]|descendant::ead:corpname[@authfilenumber]|descendant::ead:persname[@authfilenumber]"/>
		</arch:Collection>
	</xsl:template>
	
	<xsl:template match="ead:did">
		<xsl:apply-templates select="ead:unittitle|ead:unitid|ead:origination|ead:abstract|ead:extent"/>
	</xsl:template>
	
	<xsl:template match="ead:subject|ead:genreform|ead:origination|ead:geogname">
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="local-name()='subject'">dcterms:subject</xsl:when>
				<xsl:when test="local-name()='genreform'">dcterms:format</xsl:when>
				<xsl:when test="local-name()='persname'">arch:correspondedWith</xsl:when>
				<xsl:when test="local-name()='geogname'">dcterms:coverage</xsl:when>
				<xsl:when test="local-name()='corpname'">dcterms:coverage</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="resource">
			<xsl:choose>
				<xsl:when test="@source='geonames'">
					<xsl:value-of select="concat('http://www.geonames.org/', @authfilenumber)"/>					
				</xsl:when>
				<xsl:when test="@source='pleiades'">
					<xsl:value-of select="concat('http://pleiades.stoa.org/places/', @authfilenumber)"/>					
				</xsl:when>
				<xsl:when test="@source='lcsh' or @source='lcgft'">
					<xsl:value-of select="concat('http://id.loc.gov/authorities/', @authfilenumber)"/>					
				</xsl:when>				
				<xsl:when test="@source='viaf'">
					<xsl:value-of select="concat('http://viaf.org/viaf/', @authfilenumber)"/>					
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="string($resource)">
			<xsl:element name="{$element}">
				<xsl:attribute name="rdf:resource" select="$resource"/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="ead:abstract|ead:extent|ead:origination|ead:unitid|ead:unittitle">
		<xsl:variable name="element">
			<xsl:choose>
				<xsl:when test="local-name()='origination'">dcterms:creator</xsl:when>
				<xsl:when test="local-name()='unitid'">dcterms:identifier</xsl:when>
				<xsl:when test="local-name()='unittitle'">dcterms:title</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('dcterms:', local-name())"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:element name="{$element}">
			<xsl:value-of select="."/>
		</xsl:element>		
	</xsl:template>
	
	<!-- ***************** MODS-TO-RDF ******************-->
	<xsl:template name="mods-content"/>

</xsl:stylesheet>