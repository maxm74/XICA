(****************************************************************************
*                XICA (Cross-platform Image Capture Architecture)
*
*  FILE: XICA_PaperSizes.pas
*
*  VERSION:     0.0.1
*
*  DESCRIPTION:
*    Paper Sizes Types and Consts in cm/inch
*
*****************************************************************************
*
*  (c) 2026 Massimo Magnano
*
*  See changelog.txt for Change Log
*
*****************************************************************************)
unit XICA_PaperSizes;

{$H+}

interface

uses XICA_Types;

resourcestring
  rsFullsize = 'Full size';
  rsCustomsize = 'Custom size';
  rsAutosize = 'Auto size';

type
  { Description of a paper size }
  TPaperSize =
  {$ifndef FPC_REQUIRES_PROPER_ALIGNMENT}
  packed
  {$endif FPC_REQUIRES_PROPER_ALIGNMENT}
  record
    name: String[16];
    w, h: Single;
  end;
  TPaperSizes=array of TPaperSize;
  PPaperSizes=^TPaperSizes;

const
  Unit_Str: array[Boolean] of String=('in', 'cm');
  PaperSizes_MaxIndex = ptDIN_4B;

  //Sizes of Papers
  PaperSizes: array [Boolean, ptA4..ptDIN_4B] of TPaperSize = (
   (//in inch
   (name:'A4'; w:8.3; h:11.7),
   (name:'US Letter'; w:8.5; h:11.0),
   (name:'US Legal'; w:8.5; h:14.0),
   (name:'US Ledger'; w:11.0; h:17.0),
   (name:'US Statement'; w:5.5; h:8.5),
   (name:'Business card'; w:3.56; h:2.16),

   (name:'A0'; w:33.1; h:46.8), (name:'A1'; w:23.4; h:33.1), (name:'A2'; w:16.5; h:23.4),
   (name:'A3'; w:11.7; h:16.5), (name:'A5'; w:5.8; h:8.3),
   (name:'A6'; w:4.1; h:5.8), (name:'A7'; w:2.9; h:4.1), (name:'A8'; w:2.0; h:2.9),
   (name:'A9'; w:1.5; h:2.0), (name:'A10'; w:1.0; h:1.5),

   (name:'B0'; w:39.4; h:55.7), (name:'B1'; w:27.8; h:39.4), (name:'B2'; w:19.7; h:27.8),
   (name:'B3'; w:13.9; h:19.7), (name:'B4'; w:9.8; h:13.9), (name:'B5'; w:6.9; h:9.8),
   (name:'B6'; w:4.9; h:6.9), (name:'B7'; w:3.5; h:4.9), (name:'B8'; w:2.4; h:3.5),
   (name:'B9'; w:1.7; h:2.4), (name:'B10'; w:1.2; h:1.7),

   (name:'C0'; w:36.1; h:51.1), (name:'C1'; w:25.5; h:36.1), (name:'C2'; w:18.0; h:25.5),
   (name:'C3'; w:12.8; h:18.0), (name:'C4'; w:9.0; h:12.8), (name:'C5'; w:6.4; h:9.0),
   (name:'C6'; w:4.5; h:6.4), (name:'C7'; w:3.2; h:4.5), (name:'C8'; w:2.2; h:3.2),
   (name:'C9'; w:1.6; h:2.2), (name:'C10'; w:1.1; h:1.6),

   (name:'JIS B0'; w:40.6; h:57.3), (name:'JIS B1'; w:28.7; h:40.6), (name:'JIS B2'; w:20.3; h:28.7),
   (name:'JIS B3'; w:14.3; h:20.3), (name:'JIS B4'; w:10.1; h:14.3), (name:'JIS B5'; w:7.2; h:10.1),
   (name:'JIS B6'; w:5.0; h:7.2), (name:'JIS B7'; w:3.6; h:5.0), (name:'JIS B8'; w:2.5; h:3.6),
   (name:'JIS B9'; w:1.8; h:2.5), (name:'JIS B10'; w:1.3; h:1.8),
   (name:'JIS B11'; w:0.9; h:1.3), (name:'JIS B12'; w:0.6; h:0.9),

   (name:'JIS 2A'; w:46.8; h:66.2), (name:'JIS 4A'; w:66.2; h:93.6),
   (name:'DIN 2B'; w: 55.7; h: 78.8), (name:'DIN 4B'; w: 78.8; h: 111.4)
   ),
   (//in cm
   (name:'A4'; w:21.0; h:29.7),
   (name:'US Letter'; w:21.6; h:27.9),
   (name:'US Legal'; w:21.6; h:35.6),
   (name:'US Ledger'; w:27.9; h:43.2),
   (name:'US Statement'; w:14.0; h:21.6),
   (name:'Business card'; w:9.0; h:5.5),

   (name:'A0'; w:84.1; h:118.9), (name:'A1'; w:59.4; h:84.1), (name:'A2'; w:42.0; h:59.4),
   (name:'A3'; w:29.7; h:42.0), (name:'A5'; w:14.8; h:21.0),
   (name:'A6'; w:4.1; h:5.8), (name:'A7'; w:7.4; h:10.5), (name:'A8'; w:5.2; h:7.4),
   (name:'A9'; w:3.7; h:5.2), (name:'A10'; w:2.6; h:3.7),

   (name:'B0'; w:100.0; h:141.4), (name:'B1'; w:70.7; h:100.0), (name:'B2'; w:50.0; h:70.7),
   (name:'B3'; w:35.3; h:50.0), (name:'B4'; w:25.0; h:35.3), (name:'B5'; w:17.6; h:25.0),
   (name:'B6'; w:12.5; h:17.6), (name:'B7'; w:8.8; h:12.5), (name:'B8'; w:6.2; h:8.8),
   (name:'B9'; w:4.4; h:6.2), (name:'B10'; w:3.1; h:4.4),

   (name:'C0'; w:91.7; h:129.7), (name:'C1'; w:64.8; h:91.7), (name:'C2'; w:45.8; h:64.8),
   (name:'C3'; w:32.4; h:45.8), (name:'C4'; w:22.9; h:32.4), (name:'C5'; w:16.2; h:22.9),
   (name:'C6'; w:11.4; h:16.2), (name:'C7'; w:8.1; h:11.4), (name:'C8'; w:5.7; h:8.1),
   (name:'C9'; w:4.0; h:5.7), (name:'C10'; w:2.8; h:4.0),

   (name:'JIS B0'; w:103.0; h:145.6), (name:'JIS B1'; w:72.8; h:103.0), (name:'JIS B2'; w:51.5; h:72.8),
   (name:'JIS B3'; w:36.4; h:51.5), (name:'JIS B4'; w:25.7; h:36.4), (name:'JIS B5'; w:18.2; h:25.7),
   (name:'JIS B6'; w:12.8; h:18.2), (name:'JIS B7'; w:9.1; h:12.8), (name:'JIS B8'; w:6.4; h:9.1),
   (name:'JIS B9'; w:4.5; h:6.4), (name:'JIS B10'; w:3.2; h:4.5),
   (name:'JIS B11'; w:2.2; h:3.2), (name:'JIS B12'; w:1.6; h:2.2),

   (name:'JIS 2A'; w:118.9; h:168.2), (name:'JIS 4A'; w:168.2; h:237.8),
   (name:'DIN 2B'; w:141.4; h:200), (name:'DIN 4B'; w:200; h:282.8)
   )
   );


