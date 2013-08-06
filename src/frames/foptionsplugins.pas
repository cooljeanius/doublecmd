{
   Double Commander
   -------------------------------------------------------------------------
   Plugins options page

   Copyright (C) 2006-2013 Alexander Koblov (alexx2000@mail.ru)

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

unit fOptionsPlugins;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ComCtrls, StdCtrls, Grids, Buttons,
  fOptionsFrame, uDSXModule, uWCXModule, uWDXModule, uWFXmodule, uWLXModule, Controls;

type

  { TfrmOptionsPlugins }

  TfrmOptionsPlugins = class(TOptionsEditor)
    btnAddPlugin: TBitBtn;
    btnConfigPlugin: TBitBtn;
    btnEnablePlugin: TBitBtn;
    btnRemovePlugin: TBitBtn;
    btnTweakPlugin: TBitBtn;
    lblDSXDescription: TLabel;
    lblWCXDescription: TLabel;
    lblWDXDescription: TLabel;
    lblWFXDescription: TLabel;
    lblWLXDescription: TLabel;
    pcPluginsTypes: TPageControl;
    stgPlugins: TStringGrid;
    tsDSX: TTabSheet;
    tsWCX: TTabSheet;
    tsWDX: TTabSheet;
    tsWFX: TTabSheet;
    tsWLX: TTabSheet;
    procedure btnConfigPluginClick(Sender: TObject);
    procedure btnEnablePluginClick(Sender: TObject);
    procedure btnRemovePluginClick(Sender: TObject);
    procedure btnTweakPluginClick(Sender: TObject);
    procedure pcPluginsTypesChange(Sender: TObject);
    procedure stgPluginsBeforeSelection(Sender: TObject; aCol, aRow: Integer);
    procedure btnDSXAddClick(Sender: TObject);
    procedure btnWDXAddClick(Sender: TObject);
    procedure btnWFXAddClick(Sender: TObject);
    procedure btnWLXAddClick(Sender: TObject);
    procedure btnWCXAddClick(Sender: TObject);
    procedure stgPluginsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure stgPluginsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure stgPluginsSelection(Sender: TObject; aCol, aRow: Integer);
    procedure tsDSXShow(Sender: TObject);
    procedure tsWCXShow(Sender: TObject);
    procedure tsWDXShow(Sender: TObject);
    procedure tsWFXShow(Sender: TObject);
    procedure tsWLXShow(Sender: TObject);
  private
    FMoveRow: Boolean;
    FSourceRow: Integer;
  protected
    procedure Init; override;
    procedure Done; override;
    procedure Load; override;
    function Save: TOptionsEditorSaveFlags; override;
  public
    class function GetIconIndex: Integer; override;
    class function GetTitle: String; override;
  end;

var
  tmpDSXPlugins: TDSXModuleList;
  tmpWCXPlugins: TWCXModuleList;
  tmpWDXPlugins: TWDXModuleList;
  tmpWFXPlugins: TWFXModuleList;
  tmpWLXPlugins: TWLXModuleList;

implementation

{$R *.lfm}

uses
  LCLProc, Forms, Dialogs, StrUtils, uLng, uGlobs, uDCUtils, uDebug, uShowMsg,
  uTypes, fTweakPlugin, dmCommonData, DCStrUtils, uDefaultPlugins;

{ TfrmOptionsPlugins }

procedure TfrmOptionsPlugins.pcPluginsTypesChange(Sender: TObject);
begin
  if stgPlugins.RowCount > stgPlugins.FixedRows then
    stgPluginsBeforeSelection(stgPlugins, 0, stgPlugins.FixedRows);
end;

procedure TfrmOptionsPlugins.btnEnablePluginClick(Sender: TObject);
var
  sExt,
  sExts: String;
  iPluginIndex: Integer;
  bEnabled: Boolean;
begin
  if stgPlugins.Row < stgPlugins.FixedRows then Exit;
  if pcPluginsTypes.ActivePage.Name = 'tsWCX' then
    begin
      sExts:= stgPlugins.Cells[2, stgPlugins.Row];
      sExt:= Copy2SpaceDel(sExts);
      repeat
        iPluginIndex:= tmpWCXPlugins.Find(stgPlugins.Cells[3, stgPlugins.Row], sExt);
        if iPluginIndex <> -1 then
        begin
          bEnabled:= not tmpWCXPlugins.Enabled[iPluginIndex];
          tmpWCXPlugins.Enabled[iPluginIndex]:= bEnabled;
        end;
        sExt:= Copy2SpaceDel(sExts);
      until sExt = '';
      stgPlugins.Cells[0, stgPlugins.Row]:= IfThen(bEnabled, string('+'), string('-'));
      btnEnablePlugin.Caption:= IfThen(bEnabled, rsOptDisable, rsOptEnable);
    end
  else if pcPluginsTypes.ActivePage.Name = 'tsWFX' then
    begin
      bEnabled:= not tmpWFXPlugins.Enabled[stgPlugins.Row - stgPlugins.FixedRows];
      stgPlugins.Cells[0, stgPlugins.Row]:= IfThen(bEnabled, string('+'), string('-'));
      tmpWFXPlugins.Enabled[stgPlugins.Row - stgPlugins.FixedRows]:= bEnabled;
      btnEnablePlugin.Caption:= IfThen(bEnabled, rsOptDisable, rsOptEnable);
    end
  else if pcPluginsTypes.ActivePage.Name = 'tsWLX' then
    begin
      with tmpWLXPlugins.GetWlxModule(stgPlugins.Row - stgPlugins.FixedRows) do
      begin
        Enabled:= not Enabled;
        stgPlugins.Cells[0, stgPlugins.Row]:= IfThen(Enabled, string('+'), string('-'));
        btnEnablePlugin.Caption:= IfThen(Enabled, rsOptDisable, rsOptEnable);
      end;
    end;
end;

procedure TfrmOptionsPlugins.btnConfigPluginClick(Sender: TObject);
var
  WCXmodule: TWCXmodule;
  WFXmodule: TWFXmodule;
  PluginFileName: String;
begin
  if stgPlugins.Row < stgPlugins.FixedRows then Exit; // no plugins

  PluginFileName := GetCmdDirFromEnvVar(stgPlugins.Cells[3, stgPlugins.Row]);

  if pcPluginsTypes.ActivePage.Name = 'tsWCX' then
    begin
      WCXmodule := TWCXmodule.Create;
      DCDebug('TWCXmodule created');
      try
        if WCXmodule.LoadModule(PluginFileName) then
         begin
           DCDebug('WCXModule Loaded');
           WCXmodule.VFSConfigure(stgPlugins.Handle);
           DCDebug('Dialog executed');
           WCXModule.UnloadModule;
           DCDebug('WCX Module Unloaded');
         end
         else
           msgError(rsMsgErrEOpen + ': ' + PluginFileName);
      finally
        WCXmodule.Free;
        DCDebug('WCX Freed');
      end;
    end
  else if pcPluginsTypes.ActivePage.Name = 'tsWFX' then
    begin
      WFXmodule := TWFXmodule.Create;
      DCDebug('TWFXmodule created');
      try
        if WFXmodule.LoadModule(PluginFileName) then
         begin
           DCDebug('WFXModule Loaded');
           WfxModule.VFSInit(0);
           WFXmodule.VFSConfigure(stgPlugins.Handle);
           DCDebug('Dialog executed');
           WFXModule.UnloadModule;
           DCDebug('WFX Module Unloaded');
         end
         else
           msgError(rsMsgErrEOpen + ': ' + PluginFileName);
      finally
        WFXmodule.Free;
        DCDebug('WFX Freed');
      end;
    end;
end;

procedure TfrmOptionsPlugins.btnRemovePluginClick(Sender: TObject);
var
  sExt,
  sExts: String;
  iPluginIndex: Integer;
begin
  if stgPlugins.Row < stgPlugins.FixedRows then Exit; // no plugins

  if pcPluginsTypes.ActivePage.Name = 'tsDSX' then
    begin
      tmpDSXPlugins.DeleteItem(stgPlugins.Row - stgPlugins.FixedRows);
      stgPlugins.DeleteColRow(False, stgPlugins.Row);
    end
  else if pcPluginsTypes.ActivePage.Name = 'tsWCX' then
    begin
      sExts:= stgPlugins.Cells[2, stgPlugins.Row];
      sExt:= Copy2SpaceDel(sExts);
      repeat
        iPluginIndex:= tmpWCXPlugins.Find(stgPlugins.Cells[3, stgPlugins.Row], sExt);
        if iPluginIndex <> -1 then
          tmpWCXPlugins.Delete(iPluginIndex);
        sExt:= Copy2SpaceDel(sExts);
      until sExt = '';
      stgPlugins.DeleteColRow(False, stgPlugins.Row);
    end
  else if pcPluginsTypes.ActivePage.Name = 'tsWDX' then
    begin
      tmpWDXPlugins.DeleteItem(stgPlugins.Row - stgPlugins.FixedRows);
      stgPlugins.DeleteColRow(False, stgPlugins.Row);
    end
  else if pcPluginsTypes.ActivePage.Name = 'tsWFX' then
    begin
      tmpWFXPlugins.Delete(stgPlugins.Row - stgPlugins.FixedRows);
      stgPlugins.DeleteColRow(False, stgPlugins.Row);
    end
  else if pcPluginsTypes.ActivePage.Name = 'tsWLX' then
    begin
      tmpWLXPlugins.DeleteItem(stgPlugins.Row - stgPlugins.FixedRows);
      stgPlugins.DeleteColRow(False, stgPlugins.Row);
    end
end;

procedure TfrmOptionsPlugins.btnTweakPluginClick(Sender: TObject);
var
  ptPluginType: TPluginType;
  iPluginIndex: Integer;
begin
  iPluginIndex:= stgPlugins.Row - stgPlugins.FixedRows;
  if pcPluginsTypes.ActivePage.Name = 'tsDSX' then
    ptPluginType:= ptDSX
  else if pcPluginsTypes.ActivePage.Name = 'tsWCX' then
    begin
      ptPluginType:= ptWCX;
      // get plugin index
      iPluginIndex:= tmpWCXPlugins.Find(stgPlugins.Cells[3, stgPlugins.Row],
                                        Copy2Space(stgPlugins.Cells[2, stgPlugins.Row]));
    end
  else if pcPluginsTypes.ActivePage.Name = 'tsWDX' then
    ptPluginType:= ptWDX
  else if pcPluginsTypes.ActivePage.Name = 'tsWFX' then
    ptPluginType:= ptWFX
  else if pcPluginsTypes.ActivePage.Name = 'tsWLX' then
    ptPluginType:= ptWLX;

  if iPluginIndex < 0 then Exit;
  if ShowTweakPluginDlg(ptPluginType, iPluginIndex) then
    pcPluginsTypes.ActivePage.OnShow(pcPluginsTypes.ActivePage); // update info in plugin list
end;

procedure TfrmOptionsPlugins.stgPluginsBeforeSelection(Sender: TObject; aCol,
  aRow: Integer);
begin
  if stgPlugins.Cells[0, aRow] = '+' then
    btnEnablePlugin.Caption:= rsOptDisable
  else if stgPlugins.Cells[0, aRow] = '-' then
    btnEnablePlugin.Caption:= rsOptEnable;

  btnEnablePlugin.Enabled:= (stgPlugins.Cells[0, aRow] <> '');
end;

{ DSX plugins }

procedure TfrmOptionsPlugins.btnDSXAddClick(Sender: TObject);
var
  I, J: Integer;
  sFileName,
  sPluginName : String;
begin
  dmComData.OpenDialog.Filter := 'Search plugins (*.dsx)|*.dsx';
  if dmComData.OpenDialog.Execute then
  begin
    sFileName := dmComData.OpenDialog.FileName;
    if not CheckPlugin(sFileName) then Exit;

    sPluginName := ExtractOnlyFileName(sFileName);
    I:= tmpDSXPlugins.Add(sPluginName, sFileName, EmptyStr);

    if not tmpDSXPlugins.LoadModule(sPluginName) then
    begin
      MessageDlg(Application.Title, rsMsgInvalidPlugin, mtError, [mbOK], 0, mbOK);
      tmpDSXPlugins.DeleteItem(I);
      Exit;
    end;

    stgPlugins.RowCount:= stgPlugins.RowCount + 1;
    J:= stgPlugins.RowCount - stgPlugins.FixedRows;
    stgPlugins.Cells[1, J]:= tmpDSXPlugins.GetDsxModule(I).Name;
    stgPlugins.Cells[2, J]:= tmpDSXPlugins.GetDsxModule(I).Descr;
    stgPlugins.Cells[3, J]:= SetCmdDirAsEnvVar(tmpDSXPlugins.GetDsxModule(I).FileName);
  end;
end;

procedure TfrmOptionsPlugins.tsDSXShow(Sender: TObject);
var i:integer;
begin
  btnAddPlugin.OnClick:= @btnDSXAddClick;
  stgPlugins.RowCount:= tmpDSXPlugins.Count + stgPlugins.FixedRows;
  for i:=0 to tmpDSXPlugins.Count-1 do
    begin
    stgPlugins.Cells[1, I + stgPlugins.FixedRows]:= tmpDSXPlugins.GetDsxModule(i).Name;
    stgPlugins.Cells[2, I + stgPlugins.FixedRows]:= tmpDSXPlugins.GetDsxModule(i).Descr;
    stgPlugins.Cells[3, I + stgPlugins.FixedRows]:= SetCmdDirAsEnvVar(tmpDSXPlugins.GetDsxModule(i).FileName);
    end;
end;

{ WCX plugins }

procedure TfrmOptionsPlugins.btnWCXAddClick(Sender: TObject);
var
  J, iPluginIndex, iFlags: Integer;
  sExt : String;
  sExts : String;
  sExtsTemp : String;
  sFileName : String;
  sPluginName : String;
  sAlreadyAssignedExts : String;
  WCXmodule : TWCXmodule;
begin
  dmComData.OpenDialog.Filter := Format('Archive plugins (%s)|%s', [WcxMask, WcxMask]);
  if dmComData.OpenDialog.Execute then
  begin
    sFileName := dmComData.OpenDialog.FileName;
    if not CheckPlugin(sFileName) then Exit;

    WCXmodule := TWCXmodule.Create;
    try
      if not WCXmodule.LoadModule(sFileName) then
      begin
        MessageDlg(Application.Title, rsMsgInvalidPlugin, mtError, [mbOK], 0, mbOK);
        Exit;
      end;

      iFlags := WCXmodule.GetPluginCapabilities;
      WCXModule.UnloadModule;

      sPluginName := SetCmdDirAsEnvVar(sFileName);
      if InputQuery(rsOptEnterExt, Format(rsOptAssocPluginWith, [sFileName]), sExts) then
      begin
        sExtsTemp := sExts;
        sExts := '';
        sAlreadyAssignedExts := '';
        sExt:= Copy2SpaceDel(sExtsTemp);
        repeat
          iPluginIndex:= tmpWCXPlugins.Find(sPluginName, sExt);
          if iPluginIndex <> -1 then
            begin
              AddStrWithSep(sAlreadyAssignedExts, sExt);
            end
          else
            begin
              tmpWCXPlugins.AddObject(sExt + '=' + IntToStr(iFlags) + ',' + sPluginName, TObject(True));
              AddStrWithSep(sExts, sExt);
            end;
          sExt:= Copy2SpaceDel(sExtsTemp);
        until sExt = '';

        if sAlreadyAssignedExts <> '' then
          MessageDlg(Format(rsOptPluginAlreadyAssigned, [sFileName]) +
                     LineEnding + sAlreadyAssignedExts, mtWarning, [mbOK], 0);

        if sExts <> '' then
        begin
          stgPlugins.RowCount:= stgPlugins.RowCount + 1; // Add new row
          J:= stgPlugins.RowCount - 1;
          stgPlugins.Cells[0, J]:= '+'; // Enabled
          stgPlugins.Cells[1, J]:= ExtractOnlyFileName(sFileName);
          stgPlugins.Cells[2, J]:= sExts;
          stgPlugins.Cells[3, J]:= sPluginName;
        end;
      end;
    finally
      WCXmodule.Free;
    end;
  end;
end;

procedure TfrmOptionsPlugins.stgPluginsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  SourceCol: Integer;
begin
  if (Button = mbLeft) then
  begin
    stgPlugins.MouseToCell(X, Y, SourceCol, FSourceRow);
    if (FSourceRow > 0) then
    begin
      FMoveRow := True;
    end;
  end;
end;

procedure TfrmOptionsPlugins.stgPluginsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) then
  begin
    FMoveRow := False;
  end;
