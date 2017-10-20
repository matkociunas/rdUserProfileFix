unit Helper_registry;

interface
uses Classes, Registry, Windows, System.SysUtils, System.StrUtils,
              Vcl.Controls, Vcl.Dialogs, Vcl.ComCtrls;

procedure WriteStringValueRunReg(rKey, rValue: string);
procedure DeleteBakProfileKey(rKey: string);
procedure WriteStringValueReg(rKey, rValue: string);
procedure WriteIntegerValueReg(rKey: string; rValue: integer);
procedure PopulateProfilesList(lv: TListView);
function ReadIntegerValueReg(rKey: string): integer;

implementation

procedure WriteStringValueRunReg(rKey, rValue: string);
var
  reg: TRegistry;
begin
  reg:= TRegistry.Create(KEY_WRITE);
  reg.RootKey:= HKEY_LOCAL_MACHINE;

  reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run\', True);

  try
    reg.WriteString(rKey, rValue);
  except
    raise Exception.Create('Nepavyko i�saugoti web serverio nustatym�!');
  end;
  reg.CloseKey();
  reg.Free;
end;

procedure DeleteBakProfileKey(rKey: string);
var
  reg: TRegistry;
begin
  reg:= TRegistry.Create(KEY_WRITE);
  reg.RootKey:= HKEY_LOCAL_MACHINE;

  if reg.OpenKey('SOFTWARE\Microsoft\WindowsNT\ProfileList\', True) then
  try
    reg.DeleteValue(rKey);
  finally
    reg.CloseKey();
    reg.Free;
  end;
end;

procedure WriteStringValueReg(rKey, rValue: string);
var
  reg: TRegistry;
begin
  reg:= TRegistry.Create(KEY_WRITE);
  reg.RootKey:= HKEY_CURRENT_USER;
  {
  if not reg.KeyExists('Software\ePoint\eKeitykla\Parameters\') then
    reg.Access:= KEY_WRITE;
  }
  reg.OpenKey('Software\ePoint\eKeitykla\Parameters\', True);

  try
    //reg.Access:= KEY_WRITE;
    reg.WriteString(rKey, rValue);
  except
    raise Exception.Create('Nepavyko i�saugoti nustatym�!');
  end;
  reg.CloseKey();
  reg.Free;
end;

procedure WriteIntegerValueReg(rKey: string; rValue: integer);
var
  reg: TRegistry;
begin
  reg:= TRegistry.Create(KEY_WRITE);
  reg.RootKey:= HKEY_CURRENT_USER;
  {
  if not reg.KeyExists('Software\ePoint\eKeitykla\Parameters\') then
    reg.Access:= KEY_WRITE;
  }
  reg.OpenKey('Software\ePoint\eKeitykla\Parameters\', True);

  try
    //reg.Access:= KEY_WRITE;
    reg.WriteInteger(rKey, rValue);
  except
    raise Exception.Create('Nepavyko i�saugoti nustatym�!');
  end;
  reg.CloseKey();
  reg.Free;
end;

function IsBak(profileName: string): boolean;
var
  lastThree: string;
begin
  Result:= False;
  lastThree:= RightStr(profileName, 3);
  if lastThree = 'bak' then
    Result:= True;
end;

function GetProfileUsername(profileName: String): String;
var
  reg: TRegistry;
  i: integer;
begin
  reg:= TRegistry.Create(KEY_READ);
  try
    reg.RootKey:= HKEY_LOCAL_MACHINE;
    try
      if not reg.KeyExists('Software\Microsoft\Windows NT\CurrentVersion\ProfileList\' + profileName) then
        Exit
      else begin
        reg.OpenKey('Software\Microsoft\Windows NT\CurrentVersion\ProfileList\' + profileName, True);
        Result:= reg.ReadString('ProfileImagePath');
      end;
    finally
      reg.CloseKey;
    end;
  finally
    reg.Free;
  end;
end;

function GetProfileList: TStringList;
var
  reg: TRegistry;
  subKeyNames, bakProfileList: TStringList;
  i: integer;
  profileName: String;
begin
  reg:= TRegistry.Create(KEY_READ);
  try
    reg.RootKey:= HKEY_LOCAL_MACHINE;
    subKeyNames:= TStringList.Create;
    bakProfileList:= TStringList.Create;

    if not reg.KeyExists('Software\Microsoft\Windows NT\CurrentVersion\ProfileList') then
      Exit
    else
      try
        reg.OpenKey('Software\Microsoft\Windows NT\CurrentVersion\ProfileList', True);
        reg.GetKeyNames(subKeyNames);

        for i:= 0 to subKeyNames.Count - 1 do
        begin
          profileName:= subKeyNames[i];
          if IsBak(profileName) then
            bakProfileList.Add(profileName)
        end;
      finally
        reg.CloseKey;
      end;
  finally
    reg.Free;
  end;
  Result:= bakProfileList;
end;

procedure PopulateProfilesList(lv: TListView);
var
  profileList, userNames: TStringList;
  i: integer;
  lItem: TListItem;
begin
  lv.Items.Clear;
  // getting temporary profiles list from registry
  profileList:= GetProfileList;
  for i:= 0 to profileList.Count - 1 do
  begin
    lItem:= lv.Items.Add;
    lItem.Caption:= GetProfileUsername(profileList[i]);
    lItem.ImageIndex:= 0;
    lItem.SubItems.Add(profileList[i]);
  end;
end;

function ReadIntegerValueReg(rKey: string): integer;
var
  reg: TRegistry;
begin
  reg:= TRegistry.Create(KEY_READ);
  reg.RootKey:= HKEY_CURRENT_USER;

  if not reg.KeyExists('Software\ePoint\eKeitykla\Parameters\') then
    Exit
  else
    reg.OpenKey('Software\ePoint\eKeitykla\Parameters\', True);
  try
    Result:= reg.ReadInteger(rKey);
  except
    on E: Exception do
    begin
      Result:= 0;
      reg.CloseKey();
      reg.Free;
    end;
  end;
end;

end.
