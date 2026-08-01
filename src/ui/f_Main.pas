unit f_Main;

interface

uses
  System.Types,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Skia, Vcl.Skia, Vcl.ExtCtrls,
  Vcl.StdCtrls,
  u_Simulator, u_SimTypes, u_Scenarios;

type
  TMainForm = class(TForm)
    Arena: TSkAnimatedPaintBox;
    MainTimer: TTimer;
    ToolPanel: TPanel;
    Button1: TButton;
    procedure ArenaAnimationDraw(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AProgress: Double; const AOpacity: Single);
    procedure OnTimerTick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    Sim: TSimulator;
    Scenario: TScenario;
    TickCounter: Integer;
    procedure RenderStartupView(ACanvas: ISkCanvas; aWidth, aHeight: Integer);

    procedure UpdateStats;
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses System.UITypes;

{ TMainForm }
procedure TMainForm.Button1Click(Sender: TObject);
begin
  Sim.BeginSession(Scenario);
  MainTimer.Enabled := True;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Arena.ControlStyle := Arena.ControlStyle + [csOpaque];
  Sim := TSimulator.Create;

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
  Sim.Free;
end;

procedure TMainForm.ArenaAnimationDraw(ASender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AProgress: Double;
  const AOpacity: Single);
begin
  // forward to simulator
  if MainTimer.Enabled then
    Sim.Render(ACanvas, Round(ADest.Width), Round(ADest.Height))
  else
    RenderStartupView(ACanvas, Round(ADest.Width), Round(ADest.Height));
end;

procedure TMainForm.OnTimerTick(Sender: TObject);
begin
  // step simulator
  if MainTimer.Enabled then
  begin

    // loop here for 1x, 2x, 4x
    for var i := 1 to 100 do
    begin
      Inc(TickCounter);
      Sim.Step;
    end;
  end;

  UpdateStats;

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

procedure TMainForm.UpdateStats;
begin
//  if TickCounter mod 10 = 0 then
//    ToolFrame.TickCounter.Caption := TickCounter.ToString;
end;

end.
