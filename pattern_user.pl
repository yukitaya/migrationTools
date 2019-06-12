#!/usr/bin/perl

#pattern.from[trust|bad].user を{userhome}/.libmg_data/へコピー
# Ver: 1.3
#
#使用方法： 
#  　1. ユーザーを作成
#    2. pattern_user/{domain} ディレクトリに pattern.from[trust|bad].userに "_{userid}"を付けてを置く -> ex). pattern.fromtrust.user_adm
#    3. pattern_userと同じディレクトリに本ツールを置き、引数にpattern_userディレクトリを指定してコマンドを実行
#      $ ./pattern_user.pl pattern_user/
#

use strict;
use warnings;
use File::Copy;
use File::Basename;
use File::Path;
use Digest::MD5 qw(md5 md5_hex md5_base64);

my $script = basename($0);
my $filterDir;
my $domainDir;
my $sourceDir;
my $domainName;
my $filterFile;
my $domainFilterDir;
my $srcDigest;
my $dstDigest;
my $srcFile;
my $dstFile;
my $counter;


#実行権限チェック
my $runner = getpwuid($>);
if($runner ne "webmail"){
    print "Need to run with webmail\n";
exit 1;
}

#md5sumのサブルーチン
sub s_FileMD5 {
        my $path = shift;
        my $file_md5;

        open(FPMD5, $path) || return undef;
        binmode(FPMD5);
        $file_md5 = Digest::MD5->new->addfile(*FPMD5)->hexdigest;
        close(FPMD5);

        return $file_md5;
}


# ソースディレクトリオープン
$sourceDir = $ARGV[0];
opendir(SOURCEDIR, $sourceDir) or die("Cannot open $sourceDir directory");  # 引数のディレクトリを開く

# ソースディレクトリからドメイン名を取得
foreach $domainName (readdir(SOURCEDIR)){
    next if $domainName =~ /^\.{1,2}$/;    # '.'や'..'をスキップ

# ドメインディレクトリからフィルタファイルを取得
    opendir(SUBDIR, $sourceDir."/".$domainName) or die("Cannot open $domainName directory");  # サブディレクトリを開く
    foreach $filterFile(readdir(SUBDIR)){
        next if $filterFile =~ /^\.{1,2}$/;    # '.'や'..'をスキップ
        $filterFile =~ /pattern.from(.*)user_(.*)$/;

# フィルタディレクトリの作成
# [userhome]/libmg_data/へコピー

        $filterDir = `/mailgates/tools/userhome $2"@"$domainName`."/".".libmg_data";

        if (!-d $filterDir) {
            eval {
              mkpath [$filterDir] or warn $!;
            };
            if ($@) {
              die $@;
            }
        }

        if (-d $filterDir) {
            $srcFile = "$sourceDir"."/"."$domainName"."/"."$filterFile";
            $dstFile = "$filterDir"."/"."pattern.from".$1."user";
            if (!-e "$dstFile") {
                if (copy "$srcFile", "$dstFile"){
                    $counter++;
                    print "$counter:\n";
                    $srcDigest = s_FileMD5($srcFile);
                    $dstDigest = s_FileMD5($dstFile);
                    if ($srcDigest = $dstDigest){
                        print "$srcDigest\t$srcFile\n$dstDigest\t$dstFile\n";
                        print "Copied pattern.from$1user of $2\@$domainName\n\n";
                    } else {
                        print "MD5SUM of $2@$domainName is incorrect\n";
                    }
                }else{
                     print "Failed $srcFile\n";
#                    open(FH, ">> /home/webmail/logs/_pattern_user_error.txt");
#                    print FH "$srcFile failed\n";
#                    close(FH);
                }
            } else {
                print "$dstFile already exists\n";
            }
        } else {
             print "failed $srcFile\n";
#            open(FH, ">> /home/webmail/logs/_pattern_user_error.txt");
#            print "ディレクトリ$filterDirが存在しません。\n";
#            print FH "$srcFile failed\n";
#            close(FH);
        }
    }
    closedir(SUBDIR);
}
closedir(SOURCEDIR);

print "Total $counter files were copied\n";

exit 0;
