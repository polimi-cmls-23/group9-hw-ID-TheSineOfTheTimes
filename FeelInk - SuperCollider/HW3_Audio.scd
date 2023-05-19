// HW3 CMLS 2023
// Group : The Sine Of The Times
// This file implement the audio part of the system with SuperCollider language.

// Tutorial :
// 1 -> Execute 'BOOT BLOCK'
// 2 -> Execute 'MAIN BLOCK'
// 3 -> Execute 'COMMUNICATION BLOCK'
// 3 -> Wait for messages from processing files ( as debugging tool can be also executed 'EXTRA BLOCK' in the bottom)

// BOOT BLOCK (This would work only for windows. The aim of the block is to be sure that the output audio of SC is the input of VB-Cable. You can see how to do it for MacOS or Linux here : https://doc.sccode.org/Reference/AudioDeviceSelection.html)
(
o = Server.default.options;
o.outDevice_("Windows DirectSound : CABLE Input (VB-Audio Virtual Cable)");
Server.default.reboot;
)
// MAIN BLOCK
(
// Loading external sounds
~natural = Array.new;
~folder = PathName.new("./Natural Sounds/Sounds");


~folder.entries.do({
	arg path;
	~natural = ~natural.add(Buffer.read(s,path.fullPath));
});

// First Settings
~bpm = 60;
~firstPlay = true;
d = 1;
t = TempoClock.new;
t.tempo_(~bpm/60);

// All synthdefs
// Used for external natural sounds
SynthDef.new(\natural,{
	arg amp=0, out =0,start= 0,end, rate = 0.5,buf;
	var sig, ptr;
	ptr = Phasor.ar(0, BufRateScale.kr(buf)*rate, start, end);
	sig = BufRd.ar(2,buf,ptr);
	sig = sig*amp;
	Out.ar(out,sig);
}).add;

// Transition Sound
SynthDef(\transitionNoisy, {arg out = 0, freq = 440, amp = 0.2, pan = 0.5;
	var snd, env;
	env = Env.perc(0.02, 0.1).kr(doneAction: 2);
	snd = Mix(LFPulse.ar(
		freq: freq * [1, 5/2],
		iphase: 0.0,
		width: 0.5,
		mul: amp));
	snd = snd * env ;
	Out.ar(out, Pan2.ar(snd, pan*Rand.new(-1,2)) );
//By Bruno Ruviaro
//https://github.com/brunoruviaro/SynthDefs-for-Patterns/blob/master/noisy.scd
}).add;

// Violin Sound, used only for sad macro-emotions
SynthDef(\violinSad, {
	| midinote=60, gate=1, amp=0.8 |
	var env = EnvGen.kr(Env.asr(0.1, 1, 0.1), gate, doneAction:2);
	var sig = VarSaw.ar(
		midinote.midicps,
		width:LFNoise2.kr(1).range(0.2, 0.8)*SinOsc.kr(5, Rand(0.0, 1.0)).range(0.7,0.8))*0.25;
	sig = sig * env * amp;
	sig = FreeVerb.ar(sig,0.5);
	Out.ar(0, sig!2);
//by nicolaariutti
//http://sccode.org/1-5as
}).add;

// Marimba Sound, used only for happy macro-emotions
SynthDef(\marimbaHappy, {
	//Kalimba based on bank of ressonators
    |out = 0, freq = 440, amp = 0.1, mix = 0.1, relMin = 2.5, relMax = 3.5|
    var snd;
    // Basic tone is a SinOsc
    snd = SinOsc.ar(freq) * EnvGen.ar(Env.perc(0.005, Rand(relMin, relMax), 1, -8), doneAction: 2);
    // The "clicking" sounds are modeled with a bank of resonators excited by enveloped pink noise
    snd = (snd * (1 - mix)) + (DynKlank.ar(`[
        // the resonant frequencies are randomized a little to add variation
        // there are two high resonant freqs and one quiet "bass" freq to give it some depth
        [240*ExpRand(0.9, 1.1), 2020*ExpRand(0.9, 1.1), 3151*ExpRand(0.9, 1.1)],
        [-7, 0, 3].dbamp,
        [0.8, 0.05, 0.07]
    ], PinkNoise.ar * EnvGen.ar(Env.perc(0.001, 0.01))) * mix);
    Out.ar(out, Pan2.ar(snd, 0, amp));
//By Nathan Ho aka Snappiz
//http://sccode.org/1-51l
}).add;

// Harpsichord Sound, used only for Love emotion
SynthDef(\harpsichordLove, {
	|amp=1, freq=440, pan=0, atk=0, rel=0, trig= 1, maxdelaytime= 0.2, decaytime= 7, coef= 0.1|
	var env, sig, delay;
	env = EnvGen.kr(Env.linen(atk, decaytime, rel), doneAction: Done.freeSelf);
	sig = PinkNoise.ar(amp); //Can use white noise here, but Pink is more realistic
	delay = freq.reciprocal;
	sig = Pluck.ar(sig, trig, maxdelaytime , delay , decaytime , coef ) //fundamental
	+ Pluck.ar(sig, trig, maxdelaytime , delay/2 , decaytime , coef ); //octave higher
	Out.ar(0, Pan2.ar(sig*2 , pan));
//Harpsichord based on Pluck Ugen
//By Zé Craum
}).add;

// Harpsichord Sound, used only for Fourious macro-emotions
SynthDef(\pianoForious, {
	//Piano synth based on Mda Plugin
    |out = 0, freq= 440, gate= 1, vel= 80, decay= 0.8, release= 0.8, hard= 0.4, velhard= 0.8, muffle= 0.8, velmuff= 0.8, velcurve= 0.8, stereo= 0.2, tune= 0.5, random= 0.1, stretch= 0.1, sustain= 0, mul= 1, add= 0, amp = 0.5|
    var snd;
    snd = MdaPiano.ar(freq, gate, vel, decay, release, hard, velhard, muffle, velmuff, velcurve, stereo, tune, random, stretch, sustain, mul, add);
    snd = snd * EnvGen.kr(Env.asr(0, 1, 0.1), gate, doneAction: 2);
	snd = JPverb.ar(snd);
    Out.ar(out, snd * amp);
}).add;

// SineWave Sound, used only for Fourious macro-emotions
SynthDef(\sineForious, {
//Crude simulation of old sinusoidal generators - with vibrato and high noise floor
	|amp=0.1, freq=440, pan=0, atk = 0.001, sus = 2, rel = 0.01,
	vrate = 2, vdepth = 0.002, vdelay = 0.1, vonset = 0, vrateVariation = 0.1, vdepthVariation = 0.1 /*vibrato arguments*/,
	noiseAmp = 0.2|
	var env, sig, vibrato;
	env = EnvGen.kr(Env.linen(atk, sus, rel), doneAction:2);
	vibrato = Vibrato.kr(DC.kr(freq), DC.kr(vrate), DC.kr(vdepth), DC.kr(vdelay), DC.kr(vonset), DC.kr(vrateVariation), DC.kr(vdepthVariation));
	sig = SinOsc.ar(vibrato);
	sig = sig + PinkNoise.ar(noiseAmp);
	sig = sig * env;
	Out.ar(0, Pan2.ar(sig, pan, amp));
//By Zé Craum
}).add;

// Arp sound, used for Happy and Sad macro-emotions and Disgust emotion
SynthDef(\arp, { |freq = 440, sustain = 1, amp = 1 |
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: 2);
	Out.ar(0, sig ! 2)
}).add;

// Pad sound, practically used in all emotion except for Happy macro-emotions
 SynthDef(\padCalm, {
	arg atk = 0.3, dur = 3, rel = 0.5, crv = -2, gate = 1, amp = 0, pitch = 48,pitch2 = 60, pw1 = 0.2, tune1 = -0.006, lffreq1 = 0.01, lf1lo = 0.14, lf1hi = 0.2, tune2 = 0.006, lffreq2 = 2, lf2lo = 0.74, lf2hi = 0.8, tune3 = -12.06,ffreq = 200, mixrev = 0.5, room = 2 ;
	var env, osc1, freq1, freq2, sig, lfo1, osc2, lfo2,sus, freq3, osc3, sig2;
	sus = dur-atk;
	env = EnvGen.ar(Env.asr(atk,1,rel,crv), gate, doneAction:2);
	lfo1 = SinOsc.kr(lffreq1).range(lf1lo,lf1hi);
	lfo2 = SinOsc.kr(lffreq2).range(lf2lo,lf2hi);
	freq1 = (pitch+tune1).midicps;
	osc1 = Pulse.ar(freq1, lfo1);
	freq2 = (pitch+tune2).midicps;
	osc2 = Saw.ar(freq2, lfo2);
	freq3 = (pitch+tune3).midicps;
	osc3 = LFTri.ar(freq3, lfo1);
	sig = Mix.ar( [osc1*0.333, osc2*0.333,osc3*0.333]);
	sig = RLPF.ar(sig,ffreq,1);
	sig = FreeVerb.ar(sig,mixrev,room);
	sig2 = DelayC.ar (sig, 0.2, 0.05);

	Out.ar(0,[sig,sig2]*env*amp);
}).add;


// Function called every time emotion is changed
~newEmotion = {

	// Stop all synths
	if( ~firstPlay == true,{
        ~firstPlay = false;
    },{
        e.stop;
		p.stop;
		w.stop;
    });

	fork {
		"Changing emotion...".postln;
		// Changing Transition
		o = Task({
			loop {
				[60, 58, 59, 56, 57, 54, 55,52,53,50,51,48,49,46,47,44,45].do({ |midi|
					Synth(\transitionNoisy, [freq: midi.midicps, amp: 0.2, sustain: 0.1]);
					Synth(\transitionNoisy, [freq: (midi-12).midicps, amp: 0.2, sustain: 0.1]);
					0.30.wait;
				});
			}
		}).play;
		2.wait;
		o.stop;
		// Switch with the macro-emotion/emotion as entries
		// "d" is the emotion variable, if is :
		// 1 -> Happy Emotions (Amusement, Joy, Pleasure, Contentment)
		// 2 -> Calm Emotions (Interest, Relief, Admiration, Pride)
		// 3 -> Sad Emotions (Sadness, Guilt, Regret ,Disappointment)
		// 4 -> Fourious Emotions (Fear, Hate, Anger)
		// There are also two configuration for the case of Love and Disgust emotion. These are not used for the moment but they were implemented in order to follow the future idea to make system able to distinguish between several single emotions.
		// 5 -> Love
		// 6 -> Disgust
		// Otherwise -> Reset (no sound)
		switch (d,
			1, {// HAPPY EMOTIONS (Amusement, Joy, Pleasure, Contentment )
				// New Bpm
				~bpm = 100;

				// Restart Clock
				t = TempoClock.new;
				t.tempo_(~bpm/60);

				// Sound
				k.free;
		        k = Synth.new(\natural,[\buf, 0,\amp,1,\end,~natural[0].numFrames-1  ] );

				p = Pbind(
					\instrument, \arp,
					\midinote, Pseq([48,  [64,67],
						48, [64,69],
						42, [65,69],
						42, [67,71] ], inf),
					\dur, Pseq([0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25], inf)
				).play(t);

				e = Pbind(
					\instrument, \marimbaHappy,
					\midinote, Pseq([84,84,79,79], inf),
					\dur, Pseq([3.5,0.5,0.5,0.5], inf)
				).play(t);
				\bellHappy

			},
			2, { // CALM EMOTIONS (Interest, Relief, Admiration, Pride)
				// New Bpm
				~bpm = 60;

				// Restart Clock
				t = TempoClock.new;
				t.tempo_(~bpm/60);

				// Sound
		        k.free;
		        k = Synth.new(\natural,[\buf, 1,\amp,1,\end,~natural[0].numFrames-1  ] );

				e = Pbind(
					\instrument, \padCalm,
					\dur, Pseq([4,4,4,4],inf),
					\harmonic, Pexprand(1, 88,inf).round.trace,
					\pitch, Pseq([[60,64,67],
						[60,64,69],
						[60,65,69],
						[62,67,71]],inf),
					\atk, Pwhite(1,2,inf),
					\rel, 1,
					\amp, 0.5
				).play(t);

				p = Pbind(
					\instrument, \arp,
					\midinote, Pseq([72,  60, 64, 67], inf),
					\dur, Pseq([0.25,0.25,0.25,0.25], inf)
				).play(t);

			},
			3, { // SAD EMOTIONS (Sadness, Guilt, Regret ,Disappointment)
				// New Bpm
				~bpm = 40;

				// Restart Clock
				t = TempoClock.new;
				t.tempo_(~bpm/60);

				// Sound
		       k.free;
		        k = Synth.new(\natural,[\buf, 2,\amp,1,\end,~natural[0].numFrames-1  ] );

				e = Pbind(
					\instrument, \padCalm,
					\dur, Pseq([4,4,4,4],inf),
					\harmonic, Pexprand(1, 88,inf).round.trace,
					\pitch, Pseq([[72,63,67],
						[72,63,67],
						[72,65,68],
						[72,65,68]],inf),
					\atk, Pwhite(1,2,inf),
					\rel, 1,
					\amp, 0.5
				).play(t);

				p = Pbind(
					\instrument, \violinSad,
					\midinote, Pseq([[75,79] ,[74,77], [72,75], [72,75]], inf),
					\dur, Pseq([0.5,0.5,0.5,0.5], inf)
				).play(t);
			},
			4, { // FOURIOUS EMOTIONS ( Fear, Hate, Anger)
				// New Bpm
				~bpm = 100;

				// Restart Clock
				t = TempoClock.new;
				t.tempo_(~bpm/60);

				// Sound
		        k.free;
		        k = Synth.new(\natural,[\buf, 3,\amp,1,\end,~natural[0].numFrames-1  ] );

				e = Pbind(
					\instrument, \padCalm,
					\dur, Pseq([8],inf),
					\harmonic, Pexprand(1, 88,inf).round.trace,
					\pitch, Pseq([60],inf),
					\atk, Pwhite(1,2,inf),
					\rel, 1,
					\amp, 0.5
				).play(t);

				p = Pbind(
					\instrument, \pianoForious,
					\midinote, Pseq([[74,  75],[73,  74]], inf),
					\dur, Pseq([1,1,], inf)
				).play(t);
				w = Pbind(
					\instrument, \sineForious,
					\midinote, Pseq([[86,  87],[85,  86]], inf),
					\dur, Pseq([1,1,], inf)
				).play(t);
			},
			5, { // LOVE
				// New Bpm
				~bpm = 100;

				// Restart Clock
				t = TempoClock.new;
				t.tempo_(~bpm/60);

				// Sound
		        k.free;
		        k = Synth.new(\natural,[\buf, 4,\amp,1,\end,~natural[0].numFrames-1  ] );

				e = Pbind(
					\instrument, \padCalm,
					\dur, Pseq([4,4,4,4],inf),
					\harmonic, Pexprand(1, 88,inf).round.trace,
					\pitch, Pseq([[62,66,69],
						[67,71,74],
						[69,73,76],
						[71,74,78]],inf),
					\atk, Pwhite(1,2,inf),
					\rel, 1,
					\amp, 0.5
				).play(t);

				p = Pbind(
					\instrument, \harpsichordLove,
					\midinote, Pseq([[62] ,[67], [69], [71]], inf),
					\dur, Pseq([1,1,1,1], inf)
				).play(t);
			},
			6, { // DISGUST
				// New Bpm
				~bpm = 40;

				// Restart Clock
				t = TempoClock.new;
				t.tempo_(~bpm/60);

				// Sound
		        k.free;
		        k = Synth.new(\natural,[\buf, 3,\amp,1,\end,~natural[0].numFrames-1  ] );

				e = Pbind(
					\instrument, \padCalm,
					\dur, Pseq([4,4,4,4],inf),
					\harmonic, Pexprand(1, 88,inf).round.trace,
					\pitch, Pseq([[72,73],
						[82,83,],
						[75,76],
						[81,82]],inf),
					\atk, Pwhite(1,2,inf),
					\rel, 1,
					\amp, 0.5
				).play(t);

				p = Pbind(
					\instrument, \arp,
					\midinote, Pseq([[75] ,[76], [81], [82]], inf),
					\dur, Pseq([0.1,0.1,0.1,0.1], inf)
				).play(t);


			},
			{t.stop;k.free;});
		};
};

)
// COMMUNICATION BLOCK
// Enable communication with processing files
(
a = OSCdef.new(\notam, c={arg msg;d=msg[1]; ~newEmotion.value;} , '/x', recvPort:57000)
)

// EXTRA BLOCK
// used as a debugger for trying the system
(
d=3;
~newEmotion.value;
)
