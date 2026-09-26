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

{$ifdef UNIX}

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
    rDevice: SANE_Device;
    devHandle: SANE_Handle;
    lres: SANE_Status;

    rOpened,
    rEnabled: Boolean;
    rDownloadItem: TXICA_SaneItem;

    //Enumerate the avaliable items
    function _EnumerateItems(PreserveSelected: Boolean; ALastSelected: TXICA_Item): Boolean; override;

    //Get Index of a Capability Name, SANE don't have an api to get/set Value given it's name (?)
    function GetCapabilityIndex(const CapabilityName: String): SANE_Int;

    //Get Current Capability Value and it's type given the ID
    //function GetCapability(const ACapabilityId: String; out CapabilityType: SANE_Value_Type; out ACapabilityValue): Boolean; overload;

    //Get Current and Default Values of a Capability given the ID,
    function GetCapability(const ACapabilityId: String; out CapabilityType: SANE_Value_Type;
                           out ACapabilityValue(*, ACapabilityDefaultValue ? in SANE ?*)): TXICA_PropertyFlags; overload;

    //Get Current, Default and Possible Values of a Capability given the ID,
    //  Depending on the type returned in CapabilityType
    //  ACapabilityListValues can be a Dynamic Array of Integers, Real, etc... user must free it
    //  if Result contain the Flag prop_RANGE then use XICA_RANGE_XXX Indexes to get MIN/MAX/STEP Values
    function GetCapability(const ACapabilityId: String; out CapabilityType: SANE_Value_Type;
                           out ACapabilityValue(*, ACapabilityDefaultValue ? in SANE ?*);
                           out ACapabilityListValues): TXICA_PropertyFlags; overload;

    //Set the Capability Value given the ID, the user must know the correct type to use
    function SetCapability(const ACapabilityId: String; const CapabilityType: SANE_Value_Type; const ACapabilityValue): Boolean;

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

    property Opened: Boolean read rOpened;
  end;

  { TXICA_SaneManager }

  TXICA_SaneManager = class(TXICA_DeviceManager)
  protected
    rEnabled: Boolean;
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

{$ifdef UNIX}

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

procedure SANEPropertyFlags(const pFlags: SANE_Int; var AFlags: TXICA_PropertyFlags); overload;
begin
  if (pFlags and SANE_CAP_INACTIVE <> 0)
  then begin
         //If is Inactive then the Option is not Readable/Writable, delete the flags
         AFlags:= AFlags-[prop_READ];
         AFlags:= AFlags-[prop_WRITE];
       end
  else begin
         if (pFlags and SANE_CAP_SOFT_SELECT <> 0) then AFlags:= AFlags+[prop_READ];
         if (pFlags and SANE_CAP_SOFT_DETECT <> 0) then AFlags:= AFlags+[prop_WRITE];
       end;
end;

procedure SANEPropertyFlags(const pConstr: SANE_Constraint_Type; var AFlags: TXICA_PropertyFlags); overload;
begin
  if (pConstr = SANE_CONSTRAINT_RANGE)
  then AFlags:= AFlags+[prop_RANGE]
  else if (pConstr in [SANE_CONSTRAINT_WORD_LIST, SANE_CONSTRAINT_STRING_LIST]) then AFlags:= AFlags+[prop_LIST];
end;

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
   iItem,
   numItems: Integer;
   prevState: Boolean;
   curName: String;
   curItem: TXICA_SaneItem;
   capType: SANE_Value_Type;
   curSource: String;
   listSources: TStringArray;

   curFlags: TXICA_PropertyFlags;

   (*
   curDouble: Double;
   curInt: Integer;
   curBool: Boolean;
   curSingle: Single;
   listInt: TArrayInteger;
   listDouble: TArrayDouble;
   *)

