object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Turbomites'
  ClientHeight = 742
  ClientWidth = 1147
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 17
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
    object Label1: TLabel
      Left = 112
      Top = 24
      Width = 35
      Height = 17
      Caption = 'Steps:'
    end
    object lblTotalSteps: TLabel
      Left = 160
      Top = 24
      Width = 97
      Height = 15
      AutoSize = False
      Caption = '0'
    end
    object Button1: TButton
      Left = 16
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
    object tbSimSpeed: TTrackBar
      Left = 16
      Top = 80
      Width = 241
      Height = 45
      Min = 1
      Position = 1
      TabOrder = 1
      OnChange = tbSimSpeedChange
    end
  end
  object ThreadImitation: TTimer
    Enabled = False
    Interval = 100
    OnTimer = ThreadImitationTimer
    Left = 325
    Top = 36
  end
end
