unit sigo_ModelBase;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  TsigoModelBase = class
  protected
    FID: Integer;
    FCriadoEm: TDateTime;
    FAtualizado: TDateTime;
  public
    constructor Create;
    property ID: Integer read FID write FID;
    property CriadoEm: TDateTime read FCriadoEm write FCriadoEm;
    property Atualizado: TDateTime read FAtualizado write FAtualizado;
  end;

implementation

constructor TsigoModelBase.Create;
begin
  inherited Create;
  FID := 0;
  FCriadoEm := Now;
  FAtualizado := Now;
end;

end.
