(****************************************************************************
*                XICA (Cross-platform Image Capture Architecture)
*
*  FILE: XICA_Classes.pas
*
*  VERSION:     0.0.1
*
*  DESCRIPTION:
*    Base Manager and Device Classes,
*      the various image acquisition libraries must derive from these classes
*
*****************************************************************************
*
*  (c) 2026 Massimo Magnano
*
*  See changelog.txt for Change Log
*
*****************************************************************************)
unit XICA_Classes;

{$ifdef fpc}
  {$mode delphi}
{$endif}
{$H+}

interface

uses Classes, SysUtils,
     {$ifdef fpc}testutils,{$else}DelphiCompatibility,{$endif}
     MM_OpenArrayList, XICA_Types;

type
  TXICA_Manager = class;

  { TXICA_Device }

  // UI Settings of Source Device
  TInitialItemValues = (initDefault, initParams, initCurrent);
  TInitDefaultValuesEvent = procedure (var ACap: TXICA_ParamsCapabilities) of object;

  TXICA_Device = class(TNoRefCountObject)
  protected
    rOwner: TXICA_Manager;
    rIndex: Integer;
    rID,
    rManufacturer,
    rName: String;
    rType: TXICA_DeviceType;
    rSubType: Word;
    rVersion,
    rVersionSub: Integer;
    lres: HResult;
  end;

  { TXICA_Manager }

  (*TOnDeviceTransfer = function (AWiaManager: TWIAManager; AWiaDevice: TWIADevice;
                         lFlags: LONG; pWiaTransferParams: PWiaTransferParams): Boolean of object;*)

  TXICA_Manager = class(TOpenArrayList<TXICA_Device, TKeyString>)
  protected
    rEnumAll: Boolean;
    lres: HResult;
    HasEnumerated: Boolean;
    //rOnAfterDeviceTransfer,
    //rOnBeforeDeviceTransfer: TOnDeviceTransfer;
  end;


implementation

end.

