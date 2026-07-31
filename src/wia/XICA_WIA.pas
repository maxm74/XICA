(****************************************************************************
*                XICA (Cross-platform Image Capture Architecture)
*
*  FILE: XICA_WIA.pas
*
*  VERSION:     0.0.1
*
*  DESCRIPTION:
*    WIA implementation
*
*****************************************************************************
*
*  (c) 2026 Massimo Magnano
*
*  See changelog.txt for Change Log
*
*****************************************************************************)
unit XICA_WIA;

{$ifdef fpc}
  {$mode delphi}
{$endif}
{$H+}

interface

{$ifdef MSWINDOWS}

uses Windows, Classes, SysUtils,
    {$ifdef fpc}testutils,{$else}DelphiCompatibility,{$endif}
     ComObj, ActiveX, WiaDef, WIA_LH, //Wia_PaperSizes
     XICA_Types, XICA_Classes;

type
  { TXICA_WIADevice }

  TXICA_WiaDevice = class(TXICA_Device)
  protected
    pRootItem,
    pSelectedItem: IWiaItem2;
    pRootProperties,
    pSelectedProperties: IWiaPropertyStorage;


    function GetRootItemIntf: IWiaItem2;
    function GetSelectedItemIntf: IWiaItem2;
    function GetRootPropertiesIntf: IWiaPropertyStorage;
    function GetSelectedPropertiesIntf: IWiaPropertyStorage;

    //Enumerate the avaliable items
    function _EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean; override;

    (*
    //Get Paper Width, Height form the Device (in Inches)
    function _GetPaperSize(out AWidth, AHeight: Single): Boolean; overload; virtual; abstract;
    function _GetPaperSize(out AWidth, AHeight, ADefaultWidth, ADefaultHeight: Single): Boolean; overload; virtual; abstract;

    //Get Max Paper Width, Height form the Device (in Inches)
    function _GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean; virtual; abstract;

    class function SettingsDialogFunc: TXICA_SettingsDialogFunc; virtual; abstract;
  *)
  public
    constructor Create(AOwner: TXICA_DeviceManager; AIndex: Integer; ADeviceID: String);
    destructor Destroy; override;
  end;

  { TXICA_WIAManager }

  (*TOnDeviceTransfer = function (AWiaManager: TWIAManager; AWiaDevice: TWIADevice;
                         lFlags: LONG; pWiaTransferParams: PWiaTransferParams): Boolean of object;*)

  TXICA_WIAManager = class(TXICA_DeviceManager)
  protected
    pDevMgr: WIA_LH.IWiaDevMgr2;
    lres: HResult;

    //Create Main WIA Interface
    function CreateDevManager: IUnknown; virtual;

    //Enumerate the avaliable devices
    function _EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean; override;

    class function SelectDialogFunc: TXICA_SelectDialogFunc; override;

  public
    constructor Create(AEnumAll: Boolean = True);
    destructor Destroy; override;

    class function Name: String; override;
  end;

