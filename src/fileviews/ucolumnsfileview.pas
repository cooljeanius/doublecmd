unit uColumnsFileView;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Controls, Forms, ExtCtrls, Grids,
  LMessages, LCLIntf, LCLType, Menus, LCLVersion,
  uFile,
  uFileProperty,
  uFileView,
  uFileViewWithMainCtrl,
  uFileSource,
  uDisplayFile,
  uColumns,
  uFileSorting,
  DCXmlConfig,
  DCClassesUtf8,
  uTypes;

type
  TColumnsSortDirections = array of TSortDirection;
  TColumnsFileView = class;

  { TDrawGridEx }

  TDrawGridEx = class(TDrawGrid)
  private
    ColumnsView: TColumnsFileView;

    function GetGridHorzLine: Boolean;
    function GetGridVertLine: Boolean;
    procedure SetGridHorzLine(const AValue: Boolean);
    procedure SetGridVertLine(const AValue: Boolean);

  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift:TShiftState; X,Y:Integer); override;

    procedure InitializeWnd; override;
    procedure FinalizeWnd; override;

    procedure DrawCell(aCol, aRow: Integer; aRect: TRect;
              aState: TGridDrawState); override;

  public
    constructor Create(AOwner: TComponent; AParent: TWinControl); reintroduce;

    procedure UpdateView;

    function MouseOnGrid(X, Y: LongInt): Boolean;

    // Returns height of all the header rows.
    function GetHeaderHeight: Integer;

    // Adapted from TCustomGrid.GetVisibleGrid only for visible rows.
    function GetVisibleRows: TRange;
    {en
       Retrieves first and last fully visible row number.
    }
    function GetFullVisibleRows: TRange;

    function IsRowVisible(aRow: Integer): Boolean;
    procedure ScrollHorizontally(ForwardDirection: Boolean);

    property GridVertLine: Boolean read GetGridVertLine write SetGridVertLine;
    property GridHorzLine: Boolean read GetGridHorzLine write SetGridHorzLine;
  end;

  { TColumnsFileView }

  TColumnsFileView = class(TFileViewWithMainCtrl)

  private
    FColumnsSortDirections: TColumnsSortDirections;
    FFileNameColumn: Integer;
    FExtensionColumn: Integer;

    pmColumnsMenu: TPopupMenu;
    dgPanel: TDrawGridEx;

    function GetColumnsClass: TPanelColumnsClass;

    procedure SetRowCount(Count: Integer);
    procedure SetFilesDisplayItems;
    procedure SetColumns;

    procedure MakeVisible(iRow: Integer);
    procedure MakeActiveVisible;

    {en
       Format and cache all columns strings.
    }
    procedure MakeColumnsStrings(AFile: TDisplayFile);
    procedure MakeColumnsStrings(AFile: TDisplayFile; ColumnsClass: TPanelColumnsClass);
    procedure ClearAllColumnsStrings;
    procedure EachViewUpdateColumns(AFileView: TFileView; UserData: Pointer);

    {en
       Translates file sorting by functions to sorting directions of columns.
    }
    procedure SetColumnsSortDirections;

    {en
       Checks which file properties are needed for displaying.
    }
    function GetFilePropertiesNeeded: TFilePropertiesTypes;

    // -- Events --------------------------------------------------------------

{$IF lcl_fullversion >= 093100}
    procedure dgPanelBeforeSelection(Sender: TObject; aCol, aRow: Integer);
{$ENDIF}
    procedure dgPanelHeaderClick(Sender: TObject;IsColumn: Boolean; index: Integer);
    procedure dgPanelMouseWheelUp(Sender: TObject; Shift: TShiftState;
                                  MousePos: TPoint; var Handled: Boolean);
    procedure dgPanelMouseWheelDown(Sender: TObject; Shift: TShiftState;
                                  MousePos: TPoint; var Handled: Boolean);
    procedure dgPanelSelection(Sender: TObject; aCol, aRow: Integer);
    procedure dgPanelTopLeftChanged(Sender: TObject);
    procedure dgPanelResize(Sender: TObject);
    procedure ColumnsMenuClick(Sender: TObject);

  protected
    procedure CreateDefault(AOwner: TWinControl); override;

    procedure BeforeMakeFileList; override;
    procedure ClearAfterDragDrop; override;
    procedure DisplayFileListChanged; override;
    procedure DoFileUpdated(AFile: TDisplayFile; UpdatedProperties: TFilePropertiesTypes = []); override;
    procedure DoHandleKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoMainControlShowHint(FileIndex: PtrInt; X, Y: Integer); override;
    procedure DoUpdateView; override;
    procedure FileSourceFileListLoaded; override;
    function GetActiveFileIndex: PtrInt; override;
    function GetFileIndexFromCursor(X, Y: Integer; out AtFileList: Boolean): PtrInt; override;
    function GetFileRect(FileIndex: PtrInt): TRect; override;
    function GetVisibleFilesIndexes: TRange; override;
    procedure RedrawFile(FileIndex: PtrInt); override;
    procedure RedrawFile(DisplayFile: TDisplayFile); override;
    procedure RedrawFiles; override;
    procedure SetActiveFile(FileIndex: PtrInt); override;
    procedure SetSorting(const NewSortings: TFileSortings); override;
    procedure ShowRenameFileEdit(aFile: TFile); override;

    procedure AfterChangePath; override;

  public
    ActiveColm: String;
    ActiveColmSlave: TPanelColumnsClass;
    isSlave:boolean;
//---------------------

    constructor Create(AOwner: TWinControl; AFileSource: IFileSource; APath: String; AFlags: TFileViewFlags = []); override;
    constructor Create(AOwner: TWinControl; AFileView: TFileView; AFlags: TFileViewFlags = []); override;
    constructor Create(AOwner: TWinControl; AConfig: TIniFileEx; ASectionName: String; ATabIndex: Integer; AFlags: TFileViewFlags = []); override;
    constructor Create(AOwner: TWinControl; AConfig: TXmlConfig; ANode: TXmlNode; AFlags: TFileViewFlags = []); override;

    destructor Destroy; override;

    function Clone(NewParent: TWinControl): TColumnsFileView; override;
    procedure CloneTo(FileView: TFileView); override;

    procedure AddFileSource(aFileSource: IFileSource; aPath: String); override;

    procedure LoadConfiguration(Section: String; TabIndex: Integer); override;
    procedure LoadConfiguration(AConfig: TXmlConfig; ANode: TXmlNode); override;
    procedure SaveConfiguration(AConfig: TXmlConfig; ANode: TXmlNode); override;

    procedure UpdateColumnsView;

  end;

implementation

uses
  LCLProc, Clipbrd, uLng, uGlobs, uPixmapManager, uDebug,
  uDCUtils, math, fMain, fOptions,
  uOrderedFileView,
  uFileSourceProperty,
  fColumnsSetConf,
  uKeyboard,
  uFileFunctions,
  uFormCommands,
  fOptionsCustomColumns;

type
  TEachViewCallbackReason = (evcrUpdateColumns);
  TEachViewCallbackMsg = record
    Reason: TEachViewCallbackReason;
    UpdatedColumnsSetName: String;
    NewColumnsSetName: String; // If columns name renamed
  end;
  PEachViewCallbackMsg = ^TEachViewCallbackMsg;

