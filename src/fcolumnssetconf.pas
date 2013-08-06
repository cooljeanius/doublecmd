{
   Double Commander
   -------------------------------------------------------------------------
   Implementing of columns' configure dialog

   Copyright (C) 2008  Dmitry Kolomiets (B4rr4cuda@rambler.ru)
   
   contributors:

   Copyright (C) 2008-2012  Koblov Alexander (Alexx2000@mail.ru)

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


unit fColumnsSetConf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, Grids,  ComCtrls, Menus, LCLType, uColumns, uGlobs, Spin,
  uColumnsFileView,
  ColorBox;

type


  { TfColumnsSetConf }

  TfColumnsSetConf = class(TForm)
    btnAllBack: TButton;
    btnAllBack2: TButton;
    btnAllCurCol: TButton;
    btnAllCurText: TButton;
    btnAllFont: TButton;
    btnAllMarc: TButton;
    btnAllText: TButton;
    btnBackColor: TButton;
    btnBackColor2: TButton;
    btnCursorBorderColor: TButton;
    btnCursorColor: TButton;
    btnCursorText: TButton;
    btnFontSelect: TBitBtn;
    btnForeColor: TButton;
    btnMarkColor: TButton;
    btnOk: TBitBtn;
    btnCancel: TBitBtn;
    btnNext: TButton;
    btnPrev: TButton;
    cBackGrndLabel: TLabel;
    cbBackColor: TColorBox;
    cbBackColor2: TColorBox;
    cbCursorBorder: TCheckBox;
    cbCursorBorderColor: TColorBox;
    cbCursorColor: TColorBox;
    cbCursorText: TColorBox;
    cbMarkColor: TColorBox;
    cbOverColor: TCheckBox;
    cbTextColor: TColorBox;
    chkUseCustomView: TCheckBox;
    cTextLabel: TLabel;
    dlgcolor: TColorDialog;
    ComboBox1: TComboBox;
    edtFont: TEdit;
    edtNameofColumnsSet: TEdit;
    dlgfont: TFontDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lblBackground2: TLabel;
    lblConfigViewNr: TLabel;
    lblCursorColor: TLabel;
    lblCursorText: TLabel;
    lblMarkColor: TLabel;
    lblName: TLabel;
    lbNrOfColumnsSet: TLabel;
    miAddColumn: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    pnlCustomView: TPanel;
    pnlGlobalSettings: TPanel;
    pnlCustCont: TPanel;
    pnlCustHead: TPanel;
    pnlPrevCont: TPanel;
    pnlPreviewHead: TPanel;
    pnlPreview: TPanel;
    pmStringGrid: TPopupMenu;
    pmFields: TPopupMenu;
    ResBack: TButton;
    ResBack2: TButton;
    ResCurCol: TButton;
    ResCurText: TButton;
    ResFont: TButton;
    ResMark: TButton;
    ResText: TButton;
    sneFontSize: TSpinEdit;
    SplitterPreview: TSplitter;
    SplitterCustomize: TSplitter;
    stgColumns: TStringGrid;
    procedure btnAllTextClick(Sender: TObject);
    procedure btnBackColor2Click(Sender: TObject);
    procedure btnBackColorClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnCursorColorClick(Sender: TObject);
    procedure btnCursorTextClick(Sender: TObject);
    procedure btnCursorBorderColorClick(Sender: TObject);
    procedure btnFontSelectClick(Sender: TObject);
    procedure btnForeColorClick(Sender: TObject);
    procedure btnMarkColorClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnPrevClick(Sender: TObject);
    procedure cbCursorBorderChange(Sender: TObject);
    procedure cbCursorBorderColorChange(Sender: TObject);
    procedure cbOvercolorChange(Sender: TObject);
    procedure chkUseCustomViewChange(Sender: TObject);
    procedure ResFontClick(Sender: TObject);
    procedure ResBack2Click(Sender: TObject);
    procedure ResBackClick(Sender: TObject);
    procedure ResCurColClick(Sender: TObject);
    procedure ResMarkClick(Sender: TObject);
    procedure ResTextClick(Sender: TObject);
    procedure ResCurTextClick(Sender: TObject);
    procedure cbBackColor2Change(Sender: TObject);
    procedure cbBackColorChange(Sender: TObject);
    procedure cbCursorColorChange(Sender: TObject);
    procedure cbCursorTextChange(Sender: TObject);
    procedure cbMarkColorChange(Sender: TObject);
    procedure cbTextColorChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miAddColumnClick(Sender: TObject);
    procedure MenuFieldsClick(Sender: TObject);
    procedure pnlCustHeadClick(Sender: TObject);
    procedure pnlPreviewHeadClick(Sender: TObject);
    procedure sneFontSizeChange(Sender: TObject);
    procedure SplitterCustomizeCanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure stgColumnsEditingDone(Sender: TObject);
    procedure stgColumnsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure stgColumnsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure stgColumnsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure stgColumnsSelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);

    {Editors}
    procedure SpinEditExit(Sender: TObject);
    procedure SpinEditChange(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure BitBtnDeleteFieldClick(Sender: TObject);
    procedure BtnCfgClick(Sender: TObject);
    procedure ButtonAddClick(Sender: TObject);
    procedure ComboBoxXSelect(Sender: TObject);
    procedure UpDownXClick(Sender: TObject; Button: TUDBtnType);
    procedure UpDownXChanging(Sender: TObject; var AllowChange: Boolean);
  private
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UpdateColumnClass;
    procedure DGHeaderSized(Sender: TObject;IsColumn: Boolean; Index: Integer);
    { private declarations }
    procedure AddNewField;
    procedure CreateEditingControls;
    procedure EditorSaveResult(Sender: TObject);
    procedure LoadCustColumn(const Index:integer);
    procedure OpenColorsPanel;
    procedure UpdateColorsPanelHeader(const Index: Integer);

  private
    { Editing controls. }
    updWidth: TSpinEdit;
    cbbAlign: TComboBox;
    edtField: TEdit;
    btnAdd: TButton;
    btnDel: TBitBtn;
    updMove: TUpDown;
    btnCfg: TButton;

    ColPrm: TColPrm;
    // Make a custom TColumnsFileViewPreview = class(TColumnsFileView).
    PreviewPan: TColumnsFileView;
    ColumnClass:TPanelColumnsClass;

    IndexRaw: Integer;
    Showed: boolean;
    ColumnClassOwnership: Boolean;
    FUpdating: Boolean;

  public
    function GetColumnsClass: TPanelColumnsClass;
    procedure SetColumnsClass(AColumnsClass: TPanelColumnsClass);
  end;

implementation

{$R *.lfm}

uses
  uLng, uFileSystemFileSource, DCOSUtils, uDCUtils,
  uFileFunctions;

const
  pnlCustHeight: Integer = 154;
  PnlContHeight: Integer = 180;

procedure TfColumnsSetConf.LoadCustColumn(const Index:integer);
begin
  if (Index>=stgColumns.RowCount-1) or (Index<0) then exit;

  IndexRaw:=Index;
  ColPrm:= TColPrm(stgColumns.Objects[6, IndexRaw + 1]);

  FUpdating := True;
  UpdateColorsPanelHeader(IndexRaw);
  edtFont.Text:=ColumnClass.GetColumnFontName(IndexRaw);
  sneFontSize.Value:=ColumnClass.GetColumnFontSize(IndexRaw);
  SetColorInColorBox(cbTextColor, ColumnClass.GetColumnTextColor(IndexRaw));
  SetColorInColorBox(cbBackColor, ColumnClass.GetColumnBackground(IndexRaw));
  SetColorInColorBox(cbBackColor2, ColumnClass.GetColumnBackground2(IndexRaw));
  SetColorInColorBox(cbMarkColor, ColumnClass.GetColumnMarkColor(IndexRaw));
  SetColorInColorBox(cbCursorColor, ColumnClass.GetColumnCursorColor(IndexRaw));
  SetColorInColorBox(cbCursorText, ColumnClass.GetColumnCursorText(IndexRaw));
  cbOvercolor.Checked:=ColumnClass.GetColumnOvercolor(IndexRaw);
  FUpdating := False;
end;

procedure TfColumnsSetConf.EditorSaveResult(Sender: TObject);
begin
  if not FUpdating then
  begin
    if Sender is TSpinEdit then
     stgColumns.Cells[2,(Sender as TSpinEdit).Tag]:=inttostr(updWidth.Value);
    if Sender is TComboBox then
     stgColumns.Cells[3,(Sender as TComboBox).Tag]:=(Sender as TComboBox).Text;
    if Sender is TEdit then
     stgColumns.Cells[4,(Sender as TEdit).Tag]:=(Sender as TEdit).Text;

    UpdateColumnClass;
    UpdateColorsPanelHeader(IndexRaw);
  end;
end;

{ TfColumnsSetConf }

procedure TfColumnsSetConf.UpdateColumnClass;
var i,indx:integer;
    Tit,
    FuncString: string;
    Wid: integer;
    Ali: TAlignment;
 begin
   // Save fields
   ColumnClass.Clear;
   for i:=1 to stgColumns.RowCount-1 do
     begin
       with stgColumns do
         begin
           Tit:=Cells[1,i];
           Wid:=StrToInt(Cells[2,i]);
           Ali:=StrToAlign(Cells[3,i]);
           FuncString:=Cells[4,i];
         end;
       indx:=ColumnClass.Add(Tit,FuncString,Wid,Ali);
       if stgColumns.Objects[6,i]<>nil then
       ColumnClass.SetColumnPrm(Indx,TColPrm(stgColumns.Objects[6,i]));
     end;

  ColumnClass.CustomView:= chkUseCustomView.Checked;
  ColumnClass.SetCursorBorder(cbCursorBorder.Checked);
  ColumnClass.SetCursorBorderColor(cbCursorBorderColor.Selected);
  ColumnClass.Name := edtNameofColumnsSet.Text;

  PreviewPan.UpdateColumnsView;
  PreviewPan.Reload;
end;



procedure TfColumnsSetConf.stgColumnsSelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);

