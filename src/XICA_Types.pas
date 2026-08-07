(****************************************************************************
*                XICA (Cross-platform Image Capture Architecture)
*
*  FILE: XICA_Types.pas
*
*  VERSION:     0.0.1
*
*  DESCRIPTION:
*    Common Types and Consts
*
*****************************************************************************
*
*  (c) 2026 Massimo Magnano
*
*  See changelog.txt for Change Log
*
*****************************************************************************)
unit XICA_Types;

{$ifdef fpc}
  {$mode delphi}
{$endif}
{$H+}

interface

type
  //Dinamic Array types
  TArraySingle = array of Single;
  TArrayDouble = array of Double;
  TArrayInteger = array of Integer;
  TArraySmallint = array of Smallint;
  TArrayByte = array of Byte;
  TArrayWord = array of Word;
  TArrayLongWord = array of LongWord;
  TStringArray = array of String;
  TArrayGUID = array of TGUID;

  TXICA_ItemType = (
    xitFree,
    xitImage,
    xitFile,
    xitFolder,
    xitRoot,
    xitAnalyze,
    xitAudio,
    xitDevice,
    xitDeleted,
    xitDisconnected,
    xitHPanorama,
    xitVPanorama,
    xitBurst,
    xitStorage,
    xitTransfer,
    xitGenerated,
    xitHasAttachments,
    xitVideo,
    xitTwainCompatibility,
    xitRemoved,
    xitDocument,
    xitProgrammableDataSource
  );
  TXICA_ItemTypes = set of TXICA_ItemType;

  TXICA_ItemCategory = (
    xicNULL,
    xicFINISHED_FILE,
    xicFLATBED,
    xicFEEDER,
    xicFILM,
    xicROOT,
    xicFOLDER,
    xicFEEDER_FRONT,
    xicFEEDER_BACK,
    xicAUTO,
    xicIMPRINTER,
    xicENDORSER,
    xicBARCODE_READER,
    xicPATCH_CODE_READER,
    xicMICR_READER
  );

  TXICA_DeviceType = (
    devTypeUnknown = 0,
    devTypeScanner,
    devTypeDigitalCamera
  );

const
  XICA_DeviceTypeDescr : array [TXICA_DeviceType] of String = (
    'Unknown', 'Scanner', 'Digital Camera'
  );

type
  TXICA_PropertyFlag = (
    prop_READ,  prop_WRITE, prop_REQUIRED, prop_RANGE, prop_LIST
  );
  TXICA_PropertyFlags = set of TXICA_PropertyFlag;

const
  //if Property contain the Flag prop_RANGE then use propRANGE_XXX Indexes to get MIN/MAX/STEP Values
  prop_RANGE_MIN     = 0;
  prop_RANGE_DEFAULT = 1;
  prop_RANGE_MAX     = 2;
  prop_RANGE_STEP    = 3;

