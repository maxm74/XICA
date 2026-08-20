(*******************************************************************************
*                XICA (Cross-platform Image Capture Architecture)              *
*                                                                              *
*  FILE: XICA.pas                                                              *
*                                                                              *
*  VERSION:     0.0.1                                                          *
*                                                                              *
*  DESCRIPTION:                                                                *
*    The Main Manager to enumerate the different libraries                     *
*                                                                              *
********************************************************************************
*                                                                              *
*  (c) 2026 Massimo Magnano                                                    *
*                                                                              *
*  See changelog.txt for Change Log                                            *
*                                                                              *
*******************************************************************************)
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

    class function SelectDialogFunc: TXICA_SelectDialogFunc; virtual;

  public
    constructor Create(AEnumAll: Boolean = True);
    destructor Destroy; override;

    //Refresh the list of devices
    procedure Refresh(const PreserveSelected: Boolean=True);

    //Display a dialog to let the user choose a Device and return it
    function SelectDeviceDialog: TXICA_Device; virtual;

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

class function TXICA_Manager.SelectDialogFunc: TXICA_SelectDialogFunc;
begin
  Result:= XICA_UI_SelectDialogFunc;
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

procedure TXICA_Manager.Refresh(const PreserveSelected: Boolean);
var
   i: Integer;
   curDeviceManager: TXICA_DeviceManager;

begin
   for i:=0 to Count-1 do
    if Get(i, curDeviceManager) then curDeviceManager.Refresh(PreserveSelected);
end;

function TXICA_Manager.SelectDeviceDialog: TXICA_Device;
var
   fSelectDialogFunc: TXICA_SelectDialogFunc;

begin
  Result:= nil;
  try
     fSelectDialogFunc:= TXICA_Manager.SelectDialogFunc(); //Don't remove the brackets, Delphi doesn't get along very well without it
     if Assigned(fSelectDialogFunc) then fSelectDialogFunc(Self, Result);

  except
  end;
end;

end.

