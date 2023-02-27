%dw 2.0
output application/json
import * from dw::core::Binaries
import substringBefore,substringAfter from dw::core::Strings
import decodeURI from dw::core::URL
fun d(xyz) = if(isEmpty(xyz)) null else decodeURI (xyz default "")
var attribs = attributes.queryParams
var query = d(attribs."query")
var nquery = d(attribs."nquery")
var select = d(attribs."select") default "*"
var table = attributes.uriParams."table" default attribs.table default "NULL"
var join = if(! isEmpty(attribs.join)) read(fromBase64(attribs."join" default "e30="),"application/json") else null
var distinct = d(attribs."distinct") default false
var filter = d(attribs."filter")
var order = d(attribs."order")
var dec = d(attribs.descending) default false
fun getjoin(data) = ("$(upper(data."jointype")) JOIN $(data."table") ON $(data."joinclause")") default null
var join_query = if(isEmpty(join)) null else getjoin(join default {jointype : "inner",table : "xyz","joinclause": "a.bid=b.xyz"})
var countquery = if(! isEmpty(query)) "SELECT count(" ++ (lower(query default "") substringBefore  " from" )[7 to -1] ++")" ++" from" ++(lower(query default "") substringAfter " from" )  else null
var page_size = d(attribs.'size') as Number default 1000
var cpage = (d(attribs.'page') as Number default 1) 
var page = if(cpage > 0) cpage else 1
var tail_part=(if(! isEmpty(join_query)) " $(join_query default "")" else "")
++ (if(! isEmpty(filter)) " where $(filter default "")" else "")
++ (if(! isEmpty(order)) " ORDER BY $(order default '')$(if(dec) ' DESC' else '')" else "")
var climit=" LIMIT $(page_size) OFFSET $((page-1) * page_size)"
var nlimit=" LIMIT 1 OFFSET $((page) * page_size)"
---
{
	main : (if(! isEmpty(query)) query else "SELECT $(if(distinct) "DISTINCT " else "")$(select) from $(table)" ++ tail_part ++ climit),
	count : if(attribs.count as Boolean default false)(if(! isEmpty(query)) countquery else "SELECT COUNT($(if(distinct) "DISTINCT " else "")$(select)) from $(table)" ++ tail_part ++ " LIMIT 1") else null,
	next : if((!isEmpty(query)) == (!isEmpty(nquery))) (if(! isEmpty(nquery)) nquery else "SELECT $(if(distinct) "DISTINCT " else "")$(select) from $(table)" ++ tail_part ++ nlimit) else null
}
