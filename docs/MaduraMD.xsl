<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright 2010 Prometheus Consulting
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
    http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output
		method="text"
		omit-xml-declaration="yes"
		indent="no"/>
	<xsl:strip-space elements="*"/>
	<xsl:param name="Year">2007</xsl:param>
	<xsl:param name="ProductVersion">1.1.1</xsl:param>
	<xsl:param name="Build">Build 1234</xsl:param>
	<xsl:param name="Company">xyz Ltd</xsl:param>
	<xsl:key name="references" match="reference" use="@t" />
	<xsl:key name="sections" match="a1|a2|a3|a4|a5|h1|h2|h3|h4|h5" use="@t" />
	<xsl:key name="figures" match="img" use="text()" />
	<xsl:key name="tables" match="table[string-length(@t) &gt; 0]" use="@t" />
	<xsl:template match="/">
		<xsl:processing-instruction name="xml-stylesheet">
			type="text/css" href="#css"
		</xsl:processing-instruction>
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="doc">
				<xsl:apply-templates select="title" />
				<xsl:apply-templates select="body" />
	</xsl:template>

	<xsl:template match="process-references">
		<a>
	 		<xsl:attribute name="name">
	 	        	<xsl:text>reference.References</xsl:text>
			</xsl:attribute>
		<h1>
			<xsl:number format="1." level="any" from="/" count="h1|process-references|process-log"/>
			<xsl:text> </xsl:text>
			<xsl:text>References</xsl:text>
		</h1>
		</a>
		<xsl:apply-templates select="/doc/title/references" />
	</xsl:template>

	<xsl:template match="title">
#<xsl:value-of select="MainTitle" />#
	</xsl:template>

	<xsl:template match="body">
		<xsl:for-each select="h1[1]">
         			<xsl:apply-templates />
 		</xsl:for-each>		
	</xsl:template>

	<xsl:template match="h1">
		<!--<xsl:text>&#xa;</xsl:text>##<xsl:value-of select="@t" />##-->
		<xsl:apply-templates />
	</xsl:template>


	<xsl:template match="h2">
		<xsl:text>&#xa;</xsl:text><xsl:text>&#xd;</xsl:text>##<xsl:value-of select="@t" />##
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="h3">
		<xsl:text>&#xa;</xsl:text><xsl:text>&#xd;</xsl:text>###<xsl:value-of select="@t" />###
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="h4">
		<xsl:text>&#xa;</xsl:text><xsl:text>&#xd;</xsl:text>####<xsl:value-of select="@t" />####
		<xsl:apply-templates />
	</xsl:template>


	<xsl:template match="list">
<xsl:text>&#xa;</xsl:text><xsl:apply-templates />
	</xsl:template>
	<xsl:template match="le">
 * <xsl:apply-templates />
	</xsl:template>
	<xsl:template match="p">
<xsl:text>&#xa;</xsl:text><xsl:text>&#xa;</xsl:text><xsl:apply-templates />
	</xsl:template>
	<xsl:template match="emph">
	<xsl:value-of select="concat(' *',text(),'* ')" />
	</xsl:template>
	<xsl:template match="bold">
	<xsl:value-of select="concat(' **',text(),'** ')" />
	</xsl:template>
	<xsl:template match="courier">
	<xsl:value-of select="concat(' `',text(),'` ')" />
	</xsl:template>
	<xsl:template match="comment">
	</xsl:template>
	<xsl:template match="rant">
	</xsl:template>
	<xsl:template match="note">
	</xsl:template>
	<xsl:template match="warning">
	</xsl:template>
	<xsl:template match="Year">
	   <xsl:value-of select="$Year"/>
	</xsl:template>
	<xsl:template match="ProductVersion">
	   <xsl:value-of select="$ProductVersion"/>
	</xsl:template>

	<xsl:template match="references">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="reference">
		<p>
			<xsl:number format="[1]" level="any" from="/"
				count="reference" />
			<xsl:text> </xsl:text>
				<a>
					<xsl:if test="string-length(@url) &gt; 0">
					<xsl:attribute name="href">
		            		<xsl:value-of select="@url" />
		            	</xsl:attribute>
					</xsl:if>
					<xsl:value-of select="@t" />
				</a>
		</p>
	</xsl:template>

      <xsl:template match="referenceLink">
          	<xsl:call-template name="referenceLinkRef">
            		<xsl:with-param name="content" select="@t"/>
            	</xsl:call-template>
       </xsl:template>
        
         <xsl:template name="referenceLinkRef">
          	<xsl:param name="content">2007</xsl:param>
          	<xsl:for-each select="key('references',$content)">
            	<xsl:if test="string-length(@url) &gt; 0">
				<xsl:value-of select="concat('[',$content,']')" /><xsl:value-of select="concat('(',@url,')')" />
		</xsl:if>
            	<xsl:if test="string-length(@url) &lt;= 0">
				<xsl:value-of select="concat('[',$content,']')" />
		</xsl:if>
		<xsl:text> </xsl:text>
		</xsl:for-each>
          </xsl:template>

	<xsl:template match="img">
		![<xsl:value-of select="text()"/>](docs/<xsl:value-of select="@href"/>)
	</xsl:template>
	<xsl:template match="code">
		<xsl:text>&#xa;</xsl:text><xsl:text>&#xd;</xsl:text><xsl:value-of select="concat('```',text(),'&#xa;```')" />
	</xsl:template>


  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(translate(.,'&#xA;',''))"/>
  </xsl:template>
</xsl:stylesheet>
