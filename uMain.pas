(************************************************************)
(* Yahoo! Messenger Protocol                                *)
(* by Robert Milan (02/23/08)                               *)
(************************************************************)
(* This code is provided "as is" without express or         *)
(* implied warranty of any kind. Use it at your own risk.   *)
(************************************************************)
unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, StrUtils, WinInet, uYMSG;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    txtUsername: TEdit;
    txtPassword: TEdit;
    cmdLogin: TButton;
    sckYMSG: TClientSocket;
    Button1: TButton;
    procedure cmdLoginClick(Sender: TObject);
    procedure sckYMSGConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure sckYMSGRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    function  HttpsOpenUrl(URL : String) : String;
    procedure GetCrumbAndCookie(Challenge : String);
    function  ParseString(Expression : String; First : String; Last : String) : String;
  public
    { Public declarations }
  end;

var
  Form1    : TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
   Packet : String;
begin
	Packet := '1¿Ä' + txtUsername.Text + '¿Ä5¿Äthe_programming_guru¿Ä14¿ÄDENIED¿Ä';
   //Packet := '14¿Äthe_programming_guru, It''s me¿Ä65¿ÄFriends¿Ä97¿Ä1¿Ä216¿ÄRobert¿Ä254¿ÄMilan¿Ä1¿Ä' + YahooID + '¿Ä302¿Ä319¿Ä300¿Ä319¿Ä7¿Äthe_programming_guruÄ334¿Ä0¿Ä301¿Ä319¿Ä303¿Ä319¿Ä';
   sckYMSG.Socket.SendText(CreateHeader(Packet) + #$D6 + StringOfChar(#00, 4) + YahooSI + Packet);
end;

procedure TForm1.cmdLoginClick(Sender: TObject);
begin
  if (Length(txtUsername.Text) = 0) then exit;
  if (Length(txtPassword.Text) = 0) then exit;

  if (cmdLogin.Caption = 'Login') then
  begin
    cmdLogin.Caption := 'Logout';

    { Get username and password }
    YahooID := txtUsername.Text;
    YahooPW := txtPassword.Text;

    { Connect to Yahoo! Messenger }
    sckYMSG.Active := False;
    sckYMSG.Host := 'cs111.msg.sp1.yahoo.com';
    sckYMSG.Port := 5050;
    sckYMSG.Active := True;
  end else
  begin
    YahooID := EmptyStr;
    YahooPW := EmptyStr;

    cmdLogin.Caption := 'Login';
    sckYMSG.Active := false;
  end;
end;

procedure TForm1.GetCrumbAndCookie(Challenge: String);
var
  buf     : String;
  YCookie : String;
  TCookie : String;
  Crumb   : String;
begin
  { Retreive the token }
  buf := HttpsOpenUrl('https://login.yahoo.com/config/pwtoken_get?src=ymsgr&ts=&login=' + YahooID + '&passwd=' + YahooPW + '&chal=' + Challenge);

  { Password validation }
  if (Copy(buf, 1, 1) <> '0') then
  begin
    MessageBox(0,
               PChar('The password you entered was invalid!'),
               PCHAR('Error!'),
               MB_ICONERROR);
    sckYMSG.Active := False;
    exit;
  end;

  buf := HttpsOpenUrl('https://login.yahoo.com/config/pwtoken_login?src=ymsgr&ts=&token=' + ParseString(buf, 'ymsgr=', #10));

  { Send login request }
  YCookie := ParseString(buf, 'Y=', #13);
  TCookie := ParseString(buf, 'T=', #13);
  Crumb := ParseString(buf, 'crumb=', #13);

  sckYMSG.Socket.SendText(Login(YCookie, TCookie, Crumb, Challenge));
end;

function TForm1.HttpsOpenUrl(URL: String): String;
var
  { The ammount of bytes to read from the url }
  BytesRead : DWORD;

  { Download 1024 bytes at a time }
  Buffer    : Array [0..1023] of Byte;

  { WinInet }
  hInet     : HINTERNET;

  { We receive data in chunks }
  buf       : string;
begin

  { Initialize result }
  Result := EmptyStr;

  { Create HTTP Agent }
  hInet := InternetOpen(PChar('YMSG15'), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

  { Open url }
  hInet := InternetOpenUrl(hInet, PAnsiChar(URL), nil, 0, 0, 0);

  { Loop until we have received the whole buffer }
  repeat
    { Read data }
    InternetReadFile(hInet, @Buffer, SizeOf(Buffer), BytesRead);

    { Make sure we set the correct size }
    SetLength(buf, BytesRead);

    { Copy the data into buf }
    CopyMemory(Pointer(buf), @Buffer, BytesRead);

    { Add it to the result }
    Result := Result + buf;
  until (BytesRead = 0);

  { Close internet handle }
  InternetCloseHandle(hInet);
end;

function TForm1.ParseString(Expression, First, Last: String): String;
var
  n : Integer;
begin
  Result := '';
  if (Expression = EmptyStr) then exit;
  if (First = EmptyStr) then exit;
  if (Last = EmptyStr) then exit;

  { Make sure values exist }
  if ((Pos(First, Expression) > 0) and (Pos(Last, Expression) > 0)) then
  begin
    { Parse out the index of the first delimiter }
    n := Pos(First, Expression) + Length(First);

    { Make sure no error occurred }
    if (n < 1) then exit;

    Result := Copy(Expression, n, PosEx(Last, Expression, n) - n);
  end;
end;

procedure TForm1.sckYMSGConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Socket.SendText(ChallengeRequest);
end;

procedure TForm1.sckYMSGRead(Sender: TObject; Socket: TCustomWinSocket);
var
  szData : String;
begin
  szData := Socket.ReceiveText;
  case Ord(szData[12]) of
    85: { Buddylist, ignored users, ect... }
      begin
         MessageBox(Application.Handle,
                    PChar('You have successfully logged in!'),
                    PChar(Form1.Caption),
                    MB_ICONINFORMATION);
      end;

    87: { Challenge Request Return }
      begin
         YahooSI := Copy(szData, 17, 4);
         GetCrumbAndCookie(ParseString(szData, '94¿Ä', '¿Ä'));
      end;

    209: { Invalid password, room full, ect... }
      begin


        MessageBox(Application.Handle,
                   PChar('The password you entered is incorrect'),
                   PChar(Form1.Caption),
                   MB_ICONINFORMATION);
      end;
    
  end;
end;

end.
