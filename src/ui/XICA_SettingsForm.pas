(******************************************************************************
*                FreePascal \ Delphi XICA Implementation                       *
*                                                                             *
*  FILE: XICA_SettingsForm.pas                                                 *
*                                                                             *
*  VERSION:     1.0.1                                                         *
*                                                                             *
*  DESCRIPTION:                                                               *
*    XICA Property Settings for Device Dialog.                                 *
*                                                                             *
*******************************************************************************
*                                                                             *
*  (c) 2025 Massimo Magnano                                                   *
*                                                                             *
*  See changelog.txt for Change Log                                           *
*                                                                             *
*******************************************************************************)

unit XICA_SettingsForm;

{$H+}

//{$define UI_Tests}

interface

uses
  DelphiCompatibility, Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, ComCtrls, StdCtrls, Spin,
  XICA_Types, XICA_Classes, XICA_PaperSizes,
  ImgList {$ifndef fpc}, ImageList, NumberBox{$endif};

resourcestring
  rsApplyChanges = 'Apply Changes to Item %s of %s';
  rsErrorSelecting = 'Error Selecting Item %s of %s'#13#10'Try to Select another Device Item';
  rsErrorSelectingInt = 'Error Selecting Item [%d] of %s'#13#10'%s'#13#10'Try to Select another Device Item';

type
  { TXICASettingsDevice }
  TXICASettingsDevice = class(TForm)
    btContrast0: TSpeedButton;
    btContrastD: TSpeedButton;
    btResolutionD: TSpeedButton;
    btCancel: TBitBtn;
    btPaperOrientation: TSpeedButton;
    btRefreshUndo: TBitBtn;
    btOk: TBitBtn;
    btRefreshCurrent: TBitBtn;
    btRefreshDefault: TBitBtn;
    cbBitDepth: TComboBox;
    cbPaperType: TComboBox;
    cbDataType: TComboBox;
    cbResolution: TComboBox;
    cbBackFirst: TCheckBox;
    cbUseNativeUI: TCheckBox;
    edBrightness: TSpinEdit;
    {$ifdef fpc}
    edPaperH: TFloatSpinEdit;
    edPaperW: TFloatSpinEdit;
    {$else}
    edPaperH: TNumberBox;
    edPaperW: TNumberBox;
    {$endif}
    edResolution: TSpinEdit;
    edContrast: TSpinEdit;
    gbPaperAlign: TGroupBox;
    gbPaperSize: TGroupBox;
    gbFeeder: TGroupBox;
    ImgListDevice: TImageList;
    imgAlign: TImage;
    imgListAlign: TImageList;
    imgList: TImageList;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    LabelPaperSize: TLabel;
    lvDeviceItems: TListView;
    PageDeviceTypes: TPageControl;
    Panel1: TPanel;
    panelCenter: TPanel;
    panelButtons: TPanel;
    btBrightness0: TSpeedButton;
    btBrightnessD: TSpeedButton;
    rbFrontBack: TRadioButton;
    rbFrontOnly: TRadioButton;
    rbBackOnly: TRadioButton;
    tbDevice_Scanner: TTabSheet;
    trBrightness: TTrackBar;
    trHAlign: TTrackBar;
    trResolution: TTrackBar;
    trContrast: TTrackBar;
    trVAlign: TTrackBar;
    procedure bt0Click(Sender: TObject);
    procedure btDClick(Sender: TObject);
    procedure btPaperOrientationClick(Sender: TObject);
    procedure cbBackFirstClick(Sender: TObject);
    procedure cbPaperTypeChange(Sender: TObject);
    procedure cbUseNativeUIChange(Sender: TObject);
    procedure edBrightnessChange(Sender: TObject);
    procedure edContrastChange(Sender: TObject);
    procedure edResolutionChange(Sender: TObject);
    procedure lvDeviceItemsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure trBrightnessChange(Sender: TObject);
    procedure trContrastChange(Sender: TObject);
    procedure trHAlignChange(Sender: TObject);
    procedure trResolutionChange(Sender: TObject);
  private
    XICADevice: TXICA_Device;
    XICAPaperMaxWidth,
    XICAPaperMaxHeight,
    XICASelectedItemIndex: Integer;
    XICAParams: TArrayXICA_Params;
    curItem: TXICA_Item;
    curCap: TXICA_Capabilities;
    curParams: TXICA_Params;
    initItemValues: TInitialItemValues;

    OnInitDefaultValues: TInitDefaultValuesEvent;

    procedure SelectCurrentItem(AIndex: Integer);
    procedure StoreCurrentItemParams;

  public
  end;

