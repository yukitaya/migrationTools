#!/usr/bin/perl

#ペインレス移行ツールで移行されたメールの件数をカウントするツール
#Ver 1.0
#アカウント情報CSVの設定を参照して、対象のホームディレクトリにある.migration_fdr_progressの内容をコンマ区切りで標準出力します
#
#使用方法： 
#  　1. アカウント情報CSVファイルを用意
#    2. ツールの引数にアカウント情報CSVファイルを指定
#    3. 標準出力をファイルにリダイレクト
#    　　ex) ./countMigratedMails.pl [account CSV] > countMigratedMails.csv
#    4. エラーの場合は /mnt/storage/workdir/tools/logs/_countMigratedMails_error.txt に出力
#

use strict;
use warnings;

my $accountSourceFile;
my $accountLine;
my $accountCSV;
my @account;
my $migratedConf;
my $CSV;

#実行権限チェック
my $runner = getpwuid($>);
if($runner ne "webmail"){
    print "Need to run with webmail\n";
    exit 1;
}


#アカウントCSVを開く

$accountSourceFile = $ARGV[0];
open(ACCSV, $accountSourceFile) or die("Cannot open $accountSourceFile directory");

print "account,mbox,total,migrated\n";
    while($accountLine = <ACCSV>){
        $accountLine =~ s/"//g;
        @account = split(/,/, $accountLine);
#print "account,mbox,total,migrated\n";
        makecsv($account[0])
    }
close (ACCSV);


# ファイルの作成

sub makecsv{
        $migratedConf = `/webmail/tools/userhome @_`."/.migration_fdr_progress";

        if(open(CONF, "<$migratedConf")){
#            print "account,mbox,total,migrated\n";
            $_ = <CONF>;
            $_ =~ s/\t/,/g;
            print "@_,$_";
        } else {
            open(FH, ">> /mnt/storage/workdir/tools/logs/_countMigratedMails_error.txt");
            print FH "Cannot open @_\n";
            close(FH);
        }
        close(CONF);
}
exit 0;
