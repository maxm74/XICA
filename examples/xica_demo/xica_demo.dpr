program xica_demo;

uses
  Vcl.Forms,
  XICA_Demo_Form in 'XICA_Demo_Form.pas' {FormXICADemo};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormXICADemo, FormXICADemo);
  Application.Run;
end.
