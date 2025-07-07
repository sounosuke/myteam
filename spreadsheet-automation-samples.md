# スプレッドシート自動化サンプルコード集

## 共通の自動化タスク：売上データ集計と報告書作成

各技術で同じ機能を実装し、比較できるようにします。

**自動化する内容：**
- 月次売上データの読み込み
- 商品別・地域別の集計
- グラフ作成
- 報告書の自動生成

---

## 1. Google Apps Script（GAS）サンプル

### 基本的な売上データ集計スクリプト

```javascript
/**
 * 月次売上データ自動集計スクリプト
 * 実行方法：Google Apps Script エディタで実行
 */

function monthlyReportAutomation() {
  // スプレッドシートを取得
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  const dataSheet = spreadsheet.getSheetByName('売上データ');
  const reportSheet = spreadsheet.getSheetByName('月次レポート') || 
                     spreadsheet.insertSheet('月次レポート');
  
  // データ読み込み
  const dataRange = dataSheet.getDataRange();
  const data = dataRange.getValues();
  const headers = data[0];
  
  // データ処理
  const salesData = data.slice(1);
  const monthlySummary = {};
  
  // 月別集計
  salesData.forEach(row => {
    const date = new Date(row[0]); // 日付列
    const month = date.getMonth() + 1;
    const amount = row[3]; // 売上金額列
    
    if (!monthlySummary[month]) {
      monthlySummary[month] = 0;
    }
    monthlySummary[month] += amount;
  });
  
  // レポートシートに出力
  reportSheet.clear();
  reportSheet.getRange(1, 1, 1, 2).setValues([['月', '売上金額']]);
  
  let row = 2;
  for (const month in monthlySummary) {
    reportSheet.getRange(row, 1, 1, 2).setValues([
      [month + '月', monthlySummary[month]]
    ]);
    row++;
  }
  
  // グラフ作成
  const chartRange = reportSheet.getRange(1, 1, row - 1, 2);
  const chart = reportSheet.newChart()
    .setChartType(Charts.ChartType.COLUMN)
    .addRange(chartRange)
    .setPosition(1, 4, 0, 0)
    .setOption('title', '月次売上推移')
    .build();
  
  reportSheet.insertChart(chart);
  
  // 完了通知
  console.log('月次レポートが正常に作成されました');
}

/**
 * 定期実行用のトリガー設定
 */
function setupMonthlyTrigger() {
  // 毎月1日午前9時に実行
  ScriptApp.newTrigger('monthlyReportAutomation')
    .timeBased()
    .everyMonths(1)
    .onMonthDay(1)
    .atHour(9)
    .create();
}

/**
 * メール通知機能
 */
function sendReportNotification() {
  const reportUrl = SpreadsheetApp.getActiveSpreadsheet().getUrl();
  const subject = '月次売上レポートが完成しました';
  const body = `月次売上レポートが自動生成されました。\n\n確認はこちら：${reportUrl}`;
  
  GmailApp.sendEmail('manager@example.com', subject, body);
}
```

### 実行手順
1. Google Sheets でスプレッドシートを作成
2. Apps Script エディタを開く
3. 上記コードを貼り付け
4. 実行権限を許可
5. `monthlyReportAutomation()` を実行

---

## 2. Excel VBA サンプル

### 基本的な売上データ集計マクロ

