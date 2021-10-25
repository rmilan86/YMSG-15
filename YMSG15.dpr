(************************************************************)
(* Yahoo! Messenger Protocol                                *)
(* by Robert Milan (02/23/08)                               *)
(************************************************************)
(* This code is provided "as is" without express or         *)
(* implied warranty of any kind. Use it at your own risk.   *)
(************************************************************)
program YMSG15;

uses
  Forms,
  uMain in 'uMain.pas' {Form1},
  uYMSG in 'uYMSG.pas',
  uWinCrypto in 'uWinCrypto.pas',
  uCrypt in 'uCrypt.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
