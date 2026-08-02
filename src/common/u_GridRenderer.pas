unit u_GridRenderer;

interface

uses System.Skia, System.Types,

  u_SimTypes, u_Grids, u_RenderBuffers;

type
  TGridRenderer = class
  public
    class procedure RenderFrame(Canvas: ISkCanvas; Width, Height: Integer;
      const Buffer: TRenderBuffer);
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

class procedure TGridRenderer.RenderFrame(Canvas: ISkCanvas; Width, Height: Integer;
  const Buffer: TRenderBuffer);
var
  cellSize: Single;
  offsetX, offsetY: Single;
  paint: ISkPaint;
  path: ISkPathBuilder;
  cx, cy: Single;
  half: Single;
begin
  // Calculate cell size for letterbox/pillarbox fit
  cellSize := Min(Width / (GRID_EXTENT + 1), Height / (GRID_EXTENT + 1));

  // Center the grid in the available space
  offsetX := (Width - cellSize * (GRID_EXTENT + 1)) / 2;
  offsetY := (Height - cellSize * (GRID_EXTENT + 1)) / 2;

  paint := TSkPaint.Create;
  paint.AntiAlias := False;
  paint.Style := TSkPaintStyle.Fill;

  // Draw grid cells
  for var y := 0 to GRID_EXTENT do
    for var x := 0 to GRID_EXTENT do
    begin
      var color := Buffer.Cells.GetColor(x, y);
      paint.Color := COLOR_MAP[color];
      Canvas.DrawRect(
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

  for var i := 0 to High(Buffer.Ants) do
  begin
    cx := offsetX + Buffer.Ants[i].Loc.X * cellSize + half;
    cy := offsetY + Buffer.Ants[i].Loc.Y * cellSize + half;

    path := TSkPathBuilder.Create;
    case Buffer.Ants[i].Facing of
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
    Canvas.DrawPath(path.Detach, paint);
  end;
end;

end.
