unit u_SplashPainter;

interface

uses System.Skia;

type
  TSplashPainter = class
    class procedure RenderSplash(Canvas: ISkCanvas; Width, Height: Integer);
  end;

implementation

uses Vcl.Skia, System.UITypes, System.Types;

{ TSplashPainer }

const
  TITLE = 'Turbomites';
  TITLE_FONT = 'Arial';
  TITLE_COLOR = TAlphaColors.Royalblue;

class procedure TSplashPainter.RenderSplash(Canvas: ISkCanvas; Width, Height: Integer);
var
  paint: ISkPaint;
  Font: ISkFont;
  Typeface: ISkTypeface;
  TextBounds: TRectF;
  TextX: Single;
begin
  paint := TSkPaint.Create;
  paint.Color := TAlphaColors.Black;
  paint.Style := TSkPaintStyle.Fill;
  Canvas.DrawRect(RectF(0, 0, Width, Height), paint);

  Typeface := TSkTypeface.MakeFromName(TITLE_FONT, TSkFontStyle.BoldItalic);
  Font := TSkFont.Create(Typeface, 52);
  Paint := TSkPaint.Create;
  Paint.Color := TITLE_COLOR;
  Paint.AntiAlias := True;

  Font.MeasureText(TITLE, TextBounds, Paint);
  TextX := (Width - TextBounds.Width) / 2;
  Canvas.DrawSimpleText(TITLE, TextX, Height * 0.22, Font, Paint);

end;

end.
