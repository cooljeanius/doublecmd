unit uUniqueInstance;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SimpleIPC, uCmdLineParams;

type

  TOnUniqueInstanceMessage = procedure (Sender: TObject; Params: TCommandLineParams) of object;

  { TUniqueInstance }

  TUniqueInstance = class
  private
    FHandle: THandle;
    FInstanceName: UTF8String;
    FServerIPC: TSimpleIPCServer;
    FClientIPC: TSimpleIPCClient;
    FOnMessage: TOnUniqueInstanceMessage;
    {$IF DEFINED(UNIX)}
    FMyProgramCreateSemaphore:Boolean;
    FPeekThread: TThreadID;
    {$ENDIF}

    procedure OnNative(Sender: TObject);

    procedure CreateServer;
    procedure CreateClient;

    function IsRunning: Boolean;
    procedure DisposeMutex;
  public
    constructor Create(aInstanceName: String);
    destructor Destroy; override;

    function IsRunInstance: Boolean;
    procedure SendParams;

    procedure RunListen;
    procedure StopListen;

    property OnMessage: TOnUniqueInstanceMessage read FOnMessage write FOnMessage;
  end;

function IsUniqueInstance(aInstanceName: String): Boolean;

{en
   Returns @true if current application instance is allowed to run.
   Returns @false if current instance should not be run.
}
function IsInstanceAllowed: Boolean;

var
  UniqueInstance: TUniqueInstance = nil;

implementation

uses
  {$IF DEFINED(MSWINDOWS)}
  Windows,
  {$ELSEIF DEFINED(UNIX)}
  ipc,
  {$ENDIF}
  StrUtils, FileUtil, uGlobs, uDebug;

{$IF DEFINED(UNIX)}
type
  TUnixIPCServer = class(TSimpleIPCServer) end;

function PeekMessage(Parameter: Pointer): PtrInt;
var
  UnixIPC: TUnixIPCServer absolute Parameter;
begin
  while UnixIPC.Active do
  begin
    if UnixIPC.PeekMessage(100, False) then
      TThread.Synchronize(nil, @UnixIPC.ReadMessage);
  end;
end;
{$ENDIF}

{ TUniqueInstance }

procedure TUniqueInstance.OnNative(Sender: TObject);
var
  Params: TCommandLineParams;
begin
  if Assigned(FOnMessage) then
    begin
      FServerIPC.MsgData.Seek(0, soFromBeginning);
      FServerIPC.MsgData.ReadBuffer(Params, FServerIPC.MsgType);
      FOnMessage(Self, Params);
    end;
end;

procedure TUniqueInstance.CreateServer;
begin
  if FServerIPC = nil then
    begin
      FServerIPC:= TSimpleIPCServer.Create(nil);
      FServerIPC.OnMessage:= @OnNative;
    end;
  if FClientIPC <> nil then
    FreeAndNil(FClientIPC);
end;

procedure TUniqueInstance.CreateClient;
begin
  if FClientIPC = nil then
    FClientIPC:= TSimpleIPCClient.Create(nil);
end;

function TUniqueInstance.IsRunning: Boolean;
{$IF DEFINED(MSWINDOWS)}
var
  MutexName: AnsiString;
begin
  Result:= False;
  MutexName:= ExtractFileName(ParamStr(0));
  FHandle:= OpenMutex(MUTEX_MODIFY_STATE, False, PAnsiChar(MutexName));
  if FHandle = 0 then
    FHandle:= CreateMutex(nil, True, PAnsiChar(MutexName))
  else
    begin
      if WaitForSingleObject(FHandle, 0) <> WAIT_ABANDONED then
        Result:= True;
    end;
end;
{$ELSEIF DEFINED(UNIX)}
const
  SEM_PERM = 6 shl 6 { 0600 };
var
  semkey: TKey;
  status: longint = 0;
  arg: tsemun;

  function semlock(semid: longint): boolean;
  // increase special Value in semaphore structure (value decreases automatically
  // when program completed incorrectly)
  var
    p_buf: tsembuf;
  begin
    p_buf.sem_num := 0;
    p_buf.sem_op := 1;
    p_buf.sem_flg := SEM_UNDO;
    Result:= semop(semid, @p_buf, 1) = 0;
  end;

