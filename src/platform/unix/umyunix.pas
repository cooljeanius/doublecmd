{
    Double Commander
    -------------------------------------------------------------------------
    This unit contains specific UNIX functions.

    Copyright (C) 2008-2013  Koblov Alexander (Alexx2000@mail.ru)

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

unit uMyUnix;

{$mode objfpc}{$H+}

{$IF NOT DEFINED(LINUX)}
{$DEFINE FPC_USE_LIBC}
{$ENDIF}

interface

uses
  Classes, SysUtils, BaseUnix, uDrive;

const
  libc = 'c';
  _PATH_FSTAB = '/etc/fstab';
  _PATH_MOUNTED = '/etc/mtab';

const
  DE_UNKNOWN = 0;
  DE_KDE = 1;
  DE_GNOME = 2;
  DE_XFCE = 3;
  DE_LXDE = 4;

type
  PIOFILE = Pointer;
  PFILE = PIOFILE;
  //en Mount entry record
  mntent = record
    mnt_fsname: PChar;   //en< name of mounted file system
    mnt_dir: PChar;      //en< file system path prefix
    mnt_type: PChar;     //en< mount type
    mnt_opts: PChar;     //en< mount options
    mnt_freq: LongInt;   //en< dump frequency in days
    mnt_passno: LongInt; //en< pass number on parallel fsck
  end;
  TMountEntry = mntent;
  PMountEntry = ^TMountEntry;

type
  __uid_t = DWORD;
  __gid_t = DWORD;
  //en Password file entry record
  passwd = record
    pw_name: PChar;   //en< user name
    pw_passwd: PChar; //en< user password
    pw_uid: __uid_t;  //en< user ID
    pw_gid: __gid_t;  //en< group ID
    pw_gecos: PChar;  //en< real name
    pw_dir: PChar;    //en< home directory
    pw_shell: PChar;  //en< shell program
  end;
  TPasswordRecord = passwd;
  PPasswordRecord = ^TPasswordRecord;
  //en Group file entry record
  group = record
    gr_name: PChar;   //en< group name
    gr_passwd: PChar; //en< group password
    gr_gid: __gid_t;  //en< group ID
    gr_mem: ^PChar;   //en< group members
  end;
  TGroupRecord = group;
  PGroupRecord = ^TGroupRecord;

{$IFDEF LINUX}
{en
   Opens the file system description file
   @param(filename File system description file)
   @param(mode Type of access)
   @returns(The function returns a file pointer to file system description file)
}
function setmntent(const filename: PChar; const mode: PChar): PFILE; cdecl; external libc name 'setmntent';
{en
   Reads the next line from  the file system description file
   @param(stream File pointer to file system description file)
   @returns(The function returns a pointer to a structure containing the
            broken out fields from a line in the file)
}
function getmntent(stream: PFILE): PMountEntry; cdecl; external libc name 'getmntent';
{en
   Closes the file system description file
   @param(stream File pointer to file system description file)
   @returns(The function always returns 1)
}
function endmntent(stream: PFILE): LongInt; cdecl; external libc name 'endmntent';
{$ENDIF}
{en
   Get password file entry
   @param(uid User ID)
   @returns(The function returns a pointer to a structure containing the broken-out
            fields of the record in the password database that matches the user ID)
}
function getpwuid(uid: __uid_t): PPasswordRecord; cdecl; external libc name 'getpwuid';
{en
   Get password file entry
   @param(name User name)
   @returns(The function returns a pointer to a structure containing the broken-out
            fields of the record in the password database that matches the user name)
}
function getpwnam(const name: PChar): PPasswordRecord; cdecl; external libc name 'getpwnam';
{en
   Get group file entry
   @param(gid Group ID)
   @returns(The function returns a pointer to a structure containing the broken-out
            fields of the record in the group database that matches the group ID)
}
function getgrgid(gid: __gid_t): PGroupRecord; cdecl; external libc name 'getgrgid';
{en
   Get group file entry
   @param(name Group name)
   @returns(The function returns a pointer to a structure containing the broken-out
            fields of the record in the group database that matches the group name)
}
function getgrnam(name: PChar): PGroupRecord; cdecl; external libc name 'getgrnam';
{en
   Change or add an environment variable
   @param(name Environment variable name)
   @param(value Environment variable value)
   @param(overwrite Overwrite environment variable if exist)
   @returns(The function returns zero on success, or -1 if there was
            insufficient space in the environment)
}
function setenv(const name, value: PChar; overwrite: LongInt): LongInt; cdecl; external libc name 'setenv';
{en
   Change owner and group of a file (does not follow symbolic links)
   @param(path Full path to file)
   @param(owner User ID)
   @param(group Group ID)
   @returns(On success, zero is returned. On error, -1 is returned, and errno is set appropriately)
}
function fpLChown(path : pChar; owner : TUid; group : TGid): cInt; {$IFDEF FPC_USE_LIBC}cdecl; external libc name 'lchown';{$ENDIF}

{$IFDEF LINUX}
function fpOpenDir(__name: PChar): pDir; cdecl; external libc name 'opendir';
function fpReadDir(__dirp: pDir): pDirent; cdecl; external libc name 'readdir64';
function fpCloseDir(__dirp: pDir): cInt; cdecl; external libc name 'closedir';
{$ELSE}
function fpReadDir(__dirp: pDir): pDirent; inline;
function fpCloseDir(__dirp: pDir): cInt; inline;
{$ENDIF}
function fpSystemStatus(Command: string): cint;

function GetDesktopEnvironment: Cardinal;
function FileIsLinkToFolder(const FileName: UTF8String; out LinkTarget: UTF8String): Boolean;
{en
   Checks if file is executable or script
   @param(FileName File name)
   @returns(The function returns @true if successful, @false otherwise)
}
function FileIsUnixExecutable(const Filename: UTF8String): Boolean;
{en
   Find mount point of file system where file is located
   @param(FileName File name)
   @returns(Mount point of file system)
}
function FindMountPointPath(const FileName: UTF8String): UTF8String;
function GetDefaultAppCmd(const FileName: UTF8String): UTF8String;
function GetFileMimeType(const FileName: UTF8String): UTF8String;

{en
   Fix separators in case they are broken UTF-8 characters
   (FPC takes only first byte as it doesn't support Unicode).
}
procedure FixDateTimeSeparators;

function MountDrive(Drive: PDrive): Boolean;
function UnmountDrive(Drive: PDrive): Boolean;
function EjectDrive(Drive: PDrive): Boolean;

{$IF DEFINED(BSD)}
const
  MNT_WAIT = 1; // synchronously wait for I/O to complete
  MNT_NOWAIT = 2; // start all I/O, but do not wait for it
  MNT_LAZY = 3; // push data not written by filesystem syncer
  MNT_SUSPEND = 4; // suspend file system after sync

type
  TFSTab = record
    fs_spec: PChar; // block special device name
    fs_file: PChar; // file system path prefix
    fs_vfstype: PChar; // file system type, ufs, nfs
    fs_mntops: PChar; // mount options ala -o
    fs_type: PChar; // FSTAB_* from fs_mntops
    fs_freq: longint; // dump frequency, in days
    fs_passno: longint; // pass number on parallel fsc
  end;
  PFSTab = ^TFSTab;
  PStatFS = ^TStatFS;

{$IF DEFINED(DARWIN)}
function getfsstat(buf: pstatfs; bufsize: cint; flags: cint): cint; cdecl; external libc name 'getfsstat';
{$ELSE}
function getfsstat(struct_statfs: PStatFS; const buffsize: int64; const int_flags: integer): integer;
{$ENDIF}
function getfsent(): PFSTab; cdecl; external libc name 'getfsent';
procedure endfsent(); cdecl; external libc name 'endfsent';
{$ENDIF}

implementation

uses
  URIParser, Unix, FileUtil, DCClassesUtf8, DCStrUtils, uDCUtils, uOSUtils
{$IF (NOT DEFINED(FPC_USE_LIBC)) or (DEFINED(BSD) AND NOT DEFINED(DARWIN))}
  , SysCall
{$ENDIF}
{$IFDEF LINUX}
  , uMimeActions, uUDisks
{$ENDIF}
  ;

{$IF DEFINED(BSD) AND NOT DEFINED(DARWIN)}
function getfsstat(struct_statfs: PStatFS; const buffsize: int64; const int_flags: integer): integer;
{$IF DEFINED(FREEBSD) AND ((fpc_version<2) OR ((fpc_version=2) AND (fpc_release<5)))}
const
  syscall_nr_getfsstat = 18; // was not defined before fpc 2.5.1
{$ENDIF}
begin
  Result := do_syscall(syscall_nr_getfsstat, TSysParam(struct_statfs), TSysParam(buffsize), TSysParam(int_flags));
end;
{$ENDIF}

{$IFNDEF FPC_USE_LIBC}

function fpLChown(path : pChar; owner : TUid; group : TGid): cInt;
begin
  fpLChown:=do_syscall(syscall_nr_lchown,TSysParam(path),TSysParam(owner),TSysParam(group));
end;

{$ENDIF}

{$IF NOT DEFINED(LINUX)}

function fpReadDir(__dirp: pDir): pDirent;
begin
  Result:= BaseUnix.FpReaddir(__dirp^);
end;

function fpCloseDir(__dirp: pDir): cInt;
begin
  Result:= BaseUnix.FpClosedir(__dirp^);
end;

{$ENDIF}

function fpSystemStatus(Command: string): cint;
begin
  Result := fpSystem(UTF8ToSys(Command));
  if wifexited(Result) then
    Result := wexitStatus(Result);
end;

{$IFDEF LINUX}

var
  HavePMount: Boolean = False;

procedure CheckPMount;
begin
  HavePMount := (fpSystemStatus('pmount --version > /dev/null') = 0) and
                (fpSystemStatus('pumount --version > /dev/null') = 0);
end;

{$ENDIF LINUX}

function GetDesktopEnvironment: Cardinal;
var
  DesktopSession: String;
begin
  Result:= DE_UNKNOWN;
  if GetEnvironmentVariable('KDE_FULL_SESSION') <> '' then
    Exit(DE_KDE);
  if GetEnvironmentVariable('GNOME_DESKTOP_SESSION_ID') <> '' then
    Exit(DE_GNOME);
  if GetEnvironmentVariable('_LXSESSION_PID') <> '' then
    Exit(DE_LXDE);
  if fpSystemStatus('pgrep xfce4-session > /dev/null') = 0 then
    Exit(DE_XFCE);
  DesktopSession:= GetEnvironmentVariable('DESKTOP_SESSION');
  DesktopSession:= LowerCase(DesktopSession);
  if Pos('kde', DesktopSession) <> 0 then
    Exit(DE_KDE);
  if Pos('gnome', DesktopSession) <> 0 then
    Exit(DE_GNOME);
  if Pos('xfce', DesktopSession) <> 0 then
    Exit(DE_XFCE);
  if Pos('lxde', DesktopSession) <> 0 then
    Exit(DE_LXDE);
end;

function FileIsLinkToFolder(const FileName: UTF8String; out LinkTarget: UTF8String): Boolean;
var
  iniDesktop: TIniFileEx = nil;
  StatInfo: BaseUnix.Stat;
begin
  Result:= False;
  try
    iniDesktop:= TIniFileEx.Create(FileName, fmOpenRead);
    if iniDesktop.ReadString('Desktop Entry', 'Type', EmptyStr) = 'Link' then
    begin
      LinkTarget:= iniDesktop.ReadString('Desktop Entry', 'URL', EmptyStr);
      if not URIToFilename(LinkTarget, LinkTarget) then Exit;
      if fpLStat(PAnsiChar(UTF8ToSys(LinkTarget)), StatInfo) <> 0 then Exit;
      Result:= FPS_ISDIR(StatInfo.st_mode);
    end;
  finally
    if Assigned(iniDesktop) then
      FreeAndNil(iniDesktop);
  end;
end;

function FileIsUnixExecutable(const FileName: UTF8String): Boolean;
var
  Info : Stat;
  dwSign : LongWord;
  fsExeScr : TFileStreamEx = nil;
begin
  // First check FileName is not a directory and then check if executable
  Result:= (fpStat(UTF8ToSys(FileName), Info) <> -1) and FPS_ISREG(Info.st_mode) and
           (BaseUnix.fpAccess(UTF8ToSys(FileName), BaseUnix.X_OK) = 0);
  if Result and (Info.st_size >= SizeOf(dwSign)) then
  try
    fsExeScr := TFileStreamEx.Create(FileName, fmOpenRead or fmShareDenyNone);
    dwSign := fsExeScr.ReadDWord;
    // ELF or #!
    Result := ((dwSign = NtoBE($7F454C46)) or (Lo(dwSign) = NtoBE($2321)));
  finally
    if Assigned(fsExeScr) then
      fsExeScr.Free;
  end;
end;

function FindMountPointPath(const FileName: UTF8String): UTF8String;
var
  I, J: LongInt;
  sTemp: UTF8String;
  recStat: Stat;
  st_dev: QWord;
begin
  // Set root directory as mount point by default
  Result:= PathDelim;
  // Get stat info for original file
  if (fpLStat(PChar(UTF8ToSys(FileName)), recStat) < 0) then Exit;
  // Save device ID of original file
  st_dev:= recStat.st_dev;
  J:= Length(FileName);
  for I:= J downto 1 do
  begin
    if FileName[I] = PathDelim then
    begin
      if (I = 1) then
        sTemp:= PathDelim
      else
        sTemp:= Copy(FileName, 1, I - 1);
      // Stat for current directory
      if (fpLStat(PChar(UTF8ToSys(sTemp)), recStat) < 0) then Continue;
      // If it is a link then checking link destination
      if fpS_ISLNK(recStat.st_mode) then
      begin
        sTemp:= ReadSymLink(sTemp);
        Result:= FindMountPointPath(sTemp);
        Exit;
      end;
      // Check device ID
      if (recStat.st_dev <> st_dev) then
      begin
        Result:= Copy(FileName, 1, J);
        Exit;
      end;
      J:= I;
    end;
  end;
end;

function GetDefaultAppCmd(const FileName: UTF8String): UTF8String;
{$IFDEF LINUX}
var
  Filenames: TStringList;
begin
  Filenames:= TStringList.Create;
  Filenames.Add(FileName);
  Result:= uMimeActions.GetDefaultAppCmd(Filenames);
  if Length(Result) = 0 then
  Result:= 'xdg-open ' + QuoteStr(FileName);
  FreeAndNil(Filenames);
end;
{$ELSE}
begin
  Result:= 'xdg-open ' + QuoteStr(FileName);
end;
{$ENDIF}

function GetFileMimeType(const FileName: UTF8String): UTF8String;
{$IFDEF LINUX}
begin
  Result:= uMimeActions.GetFileMimeType(FileName);
end;
{$ELSE}
begin
  Result:= EmptyStr;
end;
{$ENDIF}

procedure FixDateTimeSeparators;
var
  TimeEnv: String;
begin
  TimeEnv := GetEnvironmentVariable('LC_TIME');
  if TimeEnv = EmptyStr then
    TimeEnv := GetEnvironmentVariable('LC_ALL');
  if TimeEnv = EmptyStr then
    TimeEnv := GetEnvironmentVariable('LANG');
  if TimeEnv <> EmptyStr then
  begin
    TimeEnv := upcase(TimeEnv);
    if StrEnds(TimeEnv, 'UTF-8') or StrEnds(TimeEnv, 'UTF8') then
    begin
      if Ord(DateSeparator) > $7F then
        DateSeparator := '/';
      if Ord(TimeSeparator) > $7F then
        TimeSeparator := ':';
    end;
  end;
end;

function MountDrive(Drive: PDrive): Boolean;
{$IFDEF LINUX}
var
  MountPath: UTF8String;
{$ENDIF}
begin
  if not Drive^.IsMounted then
  begin
{$IF DEFINED(UNIX) AND NOT DEFINED(DARWIN)}
    Result := False;
    // If Path is not empty "mount" can mount it because it has a destination path from fstab.
    if Drive^.Path <> EmptyStr then
{$ENDIF}
      Result := fpSystemStatus('mount ' + Drive^.DeviceId) = 0;
{$IFDEF LINUX}
    if not Result and uUDisks.Initialize then
    begin
      Result := uUDisks.Mount(DeviceFileToUDisksObjectPath(Drive^.DeviceId), EmptyStr, nil, MountPath);
      if Result then
        Drive^.Path := MountPath;
      uUDisks.Finalize;
    end;
    if not Result and HavePMount and Drive^.IsMediaRemovable then
      Result := fpSystemStatus('pmount ' + Drive^.DeviceId) = 0;
{$ENDIF}
  end
  else
    Result := True;
end;

function UnmountDrive(Drive: PDrive): Boolean;
begin
  if Drive^.IsMounted then
  begin
{$IFDEF LINUX}
    Result := False;
    if uUDisks.Initialize then
    begin
      Result := uUDisks.Unmount(DeviceFileToUDisksObjectPath(Drive^.DeviceId), nil);
      uUDisks.Finalize;
    end;
    if not Result and HavePMount and Drive^.IsMediaRemovable then
      Result := fpSystemStatus('pumount ' + Drive^.DeviceId) = 0;
    if not Result then
{$ENDIF}
    Result := fpSystemStatus('umount ' + Drive^.Path) = 0;
  end
  else
    Result := True;
end;

function EjectDrive(Drive: PDrive): Boolean;
begin
  Result := fpSystemStatus('eject ' + Drive^.DeviceId) = 0;
end;

{$IFDEF LINUX}

initialization
  CheckPMount;

{$ENDIF}

end.

