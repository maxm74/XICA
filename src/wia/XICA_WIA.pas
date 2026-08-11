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
{$R-}
{$POINTERMATH ON}

interface

{$ifdef MSWINDOWS}

uses Windows, Classes, SysUtils,
    {$ifdef fpc}testutils,{$else}DelphiCompatibility,{$endif}
     ComObj, ActiveX, WiaDef, WIA_LH, //Wia_PaperSizes
     XICA_Types, XICA_Classes;

type
  TWIAPropertyFlag = (
    WIAProp_READ, WIAProp_WRITE, WIAProp_SYNC_REQUIRED, WIAProp_NONE,
    WIAProp_RANGE, WIAProp_LIST, WIAProp_FLAG, WIAProp_CACHEABLE
  );
  TWIAPropertyFlags = set of TWIAPropertyFlag;

  { TXICA_WIAItem }

  TXICA_WIAItem = class(TXICA_Item, IWiaTransferCallback)
  protected
    pItem: IWiaItem2;
    pProperties: IWiaPropertyStorage;

    procedure ReleaseInterfaces;

    function CreateDestinationStream(FileName: String; var ppDestination: IStream): HRESULT; virtual;

(*oldcode     //Get Paper Width, Height form the Device (in Inches)
    function _GetPaperSize(out AWidth, AHeight: Single): Boolean; overload; override;
    function _GetPaperSize(out AWidth, AHeight, ADefaultWidth, ADefaultHeight: Single): Boolean; overload; override;
*)

    //Get Max Paper Width, Height form the Device (in Inches)
    function _GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean; override;

  public
    //IWiaTransferCallback implementation
    function TransferCallback(lFlags: LONG;
                              pWiaTransferParams: PWiaTransferParams): HRESULT; stdcall;
    function GetNextStream(lFlags: LONG;
                           bstrItemName,
                           bstrFullItemName: BSTR;
                           out ppDestination: IStream): HRESULT; stdcall;

    destructor Destroy; override;


    //Download the Item and return the number of files transfered.
    // if multiple pages is downloaded then the file names are
    // APath\AFileName-n.AExt where n is then Index (when 0 n is not present)
    function Download(APath, AFileName, AExt: String): Integer; overload; override;

    //Get Current Property Value and it's type given the ID
    function GetProperty(const APropId: PROPID; out propType: TVarType; out APropValue): Boolean; overload;

    //Get Current, Default and Possible Values of a Property given the ID,
    //  Depending on the type returned in propType
    //  APropListValues can be a Dynamic Array of Integers, Real, etc... user must free it
    //  if Result contain the Flag WIAProp_RANGE then use WIA_RANGE_XXX Indexes to get MIN/MAX/STEP Values
    function GetProperty(const APropId: PROPID; out propType: TVarType;
                         out APropValue, APropDefaultValue;
                         out APropListValues): TWIAPropertyFlags; overload;

    //Get a Range Property with Current, Default, Min, Max, Step Values  { #note 5 -oMaxM : do I keep it? }
    //   user MUST specify the type in propType in order to internally allocate the correct array, otherwise expect an exception
    function GetProperty(const APropId: PROPID; var propType: TVarType;
                         out APropValue, APropDefault, APropMin, APropMax, APropStep): Boolean; overload;

    //Set the Property Value given the ID, the user must know the correct type to use
    function SetProperty(const APropId: PROPID; const propType: TVarType; const APropValue): Boolean;