end;

procedure TfrmOptionsPlugins.stgPluginsSelection(Sender: TObject; aCol, aRow: Integer);
begin
  if FMoveRow and (aRow <> FSourceRow) then
  with stgPlugins do
  begin
    if pcPluginsTypes.ActivePage.Name = 'tsDSX' then
      begin
        tmpDSXPlugins.Exchange(FSourceRow - FixedRows, aRow - FixedRows);
        FSourceRow := aRow;
        tsDSXShow(stgPlugins);
      end
    else if pcPluginsTypes.ActivePage.Name = 'tsWCX' then
      begin
        tmpWCXPlugins.Exchange(FSourceRow - FixedRows, aRow - FixedRows);
        FSourceRow := aRow;
        tsWCXShow(stgPlugins);
      end
    else if pcPluginsTypes.ActivePage.Name = 'tsWDX' then
      begin
        tmpWDXPlugins.Exchange(FSourceRow - FixedRows, aRow - FixedRows);
        FSourceRow := aRow;
        tsWDXShow(stgPlugins);
      end
    else if pcPluginsTypes.ActivePage.Name = 'tsWFX' then
      begin
        tmpWFXPlugins.Exchange(FSourceRow - FixedRows, aRow - FixedRows);
        FSourceRow := aRow;
        tsWFXShow(stgPlugins);
      end
    else if pcPluginsTypes.ActivePage.Name = 'tsWLX' then
      begin
        tmpWLXPlugins.Exchange(FSourceRow - FixedRows, aRow - FixedRows);
        FSourceRow := aRow;
        tsWLXShow(stgPlugins);
      end;
  end;