```vba
' 月次売上データ自動集計マクロ
' 実行方法：Alt+F11でVBAエディタを開き、実行

Sub MonthlyReportAutomation()
    Dim ws As Worksheet
    Dim reportWs As Worksheet
    Dim lastRow As Long
    Dim dataRange As Range
    Dim cell As Range
    Dim monthlyData As Object
    Dim month As String
    Dim amount As Double
    Dim chartObj As ChartObject
    
    ' ワークシートを取得/作成
    Set ws = Sheets("売上データ")
    
    ' レポートシートを作成（存在しない場合）
    On Error Resume Next
    Set reportWs = Sheets("月次レポート")
    If reportWs Is Nothing Then
        Set reportWs = Sheets.Add(After:=Sheets(Sheets.Count))
        reportWs.Name = "月次レポート"
    End If
    On Error GoTo 0
    
    ' データ範囲を取得
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row
    Set dataRange = ws.Range("A2:D" & lastRow)
    
    ' 月別集計用辞書を作成
    Set monthlyData = CreateObject("Scripting.Dictionary")
    
    ' データを読み込み、月別に集計
    For Each cell In dataRange.Rows
        month = Format(cell.Cells(1, 1).Value, "mm") & "月"
        amount = cell.Cells(1, 4).Value
        
        If monthlyData.Exists(month) Then
            monthlyData(month) = monthlyData(month) + amount
        Else
            monthlyData.Add month, amount
        End If
    Next cell
    
    ' レポートシートをクリア
    reportWs.Cells.Clear
    
    ' ヘッダーを設定
    reportWs.Range("A1").Value = "月"
    reportWs.Range("B1").Value = "売上金額"
    
    ' 集計結果を出力
    Dim i As Integer
    i = 2
    Dim key As Variant
    For Each key In monthlyData.Keys
        reportWs.Cells(i, 1).Value = key
        reportWs.Cells(i, 2).Value = monthlyData(key)
        i = i + 1
    Next key
    
    ' グラフを作成
    Set chartObj = reportWs.ChartObjects.Add(200, 20, 400, 250)
    With chartObj.Chart
        .SetSourceData reportWs.Range("A1:B" & i - 1)
        .ChartType = xlColumnClustered
        .HasTitle = True
        .ChartTitle.Text = "月次売上推移"
    End With
    
    ' 完了メッセージ
    MsgBox "月次レポートが正常に作成されました", vbInformation
    
    ' レポートシートをアクティブに
    reportWs.Activate
End Sub

' 自動実行用のイベントプロシージャ
Private Sub Workbook_Open()
    ' ワークブック開いた時に確認
    Dim response As Integer
    response = MsgBox("月次レポートを自動生成しますか？", vbYesNo + vbQuestion)
    
    If response = vbYes Then
        Call MonthlyReportAutomation
    End If
End Sub

' データ入力時の自動実行
Private Sub Worksheet_Change(ByVal Target As Range)
    ' 売上データシートでデータが変更された場合
    If Target.Column <= 4 And Target.Row > 1 Then
        Application.EnableEvents = False
        Call MonthlyReportAutomation
        Application.EnableEvents = True
    End If
End Sub
```

### 実行手順
1. Excelファイルを開く
2. Alt+F11でVBAエディタを開く
3. モジュールを追加してコードを貼り付け
4. マクロを実行（Alt+F8）

---

## 3. Python（openpyxl + pandas）サンプル

### 基本的な売上データ集計スクリプト

```python
"""
月次売上データ自動集計スクリプト
実行方法：python monthly_report.py
"""

import pandas as pd
import openpyxl
from openpyxl.chart import BarChart, Reference
from datetime import datetime
import os

def load_sales_data(file_path):
    """売上データを読み込む"""
    try:
        df = pd.read_excel(file_path, sheet_name='売上データ')
        return df
    except FileNotFoundError:
        print(f"ファイルが見つかりません: {file_path}")
        return None
    except Exception as e:
        print(f"データ読み込みエラー: {e}")
        return None

def process_monthly_summary(df):
    """月別集計を実行"""
    # 日付列を datetime に変換
    df['日付'] = pd.to_datetime(df['日付'])
    
    # 月別に集計
    df['月'] = df['日付'].dt.month
    monthly_summary = df.groupby('月')['売上金額'].sum().reset_index()
    monthly_summary['月'] = monthly_summary['月'].astype(str) + '月'
    
    return monthly_summary

def create_excel_report(monthly_summary, output_path):
    """Excelレポートを作成"""
    # 新しいワークブックを作成
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = '月次レポート'
    
    # ヘッダーを設定
    ws['A1'] = '月'
    ws['B1'] = '売上金額'
    
    # データを書き込み
    for idx, row in monthly_summary.iterrows():
        ws[f'A{idx + 2}'] = row['月']
        ws[f'B{idx + 2}'] = row['売上金額']
    
    # グラフを作成
    chart = BarChart()
    chart.title = "月次売上推移"
    chart.y_axis.title = '売上金額'
    chart.x_axis.title = '月'
    
    # データ範囲を設定
    data_range = Reference(ws, min_col=2, min_row=1, max_col=2, max_row=len(monthly_summary) + 1)
    categories = Reference(ws, min_col=1, min_row=2, max_row=len(monthly_summary) + 1)
    
    chart.add_data(data_range, titles_from_data=True)
    chart.set_categories(categories)
    
    # グラフを配置
    ws.add_chart(chart, "D1")
    
    # ファイルを保存
    wb.save(output_path)
    print(f"レポートが作成されました: {output_path}")

def send_notification(report_path):
    """完了通知を送信（メール送信の例）"""
    import smtplib
    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart
    
    # 設定（実際の値に変更してください）
    smtp_server = "smtp.gmail.com"
    smtp_port = 587
    sender_email = "your_email@gmail.com"
    sender_password = "your_password"
    receiver_email = "manager@example.com"
    
    # メール内容
    message = MIMEMultipart()
    message["From"] = sender_email
    message["To"] = receiver_email
    message["Subject"] = "月次売上レポートが完成しました"
    
    body = f"""
    月次売上レポートが自動生成されました。
    
    ファイル: {report_path}
    生成日時: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
    """
    
    message.attach(MIMEText(body, "plain"))
    
    try:
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(sender_email, sender_password)
        text = message.as_string()
        server.sendmail(sender_email, receiver_email, text)
        server.quit()
        print("通知メールを送信しました")
    except Exception as e:
        print(f"メール送信エラー: {e}")

def main():
    """メイン実行関数"""
    # ファイルパスを設定
    input_file = "sales_data.xlsx"
    output_file = f"monthly_report_{datetime.now().strftime('%Y%m%d')}.xlsx"
    
    print("月次売上レポート自動生成を開始します...")
    
    # データ読み込み
    df = load_sales_data(input_file)
    if df is None:
        return
    
    # 月別集計
    monthly_summary = process_monthly_summary(df)
    print(f"集計完了: {len(monthly_summary)}ヶ月分のデータを処理しました")
    
    # Excelレポート作成
    create_excel_report(monthly_summary, output_file)
    
    # 通知送信
    send_notification(output_file)
    
    print("処理が完了しました")

if __name__ == "__main__":
    main()
```

