unit f_Main;

interface

uses
  System.Types,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Skia, Vcl.Skia, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls, Vcl.ControlList,

  u_Simulator, u_SimTypes, u_Scenarios, u_SimThreads,
  u_RenderBuffers, u_ScenarioFileList;

type
  TMainForm = class(TForm)
    Arena: TSkAnimatedPaintBox;
    ToolPanel: TPanel;
    tbSimSpeed: TTrackBar;
    PageControl: TPageControl;
    tsLoadScenario: TTabSheet;
    tsRunScenario: TTabSheet;
    Label2: TLabel;
    ScenarioList: TControlList;
    lblScenarioTitle: TLabel;
    lblScenarioDesc: TLabel;
    btnLoad: TButton;
    lblActiveScenario: TLabel;
    btnChangeScenario: TSpeedButton;
    CheckBox1: TCheckBox;
    Bevel1: TBevel;
    btnRunStop: TSpeedButton;
    Label3: TLabel;
    Bevel2: TBevel;
    Label4: TLabel;
    StatDisplay: TSkAnimatedPaintBox;
    Label5: TLabel;
    btnStatsMode1: TSpeedButton;
    btnStatsMode2: TSpeedButton;
    procedure ArenaAnimationDraw(ASender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AProgress: Double; const AOpacity: Single);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tbSimSpeedChange(Sender: TObject);
    procedure ScenarioListBeforeDrawItem(AIndex: Integer; ACanvas: TCanvas;
      ARect: TRect; AState: TOwnerDrawState);
    procedure btnChangeScenarioClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure ScenarioListItemClick(Sender: TObject);
    procedure btnRunStopClick(Sender: TObject);
    procedure ScenarioListItemDblClick(Sender: TObject);
    procedure StatDisplayAnimationDraw(ASender: TObject;
      const ACanvas: ISkCanvas; const ADest: TRectF; const AProgress: Double;
      const AOpacity: Single);
  private type
    TActiveScenario = record
      FileName: string;
      TimeStamp: TDateTime;
      Scenario: TScenario;
    end;
  private
    SimThread: TSimThread;
    RenderBuffer: TRenderBuffer;
    FileList: TScenarioFileList;

    ActiveScenario: TActiveScenario;

    procedure ResetStats;
    procedure HandleScenarioListChange(Sender: TObject);
    procedure UpdateControls;
    procedure ChangeActiveScenario(const AScenarioIndex: Integer);
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses System.UITypes, System.IOUtils,
  u_GridRenderer, u_SplashPainter, u_Grids, u_StatsPainter;

{ TMainForm }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  Arena.ControlStyle := Arena.ControlStyle + [csOpaque];
  SimThread := TSimThread.Create;

  var binFolder := TPath.GetDirectoryName(Application.ExeName);
  FileList := TScenarioFileList.Create(binFolder);
  FileList.OnChange := HandleScenarioListChange;
  ScenarioList.ItemCount := FileList.Count;

  lblScenarioTitle.Font.Color := clWhite;
  lblScenarioDesc.Font.Color := $00CCB0B0;
  lblActiveScenario.Font := lblScenarioTitle.Font;

  ActiveScenario := Default(TActiveScenario);

  PageControl.ActivePage := tsLoadScenario;
  UpdateControls;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SimThread.Free;
  ActiveScenario.Scenario.Free;
  FileList.Free;
end;

procedure TMainForm.HandleScenarioListChange(Sender: TObject);
begin
  // - if we have one loaded see if it changed
  ScenarioList.ItemCount := FileList.Count;  // not pertinent here, move to page selected
end;

procedure TMainForm.ResetStats;
begin
  RenderBuffer.Stats := Default(TSessionStats);
end;

procedure TMainForm.btnChangeScenarioClick(Sender: TObject);
begin
  SimThread.EndScenario;
  ActiveScenario.Scenario.Free;
  ActiveScenario := Default(TActiveScenario);
  RenderBuffer.Cells.Clear;
  PageControl.ActivePage := tsLoadScenario;

  UpdateControls;
