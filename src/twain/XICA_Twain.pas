(*******************************************************************************
*                XICA (Cross-platform Image Capture Architecture)              *
*                                                                              *
*  FILE: XICA_Twain.pas                                                        *
*                                                                              *
*  VERSION:     0.0.1                                                          *
*                                                                              *
*  DESCRIPTION:                                                                *
*    Twain implementation                                                      *
*                                                                              *
********************************************************************************
*                                                                              *
*  (c) 2026 Massimo Magnano                                                    *
*                                                                              *
*  See changelog.txt for Change Log                                            *
*                                                                              *
*******************************************************************************)
unit XICA_Twain;

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
     Twain,
     XICA_Types, XICA_Classes;

type
  //Return set for capability retrieving/setting
  TCapabilityRet = (crSuccess, crUnsupported, crBadOperation, crDependencyError, crLowMemory, crInvalidState, crInvalidContainer);

  {Kinds of capability operation}
  TCapabilityOperation = (capGet, capGetCurrent, capGetDefault, capReset, capResetAll, capSet, capSetConstraint);
  TCapabilityOperations = set of TCapabilityOperation;

  { TXICA_TwainItem }

  TXICA_TwainItem = class(TXICA_Item)
  protected
    //Get Max Paper Width, Height form the Device (in Inches)
    function _GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean; override;

    //Returns return status information
    function GetReturnStatus: TW_UINT16;

    //Converts from a result to a TCapabilityRet
    function ResultToCapabilityRec(const Value: TW_UINT16): TCapabilityRet;

    //Returns a capability structure
    function GetCapabilityRec(const ACapabilityId: TW_UINT16; out Handle: HGLOBAL; Mode: TW_UINT16; out Container: TW_UINT16): TW_UINT16;

    //Get Current Capability Value and it's type given the ID
    function GetCapability(const ACapabilityId: TW_UINT16; const AMode: TW_UINT16; out CapabilityType: TW_UINT16; out ACapabilityValue): TW_UINT16; overload;

    //Get Current, Default and Possible Values of a Capability given the ID,
    //  Depending on the type returned in CapabilityType
    //  ACapabilityListValues can be a Dynamic Array of Integers, Real, etc... user must free it
    //  if Result contain the Flag prop_RANGE then use XICA_RANGE_XXX Indexes to get MIN/MAX/STEP Values
    function GetCapability(const ACapabilityId: TW_UINT16; out CapabilityType: TW_UINT16;
                           out ACapabilityValue, ACapabilityDefaultValue;
                           out ACapabilityListValues): TXICA_PropertyFlags; overload;

    //Get a Range Capability with Current, Default, Min, Max, Step Values  { #note 5 -oMaxM : do I keep it? }
    //   user MUST specify the type in propType in order to internally allocate the correct array, otherwise expect an exception
    function GetCapability(const ACapabilityId: TW_UINT16; var CapabilityType: TW_UINT16;
                           out ACapabilityValue, ACapabilityDefault, ACapabilityMin, ACapabilityMax, ACapabilityStep): TW_UINT16; overload;

    //Set the Capability Value given the ID, the user must know the correct type to use
    function SetCapability(const ACapabilityId: TW_UINT16; const CapabilityType: TW_UINT16; const ACapabilityValue): Boolean;

  public
    destructor Destroy; override;

    //Download the Item and return the number of files transfered.
    // if multiple pages is downloaded then the file names are
    // APath\AFileName-n.AExt where n is then Index (when 0 n is not present)
    function Download(APath, AFileName, AExt: String): Integer; overload; override;

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

  { TXICA_TwainDevice }

  TXICA_TwainDevice = class(TXICA_Device)
  protected
    rOpened,
    rEnabled: Boolean;
    rIdentity: TW_IDENTITY;

    //Enumerate the avaliable items
    function _EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean; override;

    function GetType_Str: String; override;

    //Returns supported capability Operations
    function GetCapabilitySupportedOp(const ACapabilityId: TW_UINT16): TCapabilityOperations;

    function ProcessMessage(const Msg: TMsg): Boolean; virtual;

    procedure OpenDS; virtual;
    procedure CloseDS; virtual;

    procedure EnableDS(const ShowUI, Modal: Boolean; const ParentWindow: THandle=0); overload; virtual;
    procedure EnableDS(const UserInterface: TW_USERINTERFACE); overload; virtual;
    procedure DisableDS; virtual;

    procedure TransferImages; virtual;

  public
    constructor Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADeviceID: String); overload; override;
    constructor Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADeviceIdentity: TW_IDENTITY); overload; virtual;
    destructor Destroy; override;

    //Download using Native UI and return the number of files transfered in DownloadedFiles array.
    //  The system dialog works at Device level, so the selected item is ignored
    function DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
                              APath, AFileName: String;
                              out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer; override;

    property Identity: TW_IDENTITY read rIdentity;

    property Opened: Boolean read rOpened;
    property Enabled: Boolean read rEnabled;
  end;

  { TXICA_TwainManager }

  TXICA_TwainManager = class(TXICA_DeviceManager)
  protected
    TwainDirectory: String;
    m_DSMState,
    rOpenedSources,
    rEnabledSources: Integer;
    rLibHandle: HInst;
    lRes: HResult;
    VirtualWindow: THandle;

    //Enumerate the avaliable devices
    function _EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean; override;

    //Loads twain library and set rLibrayLoaded if it loaded sucessfully
    procedure LoadDSMLibrary; virtual;

    //Unloads twain library
    procedure UnloadDSMLibrary; virtual;

    procedure connectDSM; virtual;
    procedure disconnectDSM; virtual;

    procedure CreateVirtualWindow; virtual;
    procedure DestroyVirtualWindow; virtual;

  public
    constructor Create(const AEnumAll: Boolean = True); override;
    destructor Destroy; override;

    //Is the library loaded?
    function Enabled: Boolean; override;

    class function Name: String; override;

    property OpenedSources: Integer read rOpenedSources;
    property EnabledSources: Integer read rEnabledSources;
  end;

var
   AppIdentity : TW_IDENTITY;

{$endif}

implementation

{$ifdef MSWINDOWS}

uses Messages, XICA;

