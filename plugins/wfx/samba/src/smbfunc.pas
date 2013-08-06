{
   Double commander
   -------------------------------------------------------------------------
   WFX plugin for working with Common Internet File System (CIFS)

   Copyright (C) 2011  Koblov Alexander (Alexx2000@mail.ru)

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

unit SmbFunc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, WfxPlugin, Extension;

function FsInit(PluginNr: Integer; pProgressProc: TProgressProc; pLogProc: TLogProc; pRequestProc: TRequestProc): Integer; cdecl;

function FsFindFirst(Path: PAnsiChar; var FindData: TWin32FindData): THandle; cdecl;
function FsFindNext(Hdl: THandle; var FindData: TWin32FindData): BOOL; cdecl;
function FsFindClose(Hdl: THandle): Integer; cdecl;

function FsRenMovFile(OldName, NewName: PAnsiChar; Move, OverWrite: BOOL;
                      RemoteInfo: pRemoteInfo): Integer; cdecl;
function FsGetFile(RemoteName, LocalName: PAnsiChar; CopyFlags: Integer;
                   RemoteInfo: pRemoteInfo): Integer; cdecl;
function FsPutFile(LocalName, RemoteName: PAnsiChar; CopyFlags: Integer): Integer; cdecl;
function FsDeleteFile(RemoteName: PAnsiChar): BOOL; cdecl;

function FsMkDir(RemoteDir: PAnsiChar): BOOL; cdecl;
function FsRemoveDir(RemoteName: PAnsiChar): BOOL; cdecl;

function FsSetAttr(RemoteName: PAnsiChar; NewAttr: Integer): BOOL; cdecl;
function FsSetTime(RemoteName: PAnsiChar; CreationTime, LastAccessTime, LastWriteTime: PFileTime): BOOL; cdecl;

procedure FsGetDefRootName(DefRootName: PAnsiChar; MaxLen: Integer); cdecl;

{ Extension API }
procedure ExtensionInitialize(StartupInfo: PExtensionStartupInfo); cdecl;

var
  Message:   AnsiString;
  WorkGroup: array[0..MAX_PATH-1] of AnsiChar;
  UserName:  array[0..MAX_PATH-1] of AnsiChar;
  Password:  array[0..MAX_PATH-1] of AnsiChar;
  ExtensionStartupInfo: TExtensionStartupInfo;

implementation

uses
  Unix, BaseUnix, UnixType, StrUtils, SmbAuthDlg, libsmbclient;

const
  SMB_BUFFER_SIZE = 524288;

type
  PSambaHandle = ^TSambaHandle;
  TSambaHandle = record
    Path: String;
    Handle: LongInt;
  end;

var
  ProgressProc: TProgressProc;
  LogProc: TLogProc;
  RequestProc: TRequestProc;
  PluginNumber: Integer;
  Auth: Boolean = False;
  Abort: Boolean = False;
  NeedAuth: Boolean = False;

function FileTimeToUnixTime(ft: TFileTime): time_t;
var
  UnixTime: Int64;
begin
  UnixTime:= ft.dwHighDateTime;
  UnixTime:= (UnixTime shl 32) or ft.dwLowDateTime;
  UnixTime:= (UnixTime - 116444736000000000) div 10000000;
  Result:= time_t(UnixTime);
end;

function UnixTimeToFileTime(mtime: time_t): TFileTime;
var
  FileTime: Int64;
begin
  FileTime:= Int64(mtime) * 10000000 + 116444736000000000;
  Result.dwLowDateTime:= (FileTime and $FFFF);
  Result.dwHighDateTime:= (FileTime shr $20);
end;

procedure WriteError(const FuncName: String);
begin
  WriteLn(FuncName + ': ', SysErrorMessage(GetLastOSError));
end;

procedure smbc_get_auth_data(server, share: PAnsiChar;
                                  wg: PAnsiChar; wglen: LongInt;
                                  un: PAnsiChar; unlen: LongInt;
                                  pw: PAnsiChar; pwlen: LongInt); cdecl;
begin
  Auth:= True;

  if NeedAuth then
  begin
    Abort:= True;

    // Set query resource
    if (server = nil) then
      Message:= StrPas(share)
    else
      Message:= StrPas(server) + PathDelim + StrPas(share);

    // Set authentication data
    StrLCopy(WorkGroup, wg, wglen);
    StrLCopy(UserName, un, unlen);
    StrLCopy(Password, pw, pwlen);

    // Query authentication data
    if ShowSmbAuthDlg then
    begin
      Abort:= False;
      // Get authentication data
      StrLCopy(wg, WorkGroup, wglen);
      StrLCopy(un, UserName, unlen);
      StrLCopy(pw, Password, pwlen);
    end;
  end
  else
    begin
      // If has saved workgroup then use it
      if StrLen(WorkGroup) <> 0 then
        StrLCopy(wg, WorkGroup, wglen);
      // If has saved user name then use it
      if StrLen(UserName) <> 0 then
        StrLCopy(un, UserName, unlen);
      // If has saved password then use it
      if StrLen(Password) <> 0 then
        StrLCopy(pw, Password, pwlen);
    end;
end;

function BuildNetworkPath(const Path: String): String;
var
  I, C: Integer;
begin
  C:= 0;
  if Path = PathDelim then Exit('smb://');
  Result := Path;
  // Don't check last symbol
  for I := 1 to Length(Result) - 1 do
  begin
    if (Result[I] = PathDelim) then
      Inc(C);
  end;
  if (C < 2) then
    Result:= 'smb:/' + Result
  else
    begin
      I:= PosEx(PathDelim, Result, 2);
      Result:= 'smb:/' + Copy(Result, I, MaxInt);
    end;
end;

function ForceAuth(Path: PAnsiChar): String;
var
  un: array[0..MAX_PATH-1] of AnsiChar;
  pw: array[0..MAX_PATH-1] of AnsiChar;
begin
  Result:= BuildNetworkPath(Path);
  // Use by default saved user name and password
  StrLCopy(un, UserName, MAX_PATH);
  StrLCopy(pw, Password, MAX_PATH);
  // Query auth data
  smbc_get_auth_data(nil, PAnsiChar(Result), WorkGroup, MAX_PATH, un, MAX_PATH, pw, MAX_PATH);
  if (Abort = False) and (un <> '') then
  begin
    if StrLen(WorkGroup) = 0 then
      Result:= 'smb://' + un + ':' + pw + '@' + Copy(Result, 7, MAX_PATH)
    else
      Result:= 'smb://' + WorkGroup + ';' + un + ':' + pw + '@' + Copy(Result, 7, MAX_PATH);
  end;
end;

function FsInit(PluginNr: Integer; pProgressProc: tProgressProc; pLogProc: tLogProc; pRequestProc: tRequestProc): Integer; cdecl;
begin
  if not LoadSambaLibrary then
  begin
    pRequestProc(PluginNr, RT_MsgOK, nil, 'Can not load "libsmbclient" library!', nil, 0);
    Exit(-1);
  end;
  ProgressProc := pProgressProc;
  LogProc := pLogProc;
  RequestProc := pRequestProc;
  PluginNumber := PluginNr;
  FillChar(WorkGroup, SizeOf(WorkGroup), #0);
  FillChar(UserName, SizeOf(UserName), #0);
  FillChar(Password, SizeOf(Password), #0);

  Result := smbc_init(@smbc_get_auth_data, 0);
  if Result < 0 then WriteError('smbc_init');
end;

function FsFindFirst(Path: PAnsiChar; var FindData: TWin32FindData): THandle; cdecl;
var
  NetworkPath: String;
  SambaHandle: PSambaHandle;
  Handle: LongInt;
begin
  Abort:= False;
  NetworkPath:= BuildNetworkPath(Path);
  repeat
    Auth:= False;
    Handle:= smbc_opendir(PChar(NetworkPath));
    NeedAuth:= (Handle = -1);
    // Sometimes smbc_get_auth_data don't called automatically
    // so we call it manually
    if NeedAuth and (Auth = False) then
    begin
      NetworkPath:= ForceAuth(Path);
    end;
  until not NeedAuth or Abort;
  if Handle < 0 then
    begin
      WriteError('smbc_opendir');
      Result:= wfxInvalidHandle;
    end
  else
    begin
      New(SambaHandle);
      SambaHandle^.Path:= IncludeTrailingPathDelimiter(NetworkPath);
      SambaHandle^.Handle:= Handle;
      Result:= THandle(SambaHandle);
      FsFindNext(Result, FindData);
    end;
end;

function FsFindNext(Hdl: THandle; var FindData: TWin32FindData): BOOL; cdecl;
var
  dirent: psmbc_dirent;
  FileInfo: BaseUnix.Stat;
  SambaHandle: PSambaHandle absolute Hdl;
  Mode: array[0..7] of Byte;
begin
  Result:= True;
  dirent := smbc_readdir(SambaHandle^.Handle);
  if (dirent = nil) then Exit(False);
  FillByte(FindData, SizeOf(TWin32FindData), 0);
  StrLCopy(FindData.cFileName, dirent^.name, dirent^.namelen);
  if dirent^.smbc_type in [SMBC_WORKGROUP, SMBC_SERVER, SMBC_FILE_SHARE] then
    FindData.dwFileAttributes:= FILE_ATTRIBUTE_DIRECTORY;
  if dirent^.smbc_type in [SMBC_DIR, SMBC_FILE, SMBC_LINK] then
    begin
      if smbc_stat(PChar(SambaHandle^.Path + FindData.cFileName), @FileInfo) = 0 then
      begin
        FindData.nFileSizeLow := (FileInfo.st_size and MAXDWORD);
        FindData.nFileSizeHigh := (FileInfo.st_size shr $20);
        FindData.ftLastAccessTime:= UnixTimeToFileTime(FileInfo.st_atime);
        FindData.ftCreationTime:= UnixTimeToFileTime(FileInfo.st_ctime);
        FindData.ftLastWriteTime:= UnixTimeToFileTime(FileInfo.st_mtime);
      end;
      if smbc_getxattr(PChar(SambaHandle^.Path + FindData.cFileName), 'system.dos_attr.mode', @Mode, SizeOf(Mode)) >= 0 then
      begin
        if (Mode[3] = 0) then
          FindData.dwFileAttributes:= Mode[2] - SMBC_DOS_MODE_DIRECTORY - SMBC_DOS_MODE_ARCHIVE
        else
          case Mode[2] of
          48: FindData.dwFileAttributes:= 0;
          49: FindData.dwFileAttributes:= Mode[3] - SMBC_DOS_MODE_ARCHIVE;
          50: FindData.dwFileAttributes:= Mode[3] - SMBC_DOS_MODE_DIRECTORY;
          51: FindData.dwFileAttributes:= Mode[3];
          end;
      end;
  end;
end;

function FsFindClose(Hdl: THandle): Integer; cdecl;
var
  SambaHandle: PSambaHandle absolute Hdl;
begin
  Result:= smbc_closedir(SambaHandle^.Handle);
  if Result < 0 then WriteError('smbc_closedir');
  Dispose(SambaHandle);
end;

function FsRenMovFile(OldName, NewName: PAnsiChar; Move, OverWrite: BOOL;
                      RemoteInfo: pRemoteInfo): Integer; cdecl;
var
  OldFileName,
  NewFileName: String;
  Buffer: Pointer = nil;
  BufferSize: LongWord;
  fdOldFile: LongInt;
  fdNewFile: LongInt;
  dwRead: LongWord;
  Written: Int64;
  FileSize: Int64;
  Percent: LongInt;
begin
  OldFileName:= BuildNetworkPath(OldName);
  NewFileName:= BuildNetworkPath(NewName);
  if Move then
    begin
      if smbc_rename(PChar(OldFileName), PChar(NewFileName)) < 0 then
        Exit(-1);
    end
  else
    begin
      BufferSize:= SMB_BUFFER_SIZE;
      Buffer:= GetMem(BufferSize);
      try
        // Open source file
        fdOldFile:= smbc_open(PChar(OldFileName), O_RDONLY, 0);
        if (fdOldFile < 0) then Exit(FS_FILE_READERROR);
        // Open target file
        fdNewFile:= smbc_open(PChar(NewFileName), O_CREAT or O_RDWR or O_TRUNC, RemoteInfo^.Attr);
        if (fdNewFile < 0) then Exit(FS_FILE_WRITEERROR);
        // Get source file size
        FileSize:= smbc_lseek(fdOldFile, 0, SEEK_END);
        smbc_lseek(fdOldFile, 0, SEEK_SET);
        Written:= 0;
        // Copy data
        repeat
          dwRead:= smbc_read(fdOldFile, Buffer, BufferSize);
          if (fpgeterrno <> 0) then Exit(FS_FILE_READERROR);
          if (dwRead > 0) then
          begin
            if smbc_write(fdNewFile, Buffer, dwRead) <> dwRead then
              Exit(FS_FILE_WRITEERROR);
            if (fpgeterrno <> 0) then Exit(FS_FILE_WRITEERROR);
            Written:= Written + dwRead;
            // Calculate percent
            Percent:= (Written * 100) div FileSize;
            // Update statistics
            if ProgressProc(PluginNumber, PChar(OldFileName), PChar(NewFileName), Percent) = 1 then
              Exit(FS_FILE_USERABORT);
          end;
        until (dwRead = 0);
      finally
        if Assigned(Buffer) then
          FreeMem(Buffer);
        if not (fdOldFile < 0) then
          smbc_close(fdOldFile);
        if not (fdNewFile < 0) then
          smbc_close(fdNewFile);
      end;
    end;
  Result:= FS_FILE_OK;
end;

function FsGetFile(RemoteName, LocalName: PAnsiChar; CopyFlags: Integer;
                   RemoteInfo: pRemoteInfo): Integer; cdecl;
var
  OldFileName: String;
  Buffer: Pointer = nil;
  BufferSize: LongWord;
  fdOldFile: LongInt;
  fdNewFile: LongInt;
  dwRead: LongWord;
  Written: Int64;
  FileSize: Int64;
  Percent: LongInt;
begin
  OldFileName:= BuildNetworkPath(RemoteName);
  BufferSize:= SMB_BUFFER_SIZE;
  Buffer:= GetMem(BufferSize);
  try
    // Open source file
    fdOldFile:= smbc_open(PChar(OldFileName), O_RDONLY, 0);
    if (fdOldFile < 0) then Exit(FS_FILE_READERROR);
    // Open target file
    fdNewFile:= fpOpen(PChar(LocalName), O_CREAT or O_RDWR or O_TRUNC, $1A4); // $1A4 = &644
    if (fdNewFile < 0) then Exit(FS_FILE_WRITEERROR);
    // Get source file size
    FileSize:= smbc_lseek(fdOldFile, 0, SEEK_END);
    smbc_lseek(fdOldFile, 0, SEEK_SET);
    Written:= 0;
    // Copy data
    repeat
      dwRead:= smbc_read(fdOldFile, Buffer, BufferSize);
      if (fpgeterrno <> 0) then Exit(FS_FILE_READERROR);
      if (dwRead > 0) then
      begin
        if fpWrite(fdNewFile, Buffer^, dwRead) <> dwRead then
          Exit(FS_FILE_WRITEERROR);
        if (fpgeterrno <> 0) then Exit(FS_FILE_WRITEERROR);
        Written:= Written + dwRead;
        // Calculate percent
        Percent:= (Written * 100) div FileSize;
        // Update statistics
        if ProgressProc(PluginNumber, PChar(OldFileName), LocalName, Percent) = 1 then
          Exit(FS_FILE_USERABORT);
      end;
    until (dwRead = 0);
  finally
    if Assigned(Buffer) then
      FreeMem(Buffer);
    if not (fdOldFile < 0) then
      smbc_close(fdOldFile);
    if not (fdNewFile < 0) then
      fpClose(fdNewFile);
  end;
  Result:= FS_FILE_OK;
end;

function FsPutFile(LocalName, RemoteName: PAnsiChar; CopyFlags: Integer): Integer; cdecl;
var
  NewFileName: String;
  Buffer: Pointer = nil;
  BufferSize: LongWord;
  fdOldFile: LongInt;
  fdNewFile: LongInt;
  dwRead: LongWord;
  Written: Int64;
  FileSize: Int64;
  Percent: LongInt;
begin
  NewFileName:= BuildNetworkPath(RemoteName);
    begin
      BufferSize:= SMB_BUFFER_SIZE;
      Buffer:= GetMem(BufferSize);
      try
        // Open source file
        fdOldFile:= fpOpen(LocalName, O_RDONLY, 0);
        if (fdOldFile < 0) then Exit(FS_FILE_READERROR);
        // Open target file
        fdNewFile:= smbc_open(PChar(NewFileName), O_CREAT or O_RDWR or O_TRUNC, 0);
        if (fdNewFile < 0) then Exit(FS_FILE_WRITEERROR);
        // Get source file size
        FileSize:= fpLseek(fdOldFile, 0, SEEK_END);
        fpLseek(fdOldFile, 0, SEEK_SET);
        Written:= 0;
        // Copy data
        repeat
          dwRead:= fpRead(fdOldFile, Buffer^, BufferSize);
          if (fpgeterrno <> 0) then Exit(FS_FILE_READERROR);
          if (dwRead > 0) then
          begin
            if smbc_write(fdNewFile, Buffer, dwRead) <> dwRead then
              Exit(FS_FILE_WRITEERROR);
            if (fpgeterrno <> 0) then Exit(FS_FILE_WRITEERROR);
            Written:= Written + dwRead;
            // Calculate percent
            Percent:= (Written * 100) div FileSize;
            // Update statistics
            if ProgressProc(PluginNumber, LocalName, PChar(NewFileName), Percent) = 1 then
              Exit(FS_FILE_USERABORT);
          end;
        until (dwRead = 0);
      finally
        if Assigned(Buffer) then
          FreeMem(Buffer);
        if not (fdOldFile < 0) then
          fpClose(fdOldFile);
        if not (fdNewFile < 0) then
          smbc_close(fdNewFile);
      end;
    end;
  Result:= FS_FILE_OK;
end;

function FsDeleteFile(RemoteName: PAnsiChar): BOOL; cdecl;
var
  FileName: String;
begin
  FileName:= BuildNetworkPath(RemoteName);
  Result:= smbc_unlink(PChar(FileName)) = 0;
end;

function FsMkDir(RemoteDir: PAnsiChar): BOOL; cdecl;
var
  NewDir: String;
begin
  NewDir:= BuildNetworkPath(RemoteDir);
  Result:= smbc_mkdir(PChar(NewDir), $1FF) = 0; // $1FF = &0777
end;

function FsRemoveDir(RemoteName: PAnsiChar): BOOL; cdecl;
var
  RemDir: String;
begin
  RemDir:= BuildNetworkPath(RemoteName);
  Result:= smbc_rmdir(PChar(RemDir)) = 0;
end;

function FsSetAttr(RemoteName: PAnsiChar; NewAttr: Integer): BOOL; cdecl;
var
  FileName: String;
  Mode: array[0..7] of Byte;
begin
  Mode[0]:= 48;
  Mode[1]:= 120;
  FileName:= BuildNetworkPath(RemoteName);
  if (NewAttr and SMBC_DOS_MODE_DIRECTORY <> 0) and (NewAttr and SMBC_DOS_MODE_ARCHIVE <> 0) then
    begin
      Mode[2]:= 51;
      Mode[3]:= NewAttr;
    end
  else if (NewAttr and SMBC_DOS_MODE_ARCHIVE <> 0) then
    begin
      Mode[2]:= 50;
      Mode[3]:= NewAttr + SMBC_DOS_MODE_DIRECTORY;
    end
  else if (NewAttr and SMBC_DOS_MODE_DIRECTORY <> 0) then
    begin
      Mode[2]:= 49;
      Mode[3]:= NewAttr + SMBC_DOS_MODE_ARCHIVE;
    end
  else
    begin
      Mode[2]:= NewAttr + SMBC_DOS_MODE_DIRECTORY + SMBC_DOS_MODE_ARCHIVE;
      Mode[3]:= 0;
    end;
  Result:= (smbc_setxattr(PChar(FileName), 'system.dos_attr.mode', @Mode, SizeOf(Mode), 0) >= 0);
end;

function FsSetTime(RemoteName: PAnsiChar; CreationTime, LastAccessTime, LastWriteTime: PFileTime): BOOL; cdecl;
var
  FileName: String;
  tbuf: array[0..1] of timeval;
  FileInfo: BaseUnix.Stat;
begin
  FileName:= BuildNetworkPath(RemoteName);
  if (LastAccessTime = nil) or (LastWriteTime = nil) then
    begin
      if smbc_stat(PChar(FileName), @FileInfo) < 0 then
        Exit(False);

      if (LastAccessTime = nil) then
        tbuf[0].tv_sec:= FileInfo.st_atime
      else
        tbuf[0].tv_sec:= FileTimeToUnixTime(LastAccessTime^);

      if (LastWriteTime = nil) then
        tbuf[1].tv_sec:= FileInfo.st_mtime
      else
        tbuf[1].tv_sec:= FileTimeToUnixTime(LastWriteTime^);
    end
  else
    begin
      tbuf[0].tv_sec:= FileTimeToUnixTime(LastAccessTime^);
      tbuf[1].tv_sec:= FileTimeToUnixTime(LastWriteTime^);
    end;
  Result:= (smbc_utimes(PChar(FileName), @tbuf) = 0);
end;

procedure FsGetDefRootName(DefRootName: PAnsiChar; MaxLen: Integer); cdecl;
begin
  StrPLCopy(DefRootName, 'Windows Network', MaxLen);
end;

procedure ExtensionInitialize(StartupInfo: PExtensionStartupInfo); cdecl;
begin
  ExtensionStartupInfo:= StartupInfo^;
end;

end.