begin
 // Hide '+' button in other columns than 4th (Field contents).
 if (aCol <> 4) and btnAdd.Visible then
   btnAdd.Hide;

 try
  FUpdating := True;
  case aCol of
    0: begin
         // Only show delete button if there is more than one column.
         if (stgColumns.RowCount - stgColumns.FixedRows) > 1 then
         begin
           with btnDel do
             begin
               Height:=stgColumns.RowHeights[aRow];
               Width:=stgColumns.ColWidths[aCol]-2;
               Left:=(Sender as TStringGrid).CellRect(aCol,aRow).Right-Width;
               Top:=(Sender as TStringGrid).CellRect(aCol,aRow).Top;
             end;
           Editor:=btnDel;
         end
         else
           Editor := nil;
       end;

    2: begin
         with updWidth do
           begin
             Left:=(Sender as TStringGrid).CellRect(aCol,aRow).Left;
             Top:=(Sender as TStringGrid).CellRect(aCol,aRow).Top;
             Height:=(Sender as TStringGrid).RowHeights[aRow];
             Width:=(Sender as TStringGrid).ColWidths[aCol];
             Value:=StrToInt((Sender as TStringGrid).Cells[aCol,aRow]);
           end;
         Editor:=updWidth;
       end;
    3: begin
         with cbbAlign do
           begin
             Width:=(Sender as TStringGrid).ColWidths[aCol];
             Left:=(Sender as TStringGrid).CellRect(aCol,aRow).Left;
             Top:=(Sender as TStringGrid).CellRect(aCol,aRow).Top;
             Height:=(Sender as TStringGrid).RowHeights[aRow];
             ItemIndex:=Items.IndexOf((Sender as TStringGrid).Cells[aCol,aRow]);
           end;
         Editor:=cbbAlign;
       end;
    4: begin
         with btnAdd do
           begin
             Width:=20;
             Left:=(Sender as TStringGrid).CellRect(aCol,aRow).Right-Width;
             Top:=(Sender as TStringGrid).CellRect(aCol,aRow).Top;
             Height:=(Sender as TStringGrid).RowHeights[aRow];
             Tag:=aRow;
             Show;
           end;

         with edtField do
           begin
             Width:=(Sender as TStringGrid).ColWidths[aCol];
             Left:=(Sender as TStringGrid).CellRect(aCol,aRow).Left;
             Top:=(Sender as TStringGrid).CellRect(aCol,aRow).Top;
             Height:=(Sender as TStringGrid).RowHeights[aRow];
             Text:=(Sender as TStringGrid).Cells[aCol,aRow];
           end;
         Editor:=edtField;
       end;
    5: begin
         with updMove do
           begin
             Height:=stgColumns.RowHeights[aRow];
             Width:=stgColumns.ColWidths[aCol]-2;
             Min:=-((Sender as TStringGrid).RowCount-1);
             Max:=-1;
             Position:=-aRow;
             Left:=(Sender as TStringGrid).CellRect(aCol,aRow).Right-Width;
             Top:=(Sender as TStringGrid).CellRect(aCol,aRow).Top;
           end;
         Editor:=updMove;
       end;

    6: begin
         with btnCfg do
           begin
            Height:=stgColumns.RowHeights[aRow];
            Width:=stgColumns.ColWidths[aCol]-2;
            Left:=(Sender as TStringGrid).CellRect(aCol,aRow).Right-Width;
            Top:=(Sender as TStringGrid).CellRect(aCol,aRow).Top;
           end;
         Editor:=btnCfg;
       end;
  end;

 finally
   if Assigned(Editor) then
     begin
       Editor.Tag:= aRow;
       Editor.Hint:= IntToStr(aCol);
     end;
   FUpdating := False;
 end;
