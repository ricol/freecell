unit main;

{
  CONTACT: WANGXINGHE1983@GMAIL.COM
}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, MMSystem;

type
  TDIRECTION = (TORIGHT, TOLEFT);

  TPoke = record
    x, y: integer;
  end;

  TArray = array [1 .. 100] of TPoke;

  TPokerArray = array [1 .. 8] of TArray;

  TPosType = (TYPEARRAY, TYPETEMP, TYPECONTAINER);

  TFormMain = class(TForm)
    MainMenu1: TMainMenu;
    MenuGame: TMenuItem;
    MenuGameStart: TMenuItem;
    MenuGameSelect: TMenuItem;
    MenuGameReplay: TMenuItem;
    MenuGameS1: TMenuItem;
    MenuGameStatus: TMenuItem;
    MenuGameOption: TMenuItem;
    MenuGameS2: TMenuItem;
    MenuGameUndo: TMenuItem;
    MenuGameS3: TMenuItem;
    MenuGameExit: TMenuItem;
    MenuHelp: TMenuItem;
    MenuHelpDirectory: TMenuItem;
    MenuHelpS1: TMenuItem;
    MenuHelpAbout: TMenuItem;
    MenuGameStop: TMenuItem;
    PaintBoxMain: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuGameStartClick(Sender: TObject);
    procedure MenuGameStopClick(Sender: TObject);
    procedure MenuHelpAboutClick(Sender: TObject);
    procedure MenuGameExitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PaintBoxMainPaint(Sender: TObject);
    procedure PaintBoxMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; x, y: integer);
    procedure PaintBoxMainMouseMove(Sender: TObject; Shift: TShiftState; x, y: integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MenuGameReplayClick(Sender: TObject);
  private
    procedure UpDateKing(tmp: TDIRECTION);
    function GetPokeNumber(var num: integer; var data: array of string; var index: integer): TPoke;
    procedure DrawPoke(x, y: integer; poke: TPoke);
    function NotInArraY(x, y: integer; var data: array of string; var index: integer): boolean;
    procedure SetUnChoosed(tmp: integer);
    procedure SetChoosed(tmp: integer);
    procedure MovePokeFromArrayToTemp(col, num: integer);
    procedure MovePokeFromArrayToArray(colFrom, colTo: integer);
    procedure MovePokeFromTempToArray(num, col: integer);
    procedure MovePokeFromTempToContainer(num, container: integer);
    procedure MovePokeFromTempToTemp(numFrom, numTo: integer);
    procedure MovePokeFromArrayToContainer(col, container: integer);
    procedure AutoMovePokeFromArrayToContainer(col: integer);
    function PokeCanMove(pokeDown, pokeUp: TPoke): boolean;
    function IndicatePokeCanMove(numFrom, numTo: integer; typeFrom, typeTO: TPosType): boolean;
    function CanPutToContainer(poke: TPoke; container: integer): boolean;
    function CanDelete(poke: TPoke): boolean;
    function HavePoke(poke: TPoke): boolean;
    function GetContainerNumber(poke: TPoke): integer;
    function GetCanMovePokeNumber(_from, _to: integer): integer;
    function GetBlankSpace(): integer;
    function GetBlankSpace_New(col: integer): integer;
    function Another(poke: TPoke): boolean;
    function GetTargetPokeNumber(x, y: integer; var posType: TPosType): integer;
    function GetCanMovePokeNumber_New(col: integer): integer;
    procedure CheckAllPokeCanDelete();
    procedure DrawTempArea();
    procedure DrawTempAreaNumber(num: integer);
    procedure DrawContainerArea();
    procedure DrawArrayArea();
    procedure DrawArrayNumber(col: integer);
    procedure DrawContainerNumber(num: integer);
    procedure CheckGame(tmp: integer);
    procedure restart(flag: boolean; data: TPokerArray);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses Move;

{$R *.dfm}

const
  ARRAY_STARTX = 10;
  ARRAY_STARTY = 100;
  ARRAY_MULX = 81;
  ARRAY_MULY = 18;
  TEMP_STARTX = 0;
  TEMP_STARTY = 0;
  TEMP_MULX = 71;
  TEMP_MULY = 0;
  POKE_WIDTH = 71;
  POKE_HEIGHT = 96;
  RESOURCEBITMAP = '%d_%d';
  RESOURCEKINGRIGHT = 'KingRight';
  RESOURCEKINGLEFT = 'KingLeft';
  RESOURCEBACKGROUNDBITMAP = '0_0';
  RESOURCECAPTION = '空当接龙 - ';

var
  GRect: TRect;
  GKingDirection: TDIRECTION = TORIGHT;
  GArray, GBackupArray: TPokerArray;
  GTempArray: TArray;
  GTempArrayIndex: integer;
  GArrayIndex: array [1 .. 8] of integer = (
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  );
  GTemp: array [1 .. 4] of TPoke;
  GContainer: array [1 .. 4] of TPoke;
  GStringArray: array [1 .. 53] of string;
  GStringIndex: integer;
  GRunning, GHaveClicked: boolean;
  GChoosed, GTotalPoke, GFlag: integer;
  GChoosedType: TPosType;
  GBitmap: TBitmap;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if GRunning then
  begin
    if MessageBox(Self.Handle, '游戏正在进行，继续退出吗？', '提示', MB_OKCANCEL) <> ID_OK then
      Action := caNone;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  GRect.Left := Self.ClientWidth div 2 - 17;
  GRect.Top := 20;
  GRect.Right := Self.ClientWidth div 2 + 17;
  GRect.Bottom := 20 + 34;
  GKingDirection := TORIGHT;
  GRunning := False;
  GHaveClicked := False;
  GChoosed := 0;
  GFlag := 0;
  GChoosedType := TYPETEMP;
  GBitmap := TBitmap.Create;
  randomize;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  GBitmap.Free;
end;

procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    MenuGameStopClick(Sender);
end;

procedure TFormMain.UpDateKing(tmp: TDIRECTION);
begin
  if tmp = TORIGHT then
    GBitmap.LoadFromResourceName(hInstance, RESOURCEKINGRIGHT)
  else
    GBitmap.LoadFromResourceName(hInstance, RESOURCEKINGLEFT);
  with PaintBoxMain.Canvas do
  begin
    StretchDraw(GRect, GBitmap);
    Pen.Color := RGB(0, 255, 0);
    MoveTo(GRect.Left - 1, GRect.Top - 1);
    LineTo(GRect.Right + 1, GRect.Top - 1);
    MoveTo(GRect.Left - 1, GRect.Top - 1);
    LineTo(GRect.Left - 1, GRect.Bottom + 1);
    Pen.Color := RGB(0, 0, 0);
    MoveTo(GRect.Right + 1, GRect.Bottom + 1);
    LineTo(GRect.Left - 1, GRect.Bottom + 1);
    MoveTo(GRect.Right + 1, GRect.Bottom + 1);
    LineTo(GRect.Right + 1, GRect.Top - 1);
  end;
end;

procedure TFormMain.MenuGameExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.MenuGameReplayClick(Sender: TObject);
begin
  Self.restart(true, GBackupArray);
end;

procedure TFormMain.MenuGameStartClick(Sender: TObject);
begin
  Self.restart(False, GBackupArray);
end;

procedure TFormMain.MenuGameStopClick(Sender: TObject);
begin
  GRunning := False;
  PaintBoxMain.OnPaint(Sender);
end;

procedure TFormMain.MenuHelpAboutClick(Sender: TObject);
begin
  MessageBox(Self.Handle, PChar('游戏名称：空当接龙' + sLineBreak + '开发者：RICOL' + sLineBreak + '联系：WANGXINGHE1983@GMAIL.COM'), '关于', MB_OK);
end;

procedure TFormMain.MovePokeFromArrayToArray(colFrom, colTo: integer);
begin
  inc(GArrayIndex[colTo]);
  GArray[colTo][GArrayIndex[colTo]] := GArray[colFrom][GArrayIndex[colFrom]];
  GArray[colFrom][GArrayIndex[colFrom]].x := 0;
  GArray[colFrom][GArrayIndex[colFrom]].y := 0;
  dec(GArrayIndex[colFrom]);
  DrawArrayNumber(colFrom);
  DrawArrayNumber(colTo);
  CheckAllPokeCanDelete();
end;

procedure TFormMain.MovePokeFromArrayToContainer(col, container: integer);
var
  num: integer;
begin
  num := GetContainerNumber(GArray[col][GArrayIndex[col]]);
  GContainer[num] := GArray[col][GArrayIndex[col]];
  GArray[col][GArrayIndex[col]].x := 0;
  GArray[col][GArrayIndex[col]].y := 0;
  dec(GArrayIndex[col]);
  DrawArrayNumber(col);
  DrawContainerNumber(num);
  dec(GTotalPoke);
  CheckGame(GTotalPoke);
end;

procedure TFormMain.MovePokeFromArrayToTemp(col, num: integer);
begin
  GTemp[num].x := GArray[col][GArrayIndex[col]].x;
  GTemp[num].y := GArray[col][GArrayIndex[col]].y;
  GArray[col][GArrayIndex[col]].x := 0;
  GArray[col][GArrayIndex[col]].y := 0;
  dec(GArrayIndex[col]);
  DrawArrayNumber(col);
  DrawTempAreaNumber(num);
  CheckAllPokeCanDelete();
end;

procedure TFormMain.MovePokeFromTempToArray(num, col: integer);
begin
  inc(GArrayIndex[col]);
  GArray[col][GArrayIndex[col]] := GTemp[num];
  GTemp[num].x := 0;
  GTemp[num].y := 0;
  DrawTempAreaNumber(num);
  DrawArrayNumber(col);
end;

procedure TFormMain.MovePokeFromTempToContainer(num, container: integer);
var
  number: integer;
begin
  number := GetContainerNumber(GTemp[num]);
  GContainer[number] := GTemp[num];
  GTemp[num].x := 0;
  GTemp[num].y := 0;
  DrawTempAreaNumber(num);
  DrawContainerNumber(number);
  dec(GTotalPoke);
  CheckGame(GTotalPoke);
end;

procedure TFormMain.MovePokeFromTempToTemp(numFrom, numTo: integer);
begin
  GTemp[numTo] := GTemp[numFrom];
  GTemp[numFrom].x := 0;
  GTemp[numFrom].y := 0;
  DrawTempAreaNumber(numFrom);
  DrawTempAreaNumber(numTo);
end;

function TFormMain.NotInArraY(x, y: integer; var data: array of string; var index: integer): boolean;
var
  i: integer;
begin
  result := true;
  for i := Low(data) to index - 1 do
  begin
    if format('%d_%d', [x, y]) = data[i] then
    begin
      result := False;
      exit;
    end;
  end;
  data[index] := format('%d_%d', [x, y]);
  inc(index);
end;

procedure TFormMain.PaintBoxMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; x, y: integer);
var
  i, num, col, container, pokeNum, space: integer;
  pokeOne, pokeTwo: TPoke;
