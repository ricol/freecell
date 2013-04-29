unit UnitMain;

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

  TArray = array[1..100] of TPoke;

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
    procedure PaintBoxMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMainMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure UpDateKing(tmp: TDIRECTION);
    function GetPokeNumber(var tmpNumber: integer; var tmpArray: array of string; var tmpIndex: integer): TPoke;
    procedure DrawPoke(tmpX, tmpY: integer; tmpPoke: TPoke);
    function NotInArraY(tmpX, tmpY: integer; var tmpArray: array of string; var tmpIndex: integer): boolean;
    procedure SetUnChoosed(tmp: Integer);
    procedure SetChoosed(tmp: Integer);
    procedure MovePokeFromArrayToTemp(tmpCol, tmpNum: integer);
    procedure MovePokeFromArrayToArray(tmpColFrom, tmpColTo: integer);
    procedure MovePokeFromTempToArray(tmpNum, tmpCol: integer);
    procedure MovePokeFromTempToContainer(tmpNum, tmpContainer: integer);
    procedure MovePokeFromTempToTemp(tmpNumFrom, tmpNumTo: integer);
    procedure MovePokeFromArrayToContainer(tmpCol, tmpContainer: integer);
    procedure AutoMovePokeFromArrayToContainer(tmpCol: integer);
    function PokeCanMove(tmpPokeDown, tmpPokeUp: TPoke): boolean;
    function IndicatePokeCanMove(tmpNumFrom, tmpNumTo: integer; tmpTypeFrom, tmpTypeTo: TPosType): boolean;
    function CanPutToContainer(tmpPoke: TPoke; tmpContainer: integer): boolean;
    function CanDelete(tmpPoke: TPoke): boolean;
    function HavePoke(tmpPoke: TPoke): boolean;
    function GetContainerNumber(tmpPoke: TPoke): integer;
    function GetCanMovePokeNumber(tmpFrom, tmpTo: integer): integer;
    function GetBlankSpace(): integer;
    function GetBlankSpace_New(tmpCol: integer): integer;
    function Another(tmpPoke: TPoke): boolean;
    function GetTargetPokeNumber(X, Y: integer; var tmpPosType: TPosType): integer;
    function GetCanMovePokeNumber_New(tmpCol: integer): integer;
    procedure CheckAllPokeCanDelete();
    procedure DrawTempArea();
    procedure DrawTempAreaNumber(tmpNum: Integer);
    procedure DrawContainerArea();
    procedure DrawArrayArea();
    procedure DrawArrayNumber(tmpCol: integer);
    procedure DrawContainerNumber(tmpNum: integer);
    procedure CheckGame(tmp: integer);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

uses UnitMove;

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
  GArray: array[1..8] of TArray;
  GTempArray: TArray;
  GTempArrayIndex: integer;
  GArrayIndex: array[1..8] of integer = (0, 0, 0, 0, 0, 0, 0, 0);
  GTemp: array[1..4] of TPoke;
  GContainer: array[1..4] of TPoke;
  GStringArray: array[1..53] of string;
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
  GHaveClicked := false;
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

procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
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
  PaintBoxMain.Canvas.StretchDraw(GRect, GBitmap);
  PaintBoxMain.Canvas.Pen.Color := RGB(0, 255, 0);
  PaintBoxMain.Canvas.MoveTo(GRect.Left - 1, GRect.Top - 1);
  PaintBoxMain.Canvas.LineTo(GRect.Right + 1, GRect.Top - 1);
  PaintBoxMain.Canvas.MoveTo(GRect.Left - 1, GRect.Top - 1);
  PaintBoxMain.Canvas.LineTo(GRect.Left - 1, GRect.Bottom + 1);
  PaintBoxMain.Canvas.Pen.Color := RGB(0, 0, 0);
  PaintBoxMain.Canvas.MoveTo(GRect.Right + 1, GRect.Bottom + 1);
  PaintBoxMain.Canvas.LineTo(GRect.Left - 1, GRect.Bottom + 1);
  PaintBoxMain.Canvas.MoveTo(GRect.Right + 1, GRect.Bottom + 1);
  PaintBoxMain.Canvas.LineTo(GRect.Right + 1, GRect.Top - 1);
end;

procedure TFormMain.MenuGameExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.MenuGameStartClick(Sender: TObject);
var
  i, total, tmpNum: integer;
begin
  GRunning := false;
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
  while total <= 51 do
  begin
    tmpNum := total mod 8 + 1;
    inc(GArrayIndex[tmpNum]);
//    sleep(5);
    GArray[tmpNum][GArrayIndex[tmpNum]] := GetPokeNumber(total, GStringArray, GStringIndex);
    DrawPoke((tmpNum - 1) * ARRAY_MULX + ARRAY_STARTX,
             GArrayIndex[tmpNum] * ARRAY_MULY + ARRAY_STARTY,
             GArray[tmpNum][GArrayIndex[tmpNum]]);
  end;
end;

procedure TFormMain.MenuGameStopClick(Sender: TObject);
begin
  GRunning := false;
  PaintBoxMain.OnPaint(Sender);
end;

procedure TFormMain.MenuHelpAboutClick(Sender: TObject);
begin
  MessageBox(Self.Handle, PChar('游戏名称：空当接龙' + sLineBreak +
                                '开发者：RICOL' + sLineBreak +
                                '联系：WANGXINGHE1983@GMAIL.COM'), '关于', MB_OK);
