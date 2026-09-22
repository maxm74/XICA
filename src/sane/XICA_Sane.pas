(*******************************************************************************
*                XICA (Cross-platform Image Capture Architecture)              *
*                                                                              *
*  FILE: XICA_Sane.pas                                                        *
*                                                                              *
*  VERSION:     0.0.1                                                          *
*                                                                              *
*  DESCRIPTION:                                                                *
*    Sane implementation                                                      *
*                                                                              *
********************************************************************************
*                                                                              *
*  (c) 2026 Massimo Magnano                                                    *
*                                                                              *
*  See changelog.txt for Change Log                                            *
*                                                                              *
*******************************************************************************)
unit XICA_Sane;

{$ifdef fpc}
  {$mode delphi}
{$endif}
{$H+}
{$R-}
{$POINTERMATH ON}

interface

{$ifdef LINUX}

uses Classes, SysUtils,
     {$ifdef fpc}testutils,{$else}DelphiCompatibility,{$endif}
     sane, saneopts,
     XICA_Types, XICA_Classes;

type
  { TXICA_SaneItem }

  TXICA_SaneItem = class(TXICA_Item)
  protected
    //Get Max Paper Width, Height form the Device (in Inches)
    function _GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean; override;

    function Download: Integer; overload; override;

  public
    destructor Destroy; override;

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
    function SetImageFormat(const Value: TXICA_ImageFormat; out ImgExt: String): Boolean; override;

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

  { TXICA_SaneDevice }

  TXICA_SaneDevice = class(TXICA_Device)
  protected
    devHandle: SANE_Handle;
    lres: SANE_Status;

    rOpened,
    rEnabled: Boolean;
    rDownloadItem: TXICA_SaneItem;

    //Enumerate the avaliable items
    function _EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean; override;

    function OpenDS: Boolean; virtual;
    procedure CloseDS; virtual;

  public
    constructor Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADeviceID: String); overload; override;
    constructor Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADevice: SANE_Device); overload; virtual;
    destructor Destroy; override;

    //Download using Native UI and return the number of files transfered in DownloadedFiles array.
    //  The system dialog works at Device level, so the selected item is ignored
    function DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
                              APath, AFileName: String;
                              out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer; override;
  end;

  { TXICA_SaneManager }

  TXICA_SaneManager = class(TXICA_DeviceManager)
  protected
    lRes: SANE_Status;
    rOpenedSources: Integer;

    //Enumerate the avaliable devices
    function _EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean; override;

    //Loads Sane library and set rLibrayLoaded if it loaded sucessfully
    procedure LoadSaneLibrary; virtual;

    //Unloads Sane library
    procedure UnloadSaneLibrary; virtual;

  public
    constructor Create(const AEnumAll: Boolean = True); override;
    destructor Destroy; override;

    //Is the library loaded?
    function Enabled: Boolean; override;

    class function Name: String; override;
  end;

{$endif}

implementation

{$ifdef LINUX}

uses XICA;

const
  {Name of the Sane library for 32 bits enviroment}
  SaneLIBRARY_64 = 'Sane_64.DLL';
  SaneLIBRARY_32 = 'Sane_32.DLL';

  {$IFDEF WIN64}
  SaneLIBRARY = SaneLIBRARY_64;
  {$ELSE}
  SaneLIBRARY = SaneLIBRARY_32;
  {$ENDIF}

var
   Sane_Manager: TXICA_SaneManager = nil;

{ TXICA_SaneItem }

destructor TXICA_SaneItem.Destroy;
begin
  inherited Destroy;
end;

function TXICA_SaneItem.Download: Integer;
begin
  Result:= 0;

  with TXICA_SaneDevice(rOwner) do
  if (rDownloadItem = nil) then
  try
     rDownloadItem:= Self;

     //Download....

     rDownloaded:= (rDownload_Count > 0);

     Result:= rDownload_Count;

  finally
    rDownloadItem:= nil;
  end;
end;

