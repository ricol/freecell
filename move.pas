unit move;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormMove = class(TForm)
    BtnMoveAll: TButton;
    BtnMoveSingle: TButton;
    BtnCancel: TButton;
    procedure BtnMoveAllClick(Sender: TObject);
    procedure BtnMoveSingleClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMove: TFormMove;
  GMoveAll, GCancel: boolean;

implementation

{$R *.dfm}

procedure TFormMove.BtnCancelClick(Sender: TObject);
begin
  GCancel := true;
  Self.Close;
end;

procedure TFormMove.BtnMoveAllClick(Sender: TObject);
begin
  GMoveAll := true;
  Self.Close;
end;

procedure TFormMove.BtnMoveSingleClick(Sender: TObject);
begin
  GMoveAll := false;
  Self.Close;
end;

procedure TFormMove.FormActivate(Sender: TObject);
begin
  GMoveAll := false;
  GCancel := false;
  BtnMoveAll.SetFocus;
end;

end.
