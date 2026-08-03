unit u_Grids;

interface

uses System.Types,

  u_SimTypes;

type
  { TGrid }
  TGrid = record helper for TCellArray
  public
    procedure Clear;
    function GetColor(AX, AY: Integer): Byte; overload;
    function GetColor(ALoc: TPoint): Byte; overload;

    procedure SetColor(AX, AY: Integer; AColor: Byte); overload;
    procedure SetColor(ALoc: TPoint; AColor: Byte); overload;
  end;

implementation

{ TGrid }

procedure TGrid.Clear;
begin
  for var aY := 0 to GRID_EXTENT do
    for var aX := 0 to GRID_EXTENT do
      Grid[aX, aY] := 0;
end;

function TGrid.GetColor(AX, AY: Integer): Byte;
begin
  Result := Grid[AX, AY];
end;

procedure TGrid.SetColor(AX, AY: Integer; AColor: Byte);
begin
  Grid[AX, AY] := AColor;
end;

function TGrid.GetColor(ALoc: TPoint): Byte;
begin
  Result := GetColor(ALoc.X, ALoc.Y);
end;

procedure TGrid.SetColor(ALoc: TPoint; AColor: Byte);
begin
  SetColor(ALoc.X, ALoc.Y, AColor);
end;

end.
