unit u_Grids;

interface

uses System.Types,

  u_SimTypes;

type
  { TGrid }
  TGrid = record helper for TCellArray
  public
    procedure Clear;
    function GetColor(aX, aY: Integer): Byte; overload;
    function GetColor(Loc: TPoint): Byte; overload;

    procedure SetColor(aX, aY: Integer; aColor: Byte); overload;
    procedure SetColor(Loc: TPoint; aColor: Byte); overload;
  end;

implementation

{ TGrid }

procedure TGrid.Clear;
begin
  for var aY := 0 to GRID_EXTENT do
    for var aX := 0 to GRID_EXTENT do
      Grid[aX, aY] := 0;
end;

function TGrid.GetColor(aX, aY: Integer): Byte;
begin
  Result := Grid[aX, aY];
end;

procedure TGrid.SetColor(aX, aY: Integer; aColor: Byte);
begin
  Grid[aX, aY] := aColor;
end;

function TGrid.GetColor(Loc: TPoint): Byte;
begin
  Result := GetColor(Loc.X, Loc.Y);
end;

procedure TGrid.SetColor(Loc: TPoint; aColor: Byte);
begin
  SetColor(Loc.X, Loc.Y, aColor);
end;

end.
