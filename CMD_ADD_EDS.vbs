Option explicit

dim filename, signedFilename

ThisObject.CheckOut

filename = ThisObject.Files.Main.WorkFileName

signedFilename = filename & ".sing"

call singFile (filename, signedFilename)

ThisObject.CheckIn

sub singFile (f, sF)
const BASE64_TYPE = 0
const DER_TYPE = 1
const REGISTRY_STORE = 0
const PLAIN_DATA = 0
const SIGNED_DATA = 2
const SIGN_WIZARD_TYPE = 2
const ALL_OK = 0

Dim objProfile, objProfileStore, objProfiles
Dim oPKCS7Message

Set objProfileStore = CreateObject("DigtCrypto.ProfileStore")
objProfileStore.Open REGISTRY_STORE

Set objProfiles = objProfileStore.Store
If objProfiles.Count > 0 then
  Set objProfile = objProfiles.DefaultProfile
else
  Set objProfile = CreateObject("DigtCrypto.Profile")
end if
  Set oPKCS7Message = CreateObject ("DigtCrypto.PKCS7Message")
  oPKCS7Message.Profile = objProfile
  oPKCS7Message.Load PLAIN_DATA, CStr (filename), ""
  oPKCS7Message.Sign
  oPKCS7Message.Save SIGNED_DATA, BASE64_TYPE, sF
  set oPKCS7Message = nothing
End Sub
