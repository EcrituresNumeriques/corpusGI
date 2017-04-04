xquery version "3.0" ;
module namespace instin.webapp = 'instin.webapp' ;

(:~
 : This module is a RESTXQ for Instin
 :
 : @version 0.1
 : @since 2017-03-22
 : @author laconis
 :
 : This module uses SynopsX publication framework 
 : see https://github.com/synopsx
 : It is distributed under the GNU General Public Licence, 
 : see http://www.gnu.org/licenses/
 :
 :)

import module namespace restxq = 'http://exquery.org/ns/restxq' ;

import module namespace G = 'synopsx.globals' at '../../../globals.xqm' ;
import module namespace synopsx.models.synopsx= 'synopsx.models.synopsx' at '../../../models/synopsx.xqm' ;

(: Put here all import modules declarations as needed :)
import module namespace synopsx.models.tei = 'synopsx.models.tei' at '../../../models/tei.xqm' ;
import module namespace synopsx.models.ead = 'synopsx.models.ead' at '../../../models/ead.xqm' ;

import module namespace synopsx.mappings.htmlWrapping = 'synopsx.mappings.htmlWrapping' at '../../../mappings/htmlWrapping.xqm' ;

(: import module namespace instin.mappings.htmlWrapping = 'instin.mappings.htmlWrapping' at '../mappings/htmlWrapping.xqm' ; :)

declare default function namespace 'instin.webapp' ;


declare variable $instin.webapp:project := 'instin' ;
declare variable $instin.webapp:db := synopsx.models.synopsx:getProjectDB($instin.webapp:project) ;


(:~
 : fonction ressource pour la racine
 :
 :)
declare 
  %restxq:path('/instin')
function index() {
  <rest:response>
    <http:response status="303" message="See Other">
      <http:header name="location" value="/instin/home"/>
    </http:response>
  </rest:response>
};


(:~
 : this resource function is the html representation of the corpus resource
 :
 : @return an html representation of the corpus resource with a bibliographical list
 : the HTML serialization also shows a bibliographical list
 :)
declare 
  %restxq:path('/instin/home')
  %rest:produces('text/html')
  %output:method("html")
  %output:html-version("5.0")
function home() {
  let $queryParams := map {
    'project'  : $instin.webapp:project,
    'dbName'   : 'instin',  
    'model'    : 'tei' ,
    'function' : 'getItems'
    }
  let $function := synopsx.models.synopsx:getModelFunction($queryParams)
  let $data := fn:function-lookup($function, 1)($queryParams)
  let $outputParams := map {
    'layout'  : 'home.xhtml',
    'pattern' : 'pattern.xhtml',
    'xquery'  : 'teiInstin2html'
(:        'xsl':'tei2html':)
    }  
 return synopsx.models.synopsx:htmlDisplay($queryParams, $outputParams)
 (: return $data :)
};