end;

procedure TFormMain.MovePokeFromArrayToArray(tmpColFrom, tmpColTo: integer);
begin
  inc(GArrayIndex[tmpColTo]);
  GArray[tmpColTo][GArrayIndex[tmpColTo]] := GArray[tmpColFrom][GArrayIndex[tmpColFrom]];
  GArray[tmpColFrom][GArrayIndex[tmpColFrom]].x := 0;
  GArray[tmpColFrom][GArrayIndex[tmpColFrom]].y := 0;
  dec(GArrayIndex[tmpColFrom]);
  DrawArrayNumber(tmpColFrom);
  DrawArrayNumber(tmpColTo);
  CheckAllPokeCanDelete();
end;

procedure TFormMain.MovePokeFromArrayToContainer(tmpCol, tmpContainer: integer);
var
  tmpNum: integer;
begin
  tmpNum := GetContainerNumber(GArray[tmpCol][GArrayIndex[tmpCol]]);
  GContainer[tmpNum] := GArray[tmpCol][GArrayIndex[tmpCol]];
  GArray[tmpCol][GArrayIndex[tmpCol]].x := 0;
  GArray[tmpCol][GArrayIndex[tmpCol]].y := 0;
  dec(GArrayIndex[tmpCol]);
  DrawArrayNumber(tmpCol);
  DrawContainerNumber(tmpNum);
  dec(GTotalPoke);
  CheckGame(GTotalPoke);
end;

procedure TFormMain.MovePokeFromArrayToTemp(tmpCol, tmpNum: integer);
begin
  GTemp[tmpNum].x := GArray[tmpCol][GArrayIndex[tmpCol]].x;
  GTemp[tmpNum].y := GArray[tmpCol][GArrayIndex[tmpCol]].y;
  GArray[tmpCol][GArrayIndex[tmpCol]].x := 0;
  GArray[tmpCol][GArrayIndex[tmpCol]].y := 0;
  Dec(GArrayIndex[tmpCol]);
  DrawArrayNumber(tmpCol);
  DrawTempAreaNumber(tmpNum);
  CheckAllPokeCanDelete();
end;

procedure TFormMain.MovePokeFromTempToArray(tmpNum, tmpCol: integer);
begin
  inc(GArrayIndex[tmpCol]);
  GArray[tmpCol][GArrayIndex[tmpCol]] := GTemp[tmpNum];
  GTemp[tmpNum].x := 0;
  GTemp[tmpNum].y := 0;
  DrawTempAreaNumber(tmpNum);
  DrawArrayNumber(tmpCol);
end;

procedure TFormMain.MovePokeFromTempToContainer(tmpNum, tmpContainer: integer);
var
  tmpNumber: integer;
begin
  tmpNumber := GetContainerNumber(GTemp[tmpNum]);
  GContainer[tmpNumber] := GTemp[tmpNum];
  GTemp[tmpNum].x := 0;
  GTemp[tmpNum].y := 0;
  DrawTempAreaNumber(tmpNum);
  DrawContainerNumber(tmpNumber);
  dec(GTotalPoke);
  CheckGame(GTotalPoke);
end;

procedure TFormMain.MovePokeFromTempToTemp(tmpNumFrom, tmpNumTo: integer);
begin
  GTemp[tmpNumTo] := GTemp[tmpNumFrom];
  GTemp[tmpNumFrom].x := 0;
  GTemp[tmpNumFrom].y := 0;
  DrawTempAreaNumber(tmpNumFrom);
  DrawTempAreaNumber(tmpNumTo);
end;

function TFormMain.NotInArraY(tmpX, tmpY: integer;
  var tmpArray: array of string; var tmpIndex: integer): boolean;
var
  i: integer;
begin
  result := true;
  for i := Low(tmpArray) to tmpIndex - 1 do
  begin
    if format('%d_%d', [tmpX, tmpY]) = tmpArray[i] then
    begin
      result := false;
      exit;
    end;
  end;
  tmpArray[tmpIndex] := format('%d_%d', [tmpX, tmpY]);
  inc(tmpIndex);
end;

procedure TFormMain.PaintBoxMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, tmpNum, tmpCol, tmpContainer, tmpPokeNumber, tmpSpace: integer;
  tmpPokeOne, tmpPokeTwo: TPoke;
