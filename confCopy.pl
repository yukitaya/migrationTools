#!/usr/bin/perl

#.forwardおよび.vacationをユーザーホームディレクトリへコピー
# Ver: 1.3
#
#使用方法： 
#  .forward 
#  　1. ユーザーを作成
#    2. .forward　を ユーザーIDにリネーム ->  adm
#    3. adm をforward/{domain}/ディレクトリに置く
#    4. コマンド引数にforwardディレクトリを指定して、コマンドを実行
#      $ ./fileCopy.pl forward 
#
#  .vacation
#  　1. ユーザーを作成
#    2. .vacation　を ユーザーIDにリネーム ->  adm
#    3. adm をvacation/{domain}/に置く
#    4. コマンド引数にvacationディレクトリを指定して、コマンドを実行
#      $ ./fileCopy.pl vacation


use strict;
use warnings;
use File::Copy;
use File::Basename;
use Digest::MD5 qw(md5 md5_hex md5_base64);

my $script = basename($0);
my $userDir;
my $sourceDir;
my $domainHome;
my $userId;
my $subDir;
my $domainName;
my $srcDigest;
my $dstDigest;
my $srcFile;
my $dstFile;
my $fileName;
my $counter;
my $type;

#実行権限チェック
my $runner = getpwuid($>);
if($runner ne "webmail"){
    print "Need to run with webmail\n";
exit 1;
}

#forwardもしくはvacationディレクトリ以外が指定されている場合は終了
$sourceDir = $ARGV[0];

if ($sourceDir =~ /forward/){
    $type = "forward";
}
elsif ($sourceDir =~ /vacation/){
    $type = "vacation";
} else {
    print "Forward or Vacation should be choosen.\n";
exit 2;
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


# ディレクトリオープン
opendir(SOURCEDIR, $sourceDir) or die("Cannot open $sourceDir directory");  # 引数のディレクトリを開く

# ディレクトリエントリの取得
foreach $domainName (readdir(SOURCEDIR)){
    next if $domainName =~ /^\.{1,2}$/;    # '.'や'..'をスキップ
    opendir(SUBDIR, $sourceDir."/".$domainName) or die("Cannot open $domainName directory");  # サブディレクトリを開く

        foreach $fileName(readdir(SUBDIR)){
        next if $fileName =~ /^\.{1,2}$/;    # '.'や'..'をスキップ
        $userId = basename($fileName, '.old'); #userIDのみ取り出す

# ユーザーホームディレクトリへコピー
            $userDir = `/webmail/tools/userhome $userId"@"$domainName`;

            $srcFile = "$sourceDir/$domainName/$fileName";
            if ($fileName =~ /\.old$/){
                $dstFile = "$userDir/.$type\.old";
            }else{
                $dstFile = "$userDir/.$type";
            }

            if (copy "$srcFile", "$dstFile"){
                $srcDigest = s_FileMD5($srcFile);
                $dstDigest = s_FileMD5($dstFile);
                if ($srcDigest = $dstDigest){
                    $counter++;
                    print "$counter:\n";
                    print "$srcDigest\t$srcFile\n$dstDigest\t$dstFile\n";
                    print "Copied $userId\@$domainName\n\n";
                }else{
                     print "MD5SUM is incorrect\n\n";
#                    open(FH, ">> /home/webmail/logs/_$type\_error.txt");
#                    print FH "Copy failed $userId\@$domainName\n";
#                    close(FH);
               }
            }else{
                 print "Failed $userId\@$domainName\n\n";
#                print "failed $userId\@$domainName\n";
#                open(FH, ">> /home/webmail/logs/_$type\_error.txt");
#                print FH "Copy failed $userId\@$domainName\n";
#                close(FH);
            }
        }
    closedir(SUBDIR);
   }

closedir(SOURCEDIR);

print "Total $counter files were copied\n";

exit 0;
