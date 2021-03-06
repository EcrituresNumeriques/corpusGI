xquery version "3.1";

(: declare default element namespace 'http://www.tei-c.org/ns/1.0' ; :)


declare namespace tei = "http://www.tei-c.org/ns/1.0" ;
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
  case element(a) return local:a($node)
  case element(i) return local:i($node)
  case element(b) return local:b($node)
  case element(em) return local:em($node)
  case element(strong) return local:strong($node)
  case element(br) return local:br($node)
(:  case element(hi) return local:hi($node)
  case element(q) return local:q($node) 
  case element(body) return local:body($node) :)
  case element(blockquote) return local:quote($node)
  case element(html:div) return local:div($node)
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
  
    (: <p>POUET123</p> :)
    <p>{local:dispatch($node/node())}</p>
  (: <p data-paragraph="{$paragraph}">{local:dispatch($node/node())}</p> :)
};

(: <a> to <ref target=""> with attributes :)
declare function local:a($node as element(a)) as element() {  
    let $target := $node/@href
    let $target := 
      if ($node[@class='spip_in']) then ('http://remue.net/' || $target) 
      else if (fn:starts-with($target,'..')) then ('http://www.generalinstin.net/' || fn:substring-after($target,'../'))
      else $target
    let $title := if ($node/@title) then $node/@title else $node/text()
    let $class := $node/@class
    return <ref target="{$target}" title="{$title}" class="{$class}">{local:dispatch($node/text())}</ref>
};

(: <div> to <div> with attributes :)
declare function local:div($node as element(html:div)) as element() {
  let $class := $node/@class
  let $id := $node/@id
  return
  <div class="{$class}" id="{$id}">{local:dispatch($node/node())}</div>
};

declare function local:i($node as element(i)) as element() {  
    <hi rend="italic">{local:dispatch($node/node())}</hi>
};

declare function local:em($node as element(em)) as element() {  
    <emph rend="italic">{local:dispatch($node/node())}</emph>
};

declare function local:b($node as element(b)) as element() {  
    <hi rend="bold">{local:dispatch($node/node())}</hi>
};

declare function local:strong($node as element(strong)) as element() {  
    <emph rend="bold">{local:dispatch($node/node())}</emph>
};

declare function local:br($node as element(br)) as element() {  
    <lb/>
};

(: <hi> to <b>, <i>, or <span> :)
(: to be transformed in from <i> to <hi rend="italic"> :)
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
(: OK to be transformed in from <blockquote> to <quote rend="blockquote"> :)
declare function local:quote($node as element(blockquote)) as element() {
    <quote>{local:dispatch($node/node())}</quote>
};

(: <q> to quote :)
(: OK pas besoin :)
(: declare function local:q($node as element(q)) as element() {
  <span class="quotes">&#8216;{local:dispatch($node/node())}&#8217;</span>
}; :)

(: <body> to <div> with id attribute :)
(: declare function local:body($node as element(html:body)) as element() {
  <div lang="la" id="tei-document">{local:dispatch($node/node())}</div>
}; :)

(: 
 : my own
 :)

(:~
 : This function writes multiples TEI-corpus XML file (infine, the objective is to write a single TEI-corpus file)
 : @return for every item of the inventory, write a file into /TEI/ named after the name of the scrapped html file. 
 :)
declare function local:writeArticles($refs as map(*)*) as document-node()* {
  let $path := '/home/nicolas/ownCloud/General_instin/data/TEI_NSP/'
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
 : @param $article the Remue.net article
 : This function builts the article content
 : @param $ref the article references (num, source, numarticle)
 : @return an xml TEI-corpus segment
 : Objective : build a proper TEI-corpus segment with all metadatas..
 :)