begin
  if not GRunning then exit;
  tmpNum := 0;
  tmpCol := 0;
  tmpContainer := 0;
  PaintBoxMain.Cursor := crDefault;
  Application.ProcessMessages;
  if (Y >= ARRAY_MULY + ARRAY_STARTY) then        //点击的是Array区域
  begin
    for i := 1 to 8 do
      if X >= (8 - i) * ARRAY_MULX + ARRAY_STARTX then
      begin
        tmpCol := 9 - i;
        break;
      end;
    if tmpCol = 0 then exit;
    if GChoosed = 0 then
    begin
      if GArrayIndex[tmpCol] > 0 then
      begin
        GChoosed := tmpCol;
        GChoosedType := TYPEARRAY;
        SetChoosed(tmpCol);
        exit;
      end else
        exit;
    end else
    begin
      if GChoosedType = TYPEARRAY then             //之前点击的是Array区域
      begin
        if GChoosed = tmpCol then                  //两次点击的是相同的Array区域
        begin
          SetUnchoosed(tmpCol);
          GChoosed := 0;
          exit;
        end else
        begin                             //两次点击的是不同的Array区域
          if GArrayIndex[tmpCol] <= 0 then         //这次点击的Array没有Poke
          begin
            tmpPokeNumber := GetCanMovePokeNumber_New(GChoosed);
            if tmpPokeNumber = 1 then
            begin
              MovePokeFromArrayToArray(GChoosed, tmpCol);
              GChoosed := 0;
              exit;
            end;
            FormMove.Left := Self.Left + (Self.Width div 2) - FormMove.Width div 2;
            FormMove.Top := Self.Top + (Self.Height div 2) - FormMove.Height div 2;
            FormMove.ShowModal;
            if GCancel then
            begin
              SetUnchoosed(GChoosed);
              GChoosed := 0;
              exit;
            end;
            if GMoveAll then
            begin
              tmpSpace := GetBlankSpace_New(tmpCol);
              if tmpPokeNumber > tmpSpace then
                tmpPokeNumber := tmpSpace;
              GTempArrayIndex := 0;
              for i := GArrayIndex[GChoosed] downto GArrayIndex[GChoosed] - tmpPokeNumber + 1 do
              begin
                if i <= 0 then break;
                inc(GTempArrayIndex);
                GTempArray[GTempArrayIndex] := GArray[GChoosed][i];
                GArray[GChoosed][i].x := 0;
                GArray[GChoosed][i].y := 0;
                dec(GArrayIndex[GChoosed]);
              end;
              for i := GTempArrayIndex downto 1 do
              begin
                inc(GArrayIndex[tmpCol]);
                GArray[tmpCol][GArrayIndex[tmpCol]] := GTempArray[i];
              end;
              DrawArrayNumber(GChoosed);
              DrawArrayNumber(tmpCol);
              CheckAllPokeCanDelete();
              GChoosed := 0;
              exit;
            end else
            begin
              MovePokeFromArrayToArray(GChoosed, tmpCol);
            end;
            GChoosed := 0;
            exit;
          end;
          //这次点击的Array有Poke
          //首先判断可以移动的Poke数目 从GChoosed -> tmpCol
          tmpPokeNumber := GetCanMovePokeNumber(GChoosed, tmpCol);
          tmpSpace := GetBlankSpace();
          if tmpSpace < tmpPokeNumber then
          begin
            MessageBox(Self.Handle, PChar(Format('要求移动 %d 张牌。但所剩空间只能够移动 %d 张牌。', [tmpPokeNumber, tmpSpace])), '信息', MB_OK or MB_ICONINFORMATION);
            SetUnChoosed(GChoosed);
            GChoosed := 0;
            exit;
          end else
          begin
          //开始移动整堆的扑克
            GTempArrayIndex := 0;
            for i := GArrayIndex[GChoosed] downto GArrayIndex[GChoosed] - tmpPokeNumber + 1 do
            begin
              if i <= 0 then break;
              inc(GTempArrayIndex);
              GTempArray[GTempArrayIndex] := GArray[GChoosed][i];
              GArray[GChoosed][i].x := 0;
              GArray[GChoosed][i].y := 0;
              dec(GArrayIndex[GChoosed]);
            end;
            for i := GTempArrayIndex downto 1 do
            begin
              inc(GArrayIndex[tmpCol]);
              GArray[tmpCol][GArrayIndex[tmpCol]] := GTempArray[i];
            end;
            DrawArrayNumber(GChoosed);
            DrawArrayNumber(tmpCol);
            CheckAllPokeCanDelete();
            GChoosed := 0;
            exit;
          end;
        end;
      end else if GChoosedType = TYPETEMP then       //之前点击的是Temp区域
      begin
        if GTemp[GChoosed].x <> 0 then               //之前点击的Temp区域不为空
        begin
          if GArrayIndex[tmpCol] <= 0 then         //这次点击的Array没有Poke
          begin
            MovePokeFromTempToArray(GChoosed, tmpCol);
            GChoosed := 0;
            exit;
          end;
          tmpPokeOne := GTemp[GChoosed];
          tmpPokeTwo := GArray[tmpCol][GArrayIndex[tmpCol]];
          if PokeCanMove(tmpPokeOne, tmpPokeTwo) then
          begin
            MovePokeFromTempToArray(GChoosed, tmpCol);
            GChoosed := 0;
            exit;
          end else
          begin
            Beep();
            SetUnChoosed(GChoosed);
            GChoosed := 0;
            exit;
          end;
        end else
        begin                               //之前点击的Temp区域为空则出现异常错误
          ShowMessage(IntToStr(GChoosed));
          MessageBox(Self.Handle, '出现未知错误，游戏将关闭！', '系统信息', MB_OK or MB_ICONERROR);
          Application.Terminate;
        end;
      end else if GChoosedType = TYPECONTAINER then
      begin
        MessageBox(Self.Handle, '出现未知错误，游戏将关闭！', '系统信息', MB_OK or MB_ICONERROR);
        Application.Terminate;
      end else
      begin
        MessageBox(Self.Handle, '出现未知错误，游戏将关闭！', '系统信息', MB_OK or MB_ICONERROR);
        Application.Terminate;
      end;
    end;
  end else if (Y <= POKE_HEIGHT) and (X <= 4 * TEMP_MULX) then     //点击的是Temp区域
  begin
    for i := 1 to 4 do
      if X >= (4 - i) * POKE_WIDTH then
      begin
        tmpNum := 5 - i;
        break;
      end;
      if tmpNum = 0 then exit;
      if GChoosed = 0 then
      begin
        if GTemp[tmpNum].x <> 0 then
        begin
          GChoosed := tmpNum;
          GChoosedType := TYPETEMP;
          SetChoosed(tmpNum);
          exit;
        end else exit;
      end else if GChoosedType = TYPETEMP then           //之前点击的也是Temp区域
      begin
        if GChoosed <> tmpNum then                   //是不同的Temp区域
        begin
          if GTemp[tmpNum].x = 0 then
          begin
            MovePokeFromTempToTemp(GChoosed, tmpNum);
            GChoosed := 0;
            exit;
          end else
          begin
            SetUnChoosed(GChoosed);
            SetChoosed(tmpNum);
            GChoosed := tmpNum;
            exit;
          end;
        end else
        begin                               //是相同的Temp区域
          SetUnChoosed(GChoosed);
          GChoosed := 0;
          exit;
        end;
      end else if GChoosedType = TYPEARRAY then        //之前点击的是Array区域
      begin
        if GTemp[tmpNum].x = 0 then                    //现在点击的Temp区域是空的
        begin
          MovePokeFromArrayToTemp(GChoosed, tmpNum);
          GChoosed := 0;
          exit;
        end else
        begin                                 //现在点击的Temp区域不是空的
          SetUnChoosed(GChoosed);
          GChoosed := 0;
          exit;
        end;
      end else if GChoosedType = TYPECONTAINER then
      begin
        MessageBox(Self.Handle, '出现未知错误，游戏将关闭！', '系统信息', MB_OK or MB_ICONERROR);
        Application.Terminate;
      end else
      begin
        MessageBox(Self.Handle, '出现未知错误，游戏将关闭！', '系统信息', MB_OK or MB_ICONERROR);
        Application.Terminate;
      end;
  end else if (Y <= POKE_HEIGHT) and (X >= Self.ClientWidth - 4 * TEMP_MULX) then   //点击的是Container区域
  begin
    for i := 4 downto 1 do
      if X >= Self.ClientWidth - (5 - i) * TEMP_MULX then
      begin
        tmpContainer := i;
        break;
      end;
      if tmpContainer = 0 then exit;
      if GChoosed = 0 then exit;
      if GChoosedType = TYPETEMP then                              //之前点击的是Temp区域
      begin
        tmpPokeOne := GTemp[GChoosed];
        if CanPutToContainer(tmpPokeOne, tmpContainer) then
        begin
          PlaySound(PChar('WaveRecycle'), hInstance, SND_ASYNC or SND_RESOURCE);