begin
  if not GRunning then
    exit;
  num := 0;
  col := 0;
  container := 0;
  PaintBoxMain.Cursor := crDefault;
  Application.ProcessMessages;
  if (y >= ARRAY_MULY + ARRAY_STARTY) then // 点击的是Array区域
  begin
    for i := 1 to 8 do
      if x >= (8 - i) * ARRAY_MULX + ARRAY_STARTX then
      begin
        col := 9 - i;
        break;
      end;
    if col = 0 then
      exit;
    if GChoosed = 0 then
    begin
      if GArrayIndex[col] > 0 then
      begin
        GChoosed := col;
        GChoosedType := TYPEARRAY;
        SetChoosed(col);
        exit;
      end
      else
        exit;
    end
    else
    begin
      if GChoosedType = TYPEARRAY then // 之前点击的是Array区域
      begin
        if GChoosed = col then // 两次点击的是相同的Array区域
        begin
          SetUnChoosed(col);
          GChoosed := 0;
          exit;
        end
        else
        begin // 两次点击的是不同的Array区域
          if GArrayIndex[col] <= 0 then // 这次点击的Array没有Poke
          begin
            pokeNum := GetCanMovePokeNumber_New(GChoosed);
            if pokeNum = 1 then
            begin
              MovePokeFromArrayToArray(GChoosed, col);
              GChoosed := 0;
              exit;
            end;
            FormMove.Left := Self.Left + (Self.Width div 2) - FormMove.Width div 2;
            FormMove.Top := Self.Top + (Self.Height div 2) - FormMove.Height div 2;
            FormMove.ShowModal;
            if GCancel then
            begin
              SetUnChoosed(GChoosed);
              GChoosed := 0;
              exit;
            end;
            if GMoveAll then
            begin
              space := GetBlankSpace_New(col);
              if pokeNum > space then
                pokeNum := space;
              GTempArrayIndex := 0;
              for i := GArrayIndex[GChoosed] downto GArrayIndex[GChoosed] - pokeNum + 1 do
              begin
                if i <= 0 then
                  break;
                inc(GTempArrayIndex);
                GTempArray[GTempArrayIndex] := GArray[GChoosed][i];
                GArray[GChoosed][i].x := 0;
                GArray[GChoosed][i].y := 0;
                dec(GArrayIndex[GChoosed]);
              end;
              for i := GTempArrayIndex downto 1 do
              begin
                inc(GArrayIndex[col]);
                GArray[col][GArrayIndex[col]] := GTempArray[i];
              end;
              DrawArrayNumber(GChoosed);
              DrawArrayNumber(col);
              CheckAllPokeCanDelete();
              GChoosed := 0;
              exit;
            end
            else
            begin
              MovePokeFromArrayToArray(GChoosed, col);
            end;
            GChoosed := 0;
            exit;
          end;
          // 这次点击的Array有Poke
          // 首先判断可以移动的Poke数目 从GChoosed -> tmpCol
          pokeNum := GetCanMovePokeNumber(GChoosed, col);
          space := GetBlankSpace();
          if space < pokeNum then
          begin
            MessageBox(Self.Handle, PChar(format('要求移动 %d 张牌。但所剩空间只能够移动 %d 张牌。', [pokeNum, space])), '信息', MB_OK or MB_ICONINFORMATION);
            SetUnChoosed(GChoosed);
            GChoosed := 0;
            exit;
          end
          else
          begin
            // 开始移动整堆的扑克
            GTempArrayIndex := 0;
            for i := GArrayIndex[GChoosed] downto GArrayIndex[GChoosed] - pokeNum + 1 do
            begin
              if i <= 0 then
                break;
              inc(GTempArrayIndex);
              GTempArray[GTempArrayIndex] := GArray[GChoosed][i];
              GArray[GChoosed][i].x := 0;
              GArray[GChoosed][i].y := 0;
              dec(GArrayIndex[GChoosed]);
            end;
            for i := GTempArrayIndex downto 1 do
            begin
              inc(GArrayIndex[col]);
              GArray[col][GArrayIndex[col]] := GTempArray[i];
            end;
            DrawArrayNumber(GChoosed);
            DrawArrayNumber(col);
            CheckAllPokeCanDelete();
            GChoosed := 0;
            exit;
          end;
        end;
      end
      else if GChoosedType = TYPETEMP then // 之前点击的是Temp区域
      begin
        if GTemp[GChoosed].x <> 0 then // 之前点击的Temp区域不为空
        begin
          if GArrayIndex[col] <= 0 then // 这次点击的Array没有Poke
          begin
            MovePokeFromTempToArray(GChoosed, col);
            GChoosed := 0;
            exit;
          end;
          pokeOne := GTemp[GChoosed];
          pokeTwo := GArray[col][GArrayIndex[col]];
          if PokeCanMove(pokeOne, pokeTwo) then
          begin
            MovePokeFromTempToArray(GChoosed, col);
            GChoosed := 0;
            exit;
          end
          else
          begin
            Beep();
            SetUnChoosed(GChoosed);
            GChoosed := 0;
            exit;
          end;
        end
        else
        begin // 之前点击的Temp区域为空则出现异常错误
          ShowMessage(IntToStr(GChoosed));
          MessageBox(Self.Handle, '出现未知错误，游戏将关闭！', '系统信息', MB_OK or MB_ICONERROR);
          Application.Terminate;
        end;
      end
      else if GChoosedType = TYPECONTAINER then
      begin
        MessageBox(Self.Handle, '出现未知错误，游戏将关闭！', '系统信息', MB_OK or MB_ICONERROR);
        Application.Terminate;
      end
      else
      begin
        MessageBox(Self.Handle, '出现未知错误，游戏将关闭！', '系统信息', MB_OK or MB_ICONERROR);
        Application.Terminate;
      end;
    end;
  end
  else if (y <= POKE_HEIGHT) and (x <= 4 * TEMP_MULX) then // 点击的是Temp区域
  begin
    for i := 1 to 4 do
      if x >= (4 - i) * POKE_WIDTH then
      begin
        num := 5 - i;
        break;
      end;
    if num = 0 then
      exit;
    if GChoosed = 0 then
    begin
      if GTemp[num].x <> 0 then
      begin
        GChoosed := num;
        GChoosedType := TYPETEMP;
        SetChoosed(num);
        exit;
      end
      else
        exit;
    end
    else if GChoosedType = TYPETEMP then // 之前点击的也是Temp区域
    begin
      if GChoosed <> num then // 是不同的Temp区域
      begin
        if GTemp[num].x = 0 then
        begin
          MovePokeFromTempToTemp(GChoosed, num);
          GChoosed := 0;
          exit;
        end
        else
        begin
          SetUnChoosed(GChoosed);
          SetChoosed(num);
          GChoosed := num;
          exit;
        end;
      end
      else
      begin // 是相同的Temp区域
        SetUnChoosed(GChoosed);
        GChoosed := 0;
        exit;
      end;
    end
    else if GChoosedType = TYPEARRAY then // 之前点击的是Array区域
    begin
      if GTemp[num].x = 0 then // 现在点击的Temp区域是空的
      begin
        MovePokeFromArrayToTemp(GChoosed, num);
        GChoosed := 0;
        exit;
      end
      else
      begin // 现在点击的Temp区域不是空的
        SetUnChoosed(GChoosed);
        GChoosed := 0;
        exit;
      end;
    end
    else if GChoosedType = TYPECONTAINER then
    begin
      MessageBox(Self.Handle, '出现未知错误，游戏将关闭！', '系统信息', MB_OK or MB_ICONERROR);
      Application.Terminate;
    end
    else
    begin
      MessageBox(Self.Handle, '出现未知错误，游戏将关闭！', '系统信息', MB_OK or MB_ICONERROR);
      Application.Terminate;
    end;
  end
  else if (y <= POKE_HEIGHT) and (x >= Self.ClientWidth - 4 * TEMP_MULX) then
  // 点击的是Container区域
  begin
    for i := 4 downto 1 do
      if x >= Self.ClientWidth - (5 - i) * TEMP_MULX then
      begin
        container := i;
        break;
      end;
    if container = 0 then
      exit;
    if GChoosed = 0 then
      exit;
    if GChoosedType = TYPETEMP then // 之前点击的是Temp区域
    begin
      pokeOne := GTemp[GChoosed];
      if CanPutToContainer(pokeOne, container) then
      begin
        PlaySound(PChar('WaveRecycle'), hInstance, SND_ASYNC or SND_RESOURCE);
        // Sleep(100);
        MovePokeFromTempToContainer(GChoosed, container);
        GChoosed := 0;
        exit;
      end
      else
      begin
        Beep();
        SetUnChoosed(GChoosed);
        GChoosed := 0;
        exit;
      end;
    end
    else if GChoosedType = TYPEARRAY then // 之前点击的是Array区域
    begin
      pokeOne := GArray[GChoosed][GArrayIndex[GChoosed]];
      if CanPutToContainer(pokeOne, container) then
      begin
        PlaySound(PChar('WaveRecycle'), hInstance, SND_ASYNC or SND_RESOURCE);
        // Sleep(100);
        MovePokeFromArrayToContainer(GChoosed, container);
        GChoosed := 0;
        exit;
      end
      else
      begin
        Beep();
        SetUnChoosed(GChoosed);
        GChoosed := 0;
        exit;
      end;
    end;
  end;
