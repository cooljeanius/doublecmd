library unrar;

uses
  SysUtils, DynLibs, UnRARFunc;

exports
  { Mandatory }
  OpenArchive,
  OpenArchiveW,
  ReadHeader,
  ReadHeaderEx,
  ReadHeaderExW,
  ProcessFile,
  ProcessFileW,
  CloseArchive,
  SetChangeVolProc,
  SetChangeVolProcW,
  SetProcessDataProc,
  SetProcessDataProcW,
  { Optional }
  GetPackerCaps,
  { Extension API }
  ExtensionInitialize;

{$R *.res}

begin
  ModuleHandle := LoadLibrary(_unrar);
  if ModuleHandle = NilHandle then
    ModuleHandle := LoadLibrary(GetEnvironmentVariable('COMMANDER_PATH') + PathDelim + _unrar);
  if ModuleHandle <> NilHandle then
    begin
      RAROpenArchive := TRAROpenArchive(GetProcAddress(ModuleHandle, 'RAROpenArchive'));
      RAROpenArchiveEx := TRAROpenArchiveEx(GetProcAddress(ModuleHandle, 'RAROpenArchiveEx'));
      RARCloseArchive := TRARCloseArchive(GetProcAddress(ModuleHandle, 'RARCloseArchive'));
      RARReadHeader := TRARReadHeader(GetProcAddress(ModuleHandle, 'RARReadHeader'));
      RARReadHeaderEx := TRARReadHeaderEx(GetProcAddress(ModuleHandle, 'RARReadHeaderEx'));
      RARProcessFile := TRARProcessFile(GetProcAddress(ModuleHandle, 'RARProcessFile'));
      RARProcessFileW := TRARProcessFileW(GetProcAddress(ModuleHandle, 'RARProcessFileW'));
      RARSetCallback := TRARSetCallback(GetProcAddress(ModuleHandle, 'RARSetCallback'));
      RARSetChangeVolProc := TRARSetChangeVolProc(GetProcAddress(ModuleHandle, 'RARSetChangeVolProc'));
      RARSetProcessDataProc := TRARSetProcessDataProc(GetProcAddress(ModuleHandle, 'RARSetProcessDataProc'));
      RARSetPassword := TRARSetPassword(GetProcAddress(ModuleHandle, 'RARSetPassword'));
      RARGetDllVersion := TRARGetDllVersion(GetProcAddress(ModuleHandle, 'RARGetDllVersion'));
    end;
end.