end;

procedure TfrmOptionsPlugins.tsWCXShow(Sender: TObject);
var
  I,
  iIndex: Integer;
  sFileName,
  sExt: String;
  iRow: Integer;
begin
  btnAddPlugin.OnClick:= @btnWCXAddClick;
  stgPlugins.RowCount:= stgPlugins.FixedRows;

  // Clear column with extensions
  stgPlugins.Clean(2, stgPlugins.FixedRows, 2, stgPlugins.RowCount, [gzNormal]);

  for I := 0 to tmpWCXPlugins.Count - 1 do
  begin
    // get associated extension
    sExt := tmpWCXPlugins.Ext[I];

    //get file name
    sFileName:= tmpWCXPlugins.FileName[I];

    iIndex:= stgPlugins.Cols[3].IndexOf(sFileName);
    if iIndex < 0 then
      begin
        stgPlugins.RowCount:= stgPlugins.RowCount + 1;
        iRow := stgPlugins.RowCount - 1;
        stgPlugins.Cells[1, iRow]:= ExtractOnlyFileName(sFileName);
        stgPlugins.Cells[2, iRow]:= sExt + #32;

        if tmpWCXPlugins.Enabled[I] then // enabled
          begin
            stgPlugins.Cells[3, iRow]:= sFileName;
            stgPlugins.Cells[0, iRow]:= '+';
          end
        else // disabled
          begin
            stgPlugins.Cells[3, iRow]:= sFileName;
            stgPlugins.Cells[0, iRow]:= '-';
          end;
      end
    else
      begin
        stgPlugins.Cells[2, iIndex]:= stgPlugins.Cells[2, iIndex] + sExt + #32;
      end;
  end;
  if stgPlugins.RowCount > stgPlugins.FixedRows then
    stgPluginsBeforeSelection(stgPlugins, 0, stgPlugins.FixedRows);
