unit u_Grids;

interface

uses System.Types,
  u_SimTypes;

type
  { TGrid }
  TGrid = class
  private
    fCells: array[0..GRID_EXTENT, 0..GRID_EXTENT] of Byte;
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
      fCells[aX, aY] := 0;
end;

function TGrid.GetColor(aX, aY: Integer): Byte;
begin
  Result := fCells[aX, aY];
end;

procedure TGrid.SetColor(aX, aY: Integer; aColor: Byte);
begin
  fCells[aX, aY] := aColor;
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
