(*******************************************************************************
*                XICA (Cross-platform Image Capture Architecture)              *
*                                                                              *
*  FILE: XICA_Types.pas                                                        *
*                                                                              *
*  VERSION:     0.0.1                                                          *
*                                                                              *
*  DESCRIPTION:                                                                *
*    Common Types and Consts                                                   *
*                                                                              *
********************************************************************************
*                                                                              *
*  (c) 2026 Massimo Magnano                                                    *
*                                                                              *
*  See changelog.txt for Change Log                                            *
*                                                                              *
*******************************************************************************)
unit XICA_Types;

{$ifdef fpc}
  {$mode delphi}
{$endif}
{$H+}

interface

uses Classes,
     {$ifdef fpc}Laz2_XMLCfg{$else}DelphiCompatibility, DelphiXMLConfig{$endif};

type
  //Dinamic Array types
  TArraySingle = array of Single;
  TArrayDouble = array of Double;
  TArrayInteger = array of Integer;
  TArraySmallint = array of Smallint;
  TArrayShortint = array of Shortint;
  TArrayByte = array of Byte;
  TArrayWord = array of Word;
  TArrayLongWord = array of LongWord;
  TArrayBoolean = array of Boolean;
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
  prop_RANGE_NUM_ELEMS = 4;
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

  // Params and Capabilities is TObject because for Examples Cameras have addition Params like Shutter Time\Aperture
  //   override TXICA_Item.ParamsClass and CapabilitiesClass methods to assign your classes
  TXICA_Capabilities = class;

  { TXICA_Params }

  TXICA_Params = class(TPersistent)
  protected
    procedure AssignTo(Dest: TPersistent); override;

  public
    NativeUI: Boolean;
    PaperType: TXICA_PaperType;

    //Used only if PaperType=ptCUSTOM
    PaperW,
    PaperH: Single;

    Rotation: TXICA_Rotation;
    HAlign: TXICA_AlignHorizontal;
    VAlign: TXICA_AlignVertical;
    Pages,
    Resolution,
    Contrast,
    //BitDepth,
    Brightness: Integer;
    DataType: TXICA_DataType;
    DocHandling: TXICA_DocumentHandlings;

    constructor Create;

    procedure PredefinedValues; virtual;

    procedure CopyFromCapabilitiesDefaultValues(const ACapabilities: TXICA_Capabilities); overload; virtual;
    procedure CopyFromCapabilitiesDefaultValues(const ACapabilities: TXICA_Capabilities;
                                                const aHAlign: TXICA_AlignHorizontal;
                                                const aVAlign: TXICA_AlignVertical); overload; virtual;

    procedure CopyFromCapabilitiesCurrentValues(const ACapabilities: TXICA_Capabilities); overload; virtual;
    procedure CopyFromCapabilitiesCurrentValues(const ACapabilities: TXICA_Capabilities;
                                                const aHAlign: TXICA_AlignHorizontal;
                                                const aVAlign: TXICA_AlignVertical); overload; virtual;

    function Load(const xml_File, xml_RootPath: String): Boolean; overload;
    function Load(const XMLWork: TXMLConfig; xml_RootPath: String): Boolean; overload; virtual;

    function Save(const xml_File, xml_RootPath: String): Boolean; overload;
    function Save(const XMLWork: TXMLConfig; xml_RootPath: String): Boolean; overload; virtual;
  end;
  TArrayXICA_Params = array of TXICA_Params;
  TXICA_ParamsClass = class of TXICA_Params;

  { TXICA_Capabilities }

  TXICA_Capabilities = class(TPersistent)
  public
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
    DocHandlingSet: TXICA_DocumentHandlings;

    function GeDatatType_Str(const ADataType: TXICA_DataType): String; virtual;
    function GeImageFormat_Str(const AImageFormat: TXICA_ImageFormat): String; virtual;
  end;
  TArrayXICA_Capabilities = array of TXICA_Capabilities;
  TXICA_CapabilitiesClass = class of TXICA_Capabilities;

const
  XICA_ImageFormatDescr : array [TXICA_ImageFormat] of String = (
    'Undefined',
    'Raw RGB format',
    'Windows bitmap without a header',
    'Windows Device Independent Bitmap',
    'Extended Windows metafile',
    'Windows metafile',
    'JPEG compressed format',
    'W3C PNG format',
    'GIF image format',
    'Tagged Image File format',
    'Exchangeable File Format',
    'Eastman Kodak file format',
    'FlashPix format',
    'Windows icon file format',
    'Camera Image File format',
    'Apple file format',
    'JPEG 2000 compressed format',
    'JPEG 2000X compressed format',
    'Raw image file format',
    'Joint Bi-level Image experts Group format',
    'Joint Bi-level Image experts Group format (ver 2)'
  );

  XICA_DataTypeDescr: array [TXICA_DataType] of String = (
    'Black & White',
    'Gray scale',
    'Color (RGB)',
    'Color (RAW RGB)',
    'Color (RAW BGR)',
    'Color (RAW YUV)',
    'Color (RAW YUVK)',
    'Color (RAW CMY)',
    'Color (RAW CMYK)',
    'Auto'
  );