end;

procedure TFormMain.PaintBoxMainMouseMove(Sender: TObject; Shift: TShiftState; x, y: integer);
var
  posType: TPosType;
  num: integer;
begin
  if (x <= 4 * 75) and (y <= 100) then
  begin
    if GKingDirection = TORIGHT then
    begin
      GKingDirection := TOLEFT;
      UpDateKing(GKingDirection);
    end;
  end
  else if (x >= (Self.ClientWidth - 4 * 75)) and (y <= 100) then
  begin
    if GKingDirection = TOLEFT then
    begin
      GKingDirection := TORIGHT;
      UpDateKing(GKingDirection);
    end;
  end;
  if (not GRunning) or (GChoosed = 0) then
    exit;
  num := GetTargetPokeNumber(x, y, posType);
  if num = 0 then
    exit;
  if IndicatePokeCanMove(GChoosed, num, GChoosedType, posType) then
  begin
    Screen.Cursors[1] := LoadCursor(hInstance, 'DownCursor');
    PaintBoxMain.Cursor := TCursor(1);
  end
  else
    PaintBoxMain.Cursor := crDefault;
end;

procedure TFormMain.PaintBoxMainPaint(Sender: TObject);
begin
  Self.Color := RGB(0, 127, 0);
  UpDateKing(TORIGHT);
  DrawTempArea();
  DrawContainerArea();
  DrawArrayArea();
