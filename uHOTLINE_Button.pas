unit uHOTLINE_Button;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Graphics, Winapi.Messages;

type
  HOTLINE_Button = class(TButton)
  private
    { Private declarations }
    FColor: TColor;
    procedure SetFontColor(const Value: TColor);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
    property FontColor: TColor read FColor write SetFontColor default clBlack;
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
  FColor := clBlack; // Default color
  Self.Font.Color := FColor;
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
