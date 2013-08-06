{
   Seksi Commander
   ----------------------------
   Integrated viewer form

   Licence  : GNU GPL v 2.0
   Author   : radek.cervinka@centrum.cz

   contributors:

   Radek Polak
    ported to lazarus:
    changes:
     23.7.
        - fixed: scroll bar had wrong max value until user pressed key (by Radek Polak)
        - fixed: wrong scrolling with scroll bar - now look at ScrollBarVertScroll (by Radek Polak)

   Dmitry Kolomiets
   15.03.08
   changes:
     - Added WLX api support (TC WLX api v 1.8)

   Rustem Rakhimov
   25.04.10
   changes:
     - fullscreen
     - function for edit image
     - slide show
     - some Viwer function

}

unit fViewer;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, ExtCtrls, ComCtrls,
  LCLProc, Menus, Dialogs, ExtDlgs, StdCtrls, Buttons, ColorBox, Spin,
  Grids, ActnList, viewercontrol, GifAnim, fFindView, WLXPlugin, uWLXModule,
  uFileSource, fModView, Types, uThumbnails, uFormCommands, uOSForms;

type

  { TfrmViewer }

  TfrmViewer = class(TAloneForm, IFormCommands)
    actAbout: TAction;
    actCopyFile: TAction;
    actDeleteFile: TAction;
    actMirror: TAction;
    actRotate270: TAction;
    actRotate180: TAction;
    actRotate90: TAction;
    actSaveAs: TAction;
    actStretchImage: TAction;
    actMoveFile: TAction;
    actLoadPrevFile: TAction;
    actLoadNextFile: TAction;
    actReload: TAction;
    actionList: TActionList;
    btnCopyFile1: TSpeedButton;
    btnDeleteFile1: TSpeedButton;
    btnMoveFile1: TSpeedButton;
    btnNext1: TSpeedButton;
    btnPrev1: TSpeedButton;
    btnReload1: TSpeedButton;
    cbSlideShow: TCheckBox;
    ColorBoxPaint: TColorBox;
    ComboBoxWidth: TComboBox;
    ComboBoxPaint: TComboBox;
    DrawPreview: TDrawGrid;
    gboxPaint: TGroupBox;
    gboxView: TGroupBox;
    gboxSlideShow: TGroupBox;
    GifAnim: TGifAnim;
    miReload: TMenuItem;
    miLookBook: TMenuItem;
    miDiv4: TMenuItem;
    miPreview: TMenuItem;
    miScreenshot: TMenuItem;
    miFullScreen: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    gboxHightlight: TGroupBox;
    Image: TImage;
    lblHightlight: TLabel;
    miZoomOut: TMenuItem;
    miZoomIn: TMenuItem;
    miRotate: TMenuItem;
    miMirror: TMenuItem;
    mi270: TMenuItem;
    mi180: TMenuItem;
    mi90: TMenuItem;
    miSearchPrev: TMenuItem;
    miPrint: TMenuItem;
    miSearchNext: TMenuItem;
    pnlFolder: TPanel;
    pnlPreview: TPanel;
    pnlEditFile: TPanel;
    PanelEditImage: TPanel;
    pmiSelectAll: TMenuItem;
    miDiv5: TMenuItem;
    pmiCopy: TMenuItem;
    pnlImage: TPanel;
    pnlText: TPanel;
    miDiv3: TMenuItem;
    miEncoding: TMenuItem;
    miPlugins: TMenuItem;
    miSeparator: TMenuItem;
    pmEditMenu: TPopupMenu;
    SavePictureDialog: TSavePictureDialog;
    sboxImage: TScrollBox;
    btnCutTuImage: TSpeedButton;
    btnResize: TSpeedButton;
    btnUndo: TSpeedButton;
    btnHightlight: TSpeedButton;
    btn270: TSpeedButton;
    btn90: TSpeedButton;
    btnMirror: TSpeedButton;
    btnZoomIn: TSpeedButton;
    btnZoomOut: TSpeedButton;
    btnReload: TSpeedButton;
    btnPaint: TSpeedButton;
    btnFullScreen: TSpeedButton;
    seTimeShow: TSpinEdit;
    btnRedEye: TSpeedButton;
    btnNext: TSpeedButton;
    btnPrev: TSpeedButton;
    btnMoveFile: TSpeedButton;
    btnDeleteFile: TSpeedButton;
    btnCopyFile: TSpeedButton;
    btnGifMove: TSpeedButton;
    btnGifToBmp: TSpeedButton;
    btnNextGifFrame: TSpeedButton;
    btnPrevGifFrame: TSpeedButton;
    Splitter: TSplitter;
    Status: TStatusBar;
    MainMenu: TMainMenu;
    miFile: TMenuItem;
    miPrev: TMenuItem;
    miNext: TMenuItem;
    miView: TMenuItem;
    miExit: TMenuItem;
    miImage: TMenuItem;
    miStretch: TMenuItem;
    miText: TMenuItem;
    miBin: TMenuItem;
    miHex: TMenuItem;
    miWrapText: TMenuItem;
    miAbout: TMenuItem;
    miAbout2: TMenuItem;
    miDiv1: TMenuItem;
    miSearch: TMenuItem;
    miDiv2: TMenuItem;
    miGraphics: TMenuItem;
    miEdit: TMenuItem;
    miSelectAll: TMenuItem;
    miCopyToClipboard: TMenuItem;
    TimerViewer: TTimer;
    ViewerControl: TViewerControl;
    procedure actExecute(Sender: TObject);
    procedure btnCopyMoveFileClick(Sender: TObject);
    procedure btnCutTuImageClick(Sender: TObject);
    procedure btnDeleteFileClick(Sender: TObject);
    procedure btnFullScreenClick(Sender: TObject);
    procedure btnGifMoveClick(Sender: TObject);
    procedure btnGifToBmpClick(Sender: TObject);
    procedure btnPaintHightlight(Sender: TObject);
    procedure btnPrevGifFrameClick(Sender: TObject);
    procedure btnRedEyeClick(Sender: TObject);
    procedure btnResizeClick(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    procedure DrawPreviewDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure DrawPreviewSelection(Sender: TObject; aCol, aRow: Integer);
    procedure DrawPreviewTopleftChanged(Sender: TObject);
    procedure FormCreate(Sender : TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GifAnimMouseEnter(Sender: TObject);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseEnter(Sender: TObject);
    procedure ImageMouseLeave(Sender: TObject);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure ImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure miPreviewClick(Sender: TObject);
    procedure miSaveAsClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure miScreenShotClick(Sender: TObject);
    procedure miFullScreenClick(Sender: TObject);
    procedure miPluginsClick(Sender: TObject);
    procedure miPrintClick(Sender: TObject);
    procedure miSearchNextClick(Sender: TObject);
    procedure miSearchPrevClick(Sender: TObject);
    procedure miZoomClick(Sender: TObject);
    procedure PanelEditImageMouseEnter(Sender: TObject);
    procedure pnlImageResize(Sender: TObject);
    procedure sboxImageMouseEnter(Sender: TObject);
    procedure sboxImageMouseLeave(Sender: TObject);
    procedure sboxImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure btnNextGifFrameClick(Sender: TObject);
    procedure SplitterChangeBounds(Sender: TObject);
    procedure TimerViewerTimer(Sender: TObject);
    procedure ViewerControlMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure frmViewerClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure frmViewerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure miExitClick(Sender: TObject);
    procedure miStretchClick(Sender: TObject);
    procedure miTextClick(Sender: TObject);
    procedure miAbout2Click(Sender: TObject);
    procedure miSearchClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure miProcessClick(Sender: TObject);
    procedure miGraphicsClick(Sender: TObject);
    procedure miCopyToClipboardClick(Sender: TObject);
    procedure miSelectAllClick(Sender: TObject);
    procedure miChangeEncodingClick(Sender:TObject);
    procedure ViewerPositionChanged(Sender:TObject);
    procedure miRotateClick(Sender: TObject);

  private
    FileList: TStringList;
    iActiveFile,
    tmpX, tmpY,
    startX, startY, endX, endY,
    UndoSX, UndoSY, UndoEX, UndoEY,
    cas, i_timer:Integer;
    bAnimation,
    bImage,
    bPlugin,
    bQuickView,
    MDFlag,
    ImgEdit: Boolean;
    FThumbSize: TSize;
    FFindDialog:TfrmFindView;
    FFileSource: IFileSource;
    FLastSearchPos: PtrInt;
    tmp_all: TCustomBitmap;
    FModSizeDialog: TfrmModView;
    FThumbnailManager: TThumbnailManager;
    FBitmapList: TBitmapList;
    FCommands: TFormCommands;

    //---------------------
    WlxPlugins:TWLXModuleList;
    ActivePlugin:Integer;
    //---------------------
    function GetListerRect: TRect;
    function CheckPlugins(const sFileName: UTF8String; bForce: Boolean = False): Boolean;
    function CheckGraphics(const sFileName:String):Boolean;
    function LoadGraphics(const sFileName:String): Boolean;
    procedure AdjustImageSize;
    procedure DoSearch(bQuickSearch: Boolean; bSearchBackwards: Boolean);
    procedure MakeTextEncodingsMenu;
    procedure ActivatePanel(Panel: TPanel);
    procedure ReopenAsTextIfNeeded;
    procedure CheckXY;
    procedure UndoTmp;
    procedure CreateTmp;
    procedure CutToImage;
    procedure Res(W, H: integer);
    procedure RedEyes;
    procedure SaveImageAs (Var sExt: String; senderSave: boolean; Quality: integer);
    procedure CreatePreview(FullPathToFile:string; index:integer; delete: boolean = false);

    property Commands: TFormCommands read FCommands{$IF FPC_FULLVERSION >= 020501} implements IFormCommands{$ENDIF};

  public
    constructor Create(TheOwner: TComponent; aFileSource: IFileSource); overload;
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFile(const aFileName: UTF8String);
    procedure LoadNextFile(const aFileName: UTF8String);
    procedure LoadFile(iIndex:Integer);
    procedure ExitPluginMode;

    {$IF FPC_FULLVERSION < 020501}
    // "implements" does not work in FPC < 2.5.1
    function ExecuteCommand(Command: string; const Params: array of string): TCommandFuncResult;
    function GetCommandCaption(Command: String; CaptionType: TCommandCaptionType): String;
    procedure GetCommandsList(List: TStrings);
    {$ENDIF}

    property QuickView: Boolean read bQuickView write bQuickView;
  published
    // Commands for hotkey manager
    procedure cm_About(const Params: array of string);
    procedure cm_Reload(const Params: array of string);
    procedure cm_LoadNextFile(const Params: array of string);
    procedure cm_LoadPrevFile(const Params: array of string);
    procedure cm_MoveFile(const Params: array of string);
    procedure cm_CopyFile(const Params: array of string);
    procedure cm_DeleteFile(const Params: array of string);
    procedure cm_StretchImage(const Params: array of string);
    procedure cm_SaveAs(const Params: array of string);
    procedure cm_Rotate90(const Params: array of string);
    procedure cm_Rotate180(const Params: array of string);
    procedure cm_Rotate270(const Params: array of string);
    procedure cm_Mirror(const Params: array of string);
  end;

procedure ShowViewer(const FilesToView:TStringList; const aFileSource: IFileSource = nil);

implementation

{$R *.lfm}

uses
  FileUtil, IntfGraphics, Math, uLng, uShowMsg, uGlobs, LCLType, LConvEncoding,
  DCClassesUtf8, uFindMmap, DCStrUtils, uDCUtils, LCLIntf, uDebug, uHotkeyManager,
  uConvEncoding, DCBasicTypes, DCOSUtils, uOSUtils;

const
  HotkeysCategory = 'Viewer';

  // Status bar panels indexes.
  sbpFileName             = 0;
  sbpFileNr               = 1;
  // Text
  sbpPosition             = 2;
  sbpFileSize             = 3;
  sbpTextEncoding         = 4;
  // WLX
  sbpPluginName           = 2;
  // Graphics
  sbpCurrentResolution    = 2;
  sbpFullResolution       = 3;

procedure ShowViewer(const FilesToView:TStringList; const aFileSource: IFileSource);
var
  Viewer: TfrmViewer;
begin
  //DCDebug('ShowViewer - Using Internal');
  Viewer := TfrmViewer.Create(Application, aFileSource);
  Viewer.QuickView:= False;
  Viewer.FileList.Assign(FilesToView);// Make a copy of the list
  Viewer.DrawPreview.RowCount:= Viewer.FileList.Count;
  with Viewer.ViewerControl do
  case gViewerMode of
    1: ViewerMode:= vmText;
    2: ViewerMode:= vmBin;
    3: ViewerMode:= vmHex;
    4: ViewerMode:= vmWrap;
    //5: ViewerMode:= vmBook;
  end;
  Viewer.LoadFile(0);
  Viewer.Show;

  if Viewer.miPreview.Checked then
    begin
      Viewer.miPreview.Checked := not(Viewer.miPreview.Checked);
      Viewer.miPreviewClick(Viewer);
    end;
end;

constructor TfrmViewer.Create(TheOwner: TComponent; aFileSource: IFileSource);
begin
  inherited Create(TheOwner);
  FFileSource := aFileSource;
  FLastSearchPos := -1;
  FThumbnailManager:= nil;
  FBitmapList:= TBitmapList.Create(True);
  FCommands := TFormCommands.Create(Self, actionList);
end;

constructor TfrmViewer.Create(TheOwner: TComponent);
begin
  Create(TheOwner, nil);
end;

destructor TfrmViewer.Destroy;
begin
  FreeThenNil(FileList);
  FreeThenNil(FThumbnailManager);
  inherited Destroy;
  FreeAndNil(WlxPlugins);
  FFileSource := nil; // If this is temp file source, the files will be deleted.
  tmp_all.Free;
end;

procedure TfrmViewer.LoadFile(const aFileName: UTF8String);
var
  i: Integer;
  dwFileAttributes: TFileAttrs;
begin
  dwFileAttributes := mbFileGetAttr(aFileName);

  if dwFileAttributes = faInvalidAttributes then
  begin
    ShowMessage(rsMsgErrNoFiles);
    Exit;
  end;

  FLastSearchPos := -1;
  Caption := aFileName;

  if bQuickView then
  begin
    iActiveFile := 0;
    FileList.Text := aFileName;
  end;

  // Clear text on status bar.
  for i := 0 to Status.Panels.Count - 1 do
    Status.Panels[i].Text := '';

  Screen.Cursor:= crHourGlass;
  try
    if FPS_ISDIR(dwFileAttributes) then
      begin
        ActivatePanel(pnlFolder);
        pnlFolder.Caption:= rsPropsFolder + ': ' + aFileName;
      end
    else
      begin
        if CheckPlugins(aFileName) then
          ActivatePanel(nil)
        else if CheckGraphics(aFileName) and LoadGraphics(aFileName) then
          ActivatePanel(pnlImage)
        else
          begin
            ViewerControl.FileName := aFileName;
            ActivatePanel(pnlText);
          end;

        Status.Panels[sbpFileName].Text:= aFileName;
      end;
  finally
    Screen.Cursor:= crDefault;
  end;
end;

procedure TfrmViewer.LoadNextFile(const aFileName: UTF8String);
begin
  if bPlugin then
    with WlxPlugins.GetWlxModule(ActivePlugin) do
    begin
      if FileParamVSDetectStr(aFileName, False) then
      begin
        if CallListLoadNext(Self.Handle, aFileName, 0) <> LISTPLUGIN_ERROR then
          Exit;
      end;
    end;
  ExitPluginMode;
  LoadFile(aFileName);
end;

procedure TfrmViewer.LoadFile(iIndex: Integer);
begin
  iActiveFile := iIndex;
  LoadFile(FileList.Strings[iIndex]);
  gboxPaint.Visible:=false;
  gboxHightlight.Visible:=false;
  Status.Panels[sbpFileNr].Text:=Format('%d/%d',[iIndex+1,FileList.Count]);
end;

procedure TfrmViewer.FormKeyPress(Sender: TObject; var Key: Char);
begin
  // The following keys work only in QuickView mode because there is no menu there.
  // Otherwise this function is never called for those keys
  // because the menu shortcuts are automatically used.
  if bQuickView then
    case Key of
      'N', 'n':
        begin
          cm_LoadNextFile([]);
          Key := #0;
        end;
      'P', 'p':
        begin
          cm_LoadPrevFile([]);
          Key := #0;
        end;
      '1':
        begin
          miTextClick(Sender);
          Key := #0;
        end;
      '2':
        begin
          miTextClick(miBin);
          Key := #0;
        end;
      '3':
        begin
          miTextClick(miHex);
          Key := #0;
        end;
      '4':
        begin
          miTextClick(miWrapText);
          Key := #0;
        end;
    end;
end;

procedure TfrmViewer.FormResize(Sender: TObject);
begin
  if bPlugin then WlxPlugins.GetWlxModule(ActivePlugin).ResizeWindow(GetListerRect);
end;

procedure TfrmViewer.FormShow(Sender: TObject);
begin
{$IF DEFINED(LCLGTK2)}
  if not pnlPreview.Visible then
  begin
    pnlPreview.Visible:= True;
    pnlPreview.Visible:= False;
  end;
{$ENDIF}
end;

procedure TfrmViewer.GifAnimMouseEnter(Sender: TObject);
begin
  if miFullScreen.Checked then TimerViewer.Enabled:=true;
end;

procedure TfrmViewer.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MDFlag := true;
  X:=round(X*Image.Picture.Width/Image.Width);                  // for correct paint after zoom
  Y:=round(Y*Image.Picture.Height/Image.Height);
  cas:=0;
    if (button = mbLeft) and gboxHightlight.Visible then
       begin
         if (X>StartX) and (X<=StartX+10) then
            begin
              if (Y>StartY) and (Y<=StartY+10) then begin
                                                 cas:=1;
                                                 tmpX:=X-StartX;
                                                 tmpY:=Y-StartY;
                                                 end;
              if (Y>StartY+10) and (Y<=EndY-10) then begin
                                                  cas:=2;
                                                  tmpX:=X-StartX;
                                                  end;
              if (Y>EndY-9) and (Y<=EndY) then begin
                                            cas:=3;
                                            tmpX:=X-StartX;
                                            tmpY:=EndY-Y;
                                            end;
              if (Y<StartY) or (Y>EndY) then cas:=0;
            end;
         if (X>StartX+10) and (X<=EndX-10) then
            begin
              if (Y>StartY) and (Y<=StartY+10) then begin
                                                    cas:=4;
                                                    tmpY:=Y-StartY;
                                                    end;
              if (Y>StartY+10) and (Y<=EndY-10)then begin
                                                    cas:=5;
                                                    tmpX:=X-StartX;
                                                    tmpY:=Y-StartY;
                                                    end;
              if (Y>EndY-9) and (Y<=EndY) then begin
                                               cas:=6;
                                               tmpY:=EndY-Y;
                                               end;
              If (Y<StartY) or (Y>EndY) then cas:=0;
            end;
         if (X>EndX-10) and (X<=EndX) then
            begin
              if (Y>StartY) and (Y<=StartY+10) then begin
                                                    cas:=7;
                                                    tmpX := EndX-X;
                                                    tmpY:=StartY-Y;
                                                    end;
              if (Y>StartY+10) and (Y<=EndY-10) then begin
                                                     cas:=8;
                                                     tmpX := EndX-X;
                                                     end;
              if (Y>EndY-9) and (Y<=EndY) then begin
                                               cas:=9;
                                               tmpX := EndX-X;
                                               tmpY:=EndY-Y;
                                               end;
              If (Y<StartY) or (Y>EndY) then cas:=0;
            end;
         if (X<StartX) or (X>EndX) then cas:=0;
        end;
    if cas=0 then
         begin
           StartX := X;
           StartY := Y;
         end;

    if gboxPaint.Visible then
      begin
        CreateTmp;
        Image.Picture.Bitmap.Canvas.MoveTo (x,y);
    end;
  if not (gboxHightlight.Visible) and not (gboxPaint.Visible) then
    begin
    tmpX:=x;
    tmpY:=y;
    Image.Cursor:=crHandPoint;
    end;
end;

procedure TfrmViewer.ImageMouseEnter(Sender: TObject);
begin
  if miFullScreen.Checked then TimerViewer.Enabled:=true;
end;

procedure TfrmViewer.ImageMouseLeave(Sender: TObject);
begin
  if miFullScreen.Checked then TimerViewer.Enabled:=false;
end;

procedure TfrmViewer.ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  tmp: integer;
begin
  if gboxHightlight.Visible then Image.Cursor:=crCross;
  if miFullScreen.Checked then
    begin
      sboxImage.Cursor:=crDefault;
      Image.Cursor:=crDefault;
      i_timer:=0;
    end;
  X:=round(X*Image.Picture.Width/Image.Width);                      // for correct paint after zoom
  Y:=round(Y*Image.Picture.Height/Image.Height);
  if MDFlag then
        begin
      if gboxHightlight.Visible then
        begin
            if cas=0 then
            begin
              EndX:=X;
              EndY:=Y;
            end;
            if cas=1 then
            begin
              StartX:= X-tmpX;
              StartY:=Y-tmpY;
            end;
            if cas=2 then StartX:= X-tmpX;
            if cas=3then
            begin
              StartX:= X-tmpX;
              EndY:=Y+tmpY;
            end;
            if cas=4 then StartY:=Y-tmpY;
            if cas=5 then
            begin
              tmp:=EndX-StartX;
              StartX:= X-tmpX;
              EndX:=StartX+tmp;
              tmp:=EndY-StartY;
              StartY:= Y-tmpY;
              EndY:=StartY+tmp;
            end;
            if cas=6 then EndY:=Y+tmpY;
            if cas=7 then
            begin
              EndX:=X+tmpX;
              StartY:=Y-tmpY;
            end;
            if cas=8 then endX:=X+tmpX;
            if cas=9 then
            begin
              EndX:=X+tmpX;
              EndY:=Y+tmpY;
            end;
            if StartX<0 then
              begin
                StartX:=0;
                EndX:= UndoEX;
              end;
            if StartY<0 then
              begin
                StartY:=0;
                EndY:= UndoEY;
              end;
            if endX> Image.Picture.Width then endX:=Image.Picture.Width;
            if endY> Image.Picture.Height then endY:=Image.Picture.Height;
            with Image.Picture.Bitmap.Canvas do
              begin
                DrawFocusRect(Rect(UndoSX,UndoSY,UndoEX,UndoEY));
                DrawFocusRect(Rect(UndoSX+10,UndoSY+10,UndoEX-10,UndoEY-10));
                DrawFocusRect(Rect(StartX,StartY,EndX,EndY));
                DrawFocusRect(Rect(StartX+10,StartY+10,EndX-10,EndY-10));//Pen.Mode := pmNotXor;
                lblHightlight.Caption := IntToStr(EndX-StartX)+'x'+IntToStr(EndY-StartY);
                UndoSX:=StartX;
                UndoSY:=StartY;
                UndoEX:=EndX;
                UndoEY:=EndY;
              end;
          end;
        if gboxPaint.Visible then
        begin
          with Image.Picture.Bitmap.Canvas do
          begin
            Brush.Style:= bsClear;
            Pen.Width := StrToInt(ComboBoxWidth.Text);
            Pen.Color := ColorBoxPaint.Selected;
            Pen.Style := psSolid;
            tmp:= Pen.Width+10;
            if ComboBoxPaint.text='Pen' then LineTo (x,y)
            else
              begin
                if (startX>x) and (startY<y) then
                CopyRect (Rect(UndoSX+tmp,UndoSY-tmp,UndoEX-tmp,UndoEY+tmp), tmp_all.canvas,Rect(UndoSX+tmp,UndoSY-tmp,UndoEX-tmp,UndoEY+tmp));
                if (startX<x) and (startY>y) then
                CopyRect (Rect(UndoSX-tmp,UndoSY+tmp,UndoEX+tmp,UndoEY-tmp), tmp_all.canvas,Rect(UndoSX-tmp,UndoSY+tmp,UndoEX+tmp,UndoEY-tmp));
                if (startX>x) and (startY>y) then
                CopyRect (Rect(UndoSX+tmp,UndoSY+tmp,UndoEX-tmp,UndoEY-tmp), tmp_all.canvas,Rect(UndoSX+tmp,UndoSY+tmp,UndoEX-tmp,UndoEY-tmp))
                else
                CopyRect (Rect(UndoSX-tmp,UndoSY-tmp,UndoEX+tmp,UndoEY+tmp), tmp_all.canvas,Rect(UndoSX-tmp,UndoSY-tmp,UndoEX+tmp,UndoEY+tmp));//UndoTmp;
                if ComboBoxPaint.text='Rect' then Rectangle(Rect(StartX,StartY,X,Y))else Ellipse(StartX,StartY,X,Y);
              end;
            UndoSX:=StartX;
            UndoSY:=StartY;
            UndoEX:=X;
            UndoEY:=Y;
          end;
        end;
      if not (gboxHightlight.Visible) and not (gboxPaint.Visible) then
    begin
      sboxImage.VertScrollBar.Position:=sboxImage.VertScrollBar.Position+tmpY-y;
      sboxImage.HorzScrollBar.Position:=sboxImage.HorzScrollBar.Position+tmpX-x;
    end;
  end;
end;

procedure TfrmViewer.ImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  X:=round(X*Image.Picture.Width/Image.Width);             // for correct paint after zoom
  Y:=round(Y*Image.Picture.Height/Image.Height);
  MDFlag:=false;
  if PanelEditImage.Visible then
    begin
      if (button = mbLeft) and gboxHightlight.Visible then
    begin
      UndoTmp;
      CheckXY;
      with Image.Picture.Bitmap.Canvas do
      begin
        Brush.Style := bsClear;
        Pen.Style := psDot;
        Pen.Color := clHighlight;
        DrawFocusRect(Rect(StartX,StartY,EndX,EndY));
        DrawFocusRect(Rect(StartX+10,StartY+10,EndX-10,EndY-10));
        lblHightlight.Caption := IntToStr(EndX-StartX)+'x'+IntToStr(EndY-StartY);
      end;
    end;
    end;
  Image.Cursor:=crDefault;
end;

procedure TfrmViewer.CreatePreview(FullPathToFile: String; index: integer; delete: Boolean = false);
var
  bmpThumb : TBitmap = nil;
begin
  if pnlPreview.Visible or delete then
    begin
      if not Assigned(FThumbnailManager) then
        FThumbnailManager:= TThumbnailManager.Create(DrawPreview.Canvas.Brush.Color);
      if delete then
        begin
          FThumbnailManager.RemovePreview(FullPathToFile); // delete thumb if need
          if pnlPreview.Visible then FBitmapList.Delete(index);
        end
      else
        begin
          bmpThumb:= FThumbnailManager.CreatePreview(FullPathToFile);
          // Insert to the BitmapList
          FBitmapList.Insert(index, bmpThumb);
        end;
    end;
end;

procedure TfrmViewer.miPreviewClick(Sender: TObject);
var
  i: integer;
begin
  miPreview.Checked:= not (miPreview.Checked);
  pnlPreview.Visible := miPreview.Checked;
  Splitter.Visible := pnlPreview.Visible;
  if not pnlPreview.Visible then
    FBitmapList.Clear;
  Application.ProcessMessages;
  if miPreview.Checked then
   begin
     for i:=0 to FileList.Count-1 do
     CreatePreview(FileList.Strings[i], i);
     DrawPreview.FixedRows:= 0;
     DrawPreview.FixedCols:= 0;
     DrawPreview.Refresh;
   end;
  if bPlugin then WlxPlugins.GetWlxModule(ActivePlugin).ResizeWindow(GetListerRect);
end;

procedure TfrmViewer.miSaveAsClick(Sender: TObject);
begin
  FModSizeDialog:= TfrmModView.Create(Application);
  try
    FModSizeDialog.pnlSize.Visible:=false;
    FModSizeDialog.pnlCopyMoveFile.Visible :=false;
    FModSizeDialog.pnlQuality.Visible:=true;
    FModSizeDialog.Caption:='Type of Image';
    if FModSizeDialog.ShowModal = mrOk then
    begin
      if StrToInt(FModSizeDialog.teQuality.Text)<=100 then
        SaveImageAs(FModSizeDialog.sExt,false,StrToInt(FModSizeDialog.teQuality.Text))
      else
        msgError('Bad Quality');
    end
  finally
    FreeAndNil(FModSizeDialog);
  end;
end;

procedure TfrmViewer.miSaveClick(Sender: TObject);
var
  sExt: String;
begin
  DrawPreview.BeginUpdate;
  try
    CreatePreview(FileList.Strings[iActiveFile], iActiveFile, True);
    sExt:= ExtractFileExt(FileList.Strings[iActiveFile]);
    SaveImageAs(sExt, True, 80);
    CreatePreview(FileList.Strings[iActiveFile], iActiveFile);
  finally
    DrawPreview.EndUpdate;
  end;
end;

procedure TfrmViewer.miFullScreenClick(Sender: TObject);
begin
  miFullScreen.Checked:= not (miFullScreen.Checked);
  if miFullScreen.Checked then
    begin
      WindowState:= wsMaximized;
      BorderStyle:= bsNone;
      MainMenu.Items.Visible:=false;
      gboxPaint.Visible:= false;
      gboxHightlight.Visible:=false;
      miStretch.Checked:= miFullScreen.Checked;
      if miPreview.Checked then
        miPreviewClick(Sender);
    end
  else
    begin
      WindowState:= wsNormal;
      BorderStyle:= bsSizeable;
      //Viewer.MainMenu.Items.Visible:=true;            // why it work ???
      PanelEditImage.Height:= 50;
      Height:= Height div 2;
      Width:= Width div 2;
    end;
  if ExtractOnlyFileExt(FileList.Strings[iActiveFile]) <> 'gif' then
    begin
      btnHightlight.Visible:=not(miFullScreen.Checked);
      btnPaint.Visible:=not(miFullScreen.Checked);
      btnResize.Visible:=not(miFullScreen.Checked);
    end;
  sboxImage.HorzScrollBar.Visible:= not(miFullScreen.Checked);
  sboxImage.VertScrollBar.Visible:= not(miFullScreen.Checked);
  TimerViewer.Enabled:=miFullScreen.Checked;
  btnReload.Visible:=not(miFullScreen.Checked);
  Status.Visible:=not(miFullScreen.Checked);
  gboxSlideShow.Visible:=miFullScreen.Checked;

  Image.Stretch:= miFullScreen.Checked;
  Image.AutoSize:= not Image.Stretch;
  Image.Proportional:= Image.Stretch;
  AdjustImageSize;
  ShowOnTop;
end;

procedure TfrmViewer.RedEyes;
var
  tmp:TBitMap;
  x,y,r,g,b: integer;
  col: TColor;
begin
  if (EndX=StartX) or (EndY=StartY) then Exit;
  UndoTmp;
  tmp:=TBitMap.Create;
  tmp.Width:= EndX-StartX;
  tmp.Height:= EndY-StartY;
  for x:=0 to (EndX-StartX) div 2 do
     begin
       for y:=0 to (EndY-StartY) div 2  do
          begin
          if y<round(sqrt((1-(sqr(x)/sqr((EndX-StartX)/2)))*sqr((EndY-StartY)/2))) then
            begin
            col:=Image.Picture.Bitmap.Canvas.Pixels[x+StartX+(EndX-StartX) div 2,y+StartY+(EndY-StartY) div 2];
            r:=GetRValue(col);
            g:=GetGValue(col);
            b:=GetBValue(col);
            if (r>100) and (g<100) and (b<100) then r:=b;
            tmp.Canvas.Pixels[x+(EndX-StartX) div 2,y+(EndY-StartY) div 2]:= rgb(r,g,b);

            col:=Image.Picture.Bitmap.Canvas.Pixels[StartX-x+(EndX-StartX) div 2,y+StartY+(EndY-StartY) div 2];
            r:=GetRValue(col);
            g:=GetGValue(col);
            b:=GetBValue(col);
            if (r>100) and (g<100) and (b<100) then r:=b;
            tmp.Canvas.Pixels[(EndX-StartX) div 2-x,y+(EndY-StartY) div 2]:= rgb(r,g,b);

            col:=Image.Picture.Bitmap.Canvas.Pixels[StartX+x+(EndX-StartX) div 2,StartY-y+(EndY-StartY) div 2];
            r:=GetRValue(col);
            g:=GetGValue(col);
            b:=GetBValue(col);
            if (r>100) and (g<100) and (b<100) then r:=b;
            tmp.Canvas.Pixels[(EndX-StartX) div 2+x,(EndY-StartY) div 2-y]:= rgb(r,g,b);

            col:=Image.Picture.Bitmap.Canvas.Pixels[StartX-x+(EndX-StartX) div 2,StartY-y+(EndY-StartY) div 2];
            r:=GetRValue(col);
            g:=GetGValue(col);
            b:=GetBValue(col);
            if (r>100) and (g<100) and (b<100) then r:=b;
            tmp.Canvas.Pixels[(EndX-StartX) div 2-x,(EndY-StartY) div 2-y]:= rgb(r,g,b);
          end
       else
          begin
            col:=Image.Picture.Bitmap.Canvas.Pixels[x+StartX+(EndX-StartX) div 2,y+StartY+(EndY-StartY) div 2];
            tmp.Canvas.Pixels[x+(EndX-StartX) div 2,y+(EndY-StartY) div 2]:= col;

            col:=Image.Picture.Bitmap.Canvas.Pixels[StartX-x+(EndX-StartX) div 2,y+StartY+(EndY-StartY) div 2];
            tmp.Canvas.Pixels[(EndX-StartX) div 2-x,y+(EndY-StartY) div 2]:= col;

            col:=Image.Picture.Bitmap.Canvas.Pixels[StartX+x+(EndX-StartX) div 2,StartY-y+(EndY-StartY) div 2];
            tmp.Canvas.Pixels[(EndX-StartX) div 2+x,(EndY-StartY) div 2-y]:= col;

            col:=Image.Picture.Bitmap.Canvas.Pixels[StartX-x+(EndX-StartX) div 2,StartY-y+(EndY-StartY) div 2];
            tmp.Canvas.Pixels[(EndX-StartX) div 2-x,(EndY-StartY) div 2-y]:= col;
          end;
          end;
     end;
  Image.Picture.Bitmap.Canvas.Draw (StartX,StartY,tmp);
  CreateTmp;
  tmp.Free;
end;

procedure TfrmViewer.CutToImage;
begin
  UndoTmp;
  Image.Picture.Bitmap.Canvas.CopyRect(rect(0,0,EndX-StartX,EndY-StartY), Image.Picture.Bitmap.Canvas, rect(startX,StartY,EndX,EndY));
  Image.Picture.Bitmap.SetSize (EndX-StartX,EndY-StartY);
  CreateTmp;
  StartX:=0;StartY:=0;EndX:=0;EndY:=0;
end;

procedure TfrmViewer.UndoTmp;
begin
  Image.Picture.Bitmap.Canvas.Clear;
  Image.Picture.Bitmap.Canvas.Draw(0,0,tmp_all);
end;

procedure TfrmViewer.CreateTmp;
begin
  tmp_all.Free;
  tmp_all:= TBitmap.Create;
  tmp_all.Assign(Image.Picture.Graphic);
end;

procedure TfrmViewer.CheckXY;
var
  tmp: integer;
begin
  if EndX<StartX then
    begin
      tmp:=StartX;
      StartX:=EndX;
      EndX:=tmp
    end;
  if EndY<StartY then
    begin
      tmp:=StartY;
      StartY:=EndY;
      EndY:=tmp
    end;
end;

procedure TfrmViewer.Res (W, H: integer);
var
  tmp: TCustomBitmap;
  r: TRect;
begin
  if gboxHightlight.Visible then UndoTmp;
  tmp:= TBitmap.Create;
  tmp.Assign(Image.Picture.Graphic);
  r := Rect(0, 0, W, H);
  Image.Picture.Bitmap.SetSize(W,H);
  Image.Picture.Bitmap.Canvas.Clear;
  Image.Picture.Bitmap.Canvas.StretchDraw(r, tmp);
  tmp.free;
  CreateTmp;
  StartX:=0;
  StartY:=0;
  EndX:=0;
  EndY:=0;
end;

function TfrmViewer.CheckPlugins(const sFileName: UTF8String; bForce: Boolean = False): Boolean;
var
  I: Integer;
  ShowFlags: Integer;
  WlxModule: TWlxModule;
begin
  ShowFlags:= IfThen(bForce, lcp_forceshow, 0);
  // DCDebug('WlXPlugins.Count = ' + IntToStr(WlxPlugins.Count));
  for I:= 0 to WlxPlugins.Count - 1 do
  if WlxPlugins.GetWlxModule(I).FileParamVSDetectStr(sFileName, bForce) then
  begin
    DCDebug('I = ' + IntToStr(I));
    if not WlxPlugins.LoadModule(I) then Continue;
    WlxModule:= WlxPlugins.GetWlxModule(I);
    DCDebug('WlxModule.Name = ', WlxModule.Name);
    if WlxModule.CallListLoad(Self.Handle, sFileName, ShowFlags) = 0 then
    begin
      WlxModule.UnloadModule;
      Continue;
    end;
    ActivePlugin:= I;
    WlxModule.ResizeWindow(GetListerRect);
    miPrint.Enabled:= WlxModule.CanPrint;
    // Set focus to plugin window
    if not bQuickView then WlxModule.SetFocus;
    Exit(True);
  end;
  // Plugin not found
  ActivePlugin:= -1;
  Result:= False;
end;

procedure TfrmViewer.ExitPluginMode;
begin
  if (WlxPlugins.Count > 0) and (ActivePlugin >= 0) then
  begin
    WlxPlugins.GetWlxModule(ActivePlugin).CallListCloseWindow;
  end;
  bPlugin:= False;
  ActivePlugin:= -1;
  miPrint.Enabled:= False;
end;

procedure TfrmViewer.miPluginsClick(Sender: TObject);
begin
  bPlugin:= CheckPlugins(FileList.Strings[iActiveFile], True);
  if bPlugin then
    ActivatePanel(nil)
  else
    ViewerControl.FileName := FileList.Strings[iActiveFile];
end;

procedure TfrmViewer.miPrintClick(Sender: TObject);
var
  aRect: TRect;
begin
  if bPlugin then
  begin
    aRect:= GetListerRect;
    WlxPlugins.GetWlxModule(ActivePlugin).CallListPrint(FileList[iActiveFile], EmptyStr, 0, aRect);
  end;
end;

procedure TfrmViewer.SaveImageAs(var sExt: String; senderSave: boolean; Quality: integer);
var
  sFileName: string;
  ico : TIcon = nil;
  jpg : TJpegImage = nil;
  pnm : TPortableAnyMapGraphic = nil;
  fsFileStream: TFileStreamEx = nil;
begin
  if senderSave then
    sFileName:= FileList.Strings[iActiveFile]
  else
    begin
      if not SavePictureDialog.Execute then Exit;
      sFileName:= ChangeFileExt(SavePictureDialog.FileName, sExt);
    end;

  try
    fsFileStream:= TFileStreamEx.Create(sFileName, fmCreate);
    if (sExt = '.jpg') or (sExt = '.jpeg') then
      begin
        jpg := TJpegImage.Create;
        try
          jpg.Assign(Image.Picture.Graphic);
          jpg.CompressionQuality := Quality;
          jpg.SaveToStream(fsFileStream);
        finally
          jpg.Free;
        end;
      end;
    if sExt = '.ico' then
      begin
        ico := TIcon.Create;
        try
          ico.Assign(Image.Picture.Graphic);
          ico.SaveToStream(fsFileStream);
        finally
          ico.Free;
        end;
      end;
    if sExt = '.pnm' then
      begin
        pnm := TPortableAnyMapGraphic.Create;
        try
          pnm.Assign(Image.Picture.Graphic);
          pnm.SaveToStream(fsFileStream);
        finally
          pnm.Free;
        end;
      end;
    if (sExt = '.png') or (sExt = '.bmp') then
      begin
        Image.Picture.SaveToStreamWithFileExt(fsFileStream, sExt);
      end;
  finally
    FreeThenNil(fsFileStream);
  end;
end;

procedure TfrmViewer.miSearchNextClick(Sender: TObject);
begin
  DoSearch(True, False);
end;

procedure TfrmViewer.miSearchPrevClick(Sender: TObject);
begin
  DoSearch(True, True);
end;

procedure TfrmViewer.miZoomClick(Sender: TObject);
begin
  miStretch.Checked := false;
  Image.Stretch:=true;
  Image.Proportional:=true;
  Image.AutoSize := false;
  if (sender=miZoomIn) or (sender=btnZoomIn)
  then
    begin
      Image.Width:= Image.Width + round(0.118*Image.Picture.Width);
      Image.Height:= Image.Height + round(0.118*Image.Picture.Height);
    end
  else
    begin
     Image.Width:= Image.Width-Round(0.1333*Image.Width);
     Image.Height:= Image.Height-Round(0.133*Image.Height);
    end;
  AdjustImageSize;
end;

procedure TfrmViewer.PanelEditImageMouseEnter(Sender: TObject);
begin
  if miFullScreen.Checked then PanelEditImage.Height:= 50;
end;

procedure TfrmViewer.pnlImageResize(Sender: TObject);
begin
  if bImage then AdjustImageSize;
end;

procedure TfrmViewer.sboxImageMouseEnter(Sender: TObject);
begin
  if miFullScreen.Checked then TimerViewer.Enabled:=true;
end;

procedure TfrmViewer.sboxImageMouseLeave(Sender: TObject);
begin
  if miFullScreen.Checked then TimerViewer.Enabled:=false;
end;

procedure TfrmViewer.sboxImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if miFullScreen.Checked then
  begin
    sboxImage.Cursor:=crDefault;
    Image.Cursor:=crDefault;
    i_timer:=0;
  end;
end;

procedure TfrmViewer.btnNextGifFrameClick(Sender: TObject);
begin
  GifAnim.Animate:=false;
  GifAnim.NextFrame;
end;

procedure TfrmViewer.SplitterChangeBounds(Sender: TObject);
begin
  if DrawPreview.Width div (DrawPreview.DefaultColWidth+6)>0 then
    DrawPreview.ColCount:= DrawPreview.Width div (DrawPreview.DefaultColWidth + 6);
  if FileList.Count mod DrawPreview.ColCount > 0 then
    DrawPreview.RowCount:= FileList.Count div DrawPreview.ColCount + 1
  else
    DrawPreview.RowCount:= FileList.Count div DrawPreview.ColCount;
  if bPlugin then WlxPlugins.GetWlxModule(ActivePlugin).ResizeWindow(GetListerRect);
end;

procedure TfrmViewer.DrawPreviewDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  i,z,t, X, Y: Integer;
  sExt, sName, shortName: UTF8String;
  bmpThumb: TBitmap;
begin
  aRect:= Classes.Rect(aRect.Left + 2, aRect.Top + 2, aRect.Right - 2, aRect.Bottom - 2);
  i:= (aRow * DrawPreview.ColCount) + aCol; // Calculate FileList index
  if (i >= 0) and (i < FileList.Count) then
    begin
      sName:= ExtractOnlyFileName(FileList.Strings[i]);
      sExt:= ExtractFileExt(FileList.Strings[i]);
      DrawPreview.Canvas.FillRect(aRect); // Clear cell
      if (i >= 0) and (i < FBitmapList.Count) then
        begin
          bmpThumb:= FBitmapList[i];
          z:= DrawPreview.Canvas.TextHeight('Pp') + 4;
          X:= aRect.Left + (aRect.Right - aRect.Left - bmpThumb.Width) div 2;
          Y:= aRect.Top + (aRect.Bottom - aRect.Top - bmpThumb.Height - z) div 2;
          // Draw thumbnail at center
          DrawPreview.Canvas.Draw(X, Y, bmpThumb);
        end;
      z:= (DrawPreview.Width - DrawPreview.ColCount * DrawPreview.DefaultColWidth) div DrawPreview.ColCount div 2;
      if DrawPreview.Canvas.GetTextWidth(sName+sExt) < DrawPreview.DefaultColWidth then
        begin
          t:= (DrawPreview.DefaultColWidth-DrawPreview.Canvas.GetTextWidth(sName+sExt)) div 2;
          DrawPreview.Canvas.TextOut(aRect.Left+z+t, aRect.Top + FThumbSize.cy + 2, sName+sExt);
        end
      else
        begin
          shortName:= '';
          t:= 1;
          while DrawPreview.Canvas.GetTextWidth(shortName+'...'+sExt) < (DrawPreview.DefaultColWidth-15) do
            begin
              shortName:= shortName + sName[t];
              Inc(t);
            end;
          DrawPreview.Canvas.TextOut(aRect.Left+z, aRect.Top + FThumbSize.cy + 2, shortName+'...'+sExt);
        end;
    end;
end;

procedure TfrmViewer.DrawPreviewSelection(Sender: TObject; aCol, aRow: Integer);
var
  I: Integer;
begin
  gboxHightlight.Visible:= False;
  gboxPaint.Visible:= False;
  I:= DrawPreview.Row * DrawPreview.ColCount + DrawPreview.Col;
  if I < Filelist.Count then LoadNextFile(FileList.Strings[I]);
end;

procedure TfrmViewer.DrawPreviewTopleftChanged(Sender: TObject);
begin
  DrawPreview.LeftCol:= 0;
end;

procedure TfrmViewer.TimerViewerTimer(Sender: TObject);
begin
  if (miFullScreen.Checked) and (PanelEditImage.Height>3) then
  PanelEditImage.Height := PanelEditImage.Height-1;
  i_timer:=i_timer+1;
  if (cbSlideShow.Checked) and (i_timer=60*seTimeShow.Value) then
    begin
     cm_LoadNextFile([]);
     i_timer:=0;
    end;
  if i_timer=180 then
    begin
     sboxImage.Cursor:=crNone;
     Image.Cursor:=crNone;
    end;
end;

procedure TfrmViewer.ViewerControlMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    pmEditMenu.PopUp();
end;

procedure TfrmViewer.frmViewerClose(Sender: TObject;
                                    var CloseAction: TCloseAction);
begin
  CloseAction:=caFree;
  gImageStretch:= miStretch.Checked;
  gPreviewVisible := miPreview.Checked;
  gImagePaintMode := ComboBoxPaint.text;
  gImagePaintWidth := StrToInt(ComboBoxWidth.Text) ;
  gImagePaintColor := ColorBoxPaint.Selected;
  gTextPosition := ViewerControl.Position;
  case ViewerControl.ViewerMode of
    vmText: gViewerMode := 1;
    vmBin : gViewerMode := 2;
    vmHex : gViewerMode := 3;
    vmWrap: gViewerMode := 4;
    vmBook: gViewerMode := 4;
  end;

  if Assigned(WlxPlugins) then
     begin
       ExitPluginMode;
     end;
end;

procedure TfrmViewer.frmViewerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (not bQuickView) and (Key in [VK_Q, VK_ESCAPE]) then
  begin
    Key := 0;
    Close;
    Exit;
  end;

  if (not (bImage or bAnimation)) then
    case Key of
      VK_F:
        if Shift = [ssCtrl] then
        begin
          DoSearch(False, False);
          Key:= 0;
          Exit;
        end;

      VK_F3:
        if Shift - [ssShift] = [] then
        begin
          DoSearch(True, Shift = [ssShift]);
          Key:= 0;
          Exit;
        end;
    end;
end;

procedure TfrmViewer.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmViewer.miStretchClick(Sender: TObject);
begin
  miStretch.Checked:= not miStretch.Checked;
  Image.Stretch:= miStretch.Checked;
  Image.AutoSize:= not Image.Stretch;
  Image.Proportional:= Image.Stretch;
  if gboxHightlight.Visible then UndoTmp;
  if miStretch.Checked then
    begin
      gboxPaint.Visible:=false;
      gboxHightlight.Visible:=false;
      gboxView.Visible:=true;
    end;
  AdjustImageSize;
end;

procedure TfrmViewer.miTextClick(Sender: TObject);
begin
  ExitPluginMode;
  ReopenAsTextIfNeeded;
  (Sender as TMenuItem).Checked:= True;
  if Sender = miText then ViewerControl.ViewerMode := vmText
  else if Sender = miBin then ViewerControl.ViewerMode := vmBin
  else if Sender = miHex then ViewerControl.ViewerMode := vmHex
  else if Sender = miWrapText then ViewerControl.ViewerMode := vmWrap;
  if Sender = miLookBook then
    begin
      with ViewerControl do
        begin
          ViewerMode := vmBook;
          Color:= gBookBackgroundColor;
          Font.Color:= gBookFontColor;
          Font.Quality:= fqAntialiased;
          ColCount:= gColCount;
          Position:= gTextPosition;
        end;
      FontOptionsToFont(gFonts[dcfViewerBook], ViewerControl.Font);
    end
  else
    begin
      with ViewerControl do
        begin
          Color:= clWindow;
          Font.Color:= clWindowText;
          Font.Quality:= fqDefault;
          ColCount:= 1;
        end;
      FontOptionsToFont(gFonts[dcfViewer], ViewerControl.Font);
    end;
end;

procedure TfrmViewer.miAbout2Click(Sender: TObject);
begin
  MsgOK(rsViewAboutText);
end;

procedure TfrmViewer.miSearchClick(Sender: TObject);
begin
  FLastSearchPos := -1;
  DoSearch(False, False);
end;

procedure TfrmViewer.FormCreate(Sender: TObject);
var
  HMViewer: THMForm;
begin
  InitPropStorage(Self);
  HMViewer := HotMan.Register(Self, HotkeysCategory);
  HMViewer.RegisterActionList(actionList);

  ViewerControl.OnGuessEncoding:= @DetectEncoding;

  FontOptionsToFont(gFonts[dcfViewer], ViewerControl.Font);

  FileList := TStringList.Create;

  WlxPlugins:=TWLXModuleList.Create;
  WlxPlugins.Assign(gWLXPlugins);
  DCDebug('WLX: Load - OK');

  FFindDialog:=nil; // dialog is created in first use
  
  miStretch.Checked:= gImageStretch;
  miPreview.Checked:= gPreviewVisible;
  ComboBoxPaint.Text := gImagePaintMode;
  ComboBoxWidth.Text := IntToStr(gImagePaintWidth);
  ColorBoxPaint.Selected := gImagePaintColor;

  FThumbSize := gThumbSize;
  DrawPreview.DefaultColWidth := FThumbSize.cx + 4;
  DrawPreview.DefaultRowHeight := FThumbSize.cy + DrawPreview.Canvas.TextHeight('Pp') + 6;

  MakeTextEncodingsMenu;

  Status.Panels[sbpFileNr].Alignment := taRightJustify;
  Status.Panels[sbpPosition].Alignment := taRightJustify;
  Status.Panels[sbpFileSize].Alignment := taRightJustify;

  ViewerPositionChanged(Self);

  FixFormIcon(Handle);
end;

procedure TfrmViewer.btnCutTuImageClick(Sender: TObject);
begin
  CutToImage;
end;

procedure TfrmViewer.btnDeleteFileClick(Sender: TObject);
begin
  if msgYesNo(Format(rsMsgDelSel, [FileList.Strings[iActiveFile]])) then
    begin
      CreatePreview(FileList.Strings[iActiveFile], iActiveFile, true);
      mbDeleteFile(FileList.Strings[iActiveFile]);
      FileList.Delete(iActiveFile);
      LoadFile(iActiveFile);
      DrawPreview.Repaint;
      SplitterChangeBounds(Sender);
    end;
end;

procedure TfrmViewer.btnCopyMoveFileClick(Sender: TObject);
begin
  FModSizeDialog:= TfrmModView.Create(Application);
  try
    FModSizeDialog.pnlQuality.Visible:= False;
    FModSizeDialog.pnlSize.Visible:= False;
    FModSizeDialog.pnlCopyMoveFile.Visible:= True;
    if Sender = btnMoveFile then
      FModSizeDialog.Caption:= 'Move File'
    else
      FModSizeDialog.Caption:= 'Copy File' ;
    if FModSizeDialog.ShowModal = mrOk then
    begin
      if FModSizeDialog.Path = '' then
        msgError(rsMsgInvalidPath)
      else
        begin
          CopyFile(FileList.Strings[iActiveFile],FModSizeDialog.Path+PathDelim+ExtractFileName(FileList.Strings[iActiveFile]));
          if (Sender = btnMoveFile) or (Sender = btnMoveFile1) then
          begin
            CreatePreview(FileList.Strings[iActiveFile], iActiveFile, true);
            mbDeleteFile(FileList.Strings[iActiveFile]);
            FileList.Delete(iActiveFile);
            LoadFile(iActiveFile);
            DrawPreview.Repaint;
            SplitterChangeBounds(Sender);
          end;
        end;
    end;
  finally
    FreeAndNil(FModSizeDialog);
  end;
end;

procedure TfrmViewer.actExecute(Sender: TObject);
var
  cmd: string;
begin
  cmd := (Sender as TAction).Name;
  cmd := 'cm_' + Copy(cmd, 4, Length(cmd) - 3);
  Commands.ExecuteCommand(cmd, []);
end;

procedure TfrmViewer.btnFullScreenClick(Sender: TObject);
begin
  miFullScreenClick(Sender);
end;

procedure TfrmViewer.btnGifMoveClick(Sender: TObject);
begin
  GifAnim.Animate:=not GifAnim.Animate;
  btnNextGifFrame.Enabled:= not GifAnim.Animate;
  btnPrevGifFrame.Enabled:= not GifAnim.Animate;
  if GifAnim.Animate then btnGifMove.Caption:='||' else btnGifMove.Caption:='|>';
end;

procedure TfrmViewer.btnGifToBmpClick(Sender: TObject);
begin
  GifAnim.Animate:=False;
  Image.Picture.Bitmap.Create;
  Image.Picture.Bitmap.Width := GifAnim.Width;
  Image.Picture.Bitmap.Height := GifAnim.Height;
  Image.Picture.Bitmap.Canvas.CopyRect(Rect(0,0,GifAnim.Width,GifAnim.Height),GifAnim.Canvas,Rect(0,0,GifAnim.Width,GifAnim.Height));
  miSaveAsClick(sender);
end;

procedure TfrmViewer.btnPaintHightlight(Sender: TObject);
var
  bmp: TCustomBitmap = nil;
  GraphicClass: TGraphicClass;
  sExt: String;
  fsFileStream: TFileStreamEx = nil;
begin
  if not ImgEdit then
    begin
    try
      sExt:= ExtractFileExt(FileList.Strings[iActiveFile]);
      fsFileStream:= TFileStreamEx.Create(FileList.Strings[iActiveFile], fmOpenRead or fmShareDenyNone);
      GraphicClass := GetGraphicClassForFileExtension(sExt);
      if (GraphicClass <> nil) and (GraphicClass.InheritsFrom(TCustomBitmap)) then
        begin
          Image.DisableAutoSizing;
          bmp := TCustomBitmap(GraphicClass.Create);
          bmp.LoadFromStream(fsFileStream);
          Image.Picture.Bitmap := TBitmap.Create;
          Image.Picture.Bitmap.Height:= bmp.Height;
          Image.Picture.Bitmap.Width:= bmp.Width;
          Image.Picture.Bitmap.Canvas.Draw(0, 0, bmp);
          Image.EnableAutoSizing;
        end;
    finally
      FreeThenNil(bmp);
      FreeThenNil(fsFileStream);
    end;
    {miStretch.Checked:= False;
    Image.Stretch:= miStretch.Checked;
    Image.Proportional:= Image.Stretch;
    Image.Autosize:= not(miStretch.Checked);
    AdjustImageSize; }
    end;
  if gboxHightlight.Visible then UndoTmp;
  if Sender = btnHightlight then
    begin
      gboxHightlight.Visible := not (gboxHightlight.Visible);
      gboxPaint.Visible:= False;
    end
  else
    begin
      gboxPaint.Visible:= not (gboxPaint.Visible);
      gboxHightlight.Visible:= False;
    end;
  ImgEdit:= True;
  CreateTmp;
end;

procedure TfrmViewer.btnPrevGifFrameClick(Sender: TObject);
begin
  GifAnim.Animate:=False;
  GifAnim.PriorFrame;
end;

procedure TfrmViewer.btnRedEyeClick(Sender: TObject);
begin
  RedEyes;
end;

procedure TfrmViewer.btnResizeClick(Sender: TObject);
begin
  FModSizeDialog:= TfrmModView.Create(Application);
  try
    FModSizeDialog.pnlQuality.Visible:=false;
    FModSizeDialog.pnlCopyMoveFile.Visible :=false;
    FModSizeDialog.pnlSize.Visible:=true;
    FModSizeDialog.teHeight.Text:= IntToStr(Image.Picture.Bitmap.Height);
    FModSizeDialog.teWidth.Text := IntToStr(Image.Picture.Bitmap.Width);
    FModSizeDialog.Caption:= 'New Size';
    if FModSizeDialog.ShowModal = mrOk then
    begin
      Res(StrToInt(FModSizeDialog.teWidth.Text), StrToInt(FModSizeDialog.teHeight.Text));
      AdjustImageSize;
    end;
  finally
    FreeAndNil(FModSizeDialog);
  end;
end;

procedure TfrmViewer.btnUndoClick(Sender: TObject);
begin
  UndoTmp;
end;

procedure TfrmViewer.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FFindDialog);
  FreeAndNil(FBitmapList);
  HotMan.UnRegister(Self);
end;

procedure TfrmViewer.miProcessClick(Sender: TObject);
{var
  sViewCmd:String;
  sCurrName:String;}
begin
{  DCDebug('TfrmViewer.miProcessClick');
  inherited;
  miEdit.Visible:=True;
  if not miProcess.Checked then
  begin
//    if ViewerControl.DataAccess=dtNothing then
    ViewerControl.MapFile(FileList.Strings[iActiveFile]);
    miProcess.Checked:=not miProcess.Checked;
  end
  else
  begin
    sCurrName:=FileList.Strings[iActiveFile];
    sViewCmd:=gExts.GetCommandText(lowercase(ExtractFileExt(sCurrName)),'view');
    if (sViewCmd='') then Exit;
    sViewCmd:=Copy(sViewCmd, pos('=',sViewCmd)+1, length(sViewCmd));
    // i known about range, but Copy correct this "bug"

    sViewCmd:=StringReplace(sViewCmd,'%f',ExtractFileName(sCurrName),[rfReplaceAll]);
    sViewCmd:=StringReplace(sViewCmd,'%d',ExtractFilePath(sCurrName),[rfReplaceAll]);
    sViewCmd:=Trim(StringReplace(sViewCmd,'%p',sCurrName,[rfReplaceAll]));

    ViewerControl.UnMapFile;
    Status.Panels[2].Text:=IntToStr(ViewerControl.FileSize);
    Status.Panels[3].Text:=sViewCmd;
    miProcess.Checked:=not miProcess.Checked;
  end;
}
end;

procedure TfrmViewer.ReopenAsTextIfNeeded;
begin
  if bImage or bAnimation or bPlugin then
  begin
    Image.Picture := nil;
    ViewerControl.FileName := FileList.Strings[iActiveFile];
    ActivatePanel(pnlText);
  end;
end;

procedure TfrmViewer.miGraphicsClick(Sender: TObject);
begin
  if CheckGraphics(FileList.Strings[iActiveFile]) then
    begin
      ViewerControl.FileName := ''; // unload current file if any is loaded
      if LoadGraphics(FileList.Strings[iActiveFile]) then
        ActivatePanel(pnlImage)
      else
        begin
          ViewerControl.FileName := FileList.Strings[iActiveFile];
          ActivatePanel(pnlText);
        end;
    end;
end;

procedure TfrmViewer.miCopyToClipboardClick(Sender: TObject);
begin
  if bPlugin then
    WlxPlugins.GetWLxModule(ActivePlugin).CallListSendCommand(lc_copy, 0)
  else
    ViewerControl.CopyToClipboard;
end;

procedure TfrmViewer.miSelectAllClick(Sender: TObject);
begin
  if bPlugin then
    WlxPlugins.GetWLxModule(ActivePlugin).CallListSendCommand(lc_selectall, 0)
  else
    ViewerControl.SelectAll;
end;

procedure TfrmViewer.miChangeEncodingClick(Sender: TObject);
begin
  ViewerControl.EncodingName := (Sender as TMenuItem).Caption;
  Status.Panels[4].Text := rsViewEncoding + ': ' + ViewerControl.EncodingName;
end;

function TfrmViewer.CheckGraphics(const sFileName:String):Boolean;
var
  sExt: String;
{$IFDEF LCLGTK2}
  fsBitmap: TFileStreamEx = nil;
{$ENDIF}
begin
  sExt:= LowerCase(ExtractFileExt(sFileName));
  {$IFDEF LCLGTK2}
  // TImage crash on displaying monochrome bitmap on Linux/GTK2
  // See details at http://bugs.freepascal.org/view.php?id=12362
  if (sExt = '.bmp') then
  try
    fsBitmap:= TFileStreamEx.Create(sFileName, fmOpenRead or fmShareDenyNone);
    // Get the number of bits per pixel from bitmap header
    fsBitmap.Seek($1C, soFromBeginning);
    // Don't open monochrome bitmap as image
    if (fsBitmap.ReadWord = 1) then Exit(False);
  finally
    fsBitmap.Free;
  end;
  {$ENDIF}
  Result:= Image.Picture.FindGraphicClassWithFileExt(sExt, False) <> nil;
end;

// Adjust Image size (width and height) to sboxImage size
procedure TfrmViewer.AdjustImageSize;
const
  fmtImageInfo = '%s (%s %%)';
var
  sResolution: String;
  iScale: Integer = 0;
begin
  if miStretch.Checked then
     begin
       Image.Stretch:=true;
       Image.AutoSize := true;
       //if gboxHightlight.Visible or gboxPaint.Visible then Image.Center:=false else Image.Center:=true;
       Image.Center:=true;
       if (Image.Picture.Width > sboxImage.ClientWidth) or  (Image.Picture.Height > sboxImage.ClientHeight) then
         begin
           Image.Left:= 0;
           Image.Top:= 0;
           Image.AutoSize := false;
           Image.Width:= sboxImage.ClientWidth;
           Image.Height:= sboxImage.ClientHeight;
           sboxImage.HorzScrollBar.Visible:=false;
           sboxImage.VertScrollBar.Visible:=false;
           // show image resolution and scale
           if Image.Picture.Width < Image.Width then
             begin
             iScale:= 100*(Image.Picture.Width * Image.ClientHeight) div (Image.Picture.Width* Image.Picture.Height);
             sResolution:= IntToStr(Image.Picture.Width) + 'x' + IntToStr(Image.Height);
             end;
           if Image.Picture.Height < Image.Height then
             begin
              iScale:= 100*(Image.ClientWidth * Image.Picture.Height) div (Image.Picture.Width* Image.Picture.Height);
              sResolution:= IntToStr(Image.Width) + 'x' + IntToStr(Image.Picture.Height);
             end;
           if (Image.Picture.Width >= Image.Width) and  (Image.Picture.Height >= Image.Height) then
             begin
              iScale:= 100*(Image.Width * Image.Height) div (Image.Picture.Width* Image.Picture.Height);
              sResolution:= IntToStr(Image.Width) + 'x' + IntToStr(Image.Height);
             end;
           Status.Panels[sbpCurrentResolution].Text:= Format(fmtImageInfo, [sResolution, IntToStr(iScale)]);
           sResolution:= IntToStr(Image.Picture.Width) + 'x' + IntToStr(Image.Picture.Height);
           Status.Panels[sbpFullResolution].Text:= Format(fmtImageInfo, [sResolution, '100']);
         end
       else
         begin
           Image.Left:= (sboxImage.ClientWidth-Image.Picture.Width) div 2;        //move image to center
           Image.Top:=  (sboxImage.ClientHeight-Image.Picture.Height) div 2;
           sResolution:= IntToStr(Image.Picture.Width) + 'x' + IntToStr(Image.Picture.Height);
           Status.Panels[sbpCurrentResolution].Text:= Format(fmtImageInfo, [sResolution, '100']);
           Status.Panels[sbpFullResolution].Text:= Status.Panels[2].Text;
         end;
     end
  else
    begin
      // show image resolution and scale
      Image.Left:= 0;
      Image.Top:= 0;
      if (Image.Picture.Width <> 0) and (Image.Picture.Height <> 0) then
        iScale:= 100 * (Image.Width * Image.Height) div (Image.Picture.Width * Image.Picture.Height);
      sResolution:= IntToStr(Image.Width) + 'x' + IntToStr(Image.Height);
      Status.Panels[sbpCurrentResolution].Text:= Format(fmtImageInfo, [sResolution, IntToStr(iScale)]);
      sResolution:= IntToStr(Image.Picture.Width) + 'x' + IntToStr(Image.Picture.Height);
      Status.Panels[sbpFullResolution].Text:= Format(fmtImageInfo, [sResolution, '100']);
    end;
end;

// Try to rotate image
procedure TfrmViewer.miRotateClick(Sender: TObject);
var
  x, y: Integer;
  xWidth,
  yHeight: Integer;
  SourceImg: TLazIntfImage = nil;
  TargetImg: TLazIntfImage = nil;
begin
  TargetImg:= TLazIntfImage.Create(0, 0);
  SourceImg:= Image.Picture.Bitmap.CreateIntfImage;
  TargetImg.DataDescription:= SourceImg.DataDescription; // use the same image format
  xWidth:= Image.Picture.Bitmap.Width - 1;
  yHeight:= Image.Picture.Bitmap.Height - 1;
  if Sender = mi180 then
      begin
        TargetImg.SetSize(xWidth + 1, yHeight + 1);
        for y:= 0 to yHeight do
        begin
          for x:= 0 to xWidth do
          begin
            TargetImg.Colors[x, y]:= SourceImg.Colors[xWidth - x, yHeight - y];
          end;
        end;
      end;
    if (Sender = mi270) or (Sender =btn270)then
      begin
        TargetImg.SetSize(yHeight + 1, xWidth + 1);
        for y:= 0 to xWidth do
        begin
          for x:= 0 to yHeight do
          begin
            TargetImg.Colors[x, y]:= SourceImg.Colors[xWidth - y, x];
          end;
        end;
        x:= Image.Width;
        Image.Width:= Image.Height;
        Image.Height:= x;
      end;
    if (Sender = mi90) or (Sender=btn90) then
      begin
        TargetImg.SetSize(yHeight + 1, xWidth + 1);
        for y:= 0 to xWidth do
        begin
          for x:= 0 to yHeight do
          begin
            TargetImg.Colors[x, y]:= SourceImg.Colors[y, yHeight - x];
          end;
        end;
        x:= Image.Width;
        Image.Width:= Image.Height;
        Image.Height:= x;
      end;
    if (Sender = miMirror) or (Sender = btnMirror)then
      begin
        TargetImg.SetSize(xWidth + 1, yHeight + 1);
        for y:= 0 to yHeight do
        begin
          for x:= 0 to xWidth do
          begin
            TargetImg.Colors[x, y]:= SourceImg.Colors[xWidth - x, y];
          end;
        end;
      end;
  Image.Picture.Bitmap.LoadFromIntfImage(TargetImg);
  FreeThenNil(SourceImg);
  FreeThenNil(TargetImg);
  AdjustImageSize;
  CreateTmp;
end;

function TfrmViewer.GetListerRect: TRect;
begin
  Result:= ClientRect;
  Dec(Result.Bottom, Status.Height);
  if Splitter.Visible then
  begin
    Inc(Result.Left, Splitter.Left + Splitter.Width);
  end;
end;

procedure TfrmViewer.miScreenShotClick(Sender: TObject);
var
  ScreenDC: HDC;
  bmp: TCustomBitmap;
begin
  Visible:= False;
  Application.ProcessMessages; // Hide viewer window
  bmp := TBitmap.Create;
  ScreenDC := GetDC(0);
  bmp.LoadFromDevice(ScreenDC);
  ReleaseDC(0, ScreenDC);
  Image.Picture.Bitmap.Height:= bmp.Height;
  Image.Picture.Bitmap.Width:= bmp.Width;
  Image.Picture.Bitmap.Canvas.Draw(0, 0, bmp);
  CreateTmp;
  bmp.Free;
  Visible:= True;
  ImgEdit:= True;
end;

function TfrmViewer.LoadGraphics(const sFileName:String): Boolean;
var
  sExt: String;
  fsFileStream: TFileStreamEx = nil;
begin
  sExt:= ExtractOnlyFileExt(sFilename);
  if sExt <> 'gif' then
    begin
      Image.Visible:= True;
      GifAnim.Visible:= False;
      try
        fsFileStream:= TFileStreamEx.Create(sFileName, fmOpenRead or fmShareDenyNone);
        try
          Image.Picture.LoadFromStreamWithFileExt(fsFileStream, sExt);
          btnHightlight.Visible:=True;
          btnPaint.Visible:=True;
          btnResize.Visible:=True;
          miImage.Visible:=True;
          btnZoomIn.Visible:=true;
          btnZoomOut.Visible:=true;
          btn270.Visible:=true;
          btn90.Visible:=true;
          btnMirror.Visible:=true;
          btnGifMove.Visible:=false;
          btnGifToBmp.Visible:=false;
          btnNextGifFrame.Visible:=false;
          btnPrevGifFrame.Visible:=false;
        finally
          FreeAndNil(fsFileStream);
        end;
        miStretch.Checked:= not miStretch.Checked;
        miStretchClick(nil);
      except
        Exit(False);
      end;
    end
  else
    begin
      GifAnim.Visible:= True;
      Image.Visible:= False;
      try
        GifAnim.FileName:= UTF8ToSys(sFileName);
        btnHightlight.Visible:=False;
        btnPaint.Visible:=False;
        btnResize.Visible:=False;
        miImage.Visible:=False;
        btnZoomIn.Visible:=false;
        btnZoomOut.Visible:=false;
        btn270.Visible:=false;
        btn90.Visible:=false;
        btnMirror.Visible:=false;
        btnGifMove.Visible:=true;
        btnGifToBmp.Visible:=true;
        btnNextGifFrame.Visible:=true;
        btnPrevGifFrame.Visible:=true;
      except
        Exit(False);
      end;
    end;
  ImgEdit:= False;
end;

procedure TfrmViewer.DoSearch(bQuickSearch: Boolean; bSearchBackwards: Boolean);
var
  PAdr: PChar;
  iSizeData: Integer;
  sSearchTextU: UTF8String;
  sSearchTextA: AnsiString;
begin
  // in first use create dialog
  if not Assigned(FFindDialog) then
     FFindDialog:= TfrmFindView.Create(Application);

  if (bQuickSearch and gFirstTextSearch) or not bQuickSearch then
    begin
      if bPlugin then
        begin
          // if plugin has specific search dialog
          if WlxPlugins.GetWLxModule(ActivePlugin).CallListSearchDialog(0) = LISTPLUGIN_OK then
            Exit;
        end;
      // Load search history
      FFindDialog.cbDataToFind.Items.Assign(glsSearchHistory);
      if FFindDialog.ShowModal <> mrOK then Exit;
      if FFindDialog.cbDataToFind.Text = '' then Exit;
      sSearchTextU:= FFindDialog.cbDataToFind.Text;
      // Save search history
      glsSearchHistory.Assign(FFindDialog.cbDataToFind.Items);
      gFirstTextSearch:= False;
    end
  else
    begin
      if bPlugin then
        begin
          // if plugin has specific search dialog
          if WlxPlugins.GetWLxModule(ActivePlugin).CallListSearchDialog(1) = LISTPLUGIN_OK then
            Exit;
        end;
      if glsSearchHistory.Count > 0 then
        sSearchTextU:= glsSearchHistory[0];
    end;

  if bPlugin then
    begin
      iSizeData:= 0;
      if FFindDialog.cbCaseSens.Checked then
        iSizeData:= lcs_matchcase;
      WlxPlugins.GetWLxModule(ActivePlugin).CallListSearchText(sSearchTextU, iSizeData);
    end
  else
    begin
      // Choose search start position.
      if not bSearchBackwards then
      begin
        if FLastSearchPos = -1 then
          FLastSearchPos := 0
        else if FLastSearchPos < ViewerControl.FileSize - 1 then
          FLastSearchPos := FLastSearchPos + 1;
      end
      else
      begin
        if FLastSearchPos = -1 then
          FLastSearchPos := ViewerControl.FileSize - 1
        else if FLastSearchPos > 0 then
          FLastSearchPos := FLastSearchPos - 1;
      end;

      sSearchTextA:= ViewerControl.ConvertFromUTF8(sSearchTextU);
      PAdr := PosMem(ViewerControl.GetDataAdr, ViewerControl.FileSize,
                     FLastSearchPos, sSearchTextA,
                     FFindDialog.cbCaseSens.Checked, bSearchBackwards);

      if (PAdr <> Pointer(-1)) then
        begin
          FLastSearchPos := PAdr - ViewerControl.GetDataAdr;
          // Text found, show it in ViewerControl if not visible
          ViewerControl.MakeVisible(FLastSearchPos);
          // Select found text.
          ViewerControl.SelectText(FLastSearchPos, FLastSearchPos + Length(sSearchTextA));
        end
      else
        begin
          msgOK(Format(rsViewNotFound, ['"' + sSearchTextU + '"']));
          FLastSearchPos := -1;
        end;
    end;
end;

procedure TfrmViewer.MakeTextEncodingsMenu;
var
  I: Integer;
  mi: TMenuItem;
  EncodingsList: TStringList;
begin
  miEncoding.Clear;
  EncodingsList := TStringList.Create;
  try
    ViewerControl.GetSupportedEncodings(EncodingsList);
    for I:= 0 to EncodingsList.Count - 1 do
      begin
        mi:= TMenuItem.Create(miEncoding);
        mi.Caption:= EncodingsList[I];
        mi.AutoCheck:= True;
        mi.RadioItem:= True;
        mi.GroupIndex:= 1;
        mi.OnClick:= @miChangeEncodingClick;
        if ViewerControl.EncodingName = EncodingsList[I] then
          mi.Checked := True;
        miEncoding.Add(mi);
      end;
  finally
    FreeAndNil(EncodingsList);
  end;
end;

procedure TfrmViewer.ViewerPositionChanged(Sender:TObject);
begin
  if ViewerControl.FileSize > 0 then
    begin
      Status.Panels[sbpPosition].Text :=
          cnvFormatFileSize(ViewerControl.Position) +
          ' (' + IntToStr(ViewerControl.Percent) + ' %)';
    end
  else
    Status.Panels[sbpPosition].Text:= cnvFormatFileSize(0) + ' (0 %)';
end;

procedure TfrmViewer.ActivatePanel(Panel: TPanel);
begin
  pnlFolder.Hide;
  pnlImage.Hide;
  pnlText.Hide;

  if Assigned(Panel) then Panel.Visible := True;

  bAnimation         := (GifAnim.Visible);
  bImage             := (Panel = pnlImage) and (bAnimation = False);
  bPlugin            := (Panel = nil);
  miPlugins.Checked  := (Panel = nil);
  miGraphics.Checked := (Panel = pnlImage);
  miEncoding.Visible := (Panel = pnlText);
  miEdit.Visible     := (Panel = pnlText) or (Panel = nil);
  miImage.Visible    := bImage;
  miSave.Visible     := bImage;
  miSaveAs.Visible   := bImage;

  if Panel = nil then
  begin
    Status.Panels[sbpPluginName].Text:= WlxPlugins.GetWLxModule(ActivePlugin).Name;
  end
  else if Panel = pnlText then
  begin
    if (not bQuickView) and CanFocus and ViewerControl.CanFocus then
      ViewerControl.SetFocus;

    case ViewerControl.ViewerMode of
      vmText: miText.Checked := True;
      vmWrap: miWrapText.Checked := True;
      vmBin:  miBin.Checked := True;
      vmHex:  miHex.Checked := True;
      vmBook: miLookBook.Checked := True;
    end;

    Status.Panels[sbpFileSize].Text:= cnvFormatFileSize(ViewerControl.FileSize) + ' (100 %)';
    Status.Panels[sbpTextEncoding].Text := rsViewEncoding + ': ' + ViewerControl.EncodingName;
  end
  else if Panel = pnlImage then
  begin
    PanelEditImage.Visible:= not bQuickView;
  end;
end;

// Commands for hotkey manager

{$IF FPC_FULLVERSION < 020501}
function TfrmViewer.ExecuteCommand(Command: string; const Params: array of string): TCommandFuncResult;
begin
  Result := FCommands.ExecuteCommand(Command, Params);
end;

function TfrmViewer.GetCommandCaption(Command: String; CaptionType: TCommandCaptionType): String;
begin
  Result := FCommands.GetCommandCaption(Command, CaptionType);
end;

procedure TfrmViewer.GetCommandsList(List: TStrings);
begin
  FCommands.GetCommandsList(List);
end;
{$ENDIF}

procedure TfrmViewer.cm_About(const Params: array of string);
begin
  miAbout2Click(Self);
end;

procedure TfrmViewer.cm_Reload(const Params: array of string);
begin
  LoadFile(iActiveFile);
end;

procedure TfrmViewer.cm_LoadNextFile(const Params: array of string);
var
  I: Integer;
begin
  I:= iActiveFile + 1;
  if I >= FileList.Count then
    I:= 0;

  if bPlugin then
    begin
      if WlxPlugins.GetWlxModule(ActivePlugin).CallListLoadNext(Self.Handle, FileList[I], 0) <> LISTPLUGIN_ERROR then
        Exit;
    end;
  ExitPluginMode;
  if pnlPreview.Visible then
    begin
      if DrawPreview.Col = DrawPreview.ColCount-1 then
        begin
          DrawPreview.Col:=0;
          DrawPreview.Row:= DrawPreview.Row+1;
        end
      else
        DrawPreview.Col:=DrawPreview.Col+1
    end
  else LoadFile(I);
end;

procedure TfrmViewer.cm_LoadPrevFile(const Params: array of string);
var
  I: Integer;
begin
  I:= iActiveFile - 1;
  if I < 0 then
    I:= FileList.Count - 1;

  if bPlugin then
    begin
      if WlxPlugins.GetWlxModule(ActivePlugin).CallListLoadNext(Self.Handle, FileList[I], 0) <> LISTPLUGIN_ERROR then
        Exit;
    end;
  if pnlPreview.Visible then
    begin
      if DrawPreview.Col = 0  then
        begin
          DrawPreview.Col:=DrawPreview.ColCount-1;
          DrawPreview.Row:= DrawPreview.Row-1;
        end
      else
        DrawPreview.Col:=DrawPreview.Col-1
    end
  else LoadFile(I);
end;

procedure TfrmViewer.cm_MoveFile(const Params: array of string);
begin
  btnCopyMoveFileClick(btnMoveFile);
end;

procedure TfrmViewer.cm_CopyFile(const Params: array of string);
begin
  btnCopyMoveFileClick(Self);
end;

procedure TfrmViewer.cm_DeleteFile(const Params: array of string);
begin
  btnDeleteFileClick(Self);
end;

procedure TfrmViewer.cm_StretchImage(const Params: array of string);
begin
  if bImage then miStretchClick(Self);
end;

procedure TfrmViewer.cm_SaveAs(const Params: array of string);
begin
  if bAnimation or bImage then miSaveAsClick(Self);
end;

procedure TfrmViewer.cm_Rotate90(const Params: array of string);
begin
  if bImage then miRotateClick(mi90);
end;

procedure TfrmViewer.cm_Rotate180(const Params: array of string);
begin
  if bImage then miRotateClick(mi180);
end;

procedure TfrmViewer.cm_Rotate270(const Params: array of string);
begin
  if bImage then miRotateClick(mi270);
end;

procedure TfrmViewer.cm_Mirror(const Params: array of string);
begin
  if bImage then miRotateClick(miMirror);
end;

initialization
  TFormCommands.RegisterCommandsForm(TfrmViewer, HotkeysCategory, @rsHotkeyCategoryViewer);

end.

