xquery version "3.1";

declare default function namespace 'local' ;
declare namespace csv = "http://basex.org/modules/csv";

(: déclare les options pour le serialiseur CSV:)
let $options := map { 'separator': ';', 'header':"yes"}

let $rubriques := map {
  '#remue_net_traits' : 'Les traits',
  '#remue_net_generales' : 'Les générales',
  '#remue_net_reels' : 'Les réels',
  '#remue_net_noms' : 'Les noms',
  '#generalInstin_climax' : 'Climax'
}

let $images := map {
'item-001':'http://i.imgur.com/YKVC9NPm.png',  
'item-002':'http://i.imgur.com/6yO90pcm.png',
'item-003':'http://i.imgur.com/Pi7OqyFm.png',
'item-004':'http://i.imgur.com/h2j695vm.png',
'item-005':'http://i.imgur.com/zhUulytm.png',
'item-006':'http://i.imgur.com/jX2nEIsm.png',
'item-007':'http://i.imgur.com/jmTtiQWm.png',
'item-008':'http://i.imgur.com/jjhSfqlm.png',
'item-009':'http://i.imgur.com/RcUqgZXm.png',
'item-010':'http://i.imgur.com/1WrjkMrm.png',
'item-011':'http://i.imgur.com/YoxA9mJm.png',
'item-012':'http://i.imgur.com/BZUpuQFm.png',
'item-013':'http://i.imgur.com/XgD2vnXm.png',
'item-014':'http://i.imgur.com/6kMBPjWm.png',
'item-015':'http://i.imgur.com/g4sWqNLm.png',
'item-016':'http://i.imgur.com/vxhQzTmm.png',
'item-017':'http://i.imgur.com/rluqMcum.png',
'item-018':'http://i.imgur.com/yUJS9Rsm.png',
'item-019':'http://i.imgur.com/zYNrSjHm.png',
'item-020':'http://i.imgur.com/l8sRjojm.png',
'item-021':'http://i.imgur.com/0BF84Nem.png',
'item-022':'http://i.imgur.com/pAff68Tm.png',
'item-023':'http://i.imgur.com/eptFHnfm.png',
'item-024':'http://i.imgur.com/En31KMRm.png',
'item-025':'http://i.imgur.com/T04Udiym.png',
'item-026':'http://i.imgur.com/IQdCkVAm.png',
'item-027':'http://i.imgur.com/KtrJ6I7m.png',
'item-028':'http://i.imgur.com/KKrbimkm.png',
'item-029':'http://i.imgur.com/gkNov0bm.png',
'item-030':'http://i.imgur.com/u86HBAam.png',
'item-031':'http://i.imgur.com/9EFkFYMm.png',
'item-032':'http://i.imgur.com/ibnE2e7m.png',
'item-033':'http://i.imgur.com/CtaCKgFm.png',
'item-034':'http://i.imgur.com/GPe0Zsvm.png',
'item-035':'http://i.imgur.com/n9soSIXm.png',
'item-036':'http://i.imgur.com/baJrA4Hm.png',
'item-037':'http://i.imgur.com/oZtSRDtm.png',
'item-038':'http://i.imgur.com/a39vN5Em.png',
'item-039':'http://i.imgur.com/gdf4oURm.png',
'item-040':'http://i.imgur.com/qvcahjLm.png',
'item-041':'http://i.imgur.com/xQFdBurm.png',
'item-042':'http://i.imgur.com/YIAuAjIm.png',
'item-043':'http://i.imgur.com/sgFRpGam.png',
'item-044':'http://i.imgur.com/LfWJML6m.png',
'item-045':'http://i.imgur.com/gZ4DZe7m.png',
'item-046':'http://i.imgur.com/QQXZeo3m.png',
'item-047':'http://i.imgur.com/900ZxoYm.png',
'item-048':'http://i.imgur.com/MTcu4oYm.png',
'item-049':'http://i.imgur.com/xO0tnQom.png',
'item-050':'http://i.imgur.com/p9w2UXtm.png',
'item-051':'http://i.imgur.com/kaAziWUm.png',
'item-052':'http://i.imgur.com/fOuEIfvm.png',
'item-053':'http://i.imgur.com/PpXQWTTm.png',
'item-054':'http://i.imgur.com/uctZxjYm.png',
'item-055':'http://i.imgur.com/DEWwrJBm.png',
'item-056':'http://i.imgur.com/y49bAUpm.png'
}

(: ouvre la base XML:)
let $TEI := db:open("GITEI4")

 
(: construit un arbre XML à 2 niveaux (root/branche) :)
let $toBeCsv :=  <itemList>{
  for $item in $TEI/TEI
    let $title := $item//title[1]
    let $url := fn:string($item//publicationStmt/publisher/ref/@target)
    let $author := $item//author
    let $date := fn:string($item//publicationStmt/date/@when)
    let $rubrique := map:get($rubriques, fn:data($item//profileDesc[1]/textClass[1]/catRef[1]/@target))
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
    <Group>{$rubrique}</Group>
    <background></background>
  </item>
  }</itemList>


(: génère les données au format CSV :)
let $output := csv:serialize($toBeCsv, $options)

(: return $toBeCsv :)
(: return $output :)

(: écrit les données dans un fichier CSV :)
return 
    file:write-text("/home/nicolas/ownCloud/General_instin/data/script/teicsv2.csv", $output)
  