procedure TColumnsFileView.SetSorting(const NewSortings: TFileSortings);
begin
  inherited SetSorting(NewSortings);
  SetColumnsSortDirections;
end;

procedure TColumnsFileView.LoadConfiguration(Section: String; TabIndex: Integer);
var
  ColumnsClass: TPanelColumnsClass;
  SortCount: Integer;
  SortColumn: Integer;
  SortDirection: TSortDirection;
  i: Integer;
  sIndex: String;
  NewSorting: TFileSortings = nil;
  Column: TPanelColumn;
  SortFunctions: TFileFunctions;
begin
  sIndex := IntToStr(TabIndex);

  ActiveColm := gIni.ReadString(Section, sIndex + '_columnsset', 'Default');

  // Load sorting options.
  ColumnsClass := GetColumnsClass;
  SortCount := gIni.ReadInteger(Section, sIndex + '_sortcount', 0);
  for i := 0 to SortCount - 1 do
  begin
    SortColumn := gIni.ReadInteger(Section, sIndex + '_sortcolumn' + IntToStr(i), -1);
    if (SortColumn >= 0) and (SortColumn < ColumnsClass.ColumnsCount) then
    begin
      Column := ColumnsClass.GetColumnItem(SortColumn);
      if Assigned(Column) then
      begin
        SortFunctions := Column.GetColumnFunctions;
        SortDirection := TSortDirection(gIni.ReadInteger(Section, sIndex + '_sortdirection' + IntToStr(i), Integer(sdNone)));
        AddSorting(NewSorting, SortFunctions, SortDirection);
      end;
    end;
  end;
  inherited SetSorting(NewSorting);
end;

procedure TColumnsFileView.LoadConfiguration(AConfig: TXmlConfig; ANode: TXmlNode);
var
  ColumnsClass: TPanelColumnsClass;
  SortColumn: Integer;
  SortDirection: TSortDirection;
  ColumnsViewNode: TXmlNode;
  NewSorting: TFileSortings = nil;
  Column: TPanelColumn;
  SortFunctions: TFileFunctions;
begin
  inherited LoadConfiguration(AConfig, ANode);

  // Try to read new view-specific node.
  ColumnsViewNode := AConfig.FindNode(ANode, 'ColumnsView');
  if Assigned(ColumnsViewNode) then
    ANode := ColumnsViewNode;

  ActiveColm := AConfig.GetValue(ANode, 'ColumnsSet', 'Default');

  // Load sorting options.
  ColumnsClass := GetColumnsClass;
  ANode := ANode.FindNode('Sorting');
  if Assigned(ANode) then
  begin
    ANode := ANode.FirstChild;
    while Assigned(ANode) do
    begin
      if ANode.CompareName('Sort') = 0 then
      begin
        if AConfig.TryGetValue(ANode, 'Column', SortColumn) and
           (SortColumn >= 0) and (SortColumn < ColumnsClass.ColumnsCount) then
        begin
          Column := ColumnsClass.GetColumnItem(SortColumn);
          if Assigned(Column) then
          begin
            SortFunctions := Column.GetColumnFunctions;
            SortDirection := TSortDirection(AConfig.GetValue(ANode, 'Direction', Integer(sdNone)));
            AddSorting(NewSorting, SortFunctions, SortDirection);
          end;
        end
        else
          DCDebug('Invalid entry in configuration: ' + AConfig.GetPathFromNode(ANode) + '.');
      end;
      ANode := ANode.NextSibling;
    end;
    inherited SetSorting(NewSorting);
  end;
end;

procedure TColumnsFileView.SaveConfiguration(AConfig: TXmlConfig; ANode: TXmlNode);
begin
  inherited SaveConfiguration(AConfig, ANode);

  AConfig.SetAttr(ANode, 'Type', 'columns');

  ANode := AConfig.FindNode(ANode, 'ColumnsView', True);
  AConfig.ClearNode(ANode);

  AConfig.SetValue(ANode, 'ColumnsSet', ActiveColm);
end;

procedure TColumnsFileView.dgPanelHeaderClick(Sender: TObject;
  IsColumn: Boolean; Index: Integer);
var
  ShiftState : TShiftState;
  SortingDirection : TSortDirection;
  ColumnsClass: TPanelColumnsClass;
  Column: TPanelColumn;
  NewSorting: TFileSortings;
  SortFunctions: TFileFunctions;
begin
  if not IsColumn then Exit;

  ColumnsClass := GetColumnsClass;
  Column := ColumnsClass.GetColumnItem(Index);
  if Assigned(Column) then
  begin
    NewSorting := Sorting;
    SortFunctions := Column.GetColumnFunctions;
    ShiftState := GetKeyShiftStateEx;
    if [ssShift, ssCtrl] * ShiftState = [] then
    begin
      SortingDirection := GetSortDirection(NewSorting, SortFunctions);
      if SortingDirection = sdNone then
        SortingDirection := sdAscending
      else
        SortingDirection := ReverseSortDirection(SortingDirection);
      NewSorting := nil;
    end
    else
    begin
      SortingDirection := sdAscending;
    end;

    AddOrUpdateSorting(NewSorting, SortFunctions, SortingDirection);
    SetSorting(NewSorting);
  end;
end;

procedure TColumnsFileView.dgPanelMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  I: Integer;
begin
  Handled:= True;
  if not IsLoadingFileList then
  begin
    case gScrollMode of
      smLineByLine:
        for I:= 1 to gWheelScrollLines do
          dgPanel.Perform(LM_VSCROLL, SB_LINEUP, 0);
      smPageByPage:
        dgPanel.Perform(LM_VSCROLL, SB_PAGEUP, 0);
      else
        Handled:= False;
    end;
  end;
end;

procedure TColumnsFileView.dgPanelMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  I: Integer;
begin
  Handled:= True;
  if not IsLoadingFileList then
  begin
    case gScrollMode of
      smLineByLine:
        for I:= 1 to gWheelScrollLines do
          dgPanel.Perform(LM_VSCROLL, SB_LINEDOWN, 0);
      smPageByPage:
        dgPanel.Perform(LM_VSCROLL, SB_PAGEDOWN, 0);
      else
        Handled:= False;
    end;
  end;
end;

procedure TColumnsFileView.dgPanelSelection(Sender: TObject; aCol, aRow: Integer);
begin
{$IF lcl_fullversion >= 093100}
  dgPanel.Options := dgPanel.Options - [goDontScrollPartCell];
{$ENDIF}
  DoFileIndexChanged(aRow - dgPanel.FixedRows);
end;

procedure TColumnsFileView.dgPanelTopLeftChanged(Sender: TObject);
begin
  Notify([fvnVisibleFilePropertiesChanged]);
end;

procedure TColumnsFileView.dgPanelResize(Sender: TObject);
begin
  Notify([fvnVisibleFilePropertiesChanged]);
end;

procedure TColumnsFileView.AfterChangePath;
begin
  inherited AfterChangePath;

  if not IsLoadingFileList then
  begin
    FUpdatingActiveFile := True;
    dgPanel.Row := 0;
    FUpdatingActiveFile := False;
  end;
end;

procedure TColumnsFileView.ShowRenameFileEdit(aFile: TFile);
var
  ALeft, ATop, AWidth, AHeight: Integer;
