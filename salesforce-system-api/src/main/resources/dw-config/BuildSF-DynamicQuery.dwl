%dw 2.0
output application/json
fun d(Data) = do{
	import * from dw::core::URL
	---
	if(Data is Null) null else decodeURI(Data)
}
var attribs = attributes.queryParams
var select = d(attribs.select default "Fields(ALL)")
var entity = d(attribs.table) 
var condition = d(attribs.filter) as String default null
var pagesize= d(attribs.pagesize default 2000) as Number
var page = d(attribs.page default 1) as Number
var order = d(attribs.order) as String default null
var pazination = lower(d(attribs.pazination default "enabled")) != "disabled"
var count = d(attribs.count default true)
---
{
	Query : "SELECT $(select) FROM $(entity)" 
		++ (if(!isEmpty(condition)) " WHERE $(condition default "")" else "") 
		++ (if(!isEmpty(order)) " ORDER $(order default "")" else "") 
		++ (if(pazination) " LIMIT $(pagesize) OFFSET $((page-1) * pagesize)" else ""),
	CountQuery : if(count) ("SELECT COUNT($(select)) Rec_count FROM $(entity)" 
		++ (if(!isEmpty(condition)) " WHERE $(condition default "")" else "") ) else null

}