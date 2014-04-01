#!/usr/bin/env perl
#############################################################################################################################################################
#                                                                                                                                                           #
#                   FORTI PARSER v1.03                                                                                                                      #
#                                                                                                                                                           #
# Codé par Mathieu GAMIN                                                                                                                                    #
#                                                                                                                                                           #
# Ce script a pour but de créer une matrice de flux au format .csv à partir d'un fichier de configuration FortiGate.                                        #
#                                                                                                                                                           #
# Il a été créé et testé pour un FortiGate 3600 sous Forti OS v.4 MR2 Patch7 sans VDOM.                                                                     #
# Il ne gère pas les commentaires car ceux-ci peuvent être multilignes.                                                                                     #
#                                                                                                                                                           #
# perl fortiparser.pl [FICHIER SOURCE] [FICHIER DESTINATION]                                                                                                #
#                                                                                                                                                           #
#                                                                                                                                                           #
#       A faire :                                                                                                                                           #
#           -Tester la présence de flux dans le fichier                                                                                                     #
#           -Tester la version du Firmware                                                                                                                  #
#           -Implémenter des entrées et sorties par défaut                                                                                                  #
#           -Implémenter une sortie autre que le fichier                                                                                                    #
#           -Implémenter la gestion de filtres                                                                                                              #
#           -Coder un comportement pour les fichiers des autres versions de firmware                                                                        #
#           -Coder le comportement en cas de présence de VDOMs                                                                                              #
#                                                                                                                                                           #
#       Changelog v1.03:                                                                                                                                    #
#           -Correction de l'affichage demandant un fichier source une deuxième fois                                                                        #
#       Changelog v1.02:                                                                                                                                    #
#           -Possibilité de spécifier les fichiers d'entrée et de sortie si ce n'est pas fait en argument lors du lancement du script                       #
#       Changelog v1.01:                                                                                                                                    #
#           -Support de "set status" dans les règles firewall                                                                                               #
#                                                                                                                                                           #
#############################################################################################################################################################



#############
# Fonctions #
#############

sub rendre_lisible #retourne une chaîne sans guillemet ou espace disgracieux
{
    $temp = $_[0];
    $temp =~ s/"//g;
    $temp =~ s/ +/ /g;
    $temp =~ s/ $//g;
    return $temp;
}

