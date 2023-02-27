%dw 2.0
output application/json
fun addit(p,c,a): String= if(p is Null) c else "$(p)$(a)$(c)"
fun findnulls(data,SuperKey = null) : Array<String|Null> = 
flatten(
if(data is Object) data pluck findnulls($,addit(SuperKey,$$,"."))
else if (data is Array) data map findnulls($,addit(SuperKey,"[$$]",""))
else
    if(data is Null) [SuperKey] else []
)
---
payload map {
	($),
	"fieldsToNull" : findnulls($)
}