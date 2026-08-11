(****************************************************************************
*                XICA (Cross-platform Image Capture Architecture)
*
*  FILE: XICA_Classes.pas
*
*  VERSION:     0.0.1
*
*  DESCRIPTION:
*    Base Manager and Device Classes,
*      the various image acquisition libraries must derive from these classes
*
*****************************************************************************
*
*  (c) 2026 Massimo Magnano
*
*  See changelog.txt for Change Log
*
*****************************************************************************)
unit XICA_Classes;

{$ifdef fpc}
  {$mode delphi}
{$endif}
{$H+}

interface

uses Classes, SysUtils,
     {$ifdef fpc}testutils,{$else}DelphiCompatibility, Types,{$endif}
     MM_OpenArrayList,
     XICA_Types;

resourcestring
  rsLandscape = 'Landscape';
  rsPortrait = 'Portrait';
  rsAutotype = 'Auto type';
  rsNoSelectedItem = 'No Selected Item in Device %s';

type
  TXICA_DeviceManager = class;
  TXICA_Device = class;
  TXICA_Item = class;

  { TXICA_Item }

  TXICA_Item = class(TNoRefCountObject)
  protected
    rOwner: TXICA_Device;
    rIndex: Integer;
    rName: String;
    lres: HResult;

    rPaperLandscape: Boolean;
    rXRes, rYRes: Integer;                  //if <=0 then i need to Get Values from Device
    rPaperWidth, rPaperHeight,
    rPaperDefaultWidth, rPaperDefaultHeight,
    rPaperMaxWidth, rPaperMaxHeight: Single;

    rPaperHAlign: TXICA_AlignHorizontal;
    rPaperVAlign: TXICA_AlignVertical;

    rParams: TXICA_Params;
    rCapabilities: TXICA_Capabilities;

    StreamDestination: TFileStream;
    StreamAdapter: TStreamAdapter;

    rDownloaded: Boolean;
    rDownload_Count: Integer;
    rDownload_Path,
    rDownload_Ext,
    rDownload_FileName: String;

