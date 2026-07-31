unit xica_tests_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  XICA_Types, XICA_Classes, XICA, XICA_WIA;

type

  { TXICATests }

  TXICATests = class(TForm)
    btListDevices: TButton;
    Memo1: TMemo;
    procedure btListDevicesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

var
  XICATests: TXICATests;

implementation

{$R *.lfm}

uses typinfo;

{ TXICATests }

procedure TXICATests.FormCreate(Sender: TObject);
begin
end;

procedure TXICATests.FormDestroy(Sender: TObject);
begin
  if (XICA_Manager <> nil) then XICA_Manager.Free;
end;

procedure TXICATests.btListDevicesClick(Sender: TObject);
var
   mCount,
   dCount,
   iCount: DWord;
   m, d, i: Integer;
   curManager: TXICA_DeviceManager;
   curDevice: TXICA_Device;
   curItem: TXICA_Item;
   curName: String;

begin
  if (XICA_Manager <> nil) then
  begin
    mCount:= XICA_Manager.Count;
    Memo1.Lines.Add('Managers Count='+IntToStr(mCount));
    for m:=0 to mCount-1 do
    begin
      if XICA_Manager.Get(m, curManager, curName) then
      begin
        Memo1.Lines.Add('  ['+IntToStr(m)+'] => '+curName);

        dCount:= curManager.Count;
        Memo1.Lines.Add('  Devices Count='+IntToStr(dCount));
        for d:=0 to dCount-1 do
        begin
          if curManager.Get(d, curDevice, curName) then
          begin
            Memo1.Lines.Add('    ['+IntToStr(d)+'] => ID='+curDevice.ID);
            Memo1.Lines.Add('                         NAME='+curDevice.Name+' '+' MANUFACTURER='+curDevice.Manufacturer);
            Memo1.Lines.Add('                         TYPE='+curDevice.Type_Str);

            iCount:= curDevice.Count;
            Memo1.Lines.Add('                         Items Count='+IntToStr(iCount));
            for i:=0 to iCount-1 do
            begin
              if curDevice.Get(i, curItem, curName) then
              begin
                Memo1.Lines.Add('                         ['+IntToStr(i)+'] => NAME='+curItem.Name);
                (*Memo1.Lines.Add('                         TYPE='+SetToString(TypeInfo(TXICA_ItemTypes), Integer(curItem.Type_))+
                                                         ' CATEGORY='+SetToString(TypeInfo(TXICA_ItemCategory), Integer(curItem.Category)));*)
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

end.

