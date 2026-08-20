(******************************************************************************
*                XICA (Cross-platform Image Capture Architecture)             *
*                                                                             *
*  FILE: XICA_SelectForm.pas                                                  *
*                                                                             *
*  VERSION:     0.0.1                                                         *
*                                                                             *
*  DESCRIPTION:                                                               *
*    XICA Select Device Dialog.                                               *
*                                                                             *
*******************************************************************************
*                                                                             *
*  (c) 2026 Massimo Magnano                                                   *
*                                                                             *
*  See changelog.txt for Change Log                                           *
*                                                                             *
*******************************************************************************)

unit XICA_SelectForm;

{$H+}

interface

uses
  Types, Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  ComCtrls, StdCtrls, XICA_Classes, XICA;

resourcestring
  rsNoDevicePresent = 'No Device present...';

type
  { TXICASelectForm }
  TXICASelectForm = class(TForm)
    btCancel: TBitBtn;
    btRefresh: TBitBtn;
    btOk: TBitBtn;
    lvSources: TListView;
    Panel1: TPanel;
    panelButtons: TPanel;
    tmSelected: TTimer;
    procedure btRefreshClick(Sender: TObject);
    procedure lvSourcesAdvancedCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure lvSourcesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure tmSelectedTimer(Sender: TObject);
  protected
    ASender: TObject;
    SelectedDevice: TXICA_Device;
    LastSelected: TListItem;

    procedure FillList; overload;
    procedure FillList(ADeviceManager: TXICA_DeviceManager; AShowDeviceManagerName: Boolean); overload;

  end;

var
  XICASelectForm: TXICASelectForm = nil;

implementation

{$ifdef FPC}
  {$R *.lfm}
{$else}
  {$R *.dfm}
{$endif}


function XICASelectForm_Execute(Sender: TObject; var ADevice: TXICA_Device): Boolean;
begin
  Result:= False;
  if (XICASelectForm = nil)
  then XICASelectForm:= TXICASelectForm.Create(nil);

  if (XICASelectForm <> nil) then
  with XICASelectForm do
  try
    SelectedDevice:= ADevice;
    ASender:= Sender;
    FillList;

    Result:= (ShowModal = mrOk);
    if Result then ADevice:= SelectedDevice;

  finally
     XICASelectForm.Free; XICASelectForm:= nil;
  end;
end;

{ TXICASelectForm }

procedure TXICASelectForm.btRefreshClick(Sender: TObject);
begin
  if (ASender is TXICA_Manager)
  then TXICA_Manager(ASender).Refresh(True)
  else
  if (ASender is TXICA_DeviceManager)
  then TXICA_DeviceManager(ASender).Refresh(True);

  FillList;
  lvSources.SetFocus;
end;

procedure TXICASelectForm.lvSourcesAdvancedCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
   LCanvas: TCanvas;
   DisplayText: string;
   Rect: TRect;

begin
  if (Item.Data = nil) then
  begin
    LCanvas := Sender.Canvas;

    LCanvas.Brush.Color := clBtnFace;
    LCanvas.Font.Style:= [fsBold];
    LCanvas.Font.Color := clWindowText;

    Rect:= Item.DisplayRect(drBounds);

    { Fill item background }
    LCanvas.FillRect(Rect);

    { 2. Draw Item Caption (First Column) }
    DisplayText := Item.Caption;
    LCanvas.TextOut(Rect.Left, Rect.Top + 2, DisplayText);

    { 3. Draw a Custom Horizontal Divider Line at the bottom of the row }
    LCanvas.Pen.Color := clBlack; // Choose your divider color
    LCanvas.MoveTo(Rect.Left, Rect.Bottom - 1);
    LCanvas.LineTo(Rect.Right, Rect.Bottom - 1);

    DefaultDraw:= False;
  end;
end;

procedure TXICASelectForm.lvSourcesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    if (Item.Data = nil)
    then begin
           //Item.Selected:= False;

           //it doesn't update graphically I start a timer that will do it
           tmSelected.Enabled:= True;
         end
    else if (Item <> LastSelected) then begin
           LastSelected:= Item;
           SelectedDevice:= TXICA_Device(Item.Data);
         end;
  end;
end;

procedure TXICASelectForm.tmSelectedTimer(Sender: TObject);
begin
  lvSources.Selected:= LastSelected;
  tmSelected.Enabled:= False;
end;

procedure TXICASelectForm.FillList(ADeviceManager: TXICA_DeviceManager; AShowDeviceManagerName: Boolean);
var
   i,
   txtW,
   numDevices,
   selectedIndex: Integer;
   curItem: TListItem;
   curDevice: TXICA_Device;
   txt: String;

begin
  selectedIndex:= -1;
  numDevices:= ADeviceManager.Count;
  if (numDevices > 0)
  then begin
         if AShowDeviceManagerName then
         begin
           curItem:= lvSources.Items.Add;
           curItem.Caption:= ADeviceManager.Name;
           curItem.Data:= nil;
         end;
         for i:=0 to numDevices-1 do
         if ADeviceManager.Get(i, curDevice) then
         begin
           curItem:= lvSources.Items.Add;
           curItem.Data:= curDevice;

           //Add Name Colums and increase width if necessary (since MinWidth/AutoSize don't work as expected)
           txt:= curDevice.Name;
           curItem.Caption:= txt;
           txtW:= lvSources.Canvas.TextWidth(txt)+16;
           if (lvSources.Columns[0].Width < txtW) then lvSources.Columns[0].Width:= txtW;

           //Add Manufacturer
           txt:= curDevice.Manufacturer;
           curItem.SubItems.Add(txt);
           txtW:= lvSources.Canvas.TextWidth(txt)+16;
           if (lvSources.Columns[1].Width < txtW) then lvSources.Columns[1].Width:= txtW;

           //Add Type
           txt:= curDevice.Type_Str;
           curItem.SubItems.Add(txt);
           txtW:= lvSources.Canvas.TextWidth(txt)+16;
           if (lvSources.Columns[2].Width < txtW) then lvSources.Columns[2].Width:= txtW;

           //if is Current Selected Scanner set selectedIndex
           if (SelectedDevice <> nil) and (SelectedDevice.ID = curDevice.ID)
           then selectedIndex:= curItem.Index;
         end;

         //Select Current Scanner
         if (selectedIndex > -1)
         then lvSources.ItemIndex:= selectedIndex
         else lvSources.ItemIndex:= 0;
       end
  else MessageDlg(rsNoDevicePresent, mtError, [mbOk], 0);
end;

procedure TXICASelectForm.FillList;
var
   i: Integer;
   curDeviceManager: TXICA_DeviceManager;

begin
  //selectedIndex:=-1;
  lvSources.Clear;

  if (ASender is TXICA_Manager)
  then begin
        for i:=0 to  TXICA_Manager(ASender).Count-1 do
          if TXICA_Manager(ASender).Get(i, curDeviceManager) and
             curDeviceManager.Enabled then FillList(curDeviceManager, True);
       end
  else
  if (ASender is TXICA_DeviceManager)
  then FillList(TXICA_DeviceManager(ASender), False);
end;

initialization
  XICA_UI_SelectDialogFunc:= @XICASelectForm_Execute;

end.