end;

procedure TfColumnsSetConf.stgColumnsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if (Key=vk_Down) and (stgColumns.Row=stgColumns.RowCount-1) then
    begin
      AddNewField;
    end;
end;

procedure TfColumnsSetConf.stgColumnsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Col, Row: Integer;
begin
  if Y < stgColumns.GridHeight then
  begin
    // Clicked on a cell, allow editing.
    stgColumns.Options := stgColumns.Options + [goEditing];

    // Select clicked column in customize colors panel.
    stgColumns.MouseToCell(X, Y, Col, Row);
    LoadCustColumn(Row - stgColumns.FixedRows);
  end
  else
  begin
    // Clicked not on a cell, disable editing.
    stgColumns.Options := stgColumns.Options - [goEditing];

    if btnAdd.Visible then
      btnAdd.Hide;
  end;
end;

type
  THackStringGrid = class(TCustomStringGrid)
  end;

procedure TfColumnsSetConf.stgColumnsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  iCol: Integer;
  StringGrid: THackStringGrid absolute Sender;
begin
  if (StringGrid.fGridState = gsColSizing) then
    begin
      if StringGrid.EditorMode then
      with StringGrid.Editor do
      begin
        iCol:= StrToInt(Hint);
        Width:= StringGrid.ColWidths[iCol];
        Left:= StringGrid.CellRect(iCol, StringGrid.Row).Left;
      end;
      if btnAdd.Visible then
        btnAdd.Left:= StringGrid.CellRect(4, StringGrid.Row).Right - btnAdd.Width;
    end;
