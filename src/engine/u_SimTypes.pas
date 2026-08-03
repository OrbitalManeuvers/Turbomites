unit u_SimTypes;

interface

uses System.Classes, System.Generics.Collections, System.Types, System.UITypes;

const
  MAX_COLORS = 4;
  GRID_EXTENT = 255;

  COLOR_MAP: array[0 .. MAX_COLORS - 1] of TAlphaColor = (
    TAlphaColors.Black,
    TAlphaColors.White,
    TAlphaColors.Dodgerblue,
    TAlphaColors.Crimson);

  ANT_COLOR = TAlphaColors.Red;

type
  // inc = clockwise, dec = counter-clockwise
  TDirection = (diNorth, diEast, diSouth, diWest);

  // both relative and absolute
  TTurn = (ttNone, ttLeft, ttRight, ttAround, ttNorth, ttEast, ttSouth, ttWest);

  TPointArray = array of TPoint;

  TCellArray = record
    Grid: array[0..GRID_EXTENT, 0..GRID_EXTENT] of Byte;
  end;


implementation


end.
