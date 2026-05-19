unit sigo_frmConfig;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls, Grids, LCLType,
  sigo_frmBase, sigo_Utils;

type
  { TfrmConfig }
  TfrmConfig = class(TfrmBase)
    pgcConfig: TPageControl;
    tabEmpresa: TTabSheet;
    tabSistema: TTabSheet;
    tabUsuarios: TTabSheet;
    // tabEmpresa
    grpEmpresa: TGroupBox;
    lblRazaoSocial: TLabel;
    edtRazaoSocial: TEdit;
    lblNomeFantasia: TLabel;
    edtNomeFantasia: TEdit;
    lblCNPJConfig: TLabel;
    edtCNPJConfig: TEdit;
    lblIEConfig: TLabel;
    edtIEConfig: TEdit;
    lblEnderecoConfig: TLabel;
    edtEnderecoConfig: TEdit;
    lblTelConfig: TLabel;
    edtTelConfig: TEdit;
    lblEmailConfig: TLabel;
    edtEmailConfig: TEdit;
    lblSiteConfig: TLabel;
    edtSiteConfig: TEdit;
    grpLogo: TGroupBox;
    imgLogo: TImage;
    btnCarregarLogo: TBitBtn;
    // tabSistema
    grpSistema: TGroupBox;
    grdParametros: TStringGrid;
    btnSalvarParam: TBitBtn;
    lblParamDica: TLabel;
    // tabUsuarios
    grpUsuarios: TGroupBox;
    grdUsuarios: TStringGrid;
    pnlBotoesUser: TPanel;
    btnNovoUser: TBitBtn;
    btnEditarUser: TBitBtn;
    btnExcluirUser: TBitBtn;
    btnSalvarConfig: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure btnCarregarLogoClick(Sender: TObject);
    procedure btnSalvarParamClick(Sender: TObject);
    procedure btnNovoUserClick(Sender: TObject);
    procedure btnEditarUserClick(Sender: TObject);
    procedure btnExcluirUserClick(Sender: TObject);
    procedure btnSalvarConfigClick(Sender: TObject);
  protected
    // TfrmBase stubs
    procedure LimparFormulario; override;
    procedure PreencherFormulario(ARow: Integer); override;
    procedure CarregarGrid; override;
    procedure SalvarRegistro; override;
    procedure ExcluirRegistro; override;
    procedure CarregarDadosEmpresa;
    procedure CarregarParametros;
    procedure CarregarUsuarios;
  public
    destructor Destroy; override;
  end;

var
  frmConfig: TfrmConfig;

implementation

{$R *.lfm}

uses
  sqldb, sigo_DBConnection;

{ TfrmConfig }

procedure TfrmConfig.FormCreate(Sender: TObject);
begin
  // Grid de parâmetros do sistema (chave–valor)
  grdParametros.ColCount := 3;
  grdParametros.RowCount := 2;
  grdParametros.FixedRows := 1;
  grdParametros.FixedCols := 0;
  grdParametros.DefaultRowHeight := 22;
  grdParametros.Options := grdParametros.Options + [goEditing];
  grdParametros.Cells[0, 0] := 'Chave';
  grdParametros.Cells[1, 0] := 'Valor';
  grdParametros.Cells[2, 0] := 'Descrição';
  grdParametros.ColWidths[0] := 160;
  grdParametros.ColWidths[1] := 200;
  grdParametros.ColWidths[2] := 250;

  // Grid de usuários
  grdUsuarios.ColCount := 5;
  grdUsuarios.RowCount := 2;
  grdUsuarios.FixedRows := 1;
  grdUsuarios.FixedCols := 0;
  grdUsuarios.DefaultRowHeight := 22;
  grdUsuarios.Options := grdUsuarios.Options - [goEditing];
  grdUsuarios.Cells[0, 0] := 'ID';
  grdUsuarios.Cells[1, 0] := 'Login';
  grdUsuarios.Cells[2, 0] := 'Nome';
  grdUsuarios.Cells[3, 0] := 'Perfil';
  grdUsuarios.Cells[4, 0] := 'Ativo';
  grdUsuarios.ColWidths[0] := 40;
  grdUsuarios.ColWidths[1] := 100;
  grdUsuarios.ColWidths[2] := 200;
  grdUsuarios.ColWidths[3] := 100;
  grdUsuarios.ColWidths[4] := 50;

  btnCarregarLogo.OnClick := @btnCarregarLogoClick;
  btnSalvarParam.OnClick := @btnSalvarParamClick;
  btnNovoUser.OnClick := @btnNovoUserClick;
  btnEditarUser.OnClick := @btnEditarUserClick;
  btnExcluirUser.OnClick := @btnExcluirUserClick;
  btnSalvarConfig.OnClick := @btnSalvarConfigClick;
  inherited FormCreate(Sender);
  CarregarDadosEmpresa;
  CarregarParametros;
  CarregarUsuarios;
