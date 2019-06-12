#!/usr/bin/perl

# painless_migrationの設定ファイルを自動生成
# ツールの引数に common_domainを指定する
#  Ex.) ./makePainlesConf.pl common_domain

$domainSourceFile = $ARGV[0];
open(DMCSV, $domainSourceFile) or die("Cannot open $domainSourceFile directory");

while($domainLine = <DMCSV>){
    $domainLine =~ s/"//g;
    @domain = split(/,/, $domainLine);

    my @popIp = ('172.27.41.19','172.27.41.20','172.27.41.24','172.27.41.25');
    $number = int rand(4);

    &addpdmn($popIp[$number],$domain[0]);
}

sub addpdmn{
            my $ip = $_[0];
            my $dmn = $_[1];
            my $dmnconf = "/webmail/modules/painless_migration/etc/painless_migration_$dmn.conf";
            if (!-e "$dmnconf"){
                    open (CNF, "> $dmnconf") || die "$!\n";
                    print CNF "Enable=1\n";
                    print CNF "SrcDomain=$dmn\n";
                    print CNF "DestDomain=$dmn\n";
                    print CNF "MigratePassword=1\n";
                    print CNF "MigrateMail=1\n";
                    print CNF "AuthConnType=4\n";
                    print CNF "AuthPort=110\n";
                    print CNF "DownloadConnType=4\n";
                    print CNF "AuthHost=$ip\n";
                    print CNF "DownloadHost=$ip\n";
                    print CNF "DownloadPort=110\n";
                    print CNF "FullEmailLogin=1\n";
                    print CNF "KeepOnServer=1\n";
                    close (CNF);
            }
            print "Created $dmnconf\n";
}
