unit u_GridRenderer;

interface

uses System.Skia, System.Types,
  u_SimTypes, u_Grids;

type
  TAntRenderInfo = record
    Loc: TPoint;
    Facing: TDirection;
  end;
  TAntRenderArray = array of TAntRenderInfo;

  TGridRenderer = class
    class procedure RenderFrame(aCanvas: ISkCanvas; aWidth, aHeight: Integer;
      aGrid: TGrid; const Ants: TAntRenderArray);
  end;

implementation

uses System.UITypes, System.Math;

const
  COLOR_MAP: array[0 .. MAX_COLORS - 1] of TAlphaColor = (
    TAlphaColors.Black,
    TAlphaColors.White,
    TAlphaColors.Dodgerblue,
    TAlphaColors.Crimson);
  ANT_COLOR = TAlphaColors.Red;

{ TGridRenderer }

class procedure TGridRenderer.RenderFrame(aCanvas: ISkCanvas; aWidth,
  aHeight: Integer; aGrid: TGrid; const Ants: TAntRenderArray);
var
  cellSize: Single;
  offsetX, offsetY: Single;
  paint: ISkPaint;
  path: ISkPathBuilder;
  cx, cy: Single;
  half: Single;
begin
  // Calculate cell size for letterbox/pillarbox fit
  cellSize := Min(aWidth / (GRID_EXTENT + 1), aHeight / (GRID_EXTENT + 1));

  // Center the grid in the available space
  offsetX := (aWidth - cellSize * (GRID_EXTENT + 1)) / 2;
  offsetY := (aHeight - cellSize * (GRID_EXTENT + 1)) / 2;

  paint := TSkPaint.Create;
  paint.AntiAlias := False;
  paint.Style := TSkPaintStyle.Fill;

  // Draw grid cells
  for var y := 0 to GRID_EXTENT do
    for var x := 0 to GRID_EXTENT do
    begin
      var color := aGrid.GetColor(x, y);
      paint.Color := COLOR_MAP[color];
      aCanvas.DrawRect(
        RectF(
          offsetX + x * cellSize,
          offsetY + y * cellSize,
          offsetX + (x + 1) * cellSize,
          offsetY + (y + 1) * cellSize),
        paint);
    end;

  // Draw ants as triangles pointing in their facing direction
  paint.AntiAlias := True;
  paint.Color := ANT_COLOR;

  half := cellSize / 2;

  for var i := 0 to High(Ants) do
  begin
    cx := offsetX + Ants[i].Loc.X * cellSize + half;
    cy := offsetY + Ants[i].Loc.Y * cellSize + half;

    path := TSkPathBuilder.Create;
    case Ants[i].Facing of
      diNorth:
      begin
        path.MoveTo(PointF(cx, cy - half));
        path.LineTo(PointF(cx - half, cy + half));
        path.LineTo(PointF(cx + half, cy + half));
      end;
      diEast:
      begin
        path.MoveTo(PointF(cx + half, cy));
        path.LineTo(PointF(cx - half, cy - half));
        path.LineTo(PointF(cx - half, cy + half));
      end;
      diSouth:
      begin
        path.MoveTo(PointF(cx, cy + half));
        path.LineTo(PointF(cx + half, cy - half));
        path.LineTo(PointF(cx - half, cy - half));
      end;
      diWest:
      begin
        path.MoveTo(PointF(cx - half, cy));
        path.LineTo(PointF(cx + half, cy - half));
        path.LineTo(PointF(cx + half, cy + half));
      end;
    end;
    path.Close;
    aCanvas.DrawPath(path.Detach, paint);
  end;
end;

end.
