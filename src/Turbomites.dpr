program Turbomites;

uses
  Vcl.Forms,
  f_Main in 'ui\f_Main.pas' {MainForm},
  u_Simulator in 'engine\u_Simulator.pas',
  u_SimTypes in 'engine\u_SimTypes.pas',
  u_GridRenderer in 'common\u_GridRenderer.pas',
  u_SimpleJSON in 'common\u_SimpleJSON.pas',
  Vcl.Themes,
  Vcl.Styles,
  u_Scenarios in 'engine\u_Scenarios.pas',
  u_States in 'engine\u_States.pas',
  u_StateMachines in 'engine\u_StateMachines.pas',
  u_Grids in 'engine\u_Grids.pas',
  u_SimThreads in 'engine\u_SimThreads.pas',
  u_RenderBuffers in 'common\u_RenderBuffers.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Turbomites';
  TStyleManager.TrySetStyle('Klondike');
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
