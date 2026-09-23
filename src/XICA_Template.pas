(*******************************************************************************
*                XICA (Cross-platform Image Capture Architecture)              *
*                                                                              *
*  FILE: XICA_Template.pas                                                        *
*                                                                              *
*  VERSION:     0.0.1                                                          *
*                                                                              *
*  DESCRIPTION:                                                                *
*    A Base Empty Structure for Copy/Paste                                     *
*                                                                              *
********************************************************************************
*                                                                              *
*  (c) 2026 Massimo Magnano                                                    *
*                                                                              *
*  See changelog.txt for Change Log                                            *
*                                                                              *
*******************************************************************************)
unit XICA_Template;

{$ifdef fpc}
  {$mode delphi}
{$endif}
{$H+}
{$R-}
{$POINTERMATH ON}

interface

uses Classes, SysUtils,
     {$ifdef fpc}testutils,{$else}DelphiCompatibility,{$endif}
     //Your units
     XICA_Types, XICA_Classes;

type
  { TXICA_TemplateItem }

  TXICA_TemplateItem = class(TXICA_Item)
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

  { TXICA_TemplateDevice }

  TXICA_TemplateDevice = class(TXICA_Device)
  protected
    rOpened,
    rEnabled: Boolean;
    rDownloadItem: TXICA_TemplateItem;

    //Enumerate the avaliable items
    function _EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean; override;

    function OpenDS: Boolean; virtual;
    procedure CloseDS; virtual;

  public
    constructor Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADeviceID: String); overload; override;
    constructor Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADevice: Integer{SOME TEMPLATE RECORD}); overload; virtual;
    destructor Destroy; override;

    //Download using Native UI and return the number of files transfered in DownloadedFiles array.
    //  The system dialog works at Device level, so the selected item is ignored
    function DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
                              APath, AFileName: String;
                              out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer; override;
  end;

  { TXICA_TemplateManager }

  TXICA_TemplateManager = class(TXICA_DeviceManager)
  protected
    TemplateDirectory: String;
    rLibHandle: TLibHandle;
    lRes: HResult;

    //Enumerate the avaliable devices
    function _EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean; override;

    //Loads Template library and set rLibrayLoaded if it loaded sucessfully
    procedure LoadTemplateLibrary; virtual;

    //Unloads Template library
    procedure UnloadTemplateLibrary; virtual;

  public
    constructor Create(const AEnumAll: Boolean = True); override;
    destructor Destroy; override;

    //Is the library loaded?
    function Enabled: Boolean; override;

    class function Name: String; override;
  end;

implementation

uses XICA;

const
  {Name of the Template library for 32 bits enviroment}
  TemplateLIBRARY_64 = 'Template_64.DLL';
  TemplateLIBRARY_32 = 'Template_32.DLL';

  {$IFDEF WIN64}
  TemplateLIBRARY = TemplateLIBRARY_64;
  {$ELSE}
  TemplateLIBRARY = TemplateLIBRARY_32;
  {$ENDIF}

var
   Template_Manager: TXICA_TemplateManager = nil;

{ TXICA_TemplateItem }

destructor TXICA_TemplateItem.Destroy;
begin
  inherited Destroy;
end;

function TXICA_TemplateItem.Download: Integer;
begin
  Result:= 0;

  with TXICA_TemplateDevice(rOwner) do
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