begin
  if FFileNameColumn <> -1 then
  begin
    if not edtRename.Visible then
    begin
      edtRename.Font.Name  := GetColumnsClass.GetColumnFontName(FFileNameColumn);
      edtRename.Font.Size  := GetColumnsClass.GetColumnFontSize(FFileNameColumn);
      edtRename.Font.Style := GetColumnsClass.GetColumnFontStyle(FFileNameColumn);

      ATop := dgPanel.CellRect(FFileNameColumn, dgPanel.Row).Top - 2;
      ALeft := dgPanel.CellRect(FFileNameColumn, dgPanel.Row).Left;
      if gShowIcons <> sim_none then
        Inc(ALeft, gIconsSize + 2);
      AWidth := dgPanel.ColWidths[FFileNameColumn] - ALeft;
      if Succ(FFileNameColumn) = FExtensionColumn then
        Inc(AWidth, dgPanel.ColWidths[FExtensionColumn]);
      AHeight := dgPanel.RowHeights[dgPanel.Row] + 4;

      edtRename.SetBounds(ALeft, ATop, AWidth, AHeight);
    end;

    inherited ShowRenameFileEdit(AFile);
  end;
end;

procedure TColumnsFileView.RedrawFile(FileIndex: PtrInt);
begin
  dgPanel.InvalidateRow(FileIndex + dgPanel.FixedRows);
end;

procedure TColumnsFileView.SetColumnsSortDirections;
var
  Columns: TPanelColumnsClass;

  function SetSortDirection(ASortFunction: TFileFunction; ASortDirection: TSortDirection; Overwrite: Boolean): Boolean;
  var
    k, l: Integer;
    ColumnFunctions: TFileFunctions;
  begin
    for k := 0 to Columns.Count - 1 do
    begin
      ColumnFunctions := Columns.GetColumnItem(k).GetColumnFunctions;
      for l := 0 to Length(ColumnFunctions) - 1 do
        if ColumnFunctions[l] = ASortFunction then
        begin
          if Overwrite or (FColumnsSortDirections[k] = sdNone) then
          begin
            FColumnsSortDirections[k] := ASortDirection;
            Exit(True);
          end;
        end;
    end;
    Result := False;
  end;

var
  i, j: Integer;
  ASortings: TFileSortings;
begin
  Columns := GetColumnsClass;
  ASortings := Sorting;

  SetLength(FColumnsSortDirections, Columns.Count);
  for i := 0 to Length(FColumnsSortDirections) - 1 do
    FColumnsSortDirections[i] := sdNone;

  for i := 0 to Length(ASortings) - 1 do
  begin
    for j := 0 to Length(ASortings[i].SortFunctions) - 1 do
    begin
      // Search for the column containing the sort function and add sorting
      // by that column. If function is Name and it is not found try searching
      // for NameNoExtension + Extension and vice-versa.
      if not SetSortDirection(ASortings[i].SortFunctions[j], ASortings[i].SortDirection, True) then
      begin
        if ASortings[i].SortFunctions[j] = fsfName then
        begin
          SetSortDirection(fsfNameNoExtension, ASortings[i].SortDirection, False);
          SetSortDirection(fsfExtension, ASortings[i].SortDirection, False);
        end
        else if ASortings[i].SortFunctions[j] in [fsfNameNoExtension, fsfExtension] then
        begin
          SetSortDirection(fsfName, ASortings[i].SortDirection, False);
        end;
      end;
    end;
  end;
end;

procedure TColumnsFileView.SetFilesDisplayItems;
var
  i: Integer;
begin
  for i := 0 to FFiles.Count - 1 do
    FFiles[i].DisplayItem := Pointer(i + dgPanel.FixedRows);
end;

function TColumnsFileView.GetFilePropertiesNeeded: TFilePropertiesTypes;
var
  i, j: Integer;
  ColumnsClass: TPanelColumnsClass;
  Column: TPanelColumn;
  FileFunctionsUsed: TFileFunctions;
begin
  // By default always use some properties.
  Result := [fpName,
             fpSize,              // For info panel (total size, selected size)
             fpAttributes,        // For distinguishing directories
             fpLink,              // For distinguishing directories (link to dir) and link icons
             fpModificationTime   // For selecting/coloring files (by SearchTemplate)
            ];

  ColumnsClass := GetColumnsClass;
  FFileNameColumn := -1;
  FExtensionColumn := -1;

  // Scan through all columns.
  for i := 0 to ColumnsClass.Count - 1 do
  begin
    Column := ColumnsClass.GetColumnItem(i);
    FileFunctionsUsed := Column.GetColumnFunctions;
    if Length(FileFunctionsUsed) > 0 then
    begin
      // Scan through all functions in the column.
      for j := Low(FileFunctionsUsed) to High(FileFunctionsUsed) do
      begin
        // Add file properties needed to display the function.
        Result := Result + TFileFunctionToProperty[FileFunctionsUsed[j]];
        if (FFileNameColumn = -1) and (FileFunctionsUsed[j] in [fsfName, fsfNameNoExtension]) then
          FFileNameColumn := i;
        if (FExtensionColumn = -1) and (FileFunctionsUsed[j] in [fsfExtension]) then
          FExtensionColumn := i;
      end;
    end;
  end;
end;

function TColumnsFileView.GetFileRect(FileIndex: PtrInt): TRect;
begin
  Result := dgPanel.CellRect(0, FileIndex + dgPanel.FixedRows);
end;

procedure TColumnsFileView.SetRowCount(Count: Integer);
begin
  FUpdatingActiveFile := True;
  dgPanel.RowCount := dgPanel.FixedRows + Count;
  FUpdatingActiveFile := False;
end;

procedure TColumnsFileView.SetColumns;
var
  x: Integer;
  ColumnsClass: TPanelColumnsClass;
begin
  ColumnsClass := GetColumnsClass;

  dgPanel.Columns.BeginUpdate;
  try
    dgPanel.Columns.Clear;
    for x:= 0 to ColumnsClass.ColumnsCount - 1 do
    begin
      with dgPanel.Columns.Add do
      begin
        // SizePriority = 0 means don't modify Width with AutoFill.
        // Last column is always modified if all columns have SizePriority = 0.
        if (x = 0) and (gAutoSizeColumn = 0) then
          SizePriority := 1
        else
          SizePriority := 0;
        Width:= ColumnsClass.GetColumnWidth(x);
        Title.Caption:= ColumnsClass.GetColumnTitle(x);
      end;
    end;
  finally
    dgPanel.Columns.EndUpdate;
  end;
end;

procedure TColumnsFileView.MakeVisible(iRow:Integer);
var
  AVisibleRows: TRange;
begin
  with dgPanel do
  begin
    AVisibleRows := GetFullVisibleRows;
    if iRow < AVisibleRows.First then
      TopRow := AVisibleRows.First;
    if iRow > AVisibleRows.Last then
      TopRow := iRow - (AVisibleRows.Last - AVisibleRows.First);
  end;
end;

procedure TColumnsFileView.MakeActiveVisible;
begin
  if dgPanel.Row>=0 then
    MakeVisible(dgPanel.Row);
end;

procedure TColumnsFileView.SetActiveFile(FileIndex: PtrInt);
begin
  dgPanel.Row := FileIndex + dgPanel.FixedRows;
  MakeVisible(dgPanel.Row);
end;

