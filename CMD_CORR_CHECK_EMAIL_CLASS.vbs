

    Function isValidEmail(sEmail)
        isValidEmail = False

        If TypeName("str")<>TypeName(sEmail) Then   
            Exit Function                               '   >>>
        End If

        Dim sAry, nSlices
        sAry = Split(sEmail, "@")
        nSlices = UBound(sAry) + 1

        If nSlices<>2 Then Exit Function                '   >>>

        If NOT isQuoted(sAry(0)) Then
            If haveIllegalLocPartContents(sAry(0)) Then 
                Exit Function                           '   >>>
            End If
        End If

        If NOT isDomainLiteral(sAry(1)) Then
            isValidEmail = isValidHostName(sAry(1))
            Exit Function                               '   >>>
        End If

        isValidEmail = isValidIP( Mid(sAry(1), 2, Len(sAry(1))-2) )
    End Function

    '   =====
    Function isValidHostName(sFQDN)
  
        isValidHostName = False
        If TypeName("str")<>TypeName(sFQDN) Then    
            Exit Function                               '   >>>
        End If

        If Len(sFQDN)>255 Then Exit Function            '   >>>

        Dim sAry, nSlices, nI, oRegX_1, oRegX_2, oRegX_3
        sAry = Split(sFQDN, ".")
        nSlices = UBound(sAry) + 1

        If nSlices<2 Then Exit Function                 '   >>>
        
        Const WRONG_HOST_PATRN_1 = "(^[^a-zA-Z])|([^a-zA-Z0-9]$)"
        Const WRONG_HOST_PATRN_2 = "[^a-zA-Z0-9-]"
        Const WRONG_HOST_PATRN_3 = "[^a-zA-Z]"
        Set oRegX_1 = new RegExp
        Set oRegX_2 = new RegExp
        Set oRegX_3 = new RegExp
        oRegX_1.Pattern = WRONG_HOST_PATRN_1
        oRegX_2.Pattern = WRONG_HOST_PATRN_2
        oRegX_3.Pattern = WRONG_HOST_PATRN_3

        For nI=0 To nSlices-1
            If Len(sAry(nI))>63 OR sAry(nI)="" Then 
                Exit Function                           '   >>>
            End If

            If nI = nSlices-1 Then
                If Len(sAry(nI))<2 Then Exit Function   '   >>>
                If oRegX_3.Test(sAry(nI)) Then Exit Function'   >>>
            End If

            If ( oRegX_1.Test(sAry(nI)) OR oRegX_2.Test(sAry(nI)) ) Then
                Exit Function                           '   >>>
            End If
        Next

        isValidHostName = True
    End Function

    '   =====
    Function isValidIP(sIP)
    '   Will return true if passed string - "IP [:portNo]" is OK

        isValidIP = False
        If TypeName("str")<>TypeName(sIP) Then  
            Exit Function                               '   >>>
        End If

        Dim sTmpIP, oRegX, sAry, nSlices
        Const IP_PART = "(\d+)"
        Set oRegX = new RegExp
        oRegX.Pattern = IP_PART
        oRegX.Global = True
        Set sAry = oRegX.Execute(sIP)
        nSlices = sAry.Count

        Select Case nSlices
            Case 4
                If (    (sAry(0)>0) AND (sAry(0)<255)_
                    AND (sAry(1)<=255)_
                    AND (sAry(2)<=255)_
                    AND (sAry(3)<=255)      ) Then

                    sTmpIP = sAry(0) & "." & sAry(1) & "." &_
                            sAry(2) & "." & sAry(3)

                    If (sTmpIP=sIP) Then
                        isValidIP = True
                        Exit Function                   '   >>>
                    End If
                End If
            Case 5
                If (    (sAry(0)>0) AND (sAry(0)<255)_
                    AND (sAry(1)<=255)_
                    AND (sAry(2)<=255)_
                    AND (sAry(3)<=255)_
                    AND (sAry(4)>0) AND (sAry(4)<65535)     ) Then

                    sTmpIP = sAry(0) & "." & sAry(1) & "." &_
                            sAry(2) & "." & sAry(3) & ":" & sAry(4)

                    If (sTmpIP=sIP) Then
                        isValidIP = True
                        Exit Function                   '   >>>
                    End If
                End If
            Case Else
                Exit Function                           '   >>>
        End Select

    End Function

    Private Function isQuoted(sStr)
        Const QUOTED = "^"".+""$"
        Dim oRegX
        Set oRegX = new RegExp
        oRegX.Pattern = QUOTED
        isQuoted = oRegX.Test(sStr)
    End Function
    '   ---
    Private Function haveIllegalLocPartContents(sStr) 
        Const ILLEGAL_CHARS = "["" @<>\[\]\(\):;,]"
        Dim oRegX
        Set oRegX = new RegExp
        oRegX.Pattern = ILLEGAL_CHARS
        haveIllegalLocPartContents = oRegX.Test(sStr)
    End Function
    '   ---
    Private Function isDomainLiteral(sStr)
        Const DOM_LITERAL = "^\[.+\]$"
        Dim oRegX
        Set oRegX = new RegExp
        oRegX.Pattern = DOM_LITERAL
        isDomainLiteral = oRegX.Test(sStr)
    End Function
    '   --------------------------------------------------------------

' ====================== END OF CLASS ================================