end;

destructor TfrmConfig.Destroy;
begin
  inherited Destroy;
end;

procedure TfrmConfig.CarregarDadosEmpresa;
var
  Q: TSQLQuery;
begin
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT chave, valor FROM configuracoes WHERE chave IN (' +
      '''empresa_razao'',''empresa_fantasia'',''empresa_cnpj'',''empresa_ie'',' +
      '''empresa_endereco'',''empresa_tel'',''empresa_email'',''empresa_site'')';
    Q.Open;
    while not Q.EOF do
    begin
      case Q.Fields[0].AsString of
        'empresa_razao':    edtRazaoSocial.Text   := Q.Fields[1].AsString;
        'empresa_fantasia': edtNomeFantasia.Text   := Q.Fields[1].AsString;
        'empresa_cnpj':     edtCNPJConfig.Text     := Q.Fields[1].AsString;
        'empresa_ie':       edtIEConfig.Text       := Q.Fields[1].AsString;
        'empresa_endereco': edtEnderecoConfig.Text := Q.Fields[1].AsString;
        'empresa_tel':      edtTelConfig.Text      := Q.Fields[1].AsString;
        'empresa_email':    edtEmailConfig.Text    := Q.Fields[1].AsString;
        'empresa_site':     edtSiteConfig.Text     := Q.Fields[1].AsString;
      end;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmConfig.CarregarParametros;
var
  Q: TSQLQuery;
  Row: Integer;
begin
  grdParametros.RowCount := 2;
  grdParametros.Rows[1].Clear;
  Row := 1;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT chave, valor, descricao FROM configuracoes ORDER BY chave';
    Q.Open;
    while not Q.EOF do
    begin
      if Row >= grdParametros.RowCount then grdParametros.RowCount := Row + 1;
      grdParametros.Cells[0, Row] := Q.Fields[0].AsString;
      grdParametros.Cells[1, Row] := Q.Fields[1].AsString;
      grdParametros.Cells[2, Row] := Q.Fields[2].AsString;
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmConfig.CarregarUsuarios;
var
  Q: TSQLQuery;
  Row: Integer;
begin
  grdUsuarios.RowCount := 2;
  grdUsuarios.Rows[1].Clear;
  Row := 1;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Q.SQL.Text := 'SELECT id, login, nome, perfil, ativo FROM usuarios ORDER BY nome';
    Q.Open;
    while not Q.EOF do
    begin
      if Row >= grdUsuarios.RowCount then grdUsuarios.RowCount := Row + 1;
      grdUsuarios.Cells[0, Row] := Q.Fields[0].AsString;
      grdUsuarios.Cells[1, Row] := Q.Fields[1].AsString;
      grdUsuarios.Cells[2, Row] := Q.Fields[2].AsString;
      grdUsuarios.Cells[3, Row] := Q.Fields[3].AsString;
      grdUsuarios.Cells[4, Row] := IfThen(Q.Fields[4].AsInteger = 1, 'Sim', 'Não');
      Inc(Row);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmConfig.btnCarregarLogoClick(Sender: TObject);
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(nil);
  try
    Dlg.Filter := 'Imagens (*.png;*.jpg;*.bmp)|*.png;*.jpg;*.bmp';
    Dlg.Title  := 'Selecionar Logo da Empresa';
    if Dlg.Execute then
    begin
      imgLogo.Picture.LoadFromFile(Dlg.FileName);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TfrmConfig.btnSalvarParamClick(Sender: TObject);
