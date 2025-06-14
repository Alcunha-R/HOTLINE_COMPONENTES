unit uHOTLINE_Button;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics, Winapi.Messages, Vcl.Themes,
  Winapi.Windows, System.Types;

type
  HOTLINE_Button = class(TButton)
  private
    { Private declarations }
    FColor: TColor; // Existing FontColor
    FButtonColor: TColor; // New ButtonColor
    procedure SetFontColor(const Value: TColor);
    procedure SetButtonColor(const Value: TColor); // New Setter
  protected
    { Protected declarations }
    procedure DoCustomPaint(DC: HDC);
    procedure WndProc(var Message: TMessage); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property FontColor: TColor read FColor write SetFontColor default clBlack;
    property ButtonColor: TColor read FButtonColor write SetButtonColor default clBtnFace; // New Property
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('HOTLINE', [HOTLINE_Button]);
end;

{ HOTLINE_Button }

constructor HOTLINE_Button.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColor := clBlack; // Default font color
  FButtonColor := clBtnFace; // Default button color
  // Other initializations if any
end;

procedure HOTLINE_Button.SetButtonColor(const Value: TColor);
begin
  if FButtonColor <> Value then
  begin
    FButtonColor := Value;
    Invalidate; // Ensures the button is repainted
  end;
end;

procedure HOTLINE_Button.SetFontColor(const Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Invalidate; // Ensures the button is repainted
  end;
end;

procedure HOTLINE_Button.DoCustomPaint(DC: HDC);
var
  DrawFlags: Longint;
  TextRect: TRect;
  TempCanvas: TCanvas; // New temporary canvas
begin
  TempCanvas := TCanvas.Create;
  try
    TempCanvas.Handle := DC; // Associate with the provided Device Context

    // 1. Fill background
    TempCanvas.Brush.Color := FButtonColor;
    TempCanvas.FillRect(ClientRect);

    // 2. Set font color (and other font properties if needed)
    TempCanvas.Font.Color := FColor;
    // If you need to match the button's font (name, size, style), copy them:
    // TempCanvas.Font.Name := Self.Font.Name;
    // TempCanvas.Font.Size := Self.Font.Size;
    // TempCanvas.Font.Style := Self.Font.Style;
    // etc. For now, only color is handled by FColor.

    // 3. Prepare to draw text
    TextRect := ClientRect;
    TempCanvas.Brush.Style := bsClear; // Transparent background for text

    DrawFlags := DT_CENTER or DT_VCENTER or DT_SINGLELINE;
    if not Enabled then
    begin
      TempCanvas.Font.Color := clGrayText;
    end;

    // 4. Draw caption
    // DrawText needs an HDC. TempCanvas.Handle is the HDC.
    DrawText(TempCanvas.Handle, PChar(Caption), Length(Caption), TextRect, DrawFlags);

  // 5. Draw a simple border (optional)
  // Canvas.Pen.Color := clBlack; // Or another border color
  // Canvas.Pen.Style := psSolid;
  // Canvas.Brush.Style := bsClear;
  // Canvas.Rectangle(ClientRect);


  // 6. Draw focus rectangle if focused and not a themed button
  //    This part can be complex with TButton if default drawing is bypassed.
  //    For simplicity, we'll omit detailed focus/pressed states for now,
  //    unless they are handled by a potential inherited call.
  //    If we don't call inherited Paint, we lose default button behaviors
  //    like pressed state visuals.
  //    A true themed button look is hard to replicate manually.

  // If we want to try and get some default behavior (like borders, focus),
  // we could call inherited Paint; first, but it might draw over our background.
  // Or, call it last, but it might draw over our text.
  // For now, this is a fully custom paint.

    // 5. Optional border (drawing with TempCanvas)
    // TempCanvas.Pen.Color := clBlack;
    // TempCanvas.Pen.Style := psSolid;
    // TempCanvas.Brush.Style := bsClear;
    // TempCanvas.Rectangle(ClientRect);

  finally
    TempCanvas.Free; // Free the temporary canvas
  end;
end;

procedure HOTLINE_Button.WndProc(var Message: TMessage);
var
  PS: TPaintStruct;
  PaintDC: HDC;
begin
  if Message.Msg = WM_PAINT then
  begin
    if Self.Handle = 0 then // Check if handle is allocated
    begin
      inherited WndProc(Message);
      Exit;
    end;

    PaintDC := BeginPaint(Self.Handle, PS);
    try
      DoCustomPaint(PaintDC); // Call DoCustomPaint with the obtained HDC
    finally
      EndPaint(Self.Handle, PS);
    end;
    // Set Message.Result to 0 to indicate WM_PAINT was handled,
    // though for WM_PAINT, this is often implicit with BeginPaint/EndPaint.
    Message.Result := 0;
  end
  else
    inherited WndProc(Message);
end;

end.
