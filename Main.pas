unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Buttons;

type
  TfrmMain = class(TForm)
    lvProfileList: TListView;
    SpeedButton1: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses DataModule, Helper_registry;

procedure TfrmMain.SpeedButton1Click(Sender: TObject);
begin
  PopulateProfilesList(lvProfileList);
end;

end.