{$IF lcl_fullversion >= 093100}
procedure TColumnsFileView.dgPanelBeforeSelection(Sender: TObject; aCol, aRow: Integer);
begin
  if dgPanel.IsRowVisible(aRow) then
    dgPanel.Options := dgPanel.Options + [goDontScrollPartCell];
end;
{$ENDIF}

procedure TColumnsFileView.RedrawFile(DisplayFile: TDisplayFile);
begin
  dgPanel.InvalidateRow(PtrInt(DisplayFile.DisplayItem));
end;

procedure TColumnsFileView.RedrawFiles;
begin
  dgPanel.Invalidate;
end;

procedure TColumnsFileView.UpdateColumnsView;
var
  ColumnsClass: TPanelColumnsClass;
  OldFilePropertiesNeeded: TFilePropertiesTypes;
begin
  ClearAllColumnsStrings;

  // If the ActiveColm set doesn't exist this will retrieve either
  // the first set or the default set.
  ColumnsClass := GetColumnsClass;
  // Set name in case a different set was loaded.
  ActiveColm := ColumnsClass.Name;

  SetColumns;
  SetColumnsSortDirections;

  dgPanel.FocusRectVisible := ColumnsClass.GetCursorBorder and not gUseFrameCursor;
  dgPanel.FocusColor := ColumnsClass.GetCursorBorderColor;
  dgPanel.UpdateView;

  OldFilePropertiesNeeded := FilePropertiesNeeded;
  FilePropertiesNeeded := GetFilePropertiesNeeded;
  if FilePropertiesNeeded >= OldFilePropertiesNeeded then
  begin
    Notify([fvnVisibleFilePropertiesChanged]);
  end;
end;

procedure TColumnsFileView.ColumnsMenuClick(Sender: TObject);
var
  frmColumnsSetConf: TfColumnsSetConf;
  Index: Integer;
  Msg: TEachViewCallbackMsg;
begin
  Case (Sender as TMenuItem).Tag of
    1000: //This
          begin
            frmColumnsSetConf := TfColumnsSetConf.Create(nil);
            try
              Msg.Reason := evcrUpdateColumns;
              Msg.UpdatedColumnsSetName := ActiveColm;

              {EDIT Set}
              frmColumnsSetConf.edtNameofColumnsSet.Text:=ColSet.GetColumnSet(ActiveColm).CurrentColumnsSetName;
              Index:=ColSet.Items.IndexOf(ActiveColm);
              frmColumnsSetConf.lbNrOfColumnsSet.Caption:=IntToStr(1 + Index);
              frmColumnsSetConf.Tag:=Index;
              frmColumnsSetConf.SetColumnsClass(GetColumnsClass);
              {EDIT Set}
              if frmColumnsSetConf.ShowModal = mrOK then
              begin
                // Force saving changes to config file.
                SaveGlobs;
                Msg.NewColumnsSetName := frmColumnsSetConf.GetColumnsClass.Name;
                frmMain.ForEachView(@EachViewUpdateColumns, @Msg);
              end;
            finally
              FreeAndNil(frmColumnsSetConf);
            end;
          end;
    1001: //All columns
          begin
            ShowOptions(TfrmOptionsCustomColumns);
          end;
  else
    begin
      ActiveColm:=ColSet.Items[(Sender as TMenuItem).Tag];
      UpdateColumnsView;
      RedrawFiles;
    end;
  end;
end;

constructor TColumnsFileView.Create(AOwner: TWinControl; AFileSource: IFileSource; APath: String; AFlags: TFileViewFlags = []);
begin
  ActiveColm := 'Default';
  inherited Create(AOwner, AFileSource, APath, AFlags);
end;

constructor TColumnsFileView.Create(AOwner: TWinControl; AFileView: TFileView; AFlags: TFileViewFlags = []);
begin
  inherited Create(AOwner, AFileView, AFlags);
end;

constructor TColumnsFileView.Create(AOwner: TWinControl; AConfig: TIniFileEx; ASectionName: String; ATabIndex: Integer; AFlags: TFileViewFlags = []);
begin
  inherited Create(AOwner, AConfig, ASectionName, ATabIndex, AFlags);
end;

constructor TColumnsFileView.Create(AOwner: TWinControl; AConfig: TXmlConfig; ANode: TXmlNode; AFlags: TFileViewFlags = []);
begin
  inherited Create(AOwner, AConfig, ANode, AFlags);
end;

procedure TColumnsFileView.CreateDefault(AOwner: TWinControl);
begin
  DCDebug('TColumnsFileView.Create components');

  inherited CreateDefault(AOwner);

  FFileNameColumn := -1;
  FExtensionColumn := -1;

  // -- other components

  dgPanel:=TDrawGridEx.Create(Self, Self);
  MainControl := dgPanel;

  // ---
  dgPanel.OnHeaderClick:=@dgPanelHeaderClick;
  dgPanel.OnMouseWheelUp := @dgPanelMouseWheelUp;
  dgPanel.OnMouseWheelDown := @dgPanelMouseWheelDown;
  dgPanel.OnSelection:= @dgPanelSelection;
{$IF lcl_fullversion >= 093100}
  dgPanel.OnBeforeSelection:= @dgPanelBeforeSelection;
{$ENDIF}
  dgPanel.OnTopLeftChanged:= @dgPanelTopLeftChanged;
  dgpanel.OnResize:= @dgPanelResize;

  pmColumnsMenu := TPopupMenu.Create(Self);
  pmColumnsMenu.Parent := Self;
end;

destructor TColumnsFileView.Destroy;
begin
  inherited Destroy;
end;

function TColumnsFileView.Clone(NewParent: TWinControl): TColumnsFileView;
begin
  Result := TColumnsFileView.Create(NewParent, Self);
end;

procedure TColumnsFileView.CloneTo(FileView: TFileView);
begin
  if Assigned(FileView) then
  begin
    inherited CloneTo(FileView);

    if FileView is TColumnsFileView then
    with FileView as TColumnsFileView do
    begin
      FColumnsSortDirections := Self.FColumnsSortDirections;

      ActiveColm := Self.ActiveColm;
      ActiveColmSlave := nil;    // set to nil because only used in preview?
      isSlave := Self.isSlave;
    end;
  end;
end;

procedure TColumnsFileView.AddFileSource(aFileSource: IFileSource; aPath: String);
begin
  inherited AddFileSource(aFileSource, aPath);

  if not IsLoadingFileList then
  begin
    FUpdatingActiveFile := True;
    dgPanel.Row := 0;
    FUpdatingActiveFile := False;
  end;
end;

procedure TColumnsFileView.BeforeMakeFileList;
begin
  inherited;
  if gListFilesInThread then
  begin
    // Display info that file list is being loaded.
    UpdateInfoPanel;
  end;
end;

procedure TColumnsFileView.ClearAfterDragDrop;
begin
  inherited ClearAfterDragDrop;

  // reset TCustomGrid state
  dgPanel.FGridState := gsNormal;
end;

procedure TColumnsFileView.FileSourceFileListLoaded;
begin
  inherited;

  FUpdatingActiveFile := True;
  dgPanel.Row := 0;
  FUpdatingActiveFile := False;
end;

