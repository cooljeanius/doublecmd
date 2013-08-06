{
    Double Commander
    -------------------------------------------------------------------------
    Shell context menu implementation.

    Copyright (C) 2006-2012  Koblov Alexander (Alexx2000@mail.ru)

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
{$IF (FPC_VERSION > 2) or ((FPC_VERSION = 2) and (FPC_RELEASE >= 5))}
{$POINTERMATH ON}
{$ENDIF}

interface

uses
  Classes, SysUtils, Controls, uFile, Windows, ComObj, ShlObj, ActiveX,
  JwaShlGuid, uShlObjAdditional;

const
  sCmdVerbOpen = 'open';
  sCmdVerbRename = 'rename';
  sCmdVerbDelete = 'delete';
  sCmdVerbCut = 'cut';
  sCmdVerbCopy = 'copy';
  sCmdVerbPaste = 'paste';
  sCmdVerbLink = 'link';
  sCmdVerbProperties = 'properties';
  sCmdVerbNewFolder = 'NewFolder';

type

  { EContextMenuException }

  EContextMenuException = class(Exception);

  { TShellContextMenu }

  TShellContextMenu = class
  private
    FOnClose: TNotifyEvent;
    FParent: TWinControl;
    FFiles: TFiles;
    FBackground: Boolean;
    FShellMenu1: IContextMenu;
    FShellMenu: HMENU;
  public
    constructor Create(Parent: TWinControl; var Files : TFiles; Background: Boolean); reintroduce;
    destructor Destroy; override;
    procedure PopUp(X, Y: Integer);
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
  end;

function GetShellContextMenu(Handle: HWND; Files: TFiles; Background: Boolean): IContextMenu;

implementation

uses
  LCLProc, Dialogs, uGlobs, uLng, uMyWindows, uShellExecute,
  fMain, uDCUtils, uFormCommands, DCOSUtils, uOSUtils, uShowMsg;

const
  USER_CMD_ID = $1000;

var
  OldWProc: WNDPROC = nil;
  ShellMenu2: IContextMenu2 = nil;
  ShellMenu3: IContextMenu3 = nil;

function MyWndProc(hWnd: HWND; uiMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  case uiMsg of
    (* For working with submenu of context menu *)
    WM_INITMENUPOPUP,
    WM_DRAWITEM,
    WM_MENUCHAR,
    WM_MEASUREITEM:
      if Assigned(ShellMenu3) then
        ShellMenu3.HandleMenuMsg2(uiMsg, wParam, lParam, @Result)
      else if Assigned(ShellMenu2) then
          begin
            ShellMenu2.HandleMenuMsg(uiMsg, wParam, lParam);
            Result := 0;
          end
      else
        Result := CallWindowProc(OldWProc, hWnd, uiMsg, wParam, lParam);
  else
    Result := CallWindowProc(OldWProc, hWnd, uiMsg, wParam, lParam);
  end; // case
end;

function GetForegroundContextMenu(Handle : HWND; Files : TFiles): IContextMenu;
type
  PPIDLArray = ^PItemIDList;

var
  Folder,
  DesktopFolder: IShellFolder;
  PathPIDL: PItemIDList = nil;
  tmpPIDL: PItemIDList = nil;
  S: WideString;
  List: PPIDLArray = nil;
  I : Integer;
  pchEaten: ULONG;
  dwAttributes: ULONG = 0;
begin
  Result := nil;

  OleCheckUTF8(SHGetDesktopFolder(DesktopFolder));
  try
    List := CoTaskMemAlloc(SizeOf(PItemIDList)*Files.Count);
    ZeroMemory(List, SizeOf(PItemIDList)*Files.Count);

    for I := 0 to Files.Count - 1 do
      begin
        if Files[I].Name = EmptyStr then
          S := EmptyStr
        else
          S := UTF8Decode(Files[I].Path);

        OleCheckUTF8(DeskTopFolder.ParseDisplayName(Handle, nil, PWideChar(S), pchEaten, PathPIDL, dwAttributes));
        try
          OleCheckUTF8(DeskTopFolder.BindToObject(PathPIDL, nil, IID_IShellFolder, Folder));
        finally
          CoTaskMemFree(PathPIDL);
        end;

        if Files[I].Name = EmptyStr then
          S := UTF8Decode(Files[I].Path)
        else
          S := UTF8Decode(Files[I].Name);

        OleCheckUTF8(Folder.ParseDisplayName(Handle, nil, PWideChar(S), pchEaten, tmpPIDL, dwAttributes));
        (List + i)^ := tmpPIDL;
      end;

    Folder.GetUIObjectOf(Handle, Files.Count, PItemIDList(List^), IID_IContextMenu, nil, Result);

  finally
    if Assigned(List) then
    begin
      for I := 0 to Files.Count - 1 do
        if Assigned((List + i)^) then
          CoTaskMemFree((List + i)^);
      CoTaskMemFree(List);
    end;

    Folder:= nil;
    DesktopFolder:= nil;
  end;
end;

function GetBackgroundContextMenu(Handle : HWND; Files : TFiles): IContextMenu;
var
  DesktopFolder, Folder: IShellFolder;
  wsFileName: WideString;
  PathPIDL: PItemIDList = nil;
  pchEaten: ULONG;
  dwAttributes: ULONG = 0;
begin
  Result:= nil;

  if Files.Count > 0 then
  begin
    wsFileName:= UTF8Decode(Files[0].FullPath);
    OleCheckUTF8(SHGetDesktopFolder(DesktopFolder));
    try
      OleCheckUTF8(DesktopFolder.ParseDisplayName(Handle, nil, PWideChar(wsFileName), pchEaten, PathPIDL, dwAttributes));
      try
        OleCheckUTF8(DesktopFolder.BindToObject(PathPIDL, nil, IID_IShellFolder, Folder));
      finally
        CoTaskMemFree(PathPIDL);
      end;
      OleCheckUTF8(Folder.CreateViewObject(Handle, IID_IContextMenu, Result));
    finally
      Folder:= nil;
      DesktopFolder:= nil;
    end;
  end;
end;

function GetShellContextMenu(Handle: HWND; Files: TFiles; Background: Boolean): IContextMenu; inline;
begin
  if Background then
    Result:= GetBackgroundContextMenu(Handle, Files)
  else
    Result:= GetForegroundContextMenu(Handle, Files);
end;

type

  { TShellThread }

  TShellThread = class(TThread)
  private
    FParent: HWND;
    FVerb: AnsiString;
    FShellMenu: IContextMenu;
  protected
    procedure Execute; override;
  public
    constructor Create(Parent: HWND; ShellMenu: IContextMenu; Verb: AnsiString); reintroduce;
    destructor Destroy; override;
  end;

{ TShellThread }

procedure TShellThread.Execute;
var
  Result: HRESULT;
  cmici: TCMINVOKECOMMANDINFO;
begin
  CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
  try
    FillByte(cmici, SizeOf(cmici), 0);
    with cmici do
    begin
      cbSize := SizeOf(cmici);
      hwnd := FParent;
      lpVerb := PAnsiChar(FVerb);
      nShow := SW_NORMAL;
    end;
    Result:= FShellMenu.InvokeCommand(cmici);
    if not (Succeeded(Result) or (Result = COPYENGINE_E_USER_CANCELLED)) then
      msgError(Self, mbSysErrorMessage(Result));
  finally
    CoUninitialize;
  end;
end;

constructor TShellThread.Create(Parent: HWND; ShellMenu: IContextMenu; Verb: AnsiString);
begin
  inherited Create(True);
  FVerb:= Verb;
  FParent:= Parent;
  FShellMenu:= ShellMenu;
  FreeOnTerminate:= True;
end;

destructor TShellThread.Destroy;
begin
  FShellMenu:= nil;
  inherited Destroy;
end;

{ TShellContextMenu }

constructor TShellContextMenu.Create(Parent: TWinControl; var Files : TFiles; Background: Boolean);
var
  UFlags: UINT = CMF_EXPLORE or CMF_CANRENAME;
begin
  // Replace window procedure
  {$PUSH}{$HINTS OFF}
  OldWProc := WNDPROC(SetWindowLongPtr(Parent.Handle, GWL_WNDPROC, LONG_PTR(@MyWndProc)));
  {$POP}
  FParent:= Parent;
  FFiles:= Files;
  FBackground:= Background;
  FShellMenu:= 0;
  // Add extended verbs if shift key is down
  if (ssShift in GetKeyShiftState) then
    UFlags:= UFlags or CMF_EXTENDEDVERBS;
  try
    try
      FShellMenu1 := GetShellContextMenu(Parent.Handle, Files, Background);
      if Assigned(FShellMenu1) then
      begin
        FShellMenu := CreatePopupMenu;
        OleCheckUTF8(FShellMenu1.QueryContextMenu(FShellMenu, 0, 1, USER_CMD_ID - 1, UFlags));
        FShellMenu1.QueryInterface(IID_IContextMenu2, ShellMenu2); // to handle submenus.
        FShellMenu1.QueryInterface(IID_IContextMenu3, ShellMenu3); // to handle submenus.
      end;
    except
      on e: EOleError do
        raise EContextMenuException.Create(e.Message);
    end;
  finally
    Files:= nil;
  end;
end;

destructor TShellContextMenu.Destroy;
begin
  // Restore window procedure
  {$PUSH}{$HINTS OFF}
  SetWindowLongPtr(FParent.Handle, GWL_WNDPROC, LONG_PTR(@OldWProc));
  {$POP}
  // Free global variables
  ShellMenu2:= nil;
  ShellMenu3:= nil;
  // Free internal objects
  FShellMenu1:= nil;
  FreeThenNil(FFiles);
  if FShellMenu <> 0 then
    DestroyMenu(FShellMenu);
  inherited Destroy;
end;

procedure TShellContextMenu.PopUp(X, Y: Integer);
var
  aFile: TFile = nil;
  sl: TStringList = nil;
  i:Integer;
  sAct, sCmd: UTF8String;
  hActionsSubMenu: HMENU = 0;
  cmd: UINT = 0;
  iCmd: Integer;
  cmici: TCMINVOKECOMMANDINFO;
  bHandled : Boolean = False;
  ZVerb: array[0..255] of char;
  sVerb : String;
  Result: HRESULT;
  FormCommands: IFormCommands;
begin
  try
    try
      if Assigned(FShellMenu1) then
      try
        FormCommands := frmMain as IFormCommands;

        aFile := FFiles[0];
        if FBackground then // Add "Background" context menu specific items
          begin
            sl:= TStringList.Create;

            // Add commands to root of context menu
            sCmd:= 'cm_Refresh';
            I:= sl.Add(sCmd);
            sAct:= FormCommands.GetCommandCaption(sCmd);
            InsertMenuItemEx(FShellMenu, 0, PWideChar(UTF8Decode(sAct)), 0, I + USER_CMD_ID, MFT_STRING);

            // Add "Sort by" submenu
            hActionsSubMenu := CreatePopupMenu;
            sCmd:= 'cm_ReverseOrder';
            I:= sl.Add(sCmd);
            sAct:= FormCommands.GetCommandCaption(sCmd);
            InsertMenuItemEx(hActionsSubMenu,0, PWideChar(UTF8Decode(sAct)), 0, I + USER_CMD_ID, MFT_STRING);
            // Add separator
            InsertMenuItemEx(hActionsSubMenu, 0, nil, 0, 0, MFT_SEPARATOR);
            sCmd:= 'cm_SortByAttr';
            I:= sl.Add(sCmd);
            sAct:= FormCommands.GetCommandCaption(sCmd);
            InsertMenuItemEx(hActionsSubMenu,0, PWideChar(UTF8Decode(sAct)), 0, I + USER_CMD_ID, MFT_STRING);
            sCmd:= 'cm_SortByDate';
            I:= sl.Add(sCmd);
            sAct:= FormCommands.GetCommandCaption(sCmd);
            InsertMenuItemEx(hActionsSubMenu,0, PWideChar(UTF8Decode(sAct)), 0, I + USER_CMD_ID, MFT_STRING);
            sCmd:= 'cm_SortBySize';
            I:= sl.Add(sCmd);
            sAct:= FormCommands.GetCommandCaption(sCmd);
            InsertMenuItemEx(hActionsSubMenu,0, PWideChar(UTF8Decode(sAct)), 0, I + USER_CMD_ID, MFT_STRING);
            sCmd:= 'cm_SortByExt';
            I:= sl.Add(sCmd);
            sAct:= FormCommands.GetCommandCaption(sCmd);
            InsertMenuItemEx(hActionsSubMenu,0, PWideChar(UTF8Decode(sAct)), 0, I + USER_CMD_ID, MFT_STRING);
            sCmd:= 'cm_SortByName';
            I:= sl.Add(sCmd);
            sAct:= FormCommands.GetCommandCaption(sCmd);
            InsertMenuItemEx(hActionsSubMenu,0, PWideChar(UTF8Decode(sAct)), 0, I + USER_CMD_ID, MFT_STRING);
            // Add submenu to context menu
            InsertMenuItemEx(FShellMenu, hActionsSubMenu, PWideChar(UTF8Decode(rsMnuSortBy)), 1, 333, MFT_STRING);

            // Add menu separator
            InsertMenuItemEx(FShellMenu, 0, nil, 2, 0, MFT_SEPARATOR);
            // Add commands to root of context menu
            sCmd:= 'cm_PasteFromClipboard';
            I:= sl.Add(sCmd);
            sAct:= FormCommands.GetCommandCaption(sCmd);
            InsertMenuItemEx(FShellMenu, 0, PWideChar(UTF8Decode(sAct)), 3, I + USER_CMD_ID, MFT_STRING);
            // Add menu separator
            InsertMenuItemEx(FShellMenu, 0, nil, 4, 0, MFT_SEPARATOR);
          end
        else  // Add "Actions" submenu
          begin
            hActionsSubMenu := CreatePopupMenu;

            // Read actions from doublecmd.ext
            sl:=TStringList.Create;

            if gExts.GetExtActions(aFile, sl) then
              begin
                for I:= 0 to sl.Count - 1 do
                  begin
                    sAct:= sl.Names[I];
                    if (CompareText('OPEN', sAct) = 0) or (CompareText('VIEW', sAct) = 0) or (CompareText('EDIT', sAct) = 0) then Continue;
                    InsertMenuItemEx(hActionsSubMenu,0, PWChar(UTF8Decode(sAct)), 0, I + USER_CMD_ID, MFT_STRING);
                  end;
              end;

            if (FFiles.Count = 1) and not (aFile.IsDirectory or aFile.IsLinkToDirectory) then
              begin
                // Add separator if needed.
                if GetMenuItemCount(hActionsSubMenu) > 0 then
                  InsertMenuItemEx(hActionsSubMenu,0, nil, 0, 0, MFT_SEPARATOR);

                // now add VIEW item
                sCmd:= '{!VIEWER} ' + QuoteStr(aFile.FullPath);
                I := sl.Add(sCmd);
                InsertMenuItemEx(hActionsSubMenu,0, PWChar(UTF8Decode(rsMnuView)), 1, I + USER_CMD_ID, MFT_STRING);

                // now add EDIT item
                sCmd:= '{!EDITOR} ' + QuoteStr(aFile.FullPath);
                I := sl.Add(sCmd);
                InsertMenuItemEx(hActionsSubMenu,0, PWChar(UTF8Decode(rsMnuEdit)), 1, I + USER_CMD_ID, MFT_STRING);
              end;

            // Add Actions submenu if not empty.
            if GetMenuItemCount(hActionsSubMenu) > 0 then
            begin
              // Insert Actions submenu before first separator
              iCmd:= GetMenuItemCount(FShellMenu) - 1;
              for I:= 0 to iCmd do
              begin
                if GetMenuItemType(FShellMenu, I, True) = MFT_SEPARATOR then
                  Break;
              end;
              InsertMenuItemEx(FShellMenu, hActionsSubMenu, PWideChar(UTF8Decode(rsMnuActions)), I, 333, MFT_STRING);
            end;
          end;
        { /Actions submenu }
        //------------------------------------------------------------------------------
        cmd := UINT(TrackPopupMenu(FShellMenu, TPM_LEFTALIGN or TPM_LEFTBUTTON or TPM_RIGHTBUTTON or TPM_RETURNCMD, X, Y, 0, FParent.Handle, nil));
      finally
        if hActionsSubMenu <> 0 then
          DestroyMenu(hActionsSubMenu);
      end;

      if (cmd > 0) and (cmd < USER_CMD_ID) then
        begin
          iCmd := LongInt(Cmd) - 1;
          if Succeeded(FShellMenu1.GetCommandString(iCmd, GCS_VERBA, nil, ZVerb, SizeOf(ZVerb))) then
            begin
              sVerb := StrPas(ZVerb);

              if SameText(sVerb, sCmdVerbRename) then
                begin
                  if FFiles.Count = 1 then
                    with FFiles[0] do
                    begin
                      if not SameText(FullPath, ExtractFileDrive(FullPath) + PathDelim) then
                        frmMain.actRenameOnly.Execute
                      else  // change drive label
                        begin
                          sCmd:= mbGetVolumeLabel(FullPath, True);
                          if InputQuery(rsMsgSetVolumeLabel, rsMsgVolumeLabel, sCmd) then
                            mbSetVolumeLabel(FullPath, sCmd);
                        end;
                    end
                  else
                    frmMain.actRename.Execute;
                  bHandled := True;
                end
              else if SameText(sVerb, sCmdVerbCut) then
                begin
                  frmMain.actCutToClipboard.Execute;
                  bHandled := True;
                end
              else if SameText(sVerb, sCmdVerbCopy) then
                begin
                  frmMain.actCopyToClipboard.Execute;
                  bHandled := True;
                end
              else if SameText(sVerb, sCmdVerbNewFolder) then
                begin
                  frmMain.actMakeDir.Execute;
                  bHandled := True;
                end
              else if SameText(sVerb, sCmdVerbPaste) or SameText(sVerb, sCmdVerbDelete) then
                begin
                  TShellThread.Create(FParent.Handle, FShellMenu1, sVerb).Start;
                  bHandled := True;
                end;
            end;

          if not bHandled then
            begin
              FillChar(cmici, SizeOf(cmici), #0);
              with cmici do
              begin
                cbSize := SizeOf(cmici);
                hwnd := FParent.Handle;
                {$PUSH}{$HINTS OFF}
                lpVerb := PAnsiChar(PtrUInt(cmd - 1));
                {$POP}
                nShow := SW_NORMAL;
              end;

              Result:= FShellMenu1.InvokeCommand(cmici);
              if not (Succeeded(Result) or (Result = COPYENGINE_E_USER_CANCELLED)) then
                OleErrorUTF8(Result);

              // Reload after possible changes on the filesystem.
              if SameText(sVerb, sCmdVerbLink) or SameText(sVerb, sCmdVerbDelete) then
                frmMain.ActiveFrame.FileSource.Reload(frmMain.ActiveFrame.CurrentPath);
            end;

        end // if cmd > 0
      else if (cmd >= USER_CMD_ID) then // actions sub menu
        begin
          sCmd:= sl.Strings[cmd - USER_CMD_ID];
          if FBackground then
            begin
              if SameText(sCmd, 'cm_PasteFromClipboard') then
                TShellThread.Create(FParent.Handle, FShellMenu1, sCmdVerbPaste).Start
              else
                FormCommands.ExecuteCommand(sCmd, []);
              bHandled:= True;
            end
          else
            begin
              sCmd:= Copy(sCmd, Pos('=', sCmd) + 1, Length(sCmd));
              sCmd:= PrepareParameter(sCmd, frmMain.FrameLeft, frmMain.FrameRight, frmMain.ActiveFrame);
              try
                with frmMain.ActiveFrame do
                begin
                  (*
                  VFS via another file source

                  if (Pos('{!VFS}',sCmd)>0) and pnlFile.VFS.FindModule(CurrentPath + fri.sName) then
                  begin
                       pnlFile.LoadPanelVFS(@fri);
                       Exit;
                  end;
                  *)
                  try
                    if not ProcessExtCommand(sCmd, CurrentPath) then
                      frmMain.ExecCmd(sCmd);
                  except
                    on e: EInvalidCommandLine do
                      MessageDlg(rsMsgErrorInContextMenuCommand, rsMsgInvalidCommandLine + ': ' + e.Message, mtError, [mbOK], 0);
                  end;
                end;
              finally
                bHandled:= True;
              end;
            end;
        end;
    finally
      if Assigned(sl) then
        FreeAndNil(sl);
    end;

  except
    on e: EOleError do
      raise EContextMenuException.Create(e.Message);
  end;

  if Assigned(FOnClose) then
    FOnClose(Self);
end;

end.