end;

procedure TMainForm.btnLoadClick(Sender: TObject);
begin
  var scenarioIndex := ScenarioList.ItemIndex;
  ChangeActiveScenario(scenarioIndex);
end;

procedure TMainForm.btnRunStopClick(Sender: TObject);
begin
  SimThread.Active := btnRunStop.Down;
  UpdateControls;
end;

procedure TMainForm.ChangeActiveScenario(const AScenarioIndex: Integer);
begin
  ActiveScenario.FileName := FileList.Files[AScenarioIndex].FileName;
  ActiveScenario.TimeStamp := FileList.Files[AScenarioIndex].TimeStamp;
  ActiveScenario.Scenario := TScenario.Create;
  ActiveScenario.Scenario.LoadFromFile(ActiveScenario.FileName);
  lblActiveScenario.Caption := FileList.Files[AScenarioIndex].Title;

  SimThread.LoadScenario(ActiveScenario.Scenario);
  SimThread.Speed := 1;
  tbSimSpeed.Position := SimThread.Speed;

  ResetStats;

  PageControl.ActivePage := tsRunScenario;
  UpdateControls;

end;

procedure TMainForm.ArenaAnimationDraw(ASender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AProgress: Double;
  const AOpacity: Single);
var
  paint: ISkPaint;
begin
  var size := Point(Round(ADest.Width), Round(ADest.Height));
  if Assigned(ActiveScenario.Scenario) then
  begin

    SimThread.PullSnapshot(RenderBuffer);

    paint := TSkPaint.Create;
    paint.Color := TAlphaColors.Darkslategrey; // make letterbox slightly visible
    paint.Style := TSkPaintStyle.Fill;
    aCanvas.DrawRect(RectF(0, 0, size.X, size.Y), paint);

    // call renderer
    TGridRenderer.RenderFrame(ACanvas, size.X, size.Y, RenderBuffer);
  end
  else
    TSplashPainter.RenderSplash(ACanvas, size.X, size.Y);
end;

procedure TMainForm.ScenarioListBeforeDrawItem(AIndex: Integer;
  ACanvas: TCanvas; ARect: TRect; AState: TOwnerDrawState);
begin
  if (AIndex >= 0) and (AIndex < FileList.Count) then
  begin
    lblScenarioTitle.Caption := FileList.Files[AIndex].Title;
    lblScenarioDesc.Caption := FileList.Files[AIndex].Description;
  end;
end;

procedure TMainForm.ScenarioListItemClick(Sender: TObject);
begin
  UpdateControls;
end;

procedure TMainForm.ScenarioListItemDblClick(Sender: TObject);
begin
  if ScenarioList.ItemIndex <> -1 then
    btnLoadClick(nil);
end;

procedure TMainForm.StatDisplayAnimationDraw(ASender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AProgress: Double;
  const AOpacity: Single);
begin
  var size := Point(Round(ADest.Width), Round(ADest.Height));
  var mode := TStatsDisplayMode.sdPercentBars;
  if btnStatsMode2.Down then
    mode := TStatsDisplayMode.sdWrittenVsErased;
  TStatsPainter.RenderStats(ACanvas, size.X, size.Y, RenderBuffer.Stats, mode);
end;

procedure TMainForm.tbSimSpeedChange(Sender: TObject);
begin
  SimThread.Speed := tbSimSpeed.Position;
end;

procedure TMainForm.UpdateControls;
begin
  if PageControl.ActivePage = tsLoadScenario then
  begin
    btnLoad.Enabled := ScenarioList.ItemIndex <> -1;

  end
  else if PageControl.ActivePage = tsRunScenario then
  begin
    btnChangeScenario.Enabled := not SimThread.Active;
    if btnRunStop.Down then
      btnRunStop.Caption := 'Running'
    else
      btnRunStop.Caption := 'Stopped';
  end;
end;

end.