procedure TColumnsFileView.DisplayFileListChanged;
begin
  // Update grid row count.
  SetRowCount(FFiles.Count);
  SetFilesDisplayItems;
  RedrawFiles;

  if SetActiveFileNow(RequestedActiveFile) then
    RequestedActiveFile := ''
  // Requested file was not found, restore position to last active file.
  else if not SetActiveFileNow(LastActiveFile) then
  // Make sure at least that the previously active file is still visible after displaying file list.
    MakeActiveVisible;

  Notify([fvnVisibleFilePropertiesChanged]);

  inherited;
end;

procedure TColumnsFileView.MakeColumnsStrings(AFile: TDisplayFile);
begin
  MakeColumnsStrings(AFile, GetColumnsClass);
end;

procedure TColumnsFileView.MakeColumnsStrings(AFile: TDisplayFile; ColumnsClass: TPanelColumnsClass);
var
  ACol: Integer;
begin
  AFile.DisplayStrings.Clear;
  for ACol := 0 to ColumnsClass.Count - 1 do
  begin
    AFile.DisplayStrings.Add(ColumnsClass.GetColumnItemResultString(
      ACol, AFile.FSFile, FileSource));
  end;
end;

procedure TColumnsFileView.ClearAllColumnsStrings;
var
  i: Integer;
begin
  if Assigned(FAllDisplayFiles) then
  begin
    // Clear display strings in case columns have changed.
    for i := 0 to FAllDisplayFiles.Count - 1 do
      FAllDisplayFiles[i].DisplayStrings.Clear;
  end;
end;

procedure TColumnsFileView.EachViewUpdateColumns(AFileView: TFileView; UserData: Pointer);
var
  ColumnsView: TColumnsFileView;
  PMsg: PEachViewCallbackMsg;
begin
  if AFileView is TColumnsFileView then
  begin
    ColumnsView := TColumnsFileView(AFileView);
    PMsg := UserData;
    if ColumnsView.ActiveColm = PMsg^.UpdatedColumnsSetName then
    begin
      ColumnsView.ActiveColm := PMsg^.NewColumnsSetName;
      ColumnsView.UpdateColumnsView;
      ColumnsView.RedrawFiles;
    end;
  end;
end;

procedure TColumnsFileView.DoUpdateView;
begin
  inherited DoUpdateView;
  UpdateColumnsView;
end;

function TColumnsFileView.GetActiveFileIndex: PtrInt;
begin
  Result := dgPanel.Row - dgPanel.FixedRows;
end;

function TColumnsFileView.GetVisibleFilesIndexes: TRange;
begin
  Result := dgPanel.GetVisibleRows;
  Dec(Result.First, dgPanel.FixedRows);
  Dec(Result.Last, dgPanel.FixedRows);
end;

function TColumnsFileView.GetColumnsClass: TPanelColumnsClass;
begin
  if isSlave then
    Result := ActiveColmSlave
  else
    Result := ColSet.GetColumnSet(ActiveColm);
end;

function TColumnsFileView.GetFileIndexFromCursor(X, Y: Integer; out AtFileList: Boolean): PtrInt;
var
  bTemp: Boolean;
  iRow, iCol: LongInt;
begin
  with dgPanel do
  begin
    bTemp:= AllowOutboundEvents;
    AllowOutboundEvents:= False;
    MouseToCell(X, Y, iCol, iRow);
    AllowOutboundEvents:= bTemp;
    Result:= IfThen(iRow < 0, InvalidFileIndex, iRow - FixedRows);
    AtFileList := Y >= GetHeaderHeight;
  end;
end;

procedure TColumnsFileView.DoFileUpdated(AFile: TDisplayFile; UpdatedProperties: TFilePropertiesTypes);
begin
  MakeColumnsStrings(AFile);
  inherited DoFileUpdated(AFile, UpdatedProperties);
end;

procedure TColumnsFileView.DoHandleKeyDown(var Key: Word; Shift: TShiftState);
var
  AFile: TDisplayFile;
begin
  case Key of
    VK_INSERT:
      begin
        if not IsEmpty then
        begin
          if IsActiveItemValid then
          begin
            InvertFileSelection(GetActiveDisplayFile, False);
            DoSelectionChanged(dgPanel.Row - dgPanel.FixedRows);
          end;
          if dgPanel.Row < dgPanel.RowCount-1 then
            dgPanel.Row := dgPanel.Row + 1;
          MakeActiveVisible;
        end;
        Key := 0;
      end;

    // cursors keys in Lynx like mode
    VK_LEFT:
      if (Shift = []) then
      begin
        if gLynxLike then
          ChangePathToParent(True)
        else
          dgPanel.ScrollHorizontally(False);
        Key := 0;
      end;

    VK_RIGHT:
      if (Shift = []) then
      begin
        if gLynxLike then
          ChooseFile(GetActiveDisplayFile, True)
        else
          dgPanel.ScrollHorizontally(True);
        Key := 0;
      end;

    VK_SPACE:
      if Shift * KeyModifiersShortcut = [] then
      begin
        aFile := GetActiveDisplayFile;
        if IsItemValid(aFile) then
        begin
          if (aFile.FSFile.IsDirectory or
             aFile.FSFile.IsLinkToDirectory) and
             not aFile.Selected then
          begin
            CalculateSpace(aFile);
          end;

          InvertFileSelection(aFile, False);
        end;

        if gSpaceMovesDown then
          dgPanel.Row := dgPanel.Row + 1;

        MakeActiveVisible;
        DoSelectionChanged(dgPanel.Row - dgPanel.FixedRows);
        Key := 0;
      end;
  end;

  inherited DoHandleKeyDown(Key, Shift);
end;

procedure TColumnsFileView.DoMainControlShowHint(FileIndex: PtrInt; X, Y: Integer);
var
  aRect: TRect;
  iCol: Integer;
  AFile: TDisplayFile;
begin
  AFile := FFiles[FileIndex];
  aRect:= dgPanel.CellRect(0, FileIndex + dgPanel.FixedRows);
  iCol:= aRect.Right - aRect.Left - 8;
  if gShowIcons <> sim_none then
    Dec(iCol, gIconsSize);
  if iCol < dgPanel.Canvas.TextWidth(AFile.FSFile.Name) then // with file name
    dgPanel.Hint:= AFile.FSFile.Name
  else if (stm_only_large_name in gShowToolTipMode) then // don't show
    Exit
  else if not AFile.FSFile.IsDirectory then // without name
    dgPanel.Hint:= #32;
end;

{ TDrawGridEx }

constructor TDrawGridEx.Create(AOwner: TComponent; AParent: TWinControl);
begin
  inherited Create(AOwner);

  ColumnsView := AParent as TColumnsFileView;

  // Workaround for Lazarus issue 18832.
  // Set Fixed... before setting ...Count.
  FixedRows := 0;
  FixedCols := 0;

  // Override default values to start with no columns and no rows.
  RowCount := 0;
  ColCount := 0;

  DoubleBuffered := True;
  Align := alClient;
  Options := [goFixedVertLine, goFixedHorzLine, goTabs, goRowSelect,
              goColSizing, goThumbTracking, goSmoothScroll];

  TitleStyle := tsStandard;
  TabStop := False;

  Self.Parent := AParent;
  UpdateView;
end;