//          Sleep(100);
          MovePokeFromTempToContainer(GChoosed, tmpContainer);
          GChoosed := 0;
          exit;
        end else
        begin
          Beep();
          SetUnchoosed(GChoosed);
          GChoosed := 0;
          exit;
        end;
      end else if GChoosedType = TYPEARRAY then                   //之前点击的是Array区域
      begin
        tmpPokeOne := GArray[GChoosed][GArrayIndex[GChoosed]];
        if CanPutToContainer(tmpPokeOne, tmpContainer) then
        begin
          PlaySound(PChar('WaveRecycle'), hInstance, SND_ASYNC or SND_RESOURCE);
//          Sleep(100);
          MovePokeFromArrayToContainer(GChoosed, tmpContainer);
          GChoosed := 0;
          exit;
        end else
        begin
          Beep();
          SetUnChoosed(GChoosed);
          GChoosed := 0;
          exit;
        end;
      end;
  end;
end;

procedure TFormMain.PaintBoxMainMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  tmpPosType: TPosType;
  tmpNum: integer;
begin
  if (X <= 4 * 75) and (Y <= 100) then
  begin
    if GKingDirection = TORIGHT then
    begin
      GKingDirection := TOLEFT;
      UpDateKing(GKingDirection);
    end;
  end else if (X >= (Self.ClientWidth - 4 * 75)) and (Y <= 100) then
  begin
    if GKingDirection = TOLEFT then
    begin
      GKingDirection := TORIGHT;
      UpDateKing(GKingDirection);
    end;
  end;
  if (not GRunning) or (GChoosed = 0) then exit;
  tmpNum := GetTargetPokeNumber(X, Y, tmpPosType);
  if tmpNum = 0 then exit;
  if IndicatePokeCanMove(GChoosed, tmpNum, GChoosedType, tmpPosType) then
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

function TFormMain.PokeCanMove(tmpPokeDown, tmpPokeUp: TPoke): boolean;
begin
  result := false;
  if tmpPokeUp.x = tmpPokeDown.x + 1 then
  begin
    if (tmpPokeDown.y = 1) or (tmpPokeDown.y = 4) then
    begin
      if (tmpPokeUp.y = 2) or (tmpPokeUp.y = 3) then
      begin
        result := true;
        exit;
      end;
    end else
    begin
      if (tmpPokeUp.y =1) or (tmpPokeUp.y = 4) then
      begin
        result := true;
        exit;
      end;
    end;
  end;
end;

procedure TFormMain.SetChoosed(tmp: Integer);
var
  tmpIndex: integer;
