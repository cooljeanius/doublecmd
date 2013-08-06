{
   Double commander
   -------------------------------------------------------------------------
   This unit contains class for working with file comments.

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

unit uDescr;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DCClassesUtf8;

type

  { TDescription }

  TDescription = class(TStringListEx)
  private
    FLastDescrFile,
    FEncoding: String;
    FModified: Boolean;
    FDestDescr: TDescription;
    procedure PrepareDescrFile(FileName: String);
    function GetDescription(Index: Integer): String;
    function GetDescription(const FileName: String): String;
    procedure SetDescription(Index: Integer; const AValue: String);
    procedure SetDescription(const FileName: String; const AValue: String);
    procedure SetEncoding(const AValue: String);
  public
    {en
       Create TDescription class
       @param(UseSubDescr @true if need Copy/Move functions)
    }
    constructor Create(UseSubDescr: Boolean);
    {en
       Destroy TDescription class
    }
    destructor Destroy; override;
    {en
       Load data from description file
    }
    procedure LoadFromFile(const FileName: String); override;
    {en
       Save data to description file
    }
    procedure SaveToFile(const FileName: String); override;
    {en
       Add description for file
       @param(FileName File name)
       @param(Descr Description)
       @returns(Index of added item)
    }
    function AddDescription(FileName, Descr: String): Integer;
    {en
       Read description by file name
       @param(FileName File name)
       @returns(Description of file)
    }
    function ReadDescription(FileName: String): String;
    {en
       Write description for file
       @param(FileName File name)
       @param(Descr Description)
    }
    procedure WriteDescription(FileName: String; const Descr: String);
    {en
       Delete description by file name
       @param(FileName File name)
       @returns(The function returns @true if successful, @false otherwise)
    }
    function DeleteDescription(const FileName: String): Boolean;
    {en
       Copy description for file
       @param(FileNameFrom Source file name)
       @param(FileNameTo Destination file name)
       @returns(The function returns @true if successful, @false otherwise)
    }
    function CopyDescription(const FileNameFrom, FileNameTo: String): Boolean;
    {en
       Move description for file
       @param(FileNameFrom Source file name)
       @param(FileNameTo Destination file name)
       @returns(The function returns @true if successful, @false otherwise)
    }
    function MoveDescription(const FileNameFrom, FileNameTo: String): Boolean;
    {en
       Save all changes to description file
    }
    procedure SaveDescription;

    {$IF (FPC_VERSION > 2) or ((FPC_VERSION = 2) and (FPC_RELEASE >= 5)) or ((FPC_VERSION = 2) and (FPC_RELEASE = 4) and (FPC_PATCH >= 4))}
    function Find(const S: string; out Index: Integer): Boolean; override;
    {$ELSE}
    function Find(const S: string; var Index: Integer): Boolean; override;
    {$ENDIF}
    {en
       File description encoding
    }
    property Encoding: String read FEncoding write SetEncoding;
    {en
       Get description by file name
    }
    property DescrByFileName[const FileName: String]: String read GetDescription write SetDescription;
    {en
       Get description by file name index
    }
    property DescrByIndex[Index: Integer]: String read GetDescription write SetDescription;
  end;

implementation

uses
  LConvEncoding, uDebug, DCOSUtils;

{ TDescription }

procedure TDescription.PrepareDescrFile(FileName: String);
var
  sDescrFile: String;
begin
  sDescrFile:= ExtractFilePath(FileName) + 'descript.ion';
  if sDescrFile <> FLastDescrFile then
    try
      // save previous decription file if need
      if FModified and (FLastDescrFile <> EmptyStr) and (Count > 0) then
        SaveToFile(FLastDescrFile);
      // load description file if exists
      FLastDescrFile:= sDescrFile;
      if mbFileExists(FLastDescrFile) then
        begin
          LoadFromFile(FLastDescrFile);
          FEncoding:= GuessEncoding(Text); // try to guess encoding
          if FEncoding = EmptyStr then // by default use UTF-8
            FEncoding:= EncodingUTF8;
          if FEncoding <> EncodingUTF8 then
            Text:= ConvertEncoding(Text, FEncoding, EncodingUTF8);
        end;
    except
      on E: Exception do
        DCDebug('TDescription.PrepareDescrFile - ' + E.Message);
    end;
end;

{$IF (FPC_VERSION > 2) or ((FPC_VERSION = 2) and (FPC_RELEASE >= 5)) or ((FPC_VERSION = 2) and (FPC_RELEASE = 4) and (FPC_PATCH >= 4))}
function TDescription.Find(const S: string; out Index: Integer): Boolean;
{$ELSE}
function TDescription.Find(const S: string; var Index: Integer): Boolean;
{$ENDIF}
var
  iIndex, iPosOfDivider, iLength, iFirstStringPos: Integer;
  sFileName, sIndexString: String;
  cSearchChar : Char;
begin
  Result:= False;
  sFileName:= ExtractFileName(S);
  //DCDebug('#########################');
  //DCDebug('sFileName:               '+ sFileName);
  for iIndex:= Count - 1 downto 0 do
  begin
    sIndexString := Self[iIndex];
    //DCDebug('Self[I]:                 '+ sIndexString);
    //DCDebug('iIndex:                  '+ IntToStr(iIndex));
    //DCDebug('Count:                   '+ IntToStr(Count));
    //DCDebug('Pos(sFileName, Self[I]): '+ IntToStr(Pos(sFileName, sIndexString)));

    // File comment length
    iLength := Length(sIndexString);
    if iLength = 0 then Continue;

    //at the first, look if first char a "
    if(sIndexString[1]='"')then
    begin // YES
      cSearchChar := '"';
      iFirstStringPos := 2;
    end
    else
    begin //NO
     cSearchChar := ' ';
     iFirstStringPos := 1;
    end;

    // find position of next cSearchChar in sIndexString
    iPosOfDivider:= 2;
    while (iPosOfDivider < iLength) do // don't look above the strings length
    begin
      // is at this position the cSearchChar?
      if (sIndexString[iPosOfDivider] = cSearchChar) then
      begin // YES
        // found the sFileName in the sIndexString (no more, no less)
        if mbCompareFileNames(sFileName, Copy(sIndexString, iFirstStringPos, iPosOfDivider-iFirstStringPos)) then
        begin // YES
          Index := iIndex;
          Exit(True);
        end
        else
        begin // NO
          Break;
        end;
      end;
      Inc(iPosOfDivider);
    end;
  end;
end;

function TDescription.GetDescription(Index: Integer): String;
var
  sLine: String;
  iDescrStart: Integer;
begin
  sLine:= Self[Index];
  if Pos(#34, sLine) <> 1 then
    begin
      iDescrStart:= Pos(#32, sLine);
      Result:= Copy(sLine, iDescrStart+1, Length(sLine) - iDescrStart);
    end
  else
    begin
      iDescrStart:= Pos(#34#32, sLine);
      Result:= Copy(sLine, iDescrStart+2, Length(sLine) - iDescrStart);
    end;
end;

function TDescription.GetDescription(const FileName: String): String;
var
  I: Integer;
begin
  Result:= '';
  if Find(FileName, I) then
    Result:= GetDescription(I);
end;

procedure TDescription.SetDescription(Index: Integer; const AValue: String);
var
  sLine,
  sFileName: String;
  iDescrStart: Integer;
begin
  FModified:= True;
  sLine:= Self[Index];
  if Pos('"', sLine) <> 1 then
    begin
      iDescrStart:= Pos(#32, sLine);
      sFileName:= Copy(sLine, 1, iDescrStart);
      Self[Index]:= sFileName + AValue;
    end
  else
    begin
      iDescrStart:= Pos(#34#32, sLine);
      sFileName:= Copy(sLine, 1, iDescrStart+1);
      Self[Index]:= sFileName + AValue;
    end;
end;

procedure TDescription.SetDescription(const FileName: String;
  const AValue: String);
var
  I: Integer;
begin
  if Find(FileName, I) then
    SetDescription(I, AValue)
  else
    AddDescription(FileName, AValue);
end;

procedure TDescription.SetEncoding(const AValue: String);
begin
  if FEncoding <> AValue then
    begin
      FEncoding:= AValue;
      if mbFileExists(FLastDescrFile) then
        LoadFromFile(FLastDescrFile);
    end;
end;

constructor TDescription.Create(UseSubDescr: Boolean);
begin
  FModified:= False;
  FEncoding:= EncodingUTF8; // by default
  if UseSubDescr then
    FDestDescr:= TDescription.Create(False)
  else
    FDestDescr:= nil;
  inherited Create;
end;

destructor TDescription.Destroy;
begin
  if Assigned(FDestDescr) then
    FreeAndNil(FDestDescr);
  inherited Destroy;
end;

procedure TDescription.LoadFromFile(const FileName: String);
begin
  FModified:= False;
  inherited LoadFromFile(FileName);
  if FEncoding <> EncodingUTF8 then
    Text:= ConvertEncoding(Text, FEncoding, EncodingUTF8);
end;

procedure TDescription.SaveToFile(const FileName: String);
begin
  FModified:= False;
  if FEncoding <> EncodingUTF8 then
    Text:= ConvertEncoding(Text, EncodingUTF8, FEncoding);
  inherited SaveToFile(FileName);
end;

function TDescription.AddDescription(FileName, Descr: String): Integer;
begin
  FModified:= True;
  FileName:= ExtractFileName(FileName);
  if Pos(#32, FileName) <> 0 then
    Result := Add(#34+FileName+#34#32+Descr)
  else
    Result := Add(FileName+#32+Descr);
end;

function TDescription.ReadDescription(FileName: String): String;
begin
  PrepareDescrFile(FileName);
  Result:= GetDescription(FileName);
end;

procedure TDescription.WriteDescription(FileName: String; const Descr: String);
begin
  PrepareDescrFile(FileName);
  SetDescription(FileName, Descr);
end;

function TDescription.DeleteDescription(const FileName: String): Boolean;
var
  I: Integer;
begin
  Result:= False;
  PrepareDescrFile(FileName);
  if Find(FileName, I) then
    begin
      Delete(I);
      FModified:= True;
      Result:= True;
    end;
end;

function TDescription.CopyDescription(const FileNameFrom, FileNameTo: String): Boolean;
var
  I: Integer;
begin
  Result:= False;
  PrepareDescrFile(FileNameFrom);
  if Find(FileNameFrom, I) then
    begin
      DCDebug(FileNameFrom, '=', DescrByIndex[I]);
      FDestDescr.WriteDescription(FileNameTo, DescrByIndex[I]);
      Result:= True;
    end;
end;

function TDescription.MoveDescription(const FileNameFrom, FileNameTo: String): Boolean;
var
  I: Integer;
begin
  Result:= False;
  PrepareDescrFile(FileNameFrom);
  if Find(FileNameFrom, I) then
    begin
      DCDebug(FileNameFrom, '=', DescrByIndex[I]);
      FDestDescr.WriteDescription(FileNameTo, DescrByIndex[I]);
      Delete(I);
      FModified:= True;
      Result:= True;
    end;
end;

procedure TDescription.SaveDescription;
begin
  try
    if Count > 0 then
      SaveToFile(FLastDescrFile)
    else
      mbDeleteFile(FLastDescrFile);
    if Assigned(FDestDescr) then
      FDestDescr.SaveDescription;
    except
      on E: Exception do
        DCDebug('TDescription.SaveDescription - ' + E.Message);
    end;
end;

end.
