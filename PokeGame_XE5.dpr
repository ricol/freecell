program PokeGame_XE5;

{$R *.dres}

uses
  Forms,
  main in 'main.pas' {FormMain},
  move in 'move.pas' {FormMove};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '�յ�������Ϸ';
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormMove, FormMove);
  Application.Run;

end.
