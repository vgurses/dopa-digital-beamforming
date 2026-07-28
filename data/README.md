# Data directory (intentionally empty in the code repository)

The measurement data is distributed through a separate Zenodo record under
CC BY 4.0, because it is too large to keep in version control:

    Zenodo data record: #TODO data DOI

Download the three archives from that record and unzip them here so this
directory contains:

    data/
    ├── fig4_beamforming_20221209_meas2/     266deg.csv … 274deg.csv
    ├── noise_spectra_20221119/              10deg.csv, edfa.csv, noise.csv
    └── channel_characterization_128ch/      File_1.csv … File_128.csv

Every script in this repository resolves its input relative to this directory.
