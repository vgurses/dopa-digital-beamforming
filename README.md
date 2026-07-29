# DOPA — digital beamforming on a 128-element silicon photonic optical phased array

Analysis and figure-generation code for:

> V. Gurses, D. Sarkar, A. Khachaturian, R. Fatemi, A. Hajimiri,
> "A large-scale integrated optical phased array with digital beamforming,"
> *Scientific Reports* (2026), under revision.
> Preprint (original title): https://doi.org/10.21203/rs.3.rs-9466036/v1

The chip is a 128-element optical phased array receiver in which every element
has its own balanced coherent receiver and is digitized independently, so
beamforming is performed entirely in software on the recorded per-element
amplitude and phase — no on-chip phase shifters are used.

## Companion data record

This repository contains **code only**. The measurement data it consumes is
deposited alongside this code in the same CaltechDATA record, under CC BY 4.0:

> CaltechDATA record: https://doi.org/10.22002/bzrn9-4xa02

To run anything here, download the three data archives from that record and
unzip them into `data/` so the tree looks like:

```
data/
├── fig4_beamforming_20221209_meas2/     266deg.csv … 274deg.csv
├── noise_spectra_20221119/              10deg.csv, edfa.csv, noise.csv
└── channel_characterization_128ch/      File_1.csv … File_128.csv
```

All scripts use paths relative to their own directory, so run the notebooks
from `python/` and the MATLAB scripts from `matlab/`.

## What produces which figure

| Figure | Script | Input |
|---|---|---|
| Fig. 3d–f — LO leakage, CMRR and noise floor across all 128 channels | `matlab/dopa_cleaned.m`, or `python/channel_snr_cmrr.py` | `data/channel_characterization_128ch/` |
| Per-channel signal, noise floor, NEP and optical sensitivity | `python/channel_characterization.ipynb` | `data/channel_characterization_128ch/` |
| Fig. 4a — channel phase vs. illumination angle | `python/figure4_beamforming.ipynb` | `data/fig4_beamforming_20221209_meas2/` |
| Fig. 4b — phase histogram for CH1 at 4° | `python/figure4_beamforming.ipynb`, cross-checked with `python/phase_histogram.ipynb` | same |
| Fig. 4c — normalized per-channel amplitude heatmap | `python/figure4_beamforming.ipynb` | same |
| Fig. 4d — digitally reconstructed far-field patterns | `python/figure4_beamforming.ipynb` | same |
| Noise-floor / shot-noise analysis (Methods) | `matlab/noiseMaker.m` + `matlab/spectrumRead.m` | `data/noise_spectra_20221119/` |

`python/figure4_beamforming.ipynb` is the script that generated the published
Figure 4. The MATLAB files are the original implementation of the same
pipeline and are included for provenance.

`matlab/dopa_cleaned.m` generates Figure 3d–f. `python/channel_snr_cmrr.py`
is a port of it, provided so the figure can be reproduced without a MATLAB
license. Both print:

```
LO leakage   median   -81.78 dBm
CMRR         median    57.44 dB
noise floor  median  -118.90 dBm/Hz
SNR (0 dBm)  median   120.78 dB
sensitivity  median  -120.78 dBm/Hz
```

`matlab/legacy/dopa_cleaned_original.m` is the version that produced the
originally submitted figure, kept for provenance. Its header lists the four
corrections made since.

`python/channel_characterization.ipynb` covers the same input data and derives
the noise floor, noise equivalent power, photocurrent and optical sensitivity.
Its noise-floor convention — a single point at 292,839 Hz — is the one Fig. 3f
uses.

## Layout

```
python/
  figure4_beamforming.ipynb      Figure 4 (a–d) end to end
  channel_snr_cmrr.py            Figure 3 (d–f); Python port of matlab/dopa_cleaned.m
  phase_extraction.ipynb         per-angle phase/amplitude extraction, writes the .mat phase matrix
  phase_histogram.ipynb          single-pair phase-difference histogram and statistics
  channel_characterization.ipynb 128-channel traces → signal, noise floor, NEP, optical sensitivity

matlab/
  dopa_cleaned.m    Figure 3 (d–f): LO leakage per channel, CMRR histogram, noise-floor histogram
  phaseMaker.m      driver: loops over illumination angles, calls phaseCalc, plots amplitudes/phases/array factor
  phaseCalc.m       per-file DSP core (bandpass → Hilbert → phase/amplitude, amplitude gating)
  Process.m         single-file inspection: raw traces, spectra, filtered signals, phase differences
  histogram_2CH.m   two-channel phase-difference histogram
  noiseMaker.m      noise-floor comparison across receiver / EDFA / dark spectra
  spectrumRead.m    helper: read a capture and return its single-sided spectrum
  phasePlotter.m    replot channel phases from a saved .mat phase matrix
  DOPABoard.m       serial control of the TIA motherboard (quad enable, channel mux, gain select)
  legacy/           earlier versions, kept for provenance; not used for the published figures
                    (includes dopa_cleaned_original.m, the pre-correction Fig. 3 script)

processed/
  20221209_meas2.mat, 20221214.mat, 20221214_10us.mat
                    13×6 matrices of extracted per-channel phase (degrees), one row per illumination angle
```

