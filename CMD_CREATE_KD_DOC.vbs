
    set objType = thisApplication.ObjectDefs("OBJECT_KD_DOC")
    set Create_Doc =  thisApplication.ExecuteScript("CMD_KD_COMMON_LIB","Create_Doc_by_Type",objType, nothing)
