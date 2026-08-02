unit u_RenderBuffers;

interface

uses System.Types,
  u_SimTypes;

type
  TAntRenderInfo = record
    Loc: TPoint;
    Facing: TDirection;
  end;
  TAntRenderArray = array of TAntRenderInfo;

  TColorStats = array[0 .. MAX_COLORS - 1] of Cardinal;

  TSessionStats = record
    Written: TColorStats;
    Erased: TColorStats;
  end;

  TRenderBuffer = record
    Cells: TCellArray;
    Ants: TAntRenderArray;
    Stats: TSessionStats;
  end;

implementation

end.
