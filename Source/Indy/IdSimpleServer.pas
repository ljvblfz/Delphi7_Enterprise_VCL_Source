unit IdSimpleServer;

interface

uses
  Classes,
  IdSocketHandle, IdTCPConnection, IdStackConsts;

type
  TIdSimpleServer = class(TIdTCPConnection)
  protected
    FAbortedRequested: Boolean;
    FAcceptWait: Integer;
    // FBinding: TIdSocketHandle;
    FBoundIP: String;
    FBoundPort: Integer;
    FListenHandle: TIdStackSocketHandle;
    FListening: Boolean;
    //
    function GetBinding: TIdSocketHandle;
  public
    procedure Abort; virtual;
    procedure BeginListen; virtual;
    procedure Bind; virtual;
    constructor Create(AOwner: TComponent); override;
    procedure CreateBinding;
    procedure EndListen; virtual;
    function Listen: Boolean; virtual;
    procedure ResetConnection; override;
    //
    property AcceptWait: integer read FAcceptWait write FAcceptWait;
    property Binding: TIdSocketHandle read GetBinding;
    property ListenHandle: TIdStackSocketHandle read FListenHandle;
  published
    property BoundIP: string read FBoundIP write FBoundIP;
    property BoundPort: Integer read FBoundPort write FBoundPort;
  end;

implementation

uses
  IdGlobal, IdStack, IdIOHandlerSocket,
  SysUtils;

{ TIdSimpleServer }

procedure TIdSimpleServer.Abort;
begin
  FAbortedRequested := True;
end;

procedure TIdSimpleServer.BeginListen;
begin
  // Must be before IOHandler as it resets it
  if not Assigned(Binding) then begin
    ResetConnection;
    CreateBinding;
  end;
  try
    if ListenHandle = Id_INVALID_SOCKET then begin
      Bind;
    end;
    Binding.Listen(15);
    FListening := True;
  except
    FreeAndNil(FIOHandler);
    raise;
  end;
end;

procedure TIdSimpleServer.Bind;
begin
  with Binding do begin
    try
      AllocateSocket;
      FListenHandle := Handle;
      IP := BoundIP;
      Port := BoundPort;
      Bind;
    except
      FListenHandle := Id_INVALID_SOCKET;
      raise;
    end;
  end;
end;

constructor TIdSimpleServer.Create(AOwner: TComponent);
begin
  inherited;
  FListenHandle := Id_INVALID_SOCKET;
end;

procedure TIdSimpleServer.CreateBinding;
begin
  IOHandler := TIdIOHandlerSocket.Create(Self);
  IOHandler.Open;
end;

procedure TIdSimpleServer.EndListen;
begin
  ResetConnection;
end;

function TIdSimpleServer.GetBinding: TIdSocketHandle;
begin
  if Assigned(IOHandler) then begin
    Result := TIdIOHandlerSocket(IOHandler).Binding;
  end else begin
    Result := nil;
  end;
end;

function TIdSimpleServer.Listen: Boolean;
begin
  //TODO: Add a timeout to this function.
  Result := False;
  if not FListening then begin
    BeginListen;
  end;
  with Binding do begin
    if FAbortedRequested = False then
    begin
      while (FAbortedRequested = False) and (Result = False) do begin
        Result := Readable(AcceptWait);
      end;
    end;
    if Result then begin
      binding.listen(1);
      binding.Accept(binding.Handle);

    end;
    GStack.WSCloseSocket(ListenHandle);
    FListenHandle := Id_INVALID_SOCKET;
  end;
end;

procedure TIdSimpleServer.ResetConnection;
begin
  inherited ResetConnection;
  FAbortedRequested := False;
  FListening := False;
  FreeAndNil(FIOHandler);
end;

end.
