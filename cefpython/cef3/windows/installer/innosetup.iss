; Parts of this code was taken from wxPython/distrib/make_installer.py

[Setup]

AppName = CEF Python 3 for Python 3.2
AppVersion = v13
AppVerName = CEF Python 3 version v13 for Python 3.2 32bit

AppPublisher = Czarek Tomczak
AppPublisherURL = http://code.google.com/cefpython/
AppSupportURL = https://groups.google.com/group/cefpython?hl=en
AppUpdatesURL = http://code.google.com/cefpython/
AppCopyright = Copyright 2012-2013 Czarek Tomczak

DefaultDirName = {code:GetInstallDir|c:\Python}

DefaultGroupName = CEF Python 3 for Python 3.2
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

SourceDir = C:\cefpython\cefpython-src\cefpython\cef3\windows\binaries
OutputDir = C:\cefpython\cefpython-src\cefpython\cef3\windows\installer\Output
OutputBaseFilename = cefpython3_v13_py32_win32_installer

UninstallFilesDir = {app}\cefpython3
LicenseFile = C:\cefpython\cefpython-src\cefpython\cef3\windows\binaries\LICENSE.txt

[Icons]

Name: "{group}\Examples"; Filename: "{app}\cefpython3\examples"
Name: "{group}\Uninstall Package"; Filename: "{uninstallexe}"

[Run]

Filename: "{app}\cefpython3\examples"; Flags: postinstall shellexec;

[Files]

Source: "*.dll"; DestDir: "{app}\cefpython3"; Flags: ignoreversion;
Source: "*.pak"; DestDir: "{app}\cefpython3"; Flags: ignoreversion;
Source: "locales\*.pak"; DestDir: "{app}\cefpython3\locales"; Flags: ignoreversion;
Source: "C:\cefpython\cefpython-src\cefpython\cef3\windows\installer\__init__.py.install"; DestDir: "{app}\cefpython3"; DestName: "__init__.py"; Flags: ignoreversion;
Source: "cefclient.exe"; DestDir: "{app}\cefpython3"; Flags: ignoreversion;
Source: "cefpython_py27.pyd"; DestDir: "{app}\cefpython3"; Flags: ignoreversion;
Source: "cefpython_py32.pyd"; DestDir: "{app}\cefpython3"; Flags: ignoreversion;
Source: "LICENSE.txt"; DestDir: "{app}\cefpython3"; Flags: ignoreversion;
Source: "Microsoft.VC90.CRT.manifest"; DestDir: "{app}\cefpython3"; Flags: ignoreversion;
Source: "README.txt"; DestDir: "{app}\cefpython3"; Flags: ignoreversion;
Source: "subprocess.exe"; DestDir: "{app}\cefpython3"; Flags: ignoreversion;

Source: "cefwindow.py"; DestDir: "{app}\cefpython3\examples"; Flags: ignoreversion;
Source: "example.py"; DestDir: "{app}\cefpython3\examples"; Flags: ignoreversion;
Source: "example.html"; DestDir: "{app}\cefpython3\examples"; Flags: ignoreversion;
Source: "icon.ico"; DestDir: "{app}\cefpython3\examples"; Flags: ignoreversion;
Source: "pygtk_.py"; DestDir: "{app}\cefpython3\examples"; Flags: ignoreversion;
Source: "pyqt.py"; DestDir: "{app}\cefpython3\examples"; Flags: ignoreversion;
Source: "pyside.py"; DestDir: "{app}\cefpython3\examples"; Flags: ignoreversion;
Source: "wxpython.py"; DestDir: "{app}\cefpython3\examples"; Flags: ignoreversion;

[UninstallDelete]

Type: files; Name: "{app}\cefpython3\*.pyc";
Type: files; Name: "{app}\cefpython3\examples\*.pyc";
Type: files; Name: "{app}\cefpython3\examples\*.log";
Type: filesandordirs; Name: "{app}\cefpython3\__pycache__"

[Code]

program Setup;
var
    PythonDir  : String;
    InstallDir : String;

function InitializeSetup(): Boolean;
begin

    if not RegQueryStringValue(HKEY_CURRENT_USER,
            'Software\Python\PythonCore\3.2\InstallPath',
            '', PythonDir) then begin

        if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
                'Software\Python\PythonCore\3.2\InstallPath',
                '', PythonDir) then begin

            if not RegQueryStringValue(HKEY_CURRENT_USER,
                    'Software\Wow6432Node\Python\PythonCore\3.2\InstallPath',
                    '', PythonDir) then begin

                if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
                        'Software\Wow6432Node\Python\PythonCore\3.2\InstallPath',
                        '', PythonDir) then begin

                    MsgBox('No installation of Python 3.2 '
                           + 'found in registry.' + #13 + 'Be sure to enter '
                           + 'a pathname that places CEF Python 3 on the '
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
        ResultCode := MsgBox('A prior CEF Python 3 installation was found in '
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
    UninstallOld(WizardDirValue() + '\cefpython3\unins000.exe')
end;
