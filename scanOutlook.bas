Attribute VB_Name = "Scan"

Sub scanOutlookMail()
    Const strConn As String = "DSN=MyODBCConnectionToTheDatabase"
    Const remoteAttmtStore As String = "Backup/someLocation"
    Const localAttmtStore As String = "C:\myOutlookMailFolder"
    Const ftpServer As String = "myFTPServer"
    Dim ignoreAttmt As ArrayList
    Set ignoreAttmt = New ArrayList
    ignoreAttmt.Add "graycol.gif"   ''common useless gifs
    ignoreAttmt.Add "ecblank.gif"
    
    Dim olApp As Outlook.Application
    Dim olNs As Outlook.NameSpace
    Dim olFolder As Outlook.MAPIFolder
    Dim eFolder As Outlook.Folder
    Dim maxDate As Date
    
    Dim conn As ADODB.Connection
    Dim rst As ADODB.Recordset
    Set conn = New ADODB.Connection
    conn.ConnectionString = strConn
    On Error GoTo opps  ' could be the ODBC or the database
    conn.Open
    On Error GoTo 0

    Dim attmtSubStores As ArrayList
    Set attmtSubStores = New ArrayList
    
    Set olApp = New Outlook.Application
    Set olNs = olApp.GetNamespace("MAPI")

    uniquer = 1 'a variable to force conversationIndexes to be unique if they alreay exist and are greater than 256 characters
    For Each olFolder In olNs.Folders
        For Each eFolder In olFolder.Folders
            If (eFolder.Name = "Inbox") Or (eFolder.Name = "Sent Items") Then
                ' get the most recent stored email for each account
                On Error GoTo opps  ' db could be missing
                Set rst = conn.Execute("SELECT max(recievedDate) AS maxDate from tblEmail WHERE sourceFile = '" + olFolder.FolderPath + "' AND topFolder = '" + eFolder.Name + "'")
                On Error GoTo 0
                If IsNull(rst!maxDate) Then
                    maxDate = CDate("01/01/1970")
                Else
                    maxDate = CDate(rst!maxDate)
                End If
                rst.Close
                ' scan through each account's inbox and sent items for unarchived email
                Call scanFolder(eFolder, localAttmtStore, attmtSubStores, olFolder.FolderPath, eFolder.Name, maxDate, ignoreAttmt, conn)
            End If
        Next eFolder
    Next
    Set olFolder = Nothing
    conn.Close
    
    If attmtSubStores.Count > 0 Then
        Call generateFTPScript(attmtSubStores, ftpServer, localAttmtStore, remoteAttmtStore)
    End If
    
    Debug.Print "Done..."
    Exit Sub
    
opps:
    MsgBox "Something went wrong with the database connection..."
    Exit Sub
End Sub

