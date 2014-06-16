{
Asd,2014-6-16;
Compiled with fpc2.6.4 on Debian 7;
}
unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, IpHtml,   Forms,
  Controls, Graphics, Dialogs, ExtCtrls, ComCtrls, StdCtrls,regexpr,
  fphttpclient, LCLType,  Grids, fpjson,jsonparser,
  variants;

type

  { TMainForm }

  TMainForm = class(TForm)
    AppInfo_GroupBox1: TGroupBox;
    AppIco_Image1: TImage;
    LastPage_Button1: TButton;
    Button2: TButton;
    Upgrade_Button1: TButton;
    UpgradeLog_Memo1: TMemo;
    Install_Button1: TButton;
    Upgrade_GroupBox1: TGroupBox;
    Introduce_GroupBox1: TGroupBox;
    Introduce_Memo1: TMemo;
    Version_Label1: TLabel;
    Name_Label1: TLabel;
    Search_Result_ListView1: TListView;
    Search_Edit1: TEdit;
    Image1: TImage;
    PageControl: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    UpgradeDate_Label: TLabel;
    Developer_Label1: TLabel;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Install_Button1Click(Sender: TObject);
    procedure LastPage_Button1Click(Sender: TObject);
    procedure Search_Edit1UTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure Search_Result_ListView1SelectItem(Sender: TObject;
      Item: TListItem; Selected: Boolean);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }
