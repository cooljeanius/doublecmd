{
    Double Commander
    -------------------------------------------------------------------------
    Shell context menu implementation.

    Copyright (C) 2006-2010  Koblov Alexander (Alexx2000@mail.ru)

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

unit uShellContextMenu;

{$mode delphi}{$H+}

interface

uses
  Classes, SysUtils, Controls, Menus,
  uFile, uDrive;

type

  { EContextMenuException }

  EContextMenuException = class(Exception);

  { TShellContextMenu }

  TShellContextMenu = class(TPopupMenu)
  private
    FFiles: TFiles;
    FDrive: TDrive;
    procedure ContextMenuSelect(Sender: TObject);
    procedure TemplateContextMenuSelect(Sender: TObject);
    procedure DriveMountSelect(Sender: TObject);
    procedure DriveUnmountSelect(Sender: TObject);
    procedure DriveEjectSelect(Sender: TObject);
    procedure OpenWithOtherSelect(Sender: TObject);
    procedure OpenWithMenuItemSelect(Sender: TObject);
    function FillOpenWithSubMenu: Boolean;
  public
    constructor Create(Owner: TWinControl; ADrive: PDrive); reintroduce; overload;
    constructor Create(Owner: TWinControl; var Files : TFiles; Background: Boolean); reintroduce; overload;
    destructor Destroy; override;
  end;

implementation

uses
  LCLProc, Dialogs, IniFiles, Graphics, uFindEx, uDCUtils,
  uOSUtils, uFileProcs, uShellExecute, uLng, uGlobs, uPixMapManager, uMyUnix,
  fMain, fFileProperties, DCOSUtils, DCStrUtils
  {$IF DEFINED(DARWIN)}
  , MacOSAll
  {$ELSEIF DEFINED(LINUX)}
  , uMimeActions, fOpenWith
  {$ENDIF}
  ;

const
  sCmdVerbProperties = 'properties';

function GetGnomeTemplateMenu(out Items: TStringList): Boolean;
var
  userDirs: TStringList = nil;
  templateDir: UTF8String;
  searchRec: TSearchRecEx;
begin
  Result:= False;
  try
    Items:= nil;
    templateDir:= GetHomeDir + '/.config/user-dirs.dirs';
    if not mbFileExists(templateDir) then Exit;
    userDirs:= TStringList.Create;
    userDirs.LoadFromFile(templateDir);
    templateDir:= userDirs.Values['XDG_TEMPLATES_DIR'];
    if Length(templateDir) = 0 then Exit;
    templateDir:= IncludeTrailingPathDelimiter(mbExpandFileName(TrimQuotes(templateDir)));
    if mbDirectoryExists(templateDir) then
    begin
      if FindFirstEx(templateDir, faAnyFile, searchRec) = 0 then
      begin
        Items:= TStringList.Create;
        repeat
          // Skip directories
          if FPS_ISDIR(searchRec.Attr) then Continue;

          Items.Add(ExtractOnlyFileName(searchRec.Name) + '=' + templateDir + searchRec.Name);
        until FindNextEx(searchRec) <> 0;
        Result:= Items.Count > 0;
      end;
      FindCloseEx(searchRec);
    end;
  finally
    if Assigned(Items) and (Items.Count = 0) then
      FreeAndNil(Items);
    FreeThenNil(userDirs);
  end;
end;

function GetKdeTemplateMenu(out Items: TStringList): Boolean;
var
  I: Integer;
  desktopFile: TIniFile = nil;
  templateDir: array [0..1] of UTF8String;
  searchRec: TSearchRecEx;
  templateName,
  templatePath: UTF8String;
begin
  Result:= False;
  try
    Items:= nil;
    templateDir[0]:= '/usr/share/templates';
    templateDir[1]:= GetHomeDir + '/.kde/share/templates';
    for I:= Low(templateDir) to High(templateDir) do
    if mbDirectoryExists(templateDir[I]) then
    begin
      if FindFirstEx(templateDir[I] + PathDelim + '*.desktop', faAnyFile, searchRec) = 0 then
      begin
        if not Assigned(Items) then Items:= TStringList.Create;
        repeat
          // Skip directories
          if FPS_ISDIR(searchRec.Attr) then Continue;

          try
            desktopFile:= TIniFile.Create(templateDir[I] + PathDelim + searchRec.Name);
            templateName:= desktopFile.ReadString('Desktop Entry', 'Name', EmptyStr);
            templatePath:= desktopFile.ReadString('Desktop Entry', 'URL', EmptyStr);
            templatePath:= GetAbsoluteFileName(templateDir[I] + PathDelim, templatePath);

            Items.Add(templateName + '=' + templatePath);
          finally
            FreeThenNil(desktopFile);
          end;
        until FindNextEx(searchRec) <> 0;
        Result:= Items.Count > 0;
      end;
      FindCloseEx(searchRec);
    end;
  finally
    if Assigned(Items) and (Items.Count = 0) then
      FreeAndNil(Items);
  end;
end;

function GetTemplateMenu(out Items: TStringList): Boolean;
begin
  case GetDesktopEnvironment of
  DE_KDE:
    Result:= GetKdeTemplateMenu(Items);
  else
    Result:= GetGnomeTemplateMenu(Items);
  end;
end;

(* handling user commands from context menu *)
procedure TShellContextMenu.ContextMenuSelect(Sender: TObject);
var
  sCmd: String;
begin
  // ShowMessage((Sender as TMenuItem).Hint);

  sCmd:= (Sender as TMenuItem).Hint;
  with frmMain.ActiveFrame do
  begin
    (*
    if (Pos('{!VFS}',sCmd)>0) and pnlFile.VFS.FindModule(ActiveDir + FileRecItem.sName) then
     begin
        pnlFile.LoadPanelVFS(@FileRecItem);
        Exit;
      end;
    *)

    if SameText(sCmd, sCmdVerbProperties) then
      ShowFileProperties(FileSource, FFiles);

    try
      if not ProcessExtCommand(sCmd, CurrentPath) then
        frmMain.ExecCmd(sCmd);
    except
      on e: EInvalidCommandLine do
        MessageDlg(rsMsgErrorInContextMenuCommand, rsMsgInvalidCommandLine + ': ' + e.Message, mtError, [mbOK], 0);
    end;
  end;
end;

(* handling user commands from template context menu *)
procedure TShellContextMenu.TemplateContextMenuSelect(Sender: TObject);
var
  SelectedItem: TMenuItem;
  FileName: UTF8String;
begin
  // ShowMessage((Sender as TMenuItem).Hint);

  SelectedItem:= (Sender as TMenuItem);
  FileName:= SelectedItem.Caption;
  if InputQuery(rsMsgNewFile, rsMsgEnterName, FileName) then
    begin
      FileName:= FileName + ExtractFileExt(SelectedItem.Hint);
      if CopyFile(SelectedItem.Hint, frmMain.ActiveFrame.CurrentPath + FileName) then
        begin
          frmMain.ActiveFrame.Reload;
          frmMain.ActiveFrame.SetActiveFile(FileName);
        end;
    end;
end;

procedure TShellContextMenu.DriveMountSelect(Sender: TObject);
begin
  MountDrive(@FDrive);
end;

procedure TShellContextMenu.DriveUnmountSelect(Sender: TObject);
begin
  UnmountDrive(@FDrive);
end;

procedure TShellContextMenu.DriveEjectSelect(Sender: TObject);
begin
  EjectDrive(@FDrive);
end;

procedure TShellContextMenu.OpenWithOtherSelect(Sender: TObject);
var
  I: LongInt;
  FileNames: TStringList;
begin
{$IF DEFINED(LINUX)}
  FileNames := TStringList.Create;
  for I := 0 to FFiles.Count - 1 do
    FileNames.Add(FFiles[I].FullPath);
  ShowOpenWithDlg(FileNames);
{$ENDIF}
end;

procedure TShellContextMenu.OpenWithMenuItemSelect(Sender: TObject);
var
  ExecCmd: String;
begin
  ExecCmd := (Sender as TMenuItem).Hint;
  try
    ExecCmdFork(ExecCmd);
  except
    on e: EInvalidCommandLine do
      MessageDlg(rsMsgErrorInContextMenuCommand, rsMsgInvalidCommandLine + ': ' + e.Message, mtError, [mbOK], 0);
  end;
end;

function TShellContextMenu.FillOpenWithSubMenu: Boolean;
{$IF DEFINED(DARWIN)}
var
  I: CFIndex;
  ImageIndex: PtrInt;
  bmpTemp: TBitmap = nil;
  mi, miOpenWith: TMenuItem;
  ApplicationArrayRef: CFArrayRef = nil;
  FileNameCFRef: CFStringRef = nil;
  FileNameUrlRef: CFURLRef = nil;
  ApplicationUrlRef: CFURLRef = nil;
  ApplicationNameCFRef: CFStringRef = nil;
  ApplicationCString: array[0..MAX_PATH-1] of Char;
begin
  Result:= False;
  if (FFiles.Count <> 1) then Exit;
  try
    FileNameCFRef:= CFStringCreateWithFileSystemRepresentation(nil, PChar(FFiles[0].FullPath));
    FileNameUrlRef:= CFURLCreateWithFileSystemPath(nil, FileNameCFRef, kCFURLPOSIXPathStyle, False);
    ApplicationArrayRef:= LSCopyApplicationURLsForURL(FileNameUrlRef,  kLSRolesViewer or kLSRolesEditor or kLSRolesShell);
    if Assigned(ApplicationArrayRef) and (CFArrayGetCount(ApplicationArrayRef) > 0) then
    begin
      Result:= True;
      miOpenWith := TMenuItem.Create(Self);
      miOpenWith.Caption := rsMnuOpenWith;
      Self.Items.Add(miOpenWith);

      for I:= 0 to CFArrayGetCount(ApplicationArrayRef) - 1 do
      begin
        ApplicationUrlRef:= CFURLRef(CFArrayGetValueAtIndex(ApplicationArrayRef, I));
        if CFURLGetFileSystemRepresentation(ApplicationUrlRef,
                                            True,
                                            ApplicationCString,
                                            SizeOf(ApplicationCString)) then
        begin
          mi := TMenuItem.Create(miOpenWith);
          mi.Caption := ExtractOnlyFileName(ApplicationCString);
          mi.Hint := ApplicationCString + #32 + QuoteStr(FFiles[0].FullPath);
          ImageIndex:= PixMapManager.GetApplicationBundleIcon(ApplicationCString, -1);
          if LSCopyDisplayNameForURL(ApplicationUrlRef, ApplicationNameCFRef) = noErr then
          begin
            if CFStringGetCString(ApplicationNameCFRef,
                                  ApplicationCString,
                                  SizeOf(ApplicationCString),
                                  kCFStringEncodingUTF8) then
              mi.Caption := ApplicationCString;
            CFRelease(ApplicationNameCFRef);
          end;
          if ImageIndex >= 0 then
            begin
              bmpTemp:= PixMapManager.GetBitmap(ImageIndex);
              if Assigned(bmpTemp) then
                begin
                  mi.Bitmap.Assign(bmpTemp);
                  FreeAndNil(bmpTemp);
                end;
            end;
          mi.OnClick := Self.OpenWithMenuItemSelect;
          miOpenWith.Add(mi);
        end;
      end;
    end;
  finally
    if Assigned(FileNameCFRef) then
      CFRelease(FileNameCFRef);
    if Assigned(FileNameUrlRef) then
      CFRelease(FileNameUrlRef);
    if Assigned(ApplicationArrayRef) then
      CFRelease(ApplicationArrayRef);
  end;
end;
{$ELSEIF DEFINED(LINUX)}
var
  I: LongInt;
  ImageIndex: PtrInt;
  mi, miOpenWith: TMenuItem;
  FileNames: TStringList;
  DesktopEntries: TList = nil;
  bmpTemp: TBitmap = nil;
begin
  Result := True;
  FileNames := TStringList.Create;
  try
    miOpenWith := TMenuItem.Create(Self);
    miOpenWith.Caption := rsMnuOpenWith;
    Self.Items.Add(miOpenWith);

    for i := 0 to FFiles.Count - 1 do
      FileNames.Add(FFiles[i].FullPath);

    DesktopEntries := GetDesktopEntries(FileNames);

    if Assigned(DesktopEntries) and (DesktopEntries.Count > 0) then
    begin
      for i := 0 to DesktopEntries.Count - 1 do
      begin
        mi := TMenuItem.Create(miOpenWith);
        mi.Caption := PDesktopFileEntry(DesktopEntries[i])^.DisplayName;
        mi.Hint := PDesktopFileEntry(DesktopEntries[i])^.Exec;
        ImageIndex:= PixMapManager.GetIconByName(PDesktopFileEntry(DesktopEntries[i])^.IconName);
        if ImageIndex >= 0 then
          begin
            bmpTemp:= PixMapManager.GetBitmap(ImageIndex);
            if Assigned(bmpTemp) then
              begin
                mi.Bitmap.Assign(bmpTemp);
                FreeAndNil(bmpTemp);
              end;
          end;
        mi.OnClick := Self.OpenWithMenuItemSelect;
        miOpenWith.Add(mi);
      end;
      miOpenWith.AddSeparator;
    end;

    mi := TMenuItem.Create(miOpenWith);
    mi.Caption := rsMnuOpenWithOther;
    mi.OnClick := Self.OpenWithOtherSelect;
    miOpenWith.Add(mi);

  finally
    FreeAndNil(FileNames);
    if Assigned(DesktopEntries) then
    begin
      for i := 0 to DesktopEntries.Count - 1 do
        Dispose(PDesktopFileEntry(DesktopEntries[i]));
      FreeAndNil(DesktopEntries);
    end;
  end;
end;
{$ELSE}
begin
  Result:= False;
end;
{$ENDIF}

constructor TShellContextMenu.Create(Owner: TWinControl; ADrive: PDrive);
var
  mi: TMenuItem;
begin
  inherited Create(Owner);
  FDrive := ADrive^;

  mi := TMenuItem.Create(Self);
  if not ADrive^.IsMounted then
    begin
      if ADrive^.IsMediaAvailable then
        begin
          mi.Caption := rsMnuMount;
          mi.OnClick := Self.DriveMountSelect;
        end
      else
        begin
          mi.Caption := rsMnuNoMedia;
          mi.Enabled := False;
        end;
    end
  else
    begin
      mi.Caption := rsMnuUmount;
      mi.OnClick := Self.DriveUnmountSelect;
    end;
  Self.Items.Add(mi);

  if ADrive^.IsMediaEjectable then
    begin
      mi :=TMenuItem.Create(Self);
      mi.Caption := rsMnuEject;
      mi.OnClick := Self.DriveEjectSelect;
      Self.Items.Add(mi);
    end;
end;

constructor TShellContextMenu.Create(Owner: TWinControl; var Files: TFiles;
  Background: Boolean);
var
  aFile: TFile = nil;
  sl: TStringList = nil;
  I: Integer;
  sAct, sCmd: UTF8String;
  mi, miActions,
  miSortBy: TMenuItem;
  AddActionsMenu: Boolean = False;
  AddOpenWithMenu: Boolean = False;
begin
  inherited Create(Owner);

  FFiles:= Files;

  try

    if not Background then
    begin

    mi:=TMenuItem.Create(Self);
    mi.Action := frmMain.actShellExecute;
    Self.Items.Add(mi);

    mi:=TMenuItem.Create(Self);
    mi.Caption:='-';
    Self.Items.Add(mi);

    aFile := Files[0];
    // Actions submenu
    begin
      miActions:=TMenuItem.Create(Self);
      miActions.Caption:= rsMnuActions;
        
      // Read actions from doublecmd.ext
      sl:=TStringList.Create;
      try
        if gExts.GetExtActions(aFile, sl) then
          begin
            AddActionsMenu := True;

            for I:= 0 to sl.Count - 1 do
              begin
                sAct:= sl.Names[I];
                if (SysUtils.CompareText('OPEN', sAct) = 0) or (SysUtils.CompareText('VIEW', sAct) = 0) or (SysUtils.CompareText('EDIT', sAct) = 0) then Continue;
                sCmd:= sl.ValueFromIndex[I];
                sCmd:= PrepareParameter(sCmd, frmMain.FrameLeft, frmMain.FrameRight, frmMain.ActiveFrame);
                mi:= TMenuItem.Create(miActions);
                mi.Caption:= sAct;
                mi.Hint:= sCmd;
                mi.OnClick:= Self.ContextMenuSelect; // handler
                miActions.Add(mi);
              end;
          end;

          if (Files.Count = 1) and not (aFile.IsDirectory or aFile.IsLinkToDirectory) then
          begin
            if sl.Count = 0 then
              AddActionsMenu := True
            else
              begin
                // now add delimiter
                mi:=TMenuItem.Create(miActions);
                mi.Caption:='-';
                miActions.Add(mi);
              end;

            // now add VIEW item
            mi:=TMenuItem.Create(miActions);
            mi.Caption:= rsMnuView;
            mi.Hint:= '{!VIEWER} ' + QuoteStr(aFile.FullPath);
            mi.OnClick:=Self.ContextMenuSelect; // handler
            miActions.Add(mi);

            // now add EDITconfigure item
            mi:=TMenuItem.Create(miActions);
            mi.Caption:= rsMnuEdit;
            mi.Hint:= '{!EDITOR} ' + QuoteStr(aFile.FullPath);
            mi.OnClick:=Self.ContextMenuSelect; // handler
            miActions.Add(mi);
          end;
      finally
        FreeAndNil(sl);
      end;

      // Founded any commands
      if AddActionsMenu then
        Self.Items.Add(miActions)
      else
        miActions.Free;
    end; // Actions submenu

    // Add "Open with" submenu if needed
    AddOpenWithMenu:= FillOpenWithSubMenu;

    // Add separator after actions and openwith menu.
    if AddActionsMenu or AddOpenWithMenu then
    begin
      mi:=TMenuItem.Create(Self);
      mi.Caption:='-';
      Self.Items.Add(mi);
    end;

    mi:=TMenuItem.Create(Self);
    mi.Action := frmMain.actRename;
    Self.Items.Add(mi);

    mi:=TMenuItem.Create(Self);
    mi.Action := frmMain.actCopy;
    Self.Items.Add(mi);

    mi:=TMenuItem.Create(Self);
    mi.Action := frmMain.actDelete;
    Self.Items.Add(mi);

    mi:=TMenuItem.Create(Self);
    mi.Action := frmMain.actRenameOnly;
    Self.Items.Add(mi);

    mi:=TMenuItem.Create(Self);
    mi.Caption:='-';
    Self.Items.Add(mi);

    mi:=TMenuItem.Create(Self);
    mi.Action := frmMain.actCutToClipboard;
    Self.Items.Add(mi);

    mi:=TMenuItem.Create(Self);
    mi.Action := frmMain.actCopyToClipboard;
    Self.Items.Add(mi);

    mi:=TMenuItem.Create(Self);
    mi.Action := frmMain.actPasteFromClipboard;
    Self.Items.Add(mi);

    mi:=TMenuItem.Create(Self);
    mi.Caption:='-';
    Self.Items.Add(mi);

    mi:=TMenuItem.Create(Self);
    mi.Action := frmMain.actFileProperties;
    Self.Items.Add(mi);
    end
    else
      begin
        mi:=TMenuItem.Create(Self);
        mi.Action := frmMain.actRefresh;
        Self.Items.Add(mi);

        // Add "Sort by" submenu
        miSortBy := TMenuItem.Create(Self);
        miSortBy.Caption := rsMnuSortBy;
        Self.Items.Add(miSortBy);

        mi:=TMenuItem.Create(miSortBy);
        mi.Action := frmMain.actSortByName;
        miSortBy.Add(mi);

        mi:=TMenuItem.Create(miSortBy);
        mi.Action := frmMain.actSortByExt;
        miSortBy.Add(mi);

        mi:=TMenuItem.Create(miSortBy);
        mi.Action := frmMain.actSortBySize;
        miSortBy.Add(mi);

        mi:=TMenuItem.Create(miSortBy);
        mi.Action := frmMain.actSortByDate;
        miSortBy.Add(mi);

        mi:=TMenuItem.Create(miSortBy);
        mi.Action := frmMain.actSortByAttr;
        miSortBy.Add(mi);

        mi:=TMenuItem.Create(miSortBy);
        mi.Caption := '-';
        miSortBy.Add(mi);

        mi:=TMenuItem.Create(miSortBy);
        mi.Action := frmMain.actReverseOrder;
        miSortBy.Add(mi);

        mi:=TMenuItem.Create(Self);
        mi.Caption:='-';
        Self.Items.Add(mi);

        mi:=TMenuItem.Create(Self);
        mi.Action := frmMain.actPasteFromClipboard;
        Self.Items.Add(mi);

        if GetTemplateMenu(sl) then
        begin
          mi:=TMenuItem.Create(Self);
          mi.Caption:='-';
          Self.Items.Add(mi);

          // Add "New" submenu
          miSortBy := TMenuItem.Create(Self);
          miSortBy.Caption := rsMnuNew;
          Self.Items.Add(miSortBy);

          for I:= 0 to sl.Count - 1 do
          begin
            mi:=TMenuItem.Create(miSortBy);
            mi.Caption:= sl.Names[I];
            mi.Hint:= sl.ValueFromIndex[I];
            mi.OnClick:= Self.TemplateContextMenuSelect;
            miSortBy.Add(mi);
          end;
          FreeThenNil(sl);
        end;

        mi:=TMenuItem.Create(Self);
        mi.Caption:='-';
        Self.Items.Add(mi);

        mi:=TMenuItem.Create(Self);
        mi.Caption:= frmMain.actFileProperties.Caption;
        mi.Hint:= sCmdVerbProperties;
        mi.OnClick:= Self.ContextMenuSelect;
        Self.Items.Add(mi);
      end;
  finally
    Files:= nil;
  end;
end;

destructor TShellContextMenu.Destroy;
begin
  FreeThenNil(FFiles);
  inherited Destroy;
end;

end.

