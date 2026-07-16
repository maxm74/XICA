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

  TXICA_DeviceType = (
    devTypeUnknown, devTypeScanner, devTypeDigitalCamera
  );

  TXICA_PropertyFlag = (
    prop_READ,  propWRITE, prop_REQUIRED, prop_RANGE, prop_LIST
  );
  TXICA_PropertyFlags = set of TXICA_PropertyFlag;

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
    //xdtRAW_RGB,
    //xdtRAW_BGR,
    //xdtRAW_YUV,
    //xdtRAW_YUVK,
    //xdtRAW_CMY,
    //xdtRAW_CMYK,
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

  TXICA_Params = packed record
    NativeUI: Boolean;
    PaperType: TXICA_PaperType;

    //Used only if PaperType=ptCUSTOM
    PaperW,
    PaperH: Integer;

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
    PaperSizeMaxHeight: Integer;
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

implementation

end.