end;

function TFormMain.PokeCanMove(pokeDown, pokeUp: TPoke): boolean;
begin
  result := False;
  if pokeUp.x = pokeDown.x + 1 then
  begin
    if (pokeDown.y = 1) or (pokeDown.y = 4) then
    begin
      if (pokeUp.y = 2) or (pokeUp.y = 3) then
      begin
        result := true;
        exit;
      end;
    end
    else
    begin
      if (pokeUp.y = 1) or (pokeUp.y = 4) then
      begin
        result := true;
        exit;
      end;
    end;
  end;
end;

procedure TFormMain.restart(flag: boolean; data: TPokerArray);
var
  i, total, num: integer;
  j: integer;
begin
  GRunning := False;
  GChoosed := 0;
  GTotalPoke := 52;
  DrawTempArea();
  DrawContainerArea();
  DrawArrayArea();
  GRunning := true;
  for i := 1 to 4 do
  begin
    GTemp[i].x := 0;
    GTemp[i].y := 0;
    GContainer[i].x := 0;
    GContainer[i].y := 0;
  end;
  DrawTempArea();
  DrawContainerArea();
  for i := 1 to 8 do
    GArrayIndex[i] := 0;
  total := 0;
  for i := 1 to 52 do
    GStringArray[i] := '';
  GStringIndex := 1;
  if flag then
  begin
    while total <= 51 do
    begin
      num := total mod 8 + 1;
      inc(GArrayIndex[num]);
      sleep(5);
      GArray[num][GArrayIndex[num]] := data[num][GArrayIndex[num]];
      inc(total);
      DrawPoke((num - 1) * ARRAY_MULX + ARRAY_STARTX, GArrayIndex[num] * ARRAY_MULY + ARRAY_STARTY, GArray[num][GArrayIndex[num]]);
    end;
  end
  else
  begin
    while total <= 51 do
    begin
      num := total mod 8 + 1;
      inc(GArrayIndex[num]);
      sleep(5);
      GArray[num][GArrayIndex[num]] := GetPokeNumber(total, GStringArray, GStringIndex);
      DrawPoke((num - 1) * ARRAY_MULX + ARRAY_STARTX, GArrayIndex[num] * ARRAY_MULY + ARRAY_STARTY, GArray[num][GArrayIndex[num]]);
    end;
    for i := 1 to 8 do
    begin
      for j := 1 to 100 do
      begin
        GBackupArray[i][j] := GArray[i][j];
      end;
    end;
  end;
  CheckAllPokeCanDelete
