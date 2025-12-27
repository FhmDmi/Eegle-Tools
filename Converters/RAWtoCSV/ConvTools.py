import numpy as np
import mne
import pandas as pd
from shutil import copy2
import os

def decimate(raw, sfreq, decimation_factor, stim_name):
    
    """
    Decimate Raw data and display information for validation.

    Parameters:
    -----------
    raw : mne.io.Raw
        EEG data object
    sfreq : int 
        Base sampling rate or frequency (Hz)
    decimation_factor : int
        Decimation factor, must be an integer and the result
        of the new frequency needs to be an integer too
    stim_name : str
        Stim channel name

    Returns:
    --------
    raw_decimated : mne.io.Raw
        Decimated data
    """
    # 1. Loading of raw data

    print(f"Original sampling frequency: {raw.info['sfreq']} Hz")
    new_freq = sfreq / decimation_factor
    print(f"New sampling frequency will be: {new_freq} Hz")

    # h_freq needs to be lower than 1/3 of new_freq to avoid aliasing
    h_freq = int((new_freq / 3) - 2) 

    # 2. Low-pass Filter
    print("\n=== Applying Low-Pass Filter ===")
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
    print("\n=== Data Decimation ===")
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
        print(f"Value: {val}, Occurrence count: {count}")
    
    print("Decimated:")
    for val, count in zip(unique_valsd, countsd):
        print(f"Value: {val}, Occurrence count: {count}")

    # Validation
    print("\n=== Checking discrepancies between events ===")

    # Calculation of deviations for original data (in seconds)
    gaps_orig = np.diff(events_orig[:, 0]) / raw.info['sfreq']

    # Calculation of deviations for decimated data (in seconds)
    gaps_dec = np.diff(events_dec[:, 0]) / raw_decimated.info['sfreq']

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
    print("No. | Original (s) | Decimated (s) | Diff (ms)")
    print("-" * 45)
    for i in range(min(5, len(gaps_orig))):
        diff_ms = (gaps_orig[i] - gaps_dec[i]) * 1000
        print(f"{i+1:2d} | {gaps_orig[i]:11.3f} | {gaps_dec[i]:10.3f} | {diff_ms:14.3f}")

    return raw_decimated

def df_to_mne(df, sfreq):
    """
    Specifically designed for the brain invaders databases.

    Converts a CSV file into an MNE Raw object.
    
    This function expects a CSV where the first column is timestamps, 
    the last column is the stimulation/event data, and the middle 
    columns are EEG signals.
    """

    # Split columns
    eeg_data = df.iloc[:, 1:-1]   # EEG columns
    stim_data = df.iloc[:, -1]    # Last column (events)

    # Create channel names and types
    ch_names = [str(col) for col in eeg_data.columns] + ['STI']
    ch_types = ['eeg'] * len(eeg_data.columns) + ['stim']

    # Create MNE info structure
    info = mne.create_info(ch_names=ch_names, sfreq=sfreq, ch_types=ch_types)

    # Prepare data in MNE format (channels x time)
    data = np.vstack([
        eeg_data.T,
        stim_data.values[np.newaxis, :]
    ])
    
    # Initialize MNE Raw object
    raw = mne.io.RawArray(data, info)

    return raw


def rearrange(csv_num, source_folder, destination_folder):
    """
    Specifically designed for the bi2013a database.

    Rearranges specific X.csv files from each subject/session directory into 
    a centralized folder. This function ensures subject and session numbers 
    are formatted with leading zeros (e.g., subject_01).

    Args:
        csv_num (int): The index of the CSV file to extract (1, 2, 3, or 4).
        source_folder (str): Path to the directory containing all subject folders.
        destination_folder (str): Path to the target directory for renamed files.
    """
    # Create destination folder if it doesn't exist
    if not os.path.exists(destination_folder):
        os.makedirs(destination_folder)

    # Loop through all subject folders
    for subject_folder in os.listdir(source_folder):
        subject_path = os.path.join(source_folder, subject_folder)

        # Check if it is a directory
        if not os.path.isdir(subject_path):
            continue

        # Extract subject and session numbers
        if subject_folder.startswith("subject"):
            if "_session" in subject_folder:
                # Format: subject01_session01
                subject_num = int(subject_folder.split("_session")[0].replace("subject", ""))
                session_num = int(subject_folder.split("_session")[1])
            else:
                # Format: subject08, subject09, etc.
                subject_num = int(subject_folder.replace("subject", ""))
                session_num = 1  # Default to session 1 for subjects 8-24

            # Search for the Session subfolder
            for item in os.listdir(subject_path):
                if item.startswith("Session"):
                    session_path = os.path.join(subject_path, item)

                    # Locate the specific .csv file
                    csv_file = os.path.join(session_path, f"{csv_num}.csv")
                    if os.path.exists(csv_file):
                        # Create a standardized filename
                        new_name = f"subject_{subject_num:02d}_session_{session_num:02d}.csv"
                        destination_path = os.path.join(destination_folder, new_name)

                        # Copy and rename the file
                        copy2(csv_file, destination_path)
                        print(f"Copied: {csv_file} -> {destination_path}")

    print(f"\nRearrangement completed. Files are located in: {destination_folder}")


def extract_subject_data(csv_file_path, subject_number):
    """
    Extracts individual subject data from a shared bi2014b solo session CSV.
    Splits the recording into timestamps, 32 electrodes, and a stim channel.
    """
    if subject_number not in [1, 2]:
        raise ValueError("Subject number must be 1 or 2")

    df = pd.read_csv(csv_file_path, header=None)

    # Subject 1: cols 1-32 | Subject 2: cols 33-64
    if subject_number == 1:
        electrode_cols = list(range(1, 33))
    else:
        electrode_cols = list(range(33, 65))

    timestamps = df.iloc[:, 0]               # First column
    eeg_data = df.iloc[:, electrode_cols] * 1e-6 # Convert EEG columns to Volts
    stim_data = df.iloc[:, -1]                # Last column (stimulation)

    # Concatenate all components along the column axis
    extracted_data = pd.concat([timestamps, eeg_data, stim_data], axis=1)

    # Set column names: [''] (timestamp), ['1'-'32'] (EEG), ['33'] (STI)
    extracted_data.columns = [''] + [str(i) for i in range(1, 33)] + ['33']

    return extracted_data