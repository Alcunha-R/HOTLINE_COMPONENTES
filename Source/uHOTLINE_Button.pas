unit uHOTLINE_Button;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics, Winapi.Messages, Vcl.Themes;

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
  Self.Font.Color := FColor;
  FButtonColor := clBtnFace; // Default button color
  Self.Color := FButtonColor; // Apply button color
  Self.StyleElements := StyleElements - [seClient, seBorder]; // Prevent theme override
end;

procedure HOTLINE_Button.SetButtonColor(const Value: TColor);
begin
  if FButtonColor <> Value then
  begin
    FButtonColor := Value;
    Self.Color := Value; // Apply button color
    Invalidate; // Ensures the button is repainted
  end;
end;

procedure HOTLINE_Button.SetFontColor(const Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Self.Font.Color := FColor;
    Invalidate; // Ensures the button is repainted
  end;
end;

end.
