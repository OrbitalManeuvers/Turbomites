unit u_Simulator;

interface

uses System.Skia, System.Types,
  u_SimTypes, u_States, u_StateMachines, u_Grids,
  u_GridRenderer, u_Scenarios;

type
  TAnt = record
    Facing: TDirection;
    Loc: TPoint;
    State: TStateMachine;
  end;

  TSimulator = class
  private
    fScenario: TScenario;
    fGrid: TGrid;
    fAnts: TArray<TAnt>;
    fAntRenderInfo: TAntRenderArray;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BeginSession(AScenario: TScenario);
    procedure EndSession;

    procedure Step;
    procedure Render(ACanvas: ISkCanvas; aWidth, aHeight: Integer);
  end;

implementation

uses System.UITypes;

{ TSimulator }

constructor TSimulator.Create;
begin
  inherited Create;
  fGrid := TGrid.Create;
  fGrid.Clear;
  SetLength(fAnts, 0);
  SetLength(fAntRenderInfo, 0);
end;

destructor TSimulator.Destroy;
begin
  fGrid.Free;
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

procedure TSimulator.Render(ACanvas: ISkCanvas; aWidth, aHeight: Integer);
var
  paint: ISkPaint;
begin
  paint := TSkPaint.Create;
  paint.Color := TAlphaColors.Darkslategrey; // make letterbox slightly visible
  paint.Style := TSkPaintStyle.Fill;
  aCanvas.DrawRect(RectF(0, 0, aWidth, aHeight), paint);

  TGridRenderer.RenderFrame(ACanvas, aWidth, aHeight, fGrid, fAntRenderInfo);
end;

procedure TSimulator.Step;
begin
  for var i := 0 to High(fAnts) do
  begin
    // 1. read color under feet
    var color := fGrid.GetColor(fAnts[i].Loc);

    // 2. select rule by color
    var rule := fAnts[i].State.CurrentState.GetRule(color);

    // 3. write rule color
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

    // 6. change state to rule's next state, or remain in current state if no "state" node
    if rule.State <> '' then
    begin
      fAnts[i].State.SelectState(rule.State);
    end;

  end;



end;

end.
