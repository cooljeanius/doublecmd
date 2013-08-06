{
   Double commander
   -------------------------------------------------------------------------
   This module contains classes with UTF8 file names support.

   Copyright (C) 2008-2011  Koblov Alexander (Alexx2000@mail.ru)

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

unit DCClassesUtf8;

{$mode objfpc}{$H+}

interface

uses
  Classes, RtlConsts, SysUtils, IniFiles;

{$IF (FPC_VERSION = 2) and (FPC_RELEASE < 5)}
const
  { TFileStream create mode }
  fmCreate        = $FF00;
{$ENDIF}

type
  { TFileStreamEx class }

  TFileStreamEx = class(THandleStream)
  private
    FHandle: THandle;
    FFileName: UTF8String;
  public
    constructor Create(const AFileName: UTF8String; Mode: Word);
    destructor Destroy; override;
    {$IF (FPC_VERSION <= 2) and (FPC_RELEASE <= 4) and (FPC_PATCH <= 0)}
    function ReadQWord: QWord;
    procedure WriteQWord(q: QWord);
    {$ENDIF}
    property FileName: UTF8String read FFileName;
  end; 

  { TStringListEx }

  TStringListEx = class(TStringList)
  public
    function IndexOfValue(const Value: String): Integer;
    procedure LoadFromFile(const FileName: String); override;
    procedure SaveToFile(const FileName: String); override;
  end;   
  
  { TIniFileEx }

  THackIniFile = class
  private
    FFileName: String;
    FSectionList: TIniFileSectionList;
  end;

  TIniFileEx = class(TIniFile)
  private
    FIniFileStream: TFileStreamEx;
    FReadOnly: Boolean;
    function GetFileName: UTF8String;
    procedure SetFileName(const AValue: UTF8String);
  public
    constructor Create(const AFileName: String; Mode: Word); virtual;
    constructor Create(const AFileName: string; AEscapeLineFeeds : Boolean = False); override;
    destructor Destroy; override;
    procedure UpdateFile; override;
  public
    procedure Clear;
    property FileName: UTF8String read GetFileName write SetFileName;
    property ReadOnly: Boolean read FReadOnly;
  end;

implementation

uses
  DCOSUtils;

{ TFileStreamEx }

constructor TFileStreamEx.Create(const AFileName: UTF8String; Mode: Word);
begin
  if (Mode and fmCreate) <> 0 then
    begin
      FHandle:= mbFileCreate(AFileName, Mode);
      if FHandle = feInvalidHandle then
        raise EFCreateError.CreateFmt(SFCreateError, [AFileName])
      else
        inherited Create(FHandle);	  
    end
  else
    begin 
      FHandle:= mbFileOpen(AFileName, Mode);
      if FHandle = feInvalidHandle then
        raise EFOpenError.CreateFmt(SFOpenError, [AFilename])
      else
        inherited Create(FHandle);	  
    end;
  FFileName:= AFileName;
end;

destructor TFileStreamEx.Destroy;
begin
  inherited Destroy;
  // Close handle after destroying the base object, because it may use Handle in Destroy.
  if FHandle >= 0 then FileClose(FHandle);
end;

{$IF (FPC_VERSION <= 2) and (FPC_RELEASE <= 4) and (FPC_PATCH <= 0)}
function TFileStreamEx.ReadQWord: QWord;
var
  q: QWord;
begin
  ReadBuffer(q, SizeOf(QWord));
  ReadQWord:= q;
end;

procedure TFileStreamEx.WriteQWord(q: QWord);
begin
  WriteBuffer(q, SizeOf(QWord));
end;
{$ENDIF}

{ TStringListEx }

function TStringListEx.IndexOfValue(const Value: String): Integer;
var
  iStart: LongInt;
  sTemp: String;
begin
  CheckSpecialChars;
  Result:= 0;
  while (Result < Count) do
    begin
    sTemp:= Strings[Result];
    iStart:= Pos(NameValueSeparator, sTemp) + 1;
    if (iStart > 0) and (DoCompareText(Value, Copy(sTemp, iStart, MaxInt)) = 0) then
      Exit;
    Inc(result);
    end;
  Result:= -1;
end;

procedure TStringListEx.LoadFromFile(const FileName: String);
var
  fsFileStream: TFileStreamEx;
begin
  fsFileStream:= TFileStreamEx.Create(FileName, fmOpenRead or fmShareDenyNone);
  LoadFromStream(fsFileStream);
  fsFileStream.Free;
end;

procedure TStringListEx.SaveToFile(const FileName: String);
var
  fsFileStream: TFileStreamEx = nil;
begin
  try
    if mbFileExists(FileName) then
      begin
        fsFileStream:= TFileStreamEx.Create(FileName, fmOpenWrite or fmShareDenyWrite);
        fsFileStream.Position:= 0;
        fsFileStream.Size:= 0;
      end
    else
      fsFileStream:= TFileStreamEx.Create(FileName, fmCreate);

    SaveToStream(fsFileStream);
  finally
    fsFileStream.Free;
  end;
end;

{ TIniFileEx }

function TIniFileEx.GetFileName: UTF8String;
begin
  Result:= THackIniFile(Self).FFileName;
end;

procedure TIniFileEx.SetFileName(const AValue: UTF8String);
begin
  THackIniFile(Self).FFileName:= AValue;
end;

constructor TIniFileEx.Create(const AFileName: String; Mode: Word);
begin
  FReadOnly := ((Mode and $03) = fmOpenRead);

  if mbFileExists(AFileName) then
  begin
    if (Mode and $F0) = 0 then
      Mode := Mode or fmShareDenyWrite;
  end
  else
  begin
    Mode := fmCreate;
  end;

  FIniFileStream:= TFileStreamEx.Create(AFileName, Mode);
  inherited Create(FIniFileStream);
  FileName:= AFileName;
end;

constructor TIniFileEx.Create(const AFileName: string; AEscapeLineFeeds: Boolean);
begin
  if mbFileAccess(AFileName, fmOpenReadWrite or fmShareDenyWrite) then
    Create(AFileName, fmOpenReadWrite or fmShareDenyWrite)
  else
    Create(AFileName, fmOpenRead or fmShareDenyNone);
end;

procedure TIniFileEx.UpdateFile;
begin
  if not ReadOnly then
  begin
    Stream.Position:=0;
    Stream.Size:= 0;
    FileName:= EmptyStr;
    inherited UpdateFile;
    FileName:= FIniFileStream.FileName;
  end;
end;

procedure TIniFileEx.Clear;
begin
  THackIniFile(Self).FSectionList.Clear;
end;

destructor TIniFileEx.Destroy;
begin
  inherited Destroy;
  // Destroy stream after destroying the base object, because it may use the stream in Destroy.
  FreeAndNil(FIniFileStream);
end;

end.
