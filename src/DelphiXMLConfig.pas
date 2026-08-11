(****************************************************************************
*
*  FILE: DelphiXMLConfig.pas
*
*  VERSION:     1.0
*
*  DESCRIPTION:
*    TXMLConfig Class Delphi equivalent to make code compatible with FreePascal.
*
*****************************************************************************
*
*  2026 Massimo Magnano
*
*
*****************************************************************************)
unit DelphiXMLConfig;

interface

uses
  SysUtils, Classes, TypInfo, XMLDoc, XMLIntf;

type
  TXMLConfig = class
  private const
    ZeroSrc: array [0..3] of UINT64 = (0,0,0,0);
  private
    FXMLDoc: IXMLDocument;
    FFileName: string;
    function FindOrCreatePath(const APath: string; ACreateMissing: Boolean): IXMLNode;
    procedure SetFileName(const AValue: string);
  public
    constructor Create(const AFileName: string);
    destructor Destroy; override;

    function GetValue(const APath: string; const ADefault: string): string; overload;
    function GetValue(const APath: string; ADefault: Integer): Integer; overload;
    function GetValue(const APath: string; ADefault: Boolean): Boolean; overload;
    procedure GetValue(const APath: string; const ADefault; out AResult; const APTypeInfo: PTypeInfo); overload;
    procedure GetValue(const APath: string; out AResult; const APTypeInfo: PTypeInfo); overload;

    procedure SetValue(const APath: string; const AValue: string); overload;
    procedure SetValue(const APath: string; AValue: Integer); overload;
    procedure SetValue(const APath: string; AValue: Boolean); overload;
    procedure SetValue(const APath: string; AValue: Integer; ATypeInfo: PTypeInfo); overload;
    procedure SetValue(const APath: string; const AValue; const APTypeInfo: PTypeInfo); overload;

    procedure DeletePath(const APath: string);
    procedure Flush;
    procedure Clear;

    property Filename: string read FFileName write SetFileName;
  end;

implementation

constructor TXMLConfig.Create(const AFileName: string);
begin
  inherited Create;
  SetFileName(AFileName);
end;

destructor TXMLConfig.Destroy;
begin
  Flush;
  inherited;
end;

procedure TXMLConfig.SetFileName(const AValue: string);
begin
  if FFileName <> AValue then
  begin
    if (FFileName <> '') and (FXMLDoc <> nil) and FXMLDoc.Active then
      Flush;

    FFileName := AValue;
    FXMLDoc := TXMLDocument.Create(nil);
    FXMLDoc.Options := FXMLDoc.Options + [doNodeAutoIndent];

    if (FFileName <> '') and FileExists(FFileName) then
      FXMLDoc.LoadFromFile(FFileName)
    else if FFileName <> '' then
      FXMLDoc.Active := True;
  end;
end;

procedure TXMLConfig.Flush;
begin
  if (FFileName <> '') and (FXMLDoc <> nil) and FXMLDoc.Active then
    FXMLDoc.SaveToFile(FFileName);
end;

procedure TXMLConfig.Clear;
begin
  if FXMLDoc <> nil then
  begin
    FXMLDoc.Active := False;
    FXMLDoc.Active := True;
  end;
end;

function TXMLConfig.FindOrCreatePath(const APath: string; ACreateMissing: Boolean): IXMLNode;
var
  Tokens: TArray<string>;
  Token: string;
  CurrentNode: IXMLNode;
begin
  Result := nil;
  // Split path by forward slash (e.g., 'appsettings/server/host')
  Tokens := APath.Split(['/'], TStringSplitOptions.ExcludeEmpty);
  if Length(Tokens) = 0 then Exit;

  // Handle Root Node
  if FXMLDoc.DocumentElement = nil then
  begin
    if not ACreateMissing then Exit;
    FXMLDoc.DocumentElement := FXMLDoc.CreateNode(Tokens[0]);
    CurrentNode := FXMLDoc.DocumentElement;
  end
  else
  begin
    CurrentNode := FXMLDoc.DocumentElement;
    if SameText(CurrentNode.NodeName, Tokens[0]) = False then
    begin
      // Path mismatch with existing root
      if not ACreateMissing then Exit;
    end;
  end;

  // Navigate down the rest of the path tokens
  for var I := 1 to High(Tokens) do
  begin
    Token := Tokens[I];
    var Child := CurrentNode.ChildNodes.FindNode(Token);

    if Child = nil then
    begin
      if ACreateMissing then
        Child := CurrentNode.AddChild(Token)
      else
        Exit(nil); // Path element not found
    end;
    CurrentNode := Child;
  end;

  Result := CurrentNode;
end;


procedure TXMLConfig.DeletePath(const APath: string);
var
  TargetNode, ParentNode: IXMLNode;
  Tokens: TArray<string>;
