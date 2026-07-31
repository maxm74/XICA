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

type
  TXICA_DeviceManager = class;
  TXICA_Device = class;

  { TXICA_Device }

  // UI Settings of Source Device
  TInitialItemValues = (initDefault, initParams, initCurrent);
  TInitDefaultValuesEvent = procedure (var ACap: TXICA_ParamsCapabilities) of object;

  TXICA_SettingsDialogFunc = function (ADevice: TXICA_Device;
                                       var ASelectedItemIndex: Integer;
                                       { #todo -oMaxM : Possibly Filters for which Items Kinds to Show? How manage AParams without Indexes? }
                                       AInitItemValues: TInitialItemValues;
                                       var AParams: TArrayXICA_Params;
                                       AOnInitDefaultValues: TInitDefaultValuesEvent=nil): Boolean;

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

    rPaperLandscape: Boolean;
    rXRes, rYRes: Integer;                  //if <=0 then i need to Get Values from Device
    rPaperWidth, rPaperHeight,
    rPaperDefaultWidth, rPaperDefaultHeight,
    rPaperMaxWidth, rPaperMaxHeight: Single;

    rPaperHAlign: TXICA_AlignHorizontal;
    rPaperVAlign: TXICA_AlignVertical;

    StreamDestination: TFileStream;
    StreamAdapter: TStreamAdapter;

    rDownloaded: Boolean;
    rDownload_Count: Integer;
    rDownload_Path,
    rDownload_Ext,
    rDownload_FileName: String;

    function FreeElement(var aData: TXICA_Item): Boolean; override;

    //Enumerate the avaliable items
    function _EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean; virtual; abstract;
    function EnumerateItems(PreserveSelected: Boolean): Boolean;

    //Get Paper Width, Height form the Device (in Inches)
    function _GetPaperSize(out AWidth, AHeight: Single): Boolean; overload; virtual; abstract;
    function _GetPaperSize(out AWidth, AHeight, ADefaultWidth, ADefaultHeight: Single): Boolean; overload; virtual; abstract;

    //Get Max Paper Width, Height form the Device (in Inches)
    function _GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean; virtual; abstract;

    class function SettingsDialogFunc: TXICA_SettingsDialogFunc; virtual; abstract;

    function GetType_Str: String; virtual;

  public
    constructor Create(AOwner: TXICA_DeviceManager; AIndex: Integer; ADeviceID: String);
    destructor Destroy; override;

    function GetCount: DWord; override;

    //Refresh the item list
    procedure Refresh(PreserveSelected: Boolean=True);

    //Download the Selected Item and return the number of files transfered.
    // if multiple pages is downloaded then the file names are
    // APath\AFileName-n.AExt where n is then Index (when 0 n is not present)
    function Download(APath, AFileName, AExt: String): Integer; overload; virtual; abstract;
    function Download(APath, AFileName, AExt: String; AFormat: TXICA_ImageFormat): Integer; overload; virtual; abstract;
    function Download(APath, AFileName, AExt: String; AFormat: TXICA_ImageFormat;
                      out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer; overload; virtual; abstract;

    //Download using Native UI and return the number of files transfered in DownloadedFiles array.
    //  The system dialog works at Device level, so the selected item is ignored
    function DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
                              APath, AFileName: String;
                              out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer; virtual; abstract;

    //Get Available Values for XResolution,
    //  if Result contain the Flag prop_RANGE then use propRANGE_XXX Indexes to get MIN/MAX/STEP Values
    function GetResolutionsX(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags; virtual; abstract;
    //Get Available Values for YResolutions
    function GetResolutionsY(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags; virtual; abstract;

    //Get the Minimun and Maximum Resolutions Values
    function GetResolutionsLimit(out AMin, AMax: Integer): Boolean; overload; virtual; abstract;
    function GetResolutionsLimit(out AMinX, AMaxX, AMinY, AMaxY: Integer): Boolean; overload; virtual; abstract;

    //Get Current Resolutions
    function GetResolution(out AXRes, AYRes: Integer): Boolean; virtual; abstract;

    //Set Current Resolutions, The user is responsible for checking the validity of the values
    function SetResolution(const AXRes, AYRes: Integer): Boolean; virtual; abstract;

    //Get Paper Width, Height (in Inches)
    function GetPaperSize(out AWidth, AHeight: Single): Boolean; overload; virtual;

    //Get Paper Width, Height (in Inches)
    function GetPaperSize(out AWidth, AHeight, ADefaultWidth, ADefaultHeight: Single): Boolean; overload; virtual;

    //Get Max Paper Width, Height (in Inches)
    function GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean; virtual;

    //Set Current Paper Size (in Inches), the Area is calculated using Width, Height, Orientation and Align Values
    function SetPaperSize(Width, Height: Single): Boolean; virtual;

    //Set Current Paper Rect (in Pixels)
    function SetPaperRect(const Left, Top, Width, Height: Integer): Boolean; virtual; abstract;

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
    function GetRotation(var Value: TXICA_Rotation; useRoot: Boolean=False): Boolean; overload; virtual; abstract;
    //Get Available Rotations
    function GetRotation(var Current, Default: TXICA_Rotation; var Values: TXICA_Rotations): Boolean; overload; virtual; abstract;

    //Set Current Rotation, not to be confused with PaperLandscape,
    //  this function rotate the image after capturing it
    function SetRotation(const Value: TXICA_Rotation): Boolean; virtual; abstract;

    //Get Current DocumentHandling,
    function GetDocumentHandling(var Value: TXICA_DocumentHandlings): Boolean; overload; virtual; abstract;
    //Get Available DocumentHandling
    function GetDocumentHandling(var Current, Default, Values: TXICA_DocumentHandlings): Boolean; overload; virtual; abstract;

    //Set Current DocumentHandling,
    function SetDocumentHandling(const Value: TXICA_DocumentHandlings): Boolean; virtual; abstract;

    //Get Current Pages (0 = All)
    function GetPages(var Current: Integer): Boolean; overload; virtual; abstract;
    //Get Current, Default and Range Values for Pages
    function GetPages(var Current, Default, AMin, AMax, AStep: Integer): Boolean; overload; virtual; abstract;

    //Set Current Pages (0 = All)
    //  If a Feeder Scanner is unable to scan only one side of a page while in Duplex you must use an even value
    function SetPages(const Value: Integer): Boolean; virtual; abstract;

    //Get Current Brightness
    function GetBrightness(var Current: Integer): Boolean; overload; virtual; abstract;
    //Get Current, Default and Range Values for Brightness
    function GetBrightness(var Current, Default, AMin, AMax, AStep: Integer): Boolean; overload; virtual; abstract;

    //Set Current Brightness, The user is responsible for checking the validity of the value
    function SetBrightness(const Value: Integer): Boolean; virtual; abstract;

    //Get Current Contrast
    function GetContrast(var Current: Integer): Boolean; overload; virtual; abstract;
    //Get Current, Default and Range Values for Contrast
    function GetContrast(var Current, Default, AMin, AMax, AStep: Integer): Boolean; overload; virtual; abstract;

    //Set Current Contrast, The user is responsible for checking the validity of the value
    function SetContrast(const Value: Integer): Boolean; virtual; abstract;

    //Get Current Image Format
    function GetImageFormat(var Current: TXICA_ImageFormat): Boolean; overload; virtual; abstract;
    //Get Available Image Formats
    function GetImageFormat(var Current, Default: TXICA_ImageFormat; var Values: TXICA_ImageFormats): Boolean; overload; virtual; abstract;

    //Set Current Image Format
    function SetImageFormat(const Value: TXICA_ImageFormat): Boolean; virtual; abstract;

     //Get Current Image DataType
    function GetDataType(var Current: TXICA_DataType): Boolean; overload; virtual; abstract;
    //Get Available Image DataTypes
    function GetDataType(var Current, Default: TXICA_DataType; var Values: TXICA_DataTypes): Boolean; overload; virtual; abstract;

    //Set Current Image DataType
    function SetDataType(const Value: TXICA_DataType): Boolean; virtual; abstract;

    //Get Current BitDepth
    function GetBitDepth(var Current: Integer; useRoot: Boolean=False): Boolean; overload; virtual; abstract;
    //Get Available Values for BitDepth
    function GetBitDepth(var Current, Default: Integer; var Values: TArrayInteger): Boolean; overload; virtual; abstract;

    //Set Current BitDepth, The user is responsible for checking the validity of the value
    function SetBitDepth(const Value: Integer): Boolean; virtual; abstract;

    //Get Capabilities for Current Selected Item
    function GetParamsCapabilities(var Value: TXICA_ParamsCapabilities): Boolean;

    //Set Params to Current Selected Item
    function SetParams(const AParams: TXICA_Params): Boolean;

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
  end;

  { TXICA_DeviceManager }

  TXICA_SelectDialogFunc = function (ADeviceManager: TXICA_DeviceManager): Integer;

  TXICA_OnDeviceTransfer = function (ADeviceManager: TXICA_DeviceManager; AWiaDevice: TXICA_Device
                                     (*lFlags: LONG; pWiaTransferParams: PWiaTransferParams*)): Boolean of object;

  TXICA_DeviceManager = class(TOpenArrayList<TXICA_Device, TKeyString>)
  protected
    rVersion,
    rVersionSub: Integer;
    rEnumAll: Boolean;
    lres: HResult;
    HasEnumerated: Boolean;
    rOnAfterDeviceTransfer,
    rOnBeforeDeviceTransfer: TXICA_OnDeviceTransfer;

    function FreeElement(var aData: TXICA_Device): Boolean; override;

    //Enumerate the avaliable devices
    function _EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean; virtual; abstract;
    function EnumerateDevices(PreserveSelected: Boolean): Boolean;

    class function SelectDialogFunc: TXICA_SelectDialogFunc; virtual; abstract;

  public
    constructor Create(AEnumAll: Boolean = True);
    destructor Destroy; override;

    //Clears the list of devices
    function Clear: Boolean; override;

    function GetCount: DWord; override;

    //Refresh the list of devices
    procedure Refresh(PreserveSelected: Boolean=True);

    //Display a dialog to let the user choose a Device and returns it's index
    function SelectDeviceDialog: Integer; virtual;

    //Finds a matching Device index
    //  to Find Device by ID use FindByKey(ID)
    //  to Find Device by it's class use Find(Value: TXICA_Device)
    //  Find Device by it's Name (set Manufacturer to '' to Find only by Name)
    function Find(AName, AManufacturer: String): Integer; overload; virtual;

    //Find a Device by it's ID and Select the given Item
    procedure SelectDeviceItem(ADeviceID, ADeviceItem: String; out ADevice: TXICA_Device; var ADeviceItemIndex: Integer);

    //Name of the Library
    class function Name: String; virtual; abstract;

    //Version and SubVersion of Library
    property Version: Integer read rVersion write rVersion;
    property VersionSub: Integer read rVersionSub write rVersionSub;

    //Kind of Enum, if True Enum even disconnected Devices
    property EnumAll: Boolean read rEnumAll write rEnumAll;

    //Events
    property OnBeforeDeviceTransfer: TXICA_OnDeviceTransfer read rOnBeforeDeviceTransfer write rOnBeforeDeviceTransfer;
    property OnAfterDeviceTransfer: TXICA_OnDeviceTransfer read rOnAfterDeviceTransfer write rOnAfterDeviceTransfer;
  end;


implementation

uses XICA_PaperSizes;

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
  Result:= XICA_DeviceType(rType);
end;

constructor TXICA_Device.Create(AOwner: TXICA_DeviceManager; AIndex: Integer; ADeviceID: String);
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

  rPaperLandscape:= False;
  rXRes:= -1; rYRes:= -1;
  rPaperWidth:= -1; rPaperHeight:= -1;
  rPaperDefaultWidth:= -1; rPaperDefaultHeight:= -1;
  rPaperMaxWidth:= -1; rPaperMaxHeight:= -1;
  rPaperVAlign:= xaVTop;
  rPaperHAlign:= xaHLeft;
end;

destructor TXICA_Device.Destroy;
begin
  if (StreamAdapter <> nil) then StreamAdapter:= nil;

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

function TXICA_Device.GetPaperSize(out AWidth, AHeight: Single): Boolean;
begin
  if (rPaperWidth > 0) and (rPaperHeight > 0)
  then Result:= True
  else Result:= _GetPaperSize(rPaperWidth, rPaperHeight);

  if Result then
  begin
    AWidth:= rPaperWidth;
    AHeight:= rPaperHeight;
  end;
end;

function TXICA_Device.GetPaperSize(out AWidth, AHeight, ADefaultWidth, ADefaultHeight: Single): Boolean;
begin
  if (rPaperWidth > 0) and (rPaperHeight > 0) and
     (rPaperDefaultWidth > 0) and (rPaperDefaultHeight > 0)
  then Result:= True
  else Result:= _GetPaperSize(rPaperWidth, rPaperHeight, rPaperDefaultWidth, rPaperDefaultHeight);

  if Result then
  begin
    AWidth:= rPaperWidth;
    AHeight:= rPaperHeight;
    ADefaultWidth:= rPaperDefaultWidth;
    ADefaultHeight:= rPaperDefaultHeight;
  end;
end;

function TXICA_Device.GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean;
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

function TXICA_Device.SetPaperSize(Width, Height: Single): Boolean;
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

  //Check if the paper size fits within the entire area
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

function TXICA_Device.GetPaperAlign(out ALandscape: Boolean; out HAlign: TXICA_AlignHorizontal; out VAlign: TXICA_AlignVertical): Boolean;
begin
  HAlign:= rPaperHAlign;
  VAlign:= rPaperVAlign;
  Result:= GetPaperLandscape(ALandscape);
end;

function TXICA_Device.SetPaperAlign(const ALandscape: Boolean; const HAlign: TXICA_AlignHorizontal; const VAlign: TXICA_AlignVertical): Boolean;
begin
  Result:= SetPaperLandscape(ALandscape);
  if Result then
  begin
    rPaperHAlign:= HAlign;
    rPaperVAlign:= VAlign;
  end;
end;

function TXICA_Device.GetPaperType(out Current: TXICA_PaperType): Boolean;
var
   iMaxWidth,
   iMaxHeight,
   iWidth,
   iHeight: Single;

begin
  Result:= GetPaperSize(iWidth, iHeight);

  if Result
  then begin
         Result:= GetPaperSizeMax(iMaxWidth, iMaxHeight);
         if (iWidth >= iMaxWidth) or (iHeight >= iMaxHeight)
         then Current:= ptMAX
         else Current:= CalculatePaperSize(iWidth, iHeight);
       end
  else Current:= ptMAX;
end;

function TXICA_Device.GetPaperType(out Current, Default: TXICA_PaperType; out Values: TXICA_PaperTypes): Boolean;
var
   iMaxWidth,
   iMaxHeight,
   iWidth,
   iHeight: Single;

begin
  Result:= False;
  Values:= [];

  Result:= GetPaperSizeMax(iMaxWidth, iMaxHeight);
  if Result then
  begin
    Values:= CalculatePaperSizeSet(iMaxWidth, iMaxHeight);

    if GetPaperSize(iWidth, iHeight, iMaxWidth, iMaxHeight)
    then begin
           Current:= CalculatePaperSize(iWidth, iHeight);
           Default:= CalculatePaperSize(iMaxWidth, iMaxHeight);
         end
    else begin
           Current:= ptA4;
           Default:= ptA4;
         end;
  end;
end;

function TXICA_Device.SetPaperType(const Value: TXICA_PaperType): Boolean;
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

function TXICA_Device.GetPaperLandscape(out Value: Boolean): Boolean;
begin
  Value:= rPaperLandscape;
  Result:= True;
end;

function TXICA_Device.SetPaperLandscape(const Value: Boolean): Boolean;
begin
  rPaperLandscape:= Value;
  Result:= True;
end;

function TXICA_Device.GetParamsCapabilities(var Value: TXICA_ParamsCapabilities): Boolean;
var
   pFlags: TXICA_PropertyFlags;

begin
  Result:= False;
  FillChar(Value, SizeOf(TXICA_ParamsCapabilities), 0);

  with Value do
  begin
    if (Selected = nil) or (Selected^.Category <> xicAUTO) then
    begin
      Result:= GetPaperSizeMax(PaperSizeMaxWidth, PaperSizeMaxHeight);
      //if not(Result) then raise Exception.Create('GetPaperSizeMax');

      Result:= GetPaperType(PaperTypeCurrent, PaperTypeDefault, PaperTypeSet);
      //if not(Result) then raise Exception.Create('GetPaperType');

      Result:= GetRotation(RotationCurrent, RotationDefault, RotationSet);
      //if not(Result) then raise Exception.Create('GetRotation');

      pFlags:= GetResolutionsX(ResolutionCurrent, ResolutionDefault, ResolutionArray);
      Result:= (prop_READ in pFlags);
      //if not(Result) then raise Exception.Create('GetResolutionsX');
      ResolutionRange:= prop_RANGE in pFlags;

      Result:= GetBrightness(BrightnessCurrent, BrightnessDefault, BrightnessMin, BrightnessMax, BrightnessStep);
      //if not(Result) then raise Exception.Create('GetBrightness');

      Result:= GetContrast(ContrastCurrent, ContrastDefault, ContrastMin, ContrastMax, ContrastStep);
      //if not(Result) then raise Exception.Create('GetContrast');

      (*
      pFlags:= GetBitDepth(BitDepthCurrent, BitDepthDefault, BitDepthArray);
      Result:= (WIAProp_READ in pFlags);
      if not(Result) then exit;
      *)

      Result:= GetDataType(DataTypeCurrent, DataTypeDefault, DataTypeSet);
      //if not(Result) then raise Exception.Create('GetDataType');

      Result:= GetDocumentHandling(DocHandlingCurrent, DocHandlingDefault, DocHandlingSet);
      //if not(Result) then exit;
    end;
  end;

  Result:= True;
end;

function TXICA_Device.SetParams(const AParams: TXICA_Params): Boolean;
begin
  Result:= False;

  with AParams do
  begin
    if (Selected = nil) or (Selected.Category <> xicAUTO) then
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
    else Result:= True;
  end;
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

constructor TXICA_DeviceManager.Create(AEnumAll: Boolean);
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

procedure TXICA_DeviceManager.Refresh(PreserveSelected: Boolean);
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

function TXICA_DeviceManager.Find(AName, AManufacturer: String): Integer;
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

procedure TXICA_DeviceManager.SelectDeviceItem(ADeviceID, ADeviceItem: String;
                                               out ADevice: TXICA_Device; var ADeviceItemIndex: Integer);
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
     end;

  except
    ADevice:= nil;
    ADeviceItemIndex:= -1;
  end;
end;

end.