begin
  Result := False;
  semkey := ftok(PAnsiChar(ParamStr(0)), 0);
  // try create semapore for semkey
  // If semflg specifies both IPC_CREAT and IPC_EXCL and a semaphore set already
  // exists for semkey, then semget() return -1 and errno set to EEXIST
  FHandle := semget(semkey, 1, SEM_PERM or IPC_CREAT or IPC_EXCL);

  // if semaphore exists
  if FHandle = -1 then
    begin
      // get semaphore id
      FHandle := semget(semkey, 1, 0);
      // get special Value from semaphore structure
      status := semctl(FHandle, 0, SEM_GETVAL, arg);

      if status = 1 then
      // There is other running copy of the program
        begin
          Result := True;
          // Not to release semaphore when exiting from the program
          FMyProgramCreateSemaphore := false;
        end
      else
      begin
      // Other copy of the program has created a semaphore but has been completed incorrectly
      // increase special Value in semaphore structure (value decreases automatically
      // when program completed incorrectly)
        semlock(FHandle);

      // its one copy of program running, release semaphore when exiting from the program
        FMyProgramCreateSemaphore := true;
      end;
    end
  else
    begin
      // its one copy of program running, release semaphore when exiting from the program
      FMyProgramCreateSemaphore := true;
      // set special Value in semaphore structure to 0
      arg.val := 0;
      status := semctl(FHandle, 0, SEM_SETVAL, arg);
      // increase special Value in semaphore structure (value decreases automatically
      // when program completed incorrectly)
      semlock(FHandle);
    end;
  end;
{$ENDIF}

procedure TUniqueInstance.DisposeMutex;
{$IF DEFINED(MSWINDOWS)}
begin
  ReleaseMutex(FHandle);
end;
{$ELSEIF DEFINED(UNIX)}
var
  arg: tsemun;
begin
  // If my copy of the program created a semaphore then released it
  if FMyProgramCreateSemaphore then
    semctl(FHandle, 0, IPC_RMID, arg);
end;
{$ENDIF}

function TUniqueInstance.IsRunInstance: Boolean;
begin
  CreateClient;
  FClientIPC.ServerID:= FInstanceName;
  Result:= IsRunning and FClientIPC.ServerRunning;
end;

procedure TUniqueInstance.SendParams;
var
  Stream: TMemoryStream = nil;
begin
  CreateClient;
  FClientIPC.ServerID:= FInstanceName;
  if not FClientIPC.ServerRunning then
    Exit;

  Stream:= TMemoryStream.Create;
  Stream.WriteBuffer(CommandLineParams, SizeOf(TCommandLineParams));
  try
    FClientIPC.Connect;
    Stream.Seek(0, soFromBeginning);
    FClientIPC.SendMessage(SizeOf(TCommandLineParams), Stream);
  finally
    Stream.Free;
    FClientIPC.Disconnect;
  end;
end;

procedure TUniqueInstance.RunListen;
begin
  CreateServer;
  FServerIPC.ServerID:= FInstanceName;
  FServerIPC.Global:= True;
  FServerIPC.StartServer;
  {$IF DEFINED(UNIX)}
  FPeekThread:= BeginThread(@PeekMessage, FServerIPC);
  {$ENDIF}
end;

procedure TUniqueInstance.StopListen;
begin
  DisposeMutex;
  if FServerIPC = nil then Exit;
  FServerIPC.StopServer;
  {$IF DEFINED(UNIX)}
  DCDebug('Waiting for UniqueInstance thread');
  WaitForThreadTerminate(FPeekThread, 0);
  DCDebug('Close UniqueInstance thread');
  CloseThread(FPeekThread);
  {$ENDIF}
end;

constructor TUniqueInstance.Create(aInstanceName: String);
begin
  FInstanceName:= aInstanceName;
end;

destructor TUniqueInstance.Destroy;
begin
  if Assigned(FClientIPC) then
    FreeAndNil(FClientIPC);
  if Assigned(FServerIPC) then
    FreeAndNil(FServerIPC);
  inherited Destroy;
end;


function IsUniqueInstance(aInstanceName: String): Boolean;
begin
  Result:= True;
  UniqueInstance:= TUniqueInstance.Create(aInstanceName);
  if UniqueInstance.IsRunInstance then
   begin
    UniqueInstance.SendParams;
    Exit(False);
   end;
  UniqueInstance.RunListen;
end;

function IsInstanceAllowed: Boolean;
begin
  Result := (not gOnlyOneAppInstance) or IsUniqueInstance(ApplicationName);
end;

finalization
  if Assigned(UniqueInstance) then
    begin
      UniqueInstance.StopListen;
      FreeAndNil(UniqueInstance);
    end;
end.