const
  WiaImageFormatGUID : array [TXICA_ImageFormat] of TGUID = (
    '{b96b3ca9-0728-11d3-9d7b-0000f81ef32e}',
    '{bca48b55-f272-4371-b0f1-4a150d057bb4}',
    '{b96b3caa-0728-11d3-9d7b-0000f81ef32e}',
    '{b96b3cab-0728-11d3-9d7b-0000f81ef32e}',
    '{b96b3cac-0728-11d3-9d7b-0000f81ef32e}',
    '{b96b3cad-0728-11d3-9d7b-0000f81ef32e}',
    '{b96b3cae-0728-11d3-9d7b-0000f81ef32e}',
    '{b96b3caf-0728-11d3-9d7b-0000f81ef32e}',
    '{b96b3cb0-0728-11d3-9d7b-0000f81ef32e}',
    '{b96b3cb1-0728-11d3-9d7b-0000f81ef32e}',
    '{b96b3cb2-0728-11d3-9d7b-0000f81ef32e}',
    '{b96b3cb3-0728-11d3-9d7b-0000f81ef32e}',
    '{b96b3cb4-0728-11d3-9d7b-0000f81ef32e}',
    '{b96b3cb5-0728-11d3-9d7b-0000f81ef32e}',
    '{9821a8ab-3a7e-4215-94e0-d27a460c03b2}',
    '{a6bc85d8-6b3e-40ee-a95c-25d482e41adc}',
    '{344ee2b2-39db-4dde-8173-c4b75f8f1e49}',
    '{43e14614-c80a-4850-baf3-4b152dc8da27}',
    '{6f120719-f1a8-4e07-9ade-9b64c63a3dcc}',
    '{41e8dd92-2f0a-43d4-8636-f1614ba11e46}',
    '{bb8e7e67-283c-4235-9e59-0b9bf94ca687}'
  );

  WiaItemCategoryGUID : array[TXICA_ItemCategory] of TGUID = (
    '',
    '{ff2b77ca-cf84-432b-a735-3a130dde2a88}',
    '{fb607b1f-43f3-488b-855b-fb703ec342a6}',
    '{fe131934-f84c-42ad-8da4-6129cddd7288}',
    '{fcf65be7-3ce3-4473-af85-f5d37d21b68a}',
    '{f193526f-59b8-4a26-9888-e16e4f97ce10}',
    '{c692a446-6f5a-481d-85bb-92e2e86fd30a}',
    '{4823175c-3b28-487b-a7e6-eebc17614fd1}',
    '{61ca74d4-39db-42aa-89b1-8c19c9cd4c23}',
    '{defe5fd8-6c97-4dde-b11e-cb509b270e11}',
    '{fc65016d-9202-43dd-91a7-64c2954cfb8b}',
    '{47102cc3-127f-4771-adfc-991ab8ee1e97}',
    '{36e178a0-473f-494b-af8f-6c3f6d7486fc}',
    '{8faa1a6d-9c8a-42cd-98b3-ee9700cbc74f}',
    '{3b86c1ec-71bc-4645-b4d5-1b19da2be978}'
  );


{$endif}

implementation

{$ifdef MSWINDOWS}

uses (*{$ifdef fpc}FileUtil, {$endif}*) XICA;

var
   WIA_Manager: TXICA_WIAManager = nil;

//============= WIA Functions ==========================

procedure VersionStrToInt(const s: String; var Ver, VerSub: Integer); overload;
var
   pPos, ppPos: Integer;

begin
  Ver:= 0;
  VerSub:= 0;

  try
     pPos:= Pos('.', s);
     if (pPos > 0) then
     begin
       Ver:= StrToInt(Copy(s, 0, pPos-1));
       ppPos:= Pos('.', s, pPos+1);
       if (ppPos > 0)
       then VerSub:= StrToInt(Copy(s, pPos+1, ppPos-1))
       else VerSub:= StrToInt(Copy(s, pPos+1, 255));
     end;
  except

  end;
end;

procedure VersionStrToInt(const s: String; const AWIADevice: TXICA_WiaDevice); overload;
var
   rVer, rVerSub: Integer;

begin
  VersionStrToInt(s, rVer, rVerSub);
  AWIADevice.Version := rVer;
  AWIADevice.VersionSub := rVerSub;
end;

function FullPathToRelativePath(const ABasePath: String; var APath: String): Boolean;
begin
  Result:= (Pos(ABasePath, APath) = 1);
  if Result
  then APath:= '.'+DirectorySeparator+Copy(APath, Length(ABasePath)+1, MaxInt);
end;

function WIAItemTypes(pItemType: LONG): TXICA_ItemTypes;
begin
  Result :=[];

  if (pItemType = WiaItemTypeFree) then Result:= Result+[xitFree]
  else
  begin
    if (pItemType and WiaItemTypeImage <> 0) then Result:= Result+[xitImage];
    if (pItemType and WiaItemTypeFile <> 0) then Result:= Result+[xitFile];
    if (pItemType and WiaItemTypeFolder <> 0) then Result:= Result+[xitFolder];
    if (pItemType and WiaItemTypeRoot <> 0) then Result:= Result+[xitRoot];
    if (pItemType and WiaItemTypeAnalyze <> 0) then Result:= Result+[xitAnalyze];
    if (pItemType and WiaItemTypeAudio <> 0) then Result:= Result+[xitAudio];
    if (pItemType and WiaItemTypeDevice <> 0) then Result:= Result+[xitDevice];
    if (pItemType and WiaItemTypeDeleted <> 0) then Result:= Result+[xitDeleted];
    if (pItemType and WiaItemTypeDisconnected <> 0) then Result:= Result+[xitDisconnected];
    if (pItemType and WiaItemTypeHPanorama <> 0) then Result:= Result+[xitHPanorama];
    if (pItemType and WiaItemTypeVPanorama <> 0) then Result:= Result+[xitVPanorama];
    if (pItemType and WiaItemTypeBurst <> 0) then Result:= Result+[xitBurst];
    if (pItemType and WiaItemTypeStorage <> 0) then Result:= Result+[xitStorage];
    if (pItemType and WiaItemTypeTransfer	<> 0) then Result:= Result+[xitTransfer];
    if (pItemType and WiaItemTypeGenerated <> 0) then Result:= Result+[xitGenerated];
    if (pItemType and WiaItemTypeHasAttachments <> 0) then Result:= Result+[xitHasAttachments];
    if (pItemType and WiaItemTypeVideo <> 0) then Result:= Result+[xitVideo];
    if (pItemType and WiaItemTypeTwainCompatibility <> 0) then Result:= Result+[xitTwainCompatibility];
    if (pItemType and WiaItemTypeRemoved <> 0) then Result:= Result+[xitRemoved];
    if (pItemType and WiaItemTypeDocument	<> 0) then Result:= Result+[xitDocument];
    if (pItemType and WiaItemTypeProgrammableDataSource <> 0) then Result:= Result+[xitProgrammableDataSource];
  end;
