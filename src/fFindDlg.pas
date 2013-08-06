{
   Double Commander
   -------------------------------------------------------------------------
   Find dialog, with searching in thread

   Copyright (C) 2003-2004 Radek Cervinka (radek.cervinka@centrum.cz)
   Copyright (C) 2006-2013  Koblov Alexander (Alexx2000@mail.ru)

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

unit fFindDlg;

{$mode objfpc}{$H+}
{$include calling.inc}

interface

uses
  Graphics, SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Menus, EditBtn, Spin, Buttons, ZVDateTimePicker, KASComboBox,
  fAttributesEdit, uDsxModule, DsxPlugin, uFindThread, uFindFiles,
  uSearchTemplate, uFileView;

type

  { TfrmFindDlg }

  TfrmFindDlg = class(TForm)
    Bevel2: TBevel;
    btnAddAttribute: TButton;
    btnAttrsHelp: TButton;
    btnClose: TButton;
    btnGoToPath: TButton;
    btnNewSearch: TButton;
    btnLastSearch: TButton;
    btnSaveTemplate: TButton;
    btnSearchDelete: TButton;
    btnSearchLoad: TButton;
    btnSearchSave: TButton;
    btnSearchSaveWithStartingPath: TButton;
    btnStart: TButton;
    btnUseTemplate: TButton;
    btnStop: TButton;
    btnView: TButton;
    btnEdit: TButton;
    btnWorkWithFound: TButton;
    cbFindText: TCheckBox;
    cbNotContainingText: TCheckBox;
    cbDateFrom: TCheckBox;
    cbNotOlderThan: TCheckBox;
    cbFileSizeFrom: TCheckBox;
    cbDateTo: TCheckBox;
    cbFileSizeTo: TCheckBox;
    cbReplaceText: TCheckBox;
    cbTimeFrom: TCheckBox;
    cbTimeTo: TCheckBox;
    cbPartialNameSearch: TCheckBox;
    cbFollowSymLinks: TCheckBox;
    cbUsePlugin: TCheckBox;
    cbSelectedFiles: TCheckBox;
    cmbExcludeDirectories: TComboBoxWithDelItems;
    cmbNotOlderThanUnit: TComboBox;
    cmbFileSizeUnit: TComboBox;
    cmbEncoding: TComboBox;
    cmbSearchDepth: TComboBox;
    cbRegExp: TCheckBox;
    cmbPlugin: TComboBox;
    cmbReplaceText: TComboBoxWithDelItems;
    cmbFindText: TComboBoxWithDelItems;
    cmbExcludeFiles: TComboBoxWithDelItems;
    edtAttrib: TEdit;
    edtFindPathStart: TDirectoryEdit;
    gbDirectories: TGroupBox;
    gbFiles: TGroupBox;
    lblAttributes: TLabel;
    lblExcludeDirectories: TLabel;
    lblCurrent: TLabel;
    lblExcludeFiles: TLabel;
    lblFound: TLabel;
    lblStatus: TLabel;
    lblTemplateHeader: TLabel;
    lbSearchTemplates: TListBox;
    lblSearchContents: TPanel;
    lblSearchDepth: TLabel;
    lblEncoding: TLabel;
    lsFoundedFiles: TListBox;
    CheksPanel: TPanel;
    miShowAllFound: TMenuItem;
    miRemoveFromLlist: TMenuItem;
    pnlDirectoriesDepth: TPanel;
    pnlLoadSaveBottomButtons: TPanel;
    pnlLoadSaveBottom: TPanel;
    pnlButtons: TPanel;
    pnlResultsBottomButtons: TPanel;
    pnlResults: TPanel;
    pnlStatus: TPanel;
    pnlResultsBottom: TPanel;
    seNotOlderThan: TSpinEdit;
    seFileSizeFrom: TSpinEdit;
    seFileSizeTo: TSpinEdit;
    pnlFindFile: TPanel;
    pgcSearch: TPageControl;
    tsPlugins: TTabSheet;
    tsResults: TTabSheet;
    tsLoadSave: TTabSheet;
    tsStandard: TTabSheet;
    lblFindPathStart: TLabel;
    lblFindFileMask: TLabel;
    cmbFindFileMask: TComboBoxWithDelItems;
    gbFindData: TGroupBox;
    cbCaseSens: TCheckBox;
    tsAdvanced: TTabSheet;
    PopupMenuFind: TPopupMenu;
    miShowInViewer: TMenuItem;
    ZVDateFrom: TZVDateTimePicker;
    ZVDateTo: TZVDateTimePicker;
    ZVTimeFrom: TZVDateTimePicker;
    ZVTimeTo: TZVDateTimePicker;

    procedure btnAddAttributeClick(Sender: TObject);
    procedure btnAttrsHelpClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnLastSearchClick(Sender: TObject);
    procedure btnSearchDeleteClick(Sender: TObject);
    procedure btnSearchLoadClick(Sender: TObject);
    procedure btnSearchSaveWithStartingPathClick(Sender: TObject);
    procedure btnSearchSaveClick(Sender: TObject);
    procedure cbDateFromChange(Sender: TObject);
    procedure cbDateToChange(Sender: TObject);
    procedure cbPartialNameSearchChange(Sender: TObject);
    procedure cbRegExpChange(Sender: TObject);
    procedure cbSelectedFilesChange(Sender: TObject);
    procedure cmbEncodingSelect(Sender: TObject);
    procedure cbFindTextChange(Sender: TObject);
    procedure cbUsePluginChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnGoToPathClick(Sender: TObject);
    procedure btnNewSearchClick(Sender: TObject);
    procedure btnSelDirClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
    procedure btnWorkWithFoundClick(Sender: TObject);
    procedure cbDirectoryChange(Sender: TObject);
    procedure cbFileSizeFromChange(Sender: TObject);
    procedure cbFileSizeToChange(Sender: TObject);
    procedure cbNotOlderThanChange(Sender: TObject);
    procedure cbReplaceTextChange(Sender: TObject);
    procedure cbTimeFromChange(Sender: TObject);
    procedure cbTimeToChange(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure frmFindDlgClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure frmFindDlgShow(Sender: TObject);
    procedure gbDirectoriesResize(Sender: TObject);
    procedure lbSearchTemplatesDblClick(Sender: TObject);
    procedure lbSearchTemplatesSelectionChange(Sender: TObject; {%H-}User: boolean);
    procedure lsFoundedFilesDblClick(Sender: TObject);
    procedure lsFoundedFilesKeyDown(Sender: TObject;
      var Key: Word; Shift: TShiftState);
    procedure miRemoveFromLlistClick(Sender: TObject);
    procedure miShowAllFoundClick(Sender: TObject);
    procedure miShowInViewerClick(Sender: TObject);
    procedure pgcSearchChange(Sender: TObject);
    procedure seFileSizeFromChange(Sender: TObject);
    procedure seFileSizeToChange(Sender: TObject);
    procedure seNotOlderThanChange(Sender: TObject);
    procedure tsLoadSaveShow(Sender: TObject);
    procedure ZVDateFromChange(Sender: TObject);
    procedure ZVDateToChange(Sender: TObject);
    procedure ZVTimeFromChange(Sender: TObject);
    procedure ZVTimeToChange(Sender: TObject);
  private
    FSelectedFiles: TStringList;
    FFindThread:TFindThread;
    DsxPlugins: TDSXModuleList;
    FSearchingActive: Boolean;
    FFrmAttributesEdit: TfrmAttributesEdit;
    FLastTemplateName: UTF8String;
    FLastSearchTemplate: TSearchTemplate;
    FUpdating: Boolean;

    procedure DisableControlsForTemplate;
    procedure StopSearch;
    procedure AfterSearchStopped;
    procedure FillFindOptions(out FindOptions: TSearchTemplateRec; SetStartPath: Boolean);
    procedure FindOptionsToDSXSearchRec(const AFindOptions: TSearchTemplateRec;
                                        out SRec: TDsxSearchRecord);
    procedure FoundedStringCopyChanged(Sender: TObject);
    procedure LoadTemplate(const Template: TSearchTemplateRec);
    procedure LoadSelectedTemplate;
    procedure SaveTemplate(SaveStartingPath: Boolean);
    procedure SelectTemplate(const ATemplateName: String);
    procedure UpdateTemplatesList;
    procedure OnAddAttribute(Sender: TObject);
  public
    class function Instance: TfrmFindDlg;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearFilter;

    procedure ThreadTerminate(Sender:TObject);
  end;

var
  FoundedStringCopy: TStringlist = nil;

{en
   Shows the find files dialog.
   Cannot store FileView reference as it might get destroyed while Find Dialog is running.
   We can store FileSource though, if needed in future (as it is reference counted).
   @param(FileView
          For which file view the find dialog is executed,
          to get file source, current path and a list of selected files.)
}
procedure ShowFindDlg(FileView: TFileView);
function ShowDefineTemplateDlg(var TemplateName: UTF8String): Boolean;
function ShowUseTemplateDlg(var Template: TSearchTemplate): Boolean;

implementation

{$R *.lfm}

uses
  LCLProc, LCLType, LConvEncoding, StrUtils, HelpIntfs, fViewer, fMain,
  uLng, uGlobs, uShowForm, uDCUtils, uFileSource,
  uSearchResultFileSource, uFile, uFileSystemFileSource,
  uFileViewNotebook, uColumnsFileView, uKeyboard,
  DCOSUtils;

const
  TimeUnitToComboIndex: array[TTimeUnit] of Integer = (0, 1, 2, 3, 4, 5, 6);
  ComboIndexToTimeUnit: array[0..6] of TTimeUnit = (tuSecond, tuMinute, tuHour, tuDay, tuWeek, tuMonth, tuYear);
  FileSizeUnitToComboIndex: array[TFileSizeUnit] of Integer = (0, 1, 2, 3, 4);
  ComboIndexToFileSizeUnit: array[0..4] of TFileSizeUnit = (suBytes, suKilo, suMega, suGiga, suTera);

var
  GfrmFindDlgInstance: TfrmFindDlg = nil;

procedure SAddFileProc({%H-}PlugNr: Integer; FoundFile: PChar); dcpcall;
var
  s: string;
begin
  s := string(FoundFile);
  if s='' then
    begin
      TfrmFindDlg.Instance.AfterSearchStopped;
    end
  else
    begin
     FoundedStringCopy.Add(s);
     Application.ProcessMessages;
    end;
end;

procedure SUpdateStatusProc({%H-}PlugNr: Integer; CurrentFile: PChar; FilesScanned: Integer); dcpcall;
var
  sCurrentFile: String;
begin
  sCurrentFile := String(CurrentFile);
  TfrmFindDlg.Instance.lblStatus.Caption:=Format(rsFindScanned,[FilesScanned]);
  if sCurrentFile = '' then
    TfrmFindDlg.Instance.lblCurrent.Caption := ''
  else
    TfrmFindDlg.Instance.lblCurrent.Caption:=rsFindScanning + ': ' + sCurrentFile;
  Application.ProcessMessages;
end;

procedure ShowFindDlg(FileView: TFileView);
var
  ASelectedFiles: TFiles = nil;
  I: Integer;
begin
  if not Assigned(FileView) then
    raise Exception.Create('ShowFindDlg: FileView=nil');

  with TfrmFindDlg.Instance do
  begin
    // Prepare window for search files
    ClearFilter;
    Caption := rsFindSearchFiles;
    edtFindPathStart.Text := FileView.CurrentPath;

    // Get paths of selected files, if any.
    FSelectedFiles.Clear;
    ASelectedFiles := FileView.CloneSelectedFiles;
    if Assigned(ASelectedFiles) then
    try
      if ASelectedFiles.Count > 0 then
      begin
        for I := 0 to ASelectedFiles.Count - 1 do
          FSelectedFiles.Add(ASelectedFiles[I].FullPath);
      end;
    finally
      FreeAndNil(ASelectedFiles);
    end;

    ShowOnTop;
  end;
end;

function ShowDefineTemplateDlg(var TemplateName: UTF8String): Boolean;
var
  AIndex: Integer;
  AForm: TfrmFindDlg;
begin
  AForm := TfrmFindDlg.Create(nil);
  try
    with AForm do
    begin
      // Prepare window for define search template
      Caption := rsFindDefineTemplate;
      AForm.DisableControlsForTemplate;
      btnSaveTemplate.Visible := True;
      btnSaveTemplate.Default := True;
      BorderIcons := [biSystemMenu, biMaximize];
      if Length(TemplateName) > 0 then
      begin
        UpdateTemplatesList;
        AIndex:= lbSearchTemplates.Items.IndexOf(TemplateName);
        if AIndex >= 0 then
        begin
          lbSearchTemplates.ItemIndex:= AIndex;
          AForm.LoadSelectedTemplate;
        end;
      end;
      Result:= (ShowModal = mrOK);
      if Result and (lbSearchTemplates.Count > 0) then
      begin
        TemplateName:= lbSearchTemplates.Items[lbSearchTemplates.Count - 1];
      end;
    end;
  finally
    AForm.Free;
  end;
end;

function ShowUseTemplateDlg(var Template: TSearchTemplate): Boolean;
var
  AForm: TfrmFindDlg;
  SearchRec: TSearchTemplateRec;
begin
  AForm := TfrmFindDlg.Create(nil);
  try
    with AForm do
    begin
      // Prepare window for define search template
      Caption := rsFindDefineTemplate;
      DisableControlsForTemplate;
      btnUseTemplate.Visible := True;
      btnUseTemplate.Default := True;
      BorderIcons := [biSystemMenu, biMaximize];
      if Assigned(Template) then
        AForm.LoadTemplate(Template.SearchRecord);
      Result:= (ShowModal = mrOK);
      if Result then
      begin
        if not Assigned(Template) then
          Template:= TSearchTemplate.Create;
        try
          Template.TemplateName := AForm.FLastTemplateName;
          AForm.FillFindOptions(SearchRec, False);
          Template.SearchRecord := SearchRec;
        except
          FreeAndNil(Template);
          raise;
        end;
      end;
    end;
  finally
    AForm.Free;
  end;
end;

procedure TfrmFindDlg.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  Height:= pnlFindFile.Height + 22;
  DsxPlugins := TDSXModuleList.Create;
  DsxPlugins.Assign(gDSXPlugins);
  FoundedStringCopy := TStringlist.Create;
  FoundedStringCopy.OnChange:=@FoundedStringCopyChanged;

  // load language
  edtFindPathStart.DialogTitle:= rsFindWhereBeg;
  cmbNotOlderThanUnit.Items.Add(rsTimeUnitSecond);
  cmbNotOlderThanUnit.Items.Add(rsTimeUnitMinute);
  cmbNotOlderThanUnit.Items.Add(rsTimeUnitHour);
  cmbNotOlderThanUnit.Items.Add(rsTimeUnitDay);
  cmbNotOlderThanUnit.Items.Add(rsTimeUnitWeek);
  cmbNotOlderThanUnit.Items.Add(rsTimeUnitMonth);
  cmbNotOlderThanUnit.Items.Add(rsTimeUnitYear);
  cmbFileSizeUnit.Items.Add(rsSizeUnitBytes);
  cmbFileSizeUnit.Items.Add(rsSizeUnitKBytes);
  cmbFileSizeUnit.Items.Add(rsSizeUnitMBytes);
  cmbFileSizeUnit.Items.Add(rsSizeUnitGBytes);
  cmbFileSizeUnit.Items.Add(rsSizeUnitTBytes);

  // fill search depth combobox
  cmbSearchDepth.Items.Add(rsFindDepthAll);
  cmbSearchDepth.Items.Add(rsFindDepthCurDir);
  for I:= 1 to 100 do
    cmbSearchDepth.Items.Add(Format(rsFindDepth, [IntToStr(I)]));
  cmbSearchDepth.ItemIndex:= 0;
  // fill encoding combobox
  cmbEncoding.Clear;
  GetSupportedEncodings(cmbEncoding.Items);
  cmbEncoding.ItemIndex:= cmbEncoding.Items.IndexOf(EncodingAnsi);

  // gray disabled fields
  cbUsePluginChange(Sender);
  cbFindTextChange(Sender);
  cbReplaceTextChange(Sender);
  cbNotOlderThanChange(Sender);
  cbFileSizeFromChange(Sender);
  cbFileSizeToChange(Sender);
  ZVDateFrom.DateTime:=Now();
  ZVDateTo.DateTime:=Now();
  ZVTimeFrom.DateTime:=Now();
  ZVTimeTo.DateTime:=Now();
  cbDateFrom.Checked:=False;
  cbDateTo.Checked:=False;
  cbTimeFrom.Checked:=False;
  cbTimeTo.Checked:=False;

{$IF NOT (DEFINED(LCLGTK) or DEFINED(LCLGTK2))}
  btnStart.Default := True;
{$ENDIF}

  cmbNotOlderThanUnit.ItemIndex := 3; // Days
  cmbFileSizeUnit.ItemIndex := 1; // Kilobytes
  edtFindPathStart.ShowHidden := gShowSystemFiles;
  cbPartialNameSearch.Checked:= gPartialNameSearch;

  InitPropStorage(Self);
end;

procedure TfrmFindDlg.cbUsePluginChange(Sender: TObject);
begin
  EnableControl(cmbPlugin, cbUsePlugin.Checked);

  if not FUpdating and cmbPlugin.Enabled and cmbPlugin.CanFocus and (Sender = cbUsePlugin) then
  begin
    cmbPlugin.SetFocus;
    cmbPlugin.SelectAll;
  end;
end;

procedure TfrmFindDlg.cmbEncodingSelect(Sender: TObject);
begin
  if cmbEncoding.ItemIndex <> cmbEncoding.Items.IndexOf(EncodingAnsi) then
    begin
      cbCaseSens.Tag:= Integer(cbCaseSens.Checked);
      cbCaseSens.Checked:= True;
      cbCaseSens.Enabled:= False;
    end
  else
    begin
      cbCaseSens.Checked:= Boolean(cbCaseSens.Tag);
      cbCaseSens.Enabled:= True;
    end;
end;

constructor TfrmFindDlg.Create(TheOwner: TComponent);
begin
  FSelectedFiles := TStringList.Create;
  inherited Create(TheOwner);
end;

destructor TfrmFindDlg.Destroy;
begin
  inherited Destroy;
  FSelectedFiles.Free;
  FLastSearchTemplate.Free;
end;

procedure TfrmFindDlg.DisableControlsForTemplate;
begin
  lblFindPathStart.Visible := False;
  edtFindPathStart.Visible := False;
  cbFollowSymLinks.Visible := False;
  cbSelectedFiles.Visible := False;
  cbPartialNameSearch.Visible := False;
  btnStart.Visible := False;
  btnStop.Visible := False;
  btnNewSearch.Visible := False;
  btnLastSearch.Visible := False;
  btnSearchSaveWithStartingPath.Visible := False;
  gbFindData.Visible := False;
  tsPlugins.TabVisible := False;
  tsResults.TabVisible := False;
end;

procedure TfrmFindDlg.cbFindTextChange(Sender: TObject);
begin
  EnableControl(cmbFindText, cbFindText.Checked);
  EnableControl(cmbEncoding, cbFindText.Checked);
  EnableControl(cbCaseSens, cbFindText.Checked);
  EnableControl(cbReplaceText, cbFindText.Checked);
  EnableControl(cbNotContainingText, cbFindText.Checked);
  lblEncoding.Enabled:=cbFindText.Checked;
  cbReplaceText.Checked:= False;

  if not FUpdating and cmbFindText.Enabled and cmbFindText.CanFocus and (Sender = cbFindText) then
  begin
    cmbFindText.SetFocus;
    cmbFindText.SelectAll;
  end;
end;

procedure TfrmFindDlg.ClearFilter;
begin
  FUpdating := True;

  FLastTemplateName := '';
  edtFindPathStart.Text:= '';
  edtFindPathStart.ShowHidden := gShowSystemFiles;
  cmbExcludeDirectories.Text := '';
  cmbSearchDepth.ItemIndex := 0;
  cmbFindFileMask.Text:= '*';
  cmbExcludeFiles.Text := '';
  cbPartialNameSearch.Checked:= gPartialNameSearch;
  cbRegExp.Checked := False;

  // attributes
  edtAttrib.Text:= '';

  // file date/time
  ZVDateFrom.DateTime:=Now();
  ZVDateTo.DateTime:=Now();
  ZVTimeFrom.DateTime:=Now();
  ZVTimeTo.DateTime:=Now();
  cbDateFrom.Checked:=False;
  cbDateTo.Checked:=False;
  cbTimeFrom.Checked:=False;
  cbTimeTo.Checked:=False;

  // not older then
  cbNotOlderThan.Checked:= False;
  seNotOlderThan.Value:= 1;
  cmbNotOlderThanUnit.ItemIndex := 3; // Days

  // file size
  cbFileSizeFrom.Checked:= False;
  cbFileSizeTo.Checked:= False;
  seFileSizeFrom.Value:= 0;
  seFileSizeTo.Value:= 10;
  cmbFileSizeUnit.ItemIndex := 1; // Kilobytes

  // find/replace text
  // do not clear search/replace text just clear checkbox
  cbFindText.Checked:= False;
  cbReplaceText.Checked:= False;
  cbCaseSens.Checked:= False;
  cbNotContainingText.Checked:= False;
  cmbEncoding.ItemIndex := 0;

  // plugins
  cmbPlugin.Text:= '';

  FUpdating := False;
end;

procedure TfrmFindDlg.btnSearchLoadClick(Sender: TObject);
begin
  LoadSelectedTemplate;
end;

procedure TfrmFindDlg.btnSearchSaveWithStartingPathClick(Sender: TObject);
begin
  SaveTemplate(True);
end;

procedure TfrmFindDlg.btnSearchDeleteClick(Sender: TObject);
var
  OldIndex: Integer;
begin
  OldIndex := lbSearchTemplates.ItemIndex;
  if OldIndex < 0 then Exit;
  gSearchTemplateList.DeleteTemplate(OldIndex);
  lbSearchTemplates.Items.Delete(OldIndex);
  if OldIndex < lbSearchTemplates.Count then
    lbSearchTemplates.ItemIndex := OldIndex
  else if lbSearchTemplates.Count > 0 then
    lbSearchTemplates.ItemIndex := lbSearchTemplates.Count - 1;
end;

procedure TfrmFindDlg.btnAttrsHelpClick(Sender: TObject);
begin
  ShowHelpOrErrorForKeyword('', edtAttrib.HelpKeyword);
end;

procedure TfrmFindDlg.btnEditClick(Sender: TObject);
begin
  if lsFoundedFiles.ItemIndex <> -1 then
    ShowEditorByGlob(lsFoundedFiles.Items[lsFoundedFiles.ItemIndex]);
end;

procedure TfrmFindDlg.btnAddAttributeClick(Sender: TObject);
begin
  if not Assigned(FFrmAttributesEdit) then
  begin
    FFrmAttributesEdit := TfrmAttributesEdit.Create(Self);
    FFrmAttributesEdit.OnOk := @OnAddAttribute;
  end;
  FFrmAttributesEdit.Reset;
  FFrmAttributesEdit.Show;
end;

procedure TfrmFindDlg.btnSearchSaveClick(Sender: TObject);
begin
  SaveTemplate(False);
end;

procedure TfrmFindDlg.cbDateFromChange(Sender: TObject);
begin
  UpdateColor(ZVDateFrom, cbDateFrom.Checked);
end;

procedure TfrmFindDlg.cbDateToChange(Sender: TObject);
begin
  UpdateColor(ZVDateTo, cbDateTo.Checked);
end;

procedure TfrmFindDlg.cbPartialNameSearchChange(Sender: TObject);
begin
  if cbPartialNameSearch.Checked then cbRegExp.Checked:=False;
end;

procedure TfrmFindDlg.cbRegExpChange(Sender: TObject);
begin
  if cbRegExp.Checked then cbPartialNameSearch.Checked:=False;
end;

procedure TfrmFindDlg.cbSelectedFilesChange(Sender: TObject);
begin
  edtFindPathStart.Enabled := not cbSelectedFiles.Checked;
end;

procedure TfrmFindDlg.btnSelDirClick(Sender: TObject);
var
  s:String;
begin
  s:=edtFindPathStart.Text;
  if not mbDirectoryExists(s) then s:='';
  SelectDirectory(rsFindWhereBeg,'',s, False);
  edtFindPathStart.Text:=s;
end;

procedure TfrmFindDlg.btnNewSearchClick(Sender: TObject);
begin
  StopSearch;
  pgcSearch.PageIndex:= 0;
  lsFoundedFiles.Clear;
  FoundedStringCopy.Clear;
  miShowAllFound.Enabled:=False;
  lblStatus.Caption:= EmptyStr;
  lblCurrent.Caption:= EmptyStr;
  lblFound.Caption:= EmptyStr;
  if pgcSearch.ActivePage = tsStandard then
    cmbFindFileMask.SetFocus;
end;

procedure TfrmFindDlg.btnGoToPathClick(Sender: TObject);
begin
  if lsFoundedFiles.ItemIndex <> -1 then
  begin
    StopSearch;
    frmMain.ActiveFrame.CurrentPath := ExtractFilePath(lsFoundedFiles.Items[lsFoundedFiles.ItemIndex]);
    frmMain.ActiveFrame.SetActiveFile(ExtractFileName(lsFoundedFiles.Items[lsFoundedFiles.ItemIndex]));
    Close;
  end;
end;

procedure TfrmFindDlg.btnLastSearchClick(Sender: TObject);
begin
  if Assigned(FLastSearchTemplate) then
  begin
    LoadTemplate(FLastSearchTemplate.SearchRecord);
    pgcSearch.ActivePage := tsStandard;
    cmbFindFileMask.SetFocus;
  end;
end;

procedure TfrmFindDlg.FillFindOptions(out FindOptions: TSearchTemplateRec; SetStartPath: Boolean);
begin
  with FindOptions do
  begin
    if SetStartPath then
      StartPath := edtFindPathStart.Text
    else
      StartPath := '';
    ExcludeDirectories  := cmbExcludeDirectories.Text;
    FilesMasks          := cmbFindFileMask.Text;
    ExcludeFiles        := cmbExcludeFiles.Text;
    SearchDepth         := cmbSearchDepth.ItemIndex - 1;
    RegExp              := cbRegExp.Checked;
    IsPartialNameSearch := cbPartialNameSearch.Checked;
    FollowSymLinks      := cbFollowSymLinks.Checked;

    { File attributes }
    AttributesPattern := edtAttrib.Text;

    { Date/time }
    DateTimeFrom := 0;
    DateTimeTo   := 0;
    IsDateFrom   := False;
    IsDateTo     := False;
    IsTimeFrom   := False;
    IsTimeTo     := False;
    if cbDateFrom.Checked then
      begin
        IsDateFrom := True;
        DateTimeFrom := ZVDateFrom.Date;
      end;
    if cbDateTo.Checked then
      begin
        IsDateTo := True;
        DateTimeTo := ZVDateTo.Date;
      end;
    if cbTimeFrom.Checked then
      begin
        IsTimeFrom := True;
        DateTimeFrom := DateTimeFrom + ZVTimeFrom.Time;
      end;
    if cbTimeTo.Checked then
      begin
        IsTimeTo := True;
        DateTimeTo := DateTimeTo + ZVTimeTo.Time;
      end;

    { Not Older Than }
    IsNotOlderThan   := cbNotOlderThan.Checked;
    NotOlderThan     := seNotOlderThan.Value;
    NotOlderThanUnit := ComboIndexToTimeUnit[cmbNotOlderThanUnit.ItemIndex];

    { File size }
    IsFileSizeFrom := cbFileSizeFrom.Checked;
    IsFileSizeTo   := cbFileSizeTo.Checked;
    FileSizeFrom   := seFileSizeFrom.Value;
    FileSizeTo     := seFileSizeTo.Value;
    FileSizeUnit   := ComboIndexToFileSizeUnit[cmbFileSizeUnit.ItemIndex];

    { Find/replace text }
    IsFindText        := cbFindText.Checked;
    FindText          := cmbFindText.Text;
    IsReplaceText     := cbReplaceText.Checked;
    ReplaceText       := cmbReplaceText.Text;
    CaseSensitive     := cbCaseSens.Checked;
    NotContainingText := cbNotContainingText.Checked;
    TextEncoding      := cmbEncoding.Text;
    SearchPlugin      := cmbPlugin.Text;
  end;
end;

procedure TfrmFindDlg.FindOptionsToDSXSearchRec(
  const AFindOptions: TSearchTemplateRec;
  out SRec: TDsxSearchRecord);
begin
  with AFindOptions do
  begin
    FillByte(SRec{%H-}, SizeOf(SRec), 0);

    SRec.StartPath:= Copy(StartPath, 1, SizeOf(SRec.StartPath));

    if IsPartialNameSearch then
      SRec.FileMask:= '*' + Copy(FilesMasks, 1, SizeOf(SRec.FileMask) - 2) + '*'
    else
      SRec.FileMask:= Copy(FilesMasks, 1, SizeOf(SRec.FileMask));

    SRec.Attributes:= faAnyFile;  // AttrStrToFileAttr?
    SRec.AttribStr:= Copy(AttributesPattern, 1, SizeOf(SRec.AttribStr));

    SRec.CaseSensitive:=CaseSensitive;
    {Date search}
    SRec.IsDateFrom:=IsDateFrom;
    SRec.IsDateTo:=IsDateTo;
    SRec.DateTimeFrom:=DateTimeFrom;
    SRec.DateTimeTo:=DateTimeTo;
    {Time search}
    SRec.IsTimeFrom:=IsTimeFrom;
    SRec.IsTimeTo:=IsTimeTo;
    (* File size search *)
    SRec.IsFileSizeFrom:=IsFileSizeFrom;
    SRec.IsFileSizeTo:=IsFileSizeTo;
    SRec.FileSizeFrom:=FileSizeFrom;
    SRec.FileSizeTo:=FileSizeTo;
    (* Find text *)
    SRec.NotContainingText:=NotContainingText;
    SRec.IsFindText:=IsFindText;
    SRec.FindText:= Copy(FindText, 1, SizeOf(SRec.FindText));
    (* Replace text *)
    SRec.IsReplaceText:=IsReplaceText;
    SRec.ReplaceText:= Copy(ReplaceText, 1, SizeOf(SRec.ReplaceText));
  end;
end;

procedure TfrmFindDlg.StopSearch;
begin
  if FSearchingActive then
  begin
    if (cbUsePlugin.Checked) and (cmbPlugin.ItemIndex<>-1) then
      begin
        DSXPlugins.GetDSXModule(cmbPlugin.ItemIndex).CallStopSearch;
        DSXPlugins.GetDSXModule(cmbPlugin.ItemIndex).CallFinalize;
        AfterSearchStopped;
      end;

    if Assigned(FFindThread) then
    begin
      FFindThread.Terminate;
      FFindThread := nil;
    end;
  end;
end;

class function TfrmFindDlg.Instance: TfrmFindDlg;
begin
  if not Assigned(GfrmFindDlgInstance) then
    GfrmFindDlgInstance := TfrmFindDlg.Create(nil);
  Result := GfrmFindDlgInstance;
end;

procedure TfrmFindDlg.lbSearchTemplatesDblClick(Sender: TObject);
begin
  LoadSelectedTemplate;
end;

procedure TfrmFindDlg.AfterSearchStopped;
begin
  btnStop.Enabled:= False;
  btnStart.Enabled:= True;
{$IF NOT (DEFINED(LCLGTK) or DEFINED(LCLGTK2))}
  btnStart.Default:= True;
{$ENDIF}
  btnClose.Enabled:= True;
  btnNewSearch.Enabled:= True;
  FSearchingActive := False;
end;

procedure TfrmFindDlg.btnStartClick(Sender: TObject);
var
  sTemp, sPath : UTF8String;
  sr: TDsxSearchRecord;
  SearchTemplate, TmpTemplate: TSearchTemplateRec;
  PassedSelectedFiles: TStringList = nil;
begin
  sTemp:= edtFindPathStart.Text;
  repeat
    sPath:= Copy2SymbDel(sTemp, ';');
    if not mbDirectoryExists(sPath) then
      begin
        ShowMessage(Format(rsFindDirNoEx,[sPath]));
        Exit;
      end;
  until sTemp = EmptyStr;
  // add to find mask history
  InsertFirstItem(cmbFindFileMask.Text, cmbFindFileMask);
  // add to exclude directories history
  InsertFirstItem(cmbExcludeDirectories.Text, cmbExcludeDirectories);
  // add to exclude files history
  InsertFirstItem(cmbExcludeFiles.Text, cmbExcludeFiles);
  // add to search text history
  if cbFindText.Checked then
  begin
    InsertFirstItem(cmbFindText.Text, cmbFindText);
    // update search history, so it can be used in
    // Viewer/Editor opened from find files dialog
    gFirstTextSearch:= False;
    glsSearchHistory.Assign(cmbFindText.Items);
  end;
  // add to replace text history
  if cbReplaceText.Checked then
  begin
    InsertFirstItem(cmbReplaceText.Text, cmbReplaceText);
    // update replace history, so it can be used in
    // Editor opened from find files dialog (issue 0000539)
    glsReplaceHistory.Assign(cmbReplaceText.Items);
  end;

  if cbSelectedFiles.Checked and (FSelectedFiles.Count = 0) then
  begin
    ShowMessage(rsMsgNoFilesSelected);
    cbSelectedFiles.Checked:= False;
    Exit;
  end;

  // Show search results page
  pgcSearch.ActivePageIndex:= pgcSearch.PageCount - 1;

  if lsFoundedFiles.CanFocus then
    lsFoundedFiles.SetFocus;

  lsFoundedFiles.Items.Clear;
  FoundedStringCopy.Clear;
  miShowAllFound.Enabled:=False;

  FSearchingActive := True;
  btnStop.Enabled:=True;
{$IF NOT (DEFINED(LCLGTK) or DEFINED(LCLGTK2))}
  btnStop.Default:=True;
{$ENDIF}
  btnStart.Enabled:= False;
  btnClose.Enabled:= False;
  btnNewSearch.Enabled:= False;

  FillFindOptions(SearchTemplate, True);

  if not Assigned(FLastSearchTemplate) then
    FLastSearchTemplate := TSearchTemplate.Create;
  TmpTemplate := SearchTemplate;
  TmpTemplate.StartPath := ''; // Don't remember starting path.
  FLastSearchTemplate.SearchRecord := TmpTemplate;

  try
    if (cbUsePlugin.Checked) and (cmbPlugin.ItemIndex<>-1) then
      begin
        if DSXPlugins.LoadModule(cmbPlugin.ItemIndex) then
        begin
          FindOptionsToDSXSearchRec(SearchTemplate, sr);
          DSXPlugins.GetDSXModule(cmbPlugin.ItemIndex).CallInit(@SAddFileProc,@SUpdateStatusProc);
          DSXPlugins.GetDSXModule(cmbPlugin.ItemIndex).CallStartSearch(sr);
        end
        else
          StopSearch;
      end
    else
      begin
        if cbSelectedFiles.Checked then
          PassedSelectedFiles := FSelectedFiles;
        FFindThread := TFindThread.Create(SearchTemplate, PassedSelectedFiles);
        with FFindThread do
        begin
          Items := FoundedStringCopy;
          Status := lblStatus;
          Current := lblCurrent;
          Found := lblFound;
          OnTerminate := @ThreadTerminate; // will update the buttons after search is finished
        end;
        FFindThread.Start;
      end;
  except
    StopSearch;
    raise;
  end;
end;
procedure TfrmFindDlg.FoundedStringCopyChanged(Sender: TObject);
begin
  if FoundedStringCopy.Count > 0 then
    lsFoundedFiles.Items.Add(FoundedStringCopy[FoundedStringCopy.Count - 1]);
end;

procedure TfrmFindDlg.btnViewClick(Sender: TObject);
begin
  if lsFoundedFiles.ItemIndex <> -1 then
    ShowViewerByGlob(lsFoundedFiles.Items[lsFoundedFiles.ItemIndex]);
end;

procedure TfrmFindDlg.btnWorkWithFoundClick(Sender: TObject);
var
  I: Integer;
  sFileName: String;
  SearchResultFS: ISearchResultFileSource;
  FileList: TFileTree;
  aFile: TFile;
  Notebook: TFileViewNotebook;
  NewPage: TFileViewPage;
  FileView: TFileView;
begin
  StopSearch;

  FileList := TFileTree.Create;
  for i := 0 to lsFoundedFiles.Items.Count - 1 do
  begin
    sFileName:= lsFoundedFiles.Items[I];
    try
      aFile := TFileSystemFileSource.CreateFileFromFile(sFileName);
      FileList.AddSubNode(aFile);
    except
      on EFileNotFound do;
    end;
  end;

  // Create search result file source.
  // Currently only searching FileSystem is supported.
  SearchResultFS := TSearchResultFileSource.Create;
  SearchResultFS.AddList(FileList, TFileSystemFileSource.GetFileSource);

  // Add new tab for search results.
  Notebook := frmMain.ActiveNotebook;
  NewPage := Notebook.NewEmptyPage;
  NewPage.PermanentTitle := rsSearchResult;

  // Hard-coded Columns file view for now (later user will be able to change default view).
  FileView := TColumnsFileView.Create(NewPage, SearchResultFS, SearchResultFS.GetRootDir);
  frmMain.AssignEvents(FileView);
  NewPage.MakeActive;

  Close;
end;

procedure TfrmFindDlg.cbDirectoryChange(Sender: TObject);
begin
end;

procedure TfrmFindDlg.cbFileSizeFromChange(Sender: TObject);
begin
  UpdateColor(seFileSizeFrom, cbFileSizeFrom.Checked);
  EnableControl(cmbFileSizeUnit,cbFileSizeFrom.Checked or cbFileSizeTo.Checked);
end;

procedure TfrmFindDlg.cbFileSizeToChange(Sender: TObject);
begin
  UpdateColor(seFileSizeTo, cbFileSizeTo.Checked);
  EnableControl(cmbFileSizeUnit,cbFileSizeFrom.Checked or cbFileSizeTo.Checked);
end;

procedure TfrmFindDlg.cbNotOlderThanChange(Sender: TObject);
begin
   UpdateColor(seNotOlderThan, cbNotOlderThan.Checked);
   EnableControl(cmbNotOlderThanUnit,cbNotOlderThan.Checked);
end;

procedure TfrmFindDlg.cbReplaceTextChange(Sender: TObject);
begin
  EnableControl(cmbReplaceText, cbReplaceText.Checked and cbFindText.Checked);
  cbNotContainingText.Checked := False;
  cbNotContainingText.Enabled := (not cbReplaceText.Checked and cbFindText.Checked);

  if not FUpdating and cmbReplaceText.Enabled and cmbReplaceText.CanFocus then
  begin
    cmbReplaceText.SetFocus;
    cmbReplaceText.SelectAll;
  end;
end;

procedure TfrmFindDlg.cbTimeFromChange(Sender: TObject);
begin
  UpdateColor(ZVTimeFrom, cbTimeFrom.Checked);
end;

procedure TfrmFindDlg.cbTimeToChange(Sender: TObject);
begin
  UpdateColor(ZVTimeTo, cbTimeTo.Checked);
end;

procedure TfrmFindDlg.ThreadTerminate(Sender:TObject);
begin
  FFindThread:= nil;
  AfterSearchStopped;
end;

procedure TfrmFindDlg.btnStopClick(Sender: TObject);
begin
  StopSearch;
end;

procedure TfrmFindDlg.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:= not Assigned(FFindThread);
end;

procedure TfrmFindDlg.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmFindDlg.FormDestroy(Sender: TObject);
begin
  FreeThenNil(FoundedStringCopy);
  FreeThenNil(DsxPlugins);
end;

procedure TfrmFindDlg.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
{$IF DEFINED(LCLGTK) or DEFINED(LCLGTK2)}
    // On LCLGTK2 default button on Enter does not work.
    VK_RETURN, VK_SELECT:
      begin
        Key := 0;
        if btnStart.Enabled then
          btnStart.Click
        else
          btnStop.Click;
      end;
{$ENDIF}
    VK_ESCAPE:
      begin
        Key := 0;
        if FSearchingActive then
          StopSearch
        else
          Close;
      end;
    VK_1..VK_5:
      begin
        if Shift * KeyModifiersShortcut = [ssAlt] then
          begin
            pgcSearch.PageIndex := Key - VK_1;
            Key := 0;
          end;
      end;
    VK_TAB:
      begin
        if Shift * KeyModifiersShortcut = [ssCtrl] then
        begin
          pgcSearch.SelectNextPage(True);
          Key := 0;
        end
        else if Shift * KeyModifiersShortcut = [ssCtrl, ssShift] then
        begin
          pgcSearch.SelectNextPage(False);
          Key := 0;
        end;
      end;
  end;
end;

procedure TfrmFindDlg.frmFindDlgClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  glsMaskHistory.Assign(cmbFindFileMask.Items);
  glsSearchExcludeFiles.Assign(cmbExcludeFiles.Items);
  glsSearchExcludeDirectories.Assign(cmbExcludeDirectories.Items);

  if Assigned(FFrmAttributesEdit) then
  begin
    FFrmAttributesEdit.Close;
    FreeAndNil(FFrmAttributesEdit);
  end;
end;

procedure TfrmFindDlg.frmFindDlgShow(Sender: TObject);
var
  I: Integer;
begin
  pgcSearch.PageIndex:= 0;

  if cmbFindFileMask.Visible then
    cmbFindFileMask.SelectAll;

  cmbFindFileMask.Items.Assign(glsMaskHistory);
  cmbFindText.Items.Assign(glsSearchHistory);
  // if we already search text then use last searched text
  if not gFirstTextSearch then
    begin
      if glsSearchHistory.Count > 0 then
        cmbFindText.Text:= glsSearchHistory[0];
    end;
  cmbReplaceText.Items.Assign(glsReplaceHistory);
  cmbExcludeFiles.Items.Assign(glsSearchExcludeFiles);
  cmbExcludeDirectories.Items.Assign(glsSearchExcludeDirectories);

  cbFindText.Checked := False;

  cmbPlugin.Clear;
  for I:= 0 to DSXPlugins.Count-1 do
    begin
      cmbPlugin.AddItem(DSXPlugins.GetDSXModule(i).Name+' (' + DSXPlugins.GetDSXModule(I).Descr+' )',nil);
    end;
  if (cmbPlugin.Items.Count>0) then cmbPlugin.ItemIndex:=0;

  if pgcSearch.ActivePage = tsStandard then
    if cmbFindFileMask.CanFocus then
      cmbFindFileMask.SetFocus;

  cbSelectedFiles.Checked := FSelectedFiles.Count > 0;
  cbSelectedFiles.Enabled := cbSelectedFiles.Checked;
end;

procedure TfrmFindDlg.gbDirectoriesResize(Sender: TObject);
begin
  pnlDirectoriesDepth.Width := gbDirectories.Width div 3;
end;

procedure TfrmFindDlg.lbSearchTemplatesSelectionChange(Sender: TObject; User: boolean);
begin
  if lbSearchTemplates.ItemIndex < 0 then
    lblSearchContents.Caption := ''
  else
  begin
    with gSearchTemplateList.Templates[lbSearchTemplates.ItemIndex].SearchRecord do
    begin
      if StartPath <> '' then
        lblSearchContents.Caption := '"' + FilesMasks + '" -> "' + StartPath + '"'
      else
        lblSearchContents.Caption := '"' + FilesMasks + '"';
    end;
  end;
end;

procedure TfrmFindDlg.LoadSelectedTemplate;
var
  SearchTemplate: TSearchTemplate;
begin
  if lbSearchTemplates.ItemIndex < 0 then Exit;
  SearchTemplate:= gSearchTemplateList.Templates[lbSearchTemplates.ItemIndex];
  if Assigned(SearchTemplate) then
  begin
    FLastTemplateName := SearchTemplate.TemplateName;
    LoadTemplate(SearchTemplate.SearchRecord);
  end;
end;

procedure TfrmFindDlg.LoadTemplate(const Template: TSearchTemplateRec);
begin
  with Template do
  begin
    if StartPath <> '' then
      edtFindPathStart.Text:= StartPath;
    cmbExcludeDirectories.Text:= ExcludeDirectories;
    cmbFindFileMask.Text:= FilesMasks;
    cmbExcludeFiles.Text:= ExcludeFiles;
    if (SearchDepth + 1 >= 0) and (SearchDepth + 1 < cmbSearchDepth.Items.Count) then
      cmbSearchDepth.ItemIndex:= SearchDepth + 1
    else
      cmbSearchDepth.ItemIndex:= 0;
    cbRegExp.Checked := RegExp;
    cbPartialNameSearch.Checked := IsPartialNameSearch;
    cbFollowSymLinks.Checked := FollowSymLinks;
    // attributes
    edtAttrib.Text:= AttributesPattern;
    // file date/time
    cbDateFrom.Checked:= IsDateFrom;
    if IsDateFrom then
      ZVDateFrom.Date:= DateTimeFrom;

    cbDateTo.Checked:= IsDateTo;
    if IsDateTo then
      ZVDateTo.Date:= DateTimeTo;

    cbTimeFrom.Checked:= IsTimeFrom;
    if IsTimeFrom then
      ZVTimeFrom.Time:= DateTimeFrom;

    cbTimeTo.Checked:= IsTimeTo;
    if IsTimeTo then
      ZVTimeTo.Time:= DateTimeTo;

    // not older then
    cbNotOlderThan.Checked:= IsNotOlderThan;
    seNotOlderThan.Value:= NotOlderThan;
    cmbNotOlderThanUnit.ItemIndex := TimeUnitToComboIndex[NotOlderThanUnit];
    // file size
    cbFileSizeFrom.Checked:= IsFileSizeFrom;
    cbFileSizeTo.Checked:= IsFileSizeTo;
    seFileSizeFrom.Value:= FileSizeFrom;
    seFileSizeTo.Value:= FileSizeTo;
    cmbFileSizeUnit.ItemIndex := FileSizeUnitToComboIndex[FileSizeUnit];
    // find/replace text
    cbFindText.Checked:= IsFindText;
    cmbFindText.Text:= FindText;
    cbReplaceText.Checked:= IsReplaceText;
    cmbReplaceText.Text:= ReplaceText;
    cbCaseSens.Checked:= CaseSensitive;
    cbNotContainingText.Checked:= NotContainingText;
    cmbEncoding.Text:= TextEncoding;
    cmbPlugin.Text:= SearchPlugin;
  end;
end;

procedure TfrmFindDlg.lsFoundedFilesDblClick(Sender: TObject);
begin
  if not FSearchingActive then btnGoToPathClick(Sender);
end;

procedure TfrmFindDlg.lsFoundedFilesKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Shift = []) and (lsFoundedFiles.ItemIndex <> -1) then
  begin
    case Key of
      VK_F3:
      begin
        ShowViewerByGlob(lsFoundedFiles.Items[lsFoundedFiles.ItemIndex]);
        Key := 0;
      end;

      VK_F4:
      begin
        ShowEditorByGlob(lsFoundedFiles.Items[lsFoundedFiles.ItemIndex]);
        Key := 0;
      end;

      VK_DELETE:
      begin
        miRemoveFromLlistClick(Sender);
        Key := 0;
      end;

      VK_RETURN:
      begin
        if not FSearchingActive then
        begin
          btnGoToPathClick(Sender);
          Key := 0;
        end;
      end;
    end;
  end;
end;

procedure TfrmFindDlg.miRemoveFromLlistClick(Sender: TObject);
var
  i:Integer;
begin
  if lsFoundedFiles.ItemIndex=-1 then Exit;
  if lsFoundedFiles.SelCount = 0 then Exit;

  for i:=lsFoundedFiles.Items.Count-1 downto 0 do
    if lsFoundedFiles.Selected[i] then
      lsFoundedFiles.Items.Delete(i);

  miShowAllFound.Enabled:=True;
end;

procedure TfrmFindDlg.miShowAllFoundClick(Sender: TObject);
begin
  lsFoundedFiles.Clear;
  lsFoundedFiles.Items.AddStrings(FoundedStringCopy);

  miShowAllFound.Enabled:=False;
end;

procedure TfrmFindDlg.miShowInViewerClick(Sender: TObject);
var
  sl:TStringList;
  i:Integer;
begin
  if lsFoundedFiles.ItemIndex=-1 then Exit;

  sl:=TStringList.Create;
  try
    for i:=0 to lsFoundedFiles.Items.Count-1 do
      if lsFoundedFiles.Selected[i] then
        sl.Add(lsFoundedFiles.Items[i]);
    ShowViewer(sl);
  finally
    sl.Free;
  end;
end;

procedure TfrmFindDlg.seFileSizeFromChange(Sender: TObject);
begin
  if not FUpdating then
    cbFileSizeFrom.Checked:= (seFileSizeFrom.Value > 0);
end;

procedure TfrmFindDlg.seFileSizeToChange(Sender: TObject);
begin
  if not FUpdating then
    cbFileSizeTo.Checked:= (seFileSizeTo.Value > 0);
end;

procedure TfrmFindDlg.SelectTemplate(const ATemplateName: String);
var
  i: Integer;
begin
  for i := 0 to lbSearchTemplates.Count - 1 do
    if lbSearchTemplates.Items[i] = ATemplateName then
    begin
      lbSearchTemplates.ItemIndex := i;
      Break;
    end;
end;

procedure TfrmFindDlg.seNotOlderThanChange(Sender: TObject);
begin
  if not FUpdating then
    cbNotOlderThan.Checked:= (seNotOlderThan.Value > 0);
end;

procedure TfrmFindDlg.tsLoadSaveShow(Sender: TObject);
begin
  UpdateTemplatesList;
  if (lbSearchTemplates.Count > 0) and (lbSearchTemplates.ItemIndex = -1) then
    lbSearchTemplates.ItemIndex := 0;
end;

procedure TfrmFindDlg.UpdateTemplatesList;
var
  OldIndex: Integer;
begin
  OldIndex := lbSearchTemplates.ItemIndex;
  gSearchTemplateList.LoadToStringList(lbSearchTemplates.Items);
  if OldIndex <> -1 then
    lbSearchTemplates.ItemIndex := OldIndex;
end;

procedure TfrmFindDlg.ZVDateFromChange(Sender: TObject);
begin
  if not FUpdating then
    cbDateFrom.Checked:= True;
end;

procedure TfrmFindDlg.ZVDateToChange(Sender: TObject);
begin
  if not FUpdating then
    cbDateTo.Checked:= True;
end;

procedure TfrmFindDlg.ZVTimeFromChange(Sender: TObject);
begin
  if not FUpdating then
    cbTimeFrom.Checked:= True;
end;

procedure TfrmFindDlg.ZVTimeToChange(Sender: TObject);
begin
  if not FUpdating then
    cbTimeTo.Checked:= True;
end;

procedure TfrmFindDlg.OnAddAttribute(Sender: TObject);
var
  sAttr: String;
begin
  sAttr := edtAttrib.Text;
  if edtAttrib.SelStart > 0 then
    // Insert at caret position.
    Insert((Sender as TfrmAttributesEdit).AttrsAsText, sAttr, edtAttrib.SelStart + 1)
  else
    sAttr := sAttr + (Sender as TfrmAttributesEdit).AttrsAsText;
  edtAttrib.Text := sAttr;
end;

procedure TfrmFindDlg.pgcSearchChange(Sender: TObject);
begin
  if (pgcSearch.ActivePage = tsStandard) and not cmbFindFileMask.Focused then
  begin
    if cmbFindFileMask.CanFocus then
      cmbFindFileMask.SetFocus;
  end;
end;

procedure TfrmFindDlg.SaveTemplate(SaveStartingPath: Boolean);
var
  sName: UTF8String;
  SearchTemplate: TSearchTemplate;
  SearchRec: TSearchTemplateRec;
begin
  sName := FLastTemplateName;
  if not InputQuery(rsFindSaveTemplateCaption, rsFindSaveTemplateTitle, sName) then
  begin
    ModalResult:= mrCancel;
    Exit;
  end;

  FLastTemplateName := sName;
  SearchTemplate := gSearchTemplateList.TemplateByName[sName];
  if Assigned(SearchTemplate) then
  begin
    // TODO: Ask for overwriting existing template.
    FillFindOptions(SearchRec, SaveStartingPath);
    SearchTemplate.SearchRecord := SearchRec;
    Exit;
  end;

  SearchTemplate:= TSearchTemplate.Create;
  try
    SearchTemplate.TemplateName:= sName;
    FillFindOptions(SearchRec, SaveStartingPath);
    SearchTemplate.SearchRecord := SearchRec;
    gSearchTemplateList.Add(SearchTemplate);
  except
    FreeAndNil(SearchTemplate);
    raise;
  end;
  UpdateTemplatesList;
  SelectTemplate(FLastTemplateName);
end;

finalization
  FreeAndNil(GfrmFindDlgInstance);

end.