var
  XICASettingsDevice: TXICASettingsDevice=nil;

implementation

{$ifdef fpc}
  {$R *.lfm}
{$else}
  {$R *.dfm}
{$endif}

function XICASettingsSource_Execute(ADevice: TXICA_Device;
                                    AInitItemValues: TInitialItemValues;
                                    AOnInitDefaultValues: TInitDefaultValuesEvent=nil): Boolean;
var
  i, itemCount: Integer;
  curListItem: TListItem;

begin
  Result:= False;
  if (ADevice = nil) then exit;

  if (XICASettingsDevice = nil) then XICASettingsDevice:= TXICASettingsDevice.Create(nil);

  if (XICASettingsDevice <> nil) then
  with XICASettingsDevice do
  try
    XICADevice:= ADevice;
    itemCount:= XICADevice.Count;
    initItemValues:= AInitItemValues;
    OnInitDefaultValues:= AOnInitDefaultValues;

    //Do A Copy of Params Array so if the user cancels the Dialog we don't modify the Device Items Params
    if (CopyParams(ADevice, XICAParams, initItemValues) > 0) then
    begin
      //Get Capabilities and Fill ListView of Device Items
      lvDeviceItems.Clear;
      for i:=0 to itemCount-1 do
      if (XICADevice.Get(i, curItem)) then
      begin
        curListItem:= lvDeviceItems.Items.Add;
        curListItem.Caption:= curItem.Name;
        curListItem.Data:= Pointer(i);

        Case curItem.Category of
        xicFLATBED: curListItem.ImageIndex:= 1;
        xicFEEDER,
        xicFEEDER_FRONT,
        xicFEEDER_BACK:  curListItem.ImageIndex:= 2;
        xicFILM:  curListItem.ImageIndex:= 3;
        xicROOT,
        xicFOLDER:  curListItem.ImageIndex:= 5;
        xicBARCODE_READER: curListItem.ImageIndex:= 6;
        else  curListItem.ImageIndex:= 0;
        end;
      end
      else raise Exception.Create(Format(rsExcCannotGetItem, [i]));

      //Select the Initial Item to 0 if not Selected
      if (XICADevice.SelectedIndex < 0)
      then XICASelectedItemIndex:= 0
      else XICASelectedItemIndex:= XICADevice.SelectedIndex;

      lvDeviceItems.ItemIndex:= XICASelectedItemIndex;
      PageDeviceTypes.Enabled:= True;

      SelectCurrentItem(XICASelectedItemIndex);

      Caption:= Caption+' : '+XICADevice.Manufacturer+' '+XICADevice.Name;

      Result:= (ShowModal = mrOk);

      if Result then
      begin
        StoreCurrentItemParams;

        //Copy XICAParams to Device Items Params
        CopyParams(XICAParams, XICADevice);

        //Set Selected Item to Current Selected
        XICADevice.SelectedIndex:= XICASelectedItemIndex;
      end;
    end;

  finally
    FreeParams(XICAParams);
    XICASettingsDevice.Free; XICASettingsDevice:= nil;
  end;
end;

{ TXICASettingsDevice }

procedure TXICASettingsDevice.trBrightnessChange(Sender: TObject);
begin
  edBrightness.Value:=trBrightness.Position;
end;

procedure TXICASettingsDevice.edBrightnessChange(Sender: TObject);
begin
  trBrightness.Position:=edBrightness.Value;
end;

procedure TXICASettingsDevice.cbUseNativeUIChange(Sender: TObject);
begin
  PageDeviceTypes.Enabled:= not(cbUseNativeUI.Checked);
end;

procedure TXICASettingsDevice.bt0Click(Sender: TObject);
begin
  Case (TSpeedButton(Sender).Tag) of
  1: edBrightness.Value:= 0;
  2: edContrast.Value:= 0;
  end;
