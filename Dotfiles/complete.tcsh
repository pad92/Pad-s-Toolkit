##
# $Date: 2011-01-19 16:08:55 +0100 (Wed, 19 Jan 2011) $
# $Id: complete.tcsh 191 2011-01-19 15:08:55Z pascal $
#

  # tcsh
  complete {fg,bg,stop}   c/%/j/ p/1/"(%)"//
  complete kill           'c/%/j/' 'c/-/S/'
  complete chgrp          'p/1/g/'
  complete chown          'p/1/u/'
  complete find           'p/1/d/' 'n/-user/u/' 'n/-group/g/'
  complete cd             'C/*/d/'
  complete rmdir          'C/*/d/'
  complete lsd            'C/*/d/'

  complete git p/1/"(add am apply archive bisect branch config checkout clone commit  \
        count-objects describe diff fetch fsck gc grep init ls-files log merge mv pull push \
        prune rebase repack reset revert rm remote show show-branch status tag version)"/
  complete cvs 'c/--/(help help-commands help-synonyms)/' \
        'p/1/(add admin annotate checkout commit diff \
        edit editors export history import init log login \
        logout rdiff release remove rtag status tag unedit \
        update watch watchers)/' 'n/-a/(edit unedit commit \
        all none)/' 'n/watch/(on off add remove)/'
  complete svn p/1/"(add blame cat checkout cleanup commit copy delete \
        diff export help import info list lock log merge mkdir move propdel \
        propedit propget proplist propset resolved revert status switch  \
        unlock update )"/

  if ( -f /etc/debian_version ) then
    set ipackages = `dpkg --get-selections | awk '{print $1}'`
    set apackages = `apt-cache search '' | awk '{print $1}'`
    complete dpkg 'n/-L/$ipackages/'
    complete apt-get \
        'c/--/(build config-file diff-only download-only \
        fix-broken fix-missing force-yes help ignore-hold no-download \
        no-upgrade option print-uris purge reinstall quiet simulate \
        show-upgraded target-release tar-only version yes )/' \
        'c/-/(b c= d f h m o= q qq s t x y )/' \
        'n/{source,build-dep}/x:<pkgname>/' \
        'n/{remove}/`dpkg -l|grep ^ii|awk \{print\ \$2\}`/' \
        'n/{install}/`apt-cache pkgnames | sort`/' \
        'C/*/(update upgrade dselect-upgrade source \
        build-dep check clean autoclean install remove)/'

    complete apt-cache \
        'c/--/(all-versions config-file generate full help important \
        names-only option pkg-cache quiet recurse src-cache version )/' \
        'c/-/(c= h i o= p= q s= v)/' \
        'n/{search}/x:<regex>/' \
        'n/{pkgnames,policy,show,showpkg,depends,dotty}/`apt-cache pkgnames | sort`/' \
        'C/*/(add gencaches showpkg stats dump dumpavail unmet show \
        search depends pkgnames dotty policy )/'
  endif

  # signal names
  # also note that the initial - can be created with the first completion
  # but without appending a space (note the extra slash with no
  # append character specified)
  complete kill 'c/-/S/' 'p/1/(-)//'

  # use available commands as arguments for which, where, and man
  complete which 'p/1/c/'
  complete where 'p/1/c/'
  complete man 'p/1/c/'

  # aliases
  complete alias 'p/1/a/'
  complete unalias 'p/1/a/'

  # variables
  complete unset 'p/1/s/'
  complete set 'p/1/s/'

  # environment variables
  complete unsetenv 'p/1/e/'
  complete setenv 'p/1/e/'
  #(kinda cool: complete first arg with an env variable, and add an =,
  # continue completion of first arg with a filename.  complete 2nd arg
  # with a command)
  complete env 'c/*=/f/' 'p/1/e/=/' 'p/2/c/'

  # limits
  complete limit 'p/1/l/'

  # key bindings
  complete bindkey 'C/*/b/'

  # groups
  complete chgrp 'p/1/g/'

  # users
  complete chown 'p/1/u/'

  # sudo
  complete sudo 'n/-l/u/' 'p/1/c/'

  # You can use complete to provide extensive help for complex commands
  # like find.  
  # Please check your version before using these completions, as some
  # differences may exist.
  complete find 'n/-name/f/' 'n/-newer/f/' 'n/-{,n}cpio/f/' \
       'n/-exec/c/' 'n/-ok/c/' 'n/-user/u/' 'n/-group/g/' \
       'n/-fstype/(nfs 4.2)/' 'n/-type/(b c d f l p s)/' \
       'c/-/(name newer cpio ncpio exec ok user group fstype type atime \
       ctime depth inum ls mtime nogroup nouser perm print prune \
       size xdev)/' \
       'p/*/d/'

  # set up cc to complete only with files ending in .c, .a, and .o
  complete cc 'p/*/f:*.[cao]/'

  # of course, this completes with all current completions
  complete uncomplete 'p/*/X/'

  # complex completion for ln
  # In all cases, if you start typing, it completes with a filename
  # But if you complete without typing anything you get this:
  #   first argument:           adds "-s"
  #   arguments that follow -s: reminds you of which argument is expected
  complete ln 'C/?/f/' 'p/1/(-s)/' 'n/-s/x:[first arg is path to original file]/' 'N/-s/x:[second arg is new link]/'

  # set a printer list, for use with all print related commands
  set printerlist=(hp1 hp2 color)
  complete lp 'c/-d/$printerlist/'
  complete lpstat 'p/1/$printerlist/'
  complete lpq 'c/-P/$printerlist/'
  complete lpr 'c/-P/$printerlist/'
  complete enscript 'c/-d/$printerlist/'
