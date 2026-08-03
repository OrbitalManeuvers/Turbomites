object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Turbomites'
  ClientHeight = 659
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
    Height = 651
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
    Height = 651
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
    object PageControl: TPageControl
      Left = 0
      Top = 0
      Width = 287
      Height = 651
      ActivePage = tsRunScenario
      Align = alClient
      TabOrder = 0
      object tsLoadScenario: TTabSheet
        Caption = 'Load'
        TabVisible = False
        DesignSize = (
          279
          641)
        object Label2: TLabel
          Left = 0
          Top = 16
          Width = 114
          Height = 17
          Caption = 'Available scenarios:'
        end
        object ScenarioList: TControlList
          Left = 0
          Top = 39
          Width = 276
          Height = 555
          Anchors = [akLeft, akTop, akBottom]
          ItemMargins.Left = 0
          ItemMargins.Top = 0
          ItemMargins.Right = 0
          ItemMargins.Bottom = 0
          ParentColor = False
          TabOrder = 0
          OnBeforeDrawItem = ScenarioListBeforeDrawItem
          OnItemClick = ScenarioListItemClick
          OnItemDblClick = ScenarioListItemDblClick
          object lblScenarioTitle: TLabel
            AlignWithMargins = True
            Left = 8
            Top = 4
            Width = 260
            Height = 21
            Margins.Left = 8
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Align = alTop
            Caption = 'lblScenarioTitle'
            Color = clWhite
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -16
            Font.Name = 'Segoe UI Black'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            StyleElements = [seClient, seBorder]
            ExplicitWidth = 123
          end
          object lblScenarioDesc: TLabel
            AlignWithMargins = True
            Left = 8
            Top = 28
            Width = 260
            Height = 38
            Margins.Left = 8
            Margins.Top = 4
            Margins.Right = 4
            Margins.Bottom = 4
            Align = alBottom
            AutoSize = False
            Caption = 'lblScenarioDesc'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clGray
            Font.Height = -13
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
            WordWrap = True
            StyleElements = [seClient, seBorder]
            ExplicitLeft = 0
            ExplicitTop = 32
            ExplicitWidth = 246
          end
        end
        object btnLoad: TButton
          Left = 143
          Top = 603
          Width = 133
          Height = 33
          Anchors = [akLeft, akBottom]
          Caption = 'Load Scenario'
          TabOrder = 1
          OnClick = btnLoadClick
        end
      end
      object tsRunScenario: TTabSheet
        Caption = 'Run'
        ImageIndex = 1
        TabVisible = False
        object lblTotalSteps: TLabel
          Left = 160
          Top = 126
          Width = 97
          Height = 15
          AutoSize = False
          Caption = '0'
        end
        object Label1: TLabel
          Left = 112
          Top = 126
          Width = 35
          Height = 17
          Caption = 'Steps:'
        end
        object lblActiveScenario: TLabel
          Left = 8
          Top = 36
          Width = 98
          Height = 17
          Caption = 'lblActiveScenario'
        end
        object btnChangeScenario: TSpeedButton
          Left = 168
          Top = 4
          Width = 84
          Height = 25
          Caption = 'Change...'
          OnClick = btnChangeScenarioClick
        end
        object Bevel1: TBevel
          Left = 8
          Top = 95
          Width = 266
          Height = 13
          Shape = bsTopLine
        end
        object btnRunStop: TSpeedButton
          Left = 3
          Top = 116
          Width = 100
          Height = 34
          AllowAllUp = True
          GroupIndex = 1
          Caption = 'Run/Stop'
          OnClick = btnRunStopClick
        end
        object Label3: TLabel
          Left = 8
          Top = 168
          Width = 98
          Height = 17
          Caption = 'Simulator speed:'
        end
        object Bevel2: TBevel
          Left = 5
          Top = 244
          Width = 266
          Height = 13
          Shape = bsTopLine
        end
        object Label4: TLabel
          Left = 8
          Top = 8
          Width = 90
          Height = 17
          Caption = 'Active scenario:'
        end
        object tbSimSpeed: TTrackBar
          Left = 8
          Top = 192
          Width = 260
          Height = 45
          Min = 1
          Position = 1
          TabOrder = 0
          OnChange = tbSimSpeedChange
        end
        object CheckBox1: TCheckBox
          Left = 8
          Top = 66
          Width = 161
          Height = 17
          Caption = 'Restart on file change'
          TabOrder = 1
        end
      end
    end
  end
end
