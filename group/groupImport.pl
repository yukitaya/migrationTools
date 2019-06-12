#!/usr/bin/perl

#グループの複数ドメインインポート
# Ver: 1.0
#
#使用方法： 
#  　1. CSVを作成し、ファイル名を[domain].csvとする
#    2. [domain].csvを任意のディレクトリ(ex. groupdir)に格納
#    3. ツールの引数に任意のディレクトリ(ex. groupdir)を指定して実行
#      $ ./groupImport.pl groupdir/
#


use strict;
use warnings;
use File::Copy;
use File::Basename;

my $script = basename($0);
my $sourceDir;
my $domain;

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

# CSVをインポート
    ($domain = $_) =~ s/^(.*)$/$1/;
    print "\n";
    print "Domain is $domain\n";
    print "Source is $sourceDir$_\n";
    system("/webmail/tools/groupimport -C -D $domain $sourceDir/$_");

}
# ディレクトリクローズ
closedir(DIRHANDLE);

exit 0;