end;

{ WDX plugins }

procedure TfrmOptionsPlugins.btnWDXAddClick(Sender: TObject);
var
  I, J: Integer;
  sFileName,
  sPluginName : String;
begin
  dmComData.OpenDialog.Filter := Format('Content plugins (%s;*.lua)|%s;*.lua', [WdxMask, WdxMask]);
  if dmComData.OpenDialog.Execute then
  begin
    sFileName := dmComData.OpenDialog.FileName;
    if not (StrEnds(sFileName, '.lua') or CheckPlugin(sFileName)) then Exit;

    sPluginName := ExtractOnlyFileName(sFileName);
    I:= tmpWDXPlugins.Add(sPluginName, sFileName, EmptyStr);

    if not tmpWDXPlugins.LoadModule(sPluginName) then
    begin
      MessageDlg(Application.Title, rsMsgInvalidPlugin, mtError, [mbOK], 0, mbOK);
      tmpWDXPlugins.DeleteItem(I);
      Exit;
    end;
    tmpWDXPlugins.GetWdxModule(sPluginName).DetectStr:= tmpWDXPlugins.GetWdxModule(sPluginName).CallContentGetDetectString;

    stgPlugins.RowCount:= stgPlugins.RowCount + 1;
    J:= stgPlugins.RowCount - 1;
    stgPlugins.Cells[1, J]:= tmpWDXPlugins.GetWdxModule(I).Name;
    stgPlugins.Cells[2, J]:= tmpWDXPlugins.GetWdxModule(I).DetectStr;
    stgPlugins.Cells[3, J]:= SetCmdDirAsEnvVar(tmpWDXPlugins.GetWdxModule(I).FileName);
  end;