end;

procedure TXICASettingsDevice.btDClick(Sender: TObject);
var
   i: Integer;

begin
  with curCap do
  Case (TSpeedButton(Sender).Tag) of
  1: edBrightness.Value:= BrightnessDefault;
  2: edContrast.Value:= ContrastDefault;
  3: begin
       if ResolutionRange
       then edResolution.Value:= ResolutionDefault
       else begin
             i:= cbResolution.Items.IndexOf(IntToStr(ResolutionDefault));
             if (i > -1) then cbResolution.ItemIndex:= i;
            end;
     end;
  end;
end;

procedure TXICASettingsDevice.btPaperOrientationClick(Sender: TObject);
begin
  if btPaperOrientation.Down
  then begin btPaperOrientation.ImageIndex:= 1; btPaperOrientation.Hint:= rsLandscape; end
  else begin btPaperOrientation.ImageIndex:= 0; btPaperOrientation.Hint:= rsPortrait; end;
end;

procedure TXICASettingsDevice.cbBackFirstClick(Sender: TObject);
begin
  if rbFrontBack.Enabled
  then if cbBackFirst.Checked
       then rbFrontBack.Checked:= True;
end;

procedure TXICASettingsDevice.cbPaperTypeChange(Sender: TObject);
var
   selPaperSize: TXICA_PaperType;

begin
  selPaperSize:= TXICA_PaperType(PtrUInt(cbPaperType.Items.Objects[cbPaperType.ItemIndex]));
  Case selPaperSize of
    ptMAX, ptAUTO: begin
       gbPaperAlign.Enabled:= False;
       btPaperOrientation.Enabled:= False;
       gbPaperSize.Visible:= True;
       gbPaperSize.Enabled:= False;
       edPaperW.Value:= edPaperW.MaxValue;
       edPaperH.Value:= edPaperW.MaxValue;
    end;
    ptCUSTOM: begin
       gbPaperAlign.Enabled:= True;
       btPaperOrientation.Enabled:= True;
       gbPaperSize.Visible:= True;
       edPaperW.Visible:= True;
       edPaperH.Visible:= True;
       gbPaperSize.Enabled:= True;

       if XICA_UI_Settings_Unit_cm
       then begin
              edPaperW.Value:= XICAParams[XICASelectedItemIndex].PaperW*2.54;
              edPaperH.Value:= XICAParams[XICASelectedItemIndex].PaperH*2.54;
            end
       else begin
              edPaperW.Value:= XICAParams[XICASelectedItemIndex].PaperW;
              edPaperH.Value:= XICAParams[XICASelectedItemIndex].PaperH;
            end;
    end;
    else begin
       gbPaperAlign.Enabled:= True;
       btPaperOrientation.Enabled:= True;
       gbPaperSize.Visible:= False;

       if XICA_UI_Settings_Unit_cm
       then begin
              edPaperW.Value:= XICAParams[XICASelectedItemIndex].PaperW*2.54;
              edPaperH.Value:= XICAParams[XICASelectedItemIndex].PaperH*2.54;
            end
       else begin
              edPaperW.Value:= XICAParams[XICASelectedItemIndex].PaperW;
              edPaperH.Value:= XICAParams[XICASelectedItemIndex].PaperH;
            end;
    end;
  end;
end;

procedure TXICASettingsDevice.edContrastChange(Sender: TObject);
begin
  trContrast.Position:=edContrast.Value;
end;

procedure TXICASettingsDevice.edResolutionChange(Sender: TObject);
begin
  trResolution.Position:= edResolution.Value;
end;

