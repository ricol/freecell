object FormMove: TFormMove
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = #31227#21160#21040#31354#21015'...'
  ClientHeight = 128
  ClientWidth = 204
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object BtnMoveAll: TButton
    Left = 14
    Top = 16
    Width = 177
    Height = 25
    Caption = #31227#21160#25972#21015'(&C)'
    TabOrder = 0
    OnClick = BtnMoveAllClick
  end
  object BtnMoveSingle: TButton
    Left = 14
    Top = 47
    Width = 177
    Height = 25
    Caption = #31227#21160#21333#24352#29260'(&S)'
    TabOrder = 1
    OnClick = BtnMoveSingleClick
  end
  object BtnCancel: TButton
    Left = 57
    Top = 88
    Width = 75
    Height = 25
    Caption = #21462#28040
    TabOrder = 2
    OnClick = BtnCancelClick
  end
end