end;

procedure TFormMain.SetChoosed(tmp: integer);
var
  index: integer;
begin
  if tmp = 0 then
    exit;
  with PaintBoxMain.Canvas do
  begin
    if GChoosedType = TYPEARRAY then
    begin
      index := GArrayIndex[tmp];
      GBitmap.LoadFromResourceName(hInstance, RESOURCEBACKGROUNDBITMAP);
      Draw((tmp - 1) * ARRAY_MULX + ARRAY_STARTX, index * ARRAY_MULY + ARRAY_STARTY, GBitmap);
      GBitmap.LoadFromResourceName(hInstance, format(RESOURCEBITMAP, [GArray[tmp][index].x, GArray[tmp][index].y]));
      Draw((tmp - 1) * ARRAY_MULX + ARRAY_STARTX, index * ARRAY_MULY + ARRAY_STARTY, GBitmap, 100);
    end
    else if GChoosedType = TYPETEMP then
    begin
      if GTemp[tmp].x = 0 then
        exit;
      GBitmap.LoadFromResourceName(hInstance, RESOURCEBACKGROUNDBITMAP);
      Draw((tmp - 1) * TEMP_MULX, 0, GBitmap);
      GBitmap.LoadFromResourceName(hInstance, format(RESOURCEBITMAP, [GTemp[tmp].x, GTemp[tmp].y]));
      Draw((tmp - 1) * TEMP_MULX, 0, GBitmap, 100);
    end;
  end;
end;

procedure TFormMain.SetUnChoosed(tmp: integer);
var
  index: integer;
begin
  if tmp = 0 then
    exit;
  if GChoosedType = TYPEARRAY then
  begin
    index := GArrayIndex[tmp];
    GBitmap.LoadFromResourceName(hInstance, format(RESOURCEBITMAP, [GArray[tmp][index].x, GArray[tmp][index].y]));
    PaintBoxMain.Canvas.Draw((tmp - 1) * ARRAY_MULX + ARRAY_STARTX, index * ARRAY_MULY + ARRAY_STARTY, GBitmap);
  end
  else if GChoosedType = TYPETEMP then
  begin
    if GTemp[tmp].x = 0 then
      exit;
    GBitmap.LoadFromResourceName(hInstance, format(RESOURCEBITMAP, [GTemp[tmp].x, GTemp[tmp].y]));
    PaintBoxMain.Canvas.Draw((tmp - 1) * TEMP_MULX, 0, GBitmap);
  end;
end;

