procedure TFPrincipal.AtualizaDados;
var
  CustoBruto, CustoLiquido: Currency;
  CredICMS, CredPIS, CredCOFINS: Currency;
  vIPI, vICMSST, vFrete, CredDesconto, DespesasAcessorias: Currency;
  AliqICMS, AliqPIS, AliqCOFINS: Currency;
  CargaTribTotalPerc: Currency;
  CargaTribTotalV: Currency;
  ValorICMSSaida, ValorPISSaida, ValorCOFINSSaida: Currency;
  MargemVista, MargemPrazo, MargemAtacado: Currency;
  PrecoVista, PrecoPrazo, PrecoAtacado: Currency;
  LucroLiquidoVista, Divisor, LucroBrutoVista: Currency; // <<< ALTERAÇÃO: Adicionada LucroBrutoVista
  ChartData: TGraficoDataArray;
  // <<< ALTERAÇÃO INICIA: Novas variáveis para os campos adicionados
  AliqDespOp, ValorDespOp: Currency;
  AliqIRCSLL, ValorIRCSLL: Currency;
  TotalPercSaida: Currency;
  // <<< ALTERAÇÃO TERMINA
begin
  btEditar.Visible := CDSProdutos.Active and (CDSProdutos.RecordCount > 0);
  if not btEditar.Visible then
  begin
    if Assigned(pnwbFundo) then
      pnwbFundo.Visible := False;
    Exit;
  end;

  // ===== CÁLCULO DO CUSTO DE COMPRA (sem alterações aqui) =====
  CustoBruto := StrToCurrDef(Trim(edCustoBruto.Text), 0);
  CredDesconto := StrToCurrDef(Trim(edDesconto.Text), 0);
  CustoBruto := CustoBruto - CredDesconto;
  CredICMS   := (CustoBruto * StrToCurrDef(Trim(edICMSEntradaP.Text), 0)) / 100;
  CredPIS    := (CustoBruto * StrToCurrDef(Trim(edPISEntradaP.Text), 0)) / 100;
  CredCOFINS := (CustoBruto * StrToCurrDef(Trim(edCOFINSEntradaP.Text), 0)) / 100;
  vIPI := StrToCurrDef(Trim(edIPIP.Text), 0);
  DespesasAcessorias := StrToCurrDef(Trim(edDespesasAcessorias.Text), 0);
  vICMSST := StrToCurrDef(Trim(edICMSST.Text), 0);
  vFrete := StrToCurrDef(Trim(edFrete.Text), 0);
  edICMSEntradaV.Text   := FormatFloat('#,##0.00', CredICMS);
  edPISEntradaV.Text    := FormatFloat('#,##0.00', CredPIS);
  edCOFINSEntradaV.Text := FormatFloat('#,##0.00', CredCOFINS);
  CustoLiquido := (CustoBruto - CredICMS - CredPIS - CredCOFINS) + vIPI + vICMSST + vFrete + DespesasAcessorias;
  lbCustoLiquido.Caption := FormatFloat('"R$" #,##0.00', CustoLiquido);

  // ===== DEFINIÇÕES PARA VENDA =====
  AliqICMS   := StrToCurrDef(Trim(pnICMSSaidaP.Text), 0);
  AliqPIS    := StrToCurrDef(Trim(pnPISSaidaP.Text), 0);
  AliqCOFINS := StrToCurrDef(Trim(edCOFINSSaidaP.Text), 0);

  // <<< ALTERAÇÃO INICIA: Leitura dos novos campos de Despesas e IRPJ/CSLL
  AliqDespOp := StrToCurrDef(Trim(edDOperacionaisP.Text), 0);
  AliqIRCSLL := StrToCurrDef(Trim(edIRCSLLP.Text), 0);
  // <<< ALTERAÇÃO TERMINA

  CargaTribTotalPerc := AliqICMS + AliqPIS + AliqCOFINS;
  lbCargaTributariaP.Caption := FormatFloat('#,##0.00" %"', CargaTribTotalPerc);

  // <<< ALTERAÇÃO INICIA: Somar Despesas Operacionais aos percentuais de saída
  TotalPercSaida := CargaTribTotalPerc + AliqDespOp;
  // <<< ALTERAÇÃO TERMINA

  if tabTpoPreco.ActiveIndex = 0 then
    FCustoBase := CustoLiquido
  else
    FCustoBase := CustoBruto;

  if cbxCargaTributaria.Checked then
    // <<< ALTERAÇÃO INICIA: Usar o novo total de percentuais de saída
    FCargaTribUtilizada := TotalPercSaida
    // <<< ALTERAÇÃO TERMINA
  else
    FCargaTribUtilizada := 0;

  MargemVista   := StrToCurrDef(Trim(edPrecoVendaP.Text), 0);
  MargemPrazo   := StrToCurrDef(Trim(edPrecoPrazoP.Text), 0);
  MargemAtacado := StrToCurrDef(Trim(edPrecoAtacadoP.Text), 0);

  // ===== CÁLCULO DE PREÇO E LUCRO (COM OPÇÃO DE MARKUP OU MARGEM) =====
  begin
    Divisor := 1;

    if (tabMargemLucro.ActiveIndex = 0) then
    begin
      // ===== CÁLCULO USANDO MARGEM DE LUCRO (Lógica igual a da planilha Excel) =====
      // <<< ALTERAÇÃO INICIA: O Divisor agora considera IRPJ/CSLL para "corrigir" a margem de lucro
      var MargemBrutaPerc: Currency;
      if (1 - (AliqIRCSLL / 100)) <= 0 then
        MargemBrutaPerc := 0
      else // Calcula a Margem Bruta necessária para se obter a Margem Líquida desejada
        MargemBrutaPerc := (MargemVista / 100) / (1 - (AliqIRCSLL / 100));

      Divisor := 1 - MargemBrutaPerc - (FCargaTribUtilizada / 100);
      // <<< ALTERAÇÃO TERMINA

      if Divisor <= 0 then
      begin
        PrecoVista   := 0; PrecoPrazo   := 0; PrecoAtacado := 0;
      end
      else
      begin
        PrecoVista   := FCustoBase / Divisor;

        // Repete a lógica para Preço a Prazo
        if (1 - (AliqIRCSLL / 100)) <= 0 then MargemBrutaPerc := 0
        else MargemBrutaPerc := (MargemPrazo / 100) / (1 - (AliqIRCSLL / 100));
        Divisor := 1 - MargemBrutaPerc - (FCargaTribUtilizada / 100);
        if (Divisor > 0) then PrecoPrazo := FCustoBase / Divisor else PrecoPrazo := 0;

        // Repete a lógica para Preço de Atacado
        if (1 - (AliqIRCSLL / 100)) <= 0 then MargemBrutaPerc := 0
        else MargemBrutaPerc := (MargemAtacado / 100) / (1 - (AliqIRCSLL / 100));
        Divisor := 1 - MargemBrutaPerc - (FCargaTribUtilizada / 100);
        if (Divisor > 0) then PrecoAtacado := FCustoBase / Divisor else PrecoAtacado := 0;
      end;
    end
    else
    begin
      // ===== CÁLCULO USANDO MARKUP (MÉTODO ORIGINAL) =====
      Divisor := 1 - (FCargaTribUtilizada / 100);

      if Divisor <= 0 then
      begin
        PrecoVista   := 0; PrecoPrazo   := 0; PrecoAtacado := 0;
      end
      else
      begin
        // <<< ALTERAÇÃO INICIA: O Markup é "corrigido" para considerar o IRPJ/CSLL
        var MarkupBruto: Currency;
        if (1 - (AliqIRCSLL / 100)) <= 0 then
          MarkupBruto := 1
        else
          MarkupBruto := 1 + ((MargemVista / 100) / (1 - (AliqIRCSLL / 100)));
        PrecoVista   := (FCustoBase * MarkupBruto) / Divisor;

        // Repete a lógica para Preço a Prazo
        if (1 - (AliqIRCSLL / 100)) <= 0 then MarkupBruto := 1
        else MarkupBruto := 1 + ((MargemPrazo / 100) / (1 - (AliqIRCSLL / 100)));
        PrecoPrazo   := (FCustoBase * MarkupBruto) / Divisor;

        // Repete a lógica para Preço de Atacado
        if (1 - (AliqIRCSLL / 100)) <= 0 then MarkupBruto := 1
        else MarkupBruto := 1 + ((MargemAtacado / 100) / (1 - (AliqIRCSLL / 100)));
        PrecoAtacado := (FCustoBase * MarkupBruto) / Divisor;
        // <<< ALTERAÇÃO TERMINA
      end;
    end;
  end;

  // <<< ALTERAÇÃO INICIA: Novos cálculos para exibir os valores de Despesas e IRPJ/CSLL
  CargaTribTotalV   := PrecoVista * (CargaTribTotalPerc / 100);
  ValorDespOp        := PrecoVista * (AliqDespOp / 100);

  // Calcula o Lucro Bruto primeiro
  LucroBrutoVista    := PrecoVista - FCustoBase - CargaTribTotalV - ValorDespOp;

  // Calcula o IRPJ/CSLL sobre o Lucro Bruto
  if LucroBrutoVista > 0 then
    ValorIRCSLL := LucroBrutoVista * (AliqIRCSLL / 100)
  else
    ValorIRCSLL := 0;

  // O Lucro Líquido é o que sobra
  LucroLiquidoVista := LucroBrutoVista - ValorIRCSLL;
  // <<< ALTERAÇÃO TERMINA

  ValorICMSSaida   := PrecoVista * (AliqICMS / 100);
  ValorPISSaida    := PrecoVista * (AliqPIS / 100);
  ValorCOFINSSaida := PrecoVista * (AliqCOFINS / 100);


  // ===== EXIBIÇÃO DOS RESULTADOS =====
  if not edPrecoVendaV.Focused then
    edPrecoVendaV.Text    := FormatFloat('#,##0.00', PrecoVista);

  if not edPrecoPrazoV.Focused then
    edPrecoPrazoV.Text    := FormatFloat('#,##0.00', PrecoPrazo);

  if not edPrecoAtacadoV.Focused then
    edPrecoAtacadoV.Text := FormatFloat('#,##0.00', PrecoAtacado);

  edICMSSaidaV.Text   := FormatFloat('#,##0.00', ValorICMSSaida);
  edPISSaidaV.Text    := FormatFloat('#,##0.00', ValorPISSaida);
  edCOFINSSaidaV.Text := FormatFloat('#,##0.00', ValorCOFINSSaida);

  // <<< ALTERAÇÃO INICIA: Exibição dos novos campos
  edDOperacionaisV.Text := FormatFloat('#,##0.00', ValorDespOp);
  edIRCSLLV.Text        := FormatFloat('#,##0.00', ValorIRCSLL);
  // <<< ALTERAÇÃO TERMINA

  lbRLucroLiquido.Caption     := FormatFloat('"R$" #,##0.00', LucroLiquidoVista);
  lbRPrecoVenda.Caption       := FormatFloat('"R$" #,##0.00', PrecoVista);
  lbRCargaTributaria.Caption  := FormatFloat('"R$" #,##0.00', CargaTribTotalV);
  lbRCustoLiquido.Caption     := FormatFloat('"R$" #,##0.00', FCustoBase);

  // ===== MONTAGEM E GERAÇÃO DO GRÁFICO DE CUSTOS =====

  // <<< ALTERAÇÃO INICIA: Gráfico agora inclui as novas despesas
  SetLength(ChartData, 7);

  ChartData[0].Key := 'Custo do Produto';
  ChartData[0].Value := FCustoBase;

  ChartData[1].Key := 'Desp. Operac.';
  ChartData[1].Value := ValorDespOp;

  ChartData[2].Key := 'ICMS Saída';
  ChartData[2].Value := ValorICMSSaida;

  ChartData[3].Key := 'PIS Saída';
  ChartData[3].Value := ValorPISSaida;

  ChartData[4].Key := 'COFINS Saída';
  ChartData[4].Value := ValorCOFINSSaida;

  ChartData[5].Key := 'IRPJ/CSLL';
  ChartData[5].Value := ValorIRCSLL;

  ChartData[6].Key := 'Lucro Líquido';
  ChartData[6].Value := LucroLiquidoVista;

  GerarGraficoCustos(wbGrafico, ChartData, $002A170F, '');
  // <<< ALTERAÇÃO TERMINA
end;
