program PokeGame;

{$R *.dres}

uses
  Forms,
  UnitMain in 'UnitMain.pas' {FormMain},
  UnitMove in 'UnitMove.pas' {FormMove};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '�յ�������Ϸ';
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormMove, FormMove);
  Application.Run;
end.
