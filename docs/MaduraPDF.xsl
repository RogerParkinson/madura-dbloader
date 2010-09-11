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

	<!-- implement footnotes -->
      <xsl:stylesheet version="2.0" 
      	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
		xmlns:fox="http://xml.apache.org/fop/extensions"
		xmlns:svg="http://www.w3.org/2000/svg"
      	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
		<xsl:param name="debug">true</xsl:param>
         <xsl:include href="style.xsl"/>
         <xsl:key name="references" match="reference" use="@t"/>
         <xsl:key name="sections" match="a1|a2|a3|a4|a5|h1|h2|h3|h4|h5" use="@t"/>
         <xsl:key name="figures" match="img" use="text()"/>
		<xsl:key name="tables" match="table[string-length(@t) &gt; 0]" use="@t" />
         <xsl:template match="/">
            <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
               <fo:layout-master-set>
                  <xsl:call-template name="PageMasterPortrait"/>
               </fo:layout-master-set>
		         <xsl:comment>
		         	this is a comment
		         </xsl:comment>
 		  <fo:declarations>
			<x:xmpmeta xmlns:x="adobe:ns:meta/">
			    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
			      <rdf:Description rdf:about=""
			          xmlns:dc="http://purl.org/dc/elements/1.1/">
			        <dc:title><xsl:value-of select="/doc/title/MainTitle"/></dc:title>
			        <dc:creator><xsl:value-of select="/doc/title/Author"/></dc:creator>
			        <dc:description><xsl:value-of select="/doc/title/SubTitle"/></dc:description>
			      </rdf:Description>
			      <rdf:Description rdf:about=""
			          xmlns:xmp="http://ns.adobe.com/xap/1.0/">
			        <xmp:CreatorTool>MaduraDocs</xmp:CreatorTool>
			      </rdf:Description>
			    </rdf:RDF>
			  </x:xmpmeta>
			</fo:declarations>
		    <fo:bookmark-tree >
				       <xsl:apply-templates select="/doc/body/a1|/doc/body/h1|/doc/body/process-log|/doc/body/process-references|/doc/body/process-reviewers" mode="bookmark"/>
			</fo:bookmark-tree>	         
               <xsl:apply-templates select="doc/title"/>
               <fo:page-sequence master-reference="oddEven">
                  <fo:static-content flow-name="folio">
                     <xsl:call-template name="PageFooter"/>
                  </fo:static-content>
                  <fo:flow flow-name="text">
                     <xsl:apply-templates select="doc/body"/>
                  </fo:flow>
               </fo:page-sequence>
            </fo:root>
         </xsl:template>

		<xsl:template match="title">
		  <!-- Title Page -->
		  
		  <fo:page-sequence master-reference="oddEven" force-page-count="even" format="(1)">
              <fo:static-content flow-name="folio">
                 <xsl:call-template name="FirstPageFooter"/>
              </fo:static-content>
		    <fo:flow flow-name="text">
			<xsl:call-template name="FirstPage"/>
		    </fo:flow>
		  </fo:page-sequence>
		  <!-- Table of Contents -->
		  <xsl:if test="count(/doc/body/h1) &gt; 0">
			  <fo:page-sequence master-reference="oddEven" force-page-count="even" format="(1)">
	              <fo:static-content flow-name="folio">
	                 <xsl:call-template name="PageFooter"/>
	              </fo:static-content>
			    <fo:flow flow-name="text">
			      <fo:block xsl:use-attribute-sets="H1">Table of Contents</fo:block>
			      <xsl:apply-templates select="/doc/body/a1|/doc/body/h1|/doc/body/process-log|/doc/body/process-references|/doc/body/process-reviewers" mode="toc"/>
			    </fo:flow>
			  </fo:page-sequence>
		  </xsl:if>
		</xsl:template>
		
        <xsl:template name="landscapeON">
            <xsl:text disable-output-escaping="yes"><![CDATA[
            </fo:flow></fo:page-sequence>
          <fo:page-sequence master-reference="landscape">
            ]]></xsl:text>
             <fo:static-content flow-name="folio">
                <xsl:call-template name="PageFooter"/><!-- set up the page footer for landscape -->
             </fo:static-content>
            <xsl:text disable-output-escaping="yes"><![CDATA[
            <fo:flow flow-name="text">
            ]]></xsl:text>
        </xsl:template>
        
        <xsl:template name="landscapeOFF">
        	<xsl:param name="end">true</xsl:param>
          <xsl:text disable-output-escaping="yes">><![CDATA[
            </fo:flow>
          </fo:page-sequence>
           <fo:page-sequence master-reference="oddEven">
           ]]></xsl:text>
                  <fo:static-content flow-name="folio">
                     <xsl:call-template name="PageFooter"/> <!-- this sets up the page footer again for the new portrait flow-->
                  </fo:static-content>
           <xsl:text disable-output-escaping="yes"><![CDATA[
                  <fo:flow flow-name="text">
          ]]></xsl:text>
			<xsl:if test="$end">
                  <fo:block>
                  <xsl:text> </xsl:text>
                  </fo:block>
			</xsl:if>
        </xsl:template>

		<xsl:template match="process-log">
			<fo:block break-before='page'/>
            <fo:block xsl:use-attribute-sets="H1">
            	<xsl:attribute name="id">
            		<xsl:text>ChangeLog.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="h1x"/>
				<xsl:text>Change Log</xsl:text>
            </fo:block>
            <xsl:apply-templates select="/doc/title/log"/>
		</xsl:template>
 
		<xsl:template match="process-references">
			<fo:block break-before='page'/>
            <fo:block xsl:use-attribute-sets="H1">
            	<xsl:attribute name="id">
            		<xsl:text>References.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="h1x"/>
				<xsl:text>References</xsl:text>
            </fo:block>
            <xsl:apply-templates select="/doc/title/references"/>
		</xsl:template>

		<xsl:template match="process-reviewers">
			<fo:block break-before='page'/>
            <fo:block xsl:use-attribute-sets="H1">
            	<xsl:attribute name="id">
            		<xsl:text>Reviewers.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="h1x"/>
				<xsl:text>Reviewers</xsl:text>
            </fo:block>
            <xsl:apply-templates select="/doc/title/reviewers"/>
		</xsl:template>

		<!-- just dumps the log. Needs to do more about formatting the log, though -->		
        <xsl:template match="log">
        	<xsl:choose>
        	<xsl:when test="count(logentry) &gt; 0">
         	<fo:table table-layout="fixed" border-style="solid" border-width="1pt">
	         	<fo:table-column column-width="4cm"/>
	         	<fo:table-column column-width="2.2cm"/>
	         	<fo:table-column column-width="10cm"/>
				<fo:table-body>
					<fo:table-row>
					<fo:table-cell xsl:use-attribute-sets="cell-padding">
						<fo:block xsl:use-attribute-sets="th">
	         			<xsl:text>Author</xsl:text>
	         			</fo:block>
	         		</fo:table-cell>
					<fo:table-cell xsl:use-attribute-sets="cell-padding">
						<fo:block xsl:use-attribute-sets="th">
	         			<xsl:text>Date</xsl:text>
	         			</fo:block>
	         		</fo:table-cell>
					<fo:table-cell xsl:use-attribute-sets="cell-padding">
						<fo:block xsl:use-attribute-sets="th">
	         			<xsl:text>Comment</xsl:text>
	         			</fo:block>
	         		</fo:table-cell>
	         		</fo:table-row>
	         		<xsl:apply-templates/>
				</fo:table-body>
			</fo:table>
        	</xsl:when>
        	<xsl:otherwise>
	            <fo:block xsl:use-attribute-sets="normal" white-space-collapse="false" linefeed-treatment="preserve"  >
	 			<xsl:value-of select="substring-after(text(),'v $')"/>
	            </fo:block>
        	</xsl:otherwise>	
        	</xsl:choose>
         </xsl:template>
         <xsl:template match="logentry">
        	<xsl:choose>
        	<xsl:when test="string-length(msg) &gt; 0">
			<fo:table-row>
				<fo:table-cell xsl:use-attribute-sets="cell-padding">
					<fo:block xsl:use-attribute-sets="normal">
						<xsl:value-of select="author"/>
	         		</fo:block>
				</fo:table-cell>
				<fo:table-cell xsl:use-attribute-sets="cell-padding">
					<fo:block xsl:use-attribute-sets="normal">
	         			<xsl:value-of select="substring(date,1,10)"/>
	         		</fo:block>
				</fo:table-cell>
				<fo:table-cell xsl:use-attribute-sets="cell-padding">
					<fo:block xsl:use-attribute-sets="normal">
	         			<xsl:value-of select="msg"/>
	         		</fo:block>
				</fo:table-cell>
			</fo:table-row>
			</xsl:when>
			</xsl:choose>
         </xsl:template>

         <xsl:template match="references">
 			<xsl:apply-templates select="reference"/>
         </xsl:template>

         <xsl:template match="reference">
            <fo:block  xsl:use-attribute-sets="normal">
            	<xsl:attribute name="id">
            		<xsl:value-of select="@t"/>
            		<xsl:text>.reference-description</xsl:text>
            	</xsl:attribute>
				<xsl:number format="[1]" level="any" from="/" count="reference"/>
            	<xsl:text> </xsl:text>
            	<xsl:choose>
            	
            	<xsl:when test="string-length(@url) &gt; 0">
	            	<xsl:text> </xsl:text>
					<fo:basic-link color="blue" text-decoration="underline">
		            	<xsl:attribute name="external-destination">
		            		<xsl:text>url(</xsl:text>
		            		<xsl:value-of select="@url"/>
		            		<xsl:text>)</xsl:text>
		            	</xsl:attribute>
					<xsl:value-of select="@t"/>
					</fo:basic-link>
            	</xsl:when>
            	<xsl:otherwise>
            	<xsl:value-of select="@t"/>
            	</xsl:otherwise>
            	</xsl:choose>
            	
            </fo:block>
         </xsl:template>

         <xsl:template match="reviewers">
         	<fo:table table-layout="fixed" border-style="solid" border-width="1pt">
	         	<fo:table-column column-width="8.0cm"/>
	         	<fo:table-column column-width="8.0cm"/>
				<fo:table-body>
         			<xsl:apply-templates select="reviewer"/>
				</fo:table-body>
			</fo:table>
         </xsl:template>

         <xsl:template match="reviewer">
			<fo:table-row>
				<fo:table-cell xsl:use-attribute-sets="cell-padding">
					<fo:block xsl:use-attribute-sets="normal">
						<xsl:value-of select="@fullName"/>
	         		</fo:block>
				</fo:table-cell>
				<fo:table-cell xsl:use-attribute-sets="cell-padding">
					<fo:block xsl:use-attribute-sets="normal">
	         			<xsl:value-of select="@email"/>
	         		</fo:block>
				</fo:table-cell>
			</fo:table-row>
         </xsl:template>

         <xsl:template match="document">
            <fo:block>doc</fo:block>
            <xsl:apply-templates/>
         </xsl:template>

         <xsl:template match="img">
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeON"/>
         	</xsl:if>
         <fo:block keep-together.within-page="always" space-before="1em" space-after="1em">
         	<fo:external-graphic 
         		xsl:use-attribute-sets="graphic"
         		border-style="solid" 
				border-color="black" 
				border-width="0.25mm"
				scaling="uniform" 
				scaling-method="resample-any-method" 
				content-width="scale-to-fit"
				height="100%">
         	<xsl:attribute name="src">
         		<xsl:text>url(</xsl:text>
         		<xsl:value-of select="@href"/>
         		<xsl:text>)</xsl:text>
         	</xsl:attribute>
         	<xsl:if test="string-length(@width) &gt; 0">
	         	<xsl:attribute name="content-width">
	         		<xsl:value-of select="@width"/>
	         	</xsl:attribute>
         	</xsl:if>
         	<xsl:if test="string-length(@height) &gt; 0">
	         	<xsl:attribute name="height">
	         		<xsl:value-of select="@height"/>
	         	</xsl:attribute>
         	</xsl:if>
         	</fo:external-graphic>
         	<fo:block xsl:use-attribute-sets="figure">
            	<xsl:attribute name="id">
            		<xsl:value-of select="text()"/>
            		<xsl:text>.figure-description</xsl:text>
            	</xsl:attribute>
            	<fo:inline>
            		<xsl:text>Figure </xsl:text>
            		<xsl:number level="any" from="/" count="img" format="(1)"/>
            		<xsl:text> </xsl:text>
            		<!--<xsl:value-of select="@href"/>-->
	               <xsl:value-of select="text()"/>
            	</fo:inline>
         	</fo:block>
     	</fo:block>
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeOFF">
         			<xsl:with-param name="end" select="@end"/>
         		</xsl:call-template>
         	</xsl:if>
         </xsl:template>
         
		<xsl:template match="h1" mode="toc">
			<fo:block xsl:use-attribute-sets="H1TOC" space-before="1em" text-align-last="justify" keep-together="always">
				<fo:basic-link>
	 	          	<xsl:attribute name="internal-destination">
	 	          		<xsl:value-of select="@t"/>
	            		<xsl:text>.property-description</xsl:text>
	            	</xsl:attribute>
					<xsl:call-template name="h1x"/>
					<xsl:value-of select="@t"/>
					<fo:leader leader-pattern="dots" leader-alignment="reference-area"/>
					<xsl:text> </xsl:text>
					<fo:page-number-citation>
						<xsl:attribute name="ref-id">
			        		<xsl:value-of select="@t"/>
			        		<xsl:text>.property-description</xsl:text>
	        			</xsl:attribute>
	        		</fo:page-number-citation>
				</fo:basic-link>
			</fo:block>
			<xsl:for-each select="h2">
				<fo:block  xsl:use-attribute-sets="H2TOC" space-before="0em" margin-left="1.5pc" text-align-last="justify" keep-together="always">
					<fo:basic-link>
		 	          	<xsl:attribute name="internal-destination">
		 	          		<xsl:value-of select="@t"/>
		            		<xsl:text>.property-description</xsl:text>
		            	</xsl:attribute>
						<xsl:call-template name="h2x"/>
						<xsl:value-of select="@t"/>
						<fo:leader leader-pattern="dots" leader-alignment="reference-area"/>
						<xsl:text> </xsl:text>
						<fo:page-number-citation>
							<xsl:attribute name="ref-id">
	        					<xsl:value-of select="@t"/>
	        					<xsl:text>.property-description</xsl:text>
	        				</xsl:attribute>
	        			</fo:page-number-citation>
					</fo:basic-link>
				</fo:block>
				<xsl:for-each select="h3">
					<fo:block  xsl:use-attribute-sets="H3TOC" space-before="0em" margin-left="3pc" text-align-last="justify" keep-together="always">
						<fo:basic-link>
			 	          	<xsl:attribute name="internal-destination">
			 	          		<xsl:value-of select="@t"/>
			            		<xsl:text>.property-description</xsl:text>
			            	</xsl:attribute>
							<xsl:call-template name="h3x"/>
							<xsl:value-of select="@t"/>
							<fo:leader leader-pattern="dots" leader-alignment="reference-area"/>
							<xsl:text> </xsl:text>
							<fo:page-number-citation>
								<xsl:attribute name="ref-id">
		        					<xsl:value-of select="@t"/>
		        					<xsl:text>.property-description</xsl:text>
		        				</xsl:attribute>
		        			</fo:page-number-citation>
						</fo:basic-link>
					</fo:block>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:template>
         
		<xsl:template match="a1" mode="toc">
			<fo:block xsl:use-attribute-sets="H1TOC" space-before="1em" text-align-last="justify" keep-together="always">
				<fo:basic-link>
	 	          	<xsl:attribute name="internal-destination">
	 	          		<xsl:value-of select="@t"/>
	            		<xsl:text>.property-description</xsl:text>
	            	</xsl:attribute>
					<xsl:call-template name="a1x"/>
					<xsl:value-of select="@t"/>
					<fo:leader leader-pattern="dots" leader-alignment="reference-area"/>
					<xsl:text> </xsl:text>
					<fo:page-number-citation>
						<xsl:attribute name="ref-id">
			        		<xsl:value-of select="@t"/>
			        		<xsl:text>.property-description</xsl:text>
	        			</xsl:attribute>
	        		</fo:page-number-citation>
				</fo:basic-link>
			</fo:block>
			<xsl:for-each select="a2">
				<fo:block  xsl:use-attribute-sets="H2TOC" space-before="0em" margin-left="1.5pc" text-align-last="justify" keep-together="always">
					<fo:basic-link>
		 	          	<xsl:attribute name="internal-destination">
		 	          		<xsl:value-of select="@t"/>
		            		<xsl:text>.property-description</xsl:text>
		            	</xsl:attribute>
						<xsl:call-template name="a2x"/>
						<xsl:value-of select="@t"/>
						<fo:leader leader-pattern="dots" leader-alignment="reference-area"/>
						<xsl:text> </xsl:text>
						<fo:page-number-citation>
							<xsl:attribute name="ref-id">
	        					<xsl:value-of select="@t"/>
	        					<xsl:text>.property-description</xsl:text>
	        				</xsl:attribute>
	        			</fo:page-number-citation>
					</fo:basic-link>
				</fo:block>
				<xsl:for-each select="a3">
					<fo:block  xsl:use-attribute-sets="H3TOC" space-before="0em" margin-left="3pc" text-align-last="justify" keep-together="always">
						<fo:basic-link>
			 	          	<xsl:attribute name="internal-destination">
			 	          		<xsl:value-of select="@t"/>
			            		<xsl:text>.property-description</xsl:text>
			            	</xsl:attribute>
							<xsl:call-template name="a3x"/>
							<xsl:value-of select="@t"/>
							<fo:leader leader-pattern="dots" leader-alignment="reference-area"/>
							<xsl:text> </xsl:text>
							<fo:page-number-citation>
								<xsl:attribute name="ref-id">
		        					<xsl:value-of select="@t"/>
		        					<xsl:text>.property-description</xsl:text>
		        				</xsl:attribute>
		        			</fo:page-number-citation>
						</fo:basic-link>
					</fo:block>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:template>
         
		<xsl:template match="h1" mode="bookmark">
            <fo:bookmark>
	           	<xsl:attribute name="internal-destination">
	           		<xsl:value-of select="@t"/>
	           		<xsl:text>.property-description</xsl:text>
	           	</xsl:attribute>
                <fo:bookmark-title>
					<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
	            	<xsl:text> </xsl:text>
	            	<xsl:value-of select="@t"/>
                </fo:bookmark-title>
				<xsl:for-each select="h2">
		           <fo:bookmark>
		           	<xsl:attribute name="internal-destination">
		           		<xsl:value-of select="@t"/>
		           		<xsl:text>.property-description</xsl:text>
		           	</xsl:attribute>
		               <fo:bookmark-title>
							<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
							<xsl:number format="1." level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
			            	<xsl:text> </xsl:text>
			            	<xsl:value-of select="@t"/>
		               </fo:bookmark-title>
					<xsl:for-each select="h3">
						<xsl:for-each select="h3">
				           <fo:bookmark>
				           	<xsl:attribute name="internal-destination">
				           		<xsl:value-of select="@t"/>
				           		<xsl:text>.property-description</xsl:text>
				           	</xsl:attribute>
				               <fo:bookmark-title>
									<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
									<xsl:number format="1." level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
									<xsl:number format="1." level="any" from="h2" count="h3"/>
					            	<xsl:text> </xsl:text>
					            	<xsl:value-of select="@t"/>
				               </fo:bookmark-title>
								<xsl:for-each select="h4">
						           <fo:bookmark>
						           	<xsl:attribute name="internal-destination">
						           		<xsl:value-of select="@t"/>
						           		<xsl:text>.property-description</xsl:text>
						           	</xsl:attribute>
						               <fo:bookmark-title>
											<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
											<xsl:number format="1." level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
											<xsl:number format="1." level="any" from="h2" count="h3"/>
											<xsl:number format="1." level="any" from="h3" count="h4"/>
											<xsl:number format="1." level="any" from="h4" count="h5"/>
							            	<xsl:text> </xsl:text>
							            	<xsl:value-of select="@t"/>
						               </fo:bookmark-title>
						           </fo:bookmark>
								</xsl:for-each>
				           </fo:bookmark>
						</xsl:for-each>
					</xsl:for-each>
		           </fo:bookmark>
				</xsl:for-each>
            </fo:bookmark>
		</xsl:template>
		<xsl:template match="a1" mode="bookmark">
            <fo:bookmark>
	           	<xsl:attribute name="internal-destination">
	           		<xsl:value-of select="@t"/>
	           		<xsl:text>.property-description</xsl:text>
	           	</xsl:attribute>
                <fo:bookmark-title>
					<xsl:number format="A." level="any" from="/" count="a1"/>
	            	<xsl:text> </xsl:text>
	            	<xsl:value-of select="@t"/>
                </fo:bookmark-title>
				<xsl:for-each select="a2">
		           <fo:bookmark>
		           	<xsl:attribute name="internal-destination">
		           		<xsl:value-of select="@t"/>
		           		<xsl:text>.property-description</xsl:text>
		           	</xsl:attribute>
		               <fo:bookmark-title>
							<xsl:number format="A." level="any" from="/" count="a1"/>
							<xsl:number format="1." level="any" from="a1" count="a2"/>
			            	<xsl:text> </xsl:text>
			            	<xsl:value-of select="@t"/>
		               </fo:bookmark-title>
						<xsl:for-each select="a3">
				           <fo:bookmark>
				           	<xsl:attribute name="internal-destination">
				           		<xsl:value-of select="@t"/>
				           		<xsl:text>.property-description</xsl:text>
				           	</xsl:attribute>
				               <fo:bookmark-title>
									<xsl:number format="A." level="any" from="/" count="a1"/>
									<xsl:number format="1." level="any" from="a1" count="a2"/>
									<xsl:number format="1." level="any" from="a2" count="a3"/>
					            	<xsl:text> </xsl:text>
					            	<xsl:value-of select="@t"/>
				               </fo:bookmark-title>
								<xsl:for-each select="a4">
						           <fo:bookmark>
						           	<xsl:attribute name="internal-destination">
						           		<xsl:value-of select="@t"/>
						           		<xsl:text>.property-description</xsl:text>
						           	</xsl:attribute>
						               <fo:bookmark-title>
											<xsl:number format="A." level="any" from="/" count="a1"/>
											<xsl:number format="1." level="any" from="a1" count="a2"/>
											<xsl:number format="1." level="any" from="a2" count="a3"/>
											<xsl:number format="1." level="any" from="a3" count="a4"/>
											<xsl:number format="1." level="any" from="a4" count="a5"/>
							            	<xsl:text> </xsl:text>
							            	<xsl:value-of select="@t"/>
						               </fo:bookmark-title>
						           </fo:bookmark>
								</xsl:for-each>
				           </fo:bookmark>
					</xsl:for-each>
		           </fo:bookmark>
				</xsl:for-each>
            </fo:bookmark>
		</xsl:template>
