unit u_StatsPainter;

interface

uses System.Skia,

  u_SimTypes, u_RenderBuffers;

type
  TStatsDisplayMode = (sdPercentBars, sdWrittenVsErased);

  TStatsPainter = class
    class procedure RenderStats(Canvas: ISkCanvas; Width, Height: Integer;
      const Stats: TSessionStats; Mode: TStatsDisplayMode);
  end;

implementation

uses System.Types, System.UITypes, System.SysUtils, System.Math;

const
  STATS_FONT = 'Arial';
  STATS_LABEL_COLOR = TAlphaColors.White;
  STATS_VALUE_COLOR = TAlphaColors.Black;
  STATS_BACKGROUND_COLOR = TAlphaColors.Slategray;
  STATS_FONT_SIZE = 14.0;
  BAR_PADDING = 4;

{ TStatsPainter }

class procedure TStatsPainter.RenderStats(Canvas: ISkCanvas; Width, Height: Integer;
  const Stats: TSessionStats; Mode: TStatsDisplayMode);
var
  paint: ISkPaint;
  font: ISkFont;
  typeface: ISkTypeface;
  headerHeight: Single;
  barAreaTop: Single;
  barAreaHeight: Single;
  barHeight: Single;
  barY: Single;
  barWidth: Single;
  total: Int64;
  maxVal: Cardinal;
  i: Integer;
  stepText: string;
  textBounds: TRectF;
begin
  // Background
  paint := TSkPaint.Create;
  paint.Style := TSkPaintStyle.Fill;
  paint.Color := STATS_BACKGROUND_COLOR;
  Canvas.DrawRect(RectF(0, 0, Width, Height), paint);

  // Font setup
  typeface := TSkTypeface.MakeFromName(STATS_FONT, TSkFontStyle.Bold);
  font := TSkFont.Create(typeface, STATS_FONT_SIZE);

  // Draw step count header
  stepText := 'Total steps: ' + FormatFloat('#,##0', Stats.StepCount);
  font.MeasureText(stepText, textBounds, paint);
  headerHeight := textBounds.Height + BAR_PADDING * 2;

  paint.Color := STATS_VALUE_COLOR;
  Canvas.DrawSimpleText(stepText, BAR_PADDING, headerHeight - BAR_PADDING, font, paint);

  // Bar chart area
  barAreaTop := headerHeight;
  barAreaHeight := Height - barAreaTop;

  case Mode of
    sdPercentBars:
    begin
      // Calculate total writes across all colors
      total := 0;
      for i := 0 to MAX_COLORS - 1 do
        total := total + Stats.Written[i];

      // One bar per color, width proportional to percentage of total writes
      barHeight := (barAreaHeight - BAR_PADDING * (MAX_COLORS + 1)) / MAX_COLORS;

      for i := 0 to MAX_COLORS - 1 do
      begin
        barY := barAreaTop + BAR_PADDING + i * (barHeight + BAR_PADDING);

        if total > 0 then
          barWidth := (Stats.Written[i] / total) * (Width - BAR_PADDING * 2)
        else
          barWidth := 0;

        paint.Color := COLOR_MAP[i];
        if barWidth > 0 then
          Canvas.DrawRect(RectF(BAR_PADDING, barY, BAR_PADDING + barWidth, barY + barHeight), paint);
      end;
    end;

    sdWrittenVsErased:
    begin
      // Find max value across all written and erased entries for normalization
      maxVal := 0;
      for i := 0 to MAX_COLORS - 1 do
      begin
        maxVal := Max(maxVal, Stats.Written[i]);
        maxVal := Max(maxVal, Stats.Erased[i]);
      end;

      // Two bars per color (written on top, erased below), grouped
      barHeight := (barAreaHeight - BAR_PADDING * (MAX_COLORS * 2 + MAX_COLORS + 1))
        / (MAX_COLORS * 2);

      barY := barAreaTop + BAR_PADDING;

      for i := 0 to MAX_COLORS - 1 do
      begin
        // Written bar (full saturation)
        if maxVal > 0 then
          barWidth := (Stats.Written[i] / maxVal) * (Width - BAR_PADDING * 2)
        else
          barWidth := 0;

        paint.Color := COLOR_MAP[i];
        if barWidth > 0 then
          Canvas.DrawRect(RectF(BAR_PADDING, barY, BAR_PADDING + barWidth, barY + barHeight), paint);

        barY := barY + barHeight + BAR_PADDING;

        // Erased bar (dimmed version of the same color)
        if maxVal > 0 then
          barWidth := (Stats.Erased[i] / maxVal) * (Width - BAR_PADDING * 2)
        else
          barWidth := 0;

        paint.Color := TAlphaColor((COLOR_MAP[i] and $00FFFFFF) or $80000000);
        if barWidth > 0 then
          Canvas.DrawRect(RectF(BAR_PADDING, barY, BAR_PADDING + barWidth, barY + barHeight), paint);

        barY := barY + barHeight + BAR_PADDING * 2; // extra gap between color groups
      end;
    end;
  end;
end;

end.
