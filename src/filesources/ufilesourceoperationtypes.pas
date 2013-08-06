unit uFileSourceOperationTypes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

type

  // Capabilities.
  // (or make a separate type TFileSourceCapability with fsc... ?)
  TFileSourceOperationType = (
    fsoList,
    fsoCopy,            // Copy files within the same file source.
    fsoCopyIn,
    fsoCopyOut,
    fsoMove,            // Move/rename files within the same file source.
    fsoDelete,
    fsoWipe,
    fsoSplit,
    fsoCombine,
    fsoCreateDirectory,
    //fsoCreateFile,
    //fsoCreateLink,
    fsoCalcChecksum,
    fsoCalcStatistics,  // Should probably always be supported if fsoList is supported.
    fsoSetFileProperty,
    fsoExecute,
    fsoTestArchive
  );

  TFileSourceOperationTypes = set of TFileSourceOperationType;

implementation

end.

