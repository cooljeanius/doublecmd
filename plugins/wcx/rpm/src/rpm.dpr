//***************************************************************
// This file is part of RPMWCX, a archiver plugin for
// Windows Commander.
// Copyright (C) 2000 Mandryka Yurij  e-mail:braingroup@hotmail.ru
//***************************************************************
{
  Add some changes for Lazarus and Linux compability
  Copyright (C) 2007-2012  Koblov Alexander (Alexx2000@mail.ru)
}
//***************************************************************
// This code based on Christian Ghisler (support@ghisler.com) sources
//***************************************************************

library rpm;

uses
  SysUtils,
  Classes,
  WcxPlugin,
  rpm_io in 'rpm_io.pas',
  rpm_def in 'rpm_def.pas',
  rpm_archive in 'rpm_archive.pas';

exports
  CloseArchive,
  GetPackerCaps,
  OpenArchive,
  ProcessFile,
  ReadHeader,
  SetChangeVolProc,
  SetProcessDataProc;
  
{$R *.res}

begin
{$IFNDEF MSWINDOWS}
  WriteLn('Rpm plugin is loaded');
{$ENDIF}
end.
