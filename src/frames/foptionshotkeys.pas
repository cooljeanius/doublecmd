{
   Double Commander
   -------------------------------------------------------------------------
   Hotkeys options page

   Copyright (C) 2006-2011  Koblov Alexander (Alexx2000@mail.ru)

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

unit fOptionsHotkeys;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, StdCtrls, Grids,
  fOptionsFrame, fOptionsHotkeysEditHotkey, uHotkeyManager, DCBasicTypes;

type

  { TfrmOptionsHotkeys }

  TfrmOptionsHotkeys = class(TOptionsEditor)
    btnDeleteHotKey: TButton;
    btnAddHotKey: TButton;
    btnEditHotkey: TButton;
    edtFilter: TEdit;
    lblCommands: TLabel;
    lbFilter: TLabel;
    lblSCFiles: TLabel;
    lbSCFilesList: TListBox;
    lblCategories: TLabel;
    lbxCategories: TListBox;
    pnlHotkeyButtons: TPanel;
    stgCommands: TStringGrid;
    stgHotkeys: TStringGrid;
    procedure btnAddHotKeyClick(Sender: TObject);
    procedure btnDeleteHotKeyClick(Sender: TObject);
    procedure btnEditHotkeyClick(Sender: TObject);
    procedure edtFilterChange(Sender: TObject);
    procedure lbSCFilesListSelectionChange(Sender: TObject; User: boolean);
    procedure lbxCategoriesSelectionChange(Sender: TObject; User: boolean);
    procedure stgCommandsResize(Sender: TObject);
    procedure stgCommandsSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure stgHotkeysDblClick(Sender: TObject);
    procedure stgHotkeysResize(Sender: TObject);
    procedure stgHotkeysSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
  private
    FEditForm: TfrmEditHotkey;
    FHotkeysAutoColWidths: array of Integer;
    FHotkeysAutoGridWidth: Integer;
    FHotkeysCategories: TStringList; // Untranslated
    FUpdatingShortcutsFiles: Boolean;
    procedure AutoSizeCommandsGrid;
    procedure AutoSizeHotkeysGrid;
    procedure ClearHotkeysGrid;
    procedure DeleteHotkeyFromGrid(aHotkey: String);
    function  GetSelectedCommand: String;
    {en
       Refreshes all hotkeys from the Commands grid
    }
    procedure UpdateHotkeys(HMForm: THMForm);
    procedure UpdateHotkeysForCommand(HMForm: THMForm; RowNr: Integer);
    procedure FillSCFilesList;
    {en
       Return hotkeys assigned for command for the form and its controls.
    }
    procedure GetHotKeyList(HMForm: THMForm; Command: String; HotkeysList: THotkeys);
    {en
       Fill hotkey grid with all hotkeys assigned to a command
    }
    procedure FillHotkeyList(sCommand: String);
    {en
       Fill Commands grid with all commands available for the selected category.
       @param(Filter
              If not empty string then shows only commands containing Filter string.)
    }
    procedure FillCommandList(Filter: String);
    procedure FillCategoriesList;
    {en
       Retrieves untranslated form name.
    }
    function GetSelectedForm: String;
    procedure SelectHotkey(Hotkey: THotkey);
    procedure ShowEditHotkeyForm(EditMode: Boolean; aHotkeyRow: Integer);
    procedure ShowEditHotkeyForm(EditMode: Boolean;
                                 const AForm: String;
                                 const ACommand: String;
                                 const AHotkey: THotkey;
                                 const AControls: TDynamicStringArray);
  protected
    procedure Init; override;
    procedure Load; override;
    function Save: TOptionsEditorSaveFlags; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddDeleteWithShiftHotkey(UseTrash: Boolean);
    class function GetIconIndex: Integer; override;
    class function GetTitle: String; override;
  end;

implementation

{$R *.lfm}

uses
  Forms, Controls, Dialogs, LCLProc, LCLVersion,
  uFindEx, uGlobs, uGlobsPaths, uLng, uKeyboard, uFormCommands, DCStrUtils;

const
  stgCmdCommandIndex = 0;
  stgCmdHotkeysIndex = 1;
  stgCmdDescriptionIndex = 2;

type
  PHotkeyItem = ^THotkeyItem;
  THotkeyItem = record
    Hotkey: THotkey;
    Controls: TDynamicStringArray;
  end;

procedure DestroyHotkeyItem(HotkeyItem: PHotkeyItem);
begin
  if Assigned(HotkeyItem) then
  begin
    HotkeyItem^.Hotkey.Free;
    Dispose(HotkeyItem);
  end;
end;

// Converts hotkeys list to string.
function HotkeysToString(const Hotkeys: THotkeys): String;
var
  sCurrent: String;
  i: Integer;
  sList: TStringList;
begin
  Result := '';
  sList := TStringList.Create;
  try
    sList.CaseSensitive := True;
    for i := 0 to Hotkeys.Count - 1 do
    begin
      sCurrent := ShortcutsToText(Hotkeys[i].Shortcuts);
      if sList.IndexOf(sCurrent) < 0 then
      begin
        sList.Add(sCurrent);
        AddStrWithSep(Result, sCurrent, ';');
      end;
    end;
  finally
    sList.Free;
  end;
end;

function CompareCategories(List: TStringList; Index1, Index2: Integer): Integer;
begin
{$IF LCL_FULLVERSION >= 093100}
  Result := UTF8CompareText(List.Strings[Index1], List.Strings[Index2]);
{$ELSE}
  Result := WideCompareText(UTF8Decode(List.Strings[Index1]), UTF8Decode(List.Strings[Index2]));
{$ENDIF}
end;

{ TfrmOptionsHotkeys }

procedure TfrmOptionsHotkeys.btnDeleteHotKeyClick(Sender: TObject);
var
  i: Integer;
  sCommand: String;
  HMForm: THMForm;
  HMControl: THMControl;
  hotkey: THotkey;
  HotkeyItem: PHotkeyItem;
begin
  if stgHotkeys.Row >= stgHotkeys.FixedRows then
  begin
    HotkeyItem := PHotkeyItem(stgHotkeys.Objects[0, stgHotkeys.Row]);
    sCommand := GetSelectedCommand;
    HMForm := HotMan.Forms.Find(GetSelectedForm);
    if Assigned(HMForm) then
    begin
      for i := 0 to HMForm.Controls.Count - 1 do
      begin
        HMControl := HMForm.Controls[i];
        if Assigned(HMControl) then
        begin
          hotkey := HMControl.Hotkeys.FindByContents(HotkeyItem^.Hotkey);
          if Assigned(hotkey) then
            HMControl.Hotkeys.Remove(hotkey);
        end;
      end;

      hotkey := HMForm.Hotkeys.FindByContents(HotkeyItem^.Hotkey);
      if Assigned(hotkey) then
        HMForm.Hotkeys.Remove(hotkey);

      // refresh lists
      Self.UpdateHotkeys(HMForm);
      Self.FillHotkeyList(sCommand);
    end;
  end;
end;

procedure TfrmOptionsHotkeys.btnEditHotkeyClick(Sender: TObject);
begin
  ShowEditHotkeyForm(True, stgHotkeys.Row);
end;

procedure TfrmOptionsHotkeys.edtFilterChange(Sender: TObject);
{< filtering active commands list}
begin
  if lbxCategories.ItemIndex=-1 then Exit;
  FillCommandList(edtFilter.Text);
end;

procedure TfrmOptionsHotkeys.lbSCFilesListSelectionChange(Sender: TObject; User: boolean);
begin
  if not FUpdatingShortcutsFiles and (lbSCFilesList.ItemIndex >= 0) then
  begin
    HotMan.Load(gpCfgDir + lbSCFilesList.Items[lbSCFilesList.ItemIndex]);
    FillCategoriesList;
  end;
end;

procedure TfrmOptionsHotkeys.lbxCategoriesSelectionChange(Sender: TObject; User: boolean);
begin
  if lbxCategories.ItemIndex=-1 then Exit;

  edtFilter.Clear;
  FillCommandList('');
end;

procedure TfrmOptionsHotkeys.stgCommandsResize(Sender: TObject);
begin
  AutoSizeCommandsGrid;
end;

procedure TfrmOptionsHotkeys.stgCommandsSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
  // < find hotkeys for command
var
  sCommand: String;
begin
  // clears all controls
  btnAddHotKey.Enabled := False;
  btnDeleteHotKey.Enabled := False;
  btnEditHotkey.Enabled := False;
  ClearHotkeysGrid;

  if aRow >= stgCommands.FixedRows then
  begin
    sCommand := stgCommands.Cells[stgCmdCommandIndex, aRow];
    FillHotkeyList(sCommand);
    btnAddHotKey.Enabled := True;
  end;
end;

procedure TfrmOptionsHotkeys.stgHotkeysDblClick(Sender: TObject);
begin
  ShowEditHotkeyForm(True, stgHotkeys.Row);
end;

procedure TfrmOptionsHotkeys.stgHotkeysResize(Sender: TObject);
begin
  AutoSizeHotkeysGrid;
end;

procedure TfrmOptionsHotkeys.stgHotkeysSelectCell(Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
var
  aEnabled: Boolean;
begin
  aEnabled := aRow >= stgHotkeys.FixedRows;
  btnDeleteHotKey.Enabled := aEnabled;
  btnEditHotkey.Enabled := aEnabled;
end;

procedure TfrmOptionsHotkeys.AutoSizeCommandsGrid;
begin
  with stgCommands do
  begin
    AutoSizeColumns;
    if ClientWidth > GridWidth then
      ColWidths[stgCmdDescriptionIndex] := ColWidths[stgCmdDescriptionIndex] + (ClientWidth - GridWidth);
  end;
end;

procedure TfrmOptionsHotkeys.AutoSizeHotkeysGrid;
var
  Diff: Integer = 0;
  i: Integer;
begin
  with stgHotkeys do
  begin
    if Length(FHotkeysAutoColWidths) = ColCount then
    begin
      if ClientWidth > FHotkeysAutoGridWidth then
        Diff := (ClientWidth - FHotkeysAutoGridWidth) div 3;
      for i := 0 to ColCount - 1 do
        ColWidths[i] := FHotkeysAutoColWidths[i] + Diff;
    end;
  end;
end;

procedure TfrmOptionsHotkeys.btnAddHotKeyClick(Sender: TObject);
begin
  ShowEditHotkeyForm(False, GetSelectedForm, GetSelectedCommand, nil, nil);
end;

procedure TfrmOptionsHotkeys.DeleteHotkeyFromGrid(aHotkey: String);
var
  i: Integer;
begin
  for i := stgHotkeys.FixedRows to stgHotkeys.RowCount - 1 do
    if stgHotkeys.Cells[0, i] = aHotkey then
    begin
      DestroyHotkeyItem(PHotkeyItem(stgHotkeys.Objects[0, i]));
      stgHotkeys.DeleteColRow(False, i);
      Break;
    end;
end;

procedure TfrmOptionsHotkeys.UpdateHotkeys(HMForm: THMForm);
var
  i: Integer;
begin
  for i := Self.stgCommands.FixedRows to Self.stgCommands.RowCount - 1 do
    Self.UpdateHotkeysForCommand(HMForm, i);
end;

procedure TfrmOptionsHotkeys.UpdateHotkeysForCommand(HMForm: THMForm; RowNr: Integer);
var
  Hotkeys: THotkeys;
begin
  Hotkeys := THotkeys.Create(False);
  try
    GetHotKeyList(HMForm, stgCommands.Cells[stgCmdCommandIndex,RowNr], Hotkeys);
    stgCommands.Cells[stgCmdHotkeysIndex, RowNr] := HotkeysToString(Hotkeys);
  finally
    Hotkeys.Free;
  end;
end;

procedure TfrmOptionsHotkeys.FillSCFilesList;
var
  SR : TSearchRecEx;
  Res : Integer;
begin
  FUpdatingShortcutsFiles := True;
  lbSCFilesList.Items.Clear;
  Res := FindFirstEx(gpCfgDir + '*.scf', faAnyFile, SR);
  while Res = 0 do
  begin
    Res:= lbSCFilesList.Items.Add(Sr.Name);
    if Sr.Name = gNameSCFile then
      lbSCFilesList.Selected[Res] := True;
    Res := FindNextEx(SR);
  end;
  FindCloseEx(SR);
  FUpdatingShortcutsFiles := False;
end;

procedure TfrmOptionsHotkeys.GetHotKeyList(HMForm: THMForm; Command: String; HotkeysList: THotkeys);
  procedure AddHotkeys(hotkeys: THotkeys);
  var
    i: Integer;
  begin
    for i := 0 to hotkeys.Count - 1 do
    begin
      if hotkeys[i].Command = Command then
        HotkeysList.Add(hotkeys[i]);
    end;
  end;
var
  i: Integer;
begin
  AddHotkeys(HMForm.Hotkeys);
  for i := 0 to HMForm.Controls.Count - 1 do
    AddHotkeys(HMForm.Controls[i].Hotkeys);
end;

procedure TfrmOptionsHotkeys.ClearHotkeysGrid;
var
  i: Integer;
begin
  for i := stgHotkeys.FixedRows to stgHotkeys.RowCount - 1 do
    DestroyHotkeyItem(PHotkeyItem(stgHotkeys.Objects[0, i]));
  stgHotkeys.RowCount := stgHotkeys.FixedRows;
end;

procedure TfrmOptionsHotkeys.FillHotkeyList(sCommand: String);
  function SetObject(RowNr: Integer; AHotkey: THotkey): PHotkeyItem;
  var
    HotkeyItem: PHotkeyItem;
  begin
    New(HotkeyItem);
    stgHotkeys.Objects[0, RowNr] := TObject(HotkeyItem);
    HotkeyItem^.Hotkey := AHotkey.Clone;
    Result := HotkeyItem;
  end;
var
  HMForm: THMForm;
  HMControl: THMControl;
  iHotKey, iControl, iGrid: Integer;
  hotkey: THotkey;
  found: Boolean;
  HotkeyItem: PHotkeyItem;
begin
  ClearHotkeysGrid;

  if (sCommand = EmptyStr) or (lbxCategories.ItemIndex = -1) then
    Exit;

  HMForm := HotMan.Forms.Find(GetSelectedForm);
  if not Assigned(HMForm) then
    Exit;

  stgHotkeys.BeginUpdate;
  try
    // add hotkeys from form
    for iHotKey := 0 to HMForm.Hotkeys.Count - 1 do
    begin
      hotkey := HMForm.Hotkeys[iHotKey];
      if hotkey.Command <> sCommand then
        continue;

      stgHotkeys.RowCount := stgHotkeys.RowCount + 1;
      stgHotkeys.Cells[0, stgHotkeys.RowCount - 1] := ShortcutsToText(hotkey.Shortcuts);
      stgHotkeys.Cells[1, stgHotkeys.RowCount - 1] := ArrayToString(hotkey.Params);
      SetObject(stgHotkeys.RowCount - 1, hotkey);
    end;

    // add hotkeys from controls
    for iControl := 0 to HMForm.Controls.Count - 1  do
    begin
      HMControl := HMForm.Controls[iControl];
      for iHotKey := 0 to HMControl.Hotkeys.Count - 1 do
      begin
        hotkey := HMControl.Hotkeys[iHotKey];
        if hotkey.Command <> sCommand then
          continue;

        // search for hotkey in grid and add control name to list
        found := false;
        for iGrid := stgHotkeys.FixedRows to stgHotkeys.RowCount - 1 do
        begin
          HotkeyItem := PHotkeyItem(stgHotkeys.Objects[0, iGrid]);
          if HotkeyItem^.Hotkey.SameShortcuts(hotkey.Shortcuts) and
             HotkeyItem^.Hotkey.SameParams(hotkey.Params) then
          begin
            stgHotkeys.Cells[2, iGrid] := stgHotkeys.Cells[2, iGrid] + HMControl.Name + ';';
            HotkeyItem := PHotkeyItem(stgHotkeys.Objects[0, iGrid]);
            AddString(HotkeyItem^.Controls, HMControl.Name);
            found := true;
            break;
          end; { if }
        end; { for }

        // add new row for hotkey
        if not found then
        begin
          stgHotkeys.RowCount := stgHotkeys.RowCount + 1;
          stgHotkeys.Cells[0, stgHotkeys.RowCount - 1] := ShortcutsToText(hotkey.Shortcuts);
          stgHotkeys.Cells[1, stgHotkeys.RowCount - 1] := ArrayToString(hotkey.Params);
          stgHotkeys.Cells[2, stgHotkeys.RowCount - 1] := HMControl.Name + ';';
          HotkeyItem := SetObject(stgHotkeys.RowCount - 1, hotkey);
          AddString(HotkeyItem^.Controls, HMControl.Name);
        end; { if }
      end; { for }
    end; { for }
  finally
    stgHotkeys.EndUpdate;
  end;

  stgHotkeys.AutoSizeColumns;
  SetLength(FHotkeysAutoColWidths, stgHotkeys.ColCount);
  for iHotKey := 0 to stgHotkeys.ColCount - 1 do
    FHotkeysAutoColWidths[iHotKey] := stgHotkeys.ColWidths[iHotKey];
  FHotkeysAutoGridWidth := stgHotkeys.GridWidth;
  AutoSizeHotkeysGrid;
end;


procedure TfrmOptionsHotkeys.FillCommandList(Filter: String);
//< fill stgCommands with commands and descriptions
var
  slTmp: THotkeys;
  slAllCommands, slDescriptions, slHotKey: TStringList;
  slFiltered: TStringList = nil;
  lstr:   String;
  i:      Integer;
  HMForm: THMForm;
  sForm:  String;
  CommandsFormClass: TComponentClass;
  CommandsForm: TComponent = nil;
  CommandsFormCreated: Boolean = False;
  CommandsIntf: IFormCommands;
begin
  sForm := GetSelectedForm;
  CommandsFormClass := TFormCommands.GetCommandsForm(sForm);
  if not Assigned(CommandsFormClass) or
     not Supports(CommandsFormClass, IFormCommands) then
  begin
    stgCommands.Clean;
    Exit;
  end;

  // Find an instance of the form to retrieve action list (for descriptions).
  for i := 0 to Screen.CustomFormCount - 1 do
    if Screen.CustomForms[i].ClassType = CommandsFormClass then
    begin
      CommandsForm := Screen.CustomForms[i];
      Break;
    end;

  // If not found create an instance temporarily.
  if not Assigned(CommandsForm) then
  begin
    CommandsForm := CommandsFormClass.Create(Application);
    CommandsFormCreated := True;
  end;

  CommandsIntf := CommandsForm as IFormCommands;

  slAllCommands  := TStringList.Create;
  slDescriptions := TStringList.Create;
  slHotKey       := TStringList.Create;
  slTmp          := THotkeys.Create(False);
  HMForm         := HotMan.Forms.Find(sForm);

  CommandsIntf.GetCommandsList(slAllCommands);

  if Filter <> '' then // if filter not empty
  begin
    slFiltered := TStringList.Create;
    lstr := UTF8LowerCase(Filter);
    for i := 0 to slAllCommands.Count - 1 do // for all command
      // if filtered text find in command or description then add to filteredlist
      if (UTF8Pos(lstr, UTF8LowerCase(slAllCommands.Strings[i])) <> 0) or
         (UTF8Pos(lstr, UTF8LowerCase(CommandsIntf.GetCommandCaption(slAllCommands.Strings[i], cctLong))) <> 0) then
      begin
        slFiltered.Add(slAllCommands[i]);
      end;
  end
  else // filter empty -> assign all commands to filtered list
  begin
    slFiltered    := slAllCommands;
    slAllCommands := nil;
  end;

  // sort filtered items
  slFiltered.Sort;
  for i := 0 to slFiltered.Count - 1 do
  begin // for all filtered items do
    // get description for command and add to slDescriptions list
    slDescriptions.Add(CommandsIntf.GetCommandCaption(slFiltered.Strings[i], cctLong));

    // getting list of assigned hot key
    if Assigned(HMForm) then
    begin
      slTmp.Clear;
      GetHotKeyList(HMForm, slFiltered.Strings[i], slTmp);
      slHotKey.Add(HotkeysToString(slTmp)); //add to hotkey list created string
    end
    else
      slHotKey.Add('');
  end;

  // add to list NAMES of columns
  slFiltered.Insert(0, rsOptHotkeysCommand);
  slDescriptions.Insert(0, rsOptHotkeysDescription);
  slHotKey.Insert(0, rsOptHotkeysHotkeys);
  //set stringgrid rows count
  stgCommands.RowCount := slFiltered.Count;
  // copy to string grid created lists
  stgCommands.BeginUpdate;
  stgCommands.Clean;
  stgCommands.Cols[stgCmdCommandIndex].Assign(slFiltered);
  stgCommands.Cols[stgCmdHotkeysIndex].Assign(slHotKey);
  stgCommands.Cols[stgCmdDescriptionIndex].Assign(slDescriptions);
  stgCommands.EndUpdate;
  AutoSizeCommandsGrid;

  stgCommands.Row := 0; // needs for call select function for refresh hotkeylist

  slHotKey.Free;
  slAllCommands.Free;
  slDescriptions.Free;
  slFiltered.Free;
  slTmp.Free;

  if CommandsFormCreated then
    CommandsForm.Free;
end;

procedure TfrmOptionsHotkeys.FillCategoriesList;
var
  i, MainIndex, Diff: Integer;
  Translated: TStringList;
begin
  Translated := TStringList.Create;
  try
    TFormCommands.GetCategoriesList(FHotkeysCategories, Translated);

    if FHotkeysCategories.Count > 0 then
    begin
      // Remove Main category so that it can be put to the top after sorting the rest.
      MainIndex := FHotkeysCategories.IndexOf('Main');
      if (MainIndex >= 0) and (Translated[MainIndex] = rsHotkeyCategoryMain) then
      begin
        FHotkeysCategories.Delete(MainIndex);
        Translated.Delete(MainIndex);
        Diff := 1; // Account for Main category being at the top.
      end
      else
      begin
        MainIndex := -1;
        Diff := 0;
      end;

      // Assign indexes to FHotkeysCategories (untranslated).
      for i := 0 to Translated.Count - 1 do
        Translated.Objects[i] := TObject(i + Diff);

      Translated.CustomSort(@CompareCategories);

      if MainIndex >= 0 then
      begin
        FHotkeysCategories.InsertObject(0, 'Main', TObject(0));
        Translated.InsertObject(0, rsHotkeyCategoryMain, TObject(0));
      end;

      lbxCategories.Items.Assign(Translated);
      lbxCategories.ItemIndex := 0;
    end
    else
      lbxCategories.Items.Clear;
  finally
    Translated.Free;
  end;
end;

function TfrmOptionsHotkeys.GetSelectedForm: String;
var
  Index: Integer;
begin
  Index := lbxCategories.ItemIndex;
  if (Index >= 0) and (Index < FHotkeysCategories.Count) then
    Result := FHotkeysCategories[PtrUInt(lbxCategories.Items.Objects[Index])]
  else
    Result := EmptyStr;
end;

class function TfrmOptionsHotkeys.GetIconIndex: Integer;
begin
  Result := 5;
end;

function TfrmOptionsHotkeys.GetSelectedCommand: String;
begin
  if stgCommands.Row >= stgCommands.FixedRows then
    Result := stgCommands.Cells[stgCmdCommandIndex, stgCommands.Row]
  else
    Result := EmptyStr;
end;

class function TfrmOptionsHotkeys.GetTitle: String;
begin
  Result := rsOptionsEditorHotKeys;
end;

procedure TfrmOptionsHotkeys.Init;
begin
  stgCommands.FocusRectVisible := False;
  stgHotkeys.FocusRectVisible := False;
  // Localize Hotkeys.
  // stgCommands is localized in FillCommandList.
  stgHotkeys.Columns.Items[0].Title.Caption := rsOptHotkeysHotkey;
  stgHotkeys.Columns.Items[1].Title.Caption := rsOptHotkeysParameters;
end;

procedure TfrmOptionsHotkeys.Load;
begin
  FillSCFilesList;
  FillCategoriesList;
end;

function TfrmOptionsHotkeys.Save: TOptionsEditorSaveFlags;
begin
  Result := [];

  // Save hotkeys file name.
  if lbSCFilesList.ItemIndex >= 0 then
    gNameSCFile := lbSCFilesList.Items[lbSCFilesList.ItemIndex];
end;

procedure TfrmOptionsHotkeys.SelectHotkey(Hotkey: THotkey);
var
  HotkeyItem: PHotkeyItem;
  i: Integer;
begin
  for i := stgHotkeys.FixedRows to stgHotkeys.RowCount - 1 do
  begin
    HotkeyItem := PHotkeyItem(stgHotkeys.Objects[0, i]);
    if Assigned(HotkeyItem) and HotkeyItem^.Hotkey.SameAs(Hotkey) then
    begin
      stgHotkeys.Row := i;
      Break;
    end;
  end;
end;

procedure TfrmOptionsHotkeys.ShowEditHotkeyForm(EditMode: Boolean; aHotkeyRow: Integer);
var
  HotkeyItem: PHotkeyItem;
begin
  HotkeyItem := PHotkeyItem(stgHotkeys.Objects[0, aHotkeyRow]);
  if Assigned(HotkeyItem) then
    ShowEditHotkeyForm(EditMode,
                       GetSelectedForm,
                       HotkeyItem^.Hotkey.Command,
                       HotkeyItem^.Hotkey,
                       HotkeyItem^.Controls);
end;

procedure TfrmOptionsHotkeys.ShowEditHotkeyForm(
  EditMode: Boolean;
  const AForm: String;
  const ACommand: String;
  const AHotkey: THotkey;
  const AControls: TDynamicStringArray);
var
  HMForm: THMForm;
  Hotkey: THotkey = nil;
begin
  if AForm <> EmptyStr then
  begin
    if not Assigned(FEditForm) then
      FEditForm := TfrmEditHotkey.Create(Self);

    if FEditForm.Execute(EditMode, AForm, ACommand, AHotkey, AControls) then
    begin
      HMForm := HotMan.Forms.FindOrCreate(AForm);

      // refresh hotkey lists
      Self.UpdateHotkeys(HMForm);
      Self.FillHotkeyList(ACommand);

      Hotkey := FEditForm.CloneNewHotkey;
      try
        // Select the new shortcut in the hotkeys table.
        SelectHotkey(Hotkey);
      finally
        Hotkey.Free;
      end;
    end;
  end;
end;

constructor TfrmOptionsHotkeys.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FHotkeysCategories := TStringList.Create;
end;

destructor TfrmOptionsHotkeys.Destroy;
begin
  inherited Destroy;
  FHotkeysCategories.Free;
end;

procedure TfrmOptionsHotkeys.AddDeleteWithShiftHotkey(UseTrash: Boolean);
  procedure ReverseShift(Hotkey: THotkey; out Shortcut: TShortCut; out TextShortcut: String);
  var
    ShiftState: TShiftState;
  begin
    Shortcut := TextToShortCutEx(Hotkey.Shortcuts[0]);
    ShiftState := ShortcutToShiftEx(Shortcut);
    if ssShift in ShiftState then
      ShiftState := ShiftState - [ssShift]
    else
      ShiftState := ShiftState + [ssShift];
    ShortCut := KeyToShortCutEx(Shortcut, ShiftState);
    TextShortcut := ShortCutToTextEx(Shortcut);
  end;
  function ConfirmFix(Hotkey: THotkey; const Msg: String): Boolean;
  begin
    Result := QuestionDlg(rsOptHotkeysCannotSetShortcut, Msg,
                          mtConfirmation, [mrYes, rsOptHotkeysFixParameter, 'isdefault', mrCancel], 0) = mrYes;
  end;
  function FixOverrides(Hotkey: THotkey; const OldTrashParam: String; NewTrashParam: Boolean; ShouldUseTrash: Boolean): Boolean;
  begin
    if Contains(Hotkey.Params, OldTrashParam) or NewTrashParam then
    begin
      Result := ConfirmFix(Hotkey, Format(rsOptHotkeysDeleteTrashCanOverrides, [Hotkey.Shortcuts[0]]));
      if Result then
      begin
        DeleteString(Hotkey.Params, OldTrashParam);
        if ShouldUseTrash then
          SetValue(Hotkey.Params, 'trashcan', 'setting')
        else
          SetValue(Hotkey.Params, 'trashcan', 'reversesetting');
      end;
    end
    else
      Result := True;
  end;
  procedure FixReversedShortcut(
    Hotkey: THotkey;
    NonReversedHotkey: THotkey;
    const ParamsToDelete: array of String;
    const AllowedOldParam: String;
    const NewTrashParam: String;
    HasTrashCan: Boolean;
    TrashStr: String);
  var
    sDelete: String;
  begin
    if ContainsOneOf(Hotkey.Params, ParamsToDelete) or
       (HasTrashCan and (TrashStr <> NewTrashParam)) then
      if not ConfirmFix(Hotkey, Format(rsOptHotkeysDeleteTrashCanParameterExists, [Hotkey.Shortcuts[0], NonReversedHotkey.Shortcuts[0]])) then
        Exit;

    for sDelete in ParamsToDelete do
      DeleteString(Hotkey.Params, sDelete);
    if not Contains(Hotkey.Params, AllowedOldParam) then
      SetValue(Hotkey.Params, 'trashcan', NewTrashParam);
  end;
  procedure AddShiftShortcut(Hotkeys: THotkeys);
  var
    i, j: Integer;
    Shortcut: TShortCut;
    TextShortcut: String;
    NewParams: array of String;
    HasTrashCan, HasTrashBool, NormalTrashSetting: Boolean;
    TrashStr: String;
    TrashBoolValue: Boolean;
    CheckedShortcuts: TDynamicStringArray;
    ReversedHotkey: THotkey;
    CountBeforeAdded: Integer;
    SetShortcut: Boolean;
  begin
    SetLength(CheckedShortcuts, 0);
    CountBeforeAdded := Hotkeys.Count;
    for i := 0 to CountBeforeAdded - 1 do
    begin
      if (Hotkeys[i].Command = 'cm_Delete') and
         (Length(Hotkeys[i].Shortcuts) > 0) then
      begin
        if Length(Hotkeys[i].Shortcuts) > 1 then
        begin
          MessageDlg(rsOptHotkeysCannotSetShortcut,
                     Format(rsOptHotkeysShortcutForDeleteIsSequence, [ShortcutsToText(Hotkeys[i].Shortcuts)]),
                            mtWarning, [mbOK], 0);
          Continue;
        end;

        if not Contains(CheckedShortcuts, Hotkeys[i].Shortcuts[0]) then
        begin
          ReversedHotkey := nil;
          SetShortcut := True;
          ReverseShift(Hotkeys[i], Shortcut, TextShortcut);
          AddString(CheckedShortcuts, TextShortcut);

          // Check if shortcut with reversed shift already exists.
          for j := 0 to CountBeforeAdded - 1 do
          begin
            if ArrBegins(Hotkeys[j].Shortcuts, [TextShortcut], False) then
            begin
              if Hotkeys[j].Command <> Hotkeys[i].Command then
              begin
                if QuestionDlg(rsOptHotkeysCannotSetShortcut,
                               Format(rsOptHotkeysShortcutForDeleteAlreadyAssigned,
                                [Hotkeys[i].Shortcuts[0], TextShortcut, Hotkeys[j].Command]),
                               mtConfirmation, [mrYes, rsOptHotkeysChangeShortcut, 'isdefault', mrCancel], 0) = mrYes then
                begin
                  Hotkeys[j].Command := Hotkeys[i].Command;
                end
                else
                  SetShortcut := False;
              end;

              ReversedHotkey := Hotkeys[j];
              Break;
            end;
          end;

          if not SetShortcut then
            Continue;

          // Fix parameters of original hotkey if needed.
          HasTrashCan := GetParamValue(Hotkeys[i].Params, 'trashcan', TrashStr);
          HasTrashBool := HasTrashCan and GetBoolValue(TrashStr, TrashBoolValue);
          if not FixOverrides(Hotkeys[i], 'recycle', HasTrashBool and TrashBoolValue, UseTrash) then
            Continue;
          if not FixOverrides(Hotkeys[i], 'norecycle', HasTrashBool and not TrashBoolValue, not UseTrash) then
            Continue;

          // Reverse trash setting for reversed hotkey.
          NewParams := Copy(Hotkeys[i].Params);
          HasTrashCan := GetParamValue(NewParams, 'trashcan', TrashStr); // Could have been added above so check again
          if Contains(NewParams, 'recyclesettingrev') then
          begin
            DeleteString(NewParams, 'recyclesettingrev');
            NormalTrashSetting := True;
          end
          else if Contains(NewParams, 'recyclesetting') then
          begin
            DeleteString(NewParams, 'recyclesetting');
            NormalTrashSetting := False;
          end
          else if HasTrashCan and (TrashStr = 'reversesetting') then
            NormalTrashSetting := True
          else
            NormalTrashSetting := False;

          if Assigned(ReversedHotkey) then
          begin
            HasTrashCan := GetParamValue(ReversedHotkey.Params, 'trashcan', TrashStr);

            if NormalTrashSetting then
            begin
              FixReversedShortcut(ReversedHotkey, Hotkeys[i],
                ['recyclesettingrev', 'recycle', 'norecycle'],
                'recyclesetting', 'setting', HasTrashCan, TrashStr);
            end
            else
            begin
              FixReversedShortcut(ReversedHotkey, Hotkeys[i],
                ['recyclesetting', 'recycle', 'norecycle'],
                'recyclesettingrev', 'reversesetting', HasTrashCan, TrashStr);
            end;
          end
          else if QuestionDlg(rsOptHotkeysSetDeleteShortcut,
                              Format(rsOptHotkeysAddDeleteShortcutLong, [TextShortcut]),
                              mtConfirmation, [mrYes, rsOptHotkeysAddShortcutButton, 'isdefault', mrCancel], 0) = mrYes then
          begin
            if NormalTrashSetting then
              TrashStr := 'setting'
            else
              TrashStr := 'reversesetting';
            SetValue(NewParams, 'trashcan', TrashStr);

            Hotkeys.Add([TextShortcut], NewParams, Hotkeys[i].Command);
          end;
        end;
      end;
    end;
  end;

var
  HMForm: THMForm;
  I: Integer;
begin
  HMForm := HotMan.Forms.Find('Main');
  if Assigned(HMForm) then
  begin
    AddShiftShortcut(HMForm.Hotkeys);
    for I := 0 to HMForm.Controls.Count - 1 do
      AddShiftShortcut(HMForm.Controls[i].Hotkeys);
    // Refresh hotkeys list.
    if GetSelectedCommand = 'cm_Delete' then
      Self.FillHotkeyList('cm_Delete');
  end;
end;

end.

