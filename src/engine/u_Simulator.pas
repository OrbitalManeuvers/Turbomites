unit u_Simulator;

interface

uses System.Types,
  u_SimTypes, u_States, u_StateMachines, u_Grids,
  u_GridRenderer, u_Scenarios, u_RenderBuffers;

type
  TAnt = record
    Facing: TDirection;
    Loc: TPoint;
    State: TStateMachine;
  end;

  TSimulator = class
  public
    fScenario: TScenario;
    fGrid: TCellArray;
    fAnts: TArray<TAnt>;
    fAntRenderInfo: TAntRenderArray;
    fStats: TSessionStats;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BeginSession(AScenario: TScenario);
    procedure EndSession;

    procedure Step;
    property Stats: TSessionStats read fStats;
  end;

implementation

uses System.UITypes;

{ TSimulator }

constructor TSimulator.Create;
begin
  inherited Create;
  fGrid.Clear;
  SetLength(fAnts, 0);
  SetLength(fAntRenderInfo, 0);
end;

destructor TSimulator.Destroy;
begin
  inherited;
end;

procedure TSimulator.BeginSession(aScenario: TScenario);
begin
  fScenario := aScenario;
  fGrid.Clear;

  for var i := 0 to fScenario.DotCount - 1 do
  begin
    var dot := fScenario.Dots[i];
    fGrid.SetColor(dot.Loc.x, dot.Loc.Y, dot.Color);
  end;

  FillChar(fStats, SizeOf(fStats), 0);

  SetLength(fAnts, fScenario.AntCount);
  SetLength(fAntRenderInfo, fScenario.AntCount);
  for var i := 0 to fScenario.AntCount - 1 do
  begin
    var a := fScenario.Ants[i];
    fAnts[i].Facing := a.Facing;
    fAnts[i].Loc := a.Loc;
    fAntRenderInfo[i].Loc := a.Loc;
    fAntRenderInfo[i].Facing := a.Facing;
    fAnts[i].State := TStateMachine.Create(fScenario.States);
    fAnts[i].State.SelectState(a.StateName);
  end;
end;

procedure TSimulator.EndSession;
begin
  for var a in fAnts do
    a.State.Free;
  SetLength(fAnts, 0);
end;

procedure TSimulator.Step;
begin
  Inc(fStats.StepCount);
  for var i := 0 to High(fAnts) do
  begin
    // 1. read color under feet
    var color := fGrid.GetColor(fAnts[i].Loc);

    // 2. select rule by color
    var rule := fAnts[i].State.CurrentState.GetRule(color);

    // 3. write rule color
    Inc(fStats.Erased[color]);
    Inc(fStats.Written[rule.Write]);
    fGrid.SetColor(fAnts[i].Loc, rule.Write);

    // 4. turn rule direction
    case rule.Turn of
      ttNone: ; // no change
      ttLeft:
      begin
        if fAnts[i].Facing = diNorth then
          fAnts[i].Facing := diWest
        else
          fAnts[i].Facing := Pred(fAnts[i].Facing);
      end;
      ttRight:
      begin
        if fAnts[i].Facing = diWest then
          fAnts[i].Facing := diNorth
        else
          fAnts[i].Facing := Succ(fAnts[i].Facing);
      end;
      ttAround:
        fAnts[i].Facing := TDirection((Ord(fAnts[i].Facing) + 2) mod 4);
    else
      // absolute directions
      fAnts[i].Facing := TDirection(Ord(rule.Turn) - Ord(ttNorth));
    end;

    // 5. move
    var newLoc := fAnts[i].Loc;
    case fAnts[i].Facing of
      diNorth: Dec(newLoc.Y);
      diEast: Inc(newLoc.X);
      diSouth: Inc(newLoc.Y);
      diWest: Dec(newLoc.X);
    end;

    if newLoc.X > GRID_EXTENT then
      newLoc.X := 0;
    if newLoc.X < 0 then
      newLoc.X := GRID_EXTENT;
    if newLoc.Y < 0 then
      newLoc.Y := GRID_EXTENT;
    if newLoc.Y > GRID_EXTENT then
      newLoc.Y := 0;

    fAnts[i].Loc := newLoc;
    fAntRenderInfo[i].Loc := newLoc;
    fAntRenderInfo[i].Facing := fAnts[i].Facing;

    // 6. change state to rule's next state, if specified
    if rule.State <> '' then
    begin
      fAnts[i].State.SelectState(rule.State);
    end;

  end;



end;

end.