procedure TDrawGridEx.UpdateView;

  function CalculateDefaultRowHeight: Integer;
  var
    OldFont, NewFont: TFont;
    i: Integer;
    MaxFontHeight: Integer = 0;
    CurrentHeight: Integer;
    ColumnsSet: TPanelColumnsClass;
  begin
    // Start with height of the icons.
    if gShowIcons <> sim_none then
      MaxFontHeight := gIconsSize;

    // Get columns settings.
    with (Parent as TColumnsFileView) do
    begin
      if not isSlave then
        ColumnsSet := ColSet.GetColumnSet(ActiveColm)
      else
        ColumnsSet := ActiveColmSlave;
    end;

    // Assign temporary font.
    OldFont     := Canvas.Font;
    NewFont     := TFont.Create;
    Canvas.Font := NewFont;

    // Search columns settings for the biggest font (in height).
    for i := 0 to ColumnsSet.Count - 1 do
    begin
      Canvas.Font.Name  := ColumnsSet.GetColumnFontName(i);
      Canvas.Font.Style := ColumnsSet.GetColumnFontStyle(i);
      Canvas.Font.Size  := ColumnsSet.GetColumnFontSize(i);

      CurrentHeight := Canvas.GetTextHeight('Wg');
      MaxFontHeight := Max(MaxFontHeight, CurrentHeight);
    end;

    // Restore old font.
    Canvas.Font := OldFont;
    FreeAndNil(NewFont);

    Result := MaxFontHeight;
  end;

  function CalculateTabHeaderHeight: Integer;
  var
    OldFont: TFont;
  begin
    OldFont     := Canvas.Font;
    Canvas.Font := Font;
    SetCanvasFont(GetColumnFont(0, True));
    Result      := Canvas.TextHeight('Wg');
    Canvas.Font := OldFont;
  end;

var
  TabHeaderHeight: Integer;
  TempRowHeight: Integer;
begin
  Flat := gInterfaceFlat;
  AutoFillColumns:= gAutoFillColumns;
  GridVertLine:= gGridVertLine;
  GridHorzLine:= gGridHorzLine;

  // Calculate row height.
  TempRowHeight := CalculateDefaultRowHeight;
  if TempRowHeight > 0 then
    DefaultRowHeight := TempRowHeight;

  // Set rows of header.
  if gTabHeader then
  begin
    if RowCount < 1 then
      RowCount := 1;

    FixedRows := 1;

    TabHeaderHeight := Max(gIconsSize, CalculateTabHeaderHeight);
    TabHeaderHeight := TabHeaderHeight + 2; // for borders
    if not gInterfaceFlat then
    begin
      TabHeaderHeight := TabHeaderHeight + 2; // additional borders if not flat
    end;
    RowHeights[0] := TabHeaderHeight;
  end
  else
  begin
    if FixedRows > 0 then
    begin
      // First reduce number of rows so that the 0'th row, which will be changed
      // to not-fixed, won't be counted as a row having a file.
      if RowCount > 0 then
        RowCount := RowCount - 1;
      FixedRows := 0;
    end;
  end;

  FixedCols := 0;
  // Set column number to zero, must be called after fixed columns change
  MoveExtend(False, 0, Row);
end;

procedure TDrawGridEx.InitializeWnd;
begin
  inherited InitializeWnd;
  ColumnsView.InitializeDragDropEx(Self);
end;

procedure TDrawGridEx.FinalizeWnd;
begin
  ColumnsView.FinalizeDragDropEx(Self);
  inherited FinalizeWnd;
end;

function TDrawGridEx.GetFullVisibleRows: TRange;
begin
  Result.First := GCache.FullVisibleGrid.Top;
  Result.Last  := GCache.FullVisibleGrid.Bottom;
end;

procedure TDrawGridEx.DrawCell(aCol, aRow: Integer; aRect: TRect;
              aState: TGridDrawState);
