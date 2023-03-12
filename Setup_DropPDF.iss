#define MyAppName "DropPDF"
#define MyAppVersion "1.1"
#define MyAppPublisher "yann83"
#define MyAppExeName MyAppName+".exe"
#define MyDefaultDirName "C:\"+MyAppName
#define MySubkey "SOFTWARE\"+MyAppPublisher+"\"+MyAppName
#define MySubKeyVersion MySubkey+"\"+MyAppVersion
#define AppId "BBB87BC3-F075-446C-ACC9-F413952DE710"

[Setup]
AppId={#AppId}
AppMutex={#AppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={#MyDefaultDirName}
DisableDirPage=yes
DefaultGroupName={#MyAppName}
OutputDir=.\
OutputBaseFilename=Setup_{#MyAppName}_{#MyAppVersion}
Compression=lzma
SolidCompression=yes
LicenseFile=licence.txt

[Languages]
Name: french; MessagesFile: compiler:Languages\French.isl

[Files]
Source: "Bin\*"; DestDir: "{app}\Bin"; Flags: ignoreversion
Source: "{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: {commondesktop}\{#MyAppName}; Filename: {app}\{#MyAppExeName}


[Registry]
Root: HKLM64; Subkey: {#MySubkey}; ValueName: CurrentVersion; ValueType: string; ValueData: {#MyAppVersion}; MinVersion: 0.0,5.0; Flags: deletekey deletevalue
Root: HKLM64; Subkey: {#MySubKeyVersion}; MinVersion: 0.0,5.0; Flags: uninsdeletekey createvalueifdoesntexist
Root: HKLM64; Subkey: {#MySubKeyVersion}; ValueName: InstallDate; ValueType: string; ValueData: {code:Madate}; MinVersion: 0.0,5.0; Flags: uninsdeletekey createvalueifdoesntexist
Root: HKLM64; Subkey: {#MySubKeyVersion}; ValueName: InstallDir; ValueType: string; ValueData: {#MyDefaultDirName}; MinVersion: 0.0,5.0; Flags: uninsdeletekey createvalueifdoesntexist
Root: HKLM64; Subkey: {#MySubKeyVersion}; ValueName: Package; ValueType: string; ValueData: {#MyAppName} {#MyAppVersion}; MinVersion: 0.0,5.0; Flags: uninsdeletekey createvalueifdoesntexist
Root: HKLM64; Subkey: {#MySubKeyVersion}; ValueName: Publisher; ValueType: string; ValueData: {#MyAppPublisher}; MinVersion: 0.0,5.0; Flags: uninsdeletekey createvalueifdoesntexist
Root: HKLM64; Subkey: {#MySubkey}; ValueName: CurrentVersion; ValueType: string; ValueData: {#MyAppVersion}; MinVersion: 0.0,5.0; Flags: uninsdeletekey createvalueifdoesntexist

[Code]
function MaDate(Param:String): String;
begin
	result := GetDateTimeString('dd/mm/yyyy','/',':');
end;
