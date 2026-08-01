unit u_StateMachines;

interface

uses u_SimTypes, u_States;

type
  { TStateMachine }
  TStateMachine = class
  private
    fStates: TStateList;
    fCurrentState: TState;
    fCurrentRule: TRule;
    procedure SetCurrentState(const Value: TState);
  public
    constructor Create(const aStateList: TStateList);
    procedure SelectState(const aName: string);

    property CurrentState: TState read fCurrentState write SetCurrentState;
    property CurrentRule: TRule read fCurrentRule;
  end;

implementation

{ TStateMachine }

constructor TStateMachine.Create(const aStateList: TStateList);
begin
  inherited Create;
  fStates := aStateList;

  fCurrentState := nil;
  fCurrentRule := Default(TRule);

end;

procedure TStateMachine.SelectState(const aName: string);
begin
  var s := fStates.FindState(aName);
  fCurrentState := s;
end;

procedure TStateMachine.SetCurrentState(const Value: TState);
begin
  fCurrentState := Value;
end;


end.