function TXICA_TemplateItem.GetResolutionsX(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags;
begin
  Result:= [];
  with TXICA_TemplateDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_TemplateItem.GetResolutionsY(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags;
begin
  Result:= [];
  with TXICA_TemplateDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_TemplateItem.GetResolution(out AXRes, AYRes: Integer): Boolean;
begin
  Result:= False;
  with TXICA_TemplateDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_TemplateItem.SetResolution(const AXRes, AYRes: Integer): Boolean;
begin
  Result:= False;
  with TXICA_TemplateDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_TemplateItem.GetPaperRect(out Current: TRect): Boolean;
begin
end;

function TXICA_TemplateItem.GetPaperRect(out Current, Default: TRect): Boolean;
begin
end;

function TXICA_TemplateItem.SetPaperRect(const X, Y, Width, Height: Integer): Boolean;
begin
end;

function TXICA_TemplateItem._GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean;
begin
end;

function TXICA_TemplateItem.GetRotation(out Value: TXICA_Rotation): Boolean;
begin
end;

function TXICA_TemplateItem.GetRotation(out Current, Default: TXICA_Rotation; out Values: TXICA_Rotations): Boolean;
begin
  Result:= False;
  try
     Values:=[];

  finally
  end;
end;

function TXICA_TemplateItem.SetRotation(const Value: TXICA_Rotation): Boolean;
begin
end;

function TXICA_TemplateItem.GetDocumentHandling(out Value: TXICA_DocumentHandlings): Boolean;
begin
end;

function TXICA_TemplateItem.GetDocumentHandling(out Current, Default, Values: TXICA_DocumentHandlings): Boolean;
begin
  Result:= False;
  try
     Values:=[];

  finally
  end;
end;

function TXICA_TemplateItem.SetDocumentHandling(const Value: TXICA_DocumentHandlings): Boolean;
begin
end;

function TXICA_TemplateItem.GetPages(out Current: Integer): Boolean;
begin
end;

function TXICA_TemplateItem.GetPages(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
begin
end;

function TXICA_TemplateItem.SetPages(const Value: Integer): Boolean;
begin
end;

function TXICA_TemplateItem.GetBrightness(out Current: Integer): Boolean;
begin
  Result:= False;
  with TXICA_TemplateDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_TemplateItem.GetBrightness(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
begin
  Result:= False;
  with TXICA_TemplateDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_TemplateItem.SetBrightness(const Value: Integer): Boolean;
begin
  Result:= False;
  with TXICA_TemplateDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_TemplateItem.GetContrast(out Current: Integer): Boolean;
begin
  Result:= False;
  with TXICA_TemplateDevice(rOwner) do
  try

  finally
  end;
end;

function TXICA_TemplateItem.GetContrast(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
begin
end;

function TXICA_TemplateItem.SetContrast(const Value: Integer): Boolean;
begin
end;

function TXICA_TemplateItem.GetImageFormat(out Current: TXICA_ImageFormat): Boolean;
begin
end;

function TXICA_TemplateItem.GetImageFormat(out Current, Default: TXICA_ImageFormat; out Values: TXICA_ImageFormats): Boolean;
begin
  Result:= False;
  try
     Values:= [];

  finally
  end;
end;

function TXICA_TemplateItem.SetImageFormat(const Value: TXICA_ImageFormat; out ImgExt: String): Boolean;
begin
  Result:= inherited SetImageFormat(Value, ImgExt);
end;

function TXICA_TemplateItem.GetDataType(out Current: TXICA_DataType): Boolean;
begin
end;

function TXICA_TemplateItem.GetDataType(out Current, Default: TXICA_DataType; out Values: TXICA_DataTypes): Boolean;
begin
  Result:= False;
  try
     Values:= [];

  finally
  end;
end;

function TXICA_TemplateItem.SetDataType(const Value: TXICA_DataType): Boolean;
begin
end;

function TXICA_TemplateItem.GetBitDepth(out Current, Default: Integer; out Values: TArrayInteger): Boolean;
begin
end;

function TXICA_TemplateItem.GetBitDepth(out Current: Integer): Boolean;
begin
end;

function TXICA_TemplateItem.SetBitDepth(const Value: Integer): Boolean;
begin
end;


{ TXICA_TemplateDevice }

function TXICA_TemplateDevice._EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean;
var
   curName: String;
   curItem: TXICA_TemplateItem;

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

function TXICA_TemplateDevice.OpenDS: Boolean;
begin
  try
     if not(TXICA_TemplateManager(rOwner).Enabled) then TXICA_TemplateManager(rOwner).LoadTemplateLibrary;

     //Open only if it is not already opened
     if not(rOpened) then
     begin
       //Open...

       if (True) then  //if is Opened
       begin
         //Increase the loaded sources count variable
         inc(TXICA_TemplateManager(rOwner).rOpenedSources);
         rOpened:= True;
       end;
     end;

  finally
     Result:= rOpened;
  end;
end;

procedure TXICA_TemplateDevice.CloseDS;
begin
  //Close only if it is opened
  if rOpened then
  begin
    //Close

    //Decrease the loaded sources count variable
    dec(TXICA_TemplateManager(rOwner).rOpenedSources);
    rOpened:= False;
  end;
end;

constructor TXICA_TemplateDevice.Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADeviceID: String);
begin
  inherited Create(AOwner, AIndex, ADeviceID);

  rEnabled:= False;
  rDownloadItem:= nil;
  rVersion:= rOwner.Version;
  rVersionSub:= rOwner.VersionSub;
end;

constructor TXICA_TemplateDevice.Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADevice: Integer{SOME TEMPLATE RECORD});
begin
  inherited Create(AOwner, AIndex, ADevice.name);

//  rDevice:= ADevice;
//  rManufacturer:= rDevice.vendor;
//  rName:= rDevice.model;
//  rVersion:= rDevice.Version;
//  rVersionSub:= rDevice.VersionSub;
end;

destructor TXICA_TemplateDevice.Destroy;
begin
  inherited Destroy;
end;

function TXICA_TemplateDevice.DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
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

  if (TXICA_TemplateManager(rOwner) = nil) then exit;

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

     if (lres = S_OK) then
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


{ TXICA_TemplateManager }

procedure TXICA_TemplateManager.LoadTemplateLibrary;
begin
  try
     rLibHandle:= LoadLibrary(PChar(TemplateDirectory + TemplateLIBRARY));
     if (rLibHandle <> 0) then
     begin
     end;

  except
    rLibHandle:= 0;
  end;
end;

procedure TXICA_TemplateManager.UnloadTemplateLibrary;
begin
  try
     if (rLibHandle <> 0) then FreeLibrary(rLibHandle);
     rLibHandle:= 0;

  except

  end;
end;

function TXICA_TemplateManager._EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean;
var
  i:integer;
  devCount: Integer;
  curDevice: TXICA_TemplateDevice;
  curName: String;

  procedure CreateDevice;
  begin
    if PreserveSelected and (ALastSelected <> nil) //and (ALastSelected.ID = MakeID(curIdentity))
    then begin
           curDevice:= TXICA_TemplateDevice(ALastSelected);
           Add(curDevice.ID, ALastSelected);
           SelectedIndex:= i;
           curDevice.rIndex:= i;  //Update Index because can be different (Actually not used)
         end
    else begin
           curDevice:= TXICA_TemplateDevice.Create(Self, i, curName);
           Add(curDevice.ID, curDevice);
         end;
  end;

begin
  Result:= False;

  //Enum...

  Result :=True;
end;

constructor TXICA_TemplateManager.Create(const AEnumAll: Boolean = True);
begin
  inherited Create(AEnumAll);

  LoadTemplateLibrary;
end;

destructor TXICA_TemplateManager.Destroy;
begin
  inherited Destroy;

  UnloadTemplateLibrary;
end;

function TXICA_TemplateManager.Enabled: Boolean;
begin
  Result:= (rLibHandle <> 0);
end;

class function TXICA_TemplateManager.Name: String;
begin
  Result:= 'Template';
end;

initialization
  Template_Manager:= TXICA_TemplateManager.Create(XICA_EnumAllDevices);
  XICA_RegisterDeviceManager(TXICA_TemplateManager.Name, Template_Manager);

end.