<!-- 
			<fox:outline>
            	<xsl:attribute name="internal-destination">
            		<xsl:value-of select="@t"/>
            		<xsl:text>.property-description</xsl:text>
            	</xsl:attribute>
            	<fox:label>
						<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
		            	<xsl:text> </xsl:text>
		            	<xsl:value-of select="@t"/>
            	</fox:label>
				<xsl:for-each select="h2">
					<fox:outline>
		            	<xsl:attribute name="internal-destination">
		            		<xsl:value-of select="@t"/>
		            		<xsl:text>.property-description</xsl:text>
		            	</xsl:attribute>
		            	<fox:label>
							<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
							<xsl:number format="1." level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
			            	<xsl:text> </xsl:text>
			            	<xsl:value-of select="@t"/>
		            	</fox:label>
						<xsl:for-each select="h3">
							<fox:outline>
				            	<xsl:attribute name="internal-destination">
				            		<xsl:value-of select="@t"/>
				            		<xsl:text>.property-description</xsl:text>
				            	</xsl:attribute>
				            	<fox:label>
									<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
									<xsl:number format="1." level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
									<xsl:number format="1." level="any" from="h2" count="h3"/>
					            	<xsl:text> </xsl:text>
					            	<xsl:value-of select="@t"/>
				            	</fox:label>
						    </fox:outline>
						</xsl:for-each>
				    </fox:outline>
				</xsl:for-each>
		    </fox:outline>
         </xsl:template>
 -->         
		<xsl:template match="process-reviewers" mode="toc">
			<fo:block  xsl:use-attribute-sets="H1TOC" space-before="1em" text-align-last="justify" keep-together="always">
				<fo:basic-link>
	 	          	<xsl:attribute name="internal-destination">
	            		<xsl:text>Reviewers.property-description</xsl:text>
	            	</xsl:attribute>
					<xsl:call-template name="h1x"/>
					<xsl:text>Reviewers</xsl:text>
					<fo:leader leader-pattern="dots" leader-alignment="reference-area"/>
					<xsl:text> </xsl:text>
					<fo:page-number-citation>
						<xsl:attribute name="ref-id">
			        		<xsl:text>Reviewers.property-description</xsl:text>
	        			</xsl:attribute>
	        		</fo:page-number-citation>
				</fo:basic-link>
			</fo:block>
		</xsl:template>
		
		<xsl:template match="process-reviewers" mode="bookmark">
            <fo:bookmark>
	           	<xsl:attribute name="internal-destination">
	           		<xsl:text>Reviewers.property-description</xsl:text>
	           	</xsl:attribute>
                <fo:bookmark-title>
					<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
	            	<xsl:text> </xsl:text>
	            	<xsl:text>Reviewers</xsl:text>
                </fo:bookmark-title>
            </fo:bookmark>
