unit u_SimThreads;

interface

uses System.Classes, System.SyncObjs,

  u_SimTypes, u_Simulator, u_Scenarios, u_RenderBuffers;

type
  TSimSpeed = 1 .. 10;

  TSimThread = class(TThread)
  private
    fSimulator: TSimulator;
    fScenario: TScenario;
    fActive: Boolean;
    fIsDirty: Boolean;
    fLock: TCriticalSection;
    fStepsPerBatch: Integer;
    fSleepMs: Integer;
    fSpeed: TSimSpeed;
    procedure SetActive(const Value: Boolean);
    procedure SetSpeed(const Value: TSimSpeed);
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadScenario(AScenario: TScenario);
    procedure EndScenario;
    function PullSnapshot(var ADest: TRenderBuffer): Boolean;

    property Active: Boolean read fActive write SetActive;
    property Speed: TSimSpeed read fSpeed write SetSpeed;

  end;

implementation

{ TSimThread }

constructor TSimThread.Create;
begin
  inherited Create(True); // create suspended
  fSimulator := TSimulator.Create;
  fLock := TCriticalSection.Create;
  fSpeed := Low(TSimSpeed);
  SetSpeed(fSpeed);
end;

destructor TSimThread.Destroy;
begin
  Terminate;
  fActive := True;
  if Started then
    WaitFor;
  fLock.Free;
  fSimulator.Free;
  inherited;
end;

procedure TSimThread.EndScenario;
begin
  fActive := False;
  fLock.Acquire;
  try
    fSimulator.EndSession;
    fIsDirty := False;
  finally
    fLock.Release;
  end;
end;

procedure TSimThread.LoadScenario(AScenario: TScenario);
begin
  fActive := False;
  fLock.Acquire;
  try
    fScenario := AScenario;
    fSimulator.BeginSession(AScenario);
    fIsDirty := False;
  finally
    fLock.Release;
  end;
end;

procedure TSimThread.SetActive(const Value: Boolean);
begin
  fActive := Value;
  if Value and Suspended then
    Start;
end;

procedure TSimThread.Execute;
begin
  while not Terminated do
  begin
    if fActive then
    begin
      fLock.Acquire;
      try
        for var i := 1 to fStepsPerBatch do
          fSimulator.Step;
        fIsDirty := True;
      finally
        fLock.Release;
      end;

      if fSleepMs > 0 then
        Sleep(fSleepMs)
      else
        TThread.Yield;
    end
    else
      Sleep(1); // idle when paused, avoid spinning
  end;
end;

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

procedure TSimThread.SetSpeed(const Value: TSimSpeed);
begin
  if Value <> fSpeed then
  begin
    fSpeed := Value;
    case fSpeed of
      1: begin fStepsPerBatch := 1;    fSleepMs := 50;  end;
      2: begin fStepsPerBatch := 5;    fSleepMs := 20;  end;
      3: begin fStepsPerBatch := 20;   fSleepMs := 10;  end;
      4: begin fStepsPerBatch := 100;  fSleepMs := 5;   end;
      5: begin fStepsPerBatch := 500;  fSleepMs := 2;   end;
      6: begin fStepsPerBatch := 1000; fSleepMs := 1;   end;
      7: begin fStepsPerBatch := 2000; fSleepMs := 1;   end;
      8: begin fStepsPerBatch := 5000; fSleepMs := 0;   end;
      9: begin fStepsPerBatch := 10000; fSleepMs := 0;  end;
     10: begin fStepsPerBatch := 50000; fSleepMs := 0;  end;
    end;
  end;
end;

end.