end;

procedure TfrmOptionsPlugins.tsWDXShow(Sender: TObject);
var i:integer;
begin
  btnAddPlugin.OnClick:= @btnWDXAddClick;
  stgPlugins.RowCount:= tmpWDXPlugins.Count + stgPlugins.FixedRows;
  for i:=0 to tmpWDXPlugins.Count-1 do
    begin
    stgPlugins.Cells[1, I + stgPlugins.FixedRows]:= tmpWDXPlugins.GetWdxModule(i).Name;
    stgPlugins.Cells[2, I + stgPlugins.FixedRows]:= tmpWDXPlugins.GetWdxModule(i).DetectStr;
    stgPlugins.Cells[3, I + stgPlugins.FixedRows]:= SetCmdDirAsEnvVar(tmpWDXPlugins.GetWdxModule(i).FileName);
    end;
end;

{ WFX plugins }

procedure TfrmOptionsPlugins.btnWFXAddClick(Sender: TObject);
var
  I, J: Integer;
  WfxModule : TWFXmodule;
  sFileName,
  sPluginName,
  sRootName: UTF8String;
begin
  dmComData.OpenDialog.Filter := Format('File system plugins (%s)|%s', [WfxMask, WfxMask]);
  if dmComData.OpenDialog.Execute then
  begin
    sFileName:= dmComData.OpenDialog.FileName;
    DCDebug('Dialog executed');
    if not CheckPlugin(sFileName) then Exit;

    WfxModule:= TWfxModule.Create;
    DCDebug('TWFXmodule created');
    try
      if not WfxModule.LoadModule(sFileName) then
      begin
        DCDebug('Module not loaded');
        MessageDlg(Application.Title, rsMsgInvalidPlugin, mtError, [mbOK], 0, mbOK);
        Exit;
      end;

      DCDebug('WFXModule Loaded');
      sRootName:= WfxModule.VFSRootName;
      if Length(sRootName) = 0 then
      begin
        DCDebug('WFX alternate name');
        sRootName:= ExtractOnlyFileName(sFileName);
      end;
      sPluginName:= sRootName + '=' + SetCmdDirAsEnvVar(sFileName);

      WFXModule.UnloadModule;
      DCDebug('WFX Module Unloaded');

      DCDebug('WFX sPluginName=' + sPluginName);
      I:= tmpWFXPlugins.AddObject(sPluginName, TObject(True));
      stgPlugins.RowCount:= tmpWFXPlugins.Count + 1;
      J:= stgPlugins.RowCount - 1;
      stgPlugins.Cells[0, J]:= '+';
      stgPlugins.Cells[1, J]:= tmpWFXPlugins.Name[I];
      stgPlugins.Cells[2, J]:= EmptyStr;
      stgPlugins.Cells[3, J]:= tmpWFXPlugins.FileName[I];
      DCDebug('WFX Item Added');
    finally
      WFXmodule.Free;
      DCDebug('WFX Freed');
    end;
  end;