begin
  if tmp = 0 then exit;
  if GChoosedType = TYPEARRAY then
  begin
    tmpIndex := GArrayIndex[tmp];
    GBitmap.LoadFromResourceName(hInstance, RESOURCEBACKGROUNDBITMAP);
    PaintBoxMain.Canvas.Draw((tmp - 1) * ARRAY_MULX + ARRAY_STARTX, tmpIndex * ARRAY_MULY + ARRAY_STARTY, GBitmap);
    GBitmap.LoadFromResourceName(hInstance, Format(RESOURCEBITMAP, [GArray[tmp][tmpIndex].x, GArray[tmp][tmpIndex].y]));
    PaintBoxMain.Canvas.Draw((tmp - 1) * ARRAY_MULX + ARRAY_STARTX, tmpIndex * ARRAY_MULY + ARRAY_STARTY, GBitmap, 100);
  end else if GChoosedType = TYPETEMP then
  begin
    if GTemp[tmp].x = 0 then exit;
    GBitmap.LoadFromResourceName(hInstance, RESOURCEBACKGROUNDBITMAP);
    PaintBoxMain.Canvas.Draw((tmp - 1) * TEMP_MULX, 0, GBitmap);
    GBitmap.LoadFromResourceName(hInstance, Format(RESOURCEBITMAP, [GTemp[tmp].x, GTemp[tmp].y]));
    PaintBoxMain.Canvas.Draw((tmp - 1) * TEMP_MULX, 0, GBitmap, 100);
  end;
end;

procedure TFormMain.SetUnChoosed(tmp: Integer);
var
  tmpIndex: integer;
begin
  if tmp = 0 then exit;
  if GChoosedType = TYPEARRAY then
  begin
    tmpIndex := GArrayIndex[tmp];
    GBitmap.LoadFromResourceName(hInstance, Format(RESOURCEBITMAP, [GArray[tmp][tmpIndex].x, GArray[tmp][tmpIndex].y]));
    PaintBoxMain.Canvas.Draw((tmp - 1) * ARRAY_MULX + ARRAY_STARTX, tmpIndex * ARRAY_MULY + ARRAY_STARTY, GBitmap);
  end else if GChoosedType = TYPETEMP then
  begin
    if GTemp[tmp].x = 0 then exit;
    GBitmap.LoadFromResourceName(hInstance, Format(RESOURCEBITMAP, [GTemp[tmp].x, GTemp[tmp].y]));
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

function TFormMain.GetBlankSpace_New(tmpCol: integer): integer;
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

function TFormMain.GetCanMovePokeNumber(tmpFrom, tmpTo: integer): integer;
var
  tmpNum: integer;
  tmpTargetPoke: TPoke;
  i: Integer;
begin
  tmpNum := 1;
  result := 0;
  if (GArrayIndex[tmpFrom] = 0) or (GArrayIndex[tmpTo] = 0) then exit;
  tmpTargetPoke := GArray[tmpTo][GArrayIndex[tmpTo]];
  //第一步 判断Array[tmpTo]上有多少个连续扑克
  for i := GArrayIndex[tmpFrom] - 1 downto 1 do
  begin
    if PokeCanMove(GArray[tmpFrom][i + 1], GArray[tmpFrom][i]) then
    begin
      inc(tmpNum);
      continue;
    end else
      break;
  end;
//  ShowMessageFmt('有%d个连续的扑克', [tmpNum]);
  result := 0;
 //第二步 在这么多个连续扑克上检查应该哪一个就可以开始移动
  for i := GArrayIndex[tmpFrom] - tmpNum + 1 to GArrayIndex[tmpFrom] do
  begin
    if PokeCanMove(GArray[tmpFrom][i], tmpTargetPoke) then
    begin
      result := GArrayIndex[tmpFrom] - i + 1;
      exit;
    end;
  end;
end;

function TFormMain.GetCanMovePokeNumber_New(tmpCol: integer): integer;
var
  tmpNum: integer;
  i: Integer;
begin
  tmpNum := 1;
  result := 0;
  if (GArrayIndex[tmpCol] = 0) then exit;
  for i := GArrayIndex[tmpCol] - 1 downto 1 do
  begin
    if PokeCanMove(GArray[tmpCol][i + 1], GArray[tmpCol][i]) then
    begin
      inc(tmpNum);
      continue;
    end else
      break;
  end;
  result := tmpNum;
end;

function TFormMain.GetContainerNumber(tmpPoke: TPoke): integer;
begin
  result := 0;
  if tmpPoke.y = 1 then result := 1
  else if tmpPoke.y = 4 then result := 2
  else if tmpPoke.y = 2 then result := 3
  else if tmpPoke.y = 3 then result := 4;
end;

function TFormMain.GetPokeNumber(var tmpNumber: integer; var tmpArray: array of string; var tmpIndex: integer): TPoke;
var
  tmpX, tmpY: integer;
  tmpPoke: TPoke;
begin
  repeat
    tmpX := random(13) + 1;
    tmpY := random(4) + 1;
  until NotInArraY(tmpX, tmpY, tmpArray, tmpIndex);
  tmpPoke.x := tmpX;
  tmpPoke.y := tmpY;
  result := tmpPoke;
  inc(tmpNumber);
end;

function TFormMain.GetTargetPokeNumber(X, Y: integer;
  var tmpPosType: TPosType): integer;
var
  i: Integer;
