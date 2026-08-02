unit u_Scenarios;

interface

uses System.Types,
  u_SimTypes, u_States;

type
  TStartDot = record
    Color: Byte;
    Loc: TPoint;
  end;

  TStartAnt = record
    Loc: TPoint;
    Facing: TDirection;
    StateName: string;
  end;

  TScenarioInfo = record
    Title: string;
    Description: string;
  end;

  TScenario = class
  private
    fTitle: string;
    fDescription: string;
    fDots: TArray<TStartDot>;
    fDotCount: Integer;
    fAnts: TArray<TStartAnt>;
    fAntCount: Integer;
    fStates: TStateList;
    function GetDot(I: Integer): TStartDot;
    function GetAnt(I: Integer): TStartAnt;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const aFileName: string);

    class function GetInfo(const AFileName: string): TScenarioInfo;

    property Title: string read fTitle;
    property Description: string read fDescription;

    property DotCount: Integer read fDotCount;
    property Dots[I: Integer]: TStartDot read GetDot;

    property AntCount: Integer read fAntCount;
    property Ants[I: Integer]: TStartAnt read GetAnt;

    property States: TStateList read fStates;
  end;

implementation

uses System.JSON, System.Generics.Collections, System.SysUtils, System.IOUtils,
  u_SimpleJSON;

const
  TURN_CODES: array[TTurn] of Char = ('?', 'L', 'R', 'A', 'N', 'S', 'E', 'W');
  FACING_CODES: array[TDirection] of Char = ('N', 'E', 'S', 'W');

  KEY_TITLE = 'title';
  KEY_DESCRIPTION = 'description';
  KEY_STATES = 'states';
  KEY_ANTS = 'ants';
  KEY_DOTS = 'dots';
  KEY_NAME = 'name';
  KEY_RULES = 'rules';

  KEY_FIND = 'find';
  KEY_WRITE = 'write';
  KEY_TURN = 'turn';
  KEY_STATE = 'state';

  KEY_X = 'x';
  KEY_Y = 'y';
  KEY_FACING = 'facing';
  KEY_COLOR = 'color';


type
  TStateHelper = class helper for TState
  private
    procedure SetJSON(const Value: TJSONObject);
  end;

  TRuleHelper = record helper for TRule
  private
    procedure SetJSON(const Value: TJSONObject);
  end;

  TTurnHelper = record helper for TTurn
  private
    procedure SetText(const Value: string);
  end;

  TAntHelper = record helper for TStartAnt
  private
    procedure SetJSON(const Value: TJSONObject);
  end;

  TDirectionHelper = record helper for TDirection
    procedure SetText(const Value: string);
  end;

  TDotHelper = record helper for TStartDot
  private
    procedure SetJSON(const Value: TJSONObject);
  end;


{ TDirectionHelper }
procedure TDirectionHelper.SetText(const Value: string);
begin
  Self := diNorth;
  for var check := Low(TDirection) to High(TDirection) do
    if Value = FACING_CODES[check] then
    begin
      Self := check;
      Break;
    end;
end;

{ TTurnHelper }
procedure TTurnHelper.SetText(const Value: string);
begin
  Self := ttNone;
  for var check := Low(TTurn) to High(TTurn) do
    if Value = TURN_CODES[check] then
    begin
      Self := check;
      Break;
    end;
end;


{ TRuleHelper }

procedure TRuleHelper.SetJSON(const Value: TJSONObject);
begin
  Find := Value.IntValue(KEY_FIND);
  Write := Value.IntValue(KEY_WRITE);
  Turn.SetText(Value.StrValue(KEY_TURN));
  State := Value.StrValue(KEY_STATE);
end;

{ TStateHelper }
procedure TStateHelper.SetJSON(const Value: TJSONObject);
begin
  var arrRules: TJSONArray;
  if Value.TryGetValue(KEY_RULES, arrRules) then
  begin
    for var ruleIndex := 0 to arrRules.Count - 1 do
    begin
      var rule := Default(TRule);
      rule.SetJSON(arrRules[ruleIndex] as TJSONObject);
      AddRule(rule);
    end;
  end;
end;

{ TAntHelper }

procedure TAntHelper.SetJSON(const Value: TJSONObject);
begin
  Loc.X := Value.IntValue(KEY_X);
  Loc.Y := Value.IntValue(KEY_Y);
  Facing.SetText(Value.StrValue(KEY_FACING));
  StateName := Value.StrValue(KEY_STATE);
end;

{ TDotHelper }

procedure TDotHelper.SetJSON(const Value: TJSONObject);
begin
  Loc.X := Value.IntValue(KEY_X);
  Loc.Y := Value.IntValue(KEY_Y);
  Color := Value.IntValue(KEY_COLOR);
end;


{ TScenario }

constructor TScenario.Create;
begin
  inherited Create;
  fStates := TStateList.Create;
  SetLength(fDots, 0);
  SetLength(fAnts, 0);
end;

destructor TScenario.Destroy;
begin
  fStates.Free;
  inherited;
end;

function TScenario.GetAnt(I: Integer): TStartAnt;
begin
  Result := fAnts[I];
end;

function TScenario.GetDot(I: Integer): TStartDot;
begin
  Result := fDots[I];
end;

class function TScenario.GetInfo(const AFileName: string): TScenarioInfo;
var
  JSON: TJSONObject;
begin
  Result := Default(TScenarioInfo);
  if TFile.Exists(AFileName) then
  begin
    JSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(AFileName)) as TJSONObject;
    Result.Description := JSON.StrValue(KEY_DESCRIPTION);
    Result.Title := JSON.StrValue(KEY_TITLE);
  end;
end;

procedure TScenario.LoadFromFile(const aFileName: string);
var
  JSON: TJSONObject;
begin
  if not TFile.Exists(aFileName) then
    Exit;

  JSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(aFileName)) as TJSONObject;
  try
    fTitle := JSON.StrValue(KEY_TITLE);
    fDescription := JSON.StrValue(KEY_DESCRIPTION);

    // load states
    var arrStates: TJSONArray;
    if JSON.TryGetValue(KEY_STATES, arrStates) then
    begin
      for var arrIndex := 0 to arrStates.Count - 1 do
      begin
        var objState: TJSONObject := arrStates[arrIndex] as TJSONObject;
        var stateName := objState.StrValue(KEY_NAME).Trim;

        if stateName.Length > 0 then
        begin
          var state := TState.Create(stateName);
          state.SetJSON(objState);
          fStates.AddState(state);
        end;

      end;
    end;

    // load ants
    var arrAnts: TJSONArray;
    if JSON.TryGetValue(KEY_ANTS, arrAnts) then
    begin
      SetLength(fAnts, arrAnts.Count);

      for var i := 0 to arrAnts.Count - 1 do
      begin
        var objAnt := arrAnts[i] as TJSONObject;
        var ant := Default(TStartAnt);
        ant.SetJson(objAnt);
        fAnts[i] := ant;
      end;
    end;

    // load dots
    var arrDots: TJSONArray;
    if JSON.TryGetValue(KEY_DOTS, arrDots) then
    begin
      SetLength(fDots, arrDots.Count);

      for var i := 0 to arrDots.Count - 1 do
      begin
        var objDot := arrDots[i] as TJSONObject;
        var dot := Default(TStartDot);
        dot.SetJSON(objDot);
        fDots[i] := dot;
      end;
    end;

  finally
    JSON.Free;
  end;

  fAntCount := Length(fAnts);
  fDotCount := Length(fDots);
end;



end.
