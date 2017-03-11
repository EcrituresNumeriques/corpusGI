xquery version "3.1";


(:declare default element namespace 'http://www.tei-c.org/ns/1.0' ;
:)
(:
declare namespace tei = "http://www.tei-c.org/ns/1.0" ;
:)

declare namespace html = "http://www.w3.org/1999/xhtml";


declare default function namespace 'local' ;


(: XQuery for converting HTML to TEI XML :)
declare function local:dispatch($nodes as node()*) as item()* {
  for $node in $nodes
  return
  typeswitch($node)
  case text() return $node
(:  case element(s) return local:s($node):)
  case element(p) return local:p($node)
(:  case element(hi) return local:hi($node)
  case element(quote) return local:quote($node)
  case element(q) return local:q($node)
  case element(body) return local:body($node) :)
  default return local:passthru($node)
};

(: Recurse through child nodes :)
declare function local:passthru($node as node()*) as item()* {
  element {fn:name($node)} {($node/@*, local:dispatch($node/node()))}
};

(: <s> to <span> with attributes :)
declare function local:s($node as element(s)) as element() {
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
declare function local:hi($node as element(hi)) as element() {
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
declare function local:quote($node as element(quote)) as element() {
  let $rend := $node/@rend
  return
  if ($rend = 'blockquote') then
    <blockquote>{local:dispatch($node/node())}</blockquote>
  else
    <q>{local:dispatch($node/node())}</q>
};

(: <q> to quote :)
declare function local:q($node as element(q)) as element() {
  <span class="quotes">&#8216;{local:dispatch($node/node())}&#8217;</span>
};

(: <body> to <div> with id attribute :)
declare function local:body($node as element(body)) as element() {
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
  let $path := '/home/nicolas/ownCloud/General_instin/data/TEI2/'
  for $ref in $refs
  return
    (: let $article := db:open("GIwget","item-002/remue.net/spip.php?article1524.html") :)
    (: /remue.net/spip.php?article' || map:get($ref, 'numarticle') :)
    (: || fn:substring-after(map:get($ref, 'urlSource'),'http:/') || '.html' :) 
    let $article := db:open('GIwget','/item-' || map:get($ref, 'num') )/html
    (: let $file := 'item-' || map:get($ref, 'num') || '_article' || map:get($ref, 'numarticle') || '-TEI.xml' :)
    (: prévoir ici différents cas de figure selon la source : generalinstin != remue.net :)
    let $file := 'item-' || map:get($ref, 'num') || '_' || map:get($ref, 'sourceWebsite') || '_' || local:makeFileName($ref) || '.html.xml'
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
  let $content := local:getContent($article, $ref)  
  let $titre := <title>{map:get($ref, 'title')}</title>  
  let $author := <author>{map:get($ref, 'author')}</author>
  let $publisher := <publisher>{map:get($ref, 'sourceWebsite')}</publisher>
  let $num :=  map:get($ref, 'num')
  let $urlSource := <source><a href="{map:get($ref, 'urlSource')}"/></source>
  let $geoloc :=  <place><placeName>{map:get($ref, 'geoloc')}</placeName></place>
  let $datePublication := <date when="{map:get($ref, 'datePublication')}"/>
  let $dateCreation := <date when="{map:get($ref, 'dateCreation')}" type="creation"/>
  let $dateArchive := <date when="{map:get($ref, 'dateArchive')}" type="archive"/>
  let $description := <p>{map:get($ref,'description')}</p>
  let $category := <category>{map:get($ref,'categoryWebsite')}</category>
  return 
  <TEI xml:id="item-{$num}" >
     <teiHeader>
        <fileDesc>
                 <titleStmt>
                     {$titre} (:devrait être le titre de l'archive:)
                     {$author} (:devrait être nous, et pourquoi pas GI..?:)
                     <!-- respStmt à ajouter -->
                 </titleStmt>
                 <publicationStmt>
                     {$publisher}
                     {$datePublication}
                     {$urlSource}
                     {$category}
                     {$geoloc}
                 </publicationStmt>
                 (: sourceDesc sert à décrire la source. Si document nativement numérique, on peut mettre "nativement numérique":)
                 <sourceDesc>
                     {$description}
                     <keywords>
                         <term></term>
                     </keywords>
                     {$dateCreation}
                     <material>digital</material>
                     {$dateArchive}
                 </sourceDesc>
             </fileDesc>
             </teiHeader>
    <text>
      <body>
        {$content}
      </body>
    </text>
  </TEI>
};


(:~
 : This function get the article content according to the source website
 : @param $article the document item
 : @param $ref the item metadatas from inventaire (num, source, etc.)
 : @return the body in xml TEI-corpus
 :)
declare function local:getContent( $article as element(), $ref as map(*) ) as element() {
  let $sourceWebsite := map:get($ref, 'sourceWebsite')
  return switch($sourceWebsite)
    case 'remue.net' return $article//html:div[@id="contenu"]
    case 'www.generalinstin.net' return $article//article/html:div[@class="entry-content"]
    default return ()
};

(:~
 : This function constructs the file name to be written according to the source website
 : @param $ref the item metadatas from inventaire (num, source, etc.)
 : @return the file Name
 :)

declare function local:makeFileName( $ref as map(*) ){
  let $sourceWebsite := map:get($ref, 'sourceWebsite')
  let $urlSource := map:get($ref, 'urlSource')
  return switch($sourceWebsite)
   case 'remue.net' return fn:substring-after(map:get($ref, 'urlSource'), map:get($ref, 'sourceWebsite') || '/')
   case 'www.generalinstin.net' return fn:replace(fn:substring-after(map:get($ref, 'urlSource'), map:get($ref, 'sourceWebsite') || '/') , '/' , '_')
   default return ()
};



(:~
 : This fuction gets the articles references & corpus metadatas
 : @return a map sequence with the article references from the inventaireInstin.xml file
 :)

let $doc := '/home/nicolas/ownCloud/General_instin/data/INSTIN_inventaire.xml'

let $refs := for $item in fn:doc($doc)/inventaire/item
return map {
  'num' : fn:data($item/@id),
  'author' : fn:data($item/author),
  'title' : fn:data($item/title),
  'urlSource' : fn:data($item/urlSource),
  'geoloc' : fn:data($item/geoloc),
  'urlRef' : fn:data($item/urlRef),
  'description' : fn:data($item/description),
  'keywords' : fn:data($item/keywords),
  'dateCreation' : fn:data($item/dateCreation),
  'datePublication' : fn:data($item/datePublication),
  'dateArchive' : fn:data($item/dateArchive),
  'corpus' : fn:data($item/corpus),
  'materiality' : fn:data($item/materiality),
  'sourceWebsite' : fn:data($item/sourceWebsite),
  'categoryWebsite' : fn:data($item/categoryWebsite)
  }


return local:writeArticles($refs)

