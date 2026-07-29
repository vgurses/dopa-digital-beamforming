"""Channel characterization: LO leakage, CMRR and noise floor across all 128 channels.

Python port of ``matlab/dopa_cleaned.m`` (D. Sarkar), which generates
Figure 3d-f of:

    V. Gurses, D. Sarkar, A. Khachaturian, R. Fatemi, A. Hajimiri,
    "A large-scale integrated optical phased array with digital beamforming,"
    Scientific Reports (2026).

Input: ../data/channel_characterization_128ch/File_1.csv ... File_128.csv.
Keysight N9952A spectrum-analyzer traces, one per receiver channel, 1001 points
over a 10 kHz span at 1 Hz RBW and VBW, 0 dB input attenuation, preamp off,
positive-peak detector, no averaging.

The traces were recorded with the local oscillator coupled to the chip and NO
SIGNAL incident on the aperture, so the peak in each trace is the residual LO
tone at the balanced-detector output, not a received signal.

Provided so the figure can be reproduced without a MATLAB license. Verified
2026-07-28 to reproduce the MATLAB script line for line:

    LO leakage   median  -81.78 dBm
    CMRR         median   57.44 dB
    noise floor  median -118.90 dBm/Hz
    SNR (0 dBm)  median  120.78 dB
    sensitivity  median -120.78 dBm/Hz

Run from the ``python/`` directory:

    python channel_snr_cmrr.py
"""

import numpy as np
import matplotlib.pyplot as plt

DATA_DIR = "../data/channel_characterization_128ch"
N_CHANNELS = 128

# LO power per channel in microwatts, referred to the photodiodes, recorded
# separately with DOPABoard.m in groups of 4 channels.
#
# NOTE: the 99:1 monitor tap sits on the input waveguide, upstream of the 1:128
# splitter tree, so it cannot resolve channel-to-channel variation. The spread
# in this array is drift in the input LO over the ~2 h acquisition, mapped onto
# channel index because the channels were measured in sequence. It is used to
# normalise each channel's CMRR to the LO reading taken at the same time, which
# removes that drift; it is deliberately NOT used per channel anywhere else.
LO_TAP_MEAN = np.array([
    3.444, 3.402, 3.388, 3.420, 3.417, 3.450, 3.470, 3.462,
    3.508, 3.528, 3.400, 3.363, 3.433, 4.373, 3.558, 3.487,
    3.465, 4.137, 3.445, 3.397, 3.389, 3.384, 3.442, 3.450,
    4.259, 4.298, 4.784, 4.810, 4.790, 4.835, 4.370, 4.513,
])

RESPONSIVITY = 4e-6 / 6e-6      # A/W  (0.67)
TIA_GAIN = 5e3                  # ohm
Z0 = 50                         # ohm
MW = 1e-3                       # reference power for dBm
PS_REF = 1e-3                   # 0 dBm reference signal, optical, into one antenna


def read_trace(path):
    """Read a Keysight N9952A CSV export -> (frequency_Hz, power_dBm) arrays."""
    with open(path) as fh:
        lines = fh.readlines()
    start = next(i for i, line in enumerate(lines) if line.strip() == "BEGIN") + 1
    freq, power = [], []
    for line in lines[start:]:
        if line.strip() == "END":
            break
        parts = line.split(",")
        if len(parts) < 2:
            continue
        try:
            f, p = float(parts[0]), float(parts[1])
        except ValueError:
            continue
        freq.append(f)
        power.append(p)
    return np.array(freq), np.array(power)


def main():
    peaks = np.zeros(N_CHANNELS)
    floorlvl = np.zeros(N_CHANNELS)

    for k in range(1, N_CHANNELS + 1):
        _, power_dbm = read_trace(f"{DATA_DIR}/File_{k}.csv")
        peaks[k - 1] = np.nanmax(power_dbm)
        # Median of the trace in dB. The trace is 1001 points and the LO tone
        # occupies only a few of them, so the median is the level away from the
        # tone. A linear mean over the whole trace would be dominated by it.
        floorlvl[k - 1] = np.nanmedian(power_dbm)

    lo_w = np.repeat(LO_TAP_MEAN, 4) * 1e-6     # W per channel

    # Fig. 3e -- CMRR. The /MW is what makes the reference a level in dBm;
    # without it this is dBW and the result comes out 30 dB low.
    tia_out_dbm = 10 * np.log10((lo_w * RESPONSIVITY * TIA_GAIN) ** 2 / Z0 / MW)
    cmrr = tia_out_dbm - peaks

    # Fig. 3d -- LO leakage, normalised to the highest LO reading.
    # 10*log10 because lo_w is a power.
    lo_db = 10 * np.log10(lo_w)
    lo_leakage = peaks - (lo_db - lo_db.max())

    # Fig. 3f -- noise floor, and the sensitivity that follows from it.
    # A balanced pair fed by a 50:50 coupler gives a beat photocurrent of
    # amplitude 2*R*sqrt(Ps*PLO); through Rf that is a sinusoid of amplitude
    # 2*R*Rf*sqrt(Ps*PLO), whose RMS power into Z0 is V^2/(2*Z0).
    lo_ref = np.median(lo_w)
    sig_dbm = 10 * np.log10((2 * RESPONSIVITY * TIA_GAIN) ** 2 * PS_REF * lo_ref / (2 * Z0) / MW)
    snr = sig_dbm - floorlvl
    nesp = 10 * np.log10(PS_REF / MW) - snr     # noise-equivalent signal power, dBm

    print(f"LO leakage   median {np.median(lo_leakage):8.2f} dBm")
    print(f"CMRR         median {np.median(cmrr):8.2f} dB")
    print(f"noise floor  median {np.median(floorlvl):8.2f} dBm/Hz")
    print(f"SNR (0 dBm)  median {np.median(snr):8.2f} dB")
    print(f"sensitivity  median {np.median(nesp):8.2f} dBm/Hz")
    print(f"LO held at {lo_ref * 1e6:.2f} uW/channel; a 0 dBm signal into one "
          f"antenna appears at {sig_dbm:+.2f} dBm")
    print(f"{int(np.sum(np.abs(floorlvl - np.median(floorlvl)) <= 1))} of "
          f"{N_CHANNELS} channels lie within 1 dB of the median floor")

    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    axes[0].plot(np.arange(1, N_CHANNELS + 1), lo_leakage, "k*")
    axes[0].set_xlabel("Channel index")
    axes[0].set_ylabel("LO leakage (dBm)")
    axes[0].set_xlim(1, N_CHANNELS)
    axes[0].grid(alpha=0.3)

    axes[1].hist(cmrr, bins=np.arange(55, 68), color=(0, 0.4471, 0.7412))
    axes[1].set_xlabel("CMRR (dB)")
    axes[1].set_ylabel("Number of channels")
    axes[1].grid(alpha=0.3)

    axes[2].hist(floorlvl, bins=np.linspace(-119.5, -115.5, 13), color=(0, 0.4471, 0.7412))
    axes[2].set_xlabel("Noise floor (dBm/Hz)")
    axes[2].set_ylabel("Number of channels")
    axes[2].set_ylim(0, 64)
    axes[2].grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("figure3def.png", dpi=200)
    print("\nwrote figure3def.png")


if __name__ == "__main__":
    main()