begin
  result := 0;
  if (X <= 4 * TEMP_MULX) and (Y <= POKE_HEIGHT) then
  begin
    for i := 1 to 4 do
      if X >= (4 - i) * POKE_WIDTH then
      begin
        tmpPosType := TYPETEMP;
        result := 5 - i;
        exit;
      end;
  end;
  if (Y >= ARRAY_MULY + ARRAY_STARTY) then
  begin
    for i := 1 to 8 do
      if X >= (8 - i) * ARRAY_MULX + ARRAY_STARTX then
      begin
        tmpPosType := TYPEARRAY;
        result := 9 - i;
        exit;
      end;
  end;
end;

function TFormMain.HavePoke(tmpPoke: TPoke): boolean;
var
  i, j: integer;
begin
  result := false;
  for i := 1 to 4 do
    if (GTemp[i].x = tmpPoke.x) and (GTemp[i].y = tmpPoke.y) then
    begin
      result := true;
      exit;
    end;
  for i := 1 to 8 do
    for j := 1 to GArrayIndex[i] do
    begin
      if (GArray[i][j].x = tmpPoke.x) and (GArray[i][j].y = tmpPoke.y) then
      begin
        result := true;
        exit;
      end;
    end;
end;

function TFormMain.IndicatePokeCanMove(tmpNumFrom, tmpNumTo: integer;
  tmpTypeFrom, tmpTypeTo: TPosType): boolean;
var
  tmpPokeFrom, tmpPokeTo: TPoke;
begin
  result := false;
  if tmpTypeFrom = TYPETEMP then
  begin
    if tmpTypeTo = TYPETEMP then
    begin
      tmpPokeFrom := GTemp[tmpNumFrom];
      tmpPokeTo := GTemp[tmpNumTo];
      if tmpPokeTo.x = 0 then
      begin
        result := true;
        exit;
      end;
    end else if tmpTypeTo = TYPEARRAY then
    begin
      tmpPokeFrom := GTemp[tmpNumFrom];
      tmpPokeTo := GArray[tmpNumTo][GArrayIndex[tmpNumTo]];
      if (tmpPokeTo.x = 0) or (PokeCanMove(tmpPokeFrom, tmpPokeTo)) then
      begin
        result := true;
        exit;
      end;
    end;
  end else if tmpTypeFrom = TYPEARRAY then
  begin
    if tmpTypeTo = TYPETEMP then
    begin
      tmpPokeTo := GTemp[tmpNumTo];
      if tmpPokeTo.x = 0 then
      begin
        result := true;
        exit;
      end;
    end else if tmpTypeTo = TYPEARRAY then
    begin
      if GetCanMovePokeNumber(tmpNumFrom, tmpNumTo) > 0 then
      begin
        result := true;
        exit;
      end;
    end;
  end;
end;

function TFormMain.Another(tmpPoke: TPoke): boolean;
var
  i: Integer;
begin
  result := true;
  for i := 1 to 4 do
  begin
    if tmpPoke.x - GContainer[i].x > 2 then
    begin
      result := false;
      exit;
    end;
  end;
end;

procedure TFormMain.AutoMovePokeFromArrayToContainer(tmpCol: integer);
begin
  if GArray[tmpCol][GArrayIndex[tmpCol]].y = 1 then
    MovePokeFromArrayToContainer(tmpCol, 1)
  else if GArray[tmpCol][GArrayIndex[tmpCol]].y = 4 then
    MovePokeFromArrayToContainer(tmpCol, 2)
  else if GArray[tmpCol][GArrayIndex[tmpCol]].y = 2 then
    MovePokeFromArrayToContainer(tmpCol, 3)
  else if GArray[tmpCol][GArrayIndex[tmpCol]].y = 3 then
    MovePokeFromArrayToContainer(tmpCol, 4);
end;

function TFormMain.CanDelete(tmpPoke: TPoke): boolean;
var
  tmpTargetPoke: TPoke;
  tmpContainer: integer;