begin
  Tokens := APath.Split(['/'], TStringSplitOptions.ExcludeEmpty);
  if Length(Tokens) = 0 then Exit;

  if (Length(Tokens) = 1) and (FXMLDoc.DocumentElement <> nil) and
     SameText(FXMLDoc.DocumentElement.NodeName, Tokens[0]) then
  begin
    FXMLDoc.DocumentElement := nil;
    Exit;
  end;

  TargetNode := FindOrCreatePath(APath, False);
  if TargetNode <> nil then
  begin
    ParentNode := TargetNode.ParentNode;
    if ParentNode <> nil then
    begin
      ParentNode.ChildNodes.Remove(TargetNode);

      while (ParentNode <> FXMLDoc.DocumentElement) and (ParentNode.ChildNodes.Count = 0) and (ParentNode.Text = '') do
      begin
        TargetNode := ParentNode;
        ParentNode := TargetNode.ParentNode;
        if ParentNode <> nil then
          ParentNode.ChildNodes.Remove(TargetNode)
        else
          Break;
      end;
    end;
  end;
end;

function TXMLConfig.GetValue(const APath: string; const ADefault: string): string;
var
  TargetNode: IXMLNode;
begin
  TargetNode := FindOrCreatePath(APath, False);
  if (TargetNode <> nil) then
    Result := TargetNode.Text
  else
    Result := ADefault;
end;

function TXMLConfig.GetValue(const APath: string; ADefault: Integer): Integer;
begin
  Result := StrToIntDef(GetValue(APath, ''), ADefault);
end;

function TXMLConfig.GetValue(const APath: string; ADefault: Boolean): Boolean;
var
  ValueStr: string;
begin
  ValueStr := GetValue(APath, '');
  if ValueStr = '' then
    Exit(ADefault);

  if SameText(ValueStr, 'True') or (ValueStr = '1') then
    Result := True
  else if SameText(ValueStr, 'False') or (ValueStr = '0') then
    Result := False
  else
    Result := ADefault;
end;

procedure TXMLConfig.GetValue(const APath: string; const ADefault; out AResult; const APTypeInfo: PTypeInfo);
var
  ValueStr: string;
  IntValue, DefaultValue: Integer;
begin
  // Get default value given TypeInfo
  DefaultValue := 0;
  case GetTypeData(APTypeInfo)^.OrdType of
    otSByte, otUByte: DefaultValue := ShortInt(ADefault);
    otSWord, otUWord: DefaultValue := SmallInt(ADefault);
    otSLong, otULong: DefaultValue := Integer(ADefault);
  end;

  ValueStr := GetValue(APath, '');
  if ValueStr = '' then
    IntValue := DefaultValue
  else
  begin
    IntValue := GetEnumValue(APTypeInfo, ValueStr);
    if IntValue = -1 then
      IntValue := DefaultValue;
  end;

  // Set default value given TypeInfo
  case GetTypeData(APTypeInfo)^.OrdType of
    otSByte, otUByte: Byte(AResult) := IntValue;
    otSWord, otUWord: Word(AResult) := IntValue;
    otSLong, otULong: Integer(AResult) := IntValue;
  end;
end;

procedure TXMLConfig.GetValue(const APath: string; out AResult; const APTypeInfo: PTypeInfo);
begin
  GetValue(APath, ZeroSrc, AResult, APTypeInfo);
end;


procedure TXMLConfig.SetValue(const APath: string; const AValue: string);
var
  TargetNode: IXMLNode;
begin
  TargetNode := FindOrCreatePath(APath, True);
  if TargetNode <> nil then
    TargetNode.Text := AValue;
end;

procedure TXMLConfig.SetValue(const APath: string; AValue: Integer);
begin
  SetValue(APath, IntToStr(AValue));
end;

procedure TXMLConfig.SetValue(const APath: string; AValue: Boolean);
begin
  SetValue(APath, BoolToStr(AValue, True));
end;

procedure TXMLConfig.SetValue(const APath: string; AValue: Integer; ATypeInfo: PTypeInfo);
var
  EnumName: string;
begin
  EnumName := GetEnumName(ATypeInfo, AValue);
  SetValue(APath, EnumName);
end;

procedure TXMLConfig.SetValue(const APath: string; const AValue; const APTypeInfo: PTypeInfo);
var
  IntValue: Integer;
  EnumName: string;
begin
  IntValue := 0;
  case GetTypeData(APTypeInfo)^.OrdType of
    otSByte, otUByte: IntValue := Byte(AValue);
    otSWord, otUWord: IntValue := Word(AValue);
    otSLong, otULong: IntValue := Integer(AValue);
  end;

  EnumName := GetEnumName(APTypeInfo, IntValue);
  SetValue(APath, EnumName);
end;

end.

