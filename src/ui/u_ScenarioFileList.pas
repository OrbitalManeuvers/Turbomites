unit u_ScenarioFileList;

interface

uses System.Classes, System.Generics.Collections;

type
  TFileEntry = record
    FileName: string;
    Title: string;
    Description: string;
    TimeStamp: TDateTime;
  end;

  TScenarioFileList = class
  private
    fDirectory: string;
    fFiles: TList<TFileEntry>;
    fOnChange: TNotifyEvent;

    procedure Rebuild;
    function GetCount: Integer;
    function GetFile(I: Integer): TFileEntry;

  public
    constructor Create(const ADirectory: string);
    destructor Destroy; override;

    property Count: Integer read GetCount;
    property Files[I: Integer]: TFileEntry read GetFile;

    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

implementation

uses System.IOUtils, System.SysUtils,
  u_Scenarios;

{ TScenarioFileList }

constructor TScenarioFileList.Create(const ADirectory: string);
begin
  inherited Create;
  fDirectory := ADirectory;
  fFiles := TList<TFileEntry>.Create;
  Rebuild;
end;

destructor TScenarioFileList.Destroy;
begin
  fFiles.Free;
  inherited;
end;

function TScenarioFileList.GetCount: Integer;
begin
  Result := fFiles.Count;
end;

function TScenarioFileList.GetFile(I: Integer): TFileEntry;
begin
  Result := fFiles[I];
end;

procedure TScenarioFileList.Rebuild;
begin
  fFiles.Clear;

  var searchRec: TSearchRec;
  var result := FindFirst(TPath.Combine(fDirectory, '*.json'), faAnyFile, searchRec);
  try
    while result = 0 do
    begin
      var entry := Default(TFileEntry);
      entry.FileName := TPath.Combine(fDirectory, searchRec.Name);
      entry.TimeStamp := searchRec.TimeStamp;

      var info := TScenario.GetInfo(entry.FileName);
      entry.Title := info.Title;
      entry.Description := info.Description;

      fFiles.Add(entry);

      result := FindNext(searchRec);
    end;

  finally
    FindClose(searchRec);
  end;

end;

end.
