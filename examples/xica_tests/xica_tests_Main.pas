unit xica_tests_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls, XICA_Types, XICA_PaperSizes, XICA_Classes, XICA, XICA_WIA,
  XICA_SelectForm;

type

  { TXICATests }

  TXICATests = class(TForm)
    btListDevices: TButton;
    btDownload: TButton;
    btUI_Select: TButton;
    edItem: TSpinEdit;
    edManager: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    edDevice: TSpinEdit;
    panDownload: TPanel;
    edRes: TSpinEdit;
    procedure btDownloadClick(Sender: TObject);
    procedure btListDevicesClick(Sender: TObject);
    procedure btUI_SelectClick(Sender: TObject);
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

   resMin, resMax: Integer;
   pDefWidth, pDefHeight,
   pWidth, pHeight: Single;

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

                if curItem.GetResolutionsLimit(resMin, resMax)
                then Memo1.Lines.Add('                         RES='+IntToStr(resMin)+'..'+IntToStr(resMax))
                else Memo1.Lines.Add('                         RES= <NO VALUES>');

                if curItem.GetPaperSizeMax(pWidth, pHeight)
                then Memo1.Lines.Add('                         PAPER MAX='+PaperSizeToStr(False, pWidth, pHeight))
                else Memo1.Lines.Add('                         PAPER MAX= <NO VALUES>');

                if curItem.GetPaperSize(pWidth, pHeight, pDefWidth, pDefHeight)
                then begin
                       Memo1.Lines.Add('                         PAPER='+PaperSizeToStr(False, pWidth, pHeight));
                       Memo1.Lines.Add('                         PAPER DEFAULT='+PaperSizeToStr(False, pDefWidth, pDefHeight));
                     end
                else Memo1.Lines.Add('                         PAPER= <NO VALUES>');
              end;
            end;
          end;
        end;
      end;
    end;

    panDownload.Enabled:= (mCount>0) and (dCount>0);
    edManager.MaxValue:= mCount-1;
    edDevice.MaxValue:= dCount-1;
  end;
end;

procedure TXICATests.btUI_SelectClick(Sender: TObject);
var
   selDevice: TXICA_Device;

begin
  selDevice:= XICA_Manager.SelectDeviceDialog;
  if (selDevice <> nil) then
  begin
    edManager.Value:= XICA_Manager.Find(selDevice.Owner);
    edDevice.Value:= selDevice.Index;
    edItem.MaxValue:= selDevice.Count-1;       //to-do Get in List may Enumerate Items
    edItem.Value:= selDevice.SelectedIndex;
  end;
end;

procedure TXICATests.btDownloadClick(Sender: TObject);
var
   c: Integer;
   curManager: TXICA_DeviceManager;
   curDevice: TXICA_Device;
   curItem: TXICA_Item;
   curNameM, curNameD, curNameI: String;

begin
   XICA_Manager.Get(edManager.Value, curManager, curNameM);
   if (curManager <> nil) then
   begin
     curManager.Get(edDevice.Value, curDevice, curNameD);
     if (curDevice <> nil) then
     begin
       curDevice.Get(edItem.Value, curItem, curNameI);
       if (curItem <> nil) then
       begin
         Memo1.Lines.Add('Downloading From  '+curNameM+'.'+curNameD+'.'+curNameI);
         curItem.SetResolution(edRes.Value, edRes.Value);
         c:= curItem.Download('', 'xica_test', '.bmp', xifBMP);
         Memo1.Lines.Add('Downloaded '+IntToStr(c)+' Files');
       end;
     end;
   end;
end;

end.

