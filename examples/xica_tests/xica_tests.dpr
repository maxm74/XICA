program xica_tests;

uses
  Vcl.Forms,
  xica_tests_Main in 'xica_tests_Main.pas' {XICATests};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TXICATests, XICATests);
  Application.Run;
end.
