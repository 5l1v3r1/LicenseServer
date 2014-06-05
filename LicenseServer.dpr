{ ##############################################################################################
  ## Projectname:  LicenseServer
  ## Author:       0x92
  ## Release:      /
  ## Last change:  28.05.2014
  ## Contact:      0x92dev@gmail.com
  ## Note:         I see stupid people everywhere
  ##
  ## -------------------------------------------------------------------------------------------
  ## Parameter:
  ##
  ##
  ##
  ##
  ## -------------------------------------------------------------------------------------------
  ##
  ##
  ##
  ##############################################################################################}

{CMD Colors
  Black = 0;
  Blue = 1;
  Green = 2;
  Cyan = 3;
  Red = 4;
  Magenta = 5;
  Brown = 6;
  LightGray = 7;
  DarkGray = 8;
  LightBlue = 9;
  LightGreen = 10;
  LightCyan = 11;
  LightRed = 12;
  LightMagenta = 13;
  Yellow = 14;
  White = 15;
}

program LicenseServer;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Windows,
  Winsock,
  IOUtils,
  Classes,
  Variants,
  IniFiles,
  msxmldom,
  XMLDoc,
  ActiveX,
  Generics.Collections,
  uDM in 'uDM.pas' {DM: TDataModule};

var
  bDebugMode:        Boolean = True;                                            // On / Off
  sFilename:         String;
  Ini:               TIniFile;
  iConnectionPort:   Integer;

procedure WriteInfo(Text: String);
begin
  WriteLn;
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 10);
  Write('[INFO]:');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  Write(' '+Text);
end;

procedure WriteDebug(Text: String);
begin
  WriteLn;
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 13);
  Write('[DEBUG]:');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  Write(' '+Text);
end;

procedure WriteError(Text: String);
begin
  WriteLn;
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 12);
  Write('[ERROR]:');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  Write(' '+Text);
end;


procedure WriteHeader;
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  Write(' ------------------------------------------------');
  WriteLn;
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  Write('|    License Server <May 2014> by 0x92           |');
  WriteLn;
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  Write('|    Created at a rainy day for me.              |');
  WriteLn;
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  Write('|    YOCO - You only code once!                  |');
  WriteLn;
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  Write(' ------------------------------------------------');
end;

function loadConfig:boolean;
begin
  try
    DM.MysqlConnection.Server   := Ini.ReadString ('MySQL', 'host', '');
    DM.MysqlConnection.Port     := Ini.ReadInteger('MySQL', 'port', 0);
    DM.MysqlConnection.Username := Ini.ReadString ('MySQL', 'user', '');
    DM.MysqlConnection.Password := Ini.ReadString ('MySQL', 'pass', '');
    DM.MysqlConnection.Database := Ini.ReadString ('MySQL', 'database', '');
    iConnectionPort             := Ini.ReadInteger('Connection', 'port', 1338);
    Result := True;
  except
    Result := False;
  end;
end;

function ConnectToMySQL:boolean;
begin
  try
    DM.MysqlConnection.Connect;

    if Dm.MysqlConnection.Connected then
      Result := True;
  except
    Result := False;
  end;
end;


procedure HandleError;
var
  ErrorCode: Integer;
  S: String;
  Len: Integer;
begin
  ErrorCode := WSAGetLastError;
  SetLength(s, 260);
  Len := Formatmessage(Format_Message_from_System,
    nil, errorCode, 0, @s[1], length(s), nil);
  Setlength(s, Len);
  WriteDebug(IntToStr(SOCKET_ERROR));
end;

procedure InitSockets;
var Data: WSAData;
begin
  if WSAStartup( MakeWord(1,1), Data) = SOCKET_ERROR then
    HandleERROR;
end;

function createSocket_TCP:TSocket;
begin
  result := socket(AF_INET,
                   SOCK_STREAM,
                   IPProto_TCP);
  if result = INVALID_SOCKET then HandleError;
end;

{ < =========== DEBUG Methoden ============================================== > }

procedure ClearTables; //
begin
 // SQL Statements todo
end;
{ < ========================================================================= >}

begin
    WriteHeader;
    CoInitialize(nil);                                                            // Behebt den Xe3 Bug http://qc.embarcadero.com/wc/qcmain.aspx?d=108838                                                          //Debugmethoden an/aus
    DM := TDM.Create(nil);                                                        // Datenmodul erstellen
    sFilename := ExtractFilePath(ParamStr(0)) + 'mysql.ini';
    Sleep(599);
    WriteInfo('Scanning for Config ...');

    if FileExists(sFilename) then
    begin
      Ini := TIniFile.Create(sFilename);
      Sleep(599);
      WriteInfo('Config was found.');
    end
    else
    begin
      WriteError('Config not found.');
      ReadLn;
      Exit;
    end;

    if loadConfig then
    begin
      Sleep(599);
      WriteInfo('Config was loaded successfully.');
    end
    else
    begin
      WriteError('Config could not be load.');
      Readln;
      Exit;
    end;

    if ConnectToMySQL then
    begin
      Sleep(599);
      WriteInfo('Successfully connected to MySQL.');
    end
    else
    begin
      WriteError('Could not connect to MySQL. Check the config values!');
      Readln;
      Exit;
    end;

    if bDebugMode then
    begin
      Sleep(599);
      WriteDebug('Debugmode activated');
      WriteDebug('Connection port: ' + IntToStr(iConnectionPort));
    end;

    InitSockets;
    ReadLn;


    WSACleanup; // Aufr�umen bzw zu Disconnect schieben
end.