<!--             
			<fox:outline>
            	<xsl:attribute name="internal-destination">
            		<xsl:text>Reviewers.property-description</xsl:text>
            	</xsl:attribute>
            	<fox:label>
						<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
						<xsl:text> </xsl:text>
		            	<xsl:text>Reviewers</xsl:text>
            	</fox:label>
		    </fox:outline>
 -->
          </xsl:template>
         
		<xsl:template match="process-log" mode="toc">
			<fo:block  xsl:use-attribute-sets="H1TOC" space-before="1em" text-align-last="justify" keep-together="always">
				<fo:basic-link>
	 	          	<xsl:attribute name="internal-destination">
	            		<xsl:text>ChangeLog.property-description</xsl:text>
	            	</xsl:attribute>
					<xsl:call-template name="h1x"/>
					<xsl:text>Change Log</xsl:text>
					<fo:leader leader-pattern="dots" leader-alignment="reference-area"/>
					<xsl:text> </xsl:text>
					<fo:page-number-citation>
						<xsl:attribute name="ref-id">
			        		<xsl:text>ChangeLog.property-description</xsl:text>
	        			</xsl:attribute>
	        		</fo:page-number-citation>
				</fo:basic-link>
			</fo:block>
		</xsl:template>
		
		<xsl:template match="process-log" mode="bookmark">
            <fo:bookmark>
	           	<xsl:attribute name="internal-destination">
	           		<xsl:text>ChangeLog.property-description</xsl:text>
	           	</xsl:attribute>
                <fo:bookmark-title>
					<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
	            	<xsl:text> </xsl:text>
	            	<xsl:text>Change Log</xsl:text>
                </fo:bookmark-title>
            </fo:bookmark>
