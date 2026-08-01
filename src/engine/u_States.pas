unit u_States;

interface

uses System.Generics.Collections,
  u_SimTypes;

type
  TState = class;

  TRule = record
    Find: Integer;      // -1 = wildcard, 0.. MaxColors - 1
    Write: Integer;
    Turn: TTurn;
    State: string;
  end;

  // TState
  TState = class
  private
    fName: string;
    fRules: array[0 .. MAX_COLORS - 1] of TRule;
    fDefaultRule: TRule;
  public
    constructor Create(const aName: string);
    destructor Destroy; override;

    procedure AddRule(const aRule: TRule);

    property Name: string read fName;
    function GetRule(aColor: Integer): TRule;
  end;

  // TStateList - list of all states in a single state file.
  // each ant operates within one state list
  TStateList = class
  private
    fStates: TDictionary<string, TState>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddState(aState: TState);

    function FindState(const aStateName: string): TState;
  end;


implementation

{ TState }

constructor TState.Create(const aName: string);
begin
  inherited Create;
  fName := aName;
  for var i := 0 to MAX_COLORS - 1 do
  begin
    fRules[i] := Default(TRule);
    fRules[i].Find := -1;
  end;
end;

destructor TState.Destroy;
begin

  inherited;
end;

procedure TState.AddRule(const aRule: TRule);
begin
  if aRule.Find = -1 then
    fDefaultRule := aRule
  else
    fRules[aRule.Find] := aRule;
end;

function TState.GetRule(aColor: Integer): TRule;
begin
  if fRules[aColor].Find = aColor then
    Result := fRules[aColor]
  else
    Result := fDefaultRule;
end;

{ TStateList }

constructor TStateList.Create;
begin
  inherited Create;
  fStates := TDictionary<string, TState>.Create;
end;

destructor TStateList.Destroy;
begin
  for var state in fStates.Values do
    state.Free;
  fStates.Free;
  inherited;
end;

procedure TStateList.AddState(aState: TState);
begin
  fStates.Add(aState.Name, aState);
end;

function TStateList.FindState(const aStateName: string): TState;
begin
  if not fStates.TryGetValue(aStateName, Result) then
    Result := nil;
end;

end.