end;

procedure TfrmOptionsPlugins.tsWFXShow(Sender: TObject);
var
  I, iRow: Integer;
begin
  btnAddPlugin.OnClick:= @btnWFXAddClick;
  stgPlugins.RowCount:= tmpWFXPlugins.Count + stgPlugins.FixedRows;
  for I:= 0 to tmpWFXPlugins.Count - 1 do
  begin
    iRow := I + stgPlugins.FixedRows;
    if tmpWFXPlugins.Enabled[I] then
      begin
        stgPlugins.Cells[1, iRow]:= tmpWFXPlugins.Name[I];
        stgPlugins.Cells[3, iRow]:= tmpWFXPlugins.FileName[I];
        stgPlugins.Cells[0, iRow]:= '+';
      end
    else
      begin
        stgPlugins.Cells[1, iRow]:= tmpWFXPlugins.Name[I];
        stgPlugins.Cells[3, iRow]:= tmpWFXPlugins.FileName[I];
        stgPlugins.Cells[0, iRow]:= '-';
      end;
    stgPlugins.Cells[2, iRow]:= '';
  end;
end;

{ WLX Plugins }

procedure TfrmOptionsPlugins.btnWLXAddClick(Sender: TObject);
var
  I, J: Integer;
  sFileName,
  sPluginName : String;