end;

function WIAItemCategory(const AGUID: TGUID): TXICA_ItemCategory;
var
   i: TXICA_ItemCategory;

begin
  Result:= xicNULL;

  for i:=Low(TXICA_ItemCategory) to High(TXICA_ItemCategory) do
    if IsEqualGUID(WiaItemCategoryGUID[i], AGUID) then
    begin
      Result:= i;
      break;
    end;
end;

function WIAPropertyFlags(pFlags: ULONG): TXICA_PropertyFlags;
begin
  Result :=[];

  if (pFlags and WIA_PROP_READ <> 0) then Result:= Result+[prop_READ];
  if (pFlags and WIA_PROP_WRITE <> 0) then Result:= Result+[prop_WRITE];
//  if (pFlags and WIA_PROP_SYNC_REQUIRED <> 0) then Result:= Result+[prop_SYNC_REQUIRED];
//  if (pFlags and WIA_PROP_NONE <> 0) then Result:= Result+[prop_NONE];
  if (pFlags and WIA_PROP_RANGE <> 0) then Result:= Result+[prop_RANGE];
  if (pFlags and WIA_PROP_LIST <> 0) then Result:= Result+[prop_LIST];
//  if (pFlags and WIA_PROP_FLAG <> 0) then Result:= Result+[prop_FLAG];
//  if (pFlags and WIA_PROP_CACHEABLE <> 0) then Result:= Result+[prop_CACHEABLE];
end;

function WIADeviceType(const AWIADeviceType: Integer): String;
begin
  if (AWIADeviceType >= Integer(Low(TXICA_DeviceType))) and
     (AWIADeviceType <= Integer(High(TXICA_DeviceType)))
  then Result:= XICA_DeviceType(TXICA_DeviceType(AWIADeviceType))
  else if (AWIADeviceType = StiDeviceTypeStreamingVideo)
       then Result:= 'Streaming Video'
       else Result:= 'Undefined ('+IntToStr(AWIADeviceType)+')';
end;

function WIAImageFormat(const AGUID: TGUID; var Value: TXICA_ImageFormat): Boolean;
var
   i: TXICA_ImageFormat;

begin
  Result:= False;

  for i:=Low(TXICA_ImageFormat) to High(TXICA_ImageFormat) do
    if IsEqualGUID(WiaImageFormatGUID[i], AGUID) then
    begin
      Value:= i;
      Result:= True;
      break;
    end;
end;

function WIADocumentHandling(iDocumentHandling: Integer): TXICA_DocumentHandlings;
begin
  Result :=[];

  if (iDocumentHandling and FEEDER <> 0) then Result:= Result+[xdhFeeder];
  if (iDocumentHandling and FLATBED <> 0) then Result:= Result+[xdhFlatbed];
  if (iDocumentHandling and DUPLEX <> 0) then Result:= Result+[xdhDuplex];
  if (iDocumentHandling and FRONT_FIRST <> 0) then Result:= Result+[xdhFront_First];
  if (iDocumentHandling and BACK_FIRST <> 0) then Result:= Result+[xdhBack_First];
  if (iDocumentHandling and FRONT_ONLY <> 0) then Result:= Result+[xdhFront_Only];
  if (iDocumentHandling and BACK_ONLY <> 0) then Result:= Result+[xdhBack_Only];