function TFormMain.GetBlankSpace: integer;
var
  i, numTemp, numArray: integer;
begin
  numTemp := 0;
  for i := 1 to 4 do
    if GTemp[i].x = 0 then
      inc(numTemp);
  numArray := 0;
  for i := 1 to 8 do
    if GArrayIndex[i] = 0 then
      inc(numArray);
  result := numTemp + (numArray + numArray * numArray) div 2 + numTemp * numArray + 1;
end;

function TFormMain.GetBlankSpace_New(col: integer): integer;
var
  i, numTemp, numArray: integer;
begin
  numTemp := 0;
  for i := 1 to 4 do
    if GTemp[i].x = 0 then
      inc(numTemp);
  numArray := 0;
  for i := 1 to 8 do
    if GArrayIndex[i] = 0 then
      inc(numArray);
  dec(numArray);
  result := numTemp + (numArray + numArray * numArray) div 2 + numTemp * numArray + 1;
end;

function TFormMain.GetCanMovePokeNumber(_from, _to: integer): integer;
var
  num: integer;
  targetPoke: TPoke;
  i: integer;
begin
  num := 1;
  result := 0;
  if (GArrayIndex[_from] = 0) or (GArrayIndex[_to] = 0) then
    exit;
  targetPoke := GArray[_to][GArrayIndex[_to]];
  // 第一步 判断Array[tmpTo]上有多少个连续扑克
  for i := GArrayIndex[_from] - 1 downto 1 do
  begin
    if PokeCanMove(GArray[_from][i + 1], GArray[_from][i]) then
    begin
      inc(num);
      continue;
    end
    else
      break;
  end;
  // ShowMessageFmt('有%d个连续的扑克', [tmpNum]);
  result := 0;
  // 第二步 在这么多个连续扑克上检查应该哪一个就可以开始移动
  for i := GArrayIndex[_from] - num + 1 to GArrayIndex[_from] do
  begin
    if PokeCanMove(GArray[_from][i], targetPoke) then
    begin
      result := GArrayIndex[_from] - i + 1;
      exit;
    end;
  end;
end;

function TFormMain.GetCanMovePokeNumber_New(col: integer): integer;
var
  num: integer;
  i: integer;
begin
  num := 1;
  result := 0;
  if (GArrayIndex[col] = 0) then
    exit;
  for i := GArrayIndex[col] - 1 downto 1 do
  begin
    if PokeCanMove(GArray[col][i + 1], GArray[col][i]) then
    begin
      inc(num);
      continue;
    end
    else
      break;
  end;
  result := num;
end;

function TFormMain.GetContainerNumber(poke: TPoke): integer;
begin
  result := 0;
  if poke.y = 1 then
    result := 1
  else if poke.y = 4 then
    result := 2
  else if poke.y = 2 then
    result := 3
  else if poke.y = 3 then
    result := 4;
end;

function TFormMain.GetPokeNumber(var num: integer; var data: array of string; var index: integer): TPoke;
var
  x, y: integer;
  poke: TPoke;
begin
  repeat
    x := random(13) + 1;
    y := random(4) + 1;
  until NotInArraY(x, y, data, index);
  poke.x := x;
  poke.y := y;
  result := poke;
  inc(num);
end;

function TFormMain.GetTargetPokeNumber(x, y: integer; var posType: TPosType): integer;
var
  i: integer;
begin
  result := 0;
  if (x <= 4 * TEMP_MULX) and (y <= POKE_HEIGHT) then
  begin
    for i := 1 to 4 do
      if x >= (4 - i) * POKE_WIDTH then
      begin
        posType := TYPETEMP;
        result := 5 - i;
        exit;
      end;
  end;
  if (y >= ARRAY_MULY + ARRAY_STARTY) then
  begin
    for i := 1 to 8 do
      if x >= (8 - i) * ARRAY_MULX + ARRAY_STARTX then
      begin
        posType := TYPEARRAY;
        result := 9 - i;
        exit;
      end;
  end;
end;

function TFormMain.HavePoke(poke: TPoke): boolean;
var
  i, j: integer;
begin
  result := False;
  for i := 1 to 4 do
    if (GTemp[i].x = poke.x) and (GTemp[i].y = poke.y) then
    begin
      result := true;
      exit;
    end;
  for i := 1 to 8 do
    for j := 1 to GArrayIndex[i] do
    begin
      if (GArray[i][j].x = poke.x) and (GArray[i][j].y = poke.y) then
      begin
        result := true;
        exit;
      end;
    end;
end;

function TFormMain.IndicatePokeCanMove(numFrom, numTo: integer; typeFrom, typeTO: TPosType): boolean;
var
  pokeFrom, pokeTo: TPoke;
begin
  result := False;
  if typeFrom = TYPETEMP then
  begin
    if typeTO = TYPETEMP then
    begin
      pokeFrom := GTemp[numFrom];
      pokeTo := GTemp[numTo];
      if pokeTo.x = 0 then
      begin
        result := true;
        exit;
      end;
    end
    else if typeTO = TYPEARRAY then
    begin
      pokeFrom := GTemp[numFrom];
      pokeTo := GArray[numTo][GArrayIndex[numTo]];
      if (pokeTo.x = 0) or (PokeCanMove(pokeFrom, pokeTo)) then
      begin
        result := true;
        exit;
      end;
    end;
  end
  else if typeFrom = TYPEARRAY then
  begin
    if typeTO = TYPETEMP then
    begin
      pokeTo := GTemp[numTo];
      if pokeTo.x = 0 then
      begin
        result := true;
        exit;
      end;
    end
    else if typeTO = TYPEARRAY then
    begin
      if GetCanMovePokeNumber(numFrom, numTo) > 0 then
      begin
        result := true;
        exit;
      end;
    end;
  end;