begin
  Result:= False;

  try
     (*if (Type_ = devTypeDigitalCamera)
     then begin
          end
     else begin
          end;*)

      prevState:= Opened;

      //Source must be loaded
      OpenDS;

      if Opened then
      begin
        curFlags:= GetCapability(SANE_NAME_SCAN_SOURCE, capType, curSource, listSources);  //2 Items in Test Scanner
        numItems:= Length(listSources);
        if (numItems = 0)
        then begin
               //Add only Flatbed
             end
        else
        for iItem:=0 to numItems-1 do
        begin
          curName:= listSources[iItem];

          // Check if has Flatbed
          if UpperCase(curName).Contains('FLATBED') then
          begin
          end;

          // Check if has Feeder (ADF)
          if UpperCase(curName).Contains('ADF') or UpperCase(curName).Contains('FEEDER') then
          begin

          end;
        end;

        (*
        //TESTS
        curFlags:= GetCapability('hand-scanner', capType, curBool);  //Val =
        curFlags:= GetCapability('three-pass', capType, curBool);  //Not Set
        curFlags:= GetCapability(SANE_NAME_BIT_DEPTH, capType, curInt, listInt);
        curFlags:= GetCapability('fixed-constraint-word-list', capType, curDouble, listDouble);
        curFlags:= GetCapability(SANE_NAME_SCAN_RESOLUTION, capType, curDouble, listDouble);
        *)
      end;

      Result:= True;

  finally
    if not(prevState) then CloseDS;
    listSources:= nil;
    (*listInt:= nil;
    listDouble:= nil;*)
  end;
end;

function TXICA_SaneDevice.GetCapabilityIndex(const CapabilityName: String): SANE_Int;
var
  i: SANE_Int;
  saneOption: PSANE_Option_Descriptor;

begin
  Result:= -1;
  i:= 0;
  saneOption:= sane_get_option_descriptor(devHandle, i);
  While (Result < 0) and (saneOption <> nil)  do
  begin
    if (saneOption^.name = CapabilityName)
    then Result:= i
    else begin
          inc(i);
          saneOption:= sane_get_option_descriptor(devHandle, i);
        end;
  end;
end;