var
  I: Integer;
  Q: TSQLQuery;
  Trans: TSQLTransaction;
begin
  Trans := TsigoDBConnection.Instancia.Transacao;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Trans.StartTransaction;
    Q.Transaction := Trans;
    for I := 1 to grdParametros.RowCount - 1 do
    begin
      if Trim(grdParametros.Cells[0, I]) = '' then Continue;
      Q.SQL.Text :=
        'INSERT OR REPLACE INTO configuracoes (chave, valor) VALUES (:K, :V)';
      Q.ParamByName('K').AsString := Trim(grdParametros.Cells[0, I]);
      Q.ParamByName('V').AsString := Trim(grdParametros.Cells[1, I]);
      Q.ExecSQL;
    end;
    try
      Trans.Commit;
      ShowMessage('Parâmetros salvos com sucesso!');
    except
      Trans.Rollback;
      raise;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmConfig.btnSalvarConfigClick(Sender: TObject);
var
  Q: TSQLQuery;
  Trans: TSQLTransaction;

  procedure SalvarChave(const AChave, AValor: string);
  begin
    Q.SQL.Text := 'INSERT OR REPLACE INTO configuracoes (chave, valor) VALUES (:K, :V)';
    Q.ParamByName('K').AsString := AChave;
    Q.ParamByName('V').AsString := AValor;
    Q.ExecSQL;
  end;

begin
  Trans := TsigoDBConnection.Instancia.Transacao;
  Q := TsigoDBConnection.Instancia.NovaQuery;
  try
    Trans.StartTransaction;
    Q.Transaction := Trans;
    SalvarChave('empresa_razao',    Trim(edtRazaoSocial.Text));
    SalvarChave('empresa_fantasia', Trim(edtNomeFantasia.Text));
    SalvarChave('empresa_cnpj',     Trim(edtCNPJConfig.Text));
    SalvarChave('empresa_ie',       Trim(edtIEConfig.Text));
    SalvarChave('empresa_endereco', Trim(edtEnderecoConfig.Text));
    SalvarChave('empresa_tel',      Trim(edtTelConfig.Text));
    SalvarChave('empresa_email',    Trim(edtEmailConfig.Text));
    SalvarChave('empresa_site',     Trim(edtSiteConfig.Text));
    try
      Trans.Commit;
      ShowMessage('Configurações salvas com sucesso!');
    except
      Trans.Rollback;
      raise;
    end;
  finally
    Q.Free;
  end;
end;

procedure TfrmConfig.btnNovoUserClick(Sender: TObject);
begin
  ShowMessage('Use o módulo Usuários (menu Sistema > Usuários) para criar novos usuários.');
end;

procedure TfrmConfig.btnEditarUserClick(Sender: TObject);
begin
  ShowMessage('Use o módulo Usuários (menu Sistema > Usuários) para editar usuários.');
end;

procedure TfrmConfig.btnExcluirUserClick(Sender: TObject);
begin
  ShowMessage('Use o módulo Usuários (menu Sistema > Usuários) para excluir usuários.');
end;

// TfrmBase stubs

procedure TfrmConfig.LimparFormulario;
begin
  // sem uso
end;

procedure TfrmConfig.PreencherFormulario(ARow: Integer);
begin
  // sem uso
end;

procedure TfrmConfig.CarregarGrid;
begin
  CarregarDadosEmpresa;
  CarregarParametros;
  CarregarUsuarios;
end;

procedure TfrmConfig.SalvarRegistro;
begin
  // sem uso
end;

procedure TfrmConfig.ExcluirRegistro;
begin
  // sem uso
end;

end.
