object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Turbomites'
  ClientHeight = 742
  ClientWidth = 1147
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Arena: TSkAnimatedPaintBox
    AlignWithMargins = True
    Left = 301
    Top = 4
    Width = 842
    Height = 734
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    OnAnimationDraw = ArenaAnimationDraw
  end
  object ToolPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 4
    Width = 289
    Height = 734
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alLeft
    BevelEdges = [beRight]
    BevelKind = bkFlat
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object Button1: TButton
      Left = 32
      Top = 32
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object MainTimer: TTimer
    Enabled = False
    Interval = 16
    OnTimer = OnTimerTick
    Left = 330
    Top = 16
  end
end