procedure VersionStrToInt(const s: String; out Ver, VerSub: Integer); overload;

function FullPathToRelativePath(const ABasePath: String; var APath: String): Boolean;

implementation

uses SysUtils;

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

function FullPathToRelativePath(const ABasePath: String; var APath: String): Boolean;
begin
  Result:= (Pos(ABasePath, APath) = 1);
  if Result
  then APath:= '.'+DirectorySeparator+Copy(APath, Length(ABasePath)+1, MaxInt);
end;

{ TXICA_Params }

procedure TXICA_Params.AssignTo(Dest: TPersistent);
begin
  if (Dest <> nil) then
  with Dest do
  begin
    NativeUI:= Self.NativeUI;
    PaperType:= Self.PaperType;

    PaperW:= Self.PaperW;
    PaperH:= Self.PaperH;

    Rotation:= Self.Rotation;
    HAlign:= Self.HAlign;
    VAlign:= Self.VAlign;
    Pages:= Self.Pages;
    Resolution:= Self.Resolution;
    Contrast:= Self.Contrast;
    //BitDepth:= Self.BitDepth;
    Brightness:= Self.Brightness;
    DataType:= Self.DataType;
    DocHandling:= Self.DocHandling;
  end;
end;

constructor TXICA_Params.Create;
begin
  inherited Create;

  PredefinedValues;
end;

procedure TXICA_Params.PredefinedValues;
begin
  NativeUI:= False;
  PaperType:= ptMAX;
  PaperW:= 0;
  PaperH:= 0;
  Rotation:= xrPortrait;
  HAlign:= xaHLeft;
  VAlign:= xaVTop;
  Pages:= 0;
  Resolution:= 200;
  Contrast:= 0;
  Brightness:= 0;
  DataType:= xdtCOLOR;
  DocHandling:= [];
  //BitDepth:= ;
end;

procedure TXICA_Params.CopyFromCapabilitiesDefaultValues(const ACapabilities: TXICA_Capabilities);
begin
  if (ACapabilities <> nil) then
  with ACapabilities do
  begin
    PaperType:= PaperTypeDefault;
    Pages:= 0;
    Resolution:= ResolutionDefault;
    Contrast:= ContrastDefault;
    Brightness:= BrightnessDefault;
    DataType:= DataTypeDefault;
    DocHandling:= DocHandlingDefault;
    //BitDepth:= BitDepthDefault;
  end;
end;

procedure TXICA_Params.CopyFromCapabilitiesDefaultValues(const ACapabilities: TXICA_Capabilities;
                                                         const aHAlign: TXICA_AlignHorizontal; const aVAlign: TXICA_AlignVertical);
begin
  CopyFromCapabilitiesDefaultValues(ACapabilities);
  HAlign:= aHAlign;
  VAlign:= aVAlign;
end;

procedure TXICA_Params.CopyFromCapabilitiesCurrentValues(const ACapabilities: TXICA_Capabilities);
begin
  if (ACapabilities <> nil) then
  with ACapabilities do
  begin
    PaperType:= PaperTypeCurrent;
    Pages:= 0;
    Resolution:= ResolutionCurrent;
    Contrast:= ContrastCurrent;
    Brightness:= BrightnessCurrent;
    DataType:= DataTypeCurrent;
    DocHandling:= DocHandlingCurrent;
    //BitDepth:= BitDepthCurrent;
  end;
end;

procedure TXICA_Params.CopyFromCapabilitiesCurrentValues(const ACapabilities: TXICA_Capabilities;
                                                         const aHAlign: TXICA_AlignHorizontal; const aVAlign: TXICA_AlignVertical);
begin
  CopyFromCapabilitiesCurrentValues(ACapabilities);
  HAlign:= aHAlign;
  VAlign:= aVAlign;
end;

function TXICA_Params.Load(const xml_File, xml_RootPath: String): Boolean;
var
   XMLWork: TXMLConfig;

begin
  try
     Result:= False;
     XMLWork:= TXMLConfig.Create(xml_File);
     Result:= Load(XMLWork, xml_RootPath);

  finally
    XMLWork.Free;
  end;
