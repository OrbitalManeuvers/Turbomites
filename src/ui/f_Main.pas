unit f_Main;

interface

uses
  System.Types,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Skia, Vcl.Skia, Vcl.ExtCtrls,
  Vcl.StdCtrls,
  u_Simulator, u_SimTypes, u_Scenarios, u_SimThreads,
  u_RenderBuffers;

type
  TMainForm = class(TForm)
    Arena: TSkAnimatedPaintBox;
    ToolPanel: TPanel;
    Button1: TButton;
    ThreadImitation: TTimer;
    procedure ArenaAnimationDraw(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AProgress: Double; const AOpacity: Single);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ThreadImitationTimer(Sender: TObject);
  private
    Scenario: TScenario;
    SimThread: TSimThread;
    RenderBuffer: TRenderBuffer;
    procedure RenderStartupView(ACanvas: ISkCanvas; aWidth, aHeight: Integer);

    procedure UpdateStats;
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses System.UITypes, u_GridRenderer;

{ TMainForm }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  Arena.ControlStyle := Arena.ControlStyle + [csOpaque];
  SimThread := TSimThread.Create;

  // !! hard coded scenario selection for now
  Scenario := TScenario.Create;
  try
    Scenario.LoadFromFile('first.json');
  except
    Scenario.Free;
    raise;
  end;

end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SimThread.Free;
  Scenario.Free;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  SimThread.LoadScenario(Scenario);

// SimThread.Settings := settings

// ResetStats;

  SimThread.Active := True;

  ThreadImitation.Enabled := True;
end;

procedure TMainForm.ArenaAnimationDraw(ASender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AProgress: Double;
  const AOpacity: Single);
var
  paint: ISkPaint;
begin
  var size := Point(Round(ADest.Width), Round(ADest.Height));
  if SimThread.Active then
  begin

    SimThread.PullSnapshot(RenderBuffer);

    paint := TSkPaint.Create;
    paint.Color := TAlphaColors.Darkslategrey; // make letterbox slightly visible
    paint.Style := TSkPaintStyle.Fill;
    aCanvas.DrawRect(RectF(0, 0, size.X, size.Y), paint);

    // call renderer
    TGridRenderer.RenderFrame(ACanvas, size.X, size.Y, RenderBuffer);


    UpdateStats; // (dummy);
  end
  else
    RenderStartupView(ACanvas, size.X, size.Y);
end;

procedure TMainForm.RenderStartupView(ACanvas: ISkCanvas; aWidth: Integer; aHeight: Integer);
const
  S_CAPTION = 'Turbomites';
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
  aCanvas.DrawRect(RectF(0, 0, aWidth, aHeight), paint);

  Typeface := TSkTypeface.MakeFromName('Arial', TSkFontStyle.BoldItalic);
  Font := TSkFont.Create(Typeface, 52);
  Paint := TSkPaint.Create;
  Paint.Color := TAlphaColors.Darkviolet;
  Paint.AntiAlias := True;

  Font.MeasureText(S_CAPTION, TextBounds, Paint);
  TextX := (AWidth - TextBounds.Width) / 2;
  ACanvas.DrawSimpleText(S_CAPTION, TextX, AHeight * 0.22, Font, Paint);
end;

procedure TMainForm.ThreadImitationTimer(Sender: TObject);
begin
  SimThread.Step;
end;

procedure TMainForm.UpdateStats;
begin
//  if TickCounter mod 10 = 0 then
//    ToolFrame.TickCounter.Caption := TickCounter.ToString;
end;

end.