declare function local:getArticle( $article as element(), $ref as map(*) ) as element() {
  let $content := local:getContent($article, $ref)  
  let $titre := <title>{map:get($ref, 'title')}</title>  
  let $author := <author>{map:get($ref, 'author')}</author>
  let $urlSource := <ref target="{map:get($ref, 'urlSource')}"/>
  let $publisher := <publisher>{$urlSource}<name>{map:get($ref, 'sourceWebsite')}</name></publisher>
  let $num :=  map:get($ref, 'num')
  let $geoloc :=  <place><placeName>{map:get($ref, 'geoloc')}</placeName></place>
  let $datePublication := <date when="{map:get($ref, 'datePublication')}"/>
  let $dateCreation := <date when="{map:get($ref, 'dateCreation')}" type="creation"/>
  let $dateArchive := <date when="{map:get($ref, 'dateArchive')}" type="archive"/>
  let $description := <p>{map:get($ref,'description')}</p>
  let $category := local:getCategory($article, $ref)
  let $listKeywords := <list><item>{local:getKeywords($article, $ref)}</item></list>
  return 
  <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:id="item-{$num}" >
     <teiHeader>
        <fileDesc>
                 <titleStmt>
                     {$titre} <!-- titre de la page archivée -->
                     {$author}<!-- auteur de la page archivée -->
                     <respStmt>
                        <resp>Encodé par</resp>
                        <name xml:id="JN">Servanne Monjour</name>
                        <name xml:id="GE">Nicolas Sauret</name>
                      </respStmt>
                      <sponsor>CRC sur les écritures numériques</sponsor>
                 </titleStmt>
                 <publicationStmt>
                     {$publisher} <!-- site source avec name et ref pour url-->
                     {$datePublication}
                     {$geoloc}
                 </publicationStmt>
                 <!-- sourceDesc sert à décrire la source. Si document nativement numérique, on peut mettre "nativement numérique" -->
                 <sourceDesc>
                     {$description}
                     {$dateCreation}
                     <material>digital native</material>
                     {$dateArchive}
                 </sourceDesc>
             </fileDesc>
             <encodingDesc> <!-- où on déclare les catégories : rubriques de sites web -->
                <classDecl>
                  <taxonomy xml:id="siteRubrique">
                    <category xml:id="remue_net_traits">
                       <catDesc>Les traits</catDesc>
                    </category>
                    <category xml:id="remue_net_generales">
                       <catDesc>Les générales</catDesc>
                    </category>
                    <category xml:id="remue_net_reels">
                       <catDesc>Les réels</catDesc>
                    </category>
                    <category xml:id="remue_net_noms">
                       <catDesc>Les noms</catDesc>
                    </category>
                    <category xml:id="generalInstin_climax">
                       <catDesc>Climax</catDesc>
                    </category>         
                  </taxonomy> 
                  <taxonomy xml:id="generalinstin_fr">              
                  </taxonomy> 
                </classDecl>
              </encodingDesc>
              <profileDesc> <!-- on décrit l item avec nos mots-clés et la rubrique du site -->
                <textClass>
                   <keywords scheme="#archive">
                      {$listKeywords}
                   </keywords>
                   <catRef target="{$category}"/>
                  </textClass>
              </profileDesc> 
             </teiHeader>
    <text>
      <front>
        <titlePage>
          <docTitle>
            <titlePart>
              {$titre/text()}
            </titlePart>
            </docTitle>
        </titlePage>
      </front>
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
    case 'remue.net' return local:dispatch($article//div[@id="contenu"])
    case 'www.generalinstin.net' return local:dispatch($article//article/div[@class="entry-content"])
    default return ()
};


(:~
 : This function retrieves the keywords of an item in the inventaire
 : @param $article one item in the inventaire
 : @param $ref the item metadatas from inventaire (num, source, etc.)
 : @return the keywords separated by comma
 : TODO : séparer les keywords et les mettre dans une balise <item> 
        : dans ce cas, la fonction retournera une séquence element()* 
 :)
declare function local:getKeywords( $article as element(), $ref as map(*) )  {
  let $keywords := map:get($ref, 'keywords')
  return $keywords 
};

(:~
 : This function tests the rubrique of the source and return the id of the taxonomy
 : @param $article one item in the inventaire
 : @param $ref the item metadatas from inventaire (num, source, etc.)
 : @return the id of the taxonomy
 :)
declare function local:getCategory( $article as element(), $ref as map(*) )  {
  let $category := map:get($ref,'categoryWebsite')
  return switch($category)
    case 'les traits' return "#remue_net_traits"
    case 'les générales' return "#remue_net_generales"
    case 'les noms' return "#remue_net_noms"
    case 'les réels' return "#remue_net_reels"
    case 'Climax' return "#generalInstin_climax"
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

let $refs := for $item in fn:doc($doc)/inventaire/itemGI
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