<!--             
			<fox:outline>
            	<xsl:attribute name="internal-destination">
            		<xsl:text>ChangeLog.property-description</xsl:text>
            	</xsl:attribute>
            	<fox:label>
						<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
						<xsl:text> </xsl:text>
		            	<xsl:text>Change Log</xsl:text>
            	</fox:label>
		    </fox:outline>
-->
         </xsl:template>
         
		<xsl:template match="process-references" mode="toc">
			<fo:block  xsl:use-attribute-sets="H1TOC" space-before="1em" text-align-last="justify" keep-together="always">
				<fo:basic-link>
	 	          	<xsl:attribute name="internal-destination">
	            		<xsl:text>References.property-description</xsl:text>
	            	</xsl:attribute>
					<xsl:call-template name="h1x"/>
					<xsl:text>References</xsl:text>
					<fo:leader leader-pattern="dots" leader-alignment="reference-area"/>
					<xsl:text> </xsl:text>
					<fo:page-number-citation>
						<xsl:attribute name="ref-id">
			        		<xsl:text>References.property-description</xsl:text>
	        			</xsl:attribute>
	        		</fo:page-number-citation>
				</fo:basic-link>
			</fo:block>
		</xsl:template>
 		
		<xsl:template match="process-references" mode="bookmark">
            <fo:bookmark>
	           	<xsl:attribute name="internal-destination">
	           		<xsl:text>References.property-description</xsl:text>
	           	</xsl:attribute>
                <fo:bookmark-title>
					<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
	            	<xsl:text> </xsl:text>
	            	<xsl:text>References</xsl:text>
                </fo:bookmark-title>
            </fo:bookmark>