//  if (iDocumentHandling and NEXT_PAGE <> 0) then Result:= Result+[wdhNext_Page];
//  if (iDocumentHandling and PREFEED <> 0) then Result:= Result+[wdhPreFeed];
//  if (iDocumentHandling and AUTO_ADVANCE <> 0) then Result:= Result+[wdhAuto_Advance];
//  if (iDocumentHandling and ADVANCED_DUPLEX <> 0) then Result:= Result+[wdhAdvanced_Duplex];
end;

function WIADocumentHandlingInt(sDocumentHandling: TXICA_DocumentHandlings): Integer;
begin
  Result :=0;

  if (xdhFeeder in sDocumentHandling) then Result:= Result or FEEDER;
  if (xdhFlatbed in sDocumentHandling) then Result:= Result or FLATBED;
  if (xdhDuplex in sDocumentHandling) then Result:= Result or DUPLEX;
  if (xdhFront_First in sDocumentHandling) then Result:= Result or FRONT_FIRST;
  if (xdhBack_First in sDocumentHandling) then Result:= Result or BACK_FIRST;
  if (xdhFront_Only in sDocumentHandling) then Result:= Result or FRONT_ONLY;
  if (xdhBack_Only in sDocumentHandling) then Result:= Result or BACK_ONLY;
//  if (xdhNext_Page in sDocumentHandling) then Result:= Result or NEXT_PAGE;
//  if (xdhPreFeed in sDocumentHandling) then Result:= Result or PREFEED;
//  if (xdhAuto_Advance in sDocumentHandling) then Result:= Result or AUTO_ADVANCE;
//  if (xdhAdvanced_Duplex in sDocumentHandling) then Result:= Result or ADVANCED_DUPLEX;
end;

{ TXICA_WiaDevice }

function TXICA_WiaDevice.GetRootItemIntf: IWiaItem2;
begin
  Result :=nil;

  if (rOwner <> nil) then
  begin
    if (pRootItem = nil)
    then try
           lres :=TXICA_WIAManager(rOwner).pDevMgr.CreateDevice(0, StringToOleStr(Self.rID), pRootItem);
           if (lres = S_OK) then Result :=pRootItem;
         finally
         end
    else Result :=pRootItem;
  end;
end;

function TXICA_WiaDevice.GetSelectedItemIntf: IWiaItem2;
begin
  //Enumerate Items if needed
  if not(HasEnumerated)
  then HasEnumerated:= EnumerateItems(False);

  if HasEnumerated and
     (SelectedIndex >= 0) and (SelectedIndex < Count)
  then Result:= pSelectedItem
  else Result:= nil;
end;

function TXICA_WiaDevice.GetRootPropertiesIntf: IWiaPropertyStorage;
begin
  Result:= nil;

  if (pRootItem = nil) then GetRootItemIntf;
  if (pRootItem <> nil) then
  begin
    if (pRootProperties = nil)
    then lres:= pRootItem.QueryInterface(IID_IWiaPropertyStorage, pRootProperties);

    Result:= pRootProperties;
  end;
end;

function TXICA_WiaDevice.GetSelectedPropertiesIntf: IWiaPropertyStorage;
begin
  Result:= nil;

  if (pSelectedItem = nil) then GetSelectedItemIntf;
  if (pSelectedItem <> nil)
  then Result:= pSelectedProperties;
end;

function TXICA_WiaDevice._EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean;
var
   pIEnumItem: IEnumWiaItem2;
   pItem: IWiaItem2;
   iCount,
   itemFetched: ULONG;
   itemType: LONG;
   itemCategory: TGUID;
   i: Integer;
   pPropSpec: PROPSPEC;
   pPropVar: PROPVARIANT;
   pWiaPropertyStorage: IWiaPropertyStorage;
   curName: String;
   curItem: TXICA_Item;

