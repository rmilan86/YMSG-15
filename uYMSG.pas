(************************************************************)
(* Yahoo! Messenger Protocol                                *)
(* by Robert Milan (02/23/08)                               *)
(************************************************************)
(* This code is provided "as is" without express or         *)
(* implied warranty of any kind. Use it at your own risk.   *)
(************************************************************)

unit uYMSG;

interface

uses
  Windows, SysUtils, uCrypt;

var
  YahooID : String;
  YahooPW : String;
  YahooSI : String;
  
  function YMSGAuth15(Crumb : String; Challenge : String) : String;
  function CalcSize(Packet : String) : String;
  function CreateHeader(Packet : String) : String;
  function ChallengeRequest() : String;
  function Login(YCookie : String; TCookie : String; Crumb : String; Challenge : String) : String;

implementation

function YMSGAuth15(Crumb : String; Challenge : String) : String;
begin
  Result := ToY64(MD5(Crumb + Challenge, ctMD5String));
end;

function CalcSize(Packet : String) : String;
begin
  Result := Chr(Length(Packet) div 256) + Chr(Length(Packet) mod 256);
end;

function CreateHeader(Packet : String) : String;
begin
  Result := 'YMSG' + #$00#$10#$00#$00 + CalcSize(Packet) + #$00;
end;

function ChallengeRequest() : String;
var
  Packet : String;
begin
  Packet := '1��' + YahooID + '��';
  Result := CreateHeader(Packet) + #$57 + StringOfChar(#$00, 8) + Packet;
end;

function Login(YCookie : String; TCookie : String; Crumb : String; Challenge : String) : String;
var
  Hash   : String;
  Packet : String;
begin
  { Get 307 hash }
  Hash := YMSGAuth15(Crumb, Challenge);

  Packet := '277��' + YCookie + '��278��' + TCookie + '��307��' + Hash + '��0��' + YahooID + '��2��' + YahooID + '��2��1��1��' + YahooID + '��135��8.1.0.209��148��300��';
  Result := CreateHeader(Packet) + #$54 + #$5A#$55#$AA#$55 + YahooSI + Packet;
end;

end.
