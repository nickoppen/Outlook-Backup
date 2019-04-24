# Outlook-Backup
Back up your Outlook email to a database via ODBC and save attachements to an FTP server

This little routine breaks the dependence the outlook user has on the Outlook application to store old email files. If you want to back up your email in a way that allows you to move to a different email application, this routing extracts all email from .pst files currently linked to Outlook and stores them in a regular database.

### WARNING: The code contains "in the clear" usenames and passwords. Use only in an otherwise secure environment.

I wrote this using VBA on Outlook 2013. I'm quite happy with the results on this platform but I have no idea if it works with any other version.

My FTP server and mySQL database are the inbuilt apps that came with my QNAP NAS box that I bought in 2008. Newer versions have similar capabilities. QNAP now has a version of PostGreSQL an Synology supports MariaDB. I connect to the database via ODBC64. The FTP client is the command line tool supplied with Win10.

# Requirements
1. An SQL database (I'm using mySQL version 5.0.27 on my QNAP box)
2. An FTP server also on the QNAP
3. ODBC 64-bit on Win10
4. ftp on Win10

# What to do...
0. Download the scanOutlook.bas and tblEmail.sql files from this repository
1. Make sure your database server is running and available for network connections
2. Make sure your FTP server is running
3. Set up an ODBC connection to the database
4. Add the Developer tab to Outlook (Options... Customize Ribbon... and tick the Developer tab entry (which is off by default)
5. Go to the Developer Tab and click "Visual Basic" which brings up the Visual Basic editor
6. In the VB Editor window choose File | Import and load the "ScanOutlook.bas" file
7. In Tools | References make sure that the following tools are selected: Visual Basic For Applications; Microsoft Outlook 15.0 Object Library; mscorlib.dll; OLE Automation; Microsoft Office 15.0 Object Library; Microsoft OLE DB Simple Provider 1.5 Library; Microsoft ActiveX Data Ojects 2.7 Library
8. Open your database administrator interface and load tblEmail.sql into a new database, correcting any compatability issues that may arrise
9. Edit the VB code to reflect your chosen names in the Const statements at the top of the code
10. Edit the routine "generateFTPScript()" replacing "ftpUserName" with your user name and "ftpPassword" with your password.
11.Run the code and fix any issues with connectivity

If you have issues mid way through a run, you will need to delete everything that has been already loaded. The routine only loads email that are newer than those already loaded. The attachments will over-write previously saved files.

Once you have your connections and permissions have been sorted out, delete everthing again and run the whole lot from the top. You will be left with .cmd .ftp and .log files prefixed with the run date (in YYYY-MM-DD format). Delete manually as needed. I the Shell command with is asynchronous which means that the VB code exits before the generated cmd file has finished executing.

When everything is good, you can remove the Developer Tab from your ribbon and add a button that directly executes the code. To delete the developer tab, go to File | Options | Customize Ribbon and deselect Developer in the right hand box. To add a button to execute the code directly, add a new tab or open an existing one, and add a new group in the right hand panel. Then on the left hand side choose "Macros" in the "Choose Commands From:" drop-down list and the name "Project1.scanOutlookMail" (or whatever name you called it) will appear in the left hand box. Select the macro name and with your new tab and group selected in the right hand box click the "Add>>" button between the boxes.

This code is offered for personal use without support. Feel free to fork, extend, alter, modify as you please.
