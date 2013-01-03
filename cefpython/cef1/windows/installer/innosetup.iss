; Parts of this code was taken from wxPython/distrib/make_installer.py

[Setup]

AppName = CEF Python 1
AppVersion = 0.52
AppVerName = CEF Python 1 version 0.52 for Python 2.7 32bit

AppPublisher = Czarek Tomczak
AppPublisherURL = http://code.google.com/cefpython/
AppSupportURL = https://groups.google.com/group/cefpython?hl=en
AppUpdatesURL = http://code.google.com/cefpython/
AppCopyright = Copyright 2012 Czarek Tomczak

DefaultDirName = {code:GetInstallDir|c:\Python}

DefaultGroupName = CEF Python 1
PrivilegesRequired = none
DisableStartupPrompt = yes
Compression = zip
DirExistsWarning = no
DisableReadyMemo = yes
DisableReadyPage = yes
DisableDirPage = no
DisableProgramGroupPage = no
UsePreviousAppDir = yes
UsePreviousGroup = yes

SourceDir = C:\cefpython\cefpython-src\cefpython\cef1\windows\binaries
OutputDir = C:\cefpython\cefpython-src\cefpython\cef1\windows\installer\Output
OutputBaseFilename = cefpython1_v0.52_win32_installer

UninstallFilesDir = {app}\cefpython1
LicenseFile = C:\cefpython\cefpython-src\cefpython\cef1\windows\binaries\LICENSE.txt

[Icons]

Name: "{group}\Examples"; Filename: "{app}\cefpython1\examples"
Name: "{group}\Uninstall Package"; Filename: "{uninstallexe}"

[Run]

Filename: "{app}\cefpython1\examples"; Flags: postinstall shellexec;

[Files]

Source: "*.dll"; DestDir: "{app}\cefpython1"; Flags: ignoreversion;
Source: "*.pak"; DestDir: "{app}\cefpython1"; Flags: ignoreversion;
Source: "locales\*.pak"; DestDir: "{app}\cefpython1\locales"; Flags: ignoreversion;
Source: "C:\cefpython\cefpython-src\cefpython\cef1\windows\installer\__init__.py.install"; DestDir: "{app}\cefpython1"; DestName: "__init__.py"; Flags: ignoreversion;
Source: "cefclient.exe"; DestDir: "{app}\cefpython1"; Flags: ignoreversion;
Source: "cefpython_py27.py"; DestDir: "{app}\cefpython1"; Flags: ignoreversion;
Source: "cefpython_py27.pyd"; DestDir: "{app}\cefpython1"; Flags: ignoreversion;
Source: "LICENSE.txt"; DestDir: "{app}\cefpython1"; Flags: ignoreversion;
Source: "Microsoft.VC90.CRT.manifest"; DestDir: "{app}\cefpython1"; Flags: ignoreversion;
Source: "README.txt"; DestDir: "{app}\cefpython1"; Flags: ignoreversion;

Source: "cefadvanced.html"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "cefadvanced.py"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "cefsimple.html"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "cefsimple.py"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "cefwindow.py"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "cefwxpanel.py"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "cefwxpanel_sample1.py"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "cefwxpanel_sample2.py"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "icon.ico"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "panda3d_.py"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "pygtk_.py"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "pyqt.py"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "pyside.py"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;
Source: "wxpython.py"; DestDir: "{app}\cefpython1\examples"; Flags: ignoreversion;

[UninstallDelete]

Type: files; Name: "{app}\cefpython1\*.pyc";
Type: files; Name: "{app}\cefpython1\examples\*.pyc";
Type: files; Name: "{app}\cefpython1\examples\*.log";

[Code]

program Setup;
var
    PythonDir  : String;
    InstallDir : String;

function InitializeSetup(): Boolean;
begin

    if not RegQueryStringValue(HKEY_CURRENT_USER,
            'Software\Python\PythonCore\2.7\InstallPath',
            '', PythonDir) then begin

        if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
                'Software\Python\PythonCore\2.7\InstallPath',
                '', PythonDir) then begin

            if not RegQueryStringValue(HKEY_CURRENT_USER,
                    'Software\Wow6432Node\Python\PythonCore\2.7\InstallPath',
                    '', PythonDir) then begin

                if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
                        'Software\Wow6432Node\Python\PythonCore\2.7\InstallPath',
                        '', PythonDir) then begin

                    MsgBox('No installation of Python 2.7 '
                           + 'found in registry.' + #13 + 'Be sure to enter '
                           + 'a pathname that places CEF Python 1 on the '
                           + 'PYTHONPATH',
                           mbConfirmation, MB_OK);
                    PythonDir := 'C:\Python';
                end;
            end;
        end;
    end;

    InstallDir := PythonDir + '\Lib\site-packages';
    Result := True;
end;

function GetInstallDir(Default: String): String;
begin
    Result := InstallDir;
end;

function UninstallOld(FileName: String): Boolean;
var
    ResultCode: Integer;
begin
    Result := False;
    if FileExists(FileName) then begin
        Result := True;
        ResultCode := MsgBox('A prior CEF Python 1 installation was found in '
                + 'this directory.  It' + #13 + 'is recommended that it be '
                + 'uninstalled first.' + #13#13 + 'Should I do it?',
                mbConfirmation, MB_YESNO);
        if ResultCode = IDYES then begin
            Exec(FileName, '/SILENT', WizardDirValue(), SW_SHOWNORMAL,
                 ewWaitUntilTerminated, ResultCode);
        end;
    end;
end;

function NextButtonClick(CurPage: Integer): Boolean;
begin
    Result := True;
    if CurPage <> wpSelectDir then Exit;
    UninstallOld(WizardDirValue() + '\cefpython1\unins000.exe')
end;
