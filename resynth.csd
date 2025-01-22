<CsoundSynthesizer>
<CsOptions>
; Select audio/midi flags here according to platform
-odac  --limiter=0.95   ;;; realtime audio out, limit loud pops
;-iadc    ;;; uncomment -iadc if realtime audio input is needed too
; For Non-realtime output leave only the line below:
; -o lpfreson.wav -W ;;; for file output any platform
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 32
nchnls = 2
0dbfs  = 1

; Adjusted to accept dynamic input files from command line

instr 1
Sfile     strget SARGS, 1                ; Get the second argument (WAV filename) passed via the command line
ires      system_i 1,{{ lpanal -p50 -h200 -P50  -Q15000 -v1 }}, Sfile, strcat(Sfile, "_coef.lpc")

ilen      filelen Sfile                     ; length of soundfile
prints    "%s = %f seconds\\n", Sfile, ilen ; print filename and length
aref      diskin Sfile, 1                   ; don't play this, but use as amplitude reference

ktime     line 0, p3, p4
krmsr,krmso,kerr,kcps lpread ktime, strcat(Sfile, "_coef.lpc")
krmso    *= .000007                        ; scale amplitude
asig      buzz krmso, kcps, int(sr/2/kcps), 1  ; max harmonics without aliasing
aout      lpfreson asig, p5                   ; Pole file not supported!!
abal      balance2 aout, aref                 ; use amplitude of diskin as reference       
          outs abal, abal

endin
</CsInstruments>

<CsScore>
; sine
f1 0 4096 10 1

; Example score events (use whatever you like for p4, p5)
i 1 0 2.8 1 1
i 1 4 2.8 1 0.5
i 1 8 2.8 2.756 1
i 1 12 2.8 2.756 2

e
</CsScore>
</CsoundSynthesizer>