end;

function TFormMain.Another(poke: TPoke): boolean;
var
  i: integer;
begin
  result := true;
  for i := 1 to 4 do
  begin
    if poke.x - GContainer[i].x > 2 then
    begin
      result := False;
      exit;
    end;
  end;
end;

procedure TFormMain.AutoMovePokeFromArrayToContainer(col: integer);
begin
  if GArray[col][GArrayIndex[col]].y = 1 then
    MovePokeFromArrayToContainer(col, 1)
  else if GArray[col][GArrayIndex[col]].y = 4 then
    MovePokeFromArrayToContainer(col, 2)
  else if GArray[col][GArrayIndex[col]].y = 2 then
    MovePokeFromArrayToContainer(col, 3)
  else if GArray[col][GArrayIndex[col]].y = 3 then
    MovePokeFromArrayToContainer(col, 4);
end;

function TFormMain.CanDelete(poke: TPoke): boolean;
var
  targetPoke: TPoke;
  container: integer;
begin
  result := False;
  // 第一步得到Container的位置
  container := 0;
  if poke.y = 1 then
    container := 1
  else if poke.y = 4 then
    container := 2
  else if poke.y = 2 then
    container := 3
  else if poke.y = 3 then
    container := 4;
  // 第二步判断Container位置的Poke
  if GContainer[container].x <> poke.x - 1 then
    exit;
  if not Another(poke) then
    exit;
  targetPoke.x := poke.x;
  if poke.y = 1 then
  begin
    targetPoke.y := 4;
    if HavePoke(targetPoke) then
    begin
      result := true;
      exit;
    end
    else
    begin
      targetPoke.x := poke.x - 1;
      if targetPoke.x <= 0 then
      begin
        result := true;
        exit;
      end;
      targetPoke.y := 2;
      if not HavePoke(targetPoke) then
      begin
        targetPoke.y := 3;
        if not HavePoke(targetPoke) then
        begin
          result := true;
          exit;
        end;
      end;
    end;
  end
  else if poke.y = 4 then
  begin
    targetPoke.y := 1;
    if HavePoke(targetPoke) then
    begin
      result := true;
      exit;
    end
    else
    begin
      targetPoke.x := poke.x - 1;
      if targetPoke.x <= 0 then
      begin
        result := true;
        exit;
      end;
      targetPoke.y := 2;
      if not HavePoke(targetPoke) then
      begin
        targetPoke.y := 3;
        if not HavePoke(targetPoke) then
        begin
          result := true;
          exit;
        end;
      end;
    end;
  end
  else if poke.y = 2 then
  begin
    targetPoke.y := 3;
    if HavePoke(targetPoke) then
    begin
      result := true;
      exit;
    end
    else
    begin
      targetPoke.x := poke.x - 1;
      if targetPoke.x <= 0 then
      begin
        result := true;
        exit;
      end;
      targetPoke.y := 1;
      if not HavePoke(targetPoke) then
      begin
        targetPoke.y := 4;
        if not HavePoke(targetPoke) then
        begin
          result := true;
          exit;
        end;
      end;
    end;
  end
  else if poke.y = 3 then
  begin
    targetPoke.y := 2;
    if HavePoke(targetPoke) then
    begin
      result := true;
      exit;
    end
    else
    begin
      targetPoke.x := poke.x - 1;
      if targetPoke.x <= 0 then
      begin
        result := true;
        exit;
      end;
      targetPoke.y := 1;
      if not HavePoke(targetPoke) then
      begin
        targetPoke.y := 4;
        if not HavePoke(targetPoke) then
        begin
          result := true;
          exit;
        end;
      end;
    end;
  end;
end;

function TFormMain.CanPutToContainer(poke: TPoke; container: integer): boolean;
var
  pokeContainer: TPoke;
begin
  result := False;
  if GContainer[container].x = 0 then
  begin
    if CanDelete(poke) then
    begin
      result := true;
      exit;
    end;
  end
  else
  begin
    pokeContainer := GContainer[container];
    if (poke.x = pokeContainer.x + 1) and (poke.y = pokeContainer.y) then
    begin
      result := true;
      exit;
    end;
  end;
end;

procedure TFormMain.CheckAllPokeCanDelete;
var
  i: integer;
begin
  for i := 1 to 4 do
    if GTemp[i].x <> 0 then
    begin
      if CanDelete(GTemp[i]) then
        MovePokeFromTempToContainer(i, 1);
    end;
  for i := 1 to 8 do
  begin
    if CanDelete(GArray[i][GArrayIndex[i]]) then
    begin
      PlaySound(PChar('WaveRecycle'), hInstance, SND_ASYNC or SND_RESOURCE);
      // Sleep(100);
      AutoMovePokeFromArrayToContainer(i);
      CheckAllPokeCanDelete();
    end;
  end;
end;

procedure TFormMain.CheckGame(tmp: integer);
begin
  if tmp = 0 then
  begin
    GRunning := False;
    MessageBox(Self.Handle, '恭喜，你完成了！', '信息', MB_OK);
    PaintBoxMain.OnPaint(nil);
  end;