procedure TXICASettingsDevice.lvDeviceItemsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected and (Item.Index <> XICASelectedItemIndex) then
(*  Case MessageDlg(Format(rsApplyChanges, [XICADevice.Items[XICASelectedItemIndex]^.Name, XICADevice.Name]),
                  mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
    mrYes:*) begin
            StoreCurrentItemParams;
            SelectCurrentItem(lvDeviceItems.ItemIndex);
    end;
(*    mrNo: SelectCurrentItem(lvDeviceItems.ItemIndex);
  end; *)
end;

procedure TXICASettingsDevice.trContrastChange(Sender: TObject);
begin
  edContrast.Value:=trContrast.Position;
end;

procedure TXICASettingsDevice.trHAlignChange(Sender: TObject);
begin
  {$ifdef fpc}
  imgAlign.ImageIndex:= (trVAlign.Position*3)+trHAlign.Position;
  {$else}
  imgListAlign.GetIcon((trVAlign.Position*3)+trHAlign.Position, imgAlign.Picture.Icon);
  {$endif}
end;

procedure TXICASettingsDevice.trResolutionChange(Sender: TObject);
begin
  edResolution.Value:=trResolution.Position;
end;

procedure TXICASettingsDevice.SelectCurrentItem(AIndex: Integer);
var
   AParams: TXICA_Params;
   ACap: TXICA_Capabilities;
   AItem: TXICA_Item;
   capRet: Boolean;
   paperI: TXICA_PaperType;
   dataI: TXICA_DataType;
   i, cbSelected: Integer;

begin
  if XICADevice.Get(AIndex, AItem) then
  begin
    AParams:= XICAParams[AIndex];
    ACap:= AItem.Capabilities;
    with ACap do
    begin
      cbUseNativeUI.Checked:= AParams.NativeUI;
      PageDeviceTypes.Enabled:= not(cbUseNativeUI.Checked) and (AItem.Category <> xicAUTO);

      //Fill List of Papers
      cbPaperType.Clear;
      cbSelected:= 0;
      cbPaperType.Items.AddObject(rsFullsize, TObject(PtrUInt(ptMAX)));
      cbPaperType.Items.AddObject(rsAutosize, TObject(PtrUInt(ptAUTO)));
      cbPaperType.Items.AddObject(rsCustomsize, TObject(PtrUInt(ptCUSTOM)));
      for paperI in PaperTypeSet do
      begin
        if not(paperI in [ptAUTO, ptCUSTOM, ptMAX]) then
        begin
          cbPaperType.Items.AddObject(PaperTypeNameAndSize(XICA_UI_Settings_Unit_cm, paperI),
                                      TObject(PtrUInt(paperI)));

          if (paperI = AParams.PaperType) then cbSelected:= cbPaperType.Items.Count-1;
        end;
      end;
      cbPaperType.ItemIndex:= cbSelected;

      //Set Landscape/Portrait Button
      btPaperOrientation.Down:= (AParams.Rotation in [xrLandscape, xrRot270]);
      if btPaperOrientation.Down
      then begin btPaperOrientation.ImageIndex:= 1; btPaperOrientation.Hint:= rsLandscape; end
      else begin btPaperOrientation.ImageIndex:= 0; btPaperOrientation.Hint:= rsPortrait; end;

      //Paper Align
      trHAlign.Position:= Integer(AParams.HAlign);
      trVAlign.Position:= Integer(AParams.VAlign);
      trHAlignChange(nil);

      //Set Max,Current Values for Custom Paper Size
      if XICA_UI_Settings_Unit_cm
      then begin
             edPaperW.MaxValue:= PaperSizeMaxWidth*2.54;
             edPaperH.MaxValue:= PaperSizeMaxHeight*2.54;
           end
      else begin
             edPaperW.MaxValue:= PaperSizeMaxWidth;
             edPaperH.MaxValue:= PaperSizeMaxHeight;
           end;

      if (AItem.Category = xicFEEDER) then
      begin
        gbFeeder.Visible:= True;
        (*
        if (wdhAdvanced_Duplex in DocHandlingSet)
        then begin
             //WIA 2 Item structure
             rbFrontOnly.Enabled:= True;
             rbFrontBack.Enabled:= True;
             rbBackOnly.Enabled:= True;
             cbBackFirst.Enabled:= True;
           end
        else begin
             rbFrontOnly.Enabled:= (wdhFront_Only in DocHandlingSet);
             rbFrontBack.Enabled:= (wdhDuplex in DocHandlingSet);
             rbBackOnly.Enabled:= (wdhBack_Only in DocHandlingSet);
             cbBackFirst.Enabled:= (wdhBack_First in DocHandlingSet);
           end;
        *)
        rbFrontOnly.Enabled:= (xdhFront_Only in DocHandlingSet);
        rbFrontBack.Enabled:= (xdhDuplex in DocHandlingSet);
        rbBackOnly.Enabled:= (xdhBack_Only in DocHandlingSet);
        cbBackFirst.Enabled:= (xdhBack_First in DocHandlingSet);
        {$ifdef UI_Tests}
        rbFrontOnly.Enabled:= True;
        rbFrontBack.Enabled:= True;
        rbBackOnly.Enabled:= True;
        cbBackFirst.Enabled:= True;
        {$endif}

        rbFrontOnly.Checked:= (xdhFront_Only in AParams.DocHandling);
        rbFrontBack.Checked:= (xdhDuplex in AParams.DocHandling);
        rbBackOnly.Enabled:= (xdhBack_Only in AParams.DocHandling);
        cbBackFirst.Enabled:= (xdhBack_First in AParams.DocHandling);
      end
      else gbFeeder.Visible:= False;

(*
  { #todo 10 -oMaxM : In theory the selectable BitDepths depend on ImageType,
                      but WIA does not give me an error when I set for example
                      "Black and White" and BitDepht to 24 bit but I get a damaged Image.
                      Change automatically from the Form? }

  //Fill List of Image Bit Depth
  cbBitDepth.Clear;
  cbSelected :=0;
  for i:=0 to Length(BitDepthArray)-1 do
  begin
    if (BitDepthArray[i] = 0)
    then cbBitDepth.Items.AddObject('Auto', nil)
    else cbBitDepth.Items.AddObject(IntToStr(BitDepthArray[i])+' Bit', TObject(PtrUInt(BitDepthArray[i])));

    case initItemValues of
    initDefault: begin if (BitDepthArray[i] = BitDepthDefault) then cbSelected :=cbBitDepth.Items.Count-1; end;
    initParams:  begin if (BitDepthArray[i] = AParams.BitDepth) then cbSelected :=cbBitDepth.Items.Count-1; end;
    initCurrent: begin if (BitDepthArray[i] = BitDepthCurrent) then cbSelected :=cbBitDepth.Items.Count-1; end;
    end;
  end;
  cbBitDepth.ItemIndex:=cbSelected;
*)

      //Fill List of Image Data Type
      cbDataType.Clear;
      cbSelected:= 0;
      for dataI in DataTypeSet do
      begin
        cbDataType.Items.AddObject(GeDatatType_Str(dataI), TObject(PtrUInt(dataI)));

        if (dataI = AParams.DataType) then cbSelected:= cbDataType.Items.Count-1;
      end;
      cbDataType.ItemIndex:= cbSelected;

      {$ifdef UI_Tests}
      ResolutionRange:= True;
      {$endif}

      if ResolutionRange
      then begin
             trResolution.Visible:= True; edResolution.Visible:= True;
             cbResolution.Visible:= False;

             //Set Resolution Range Limit
             {$ifdef UI_Tests}
             trResolution.Min:= ResolutionArray[0];
             trResolution.Max:= ResolutionArray[Length(ResolutionArray)-1];
             trResolution.LineSize:= 1;

             edResolution.MinValue:= ResolutionArray[0];
             edResolution.MaxValue:= ResolutionArray[Length(ResolutionArray)-1];
             edResolution.Increment:= 1;
             {$else}
             trResolution.Min:= ResolutionArray[prop_RANGE_MIN];
             trResolution.Max:= ResolutionArray[prop_RANGE_MAX];
             trResolution.LineSize:= ResolutionArray[prop_RANGE_STEP];

             edResolution.MinValue:= ResolutionArray[prop_RANGE_MIN];
             edResolution.MaxValue:= ResolutionArray[prop_RANGE_MAX];
             edResolution.Increment:= ResolutionArray[prop_RANGE_STEP];
             {$endif}

             trResolution.Position:= AParams.Resolution;
             edResolution.Value:= AParams.Resolution;
           end
      else begin
             trResolution.Visible:= False; edResolution.Visible:= False;
             cbResolution.Visible:= True;

             //Fill List of Resolution (Y Resolution=X Resolution)
             cbResolution.Clear;
             cbSelected :=0;
             for i:=0 to Length(ResolutionArray)-1 do
             begin
               cbResolution.Items.AddObject(IntToStr(ResolutionArray[i]), TObject(PtrUInt(i)));

               if (ResolutionArray[i] = AParams.Resolution) then cbSelected :=cbResolution.Items.Count-1;
             end;
             cbResolution.ItemIndex:=cbSelected;
           end;

      //Brightness
      trBrightness.Min:= BrightnessMin;
      trBrightness.Max:= BrightnessMax;
      trBrightness.LineSize:= BrightnessStep;
      trBrightness.Position:= AParams.Brightness;
      edBrightness.MinValue:= BrightnessMin;
      edBrightness.MaxValue:= BrightnessMax;
      edBrightness.Increment:= BrightnessStep;
      edBrightness.Value:= trBrightness.Position;

      //Contrast
      trContrast.Min:= ContrastMin;
      trContrast.Max:= ContrastMax;
      trContrast.LineSize:= ContrastStep;
      trContrast.Position:= AParams.Contrast;
      edContrast.MinValue:= ContrastMin;
      edContrast.MaxValue:= ContrastMax;
      edContrast.Increment:= ContrastStep;
      edContrast.Value:= trContrast.Position;
    end;

    curParams:= AParams;
    curCap:= ACap;
    curItem:= AItem;
    XICASelectedItemIndex:= AIndex;
    cbPaperTypeChange(nil);
  end;
end;

procedure TXICASettingsDevice.StoreCurrentItemParams;
begin
  if (curItem <> nil) then
  with curParams do
  begin
    NativeUI:= cbUseNativeUI.Checked;
    if not(NativeUI) then
    begin
      if (cbPaperType.ItemIndex>-1)
      then PaperType:= TXICA_PaperType(PtrUInt(cbPaperType.Items.Objects[cbPaperType.ItemIndex]));

      if (PaperType = ptCUSTOM) then
      begin
        if XICA_UI_Settings_Unit_cm
        then begin
               PaperW:= edPaperW.Value/2.54;
               PaperH:= edPaperH.Value/2.54;
             end
        else begin
               PaperW:= edPaperW.Value;
               PaperH:= edPaperH.Value;
             end;
      end;

      if btPaperOrientation.Down
      then Rotation:= xrLandscape
      else Rotation:= xrPortrait;

      HAlign:= TXICA_AlignHorizontal(trHAlign.Position);
      VAlign:= TXICA_AlignVertical(trVAlign.Position);

      if (curItem.Category = xicFEEDER) then
      begin
        DocHandling:= [];
        if rbFrontOnly.Checked
        then DocHandling:= DocHandling+[xdhFront_Only]
        else
        if rbFrontBack.Checked
        then begin
               (*//if is A WIA2 structure add wdhAdvanced_Duplex so TXICADevice.Download understand how to work
               if (wdhAdvanced_Duplex in XICACaps[XICASelectedItemIndex].DocHandlingSet)
               then DocHandling:= DocHandling+[wdhAdvanced_Duplex]
               else*) DocHandling:= DocHandling+[xdhDuplex];

               if cbBackFirst.Checked then DocHandling:= DocHandling+[xdhBack_First];
             end
        else
        if rbBackOnly.Checked then DocHandling:= DocHandling+[xdhBack_Only];
      end;

      (*
      if (cbBitDepth.ItemIndex>-1)
      then BitDepth:=PtrUInt(cbBitDepth.Items.Objects[cbBitDepth.ItemIndex]);
      *)

      if (cbDataType.ItemIndex>-1) then DataType:= TXICA_DataType(PtrUInt(cbDataType.Items.Objects[cbDataType.ItemIndex]));

      if curCap.ResolutionRange
      then Resolution:= edResolution.Value
      else if (cbResolution.ItemIndex > -1) then Resolution:= curCap.ResolutionArray[PtrUInt(cbResolution.Items.Objects[cbResolution.ItemIndex])];

      Contrast:= edContrast.Value;
      Brightness:= edBrightness.Value;
   end;
  end;

  //XICAParams[XICASelectedItemIndex]:= curParams;
end;


initialization
  XICA_UI_SettingsDialogFunc:= @XICASettingsSource_Execute;


end.

