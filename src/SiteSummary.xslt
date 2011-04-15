<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE xsl:stylesheet [
	<!ENTITY NewDocument "*[@isDoc]">
	<!ENTITY NewProperty "*[not(@isDoc)]">
	<!ENTITY NewDocName "name()">
	<!ENTITY NewPropName "name()">

	<!ENTITY Document "*[@isDoc]">
	<!ENTITY property "*[not(@isDoc)]">
	<!ENTITY docName "name()">
	<!ENTITY propName "name()">

	<!ENTITY NiceUrl "string">
	
	<!ENTITY Old_Document "node">
	<!ENTITY Old_property "data">
	<!ENTITY Old_docName "@nodeTypeAlias">
	<!ENTITY Old_propName "@alias">
]>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:umb="urn:umbraco.library"
	exclude-result-prefixes="umb"
>

	<xsl:output method="html" indent="yes" omit-xml-declaration="yes" />

	<xsl:param name="currentPage" select="/root/*/*[1]" />
	<xsl:variable name="siteRoot" select="$currentPage/ancestor-or-self::*[@level = 1]" />

	<xsl:key name="document-by-name" match="&Document;" use="&docName;" />

	<xsl:template match="/">
		<html>
		<head>
			<title>Umbraco Website Summary</title>
			<style>
				html, body, h1, h2, h3, h4, ul, ol, li { margin: 0; padding: 0; }
				body { font-size: 75%; }
				.doc, .doc h3 {
					-webkit-border-radius: 6px;
					-moz-border-radius: 6px;
					border-radius: 6px;				
				}
				.doc {
					border: 2px solid rgba(0, 0, 0, 0.1);
					background: rgba(0, 0, 0, 0.2);
					width: 220px;
					margin: 5px;
					float: left;
					min-height: 200px;
					-webkit-transform: scale(0.8);
					-webkit-transition: all 0.3s ease-in;
				}
				.doc:hover {
					-webkit-box-shadow: 0 4px 8px rgba(0, 0, 0, 0.75);
					-moz-box-shadow: 0 4px 8px rgba(0, 0, 0, 0.75);
					box-shadow: 0 4px 8px rgba(0, 0, 0, 0.75);
					-webkit-transform: scale(1.0);
				}
				.doc:hover .props {
					overflow: hidden;
				}
				.doc h3 {
					height: 30px;
					line-height: 30px;
					text-align: center;
					color: #fff;
					background: #000;
				}
				.doc p, .doc h4, .doc ul {
					margin: 0.5em 10px; 
				}
				.doc p { text-align: right; cursor: pointer; }
				.doc h4 {
					border-bottom: 2px groove #ccc;
					padding-bottom: 2px;
				}
				.doc ul {
					list-style: square;
					margin-left: 3em;
				}
				.doc pre {
					font-size: 9px;
					overflow: auto; 
				}
			</style>
			<script><![CDATA[
				function $(node) {
					if (typeof(node) === 'string') {
						return document.getElementById(node);
					} else {
						return node;
					}
				}
				function toggle(element) {
					var s = $(element).style;
					if (s.display == 'none') {
						show(element);
					} else {
						hide(element);
					}					
				}
				function hide(element) {
					$(element).style.display = 'none';
				}
				function show(element) {
					$(element).style.display = 'block';
				}]]>
			</script>
		</head>
		<body>
			<xsl:apply-templates />
		</body>
		</html>
	</xsl:template>

	<xsl:template match="root">
		<h1>Site Summary</h1>
		<h2>Document Types</h2>
		
		<xsl:apply-templates select="." mode="doctypes" />
		
	</xsl:template>
	
	<xsl:template match="root" mode="doctypes">
		<xsl:apply-templates select="//&Document;[count(. | key('document-by-name', &docName;)[1]) = 1]" mode="summary">
			<xsl:sort select="&docName;" />
			<xsl:sort select="position()" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="&Document;" mode="summary">
		<xsl:variable name="publishedDocs" select="key('document-by-name', &docName;)" />
		<div class="doc">
			<h3><xsl:value-of select="&docName;" /></h3>
			<p onclick="toggle('{generate-id()}')">
				<xsl:value-of select="count($publishedDocs)" /> nodes published.<xsl:text />
			</p>
			<xsl:if test="$publishedDocs">
				<ul id="{generate-id()}" style="display:none">
					<xsl:apply-templates select="$publishedDocs" mode="ref" />
				</ul>
				<hr />
			</xsl:if>
			
			<div class="props">
				<xsl:apply-templates select="self::*[&property;]" mode="properties" />
			</div>
			
		</div>
	</xsl:template>
	
	<xsl:template match="&Document;" mode="properties">
		<h4>Properties</h4>
		<ul>
			<xsl:apply-templates select="&property;" mode="summary" />
		</ul>
	</xsl:template>
	
	<xsl:template match="&property;" mode="summary">
		<li>
			<xsl:value-of select="&propName;" />
		</li>
	</xsl:template>
	
	<xsl:template match="&Document;" mode="ref">
		<li>
			<a href="{&NiceUrl;(@id)}" title="Go to page in site"><xsl:value-of select="@nodeName" /></a>
			<xsl:text /> (<a href="{&NiceUrl;(@id)}/xmldump" title="View this page's XML">XML</a>)<xsl:text />
		</li>
	</xsl:template>

	<xsl:template match="&Document;" mode="sample">
		<pre class="hide"><code>
&lt;<xsl:value-of select="&docName;" />&gt;
	<xsl:apply-templates select="&property;" mode="sample" />
&lt;/<xsl:value-of select="&propName;" />&gt;<xsl:text />
		</code></pre>
	</xsl:template>
	
	<xsl:template match="&property;" mode="sample">
		<xsl:text />&lt;<xsl:value-of select="&propName;" /> /&gt;
	</xsl:template>
	
</xsl:stylesheet>