(****************************************************************************
*                XICA (Cross-platform Image Capture Architecture)
*
*  FILE: XICA_WIA.pas
*
*  VERSION:     0.0.1
*
*  DESCRIPTION:
*    WIA implementation
*
*****************************************************************************
*
*  (c) 2026 Massimo Magnano
*
*  See changelog.txt for Change Log
*
*****************************************************************************)
unit XICA_WIA;

{$ifdef fpc}
  {$mode delphi}
{$endif}
{$H+}

interface

{$ifdef MSWINDOWS}

uses Windows, Classes, SysUtils,
    {$ifdef fpc}testutils,{$else}DelphiCompatibility,{$endif}
     ComObj, ActiveX, WiaDef, WIA_LH, //Wia_PaperSizes
     XICA_Types, XICA_Classes;

type
  { TXICA_WIADevice }

  TXICA_WiaDevice = class(TXICA_Device)
  end;

  { TXICA_WIAManager }

  (*TOnDeviceTransfer = function (AWiaManager: TWIAManager; AWiaDevice: TWIADevice;
                         lFlags: LONG; pWiaTransferParams: PWiaTransferParams): Boolean of object;*)

  TXICA_WIAManager = class(TXICA_DeviceManager)
  protected
    //rOnAfterDeviceTransfer,
    //rOnBeforeDeviceTransfer: TOnDeviceTransfer;
  end;

{$endif}

implementation

{$ifdef MSWINDOWS}
{$endif}

end.