end;

procedure TfColumnsSetConf.EditorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if Key=VK_RETURN then
      begin
         EditorSaveResult(Sender);
         stgColumns.EditorMode:= False;
         Key:=0;
      end;
end;

procedure TfColumnsSetConf.AddNewField;
begin
  stgColumns.RowCount:= stgColumns.RowCount + 1;
  stgColumns.Cells[1,stgColumns.RowCount-1]:= EmptyStr;
  stgColumns.Cells[2,stgColumns.RowCount-1]:= '50';
  stgColumns.Cells[3,stgColumns.RowCount-1]:= '<-';
  stgColumns.Cells[4,stgColumns.RowCount-1]:= '';
  stgColumns.Objects[6,stgColumns.RowCount-1]:= TColPrm.Create;

  UpdateColumnClass;
end;

procedure TfColumnsSetConf.FormCreate(Sender: TObject);
begin
  ColPrm:= nil;
  FUpdating := False;

  ColumnClass:=TPanelColumnsClass.Create;
  ColumnClassOwnership := True;

  // Initialize property storage
  InitPropStorage(Self);
  PreviewPan := TColumnsFileView.Create(pnlPreview, TFileSystemFileSource.Create, mbGetCurrentDir);

  CreateEditingControls;
end;

procedure TfColumnsSetConf.CreateEditingControls;
begin
  // Editing controls are created with no parent-control.
  // TCustomGrid handles their visibility when they are assigned to Editor property.

  btnCfg:=TButton.Create(Self);
  with btnCfg do
   begin
     Caption := rsConfColConfig;
     OnClick := @BtnCfgClick;
   end;

  btnDel:=TBitBtn.Create(Self);
  with btnDel do
   begin
     Glyph.Assign(btnCancel.Glyph);
     Caption := '';
     OnClick := @BitBtnDeleteFieldClick;
   end;

  cbbAlign:=TComboBox.Create(Self);
  with cbbAlign do
   begin
     Style := csDropDownList;
     AddItem('<-',nil);
     AddItem('->',nil);
     AddItem('=',nil);
     OnSelect := @ComboBoxXSelect;
     OnKeyDown := @EditorKeyDown;
   end;

  edtField:=TEdit.Create(Self);
  with edtField do
   begin
     OnExit := @EditExit;
     OnKeyDown := @EditorKeyDown;
   end;

  updMove:=TUpDown.Create(Self);
  with updMove do
   begin
     OnChanging := @UpDownXChanging;
     OnClick := @UpDownXClick;
   end;

  updWidth:=TSpinEdit.Create(Self);
  with updWidth do
   begin
     MinValue := 0;
     MaxValue := 1000;
     OnKeyDown := @EditorKeyDown;
     OnChange := @SpinEditChange;
     OnExit := @SpinEditExit;
  end;


  // Add button displayed in 'Field contents'.
  btnAdd:=TButton.Create(Self);
  with btnAdd do
   begin
     Visible := False;
     Parent := stgColumns; // set Parent, because this control is shown manually in stgColumns
     Caption := '+';
     OnClick := @ButtonAddClick;
   end;
end;

procedure TfColumnsSetConf.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  showed:=false;
  if (ColumnClassOwnership = True) and Assigned(ColumnClass) then
    FreeAndNil(ColumnClass);

  // Free TColPrm objects assigned to each row.
  for i := 0 to stgColumns.RowCount-1 do
  begin
    if Assigned(stgColumns.Objects[6, i]) then
    begin
      (stgColumns.Objects[6, i] as TColPrm).Free;
      stgColumns.Objects[6, i] := nil;
    end;
  end;
end;

procedure TfColumnsSetConf.FormResize(Sender: TObject);
var z,i:integer;
begin
if not showed then exit;
   //Size of content field
    z:=stgColumns.Width;
    for i:=0 to 3 do
     z:=z-stgColumns.ColWidths[i];
    z:=z-stgColumns.ColWidths[5]*stgColumns.ColWidths[6];
    stgColumns.ColWidths[4]:=z;
end;

procedure TfColumnsSetConf.FormShow(Sender: TObject);
var
  I: Integer;
