{
   Double Commander
   -------------------------------------------------------------------------
   ImageMagick thumbnail provider

   Copyright (C) 2013 Alexander Koblov (alexx2000@mail.ru)

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
}

unit uMagickWand;

{$mode delphi}

interface

implementation

uses
  LCLIntf, Classes, SysUtils, GraphType, DynLibs, FileUtil, Types, Graphics,
  CTypes, uThumbnails, uDebug, uClassesEx;

const
  MagickFalse = 0;
  MagickTrue = 1;

const
  libMagickWand = 'libMagickWand.so.%d';

type
  PMagickWand = Pointer;
  MagickBooleanType = culong;
  ExceptionType = Word;
  PExceptionType = ^ExceptionType;

type
  TRawAccess = class(TPortableNetworkGraphic) end;

{$PACKENUM 4}

type
  FilterTypes = (
   UndefinedFilter,
   PointFilter,
   BoxFilter,
   TriangleFilter,
   HermiteFilter,
   HanningFilter,
   HammingFilter,
   BlackmanFilter,
   GaussianFilter,
   QuadraticFilter,
   CubicFilter,
   CatromFilter,
   MitchellFilter,
   LanczosFilter,
   BesselFilter,
   SincFilter
  );

var
  MagickWand: TLibHandle;

var
  MagickWandGenesis: procedure(); cdecl;
  MagickWandTerminus: procedure(); cdecl;
  NewMagickWand: function(): PMagickWand; cdecl;
  DestroyMagickWand: function(wand: PMagickWand): PMagickWand; cdecl;
  MagickGetException: function(wand: PMagickWand; severity: PExceptionType): PAnsiChar; cdecl;
  MagickRelinquishMemory: function(resource: Pointer): Pointer; cdecl;
  MagickReadImage: function(wand: PMagickWand; const filename: PAnsiChar): MagickBooleanType; cdecl;
  MagickGetImageWidth: function(wand: PMagickWand): culong; cdecl;
  MagickGetImageHeight: function(wand: PMagickWand): culong; cdecl;
  MagickResizeImage: function(wand: PMagickWand; const columns, rows: culong; const filter: FilterTypes; const blur: double): MagickBooleanType; cdecl;
  MagickSetImageFormat: function(wand: PMagickWand; const format: PAnsiChar): MagickBooleanType; cdecl;
  MagickGetImageBlob: function(wand: PMagickWand; length: Pcsize_t): PByte; cdecl;

procedure BitmapAssign(Bitmap: TBitmap; Image: TPortableNetworkGraphic);
var
  RawImage: PRawImage;
begin
  RawImage:= TRawAccess(Image).GetRawImagePtr;
  // Simply change raw image owner without data copy
  Bitmap.LoadFromRawImage(RawImage^, True);
  // Set image data pointer to nil, so it will not free double
  RawImage^.ReleaseData;
end;

procedure RaiseWandException(Wand: PMagickWand);
var
  Description: PAnsiChar;
  Severity: ExceptionType;
  ExceptionMessage: AnsiString;
begin
  Description:= MagickGetException(Wand, @Severity);
  ExceptionMessage:= AnsiString(Description);
  Description:= MagickRelinquishMemory(Description);
  Raise Exception.Create(ExceptionMessage);
end;

function GetThumbnail(const aFileName: UTF8String; aSize: TSize): Graphics.TBitmap;
var
  Memory: PByte;
  Wand: PMagickWand;
  MemorySize: csize_t;
  Width, Height: culong;
  BlobStream: TBlobStream;
  Status: MagickBooleanType;
  Bitmap: TPortableNetworkGraphic;
