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
  { TXICA_TwainItem }

  TXICA_TwainItem = class(TXICA_Item)
  protected
    //Get Max Paper Width, Height form the Device (in Inches)
    function _GetPaperSizeMax(out AMaxWidth, AMaxHeight: Single): Boolean; override;

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
    gDSM_Entry: TW_ENTRYPOINT;
    lRes: HResult;
    VirtualWindow: THandle;

    //Enumerate the avaliable devices
    function _EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean; override;

    //Loads twain library and set rLibrayLoaded if it loaded sucessfully
    procedure LoadDSMLibrary; virtual;

    //Unloads twain library
    procedure UnloadDSMLibrary; virtual;

    function DSM_Alloc(_size: TW_UINT32): TW_HANDLE;
    procedure DSM_Free(_hMemory: TW_HANDLE);
    function DSM_LockMemory(_hMemory: TW_HANDLE): TW_MEMREF;
    procedure DSM_UnlockMemory(_hMemory: TW_HANDLE);

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
   prevState: Boolean;

begin
  Result:= False;

  //We have ONLY One Item, Select it by default
  rSelectedIndex:= 0;

  if PreserveSelected and (ALastSelected <> nil)
  then begin
         curItem:= TXICA_TwainItem(ALastSelected);
         Add(ALastSelected.Name, ALastSelected);
         Result:= True;
       end
  else try
          prevState:= Opened;
          OpenDS;

          curItem:= TXICA_TwainItem.Create(Self, 0, curName);

          //CAP_CAMERASIDE  Se OK                  Type Camera
          //  else
          //Type Scanner
          //
          //  CAP_FEEDERENABLED
          //     errore (es. TWRC_FAILURE / TWCC_CAPUNSUPPORTED) Category Flatbed
          //     Se la risposta è TRUE o FALSE                   Category Feeder

          Add(curName, curItem);

          Result:= True;

        finally
          if not(prevState) then CloseDS;
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

function TXICA_TwainManager.DSM_Alloc(_size: TW_UINT32): TW_HANDLE;
begin
  if Assigned(gDSM_Entry.DSM_MemAllocate)
  then Result:= gDSM_Entry.DSM_MemAllocate(_size)
  else Result:= GlobalAlloc(GPTR, _size);
end;

procedure TXICA_TwainManager.DSM_Free(_hMemory: TW_HANDLE);
begin
  if Assigned(gDSM_Entry.DSM_MemFree)
  then gDSM_Entry.DSM_MemFree(_hMemory)
  else GlobalFree(_hMemory);
end;

function TXICA_TwainManager.DSM_LockMemory(_hMemory: TW_HANDLE): TW_MEMREF;
begin
  if Assigned(gDSM_Entry.DSM_MemLock)
  then Result:= gDSM_Entry.DSM_MemLock(_hMemory)
  else Result:= GlobalLock(_hMemory);
end;

procedure TXICA_TwainManager.DSM_UnlockMemory(_hMemory: TW_HANDLE);
begin
  if Assigned(gDSM_Entry.DSM_MemUnlock)
  then gDSM_Entry.DSM_MemUnlock(_hMemory)
  else GlobalUnlock(_hMemory);
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
           curDevice.rType:= devTypeScanner;                  //to-do Verify other types?
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