type
  AppInfo=record         {Store app's info}
    name:string;         {Name of app}
    size:string;         {Size of app,like '3.14M'}
    version:string;      {Build version of app,an interger}
    {upgradeDate:string; {Date of the latest version}}
    superior:string;     {Developer level}
    description:string;  {Introduction of app}
    iconsurl:string;     {App's ico-url}
    packageName:string;  {PackageName of app,like 'com.tencent.mobileqq'}
    snippet:string;      {Sort Introduction}
  end;
const
  Maxload=20;            {The number of items that loaded in ListView every time}
var
  pageIndexNow:longint=1;
  itemLoaded:byte=0;     {The number of items that were loaded in ListView}
  Apps:array[0..Maxload] of AppInfo;
procedure search(page:byte);
var
  ResponseResult : ansistring;
  D_json,E_json,F_json:TJSONData;
  i:byte;
begin
  MainForm.Search_Result_listview1.Items.Clear;
  ResponseResult:=TFPCustomHTTPClient.SimpleGet('http://apps.wandoujia.com/api/v1/search/'+MainForm.Search_Edit1.Text+'?max='+inttostr(Maxload)+'&hasAd=0&start='+inttostr((page-1)*Maxload)+'&opt_fields=description,title,packageName,apks.size,icons.px68,apks.superior,snippet,apks.versionCode');
  D_json:=GetJSON(ResponseResult);
  E_json:=D_json.FindPath('appList');
  itemLoaded:= E_json.Count-1;
  for i:=0 to E_json.Count-1 do  {Loaded AppInfo to Structure }
  begin
       E_json:=D_json.FindPath('appList['+inttostr(i)+'].icons');
       E_json:=GetJSON(StringReplace(E_json.AsJSON,'[','',[rfReplaceAll]));
       F_json:=E_json.FindPath('px68');
       Apps[i].iconsurl:={F_json.AsJSON;}StringReplace(F_json.AsJSON,'\','',[rfReplaceAll]);
       Apps[i].iconsurl:={F_json.AsJSON;}StringReplace(Apps[i].iconsurl,'"','',[rfReplaceAll]);

       E_json:=D_json.FindPath('appList['+inttostr(i)+'].apks');
       E_json:=GetJSON(StringReplace(E_json.AsJSON,'[','',[rfReplaceAll]));

       F_json:=E_json.FindPath('versionCode');
       Apps[i].version:=StringReplace(F_json.AsJSON,'"','',[rfReplaceAll]);

       F_json:=E_json.FindPath('size');
       Apps[i].size:=StringReplace(F_json.AsJSON,'"','',[rfReplaceAll]);

       F_json:=E_json.FindPath('superior');
       Apps[i].superior:=StringReplace(F_json.AsJSON,'"','',[rfReplaceAll]);

       F_json:=D_json.FindPath('appList['+inttostr(i)+'].description');
       Apps[i].description:=StringReplace(F_json.AsJSON,'"','',[rfReplaceAll]);

       F_json:=D_json.FindPath('appList['+inttostr(i)+'].title');
       Apps[i].name:=StringReplace(F_json.AsJSON,'<em>','',[rfReplaceAll]);
       Apps[i].name:=StringReplace(Apps[i].name,'<\/em>','',[rfReplaceAll]);

       F_json:=D_json.FindPath('appList['+inttostr(i)+'].packageName');
       Apps[i].packageName:=StringReplace(F_json.AsJSON,'"','',[rfReplaceAll]);

       F_json:=D_json.FindPath('appList['+inttostr(i)+'].snippet');
       Apps[i].snippet:=StringReplace(F_json.AsJSON,'"','',[rfReplaceAll]);


       with MainForm.Search_Result_listview1.items.add do {Added AppInfo to the ListView}
       begin
            caption:=Apps[i].name;
            subitems.add(Apps[i].packageName);
            subitems.add(Apps[i].size);
       end;
  end;
end;
procedure LoadImageFromUrl(index:LongInt);
var
  ImageStream:TMemoryStream;
begin
  ImageStream:=TMemoryStream.Create;
  TFPCustomHTTPClient.SimpleGet(Apps[index].iconsurl,ImageStream);
  ImageStream.Position:=0;
  MainForm.AppIco_Image1.Picture.LoadFromStream(ImageStream);
  ImageStream.Free;
end;
procedure TMainForm.Image1Click(Sender: TObject);
begin
  halt;
end;

procedure TMainForm.Install_Button1Click(Sender: TObject);
begin
  {Download apk and install it}
end;

procedure TMainForm.LastPage_Button1Click(Sender: TObject);
begin
  if pageIndexNow=1 then
  begin
    ShowMessage('没有前一页了！');
    exit();
  end;
  dec(pageIndexNow);
  search(pageIndexNow);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  {Something got wrong,if there was 'with ... do..'}
  {Init ListView}
  Search_Result_ListView1.Clear;
  Search_Result_ListView1.Columns.Clear;
  Search_Result_ListView1.Columns.Add;
  Search_Result_ListView1.Columns.Add;
  Search_Result_ListView1.Columns.Add;
  Search_Result_ListView1.Columns.Items[0].Caption:='Name';
  Search_Result_ListView1.Columns.Items[1].Caption:='Package';
  Search_Result_ListView1.Columns.Items[2].Caption:='Size';
  Search_Result_ListView1.Columns.Items[0].Width:=200 ;
  Search_Result_ListView1.Columns.Items[1].Width:=200 ;
  Search_Result_ListView1.ViewStyle:=vsreport;
  Search_Result_ListView1.GridLines:=true;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  if itemLoaded<Maxload-1 then
  begin
    ShowMessage('没有后一页了！');
    exit();
  end;
  inc(pageIndexNow);
  search(pageIndexNow);
end;

procedure TMainForm.Search_Edit1UTF8KeyPress(Sender: TObject;
  var UTF8Key: TUTF8Char);
begin
   if UTF8Key=#13 {The key is 'Enter'} then
      begin
        search(1);
        pageIndexNow:=1;
      end;
end;

procedure TMainForm.Search_Result_ListView1SelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  if Selected=true then  {Load AppInfo To panel}
     begin
       LoadImageFromUrl(Item.index);
       Name_Label1.Caption:=Apps[Item.Index].name;
       Version_Label1.Caption:=Apps[Item.Index].version;

       if Apps[Item.Index].superior='1' then
          Developer_Label1.Caption:='优质开发者'
       else
          Developer_Label1.Caption:='普通开发者';

       Introduce_Memo1.Text:=Apps[Item.Index].description;
       {UpgradeLog_Memo1.Text:=Apps[Item.Index].;}
     end;
end;

end.

