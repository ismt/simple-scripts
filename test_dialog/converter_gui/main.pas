unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  StdCtrls, AsyncProcess, LazFileUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    AsyncProcess1: TAsyncProcess;
    PictureToDlinnopost: TButton;
    procedure FormCreate(Sender: TObject);
    procedure PictureToDlinnopostClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  //ItogRootPath: String;
  DefaultJpgConvertOptions: TStringList;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.PictureToDlinnopostClick(Sender: TObject);
begin

end;

function ItogRootPath():string;
begin
  Result := GetUserDir+DirectorySeparator+'КартинкиВДлиннопост';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     DefaultJpgConvertOptions:=TStringList.Create;
     DefaultJpgConvertOptions.Add('-interlace');
     DefaultJpgConvertOptions.Add('jpeg');
     DefaultJpgConvertOptions.Add('-define');
     DefaultJpgConvertOptions.Add('jpeg:optimize-coding=on'); //
     DefaultJpgConvertOptions.Add('-define');
     DefaultJpgConvertOptions.Add('jpeg:dct-method=float');
     DefaultJpgConvertOptions.Add('-alpha');
     DefaultJpgConvertOptions.Add('Remove');
     DefaultJpgConvertOptions.Add('-background');
     DefaultJpgConvertOptions.Add('rgb(255,255,255)');
     DefaultJpgConvertOptions.Add('-monitor');

     if (not FileExistsUTF8(ItogRootPath())) then CreateDirUTF8(ItogRootPath());

     //DeleteDirectory();
end;



end.