end;

function TXICA_Params.Load(const XMLWork: TXMLConfig; xml_RootPath: String): Boolean;
var
   curItemPath: String;

begin
  Result:= False;

  curItemPath:= xml_RootPath;
  if (curItemPath[Length(curItemPath)] <> '/') then curItemPath:= curItemPath+'/';

  NativeUI:= XMLWork.GetValue(curItemPath+'NativeUI', False);
  XMLWork.GetValue(curItemPath+'PaperType', PaperType, TypeInfo(TXICA_PaperType));
  PaperW:= StrToFloat(XMLWork.GetValue(curItemPath+'PaperW', '0'));
  PaperH:= StrToFloat(XMLWork.GetValue(curItemPath+'PaperH', '0'));
  XMLWork.GetValue(curItemPath+'Rotation', Rotation, TypeInfo(TXICA_Rotation));
  XMLWork.GetValue(curItemPath+'HAlign', HAlign, TypeInfo(TXICA_AlignHorizontal));
  XMLWork.GetValue(curItemPath+'VAlign', VAlign, TypeInfo(TXICA_AlignVertical));
  Pages:= XMLWork.GetValue(curItemPath+'Pages', 0);
  Resolution:= XMLWork.GetValue(curItemPath+'Resolution', 200);
  Contrast:= XMLWork.GetValue(curItemPath+'Contrast', 0);
  Brightness:= XMLWork.GetValue(curItemPath+'Brightness', 0);
  XMLWork.GetValue(curItemPath+'DataType', DataType, TypeInfo(TXICA_DataType));
  XMLWork.GetValue(curItemPath+'DocHandling', DocHandling, TypeInfo(TXICA_DocumentHandlings));

  Result:= True;
end;

function TXICA_Params.Save(const xml_File, xml_RootPath: String): Boolean;
var
   XMLWork: TXMLConfig;

begin
  try
     Result:= False;
     XMLWork:= TXMLConfig.Create(xml_File);
     Result:= Save(XMLWork, xml_RootPath);

  finally
    XMLWork.Free;
  end;
end;

function TXICA_Params.Save(const XMLWork: TXMLConfig; xml_RootPath: String): Boolean;
var
   curItemPath: String;

begin
  Result:= False;

  curItemPath:= xml_RootPath;
  if (curItemPath[Length(curItemPath)] <> '/') then curItemPath:= curItemPath+'/';

  XMLWork.SetValue(curItemPath+'NativeUI', NativeUI);
  XMLWork.SetValue(curItemPath+'PaperType', PaperType, TypeInfo(TXICA_PaperType));
  XMLWork.SetValue(curItemPath+'PaperW', FloatToStr(PaperW));
  XMLWork.SetValue(curItemPath+'PaperH',  FloatToStr(PaperH));
  XMLWork.SetValue(curItemPath+'Rotation', Rotation, TypeInfo(TXICA_Rotation));
  XMLWork.SetValue(curItemPath+'HAlign', HAlign, TypeInfo(TXICA_AlignHorizontal));
  XMLWork.SetValue(curItemPath+'VAlign', VAlign, TypeInfo(TXICA_AlignVertical));
  XMLWork.SetValue(curItemPath+'Pages', Pages);
  XMLWork.SetValue(curItemPath+'Resolution', Resolution);
  XMLWork.SetValue(curItemPath+'Contrast', Contrast);
  XMLWork.SetValue(curItemPath+'Brightness', Brightness);
  XMLWork.SetValue(curItemPath+'DataType', DataType, TypeInfo(TXICA_DataType));
  XMLWork.SetValue(curItemPath+'DocHandling', DocHandling, TypeInfo(TXICA_DocumentHandlings));

  XMLWork.Flush;

  Result:= True;
end;

{ TXICA_Capabilities }

function TXICA_Capabilities.GeDatatType_Str(const ADataType: TXICA_DataType): String;
begin
  if (ADataType in [Low(TXICA_DataType)..High(TXICA_DataType)])
  then Result:= XICA_DataTypeDescr[ADataType]
  else Result:= 'Unknown ('+IntToStr(Integer(ADataType))+')';
end;

function TXICA_Capabilities.GeImageFormat_Str(const AImageFormat: TXICA_ImageFormat): String;
begin
  if (AImageFormat in [Low(TXICA_ImageFormat)..High(TXICA_ImageFormat)])
  then Result:= XICA_ImageFormatDescr[AImageFormat]
  else Result:= 'Unknown ('+IntToStr(Integer(AImageFormat))+')';
end;


end.

