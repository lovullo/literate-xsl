<?xml version="1.0" encoding="ISO-8859-1"?>
<!--@comment
  Texinfo documentation generator for XSL stylesheets

  Copyright (C) 2014 LoVullo Associates, Inc.

    This file is part of xslink.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
-->

<stylesheet version="2.0"
  xmlns="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xt="http://www.lovullo.com/xsltexi">

<output method="text" />

<variable name="xt:nl" select="'&#10;'" />


<!--
  Entry point

  Comments that precede the stylesheet definition will also be
  processed, since these are commonly used to describe the stylesheet
  as a whole.
-->
<template match="xsl:stylesheet|xsl:transform">
  <apply-templates mode="xt:doc-gen"
                   select="preceding-sibling::comment()|*" />
</template>


<!--
  Generate `match' definition for templates with @code{@match}

  The mode (default of @code{(select)}) will act as the function name
  in the output, with the XPath following in place of the argument
  list.

  TODO: Put more thought into large XPath expressions.
  TODO: Params.
-->
<template mode="xt:doc-gen" priority="7"
          match="xsl:template[ @match ]">
  <variable name="doc" as="comment()?"
            select="preceding-sibling::comment()[1]" />

  <variable name="mode" as="xs:string"
            select="if ( @mode ) then @mode else '(default)'" />

  <value-of select="concat(
                      $xt:nl,
                      '@deffn match {', @mode, '} ',
                      ' on {', @match, '}',
                      $xt:nl,
                      $doc,
                      $xt:nl,
                      '@end deffn',
                      $xt:nl)" />
</template>


<!--
  Generate `template' and `function' definitions

  The return type, if not provided as @code{@as}, defaults to
  @code{xs:sequence()}.  Parameters are output in a style consistent
  with the XPath specification.
-->
<template mode="xt:doc-gen" priority="5"
          match="xsl:template|xsl:function">
  <variable name="doc" as="comment()?"
            select="preceding-sibling::comment()[1]" />

  <variable name="param-str" as="xs:string"
            select="string-join( xt:typed-param-str( xsl:param ),
                                 ', ' )" />

  <variable name="type" as="xs:string"
            select="if ( @as ) then @as else 'xs:sequence*'" />

  <value-of select="concat(
                      $xt:nl,
                      '@deftypefn ', name(), ' {', $type, '} ',
                        @name, ' (', $param-str, ')',
                      $xt:nl,
                      $doc,
                      $xt:nl,
                      '@end deftypefn',
                      $xt:nl)" />
</template>


<!--
  Echo comment blocks

  This allows including arbitrary output, enabling the writing of
  complete documentation as a component of the source code
  itself.  This style is popular in the TeX/LaTeX community, based on
  Knuth's concept of "Literate Programming" in his languages
  WEB.

  If you do @emph{not} wish for comments to be directly echoed, then
  they must contain @code{@comment} at the beginning of the comment
  node, with @emph{no} whitespace preceding it.
-->
<template mode="xt:doc-gen" priority="5"
          match="comment()[ not( starts-with( ., '@comment' ) ) ]">
  <value-of select="concat( ., $xt:nl )" />
</template>


<!--
  Generate typed parameter list from @var{params}

  The style is consistent with that of the XPath specification: `PARAM
  as TYPE'.
-->
<function name="xt:typed-param-str" as="xs:string*">
  <param name="params" as="element( xsl:param )*" />

  <for-each select="$params">
    <value-of select="concat(
                        if ( position() gt 1 ) then ' ' else '',
                        @name, ' as ',
                        '{',
                        if ( @as ) then @as else 'xs:sequence*',
                        '} ' )" />
  </for-each>
</function>


<!--
  All other nodes are ignored, for now.
-->
<template mode="xt:doc-gen" priority="1"
          match="*|@*|text()|comment()">
</template>

</stylesheet>
