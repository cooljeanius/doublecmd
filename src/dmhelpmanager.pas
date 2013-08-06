{
    Double Commander
    -------------------------------------------------------------------------
    Help manager

    Copyright (C) 2008  Koblov Alexander (Alexx2000@mail.ru)

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

unit dmHelpManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Dialogs, LazHelpHTML;

type

  { TdmHelpManager }

  TdmHelpManager = class(TDataModule)
    HTMLBrowserHelpViewer: THTMLBrowserHelpViewer;
    HTMLHelpDatabase: THTMLHelpDatabase;
    procedure DataModuleCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  dmHelpMgr: TdmHelpManager;

implementation

{$R *.lfm}

uses
  {$IFDEF MSWindows}
  LCLIntf,
  {$ENDIF}
  uGlobsPaths, uGlobs, DCStrUtils, DCOSUtils, StrUtils;

{ TdmHelpManager }

procedure TdmHelpManager.DataModuleCreate(Sender: TObject);
{$IFDEF MSWindows}
var
  ABrowser, AParams: String;
{$ENDIF}
begin
  if NumCountChars('.', gPOFileName) < 2 then
    gHelpLang:= 'en'
  else
    begin
      gHelpLang:= ExtractDelimited(2, gPOFileName, ['.']);
      if not mbDirectoryExists(gpExePath + 'doc' + PathDelim + gHelpLang) then
        gHelpLang:= 'en';
    end;

  HTMLHelpDatabase.BaseURL:= 'file://' + gpExePath + 'doc' + PathDelim + gHelpLang;
  HTMLHelpDatabase.KeywordPrefix:= '/';

  {$IFDEF MSWindows}
  // Lazarus issue #0021637.
  if FindDefaultBrowser(ABrowser, AParams) then
  begin
    HTMLBrowserHelpViewer.BrowserPath := ABrowser;
    HTMLBrowserHelpViewer.BrowserParams := StringReplace(AParams, '%s', '"%s"', [rfReplaceAll]);
  end;
  {$ENDIF}
end;

end.
