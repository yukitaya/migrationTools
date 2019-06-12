#!/usr/bin/perl

#複数のグループメンバーをインポート
# Ver: 1.1
#
#使用方法：
#    1. グループを作成 
#  　2. CSVを作成し、ファイル名をグループ代表アドレスとする
#    3. CSVファイルを任意のディレクトリ(ex. groupmember)に格納
#    4. ツールの引数に任意のディレクトリ(ex. groupmember)を指定して実行
#      $ ./groupImport.pl groupmember/ 
#


use strict;
use warnings;
use File::Copy;
use File::Basename;

my $script = basename($0);
my $sourceDir;
my $domain;
my $gmember;
my $groupName;
my $csv;

#実行権限チェック
my $runner = getpwuid($>);
if($runner ne "webmail"){
    print "Need to run with webmail\n";
    exit 1;
}


$sourceDir = $ARGV[0];

# ディレクトリオープン
opendir(DIRHANDLE, $sourceDir) or die("Cannot open $sourceDir directory");

# ディレクトリエントリの取得
foreach(readdir(DIRHANDLE)){

    next if /^$script/;     # 自身のファイルをスキップ
    next if /^\.{1,2}$/;    # '.'や'..'をスキップ
    next if /^_error.txt/;  # _error.txtをスキップ

    print "\nGroup is $_\n";
# CSVをインポート
    ($domain = $_) =~ s/^(.*)$/$1/;
    system("/webmail/tools/grpfwdmgr -u $_ -F -C imp -i $sourceDir/$_");
}
# ディレクトリクローズ
closedir(DIRHANDLE);

exit 0;