begin

  pnlCustHeadClick(Sender);

  with PreviewPan do
  begin
    ActiveColmSlave:=ColumnClass;
    isSlave:=true;

    //dgPanel.OnHeaderSized:=@DGHeaderSized;
  end;

    if ColumnClass.ColumnsCount>0 then
      begin
        stgColumns.RowCount:=ColumnClass.ColumnsCount+1;
        for i:=0 to ColumnClass.ColumnsCount-1 do
          begin
              stgColumns.Cells[1,i+1]:=ColumnClass.GetColumnTitle(i);
              stgColumns.Cells[2,i+1]:=inttostr(ColumnClass.GetColumnWidth(i));
              stgColumns.Cells[3,i+1]:=ColumnClass.GetColumnAlignString(i);
              stgColumns.Cells[4,i+1]:=ColumnClass.GetColumnFuncString(i);
              stgColumns.Objects[6,i+1]:=ColumnClass.GetColumnPrm(i);
              
          end;
      end
    else
        begin
            stgColumns.RowCount:=1;
            AddNewField;
        end;

    PreviewPan.UpdateColumnsView;

    FUpdating := True;
    chkUseCustomView.Checked:= ColumnClass.CustomView;
    cbCursorBorder.Checked := ColumnClass.GetCursorBorder;
    SetColorInColorBox(cbCursorBorderColor, ColumnClass.GetCursorBorderColor);
    FUpdating := False;

    // Localize StringGrid header
    stgColumns.Cells[0,0]:= rsConfColDelete;
    stgColumns.Cells[1,0]:= rsConfColCaption;
    stgColumns.Cells[2,0]:= rsConfColWidth;
    stgColumns.Cells[3,0]:= rsConfColAlign;
    stgColumns.Cells[4,0]:= rsConfColFieldCont;
    stgColumns.Cells[5,0]:= rsConfColMove;
    stgColumns.Cells[6,0]:= rsOptionsEditorColors;

  LoadCustColumn(0);

  Showed:=true;
end;


procedure TfColumnsSetConf.miAddColumnClick(Sender: TObject);
begin
  AddNewField;
end;

procedure TfColumnsSetConf.SpinEditExit(Sender: TObject);
begin
  EditorSaveResult(Sender);
end;

procedure TfColumnsSetConf.SpinEditChange(Sender: TObject);
begin
EditorSaveResult(Sender);
end;

procedure TfColumnsSetConf.EditExit(Sender: TObject);
begin
  EditorSaveResult(Sender);
end;

procedure TfColumnsSetConf.ComboBoxXSelect(Sender: TObject);
begin
  EditorSaveResult(Sender);
end;

procedure TfColumnsSetConf.UpDownXClick(Sender: TObject; Button: TUDBtnType);
begin
 stgColumns.ExchangeColRow(False,updMove.Tag,abs(updMove.Position));
 with updMove do
   begin
     Left:=stgColumns.CellRect(5,abs(updMove.Position)).Right-Width;
     Top:=stgColumns.CellRect(5,abs(updMove.Position)).Top;
   end;
  EditorSaveResult(Sender);
  LoadCustColumn(abs(updMove.Position) - 1);
end;

procedure TfColumnsSetConf.UpDownXChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  updMove.tag:=abs(updMove.Position);
   EditorSaveResult(Sender);
end;

procedure TfColumnsSetConf.BitBtnDeleteFieldClick(Sender: TObject);
var
  RowNr: Integer;
begin
  RowNr := (Sender as TBitBtn).Tag;

  // Free TColPrm object assigned to the row.
  if Assigned(stgColumns.Objects[6, RowNr]) then
  begin
    (stgColumns.Objects[6, RowNr] as TColPrm).Free;
    stgColumns.Objects[6, RowNr] := nil;
  end;

  stgColumns.DeleteColRow(false, RowNr);
  EditorSaveResult(Sender);

  if RowNr = stgColumns.RowCount then
    // The last row was deleted, load previous column.
    LoadCustColumn(RowNr - stgColumns.FixedRows - 1)
  else
    // Load next column (RowNr will point to it after deleting).
    LoadCustColumn(RowNr - stgColumns.FixedRows);
end;

procedure TfColumnsSetConf.BtnCfgClick(Sender: TObject);
begin
  LoadCustColumn((Sender as TButton).Tag-1);
  OpenColorsPanel;
end;

procedure TfColumnsSetConf.DGHeaderSized(Sender: TObject; IsColumn: Boolean;
  Index: Integer);
begin
{
  stgColumns.Cells[2,Index+1]:=inttostr(PreviewPan.dgPanel.ColWidths[index]);
  ColumnClass.SetColumnWidth(Index,PreviewPan.dgPanel.ColWidths[index])
}
end;

procedure TfColumnsSetConf.btnOkClick(Sender: TObject);
begin
  if edtNameofColumnsSet.Text='' then
     edtNameofColumnsSet.Text:=DateTimeToStr(now);

  UpdateColumnClass;

  case Self.Tag of
  -1: ColSet.Add(ColumnClass);
  else
    begin
      ColSet.DeleteColumnSet(Self.Tag);
      Colset.Insert(Self.Tag,ColumnClass);
    end;
  end;

  // Release ownership of ColumnClass (ColSet is now responsible for it).
  ColumnClassOwnership := False;
end;

