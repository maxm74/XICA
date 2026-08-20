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
    //Enumerate the avaliable items
    function _EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean; override;

    function GetType_Str: String; override;

  public
    constructor Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADeviceID: String); override;
    destructor Destroy; override;

    //Download using Native UI and return the number of files transfered in DownloadedFiles array.
    //  The system dialog works at Device level, so the selected item is ignored
    function DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
                              APath, AFileName: String;
                              out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer; override;

  end;

  { TXICA_TwainManager }

  TXICA_TwainManager = class(TXICA_DeviceManager)
  protected
    TwainDirectory: String;
    rLibrayLoaded: Boolean;
    rLibHandle: HInst;
    rTwainProc: TDSMEntryProc;
    lres: HResult;

    //Loads twain library and set rLibrayLoaded if it loaded sucessfully
    procedure LoadTwainLibrary; virtual;

    //Unloads twain library
    procedure UnloadTwainLibrary; virtual;

    //Enumerate the avaliable devices
    function _EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean; override;

  public
    constructor Create(const AEnumAll: Boolean = True); override;
    destructor Destroy; override;

    //Is the library loaded?
    function Enabled: Boolean; override;

    class function Name: String; override;
  end;


{$endif}

implementation

{$ifdef MSWINDOWS}

uses XICA;

const
  {Name of the Twain library for 32 bits enviroment}
  TWAINLIBRARY_64 = 'TWAINDSM.DLL';
  TWAINLIBRARY_32 = 'TWAIN_32.DLL';

  {$IFDEF WIN64}
  TWAINLIBRARY = TWAINLIBRARY_64;
  {$ELSE}
  TWAINLIBRARY = TWAINLIBRARY_32;
  {$ENDIF}

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
   iCount,
   i: Integer;
   curName: String;
   curItem: TXICA_TwainItem;

begin
  Result:= False;

(*  if (GetRootItemIntf = nil) then exit;

  lres:= pRootItem.EnumChildItems(nil, pIEnumItem);
  if (lres = S_OK) then
  begin
    lres:= pIEnumItem.GetCount(iCount);
    if (lres = S_OK) then
    begin
*)
      iCount:= 0;

      if not(PreserveSelected) or (ALastSelected = nil)
      then  //Select the First item by default
            if (rSelectedIndex < 0) or (rSelectedIndex > iCount-1)
            then rSelectedIndex:= 0;


      for i:=0 to iCount-1 do
      begin
//        lres:= pIEnumItem.Next(1, pItem, itemFetched);

        Result := (lres = S_OK);
        if Result then
        begin


            if PreserveSelected and (ALastSelected <> nil) and (ALastSelected.Name = curName)
            then begin
                   curItem:= TXICA_TwainItem(ALastSelected);
                   Add(curName, ALastSelected);
                   SelectedIndex:= i;
                 end
            else begin
                   curItem:= TXICA_TwainItem.Create(Self, i, curName);
                   Add(curName, curItem);
                 end;
        end
        else break;
      end;

//      Result :=True;
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

constructor TXICA_TwainDevice.Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADeviceID: String);
begin
  inherited Create(AOwner, AIndex, ADeviceID);
end;

destructor TXICA_TwainDevice.Destroy;
begin
  inherited Destroy;
end;

function TXICA_TwainDevice.DownloadNativeUI(hwndParent: THandle; useSystemUI: Boolean;
                                          APath, AFileName: String;
                                          out DownloadedFiles: TStringArray; UseRelativePath: Boolean=False): Integer;
var
   dlgFlags: LONG;
   i: Integer;
   rDownloaded: Boolean;
   rDownload_Count: Integer;
   rDownload_Path,
   rDownload_Ext,
   rDownload_FileName: String;

begin
  Result:= 0;
  DownloadedFiles:= nil;

  if (TXICA_TwainManager(rOwner) = nil) (*or (TXICA_TwainManager(rOwner).pDevMgr = nil)*) then exit;

  try
     if (APath = '') or CharInSet(APath[Length(APath)], AllowDirectorySeparators)
     then rDownload_Path:= APath
     else rDownload_Path:= APath+DirectorySeparator;

     if not(ForceDirectories(rDownload_Path)) then exit;

     rDownload_FileName:= AFileName;
     rDownload_Ext:= '';
     rDownload_Count:= 0;
     rDownloaded:= False;

(*     if useSystemUI
     then dlgFlags:= WIA_DEVICE_DIALOG_USE_COMMON_UI
     else dlgFlags:= 0;
*)
//     filePaths:= nil;
//     itemArray:= nil;

