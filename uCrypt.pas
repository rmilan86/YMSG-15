(************************************************************)
(* Yahoo! Messenger Protocol                                *)
(* by Robert Milan (02/23/08)                               *)
(************************************************************)
(* This code is provided "as is" without express or         *)
(* implied warranty of any kind. Use it at your own risk.   *)
(************************************************************)
unit uCrypt;

interface

uses
  Windows, SysUtils, uWinCrypto;

  function MD5(Value : String; ctType : DWORD) : String;
  function ToY64(s : String) : String;

const
  { MD5 Digest output type }
  ctMD5Hash   = $00000000;   // Outputs md5 as hex
  ctMD5String = $00000001;   // Outputs md5 as ascii

implementation


function MD5(Value : String; ctType : DWORD) : String;
var
  hCryptProvider : HCRYPTPROV;

  hHash          : HCRYPTHASH;
  bHash          : Array [0..$7f] of Byte;
  dwHashLen      : DWORD;

  pbContent      : PByte;
  n              : Integer;
begin
  dwHashLen := 16;
  pbContent := Pointer(PChar(Value));

  Result := '';
  if (CryptAcquireContext(@hCryptProvider, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT or CRYPT_MACHINE_KEYSET) = true) then
  begin
    if (CryptCreateHash(hCryptProvider, CALG_MD5, 0, 0, @hHash) = true) then
    begin
      if (CryptHashData(hHash, pbContent, Length(Value), 0) = true) then
      begin
        if (CryptGetHashParam(hHash, HP_HASHVAL, @bHash[0], @dwHashLen, 0) = true) then
        begin

          if (ctType = ctMD5Hash) then
          begin
            for n := 0 to dwHashLen - 1 do
            begin
              Result := Result + Uppercase(Format('%.2x', [bHash[n]]));
            end;
          end else
          begin
            for n := 0 to dwHashLen - 1 do
            begin
              Result := Result + Chr(bHash[n]);
            end;
          end;
        end;
      end;

      CryptDestroyHash(hHash);
    end;

    CryptReleaseContext(hCryptProvider, 0);
  end;
end;

function ToY64(s : String) : String;
const
   Base64_Table : shortstring = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._';
var
  NewLength: Integer;
begin
  NewLength := ((2 + Length(s)) div 3) * 4;
  SetLength( Result, NewLength);

  asm
    Push  ESI
    Push  EDI
    Push  EBX

    Lea   EBX, Base64_Table
    Inc   EBX                // Move past String Size (ShortString)

    Mov   EDI, Result
    Mov   EDI, [EDI]
    Mov   ESI, s
    Mov   EDX, [ESI-4]        //Length of Input String

@WriteFirst2:

    CMP EDX, 0
    JLE @Done

    MOV AL, [ESI]
    SHR AL, 2
    XLAT

    MOV [EDI], AL
    INC EDI
    MOV AL, [ESI + 1]
    MOV AH, [ESI]
    SHR AX, 4
    AND AL, 63
    XLAT

    MOV [EDI], AL
    INC EDI
    CMP EDX, 1
    JNE @Write3

    MOV AL, 45                        // Add --
    MOV [EDI], AL
    INC EDI

    MOV [EDI], AL
    INC EDI
    JMP @Done

@Write3:
    MOV AL, [ESI + 2]
    MOV AH, [ESI + 1]
    SHR AX, 6
    AND AL, 63
    XLAT

    MOV [EDI], AL
    INC EDI
    CMP EDX, 2
    JNE @Write4

    MOV AL, 45                        // Add -
    MOV [EDI], AL
    INC EDI
    JMP @Done

@Write4:
    MOV AL, [ESI + 2]
    AND AL, 63
    XLAT

    MOV [EDI], AL
    INC EDI
    ADD ESI, 3
    SUB EDX, 3
    JMP @WriteFirst2

@done:
    Pop EBX
    Pop EDI
    Pop ESI
  end;
end;

end.