end;

procedure TFormMain.DrawArrayArea;
var
  i: integer;
begin
  with PaintBoxMain.Canvas do
  begin
    Pen.Color := RGB(0, 127, 0);
    Rectangle(ARRAY_STARTX, 1 * ARRAY_MULY + ARRAY_STARTY, ARRAY_STARTX + Self.Width, 52 * ARRAY_MULY + ARRAY_STARTY);
  end;
  for i := 1 to 8 do
    DrawArrayNumber(i);
end;

procedure TFormMain.DrawArrayNumber(col: integer);
var
  i: integer;
begin
  PaintBoxMain.Canvas.Pen.Color := RGB(0, 127, 0);
  PaintBoxMain.Canvas.Rectangle((col - 1) * ARRAY_MULX + ARRAY_STARTX, 1 * ARRAY_MULY + ARRAY_STARTY, (col - 1) * ARRAY_MULX + ARRAY_STARTX + 71,
    52 * ARRAY_MULY + ARRAY_STARTY);
  if GRunning then
  begin
    for i := 1 to GArrayIndex[col] do
      DrawPoke((col - 1) * ARRAY_MULX + ARRAY_STARTX, i * ARRAY_MULY + ARRAY_STARTY, GArray[col][i]);
  end;
end;

procedure TFormMain.DrawContainerArea;
var
  i, w: integer;
begin
  with PaintBoxMain.Canvas do
  begin
    w := PaintBoxMain.Width;
    Pen.Color := RGB(0, 213, 0);
    Rectangle(w - 71, 0, w, 96);
    Rectangle(w - 2 * 71, 0, w - 71, 96);
    Rectangle(w - 3 * 71, 0, w - 2 * 71, 96);
    Rectangle(w - 4 * 71, 0, w - 3 * 71, 96);
    Pen.Color := RGB(0, 0, 0);
    MoveTo(w, 0);
    LineTo(w - 4 * 71, 0);
    MoveTo(w, 0);
    LineTo(w, 96);
    MoveTo(w - 71, 0);
    LineTo(w - 71, 96);
    MoveTo(w - 2 * 71, 0);
    LineTo(w - 2 * 71, 96);
    MoveTo(w - 3 * 71, 0);
    LineTo(w - 3 * 71, 96);
    MoveTo(w - 4 * 71, 0);
    LineTo(w - 4 * 71, 96);
  end;
  if GRunning then
    for i := 1 to 4 do
      DrawContainerNumber(i);
end;

procedure TFormMain.DrawContainerNumber(num: integer);
begin
  if (GContainer[num].x <> 0) or (GContainer[num].y <> 0) then
  begin
    GBitmap.LoadFromResourceName(hInstance, format(RESOURCEBITMAP, [GContainer[num].x, GContainer[num].y]));
    PaintBoxMain.Canvas.Draw(Self.Width - (5 - num) * 71 - 6, 0, GBitmap);
  end;
end;

procedure TFormMain.DrawPoke(x, y: integer; poke: TPoke);
begin
  GBitmap.LoadFromResourceName(hInstance, format(RESOURCEBITMAP, [poke.x, poke.y]));
  PaintBoxMain.Canvas.StretchDraw(Rect(x, y, x + POKE_WIDTH, y + POKE_HEIGHT), GBitmap);
end;

procedure TFormMain.DrawTempArea();
var
  i: integer;
begin
  with PaintBoxMain.Canvas do
  begin
    Pen.Color := RGB(0, 213, 0);
    Rectangle(0, 0, 71, 96);
    Rectangle(71, 0, 142, 96);
    Rectangle(142, 0, 213, 96);
    Rectangle(213, 0, 284, 96);
    Pen.Color := RGB(0, 0, 0);
    MoveTo(0, 0);
    LineTo(0, 96);
    MoveTo(0, 0);
    LineTo(284, 0);
    MoveTo(71, 0);
    LineTo(71, 96);
    MoveTo(142, 0);
    LineTo(142, 96);
    MoveTo(213, 0);
    LineTo(213, 96);
  end;
  if GRunning then
    for i := 1 to 4 do
      DrawTempAreaNumber(i);
end;

procedure TFormMain.DrawTempAreaNumber(num: integer);
begin
  with PaintBoxMain.Canvas do
  begin
    if (GTemp[num].x <> 0) or (GTemp[num].y <> 0) then
    begin
      GBitmap.LoadFromResourceName(hInstance, format(RESOURCEBITMAP, [GTemp[num].x, GTemp[num].y]));
      Draw((num - 1) * TEMP_MULX, 0, GBitmap);
    end
    else
    begin
      Pen.Color := RGB(0, 213, 0);
      case num of
        1:
          begin
            Rectangle(0, 0, 71, 96);
          end;
        2:
          begin
            Rectangle(71, 0, 142, 96);
          end;
        3:
          begin
            Rectangle(142, 0, 213, 96);
          end;
        4:
          begin
            Rectangle(213, 0, 284, 96);
          end
      else
        ;
      end;
      Pen.Color := RGB(0, 0, 0);
      MoveTo(0, 0);
      LineTo(0, 96);
      MoveTo(0, 0);
      LineTo(284, 0);
      MoveTo(71, 0);
      LineTo(71, 96);
      MoveTo(142, 0);
      LineTo(142, 96);
      MoveTo(213, 0);
      LineTo(213, 96);
    end;
  end;
end;

end.
