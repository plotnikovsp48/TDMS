use CMD_KD_ORDER_LIB


set order = thisApplication.GetObjectByGUID("{8D859ABA-903D-4FC2-89AE-3F1EEB5814A8}")
set doc = thisApplication.GetObjectByGUID("{7191AAE5-B2AA-48DF-BC4F-D2CA81A0F82D}")
set user =  thisApplication.Users("USER_85551D33_2F27_4DE2_A43F_817174A8F610")
set userto =  thisApplication.Users("USER_76F3D54C_893F_4D62_A988_498E36152A99")
'CreateOrders order, doc 
' docObj, objType, userTo, userFrom, resol, txt,planDate)
'call CreateSystemOrder( doc, "OBJECT_KD_ORDER_REP", userto, user, "NODE_KD_EXECUTE","создать ид","20.10.17")
call CreateOrderAdnShow( doc, "OBJECT_KD_ORDER_REP", userto, user, "NODE_KD_EXECUTE","создать ид","20.10.17", true)
' CreateAgreeObj(obj, silent)

'set oYear = GET_FOLDER_OFFER("2014")
'thisApplication.DebugPrint oYear.description