### 必要なライブラリのインストール

```bash
pip install pandas openpyxl matplotlib
```

### 実行手順
1. Pythonをインストール
2. 必要なライブラリをインストール
3. スクリプトを保存（monthly_report.py）
4. コマンドラインで実行：`python monthly_report.py`

---

## 4. ローコード（Power Automate）サンプル

### フロー設定例

```yaml
# Power Automate フロー設定
name: "月次売上レポート自動生成"
trigger:
  type: "Recurrence"
  frequency: "Month"
  interval: 1
  startTime: "2025-01-01T09:00:00Z"

actions:
  1. "Excel_Online_Get_Tables":
     parameters:
       location: "SharePoint"
       document_library: "Documents"
       file: "sales_data.xlsx"
       table: "Table1"
  
  2. "Data_Operation_Create_HTML_Table":
     parameters:
       from: "@outputs('Excel_Online_Get_Tables')?['body/value']"
       columns: ["月", "売上金額"]
  
  3. "Excel_Online_Create_Worksheet":
     parameters:
       location: "SharePoint"
       document_library: "Documents"
       file: "monthly_report.xlsx"
       name: "月次レポート"
  
  4. "Excel_Online_Add_Row":
     parameters:
       location: "SharePoint"
       document_library: "Documents"
       file: "monthly_report.xlsx"
       table: "ReportTable"
       row: "@body('Data_Operation_Create_HTML_Table')"
  
  5. "Office_365_Outlook_Send_Email":
     parameters:
       to: "manager@example.com"
       subject: "月次売上レポートが完成しました"
       body: "月次売上レポートが自動生成されました。SharePointでご確認ください。"
```

### 設定手順
1. Power Automate にアクセス
2. 新しいフローを作成
3. 上記設定を参考にフローを構築
4. 実行とテストを行う

---

## 5. 実装時の注意点

### 共通事項
- **データ形式の統一**: 日付、数値形式を統一
- **エラーハンドリング**: 例外処理を必ず実装
- **バックアップ**: 元データのバックアップを取る
- **テスト**: 小さなデータでまず動作確認

### セキュリティ
- **認証情報**: パスワードなどをコードに直接記述しない
- **アクセス権限**: 必要最小限の権限で実行
- **データ保護**: 機密データの取り扱いに注意

### 保守性
- **コメント**: 処理内容を明確に記述
- **モジュール化**: 機能を分割して再利用可能にする
- **ログ**: 実行状況を記録する