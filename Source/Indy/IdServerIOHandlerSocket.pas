unit IdServerIOHandlerSocket;

interface

Uses
  SysUtils, IdGlobal, IdThread, IdServerIOHandler, IdStackConsts, IdIOHandler, IdIOHandlerSocket;

type
  TIdServerIOHandlerSocket = class(TIdServerIOHandler)
  public
    procedure Init; override;
    function Accept(ASocket: TIdStackSocketHandle;
      AThread: TIdThread = nil): TIdIOHandler; override;
  end;

implementation

uses Classes;

{ TIdServerIOHandlerSocket }

procedure TIdServerIOHandlerSocket.Init;
begin
  //
end;

function TIdServerIOHandlerSocket.Accept(ASocket: TIdStackSocketHandle;
  AThread: TIdThread = nil): TIdIOHandler;
Var
  LIOHandler: TIdIOHandlerSocket;
begin
  LIOHandler := TIdIOHandlerSocket.Create(nil);
  LIOHandler.Open;
  Result := nil;
  if Assigned(AThread) then begin
    while not AThread.Stopped do begin
      if LIOHandler.Binding.Select(ASocket, 100) then begin  // Wait for 100 ms
        if LIOHandler.Binding.Accept(ASocket) then begin
          Result := LIOHandler;
          EXIT;
        end else begin
          FreeAndNil(LIOHandler);
          EXIT;
        end;//if Accept
      end;//if select
    end;
    if AThread.Stopped then begin
      FreeAndNil(LIOHandler);
    end;
  end
  // Old way for compatibility
  else begin
    if LIOHandler.Binding.Accept(ASocket) then begin
      Result := LIOHandler;
      Exit;
    end else begin
      FreeAndNil(LIOHandler);
    end;
  end;
end;

end.
 
