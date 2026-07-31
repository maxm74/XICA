(****************************************************************************
*                XICA (Cross-platform Image Capture Architecture)
*
*  FILE: XICA.pas
*
*  VERSION:     0.0.1
*
*  DESCRIPTION:
*    The Main Manager to enumerate the different libraries
*
*****************************************************************************
*
*  (c) 2026 Massimo Magnano
*
*  See changelog.txt for Change Log
*
*****************************************************************************)
unit XICA;

{$ifdef fpc}
  {$mode delphi}
{$endif}
{$H+}
{$R-}

interface

uses Classes, SysUtils,
     {$ifdef fpc}testutils,{$else}DelphiCompatibility,{$endif}
     MM_OpenArrayList,
     XICA_Classes;

type

  { TXICA_Manager }

  TXICA_Manager = class(TOpenArrayList<TXICA_DeviceManager, TKeyString>)
  protected
    rEnumAll: Boolean;
    rOnAfterDeviceTransfer,
    rOnBeforeDeviceTransfer: TXICA_OnDeviceTransfer;

    function FreeElement(var aData: TXICA_DeviceManager): Boolean; override;

  public
    constructor Create(AEnumAll: Boolean = True);
    destructor Destroy; override;

    //Kind of Enum, if True Enum even disconnected Devices
    property EnumAll: Boolean read rEnumAll write rEnumAll;

    //Events
    property OnBeforeDeviceTransfer: TXICA_OnDeviceTransfer read rOnBeforeDeviceTransfer write rOnBeforeDeviceTransfer;
    property OnAfterDeviceTransfer: TXICA_OnDeviceTransfer read rOnAfterDeviceTransfer write rOnAfterDeviceTransfer;
  end;


var
   XICA_EnumAllDevices: Boolean = True;
   XICA_Manager: TXICA_Manager = nil;

procedure XICA_RegisterDeviceManager(const AName: TKeyString; const ADeviceManager: TXICA_DeviceManager);
procedure XICA_UnRegisterDeviceManager(const ADeviceManager: TXICA_DeviceManager);

implementation

procedure XICA_RegisterDeviceManager(const AName: TKeyString; const ADeviceManager: TXICA_DeviceManager);
begin
  try
     if (XICA_Manager = nil) then XICA_Manager:= TXICA_Manager.Create;
     if (XICA_Manager <> nil) then XICA_Manager.Add(AName, ADeviceManager);
  except
  end;
end;

procedure XICA_UnRegisterDeviceManager(const ADeviceManager: TXICA_DeviceManager);
begin
  try
     if (XICA_Manager <> nil) then XICA_Manager.Del(ADeviceManager);
  except
  end;
end;

{ TXICA_Manager }

function TXICA_Manager.FreeElement(var aData: TXICA_DeviceManager): Boolean;
begin
  try
     FreeAndNil(aData);
     Result:= True;
  except
    Result:= False;
  end;
end;

constructor TXICA_Manager.Create(AEnumAll: Boolean);
begin
  inherited Create;

  rEnumAll:= AEnumAll;
end;

destructor TXICA_Manager.Destroy;
begin
  inherited Destroy;
end;

end.