procedure TfColumnsSetConf.btnPrevClick(Sender: TObject);
begin
  LoadCustColumn(IndexRaw-1);
  OpenColorsPanel;
end;

procedure TfColumnsSetConf.cbCursorBorderChange(Sender: TObject);
begin
  EditorSaveResult(nil);
end;

procedure TfColumnsSetConf.cbOvercolorChange(Sender: TObject);
begin
  TColPrm(stgColumns.Objects[6,IndexRaw+1]).Overcolor:=cbOvercolor.Checked;
    EditorSaveResult(nil);
end;

procedure TfColumnsSetConf.chkUseCustomViewChange(Sender: TObject);
begin
  pnlCustomView.Enabled:= chkUseCustomView.Checked;
end;

procedure TfColumnsSetConf.ResFontClick(Sender: TObject);
begin
  TColPrm(stgColumns.Objects[6,IndexRaw+1]).FontName:= gFonts[dcfMain].Name;
  TColPrm(stgColumns.Objects[6,IndexRaw+1]).FontSize:= gFonts[dcfMain].Size;
  TColPrm(stgColumns.Objects[6,IndexRaw+1]).FontStyle:= gFonts[dcfMain].Style;
  edtFont.Text:= gFonts[dcfMain].Name;
  sneFontSize.Value:= gFonts[dcfMain].Size;
  EditorSaveResult(nil);
end;
    
procedure TfColumnsSetConf.ResBack2Click(Sender: TObject);
begin
  TColPrm(stgColumns.Objects[6,IndexRaw+1]).Background2:=gBackColor2;
  SetColorInColorBox(cbBackColor2,gBackColor2);
  EditorSaveResult(nil);
end;

procedure TfColumnsSetConf.ResBackClick(Sender: TObject);
begin
  TColPrm(stgColumns.Objects[6,IndexRaw+1]).Background:=gBackColor;
  SetColorInColorBox(cbBackColor,gBackColor);
  EditorSaveResult(nil);
end;

procedure TfColumnsSetConf.ResCurColClick(Sender: TObject);
begin
  TColPrm(stgColumns.Objects[6,IndexRaw+1]).CursorColor:=gCursorColor;
  SetColorInColorBox(cbCursorColor,gCursorColor);
  EditorSaveResult(nil);
end;

procedure TfColumnsSetConf.ResMarkClick(Sender: TObject);
begin
  TColPrm(stgColumns.Objects[6,IndexRaw+1]).MarkColor:=gMarkColor;
  SetColorInColorBox(cbMarkColor,gMarkColor);
  EditorSaveResult(nil);
end;

procedure TfColumnsSetConf.ResTextClick(Sender: TObject);
begin
  TColPrm(stgColumns.Objects[6,IndexRaw+1]).TextColor:=gForeColor;
  SetColorInColorBox(cbTextColor,gForeColor);
  EditorSaveResult(nil);
end;

procedure TfColumnsSetConf.ResCurTextClick(Sender: TObject);
begin
  TColPrm(stgColumns.Objects[6,IndexRaw+1]).CursorText:= gCursorText;
  SetColorInColorBox(cbCursorText, gCursorText);
  EditorSaveResult(nil);
end;

procedure TfColumnsSetConf.cbBackColor2Change(Sender: TObject);
begin
  if Assigned(ColPrm) then
  begin
    ColPrm.Background2:= (Sender as TColorBox).Selected;
    EditorSaveResult(nil);
  end;
end;

procedure TfColumnsSetConf.cbBackColorChange(Sender: TObject);
begin
  if Assigned(ColPrm) then
  begin
    ColPrm.Background:= (Sender as TColorBox).Selected;
    EditorSaveResult(nil);
  end;
end;

procedure TfColumnsSetConf.cbCursorColorChange(Sender: TObject);
begin
  if Assigned(ColPrm) then
  begin
    ColPrm.CursorColor:= (Sender as TColorBox).Selected;
    EditorSaveResult(nil);
  end;
end;

procedure TfColumnsSetConf.cbCursorTextChange(Sender: TObject);
begin
  if Assigned(ColPrm) then
  begin
    ColPrm.CursorText:= (Sender as TColorBox).Selected;
    EditorSaveResult(nil);
  end;
end;

procedure TfColumnsSetConf.cbMarkColorChange(Sender: TObject);
begin
  if Assigned(ColPrm) then
  begin
    ColPrm.MarkColor:= (Sender as TColorBox).Selected;
    EditorSaveResult(nil);
  end;
end;

procedure TfColumnsSetConf.cbTextColorChange(Sender: TObject);
begin
  if Assigned(ColPrm) then
  begin
    ColPrm.TextColor:= (Sender as TColorBox).Selected;
    EditorSaveResult(nil);
  end;
end;

procedure TfColumnsSetConf.cbCursorBorderColorChange(Sender: TObject);
begin
  if Assigned(ColPrm) then
  begin
    EditorSaveResult(nil);
  end;
end;

procedure TfColumnsSetConf.btnCancelClick(Sender: TObject);
begin
  close;
