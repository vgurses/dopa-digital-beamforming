# Data directory (intentionally empty in the code repository)

The measurement data is distributed through the CaltechDATA record that also
holds this code, under CC BY 4.0, because it is too large to keep in version
control:

    CaltechDATA record: https://doi.org/10.22002/bzrn9-4xa02

Download the three data archives from that record and unzip them here so this
directory contains:

    data/
    ├── fig4_beamforming_20221209_meas2/     266deg.csv … 274deg.csv
    ├── noise_spectra_20221119/              10deg.csv, edfa.csv, noise.csv
    └── channel_characterization_128ch/      File_1.csv … File_128.csv

Every script in this repository resolves its input relative to this directory.
