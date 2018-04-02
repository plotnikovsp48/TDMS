'QUERY_ALL_OBJECT_TEMPLATE_LISTS

sub repair()
  set query = thisApplication.CreateQuery()
  query.AddCondition tdmQueryConditionObjectDef, "OBJECT_TEMPLATE_LIST"
  for each i in query.objects
    if i.attributes.count < i.objectdef.attributedefs.count then
      for each j in i.objectdef.attributedefs
        if not i.attributes.has(j.sysname) then
          i.attributes.create j
        end if
      next
    end if
  next
  
end sub

repair()