begin
  if (GetRootItemIntf = nil) then exit;

  lres:= pRootItem.EnumChildItems(nil, pIEnumItem);
  if (lres = S_OK) then
  begin
    lres:= pIEnumItem.GetCount(iCount);
    if (lres = S_OK) then
    begin
      (*
      if not(PreserveSelected) or (ALastSelected = nil)
      then  //Select the First item by default
            if (rSelectedIndex < 0) or (rSelectedIndex > iCount-1)
            then rSelectedIndex:= 0;
      *)

      //If there is an Item Selected free Interfaces pointers
      if (pSelectedItem <> nil) then
      begin
        pSelectedItem:= nil;
        pSelectedProperties:= nil;
      end;

      for i:=0 to iCount-1 do
      begin
        lres:= pIEnumItem.Next(1, pItem, itemFetched);

        Result := (lres = S_OK);
        if Result then
        begin
          lres:= pItem.QueryInterface(IID_IWiaPropertyStorage, pWiaPropertyStorage);
          if (lres = S_OK) and (pWiaPropertyStorage <> nil) then
          begin
            pPropSpec.ulKind := PRSPEC_PROPID;
            pPropSpec.propid := WIA_IPA_ITEM_NAME; //WIA_IPA_FULL_ITEM_NAME

            lres := pWiaPropertyStorage.ReadMultiple(1, @pPropSpec, @pPropVar);

            if (VT_BSTR = pPropVar.vt)
            then curName:= pPropVar.bstrVal
            else curName:= IntToStr(i);

            if PreserveSelected and (ALastSelected <> nil) and (ALastSelected.Name = curName)
            then begin
                   curItem:= ALastSelected;
                   Add(curName, ALastSelected);
                   SelectedIndex:= i;
                 end
            else begin
                   curItem:= TXICA_Item.Create; //(Self, i, pPropVar[0].bstrVal);
                   curItem.Name:= curName;
                   Add(curName, curItem);
                 end;

            lres:= pItem.GetItemType(itemType);
            if (lres = S_OK)
            then curItem.Type_:= WIAItemTypes(itemType)
            else curItem.Type_:= [];

            lres:= pItem.GetItemCategory(itemCategory);
            if (lres = S_OK)
            then curItem.Category :=WIAItemCategory(itemCategory)
            else curItem.Category :=xicNULL;

            if (i = rSelectedIndex)
            then begin
                   //if it is the Selected Item keep the Interfaces pointers
                   pSelectedItem:= pItem;
                   pSelectedProperties:= pWiaPropertyStorage;
                 end
            else begin
                   //else Release it
                   pItem:= nil;
                   pWiaPropertyStorage:= nil;
                 end;
          end;
        end
        else break;
      end;

      Result :=True;
    end;

    pIEnumItem:= nil;
  end;
end;

constructor TXICA_WiaDevice.Create(AOwner: TXICA_DeviceManager; AIndex: Integer; ADeviceID: String);
begin
  inherited Create(AOwner, AIndex, ADeviceID);

  pRootItem:= nil;
  pSelectedItem:= nil;
  pSelectedProperties:= nil;
end;

destructor TXICA_WiaDevice.Destroy;
begin
  //Free the Interfaces
  if (pRootItem <> nil) then pRootItem:= nil;
  if (pSelectedItem <> nil) then pSelectedItem:= nil;
  if (pSelectedProperties <> nil) then pSelectedProperties:= nil;

  inherited Destroy;
end;



{ TXICA_WIAManager }

function TXICA_WIAManager.CreateDevManager: IUnknown;
begin
  lres:= CoCreateInstance(CLSID_WiaDevMgr2, nil, CLSCTX_LOCAL_SERVER, IID_IWiaDevMgr2, Result);
end;

function TXICA_WIAManager._EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean;
var
  i:integer;
  ppIEnum: IEnumWIA_DEV_INFO;
  devCount: ULONG;
  devFetched: ULONG;
  pWiaPropertyStorage: IWiaPropertyStorage;
  //pPropIDS: array [0..3] of PROPID;
  //pPropNames: array [0..3] of LPOLESTR;
  pPropSpec: array [0..4] of PROPSPEC;
  pPropVar: array [0..4] of PROPVARIANT;
  curDevice: TXICA_WIADevice;