begin
  dmComData.OpenDialog.Filter:= Format('Viewer plugins (%s)|%s', [WlxMask, WlxMask]);
  if dmComData.OpenDialog.Execute then
  begin
    sFileName := dmComData.OpenDialog.FileName;
    if not CheckPlugin(sFileName) then Exit;

    sPluginName := ExtractOnlyFileName(sFileName);
    I:= tmpWLXPlugins.Add(sPluginName, sFileName, EmptyStr);

    if not tmpWLXPlugins.LoadModule(sPluginName) then
    begin
      MessageDlg(Application.Title, rsMsgInvalidPlugin, mtError, [mbOK], 0, mbOK);
      tmpWLXPlugins.DeleteItem(I);
      Exit;
    end;
    tmpWLXPlugins.GetWlxModule(sPluginName).DetectStr:= tmpWLXPlugins.GetWlxModule(sPluginName).CallListGetDetectString;

    stgPlugins.RowCount:= stgPlugins.RowCount + 1;
    J:= stgPlugins.RowCount - 1;
    stgPlugins.Cells[0, J]:= '+';
    stgPlugins.Cells[1, J]:= tmpWLXPlugins.GetWlxModule(I).Name;
    stgPlugins.Cells[2, J]:= tmpWLXPlugins.GetWlxModule(I).DetectStr;
    stgPlugins.Cells[3, J]:= SetCmdDirAsEnvVar(tmpWLXPlugins.GetWlxModule(I).FileName);
  end;
