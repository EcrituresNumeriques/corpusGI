xquery version '3.0' ;
module namespace instin.mappings.teiInstin2html = 'instin.mappings.teiInstin2html' ;

(:~
 : This module is a TEI Instin to html function library for SynopsX
 :
 : @version 0.1 
 : @since 2017-03-22 
 : @author laconis
 :
 : This file is part of SynopsX.
 : created by AHN team (http://ahn.ens-lyon.fr)
 :
 : SynopsX is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
 : SynopsX is distributed in the hope that it will be useful,
 : but WITHOUT ANY WARRANTY; without even the implied warranty of
 : MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 : See the GNU General Public License for more details.
 : You should have received a copy of the GNU General Public License along 
 : with SynopsX. If not, see http://www.gnu.org/licenses/
 :)

declare namespace tei = 'http://www.tei-c.org/ns/1.0' ;

declare default function namespace 'instin.mappings.teiInstin2html' ;

(:~
 : this function 
 :)
declare function entry($node as node()*, $options as map(*)) as item()* {
  dispatch($node, $options)
};

(:~
 : this function dispatches the treatment of the XML document
 :)
declare function dispatch($node as node()*, $options as map(*)) as item()* {
  typeswitch($node)
    case text() return $node
    (: case element(erudit:para) return para($node, $options)
    case element(erudit:titre) return titre($node, $options)
    case element(erudit:section4) return section($node, $options)
    case element(erudit:section3) return section($node, $options)
    case element(erudit:section2) return section($node, $options)
    case element(erudit:section1) return section($node, $options)
    case element(erudit:corps) return passthru($node, $options) :)
    case element(body) return body($node, $options)
    default return passthru($node, $options)
};

(:~
 : This function pass through child nodes (xsl:apply-templates)
 :)
declare function passthru($nodes as node(), $options as map(*)) as item()* {
  for $node in $nodes/node()
  return dispatch($node, $options)
};


(:~
 : ~:~:~:~:~:~:~:~:~
 : tei textstructure
 : ~:~:~:~:~:~:~:~:~
 :)

declare function body($node as element(), $option as map(*)){
  <body>{passthru($node, $option)}</body>
};

(: declare function section($node as element(erudit:section)+, $options as map(*)) {
  <section>
    { if ($node/@xml:id) then attribute id { $node/@xml:id } else (),
    passthru($node, $options)}
  </section>
};

declare function titre($node as element(erudit:titre)+, $options as map(*)) as element() {   
  if ($node/parent::erudit:titre) then 
    let $level := if ($node/ancestor::section1 | $node/ancestor::section2 | $node/ancestor::section3) then fn:count($node/ancestor::div) + 1 else 1
    return element { 'h' || $level } { passthru($node, $options) }
  else  passthru($node, $options)
};

declare function para($node as element(erudit:para)+, $options as map(*)) {
  <p>{ passthru($node, $options) }</p>
}; :)
