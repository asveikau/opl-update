#!/bin/sh

if [ x`which gmake 2>/dev/null` != x ]; then
   MAKE=gmake
else
   MAKE=make
fi

mkdir -p PSX PS2

if [ ! -d out/POPS ]; then
   # Copy POPS into POPS-tmp.  Temp location followed by mv is for atomicity if the script is
   # interrupted.
   rm -rf out/POPS-tmp
   mkdir -p out/POPS-tmp
   cp submodules/POPS-binaries/* out/POPS-tmp
   cp third-party/popstarter/* out/POPS-tmp
   mv out/POPS-tmp out/POPS
fi

$MAKE -C submodules/cue2pops clean all

bufsz=20

cd PSX
for cuefile in *.cue; do
   echo $cuefile
   gameid=""
   grep ^FILE\ \" "$cuefile" | sed s/^FILE\ \"// | sed s/\"\ BINARY.*$// | while read binfile; do
      # Hacky way to parse gameid straight from the ISO, without proper parsing.
      # One advantage is this doesn't require loopback mounting (so you don't need to be root, and it's
      # quite portable.)
      gameid="`head -c $(($bufsz*1024*1024)) "$binfile" | strings | grep BOOT | sed -z s/.*cdrom:'\\\\'// | sed s/\;.*$// `"
      gameid="`echo $gameid | sed s/\ .*//`"
      if [ "$gameid" != "" ]; then
         echo $gameid
         filename=../out/POPS/"$gameid.`echo $cuefile | sed s/cue$/VCD/`"
         if [ -f "$filename" ]; then
            break;
         fi
         ../submodules/cue2pops/cue2pops "$cuefile" "$filename"
         break;
      fi
   done
done
cd ..

$MAKE -C submodules/iso2opl clean all

for isofile in PS2/*.iso; do
   echo $isofile
   gameid="`head -c $(($bufsz*1024*1024)) "$isofile" | strings | grep BOOT2 | sed -z s/.*cdrom0:'\\\\'// | sed s/\;.*$//`"
   gameid="`echo $gameid | sed s/\ .*//`"
   if [ "$gameid" != "" ]; then
      echo $gameid
      if [ `ls out/ul*.$gameid.* 2>/dev/null | wc -l` != 0 ]; then
         continue
      fi
      submodules/iso2opl/iso2opl "$isofile" out "`echo $isofile | cut -d / -f 2- | sed s/\.iso$// | fold -w 32 | head -n 1`" DVD
   fi
done