Function scanFolder(topFolder As Outlook.Folder, attachmentStore As String, attmtSubStores As ArrayList, sourceFile As String, folderName As String, maxDate As Date, ignoreAttmt As ArrayList, conn As ADODB.Connection)
    Dim eFolder As Outlook.Folder
    Dim folderItem As Object
    Dim olMail As Outlook.MailItem
    Dim attachmentSubStore, subStore As String
    Dim attmt As Outlook.Attachment
    Dim attmts As String
    Dim recip As Outlook.Recipient
    Dim recipients As String
    Dim conversationIndex As String
    Dim unk As Integer
    Dim newFileName As String   ' the dequoted file name
    Dim strInsert, VALUES As String
    
    unk = 0
    For Each folderItem In topFolder.Items
        If TypeOf folderItem Is MailItem Then
            attmts = ""
            recipients = ""
            subStore = ""
            
            Set olMail = folderItem
            If folderItem.ReceivedTime >= maxDate Then
                conversationIndex = Left(olMail.conversationIndex, 256)
                
                ' none found with that combination of coversationId and conversationIndex so we have not stored this email before
                If uniqueConversation(olMail.conversationId, conversationIndex, conn) Then
                    
                    For Each recip In olMail.recipients
                        recipients = recipients + recip.Address + ";"
                    Next recip
                    recipients = Left(dequote(recipients), 255)  ' truncate huge mailing lists
                    
                    ' save all attachements to a local folder building a list of file names in the process
                    If olMail.Attachments.Count > 0 Then
                        subStore = Format(olMail.ReceivedTime, "YYYY-MM-DD")
                        
                        'save all attachments to the sub directory removing quoted names as we go
                        For Each attmt In olMail.Attachments
                            newFileName = checkFileName(attmt, unk)
                            If Not ignoreAttmt.Contains(newFileName) Then
                                attachmentSubStore = prepareSubStore(attachmentStore, subStore, attmtSubStores)
                                attmt.SaveAsFile (attachmentSubStore + "\" + newFileName)
                                attmts = attmts + newFileName + ";"
                            End If
                        Next attmt
                    End If
                    attmts = Left(dequote(attmts), 255)
    
                    ' insert all of the data related to one email in one big insert
                    strInsert = "INSERT INTO tblEmail "
                    VALUES = " VALUES ('" + olMail.conversationId + "', '" + conversationIndex + "', '" + sourceFile + "', '" + folderName + "', '" + doublequote(olMail.Subject) _
                                + "', '" + doublequote(olMail.Sender) + "', '" + olMail.SenderEmailAddress + "', '" + dequote(olMail.CC) + "', '" + dequote(olMail.To) + "', '" _
                                + Format(olMail.ReceivedTime, "YYYY-MM-DD HH:MM:SS") + "', '" + Format(olMail.SentOn, "YYYY-MM-DD HH:MM:SS") _
                                + "', '" + recipients + "', '" + demoji(doublequote(olMail.Body)) + "', '" + subStore + "', '" + attmts + "')"
                      Debug.Print VALUES
                    conn.Execute strInsert + VALUES
                End If ' not alread stored
            End If ' within date range
        End If  ' is mail item
    Next folderItem
    For Each eFolder In topFolder.Folders
        Call scanFolder(eFolder, attachmentStore, attmtSubStores, sourceFile, folderName, maxDate, ignoreAttmt, conn)
    Next eFolder
    Exit Function
    

End Function

Private Function uniqueConversation(conversationId As String, ByRef conversationIndex As String, conn As ADODB.Connection) As Boolean
' A function to check that the email has not been stored before
' If the conversationIndex is > 256 then the email has gone backwards and forwards too many times making the conversationIndex longer that the db field can store
' Therefore if the Id/Index pair have been stored before and the Index is > 256 then insert a unique string onto the front
' conversationIndex has already been truncated to 256 chars before the call

    Dim countRec As Integer
    Dim strSelect As String
    Dim rst As ADODB.Recordset

    strSelect = "SELECT count( * ) AS countRec " + _
                "FROM tblEmail " + _
                "WHERE conversationId = '" + conversationId + "' " + _
                "AND conversationIndex = '" + conversationIndex + "'"
                
    Set rst = conn.Execute(strSelect)
    countRec = rst!countRec
    rst.Close
    
    If countRec = 0 Then
        uniqueConversation = True
        Exit Function
    Else
        If (Len(conversationIndex) = 256) Then
            Mid(conversationIndex, 1) = "MADE_UNIQUE" + Format(Now(), "YYYYMMDDHHMMSS") + Format(CInt(Rnd() * 9999), "0000")    'force in conversation index to be unique
            uniqueConversation = True                                                                                           'it might mean that there is a duplicate
            Exit Function                                                                                                       'but it won't happen very often
        End If
    End If
    uniqueConversation = False

End Function

Private Function prepareSubStore(attachmentStore As String, subStore As String, attmtSubStores As ArrayList)
    
    'remember the sub-directory name for ftp and deleteion later
    If Not attmtSubStores.Contains(subStore) Then
        attmtSubStores.Add subStore
    End If
    
    ' create the sub-directory if needed
    attachmentSubStore = attachmentStore + "\" + subStore
    If Dir(attachmentSubStore, vbDirectory) = "" Then
        MkDir (attachmentSubStore)
    End If
    prepareSubStore = attachmentSubStore
End Function

Private Function checkFileName(attmt As Outlook.Attachment, unk As Integer) As String

    On Error GoTo nameMissingError
        newFileName = dequote(attmt.FileName)
    On Error GoTo 0
    
    If newFileName <> "" Then
        checkFileName = newFileName
        Exit Function
    End If
        

nameMissingError:
    newFileName = "unk" + Trim(str(unk)) 'attachments pasted directly into an email from the clipboard have no name
    unk = unk + 1
    checkFileName = newFileName
    
End Function

Private Function doublequote(str As String)

    Dim charPos As Long
    charPos = InStr(1, str, "'")
    While charPos
        str = Mid(str, 1, charPos) + Mid(str, charPos)
        charPos = InStr(charPos + 2, str, "'")
    Wend
    charPos = InStr(1, str, "\")
    While charPos
        str = Mid(str, 1, charPos) + Mid(str, charPos)
        charPos = InStr(charPos + 2, str, "\")
    Wend
    doublequote = str

End Function

Private Function dequote(str As String)

    Dim charPos As Long
    charPos = InStr(1, str, "'")
    While charPos
        str = Mid(str, 1, charPos - 1) + Mid(str, charPos + 1)
        charPos = InStr(charPos, str, "'")
    Wend
    charPos = InStr(1, str, "\")
    While charPos
        str = Mid(str, 1, charPos - 1) + Mid(str, charPos + 1)
        charPos = InStr(charPos, str, "\")
    Wend
    dequote = str

End Function

Private Function demoji(txt As String)
    
    Dim regEx As Object
    
    Set regEx = CreateObject("vbscript.regexp")
    regEx.Pattern = "[^\u0000-\u007F]"
    demoji = regEx.Replace(txt, "")

End Function


Private Function generateFTPScript(subStores As ArrayList, ftpServer As String, localAttmtStore As String, remoteAttmtStore As String)

    Dim remoteBaseDir As String
    Dim baseFileName, scriptFilename, cmdFileName As String
    Dim shellId As Long
    baseFileName = Format(Now(), "YYYY-MM-DD")
    scriptFilename = localAttmtStore + "\" + baseFileName + ".ftp"
    cmdFileName = localAttmtStore + "\" + baseFileName + ".cmd"
    Open scriptFilename For Output As #1
    Open cmdFileName For Output As #2
    
    subStores.Sort
    remoteBaseDir = Left(subStores(0), 4)
    Print #2, "ftp -i -s:" + scriptFilename + " > " + localAttmtStore + "\" + baseFileName + ".log"
    Print #1, "open " + ftpServer
    Print #1, "myFTPUser"          ''' FTP user
    Print #1, "myFTPpassword"        ''' FTP password
    Print #1, "binary"
    Print #1, "lcd " + localAttmtStore
    Print #1, "cd " + remoteAttmtStore
    Print #1, "mkdir " + remoteBaseDir
    Print #1, "cd " + remoteBaseDir
    
    For i = 0 To subStores.Count - 1
        If Left(subStores(i), 4) <> remoteBaseDir Then
            remoteBaseDir = Left(subStores(i), 4)
            Print #1, "cd /" + remoteAttmtStore
            Print #1, "mkdir " + remoteBaseDir
            Print #1, "cd " + remoteBaseDir
        End If
        Print #1, "mkdir " + subStores(i)
        Print #1, "cd " + subStores(i)
        Print #1, "mput .\" + subStores(i) + "\*"
        Print #1, "cd .."
        Print #2, "del /Q " + localAttmtStore + "\" + subStores(i)
        Print #2, "rmdir /Q " + localAttmtStore + "\" + subStores(i)
            
    Next i
    Print #1, "bye"
    Print #2, "exit"
    Close #1
    Close #2
    shellId = Shell(cmdFileName, vbNormalNoFocus)
End Function