var
  //shared variables
  s:   string;
  iTextTop: Integer;
  AFile: TDisplayFile;
  FileSourceDirectAccess: Boolean;
  ColumnsSet: TPanelColumnsClass;

  //------------------------------------------------------
  //begin subprocedures
  //------------------------------------------------------

  procedure DrawFixed;
  //------------------------------------------------------
  var
    SortingDirection: TSortDirection;
    TitleX: Integer;
  begin
    // Draw background.
    Canvas.Brush.Color := GetColumnColor(ACol, True);
    Canvas.FillRect(aRect);

    SetCanvasFont(GetColumnFont(aCol, True));

    iTextTop := aRect.Top + (RowHeights[aRow] - Canvas.TextHeight('Wg')) div 2;

    TitleX := 0;
    s      := ColumnsSet.GetColumnTitle(ACol);

    SortingDirection := ColumnsView.FColumnsSortDirections[ACol];
    if SortingDirection <> sdNone then
    begin
      TitleX := TitleX + gIconsSize;
      PixMapManager.DrawBitmap(
          PixMapManager.GetIconBySortingDirection(SortingDirection),
          Canvas,
          aRect.Left, aRect.Top + (RowHeights[aRow] - gIconsSize) div 2);
    end;

    TitleX := max(TitleX, 4);

    if gCutTextToColWidth then
    begin
      if (aRect.Right - aRect.Left) < TitleX then
        // Column too small to display text.
        Exit
      else
        while Canvas.TextWidth(s) - ((aRect.Right - aRect.Left) - TitleX) > 0 do
          UTF8Delete(s, UTF8Length(s), 1);
    end;

    Canvas.TextOut(aRect.Left + TitleX, iTextTop, s);
  end; // of DrawHeader
  //------------------------------------------------------


  procedure DrawIconCell;
  //------------------------------------------------------
  var
    Y: Integer;
    IconID: PtrInt;
  begin
    if (gShowIcons <> sim_none) then
    begin
      IconID := AFile.IconID;
      // Draw default icon if there is no icon for the file.
      if IconID = -1 then
        IconID := PixMapManager.GetDefaultIcon(AFile.FSFile);

      // center icon vertically
      Y:= aRect.Top + (RowHeights[ARow] - gIconsSize) div 2;

      // Draw icon for a file
      PixMapManager.DrawBitmap(IconID,
                               Canvas,
                               aRect.Left + 1,
                               Y
                               );

      // Draw overlay icon for a file if needed
      if gIconOverlays then
      begin
        PixMapManager.DrawBitmapOverlay(AFile,
                                        FileSourceDirectAccess,
                                        Canvas,
                                        aRect.Left + 1,
                                        Y
                                        );
      end;

    end;

    if AFile.DisplayStrings.Count = 0 then
      ColumnsView.MakeColumnsStrings(AFile, ColumnsSet);
    s := AFile.DisplayStrings.Strings[ACol];

    if gCutTextToColWidth then
    begin
      Y:= ((aRect.Right - aRect.Left) - 4 - Canvas.TextWidth('W'));
      if (gShowIcons <> sim_none) then Y:= Y - gIconsSize;
      if Canvas.TextWidth(s) - Y > 0 then
      begin
        repeat
          IconID:= UTF8Length(s);
          UTF8Delete(s, IconID, 1);
        until (Canvas.TextWidth(s) - Y < 1) or (IconID = 0);
        if (IconID > 0) then
        begin
          s:= UTF8Copy(s, 1, IconID - 3);
          if gDirBrackets and (AFile.FSFile.IsDirectory or AFile.FSFile.IsLinkToDirectory) then
            s:= s + '..]'
          else
            s:= s + '...';
        end;
      end;
    end;

    if (gShowIcons <> sim_none) then
      Canvas.TextOut(aRect.Left + gIconsSize + 4, iTextTop, s)
    else
      Canvas.TextOut(aRect.Left + 2, iTextTop, s);
  end; //of DrawIconCell
  //------------------------------------------------------

  procedure DrawOtherCell;
  //------------------------------------------------------
  var
    tw, cw: Integer;
  begin
    if AFile.DisplayStrings.Count = 0 then
      ColumnsView.MakeColumnsStrings(AFile, ColumnsSet);
    s := AFile.DisplayStrings.Strings[ACol];

    if gCutTextToColWidth then
    begin
      while Canvas.TextWidth(s) - (aRect.Right - aRect.Left) - 4 > 0 do
        Delete(s, Length(s), 1);
    end;

    case ColumnsSet.GetColumnAlign(ACol) of

      taRightJustify:
        begin
          cw := ColWidths[ACol];
          tw := Canvas.TextWidth(s);
          Canvas.TextOut(aRect.Left + cw - tw - 3, iTextTop, s);
        end;

      taLeftJustify:
        begin
          Canvas.TextOut(aRect.Left + 3, iTextTop, s);
        end;

      taCenter:
        begin
          cw := ColWidths[ACol];
          tw := Canvas.TextWidth(s);
          Canvas.TextOut(aRect.Left + ((cw - tw - 3) div 2), iTextTop, s);
        end;

    end; //of case
  end; //of DrawOtherCell
  //------------------------------------------------------

  procedure PrepareColors;
  //------------------------------------------------------
  var
    TextColor: TColor = clDefault;
    BackgroundColor: TColor;
    IsCursor: Boolean;
  //---------------------
  begin
    Canvas.Font.Name   := ColumnsSet.GetColumnFontName(ACol);
    Canvas.Font.Size   := ColumnsSet.GetColumnFontSize(ACol);
    Canvas.Font.Style  := ColumnsSet.GetColumnFontStyle(ACol);

    IsCursor := (gdSelected in aState) and ColumnsView.Active and (not gUseFrameCursor);
    // Set up default background color first.
    if IsCursor then
      BackgroundColor := ColumnsSet.GetColumnCursorColor(ACol)
    else
      begin
        // Alternate rows background color.
        if odd(ARow) then
          BackgroundColor := ColumnsSet.GetColumnBackground(ACol)
        else
          BackgroundColor := ColumnsSet.GetColumnBackground2(ACol);
      end;

    // Set text color.
    if ColumnsSet.GetColumnOvercolor(ACol) then
      TextColor := AFile.TextColor;
    if (TextColor = clDefault) or (TextColor = clNone) then
      TextColor := ColumnsSet.GetColumnTextColor(ACol);

    if AFile.Selected then
    begin
      if gUseInvertedSelection then
        begin
          //------------------------------------------------------
          if IsCursor then
            begin
              TextColor := InvertColor(ColumnsSet.GetColumnCursorText(ACol));
            end
          else
            begin
              BackgroundColor := ColumnsSet.GetColumnMarkColor(ACol);
              TextColor := ColumnsSet.GetColumnBackground(ACol);
            end;
          //------------------------------------------------------
        end
      else
        begin
          TextColor := ColumnsSet.GetColumnMarkColor(ACol);
        end;
    end
    else if IsCursor then
      begin
        TextColor := ColumnsSet.GetColumnCursorText(ACol);
      end;

    BackgroundColor := ColumnsView.DimColor(BackgroundColor);

    if AFile.RecentlyUpdatedPct <> 0 then
    begin
      TextColor := LightColor(TextColor, AFile.RecentlyUpdatedPct);
      BackgroundColor := LightColor(BackgroundColor, AFile.RecentlyUpdatedPct);
    end;

    // Draw background.
    Canvas.Brush.Color := BackgroundColor;
    Canvas.FillRect(aRect);
    Canvas.Font.Color := TextColor;
  end;// of PrepareColors;

  procedure DrawLines;
  begin
    // Draw frame cursor.
    if gUseFrameCursor and (gdSelected in aState) and ColumnsView.Active then
    begin
      Canvas.Pen.Color := ColumnsSet.GetColumnCursorColor(ACol);
      Canvas.Line(aRect.Left, aRect.Top, aRect.Right, aRect.Top);
      Canvas.Line(aRect.Left, aRect.Bottom - 1, aRect.Right, aRect.Bottom - 1);
    end;

    // Draw drop selection.
    if ARow - FixedRows = ColumnsView.FDropFileIndex then
    begin
      Canvas.Pen.Color := ColumnsSet.GetColumnTextColor(ACol);
      Canvas.Line(aRect.Left, aRect.Top, aRect.Right, aRect.Top);
      Canvas.Line(aRect.Left, aRect.Bottom - 1, aRect.Right, aRect.Bottom - 1);
    end;
  end;
  //------------------------------------------------------
  //end of subprocedures
  //------------------------------------------------------

begin
  ColumnsSet := ColumnsView.GetColumnsClass;

  if gdFixed in aState then
  begin
    DrawFixed;  // Draw column headers
    DrawCellGrid(aCol,aRow,aRect,aState);
  end
  else if ColumnsView.FFiles.Count > 0 then
  begin
    AFile := ColumnsView.FFiles[ARow - FixedRows]; // substract fixed rows (header)
    FileSourceDirectAccess := fspDirectAccess in ColumnsView.FileSource.Properties;

    PrepareColors;

    iTextTop := aRect.Top + (RowHeights[aRow] - Canvas.TextHeight('Wg')) div 2;

    if ACol = 0 then
      DrawIconCell  // Draw icon in the first column
    else
      DrawOtherCell;

    DrawCellGrid(aCol,aRow,aRect,aState);
    DrawLines;
  end
  else
  begin
    Canvas.Brush.Color := Self.Color;
    Canvas.FillRect(aRect);
  end;
end;

procedure TDrawGridEx.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  I : Integer;
  Point: TPoint;
  MI: TMenuItem;
  Background: Boolean;
