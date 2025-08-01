WebCharts1.NewProject
   .Rows._Div.ColSpan(12).Add(
    '<style>' +
    'body { background-color: #121212; color: #FFFFFF; font-family: "Segoe UI", sans-serif; }' +
    '.count { font-weight: bold; }' +
    '.count_top { font-size: 14px; color: #E0E0E0; margin-bottom: 5px; display: block; }' +
    '.count_bottom { font-size: 12px; color: #AAAAAA; margin-top: 5px; display: block; }' +
    '.count_title { font-size: 30px; font-weight: bold; color: #1ABC9C; margin-bottom: 20px; }' +
    '.count_box { padding: 15px; background: #1E1E1E; border-radius: 10px; margin-bottom: 15px; }' +
    '</style>'
  ).&End

  // Título principal
  .Rows._Div.ColSpan(8).Add(
    '<div class="count_title">Curva ABC - Produtos Vendidos</div>'
  ).&End

  // Totais
  ._Div.ColSpan(8).Add(
    '<div class="count_box"><i class="fas fa-chart-line"></i> Valor total das vendas: <strong style="color: #00E5FF;">' +
    FormatFloat('#,###,##0.00', FTotalCurvaABC.cValorTotalCurvaACBProdutos) +
    '</strong></div>'
  ).&End

  ._Div.ColSpan(8).Add(
    '<div class="count_box"><i class="fas fa-dollar-sign"></i> Valor total do lucro bruto: <strong style="color: #00FF94;">' +
    FormatFloat('#,###,##0.00', FTotalCurvaABC.cValorLucroBrutoCurvaACBProdutos) +
    '</strong></div>'
  ).&End

  ._Div.ColSpan(8).Add(
    '<div class="count_box"><i class="fas fa-calendar-alt"></i> Período: <strong style="color: #FFD54F;">' +
    FormatDateTime('dd/mm/yyyy', DTIni.Date) + ' a ' + FormatDateTime('dd/mm/yyyy', DTFin.Date) +
    '</strong></div>'
  ).&End

  .&End

  // Gráfico
  .Charts._ChartType(line).Attributes
    .Name('Meu Grafico de Barras').ColSpan(8)
    .DataSet.textLabel('Curva ABC').DataSet(CDSGraficoCurvaABC)
    .BackgroundColor('0,229,255').BorderColor('0,229,255').Fill(false)
  .&End
  .&End
  .&End

  .Jumpline

  // Cards Curva A/B/C
  .Rows
    ._Div.ColSpan(2).Add(
      '<div class="count_box"><span class="count_top"><i class="fas fa-star"></i> Curva A</span>' +
      '<div class="count" style="font-size: 20px; color: #00E5FF;">' + aValorCurvaA + '</div>' +
      '<span class="count_bottom"><i class="fas fa-percentage"></i> ' + aQtdeCurvaA +
      '% dos produtos, representam ' + aPercentualCurvaA + '% do faturamento</span></div>'
    ).&End

    ._Div.ColSpan(2).Add(
      '<div class="count_box"><span class="count_top"><i class="fas fa-clock"></i> Curva B</span>' +
      '<div class="count" style="font-size: 20px; color: #FFA726;">' + aValorCurvaB + '</div>' +
      '<span class="count_bottom"><i class="fas fa-percentage"></i> ' + aQtdeCurvaB +
      '% dos produtos, representam ' + aPercentualCurvaB + '% do faturamento</span></div>'
    ).&End

    ._Div.ColSpan(2).Add(
      '<div class="count_box"><span class="count_top"><i class="fas fa-box"></i> Curva C</span>' +
      '<div class="count" style="font-size: 20px; color: #EF5350;">' + aValorCurvaC + '</div>' +
      '<span class="count_bottom"><i class="fas fa-percentage"></i> ' + aQtdeCurvaC +
      '% dos produtos, representam ' + aPercentualCurvaC + '% do faturamento</span></div>'
    ).&End
  .&End

  .Jumpline.Jumpline.Jumpline

  .Rows.Title.Configuracoes.H5('Relação dos produtos vendidos, ordenados por maior valor vendido')
  .&End
  .&End
  .&End

  .Table.TableClass.tableSm.tableHover.EndTableClass.DataSet.DataSet(CDSProdutosCurvaABC)
  .&End
  .&End

  .WebBrowser(wbABC).Generated;