## How the Fig. 3 quantities are defined

`dopa_cleaned.m` (and its Python port) works from two numbers per channel, both
read off the spectrum-analyzer trace: the peak power at the LO tone, and the
noise floor, taken as the median of the trace. The trace is 1001 points and the
tone occupies only a few of them, so the median is the level away from the
tone; a linear mean over the whole trace would be dominated by it. At 1 Hz RBW
that floor is a power spectral density in dBm/Hz directly.

The traces were taken with the LO on and no signal coupled to the antennas, so
the peak is residual LO leakage through the balanced detector. Normalized to
the highest LO tap level in the array, that is what Fig. 3d plots.

The LO tap photocurrent statistics used for that normalization are not in the
traces; they were recorded separately with `DOPABoard.m` in groups of four
channels and are inlined in the script as the `means`, `stddev` and `nsamp`
arrays.

Expected TIA output power follows from the LO tap level through the photodiode
responsivity, the transimpedance gain and the 50 Ω load. CMRR is the difference
between that and the measured leakage:

```
CMRR = 10·log10[ (R·P_LO·Z_T)² / (Z₀·P₀) ] − P_LO,leakage
```

with R = 0.67 A/W, Z_T = 5 kΩ, Z₀ = 50 Ω and P₀ = 1 mW, so both terms are in
dBm and the difference is in dB. All four constants are inlined at the top of
the "Figures" section of the script.

Fig. 3f is the distribution of the noise floor in dBm/Hz. It is not a
signal-to-noise ratio: with no signal coupled, no SNR can be formed from these
traces.

## Signal processing pipeline

1. Read the digitizer capture (8 columns; 6 are receiver channels, sampled at 100 MS/s).
2. Bandpass around the 1 MHz LO phase-modulation tone (5–10 kHz bandwidth,
   6th-order Chebyshev-I, zero-phase via `sosfiltfilt`).
3. Hilbert transform each channel to get the analytic signal; take
   `arctan2` for instantaneous phase (unwrapped) and the envelope for amplitude.
4. Trim 50 µs from each edge to remove filter transients.
5. Form phase differences against the reference channel, gate on amplitude
   envelope so only high-SNR samples contribute, and take the median and spread.
6. Evaluate the array factor
   `AF(θ) = Σ_n exp(j·φ_n) · exp(j·n·k·d·sin θ)` with `d = 10.85 µm`,
   `λ = 1555.23 nm`, to synthesize the beam.

## Environment

Python ≥ 3.10 with the packages in `requirements.txt`:

```bash
pip install -r requirements.txt
jupyter lab
```

MATLAB R2021b or newer (uses `bandpass`, `hilbert`, `findpeaks`, `readmatrix`;
Signal Processing Toolbox required). `DOPABoard.m` additionally needs the
Instrument Control Toolbox and a Teensy 3.6 on the serial port.

## Notes and known quirks

- `phaseMaker.m` writes its output to `../processed/20221214_10us.mat`
  regardless of which campaign it read. The filename is historical; the
  contents correspond to whichever `filepath` was set at the top of the script.
- `phasePlotter.m` replots from `20221214_10us.mat`, which holds 13 illumination
  angles from the 2022-12-14 campaign. Those raw traces are not part of the
  deposited data record; the extracted phase matrix in `processed/` is included
  so the plot can still be reproduced.
- `figure4_beamforming.ipynb` uses only the first 20,000 samples (200 µs) of
  each 10 ms capture. The full captures are deposited unmodified.
- `matlab/legacy/` refers to campaigns that are not in the deposited data
  record; those paths are marked `_NOT_INCLUDED` in the source.
- `dopa_cleaned.m` uses `peaks` and `floor` as variable names, which shadow
  MATLAB built-ins inside that script. Harmless as written, but do not add
  calls to either built-in below their assignment.
- The data record includes five `retakes/` traces taken 2026-01-12 with a
  wider span and coarser resolution bandwidth than the main channel sweep.
  No script in this repository uses them; they are archived for completeness.

## License

MIT — see `LICENSE`. The companion measurement data is licensed CC BY 4.0.