{ #note -oMaxM : Build overloaded functions for Set/Get Property? }
(*
    function SetProperty(APropId: PROPID; APropValue: Smallint): Boolean; overload;  //VT_I2
    function SetProperty(APropId: PROPID; APropValue: Integer): Boolean; overload;   //VT_I4, VT_INT
    function SetProperty(APropId: PROPID; APropValue: Single): Boolean; overload;    //VT_R4
    function SetProperty(APropId: PROPID; APropValue: Double): Boolean; overload;    //VT_R8
    function SetProperty(APropId: PROPID; APropValue: Currency): Boolean; overload;  //VT_R8
    function SetProperty(APropId: PROPID; APropValue: TDateTime): Boolean; overload; //VT_DATE
    function SetProperty(APropId: PROPID; APropValue: BSTR): Boolean; overload;      //VT_BSTR
    function SetProperty(APropId: PROPID; APropValue: Boolean): Boolean; overload;   //VT_BOOL
    function SetProperty(APropId: PROPID; APropValue: Word): Boolean; overload;      //VT_UI2
    function SetProperty(APropId: PROPID; APropValue: DWord): Boolean; overload;     //VT_UI4, VT_UINT
    function SetProperty(APropId: PROPID; APropValue: Int64): Boolean; overload;     //VT_I8
    function SetProperty(APropId: PROPID; APropValue: UInt64): Boolean; overload;    //VT_UI8
    function SetProperty(APropId: PROPID; APropValue: LPSTR): Boolean; overload;     //VT_LPSTR
//    procedure SetProperty(APropId: PROPID; APropValue: LPWSTR): Boolean; overload;  //VT_LPWSTR
*)

    //Get Available Values for XResolution,
    //  if Result contain the Flag prop_RANGE then use propRANGE_XXX Indexes to get MIN/MAX/STEP Values
    function GetResolutionsX(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags; override;
    //Get Available Values for YResolutions
    function GetResolutionsY(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags; override;

    //Get Current Resolutions
    function GetResolution(out AXRes, AYRes: Integer): Boolean; override;

    //Set Current Resolutions, The user is responsible for checking the validity of the values
    function SetResolution(const AXRes, AYRes: Integer): Boolean; override;

    //Get Current Paper Rect (in Pixels)
    function GetPaperRect(out Current: TRect): Boolean; overload; override;
    function GetPaperRect(out Current, Default: TRect): Boolean; overload; override;

    //Set Current Paper Rect (in Pixels)
    function SetPaperRect(const X, Y, Width, Height: Integer): Boolean; override;

     //Get Current Rotation, not to be confused with PaperLandscape
    function GetRotation(out Value: TXICA_Rotation): Boolean; overload; override;
    //Get Available Rotations
    function GetRotation(out Current, Default: TXICA_Rotation; out Values: TXICA_Rotations): Boolean; overload; override;

    //Set Current Rotation, not to be confused with PaperLandscape,
    //  this function rotate the image after capturing it
    function SetRotation(const Value: TXICA_Rotation): Boolean; override;

    //Get Current DocumentHandling,
    function GetDocumentHandling(out Value: TXICA_DocumentHandlings): Boolean; overload; override;
    //Get Available DocumentHandling
    function GetDocumentHandling(out Current, Default, Values: TXICA_DocumentHandlings): Boolean; overload; override;

    //Set Current DocumentHandling,
    function SetDocumentHandling(const Value: TXICA_DocumentHandlings): Boolean; override;

    //Get Current Pages (0 = All)
    function GetPages(out Current: Integer): Boolean; overload; override;
    //Get Current, Default and Range Values for Pages
    function GetPages(out Current, Default, AMin, AMax, AStep: Integer): Boolean; overload; override;

    //Set Current Pages (0 = All)
    //  If a Feeder Scanner is unable to scan only one side of a page while in Duplex you must use an even value
    function SetPages(const Value: Integer): Boolean; override;

    //Get Current Brightness
    function GetBrightness(out Current: Integer): Boolean; overload; override;
    //Get Current, Default and Range Values for Brightness
    function GetBrightness(out Current, Default, AMin, AMax, AStep: Integer): Boolean; overload; override;

    //Set Current Brightness, The user is responsible for checking the validity of the value
    function SetBrightness(const Value: Integer): Boolean; override;

    //Get Current Contrast
    function GetContrast(out Current: Integer): Boolean; overload; override;
    //Get Current, Default and Range Values for Contrast
    function GetContrast(out Current, Default, AMin, AMax, AStep: Integer): Boolean; overload; override;

    //Set Current Contrast, The user is responsible for checking the validity of the value
    function SetContrast(const Value: Integer): Boolean; override;

    //Get Current Image Format
    function GetImageFormat(out Current: TXICA_ImageFormat): Boolean; overload; override;
    //Get Available Image Formats
    function GetImageFormat(out Current, Default: TXICA_ImageFormat; out Values: TXICA_ImageFormats): Boolean; overload; override;

    //Set Current Image Format
    function SetImageFormat(const Value: TXICA_ImageFormat): Boolean; override;

     //Get Current Image DataType
    function GetDataType(out Current: TXICA_DataType): Boolean; overload; override;
    //Get Available Image DataTypes
    function GetDataType(out Current, Default: TXICA_DataType; out Values: TXICA_DataTypes): Boolean; overload; override;

    //Set Current Image DataType
    function SetDataType(const Value: TXICA_DataType): Boolean; override;

    //Get Current BitDepth
    function GetBitDepth(out Current: Integer): Boolean; overload; override;
    //Get Available Values for BitDepth
    function GetBitDepth(out Current, Default: Integer; out Values: TArrayInteger): Boolean; overload; override;

    //Set Current BitDepth, The user is responsible for checking the validity of the value
    function SetBitDepth(const Value: Integer): Boolean; override;
  end;

  { TXICA_WIADevice }

  TXICA_WiaDevice = class(TXICA_Device)
  protected
    pRootItem: IWiaItem2;
    pRootProperties: IWiaPropertyStorage;

    function GetRootItemIntf: IWiaItem2;
    function GetRootPropertiesIntf: IWiaPropertyStorage;

    //Enumerate the avaliable items
    function _EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean; override;

    function GetType_Str: String; override;

  public
    constructor Create(AOwner: TXICA_DeviceManager; AIndex: Integer; ADeviceID: String); override;
    destructor Destroy; override;

    //Download using Native UI and return the number of files transfered in DownloadedFiles array.
    //  The system dialog works at Device level, so the selected item is ignored
    function DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
                              APath, AFileName: String;
                              out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer; override;

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


function WIAItemTypes(const pItemType: LONG): TXICA_ItemTypes;
function WIAItemCategory(const AGUID: TGUID): TXICA_ItemCategory;

procedure WIAPropertyFlags(const pFlags: ULONG; out AFlags: TWIAPropertyFlags); overload;
procedure WIAPropertyFlags(const pFlags: ULONG; out AFlags: TXICA_PropertyFlags); overload;

function XICA_PropertyFlags(const pFlags: TWIAPropertyFlags): TXICA_PropertyFlags;

function WIAImageFormat(const AGUID: TGUID; out Value: TXICA_ImageFormat): Boolean;


{$endif}

implementation

{$ifdef MSWINDOWS}

uses (*{$ifdef fpc}FileUtil, {$endif}*) XICA;

var
   WIA_Manager: TXICA_WIAManager = nil;

//============= WIA Functions ==========================

function WIAItemTypes(const pItemType: LONG): TXICA_ItemTypes;
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

procedure WIAPropertyFlags(const pFlags: ULONG; out AFlags: TWIAPropertyFlags); overload;
begin
  AFlags:= [];

  if (pFlags and WIA_PROP_READ <> 0) then AFlags:= AFlags+[WIAProp_READ];
  if (pFlags and WIA_PROP_WRITE <> 0) then AFlags:= AFlags+[WIAProp_WRITE];
  if (pFlags and WIA_PROP_SYNC_REQUIRED <> 0) then AFlags:= AFlags+[WIAProp_SYNC_REQUIRED];
  if (pFlags and WIA_PROP_NONE <> 0) then AFlags:= AFlags+[WIAProp_NONE];
  if (pFlags and WIA_PROP_RANGE <> 0) then AFlags:= AFlags+[WIAProp_RANGE];
  if (pFlags and WIA_PROP_LIST <> 0) then AFlags:= AFlags+[WIAProp_LIST];
  if (pFlags and WIA_PROP_FLAG <> 0) then AFlags:= AFlags+[WIAProp_FLAG];
  if (pFlags and WIA_PROP_CACHEABLE <> 0) then AFlags:= AFlags+[WIAProp_CACHEABLE];
end;


procedure WIAPropertyFlags(const pFlags: ULONG; out AFlags: TXICA_PropertyFlags); overload;
begin
  AFlags:= [];

  if (pFlags and WIA_PROP_READ <> 0) then AFlags:= AFlags+[prop_READ];
  if (pFlags and WIA_PROP_WRITE <> 0) then AFlags:= AFlags+[prop_WRITE];
  if (pFlags and WIA_PROP_RANGE <> 0) then AFlags:= AFlags+[prop_RANGE];
  if (pFlags and WIA_PROP_LIST <> 0) then AFlags:= AFlags+[prop_LIST];
end;

function XICA_PropertyFlags(const pFlags: TWIAPropertyFlags): TXICA_PropertyFlags;
begin
  Result:= [];

  if (WIAProp_READ in pFlags) then Result:= Result+[prop_READ];
  if (WIAProp_WRITE in pFlags) then Result:= Result+[prop_WRITE];
  if (WIAProp_RANGE in pFlags) then Result:= Result+[prop_RANGE];
  if (WIAProp_LIST in pFlags) then Result:= Result+[prop_LIST];
end;

function WIAImageFormat(const AGUID: TGUID; out Value: TXICA_ImageFormat): Boolean;
var
   i: TXICA_ImageFormat;

begin
  Result:= False;
  Value:= xifUNDEFINED;

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

{ TXICA_WIAItem }

procedure TXICA_WIAItem.ReleaseInterfaces;
begin
  pItem:= nil;
  pProperties:= nil;
end;

function TXICA_WIAItem.CreateDestinationStream(FileName: String; var ppDestination: IStream): HRESULT;
begin
  StreamDestination:= TFileStream.Create(FileName, fmCreate);
  ppDestination:= TStreamAdapter.Create(StreamDestination, soOwned);
  Result:= S_OK;
end;

destructor TXICA_WIAItem.Destroy;
begin
  ReleaseInterfaces;

  inherited Destroy;
end;

function TXICA_WIAItem.TransferCallback(lFlags: LONG; pWiaTransferParams: PWiaTransferParams): HRESULT; stdcall;
begin
  if not(Assigned(rOwner.OnBeforeDeviceTransfer))
  then Result:= S_OK
  else if rOwner.OnBeforeDeviceTransfer(rOwner, Self(*, lFlags, pWiaTransferParams*))
       then Result:= S_OK
       else Result:= S_FALSE;

  if (Result = S_OK) and (pWiaTransferParams <> nil) then
  Case pWiaTransferParams^.lMessage of
    WIA_TRANSFER_MSG_STATUS: begin
    end;
    WIA_TRANSFER_MSG_END_OF_STREAM: begin
      if (pWiaTransferParams^.ulTransferredBytes > 0)
      then Inc(rDownload_Count)
      else try
              //Some Scanner call GetNextStream even if there are no more pages
              //so we end up with an extra file with size 0, delete it
              DeleteFile(rDownload_Path+rDownload_FileName+
                         '-'+IntToStr(rDownload_Count)+rDownload_Ext);
           except
           end;

      rDownloaded:= (rDownload_Count > 0);
    end;
    WIA_TRANSFER_MSG_END_OF_TRANSFER: begin
      pWiaTransferParams^.lPercentComplete:=100;
    end;
    WIA_TRANSFER_MSG_DEVICE_STATUS: begin
    end;
    WIA_TRANSFER_MSG_NEW_PAGE: begin
    end
    else begin

    end;
  end;

  if Assigned(rOwner.OnAfterDeviceTransfer)
  then if rOwner.OnAfterDeviceTransfer(rOwner, Self (*, lFlags, pWiaTransferParams*))
       then Result:= S_OK
       else Result:= S_FALSE;
end;

function TXICA_WIAItem.GetNextStream(lFlags: LONG; bstrItemName, bstrFullItemName: BSTR; out ppDestination: IStream): HRESULT; stdcall;
begin
  Result:= S_OK;

  //  Return a new stream for this item's data.
  if (rDownload_Count = 0)
  then Result:= CreateDestinationStream(rDownload_Path+rDownload_FileName+rDownload_Ext, ppDestination)
  else Result:= CreateDestinationStream(rDownload_Path+rDownload_FileName+
                                        '-'+IntToStr(rDownload_Count)+rDownload_Ext, ppDestination);
end;

function TXICA_WIAItem.Download(APath, AFileName, AExt: String): Integer;
var
   pWiaTransfer: IWiaTransfer;
   myTickStart, curTick: UInt64;
//oldcode   selItem: TWIAItem;

   procedure DownloadSingleItem;
   begin
     lres:= pItem.QueryInterface(IID_IWiaTransfer, pWiaTransfer);
     if (lres = S_OK) and (pWiaTransfer <> nil) then
     try
       { #todo 10 -oMaxM : Check this in Various Scanner / Camera }
       // in My Samsung 00082007 =  [witImage,witFile,witFolder,witProgrammableDataSource] WHY witFolder?
       // in Kyocera via LAN = [witFolder, witStorage]
       (*
       if (witTransfer in selItem.ItemType) then
       begin
         if (witProgrammableDataSource in selItem.ItemType)
         then lres:= pWiaTransfer.Download(0, Self)
         else
         if (witDocument in selItem.ItemType) then
         begin
           if (witFolder in selItem.ItemType)
           then begin
                  lres:= pWiaTransfer.Download(WIA_TRANSFER_ACQUIRE_CHILDREN, Self);
                end
           else
           if (witFile in selItem.ItemType)
           then begin
                  lres:= pWiaTransfer.Download(0, Self);
                end;
         end;
       end;
       *)

       lres:= pWiaTransfer.Download(0, Self);

     finally
       // Release the IWiaTransfer
       pWiaTransfer:= nil;
     end;
   end;

   (*
   procedure DownloadAdvDuplex;
   var
      AItemArray: TArrayWIAItem;
      curSubItem: IWiaItem2;

   begin
     try
        if GetSelectedItemSubItems(AItemArray) then
        begin
          { #todo 10 -oMaxM : Implement me (If i find a Duplex Scanner for Free) }
        end;

     finally
       AItemArray:= nil;
     end;
   end;
   *)

begin
  Result:= 0;

  if (pItem <> nil) then
  begin
    //oldcode selItem:= rItemList[rSelectedItemIndex];

    if (APath = '') or CharInSet(APath[Length(APath)], AllowDirectorySeparators)
    then rDownload_Path:= APath
    else rDownload_Path:= APath+DirectorySeparator;

    if (rDownload_Path<>'') and not(ForceDirectories(rDownload_Path)) then exit;

    rDownload_FileName:= AFileName;
    rDownload_Ext:= AExt;
    rDownload_Count:= 0;
    rDownloaded:= False;

    (*if (selItem.ItemCategory = wicFEEDER)
    then begin
           if (rVersion = 2) and (wdhAdvanced_Duplex in ADocHandling) //or have SubItems?
           then DownloadAdvDuplex
           else DownloadSingleItem;
         end
     else*) DownloadSingleItem;

      { #todo 2 -oMaxM : Test if all Scanner is Synch }
      (*

      myTickStart:= GetTickCount64; curTick:= myTickStart;
      repeat
        CheckSynchronize(100);

        curTick:= GetTickCount64;

      until (rDownloaded) or ((curTick-myTickStart) > 27666);
      *)

      if (lres = S_OK) and rDownloaded
      then Result:= rDownload_Count
      else Result:= 0;
  end;
end;

function TXICA_WIAItem.GetProperty(const APropId: PROPID; out propType: TVarType; out APropValue): Boolean;
var
   pPropSpec: PROPSPEC;
   pPropVar: PROPVARIANT;

begin
  Result:= False;

  if (pProperties <> nil) then
  begin
       pPropSpec.ulKind:= PRSPEC_PROPID;
       pPropSpec.propid:= APropId;

       { #note -oMaxM : The Overloaded Version also call  }
       //lres:= GetPropertyAttributes(1, @pPropSpec, @pFlags, @pPropVar);

       lres:= pProperties.ReadMultiple(1, @pPropSpec, @pPropVar);

       Result:= (lres = S_OK);

       if Result then
       begin
         propType:= pPropVar.vt;

         // Convert ONLY the Types Used in WIA to APropValue,
         Case propType of
         VT_I2: SmallInt(APropValue):= pPropVar.iVal; //2 byte signed int
         VT_I4, VT_INT: Integer(APropValue):= pPropVar.lVal; //4 byte signed int, signed machine int
         VT_R4: Single(APropValue):= pPropVar.fltVal; //4 byte real
         VT_R8: Double(APropValue):= pPropVar.dblVal; //8 byte real
         VT_BSTR: String(APropValue):= pPropVar.bstrVal; //OLE Automation string,
         //VT_LPSTR: String(APropValue):= pPropVar.pszVal; //null terminated string
         //VT_LPWSTR: String(APropValue):= pPropVar.pwszVal; //wide null terminated string
         VT_UI1: Byte(APropValue):= pPropVar.bVal; //unsigned AnsiChar
         VT_UI2: Word(APropValue):= pPropVar.uiVal; //unsigned short
         VT_UI4, VT_UINT : LongWord(APropValue):= pPropVar.ulVal; //unsigned long
         VT_CLSID : TGUID(APropValue):= pPropVar.puuid^; //A Class ID
         else Result:= False;
         end;
       end;
   end;
end;

function TXICA_WIAItem.GetProperty(const APropId: PROPID; out propType: TVarType;
                                   out APropValue, APropDefaultValue; out APropListValues): TWIAPropertyFlags;
var
   pPropSpec: PROPSPEC;
   pPropVar,
   pPropInfo: PROPVARIANT;
   pFlags: ULONG;
   i: Integer;
   numElems,
   firstElem: DWord;

begin
  Result:= [];

  if (pProperties <> nil) then
  begin
       pPropSpec.ulKind:= PRSPEC_PROPID;
       pPropSpec.propid:= APropId;

       lres:= pProperties.GetPropertyAttributes(1, @pPropSpec, @pFlags, @pPropInfo);

       if (lres = S_OK) then
       begin
         propType:= pPropInfo.vt;

         WIAPropertyFlags(pFlags, Result);

         if not(Result = []) then
         begin
           lres:= pProperties.ReadMultiple(1, @pPropSpec, @pPropVar);
           propType:= pPropVar.vt;
           { #todo -oMaxM : What to do if the two types (pPropVar and pPropInfo) are different? }

           { #todo 10 -oMaxM : Convert ONLY the Types Used in WIA }

           if (lres = S_OK) then
           Case propType of
             VT_I2: begin //2 byte signed int
               SmallInt(APropValue):= pPropVar.iVal;
               numElems:= 0;
               firstElem:= 0;
               SmallInt(APropDefaultValue):= 0;

               if (WIAProp_LIST in Result)
               then begin
                      numElems:= pPropInfo.cai.cElems-WIA_LIST_VALUES; //pElems[WIA_LIST_COUNT]
                      firstElem:= WIA_LIST_VALUES;
                      SmallInt(APropDefaultValue):= pPropInfo.cai.pElems[WIA_LIST_NOM];
                    end
               else
               if (WIAProp_RANGE in Result)
               then begin
                      numElems:= WIA_RANGE_NUM_ELEMS;
                      firstElem:= 0;
                      SmallInt(APropDefaultValue):= pPropInfo.cai.pElems[WIA_RANGE_NOM];
                    end;
               if (WIAProp_FLAG in Result)
               then begin
                      numElems:= pPropInfo.cai.cElems-WIA_FLAG_VALUES; //WIA_FLAG_NUM_ELEMS;
                      firstElem:= WIA_FLAG_VALUES; //0;
                      SmallInt(APropDefaultValue):= pPropInfo.cai.pElems[WIA_FLAG_NOM];
                    end;

               SetLength(TArraySmallInt(APropListValues), numElems);
               for i:=firstElem to firstElem+numElems-1 do
                 TArraySmallInt(APropListValues)[i-firstElem]:= Integer(pPropInfo.cai.pElems[i]);
             end;
             VT_I4, VT_INT: begin //4 byte signed int, signed machine int
               Integer(APropValue):= pPropVar.lVal;
               numElems:= 0;
               firstElem:= 0;
               Integer(APropDefaultValue):= 0;

               if (WIAProp_LIST in Result)
               then begin
                      numElems:= pPropInfo.cal.pElems[WIA_LIST_COUNT]; //pPropInfo.cal.cElems-WIA_LIST_VALUES
                      firstElem:= WIA_LIST_VALUES;
                      Integer(APropDefaultValue):= pPropInfo.cal.pElems[WIA_LIST_NOM];
                    end
               else
               if (WIAProp_RANGE in Result)
               then begin
                      numElems:= WIA_RANGE_NUM_ELEMS;
                      firstElem:= 0;
                      Integer(APropDefaultValue):= pPropInfo.cal.pElems[WIA_RANGE_NOM];
                    end;
               if (WIAProp_FLAG in Result)
               then begin
                      numElems:= pPropInfo.cal.cElems-WIA_FLAG_VALUES; //WIA_FLAG_NUM_ELEMS;
                      firstElem:= WIA_FLAG_VALUES; //0;
                      Integer(APropDefaultValue):= pPropInfo.cal.pElems[WIA_FLAG_NOM];
                    end;

               SetLength(TArrayInteger(APropListValues), numElems);
               for i:=firstElem to firstElem+numElems-1 do
                 TArrayInteger(APropListValues)[i-firstElem]:= Integer(pPropInfo.cal.pElems[i]);
             end;
             VT_R4: begin //4 byte real
               Single(APropValue):= pPropVar.fltVal;
               numElems:= 0;
               firstElem:= 0;
               Single(APropDefaultValue):= 0;

               if (WIAProp_LIST in Result)
               then begin
                 { #note -oMaxM : documentaion says to use pElems[WIA_LIST_COUNT] but is a nonsense when the type is not an Integer}
                      numElems:= pPropInfo.caflt.cElems-WIA_LIST_VALUES;
                      firstElem:= WIA_LIST_VALUES;
                      Single(APropDefaultValue):= pPropInfo.caflt.pElems[WIA_LIST_NOM];
                    end
               else
               if (WIAProp_RANGE in Result)
               then begin
                      numElems:= WIA_RANGE_NUM_ELEMS;
                      firstElem:= 0;
                      Single(APropDefaultValue):= pPropInfo.caflt.pElems[WIA_RANGE_NOM];
                    end;
               //if (WIAProp_FLAG in Result) ?? nonsense

               SetLength(TArraySingle(APropListValues), numElems);
               for i:=firstElem to firstElem+numElems-1 do
                 TArraySingle(APropListValues)[i-firstElem]:= Single(pPropInfo.caflt.pElems[i]);
             end;
             VT_R8: begin //8 byte real
               Double(APropValue):= pPropVar.dblVal;
               numElems:= 0;
               firstElem:= 0;
               Double(APropDefaultValue):= 0;

               if (WIAProp_LIST in Result)
               then begin
                 { #note -oMaxM : documentaion says to use pElems[WIA_LIST_COUNT] but is a nonsense when the type is not an Integer}
                      numElems:= pPropInfo.cadbl.cElems-WIA_LIST_VALUES;
                      firstElem:= WIA_LIST_VALUES;
                      Double(APropDefaultValue):= pPropInfo.cadbl.pElems[WIA_LIST_NOM];
                    end
               else
               if (WIAProp_RANGE in Result)
               then begin
                      numElems:= WIA_RANGE_NUM_ELEMS;
                      firstElem:= 0;
                      Double(APropDefaultValue):= pPropInfo.cadbl.pElems[WIA_RANGE_NOM];
                    end;
               //if (WIAProp_FLAG in Result) ?? nonsense

               SetLength(TArrayDouble(APropListValues), numElems);
               for i:=firstElem to firstElem+numElems-1 do
                 TArrayDouble(APropListValues)[i-firstElem]:= Double(pPropInfo.cadbl.pElems[i]);
             end;
             VT_BSTR: begin //OLE Automation string
               String(APropValue):= pPropVar.bstrVal;
               numElems:= 0;
               firstElem:= 0;
               String(APropDefaultValue):= '';

               if (WIAProp_LIST in Result)
               then begin
                 { #note -oMaxM : documentaion says to use pElems[WIA_LIST_COUNT] but is a nonsense when the type is not an Integer}
                      numElems:= pPropInfo.cabstr.cElems-WIA_LIST_VALUES;
                      firstElem:= WIA_LIST_VALUES;
                      String(APropDefaultValue):= pPropInfo.cabstr.pElems[WIA_LIST_NOM];
                    end
               else
               //if (WIAProp_RANGE in Result) ?? nonsense
               //if (WIAProp_FLAG in Result) ?? nonsense

               SetLength(TStringArray(APropListValues), numElems);
               for i:=firstElem to firstElem+numElems-1 do
                 TStringArray(APropListValues)[i-firstElem]:= String(pPropInfo.cabstr.pElems[i]);
             end;
             VT_UI1: begin //unsigned AnsiChar
               Byte(APropValue):= pPropVar.bVal;
               numElems:= 0;
               firstElem:= 0;
               Byte(APropDefaultValue):= 0;

               if (WIAProp_LIST in Result)
               then begin
                      numElems:= pPropInfo.caub.cElems-WIA_LIST_VALUES; //pElems[WIA_LIST_COUNT]
                      firstElem:= WIA_LIST_VALUES;
                      Byte(APropDefaultValue):= pPropInfo.caub.pElems[WIA_LIST_NOM];
                    end
               else
               if (WIAProp_RANGE in Result)
               then begin
                      numElems:= WIA_RANGE_NUM_ELEMS;
                      firstElem:= 0;
                      Byte(APropDefaultValue):= pPropInfo.caub.pElems[WIA_RANGE_NOM];
                    end;
               if (WIAProp_FLAG in Result)
               then begin
                      numElems:= pPropInfo.caub.cElems-WIA_FLAG_VALUES; //WIA_FLAG_NUM_ELEMS;
                      firstElem:= WIA_FLAG_VALUES;
                      Byte(APropDefaultValue):= pPropInfo.caub.pElems[WIA_FLAG_NOM];
                    end;

               SetLength(TArrayByte(APropListValues), numElems);
               for i:=firstElem to firstElem+numElems-1 do
                 TArrayByte(APropListValues)[i-firstElem]:= Byte(pPropInfo.caub.pElems[i]);
             end;
             VT_UI2: begin //unsigned short
               Word(APropValue):= pPropVar.uiVal;
               numElems:= 0;
               firstElem:= 0;
               Word(APropDefaultValue):= 0;

               if (WIAProp_LIST in Result)
               then begin
                      numElems:= pPropInfo.caui.cElems-WIA_LIST_VALUES; //pElems[WIA_LIST_COUNT]
                      firstElem:= WIA_LIST_VALUES;
                      Word(APropDefaultValue):= pPropInfo.caui.pElems[WIA_LIST_NOM];
                    end
               else
               if (WIAProp_RANGE in Result)
               then begin
                      numElems:= WIA_RANGE_NUM_ELEMS;
                      firstElem:= 0;
                      Word(APropDefaultValue):= pPropInfo.caui.pElems[WIA_RANGE_NOM];
                    end;
               if (WIAProp_FLAG in Result)
               then begin
                      numElems:= pPropInfo.caui.cElems-WIA_FLAG_VALUES; //WIA_FLAG_NUM_ELEMS;
                      firstElem:= WIA_FLAG_VALUES; //0;
                      Word(APropDefaultValue):= pPropInfo.caui.pElems[WIA_FLAG_NOM];
                    end;

               SetLength(TArrayWord(APropListValues), numElems);
               for i:=firstElem to firstElem+numElems-1 do
                 TArrayWord(APropListValues)[i-firstElem]:= Word(pPropInfo.caui.pElems[i]);
             end;
             VT_UI4, VT_UINT : begin //unsigned long
               LongWord(APropValue):= pPropVar.ulVal;
               numElems:= 0;
               firstElem:= 0;
               LongWord(APropDefaultValue):= 0;

               if (WIAProp_LIST in Result)
               then begin
                      numElems:= pPropInfo.caul.cElems-WIA_LIST_VALUES; //pElems[WIA_LIST_COUNT]
                      firstElem:= WIA_LIST_VALUES;
                      LongWord(APropDefaultValue):= pPropInfo.caul.pElems[WIA_LIST_NOM];
                    end
               else
               if (WIAProp_RANGE in Result)
               then begin
                      numElems:= WIA_RANGE_NUM_ELEMS;
                      firstElem:= 0;
                      LongWord(APropDefaultValue):= pPropInfo.caul.pElems[WIA_RANGE_NOM];
                    end;
               if (WIAProp_FLAG in Result)
               then begin
                      numElems:= pPropInfo.caul.cElems-WIA_FLAG_VALUES; //WIA_FLAG_NUM_ELEMS;
                      firstElem:= WIA_FLAG_VALUES; //0;
                      LongWord(APropDefaultValue):= pPropInfo.caul.pElems[WIA_FLAG_NOM];
                    end;

               SetLength(TArrayLongWord(APropListValues), numElems);
               for i:=firstElem to firstElem+numElems-1 do
                 TArrayLongWord(APropListValues)[i-firstElem]:= LongWord(pPropInfo.caul.pElems[i]);
             end;
             VT_CLSID : begin //A Class ID
               //TGUID(APropValue):= pPropVar.puuid^; //it should be this assign but it isn't
               TGUID(APropValue):= GUID_NULL;

               numElems:= 0;
               firstElem:= 0;
               TGUID(APropDefaultValue):= GUID_NULL;

               if (WIAProp_LIST in Result)
               then begin
                      numElems:= pPropInfo.cauuid.cElems;
                      firstElem:= 0;
                      { #note -oMaxM : I don't understand the logic but in this case the WIA_LIST_XXX indexes are not valid}
                      //TGUID(APropDefaultValue):= pPropInfo.cauuid.pElems[WIA_LIST_NOM];

                      SetLength(TArrayGUID(APropListValues), numElems);
                      for i:=firstElem to firstElem+numElems-1 do
                        TArrayGUID(APropListValues)[i-firstElem]:= TGUID(pPropInfo.cauuid.pElems[i]);
                    end;
               //if (WIAProp_RANGE in Result) ?? nonsense
               //if (WIAProp_FLAG in Result) ?? nonsense
            end;
            else Result:= [];
           end;
         end;
       end;
  end;
end;

function TXICA_WIAItem.GetProperty(const APropId: PROPID; var propType: TVarType;
                                   out APropValue, APropDefault, APropMin, APropMax, APropStep): Boolean;
var
   pFlags: TWIAPropertyFlags;
   iValues: TArrayInteger;

begin
  Result:= False;
  try
     Case propType of
       VT_I4, VT_INT: GetProperty(APropId, propType, APropValue, APropDefault, iValues);
     end;

     pFlags:= GetProperty(APropId, propType, APropValue, APropDefault, iValues);

     Result:= (WIAProp_RANGE in pFlags);

     if Result then
     begin
       Case propType of
         VT_I4, VT_INT: begin
            Result:= (Length(iValues) = WIA_RANGE_NUM_ELEMS);
            if Result then
            begin
              Integer(APropMin):= iValues[WIA_RANGE_MIN];
              Integer(APropMax):= iValues[WIA_RANGE_MAX];
              Integer(APropStep):= iValues[WIA_RANGE_STEP];
            end;
         end;
       end;
     end;

  finally
    iValues:= nil;
  end;
end;

function TXICA_WIAItem.SetProperty(const APropId: PROPID; const propType: TVarType; const APropValue): Boolean;
var
   pPropSpec: PROPSPEC;
   pPropVar: PROPVARIANT;

begin
  Result:= False;

  if (pProperties <> nil) then
  begin
       pPropSpec.ulKind:= PRSPEC_PROPID;
       pPropSpec.propid:= APropId;
       pPropVar.vt:= propType;

       { #todo 10 -oMaxM : Convert ONLY the Types Used in WIA }
       Case propType of
         VT_I2: begin //2 byte signed int
           pPropVar.iVal:= SmallInt(APropValue);
         end;
         VT_I4, VT_INT: begin //4 byte signed int, signed machine int
           pPropVar.lVal:= Integer(APropValue);
         end;
         VT_R4: begin //4 byte real
           pPropVar.fltVal:= Single(APropValue);
         end;
         VT_R8, VT_DATE: begin //8 byte real , date
           if (propType = VT_R8)
           then pPropVar.dblVal:= Double(APropValue)
           else pPropVar.date:= Double(APropValue);
         end;
         VT_CY: begin //currency
           pPropVar.cyVal:= CURRENCY(APropValue);
         end;
         VT_BSTR, VT_LPSTR, VT_LPWSTR: begin //OLE Automation string, null terminated string, wide null terminated string
            { #note 5 -oMaxM : Test this Casts }
           case propType of
           VT_BSTR: pPropVar.bstrVal:= PWideChar(String(APropValue));
           VT_LPSTR: pPropVar.pszVal:= PAnsiChar(String(APropValue));
           VT_LPWSTR: pPropVar.pwszVal:= PWideChar(String(APropValue));
           end;
         end;
         VT_BOOL: begin //True=-1, False=0
           pPropVar.boolVal:= Boolean(APropValue);
         end;
         VT_I1: begin //signed AnsiChar
           { #note -oMaxM : Delphi has wrong declaration of cVal as ShortInt, correct one is Char }
           {$ifdef fpc}
           pPropVar.cVal:= AnsiChar(APropValue);
           {$else}
           pPropVar.cVal:= ShortInt(APropValue);
           {$endif}
         end;
         VT_UI1: begin //unsigned AnsiChar
           pPropVar.bVal:= Byte(APropValue);
         end;
         VT_UI2: begin //unsigned short
           pPropVar.uiVal:= Word(APropValue);
         end;
         VT_UI4, VT_UINT : begin //unsigned long
           pPropVar.ulVal:= LongWord(APropValue);
         end;
         VT_I8 : begin //signed 64-bit int
           pPropVar.hVal:= LARGE_INTEGER(APropValue);
         end;
         VT_UI8 : begin //unsigned 64-bit int
           pPropVar.uhVal:= ULARGE_INTEGER(APropValue);
         end;
         VT_CLSID : begin //A Class ID
           pPropVar.puuid:= @TGUID(APropValue); { #note 5 -oMaxM : Test this Cast }
         end;
     end;

     lres:= pProperties.WriteMultiple(1, @pPropSpec, @pPropVar, 2);

     Result:= (lres = S_OK);
  end;
end;

function TXICA_WIAItem.GetResolutionsX(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags;
var
   propType: TVarType;

begin
  Result:= XICA_PropertyFlags(GetProperty(WIA_IPS_XRES, propType, Current, Default, Values));
  { #note 5 -oMaxM : what to do if the propType is not the expected one VT_I4}
end;

function TXICA_WIAItem.GetResolutionsY(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags;
var
   propType: TVarType;

begin
  Result:= XICA_PropertyFlags(GetProperty(WIA_IPS_YRES, propType, Current, Default, Values));
  { #note 5 -oMaxM : what to do if the propType is not the expected one VT_I4}
end;

function TXICA_WIAItem.GetResolution(out AXRes, AYRes: Integer): Boolean;
var
   propType: TVarType;

begin
  Result:= GetProperty(WIA_IPS_XRES, propType, AXRes) and
           GetProperty(WIA_IPS_YRES, propType, AYRes);
  { #note 5 -oMaxM : what to do if the propType is not the expected one VT_I4}
end;

function TXICA_WIAItem.SetResolution(const AXRes, AYRes: Integer): Boolean;
begin
  Result:= SetProperty(WIA_IPS_XRES, VT_I4, AXRes);
  if Result
  then rXRes:= AXRes
  else Exit;

  Result:= SetProperty(WIA_IPS_YRES, VT_I4, AYRes);
  if Result then rYRes:= AYRes;
end;

function TXICA_WIAItem.GetPaperRect(out Current: TRect): Boolean;
var
   propType: TVarType;
   xWidth, xPos,
   yHeight, yPos: Integer;

begin
  Result:= GetProperty(WIA_IPS_XPOS, propType, xPos) and
           GetProperty(WIA_IPS_XEXTENT, propType, xWidth) and
           GetProperty(WIA_IPS_YPOS, propType, yPos) and
           GetProperty(WIA_IPS_YEXTENT, propType, yHeight);

  if Result then
  begin
    Current.Left:= xPos;
    Current.Right:= xPos+xWidth;
    Current.Top:= yPos;
    Current.Bottom:= yPos+yHeight;
  end;
end;

function TXICA_WIAItem.GetPaperRect(out Current, Default: TRect): Boolean;
var
   propType: TVarType;
   xWidth, xPos,
   yHeight, yPos,
   xDefWidth, xDefPos,
   yDefHeight, yDefPos,
   iMin, iMax, iStep: Integer;

begin
  propType:= VT_I4;
  Result:= GetProperty(WIA_IPS_XPOS, propType, xPos, xDefPos, iMin, iMax, iStep) and
           GetProperty(WIA_IPS_XEXTENT, propType, xWidth, xDefWidth, iMin, iMax, iStep) and
           GetProperty(WIA_IPS_YPOS, propType, yPos, yDefPos, iMin, iMax, iStep) and
           GetProperty(WIA_IPS_YEXTENT, propType, yHeight, yDefHeight, iMin, iMax, iStep);

  if Result then
  begin
    Current.Left:= xPos;
    Current.Right:= xPos+xWidth;
    Current.Top:= yPos;
    Current.Bottom:= yPos+yHeight;

    Default.Left:= xDefPos;
    Default.Right:= xDefPos+xDefWidth;
    Default.Top:= yDefPos;
    Default.Bottom:= yDefPos+yDefHeight;
  end;
end;

function TXICA_WIAItem.SetPaperRect(const X, Y, Width, Height: Integer): Boolean;
begin
  Result:= SetProperty(WIA_IPS_XPOS, VT_I4, X) and
           SetProperty(WIA_IPS_YPOS, VT_I4, Y) and
           SetProperty(WIA_IPS_XEXTENT, VT_I4, Width) and
           SetProperty(WIA_IPS_YEXTENT, VT_I4, Height);
end;

(*oldcode
function TXICA_WIAItem._GetPaperSize(out AWidth, AHeight: Single): Boolean;
var
   propType: TVarType;
   xWidth, xPos,
   yHeight, yPos,
   iValue, iDefault, iMin, iMax, iStep: Integer;

begin
//oldcode
//  Result:= GetProperty(WIA_IPS_PAGE_WIDTH, propType, iWidth) and
//           GetProperty(WIA_IPS_PAGE_HEIGHT, propType, iHeight); { #note 5 -oMaxM : Always return False ?}
//
  Result:= False;

  if (rXRes = -1) or (rYRes = -1)
  then if not(GetResolution(rXRes, rYRes)) then Exit;

  Result:= GetProperty(WIA_IPS_XPOS, propType, xPos) and
           GetProperty(WIA_IPS_XEXTENT, propType, xWidth);
  if Result then AWidth:= (xWidth-xPos)/rXRes;

  Result:= GetProperty(WIA_IPS_YPOS, propType, yPos, iDefault, iMin, iMax, iStep) and
           GetProperty(WIA_IPS_YEXTENT, propType, yHeight, iDefault, iMin, iMax, iStep);
  if Result then AHeight:= (yHeight-yPos)/rYRes;
end;

function TXICA_WIAItem._GetPaperSize(out AWidth, AHeight, ADefaultWidth, ADefaultHeight: Single): Boolean;
var
   propType: TVarType;
   iWidth, iHeight,
   iDefaultWidth,
   iDefaultHeight: Integer;
   iList: TArrayInteger;

begin
  try
     //oldcode
     //Result:= (WIAProp_READ in GetProperty(WIA_IPS_PAGE_WIDTH, propType, iWidth, iDefaultWidth, iList)) and
     //         (WIAProp_READ in GetProperty(WIA_IPS_PAGE_HEIGHT, propType, iHeight, iDefaultHeight, iList)); { #note 5 -oMaxM : Always return False ?}
     //
     Result:= (WIAProp_READ in GetProperty(WIA_IPS_XEXTENT, propType, iWidth, iDefaultWidth, iList)) and
              (WIAProp_READ in GetProperty(WIA_IPS_YEXTENT, propType, iHeight, iDefaultHeight, iList)); { #note 5 -oMaxM : Always return False ?}

     if Result then
     begin
       AWidth:= iWidth/1000;
       AHeight:= iHeight/1000;
       ADefaultWidth:= iDefaultWidth/1000;
       ADefaultHeight:= iDefaultHeight/1000;
     end;
  finally
    iList:= nil;
  end;
end;
*)

function TXICA_WIAItem._GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean;
var
   propType: TVarType;
   iMaxWidth,
   iMaxHeight,
   curSource: Integer;

begin
  if (rOwner.Version = 1)
  then begin
         Result:= GetProperty(WIA_DPS_DOCUMENT_HANDLING_SELECT, propType, curSource);
         if Result then
         begin
           if (curSource and FEEDER <> 0)
           then Result:= GetProperty(WIA_DPS_HORIZONTAL_SHEET_FEED_SIZE, propType, iMaxWidth) and
                         GetProperty(WIA_DPS_VERTICAL_SHEET_FEED_SIZE, propType, iMaxHeight)
           else Result:= GetProperty(WIA_DPS_HORIZONTAL_BED_SIZE, propType, iMaxWidth) and
                         GetProperty(WIA_DPS_VERTICAL_BED_SIZE, propType, iMaxHeight);
         end;
       end
  else Result:= GetProperty(WIA_IPS_MAX_HORIZONTAL_SIZE, propType, iMaxWidth) and
                GetProperty(WIA_IPS_MAX_VERTICAL_SIZE, propType, iMaxHeight);

  if Result then
  begin
    AMaxWidth:= iMaxWidth/1000;
    AMaxHeight:= iMaxHeight/1000;
  end;
end;

function TXICA_WIAItem.GetRotation(out Value: TXICA_Rotation): Boolean;
var
   propType: TVarType;

begin
  Result:= GetProperty(WIA_IPS_ROTATION, propType, Value);
end;

function TXICA_WIAItem.GetRotation(out Current, Default: TXICA_Rotation; out Values: TXICA_Rotations): Boolean;
var
   i: Integer;
   intValues: TArrayInteger;
   propType: TVarType;
   pFlags: TWIAPropertyFlags;

begin
  Result:= False;
  try
     Values:=[];

     pFlags:= GetProperty(WIA_IPS_ROTATION, propType, Current, Default, intValues);
     if not(WIAProp_READ in pFlags) then Exit;

     if (WIAProp_LIST in pFlags) then
     begin
       for i:=0 to Length(intValues)-1 do Values:= Values+[TXICA_Rotation(intValues[i])];

       Result:= True;
     end;

  finally
    intValues:= nil;
  end;
end;

function TXICA_WIAItem.SetRotation(const Value: TXICA_Rotation): Boolean;
var
   iValue: Integer;

begin
  iValue:= Integer(Value); // Avoid Delphi Release Optimization Error
  Result:= SetProperty(WIA_IPS_ROTATION, VT_I4, iValue);
end;

function TXICA_WIAItem.GetDocumentHandling(out Value: TXICA_DocumentHandlings): Boolean;
var
   propType: TVarType;
   iCurrent: Integer;

begin
  Result:= GetProperty(WIA_IPS_DOCUMENT_HANDLING_SELECT, propType, iCurrent);
  if Result then Value:= WIADocumentHandling(iCurrent);
end;

function TXICA_WIAItem.GetDocumentHandling(out Current, Default, Values: TXICA_DocumentHandlings): Boolean;
var
   i,
   iCurrent,
   iDefault: Integer;
   intValues: TArrayInteger;
   propType: TVarType;
   pFlags: TWIAPropertyFlags;

begin
  Result:= False;
  try
     Values:=[];

     pFlags:= GetProperty(WIA_IPS_DOCUMENT_HANDLING_SELECT, propType, iCurrent, iDefault, intValues);
     if not(WIAProp_READ in pFlags) then Exit;

     if (WIAProp_FLAG in pFlags) then
     begin
       Current:= WIADocumentHandling(iCurrent);
       Default:= WIADocumentHandling(iDefault);
       Values:= WIADocumentHandling(TArrayInteger(intValues)[0]);

       Result:= True;
     end;

   finally
     intValues:= nil;
   end;
end;

function TXICA_WIAItem.SetDocumentHandling(const Value: TXICA_DocumentHandlings): Boolean;
var
   iValue: Integer;

begin
  iValue:= WIADocumentHandlingInt(Value);
  Result:= SetProperty(WIA_IPS_DOCUMENT_HANDLING_SELECT, VT_I4, iValue);
end;

function TXICA_WIAItem.GetPages(out Current: Integer): Boolean;
var
   propType: TVarType;

begin
  Result:= GetProperty(WIA_IPS_PAGES, propType, Current);
end;

function TXICA_WIAItem.GetPages(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
var
   propType: TVarType;
   pFlags: TWIAPropertyFlags;
   intValues: TArrayInteger;

begin
  Result:= False;
  try
     pFlags:= GetProperty(WIA_IPS_PAGES, propType, Current, Default, intValues);

     Result:= (WIAProp_RANGE in pFlags) and (Length(intValues) = WIA_RANGE_NUM_ELEMS);

     if Result then
     begin
       AMin:= intValues[WIA_RANGE_MIN];
       AMax:= intValues[WIA_RANGE_MAX];
       AStep:= intValues[WIA_RANGE_STEP];
     end;

  finally
    intValues:= nil;
  end;
end;

function TXICA_WIAItem.SetPages(const Value: Integer): Boolean;
begin
  Result:= SetProperty(WIA_IPS_PAGES, VT_I4, Value);
end;

function TXICA_WIAItem.GetBrightness(out Current: Integer): Boolean;
var
   propType: TVarType;

begin
  Result:= GetProperty(WIA_IPS_BRIGHTNESS, propType, Current);
end;

function TXICA_WIAItem.GetBrightness(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
var
   propType: TVarType;
   pFlags: TWIAPropertyFlags;
   intValues: TArrayInteger;

begin
  Result:= False;
  try
     pFlags:= GetProperty(WIA_IPS_BRIGHTNESS, propType, Current, Default, intValues);
     { #note 5 -oMaxM : what to do if the propType is not the expected one VT_I4}

     Result:= (WIAProp_RANGE in pFlags) and (Length(intValues) = WIA_RANGE_NUM_ELEMS);

     if Result then
     begin
       AMin:= intValues[WIA_RANGE_MIN];
       AMax:= intValues[WIA_RANGE_MAX];
       AStep:= intValues[WIA_RANGE_STEP];
     end;

  finally
    intValues:= nil;
  end;
end;

function TXICA_WIAItem.SetBrightness(const Value: Integer): Boolean;
begin
  Result:= SetProperty(WIA_IPS_BRIGHTNESS, VT_I4, Value);
end;

function TXICA_WIAItem.GetContrast(out Current: Integer): Boolean;
var
   propType: TVarType;

begin
  Result:= GetProperty(WIA_IPS_CONTRAST, propType, Current);
end;

function TXICA_WIAItem.GetContrast(out Current, Default, AMin, AMax,
  AStep: Integer): Boolean;
var
   propType: TVarType;
   pFlags: TWIAPropertyFlags;
   intValues: TArrayInteger;

begin
  Result:= False;
  try
     pFlags:= GetProperty(WIA_IPS_CONTRAST, propType, Current, Default, intValues);
     { #note 5 -oMaxM : what to do if the propType is not the expected one VT_I4}

     Result:= (WIAProp_RANGE in pFlags) and (Length(intValues) = WIA_RANGE_NUM_ELEMS);

     if Result then
     begin
       AMin:= intValues[WIA_RANGE_MIN];
       AMax:= intValues[WIA_RANGE_MAX];
       AStep:= intValues[WIA_RANGE_STEP];
     end;

  finally
    intValues:= nil;
  end;
end;

function TXICA_WIAItem.SetContrast(const Value: Integer): Boolean;
begin
  Result:= SetProperty(WIA_IPS_CONTRAST, VT_I4, Value);
end;

function TXICA_WIAItem.GetImageFormat(out Current: TXICA_ImageFormat): Boolean;
var
   propType: TVarType;
   gValue: TGUID;

begin
  Result:= GetProperty(WIA_IPA_FORMAT, propType, gValue);
  if Result
  then Result:= WIAImageFormat(gValue, Current);
end;

function TXICA_WIAItem.GetImageFormat(out Current, Default: TXICA_ImageFormat; out Values: TXICA_ImageFormats): Boolean;
var
   i: Integer;
   gValues: TArrayGUID;
   propType: TVarType;
   pFlags: TWIAPropertyFlags;
   curValue: TXICA_ImageFormat;
   gValue: TGUID;

begin
  Result:= False;
  try
     Values:= [];

     //Does not return the Current and Default Values
     pFlags:= GetProperty(WIA_IPA_FORMAT, propType, Current, Default, gValues);
     if not(WIAProp_READ in pFlags) then Exit;

     if (WIAProp_LIST in pFlags) then
     for i:=0 to Length(gValues)-1 do
     begin
       Result:= WIAImageFormat(gValues[i], curValue);
       if Result
       then Values:= Values+[curValue];
       { #todo 2 -oMaxM : else Ignore it or return False? }
     end;

     //Default Values are not valid so we must take it in this way
     Current:= xifUNDEFINED;
     Default:= xifUNDEFINED;
     Result:= GetProperty(WIA_IPA_FORMAT, propType, gValue) and
              WIAImageFormat(gValue, Current);
     if not(Result) then exit;

     Result:= GetProperty(WIA_IPA_PREFERRED_FORMAT, propType, gValue) and
              WIAImageFormat(gValue, Default);

  finally
    gValues:= nil;
  end;
end;

function TXICA_WIAItem.SetImageFormat(const Value: TXICA_ImageFormat): Boolean;
begin
  Result:= SetProperty(WIA_IPA_FORMAT, VT_CLSID, WiaImageFormatGUID[Value]);
end;

function TXICA_WIAItem.GetDataType(out Current: TXICA_DataType): Boolean;
var
   propType: TVarType;

begin
  Result:= GetProperty(WIA_IPA_DATATYPE, propType, Current);
end;

function TXICA_WIAItem.GetDataType(out Current, Default: TXICA_DataType; out Values: TXICA_DataTypes): Boolean;
var
   i: Integer;
   intValues: TArrayInteger;
   propType: TVarType;
   pFlags: TWIAPropertyFlags;

begin
  Result:= False;
  try
     Values:= [];

     pFlags:= GetProperty(WIA_IPA_DATATYPE, propType, Current, Default, intValues);
     if not(WIAProp_READ in pFlags) then Exit;

     { #note 5 -oMaxM : what to do if the propType is not the expected one VT_I4}

     if (WIAProp_LIST in pFlags) then
     begin
       for i:=0 to Length(intValues)-1 do Values:= Values+[TXICA_DataType(intValues[i])];

       Result:= True;
     end;

  finally
    intValues:= nil;
  end;
end;

function TXICA_WIAItem.SetDataType(const Value: TXICA_DataType): Boolean;
begin
  Result:= SetProperty(WIA_IPA_DATATYPE, VT_I4, Value);
end;

function TXICA_WIAItem.GetBitDepth(out Current, Default: Integer; out Values: TArrayInteger): Boolean;
var
   propType: TVarType;
   pFlags: TWIAPropertyFlags;

begin
  pFlags:= GetProperty(WIA_IPA_DEPTH, propType, Current, Default, Values);
  Result:= (WIAProp_READ in pFlags) and (WIAProp_LIST in pFlags);
end;

function TXICA_WIAItem.GetBitDepth(out Current: Integer): Boolean;
var
   propType: TVarType;

begin
  Result:= GetProperty(WIA_IPA_DEPTH, propType, Current);
end;

function TXICA_WIAItem.SetBitDepth(const Value: Integer): Boolean;
begin
  Result:= SetProperty(WIA_IPA_DEPTH, VT_I4, Value);
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

(*oldcode
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

function TXICA_WiaDevice.GetSelectedPropertiesIntf: IWiaPropertyStorage;
begin
  Result:= nil;

  if (pSelectedItem = nil) then GetSelectedItemIntf;
  if (pSelectedItem <> nil)
  then Result:= pSelectedProperties;
end;
*)

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
   curItem: TXICA_WIAItem;

begin
  if (GetRootItemIntf = nil) then exit;

  lres:= pRootItem.EnumChildItems(nil, pIEnumItem);
  if (lres = S_OK) then
  begin
    lres:= pIEnumItem.GetCount(iCount);
    if (lres = S_OK) then
    begin
      if not(PreserveSelected) or (ALastSelected = nil)
      then  //Select the First item by default
            if (rSelectedIndex < 0) or (rSelectedIndex > iCount-1)
            then rSelectedIndex:= 0;


      (*oldcode
      //If there is an Item Selected free Interfaces pointers
      if (pSelectedItem <> nil) then
      begin
        pSelectedItem:= nil;
        pSelectedProperties:= nil;
      end;
      *)

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
                   curItem:= TXICA_WIAItem(ALastSelected);
                   curItem.ReleaseInterfaces;  //we will set the new interfaces below
                   Add(curName, ALastSelected);
                   SelectedIndex:= i;
                 end
            else begin
                   curItem:= TXICA_WIAItem.Create(Self, i, curName);
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

            (* better to keep the interface inside the item
            //if it is not the Selected Item release Interfaces pointers
            if (i <> rSelectedIndex) then
            begin
              pItem:= nil;
              pWiaPropertyStorage:= nil;
            end;
            *)

            curItem.pItem:= pItem;
            curItem.pProperties:= pWiaPropertyStorage;
          end;
        end
        else break;
      end;

      Result :=True;
    end;

    pIEnumItem:= nil;
  end;
end;

function TXICA_WiaDevice.GetType_Str: String;
begin
  if (rType in [devTypeUnknown..devTypeDigitalCamera])
  then Result:= inherited GetType_Str
  else if (Integer(rType) = StiDeviceTypeStreamingVideo)
       then Result:= 'Streaming Video'
       else Result:= 'Undefined ('+IntToStr(Integer(rType))+')';
end;

constructor TXICA_WiaDevice.Create(AOwner: TXICA_DeviceManager; AIndex: Integer; ADeviceID: String);
begin
  inherited Create(AOwner, AIndex, ADeviceID);

  pRootItem:= nil;
end;

destructor TXICA_WiaDevice.Destroy;
begin
  //Free the Interfaces
  pRootItem:= nil;

  inherited Destroy;
end;

function TXICA_WiaDevice.DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
                                          APath, AFileName: String;
                                          out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer;
var
   dlgFlags: LONG;
   i: Integer;
   filePaths: PBSTR;
   itemArray: PIWiaItem2;
   rDownloaded: Boolean;
   rDownload_Count: Integer;
   rDownload_Path,
   rDownload_Ext,
   rDownload_FileName: String;

begin
  Result:= 0;
  DownloadedFiles:= nil;

  if (TXICA_WIAManager(rOwner) = nil) or (TXICA_WIAManager(rOwner).pDevMgr = nil) then exit;

  try
     if (APath = '') or CharInSet(APath[Length(APath)], AllowDirectorySeparators)
     then rDownload_Path:= APath
     else rDownload_Path:= APath+DirectorySeparator;

     if not(ForceDirectories(rDownload_Path)) then exit;

     rDownload_FileName:= AFileName;
     rDownload_Ext:= '';
     rDownload_Count:= 0;
     rDownloaded:= False;

     if useSystemUI
     then dlgFlags:= WIA_DEVICE_DIALOG_USE_COMMON_UI
     else dlgFlags:= 0;

     filePaths:= nil;
     itemArray:= nil;

(*
     if (GetRootItemIntf = nil) then exit;

     //  Alternative but this works only with usb connected devices
     lres:= pRootItem.DeviceDlg(dlgFlags, hwndParent,
                                StringToOleStr(rDownload_Path), StringToOleStr(rDownload_FileName),
                                rDownload_Count, filePaths, itemArray);
*)

     lres:= TXICA_WIAManager(rOwner).pDevMgr.GetImageDlg(dlgFlags, StringToOleStr(Self.ID), hwndParent,
                                                         StringToOleStr(rDownload_Path), StringToOleStr(rDownload_FileName),
                                                         rDownload_Count, filePaths, itemArray);

     if (lres = S_OK) then
     begin
       //Copy filePaths to DownloadedFiles and Free elements
       SetLength(DownloadedFiles, rDownload_Count);
       for i:=0 to rDownload_Count-1 do
       begin
         DownloadedFiles[i]:= filePaths^[i];  { #todo 2 -oMaxM : Test if OleStrToString is necessary }

         if UseRelativePath then FullPathToRelativePath(rDownload_Path, DownloadedFiles[i]);

         SysFreeString(filePaths^[i]);
       end;

       Result:= rDownload_Count;
     end;
  finally
    if (filePaths <> nil) then CoTaskMemFree(filePaths);
    //if (itemArray <> nil) then CoTaskMemFree(itemArray); //the documentation says to release it but we always have Exception
  end;
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

  if (pDevMgr = nil) then pDevMgr:= WIA_LH.IWiaDevMgr2(CreateDevManager);
  if (pDevMgr <> nil) then
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

