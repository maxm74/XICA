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
  XICA, XICA_PaperSizes,
  ImgList {$ifndef fpc}, ImageList, NumberBox{$endif};

resourcestring
  rsApplyChanges = 'Apply Changes to Item %s of %s';
  rsExcCannotGetSourceItem = 'Cannot Get Source Item %d';
  rsExcCannotGetCapabilities = 'Cannot Get Capabilities for Source Item %d';
  rsErrorSelecting = 'Error Selecting Item %s of %s'#13#10'Try to Select another Source Item';
  rsErrorSelectingInt = 'Error Selecting Item [%d] of %s'#13#10'%s'#13#10'Try to Select another Source Item';

type
  { TXICASettingsSource }
  TXICASettingsSource = class(TForm)
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
    ImgListSource: TImageList;
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
    lvSourceItems: TListView;
    PageSourceTypes: TPageControl;
    Panel1: TPanel;
    panelCenter: TPanel;
    panelButtons: TPanel;
    btBrightness0: TSpeedButton;
    btBrightnessD: TSpeedButton;
    rbFrontBack: TRadioButton;
    rbFrontOnly: TRadioButton;
    rbBackOnly: TRadioButton;
    tbSource_Scanner: TTabSheet;
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
    procedure lvSourceItemsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure trBrightnessChange(Sender: TObject);
    procedure trContrastChange(Sender: TObject);
    procedure trHAlignChange(Sender: TObject);
    procedure trResolutionChange(Sender: TObject);
  private
    XICASource: TXICADevice;
    XICAPaperMaxWidth,
    XICAPaperMaxHeight,
    XICASelectedItemIndex: Integer;
    XICACaps: TArrayXICAParamsCapabilities;
    XICAParams: TArrayXICAParams;
    curCap: TXICAParamsCapabilities;
    curParams: TXICAParams;
    initItemValues: TInitialItemValues;

    OnInitDefaultValues: TInitDefaultValuesEvent;

    procedure SelectCurrentItem(AIndex: Integer);
    procedure StoreCurrentItemParams;

  public
     class function Execute(AXICASource: TXICADevice;
                            var ASelectedItemIndex: Integer;
                            { #todo -oMaxM : Possibly Filters for which Items Kinds to Show? How manage AParams without Indexes? }
                            AInitItemValues: TInitialItemValues;
                            var AParams: TArrayXICAParams;
                            AOnInitDefaultValues: TInitDefaultValuesEvent=nil): Boolean; deprecated 'use TXICADevice.SettingsDeviceDialog intestead';
  end;

var
  XICASettingsSource: TXICASettingsSource=nil;

implementation

{$ifdef fpc}
  {$R *.lfm}
{$else}
  {$R *.dfm}
{$endif}

uses XICADef, XICA_UI_Common;

function XICASettingsSource_Execute(AXICASource: TXICADevice; var ASelectedItemIndex: Integer;
                                   AInitItemValues: TInitialItemValues; var AParams: TArrayXICAParams;
                                   AOnInitDefaultValues: TInitDefaultValuesEvent): Boolean;
var
  i,
  itemCount,
  lenAParams: Integer;
  curListItem: TListItem;
  curItem: PXICAItem;

begin
  Result:= False;
  if (AXICASource = nil) then exit;

  if (XICASettingsSource=nil)
  then XICASettingsSource :=TXICASettingsSource.Create(nil);

  if (XICASettingsSource <> nil) then
  with XICASettingsSource do
  try
    XICASource:= AXICASource;
    itemCount:= XICASource.ItemCount;
    initItemValues:= AInitItemValues;
    OnInitDefaultValues:= AOnInitDefaultValues;

    //Do A Copy of Params Array so if the user cancels the Dialog we don't modify the starting array
    XICAParams:= Copy(AParams);

    //If XICASource Item Count is greater then our Array enlarge it
    lenAParams:= Length(AParams);
    if (lenAParams < itemCount)
    then SetLength(XICAParams, itemCount);

    SetLength(XICACaps, itemCount);

    //Get Capabilities and Fill ListView of Source Items
    lvSourceItems.Clear;
    for i:=0 to itemCount-1 do
    begin
      //Get Item[i] Default Values
      XICASource.SelectedItemIndex:= i;
      curItem:= XICASource.Items[i];

      if (curItem = nil)
      then raise Exception.Create(Format(rsExcCannotGetSourceItem, [i]));

      if not(XICASource.GetParamsCapabilities(XICACaps[i]))
      then raise Exception.Create(Format(rsExcCannotGetCapabilities, [i]));

      Case initItemValues of
      initDefault:  if (curItem^.ItemCategory = wicFEEDER)
                    then XICAParams[i]:= XICACopyDefaultValues(XICACaps[i], waHCenter)
                    else XICAParams[i]:= XICACopyDefaultValues(XICACaps[i]);
      initParams : if (i >= lenAParams) then //if is a new Item then Assign Default Values
                   begin
                     if (curItem^.ItemCategory = wicFEEDER)
                     then XICAParams[i]:= XICACopyDefaultValues(XICACaps[i], waHCenter)
                     else XICAParams[i]:= XICACopyDefaultValues(XICACaps[i]);
                   end;
      initCurrent: if (curItem^.ItemCategory = wicFEEDER)
                   then XICAParams[i]:= XICACopyCurrentValues(XICACaps[i], waHCenter)
                   else XICAParams[i]:= XICACopyCurrentValues(XICACaps[i]);
      end;

      curListItem:= lvSourceItems.Items.Add;
      curListItem.Caption :=XICASource.Items[i]^.Name;
      curListItem.Data:= Pointer(i);

      Case curItem^.ItemCategory of
      wicFLATBED: curListItem.ImageIndex:= 1;
      wicFEEDER,
      wicFEEDER_FRONT,
      wicFEEDER_BACK:  curListItem.ImageIndex:= 2;
      wicFILM:  curListItem.ImageIndex:= 3;
      wicROOT,
      wicFOLDER:  curListItem.ImageIndex:= 5;
      wicBARCODE_READER: curListItem.ImageIndex:= 6;
      else  curListItem.ImageIndex:= 0;
      end;
    end;

    try
      //Select the Initial Item to ASelectedItemIndex
      if (ASelectedItemIndex < 0)
      then XICASelectedItemIndex:= 0
      else XICASelectedItemIndex:= ASelectedItemIndex;
      try
         XICASource.SelectedItemIndex:= XICASelectedItemIndex;
      except
         XICASource.SelectedItemIndex:= 0;
      end;
      XICASelectedItemIndex:= XICASource.SelectedItemIndex;

      PageSourceTypes.Enabled:= (XICASource.SelectedItemIntf <> nil);
      if (PageSourceTypes.Enabled)
      then SelectCurrentItem(XICASelectedItemIndex)
      else MessageDlg(Format(rsErrorSelecting, [XICASource.Items[XICASelectedItemIndex]^.Name, XICASource.Name]),
                      mtError, [mbOk], 0);
    except
       on E: Exception do
       MessageDlg(Format(rsErrorSelectingInt, [XICASelectedItemIndex, XICASource.Name, E.Message]),
                  mtError, [mbOk], 0);
    end;
    //cbSourceItem.ItemIndex:= XICASelectedItemIndex;
    lvSourceItems.ItemIndex:= XICASelectedItemIndex;
    SelectCurrentItem(XICASelectedItemIndex);

    Caption:= Caption+' : '+XICASource.Manufacturer+' '+XICASource.Name;

    Result := (ShowModal=mrOk);

    if Result then
    begin
      ASelectedItemIndex:= XICASelectedItemIndex;

      StoreCurrentItemParams;

      //Do A Copy of XICAParams to AParams Array and stretch it if needed
      if (Length(AParams) < Length(XICAParams)) then SetLength(AParams, Length(XICAParams));
      //Move(XICAParams, AParams, Length(AParams));
      //AParams:= Copy(XICAParams);
      for i:=0 to Length(AParams)-1 do AParams[i]:= XICAParams[i];
    end;

  finally
    XICAParams:= nil;
    XICACaps:= nil;
    XICASettingsSource.Free; XICASettingsSource:= nil;
  end;
end;

{ TXICASettingsSource }

procedure TXICASettingsSource.trBrightnessChange(Sender: TObject);
begin
  edBrightness.Value:=trBrightness.Position;
end;

procedure TXICASettingsSource.edBrightnessChange(Sender: TObject);
begin
  trBrightness.Position:=edBrightness.Value;
end;

procedure TXICASettingsSource.cbUseNativeUIChange(Sender: TObject);
begin
  PageSourceTypes.Enabled:= not(cbUseNativeUI.Checked);
end;

procedure TXICASettingsSource.bt0Click(Sender: TObject);
begin
  Case (TSpeedButton(Sender).Tag) of
  1: edBrightness.Value:= 0;
  2: edContrast.Value:= 0;
  end;
end;

procedure TXICASettingsSource.btDClick(Sender: TObject);
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

procedure TXICASettingsSource.btPaperOrientationClick(Sender: TObject);
begin
  if btPaperOrientation.Down
  then begin btPaperOrientation.ImageIndex:= 1; btPaperOrientation.Hint:= rsLandscape; end
  else begin btPaperOrientation.ImageIndex:= 0; btPaperOrientation.Hint:= rsPortrait; end;
end;

procedure TXICASettingsSource.cbBackFirstClick(Sender: TObject);
begin
  if rbFrontBack.Enabled
  then if cbBackFirst.Checked
       then rbFrontBack.Checked:= True;
end;

procedure TXICASettingsSource.cbPaperTypeChange(Sender: TObject);
var
   selPaperSize: TXICAPaperType;

begin
  selPaperSize:= TXICAPaperType(PtrUInt(cbPaperType.Items.Objects[cbPaperType.ItemIndex]));
  Case selPaperSize of
    wptMAX, wptAUTO: begin
       gbPaperAlign.Enabled:= False;
       btPaperOrientation.Enabled:= False;
       gbPaperSize.Visible:= True;
       gbPaperSize.Enabled:= False;
       edPaperW.Value:= edPaperW.MaxValue;
       edPaperH.Value:= edPaperW.MaxValue;
    end;
    wptCUSTOM: begin
       gbPaperAlign.Enabled:= True;
       btPaperOrientation.Enabled:= True;
       gbPaperSize.Visible:= True;
       edPaperW.Visible:= True;
       edPaperH.Visible:= True;
       gbPaperSize.Enabled:= True;

       if XICASettings_Unit_cm
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

       if XICASettings_Unit_cm
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

procedure TXICASettingsSource.edContrastChange(Sender: TObject);
begin
  trContrast.Position:=edContrast.Value;
end;

procedure TXICASettingsSource.edResolutionChange(Sender: TObject);
begin
  trResolution.Position:= edResolution.Value;
end;

procedure TXICASettingsSource.lvSourceItemsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected and (Item.Index <> XICASelectedItemIndex) then
  Case MessageDlg(Format(rsApplyChanges, [XICASource.Items[XICASelectedItemIndex]^.Name, XICASource.Name]),
                  mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
    mrYes: begin
            StoreCurrentItemParams;
            SelectCurrentItem(lvSourceItems.ItemIndex);
    end;
    mrNo: SelectCurrentItem(lvSourceItems.ItemIndex);
  end;
end;

procedure TXICASettingsSource.trContrastChange(Sender: TObject);
begin
  edContrast.Value:=trContrast.Position;
end;

procedure TXICASettingsSource.trHAlignChange(Sender: TObject);
begin
  {$ifdef fpc}
  imgAlign.ImageIndex:= (trVAlign.Position*3)+trHAlign.Position;
  {$else}
  imgListAlign.GetIcon((trVAlign.Position*3)+trHAlign.Position, imgAlign.Picture.Icon);
  {$endif}
end;

procedure TXICASettingsSource.trResolutionChange(Sender: TObject);
begin
  edResolution.Value:=trResolution.Position;
end;

procedure TXICASettingsSource.SelectCurrentItem(AIndex: Integer);
var
   AParams: TXICAParams;
   ACap: TXICAParamsCapabilities;
   capRet: Boolean;
   paperI: TXICAPaperType;
   dataI: TXICADataType;
   i, cbSelected: Integer;
   curItem: PXICAItem;

begin
  AParams:= XICAParams[AIndex];
  ACap:= XICACaps[AIndex];
  curItem:= XICASource.Items[AIndex];

  if (curItem <> nil) then
  with ACap do
  begin
    cbUseNativeUI.Checked:= AParams.NativeUI;
    PageSourceTypes.Enabled:= not(cbUseNativeUI.Checked) and (curItem^.ItemCategory <> wicAUTO);

    //Fill List of Papers
    cbPaperType.Clear;
    cbSelected :=0;
    cbPaperType.Items.AddObject(rsFullsize, TObject(PtrUInt(wptMAX)));
    for paperI in PaperTypeSet do
    begin
      if (paperI <> wptMAX) then
      begin
        cbPaperType.Items.AddObject(PaperTypeNameAndSize(XICASettings_Unit_cm, paperI),
                                    TObject(PtrUInt(paperI)));

        if (paperI = AParams.PaperType) then cbSelected :=cbPaperType.Items.Count-1;
      end;
    end;
    cbPaperType.ItemIndex:=cbSelected;

    //Set Landscape/Portrait Button
    btPaperOrientation.Down:= (AParams.Rotation in [wrLandscape, wrRot270]);
    if btPaperOrientation.Down
    then begin btPaperOrientation.ImageIndex:= 1; btPaperOrientation.Hint:= rsLandscape; end
    else begin btPaperOrientation.ImageIndex:= 0; btPaperOrientation.Hint:= rsPortrait; end;

    //Paper Align
    trHAlign.Position:= Integer(AParams.HAlign);
    trVAlign.Position:= Integer(AParams.VAlign);
    trHAlignChange(nil);

    //Set Max,Current Values for Custom Paper Size
    if XICASettings_Unit_cm
    then begin
           edPaperW.MaxValue:= PaperSizeMaxWidth*2.54;
           edPaperH.MaxValue:= PaperSizeMaxHeight*2.54;
         end
    else begin
           edPaperW.MaxValue:= PaperSizeMaxWidth;
           edPaperH.MaxValue:= PaperSizeMaxHeight;
         end;

    if (curItem^.ItemCategory = wicFEEDER) then
    begin
      { #todo 5 -oMaxM : Must be tested in a Duplex Scanner }
      gbFeeder.Visible:= True;
      (*
      if (wdhAdvanced_Duplex in DocHandlingSet)
      then begin
             //XICA 2 Item structure
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
      rbFrontOnly.Enabled:= (wdhFront_Only in DocHandlingSet);
      rbFrontBack.Enabled:= (wdhAdvanced_Duplex in DocHandlingSet) or (wdhDuplex in DocHandlingSet);
      rbBackOnly.Enabled:= (wdhBack_Only in DocHandlingSet);
      cbBackFirst.Enabled:= (wdhBack_First in DocHandlingSet);
      {$ifdef UI_Tests}
        rbFrontOnly.Enabled:= True;
        rbFrontBack.Enabled:= True;
        rbBackOnly.Enabled:= True;
        cbBackFirst.Enabled:= True;
      {$endif}

      rbFrontOnly.Checked:= (wdhFront_Only in AParams.DocHandling);
      rbFrontBack.Checked:= (wdhDuplex in AParams.DocHandling) or (wdhAdvanced_Duplex in AParams.DocHandling);
      rbBackOnly.Enabled:= (wdhBack_Only in AParams.DocHandling);
      cbBackFirst.Enabled:= (wdhBack_First in AParams.DocHandling);
     end
     else gbFeeder.Visible:= False;

(*
  { #todo 10 -oMaxM : In theory the selectable BitDepths depend on ImageType,
                      but XICA does not give me an error when I set for example
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
    cbSelected :=0;
    for dataI in DataTypeSet do
      Case dataI of
      wdtAUTO: cbDataType.Items.AddObject(rsAutotype, TObject(PtrUInt(wdtAUTO)));
      wdtDITHER, wdtCOLOR_DITHER: begin end;
      else begin
             cbDataType.Items.AddObject(XICADataTypeDescr[dataI], TObject(PtrUInt(dataI)));

             if (dataI = AParams.DataType) then cbSelected :=cbDataType.Items.Count-1;
           end;
      end;
    cbDataType.ItemIndex:=cbSelected;

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
             trResolution.Min:= ResolutionArray[XICA_RANGE_MIN];
             trResolution.Max:= ResolutionArray[XICA_RANGE_MAX];
             trResolution.LineSize:= ResolutionArray[XICA_RANGE_STEP];

             edResolution.MinValue:= ResolutionArray[XICA_RANGE_MIN];
             edResolution.MaxValue:= ResolutionArray[XICA_RANGE_MAX];
             edResolution.Increment:= ResolutionArray[XICA_RANGE_STEP];
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
  XICASelectedItemIndex:= AIndex;
  cbPaperTypeChange(nil);
end;

procedure TXICASettingsSource.StoreCurrentItemParams;
var
   curItem: PXICAItem;

begin
  curItem:= XICASource.Items[XICASelectedItemIndex];

  if (curItem <> nil) then
  with curParams do
  begin
    NativeUI:= cbUseNativeUI.Checked;
    if not(NativeUI) then
    begin
      if (cbPaperType.ItemIndex>-1)
      then PaperType:= TXICAPaperType(PtrUInt(cbPaperType.Items.Objects[cbPaperType.ItemIndex]));

      if (PaperType = wptCUSTOM) then
      begin
        if XICASettings_Unit_cm
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
      then Rotation:= wrLandscape
      else Rotation:= wrPortrait;

      HAlign:= TXICAAlignHorizontal(trHAlign.Position);
      VAlign:= TXICAAlignVertical(trVAlign.Position);

      if (curItem^.ItemCategory = wicFEEDER) then
      begin
        { #todo 5 -oMaxM : Must be tested in a Duplex Scanner }
        DocHandling:= [];
        if rbFrontOnly.Checked
        then DocHandling:= DocHandling+[wdhFront_Only]
        else
        if rbFrontBack.Checked
        then begin
               (*//if is A XICA2 structure add wdhAdvanced_Duplex so TXICADevice.Download understand how to work
               if (wdhAdvanced_Duplex in XICACaps[XICASelectedItemIndex].DocHandlingSet)
               then DocHandling:= DocHandling+[wdhAdvanced_Duplex]
               else*) DocHandling:= DocHandling+[wdhDuplex];

               if cbBackFirst.Checked then DocHandling:= DocHandling+[wdhBack_First];
             end
        else
        if rbBackOnly.Checked
        then DocHandling:= DocHandling+[wdhBack_Only];
      end;

      (*
      if (cbBitDepth.ItemIndex>-1)
      then BitDepth:=PtrUInt(cbBitDepth.Items.Objects[cbBitDepth.ItemIndex]);
      *)

      if (cbDataType.ItemIndex>-1)
      then DataType:=TXICADataType(PtrUInt(cbDataType.Items.Objects[cbDataType.ItemIndex]));

      if XICACaps[XICASelectedItemIndex].ResolutionRange
      then Resolution:= edResolution.Value
      else if (cbResolution.ItemIndex > -1)
           then Resolution:= curCap.ResolutionArray[PtrUInt(cbResolution.Items.Objects[cbResolution.ItemIndex])];

      Contrast:=edContrast.Value;
      Brightness:=edBrightness.Value;
   end;
  end;

  XICAParams[XICASelectedItemIndex]:= curParams;
end;

class function TXICASettingsSource.Execute(AXICASource: TXICADevice;
                                          var ASelectedItemIndex: Integer; AInitItemValues: TInitialItemValues;
                                          var AParams: TArrayXICAParams; AOnInitDefaultValues: TInitDefaultValuesEvent): Boolean;
begin
  Result:= XICASettingsSource_Execute(AXICASource, ASelectedItemIndex, AInitItemValues,
                                     AParams, AOnInitDefaultValues);
end;

initialization
  XICASettingsDialogFunc:= @XICASettingsSource_Execute;


end.

