;csound lpfreson.csd input_file.wav
sr = 44100
kr = 4410
ksmps = 10
nchnls = 2

; by Menno Knevel - 2021, modified for flexible input

instr 1
    ; Get input file name
    Sinput_file = p4
    prints "Processing file: %s\n", Sinput_file

    ; Generate the coefficient file name based on the input file
    SinputNoExt strcpy Sinput_file
    ilen strrindex SinputNoExt, "."
    if (ilen > 0) then
        Scoef_name strsub SinputNoExt, 0, ilen
    else
        Scoef_name = SinputNoExt
    endif
    Scoef_file sprintf "%s_coef.lpc", Scoef_name

    ; Run lpanal to generate coefficient file
    Scmd sprintf "lpanal -p50 -h200 -P50 -Q15000 -v1 %s %s", Sinput_file, Scoef_file
    ires system_i 1, Scmd
    if (ires != 0) then
        prints "Error: lpanal failed to generate coefficient file.\n"
        goto end
    endif

    ; Get length of input file
    ilen filelen Sinput_file
    prints "%s = %f seconds\n", Sinput_file, ilen

    ; Read input file
    aref diskin Sinput_file, 1 ; don't play this, but use this as an amplitude reference

    ktime line 0, p3, ilen  ; Use file length for duration
    krmsr, krmso, kerr, kcps lpread ktime, Scoef_file
    krmso = krmso * 0.000007 ; scale amplitude

    asig buzz krmso, kcps, int(sr/2/kcps), 1 ; max harmonics without aliasing
    aout lpfreson asig, 1 ; Use fixed ratio of 1
    abal balance2 aout, aref ; use amplitude of diskin as reference

    outs abal, abal

end:
endin

; Score
f1 0 4096 10 1 ; sine
i1 0 -1 "input_file" ; Run for the duration of the input file
e