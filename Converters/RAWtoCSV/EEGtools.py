import numpy as np
import mne

def decimate(raw, sfreq, decimation_factor, stim_name):
    
    """
    Decimate Raw data and display informations for validation.

    Parameters:
    -----------
    raw_path : str
        EEG data
    sfreq : int 
        Base sampling rate or frequency (Hz)
    decimation_factor : int
        Decimation factor, must be an integer and the result
        of the new frequency needs to be an integer too
    stim_name : str
        Stim channel name

    Returns:
    --------
    raw_decimated : mne.io.RawArray
        Decimated data
    """
    # 1. Loading of raw data

    print(f"Original sampling frequency : {raw.info['sfreq']} Hz")
    new_freq = sfreq/decimation_factor
    print(f"New sampling frequency will be : {new_freq} Hz")

    
    h_freq = int((new_freq/3)-2) # h_freq needs to be lower than 1/3 of new_freq

    # 2. Low-pass Filter
    print("\n=== Application du filtre passe-bas ===")
    raw_filtered = raw.copy().filter(
        l_freq=None,
        h_freq=h_freq,      
        method='iir',
        iir_params=dict(
            order=4,
            ftype='butter'
        ),
        phase='zero'    # forward-backward filtering 
    )

    # 3. Decimation
    print("\n=== Data decimation===")
    raw_decimated = raw_filtered.copy().resample(new_freq)

    print("\n=== EVENTS ===")
    events_orig = mne.find_events(raw, stim_channel=stim_name)
    events_dec = mne.find_events(raw_decimated, stim_channel=stim_name)
    
    print("\n=== Labels Check ===")
    stim_idx = raw.ch_names.index(stim_name)
    stim_data = raw.get_data(picks=stim_idx)
    stim_data_d = raw_decimated.get_data(picks=stim_idx)
    unique_vals, counts = np.unique(stim_data[stim_data != 0], return_counts=True)
    unique_valsd, countsd = np.unique(stim_data_d[stim_data_d != 0], return_counts=True)
    print("Original:")
    for val, count in zip(unique_vals, counts):
        print(f"Value : {val}, Occurences count : {count}")
    print("Decimated:")
    for val, count in zip(unique_valsd, countsd):
        print(f"Value : {val}, Occurences count : {count}")

    # Validation
    print("\n=== Checking discrepancies between events ===")

    # Calculation of deviations for original data
    gaps_orig = np.diff(events_orig[:, 0]) / raw.info['sfreq']  # in seconds

    # Calculation of deviations for decimated data
    gaps_dec = np.diff(events_dec[:, 0]) / raw_decimated.info['sfreq']  # in seconds

    # Displaying deviation statistics
    print("\nTime between events (seconds):")
    print("Original:")
    print(f"  Min: {np.min(gaps_orig):.3f}s")
    print(f"  Max: {np.max(gaps_orig):.3f}s")
    print(f"  Mean: {np.mean(gaps_orig):.3f}s")
    print(f"  Standard deviation: {np.std(gaps_orig):.3f}s")

    print("\nDecimated:")
    print(f"  Min: {np.min(gaps_dec):.3f}s")
    print(f"  Max: {np.max(gaps_dec):.3f}s")
    print(f"  Mean: {np.mean(gaps_dec):.3f}s")
    print(f"  Standard deviation: {np.std(gaps_dec):.3f}s")

    # Display of the first 5 deviations for comparison
    print("\nComparison of the first 5 gaps:")
    print("N° | Original (s) | Decimated (s) | Diff (ms)")
    print("-" * 45)
    for i in range(min(5, len(gaps_orig))):
        diff_ms = (gaps_orig[i] - gaps_dec[i]) * 1000
        print(f"{i+1:2d} | {gaps_orig[i]:11.3f} | {gaps_dec[i]:10.3f} | {diff_ms:14.3f}")

    return raw_decimated