end;

procedure TfrmOptionsPlugins.tsWLXShow(Sender: TObject);
var
  i: Integer;
begin
  btnAddPlugin.OnClick:= @btnWLXAddClick;
  stgPlugins.RowCount:= tmpWLXPlugins.Count + stgPlugins.FixedRows;
  for i:=0 to tmpWLXPlugins.Count-1 do
    begin
    stgPlugins.Cells[0, I + stgPlugins.FixedRows]:= IfThen(tmpWLXPlugins.GetWlxModule(i).Enabled, '+', '-');
    stgPlugins.Cells[1, I + stgPlugins.FixedRows]:= tmpWLXPlugins.GetWlxModule(i).Name;
    stgPlugins.Cells[2, I + stgPlugins.FixedRows]:= tmpWLXPlugins.GetWlxModule(i).DetectStr;
    stgPlugins.Cells[3, I + stgPlugins.FixedRows]:= SetCmdDirAsEnvVar(tmpWLXPlugins.GetWlxModule(i).FileName);
    end;
end;

class function TfrmOptionsPlugins.GetIconIndex: Integer;
begin
  Result := 6;
end;

class function TfrmOptionsPlugins.GetTitle: String;
begin
  Result := rsOptionsEditorPlugins;
end;

procedure TfrmOptionsPlugins.Init;
begin
  // Localize plugins.
  stgPlugins.Columns.Items[0].Title.Caption := rsOptPluginsActive;
  stgPlugins.Columns.Items[1].Title.Caption := rsOptPluginsName;
  stgPlugins.Columns.Items[2].Title.Caption := rsOptPluginsRegisteredFor;
  stgPlugins.Columns.Items[3].Title.Caption := rsOptPluginsFileName;

  // create plugins lists
  tmpDSXPlugins:= TDSXModuleList.Create;
  tmpWCXPlugins:= TWCXModuleList.Create;
  tmpWDXPlugins:= TWDXModuleList.Create;
  tmpWFXPlugins:= TWFXModuleList.Create;
  tmpWLXPlugins:= TWLXModuleList.Create;
end;

procedure TfrmOptionsPlugins.Done;
begin
  FreeThenNil(tmpDSXPlugins);
  FreeThenNil(tmpWCXPlugins);
  FreeThenNil(tmpWDXPlugins);
  FreeThenNil(tmpWFXPlugins);
  FreeThenNil(tmpWLXPlugins);
end;

procedure TfrmOptionsPlugins.Load;
begin
  { Fill plugins lists }
  tmpDSXPlugins.Assign(gDSXPlugins);
  tmpWCXPlugins.Assign(gWCXPlugins);
  tmpWDXPlugins.Assign(gWDXPlugins);
  tmpWFXPlugins.Assign(gWFXPlugins);
  tmpWLXPlugins.Assign(gWLXPlugins);

  // Update selected page.
  if pcPluginsTypes.ActivePage = tsDSX then
    tsDSXShow(Self)
  else if pcPluginsTypes.ActivePage = tsWCX then
    tsWCXShow(Self)
  else if pcPluginsTypes.ActivePage = tsWDX then
    tsWDXShow(Self)
  else if pcPluginsTypes.ActivePage = tsWFX then
    tsWFXShow(Self)
  else if pcPluginsTypes.ActivePage = tsWLX then
    tsWLXShow(Self);
end;

function TfrmOptionsPlugins.Save: TOptionsEditorSaveFlags;
begin
  { Set plugins lists }
  gDSXPlugins.Assign(tmpDSXPlugins);
  gWCXPlugins.Assign(tmpWCXPlugins);
  gWDXPlugins.Assign(tmpWDXPlugins);
  gWFXPlugins.Assign(tmpWFXPlugins);
  gWLXPlugins.Assign(tmpWLXPlugins);
  Result := [];
end;

end.

