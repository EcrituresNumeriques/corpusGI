xquery version "3.1";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace html = "";

declare default function namespace 'local' ;

(: XQuery for converting HTML to TEI XML :)
declare function local:dispatch($nodes as node()*) as item()* {
  for $node in $nodes
  return
  typeswitch($node)
  case text() return $node
(:  case element(tei:s) return local:s($node):)
  case element(p) return local:p($node)
(:  case element(tei:hi) return local:hi($node)
  case element(tei:quote) return local:quote($node)
  case element(tei:q) return local:q($node)
  case element(tei:body) return local:body($node) :)
  default return local:passthru($node)
};

(: Recurse through child nodes :)
declare function local:passthru($node as node()*) as item()* {
  element {fn:name($node)} {($node/@*, local:dispatch($node/node()))}
};

(: <s> to <span> with attributes :)
declare function local:s($node as element(tei:s)) as element() {
  let $sentence := $node/@n
  return
  <span data-sentence="{$sentence}">{local:dispatch($node/node())}</span>
};

(: <p> to <p> with attributes :)
declare function local:p($node as element(p)) as element() {
  let $paragraph := $node/@n
  return
  <p data-paragraph="{$paragraph}">{local:dispatch($node/node())}</p>
};

(: <hi> to <b>, <i>, or <span> :)
declare function local:hi($node as element(tei:hi)) as element() {
  let $rend := $node/@rend
  return
  if ($rend = 'bold') then
    <b>{local:dispatch($node/node())}</b>
  else if ($rend = 'italic') then
    <i>{local:dispatch($node/node())}</i>
  else
    <span>{local:dispatch($node/node())}</span>
};
(: <quote> to <span> :)
declare function local:quote($node as element(tei:quote)) as element() {
  let $rend := $node/@rend
  return
  if ($rend = 'blockquote') then
    <blockquote>{local:dispatch($node/node())}</blockquote>
  else
    <q>{local:dispatch($node/node())}</q>
};

(: <q> to quote :)
declare function local:q($node as element(tei:q)) as element() {
  <span class="quotes">&#8216;{local:dispatch($node/node())}&#8217;</span>
};

(: <body> to <div> with id attribute :)
declare function local:body($node as element(tei:body)) as element() {
  <div lang="la" id="tei-document">{local:dispatch($node/node())}</div>
};

(: 
 : my own
 :)

(:~
 : This function writes multiples TEI-corpus XML file (infine, the objective is to write a single TEI-corpus file)
 : @return for every item of the inventory, write a file into /TEI/ named after the name of the scrapped html file. 
 :)
declare function local:writeArticles($refs as map(*)*) as document-node()* {
  let $path := '/home/nicolas/ownCloud/General_instin/data/TEI/'
  for $ref in $refs
  return
    (: let $article := db:open("GIwget","item-002/remue.net/spip.php?article1524.html") :)
    let $article := db:open('GIwget','/item-' || map:get($ref, 'num') || '/remue.net/spip.php?article' || map:get($ref, 'numarticle') || '.html')/html
    (: let $file := "item-006_article2998.html.xml" :)
    (: let $file := 'item-' || map:get($ref, 'num') || '_article' || map:get($ref, 'numarticle') || '-TEI.xml' :)
    let $file := 'spip.php?article' || map:get($ref, 'numarticle') || '.html.xml'
    let $article := local:getArticle($article, $ref)
    return file:write($path || $file, $article, map { 'method' : 'xml', 'indent' : 'yes', 'omit-xml-declaration' : 'no'}) 
};

(:~
 : This function builts the article content
 : @param $article the Remue.net article
 : @param $ref the article references (num, source, numarticle)
 : @return an xml TEI-corpus segment
 : Objective : build a proper TEI-corpus segment with all metadatas..
 :)
declare function local:getArticle( $article as element(), $ref as map(*) ) as element() {
  let $content := $article//div[@id="contenu"]
  let $titre := $article/head/title
  let $num :=  map:get($ref, 'num')
  return <TEI>{
    $titre,
    $content
  }
  </TEI>
};



(:~
 : This fuction gets the articles references & corpus metadatas
 : @return a map sequence with the article references from the inventaireInstin.xml file
 :)

let $doc := '/home/nicolas/ownCloud/General_instin/data/wget/inventaireInstin.xml'

let $refs := for $item in fn:doc($doc)/inventaire/item
return map {
  'num' : fn:data($item/num),
  'source' : fn:data($item/source),
  'numarticle' : fn:data($item/article)
  }


return local:writeArticles($refs)

