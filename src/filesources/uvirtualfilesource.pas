unit uVirtualFileSource;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uFileSource;

type

  IVirtualFileSource = interface(IFileSource)
  end;

  {en
     Base class for any virtual file source
     (this can be any list of files, internal lists, temporary,
      links to favourite files, results from search queries, etc.).
  }
  TVirtualFileSource = class(TFileSource, IVirtualFileSource)
  end;

implementation

end.