begin
  Result:= False;

  if (pDevMgr = nil)
  then pDevMgr:= WIA_LH.IWiaDevMgr2(CreateDevManager);

  if pDevMgr<>nil then
  begin
    if EnumAll
    then lres :=pDevMgr.EnumDeviceInfo(WIA_DEVINFO_ENUM_ALL, ppIEnum)
    else lres :=pDevMgr.EnumDeviceInfo(WIA_DEVINFO_ENUM_LOCAL, ppIEnum);

    if (lres=S_OK) and (ppIEnum<>nil) then
    begin
      lres :=ppIEnum.GetCount(devCount);

      if (lres<>S_OK)
      then Exception.Create('Number of WIA Devices not available');

      if (devCount > 0) then
      begin
        // Define which properties you want to read:
        // Device ID.  This is what you would use to create
        // the device.
        pPropSpec[0].ulKind := PRSPEC_PROPID;
        pPropSpec[0].propid := WIA_DIP_DEV_ID;
        //pPropIDS[0] :=WIA_DIP_DEV_ID;

        // Device Manufacturer
        pPropSpec[1].ulKind := PRSPEC_PROPID;
        pPropSpec[1].propid := WIA_DIP_VEND_DESC;
        //pPropIDS[1] :=WIA_DIP_VEND_DESC;

        // Device Name
        pPropSpec[2].ulKind := PRSPEC_PROPID;
        pPropSpec[2].propid := WIA_DIP_DEV_NAME;
        //pPropIDS[2] :=WIA_DIP_DEV_NAME;

        // Device Type
        pPropSpec[3].ulKind := PRSPEC_PROPID;
        pPropSpec[3].propid := WIA_DIP_DEV_TYPE;
        //pPropIDS[3] :=WIA_DIP_DEV_TYPE;

        // Device Wia Version
        pPropSpec[4].ulKind := PRSPEC_PROPID;
        pPropSpec[4].propid := WIA_DIP_WIA_VERSION;
        //pPropIDS[4] :=WIA_DIP_WIA_VERSION;

        pWiaPropertyStorage :=nil;

        for i:=0 to devCount-1 do
        begin
          FillChar(pPropVar, Sizeof(pPropVar), 0);
          //FillChar(pPropNames, Sizeof(pPropNames), 0);

          lres :=ppIEnum.Next(1, pWiaPropertyStorage, devFetched);

          if (lres<>S_OK)
          then Exception.Create('pWiaPropertyStorage for Device '+IntToStr(i)+' not available');

          // Ask for the property values
          lres := pWiaPropertyStorage.ReadMultiple(Length(pPropSpec), @pPropSpec, @pPropVar);

          // lres := pWiaPropertyStorage.ReadPropertyNames(Length(pPropIDS), @pPropIDS, @pPropNames);

          if (VT_BSTR = pPropVar[0].vt)
          then begin
                 if PreserveSelected and (ALastSelected <> nil) and (ALastSelected.ID = pPropVar[0].bstrVal)
                 then begin
                        curDevice:= TXICA_WIADevice(ALastSelected);
                        Add(pPropVar[0].bstrVal, ALastSelected);
                        SelectedIndex:= i;
                        //curDevice.rIndex:= i;  //Update Index because can be different (Actually not used)
                      end
                 else begin
                        curDevice:= TXICA_WIADevice.Create(Self, i, pPropVar[0].bstrVal);
                        Add(pPropVar[0].bstrVal, curDevice);
                      end;
               end
          else Exception.Create('ID of Device '+IntToStr(i)+' not String');

          if (VT_BSTR = pPropVar[1].vt)
          then curDevice.rManufacturer :=pPropVar[1].bstrVal
          else Exception.Create('Manufacturer of Device '+IntToStr(i)+' not String');

          if (VT_BSTR = pPropVar[2].vt)
          then curDevice.rName :=pPropVar[2].bstrVal
          else Exception.Create('Name of Device '+IntToStr(i)+' not String');

          if (VT_I4 = pPropVar[3].vt)
          then curDevice.rType :=TXICA_DeviceType(pPropVar[3].iVal)
          else Exception.Create('DeviceType of Device '+IntToStr(i)+' not Integer');

          if (VT_BSTR = pPropVar[4].vt)
          then VersionStrToInt(pPropVar[4].bstrVal, curDevice)
          else Exception.Create('WiaVersion of Device '+IntToStr(i)+' not String');

          pWiaPropertyStorage:= nil;

          (*CoTaskMemFree(pPropNames[0]);
            CoTaskMemFree(pPropNames[1]);
            CoTaskMemFree(pPropNames[2]);
            CoTaskMemFree(pPropNames[3]);*)
        end;
      end;

      ppIEnum :=nil;
    end;

    Result :=True;
  end;
end;

class function TXICA_WIAManager.SelectDialogFunc: TXICA_SelectDialogFunc;
begin

end;

constructor TXICA_WIAManager.Create(AEnumAll: Boolean);
begin
  inherited Create;

  HasEnumerated:= False;
  pDevMgr:= nil;
  rEnumAll:= AEnumAll;
end;

destructor TXICA_WIAManager.Destroy;
begin
  inherited Destroy;

  if (pDevMgr<>nil) then pDevMgr :=nil; //Free the Interface
end;

class function TXICA_WIAManager.Name: String;
begin
  Result:= 'WIA';
end;

initialization
  WIA_Manager:= TXICA_WIAManager.Create(XICA_EnumAllDevices);
  XICA_RegisterDeviceManager(TXICA_WIAManager.Name, WIA_Manager);

{$endif}
end.

