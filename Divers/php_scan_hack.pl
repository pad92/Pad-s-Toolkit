#!/usr/bin/perl -w

# Parse le contenu de fichier a la recherche de traces d'un webshell ou de chaines connues

use strict;

my @patterns = (
    'BXcfTYewQ',
    '/etc/passwd',
    '/etc/shadow',
    '7b1dWyLJ0ih63T6P/6GG5RpgWpFPFW2dVkTF',
    '9f681f3de8d1d1f5b469c2e0025b7fe3', # header add php SBA
    'CRYPT.obfuscate',
    'JGxsbGxsbGxsbGxsPSdiYXNlNjRfZGVjb2RlJzs=',
    'PCEtLTlmNjgxZjNkZThkMWQxZj', # header SBA
    'QAACOzh3b3cKDQoNKC0KDScAQkoAAEhDT',
    'UnixCr3w',
    'Web Shell',
    '[S][h][a][u][n]',
    'irc.allnetwork.org',
    'milw0rm',
    'str_rot13',
    'tmpdir.md5', # content injecte SBA
    'uggc://',
    'base64_decode',
    'eval',
    'gzinflate',
    '\\x65\\x76\\x61\\x6C', #eval
    '\x62\x61\x73\x65\x36\x34\x5F\x64\x65\x63\x6F\x64\x65' # base64_decode
    '\x65\x76\x61\x6C\x28\x67\x7A\x69\x6E\x66\x6C\x61\x74\x65\x28\x62\x61\x73\x65\x36\x34\x5F\x64\x65\x63\x6F\x64\x65\x28', #eval(gzinflate(base64_decode
    '\x67\x7A\x69\x6E\x66\x6C\x61\x74\x65', #gzinflate
);

sub analyze
{
    my $filepath = shift;
    my $FD;

    open FD, "<$filepath", or die "Unable to open $filepath : $!";
    while (<FD>) {
        my $line = $_;
        my $pat;
        foreach (@patterns){
            $pat = $_;
            if ($line =~ /$pat/) {
                print "[!!] Detected pattern $pat in text file $filepath\n";
                return; # Sig found go next
            }
        }
    }
}

sub dig
{
    my $entry=shift;
    my $prot_dir=quotemeta($entry);
    if ( -d $entry ) {
        foreach (glob ($prot_dir."/*")) {
            dig($_) ;
        }
    } else {
        analyze($entry);
    }
}

foreach (@ARGV) {
    dig($_);
}