type
  TXICA_Rotation = (
    xrPortrait, xrLandscape,
    xrRot180, xrRot270
  );
  TXICA_Rotations = set of TXICA_Rotation;

  TXICA_DocumentHandling = (
    xdhFeeder,
    xdhFlatbed,
    xdhDuplex,
    xdhFront_First,
    xdhBack_First,
    xdhFront_Only,
    xdhBack_Only
  );
  TXICA_DocumentHandlings = set of TXICA_DocumentHandling;

  TXICA_AlignVertical = (xaVTop, xaVCenter, xaVBottom);
  TXICA_AlignHorizontal = (xaHLeft, xaHCenter, xaHRight);

  TXICA_ImageFormat = (
    xifUNDEFINED,
    xifRAWRGB,
    xifMEMORYBMP,
    xifBMP,
    xifEMF,
    xifWMF,
    xifJPEG,
    xifPNG,
    xifGIF,
    xifTIFF,
    xifEXIF,
    xifPHOTOCD,
    xifFLASHPIX,
    xifICO,
    xifCIFF,
    xifPICT,
    xifJPEG2K,
    xifJPEG2KX,
    xifRAW,
    xifJBIG,
    xifJBIG2
  );
  TXICA_ImageFormats = set of TXICA_ImageFormat;

  TXICA_DataType = (
    xdtBN,
    xdtGRAYSCALE,
    xdtCOLOR,
    xdtRAW_RGB,
    xdtRAW_BGR,
    xdtRAW_YUV,
    xdtRAW_YUVK,
    xdtRAW_CMY,
    xdtRAW_CMYK,
    xdtAUTO
  );
  TXICA_DataTypes = set of TXICA_DataType;

  TXICA_PaperType = (
   ptA4,
   ptLETTER,
   ptUSLEGAL,
   ptUSLEDGER,
   ptUSSTATEMENT,
   ptBUSINESSCARD,
   ptISO_A0,
   ptISO_A1,
   ptISO_A2,
   ptISO_A3,
   ptISO_A5,
   ptISO_A6,
   ptISO_A7,
   ptISO_A8,
   ptISO_A9,
   ptISO_A10,
   ptISO_B0,
   ptISO_B1,
   ptISO_B2,
   ptISO_B3,
   ptISO_B4,
   ptISO_B5,
   ptISO_B6,
   ptISO_B7,
   ptISO_B8,
   ptISO_B9,
   ptISO_B10,
   ptISO_C0,
   ptISO_C1,
   ptISO_C2,
   ptISO_C3,
   ptISO_C4,
   ptISO_C5,
   ptISO_C6,
   ptISO_C7,
   ptISO_C8,
   ptISO_C9,
   ptISO_C10,
   ptJIS_B0,
   ptJIS_B1,
   ptJIS_B2,
   ptJIS_B3,
   ptJIS_B4,
   ptJIS_B5,
   ptJIS_B6,
   ptJIS_B7,
   ptJIS_B8,
   ptJIS_B9,
   ptJIS_B10,
   ptJIS_B11,
   ptJIS_B12,
   ptJIS_2A,
   ptJIS_4A,
   ptDIN_2B,
   ptDIN_4B,
   ptAUTO,
   ptCUSTOM, // Use a Range from MIN_SIZE to MAX_SIZE
   ptMAX     // Use MAX_HORIZONTAL/VERTICAL_SIZE
  );
  TXICA_PaperTypes = set of TXICA_PaperType;

  // to-do : CONVERT TO OBJECTS for Examples Cameras have addition Params like Shutter Time\Aperture
  TXICA_Params = packed record
    NativeUI: Boolean;
    PaperType: TXICA_PaperType;

    //Used only if PaperType=ptCUSTOM
    PaperW,
    PaperH: Single;

    Rotation: TXICA_Rotation;
    HAlign: TXICA_AlignHorizontal;
    VAlign: TXICA_AlignVertical;
    Resolution,
    Contrast,
    //BitDepth,
    Brightness: Integer;
    DataType: TXICA_DataType;
    DocHandling: TXICA_DocumentHandlings;
  end;
  TArrayXICA_Params = array of TXICA_Params;

  TXICA_ParamsCapabilities = packed record
    PaperSizeMaxWidth,
    PaperSizeMaxHeight: Single;
    PaperTypeSet: TXICA_PaperTypes;
    PaperTypeCurrent,
    PaperTypeDefault: TXICA_PaperType;
    RotationCurrent,
    RotationDefault: TXICA_Rotation;
    RotationSet: TXICA_Rotations;
    ResolutionArray: TArrayInteger;
    ResolutionRange: Boolean;
    ResolutionCurrent,
    ResolutionDefault,
    BrightnessCurrent,
    BrightnessDefault,
    BrightnessMin,
    BrightnessMax,
    BrightnessStep,
    ContrastCurrent,
    ContrastDefault,
    ContrastMin,
    ContrastMax,
    ContrastStep (*,
    BitDepthCurrent,
    BitDepthDefault*): Integer;
    //BitDepthArray: TArrayInteger;
    DataTypeCurrent,
    DataTypeDefault: TXICA_DataType;
    DataTypeSet: TXICA_DataTypes;
    DocHandlingCurrent,
    DocHandlingDefault,
    DocHandlingSet: TXICA_DocumentHandlings; { #todo 5 -oMaxM : Must be tested in a Duplex Scanner }
  end;
  TArrayXICA_ParamsCapabilities = array of TXICA_ParamsCapabilities;

var
  XICA_Settings_Unit_cm: Boolean = True; //False to show then measurement in fucking inches


function XICA_DeviceType(const ADeviceType: TXICA_DeviceType): String;

function XICA_CopyCurrentValues(const Cap: TXICA_ParamsCapabilities;
                                const aHAlign: TXICA_AlignHorizontal=xaHLeft;
                                const aVAlign: TXICA_AlignVertical=xaVTop): TXICA_Params;
function XICA_CopyDefaultValues(const Cap: TXICA_ParamsCapabilities;
                                const aHAlign: TXICA_AlignHorizontal=xaHLeft;
                                const aVAlign: TXICA_AlignVertical=xaVTop): TXICA_Params;

procedure VersionStrToInt(const s: String; out Ver, VerSub: Integer); overload;

function FullPathToRelativePath(const ABasePath: String; out APath: String): Boolean;

implementation

uses SysUtils;

function XICA_DeviceType(const ADeviceType: TXICA_DeviceType): String;
begin
  if (ADeviceType in [Low(TXICA_DeviceType)..High(TXICA_DeviceType)])
  then Result:= XICA_DeviceTypeDescr[ADeviceType]
  else Result:= 'Undefined ('+IntToStr(Integer(ADeviceType))+')';
end;

function XICA_CopyCurrentValues(const Cap: TXICA_ParamsCapabilities;
                                const aHAlign: TXICA_AlignHorizontal=xaHLeft;
                                const aVAlign: TXICA_AlignVertical=xaVTop): TXICA_Params;
begin
  FillChar(Result, Sizeof(Result), 0);
  with Result do
  begin
    PaperType:= Cap.PaperTypeCurrent;
    Resolution:= Cap.ResolutionCurrent;
    Contrast:= Cap.ContrastCurrent;
    Brightness:= Cap.BrightnessCurrent;
    DocHandling:= Cap.DocHandlingCurrent;
    //BitDepth:= Cap.BitDepthCurrent;
    DataType:= Cap.DataTypeCurrent;
    HAlign:= aHAlign;
    VAlign:= aVAlign;
  end;
end;

function XICA_CopyDefaultValues(const Cap: TXICA_ParamsCapabilities;
                                const aHAlign: TXICA_AlignHorizontal=xaHLeft;
                                const aVAlign: TXICA_AlignVertical=xaVTop): TXICA_Params;
begin
  FillChar(Result, Sizeof(Result), 0);
  with Result do
  begin
    PaperType:= Cap.PaperTypeDefault;
    Resolution:= Cap.ResolutionDefault;
    Contrast:= Cap.ContrastDefault;
    Brightness:= Cap.BrightnessDefault;
    DocHandling:= Cap.DocHandlingDefault;
    //BitDepth:= Cap.BitDepthDefault;
    DataType:= Cap.DataTypeDefault;
    HAlign:= aHAlign;
    VAlign:= aVAlign;
  end;
end;

procedure VersionStrToInt(const s: String; out Ver, VerSub: Integer); overload;
var
   pPos, ppPos: Integer;

begin
  Ver:= 0;
  VerSub:= 0;

  try
     pPos:= Pos('.', s);
     if (pPos > 0) then
     begin
       Ver:= StrToInt(Copy(s, 0, pPos-1));
       ppPos:= Pos('.', s, pPos+1);
       if (ppPos > 0)
       then VerSub:= StrToInt(Copy(s, pPos+1, ppPos-1))
       else VerSub:= StrToInt(Copy(s, pPos+1, 255));
     end;
  except

  end;
end;

function FullPathToRelativePath(const ABasePath: String; out APath: String): Boolean;
begin
  Result:= (Pos(ABasePath, APath) = 1);
  if Result
  then APath:= '.'+DirectorySeparator+Copy(APath, Length(ABasePath)+1, MaxInt);
end;



end.

