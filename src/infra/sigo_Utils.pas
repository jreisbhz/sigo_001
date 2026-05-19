unit sigo_Utils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics;

const
  C_COR_FUNDO_PRINCIPAL   = $002D2D2D;
  C_COR_FUNDO_CONTEUDO    = $00F5F5F5;
  C_COR_FUNDO_RODAPE      = $00404040;
  C_COR_PRIMARIA          = $00C0392B;
  C_COR_PRIMARIA_HOVER    = $00E74C3C;
  C_COR_SECUNDARIA        = $002980B9;
  C_COR_SUCESSO           = $0027AE60;
  C_COR_AVISO             = $00F39C12;
  C_COR_PERIGO            = $00C0392B;
  C_COR_TEXTO_CLARO       = $00FFFFFF;
  C_COR_TEXTO_ESCURO      = $00333333;
  C_COR_TEXTO_DESABILITADO = $00999999;
  C_COR_LINHA_PAR         = $00FFFFFF;
  C_COR_LINHA_IMPAR       = $00F0F4F8;
  C_COR_LINHA_SELECIONADA = $00BDE0F7;
  C_COR_LINHA_CRITICA     = $00FFCCCC;
  C_COR_LINHA_AVISO       = $00FFFACD;
  C_COR_LINHA_OK          = $00CCFFCC;

function FormatMoeda(AValor: Double): string;
function FormatData(AData: TDate): string;
function FormatDataHora(ADateTime: TDateTime): string;
function SomenteNumeros(const AStr: string): string;
function SQLiteParaData(const AStr: string): TDate;
function DataParaSQLite(AData: TDate): string;
function FormatCPF(const ADoc: string): string;
function FormatCNPJ(const ADoc: string): string;
function GerarNumeroOS: string;
function PrimeiraDiaMes(AData: TDate): TDate;
function UltimoDiaMes(AData: TDate): TDate;
function IfThen(ACondition: Boolean; const ATrue: string; const AFalse: string = ''): string; overload;
function IfThen(ACondition: Boolean; ATrue: Integer; AFalse: Integer = 0): Integer; overload;

implementation

uses
  DateUtils;

function FormatMoeda(AValor: Double): string;
begin
  Result := FormatFloat('#,##0.00', AValor);
end;

function FormatData(AData: TDate): string;
begin
  Result := FormatDateTime('dd/mm/yyyy', AData);
end;

function FormatDataHora(ADateTime: TDateTime): string;
begin
  Result := FormatDateTime('dd/mm/yyyy hh:nn', ADateTime);
end;

function SomenteNumeros(const AStr: string): string;
var
  i: Integer;
  c: char;
begin
  Result := '';
  for i := 1 to Length(AStr) do
  begin
    c := AStr[i];
    if (c >= '0') and (c <= '9') then
      Result := Result + c;
  end;
end;

function SQLiteParaData(const AStr: string): TDate;
var
  LData: string;
begin
  if Length(AStr) < 10 then
  begin
    Result := 0;
    Exit;
  end;
  LData := Copy(AStr, 9, 2) + '/' + Copy(AStr, 6, 2) + '/' + Copy(AStr, 1, 4);
  Result := StrToDateDef(LData, 0);
end;

function DataParaSQLite(AData: TDate): string;
begin
  Result := FormatDateTime('yyyy-mm-dd', AData);
end;

function FormatCPF(const ADoc: string): string;
var
  LDoc: string;
begin
  LDoc := SomenteNumeros(ADoc);
  if Length(LDoc) = 11 then
    Result := Copy(LDoc, 1, 3) + '.' + Copy(LDoc, 4, 3) + '.' + Copy(LDoc, 7, 3) + '-' + Copy(LDoc, 10, 2)
  else
    Result := ADoc;
end;

function FormatCNPJ(const ADoc: string): string;
var
  LDoc: string;
begin
  LDoc := SomenteNumeros(ADoc);
  if Length(LDoc) = 14 then
    Result := Copy(LDoc, 1, 2) + '.' + Copy(LDoc, 3, 3) + '.' + Copy(LDoc, 6, 3) + '/' +
              Copy(LDoc, 9, 4) + '-' + Copy(LDoc, 13, 2)
  else
    Result := ADoc;
end;

function GerarNumeroOS: string;
begin
  Result := 'OS-' + FormatDateTime('yyyy', Date) + '-' +
            FormatDateTime('0000', Int(Random(9999) + 1));
end;

function PrimeiraDiaMes(AData: TDate): TDate;
begin
  Result := EncodeDate(YearOf(AData), MonthOf(AData), 1);
end;

function UltimoDiaMes(AData: TDate): TDate;
begin
  Result := EncodeDate(YearOf(AData), MonthOf(AData) + 1, 1) - 1;
end;

function IfThen(ACondition: Boolean; const ATrue: string; const AFalse: string = ''): string;
begin
  if ACondition then Result := ATrue else Result := AFalse;
end;

function IfThen(ACondition: Boolean; ATrue: Integer; AFalse: Integer = 0): Integer;
begin
  if ACondition then Result := ATrue else Result := AFalse;
end;

end.
