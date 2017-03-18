xquery version "3.1";

declare default function namespace 'local' ;
declare namespace csv = "http://basex.org/modules/csv";

(: déclare les options pour le serialiseur CSV:)
let $options := map { 'separator': ';'}

(: ouvre la base XML:)
let $TEI := db:open("GITEI2")
 
(: construit un arbre XML à 2 niveaux (root/branche) :)
let $toBeCsv :=  <itemList>{
  for $item in $TEI/TEI
    let $title := $item//title
    let $url := fn:string($item//publicationStmt/source/a/@href)
    let $author := $item//author
    let $date := fn:string($item//publicationStmt/date/@when)
    let $rubrique := $item//publicationStmt/category
  return 
  <item>
    <year>{fn:substring($date,1,4)}</year>
    <month>{fn:substring($date,6,2)}</month>
    <day>{fn:substring($date,9,2)}</day>
    <time></time>
    <endYear></endYear>
    <endMonth></endMonth>
    <endDay></endDay>
    <endTime></endTime>
    <displayDate></displayDate>
    {$title}
    {$author}
    <media></media>
    <mediaCredit></mediaCredit>
    <mediaCaption></mediaCaption>
    <type></type>
    <mediaThumbnail></mediaThumbnail>
    {$rubrique}
    <background></background>
  </item>
  }</itemList>


(: génère les données au format CSV :)
let $output := csv:serialize($toBeCsv, $options)

(: return $toBeCsv :)
(: return $output :)

(: écrit les données dans un fichier CSV :)
return 
    file:write-text("/home/nicolas/ownCloud/General_instin/data/script/teicsv.csv", $output)
  
