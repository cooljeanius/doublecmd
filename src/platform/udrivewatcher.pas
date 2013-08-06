{
   Double Commander
   -------------------------------------------------------------------------
   Enumerating and monitoring drives in the system.

   Copyright (C) 2006-2013  Koblov Alexander (Alexx2000@mail.ru)
   Copyright (C) 2010  Przemyslaw Nagay (cobines@gmail.com)

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

unit uDriveWatcher;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, LCLType, uDrive;

type
  TDriveWatcherEvent = (dweDriveAdded,
                        dweDriveRemoved,
                        dweDriveChanged);

  TDriveWatcherEventNotify = procedure(EventType: TDriveWatcherEvent;
                                       const ADrive: PDrive) of object;

  TDriveWatcherObserverList = specialize TFPGList<TDriveWatcherEventNotify>;

  TDriveWatcher = class
    class procedure Initialize(Handle: HWND);
    class procedure Finalize;
    class procedure AddObserver(Func: TDriveWatcherEventNotify);
    class procedure RemoveObserver(Func: TDriveWatcherEventNotify);
    class function GetDrivesList: TDrivesList;
  end;

implementation

uses
  {$IFDEF UNIX}
  Unix, uMyUnix, uDebug
   {$IFDEF BSD}
   , BSD, BaseUnix, StrUtils, FileUtil
   {$ENDIF}
   {$IFDEF LINUX}
   , uUDisks, uFileSystemWatcher, DCStrUtils, uOSUtils, FileUtil
   {$ENDIF}
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  uMyWindows, Windows, JwaDbt
  {$ENDIF}
  ;

{$IFDEF LINUX}
type
  TFakeClass = class
  public
    procedure OnWatcherNotifyEvent(const EventData: TFSWatcherEventData);
    procedure OnUDisksNotify(Reason: TUDisksMethod; const ObjectPath: UTF8String);
  end;
{$ENDIF}

{$IFDEF BSD}
const
  {$warning Remove this two constants when they are added to FreePascal}
  NOTE_MOUNTED = $0008;
  NOTE_UMOUNTED = $0010;

type
  TKQueueDriveEvent = procedure(Event: TDriveWatcherEvent);

  TKQueueDriveEventWatcher = class(TThread)
    private
      kq: Longint;
      Event: TDriveWatcherEvent;
      FErrorMsg: String;
      FOnError: TNotifyEvent;
      FOnDriveEvent: TKQueueDriveEvent;
      FFinished: Boolean;
      procedure RaiseErrorEvent;
      procedure RaiseDriveEvent;
    protected
      procedure Execute; override;
      procedure DoTerminate; override;
    public
      property ErrorMsg: String read FErrorMsg;
      property OnError: TNotifyEvent read FOnError write FOnError;
      property OnDriveEvent: TKQueueDriveEvent read FOnDriveEvent write FOnDriveEvent;
      constructor Create();
      destructor Destroy; override;
    end;
{$ENDIF}

var
  FObservers: TDriveWatcherObserverList = nil;
  InitializeCounter: Integer = 0;
  {$IFDEF LINUX}
  FakeClass: TFakeClass = nil;
  IsUDisksAvailable: Boolean = False;
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  OldWProc: WNDPROC;
  {$ENDIF}
  {$IFDEF BSD}
  KQueueDriveWatcher: TKQueueDriveEventWatcher;
  {$ENDIF}

procedure DoDriveAdded(const ADrive: PDrive);
var
  i: Integer;
begin
  for i := 0 to FObservers.Count - 1 do
    FObservers[i](dweDriveAdded, ADrive);
end;

procedure DoDriveRemoved(const ADrive: PDrive);
var
  i: Integer;
begin
  for i := 0 to FObservers.Count - 1 do
    FObservers[i](dweDriveRemoved, ADrive);
end;

procedure DoDriveChanged(const ADrive: PDrive);
var
  i: Integer;
begin
  for i := 0 to FObservers.Count - 1 do
    FObservers[i](dweDriveChanged, ADrive);
end;

{$IFDEF MSWINDOWS}
function MyWndProc(hWnd: HWND; uiMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  ADrive: PDrive = nil;
begin
  case uiMsg of
    WM_DEVICECHANGE:
      case wParam of
        DBT_DEVICEARRIVAL:
          DoDriveAdded(ADrive);
        DBT_DEVICEREMOVECOMPLETE:
          DoDriveRemoved(ADrive);
      end;
  end; // case
  Result := CallWindowProc(OldWProc, hWnd, uiMsg, wParam, lParam);
end;

procedure SetMyWndProc(Handle : HWND);
begin
  {$PUSH}{$HINTS OFF}
  OldWProc := WNDPROC(SetWindowLongPtr(Handle, GWL_WNDPROC, LONG_PTR(@MyWndProc)));
  {$POP}
end;
{$ENDIF}

{$IFDEF BSD}
procedure KQueueDriveWatcher_OnDriveEvent(Event: TDriveWatcherEvent);
begin
  case Event of
    dweDriveAdded:
      DoDriveAdded(nil);
    dweDriveRemoved:
      DoDriveRemoved(nil);
  end; { case }
end;
{$ENDIF}

class procedure TDriveWatcher.Initialize(Handle: HWND);
begin
  Inc(InitializeCounter);
  if InitializeCounter > 1 then
    // Already initialized.
    Exit;

  FObservers := TDriveWatcherObserverList.Create;

  {$IFDEF LINUX}
  FakeClass := TFakeClass.Create;

  if uUDisks.Initialize then
  begin
    IsUDisksAvailable := True;
    uUDisks.AddObserver(@FakeClass.OnUDisksNotify);
  end
  else
  begin
    DCDebug('Detecting devices through /etc/mtab.');
    TFileSystemWatcher.AddWatch('/etc', [wfFileNameChange], @FakeClass.OnWatcherNotifyEvent);
  end;
  {$ENDIF}

  {$IFDEF MSWINDOWS}
  SetMyWndProc(Handle);
  {$ENDIF}

  {$IFDEF BSD}
  KQueueDriveWatcher := TKQueueDriveEventWatcher.Create();
  KQueueDriveWatcher.OnDriveEvent := @KQueueDriveWatcher_OnDriveEvent;
  KQueueDriveWatcher.Start;
  {$ENDIF}
end;

class procedure TDriveWatcher.Finalize;
begin
  Dec(InitializeCounter);
  if InitializeCounter <> 0 then
    // Don't finalize yet.
    Exit;

  {$IFDEF LINUX}
  if IsUDisksAvailable then
  begin
    uUDisks.RemoveObserver(@FakeClass.OnUDisksNotify);
    uUDisks.Finalize;
    IsUDisksAvailable := False;
  end;
  TFileSystemWatcher.RemoveWatch('/etc', @FakeClass.OnWatcherNotifyEvent);
  if Assigned(FakeClass) then
    FreeAndNil(FakeClass);
  {$ENDIF}

  {$IFDEF BSD}
  KQueueDriveWatcher.Terminate;
  FreeAndNil(KQueueDriveWatcher);
  {$ENDIF}

  if Assigned(FObservers) then
    FreeAndNil(FObservers);
end;

class procedure TDriveWatcher.AddObserver(Func: TDriveWatcherEventNotify);
begin
  if FObservers.IndexOf(Func) < 0 then
    FObservers.Add(Func);
end;

class procedure TDriveWatcher.RemoveObserver(Func: TDriveWatcherEventNotify);
begin
  FObservers.Remove(Func);
end;

{$IFDEF LINUX}
function BeginsWithString(const patterns: array of string; const strings: array of string): Boolean;
var
  i, j: Integer;
begin
  for i := Low(strings) to High(strings) do
  begin
    for j := Low(patterns) to High(patterns) do
      if StrBegins(strings[i], patterns[j]) then
        Exit(True);
  end;
  Result := False;
end;

function IsPartOfString(const patterns: array of string; const str: string): Boolean;
var
  I: Integer;
begin
  for I := Low(patterns) to High(patterns) do
    if Pos(patterns[I], str) > 0 then
      Exit(True);
  Result := False;
end;

function UDisksGetDeviceInfo(const DeviceObjectPath: UTF8String;
                             const Devices: TUDisksDevicesInfos;
                             out DeviceInfo: TUDisksDeviceInfo): Boolean;
var
  i: Integer;
begin
  if Assigned(Devices) then
  begin
    for i := Low(Devices) to High(Devices) do
    begin
      if Devices[i].DeviceObjectPath = DeviceObjectPath then
      begin
        DeviceInfo := Devices[i];
        Exit(True);
      end;
    end;
    Result := False;
  end
  else
  begin
    // Devices not supplied, retrieve info from UDisks.
    Result := uUDisks.GetDeviceInfo(DeviceObjectPath, DeviceInfo);
  end;
end;

procedure UDisksDeviceToDrive(const Devices: TUDisksDevicesInfos; const DeviceInfo: TUDisksDeviceInfo; out Drive: PDrive);
var
  OwnerDevice: TUDisksDeviceInfo;
begin
  New(Drive);
  with DeviceInfo do
  begin
    Drive^.DeviceId := DeviceFile;
    Drive^.DisplayName := DevicePresentationName;
    if DeviceIsMounted and (Length(DeviceMountPaths) > 0) then
    begin
      Drive^.Path := DeviceMountPaths[0];
      if Drive^.DisplayName = EmptyStr then
      begin
        if Drive^.Path <> PathDelim then
          Drive^.DisplayName := ExtractFileName(Drive^.Path)
        else
          Drive^.DisplayName := PathDelim;
      end;
    end
    else
    begin
      Drive^.Path := EmptyStr;
      if Drive^.DisplayName = EmptyStr then
      begin
        if (IdLabel <> EmptyStr) then
          Drive^.DisplayName := IdLabel
        else
          Drive^.DisplayName := ExtractFileName(DeviceFile);
      end;
    end;
    Drive^.DriveLabel := IdLabel;
    Drive^.FileSystem := IdType;

    if DeviceIsPartition then
    begin
      if UDisksGetDeviceInfo(PartitionSlave, Devices, OwnerDevice) and
         OwnerDevice.DeviceIsRemovable then
      begin
        // Removable partition usually means pen-drive type.
        if BeginsWithString(['usb'], OwnerDevice.DriveConnectionInterface) then
          Drive^.DriveType := dtRemovableUsb
        else
          Drive^.DriveType := dtRemovable;
      end
      else
        Drive^.DriveType := dtHardDisk;
    end
    else if DeviceIsDrive then
    begin
      if BeginsWithString(['flash'], DriveMediaCompatibility) then
        Drive^.DriveType := dtFlash
      else if BeginsWithString(['floppy'], DriveMediaCompatibility) then
        Drive^.DriveType := dtFloppy
      else if BeginsWithString(['optical'], DriveMediaCompatibility) then
        Drive^.DriveType := dtOptical
      else if BeginsWithString(['usb'], DriveConnectionInterface) then
        Drive^.DriveType := dtRemovableUsb
      else
        Drive^.DriveType := dtUnknown;
    end
    else if DeviceIsSystemInternal then
      Drive^.DriveType := dtHardDisk
    else
      Drive^.DriveType := dtUnknown;

    Drive^.IsMediaAvailable := DeviceIsMediaAvailable;
    Drive^.IsMediaEjectable := DeviceIsDrive and DriveIsMediaEjectable;
    Drive^.IsMediaRemovable := DeviceIsRemovable;
    Drive^.IsMounted := DeviceIsMounted;
    Drive^.AutoMount := (DeviceAutomountHint = EmptyStr) or (DeviceAutomountHint = 'always');
  end;
end;
{$ENDIF}

class function TDriveWatcher.GetDrivesList: TDrivesList;
{$IF DEFINED(MSWINDOWS)}
var
  Drive : PDrive;
  DriveNum: Integer;
  DriveBits: DWORD;
  WinDriveType: UINT;
  DriveLetter: AnsiChar;
  DrivePath: String;
  Key: HKEY;
  RegDrivePath: WideString;
  NetworkPath: array[0..Pred(MAX_PATH)] of WideChar;
  NetworkPathSize: DWORD = MAX_PATH * SizeOf(WideChar);
begin
  Result := TDrivesList.Create;
  { fill list }
  DWORD(DriveBits) := GetLogicalDrives;
  for DriveNum := 0 to 25 do
  begin
    if ((DriveBits shr DriveNum) and $1) = 0 then
    begin
      // Try to find in mapped network drives
      DriveLetter := AnsiChar(DriveNum + Ord('a'));
      RegDrivePath := 'Network' + PathDelim + DriveLetter;
      if RegOpenKeyExW(HKEY_CURRENT_USER, PWideChar(RegDrivePath), 0, KEY_READ, Key) = ERROR_SUCCESS then
      begin
        if RegQueryValueExW(Key, 'RemotePath', nil, nil, @NetworkPath, @NetworkPathSize) = ERROR_SUCCESS then
        begin
          New(Drive);
          Result.Add(Drive);
          FillChar(Drive^, SizeOf(TDrive), #0);
          with Drive^ do
          begin
            Path := DriveLetter + ':\';
            DisplayName := DriveLetter;
            DriveLabel := UTF8Encode(WideString(NetworkPath));
            DriveType := dtNetwork;
            AutoMount := True;
          end;
        end;
        RegCloseKey(Key);
      end;
      Continue;
    end;

    DriveLetter := AnsiChar(DriveNum + Ord('a'));
    DrivePath := DriveLetter + ':\';
    WinDriveType := GetDriveType(PChar(DrivePath));
    if WinDriveType = DRIVE_NO_ROOT_DIR then Continue;
    New(Drive);
    Result.Add(Drive);
    with Drive^ do
    begin
      DeviceId := EmptyStr;
      Path := DrivePath;
      DisplayName := DriveLetter;
      DriveLabel := EmptyStr;
      FileSystem := EmptyStr;
      IsMediaAvailable := True;
      IsMediaEjectable := False;
      IsMediaRemovable := False;
      IsMounted := True;
      AutoMount := True;

      case WinDriveType of
        DRIVE_REMOVABLE:
          begin
            if DriveLetter in ['a', 'b'] then
              DriveType := dtFloppy
            else
              DriveType := dtFlash;
            IsMediaEjectable := True;
            IsMediaRemovable := True;
          end;
        DRIVE_FIXED:
          DriveType := dtHardDisk;
        DRIVE_REMOTE:
          DriveType := dtNetwork;
        DRIVE_CDROM:
          begin
            DriveType := dtOptical;
            IsMediaEjectable := True;
            IsMediaRemovable := True;
          end;
        DRIVE_RAMDISK:
          DriveType := dtRamDisk;
        else
          DriveType := dtUnknown;
      end;

      if IsMediaAvailable then
      begin
        case DriveType of
          dtFloppy: ; // Don't retrieve, it's slow.
          dtHardDisk:
            begin
              DriveLabel := mbGetVolumeLabel(Path, True);
              FileSystem := mbGetFileSystem(DrivePath);
            end;
          dtNetwork:
            DriveLabel := mbGetRemoteFileName(Path);
          else
            DriveLabel := mbGetVolumeLabel(Path, True);
        end;
      end;
    end;
  end;
end;
{$ELSEIF DEFINED(LINUX)}
  function CheckMountEntry(MountEntry: PMountEntry): Boolean;
  begin
    Result:= False;
    with MountEntry^ do
    begin
      // check filesystem
      if (mnt_fsname = 'proc') then Exit;

      // check mount dir
      if (mnt_dir = '') or
         (mnt_dir = '/') or
         (mnt_dir = 'none') or
         (mnt_dir = '/proc') or
         (StrBegins(mnt_dir, '/dev/')) or
         (StrBegins(mnt_dir, '/sys/')) or
         (StrBegins(mnt_dir, '/proc/')) then Exit;

      // check file system type
      if (mnt_type = 'ignore') or
         (mnt_type = 'none') or
         (mnt_type = 'cgroup') or
         (mnt_type = 'cpuset') or
         (mnt_type = 'tmpfs') or
         (mnt_type = 'proc') or
         (mnt_type = 'swap') or
         (mnt_type = 'sysfs') or
         (mnt_type = 'debugfs') or
         (mnt_type = 'devtmpfs') or
         (mnt_type = 'devpts') or
         (mnt_type = 'fusectl') or
         (mnt_type = 'securityfs') or
         (mnt_type = 'binfmt_misc') or
         (mnt_type = 'fuse.gvfs-fuse-daemon') or
         (mnt_type = 'fuse.truecrypt') or
         (mnt_type = 'nfsd') or
         (mnt_type = 'usbfs') or
         (mnt_type = 'mqueue') or
         (mnt_type = 'configfs') or
         (mnt_type = 'hugetlbfs') or
         (mnt_type = 'selinuxfs') or
         (mnt_type = 'rpc_pipefs') then Exit;
    end;
    Result:= True;
  end;
  function UDisksGetDeviceObjectByUUID(const UUID: String; const Devices: TUDisksDevicesInfos): String;
  var
    i: Integer;
  begin
    for i := Low(Devices) to High(Devices) do
      if Devices[i].IdUuid = UUID then
        Exit(Devices[i].DeviceObjectPath);
    Result := EmptyStr;
  end;
  function UDisksGetDeviceObjectByLabel(const DriveLabel: String; const Devices: TUDisksDevicesInfos): String;
  var
    i: Integer;
  begin
    for i := Low(Devices) to High(Devices) do
      if Devices[i].IdLabel = DriveLabel then
        Exit(Devices[i].DeviceObjectPath);
    Result := EmptyStr;
  end;
function UDisksGetDeviceObjectByDeviceFile(const DeviceFile: String; const Devices: TUDisksDevicesInfos): String;
var
  i: Integer;
begin
  for i := Low(Devices) to High(Devices) do
    if Devices[i].DeviceFile = DeviceFile then
      Exit(Devices[i].DeviceObjectPath);
  Result := EmptyStr;
end;

var
  AddedDevices: TStringList = nil;
  AddedMountPoints: TStringList = nil;
  HaveUDisksDevices: Boolean = False;

  function CheckDevice(const Device: String): Boolean;
  begin
    // If UDisks is available name=value pair should have been handled,
    // so we are free to check the device name. Otherwise don't check it
    // if it is a known name=value pair.
    Result := HaveUDisksDevices or
              not (StrBegins(Device, 'UUID=') or
                   StrBegins(Device, 'LABEL='));
  end;

  // Checks if device on some mount point hasn't been added yet.
  function CanAddDevice(const Device, MountPoint: String): Boolean;
  var
    Idx: Integer;
  begin
    Idx := AddedMountPoints.IndexOf(MountPoint);
    Result := (Idx < 0) or
              (CheckDevice(Device) and
               CheckDevice(AddedDevices[Idx]) and
               (AddedDevices[Idx] <> Device));
  end;

  function GetDrive(const DrivesList: TDrivesList;
                    const Device, MountPoint: String): PDrive;
  var
    i: Integer;
  begin
    for i := 0 to DrivesList.Count - 1 do
    begin
      // If UDisks not available only check mount points.
      if (DrivesList[i]^.Path = MountPoint) and
         (not CheckDevice(Device) or
          not CheckDevice(DrivesList[i]^.DeviceId) or
          (DrivesList[i]^.DeviceId = Device)) then
        Exit(DrivesList[i]);
    end;
    Result := nil;
  end;

  function GetStrMaybeQuoted(const s: string): string;
  var
    i: Integer;
  begin
    Result := '';
    if Length(s) > 0 then
    begin
      if s[1] in ['"', ''''] then
      begin
        for i := Length(s) downto 2 do
        begin
          if s[i] = s[1] then
            Exit(Copy(s, 2, i-2));
        end;
      end
      else
        Result := s;
    end;
  end;

  function IsDeviceMountedAtRoot(const UDisksDevice: TUDisksDeviceInfo): Boolean;
  var
    i: Integer;
  begin
    if UDisksDevice.DeviceIsMounted then
    begin
      for i := Low(UDisksDevice.DeviceMountPaths) to High(UDisksDevice.DeviceMountPaths) do
        if UDisksDevice.DeviceMountPaths[i] = PathDelim then
          Exit(True);
    end;
    Result := False;
  end;

const
  MntEntFileList: array[1..2] of PChar = (_PATH_FSTAB, _PATH_MOUNTED);
var
  Drive : PDrive = nil;
  ExistingDrive : PDrive;
  fstab: PIOFile;
  pme: PMountEntry;
  I: Integer;
  UDisksDevices: TUDisksDevicesInfos;
  UDisksDevice: TUDisksDeviceInfo;
  UDisksDeviceObject: UTF8String;
  DeviceFile: String;
  MountPoint: String;
  HandledByUDisks: Boolean = False;
begin
  Result := TDrivesList.Create;
  try
    AddedDevices := TStringList.Create;
    AddedMountPoints := TStringList.Create;

    if IsUDisksAvailable then
      HaveUDisksDevices := uUDisks.EnumerateDevices(UDisksDevices);

    // Storage devices have to be in fstab or mtab and reported by UDisks.
    for I:= Low(MntEntFileList) to High(MntEntFileList) do
    begin
      fstab:= setmntent(MntEntFileList[I],'r');
      if not Assigned(fstab) then Continue;
      pme:= getmntent(fstab);
      while (pme <> nil) do
      begin
        if CheckMountEntry(pme) then
        begin
          DeviceFile := StrPas(pme^.mnt_fsname);
          MountPoint := SysToUTF8(StrPas(pme^.mnt_dir));
          if MountPoint <> PathDelim then
            MountPoint := ExcludeTrailingPathDelimiter(MountPoint);

          if HaveUDisksDevices then
          begin
            // Handle "/dev/", "UUID=" and "LABEL=" through UDisks if available.
            if StrBegins(DeviceFile, 'UUID=') then
            begin
              UDisksDeviceObject := UDisksGetDeviceObjectByUUID(
                  GetStrMaybeQuoted(Copy(DeviceFile, 6, MaxInt)), UDisksDevices);
              if UDisksDeviceObject <> EmptyStr then
                DeviceFile := '/dev/' + ExtractFileName(UDisksDeviceObject);
              HandledByUDisks := True;
            end
            else if StrBegins(DeviceFile, 'LABEL=') then
            begin
              UDisksDeviceObject := UDisksGetDeviceObjectByLabel(
                  GetStrMaybeQuoted(Copy(DeviceFile, 7, MaxInt)), UDisksDevices);
              if UDisksDeviceObject <> EmptyStr then
                DeviceFile := '/dev/' + ExtractFileName(UDisksDeviceObject);
              HandledByUDisks := True;
            end
            else if StrBegins(DeviceFile, '/dev/') then
            begin
              DeviceFile := mbCheckReadLinks(DeviceFile);
              if StrBegins(DeviceFile, '/dev/') then
                UDisksDeviceObject := DeviceFileToUDisksObjectPath(DeviceFile)
              else
                UDisksDeviceObject := UDisksGetDeviceObjectByDeviceFile(DeviceFile, UDisksDevices);
              HandledByUDisks := True;
            end
            else
              HandledByUDisks := False;

            if HandledByUDisks then
            begin
              if CanAddDevice(DeviceFile, MountPoint) and
                 UDisksGetDeviceInfo(UDisksDeviceObject, UDisksDevices, UDisksDevice) then
              begin
                if not UDisksDevice.DevicePresentationHide then
                begin
                  UDisksDeviceToDrive(UDisksDevices, UDisksDevice, Drive);
                  Drive^.Path := MountPoint;
                  Drive^.DisplayName := UDisksDevice.DevicePresentationName;
                  if Drive^.DisplayName = EmptyStr then
                  begin
                    if MountPoint <> PathDelim then
                      Drive^.DisplayName := ExtractFileName(MountPoint)
                    else
                      Drive^.DisplayName := PathDelim;
                  end;
                end;
              end
              // Even if mounted device is not listed by UDisks add it anyway the standard way.
              else if I = 2 then // MntEntFileList[2] = _PATH_MOUNTED
                HandledByUDisks := False;
              // Else don't add the device if it's not listed by UDisks.
            end;
          end;

          // Add by entry in fstab/mtab.
          if not HandledByUDisks then
          begin
            DeviceFile := mbCheckReadLinks(DeviceFile);
            if CanAddDevice(DeviceFile, MountPoint) then
            begin
              New(Drive);
              with Drive^ do
              begin
                DeviceId := DeviceFile;
                Path := MountPoint;
                if MountPoint <> PathDelim then
                  DisplayName := ExtractFileName(Path)
                else
                  DisplayName := PathDelim;
                DriveLabel := Path;
                FileSystem := StrPas(pme^.mnt_type);

                if IsPartOfString(['ISO9660', 'CDROM', 'CDRW', 'DVD', 'UDF'], UpperCase(FileSystem)) then // for external usb cdrom and dvd
                    DriveType := dtOptical else
                if IsPartOfString(['ISO9660', 'CDROM', 'CDRW', 'DVD'], UpperCase(DeviceFile)) then
                  DriveType := dtOptical else
                if IsPartOfString(['FLOPPY'], UpperCase(FileSystem)) then
                  DriveType := dtFloppy else
                if IsPartOfString(['FLOPPY', '/DEV/FD'], UpperCase(DeviceFile)) then
                  DriveType := dtFloppy else
                if IsPartOfString(['ZIP', 'USB', 'CAMERA'], UpperCase(FileSystem)) then
                  DriveType := dtFlash else
                if IsPartOfString(['/MEDIA/'], UpperCase(MountPoint)) then
                    DriveType := dtFlash else
                if IsPartOfString(['NFS', 'SMB', 'NETW', 'CIFS'], UpperCase(FileSystem)) then
                  DriveType := dtNetwork
                else
                  DriveType := dtHardDisk;

                IsMediaAvailable:= True;
                IsMediaEjectable:= (DriveType = dtOptical);
                IsMediaRemovable:= DriveType in [dtFloppy, dtOptical, dtFlash];
                // If drive from /etc/mtab then it is mounted
                // else it will be checked via mtab below
                IsMounted:= (MntEntFileList[I] = _PATH_MOUNTED);
                AutoMount:= True;
              end;
            end
            // Mark drive as mounted if found in mtab.
            else if MntEntFileList[I] = _PATH_MOUNTED then
            begin
              ExistingDrive := GetDrive(Result, DeviceFile, MountPoint);
              if Assigned(ExistingDrive) then
              begin
                ExistingDrive^.IsMounted := True;
                if ExistingDrive^.FileSystem = EmptyStr then
                  ExistingDrive^.FileSystem := StrPas(pme^.mnt_type);
              end;
            end;
          end;

          // If drive object has been created add it to the list.
          if Assigned(Drive) then
          begin
            Result.Add(Drive);
            Drive := nil;
            AddedDevices.Add(DeviceFile);
            AddedMountPoints.Add(MountPoint);

            {$IFDEF DEBUG}
            DCDebug('Adding drive "' + DeviceFile + '" with mount point "' + MountPoint + '"');
            {$ENDIF}
          end;
        end;
        pme:= getmntent(fstab);
      end;
      endmntent(fstab);
    end;

    if HaveUDisksDevices then
    begin
      for i := Low(UDisksDevices) to High(UDisksDevices) do
      begin
        // Add drives not having a partition table which are usually devices
        // with removable media like CDROM, floppy - they can be mounted.
        // Don't add drives with partition table because they cannot be mounted.
        // Don't add drives with loop device because they cannot be mounted.
        // Add devices reported as "filesystem".
        if ((UDisksDevices[i].DeviceIsDrive and not UDisksDevices[i].DeviceIsPartitionTable) or
           (UDisksDevices[i].IdUsage = 'filesystem')) and
           (StrBegins(UDisksDevices[i].DeviceFile, '/dev/loop') = False) and
           (not UDisksDevices[i].DevicePresentationHide) then
        begin
          if (AddedDevices.IndexOf(UDisksDevices[i].DeviceFile) < 0) and
             (not IsDeviceMountedAtRoot(UDisksDevices[i])) then
          begin
            UDisksDeviceToDrive(UDisksDevices, UDisksDevices[i], Drive);
            Result.Add(Drive);
            Drive := nil;
            AddedDevices.Add(UDisksDevices[i].DeviceFile);
            AddedMountPoints.Add(EmptyStr);

            {$IFDEF DEBUG}
            DCDebug('Adding UDisks drive "' + UDisksDevices[i].DeviceFile + '"');
            {$ENDIF}
          end;
        end;
      end;
    end;

  finally
    if Assigned(AddedDevices) then
      AddedDevices.Free;
    if Assigned(AddedMountPoints) then
      AddedMountPoints.Free;
    if Assigned(Drive) then
      Dispose(Drive);
  end;
end;
{$ELSEIF DEFINED(BSD)}
  function GetDriveTypeFromDeviceOrFSType(const DeviceId, FSType: String): TDriveType;
  begin
    // using filesystem type
    if FSType = 'swap' then
      Result := dtUnknown
    else if FSType = 'zfs' then
      Result := dtHardDisk
    else if FSType = 'nfs' then
      Result := dtNetwork
    else if FSType = 'smbfs' then
      Result := dtNetwork
    else if FSType = 'cifs' then
      Result := dtNetwork
{$IF DEFINED(DARWIN)}
    else if FSType = 'hfs' then
      Result := dtHardDisk
    else if FSType = 'ntfs' then
      Result := dtHardDisk
    else if FSType = 'msdos' then
      Result := dtHardDisk
    else if FSType = 'exfat' then
      Result := dtHardDisk
    else if FSType = 'udf' then
      Result := dtOptical
    else if FSType = 'cd9660' then
      Result := dtOptical
    else if FSType = 'cddafs' then
      Result := dtOptical
    else if FSType = 'afpfs' then
      Result := dtNetwork
    else if FSType = 'webdav' then
      Result := dtNetwork
{$ENDIF}
    // using device name
    else if AnsiStartsStr('/dev/ad', DeviceId) then
      Result := dtHardDisk
    else if AnsiStartsStr('/dev/acd', DeviceId) then
      Result := dtOptical // CD-ROM (IDE)
    else if AnsiStartsStr('/dev/da', DeviceId) then
      Result := dtFlash // USB
    else if AnsiStartsStr('/dev/cd', DeviceId) then
      Result := dtOptical // CD-ROM (SCSI)
    else if AnsiStartsStr('/dev/mcd', DeviceId) then
      Result := dtOptical // CD-ROM (other)
    else if AnsiStartsStr('/dev/fd', DeviceId) then
      Result := dtFloppy
    else if AnsiStartsStr('/dev/sa', DeviceId) then
      Result := dtUnknown // Tape (SCSI)
    else if AnsiStartsStr('/dev/ast', DeviceId) then
      Result := dtUnknown // Tape (IDE)
    else if AnsiStartsStr('/dev/fla', DeviceId) then
      Result := dtHardDisk // Flash drive
    else if AnsiStartsStr('/dev/aacd', DeviceId)
      or AnsiStartsStr('/dev/mlxd', DeviceId)
      or AnsiStartsStr('/dev/mlyd', DeviceId)
      or AnsiStartsStr('/dev/amrd', DeviceId)
      or AnsiStartsStr('/dev/idad', DeviceId)
      or AnsiStartsStr('/dev/idad', DeviceId)
      or AnsiStartsStr('/dev/twed', DeviceId) then
      Result := dtHardDisk
    else
      Result := dtUnknown; // devfs, nullfs, procfs, etc.
  end;
const
  MAX_FS = 128;
var
  drive: PDrive;
  fstab: PFSTab;
  fs: TStatFS;
  fsList: array[0..MAX_FS] of TStatFS;
  iMounted, iAdded, count: Integer;
  found: boolean;
  dtype: TDriveType;
begin
  Result := TDrivesList.Create;

  fstab := getfsent();
  while fstab <> nil do
  begin
    dtype := GetDriveTypeFromDeviceOrFSType(fstab^.fs_spec, fstab^.fs_vfstype);

    // only add known drive types and skip root directory
    if (dtype = dtUnknown) or (fstab^.fs_file = PathDelim) then
    begin
      fstab := getfsent();
      Continue;
    end; { if }

    New(drive);
    Result.Add(drive);

    with drive^ do
    begin
      Path := SysToUTF8(fstab^.fs_file);
      DisplayName := ExtractFileName(Path);
      DriveLabel := Path;
      FileSystem := fstab^.fs_vfstype;
      DeviceId := fstab^.fs_spec;
      DriveType := dtype;
      IsMediaAvailable := false;
      IsMediaEjectable := false;
      IsMediaRemovable := false;
      IsMounted := false;
      AutoMount := true;
    end; { with }

    fstab := getfsent();
  end; { while }
  endfsent();

  count := getfsstat(@fsList, SizeOf(fsList), MNT_WAIT);
  for iMounted := 0 to count - 1 do
  begin
    fs := fsList[iMounted];

    // check if already added using fstab
    found := false;
    for iAdded := 0 to Result.Count - 1 do
    begin
      if Result[iAdded]^.Path = fs.mountpoint then
      begin
        drive := Result[iAdded];
        with drive^ do
        begin
          IsMounted := true;
          IsMediaAvailable := true;
        end;
        found := true;
        break;
      end; { if }
    end; { for }

    if found then
      continue;

    dtype := GetDriveTypeFromDeviceOrFSType(
                                            {$IF DEFINED(DARWIN)}
                                            fs.mntfromname
                                            {$ELSE}
                                            fs.mnfromname
                                            {$ENDIF},
                                            fs.fstypename
                                            );

    // only add known drive types and skip root directory
    if (dtype = dtUnknown) or (fs.mountpoint = PathDelim) then
      Continue;

    New(drive);
    Result.Add(drive);

    with drive^ do
    begin
      Path := SysToUTF8(fs.mountpoint);
      DisplayName := ExtractFileName(Path);
      DriveLabel := Path;
      FileSystem := fs.fstypename;
      DeviceId := {$IF DEFINED(DARWIN)}fs.mntfromname{$ELSE}fs.mnfromname{$ENDIF};
      DriveType := dtype;
      IsMediaAvailable := true;
      IsMediaEjectable := false;
      IsMediaRemovable := false;
      IsMounted := true;
      AutoMount := true;
    end; { with }
  end; { for }
end;
{$ELSE}
begin
  Result := TDrivesList.Create;
end;
{$ENDIF}

{$IFDEF LINUX}
procedure TFakeClass.OnWatcherNotifyEvent(const EventData: TFSWatcherEventData);
var
  ADrive: PDrive = nil;
begin
  if (EventData.EventType = fswFileDeleted) and (Pos('mtab', EventData.FileName) = 1) then
    DoDriveChanged(ADrive);
end;

procedure TFakeClass.OnUDisksNotify(Reason: TUDisksMethod; const ObjectPath: UTF8String);
var
  ADrive: PDrive = nil;
  DeviceInfo: TUDisksDeviceInfo;
begin
  if uUDisks.GetDeviceInfo(ObjectPath, DeviceInfo) then
    UDisksDeviceToDrive(nil, DeviceInfo, ADrive);
  try
    case Reason of
      UDisks_DeviceAdded:
        DoDriveAdded(ADrive);
      UDisks_DeviceRemoved:
        DoDriveRemoved(ADrive);
      UDisks_DeviceChanged:
        DoDriveChanged(ADrive);
    end;
  finally
    if Assigned(ADrive) then
      Dispose(ADrive);
  end;
end;
{$ENDIF}

{$IFDEF BSD}
{ TKQueueDriveEventWatcher }

procedure TKQueueDriveEventWatcher.RaiseErrorEvent;
begin
  DCDebug(Self.ErrorMsg);
  if Assigned(Self.FOnError) then
    Self.FOnError(Self);
end;

procedure TKQueueDriveEventWatcher.RaiseDriveEvent;
begin
  if Assigned(Self.FOnDriveEvent) then
    Self.FOnDriveEvent(Self.Event);
end;

procedure TKQueueDriveEventWatcher.Execute;
const
  KQUEUE_ERROR = -1;
var
  ke: TKEvent;
begin
  try
    Self.kq := kqueue();
    if Self.kq = KQUEUE_ERROR then
    begin
      Self.FErrorMsg := 'ERROR: kqueue()';
      Synchronize(@Self.RaiseErrorEvent);
      exit;
    end; { if }

    try
      FillByte(ke, SizeOf(ke), 0);
      EV_SET(@ke, 1, EVFILT_FS, EV_ADD, 0, 0, nil);
      if kevent(kq, @ke, 1, nil, 0, nil) = KQUEUE_ERROR then
      begin
        Self.FErrorMsg := 'ERROR: kevent()';
        Synchronize(@Self.RaiseErrorEvent);
        exit;
      end; { if }

      while not Terminated do
      begin
        FillByte(ke, SizeOf(ke), 0);
        if kevent(kq, nil, 0, @ke, 1, nil) = KQUEUE_ERROR then
            break;

        case ke.Filter of
          EVFILT_TIMER: // user triggered
            continue;

          EVFILT_FS:
          begin
            if (ke.FFlags and NOTE_MOUNTED <> 0) then
            begin
              Self.Event := dweDriveAdded;
  {$IFDEF DARWIN}
              Sleep(1 * 1000); // wait so drive gets available in MacOSX
  {$ENDIF}
              Synchronize(@Self.RaiseDriveEvent);
            end { if }
            else if (ke.FFlags and NOTE_UMOUNTED <> 0) then
            begin
              Self.Event := dweDriveRemoved;
  {$IFDEF DARWIN}
              Sleep(1 * 1000); // wait so drive disappears in MacOSX
  {$ENDIF}
              Synchronize(@Self.RaiseDriveEvent);
            end; { else if }
          end;
        end; { case }
      end; { while }

    finally
      FpClose(Self.kq);
    end; { try - finally }
  finally
    FFinished := True;
  end; { try - finally }
end;

procedure TKQueueDriveEventWatcher.DoTerminate;
var
  ke: TKEvent;
begin
  inherited DoTerminate;

  if Self.kq = -1 then
    Exit;

  FillByte(ke, SizeOf(ke), 0);
  EV_SET(@ke, 0, EVFILT_TIMER, EV_ADD or EV_ONESHOT, 0, 0, nil);
  kevent(Self.kq, @ke, 1, nil, 0, nil);
end;

constructor TKQueueDriveEventWatcher.Create();
begin
  Self.FreeOnTerminate := true;
  Self.FFinished := false;

  inherited Create(true);
end;

destructor TKQueueDriveEventWatcher.Destroy;
begin
  if not Terminated then
  begin
    Self.Terminate;
{$IF (fpc_version<2) or ((fpc_version=2) and (fpc_release<5))}
    If (MainThreadID=GetCurrentThreadID) then
      while not FFinished do
        CheckSynchronize(100);
{$ENDIF}
    WaitFor;
  end; { if }
end;
{$ENDIF}

end.