begin
  Result:= nil;

  if GetGraphicClassForFileExtension(ExtractFileExt(aFileName)) <> nil then
  begin
    // DCDebug('GetThumbnail start: ' + IntToStr(GetTickCount));
    MagickWandGenesis;

    Wand:= NewMagickWand;

    try
      Status:= MagickReadImage(Wand, PAnsiChar(UTF8ToSys(aFileName)));
      try
        if (Status = MagickFalse) then RaiseWandException(Wand);

        // Get image width and height
        Width:= MagickGetImageWidth(Wand);
        Height:= MagickGetImageHeight(Wand);

        if (Width > aSize.cx) or (Height > aSize.cy) then
        begin
          // Calculate aspect width and height of thumb
          aSize:= TThumbnailManager.GetPreviewScaleSize(Width, Height);
          // Create image thumbnail
          Status:= MagickResizeImage(Wand, aSize.cx, aSize.cy, LanczosFilter, 1.0);
          if (Status = MagickFalse) then RaiseWandException(Wand);
        end;

        Status:= MagickSetImageFormat(Wand, 'PNG');
        if (Status = MagickFalse) then RaiseWandException(Wand);

        Memory:= MagickGetImageBlob(Wand, @MemorySize);
        if Assigned(Memory) then
        try
          BlobStream:= TBlobStream.Create(Memory, MemorySize);
          Bitmap:= TPortableNetworkGraphic.Create;
          try
            Bitmap.LoadFromStream(BlobStream);
            Result:= Graphics.TBitmap.Create;
            BitmapAssign(Result, Bitmap);
          except
            FreeAndNil(Result);
          end;
          Bitmap.Free;
          BlobStream.Free;
        finally
          MagickRelinquishMemory(Memory);
        end;
      except
        on E: Exception do
        DCDebug('ImageMagick: ' + E.Message);
      end;

    finally
      Wand:= DestroyMagickWand(Wand);
      MagickWandTerminus;
      // DCDebug('GetThumbnail finish: ' + IntToStr(GetTickCount));
    end;
  end;
end;

function SafeGetProcAddress(Lib : TlibHandle; const ProcName : AnsiString) : Pointer;
begin
  Result:= GetProcedureAddress(Lib, ProcName);
  if (Result = nil) then raise Exception.Create(EmptyStr);
end;

procedure Initialize;
var
  Version: Integer;
  LibraryName: AnsiString = 'libMagickWand-6.Q16.so.1';
begin
  MagickWand:= LoadLibrary(LibraryName);

  if (MagickWand = NilHandle) then
  for Version:= 7 downto 3 do
  begin
    LibraryName:= Format(libMagickWand, [Version]);
    MagickWand:= LoadLibrary(LibraryName);
    if (MagickWand <> NilHandle) then Break;
  end;

  if (MagickWand <> NilHandle) then
  try
    @MagickWandGenesis:= SafeGetProcAddress(MagickWand, 'MagickWandGenesis');
    @MagickWandTerminus:= SafeGetProcAddress(MagickWand, 'MagickWandTerminus');

    @NewMagickWand:= SafeGetProcAddress(MagickWand, 'NewMagickWand');
    @DestroyMagickWand:= SafeGetProcAddress(MagickWand, 'DestroyMagickWand');
    @MagickGetException:= SafeGetProcAddress(MagickWand, 'MagickGetException');

    @MagickRelinquishMemory:= SafeGetProcAddress(MagickWand, 'MagickRelinquishMemory');
    @MagickReadImage:= SafeGetProcAddress(MagickWand, 'MagickReadImage');
    @MagickGetImageWidth:= SafeGetProcAddress(MagickWand, 'MagickGetImageWidth');
    @MagickGetImageHeight:= SafeGetProcAddress(MagickWand, 'MagickGetImageHeight');
    @MagickResizeImage:=  SafeGetProcAddress(MagickWand, 'MagickResizeImage');

    @MagickSetImageFormat:= SafeGetProcAddress(MagickWand, 'MagickSetImageFormat');
    @MagickGetImageBlob:= SafeGetProcAddress(MagickWand, 'MagickGetImageBlob');

    // Register thumbnail provider
    TThumbnailManager.RegisterProvider(@GetThumbnail);
    DCDebug('ImageMagick: ' + LibraryName);
  except
  end;
end;

procedure Finalize;
begin
  if (MagickWand <> NilHandle) then FreeLibrary(MagickWand);
end;

initialization
  Initialize;

finalization
  Finalize;

end.