begin
  result := false;
  //第一步得到Container的位置
  tmpContainer := 0;
  if tmpPoke.y = 1 then tmpContainer := 1
  else if tmpPoke.y = 4 then tmpContainer := 2
  else if tmpPoke.y = 2 then tmpContainer := 3
  else if tmpPoke.y = 3 then tmpContainer := 4;
  //第二步判断Container位置的Poke
  if GContainer[tmpContainer].x <> tmpPoke.x - 1 then exit;
  if not Another(tmpPoke) then exit;
  tmpTargetPoke.x := tmpPoke.x;
  if tmpPoke.y = 1 then
  begin
    tmpTargetPoke.y := 4;
    if HavePoke(tmpTargetPoke) then
    begin
      result := true;
      exit;
    end else
    begin
      tmpTargetPoke.x := tmpPoke.x - 1;
      if tmpTargetPoke.x <= 0 then
      begin
        result := true;
        exit;
      end;
      tmpTargetPoke.y := 2;
      if not HavePoke(tmpTargetPoke) then
      begin
        tmpTargetPoke.y := 3;
        if not HavePoke(tmpTargetPoke) then
        begin
          result := true;
          exit;
        end;
      end;
    end;
  end else if tmpPoke.y = 4 then
  begin
    tmpTargetPoke.y := 1;
    if HavePoke(tmpTargetPoke) then
    begin
      result := true;
      exit;
    end else
    begin
      tmpTargetPoke.x := tmpPoke.x - 1;
      if tmpTargetPoke.x <= 0 then
      begin
        result := true;
        exit;
      end;
      tmpTargetPoke.y := 2;
      if not HavePoke(tmpTargetPoke) then
      begin
        tmpTargetPoke.y := 3;
        if not HavePoke(tmpTargetPoke) then
        begin
          result := true;
          exit;
        end;
      end;
    end;
  end else if tmpPoke.y = 2 then
  begin
    tmpTargetPoke.y := 3;
    if HavePoke(tmpTargetPoke)then
    begin
      result := true;
      exit;
    end else
    begin
      tmpTargetPoke.x := tmpPoke.x - 1;
      if tmpTargetPoke.x <= 0 then
      begin
        result := true;
        exit;
      end;
      tmpTargetPoke.y := 1;
      if not HavePoke(tmpTargetPoke) then
      begin
        tmpTargetPoke.y := 4;
        if not HavePoke(tmpTargetPoke) then
        begin
          result := true;
          exit;
        end;
      end;
    end;
  end else if tmpPoke.y = 3 then
  begin
    tmpTargetPoke.y := 2;
    if HavePoke(tmpTargetPoke)then
    begin
      result := true;
      exit;
    end else
    begin
      tmpTargetPoke.x := tmpPoke.x - 1;
      if tmpTargetPoke.x <= 0 then
      begin
        result := true;
        exit;
      end;
      tmpTargetPoke.y := 1;
      if not HavePoke(tmpTargetPoke) then
      begin
        tmpTargetPoke.y := 4;
        if not HavePoke(tmpTargetPoke) then
        begin
          result := true;
          exit;
        end;
      end;
    end;
  end;
end;

function TFormMain.CanPutToContainer(tmpPoke: TPoke; tmpContainer: integer): boolean;
var
  tmpPokeContainer: TPoke;
begin
  result := false;
  if GContainer[tmpContainer].x = 0 then
  begin
    if CanDelete(tmpPoke) then
    begin
      result := true;
      exit;
    end;
  end else
  begin
    tmpPokeContainer := GContainer[tmpContainer];
    if (tmpPoke.x = tmpPokeContainer.x + 1) and (tmpPoke.y = tmpPokeContainer.y) then
    begin
      result := true;
      exit;
    end;
  end;
end;

procedure TFormMain.CheckAllPokeCanDelete;
var
  i: integer;
  Need: boolean;
begin
  PaintBoxMain.Cursor := crHourGlass;
  Application.ProcessMessages;
  Need := false;
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
    //  Sleep(100);
      AutoMovePokeFromArrayToContainer(i);
      Need := true;
    end;
  end;
  if Need then
    CheckAllPokeCanDelete();
  PaintBoxMain.Cursor := crDefault;
end;

procedure TFormMain.CheckGame(tmp: integer);
begin
  if tmp = 0 then
  begin
    GRunning := false;
    MessageBox(Self.Handle, '恭喜，你完成了！', '信息', MB_OK);
    PaintBoxMain.OnPaint(nil);
  end;
end;

procedure TFormMain.DrawArrayArea;
var
  i: integer;
begin
  PaintBoxMain.Canvas.Pen.Color := RGB(0, 127, 0);
  PaintBoxMain.Canvas.Rectangle(ARRAY_STARTX, 1 * ARRAY_MULY + ARRAY_STARTY, ARRAY_STARTX + Self.Width, 52 * ARRAY_MULY + ARRAY_STARTY);
  for i := 1 to 8 do
    DrawArrayNumber(i);
end;

procedure TFormMain.DrawArrayNumber(tmpCol: integer);
var
  i: Integer;
begin
  PaintBoxMain.Canvas.Pen.Color := RGB(0, 127, 0);
  PaintBoxMain.Canvas.Rectangle((tmpCol - 1) * ARRAY_MULX + ARRAY_STARTX, 1 * ARRAY_MULY + ARRAY_STARTY,
                                  (tmpCol - 1) * ARRAY_MULX + ARRAY_STARTX + 71, 52 * ARRAY_MULY + ARRAY_STARTY);
  if GRunning then
  begin
    for i := 1 to GArrayIndex[tmpCol] do
      DrawPoke((tmpCol - 1) * ARRAY_MULX + ARRAY_STARTX, i * ARRAY_MULY + ARRAY_STARTY, GArray[tmpCol][i]);
  end;
end;

procedure TFormMain.DrawContainerArea;
var
  i: integer;