//  Builds a set of Paper Types contained within the specified size
function CalculatePaperSizeSet(Max_Width, Max_Height: Single): TXICA_PaperTypes;

function CalculatePaperSize(AWidth, AHeight: Single): TXICA_PaperType;

function PaperTypeNameAndSize(Unit_cm: Boolean; APaperType: TXICA_PaperType): String;

var
   Size_Unit_cm: Boolean = True; //False to show then measurement in fucking inches

implementation

uses SysUtils;

function CalculatePaperSizeSet(Max_Width, Max_Height: Single): TXICA_PaperTypes;
var
   iSwap: Single;
   i: TXICA_PaperType;

begin
  Result:= [ptMAX];

  //We need always the Vertical Dimensions, PaperSizes is Portrait
  if (Max_Width > Max_Height) then
  begin
    iSwap:= Max_Height;
    Max_Height:= Max_Width;
    Max_Width:= iSwap;
  end;

  for i:=ptA4 to PaperSizes_MaxIndex do
  begin
    //if the Paper is inside the Max Area then include it as selectable
    if (PaperSizes[Size_Unit_cm, i].w <= Max_Width) and (PaperSizes[Size_Unit_cm, i].h <= Max_Height)
    then Result:= Result + [i];
  end;
end;

function CalculatePaperSize(AWidth, AHeight: Single): TXICA_PaperType;
var
   i: TXICA_PaperType;

begin
  Result:= ptCUSTOM;
  for i:=ptA4 to PaperSizes_MaxIndex do
  begin
    //if the Width/Height is equals to a Paper then select it
    { #note -oMaxM : It might be helpful to include a margin of error }
    if (PaperSizes[Size_Unit_cm, i].w = AWidth) and (PaperSizes[Size_Unit_cm, i].h = AHeight)
    then begin Result:= i; break; end;
  end;
end;

function PaperTypeNameAndSize(Unit_cm: Boolean; APaperType: TXICA_PaperType): String;
begin
  Case APaperType of
  ptMAX: Result:= rsFullsize;
  ptCUSTOM: Result:= rsCustomsize;
  ptAUTO: Result:= rsAutosize;
  else Result:= PaperSizes[Unit_cm, APaperType].name+' ('+
                       FloatToStrF(PaperSizes[Unit_cm, APaperType].w, ffFixed, 15, 2)+' x '+
                       FloatToStrF(PaperSizes[Unit_cm, APaperType].h, ffFixed, 15, 2)+' '+Unit_Str[Unit_cm];
  end;
end;

end.