(*oldcode    //Get Paper Width, Height form the Device (in Inches)
    function _GetPaperSize(out AWidth, AHeight: Single): Boolean; overload; virtual; abstract;
    function _GetPaperSize(out AWidth, AHeight, ADefaultWidth, ADefaultHeight: Single): Boolean; overload; virtual; abstract;
*)
    //Get Max Paper Width, Height form the Device (in Inches)
    function _GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean; virtual; abstract;

    class function ParamsClass: TXICA_ParamsClass; virtual;
    class function CapabilitiesClass: TXICA_CapabilitiesClass; virtual;

  public
    Type_: TXICA_ItemTypes;
    SubType: Word;
    Category: TXICA_ItemCategory;
    Version,
    VersionSub: Integer;

    constructor Create(AOwner: TXICA_Device; AIndex: Integer; AName: String); virtual;
    destructor Destroy; override;

    //Download the Selected Item and return the number of files transfered.
    // if multiple pages is downloaded then the file names are
    // APath\AFileName-n.AExt where n is then Index (when 0 n is not present)
    function Download(APath, AFileName, AExt: String): Integer; overload; virtual; abstract;
    function Download(APath, AFileName, AExt: String; AFormat: TXICA_ImageFormat): Integer; overload; virtual;
    function Download(APath, AFileName, AExt: String; AFormat: TXICA_ImageFormat;
                      out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer; overload; virtual;

    //Get Available Values for XResolution,
    //  if Result contain the Flag prop_RANGE then use propRANGE_XXX Indexes to get MIN/MAX/STEP Values
    function GetResolutionsX(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags; virtual; abstract;
    //Get Available Values for YResolutions
    function GetResolutionsY(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags; virtual; abstract;

    //Get the Minimun and Maximum Resolutions Values
    function GetResolutionsLimit(out AMin, AMax: Integer): Boolean; overload; virtual;
    function GetResolutionsLimit(out AMinX, AMaxX, AMinY, AMaxY: Integer): Boolean; overload; virtual;

    //Get Current Resolutions
    function GetResolution(out AXRes, AYRes: Integer): Boolean; virtual; abstract;

    //Set Current Resolutions, The user is responsible for checking the validity of the values
    function SetResolution(const AXRes, AYRes: Integer): Boolean; virtual; abstract;

    //Get Paper Width, Height (in Inches)
    function GetPaperSize(out AWidth, AHeight: Single): Boolean; overload; virtual;
    function GetPaperSize(out AWidth, AHeight, ADefaultWidth, ADefaultHeight: Single): Boolean; overload; virtual;

    //Get Max Paper Width, Height (in Inches)
    function GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean; virtual;

    //Set Current Paper Size (in Inches), the Area is calculated using Width, Height, Orientation and Align Values
    function SetPaperSize(Width, Height: Single): Boolean; virtual;

    //Get Current Paper Rect (in Pixels)
    function GetPaperRect(out Current: TRect): Boolean; overload; virtual; abstract;
    function GetPaperRect(out Current, Default: TRect): Boolean; overload; virtual; abstract;

    //Set Current Paper Rect (in Pixels)
    function SetPaperRect(const X, Y, Width, Height: Integer): Boolean; virtual; abstract;

    //Get Current Paper Align
    function GetPaperAlign(out ALandscape:Boolean; out HAlign: TXICA_AlignHorizontal; out VAlign: TXICA_AlignVertical): Boolean; virtual;
    //Set Current Paper Align
    function SetPaperAlign(const ALandscape:Boolean; const HAlign: TXICA_AlignHorizontal; const VAlign: TXICA_AlignVertical): Boolean; virtual;

    //Get Current Paper Type
    function GetPaperType(out Current: TXICA_PaperType): Boolean; overload; virtual;

    //Get Available Paper Sizes
    function GetPaperType(out Current, Default: TXICA_PaperType; out Values: TXICA_PaperTypes): Boolean; overload; virtual;

    //Set Current Paper Type,
    function SetPaperType(const Value: TXICA_PaperType): Boolean; virtual;

    //Get Current Paper Landscape,
    function GetPaperLandscape(out Value: Boolean): Boolean; virtual;

    //Set Current Paper Landscape,
    function SetPaperLandscape(const Value: Boolean): Boolean; virtual;

     //Get Current Rotation, not to be confused with PaperLandscape
    function GetRotation(out Value: TXICA_Rotation): Boolean; overload; virtual; abstract;
    //Get Available Rotations
    function GetRotation(out Current, Default: TXICA_Rotation; out Values: TXICA_Rotations): Boolean; overload; virtual; abstract;

    //Set Current Rotation, not to be confused with PaperLandscape,
    //  this function rotate the image after capturing it
    function SetRotation(const Value: TXICA_Rotation): Boolean; virtual; abstract;

    //Get Current DocumentHandling,
    function GetDocumentHandling(out Value: TXICA_DocumentHandlings): Boolean; overload; virtual; abstract;
    //Get Available DocumentHandling
    function GetDocumentHandling(out Current, Default, Values: TXICA_DocumentHandlings): Boolean; overload; virtual; abstract;

    //Set Current DocumentHandling,
    function SetDocumentHandling(const Value: TXICA_DocumentHandlings): Boolean; virtual; abstract;

    //Get Current Pages (0 = All)
    function GetPages(out Current: Integer): Boolean; overload; virtual; abstract;
    //Get Current, Default and Range Values for Pages
    function GetPages(out Current, Default, AMin, AMax, AStep: Integer): Boolean; overload; virtual; abstract;

    //Set Current Pages (0 = All)
    //  If a Feeder Scanner is unable to scan only one side of a page while in Duplex you must use an even value
    function SetPages(const Value: Integer): Boolean; virtual; abstract;

    //Get Current Brightness
    function GetBrightness(out Current: Integer): Boolean; overload; virtual; abstract;
    //Get Current, Default and Range Values for Brightness
    function GetBrightness(out Current, Default, AMin, AMax, AStep: Integer): Boolean; overload; virtual; abstract;

    //Set Current Brightness, The user is responsible for checking the validity of the value
    function SetBrightness(const Value: Integer): Boolean; virtual; abstract;

    //Get Current Contrast
    function GetContrast(out Current: Integer): Boolean; overload; virtual; abstract;
    //Get Current, Default and Range Values for Contrast
    function GetContrast(out Current, Default, AMin, AMax, AStep: Integer): Boolean; overload; virtual; abstract;

    //Set Current Contrast, The user is responsible for checking the validity of the value
    function SetContrast(const Value: Integer): Boolean; virtual; abstract;

    //Get Current Image Format
    function GetImageFormat(out Current: TXICA_ImageFormat): Boolean; overload; virtual; abstract;
    //Get Available Image Formats
    function GetImageFormat(out Current, Default: TXICA_ImageFormat; out Values: TXICA_ImageFormats): Boolean; overload; virtual; abstract;

    //Set Current Image Format
    function SetImageFormat(const Value: TXICA_ImageFormat): Boolean; virtual; abstract;

     //Get Current Image DataType
    function GetDataType(out Current: TXICA_DataType): Boolean; overload; virtual; abstract;
    //Get Available Image DataTypes
    function GetDataType(out Current, Default: TXICA_DataType; out Values: TXICA_DataTypes): Boolean; overload; virtual; abstract;

    //Set Current Image DataType
    function SetDataType(const Value: TXICA_DataType): Boolean; virtual; abstract;

    //Get Current BitDepth
    function GetBitDepth(out Current: Integer): Boolean; overload; virtual; abstract;
    //Get Available Values for BitDepth
    function GetBitDepth(out Current, Default: Integer; out Values: TArrayInteger): Boolean; overload; virtual; abstract;

    //Set Current BitDepth, The user is responsible for checking the validity of the value
    function SetBitDepth(const Value: Integer): Boolean; virtual; abstract;

    //Get Capabilities for this Item
    //  To avoid getting the capabilities from the device every time you access the property,
    //  it is recommended to use a Local Variable and access the property only once.
    function GetCapabilities: TXICA_Capabilities; virtual;

    //Get Params for this Item
    //  This is YOUR Params
    function GetParams: TXICA_Params; virtual;

    //Set Params for this Item
    procedure SetParams(const AParams: TXICA_Params); virtual;

    property Name: String read rName;

    property Params: TXICA_Params read GetParams write SetParams;
    property Capabilities: TXICA_Capabilities read GetCapabilities;
  end;
  PXICA_Item = ^TXICA_Item;
  TArrayXICA_Item = array of TXICA_Item;

  { TXICA_Device }

  // UI Settings of Source Device
  TInitialItemValues = (initDefault, initParams, initCurrent);
  TInitDefaultValuesEvent = procedure (var ACap: TXICA_Capabilities) of object;

  TXICA_SettingsDialogFunc = function (ADevice: TXICA_Device;
                                       var ASelectedItemIndex: Integer;
                                       { #todo -oMaxM : Possibly Filters for which Items Kinds to Show? How manage AParams without Indexes? }
                                       AInitItemValues: TInitialItemValues;
                                       var AParams: TArrayXICA_Params;
                                       AOnInitDefaultValues: TInitDefaultValuesEvent=nil): Boolean;

  TXICA_OnDeviceTransfer = function (ADevice: TXICA_Device; AItem: TXICA_Item
                                     (*lFlags: LONG; pWiaTransferParams: PWiaTransferParams*)): Boolean of object;


  TXICA_Device = class(
                       TOpenArrayList<TXICA_Item, TKeyString>
                       { #todo -oMaxM : Create a Unit with Bridge to other languages }
                       //,IOpenArrayListR<TXICA_Item, TKeyString>
                       //,IOpenArrayListW<TXICA_Item, TKeyString>
                       )
  protected
    rOwner: TXICA_DeviceManager;
    rIndex: Integer;
    rID,
    rManufacturer,
    rName: String;
    rType: TXICA_DeviceType;
    rSubType: Word;
    rVersion,
    rVersionSub: Integer;
    lres: HResult;

    HasEnumerated: Boolean;

    rOnAfterDeviceTransfer,
    rOnBeforeDeviceTransfer: TXICA_OnDeviceTransfer;

    function FreeElement(var aData: TXICA_Item): Boolean; override;

    //Enumerate the avaliable items
    function _EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean; virtual; abstract;
    function EnumerateItems(PreserveSelected: Boolean): Boolean;


    class function SettingsDialogFunc: TXICA_SettingsDialogFunc; virtual; abstract;

    function GetType_Str: String; virtual;

  public
    constructor Create(AOwner: TXICA_DeviceManager; AIndex: Integer; ADeviceID: String); virtual;
    destructor Destroy; override;

    function GetCount: DWord; override;

    //Refresh the item list
    procedure Refresh(PreserveSelected: Boolean=True);

    // ALL the following methods calls then same method of Selected Item, if there is no Selected Item raise an Exception

    //Download the Selected Item and return the number of files transfered.
    // if multiple pages is downloaded then the file names are
    // APath\AFileName-n.AExt where n is then Index (when 0 n is not present)
    function Download(APath, AFileName, AExt: String): Integer; overload; virtual;
    function Download(APath, AFileName, AExt: String; AFormat: TXICA_ImageFormat): Integer; overload; virtual;
    function Download(APath, AFileName, AExt: String; AFormat: TXICA_ImageFormat;
                      out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer; overload; virtual;

    //Download using Native UI and return the number of files transfered in DownloadedFiles array.
    //  The system dialog works at Device level, so the selected item is ignored
    function DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
                              APath, AFileName: String;
                              out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer; virtual; abstract;

    //Get Available Values for XResolution,
    //  if Result contain the Flag prop_RANGE then use propRANGE_XXX Indexes to get MIN/MAX/STEP Values
    function GetResolutionsX(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags; virtual;
    //Get Available Values for YResolutions
    function GetResolutionsY(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags; virtual;

    //Get the Minimun and Maximum Resolutions Values
    function GetResolutionsLimit(out AMin, AMax: Integer): Boolean; overload; virtual;
    function GetResolutionsLimit(out AMinX, AMaxX, AMinY, AMaxY: Integer): Boolean; overload; virtual;

    //Get Current Resolutions
    function GetResolution(out AXRes, AYRes: Integer): Boolean; virtual;

    //Set Current Resolutions, The user is responsible for checking the validity of the values
    function SetResolution(const AXRes, AYRes: Integer): Boolean; virtual;

    //Get Paper Width, Height (in Inches)
    function GetPaperSize(out AWidth, AHeight: Single): Boolean; overload; virtual;

    //Get Paper Width, Height (in Inches)
    function GetPaperSize(out AWidth, AHeight, ADefaultWidth, ADefaultHeight: Single): Boolean; overload; virtual;

    //Get Max Paper Width, Height (in Inches)
    function GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean; virtual;

    //Set Current Paper Size (in Inches), the Area is calculated using Width, Height, Orientation and Align Values
    function SetPaperSize(Width, Height: Single): Boolean; virtual;

    //Get Current Paper Rect (in Pixels)
    //Get Current Paper Rect (in Pixels)
    function GetPaperRect(out Current: TRect): Boolean; overload; virtual;
    function GetPaperRect(out Current, Default: TRect): Boolean; overload; virtual;

    //Set Current Paper Rect (in Pixels)
    function SetPaperRect(const X, Y, Width, Height: Integer): Boolean; virtual;

    //Get Current Paper Align
    function GetPaperAlign(out ALandscape:Boolean; out HAlign: TXICA_AlignHorizontal; out VAlign: TXICA_AlignVertical): Boolean; virtual;
    //Set Current Paper Align
    function SetPaperAlign(const ALandscape:Boolean; const HAlign: TXICA_AlignHorizontal; const VAlign: TXICA_AlignVertical): Boolean; virtual;

    //Get Current Paper Type
    function GetPaperType(out Current: TXICA_PaperType): Boolean; overload; virtual;

    //Get Available Paper Sizes
    function GetPaperType(out Current, Default: TXICA_PaperType; out Values: TXICA_PaperTypes): Boolean; overload; virtual;

    //Set Current Paper Type,
    function SetPaperType(const Value: TXICA_PaperType): Boolean; virtual;

    //Get Current Paper Landscape,
    function GetPaperLandscape(out Value: Boolean): Boolean; virtual;

    //Set Current Paper Landscape,
    function SetPaperLandscape(const Value: Boolean): Boolean; virtual;

     //Get Current Rotation, not to be confused with PaperLandscape
    function GetRotation(out Value: TXICA_Rotation): Boolean; overload; virtual;
    //Get Available Rotations
    function GetRotation(out Current, Default: TXICA_Rotation; out Values: TXICA_Rotations): Boolean; overload; virtual;

    //Set Current Rotation, not to be confused with PaperLandscape,
    //  this function rotate the image after capturing it
    function SetRotation(const Value: TXICA_Rotation): Boolean; virtual;

    //Get Current DocumentHandling,
    function GetDocumentHandling(out Value: TXICA_DocumentHandlings): Boolean; overload; virtual;
    //Get Available DocumentHandling
    function GetDocumentHandling(out Current, Default, Values: TXICA_DocumentHandlings): Boolean; overload; virtual;

    //Set Current DocumentHandling,
    function SetDocumentHandling(const Value: TXICA_DocumentHandlings): Boolean; virtual;

    //Get Current Pages (0 = All)
    function GetPages(out Current: Integer): Boolean; overload; virtual;
    //Get Current, Default and Range Values for Pages
    function GetPages(out Current, Default, AMin, AMax, AStep: Integer): Boolean; overload; virtual;

    //Set Current Pages (0 = All)
    //  If a Feeder Scanner is unable to scan only one side of a page while in Duplex you must use an even value
    function SetPages(const Value: Integer): Boolean; virtual;

    //Get Current Brightness
    function GetBrightness(out Current: Integer): Boolean; overload; virtual;
    //Get Current, Default and Range Values for Brightness
    function GetBrightness(out Current, Default, AMin, AMax, AStep: Integer): Boolean; overload; virtual;

    //Set Current Brightness, The user is responsible for checking the validity of the value
    function SetBrightness(const Value: Integer): Boolean; virtual;

    //Get Current Contrast
    function GetContrast(out Current: Integer): Boolean; overload; virtual;
    //Get Current, Default and Range Values for Contrast
    function GetContrast(out Current, Default, AMin, AMax, AStep: Integer): Boolean; overload; virtual;

    //Set Current Contrast, The user is responsible for checking the validity of the value
    function SetContrast(const Value: Integer): Boolean; virtual;

    //Get Current Image Format
    function GetImageFormat(out Current: TXICA_ImageFormat): Boolean; overload; virtual;
    //Get Available Image Formats
    function GetImageFormat(out Current, Default: TXICA_ImageFormat; out Values: TXICA_ImageFormats): Boolean; overload; virtual;

    //Set Current Image Format
    function SetImageFormat(const Value: TXICA_ImageFormat): Boolean; virtual;

     //Get Current Image DataType
    function GetDataType(out Current: TXICA_DataType): Boolean; overload; virtual;
    //Get Available Image DataTypes
    function GetDataType(out Current, Default: TXICA_DataType; out Values: TXICA_DataTypes): Boolean; overload; virtual;

    //Set Current Image DataType
    function SetDataType(const Value: TXICA_DataType): Boolean; virtual;

    //Get Current BitDepth
    function GetBitDepth(out Current: Integer): Boolean; overload; virtual;
    //Get Available Values for BitDepth
    function GetBitDepth(out Current, Default: Integer; out Values: TArrayInteger): Boolean; overload; virtual;

    //Set Current BitDepth, The user is responsible for checking the validity of the value
    function SetBitDepth(const Value: Integer): Boolean; virtual;

    //Get Capabilities for Current Selected Item
    function GetCapabilities: TXICA_Capabilities; virtual;

    //Get Params for Current Selected Item
    function GetParams: TXICA_Params; virtual;

    //Set Params for Current Selected Item
    procedure SetParams(const AParams: TXICA_Params); virtual;

    //Display a dialog to let the user choose Settings of the Device
    function SettingsDeviceDialog(var ASelectedItemIndex: Integer;
                                  { #todo -oMaxM : Possibly Filters for which Items Kinds to Show? How manage AParams without Indexes? }
                                  AInitItemValues: TInitialItemValues;
                                  var AParams: TArrayXICA_Params;
                                  AOnInitDefaultValues: TInitDefaultValuesEvent=nil): Boolean; virtual;

    property ID: String read rID;
    property Manufacturer: String read rManufacturer;
    property Name: String read rName;
    property Type_: TXICA_DeviceType read rType;
    property Type_Str: String read GetType_Str;
    property SubType: Word read rSubType;

    //Version and SubVersion of Device
    property Version: Integer read rVersion write rVersion;
    property VersionSub: Integer read rVersionSub write rVersionSub;

    property Params: TXICA_Params read GetParams write SetParams;
    property Capabilities: TXICA_Capabilities read GetCapabilities;

    //Events
    property OnBeforeDeviceTransfer: TXICA_OnDeviceTransfer read rOnBeforeDeviceTransfer write rOnBeforeDeviceTransfer;
    property OnAfterDeviceTransfer: TXICA_OnDeviceTransfer read rOnAfterDeviceTransfer write rOnAfterDeviceTransfer;
  end;

  { TXICA_DeviceManager }

  TXICA_SelectDialogFunc = function (ADeviceManager: TXICA_DeviceManager): Integer;

  TXICA_OnDeviceManagerTransfer = function (ADeviceManager: TXICA_DeviceManager; AWiaDevice: TXICA_Device
                                     (*lFlags: LONG; pWiaTransferParams: PWiaTransferParams*)): Boolean of object;

  TXICA_DeviceManager = class(TOpenArrayList<TXICA_Device, TKeyString>)
  protected
    rVersion,
    rVersionSub: Integer;
    rEnumAll: Boolean;
    lres: HResult;
    HasEnumerated: Boolean;
    rOnAfterDeviceTransfer,
    rOnBeforeDeviceTransfer: TXICA_OnDeviceManagerTransfer;

    function FreeElement(var aData: TXICA_Device): Boolean; override;

    //Enumerate the avaliable devices
    function _EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean; virtual; abstract;
    function EnumerateDevices(PreserveSelected: Boolean): Boolean;

    class function SelectDialogFunc: TXICA_SelectDialogFunc; virtual; abstract;

  public
    constructor Create(const AEnumAll: Boolean = True);
    destructor Destroy; override;

    //Clears the list of devices
    function Clear: Boolean; override;

    function GetCount: DWord; override;

    //Refresh the list of devices
    procedure Refresh(const PreserveSelected: Boolean=True);

    //Display a dialog to let the user choose a Device and returns it's index
    function SelectDeviceDialog: Integer; virtual;

    //Finds a matching Device index
    //  to Find Device by ID use FindByKey(ID)
    //  to Find Device by it's class use Find(Value: TXICA_Device)
    //  Find Device by it's Name (set Manufacturer to '' to Find only by Name)
    function Find(const AName, AManufacturer: String): Integer; overload; virtual;

    //Find a Device by it's ID and Select the given Item
    procedure SelectDeviceItem(const ADeviceID, ADeviceItem: String; out ADevice: TXICA_Device; out ADeviceItemIndex: Integer);

    //Name of the Library
    class function Name: String; virtual; abstract;

    //Version and SubVersion of Library
    property Version: Integer read rVersion write rVersion;
    property VersionSub: Integer read rVersionSub write rVersionSub;

    //Kind of Enum, if True Enum even disconnected Devices
    property EnumAll: Boolean read rEnumAll write rEnumAll;

    //Events
    property OnBeforeDeviceTransfer: TXICA_OnDeviceManagerTransfer read rOnBeforeDeviceTransfer write rOnBeforeDeviceTransfer;
    property OnAfterDeviceTransfer: TXICA_OnDeviceManagerTransfer read rOnAfterDeviceTransfer write rOnAfterDeviceTransfer;
  end;

procedure VersionStrToInt(const s: String; const ADevice: TXICA_Device); overload;

implementation

uses math, XICA_PaperSizes;


procedure VersionStrToInt(const s: String; const ADevice: TXICA_Device); overload;
var
   rVer, rVerSub: Integer;

begin
  VersionStrToInt(s, rVer, rVerSub);
  ADevice.Version:= rVer;
  ADevice.VersionSub:= rVerSub;
end;


{ TXICA_Item }

class function TXICA_Item.ParamsClass: TXICA_ParamsClass;
begin
  Result:= TXICA_Params;
end;

class function TXICA_Item.CapabilitiesClass: TXICA_CapabilitiesClass;
begin
  Result:= TXICA_Capabilities;
end;

constructor TXICA_Item.Create(AOwner: TXICA_Device; AIndex: Integer; AName: String);
begin
  inherited Create;

  rOwner:= AOwner;
  rIndex:= AIndex;
  rName:= AName;

  rParams:= nil;
  rCapabilities:= nil;

  StreamAdapter:= nil;
  StreamDestination:= nil;
  rDownload_Path:= '';
  rDownload_Ext:= '';
  rDownload_FileName:= '';
  rDownload_Count:= 0;
  rDownloaded:= False;

  rPaperLandscape:= False;
  rXRes:= -1; rYRes:= -1;
  rPaperWidth:= -1; rPaperHeight:= -1;
  rPaperDefaultWidth:= -1; rPaperDefaultHeight:= -1;
  rPaperMaxWidth:= -1; rPaperMaxHeight:= -1;
  rPaperVAlign:= xaVTop;
  rPaperHAlign:= xaHLeft;
end;

destructor TXICA_Item.Destroy;
begin
  if (rParams <> nil) then rParams.Free;
  if (rCapabilities <> nil) then rCapabilities.Free;

  inherited Destroy;
end;

function TXICA_Item.Download(APath, AFileName, AExt: String; AFormat: TXICA_ImageFormat): Integer;
begin
  Result:= 0;

  if SetImageFormat(AFormat) then Result:= Download(APath, AFileName, AExt);
end;

function TXICA_Item.Download(APath, AFileName, AExt: String; AFormat: TXICA_ImageFormat;
                             out DownloadedFiles: TStringArray; UseRelativePath: Boolean): Integer;
var
   i: Integer;

begin
  Result:= 0;
  DownloadedFiles:= nil;

  if SetImageFormat(AFormat) then
  begin
    Result:= Download(APath, AFileName, AExt);
    if (Result > 0 ) then
    begin
      SetLength(DownloadedFiles, Result);

      if UseRelativePath
      then begin
             DownloadedFiles[0]:= rDownload_FileName+rDownload_Ext;
             for i:=1 to Result-1 do
               DownloadedFiles[i]:= rDownload_FileName+'-'+IntToStr(i)+rDownload_Ext;
           end
      else begin
             DownloadedFiles[0]:= rDownload_Path+rDownload_FileName+rDownload_Ext;
             for i:=1 to Result-1 do
               DownloadedFiles[i]:= rDownload_Path+rDownload_FileName+'-'+IntToStr(i)+rDownload_Ext;
           end;
    end;
  end;
end;

function TXICA_Item.GetResolutionsLimit(out AMin, AMax: Integer): Boolean;
var
   Current,
   Default: Integer;
   pFlags: TXICA_PropertyFlags;
   Values: TArrayInteger;

begin
  Result:= False;
  try
     pFlags:= GetResolutionsX(Current, Default, Values);
     if not(prop_READ in pFlags) then exit;

     if (prop_RANGE in pFlags)
     then begin
            AMin:= Values[prop_RANGE_MIN];
            AMax:= Values[prop_RANGE_MAX];
            Result:= True;
        end
     else
     if (prop_LIST in pFlags)
     then begin
            //In theory the minimum is the first value and the maximum is the last,
            //  but you never know a little paranoia doesn't hurt
            AMin:= MaxInt;
            AMax:= 0;
            for Current:=0 to Length(Values)-1 do
            begin
              if (Values[Current] < AMin) then AMin:= Values[Current];
              if (Values[Current] > AMax) then AMax:= Values[Current];
            end;
            Result:= True;
          end;

  finally
    Values:= nil;
  end;
end;

function TXICA_Item.GetResolutionsLimit(out AMinX, AMaxX, AMinY, AMaxY: Integer): Boolean;
var
   propType: TVarType;
   Current,
   Default: Integer;
   pFlags: TXICA_PropertyFlags;
   ValuesX,
   ValuesY: TArrayInteger;

begin
  Result:= False;
  try
     pFlags:= GetResolutionsX(Current, Default, ValuesX);
     if not(prop_READ in pFlags) then exit;

     pFlags:= GetResolutionsY(Current, Default, ValuesY);
     if not(prop_READ in pFlags) then exit;

     if (prop_RANGE in pFlags)
     then begin
            AMinX:= ValuesX[prop_RANGE_MIN];
            AMaxX:= ValuesX[prop_RANGE_MAX];
            AMinY:= ValuesY[prop_RANGE_MIN];
            AMaxY:= ValuesY[prop_RANGE_MAX];
            Result:= True;
        end
     else
     if (prop_LIST in pFlags)
     then begin
            //In theory the minimum is the first value and the maximum is the last,
            //  but you never know a little paranoia doesn't hurt
            AMinX:= MaxInt;
            AMaxX:= 0;
            AMinY:= MaxInt;
            AMaxY:= 0;
            for Current:=0 to Length(ValuesX)-1 do
            begin
              if (ValuesX[Current] < AMinX) then AMinX:= ValuesX[Current];
              if (ValuesX[Current] > AMaxX) then AMaxX:= ValuesX[Current];
              try
                 //Y may have a different size than X, use try/except block
                 if (ValuesY[Current] < AMinY) then AMinY:= ValuesY[Current];
                 if (ValuesY[Current] > AMaxY) then AMaxY:= ValuesY[Current];
              except
              end;
            end;
            Result:= True;
          end;

  finally
    ValuesX:= nil;
    ValuesY:= nil;
  end;
end;

function TXICA_Item.GetPaperSize(out AWidth, AHeight: Single): Boolean;
var
   pRect: TRect;

begin
  Result:= (rPaperWidth > 0) and (rPaperHeight > 0);

  if not(Result) then
  begin
    if (rXRes = -1) or (rYRes = -1)
    then if not(GetResolution(rXRes, rYRes)) then Exit;

    Result:= GetPaperRect(pRect);
    if Result then
    begin
      rPaperWidth:= pRect.Width/rXRes;
      rPaperHeight:= pRect.Height/rYRes;

      { #todo -oMaxM : Calculate the Aligns ? }
    end;
  end;

  if Result then
  begin
    AWidth:= rPaperWidth;
    AHeight:= rPaperHeight;
  end;
end;

function TXICA_Item.GetPaperSize(out AWidth, AHeight, ADefaultWidth, ADefaultHeight: Single): Boolean;
var
   pRect, pDefRect: TRect;
   defXRes,defYRes: Integer;
   iRes: TArrayInteger;

begin
  Result:= (rPaperWidth > 0) and (rPaperHeight > 0) and
           (rPaperDefaultWidth > 0) and (rPaperDefaultHeight > 0);

  if not(Result) then
  begin
    if (rXRes = -1) or (rYRes = -1)
    then if not(prop_Read in GetResolutionsX(rXRes, defXRes, iRes)) or
            not(prop_Read in GetResolutionsY(rYRes, defYRes, iRes)) then Exit; { #todo -oMaxM : Default Rect is in Default Resolutions ? }

    Result:= GetPaperRect(pRect, pDefRect);
    if Result then
    begin
      rPaperWidth:= pRect.Width/rXRes;
      rPaperHeight:= pRect.Height/rYRes;

      rPaperDefaultWidth:= pDefRect.Width/defXRes;
      rPaperDefaultHeight:= pDefRect.Height/defYRes;
      { #todo -oMaxM : Calculate the Aligns ? }
    end;
  end;

  if Result then
  begin
    AWidth:= rPaperWidth;
    AHeight:= rPaperHeight;
    ADefaultWidth:= rPaperDefaultWidth;
    ADefaultHeight:= rPaperDefaultHeight;
  end;
end;

function TXICA_Item.GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean;
begin
  if (rPaperWidth > 0) and (rPaperHeight > 0)
  then Result:= True
  else Result:= _GetPaperSizeMax(rPaperMaxWidth, rPaperMaxHeight);

  if Result then
  begin
    AMaxWidth:= rPaperMaxWidth;
    AMaxHeight:= rPaperMaxHeight;
  end;
end;

function TXICA_Item.SetPaperSize(Width, Height: Single): Boolean;
var
   MaxWidth,
   MaxHeight,
   swapS,
   X, Y: Single;

begin
  Result:= GetPaperSizeMax(MaxWidth, MaxHeight);
  if not(Result) then Exit;

  Result:= False;

  if (rXRes = -1) or (rYRes = -1)
  then if not(GetResolution(rXRes, rYRes)) then Exit;

  if (rPaperLandscape) then
  begin
    //Swap Width with Height
    swapS:= Width;
    Width:= Height;
    Height:= swapS;
  end;

  Case rPaperHAlign of
  xaHLeft: X:= 0;
  xaHCenter: X:= Round((MaxWidth-Width) / 2);
  xaHRight: X:= MaxWidth-Width;
  end;

  Case rPaperVAlign of
  xaVTop: Y:= 0;
  xaVCenter: Y:= Round((MaxHeight-Height) / 2);
  xaVBottom: Y:= MaxHeight-Height;
  end;

  //I prefer to be less restrictive and do the scan
  if (X < 0) then X:= 0;
  if (X > MaxWidth) then X:= MaxWidth;
  if (Y < 0) then Y:= 0;
  if (Y > MaxHeight) then Y:= MaxHeight;

  //if (X+Width > MaxWidth) or (Y+Height > MaxHeight) then Exit; //Be restrictive

  Result:= SetPaperRect(Trunc(X*rXRes), Trunc(Y*rYRes), Trunc(Width*rXRes), Trunc(Height*rYRes));
end;

function TXICA_Item.GetPaperAlign(out ALandscape: Boolean; out HAlign: TXICA_AlignHorizontal; out VAlign: TXICA_AlignVertical): Boolean;
begin
  HAlign:= rPaperHAlign;
  VAlign:= rPaperVAlign;
  Result:= GetPaperLandscape(ALandscape);
end;

function TXICA_Item.SetPaperAlign(const ALandscape: Boolean; const HAlign: TXICA_AlignHorizontal; const VAlign: TXICA_AlignVertical): Boolean;
begin
  Result:= SetPaperLandscape(ALandscape);
  if Result then
  begin
    rPaperHAlign:= HAlign;
    rPaperVAlign:= VAlign;
  end;
end;

function TXICA_Item.GetPaperType(out Current: TXICA_PaperType): Boolean;
var
   sMaxWidth,
   sMaxHeight,
   sWidth,
   sHeight: Single;

begin
  Result:= GetPaperSize(sWidth, sHeight);

  if Result
  then begin
         Result:= GetPaperSizeMax(sMaxWidth, sMaxHeight);

         if SameValue(sWidth, sMaxWidth) and SameValue(sHeight, sMaxHeight)
         then Current:= ptMAX
         else Current:= CalculatePaperSize(sWidth, sHeight);
       end
  else Current:= ptMAX;
end;

function TXICA_Item.GetPaperType(out Current, Default: TXICA_PaperType; out Values: TXICA_PaperTypes): Boolean;
var
   sMaxWidth,
   sMaxHeight,
   sWidth, sDefWidth,
   sHeight, sDefHeight: Single;

begin
  Result:= False;
  Values:= [];

  Result:= GetPaperSizeMax(sMaxWidth, sMaxHeight);
  if Result then
  begin
    Values:= CalculatePaperSizeSet(sMaxWidth, sMaxHeight);

    Result:= GetPaperSize(sWidth, sHeight, sDefWidth, sDefHeight);
    if Result then
    begin
      if SameValue(sWidth, sMaxWidth) and SameValue(sHeight, sMaxHeight)
      then Current:= ptMAX
      else Current:= CalculatePaperSize(sWidth, sHeight);

      if SameValue(sDefWidth, sMaxWidth) and SameValue(sDefHeight, sMaxHeight)
      then Default:= ptMAX
      else Default:= CalculatePaperSize(sDefWidth, sDefHeight);
    end;
  end;

  if not(Result) then
  begin
    Current:= ptMAX;
    Default:= ptMAX;
  end;
end;

function TXICA_Item.SetPaperType(const Value: TXICA_PaperType): Boolean;
var
   propType: TVarType;
   MaxWidth,
   MaxHeight,
   Width,
   Height,
   X, Y: Single;

begin
  Result:= GetPaperSizeMax(MaxWidth, MaxHeight);
  if not(Result) then Exit;

  Result:= False;

  if (rXRes = -1) or (rYRes = -1)
  then if not(GetResolution(rXRes, rYRes)) then  Exit;

  //if ptMAX then assigns the entire area,
  //otherwise check if the real paper size fits within the entire area
  if (Value = ptMAX)
  then begin
         Width:= MaxWidth;
         Height:= MaxHeight;
         //we deliberately ignore Aligments because we cannot rotate/align the maximum size
         X:= 0;
         Y:= 0;
       end
  else begin
         if (rPaperLandscape)
         then begin
                //Swap Width with Height
                Width:= PaperSizes[False, Value].h;
                Height:= PaperSizes[False, Value].w;
              end
         else begin
                Width:= PaperSizes[False, Value].w;
                Height:= PaperSizes[False, Value].h;
              end;

         Case rPaperHAlign of
         xaHLeft: X:= 0;
         xaHCenter: X:= (MaxWidth-Width) / 2;
         xaHRight: X:= MaxWidth-Width;
         end;

         Case rPaperVAlign of
         xaVTop: Y:= 0;
         xaVCenter: Y:= (MaxHeight-Height) / 2;
         xaVBottom: Y:= MaxHeight-Height;
         end;

         //I prefer to be less restrictive and do the scan
         if (X < 0) then X:= 0;
         if (X > MaxWidth) then X:= MaxWidth;
         if (Y < 0) then Y:= 0;
         if (Y > MaxHeight) then Y:= MaxHeight;

         //if (X+Width > MaxWidth) or (Y+Height > MaxHeight) then Exit; //Be restrictive
       end;

  Result:= SetPaperRect(Trunc(X*rXRes), Trunc(Y*rYRes), Trunc(Width*rXRes), Trunc(Height*rYRes));
end;

function TXICA_Item.GetPaperLandscape(out Value: Boolean): Boolean;
begin
  Value:= rPaperLandscape;
  Result:= True;
end;

function TXICA_Item.SetPaperLandscape(const Value: Boolean): Boolean;
begin
  rPaperLandscape:= Value;
  Result:= True;
end;

function TXICA_Item.GetCapabilities: TXICA_Capabilities;
var
   pFlags: TXICA_PropertyFlags;
   Res: Boolean;

begin
  if (rCapabilities = nil) then
  try
    rCapabilities:= CapabilitiesClass.Create;

  except
    if (rCapabilities <> nil) then rCapabilities.Free;
    rCapabilities:= nil;
  end;

  if (rCapabilities <> nil) then
  with rCapabilities do
  begin
    if (Category <> xicAUTO) then
    begin
      Res:= GetPaperSizeMax(PaperSizeMaxWidth, PaperSizeMaxHeight);
      //if not(Res) then raise Exception.Create('GetPaperSizeMax');

      Res:= GetPaperType(PaperTypeCurrent, PaperTypeDefault, PaperTypeSet);
      //if not(Res) then raise Exception.Create('GetPaperType');

      Res:= GetRotation(RotationCurrent, RotationDefault, RotationSet);
      //if not(Res) then raise Exception.Create('GetRotation');

      pFlags:= GetResolutionsX(ResolutionCurrent, ResolutionDefault, ResolutionArray);
      Res:= (prop_READ in pFlags);
      //if not(Res) then raise Exception.Create('GetResolutionsX');
      ResolutionRange:= prop_RANGE in pFlags;

      Res:= GetBrightness(BrightnessCurrent, BrightnessDefault, BrightnessMin, BrightnessMax, BrightnessStep);
      //if not(Res) then raise Exception.Create('GetBrightness');

      Res:= GetContrast(ContrastCurrent, ContrastDefault, ContrastMin, ContrastMax, ContrastStep);
      //if not(Res) then raise Exception.Create('GetContrast');

      (*
      pFlags:= GetBitDepth(BitDepthCurrent, BitDepthDefault, BitDepthArray);
      Res:= (WIAProp_READ in pFlags);
      if not(Res) then exit;
      *)

      Res:= GetDataType(DataTypeCurrent, DataTypeDefault, DataTypeSet);
      //if not(Res) then raise Exception.Create('GetDataType');

      Res:= GetDocumentHandling(DocHandlingCurrent, DocHandlingDefault, DocHandlingSet);
      //if not(Res) then exit;
    end;
  end;

  Result:= rCapabilities;
end;

function TXICA_Item.GetParams: TXICA_Params;
begin
  if (rParams = nil) then
  try
    rParams:= ParamsClass.Create;
    rParams.CopyFromCapabilitiesCurrentValues(Capabilities, rPaperHAlign, rPaperVAlign);

  except
    if (rParams <> nil) then rParams.Free;
    rParams:= nil;
  end;

  Result:= rParams;
end;

procedure TXICA_Item.SetParams(const AParams: TXICA_Params);
var
   Result: Boolean;

begin
  Result:= False;

  if (AParams <> nil) then
  with AParams do
  begin
    if (Category <> xicAUTO) then
    begin
      Result:= SetResolution(Resolution, Resolution);
      //if not(Result) then raise Exception.Create('SetResolution');

      Result:= SetPaperAlign((Rotation in [xrLandscape, xrRot270]), HAlign, VAlign);
      //if not(Result) then raise Exception.Create('SetPaperAlign');

      if (PaperType = ptCUSTOM)
      then Result:= SetPaperSize(PaperW, PaperH)
      else Result:= SetPaperType(PaperType);
      //if not(Result) then raise Exception.Create('SetPaperType');

      Result:= SetDocumentHandling(DocHandling);
      //if not(Result) then raise Exception.Create('SetDocumentHandling');

      Result:= SetBrightness(Brightness);
      //if not(Result) then raise Exception.Create('SetBrightness');

      Result:= SetContrast(Contrast);
      //if not(Result) then raise Exception.Create('SetContrast');

      (*
      Result:= WIASource.SetBitDepth(BitDepth);
      if not(Result) then raise Exception.Create('SetBitDepth');
      *)

      Result:= SetDataType(DataType);
      //if not(Result) then raise Exception.Create('SetDataType');
    end
    else Result:= False;
  end;

  if Result then Params.Assign(AParams);
end;


{ TXICA_Device }

function TXICA_Device.FreeElement(var aData: TXICA_Item): Boolean;
begin
  try
     FreeAndNil(aData);
     Result:= True;
  except
    Result:= False;
  end;
end;

function TXICA_Device.EnumerateItems(PreserveSelected: Boolean): Boolean;
var
   lastSelected: ^TXICA_Item;

begin
  Result:= False;

  if PreserveSelected
  then lastSelected:= Selected
  else lastSelected:= nil;

  Clear(PreserveSelected);

  try
     //open arraylist returns nil if not selected and the class address if selected, we can't do nil^
     if (lastSelected = nil)
     then Result:= _EnumerateItems(PreserveSelected, nil)
     else Result:= _EnumerateItems(PreserveSelected, lastSelected^);

     //Result:= _EnumerateItems(PreserveSelected, lastSelected);

  except
    Clear(PreserveSelected);
    Result:= False;
  end;
end;

function TXICA_Device.GetType_Str: String;
begin
  if (rType in [Low(TXICA_DeviceType)..High(TXICA_DeviceType)])
  then Result:= XICA_DeviceTypeDescr[rType]
  else Result:= 'Undefined ('+IntToStr(Integer(rType))+')';
end;

constructor TXICA_Device.Create(AOwner: TXICA_DeviceManager; AIndex: Integer; ADeviceID: String);
begin
  inherited Create;

  rOwner :=AOwner;
  HasEnumerated :=False;
  rIndex :=AIndex;
  rID :=ADeviceID;
end;

destructor TXICA_Device.Destroy;
begin
  inherited Destroy;
end;

function TXICA_Device.GetCount: DWord;
begin
  //Enumerate Items if needed
  if not(HasEnumerated)
  then HasEnumerated:= EnumerateItems(False);

  Result:=inherited GetCount;
end;

procedure TXICA_Device.Refresh(PreserveSelected: Boolean);
begin
  HasEnumerated:= EnumerateItems(PreserveSelected);
end;

function TXICA_Device.Download(APath, AFileName, AExt: String): Integer;
begin
  if (Selected <> nil) then Result:= Selected^.Download(APath, AFileName, AExt)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.Download(APath, AFileName, AExt: String; AFormat: TXICA_ImageFormat): Integer;
begin
  if (Selected <> nil) then Result:= Selected^.Download(APath, AFileName, AExt, AFormat)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.Download(APath, AFileName, AExt: String;
                               AFormat: TXICA_ImageFormat; out DownloadedFiles: TStringArray;
                               UseRelativePath: Boolean): Integer;
begin
  if (Selected <> nil) then Result:= Selected^.Download(APath, AFileName, AExt, AFormat, DownloadedFiles, UseRelativePath)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetResolutionsX(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags;
begin
  if (Selected <> nil) then Result:= Selected^.GetResolutionsX(Current, Default, Values)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetResolutionsY(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags;
begin
  if (Selected <> nil) then Result:= Selected^.GetResolutionsY(Current, Default, Values)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetResolutionsLimit(out AMin, AMax: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetResolutionsLimit(AMin, AMax)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetResolutionsLimit(out AMinX, AMaxX, AMinY, AMaxY: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetResolutionsLimit(AMinX, AMaxX, AMinY, AMaxY)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetResolution(out AXRes, AYRes: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetResolution(AXRes, AYRes)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetResolution(const AXRes, AYRes: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetResolution(AXRes, AYRes)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetPaperSize(out AWidth, AHeight: Single): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetPaperSize(AWidth, AHeight)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetPaperSize(out AWidth, AHeight, ADefaultWidth, ADefaultHeight: Single): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetPaperSize(AWidth, AHeight, ADefaultWidth, ADefaultHeight)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetPaperSizeMax(AMaxWidth, AMaxHeight)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetPaperSize(Width, Height: Single): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetPaperSize(Width, Height)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetPaperRect(out Current: TRect): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetPaperRect(Current)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetPaperRect(out Current, Default: TRect): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetPaperRect(Current, Default)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetPaperRect(const X, Y, Width, Height: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetPaperRect(X, Y, Width, Height)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetPaperAlign(out ALandscape: Boolean; out HAlign: TXICA_AlignHorizontal; out VAlign: TXICA_AlignVertical): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetPaperAlign(ALandscape, HAlign, VAlign)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetPaperAlign(const ALandscape: Boolean; const HAlign: TXICA_AlignHorizontal; const VAlign: TXICA_AlignVertical): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetPaperAlign(ALandscape, HAlign, VAlign)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetPaperType(out Current: TXICA_PaperType): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetPaperType(Current)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetPaperType(out Current, Default: TXICA_PaperType; out Values: TXICA_PaperTypes): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetPaperType(Current, Default, Values)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetPaperType(const Value: TXICA_PaperType): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetPaperType(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetPaperLandscape(out Value: Boolean): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetPaperLandscape(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetPaperLandscape(const Value: Boolean): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetPaperLandscape(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetRotation(out Value: TXICA_Rotation): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetRotation(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetRotation(out Current, Default: TXICA_Rotation; out Values: TXICA_Rotations): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetRotation(Current, Default, Values)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetRotation(const Value: TXICA_Rotation): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetRotation(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetDocumentHandling(out Value: TXICA_DocumentHandlings): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetDocumentHandling(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetDocumentHandling(out Current, Default, Values: TXICA_DocumentHandlings): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetDocumentHandling(Current, Default, Values)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetDocumentHandling(const Value: TXICA_DocumentHandlings): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetDocumentHandling(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetPages(out Current: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetPages(Current)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetPages(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetPages(Current, Default, AMin, AMax, AStep)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetPages(const Value: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetPages(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetBrightness(out Current: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetBrightness(Current)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetBrightness(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetBrightness(Current, Default, AMin, AMax, AStep)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetBrightness(const Value: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetBrightness(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetContrast(out Current: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetContrast(Current)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetContrast(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetContrast(Current, Default, AMin, AMax, AStep)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetContrast(const Value: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetContrast(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetImageFormat(out Current: TXICA_ImageFormat): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetImageFormat(Current)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetImageFormat(out Current, Default: TXICA_ImageFormat; out Values: TXICA_ImageFormats): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetImageFormat(Current, Default, Values)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetImageFormat(const Value: TXICA_ImageFormat): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetImageFormat(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetDataType(out Current: TXICA_DataType): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetDataType(Current)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetDataType(out Current, Default: TXICA_DataType; out Values: TXICA_DataTypes): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetDataType(Current, Default, Values)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetDataType(const Value: TXICA_DataType): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetDataType(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetBitDepth(out Current: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetBitDepth(Current)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetBitDepth(out Current, Default: Integer; out Values: TArrayInteger): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.GetBitDepth(Current, Default, Values)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SetBitDepth(const Value: Integer): Boolean;
begin
  if (Selected <> nil) then Result:= Selected^.SetBitDepth(Value)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetCapabilities: TXICA_Capabilities;
begin
  if (Selected <> nil) then Result:= Selected^.GetCapabilities
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.GetParams: TXICA_Params;
begin
  if (Selected <> nil) then Result:= Selected^.GetParams
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

procedure TXICA_Device.SetParams(const AParams: TXICA_Params);
begin
  if (Selected <> nil) then Selected^.SetParams(AParams)
  else raise Exception.Create(Format(rsNoSelectedItem, [Name]));
end;

function TXICA_Device.SettingsDeviceDialog(var ASelectedItemIndex: Integer;
                                           AInitItemValues: TInitialItemValues; var AParams: TArrayXICA_Params;
                                           AOnInitDefaultValues: TInitDefaultValuesEvent): Boolean;
var
   fSettingsDialogFunc: TXICA_SettingsDialogFunc;

begin
  Result:= False;
  try
     fSettingsDialogFunc:= @TXICA_Device.SettingsDialogFunc;

     if Assigned(fSettingsDialogFunc)
     then Result:= fSettingsDialogFunc(Self, ASelectedItemIndex,
                                       AInitItemValues, AParams, AOnInitDefaultValues);

  except
  end;
end;

{ TXICA_DeviceManager }

function TXICA_DeviceManager.FreeElement(var aData: TXICA_Device): Boolean;
begin
  try
     FreeAndNil(aData);
     Result:= True;
  except
    Result:= False;
  end;
end;

function TXICA_DeviceManager.EnumerateDevices(PreserveSelected: Boolean): Boolean;
var
   lastSelected: ^TXICA_Device;

begin
  Result :=False;

  if PreserveSelected
  then lastSelected:= Selected
  else lastSelected:= nil;

  Clear(PreserveSelected);

  try
     //open arraylist returns nil if not selected and the class address if selected, we can't do nil^
     if (lastSelected = nil)
     then Result:= _EnumerateDevices(PreserveSelected, nil)
     else Result:= _EnumerateDevices(PreserveSelected, lastSelected^);

  except
    Clear(PreserveSelected);
    Result :=False;
  end;
end;

constructor TXICA_DeviceManager.Create(const AEnumAll: Boolean);
begin
  inherited Create;

  HasEnumerated:= False;
  rEnumAll:= AEnumAll;
end;

destructor TXICA_DeviceManager.Destroy;
begin
  inherited Destroy;
end;

function TXICA_DeviceManager.Clear: Boolean;
begin
  Result:=inherited Clear;
end;

function TXICA_DeviceManager.GetCount: DWord;
begin
  //Enumerate devices if needed
  if not(HasEnumerated)
  then HasEnumerated:= EnumerateDevices(False);

  Result:=inherited GetCount;
end;

procedure TXICA_DeviceManager.Refresh(const PreserveSelected: Boolean);
begin
  HasEnumerated:= EnumerateDevices(PreserveSelected);
end;

function TXICA_DeviceManager.SelectDeviceDialog: Integer;
var
   fSelectDialogFunc: TXICA_SelectDialogFunc;

begin
  Result:= -1;
  try
     fSelectDialogFunc:= @TXICA_DeviceManager.SelectDialogFunc;
     if Assigned(fSelectDialogFunc) then Result:= fSelectDialogFunc(Self);

  except
  end;
end;

function TXICA_DeviceManager.Find(const AName, AManufacturer: String): Integer;
var
   i: Integer;

begin
  Result:= -1;
  for i:=0 to Length(rList)-1 do
  begin
    { #todo -oMaxM : if there is more identical device? }
    if (rList[i].Data <> nil) and
       (rList[i].Data.Name = AName) and
       ((AManufacturer <> '') and (rList[i].Data.Manufacturer = AManufacturer))
    then begin Result:=i; break; end;
  end;
end;

procedure TXICA_DeviceManager.SelectDeviceItem(const ADeviceID, ADeviceItem: String;
                                               out ADevice: TXICA_Device; out ADeviceItemIndex: Integer);
var
   iDevice: Integer;

begin
  ADevice:= nil;
  ADeviceItemIndex:= -1;

  try
     iDevice:= FindByKey(ADeviceID);
     if (iDevice > -1) and (rList[iDevice].Data <> nil) then
     begin
       ADevice:= rList[iDevice].Data;
       ADevice.Select(ADeviceItem);
       ADeviceItemIndex:= ADevice.SelectedIndex;
     end;

  except
    ADevice:= nil;
    ADeviceItemIndex:= -1;
  end;
end;

end.




