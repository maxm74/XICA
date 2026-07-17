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
     {$ifdef fpc}testutils,{$else}DelphiCompatibility,{$endif}
     MM_OpenArrayList, XICA_Types;

type
  TXICA_Manager = class;

  { TXICA_Device }

  // UI Settings of Source Device
  TInitialItemValues = (initDefault, initParams, initCurrent);
  TInitDefaultValuesEvent = procedure (var ACap: TXICA_ParamsCapabilities) of object;

  TXICA_Device = class(TOpenArrayList<TXICA_Item, TKeyString>)
  protected
    rOwner: TXICA_Manager;
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

    rXRes, rYRes: Integer; //Used with PaperSizes_Calculated, if -1 then i need to Get Values from Device
    rPaperLandscape: Boolean;
    rHAlign: TXICA_AlignHorizontal;
    rVAlign: TXICA_AlignVertical;

    StreamDestination: TFileStream;
    StreamAdapter: TStreamAdapter;

    rDownloaded: Boolean;
    rDownload_Count: Integer;
    rDownload_Path,
    rDownload_Ext,
    rDownload_FileName: String;

    //Enumerate the avaliable items
    function EnumerateItems: Boolean; virtual; abstract;

  public
    constructor Create(AOwner: TXICA_Manager; AIndex: Integer; ADeviceID: String);
    destructor Destroy; override;

    //Download the Selected Item and return the number of files transfered.
    // if multiple pages is downloaded then the file names are
    // APath\AFileName-n.AExt where n is then Index (when 0 n is not present)
    function Download(APath, AFileName, AExt: String): Integer; overload; virtual; abstract;
    function Download(APath, AFileName, AExt: String; AFormat: TXICA_ImageFormat): Integer; overload; virtual; abstract;
    function Download(APath, AFileName, AExt: String; AFormat: TXICA_ImageFormat;
                      var DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer; overload; virtual; abstract;

    //Download using Native UI and return the number of files transfered in DownloadedFiles array.
    //  The system dialog works at Device level, so the selected item is ignored
    function DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
                              APath, AFileName: String;
                              var DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer; virtual; abstract;

    //Get Available Values for XResolution,
    //  if Result contain the Flag prop_RANGE then use propRANGE_XXX Indexes to get MIN/MAX/STEP Values
    function GetResolutionsX(var Current, Default: Integer; var Values: TArrayInteger): TXICA_PropertyFlags; virtual; abstract;
    //Get Available Values for YResolutions
    function GetResolutionsY(var Current, Default: Integer; var Values: TArrayInteger): TXICA_PropertyFlags; virtual; abstract;

    //Get the Minimun and Maximum Resolutions Values
    function GetResolutionsLimit(var AMin, AMax: Integer): Boolean; overload; virtual; abstract;
    function GetResolutionsLimit(var AMinX, AMaxX, AMinY, AMaxY: Integer): Boolean; overload; virtual; abstract;

    //Get Current Resolutions
    function GetResolution(var AXRes, AYRes: Integer): Boolean; virtual; abstract;

    //Set Current Resolutions, The user is responsible for checking the validity of the values
    function SetResolution(const AXRes, AYRes: Integer): Boolean; virtual; abstract;

    //Get Max Paper Width, Height
    function GetPaperSizeMax(var AMaxWidth, AMaxHeight: Integer): Boolean; virtual; abstract;

    //Get Current Paper Align
    function GetPaperAlign(var ALandscape:Boolean; var HAlign: TXICA_AlignHorizontal; var VAlign: TXICA_AlignVertical): Boolean; virtual;
    //Set Current Paper Align
    function SetPaperAlign(const ALandscape:Boolean; const HAlign: TXICA_AlignHorizontal; const VAlign: TXICA_AlignVertical): Boolean; virtual;

    //Get Current Paper Type
    function GetPaperType(var Current: TXICA_PaperType): Boolean; overload; virtual;
    //Get Available Paper Sizes
    function GetPaperType(var Current, Default: TXICA_PaperType; var Values: TXICA_PaperTypes): Boolean; overload; virtual;

    //Set Current Paper Type,
    function SetPaperType(const Value: TXICA_PaperType): Boolean; virtual;

    //Set Current Paper Size, the Area is calculated using Width, Height, Orientation and Align Values
    function SetPaperSize(Width, Height: Integer): Boolean; virtual;

    //Get Current Paper Landscape,
    function GetPaperLandscape(var Value: Boolean): Boolean; virtual;

    //Set Current Paper Landscape,
    function SetPaperLandscape(const Value: Boolean): Boolean; virtual;

  end;

  { TXICA_Manager }

  (*TOnDeviceTransfer = function (AWiaManager: TWIAManager; AWiaDevice: TWIADevice;
                         lFlags: LONG; pWiaTransferParams: PWiaTransferParams): Boolean of object;*)

  TXICA_Manager = class(TOpenArrayList<TXICA_Device, TKeyString>)
  protected
    rEnumAll: Boolean;
    lres: HResult;
    HasEnumerated: Boolean;
    //rOnAfterDeviceTransfer,
    //rOnBeforeDeviceTransfer: TOnDeviceTransfer;
  end;


implementation

{ TXICA_Device }

constructor TXICA_Device.Create(AOwner: TXICA_Manager; AIndex: Integer; ADeviceID: String);
begin
  inherited Create;

  rOwner :=AOwner;
  HasEnumerated :=False;
  rIndex :=AIndex;
  rID :=ADeviceID;

  StreamAdapter:= nil;
  StreamDestination:= nil;
  rDownload_Path:= '';
  rDownload_Ext:= '';
  rDownload_FileName:= '';
  rDownload_Count:= 0;
  rDownloaded:= False;

  rXRes:= -1; rYRes:= -1;
  rPaperLandscape:= False;
  rVAlign:= xaVTop;
  rHAlign:= xaHLeft;
end;

destructor TXICA_Device.Destroy;
begin
  inherited Destroy;
end;

function TXICA_Device.GetPaperAlign(var ALandscape: Boolean; var HAlign: TXICA_AlignHorizontal; var VAlign: TXICA_AlignVertical): Boolean;
begin
  HAlign:= rHAlign;
  VAlign:= rVAlign;
  Result:= GetPaperLandscape(ALandscape);
end;

function TXICA_Device.SetPaperAlign(const ALandscape: Boolean; const HAlign: TXICA_AlignHorizontal; const VAlign: TXICA_AlignVertical): Boolean;
begin
  rHAlign:= HAlign;
  rVAlign:= VAlign;
  Result:= SetPaperLandscape(ALandscape);
end;

function TXICA_Device.GetPaperType(var Current: TXICA_PaperType): Boolean;
begin

end;

function TXICA_Device.GetPaperType(var Current, Default: TXICA_PaperType; var Values: TXICA_PaperTypes): Boolean;
begin

end;

function TXICA_Device.SetPaperType(const Value: TXICA_PaperType): Boolean;
begin

end;

function TXICA_Device.SetPaperSize(Width, Height: Integer): Boolean;
begin

end;

function TXICA_Device.GetPaperLandscape(var Value: Boolean): Boolean;
begin

end;

function TXICA_Device.SetPaperLandscape(const Value: Boolean): Boolean;
begin

end;

end.




