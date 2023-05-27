import argparse

# Define command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('binary_file', help='the path to the binary file')

# Parse command line arguments
args = parser.parse_args()

# Read binary file
with open(args.binary_file, 'rb') as f:
    binary_data = f.read()

# XOR binary data with 0x41 key
key = 0x41
xored_data = bytes([c ^ key for c in binary_data])

# Save XORed data as a PowerShell script file
with open('output.ps1', 'wb') as f:
    f.write(b'$xor_data = @(')
    f.write(b','.join([bytes(f'0x{b:02X}', 'utf-8') for b in xored_data]))
    f.write(b')')