const
  {Name of the Twain library for 32 bits enviroment}
  TWAINLIBRARY_64 = 'TWAINDSM.DLL';
  TWAINLIBRARY_32 = 'TWAIN_32.DLL';

  {$IFDEF WIN64}
  TWAINLIBRARY = TWAINLIBRARY_64;
  {$ELSE}
  TWAINLIBRARY = TWAINLIBRARY_32;
  {$ENDIF}

  VirtualWinClassName: array[0..17] of WideChar =
  ('X', 'I', 'C', 'A', '_', 'T', 'w', 'a', 'i', 'n', 'M', 'a', 'n', 'a', 'g', 'e', 'r', #0);


type
  //Kinds of directories to be obtained with GetCustomDirectory
  TDirectoryKind = (dkWindows, dkSystem, dkCurrent, dkApplication, dkTemp);

var
   gDSM_Entry: TW_ENTRYPOINT;
   Twain_Manager: TXICA_TwainManager = nil;


//Returns Windows directories
function GetCustomDirectory(const DirectoryKind: TDirectoryKind): String;
var
   Buffer: array[0..MAX_PATH] of Char;

begin
  try
     case DirectoryKind of
     dkWindows: SetString(Result, Buffer, Windows.GetWindowsDirectory(Buffer, MAX_PATH));
     dkSystem : SetString(Result, Buffer, Windows.GetSystemDirectory(Buffer, MAX_PATH));
     dkCurrent: SetString(Result, Buffer, Windows.GetCurrentDirectory(MAX_PATH, Buffer));
     dkApplication: Result:= ExtractFileDir(ParamStr(0));
     dkTemp   : SetString(Result, Buffer, Windows.GetTempPath(MAX_PATH, Buffer));
     end;
     Result:= IncludeTrailingBackslash(Result);

  except
    Result:= ''
  end;
end;

//Returns full Twain directory (usually in Windows directory)
function GetTwainDirectory(const ALib: String = TWAINLIBRARY): String;
var
   i: TDirectoryKind;
   Dir: String;

begin
  //Searches in all the directories
  for i :=Low(TDirectoryKind) to High(TDirectoryKind) do
  try
     //Directory to search
     Dir:= GetCustomDirectory(i);

     //Tests if the file exists in this directory
     if FileExists(Dir + ALib) then
     begin
       Result:= Dir; break;
     end;
  except
    //FileExists got an ERangeError Exception when File does not exists
  end;
end;

//Returns a TMsg structure from a Message Params
function MakeMsg(const Handle: THandle; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): TMsg;
begin
  Result.hwnd := Handle;
  Result.message := uMsg;
  Result.wParam := wParam;
  Result.lParam := lParam;
  GetCursorPos(Result.pt);
end;

function MakeID(AIdentity: TW_IDENTITY): String;
begin
  Result:= AIdentity.Manufacturer+'\'+AIdentity.ProductName;
end;

function DSM_Alloc(_size: TW_UINT32): TW_HANDLE;
begin
  if Assigned(gDSM_Entry.DSM_MemAllocate)
  then Result:= gDSM_Entry.DSM_MemAllocate(_size)
  else Result:= GlobalAlloc(GPTR, _size);
end;

procedure DSM_Free(_hMemory: TW_HANDLE);
begin
  if Assigned(gDSM_Entry.DSM_MemFree)
  then gDSM_Entry.DSM_MemFree(_hMemory)
  else GlobalFree(_hMemory);
end;

function DSM_LockMemory(_hMemory: TW_HANDLE): TW_MEMREF;
begin
  if Assigned(gDSM_Entry.DSM_MemLock)
  then Result:= gDSM_Entry.DSM_MemLock(_hMemory)
  else Result:= GlobalLock(_hMemory);
end;

procedure DSM_UnlockMemory(_hMemory: TW_HANDLE);
begin
  if Assigned(gDSM_Entry.DSM_MemUnlock)
  then gDSM_Entry.DSM_MemUnlock(_hMemory)
  else GlobalUnlock(_hMemory);
end;

//Convert from Single to Fix32
function FloatToFix32 (floater: Single): TW_FIX32;
//Chad Berchek new code:
var
  i32: Cardinal;
begin
  {$IFOPT R+}{$DEFINE RANGEON}{$ELSE}{$UNDEF RANGEON}{$ENDIF} {save initial switch state}
  {$R-}
  i32 := Round(floater * 65536.0);
  Result.Whole := i32 shr 16;
  Result.Frac := i32 and $ffff;
  {$IFDEF RANGEON}{$R+}{$UNDEF RANGEON}{$ENDIF}
end;
{function FloatToFix32 (floater: Single): TW_FIX32;
//old code
var
  fracpart : Single;
begin
  //Obtain numerical part by truncating the float number
  Result.Whole := trunc(floater);
  //Obtain fracional part by subtracting float number by
  //numerical part. Also we make sure the number is not
  //negative by multipling by -1 if it is negative
  fracpart := floater - result.Whole;
  if fracpart < 0 then fracpart := fracpart * -1;
  //Multiply by 10 until there is no fracional part any longer
  while FracPart - trunc(FracPart) <> 0 do fracpart := fracpart * 10;
  //Return fracional part
  Result.Frac := trunc(fracpart);
end;}

//Convert from twain Fix32 to Single
function Fix32ToFloat(Value: TW_FIX32): Single;
begin
  {$IFOPT R+}{$DEFINE RANGEON}{$ELSE}{$UNDEF RANGEON}{$ENDIF} {save initial switch state}
  {$R-}
  Result := Value.Whole + (Value.Frac / 65536.0);
  {$IFDEF RANGEON}{$R+}{$UNDEF RANGEON}{$ENDIF}
end;

{Returns the size of a twain type}
function TW_TypeSize(TypeName: TW_UINT16): Integer;
begin
  {Test the type to return the size}
  case TypeName of
    TWTY_INT8  :  Result := sizeof(TW_INT8);
    TWTY_UINT8 :  Result := sizeof(TW_UINT8);
    TWTY_INT16 :  Result := sizeof(TW_INT16);
    TWTY_UINT16:  Result := sizeof(TW_UINT16);
    TWTY_INT32 :  Result := sizeof(TW_INT32);
    TWTY_UINT32:  Result := sizeof(TW_UINT32);
    TWTY_FIX32 :  Result := sizeof(TW_FIX32);
    TWTY_FRAME :  Result := sizeof(TW_FRAME);
    TWTY_STR32 :  Result := sizeof(TW_STR32);
    TWTY_STR64 :  Result := sizeof(TW_STR64);
    TWTY_STR128:  Result := sizeof(TW_STR128);
    TWTY_STR255:  Result := sizeof(TW_STR255);
    //npeter: the following types were not implemented
    //especially the bool caused problems
    TWTY_BOOL:    Result := sizeof(TW_BOOL);
    TWTY_UNI512:  Result := sizeof(TW_UNI512);
    TWTY_STR1024:  Result := sizeof(TW_STR1024);
    else          Result := 0;
  end {case}
end;

//Convert Twain Data to Value
function TW_GetData(const ADataType: TW_UINT16; const Data: Pointer; out Value): Boolean;
begin
  Result:= True;

  case ADataType of
  TWTY_INT8   : TW_INT8(Value):= pTW_INT8(Data)^;
  TWTY_UINT8  : TW_UINT8(Value):= pTW_UINT8(Data)^;
  TWTY_INT16,
  44 {TWTY_HANDLE} : TW_INT16(Value):= pTW_INT16(Data)^;
  TWTY_UINT16 : TW_UINT16(Value):= pTW_UINT16(Data)^;
  TWTY_INT32  : TW_INT32(Value):= pTW_INT32(Data)^;
  TWTY_UINT32,
  43 {TWTY_MEMREF} : TW_UINT32(Value):= pTW_UINT32(Data)^;
  TWTY_BOOL   : TW_BOOL(Value):= pTW_BOOL(Data)^;
  TWTY_FIX32  : Single(Value):= Fix32ToFloat(pTW_FIX32(Data)^);
  //TWTY_FRAME
  TWTY_STR32,
  TWTY_STR64,
  TWTY_STR128,
  TWTY_STR255 : String(Value):= String(PAnsiChar(Data));
  else Result:= False;
  end;
end;



{ TXICA_TwainItem }

destructor TXICA_TwainItem.Destroy;
begin
  inherited Destroy;
end;

function TXICA_TwainItem.Download(APath, AFileName, AExt: String): Integer;
begin
  Result:= 0;

    if (APath = '') or CharInSet(APath[Length(APath)], AllowDirectorySeparators)
    then rDownload_Path:= APath
    else rDownload_Path:= APath+DirectorySeparator;

    if (rDownload_Path<>'') and not(ForceDirectories(rDownload_Path)) then exit;

    rDownload_FileName:= AFileName;
    rDownload_Ext:= AExt;
    rDownload_Count:= 0;
    rDownloaded:= False;

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
//  end;
end;

function TXICA_TwainItem.GetResolutionsX(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags;
begin
end;

function TXICA_TwainItem.GetResolutionsY(out Current, Default: Integer; out Values: TArrayInteger): TXICA_PropertyFlags;
begin
end;

function TXICA_TwainItem.GetResolution(out AXRes, AYRes: Integer): Boolean;
begin
end;

function TXICA_TwainItem.SetResolution(const AXRes, AYRes: Integer): Boolean;
begin
end;

function TXICA_TwainItem.GetPaperRect(out Current: TRect): Boolean;
begin
end;

function TXICA_TwainItem.GetPaperRect(out Current, Default: TRect): Boolean;
begin
end;

function TXICA_TwainItem.SetPaperRect(const X, Y, Width, Height: Integer): Boolean;
begin
end;

function TXICA_TwainItem._GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean;
begin
end;

function TXICA_TwainItem.GetReturnStatus: TW_UINT16;
var
  StatusInfo: TW_STATUS;

begin
  //The source must be loaded in order to get the status
  if TXICA_TwainDevice(Owner).Opened then
  begin
    DSM_Entry(@AppIdentity, @TXICA_TwainDevice(Owner).rIdentity, DG_CONTROL, DAT_STATUS, MSG_GET, @StatusInfo);
    Result := StatusInfo.ConditionCode;
  end
  else Result:= 0;
end;

function TXICA_TwainItem.ResultToCapabilityRec(const Value: TW_UINT16): TCapabilityRet;
begin
  case Value of
  TWRC_SUCCESS: Result:= crSuccess;
  else case GetReturnStatus of  //Error, get more on the error, and return result}
         TWCC_CAPUNSUPPORTED: Result := crUnsupported;
         TWCC_CAPBADOPERATION: Result := crBadOperation;
         TWCC_CAPSEQERROR: Result := crDependencyError;
         TWCC_LOWMEMORY: Result := crLowMemory;
         TWCC_SEQERROR: Result := crInvalidState;
         else Result := crBadOperation;
       end;
  end;
end;

function TXICA_TwainItem.GetCapabilityRec(const ACapabilityId: TW_UINT16;
                                          out Handle: HGLOBAL; Mode: TW_UINT16; out Container: TW_UINT16): TW_UINT16;
var
  CapabilityInfo: TW_CAPABILITY;

begin
  //Source must be loaded
  if TXICA_TwainDevice(Owner).Opened then
  begin
    //Fill structure
    CapabilityInfo.Cap:= ACapabilityId;
    CapabilityInfo.ConType:= TWON_DONTCARE16;
    CapabilityInfo.hContainer:= 0;

    //Call DSM_Entry and store return
    Result:= DSM_Entry(@AppIdentity, @TXICA_TwainDevice(Owner).rIdentity, DG_CONTROL, DAT_CAPABILITY, Mode, @CapabilityInfo);

    if (Result = TWRC_SUCCESS) then
    begin
      Handle:= CapabilityInfo.hContainer;
      Container:= CapabilityInfo.ConType;
    end
  end
  else Result:= TWRC_DATANOTAVAILABLE;
end;

function TXICA_TwainItem.GetCapability(const ACapabilityId: TW_UINT16;  const AMode: TW_UINT16;
                                       out CapabilityType: TW_UINT16; out ACapabilityValue): TW_UINT16;
var
  OneV: pTW_ONEVALUE;
  Container: TW_UINT16;
  MemHandle: HGLOBAL;

begin
  MemHandle:= 0;

  Result:= GetCapabilityRec(ACapabilityId, MemHandle, AMode, {%H-}Container);
  if (Result = TWRC_SUCCESS) then
  begin
    if (Container = TWON_ONEVALUE) then
    try
       //Obtain structure pointer
       OneV:= DSM_LockMemory(MemHandle);
       if (OneV = nil) then exit(TWRC_DATANOTAVAILABLE);

       CapabilityType:= OneV^.ItemType;

       case CapabilityType of
       TWTY_INT8   : Shortint(ACapabilityValue):= pTW_INT8(@OneV^.Item)^;
       TWTY_UINT8  : Byte(ACapabilityValue):= pTW_UINT8(@OneV^.Item)^;
       TWTY_INT16,
       44 {TWTY_HANDLE} : Smallint(ACapabilityValue):= pTW_INT16(@OneV^.Item)^;
       TWTY_UINT16 : Word(ACapabilityValue):= pTW_UINT16(@OneV^.Item)^;
       TWTY_INT32  : Integer(ACapabilityValue):= pTW_INT32(@OneV^.Item)^;
       TWTY_UINT32,
       43 {TWTY_MEMREF} : LongWord(ACapabilityValue):= pTW_UINT32(@OneV^.Item)^;
       TWTY_BOOL   : Boolean(ACapabilityValue):= pTW_BOOL(@OneV^.Item)^;
       TWTY_FIX32  : Single(ACapabilityValue):= Fix32ToFloat(pTW_FIX32(@OneV^.Item)^);
       //TWTY_FRAME
       TWTY_STR32,
       TWTY_STR64,
       TWTY_STR128,
       TWTY_STR255 : String(ACapabilityValue):= String(PAnsiChar(@OneV^.Item));
       else Result:= TWRC_DATANOTAVAILABLE;
       end;

    finally
       //Unlock memory
       DSM_UnlockMemory(MemHandle);
    end;

    //Unallocate memory
    DSM_Free(MemHandle);
  end;
end;

function TXICA_TwainItem.GetCapability(const ACapabilityId: TW_UINT16; out CapabilityType: TW_UINT16;
                                       out ACapabilityValue, ACapabilityDefaultValue; out ACapabilityListValues): TXICA_PropertyFlags;
var
   ArrayV   : pTW_ARRAY;
   RangeV   : pTW_RANGE;
   NumItems,
   ItemSize : Integer;
   Data     : Pointer;
   CurItem  : Integer;
   Container: TW_UINT16;
   MemHandle: HGLOBAL;

begin
  MemHandle:= 0;

  Result:= [];
  if (GetCapabilityRec(ACapabilityId, MemHandle, MSG_GET, {%H-}Container) = TWRC_SUCCESS) then
  try
     Case Container of
       TWON_ARRAY,
       TWON_ENUMERATION: try
          ArrayV:= GlobalLock(MemHandle);
          if (ArrayV = nil) then exit;

          Result:= Result+[prop_READ, prop_LIST];

          //Prepare to list items
          //  The two records have the first two fields (ItemType, NumItems) in the same position, so we have no problems.
          CapabilityType:= ArrayV^.ItemType;
          NumItems:= ArrayV^.NumItems;
          //  To get Data Pointer to First List Item we use a Cast to skip TW_ENUMERATION CurrentIndex, DefaultIndex
          if (Container = TWON_ARRAY)
          then Data:= @ArrayV^.ItemList[0]
          else Data:= @pTW_ENUMERATION(ArrayV)^.ItemList[0];

          ItemSize:= TW_TypeSize(CapabilityType);

          case CapabilityType of
            TWTY_INT8   : begin
              SetLength(TArrayShortint(ACapabilityListValues), NumItems);
              //Copy items
              for CurItem:= 0 to ArrayV^.NumItems-1 do
              begin
                TArrayShortint(ACapabilityListValues)[CurItem]:= pTW_INT8(Data)^;

                //Move memory to the next Data
                inc(Data, ItemSize);
              end;

              if (Container = TWON_ENUMERATION) then
              begin
                Shortint(ACapabilityValue):= TArrayShortint(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.CurrentIndex];
                Shortint(ACapabilityDefaultValue):= TArrayShortint(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.DefaultIndex];
              end;
            end;
            TWTY_UINT8  : begin
              SetLength(TArrayByte(ACapabilityListValues), NumItems);
              //Copy items
              for CurItem:= 0 to NumItems-1 do
              begin
                TArrayByte(ACapabilityListValues)[CurItem]:= pTW_UINT8(Data)^;

                //Move memory to the next Data
                inc(Data, ItemSize);
              end;

              if (Container = TWON_ENUMERATION) then
              begin
                Byte(ACapabilityValue):= TArrayByte(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.CurrentIndex];
                Byte(ACapabilityDefaultValue):= TArrayByte(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.DefaultIndex];
              end;
            end;
            TWTY_INT16,
            44 {TWTY_HANDLE} : begin
              SetLength(TArraySmallint(ACapabilityListValues), NumItems);
              //Copy items
              for CurItem:= 0 to NumItems-1 do
              begin
                TArraySmallint(ACapabilityListValues)[CurItem]:= pTW_INT16(Data)^;

                //Move memory to the next Data
                inc(Data, ItemSize);
              end;

              if (Container = TWON_ENUMERATION) then
              begin
                Smallint(ACapabilityValue):= TArraySmallint(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.CurrentIndex];
                Smallint(ACapabilityDefaultValue):= TArraySmallint(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.DefaultIndex];
              end;
            end;
            TWTY_UINT16 : begin
              SetLength(TArrayWord(ACapabilityListValues), NumItems);
              //Copy items
              for CurItem:= 0 to NumItems-1 do
              begin
                TArrayWord(ACapabilityListValues)[CurItem]:= pTW_UINT16(Data)^;

                //Move memory to the next Data
                inc(Data, ItemSize);
              end;

              if (Container = TWON_ENUMERATION) then
              begin
                Word(ACapabilityValue):= TArrayWord(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.CurrentIndex];
                Word(ACapabilityDefaultValue):= TArrayWord(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.DefaultIndex];
              end;
            end;
            TWTY_INT32  : begin
              SetLength(TArrayInteger(ACapabilityListValues), NumItems);
              //Copy items
              for CurItem:= 0 to NumItems-1 do
              begin
                TArrayInteger(ACapabilityListValues)[CurItem]:= pTW_INT32(Data)^;

                //Move memory to the next Data
                inc(Data, ItemSize);
              end;

              if (Container = TWON_ENUMERATION) then
              begin
                Integer(ACapabilityValue):= TArrayInteger(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.CurrentIndex];
                Integer(ACapabilityDefaultValue):= TArrayInteger(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.DefaultIndex];
              end;
            end;
            TWTY_UINT32,
            43 {TWTY_MEMREF} : begin
              SetLength(TArrayLongWord(ACapabilityListValues), NumItems);
              //Copy items
              for CurItem:= 0 to NumItems-1 do
              begin
                TArrayLongWord(ACapabilityListValues)[CurItem]:= pTW_UINT32(Data)^;

                //Move memory to the next Data
                inc(Data, ItemSize);
              end;

              if (Container = TWON_ENUMERATION) then
              begin
                LongWord(ACapabilityValue):= TArrayLongWord(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.CurrentIndex];
                LongWord(ACapabilityDefaultValue):= TArrayLongWord(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.DefaultIndex];
              end;
            end;
            TWTY_BOOL   : begin
              SetLength(TArrayBoolean(ACapabilityListValues), NumItems);
              //Copy items
              for CurItem:= 0 to NumItems-1 do
              begin
                TArrayBoolean(ACapabilityListValues)[CurItem]:= pTW_BOOL(Data)^;

                //Move memory to the next Data
                inc(Data, ItemSize);
              end;

              if (Container = TWON_ENUMERATION) then
              begin
                Boolean(ACapabilityValue):= TArrayBoolean(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.CurrentIndex];
                Boolean(ACapabilityDefaultValue):= TArrayBoolean(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.DefaultIndex];
              end;
            end;
            TWTY_FIX32  : begin
              SetLength(TArraySingle(ACapabilityListValues), NumItems);
              //Copy items
              for CurItem:= 0 to NumItems-1 do
              begin
                TArraySingle(ACapabilityListValues)[CurItem]:= Fix32ToFloat(pTW_FIX32(Data)^);

                //Move memory to the next Data
                inc(Data, ItemSize);
              end;

              if (Container = TWON_ENUMERATION) then
              begin
                Single(ACapabilityValue):= TArraySingle(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.CurrentIndex];
                Single(ACapabilityDefaultValue):= TArraySingle(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.DefaultIndex];
              end;
            end;
            //TWTY_FRAME
            TWTY_STR32,
            TWTY_STR64,
            TWTY_STR128,
            TWTY_STR255 : begin
              SetLength(TStringArray(ACapabilityListValues), NumItems);
              //Copy items
              for CurItem:= 0 to NumItems-1 do
              begin
                TStringArray(ACapabilityListValues)[CurItem]:= String(PAnsiChar(Data));

                //Move memory to the next Data
                inc(Data, ItemSize);
              end;

              if (Container = TWON_ENUMERATION) then
              begin
                String(ACapabilityValue):= TStringArray(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.CurrentIndex];
                String(ACapabilityDefaultValue):= TStringArray(ACapabilityListValues)[pTW_ENUMERATION(ArrayV)^.DefaultIndex];
              end;
            end;
          end;

         if (Container = TWON_ARRAY) then
         begin
           //????????
           GetCapability(ACapabilityId, MSG_GETCURRENT, CapabilityType, ACapabilityValue);
           GetCapability(ACapabilityId, MSG_GETDEFAULT, CapabilityType, ACapabilityDefaultValue);
         end;

       finally
          //Unlock memory
          DSM_UnlockMemory(MemHandle);
       end;
       TWON_RANGE: try
         RangeV:= GlobalLock(MemHandle);
         if (RangeV = nil) then exit;

         Result:= Result+[prop_READ, prop_RANGE];

         case RangeV^.ItemType of
         TWTY_INT8   : begin
           SetLength(TArrayShortint(ACapabilityListValues), prop_RANGE_NUM_ELEMS);
           Shortint(TArrayShortint(ACapabilityListValues)[prop_RANGE_MIN]):= pTW_INT8(@RangeV^.MinValue)^;
           Shortint(TArrayShortint(ACapabilityListValues)[prop_RANGE_MAX]):= pTW_INT8(@RangeV^.MaxValue)^;
           Shortint(TArrayShortint(ACapabilityListValues)[prop_RANGE_STEP]):= pTW_INT8(@RangeV^.StepSize)^;
           Shortint(TArrayShortint(ACapabilityListValues)[prop_RANGE_DEFAULT]):= pTW_INT8(@RangeV^.DefaultValue)^;
           Shortint(ACapabilityDefaultValue):= pTW_INT8(@RangeV^.DefaultValue)^;
           Shortint(ACapabilityValue):= pTW_INT8(@RangeV^.CurrentValue)^;
         end;
         TWTY_UINT8  : begin
           SetLength(TArrayByte(ACapabilityListValues), prop_RANGE_NUM_ELEMS);
           Byte(TArrayByte(ACapabilityListValues)[prop_RANGE_MIN]):= pTW_UINT8(@RangeV^.MinValue)^;
           Byte(TArrayByte(ACapabilityListValues)[prop_RANGE_MAX]):= pTW_UINT8(@RangeV^.MaxValue)^;
           Byte(TArrayByte(ACapabilityListValues)[prop_RANGE_STEP]):= pTW_UINT8(@RangeV^.StepSize)^;
           Byte(TArrayByte(ACapabilityListValues)[prop_RANGE_DEFAULT]):= pTW_UINT8(@RangeV^.DefaultValue)^;
           Byte(ACapabilityDefaultValue):= pTW_UINT8(@RangeV^.DefaultValue)^;
           Byte(ACapabilityValue):= pTW_UINT8(@RangeV^.CurrentValue)^;
         end;
         TWTY_INT16, {TWTY_HANDLE}
         44          : begin
           SetLength(TArraySmallint(ACapabilityListValues), prop_RANGE_NUM_ELEMS);
           Smallint(TArraySmallint(ACapabilityListValues)[prop_RANGE_MIN]):= pTW_INT16(@RangeV^.MinValue)^;
           Smallint(TArraySmallint(ACapabilityListValues)[prop_RANGE_MAX]):= pTW_INT16(@RangeV^.MaxValue)^;
           Smallint(TArraySmallint(ACapabilityListValues)[prop_RANGE_STEP]):= pTW_INT16(@RangeV^.StepSize)^;
           Smallint(TArraySmallint(ACapabilityListValues)[prop_RANGE_DEFAULT]):= pTW_INT16(@RangeV^.DefaultValue)^;
           Smallint(ACapabilityDefaultValue):= pTW_INT16(@RangeV^.DefaultValue)^;
           Smallint(ACapabilityValue):= pTW_INT16(@RangeV^.CurrentValue)^;
         end;
         TWTY_UINT16 : begin
           SetLength(TArrayWord(ACapabilityListValues), prop_RANGE_NUM_ELEMS);
           Word(TArrayWord(ACapabilityListValues)[prop_RANGE_MIN]):= pTW_UINT16(@RangeV^.MinValue)^;
           Word(TArrayWord(ACapabilityListValues)[prop_RANGE_MAX]):= pTW_UINT16(@RangeV^.MaxValue)^;
           Word(TArrayWord(ACapabilityListValues)[prop_RANGE_STEP]):= pTW_UINT16(@RangeV^.StepSize)^;
           Word(TArrayWord(ACapabilityListValues)[prop_RANGE_DEFAULT]) := pTW_UINT16(@RangeV^.DefaultValue)^;
           Word(ACapabilityDefaultValue):= pTW_UINT16(@RangeV^.DefaultValue)^;
           Word(ACapabilityValue):= pTW_UINT16(@RangeV^.CurrentValue)^;
         end;
         TWTY_INT32  : begin
           SetLength(TArrayInteger(ACapabilityListValues), prop_RANGE_NUM_ELEMS);
           Integer(TArrayInteger(ACapabilityListValues)[prop_RANGE_MIN]):= pTW_INT32(@RangeV^.MinValue)^;
           Integer(TArrayInteger(ACapabilityListValues)[prop_RANGE_MAX]):= pTW_INT32(@RangeV^.MaxValue)^;
           Integer(TArrayInteger(ACapabilityListValues)[prop_RANGE_STEP]):= pTW_INT32(@RangeV^.StepSize)^;
           Integer(TArrayInteger(ACapabilityListValues)[prop_RANGE_DEFAULT]):= pTW_INT32(@RangeV^.DefaultValue)^;
           Integer(ACapabilityDefaultValue):= pTW_INT32(@RangeV^.DefaultValue)^;
           Integer(ACapabilityValue):= pTW_INT32(@RangeV^.CurrentValue)^;
         end;
         TWTY_UINT32, {TWTY_MEMREF}
         43           : begin
           SetLength(TArrayLongWord(ACapabilityListValues), prop_RANGE_NUM_ELEMS);
           LongWord(TArrayLongWord(ACapabilityListValues)[prop_RANGE_MIN]):= pTW_UINT32(@RangeV^.MinValue)^;
           LongWord(TArrayLongWord(ACapabilityListValues)[prop_RANGE_MAX]):= pTW_UINT32(@RangeV^.MaxValue)^;
           LongWord(TArrayLongWord(ACapabilityListValues)[prop_RANGE_STEP]):= pTW_UINT32(@RangeV^.StepSize)^;
           LongWord(TArrayLongWord(ACapabilityListValues)[prop_RANGE_DEFAULT]):= pTW_UINT32(@RangeV^.DefaultValue)^;
           LongWord(ACapabilityDefaultValue):= pTW_UINT32(@RangeV^.DefaultValue)^;
           LongWord(ACapabilityValue):= pTW_UINT32(@RangeV^.CurrentValue)^;
         end;
         TWTY_FIX32  : begin
           SetLength(TArraySingle(ACapabilityListValues), prop_RANGE_NUM_ELEMS);
           Single(TArraySingle(ACapabilityListValues)[prop_RANGE_MIN]):= Fix32ToFloat(pTW_FIX32(@RangeV^.MinValue)^);
           Single(TArraySingle(ACapabilityListValues)[prop_RANGE_MAX]):= Fix32ToFloat(pTW_FIX32(@RangeV^.MaxValue)^);
           Single(TArraySingle(ACapabilityListValues)[prop_RANGE_STEP]):= Fix32ToFloat(pTW_FIX32(@RangeV^.StepSize)^);
           Single(TArraySingle(ACapabilityListValues)[prop_RANGE_DEFAULT]):= Fix32ToFloat(pTW_FIX32(@RangeV^.DefaultValue)^);
           Single(ACapabilityDefaultValue):= Fix32ToFloat(pTW_FIX32(@RangeV^.DefaultValue)^);
           Single(ACapabilityValue):= Fix32ToFloat(pTW_FIX32(@RangeV^.CurrentValue)^);
         end;
         end;

       finally
          //Unlock memory
          DSM_UnlockMemory(MemHandle);
       end;
     end;

  finally
       //Unallocate memory
       DSM_Free(MemHandle);
  end;
end;

function TXICA_TwainItem.GetCapability(const ACapabilityId: TW_UINT16; var CapabilityType: TW_UINT16;
                                       out ACapabilityValue, ACapabilityDefault, ACapabilityMin, ACapabilityMax, ACapabilityStep): TW_UINT16;
begin

end;

function TXICA_TwainItem.SetCapability(const ACapabilityId: TW_UINT16; const CapabilityType: TW_UINT16; const ACapabilityValue): Boolean;
begin

end;

function TXICA_TwainItem.GetRotation(out Value: TXICA_Rotation): Boolean;
begin
end;

function TXICA_TwainItem.GetRotation(out Current, Default: TXICA_Rotation; out Values: TXICA_Rotations): Boolean;
begin
  Result:= False;
  try
     Values:=[];

  finally
  end;
end;

function TXICA_TwainItem.SetRotation(const Value: TXICA_Rotation): Boolean;
begin
end;

function TXICA_TwainItem.GetDocumentHandling(out Value: TXICA_DocumentHandlings): Boolean;
begin
end;

function TXICA_TwainItem.GetDocumentHandling(out Current, Default, Values: TXICA_DocumentHandlings): Boolean;
begin
  Result:= False;
  try
     Values:=[];

  finally
  end;
end;

function TXICA_TwainItem.SetDocumentHandling(const Value: TXICA_DocumentHandlings): Boolean;
begin
end;

function TXICA_TwainItem.GetPages(out Current: Integer): Boolean;
begin
end;

function TXICA_TwainItem.GetPages(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
begin
end;

function TXICA_TwainItem.SetPages(const Value: Integer): Boolean;
begin
end;

function TXICA_TwainItem.GetBrightness(out Current: Integer): Boolean;
begin
end;

function TXICA_TwainItem.GetBrightness(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
begin
end;

function TXICA_TwainItem.SetBrightness(const Value: Integer): Boolean;
begin
end;

function TXICA_TwainItem.GetContrast(out Current: Integer): Boolean;
begin
end;

function TXICA_TwainItem.GetContrast(out Current, Default, AMin, AMax, AStep: Integer): Boolean;
begin
end;

function TXICA_TwainItem.SetContrast(const Value: Integer): Boolean;
begin
end;

function TXICA_TwainItem.GetImageFormat(out Current: TXICA_ImageFormat): Boolean;
begin
end;

function TXICA_TwainItem.GetImageFormat(out Current, Default: TXICA_ImageFormat; out Values: TXICA_ImageFormats): Boolean;
begin
  Result:= False;
  try
     Values:= [];

  finally
  end;
end;

function TXICA_TwainItem.SetImageFormat(const Value: TXICA_ImageFormat): Boolean;
begin
end;

function TXICA_TwainItem.GetDataType(out Current: TXICA_DataType): Boolean;
begin
end;

function TXICA_TwainItem.GetDataType(out Current, Default: TXICA_DataType; out Values: TXICA_DataTypes): Boolean;
begin
  Result:= False;
  try
     Values:= [];

  finally
  end;
end;

function TXICA_TwainItem.SetDataType(const Value: TXICA_DataType): Boolean;
begin
end;

function TXICA_TwainItem.GetBitDepth(out Current, Default: Integer; out Values: TArrayInteger): Boolean;
begin
end;

function TXICA_TwainItem.GetBitDepth(out Current: Integer): Boolean;
begin
end;

function TXICA_TwainItem.SetBitDepth(const Value: Integer): Boolean;
begin
end;


{ TXICA_TwainDevice }

function TXICA_TwainDevice._EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean;
var
   curName: String;
   curItem: TXICA_TwainItem;
   capSupport: TCapabilityOperations;

begin
  Result:= False;

  try
     if (Type_ = devTypeDigitalCamera)
     then begin
            //Digital camera : Maybe Tested

            curName:= XICA_ItemCategoryDescr[xicFILM];
            if PreserveSelected and (ALastSelected <> nil) and (ALastSelected.Name = curName)
            then begin
                   curItem:= TXICA_TwainItem(ALastSelected);
                   Add(curName, ALastSelected);
                 end
            else begin
                   curItem:= TXICA_TwainItem.Create(Self, 0, curName);
                   curItem.Type_:= [xitProgrammableDataSource];
                   curItem.Category:= xicFILM;     //????
                   Add(curName, curItem);
                 end;

            SelectedIndex:= 0;
          end
     else begin
            //Device is a Scanner, Test if it has a Feeder
            capSupport:= GetCapabilitySupportedOp(CAP_FEEDERENABLED);
            if (capSupport = [])
            then begin
                   //Don't have a Feeder, so is a Flatbed Only Device

                   curName:= XICA_ItemCategoryDescr[xicFEEDER];
                   if PreserveSelected and (ALastSelected <> nil) and (ALastSelected.Name = curName)
                   then begin
                          curItem:= TXICA_TwainItem(ALastSelected);
                          Add(curName, ALastSelected);
                        end
                   else begin
                          curItem:= TXICA_TwainItem.Create(Self, 0, curName);
                          curItem.Type_:= [xitProgrammableDataSource];
                          curItem.Category:= xicFEEDER;
                          Add(curName, curItem);
                        end;

                   SelectedIndex:= 0;
                 end
            else begin
                   SelectedIndex:= -1;

                   if (capSet in capSupport) then
                   begin
                     Really Test if can SET

                     //I Can Disable the Feeder, so Device have also Flatbed
                     curName:= XICA_ItemCategoryDescr[xicFLATBED];
                     if PreserveSelected and (ALastSelected <> nil) and (ALastSelected.Name = curName)
                     then begin
                            curItem:= TXICA_TwainItem(ALastSelected);
                            Add(curName, ALastSelected);
                            SelectedIndex:= 0;
                          end
                     else begin
                            curItem:= TXICA_TwainItem.Create(Self, 0, curName);
                            curItem.Type_:= [xitProgrammableDataSource];
                            curItem.Category:= xicFLATBED;
                            Add(curName, curItem);
                          end;
                   end;

                   //Add Feeder
                   curName:= XICA_ItemCategoryDescr[xicFEEDER];
                   if PreserveSelected and (ALastSelected <> nil) and (ALastSelected.Name = curName)
                   then begin
                          curItem:= TXICA_TwainItem(ALastSelected);
                          Add(curName, ALastSelected);
                          SelectedIndex:= Length(rList)-1;
                        end
                   else begin
                          curItem:= TXICA_TwainItem.Create(Self, 0, curName);
                          curItem.Type_:= [xitProgrammableDataSource];
                          curItem.Category:= xicFEEDER;
                          Add(curName, curItem);
                        end;

                   if (SelectedIndex < 0) then SelectedIndex:= 0;
                 end;
          end;

     Result:= True;

  finally
  end;
end;

function TXICA_TwainDevice.GetType_Str: String;
begin
  if (rType in [devTypeUnknown..devTypeDigitalCamera])
  then Result:= inherited GetType_Str
(*
  else if (Integer(rType) = StiDeviceTypeStreamingVideo)
       then Result:= 'Streaming Video'
       else Result:= 'Undefined ('+IntToStr(Integer(rType))+')';
*)
end;

function TXICA_TwainDevice.GetCapabilitySupportedOp(const ACapabilityId: TW_UINT16): TCapabilityOperations;
var
   prevState: Boolean;
   CapabilityInfo: TW_CAPABILITY;
   OneV: pTW_ONEVALUE;

begin
  Result:= [];
  try
     prevState:= Opened;

     //Source must be loaded
     OpenDS;

     if Opened then
     begin
       //Fill structure
       CapabilityInfo.Cap:= ACapabilityId;
       CapabilityInfo.ConType:= TWON_ONEVALUE;
       CapabilityInfo.hContainer:= 0;

       //Call DSM_Entry and store return
       lRes:= DSM_Entry(@AppIdentity, @rIdentity, DG_CONTROL, DAT_CAPABILITY, MSG_QUERYSUPPORT, @CapabilityInfo);

       if (lRes = TWRC_SUCCESS) then
       try
          //Obtain structure pointer
          OneV:= DSM_LockMemory(CapabilityInfo.hContainer);
          if (OneV = nil) then exit;

          if (OneV^.Item and TWQC_GET)=TWQC_GET then Result:= [capGet];
          if (OneV^.Item and TWQC_SET)=TWQC_SET then Result:= Result+[capSet];
          if (OneV^.Item and TWQC_GETDEFAULT)=TWQC_GETDEFAULT then Result:= Result+[capGetDefault];
          if (OneV^.Item and TWQC_GETCURRENT)=TWQC_GETCURRENT then Result:= Result+[capGetCurrent];
          if (OneV^.Item and TWQC_RESET)=TWQC_RESET then Result:= Result+[capReset];
          if (OneV^.Item and TWQC_SETCONSTRAINT)=TWQC_SETCONSTRAINT then Result:= Result+[capSetConstraint];

       finally
          //Unlock memory
          DSM_UnlockMemory(CapabilityInfo.hContainer);

          //Unallocate memory
          DSM_Free(CapabilityInfo.hContainer);
       end;
     end;

  finally
     if not(prevState) then CloseDS;
  end;
end;

function TXICA_TwainDevice.ProcessMessage(const Msg: TMsg): Boolean;
var
  twEvent: TW_EVENT;
begin
  //Make twEvent structure
  twEvent.TWMessage:= MSG_NULL;
  twEvent.pEvent:= TW_MEMREF(@Msg);

  //Call DSM_Entry procedure to handle message
  Result:= (DSM_Entry(@AppIdentity, @rIdentity, DG_CONTROL, DAT_EVENT, MSG_PROCESSEVENT, @twEvent) = TWRC_DSEVENT);

  //{If it is a message from the source, process
  if Result then
    case twEvent.TWMessage of
      //No message from the source
      MSG_NULL: exit;
      //Requested to close the source
      MSG_CLOSEDSREQ:
      begin
        //Call notification event
        (*
        if (Assigned(Owner.OnAcquireCancel)) then
          Owner.OnAcquireCancel(Owner, Index);
        if Assigned(Owner.OnTransferComplete) then
          Owner.OnTransferComplete(Owner, Index, True);
        *)
        //Disable the source
        DisableDS;
      end;
      //Ready to transfer the images
      MSG_XFERREADY: TransferImages;  //Start Transfer Images

      MSG_CLOSEDSOK: Result:= True;

      MSG_DEVICEEVENT: Result:=true;
    end;
end;

procedure TXICA_TwainDevice.OpenDS;
begin
  if (TXICA_TwainManager(rOwner).m_DSMState < 3) then TXICA_TwainManager(rOwner).connectDSM;

  //Open only if it is not already opened
  if not(rOpened) then
  begin
    lRes:= DSM_Entry(@AppIdentity, nil, DG_CONTROL, DAT_IDENTITY, MSG_OPENDS, @rIdentity);

    if (lRes = TWRC_SUCCESS) then
    begin
      //Increase the loaded sources count variable
      inc(TXICA_TwainManager(rOwner).rOpenedSources);
      rOpened:= True;
    end;
  end;
end;

procedure TXICA_TwainDevice.CloseDS;
begin
  //Close only if it is opened
  if rOpened then
  begin
    //If is Enabled then Disable it first
    if rEnabled then DisableDS;

    lRes:= DSM_Entry(@AppIdentity, nil, DG_CONTROL, DAT_IDENTITY, MSG_CLOSEDS, @rIdentity);

    if (lRes = TWRC_SUCCESS) then
    begin
      //Increase the loaded sources count variable
      dec(TXICA_TwainManager(rOwner).rOpenedSources);
      rOpened:= False;
    end;
  end;
end;

procedure TXICA_TwainDevice.EnableDS(const ShowUI, Modal: Boolean; const ParentWindow: THandle);
var
  twUserInterface: TW_USERINTERFACE;

begin
  {Builds UserInterface structure}
  twUserInterface.ShowUI:= ShowUI;
  twUserInterface.ModalUI:= Modal;

  if (ParentWindow=0)
  then twUserInterface.hParent:= TXICA_TwainManager(rOwner).VirtualWindow    //Owner.CustomGetParentWindow
  else twUserInterface.hParent:= ParentWindow;

  EnableDS(twUserInterface);
end;

procedure TXICA_TwainDevice.EnableDS(const UserInterface: TW_USERINTERFACE);
begin
  //Enable only if it is not already Enabled
  if not(rEnabled) then
  begin
    //If not opened Open it First
    if not(rOpened) then OpenDS;

    if rOpened then
    begin
      lRes:= DSM_Entry(@AppIdentity, nil, DG_CONTROL, DAT_USERINTERFACE, MSG_ENABLEDS, @rIdentity);

      if (lRes in [TWRC_SUCCESS, TWRC_CHECKSTATUS]) then
      begin
        //Increase the loaded sources count variable
        inc(TXICA_TwainManager(rOwner).rEnabledSources);
        rEnabled:= True;
      end;
    end;
  end;
end;

procedure TXICA_TwainDevice.DisableDS;
var
  twUserInterface: TW_USERINTERFACE;

begin
  //If not opened simply set interal var to False
  if not(rOpened) then rEnabled:= False;

  if rEnabled then
  begin
    lRes:= DSM_Entry(@AppIdentity, nil, DG_CONTROL, DAT_USERINTERFACE, MSG_DISABLEDS, @twUserInterface);

    if (lRes = TWRC_SUCCESS) then
    begin
      //Increase the loaded sources count variable
      dec(TXICA_TwainManager(rOwner).rEnabledSources);
      rEnabled:= False;
    end;
  end;
end;

procedure TXICA_TwainDevice.TransferImages;
begin
  //TO-DO Copy from DelphiTwain
end;

constructor TXICA_TwainDevice.Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADeviceID: String);
begin
  inherited Create(AOwner, AIndex, ADeviceID);

  FillChar(rIdentity, sizeof(rIdentity), 0);
  rOpened:= False;
  rEnabled:= False;
end;

constructor TXICA_TwainDevice.Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADeviceIdentity: TW_IDENTITY);
begin
  inherited Create(AOwner, AIndex, MakeID(ADeviceIdentity));

  rIdentity:= ADeviceIdentity;
  rManufacturer:= rIdentity.Manufacturer;
  rName:= rIdentity.ProductName;
  rVersion:= rIdentity.Version.MajorNum;
  rVersionSub:= rIdentity.Version.MinorNum;
end;

destructor TXICA_TwainDevice.Destroy;
begin
  CloseDS;

  inherited Destroy;
end;

function TXICA_TwainDevice.DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
                                          APath, AFileName: String;
                                          out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer;
var
   dlgFlags: LONG;
   i: Integer;
   UserInterface: TW_USERINTERFACE;
   rDownloaded: Boolean;
   rDownload_Count: Integer;
   rDownload_Path,
   rDownload_Ext,
   rDownload_FileName: String;

begin
  Result:= 0;
  DownloadedFiles:= nil;

  if (TXICA_TwainManager(rOwner) = nil) then exit;

  try
     if (APath = '') or CharInSet(APath[Length(APath)], AllowDirectorySeparators)
     then rDownload_Path:= APath
     else rDownload_Path:= APath+DirectorySeparator;

     if not(ForceDirectories(rDownload_Path)) then exit;

     rDownload_FileName:= AFileName;
     rDownload_Ext:= '';
     rDownload_Count:= 0;
     rDownloaded:= False;

     //Download with UserInterface setted
     UserInterface.hParent:= hwndParent;
     UserInterface.ModalUI:= True;
     UserInterface.ShowUI:= True;

     //TO-DO: Search in Specs...
     //rDownload_Count:= Download(UserInterface, APath, 'twain_demo', '.bmp', tfBMP);

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


{ TXICA_TwainManager }

procedure TXICA_TwainManager.LoadDSMLibrary;
begin
  if (m_DSMState < 2) then
  try
     rLibHandle:= 0;
     DSM_Entry:= nil;

     //Searches for Twain directory
     TwainDirectory:= GetTwainDirectory;

     if (TwainDirectory <> '') then
     begin
       rLibHandle:= LoadLibrary(PChar(TwainDirectory + TWAINLIBRARY));
       if (rLibHandle <> 0) then
       begin
         //Obtains Twain proc function
         DSM_Entry:= GetProcAddress(rLibHandle, 'DSM_Entry');
         if Assigned(DSM_Entry)
         then m_DSMState:= 2
         else m_DSMState:= 1;

         //If the function was not obtained, also free the library
         if (m_DSMState < 2) then
         begin
           FreeLibrary(rLibHandle);
           rLibHandle:= 0;
         end;
       end;
     end;

  except
    rLibHandle:= 0;
    m_DSMState:= 1;
    DSM_Entry:= nil;
  end;
end;

procedure TXICA_TwainManager.UnloadDSMLibrary;
begin
  if (m_DSMState > 1) then
  try
     //Unloads the source manager}
     if (m_DSMState > 2) then disconnectDSM;

     if (rLibHandle <> 0) then FreeLibrary(rLibHandle);
     rLibHandle:= 0;
     m_DSMState:= 1;
     DSM_Entry:= nil;

  except

  end;
end;

procedure TXICA_TwainManager.connectDSM;
begin
  if (m_DSMState > 2) then exit;  //Already Opened
  if (m_DSMState < 2) then LoadDSMLibrary; //Load Library First
  if (m_DSMState > 1) then
  begin
    CreateVirtualWindow;

    if (DSM_Entry(@AppIdentity, nil, DG_CONTROL, DAT_PARENT, MSG_OPENDSM, @VirtualWindow) = TWRC_SUCCESS) then
    begin
      if not(((AppIdentity.SupportedGroups and DF_DSM2) = DF_DSM2) and
             (DSM_Entry(@AppIdentity, nil, DG_CONTROL, DAT_ENTRYPOINT, MSG_GET, @gDSM_Entry) = TWRC_SUCCESS))
      then FillChar(gDSM_Entry, SizeOf(gDSM_Entry), 0);

      m_DSMState:= 3;
    end;
  end;
end;

procedure TXICA_TwainManager.disconnectDSM;
begin
  if (m_DSMState < 3) then exit;  //Not Opened
  if (DSM_Entry(@AppIdentity, nil, DG_CONTROL, DAT_PARENT, MSG_CLOSEDSM, @VirtualWindow) = TWRC_SUCCESS) then
  begin
    DestroyVirtualWindow;

    m_DSMState:= 2;
  end;
end;

//Virtual window procedure handler - Forward messages to opened devices
function VirtualWinProc(Handle: THandle; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LResult; stdcall;

var
  i: Integer;
  Msg: TMsg;
  curDevice: TXICA_TwainDevice;

begin
  case uMsg of
    WM_CREATE: begin end;//Creation of the window
    else
    begin
      if (Twain_Manager <> nil) and (Twain_Manager.m_DSMState > 2) then
      begin
        //Convert parameters to a TMsg
        Msg := MakeMsg(Handle, uMsg, wParam, lParam);

        //Tell about this message
        if (Twain_Manager.OpenedSources > 0) then
        for i:=0 to Twain_Manager.Count-1 do
          if Twain_Manager.Get(i, TXICA_Device(curDevice)) then
          begin
            //Process this message only if Device is Opened
            if (curDevice.Opened) and (curDevice.ProcessMessage(Msg)) then
            begin
              //Case this was a message from the source, there is no need for the default procedure to process
              Result:= 0;
              Exit;
            end;
          end;
      end;
    end;
  end;

  Result:= DefWindowProc(Handle, uMsg, wParam, lParam);
end;

procedure TXICA_TwainManager.CreateVirtualWindow;
var
  WindowClassW: WndClassW;

begin
  if (Windows.GetClassInfoW(HInstance, @VirtualWinClassName, {$IFDEF FPC}@{$ENDIF}WindowClassW)=False) then
  begin
    with WindowClassW do
    begin
      Style :=0;
      LPFnWndProc := @VirtualWinProc;
      CbClsExtra := 0;
      CbWndExtra := 0;
      hIcon := 0;
      hCursor := 0;
      hbrBackground := 0;
      LPSzMenuName := nil;
      LPSzClassName := @VirtualWinClassName;
    end;
    WindowClassW.hInstance :=HInstance;
    Windows.RegisterClassW(WindowClassW);
  end;

  VirtualWindow :=CreateWindowExW(0, @VirtualWinClassName, @VirtualWinClassName,
                                  WS_POPUP, 0, 0, 0, 0, 0, 0, HInstance, Pointer(PtrUint(Self)));
end;

procedure TXICA_TwainManager.DestroyVirtualWindow;
begin
  DestroyWindow(VirtualWindow);
end;

function TXICA_TwainManager._EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean;
var
  i:integer;
  devCount: ULONG;
  curDevice: TXICA_TwainDevice;
  curIdentity: TW_IDENTITY;
  curName: String;

  procedure CreateDevice;
  var
     capSupport: TCapabilityOperations;

  begin
    if PreserveSelected and (ALastSelected <> nil) and (ALastSelected.ID = MakeID(curIdentity))
    then begin
           curDevice:= TXICA_TwainDevice(ALastSelected);
           Add(curDevice.ID, ALastSelected);
           SelectedIndex:= i;
           curDevice.rIndex:= i;  //Update Index because can be different (Actually not used)
         end
    else begin
           curDevice:= TXICA_TwainDevice.Create(Self, i, curIdentity);
           Add(curDevice.ID, curDevice);

           capSupport:= curDevice.GetCapabilitySupportedOp(ICAP_EXPOSURETIME); //CAP_CAMERAENABLED CAP_CAMERASIDE ?;
           if (capGet in capSupport)
           then curDevice.rType:= devTypeDigitalCamera
           else curDevice.rType:= devTypeScanner;
         end;
  end;

begin
  Result:= False;

(*  if (pDevMgr = nil) then pDevMgr:= WIA_LH.IWiaDevMgr2(CreateDevManager);
  if (pDevMgr <> nil) then
*)
  connectDSM;
  if (m_DSMState > 2) then
  begin
    i:= 0;
    FillChar(curIdentity, Sizeof(curIdentity), 0);
    lRes:= DSM_Entry(@AppIdentity, nil, DG_CONTROL, DAT_IDENTITY, MSG_GETFIRST, @curIdentity);
    while not(lRes = TWRC_ENDOFLIST) do
    begin
      Case lRes of
      TWRC_SUCCESS: begin
                      inc(i);
                      CreateDevice;
                    end;
      TWRC_FAILURE: begin
                    end;
      end;

      lRes:= DSM_Entry(@AppIdentity, nil, DG_CONTROL, DAT_IDENTITY, MSG_GETNEXT, @curIdentity);
    end;

    Result :=True;
  end;
end;

constructor TXICA_TwainManager.Create(const AEnumAll: Boolean = True);
begin
  inherited Create(AEnumAll);

  m_DSMState:= 1;
  FillChar(gDSM_Entry, SizeOf(gDSM_Entry), 0);
  VirtualWindow:= 0;
  rOpenedSources:= 0;
  rEnabledSources:= 0;

  LoadDSMLibrary;
end;

destructor TXICA_TwainManager.Destroy;
begin
  inherited Destroy;

  UnloadDSMLibrary;
end;

function TXICA_TwainManager.Enabled: Boolean;
begin
  Result:= (m_DSMState > 1);
end;

class function TXICA_TwainManager.Name: String;
begin
  Result:= 'Twain';
end;

initialization
  FillChar(AppIdentity, SizeOf(AppIdentity), 0);
  AppIdentity.Version.MajorNum:= 0;
  AppIdentity.Version.MinorNum:= 1;
  AppIdentity.Version.Language:= TW_UINT16(TWLG_USERLOCALE);
  AppIdentity.Version.Country:= TWCY_ITALY;
  AppIdentity.Version.Info:= '0.0.1';
  AppIdentity.ProtocolMajor:= TWON_PROTOCOLMAJOR;
  AppIdentity.ProtocolMinor:= TWON_PROTOCOLMINOR;
  AppIdentity.SupportedGroups:= DF_APP2 or DG_IMAGE or DG_CONTROL;
  AppIdentity.Manufacturer:= 'MaxM';
  AppIdentity.ProductFamily:= 'XICA';
  AppIdentity.ProductName:= 'XICA Twain';

  Twain_Manager:= TXICA_TwainManager.Create(XICA_EnumAllDevices);
  XICA_RegisterDeviceManager(TXICA_TwainManager.Name, Twain_Manager);

{$endif}
end.