end;

procedure TfColumnsSetConf.btnCursorColorClick(Sender: TObject);
begin
  dlgcolor.Color:= cbCursorColor.Selected;
  if dlgcolor.Execute then
    begin
      SetColorInColorBox(cbCursorColor, dlgcolor.Color);
      TColPrm(stgColumns.Objects[6,IndexRaw+1]).CursorColor:= cbCursorColor.Selected;
      EditorSaveResult(nil);
    end;
end;

procedure TfColumnsSetConf.btnCursorTextClick(Sender: TObject);
begin
  dlgcolor.Color:= cbCursorText.Selected;
  if dlgcolor.Execute then
    begin
      SetColorInColorBox(cbCursorText, dlgcolor.Color);
      TColPrm(stgColumns.Objects[6,IndexRaw+1]).CursorText:= cbCursorText.Selected;
      EditorSaveResult(nil);
    end;
end;

procedure TfColumnsSetConf.btnCursorBorderColorClick(Sender: TObject);
begin
  dlgcolor.Color:= cbCursorBorderColor.Selected;
  if dlgcolor.Execute then
    begin
      SetColorInColorBox(cbCursorBorderColor,dlgcolor.Color);
      EditorSaveResult(nil);
    end;
end;

procedure TfColumnsSetConf.btnBackColorClick(Sender: TObject);
begin
  dlgcolor.Color:= cbBackColor.Selected;
  if dlgcolor.Execute then
    begin
    SetColorInColorBox(cbBackColor,dlgcolor.Color);
      TColPrm(stgColumns.Objects[6,IndexRaw+1]).Background:=cbBackColor.Selected;
      EditorSaveResult(nil);
    end;
end;

procedure TfColumnsSetConf.btnBackColor2Click(Sender: TObject);
begin
  dlgcolor.Color:= cbBackColor2.Selected;
  if dlgcolor.Execute then
    begin
      SetColorInColorBox(cbBackColor2,dlgcolor.Color);
      TColPrm(stgColumns.Objects[6,IndexRaw+1]).Background2:=cbBackColor2.Selected;
      EditorSaveResult(nil);
    end;
end;

procedure TfColumnsSetConf.btnAllTextClick(Sender: TObject);
var i:integer;
begin
for i:= 1 to stgColumns.RowCount-1 do
  case (Sender as TButton).tag of
    0:begin
      TColPrm(stgColumns.Objects[6,i]).FontName :=TColPrm(stgColumns.Objects[6,IndexRaw+1]).FontName;
      TColPrm(stgColumns.Objects[6,i]).FontSize :=TColPrm(stgColumns.Objects[6,IndexRaw+1]).FontSize;
      TColPrm(stgColumns.Objects[6,i]).FontStyle :=TColPrm(stgColumns.Objects[6,IndexRaw+1]).FontStyle;  
    end;
    1:begin
      TColPrm(stgColumns.Objects[6,i]).TextColor :=cbTextColor.Selected;
    end;
    2:begin
      TColPrm(stgColumns.Objects[6,i]).Background :=cbBackColor.Selected;
    end;
    3:begin
      TColPrm(stgColumns.Objects[6,i]).Background2 :=cbBackColor2.Selected;
    end;
    4:begin
      TColPrm(stgColumns.Objects[6,i]).MarkColor :=cbMarkColor.Selected;
    end;
    5:begin
      TColPrm(stgColumns.Objects[6,i]).CursorColor :=cbCursorColor.Selected;
    end;
    6:begin
      TColPrm(stgColumns.Objects[6,i]).CursorText :=cbCursorText.Selected;
    end;
  end;
UpdateColumnClass;
end;

procedure TfColumnsSetConf.btnFontSelectClick(Sender: TObject);
begin
  with TColPrm(stgColumns.Objects[6,IndexRaw+1]) do
    begin
      dlgfont.Font.Name  := FontName;
      dlgfont.Font.Size  := FontSize;
      dlgfont.Font.Style := FontStyle;

      if dlgfont.Execute then
        begin
          edtFont.Text := dlgfont.Font.Name;
          sneFontSize.Value := dlgfont.Font.Size;
          FontName  := dlgfont.Font.Name;
          FontSize  := dlgfont.Font.Size;
          FontStyle := dlgfont.Font.Style;
          EditorSaveResult(nil);
        end;
    end;
end;

procedure TfColumnsSetConf.btnForeColorClick(Sender: TObject);
begin
  dlgcolor.Color:= cbTextColor.Selected;
  if dlgcolor.Execute then
    begin
     SetColorInColorBox(cbTextColor,dlgcolor.Color);

      TColPrm(stgColumns.Objects[6,IndexRaw+1]).TextColor:=cbTextColor.Selected;
      EditorSaveResult(nil);
    end;
end;

