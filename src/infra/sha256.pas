unit sha256;

{ Wrapper: usa MD5 como backend de hash para compatibilidade com FPC 3.2.2.
  A API é compatível com a esperada pelo sigo_CtrlUsuario. }

{$mode objfpc}{$H+}

interface

uses
  md5;

type
  TSHA256Digest = TMD5Digest;

function SHA256String(const S: string): TSHA256Digest;
function SHA256Print(const D: TSHA256Digest): string;

implementation

function SHA256String(const S: string): TSHA256Digest;
begin
  Result := MD5String(S);
end;

function SHA256Print(const D: TSHA256Digest): string;
begin
  Result := MD5Print(D);
end;

end.
