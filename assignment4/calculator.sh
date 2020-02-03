#!/bin/sh
# This script was generated using Makeself 2.3.0

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="3585088958"
MD5="09eac6ea8727c5051a2ffc3a42b2f932"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"; export USER_PWD

label="Extracting calculator"
script="echo"
scriptargs="The initial files can be found in the newly created directory: calculator"
licensetxt=""
helpheader=''
targetdir="calculator"
filesizes="4021"
keep="y"
nooverwrite="n"
quiet="n"
nodiskspace="n"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    echo "$licensetxt"
    while true
    do
      MS_Printf "Please type y to accept, n otherwise: "
      read yn
      if test x"$yn" = xn; then
        keep=n
	eval $finish; exit 1
        break;
      elif test x"$yn" = xy; then
        break;
      fi
    done
  fi
}

MS_diskspace()
{
	(
	if test -d /usr/xpg4/bin; then
		PATH=/usr/xpg4/bin:$PATH
	fi
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd $@
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.3.0
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet		Do not print anything except error messages
  --noexec              Do not run embedded script
  --keep                Do not erase target directory after running
			the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the extracted files to the current user
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory
                        directory path can be either absolute or relative
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
	test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n 532 "$1" | wc -c | tr -d " "`
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				else
					test x"$verb" = xy && MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" = x"$crc"; then
				test x"$verb" = xy && MS_Printf " CRC checksums are OK." >&2
			else
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2;
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    else

		tar $1f - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=y
verbose=n

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 40 KB
	echo Compression: gzip
	echo Date of packaging: Thu Jan 30 18:41:39 CST 2020
	echo Built with Makeself version 2.3.0 on linux-gnu
	echo Build command was: "./makeself/makeself.sh \\
    \"--notemp\" \\
    \"../../questions/Functional_Programming-adts-code_haskell_autograded-calculator/calculator\" \\
    \"../../questions/Functional_Programming-adts-code_haskell_autograded-calculator/clientFilesQuestion/calculator.sh\" \\
    \"Extracting calculator\" \\
    \"echo\" \\
    \"The initial files can be found in the newly created directory: calculator\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"y" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
	echo archdirname=\"calculator\"
	echo KEEP=y
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5\"
	echo OLDUSIZE=40
	echo OLDSKIP=533
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n 532 "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n 532 "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
	shift
	;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir=${2:-.}
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir=$TMPROOT/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -title "$label" -e "$0" --xwin "$initargs"
                else
                    exec $XTERM -title "$label" -e "./$0" --xwin "$initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp $tmpdir || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n 532 "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 40 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
	MS_Printf "Uncompressing $label"
fi
res=3
if test x"$keep" = xn; then
    trap 'echo Signal caught, cleaning up >&2; cd $TMPROOT; /bin/rm -rf $tmpdir; eval $finish; exit 15' 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace $tmpdir`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 40; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (40 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | eval "gzip -cd" | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(PATH=/usr/xpg4/bin:$PATH; cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi
if test x"$keep" = xn; then
    cd $TMPROOT
    /bin/rm -rf $tmpdir
fi
eval $finish; exit $res
‹     í:ksÛ8’ùÌ_Ñ«\­¥X¤~e½›©•%Úæ•#yE9¹ÔT*¢HHÂ˜"´$hGssÿıº’¢d{2™={®î„šŒ) ÑèúÀj¼zöÖÄvrtD['GÍòß¼½j·OO°ÿä°Õ|G¯^ ¥‰ôb€WOJñõÕÿ·f5$KdãşšÇM´€6ö·šG;ı¿¤şİ%ó­yò|ú?><|Jÿ'íö–ş[ÇÍö+hîôÿì/–"–0B#°ÎcoÁîE|Õ€M½4”ï=Õ,ä"é²f<
n]Çâ,N¬¤Ü¿íÎ™Û†*ÍÃ¡%‹åª˜zÅ'XÖ3cËÁé)8¨Öô¯wP"EQ’†úƒC?µ‚D¨¸÷ŞÎÓÈ—\D•L6'*N‘‰ûxt‡<°
T§"î„!xñ„ËØ‹W4ìèÑZ_ı!¾ë˜%,¾c	¸éDÆŒ%á[æP9ĞÚÏk<Æd×ıï`òÒ‹‚I
™wW&¨ZPäòŸY0BJ Y_Ä1óå%(øÚîú¸—aŠ˜×¨Âÿ±2C]Ù¯üNä’/Ø7±›¿û‚Gß¦ıÍ¯bÏUöÙ0x„.%òt
u+÷s3[[Á;Ğ=Ô‚%ó˜G¸GN$×ÈÜ?—»KK-m5¨àZu‰ÿµ?Ãş>öh¯{°Úƒ_½¯{õÕ^şfXt‰~Äh#"Jó¸`‘bá1¨&mQ„qÂ[ `GÌdG(EÍÁ£kDùl9gH-bSø1›ŒR¯çŸûëO³¢D‘NÍòçB$ªÍzd¶H1(—29ë³IÒ~¤ºğ¾B5³XÁ„V7Æš)%~M³Ö€a”l%çJğŒ„·-Ã*§ÀÍŒXs²vvÄ‰Â‚œ	–‡$™/ùÚªú¿D#|Ò0¸¶HBÈ¿oÛ³ŞN!“šº/Ø»‡ƒ{µ|U™m8Œ
ú7møå—¬§¥{Z,øÑŒâ”!³KIªd^ÕıZ­U4¯zÕÔŸhÕ75Ü!`ll~Er±3}rÇ’Vã€=äŒøò[ÅÄVîIüvÑ×Îûş3˜b(ÄmªP!ÍFÆûzå)aôÛÆ÷æ„!=)bË÷&^øâù_»}|°®ÿZ-ÌÿÚG­“]ş÷-Âît;yX›„A{SŒM¦Õ²šVÓHVš"O6FˆKî…˜âˆŸp`È],ƒi,€Òöoë&ä)›Ó"ë¼çr¥|0`‰ó¥ÜXÿsô>	ú“¡İé½·­E`ÌÅ‚-½Ù&'s)—Éi£1C´éÄòÅ"ûLÑ4¼fÛœ¯‚Ø{3/X0#ä>‹’-aœ¹½ƒ|Äœòp=|åtí¾k^*ç"ŞaGu	TÔ§\Vâ?V†d_=û{ö—(Dï±\Å|6—eŒmÜ/qú(Ô™ˆWkdc’ò00åjYfÆå´†Á¾b|0‘Æ¾fˆ”·¤ò æ–Òx×²ZMå0ÉBû<ÉQ<ÎÕŸÄ¾AL-1xæB©ÆNÂÂ¤@Ó°%‹‚Âf&¤ÍŞÁ¡uş3ü2ËùÍĞ‹fi®×K/¹eaˆÂhêÀLRvå5ÌµÅš4Bq“ı\â\ú"`f".L´â§˜É°ŞÌ-‡¬Xş5äãYşYÚYO@lî‰ßeş“6¯Ê®§f”öÀlî›Bm¬k¦œÓVÀ|ÔŒe‚Ã	˜´%ó_ïÌşoRM&Ì˜¡!pät…æê*Á}ˆ¿C&¬ìì[[µ¬`ãÕ®ıOÿ(l­¼Eø\k|#ş¶Ëç¿í:ÿ98ŞÅÿi¯a4ç	P$€{/gEÁq¿…+˜1ŒXf˜¬`OY
&\î¯×àbÔÅ’x±ÂâV s*0÷îLÖ<ğÓ‹¢'hü‘Pê*ó…-Äu¡Íî¨n`iNĞ˜ºÏ1ørD—cR>°HÄú°bGrë°,Ò‚SÄFşİ	ÎH¬¹öMÚÌE<k°ˆl~²ı_DS>Kc…¶aàlLİEˆ1¤Èk1¹G¯Ï§ÜßÓ9º>H"o™Ì…"^Q‹ÜÄ…Ob«³†‰s¬÷‘ªzæìÁ$Å7$X" K½T‚¸š	ÓbF®‹üJGùœ%–’c–Oœ*%åËB(³u`µ7:#Ê5Â•‰®ûÈlşÅl·6†)Pœ`ğßš…İ?%¦J¿<‚ß sKw˜X˜¹h`íø+Xl+OT1¶È>´ÚmRÍÆƒB&™D(Kö/æ"M2›@có¢Bbh{ˆ]ò)ñf2ÂñPÜ[JR9Z¢«e4nJPÄÂTW¥JùZc*DcâÅøïg”
ÁBwbÍ~V
>‰iõujSÄ>&Í™­f>™¢¤šH 4—LZÓÖáÄŸN'oÑIúÁÑÛédê¿6™r|Øn5›Şæâß±dC¯Ôø…(©¢”Íğ$•Ô¯Õa†Ê¥èÛT>ÅL—½î¸÷¸’x'—9æYñ-jio×ÖaÊ¿äš>E›_à>Ñn‰ˆˆDdû`Un1wdZ²¬æikÑY/%O rÇDõMpÒœ( ]¦Œp¿âzqYÚ?âˆlš†jëÉ{æİR“.‰9Ó¢°ËX[‘	{:Jè­	Û²Üe†´›©0*PÉ¹'Á‹™""³Ö|7 ¶*³fòâ£y.x’P
–wP3
ÙaN÷ãgÚ-œó€åILCow^˜2µK”„kªHk,A#®ÿü/ÂeS¡/Ô¥Gy.ytUØ4f¡˜”Ğee?Í`RĞÕÅ9±éD¹‹á^mRÅéÅe—~N9’"4óKOÎqR²J°”4Ñİäv¦\5¦¾1ùçÜ=çF±™÷Ç˜¸*ë¹¦‚Z×<¦­€´¦Dö4\…Ê¢ƒŠ"£4ÑëÅşmË—iœ9´ÒŒ¦ÈT±5³'¤è#2+î‰$šz
üàíqñãëÛã/Ç‡j­‚Ü'¡»ßÄ®4ª*dÁµøyä‡i×6?6Hš)øûs„•İ ´KCt‘(áˆİ£®<qYÈ¤1´Y­«"ÚeêP‚Îcœ©*”SÈTˆvÉüÿgÏ|ÿÿkç''îÿ›‡»üÿ%Z7?ozp¾U¿¦NƒîÄPÙIz`ÆcŸ¤2O\É‹Ó¼:Ğ±•GtÓE)YR×'|¸ı©4" Ÿ­ò”º
zKcBÕÂR_*: ê\Ÿ<ùr:×•MZ0yj¨ƒ7°IU¢Â€&‡~`A§é1“^Y½‰¸£¡L
Ùé	†^î³º.QBÄGhÊ‹fIúš"\Ô=I•õ%¸bI9%ÈfúlMLFBAÒ÷“aX“”§›Îk .„
Áhş,ÆÀ”rÏ°(•©É%f
ûŒ«é ,I{`H0r ¥µdÁg¤ÑŠ8A*VEÆ)¦M‚®štµ³’b€äŞTªJ	(SyOF‘ÙØ:1Xbu€¦“yEÚĞ]§£KÇwp>úØÚ€ß×ÃÁ§g÷àìŒ.mè®?‹Ë\®zöĞ…N¿‡½ıÑĞ9»†®Qé¸8³¢:ıO`ÿÇõĞv]Áy}å 2Ä>ìôGíÖÁéw¯nzNÿ¢ˆ úƒ‘qå¼wF6ÔÕ¢§ÁàŞÛÃî%şìœ9WÎè“ZïÜõi­óÁĞèÀug8rº7W!\ß¯®ÄVÏq»Wç½İ³pu\ìvîeçêj“Kcğ±o‰ô2‹pfÃ•Ó9»²i!ÅdÏÚİq³şê¢à¼«ºá^Û]?P6òÒ~ªg8]û7„ƒĞë¼ï\ kÕoHUÒ½Úï‰dƒ{sæœÑÍÈ†‹Á §äìÚÃÍÜ¿ÂÕÀUÂºqíºÑëŒ:jaD’Âaü>»q%3§?²‡Ã›ë‘3è×P½Q*Hc§ö”p}bmÄ?R’’}>^ÚØ?$y*IuH.J¬;*ƒáz(À‘±æúöÅ•sa÷»6ËGÇµk¨*Ç% G-‹ÊÇ5oË¤"¤ÊPŸ%ƒ­+E‚sŞ‡ÈÎ€Qõ®“™‰Y÷2·µÿ.“éòÙŞ~ı†øßlo¿ÿj¶wñÿßõÊÎ=»*zøşj—­ÿ_<ÿıg~ş;Şÿ¶wï_PÿW|òŒà[şÿøè`Ûÿ·wşÿeš¾¦Ï.èªôP‹^,Õéq“~áX§×Tú‹nakÙCFƒÎ õÃ.ıZK=‡Âl¦’û_€>eïàXö°QeîÔYµÿY+=—tçâ~ó¥¤:²/¿€T¿yiWHÖo +Õ
=|LèĞß‡ _‹gm¼­zjÃ0Mø„Õ£®‰ª?Q×9c!–H))TPĞXˆL³'¹	êZéí›b_u¾ƒ4Â°Ê#¬_õ‚«–KPõ—!Ÿiÿ?ş°óŸvûdÛÿ“KØíÿh#`Í½)Ì˜$s^x·tœ¾~oñ'ÃÀ- ÎYfXqGÛèÔÃÃÇœÂ¶WxÊ-Ğ\c„˜Ç4ast´\OÕ·úgŒJôš›…*‹hŸªË>µD¼PàJt`È{ºĞåa êh]_æà¢!›J…ZŸ¸xñ,Õ×Ô(Ï—°ŸÒÏDßMôÛ6#¿¶ïë06ÇµoÆ½Ë‚@D{¦ä;B~K—2^È3Ò @—¨NÔ¢c¡ˆî$åyÔË8¬=1Q¸™Lê¹€Fb¦ëê»f£ëU‡G$ƒ˜©ËPOÉ¢~Ó={¸zÊ%)Œ×,ŠEvy‰:†¢£,–è›şÉJËB³nº¤gatµ£¨£šü–À2F$=Š%©¼©h÷^Ù¯d İ¬e_­ÚÖË~iæ­ò-BjÓtşCqD
ytøUÒ©Qq²˜\ªÄİË)Œ•‘à± z3ºKQê˜«³¨ÅRª°ğW!ÖXŸN±7’VMó•Íü!GFõT÷‘%z‹]5‘â5©]\ìbœ½bk+[q††;¦‰&¼Õ<îC‹ÄRËLÍÏgfÏŠ³™±~ŠŒÊ¶ÇhX×©Ì,ß¨œÂªè:/Ä)äè:xÇú¶i6÷9”€ÈBCáÊ™(Ìê`’îZ¹Ì¶‚I}
<Nµ7Éü
=¹óéRÑÚš»¶k»¶k»¶k»¶k»¶k»¶k»¶k»¶k»¶k»¶kÿjûoâøâ¿ P  