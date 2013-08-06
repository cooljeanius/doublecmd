unit uFileSourceWipeOperation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, syncobjs,
  uFileSourceOperation,
  uFileSourceOperationTypes,
  uFileSource,
  uFile;

type

  TFileSourceWipeOperationStatistics = record
    CurrentFile: String;
    CurrentFileTotalBytes: Int64;
    CurrentFileDoneBytes: Int64;
    TotalFiles: Int64;
    DoneFiles: Int64;
    TotalBytes: Int64;
    DoneBytes: Int64;
    BytesPerSecond: Int64;
    RemainingTime: TDateTime;
  end;

  {en
     Operation that wipes files from an arbitrary file source.
     File source should match the class type.
  }

  { TFileSourceWipeOperation }

  TFileSourceWipeOperation = class(TFileSourceOperation)

  private
    FStatistics: TFileSourceWipeOperationStatistics;
    FStatisticsAtStartTime: TFileSourceWipeOperationStatistics;
    FStatisticsLock: TCriticalSection;             //<en For synchronizing statistics.
    FFileSource: IFileSource;
    FFilesToWipe: TFiles;

  protected
    function GetID: TFileSourceOperationType; override;
    procedure DoReloadFileSources; override;

    procedure UpdateStatistics(var NewStatistics: TFileSourceWipeOperationStatistics);
    procedure UpdateStatisticsAtStartTime; override;

    property FileSource: IFileSource read FFileSource;
    property FilesToWipe: TFiles read FFilesToWipe;

  public
    constructor Create(aTargetFileSource: IFileSource;
                       var theFilesToWipe: TFiles); virtual reintroduce;
    destructor Destroy; override;

    function GetDescription(Details: TFileSourceOperationDescriptionDetails): String; override;
    function RetrieveStatistics: TFileSourceWipeOperationStatistics;
  end;

implementation

uses
  uDCUtils, uLng;

constructor TFileSourceWipeOperation.Create(aTargetFileSource: IFileSource;
                                            var theFilesToWipe: TFiles);
begin
  with FStatistics do
  begin
    CurrentFile := '';

    TotalFiles := 0;
    DoneFiles := 0;
    TotalBytes := 0;
    DoneBytes := 0;
    CurrentFileTotalBytes := 0;
    CurrentFileDoneBytes := 0;
    BytesPerSecond := 0;
    RemainingTime := 0;
  end;

  FStatisticsLock := TCriticalSection.Create;

  inherited Create(aTargetFileSource);

  FFileSource := aTargetFileSource;
  FFilesToWipe := theFilesToWipe;
  theFilesToWipe := nil;
end;

destructor TFileSourceWipeOperation.Destroy;
begin
  inherited Destroy;

  if Assigned(FStatisticsLock) then
    FreeAndNil(FStatisticsLock);
  if Assigned(FFilesToWipe) then
    FreeAndNil(FFilesToWipe);
end;

function TFileSourceWipeOperation.GetID: TFileSourceOperationType;
begin
  Result := fsoWipe;
end;

procedure TFileSourceWipeOperation.DoReloadFileSources;
begin
  FFileSource.Reload(FFilesToWipe.Path);
end;

function TFileSourceWipeOperation.GetDescription(Details: TFileSourceOperationDescriptionDetails): String;
begin
  case Details of
    fsoddJobAndTarget:
    begin
      if FilesToWipe.Count = 1 then
        Result := Format(rsOperWipingSomething, [FilesToWipe[0].FullPath])
      else
        Result := Format(rsOperWipingIn, [FilesToWipe.Path]);
    end;
    else
      Result := rsOperWiping;
  end;
end;

procedure TFileSourceWipeOperation.UpdateStatistics(var NewStatistics: TFileSourceWipeOperationStatistics);
begin
  FStatisticsLock.Acquire;
  try
    // Check if the value by which we calculate progress and remaining time has changed.
    if FStatistics.DoneBytes <> NewStatistics.DoneBytes then
    begin
      with NewStatistics do
      begin
        RemainingTime :=
          EstimateRemainingTime(FStatisticsAtStartTime.DoneBytes,
                                DoneBytes,
                                TotalBytes,
                                StartTime,
                                SysUtils.Now,
                                BytesPerSecond);

        // Update overall progress.
        if TotalBytes <> 0 then
          UpdateProgress(DoneBytes/TotalBytes);
      end;
    end;

    FStatistics := NewStatistics;

  finally
    FStatisticsLock.Release;
  end;
end;

procedure TFileSourceWipeOperation.UpdateStatisticsAtStartTime;
begin
  FStatisticsLock.Acquire;
  try
    Self.FStatisticsAtStartTime := Self.FStatistics;
  finally
    FStatisticsLock.Release;
  end;
end;

function TFileSourceWipeOperation.RetrieveStatistics: TFileSourceWipeOperationStatistics;
begin
  // Statistics have to be synchronized because there are multiple values
  // and they all have to be consistent at every moment.
  FStatisticsLock.Acquire;
  try
    Result := Self.FStatistics;
  finally
    FStatisticsLock.Release;
  end;
end;

end.