begin
  PaintBoxMain.Canvas.Pen.Color := RGB(0, 213, 0);
  PaintBoxMain.Canvas.Rectangle(PaintBoxMain.Width - 71, 0, PaintBoxMain.Width, 96);
  PaintBoxMain.Canvas.Rectangle(PaintBoxMain.Width - 2 * 71, 0, PaintBoxMain.Width - 71, 96);
  PaintBoxMain.Canvas.Rectangle(PaintBoxMain.Width - 3 * 71, 0, PaintBoxMain.Width - 2 * 71, 96);
  PaintBoxMain.Canvas.Rectangle(PaintBoxMain.Width - 4 * 71, 0, PaintBoxMain.Width - 3 * 71, 96);
  PaintBoxMain.Canvas.Pen.Color := RGB(0, 0, 0);
  PaintBoxMain.Canvas.MoveTo(PaintBoxMain.Width, 0);
  PaintBoxMain.Canvas.LineTo(PaintBoxMain.Width - 4 * 71, 0);
  PaintBoxMain.Canvas.MoveTo(PaintBoxMain.Width, 0);
  PaintBoxMain.Canvas.LineTo(PaintBoxMain.Width, 96);
  PaintBoxMain.Canvas.MoveTo(PaintBoxMain.Width - 71, 0);
  PaintBoxMain.Canvas.LineTo(PaintBoxMain.Width - 71, 96);
  PaintBoxMain.Canvas.MoveTo(PaintBoxMain.Width - 2 * 71, 0);
  PaintBoxMain.Canvas.LineTo(PaintBoxMain.Width - 2 * 71, 96);
  PaintBoxMain.Canvas.MoveTo(PaintBoxMain.Width - 3 * 71, 0);
  PaintBoxMain.Canvas.LineTo(PaintBoxMain.Width - 3 * 71, 96);
  PaintBoxMain.Canvas.MoveTo(PaintBoxMain.Width - 4 * 71, 0);
  PaintBoxMain.Canvas.LineTo(PaintBoxMain.Width - 4 * 71, 96);
  if GRunning then
    for i := 1 to 4 do
      DrawContainerNumber(i);
end;

procedure TFormMain.DrawContainerNumber(tmpNum: integer);
begin
  if (GContainer[tmpNum].x <> 0) or (GContainer[tmpNum].y <> 0) then
  begin
    GBitmap.LoadFromResourceName(hInstance, Format(RESOURCEBITMAP, [GContainer[tmpNum].x, GContainer[tmpNum].y]));
    PaintBoxMain.Canvas.Draw(Self.Width - (5 - tmpNum) * 71 - 6, 0, GBitmap);
  end;
end;

procedure TFormMain.DrawPoke(tmpX, tmpY: integer; tmpPoke: TPoke);
begin
  GBitmap.LoadFromResourceName(hInstance, format(RESOURCEBITMAP, [tmpPoke.x, tmpPoke.y]));
  PaintBoxMain.Canvas.StretchDraw(Rect(tmpX, tmpY, tmpX + POKE_WIDTH, tmpY + POKE_HEIGHT), GBitmap);
end;

procedure TFormMain.DrawTempArea();
var
  i: integer;
begin
  PaintBoxMain.Canvas.Pen.Color := RGB(0, 213, 0);
  PaintBoxMain.Canvas.Rectangle(0, 0, 71, 96);
  PaintBoxMain.Canvas.Rectangle(71, 0, 142, 96);
  PaintBoxMain.Canvas.Rectangle(142, 0, 213, 96);
  PaintBoxMain.Canvas.Rectangle(213, 0, 284, 96);
  PaintBoxMain.Canvas.Pen.Color := RGB(0, 0, 0);
  PaintBoxMain.Canvas.MoveTo(0, 0);
  PaintBoxMain.Canvas.LineTo(0, 96);
  PaintBoxMain.Canvas.MoveTo(0, 0);
  PaintBoxMain.Canvas.LineTo(284, 0);
  PaintBoxMain.Canvas.MoveTo(71, 0);
  PaintBoxMain.Canvas.LineTo(71, 96);
  PaintBoxMain.Canvas.MoveTo(142, 0);
  PaintBoxMain.Canvas.LineTo(142, 96);
  PaintBoxMain.Canvas.MoveTo(213, 0);
  PaintBoxMain.Canvas.LineTo(213, 96);
  if GRunning then
    for i := 1 to 4 do
      DrawTempAreaNumber(i);
end;

procedure TFormMain.DrawTempAreaNumber(tmpNum: Integer);
begin
  if (GTemp[tmpNum].x <> 0) or (GTemp[tmpNum].y <> 0) then
  begin
    GBitmap.LoadFromResourceName(hInstance, Format(RESOURCEBITMAP, [GTemp[tmpNum].x, GTemp[tmpNum].y]));
    PaintBoxMain.Canvas.Draw((tmpNum - 1) * TEMP_MULX, 0, GBitmap);
  end else
  begin
  PaintBoxMain.Canvas.Pen.Color := RGB(0, 213, 0);
  case tmpNum of
  1:
  begin
    PaintBoxMain.Canvas.Rectangle(0, 0, 71, 96);
  end;
  2:
  begin
    PaintBoxMain.Canvas.Rectangle(71, 0, 142, 96);
  end;
  3:
  begin
    PaintBoxMain.Canvas.Rectangle(142, 0, 213, 96);
  end;
  4:
  begin
    PaintBoxMain.Canvas.Rectangle(213, 0, 284, 96);
  end
  else
  ;
  end;
  PaintBoxMain.Canvas.Pen.Color := RGB(0, 0, 0);
  PaintBoxMain.Canvas.MoveTo(0, 0);
  PaintBoxMain.Canvas.LineTo(0, 96);
  PaintBoxMain.Canvas.MoveTo(0, 0);
  PaintBoxMain.Canvas.LineTo(284, 0);
  PaintBoxMain.Canvas.MoveTo(71, 0);
  PaintBoxMain.Canvas.LineTo(71, 96);
  PaintBoxMain.Canvas.MoveTo(142, 0);
  PaintBoxMain.Canvas.LineTo(142, 96);
  PaintBoxMain.Canvas.MoveTo(213, 0);
  PaintBoxMain.Canvas.LineTo(213, 96);
  end;
end;

end.