function TXICA_SaneItem.GetResolutionsX(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags;
begin
  Result:= [];
  with TXICA_SaneDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_SaneItem.GetResolutionsY(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags;
begin
  Result:= [];
  with TXICA_SaneDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_SaneItem.GetResolution(out AXRes, AYRes: Integer): Boolean;
begin
  Result:= False;
  with TXICA_SaneDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_SaneItem.SetResolution(const AXRes, AYRes: Integer): Boolean;
begin
  Result:= False;
  with TXICA_SaneDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_SaneItem.GetPaperRect(out Current: TRect): Boolean;
begin
end;

function TXICA_SaneItem.GetPaperRect(out Current, Default: TRect): Boolean;
begin
end;

function TXICA_SaneItem.SetPaperRect(const X, Y, Width, Height: Integer): Boolean;
begin
end;

function TXICA_SaneItem._GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean;
begin
end;

function TXICA_SaneItem.GetRotation(out Value: TXICA_Rotation): Boolean;
begin
end;

function TXICA_SaneItem.GetRotation(out Current, Default: TXICA_Rotation; out Values: TXICA_Rotations): Boolean;
begin
  Result:= False;
  try
     Values:=[];

  finally
  end;
end;

function TXICA_SaneItem.SetRotation(const Value: TXICA_Rotation): Boolean;
begin
end;

function TXICA_SaneItem.GetDocumentHandling(out Value: TXICA_DocumentHandlings): Boolean;
begin
end;

function TXICA_SaneItem.GetDocumentHandling(out Current, Default, Values: TXICA_DocumentHandlings): Boolean;
begin
  Result:= False;
  try
     Values:=[];

  finally
  end;
end;

function TXICA_SaneItem.SetDocumentHandling(const Value: TXICA_DocumentHandlings): Boolean;
begin
end;

function TXICA_SaneItem.GetPages(out Current: Integer): Boolean;
begin
end;

function TXICA_SaneItem.GetPages(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
begin
end;

function TXICA_SaneItem.SetPages(const Value: Integer): Boolean;
begin
end;

function TXICA_SaneItem.GetBrightness(out Current: Integer): Boolean;
begin
  Result:= False;
  with TXICA_SaneDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_SaneItem.GetBrightness(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
begin
  Result:= False;
  with TXICA_SaneDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_SaneItem.SetBrightness(const Value: Integer): Boolean;
begin
  Result:= False;
  with TXICA_SaneDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_SaneItem.GetContrast(out Current: Integer): Boolean;
begin
  Result:= False;
  with TXICA_SaneDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_SaneItem.GetContrast(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
begin
end;

function TXICA_SaneItem.SetContrast(const Value: Integer): Boolean;
begin
end;

function TXICA_SaneItem.GetImageFormat(out Current: TXICA_ImageFormat): Boolean;
begin
end;

function TXICA_SaneItem.GetImageFormat(out Current, Default: TXICA_ImageFormat; out Values: TXICA_ImageFormats): Boolean;
begin
  Result:= False;
  try
     Values:= [];

  finally
  end;
end;

function TXICA_SaneItem.SetImageFormat(const Value: TXICA_ImageFormat; out ImgExt: String): Boolean;
begin
  Result:= inherited SetImageFormat(Value, ImgExt);
end;

function TXICA_SaneItem.GetDataType(out Current: TXICA_DataType): Boolean;
begin
end;

function TXICA_SaneItem.GetDataType(out Current, Default: TXICA_DataType; out Values: TXICA_DataTypes): Boolean;
begin
  Result:= False;
  try
     Values:= [];

  finally
  end;
end;

function TXICA_SaneItem.SetDataType(const Value: TXICA_DataType): Boolean;
begin
end;

function TXICA_SaneItem.GetBitDepth(out Current, Default: Integer; out Values: TArrayInteger): Boolean;
begin
end;

function TXICA_SaneItem.GetBitDepth(out Current: Integer): Boolean;
begin
end;

function TXICA_SaneItem.SetBitDepth(const Value: Integer): Boolean;
begin
end;


{ TXICA_SaneDevice }

function TXICA_SaneDevice._EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean;
var
   curName: String;
   curItem: TXICA_SaneItem;

begin
  Result:= False;

  try
     if (Type_ = devTypeDigitalCamera)
     then begin
          end
     else begin
          end;

     Result:= True;

  finally
  end;
end;

function TXICA_SaneDevice.OpenDS: Boolean;
begin
  try
     if not(TXICA_SaneManager(rOwner).Enabled) then TXICA_SaneManager(rOwner).LoadSaneLibrary;

     //Open only if it is not already opened
     if not(rOpened) then
     begin
       lRes:= sane_open(PChar(rID), devHandle);

       if (lRes = SANE_STATUS_GOOD) then
       begin
         //Increase the loaded sources count variable
         inc(TXICA_SaneManager(rOwner).rOpenedSources);
         rOpened:= True;
       end;
     end;

  finally
     Result:= rOpened;
  end;
end;

procedure TXICA_SaneDevice.CloseDS;
begin
  //Close only if it is opened
  if rOpened then
  begin
    sane_close(devHandle);

    //Decrease the loaded sources count variable
    dec(TXICA_SaneManager(rOwner).rOpenedSources);
    rOpened:= False;
  end;
end;

constructor TXICA_SaneDevice.Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADeviceID: String);
begin
  inherited Create(AOwner, AIndex, ADeviceID);

  rEnabled:= False;
  rDownloadItem:= nil;
end;

constructor TXICA_SaneDevice.Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADevice: SANE_Device);
begin
  inherited Create(AOwner, AIndex, ADevice.name);

//  rDevice:= ADevice;
  rManufacturer:= ADevice.vendor;
  rName:= ADevice.model;
//  rVersion:= rIdentity.Version.MajorNum;
//  rVersionSub:= rIdentity.Version.MinorNum;
end;

destructor TXICA_SaneDevice.Destroy;
begin
  inherited Destroy;
end;

function TXICA_SaneDevice.DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
                                          APath, AFileName: String;
                                          out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer;
var
   i: Integer;
   rDownloaded: Boolean;
   rDownload_Count: Integer;
   rDownload_Path,
   rDownload_Ext,
   rDownload_FileName: String;

begin
  Result:= 0;
  DownloadedFiles:= nil;

  if (TXICA_SaneManager(rOwner) = nil) then exit;

  try
     if (APath = '') or CharInSet(APath[Length(APath)], AllowDirectorySeparators)
     then rDownload_Path:= APath
     else rDownload_Path:= APath+DirectorySeparator;

     if not(ForceDirectories(rDownload_Path)) then exit;

     rDownload_FileName:= AFileName;
     rDownload_Ext:= '';
     rDownload_Count:= 0;
     rDownloaded:= False;

     //Download....

     if (lres = SANE_STATUS_GOOD) then
     begin
       //Copy filePaths to DownloadedFiles and Free elements
       SetLength(DownloadedFiles, rDownload_Count);
       for i:=0 to rDownload_Count-1 do
       begin
         if UseRelativePath then FullPathToRelativePath(rDownload_Path, DownloadedFiles[i]);
       end;

       Result:= rDownload_Count;
     end;
  finally
  end;
end;


{ TXICA_SaneManager }

procedure TXICA_SaneManager.LoadSaneLibrary;
begin
  try
     sane.Load;

  except
  end;
end;

procedure TXICA_SaneManager.UnloadSaneLibrary;
begin
  try
     sane.Unload;

  except
  end;
end;

function TXICA_SaneManager._EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean;
var
  i:integer;
  curDevice: TXICA_SaneDevice;
  Devicelist: PSANE_DeviceArray;
  pDevice: PSANE_Device;

  procedure CreateDevice;
  begin
    if PreserveSelected and (ALastSelected <> nil) and (ALastSelected.ID = pDevice^.name)
    then begin
           curDevice:= TXICA_SaneDevice(ALastSelected);
           Add(curDevice.ID, ALastSelected);
           SelectedIndex:= i;
           curDevice.rIndex:= i;  //Update Index because can be different (Actually not used)
         end
    else begin
           curDevice:= TXICA_SaneDevice.Create(Self, i, pDevice^);
           Add(curDevice.ID, curDevice);
         end;
  end;

begin
  Result:= False;

  lRes:= sane_init(nil, nil);
  if (lRes = SANE_STATUS_GOOD) then
  try
     Devicelist:= nil;
     lRes := sane_get_devices(Devicelist, SANE_TRUE);
     if (lRes = SANE_STATUS_GOOD) then
     begin
       i:= 0;
       repeat
         try
            pDevice:= Devicelist^[i];
         except
            pDevice:= nil;
         end;

         if (pDevice <> nil) then
         begin
           CreateDevice;
           Inc(i);
         end;
       until (pDevice = nil);
     end;

  finally
     sane_exit;
  end;

  Result :=True;
end;

constructor TXICA_SaneManager.Create(const AEnumAll: Boolean = True);
begin
  inherited Create(AEnumAll);

  rOpenedSources:= 0;
  LoadSaneLibrary;
end;

destructor TXICA_SaneManager.Destroy;
begin
  inherited Destroy;

  UnloadSaneLibrary;
end;

function TXICA_SaneManager.Enabled: Boolean;
begin
  Result:= (sane.libHandle <> 0);
end;

class function TXICA_SaneManager.Name: String;
begin
  Result:= 'Sane';
end;

initialization
  Sane_Manager:= TXICA_SaneManager.Create(XICA_EnumAllDevices);
  XICA_RegisterDeviceManager(TXICA_SaneManager.Name, Sane_Manager);

{$endif}

end.