begin
  if ColumnsView.IsLoadingFileList then Exit;
{$IFDEF LCLGTK2}
  // Workaround for two doubleclicks being sent on GTK.
  // MouseUp event is sent just after doubleclick, so if we drop
  // doubleclick events we have to also drop MouseUp events that follow them.
  if ColumnsView.TooManyDoubleClicks then Exit;
{$ENDIF}

  // Handle only if button-up was not lifted to finish drag&drop operation.
  if not ColumnsView.FMainControlMouseDown then
    Exit;

  inherited MouseUp(Button, Shift, X, Y);

  ColumnsView.FMainControlMouseDown := False;

  if Button = mbRight then
    begin
      { If right click on header }
      if (Y < GetHeaderHeight) then
        begin
          //Load Columns into menu
          ColumnsView.pmColumnsMenu.Items.Clear;
          if ColSet.Items.Count>0 then
            begin
              For I:=0 to ColSet.Items.Count-1 do
                begin
                  MI:=TMenuItem.Create(ColumnsView.pmColumnsMenu);
                  MI.Tag:=I;
                  MI.Caption:=ColSet.Items[I];
                  MI.OnClick:=@ColumnsView.ColumnsMenuClick;
                  ColumnsView.pmColumnsMenu.Items.Add(MI);
                end;
            end;
          //-
          MI:=TMenuItem.Create(ColumnsView.pmColumnsMenu);
          MI.Caption:='-';
          ColumnsView.pmColumnsMenu.Items.Add(MI);
          //Configure this custom columns
          MI:=TMenuItem.Create(ColumnsView.pmColumnsMenu);
          MI.Tag:=1000;
          MI.Caption:=rsMenuConfigureThisCustomColumn;
          MI.OnClick:=@ColumnsView.ColumnsMenuClick;
          ColumnsView.pmColumnsMenu.Items.Add(MI);
          //Configure custom columns
          MI:=TMenuItem.Create(ColumnsView.pmColumnsMenu);
          MI.Tag:=1001;
          MI.Caption:=rsMenuConfigureCustomColumns;
          MI.OnClick:=@ColumnsView.ColumnsMenuClick;
          ColumnsView.pmColumnsMenu.Items.Add(MI);

          Point:=ClientToScreen(Classes.Point(0,0));
          Point.Y:=Point.Y+GetHeaderHeight;
          Point.X:=Point.X+X-50;
          ColumnsView.pmColumnsMenu.PopUp(Point.X,Point.Y);
        end

      { If right click on file/directory }
      else if ((gMouseSelectionButton<>1) or not gMouseSelectionEnabled) then
        begin
          Background:= not MouseOnGrid(X, Y);
          Point := ClientToScreen(Classes.Point(X, Y));
          frmMain.Commands.DoContextMenu(ColumnsView, Point.x, Point.y, Background);
        end
      else if (gMouseSelectionEnabled and (gMouseSelectionButton = 1)) then
        begin
          ColumnsView.tmContextMenu.Enabled:= False; // stop context menu timer
        end;
    end
  { Open folder in new tab on middle click }
  else if (Button = mbMiddle) and (Y > GetHeaderHeight) then
    begin
      frmMain.Commands.cm_OpenDirInNewTab([]);
    end;
end;

procedure TDrawGridEx.MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
begin
  if ColumnsView.IsLoadingFileList then Exit;
{$IFDEF LCLGTK2}
  // Workaround for two doubleclicks being sent on GTK.
  // MouseDown event is sent just before doubleclick, so if we drop
  // doubleclick events we have to also drop MouseDown events that precede them.
  if ColumnsView.TooManyDoubleClicks then Exit;
{$ENDIF}

  ColumnsView.FMainControlMouseDown := True;

  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TDrawGridEx.MouseMove(Shift: TShiftState; X, Y: Integer);
  procedure Scroll(ScrollCode: SmallInt);
  var
    Msg: TLMVScroll;
  begin
    Msg.Msg := LM_VSCROLL;
    Msg.ScrollCode := ScrollCode;
    Msg.SmallPos := 1; // How many lines scroll
    Msg.ScrollBar := Handle;
    Dispatch(Msg);
  end;
begin
  inherited MouseMove(Shift, X, Y);
  if DragManager.IsDragging or ColumnsView.IsMouseSelecting then
  begin
    if Y < DefaultRowHeight then
      Scroll(SB_LINEUP)
    else if Y > ClientHeight - DefaultRowHeight then
      Scroll(SB_LINEDOWN);
  end;
end;

function TDrawGridEx.MouseOnGrid(X, Y: LongInt): Boolean;
var
  bTemp: Boolean;
  iRow, iCol: LongInt;
begin
  bTemp:= AllowOutboundEvents;
  AllowOutboundEvents:= False;
  MouseToCell(X, Y, iCol, iRow);
  AllowOutboundEvents:= bTemp;
  Result:= not ((iCol < 0) and (iRow < 0));
end;

function TDrawGridEx.GetHeaderHeight: Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to FixedRows-1 do
    Result := Result + RowHeights[i];
  if Flat and (BorderStyle = bsSingle) then // TCustomGrid.GetBorderWidth
    Result := Result + 1;
end;

function TDrawGridEx.GetGridHorzLine: Boolean;
begin
  Result := goHorzLine in Options;
end;

function TDrawGridEx.GetGridVertLine: Boolean;
begin
  Result := goVertLine in Options;
end;

procedure TDrawGridEx.SetGridHorzLine(const AValue: Boolean);
begin
  if AValue then
    Options := Options + [goHorzLine]
  else
    Options := Options - [goHorzLine];
end;

procedure TDrawGridEx.SetGridVertLine(const AValue: Boolean);
begin
  if AValue then
    Options := Options + [goVertLine]
  else
    Options := Options - [goVertLine];
end;

function TDrawGridEx.GetVisibleRows: TRange;
var
  w: Integer;
  rc: Integer;
begin
  if (TopRow<0)or(csLoading in ComponentState) then begin
    Result.First := 0;
    Result.Last := -1;
    Exit;
  end;
  // visible TopLeft Cell
  Result.First:=TopRow;
  Result.Last:=Result.First;
  rc := RowCount;

  // Top Margin of next visible Row and Bottom most visible cell
  if rc>FixedRows then begin
    w:=RowHeights[Result.First] + GCache.FixedHeight - GCache.TLRowOff;
    while (Result.Last<rc-1)and(W<GCache.ClientHeight) do begin
      Inc(Result.Last);
      W:=W+RowHeights[Result.Last];
    end;
  end else begin
    Result.Last := Result.First - 1; // no visible cells here
  end;
end;

function TDrawGridEx.IsRowVisible(aRow: Integer): Boolean;
begin
  with GCache.FullVisibleGrid do
    Result:= (Top<=aRow)and(aRow<=Bottom);
end;

procedure TDrawGridEx.KeyDown(var Key: Word; Shift: TShiftState);
var
  SavedKey: Word;
begin
  if ColumnsView.IsLoadingFileList then
  begin
    ColumnsView.HandleKeyDownWhenLoading(Key, Shift);
    Exit;
  end;

  SavedKey := Key;
  // Set RangeSelecting before cursor is moved.
  ColumnsView.FRangeSelecting :=
    (ssShift in Shift) and
    (SavedKey in [VK_HOME, VK_END, VK_PRIOR, VK_NEXT]);
  // Special case for selection with shift key (works like VK_INSERT)
  if (SavedKey in [VK_UP, VK_DOWN]) and (ssShift in Shift) then
    ColumnsView.InvertActiveFile;

  {$IFDEF LCLGTK2}
  // Workaround for GTK2 - up and down arrows moving through controls.
  if Key in [VK_UP, VK_DOWN] then
  begin
    if ((Row = RowCount-1) and (Key = VK_DOWN))
    or ((Row = FixedRows) and (Key = VK_UP)) then
      Key := 0;
  end;
  {$ENDIF}

  inherited KeyDown(Key, Shift);

  if (ColumnsView.FRangeSelecting) and (Row >= FixedRows) then
    ColumnsView.Selection(SavedKey, Row - FixedRows);
end;

procedure TDrawGridEx.ScrollHorizontally(ForwardDirection: Boolean);
  function TryMove(ACol: Integer): Boolean;
  begin
    Result := not IscellVisible(ACol, Row);
    if Result then
      MoveExtend(False, ACol, Row);
  end;
var
  i: Integer;
begin
  if ForwardDirection then
  begin
    for i := Col + 1 to ColCount - 1 do
      if TryMove(i) then
        Break;
  end
  else
  begin
    for i := Col - 1 downto 0 do
      if TryMove(i) then
        Break;
  end;
end;

end.

