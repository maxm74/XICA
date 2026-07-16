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
  TXICA_LibraryManager = class(TOpenArrayList<TXICA_Manager, TKeyString>)
  protected
    rEnumAll: Boolean;
    lres: HResult;
    HasEnumerated: Boolean;
    //rOnAfterDeviceTransfer,
    //rOnBeforeDeviceTransfer: TOnDeviceTransfer;
  end;


var
   XICA_LibraryManager: TXICA_LibraryManager = nil;

implementation

end.