procedure TfColumnsSetConf.btnMarkColorClick(Sender: TObject);
begin
  dlgcolor.Color:= cbMarkColor.Selected;
  if dlgcolor.Execute then
    begin
      SetColorInColorBox(cbMarkColor,dlgcolor.Color);
      TColPrm(stgColumns.Objects[6,IndexRaw+1]).MarkColor:=cbMarkColor.Selected;
      EditorSaveResult(nil);
    end;
end;

procedure TfColumnsSetConf.btnNextClick(Sender: TObject);
begin
  LoadCustColumn(IndexRaw+1);
  OpenColorsPanel;
end;

procedure TfColumnsSetConf.MenuFieldsClick(Sender: TObject);
var
  MenuItem: TMenuItem absolute Sender;
begin
  if Length(stgColumns.Cells[1,btnAdd.Tag]) = 0 then
  begin
    if MenuItem.Tag = 0 then
      stgColumns.Cells[1,btnAdd.Tag]:= Copy(MenuItem.Caption, 1, Pos('(', MenuItem.Caption) - 3)
    else
      stgColumns.Cells[1,btnAdd.Tag]:= MenuItem.Caption;
  end;
  case MenuItem.Tag of
    0:  begin
          stgColumns.Cells[4,btnAdd.Tag]:= stgColumns.Cells[4,btnAdd.Tag]+'[DC().'+MenuItem.Hint+'{}] ';
        end;
    1: begin
          stgColumns.Cells[4,btnAdd.Tag]:= stgColumns.Cells[4,btnAdd.Tag]+'[Plugin('+MenuItem.Parent.Caption+').'+MenuItem.Caption+'{}] ';
       end;
    2: begin
          stgColumns.Cells[4,btnAdd.Tag]:= stgColumns.Cells[4,btnAdd.Tag]+'[Plugin('+MenuItem.Parent.Parent.Caption+').'+MenuItem.Parent.Caption+'{' + MenuItem.Caption + '}] ';
       end;
  end;
 EditorSaveResult(Sender);
end;

procedure TfColumnsSetConf.pnlCustHeadClick(Sender: TObject);
begin
    if SplitterCustomize.Height+1>pnlCustCont.Height then
    begin
     //open panel
     if pnlCustHead.Top<250 then SplitterPreview.MoveSplitter(100);
     pnlCustCont.Constraints.MinHeight:=pnlCustHeight;
     pnlCustCont.Constraints.MaxHeight:=pnlCustHeight;
     SplitterCustomize.MoveSplitter(-pnlCustHeight);
    end
  else
    begin
      //Hide panel
      pnlCustCont.Constraints.MinHeight:=1;
      pnlCustCont.Constraints.MaxHeight:=1;
      SplitterCustomize.MoveSplitter(pnlCustCont.Height);
    end;
end;

procedure TfColumnsSetConf.pnlPreviewHeadClick(Sender: TObject);
begin
  if SplitterPreview.Height>pnlPrevCont.Height then
   //open panel
   SplitterPreview.MoveSplitter(-PnlContHeight)
  else
    begin
      //Hide panel
      PnlContHeight:=pnlPrevCont.Height;
      SplitterPreview.MoveSplitter(pnlPrevCont.Height);
    end;
end;

procedure TfColumnsSetConf.sneFontSizeChange(Sender: TObject);
begin
//  edtFont.Font.Size:=sneFontSize.Value;
  TColPrm(stgColumns.Objects[6,IndexRaw+1]).FontSize:=sneFontSize.Value;
UpdateColumnClass;
end;

procedure TfColumnsSetConf.SplitterCustomizeCanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
begin
 { if NewSize=130 then
  Accept:=true
  else
  Accept:=false; }
end;

procedure TfColumnsSetConf.stgColumnsEditingDone(Sender: TObject);
begin
  EditorSaveResult(sender);
end;


procedure TfColumnsSetConf.ButtonAddClick(Sender: TObject);
var
  Point: TPoint;
begin
  // Fill column fields menu
  FillContentFieldMenu(pmFields.Items, @MenuFieldsClick);
  // Show popup menu
  Point.x:= (Sender as TButton).Left - 25;
  Point.y:= (Sender as TButton).Top + (Sender as TButton).Height + 40;
  Point:= ClientToScreen(Point);
  pmFields.PopUp(Point.X, Point.Y);
end;

procedure TfColumnsSetConf.OpenColorsPanel;
begin
  //open pblCustCont if it is hidden
  if SplitterCustomize.Height+1>pnlCustCont.Height then
    pnlCustHeadClick(nil);
end;

procedure TfColumnsSetConf.UpdateColorsPanelHeader(const Index: Integer);
begin
  pnlCustHead.Caption := rsConfCustHeader + ' ' + IntToStr(Index+1) + ': '
                       + #39 + ColumnClass.GetColumnTitle(Index) + #39;
end;

function TfColumnsSetConf.GetColumnsClass: TPanelColumnsClass;
begin
  Result := ColumnClass;
end;

procedure TfColumnsSetConf.SetColumnsClass(AColumnsClass: TPanelColumnsClass);
begin
  ColumnClass.Assign(AColumnsClass);
end;

end.

