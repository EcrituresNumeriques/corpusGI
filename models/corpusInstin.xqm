xquery version "3.0" ;
module namespace instin.models.instin = 'instin.models.corpusInstin' ;

(:~
 : This module is a TEI models library for paris' guidebooks edition
 :
 : @version 0.1
 : @since 2017-03-22
 : @author laconis
 :
 : derivated from
 : @author emchateau (Cluster Pasts in the Present)
 : @since 2014-11-10 
 : @version 0.2
 : @see http://guidesdeparis.net
 :
 : This module uses SynopsX publication framework 
 : see https://github.com/ahn-ens-lyon/synopsx
 : It is distributed under the GNU General Public Licence, 
 : see http://www.gnu.org/licenses/
 :
 :)

import module namespace synopsx.models.synopsx = 'synopsx.models.synopsx' at '../../../models/synopsx.xqm' ;

declare namespace tei = 'http://www.tei-c.org/ns/1.0' ;

declare default function namespace 'instin.models.corpusInstin' ;

(:~
 : this function get an ItemGI list
 :
 : @param $queryParams the request params sent by restxq
 : @return a map with meta and content
 :)
declare function getItems($queryParams as map(*)) as map(*) {
  (: let $itemsGI := synopsx.models.synopsx:getDb($queryParams)//tei:TEI :)
  let $itemsGI := db:open('instin')//*:TEI
  let $meta := map{
    'title' : 'Liste d’items'
    (: 'all' : $itemsGI :)
    (: 'keywords' : $itemsGI//erudit:liminaire/erudit:grmotcle/erudit:motcle/text() :)
    }
  let $content := for $itemGI in $itemsGI return map {
    'title' : 'titre1', (:$itemGI//tei:title/text():)
    'author' : 'auteur' (:$itemGI//tei:author/text():)
    (: 'datePublication' : fn:string($itemGI//tei:publicationStmt/date[@when]) :)
    }
  return  map{
    'meta'    : $meta,
    'content' : $content
    }
};