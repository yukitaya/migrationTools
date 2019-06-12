#!/usr/bin/perl

#アカウント単位で設定された隔離ポリシー設定を適用するツール
#Ver: 1.0
#アカウント情報CSVの設定を参照して、ユーザーの設定に適用します。
#１．アカウント情報CSVの隔離ポリシー設定を参照
#２．各ユーザーのホームディレクトリに設定ファイルを書き込む
#
#
#使用方法： 
#  　1. アカウント情報CSVファイルを用意
#    2. ツールの引数にアカウント情報CSVファイルを指定
#    　　ex) ./commtouchConf.pl [account CSV]
#
#

use strict;
use warnings;
use File::Copy;
use File::Basename;
use File::Path;
use Switch;

my $script = basename($0);
my $homeDir;
my $domainDir;
my $domainSourceFile;
my $accountSourceFile;
my $domainCSV;
my $filterFile;
my $domainFilterDir;
my @domain;
my $domainLine;
my $accountLine;
my $userId;
my $accountCSV;
my @account;
my $sourceDir;
my $domainName;
my $counter;
my $level;

#実行権限チェック
my $runner = getpwuid($>);
if($runner ne "webmail"){
    print "Need to run with webmail\n";
    exit 1;
}



#1. アカウントCSVを開く
#2. 隔離ポリシー設定の値を読み込む
#　　　　->　0:  高
#            10: 中
#            20: 低
#            30: 無
#3. 各IDのホームディレクトリに設定ファイルを書き込み
#


$accountSourceFile = $ARGV[0];

open(ACCSV, $accountSourceFile) or die("Cannot open $accountSourceFile directory");

    while($accountLine = <ACCSV>){
        $accountLine =~ s/"//g;
        @account = split(/,/, $accountLine);
        chomp @account;
        switch($account[22]){
            case 0 {$level = 3}
            case 10 {$level = 2}
            case 20 {$level = 1}
            case 30 {$level = 0}
            else    {print "Cannot get Quarantine policy\n";}
        }

        makeconf($account[0])
    }
close (ACCSV);


# ファイルの作成
# [userhome]/commtouch_setting.conf を作成し、Level を追記

sub makeconf{
        $homeDir = `/mailgates/tools/userhome @_`."/";
        if (!-d $homeDir) {
            eval {
              mkpath [$homeDir] or warn $!;
            };
            if ($@) {
              die $@;
            }
        }

        if (-d $homeDir) {
            if (!-e "$homeDir/commtouch_setting.conf"){
                open(FH, ">$homeDir/commtouch_setting.conf");
                $counter++;
                print FH "level=$level";
                close(FH);
                print "$counter: Set Commtouch Level High on $account[0]\n" if $level == 3;
                print "$counter: Set Commtouch Level Middle on $account[0]\n" if $level == 2;
                print "$counter: Set Commtouch Level Low on $account[0]\n" if $level == 1;
                print "$counter: Set Commtouch Level None on $account[0]\n" if $level == 0;
            } else {
                print "$homeDir"."commtouch_setting.conf already exist\n";
            }
        } else {
             open(FH, ">> /home/webmail/logs/_commtouchConf_error.txt");
             print "ディレクトリ$homeDirが存在しません。\n";
             print FH "$sourceDir."/".$domainName."/".$filterFile failed\n";
             close(FH);
            }
}

print "Total $counter accounts were set\n";

exit 0;