(*
     lres:= TXICA_TwainManager(rOwner).pDevMgr.GetImageDlg(dlgFlags, StringToOleStr(Self.ID), hwndParent,
                                                         StringToOleStr(rDownload_Path), StringToOleStr(rDownload_FileName),
                                                         rDownload_Count, filePaths, itemArray);
*)
     if (lres = S_OK) then
     begin
       //Copy filePaths to DownloadedFiles and Free elements
       SetLength(DownloadedFiles, rDownload_Count);
       for i:=0 to rDownload_Count-1 do
       begin
//         DownloadedFiles[i]:= filePaths^[i];  { #todo 2 -oMaxM : Test if OleStrToString is necessary }

         if UseRelativePath then FullPathToRelativePath(rDownload_Path, DownloadedFiles[i]);

//         SysFreeString(filePaths^[i]);
       end;

       Result:= rDownload_Count;
     end;
  finally
  end;
end;


{ TXICA_TwainManager }

procedure TXICA_TwainManager.LoadTwainLibrary;
begin
  if not(rLibrayLoaded) then
  try
     rLibHandle:= 0;
     rTwainProc:= nil;

     //Searches for Twain directory
     TwainDirectory:= GetTwainDirectory;

     if (TwainDirectory <> '') then
     begin
       rLibHandle:= LoadLibrary(PChar(TwainDirectory + TWAINLIBRARY));
       if (rLibHandle <> 0) then
       begin
         //Obtains Twain proc function
         rTwainProc:= GetProcAddress(rLibHandle, MAKEINTRESOURCE(1));
         rLibrayLoaded:= Assigned(rTwainProc);

         //If the function was not obtained, also free the library
         if not(rLibrayLoaded) then
         begin
           FreeLibrary(rLibHandle);
           rLibHandle:= 0;
         end;
       end;
     end;

  except
    rLibHandle:= 0;
    rLibrayLoaded:= False;
    rTwainProc:= nil;
  end;
end;

procedure TXICA_TwainManager.UnloadTwainLibrary;
begin
  if rLibrayLoaded then
  try
     //Unloads the source manager}
     //SourceManagerLoaded := FALSE;

     if (rLibHandle <> 0) then FreeLibrary(rLibHandle);
     rLibHandle:= 0;
     rLibrayLoaded:= False;
     rTwainProc:= nil;

  except

  end;
end;

function TXICA_TwainManager._EnumerateDevices(PreserveSelected: Boolean; ALastSelected: TXICA_Device): Boolean;
var
  i:integer;
  devCount: ULONG;
  curDevice: TXICA_TwainDevice;
  curName: String;

begin
  Result:= False;

(*  if (pDevMgr = nil) then pDevMgr:= WIA_LH.IWiaDevMgr2(CreateDevManager);
  if (pDevMgr <> nil) then
*)
  begin
    (*
    if EnumAll
    then lres :=pDevMgr.EnumDeviceInfo(WIA_DEVINFO_ENUM_ALL, ppIEnum)
    else lres :=pDevMgr.EnumDeviceInfo(WIA_DEVINFO_ENUM_LOCAL, ppIEnum);
    *)

    if (lres=S_OK) then
    begin
      //lres :=ppIEnum.GetCount(devCount);

      devCount:= 0;

      if (lres<>S_OK) then Exception.Create('Number of Twain Devices not available');

      if (devCount > 0) then
      begin
        for i:=0 to devCount-1 do
        begin
                 if PreserveSelected and (ALastSelected <> nil) and (ALastSelected.ID = curName)
                 then begin
                        curDevice:= TXICA_TwainDevice(ALastSelected);
                        Add(curName, ALastSelected);
                        SelectedIndex:= i;
                        //curDevice.rIndex:= i;  //Update Index because can be different (Actually not used)
                      end
                 else begin
                        curDevice:= TXICA_TwainDevice.Create(Self, i, curName);
                        Add(curName, curDevice);
                      end;

          (*
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

          *)
        end;


        Result :=True;

      end;
    end;
  end;
end;

constructor TXICA_TwainManager.Create(const AEnumAll: Boolean = True);
begin
  inherited Create(AEnumAll);

  LoadTwainLibrary;
end;

destructor TXICA_TwainManager.Destroy;
begin
  UnloadTwainLibrary;

  inherited Destroy;
end;

function TXICA_TwainManager.Enabled: Boolean;
begin
  Result:= rLibrayLoaded;
end;

class function TXICA_TwainManager.Name: String;
begin
  Result:= 'Twain';
end;

initialization
  Twain_Manager:= TXICA_TwainManager.Create(XICA_EnumAllDevices);
  XICA_RegisterDeviceManager(TXICA_TwainManager.Name, Twain_Manager);

{$endif}
end.

