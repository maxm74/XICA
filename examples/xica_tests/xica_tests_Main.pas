unit xica_tests_Main;

{$ifdef FPC}
  {$mode objfpc}
{$endif}
{$H+}

interface

uses
  Types, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin,
  ExtCtrls,
  MM_OpenArrayList,
  XICA_Types, XICA_PaperSizes, XICA_Classes, XICA,
  //XICA_WIA,
  XICA_Twain,
  XICA_SelectForm, XICA_SettingsForm;

type

  { TXICATests }

  TXICATests = class(TForm)
    btGetBright: TButton;
    btListDevices: TButton;
    btDownload: TButton;
    btGetRes: TButton;
    btSetBright: TButton;
    btUI_Select: TButton;
    btSettings: TButton;
    btSetRes: TButton;
    btManSelect: TButton;
    edItem: TSpinEdit;
    edRes: TSpinEdit;
    edManager: TSpinEdit;
    edBright: TSpinEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Memo1: TMemo;
    edDevice: TSpinEdit;
    panDownload: TPanel;
    procedure btDownloadClick(Sender: TObject);
    procedure btGetBrightClick(Sender: TObject);
    procedure btGetResClick(Sender: TObject);
    procedure btListDevicesClick(Sender: TObject);
    procedure btManSelectClick(Sender: TObject);
    procedure btSetBrightClick(Sender: TObject);
    procedure btSetResClick(Sender: TObject);
    procedure btSettingsClick(Sender: TObject);
    procedure btUI_SelectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    selManager: TXICA_DeviceManager;
    selDevice: TXICA_Device;
    selItem: TXICA_Item;
    curNameM, curNameD, curNameI: TKeyString;

    procedure GetSelectedItem;

  public

  end;

var
  XICATests: TXICATests;

implementation

{$ifdef FPC}
  {$R *.lfm}
{$else}
  {$R *.dfm}
{$endif}

uses typinfo;

{ TXICATests }

procedure TXICATests.FormCreate(Sender: TObject);
begin
   selDevice:= nil;
end;

procedure TXICATests.FormDestroy(Sender: TObject);
begin
  if (XICA_Manager <> nil) then XICA_Manager.Free;
end;

procedure TXICATests.GetSelectedItem;
var
   curManager: TXICA_DeviceManager;
   curDevice: TXICA_Device;
   curItem: TXICA_Item;

