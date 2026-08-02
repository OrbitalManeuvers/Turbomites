unit u_SimThreads;

interface

uses System.SyncObjs, u_SimTypes, u_Simulator, u_Scenarios, u_RenderBuffers;

type
  TSimThread = class
  private
    fSimulator: TSimulator;
    fScenario: TScenario;
    fActive: Boolean;
    fIsDirty: Boolean;
    fLock: TCriticalSection;
    procedure SetActive(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    // temp
    procedure Step;

    procedure LoadScenario(aScenario: TScenario);
    procedure EndScenario;
    function PullSnapshot(var ADest: TRenderBuffer): Boolean;

    property Active: Boolean read fActive write SetActive;

  end;

implementation

{ TSimThread }

constructor TSimThread.Create;
begin
  inherited Create;
  fSimulator := TSimulator.Create;
  fLock := TCriticalSection.Create;
end;

destructor TSimThread.Destroy;
begin
  fLock.Free;
  fSimulator.Free;
  inherited;
end;

procedure TSimThread.EndScenario;
begin
  fSimulator.EndSession;
end;

procedure TSimThread.LoadScenario(aScenario: TScenario);
begin
  fScenario := aScenario;
  fSimulator.BeginSession(aScenario);
end;

procedure TSimThread.SetActive(const Value: Boolean);
begin
  fActive := Value;
end;

procedure TSimThread.Step;
begin
  fLock.Acquire;
  try
    fSimulator.Step;
    fIsDirty := True;
  finally
    fLock.Release;
  end;
end;

//procedure TSimThread.Execute;
//begin
//  while not Terminated do
//  begin
//    if fRunning then
//    begin
//      fLock.Acquire;
//      try
//        for var I := 1 to fStepsPerBatch do
//          fSim.Step;
//
//        fIsDirty := True;
//      finally
//        fLock.Release;
//      end;
//    end;
//
//    // Crucial: yield the rest of the thread's timeslice so the Main Thread
//    // can grab the lock if an OnDraw is pending.
//    TThread.Yield;
//  end;
//end;

function TSimThread.PullSnapshot(var ADest: TRenderBuffer): Boolean;
begin
  fLock.Acquire;
  try
    Result := fIsDirty;
    if fIsDirty then
    begin
      // Fast memory copy the state from the simulator into the shared render buffer
      ADest.Cells := fSimulator.fGrid;
      ADest.Ants := Copy(fSimulator.fAntRenderInfo);
      ADest.Stats := fSimulator.fStats;
      fIsDirty := False;
    end;
  finally
    fLock.Release;
  end;
end;

end.
