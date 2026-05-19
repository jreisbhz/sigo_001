unit sigo_ConsultaCEP;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, sqldb, sigo_DBConnection;

type
  TsigoCEP = record
    Logradouro: string;
    Bairro: string;
    Cidade: string;
    UF: string;
  end;

  TsigoConsultaCEP = class
  private
    FDB: TsigoDBConnection;
    procedure SalvarNoCache(const ACEP: string; const ACEP_Data: TsigoCEP);
    function BuscarNoCache(const ACEP: string; out ACEP_Data: TsigoCEP): Boolean;
  public
    constructor Create;
    function Buscar(const ACEP: string; out ACEP_Data: TsigoCEP): Boolean;
  end;

implementation

constructor TsigoConsultaCEP.Create;
begin
  inherited Create;
  FDB := TsigoDBConnection.Instancia;
end;

procedure TsigoConsultaCEP.SalvarNoCache(const ACEP: string; const ACEP_Data: TsigoCEP);
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  LSQL := 'INSERT OR REPLACE INTO cep_cache (cep, logradouro, bairro, cidade, uf) ' +
          'VALUES (:CEP, :LOGRADOURO, :BAIRRO, :CIDADE, :UF)';
  LQuery := FDB.NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('CEP').AsString := ACEP;
    LQuery.ParamByName('LOGRADOURO').AsString := ACEP_Data.Logradouro;
    LQuery.ParamByName('BAIRRO').AsString := ACEP_Data.Bairro;
    LQuery.ParamByName('CIDADE').AsString := ACEP_Data.Cidade;
    LQuery.ParamByName('UF').AsString := ACEP_Data.UF;
    LQuery.ExecSQL;
    FDB.Commit;
  finally
    LQuery.Free;
  end;
end;

function TsigoConsultaCEP.BuscarNoCache(const ACEP: string; out ACEP_Data: TsigoCEP): Boolean;
var
  LSQL: string;
  LQuery: TSQLQuery;
begin
  Result := False;
  LSQL := 'SELECT logradouro, bairro, cidade, uf FROM cep_cache WHERE cep = :CEP';
  LQuery := FDB.NovaQuery;
  try
    LQuery.SQL.Text := LSQL;
    LQuery.ParamByName('CEP').AsString := ACEP;
    LQuery.Open;
    if not LQuery.EOF then
    begin
      ACEP_Data.Logradouro := LQuery.FieldByName('logradouro').AsString;
      ACEP_Data.Bairro := LQuery.FieldByName('bairro').AsString;
      ACEP_Data.Cidade := LQuery.FieldByName('cidade').AsString;
      ACEP_Data.UF := LQuery.FieldByName('uf').AsString;
      Result := True;
    end;
  finally
    LQuery.Free;
  end;
end;

function TsigoConsultaCEP.Buscar(const ACEP: string; out ACEP_Data: TsigoCEP): Boolean;
begin
  Result := BuscarNoCache(ACEP, ACEP_Data);
  if not Result then
  begin
    FillChar(ACEP_Data, SizeOf(TsigoCEP), 0);
    ACEP_Data.Logradouro := '';
    ACEP_Data.Bairro := '';
    ACEP_Data.Cidade := '';
    ACEP_Data.UF := '';
  end;
end;

end.