begin
  if (selDevice = nil) then
  begin
    XICA_Manager.Get(edManager.Value, curManager, curNameM);
    if (curManager <> nil) then
    begin
      curManager.Get(edDevice.Value, curDevice, curNameD);
      if (curDevice <> nil) then
      begin
        selDevice:= curDevice;
        curDevice.Get(edItem.Value, curItem, curNameI);
      end;
    end;
  end
  else
  begin
    curNameM:= selDevice.Owner.Name;
    curNameD:= selDevice.Name;
    if (selDevice.SelectedIndex >= 0)
    then selDevice.Get(selDevice.SelectedIndex, curItem, curNameI)
    else curItem:= nil;
  end;
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
   curName: TKeyString;

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
                Memo1.Lines.Add(#13#10'                         ['+IntToStr(i)+'] => NAME='+curItem.Name);
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

procedure TXICATests.btManSelectClick(Sender: TObject);
begin
  XICA_Manager.Get(edManager.Value, selManager, curNameM);
  if (selManager <> nil) then
  begin
    selManager.Get(edDevice.Value, selDevice, curNameD);
    if (selDevice <> nil) then selDevice.Get(edItem.Value, selItem, curNameI);
  end;

  panDownload.Enabled:= (selManager <> nil) and (selDevice <> nil) and (selItem <> nil);
end;

procedure TXICATests.btSetBrightClick(Sender: TObject);
var
   v: Integer;

begin
   if (selItem <> nil) then
   begin
     if selItem.SetBrightness(edBright.Value)
     then begin
            if selItem.GetBrightness(v)
            then Memo1.Lines.Add('GetBrightness Value='+IntToStr(v))
            else Memo1.Lines.Add('ERROR: GetBrightness');
          end
     else Memo1.Lines.Add('ERROR: GetBrightness');
   end
   else Memo1.Lines.Add('ERROR: NO Selected Item');
end;

procedure TXICATests.btSetResClick(Sender: TObject);
var
   ResX, ResY: Integer;

begin
  GetSelectedItem;
  if (selItem <> nil) then
  begin
    if selItem.SetResolution(edRes.Value, edRes.Value)
    then begin
           if selItem.GetResolution(ResX, ResY)
           then Memo1.Lines.Add('GetResolution X='+IntToStr(ResX)+' Y='+IntToStr(ResY))
           else Memo1.Lines.Add('ERROR: GetResolution');
         end
    else Memo1.Lines.Add('ERROR: SetResolution');
  end
  else Memo1.Lines.Add('ERROR: NO Selected Item');
end;

procedure TXICATests.btSettingsClick(Sender: TObject);
begin
  if (selDevice = nil) then btUI_SelectClick(Sender);
  if (selDevice <> nil) then
  begin
    if (selDevice.SettingsDeviceDialog(initCurrent)) then
    begin
      edManager.Value:= XICA_Manager.Find(selDevice.Owner);
      edDevice.Value:= selDevice.Index;
      edItem.MaxValue:= selDevice.Count-1;       //to-do Get in List may Enumerate Items
      edItem.Value:= selDevice.SelectedIndex;
    end;
  end;
end;

procedure TXICATests.btUI_SelectClick(Sender: TObject);
begin
  selDevice:= XICA_Manager.SelectDeviceDialog;
  if (selDevice <> nil) then
  begin
    selManager:= selDevice.Owner;

    selItem:= selDevice.Selected;

    edItem.MaxValue:= selDevice.Count-1;       //to-do Get in List may Enumerate Items
    edItem.Value:= selDevice.SelectedIndex;
  end;

  panDownload.Enabled:= (selManager <> nil) and (selDevice <> nil) and (selItem <> nil);
end;

procedure TXICATests.btDownloadClick(Sender: TObject);
var
   c: Integer;

begin
   if (selItem <> nil) then
   begin
     Memo1.Lines.Add('Downloading From  '+curNameM+'.'+curNameD+'.'+curNameI);
     selItem.SetPages(0);
     c:= selItem.Download('', 'xica_tests', '.bmp', xifBMP);
     Memo1.Lines.Add('Downloaded '+IntToStr(c)+' Files');
   end
   else Memo1.Lines.Add('ERROR: Downloading - NO Selected Item');

end;

procedure TXICATests.btGetBrightClick(Sender: TObject);
var
   v, d, min, max, step: Integer;

begin
   if (selItem <> nil) then
   begin
     if selItem.GetBrightness(v, d, min, max, step)
     then begin
            edBright.MinValue:= min;
            edBright.MaxValue:= max;
            edBright.Increment:= step;
            edBright.Value:= v;
            Memo1.Lines.Add('GetBrightness Current='+IntToStr(v)+' Default='+IntToStr(d)+#13#10+
                            ' Min='+IntToStr(min)+' Max='+IntToStr(max)+' Step='+IntToStr(step));
          end
     else Memo1.Lines.Add('ERROR: GetBrightness');
   end
   else Memo1.Lines.Add('ERROR: NO Selected Item');
end;

procedure TXICATests.btGetResClick(Sender: TObject);
var
   ResX, ResY: Integer;

begin
   if (selItem <> nil) then
   begin
     if selItem.GetResolution(ResX, ResY)
     then edRes.Value:= ResX
     else Memo1.Lines.Add('ERROR: GetResolution');
   end
   else Memo1.Lines.Add('ERROR: NO Selected Item');
end;

end.