<!--             
			<fox:outline>
            	<xsl:attribute name="internal-destination">
            		<xsl:text>References.property-description</xsl:text>
            	</xsl:attribute>
            	<fox:label>
						<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
						<xsl:text> </xsl:text>
		            	<xsl:text>References</xsl:text>
            	</fox:label>
		    </fox:outline>
 -->
         </xsl:template>
         
         <xsl:template match="list">
			<fo:table table-layout="fixed" width="100%">
				<xsl:choose>
					<xsl:when test="count(ll) &gt; 0">
			         	<fo:table-column column-width="4cm"/>
			         	<fo:table-column column-width="10cm"/>
					</xsl:when>
					<xsl:otherwise>
			         	<fo:table-column column-width="0.7cm"/>
			         	<fo:table-column column-width="14cm"/>
					</xsl:otherwise>
				</xsl:choose>
	         	<fo:table-column column-width="0.7cm"/>
	         	<fo:table-column column-width="14cm"/>
				<fo:table-body>
         			<xsl:apply-templates select="le|ln|ll|lx"/>
				</fo:table-body>
			</fo:table>
		 </xsl:template>
		 
         <xsl:template match="le">
			<fo:table-row>
				<fo:table-cell>
					<fo:block xsl:use-attribute-sets="normal">
						<fo:character character="&#8226;"/>
	         			<!--<fo:character character="o"/><xsl:text>o</xsl:text>-->
	         		</fo:block>
				</fo:table-cell>
				<fo:table-cell>
					<fo:block xsl:use-attribute-sets="normal">
	         			<xsl:apply-templates/>
	         		</fo:block>
				</fo:table-cell>
			</fo:table-row>
		 </xsl:template>
         <xsl:template match="ln">
			<fo:table-row>
				<fo:table-cell>
					<fo:block xsl:use-attribute-sets="normal">
				      <fo:block><xsl:number format="1." level="any" from="list" count="ln"/></fo:block>
	         		</fo:block>
				</fo:table-cell>
				<fo:table-cell>
					<fo:block xsl:use-attribute-sets="normal">
	         			<xsl:apply-templates/>
	         		</fo:block>
				</fo:table-cell>
			</fo:table-row>
		 </xsl:template>
         <xsl:template match="ll">
			<fo:table-row>
				<fo:table-cell>
					<fo:block xsl:use-attribute-sets="bold">
			      	<xsl:value-of select="@name"/>
	         		</fo:block>
				</fo:table-cell>
				<fo:table-cell>
					<fo:block xsl:use-attribute-sets="normal">
	         			<xsl:apply-templates/>
	         		</fo:block>
				</fo:table-cell>
			</fo:table-row>
		 </xsl:template>

         <xsl:template match="table">
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeON"/>
         	</xsl:if>
			<fo:table table-layout="fixed" width="100%">
         		<xsl:apply-templates select="tw"/>
				<fo:table-body>
         			<xsl:apply-templates select="tr"/>
				</fo:table-body>
			</fo:table>
			<xsl:if test="string-length(@t) &gt; 0">
	         	<fo:block xsl:use-attribute-sets="figure">
	            	<xsl:attribute name="id">
	            		<xsl:value-of select="@t"/>
	            		<xsl:text>.table-description</xsl:text>
	            	</xsl:attribute>
	            	<fo:inline>
	            		<xsl:text>Table </xsl:text>
	            		<xsl:number level="any" from="/" count="table[string-length(@t) &gt; 0]" format="(1)"/>
	            		<xsl:text> </xsl:text>
		               <xsl:value-of select="@t"/>
	            	</fo:inline>
	         	</fo:block>
			</xsl:if>
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeOFF">
         			<xsl:with-param name="end" select="@end"/>
         		</xsl:call-template>
         	</xsl:if>
         </xsl:template>
         
         <xsl:template match="tw">
         	<fo:table-column>
            	<xsl:attribute name="column-width">
            		<xsl:value-of select="text()"/>
            	</xsl:attribute>
         	</fo:table-column>
         </xsl:template>

         <xsl:template match="tr">
			<fo:table-row>
         		<xsl:apply-templates select="td|th"/>
			</fo:table-row>
         </xsl:template>
         
         <xsl:template match="td">
			<fo:table-cell xsl:use-attribute-sets="cell-padding">
				<fo:block xsl:use-attribute-sets="normal">
         			<xsl:apply-templates/>
         		</fo:block>
			</fo:table-cell>
         </xsl:template>
         
         <xsl:template match="th">
			<fo:table-cell xsl:use-attribute-sets="cell-padding">
				<fo:block xsl:use-attribute-sets="th">
         			<xsl:apply-templates/>
         		</fo:block>
			</fo:table-cell>
         </xsl:template>
         
         <xsl:template match="h1">
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeON"/>
         	</xsl:if>
			<fo:block break-before='page'/>
            <fo:block xsl:use-attribute-sets="H1" keep-together.within-page="always">
            	<xsl:attribute name="id">
            		<xsl:value-of select="@t"/>
            		<xsl:text>.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="h1x"/>
				<xsl:value-of select="@t"/>
            </fo:block>
			<xsl:apply-templates/>
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeOFF">
         			<xsl:with-param name="end" select="@end"/>
         		</xsl:call-template>
         	</xsl:if>
         </xsl:template>
         
         <xsl:template match="a1">
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeON"/>
         	</xsl:if>
			<fo:block break-before='page'/>
            <fo:block xsl:use-attribute-sets="H1" keep-together.within-page="always">
            	<xsl:attribute name="id">
            		<xsl:value-of select="@t"/>
            		<xsl:text>.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="a1x"/>
				<xsl:value-of select="@t"/>
            </fo:block>
			<xsl:apply-templates/>
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeOFF">
         			<xsl:with-param name="end" select="@end"/>
         		</xsl:call-template>
         	</xsl:if>
         </xsl:template>
         
		<xsl:template name="h1x">
			<fo:inline>
				<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
            	<xsl:text> </xsl:text>
			</fo:inline>
		</xsl:template>

		<xsl:template name="a1x">
			<fo:inline>
				<xsl:number format="A." level="any" from="/" count="a1"/>
            	<xsl:text> </xsl:text>
			</fo:inline>
		</xsl:template>

         <xsl:template match="h2">
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeON"/>
         	</xsl:if>
            <fo:block xsl:use-attribute-sets="H2" keep-with-next="always">
            	<xsl:attribute name="id">
            		<xsl:value-of select="@t"/>
            		<xsl:text>.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="h2x"/>
				<xsl:value-of select="@t"/>
            </fo:block>
			<xsl:apply-templates/>
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeOFF">
         			<xsl:with-param name="end" select="@end"/>
         		</xsl:call-template>
         	</xsl:if>
         </xsl:template>
         
		<xsl:template name="h2x">
			<fo:inline>
				<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
				<xsl:number format="1." level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
            	<xsl:text> </xsl:text>
			</fo:inline>
		</xsl:template>

         <xsl:template match="a2">
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeON"/>
         	</xsl:if>
            <fo:block xsl:use-attribute-sets="H2" keep-with-next="always">
            	<xsl:attribute name="id">
            		<xsl:value-of select="@t"/>
            		<xsl:text>.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="a2x"/>
				<xsl:value-of select="@t"/>
            </fo:block>
			<xsl:apply-templates/>
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeOFF">
         			<xsl:with-param name="end" select="@end"/>
         		</xsl:call-template>
         	</xsl:if>
         </xsl:template>
         
		<xsl:template name="a2x">
			<fo:inline>
				<xsl:number format="A." level="any" from="/" count="a1"/>
				<xsl:number format="1." level="any" from="a1" count="a2"/>
            	<xsl:text> </xsl:text>
			</fo:inline>
		</xsl:template>

         <xsl:template match="h3">
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeON"/>
         	</xsl:if>
            <fo:block xsl:use-attribute-sets="H3" keep-with-next="always">
            	<xsl:attribute name="id">
            		<xsl:value-of select="@t"/>
            		<xsl:text>.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="h3x"/>
				<xsl:value-of select="@t"/>
            </fo:block>
			<xsl:apply-templates/>
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeOFF">
         			<xsl:with-param name="end" select="@end"/>
         		</xsl:call-template>
         	</xsl:if>
         </xsl:template>
         
		<xsl:template name="h3x">
			<fo:inline>
				<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
				<xsl:number format="1." level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
				<xsl:number format="1." level="any" from="h2" count="h3"/>
            	<xsl:text> </xsl:text>
			</fo:inline>
		</xsl:template>

         <xsl:template match="a3">
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeON"/>
         	</xsl:if>
            <fo:block xsl:use-attribute-sets="H3" keep-with-next="always">
            	<xsl:attribute name="id">
            		<xsl:value-of select="@t"/>
            		<xsl:text>.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="a3x"/>
				<xsl:value-of select="@t"/>
            </fo:block>
			<xsl:apply-templates/>
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeOFF">
         			<xsl:with-param name="end" select="@end"/>
         		</xsl:call-template>
         	</xsl:if>
         </xsl:template>
         
		<xsl:template name="a3x">
			<fo:inline>
				<xsl:number format="A." level="any" from="/" count="a1"/>
				<xsl:number format="1." level="any" from="a1" count="a2"/>
				<xsl:number format="1." level="any" from="a2" count="a3"/>
            	<xsl:text> </xsl:text>
			</fo:inline>
		</xsl:template>

         <xsl:template match="h4">
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeON"/>
         	</xsl:if>
            <fo:block xsl:use-attribute-sets="H4" keep-with-next="always">
            	<xsl:attribute name="id">
            		<xsl:value-of select="@t"/>
            		<xsl:text>.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="h4x"/>
				<xsl:value-of select="@t"/>
            </fo:block>
			<xsl:apply-templates/>
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeOFF">
         			<xsl:with-param name="end" select="@end"/>
         		</xsl:call-template>
         	</xsl:if>
         </xsl:template>
         
		<xsl:template name="h4x">
			<fo:inline>
				<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
				<xsl:number format="1." level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
				<xsl:number format="1." level="any" from="h2" count="h3"/>
				<xsl:number format="1." level="any" from="h3" count="h4"/>
            	<xsl:text> </xsl:text>
			</fo:inline>
		</xsl:template>

         <xsl:template match="a4">
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeON"/>
         	</xsl:if>
            <fo:block xsl:use-attribute-sets="H4" keep-with-next="always">
            	<xsl:attribute name="id">
            		<xsl:value-of select="@t"/>
            		<xsl:text>.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="a4x"/>
				<xsl:value-of select="@t"/>
            </fo:block>
			<xsl:apply-templates/>
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeOFF">
         			<xsl:with-param name="end" select="@end"/>
         		</xsl:call-template>
         	</xsl:if>
         </xsl:template>
         
		<xsl:template name="a4x">
			<fo:inline>
				<xsl:number format="A." level="any" from="/" count="a1"/>
				<xsl:number format="1." level="any" from="a1" count="a2"/>
				<xsl:number format="1." level="any" from="a2" count="a3"/>
				<xsl:number format="1." level="any" from="a3" count="a4"/>
            	<xsl:text> </xsl:text>
			</fo:inline>
		</xsl:template>

         <xsl:template match="h5">
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeON"/>
         	</xsl:if>
            <fo:block xsl:use-attribute-sets="H5" keep-with-next="always">
            	<xsl:attribute name="id">
            		<xsl:value-of select="@t"/>
            		<xsl:text>.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="h5x"/>
				<xsl:value-of select="@t"/>
            </fo:block>
			<xsl:apply-templates/>
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeOFF">
         			<xsl:with-param name="end" select="@end"/>
         		</xsl:call-template>
         	</xsl:if>
         </xsl:template>
         
		<xsl:template name="h5x">
			<fo:inline>
				<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
				<xsl:number format="1." level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
				<xsl:number format="1." level="any" from="h2" count="h3"/>
				<xsl:number format="1." level="any" from="h3" count="h4"/>
				<xsl:number format="1." level="any" from="h4" count="h5"/>
            	<xsl:text> </xsl:text>
			</fo:inline>
		</xsl:template>

         <xsl:template match="a5">
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeON"/>
         	</xsl:if>
            <fo:block xsl:use-attribute-sets="H5" keep-with-next="always">
            	<xsl:attribute name="id">
            		<xsl:value-of select="@t"/>
            		<xsl:text>.property-description</xsl:text>
            	</xsl:attribute>
				<xsl:call-template name="a5x"/>
				<xsl:value-of select="@t"/>
            </fo:block>
			<xsl:apply-templates/>
         	<xsl:if test="@landscape">
         		<xsl:call-template name="landscapeOFF">
         			<xsl:with-param name="end" select="@end"/>
         		</xsl:call-template>
         	</xsl:if>
         </xsl:template>
         
		<xsl:template name="a5x">
			<fo:inline>
				<xsl:number format="A." level="any" from="/" count="a1"/>
				<xsl:number format="1." level="any" from="a1" count="a2"/>
				<xsl:number format="1." level="any" from="a2" count="a3"/>
				<xsl:number format="1." level="any" from="a3" count="a4"/>
				<xsl:number format="1." level="any" from="a4" count="a5"/>
            	<xsl:text> </xsl:text>
			</fo:inline>
		</xsl:template>

         <xsl:template match="figureLink">
            <fo:wrapper font-style="italic">
	         	<fo:basic-link>
	 	          	<xsl:attribute name="internal-destination">
	 	          		<xsl:value-of select="@t"/>
	            		<xsl:text>.figure-description</xsl:text>
	            	</xsl:attribute>
					<xsl:text>Figure </xsl:text>
	            	<xsl:call-template name="figureLinkRef">
	            		<xsl:with-param name="content" select="@t"/>
	            	</xsl:call-template>
	         	</fo:basic-link>
            </fo:wrapper>
          </xsl:template>
          
         <xsl:template name="figureLinkRef">
          	<xsl:param name="content">2007</xsl:param>
          		<xsl:for-each select="key('figures',$content)">
  			      	<xsl:choose>
			          <xsl:when test="name() = 'img'">
	            		<xsl:number level="any" from="/" count="img" format="(1)"/>
			          </xsl:when>
			          <xsl:otherwise>
					      <xsl:message terminate="yes">
					        <xsl:text>Error: No such figure</xsl:text><xsl:value-of select="$content"/>
					      </xsl:message>
			          </xsl:otherwise>
			        </xsl:choose>
			  </xsl:for-each>
          </xsl:template>

         <xsl:template match="sectionLink">
            <fo:wrapper font-style="italic">
	         	<fo:basic-link>
	 	          	<xsl:attribute name="internal-destination">
	 	          		<xsl:value-of select="@t"/>
	            		<xsl:text>.property-description</xsl:text>
	            	</xsl:attribute>
					<!--  -->
	            	<xsl:call-template name="linkRef">
	            		<xsl:with-param name="content" select="@t"/>
	            	</xsl:call-template>
	         	</fo:basic-link>
            </fo:wrapper>
          </xsl:template>
          
         <xsl:template name="linkRef">
          	<xsl:param name="content">2007</xsl:param>
          		<xsl:for-each select="key('sections',$content)">
  			      	<xsl:choose>
			          <xsl:when test="name() = 'h1'">
			            <fo:inline><xsl:number format="1"/></fo:inline>
			          </xsl:when>
			          <xsl:when test="name() = 'h2'">
			        	<fo:inline>
				        	<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
							<xsl:number format="1" level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
						</fo:inline>
			          </xsl:when>
			          <xsl:when test="name() = 'h3'">
			        	<fo:inline>
				        	<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
							<xsl:number format="1." level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
							<xsl:number format="1" level="any" from="h2" count="h3"/>
						</fo:inline>
			          </xsl:when>
			          <xsl:when test="name() = 'h4'">
			        	<fo:inline>
				        	<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
							<xsl:number format="1." level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
							<xsl:number format="1." level="any" from="h2" count="h3"/>
							<xsl:number format="1" level="any" from="h3" count="h4"/>
						</fo:inline>
			          </xsl:when>
			          <xsl:when test="name() = 'h5'">
			        	<fo:inline>
				        	<xsl:number format="1." level="any" from="/" count="h1|process-log|process-references|process-reviewers"/>
							<xsl:number format="1." level="any" from="h1|process-log|process-references|process-reviewers" count="h2"/>
							<xsl:number format="1." level="any" from="h2" count="h3"/>
							<xsl:number format="1." level="any" from="h3" count="h4"/>
							<xsl:number format="1" level="any" from="h4" count="h5"/>
						</fo:inline>
			          </xsl:when>
			          <xsl:when test="name() = 'a1'">
			            <fo:inline><xsl:number format="A"/></fo:inline>
			          </xsl:when>
			          <xsl:when test="name() = 'a2'">
			        	<fo:inline>
				        	<xsl:number format="A." level="any" from="/" count="a1"/>
							<xsl:number format="1" level="any" from="a1" count="a2"/>
						</fo:inline>
			          </xsl:when>
			          <xsl:when test="name() = 'a3'">
			        	<fo:inline>
				        	<xsl:number format="A." level="any" from="/" count="a1"/>
							<xsl:number format="1." level="any" from="a1" count="a2"/>
							<xsl:number format="1" level="any" from="a2" count="a3"/>
						</fo:inline>
			          </xsl:when>
			          <xsl:when test="name() = 'a4'">
			        	<fo:inline>
				        	<xsl:number format="A." level="any" from="/" count="a1"/>
							<xsl:number format="1." level="any" from="a1" count="a2"/>
							<xsl:number format="1." level="any" from="a2" count="a3"/>
							<xsl:number format="1" level="any" from="a3" count="a4"/>
						</fo:inline>
			          </xsl:when>
			          <xsl:when test="name() = 'a5'">
			        	<fo:inline>
				        	<xsl:number format="A." level="any" from="/" count="a1"/>
							<xsl:number format="1." level="any" from="a1" count="a2"/>
							<xsl:number format="1." level="any" from="a2" count="a3"/>
							<xsl:number format="1." level="any" from="a3" count="a4"/>
							<xsl:number format="1" level="any" from="a4" count="a5"/>
						</fo:inline>
			          </xsl:when>
			          <xsl:otherwise>
					      <xsl:message terminate="yes">
					        <xsl:text>Error: No such xref</xsl:text><xsl:value-of select="$content"/>
					      </xsl:message>
			          </xsl:otherwise>
			        </xsl:choose>
          			
          			<!--<xsl:value-of select="@t"/>-->
			  </xsl:for-each>
          </xsl:template>

         <xsl:template match="paragraph|p">
            <fo:block xsl:use-attribute-sets="normal">
               <xsl:apply-templates/>
            </fo:block>
         </xsl:template>
         <xsl:template match="code">
            <fo:block xsl:use-attribute-sets="code">
               <xsl:apply-templates/>
            </fo:block>
         </xsl:template>
         <xsl:template match="note">
			<fo:table table-layout="fixed">
	         	<fo:table-column column-width="1cm"/>
	         	<fo:table-column column-width="30px"/>
	         	<fo:table-column column-width="10cm"/>
				<fo:table-body>
					<fo:table-row>
					<fo:table-cell>
						<fo:block>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell display-align="before">
						<fo:block text-align="center">
							<fo:external-graphic 
								xsl:use-attribute-sets="graphic"
				         		border-style="solid" 
								border-color="black" 
								scaling="uniform" 
								scaling-method="resample-any-method" 
								content-width="scale-to-fit"
								height="20px" src="url(note.png)"/>
						</fo:block>
	         		</fo:table-cell>
					<fo:table-cell>
						<fo:block xsl:use-attribute-sets="note">
						<xsl:apply-templates/>
						</fo:block>
					</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
         </xsl:template>
         <xsl:template match="warning">
			<fo:table table-layout="fixed">
	         	<fo:table-column column-width="1cm"/>
	         	<fo:table-column column-width="30px"/>
	         	<fo:table-column column-width="10cm"/>
				<fo:table-body>
					<fo:table-row>
					<fo:table-cell>
						<fo:block>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell display-align="before">
						<fo:block text-align="center">
							<fo:external-graphic 
								xsl:use-attribute-sets="graphic"
				         		border-style="solid" 
								border-color="black" 
								scaling="uniform" 
								scaling-method="resample-any-method" 
								content-width="scale-to-fit"
								height="20px" src="url(warning.gif)"/>
						</fo:block>
	         		</fo:table-cell>
					<fo:table-cell>
						<fo:block xsl:use-attribute-sets="warning">
						<xsl:apply-templates/>
						</fo:block>
					</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
			</fo:table>
         </xsl:template>
         <xsl:template match="emph">
            <fo:wrapper font-style="italic">
               <xsl:apply-templates/>
            </fo:wrapper>
         </xsl:template>
         <xsl:template match="courier">
            <fo:wrapper font-family="Courier">
               <xsl:apply-templates/>
            </fo:wrapper>
         </xsl:template>
		<xsl:template match="svg:*">
		<xsl:element name="svg:{local-name(.)}">
		 <xsl:copy-of select="@*"/>
		<xsl:apply-templates/>
		</xsl:element>
		</xsl:template>
		<xsl:template match="fo:*">
		<xsl:element name="fo:{local-name(.)}">
		 <xsl:copy-of select="@*"/>
		<xsl:apply-templates/>
		</xsl:element>
		</xsl:template>
         <xsl:template match="bold">
            <fo:wrapper font-weight="bold">
               <xsl:apply-templates/>
            </fo:wrapper>
         </xsl:template>
         <xsl:template match="Year">
            <xsl:value-of select="$Year"/>
         </xsl:template>
         <xsl:template match="ProductVersion">
            <xsl:value-of select="$ProductVersion"/>
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
            	
            	<fo:basic-link color="blue" text-decoration="underline">
		            	<xsl:attribute name="external-destination">
		            		<xsl:text>url(</xsl:text>
		            		<xsl:value-of select="@url" />
		            		<xsl:text>)</xsl:text>
		            	</xsl:attribute>
					<xsl:number format="[1]" level="any" from="/" count="reference"/>
				</fo:basic-link>
		</xsl:if>
            	<xsl:if test="string-length(@url) &lt;= 0">
	         	<fo:basic-link>
	 	          	<xsl:attribute name="internal-destination">
	 	          		<xsl:value-of select="@t"/>
	            		<xsl:text>.reference-description</xsl:text>
	            	</xsl:attribute>
                 <xsl:for-each select="key('references',@t)">
                    <fo:inline>
                    <xsl:number format="[1]" level="any" from="/" count="reference"/>
                    </fo:inline>
                 </xsl:for-each>
	         	</fo:basic-link>
		</xsl:if>
		</xsl:for-each>
          </xsl:template>
         
         <xsl:template match="tableLink">
            <fo:wrapper font-style="italic">
	         	<fo:basic-link>
	 	          	<xsl:attribute name="internal-destination">
	 	          		<xsl:value-of select="@t"/>
	            		<xsl:text>.table-description</xsl:text>
	            	</xsl:attribute>
					<xsl:text>Table </xsl:text>
	            	<xsl:call-template name="tableLinkRef">
	            		<xsl:with-param name="content" select="@t"/>
	            	</xsl:call-template>
	         	</fo:basic-link>
            </fo:wrapper>
          </xsl:template>
          
         <xsl:template name="tableLinkRef">
          	<xsl:param name="content">2007</xsl:param>
          		<xsl:for-each select="key('tables',$content)">
  			      	<xsl:choose>
			          <xsl:when test="name() = 'table'">
	            		<xsl:number level="any" from="/" count="table[string-length(@t) &gt; 0]" format="(1)"/>
			          </xsl:when>
			          <xsl:otherwise>
					      <xsl:message terminate="yes">
					        <xsl:text>Error: No such table</xsl:text><xsl:value-of select="$content"/>
					      </xsl:message>
			          </xsl:otherwise>
			        </xsl:choose>
			  </xsl:for-each>
          </xsl:template>

    	<xsl:template match="footnote">
			<fo:footnote>
				<fo:inline font-size="0.83em" baseline-shift="super">
					<xsl:number level="any" count="footnote" format="(1)"/>
				</fo:inline>
				<fo:footnote-body>
					<fo:list-block provisional-distance-between-starts="20pt"
						provisional-label-separation="5pt">
						<fo:list-item>
						<fo:list-item-label end-indent="label-end()">
						<fo:block font-size="0.83em"
						line-height="0.9em">
						<xsl:number level="any" count="footnote" format="1)"/>
						</fo:block>
						</fo:list-item-label>
						<fo:list-item-body start-indent="body-start()">
						<fo:block font-size="0.83em"
						line-height="0.9em">
						<xsl:apply-templates/>
						</fo:block>
						</fo:list-item-body>
						</fo:list-item>
					</fo:list-block>
				</fo:footnote-body>
			</fo:footnote>
		</xsl:template>

      </xsl:stylesheet>

