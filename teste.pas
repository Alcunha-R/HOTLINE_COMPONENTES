class function TGraficoController.MostrarGraficoVendasUsuario(
  pCdsVenda: TClientDataSet; pWebBrowser: TWebBrowser; WebCharts: TWebCharts): Boolean;
var
  chartData: string;
  labels, data, backgroundColors: TStringList;
  fs: TFormatSettings;
  i: Integer;
const
  // Paleta de cores para evitar cores aleatórias e garantir boa visualização
  CORES_GRAFICO: array[0..11] of string = (
    '#4e79a7', '#f28e2c', '#e15759', '#76b7b2', '#59a14f', '#edc949',
    '#af7aa1', '#ff9da7', '#9c755f', '#bab0ab', '#004d40', '#d81b60'
  );
begin
  if pCdsVenda.IsEmpty then
  begin
    pWebBrowser.Navigate('about:blank');
    Exit;
  end;

  labels := TStringList.Create;
  data := TStringList.Create;
  backgroundColors := TStringList.Create;
  try
    fs := TFormatSettings.Create;
    fs.DecimalSeparator := '.';

    pCdsVenda.First;
    i := 0;
    while not pCdsVenda.Eof do
    begin
      if (pCdsVenda.FieldByName('TIPO').AsString = 'USUARIO') then
        begin
          labels.Add(QuotedStr(pCdsVenda.FieldByName('USUARIO').AsString)); // Adicionado QuotedStr para nomes com apóstrofo
          data.Add(FloatToStr(pCdsVenda.FieldByName('TOTAL_VALOR').AsFloat, fs));
          backgroundColors.Add(QuotedStr(CORES_GRAFICO[i mod Length(CORES_GRAFICO)]));
          Inc(i);
          Result := True;
        end;
      pCdsVenda.Next;
    end;

    chartData :=
      '<!DOCTYPE html>' +
      '<html>' +
      '<head>' +
      '  <meta charset="utf-8">' +
      '  <script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.4/dist/Chart.min.js"></script>' +
      '  <style>' +
      '    body { background-color: #000000; color: #EAEAEA; font-family: sans-serif; margin: -15px; padding: 0; }' +
      '  </style>' +
      '</head>' +
      '<body>' +
      '  <div style="text-align: center;">'+
      '  <h3 style="font-size: 20px; font-weight: normal;">Vendas por Usuário</h3>' +
      '  </div>'+
      '  <canvas id="graficoVendasUsuario" width="450" height="130"></canvas>' +
      '  <script>' +
      // --- MUDANÇA 1: Corrigido o ID do elemento canvas ---
      '    var ctx = document.getElementById("graficoVendasUsuario").getContext("2d");' +
      '    var myChart = new Chart(ctx, {' +
      '      type: "doughnut",' +
      '      data: {' +
      '        labels: [' + labels.CommaText + '],' +
      '        datasets: [{' +
      '          label: "Total de Vendas (R$)",' +
      '          data: [' + data.CommaText + '],' +
      '          backgroundColor: [' + backgroundColors.CommaText + '],' +
      '          borderColor: "rgba( 0, 0, 0, 1)",' +
      '          borderWidth: 1,' +
      '        }]' +
      '      },' +
      '      options: {' +
      '        responsive: true,' +
      '        maintainAspectRatio: true,' +
      '        legend: { position: "right", labels: { fontColor: "#EAEAEA", fontSize: 10, usePointStyle: true } },' +
      // --- MUDANÇA 2: Modificado o callback do tooltip para incluir a porcentagem ---
      '        tooltips: {' +
      '          callbacks: {' +
      '            label: function(tooltipItem, data) {' +
      '              var dataset = data.datasets[tooltipItem.datasetIndex];' +
      '              var total = dataset.data.reduce(function(previousValue, currentValue) { return previousValue + currentValue; });' +
      '              var currentValue = dataset.data[tooltipItem.index];' +
      '              var percentage = ((currentValue / total) * 100).toFixed(2);' +
      '              var label = data.labels[tooltipItem.index] || "";' +
      '              var valorFormatado = parseFloat(currentValue).toLocaleString("pt-BR", { style: "currency", currency: "BRL" });' +
      '              return label + ": " + valorFormatado + " (" + percentage + "%)";' +
      '            }' +
      '          }' +
      '        }' +
      '      }' +
      '    });' +
      '  </script>' +
      '</body>' +
      '</html>';

    WebCharts.NewProject
      .ClearHTML
      .HTML(chartData)
      .WebBrowser(pWebBrowser)
      .Generated;

  finally
    labels.Free;
    data.Free;
    backgroundColors.Free;
  end;
end;