(*
function TXICA_SaneDevice.GetCapability(const ACapabilityId: String; out CapabilityType: SANE_Value_Type;
                                        out ACapabilityValue): Boolean;
begin
  Result:= (prop_READ in GetCapability(ACapabilityId, CapabilityType, ACapabilityValue);
end;
*)

function TXICA_SaneDevice.GetCapability(const ACapabilityId: String; out CapabilityType: SANE_Value_Type;
                                        out ACapabilityValue (*, ACapabilityDefaultValue*)): TXICA_PropertyFlags;
var
   CapabilityIndex, info: SANE_Int;
   saneOption: PSANE_Option_Descriptor;
   pData: Pointer = nil;

begin
  Result:= [];

  try
     CapabilityIndex:= GetCapabilityIndex(ACapabilityId);
     if (CapabilityIndex >= 0) then
     begin
       saneOption:= sane_get_option_descriptor(devHandle, CapabilityIndex);
       if (saneOption <> nil) then
       begin
         //Set PropertyFlags
         SANEPropertyFlags(saneOption^.cap, Result);
         SANEPropertyFlags(saneOption^.constraint_type, Result);

         CapabilityType:= saneOption^._type;

         //Allocate Memory and fill with 0
         GetMem(pData, saneOption^.size);
         FillChar(pData^, saneOption^.size, 0);

         if sane_control_option(devHandle, CapabilityIndex, SANE_ACTION_GET_VALUE, pData, CapabilityIndex) = SANE_STATUS_GOOD then
         Case CapabilityType of
           SANE_TYPE_BOOL: Boolean(ACapabilityValue):= Boolean(PSANE_Bool(pData)^);
           SANE_TYPE_INT:  Integer(ACapabilityValue):= PSANE_Int(pData)^;
           SANE_TYPE_FIXED: Double(ACapabilityValue):= SANE_UNFIX(PSANE_Word(pData)^);
           SANE_TYPE_STRING: String(ACapabilityValue):= PChar(pData);
           //SANE_TYPE_BUTTON:  Non Sense, return always nil
           SANE_TYPE_GROUP: String(ACapabilityValue):= saneOption^.title;
         end;
       end;
     end;

  finally
    if (pData <> nil) then FreeMem(pData);
  end;
end;

function TXICA_SaneDevice.GetCapability(const ACapabilityId: String; out CapabilityType: SANE_Value_Type;
                                        out ACapabilityValue (*, ACapabilityDefaultValue*); out ACapabilityListValues): TXICA_PropertyFlags;
var
   i, count: Integer;
   CapabilityIndex: SANE_Int;
   saneOption: PSANE_Option_Descriptor;
   pData: Pointer = nil;

begin
  Result:= [];

  try
     CapabilityIndex:= GetCapabilityIndex(ACapabilityId);
     if (CapabilityIndex >= 0) then
     begin
       saneOption:= sane_get_option_descriptor(devHandle, CapabilityIndex);
       if (saneOption <> nil) then
       begin
         //Set PropertyFlags
         SANEPropertyFlags(saneOption^.cap, Result);
         SANEPropertyFlags(saneOption^.constraint_type, Result);

         CapabilityType:= saneOption^._type;

         //Allocate Memory and fill with 0
         GetMem(pData, saneOption^.size);
         FillChar(pData^, saneOption^.size, 0);

         if sane_control_option(devHandle, CapabilityIndex, SANE_ACTION_GET_VALUE, pData, CapabilityIndex) = SANE_STATUS_GOOD then
         begin
           //Set the Value based on the data type, there is no Default Value in SANE(?)
           Case CapabilityType of
             SANE_TYPE_BOOL: Boolean(ACapabilityValue):= Boolean(PSANE_Bool(pData)^);
             SANE_TYPE_INT:  Integer(ACapabilityValue):= PSANE_Int(pData)^;
             SANE_TYPE_FIXED: Double(ACapabilityValue):= SANE_UNFIX(PSANE_Word(pData)^);
             SANE_TYPE_STRING: String(ACapabilityValue):= PChar(pData);
             //SANE_TYPE_BUTTON:  Non Sense, return always nil
             SANE_TYPE_GROUP: String(ACapabilityValue):= saneOption^.title;
           end;
         end;

         //Regardless of whether SANE_ACTION_GET_VALUE fails or not, there might be an array or a range — retrieve the value anyway
         if (saneOption^.constraint_type <> SANE_CONSTRAINT_NONE) then
         begin
           //Copy the items into the array, if present. I only take the constraint_type into account because
           //maybe a data type inconsistency —f or example, SANE_TYPE_INT versus SANE_CONSTRAINT_STRING_LIST
           Case saneOption^.constraint_type of
             SANE_CONSTRAINT_RANGE: begin
               //only SANE_TYPE_INT and SANE_TYPE_FIXED makes sense
                if (CapabilityType = SANE_TYPE_FIXED)
                then begin
                       SetLength(TArrayDouble(ACapabilityListValues), prop_RANGE_NUM_ELEMS);
                       Double(TArrayDouble(ACapabilityListValues)[prop_RANGE_MIN]):= SANE_UNFIX(saneOption^.range^.min);
                       Double(TArrayDouble(ACapabilityListValues)[prop_RANGE_MAX]):= SANE_UNFIX(saneOption^.range^.max);
                       Double(TArrayDouble(ACapabilityListValues)[prop_RANGE_STEP]):= SANE_UNFIX(saneOption^.range^.quant);
                       //Double(TArrayDouble(ACapabilityListValues)[prop_RANGE_DEFAULT]):= ACapabilityDefaultValue;
                     end
                else begin
                       SetLength(TArrayInteger(ACapabilityListValues), prop_RANGE_NUM_ELEMS);
                       Integer(TArrayInteger(ACapabilityListValues)[prop_RANGE_MIN]):= saneOption^.range^.min;
                       Integer(TArrayInteger(ACapabilityListValues)[prop_RANGE_MAX]):= saneOption^.range^.max;
                       Integer(TArrayInteger(ACapabilityListValues)[prop_RANGE_STEP]):= saneOption^.range^.quant;
                       //Double(TArrayInteger(ACapabilityListValues)[prop_RANGE_DEFAULT]):= ACapabilityDefaultValue;
                     end;
             end;
             SANE_CONSTRAINT_STRING_LIST: begin
               //Iterate through the array until you find nil
               i:= 0;
               while (saneOption^.stringlist^[i] <> nil) do
               begin
                 //Add an Item
                 SetLength(TStringArray(ACapabilityListValues), i+1);
                 TStringArray(ACapabilityListValues)[i]:= String(saneOption^.stringlist^[i]);
                 Inc(i);
               end;
             end;
             SANE_CONSTRAINT_WORD_LIST: begin
               //Get array count
               count:= saneoption^.wordlist^[0];

               //Add Items to Array
               if (CapabilityType = SANE_TYPE_FIXED)
               then begin
                      SetLength(TArrayDouble(ACapabilityListValues), count);
                      for i:=0 to count-1 do Double(TArrayDouble(ACapabilityListValues)[i]):= SANE_UNFIX(saneoption^.wordlist^[i+1]);
                    end
               else begin
                      SetLength(TArrayInteger(ACapabilityListValues), count);
                      for i:=0 to count-1 do Integer(TArrayInteger(ACapabilityListValues)[i]):= saneoption^.wordlist^[i+1];
                    end;
             end;
            end;

         end;
       end;
     end;

  finally
    if (pData <> nil) then FreeMem(pData);
  end;
end;

function TXICA_SaneDevice.SetCapability(const ACapabilityId: String; const CapabilityType: SANE_Value_Type;
                                        const ACapabilityValue): Boolean;
var
   CapabilityIndex: SANE_Int;

begin
  Result:= False;

  try
     CapabilityIndex:= GetCapabilityIndex(ACapabilityId);
     if (CapabilityIndex >= 0) then
     begin

       Result:= True;
     end;

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

  FillChar(rDevice, Sizeof(rDevice), 0);
  rEnabled:= False;
  rDownloadItem:= nil;
  rVersion:= rOwner.Version;
  rVersionSub:= rOwner.VersionSub;
end;

constructor TXICA_SaneDevice.Create(const AOwner: TXICA_DeviceManager; const AIndex: Integer; const ADevice: SANE_Device);
begin
  inherited Create(AOwner, AIndex, ADevice.name);

  rDevice:= ADevice;
  rManufacturer:= rDevice.vendor;
  rName:= rDevice.model;
//  rVersion:= rDevice.Version;
//  rVersionSub:= rDevice.VersionSub;
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
var
   ver: SANE_INT;

begin
  if not(rEnabled) then
  try
     if sane.Load then
     begin
       lRes:= sane_init(@ver, nil);
       if (lRes = SANE_STATUS_GOOD) then
       begin
         rEnabled:= True;
         rVersion:= SANE_VERSION_MAJOR(ver);
         rVersionSub:= SANE_VERSION_MINOR(ver);
       end;
      end;

  except
    rEnabled:= False;
  end;
end;

procedure TXICA_SaneManager.UnloadSaneLibrary;
begin
  try
     if rEnabled then sane_exit;
     sane.Unload;
     rEnabled:= False;

  except
    rEnabled:= False;
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

           curDevice.rType:= devTypeScanner;
         end;
  end;

begin
  Result:= False;

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
  end;

  Result :=True;
end;

constructor TXICA_SaneManager.Create(const AEnumAll: Boolean = True);
begin
  inherited Create(AEnumAll);

  rEnabled:= False;
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
  Result:= rEnabled;
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