sub creer_flux #Créer un tableau associatif à partir d un tableau de lignes de configurations
{
    my @tab = @_[0];
    my %flux;
    my $i = 0;
    while(defined($tab[0][$i]))
    {
        if($tab[0][$i] =~ /edit (\d*)$/){ $flux{"id"}=&rendre_lisible($1);}
        if($tab[0][$i] =~ /set srcintf (.*)$/){ $flux{"srcintf"}=&rendre_lisible($1);}
        if($tab[0][$i] =~ /set dstintf (.*)$/){ $flux{"dstintf"}=&rendre_lisible($1);}
        if($tab[0][$i] =~ /set srcaddr (.*)$/){ $flux{"srcaddr"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set dstaddr (.*)$/){ $flux{"dstaddr"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set action (.*)$/){ $flux{"action"}=&rendre_lisible($1); } #"set action" n'est pas défini lors des refus de flux (valeur par défaut "deny") mais c'est une valeur obligatoire
        if($tab[0][$i] =~ /set utm-status (.*)$/){ $flux{"utmstatus"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set label (.*)$/){ $flux{"label"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set schedule (.*)$/){ $flux{"schedule"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set service (.*)$/){ $flux{"service"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set av-profile (.*)$/){ $flux{"avprofile"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set webfilter-profile (.*)$/){ $flux{"webfilterprofile"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set ips-sensor (.*)$/){ $flux{"ipssensor"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set application-list (.*)$/){ $flux{"applicationlist"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set profile-protocol-options (.*)$/){ $flux{"profileprotocoloptions"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set logtraffic (.*)$/){ $flux{"logtraffic"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set nat (.*)$/){ $flux{"nat"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set ippool (.*)$/){ $flux{"ippool"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set poolname (.*)$/){ $flux{"poolname"}=&rendre_lisible($1); }
        if($tab[0][$i] =~ /set status (.*)$/){ $flux{"status"}=&rendre_lisible($1); } #"set status" n'est pas défini lorsque paramétré sur sa valeur par défaut (enable) mais c'est une valeur obligatoire

        #Les commentaires pouvant être multilignes, un code un peu plus travaillé doit être mis en place
        #if($policy[$index][$i] =~ /set comments (.*)$/){ $flux{"comments"}=&rendre_lisible($1); }
        $i++;
    }
    return %flux;
}

#############
# Prérequis #
#############

#Définition des fichiers à manipuler

$saisie1 = $ARGV[0];
$saisie2 = $ARGV[1];

if(!$saisie1) { print "Merci de spécifier un fichier source : "; chomp($saisie1 = <STDIN>);}
if(!$saisie2) { print "Merci de spécifier un fichier destination : "; chomp($saisie2 = <STDIN>);}

open(CONF, "<$saisie1") or die ("Erreur lors de l'ouverture du fichier : $!");  #Ouvre le fichier de configuration en lecture
open (CSV, ">$saisie2") or die ("Erreur lors de l'ouverture du CSV : $!");      #Ouvre le CSV en écriture (écrasement)

############
#   Main   #
############

#Recupération des lignes des flux firewall
while(<CONF>){
    if (/^config firewall policy$/../^end$/)
    {
        push(@firewall, $_);
    }
}

#Création de la table de tables de règles à partir des flux firewall
foreach $line (@firewall)
{
    if ($line =~ /edit [0-9]+$/)
    {
        if(defined($index)){$index++;}else{$index=0;}
    }
    push @{$policy[$index]}, $line;
}

#Génération du CSV
print CSV "ID,Status,Source interface,Destination interface,Sources addresses,Destination addresses,Services,Action,Logging,Schedule,Label,NAT,IP pool,Pool name,UTM-status,IPS-sensor,Webfilter-profile,AV-profile,Application-list,Profile-protocol-option\n"; #",Comment" à ajouter éventuellement
my $index = 0;
while(defined($policy[$index]))
{
    %f = creer_flux($policy[$index]);
    print CSV "$f{id}";
    if($f{status}) {print CSV ",$f{status}"} else {print CSV ",enable";}; #"set status" n'est pas défini lorsque paramétré sur sa valeur par défaut (enable) mais c'est une valeur obligatoire
    print CSV ",$f{srcintf}";
    print CSV ",$f{dstintf}";
    print CSV ",$f{srcaddr}";
    print CSV ",$f{dstaddr}";
    print CSV ",$f{service}";
    if($f{action}) {print CSV ",$f{action}"} else {print CSV ",deny";}; #"set action" n'est pas défini lors des refus de flux (valeur par défaut "deny") mais c'est une valeur obligatoire
    print CSV ",$f{logtraffic}";
    print CSV ",$f{schedule}";
    print CSV ",$f{label}";
    print CSV ",$f{nat}";
    print CSV ",$f{ippool}";
    print CSV ",$f{poolname}";
    print CSV ",$f{utmstatus}";
    print CSV ",$f{ipssensor}";
    print CSV ",$f{webfilterprofile}";
    print CSV ",$f{avprofile}";
    print CSV ",$f{applicationlist}";
    print CSV ",$f{profileprotocoloptions}";

    #Les commentaires pouvant être multilignes, un code un peu plus travaillé doit être mis en place dans la fonction creer_flux{}
    #print CSV ",$f{comments}";

    print CSV "\n";

    $index++;
}

#Cloture

close(CONF);    #Ferme le fichier
close(CSV);     #Ferme le CSV
exit;
