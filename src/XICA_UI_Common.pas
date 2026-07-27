(****************************************************************************
*                XICA (Cross-platform Image Capture Architecture)
*
*  FILE: XICA_UI_Common.pas
*
*  VERSION:     0.0.1
*
*  DESCRIPTION:
*    XICA UI Basic Types and Functions for registering User Interfaces.
*
*****************************************************************************
*
*  (c) 2026 Massimo Magnano
*
*  See changelog.txt for Change Log
*
*****************************************************************************)

unit XICA_UI_Common;

interface

uses
  Classes, SysUtils,
  XICA_Types, XICA_Classes;

resourcestring
  rsLandscape = 'Landscape';
  rsPortrait = 'Portrait';
  rsAutotype = 'Auto type';

type
  TXICA_SelectDialogFunc = function (ADeviceManager: TXICA_DeviceManager): Integer;

  TXICA_SettingsDialogFunc = function (ADevice: TXICA_Device;
                                       var ASelectedItemIndex: Integer;
                                       { #todo -oMaxM : Possibly Filters for which Items Kinds to Show? How manage AParams without Indexes? }
                                       AInitItemValues: TInitialItemValues;
                                       var AParams: TArrayXICA_Params;
                                       AOnInitDefaultValues: TInitDefaultValuesEvent=nil): Boolean;

var
   XICA_SelectDialogFunc: TXICA_SelectDialogFunc = nil;
   XICA_SettingsDialogFunc: TXICA_SettingsDialogFunc = nil;
   XICA_Settings_Unit_cm: Boolean = True; //False to show then measurement in fucking inches



implementation

end.

