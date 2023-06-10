# File Monitor Tool

The `eyer.sh` script is a bash script that monitors a file for modifications and sends a notification when the file is modified. The script takes three optional parameters:

- `-f`: The path to the file to monitor
- `-i`: The interval (in seconds) between checks for modifications (default: 5)
- `-n`: The ID of the [notify](https://github.com/projectdiscovery/notify) tool service to use

## Usage

To use the script, simply provide the path to the file to monitor using the `-f` flag, and the ID of the [notify](https://github.com/projectdiscovery/notify) to use using the `-n` flag. You can also optionally specify the interval between checks for modifications using the `-i` flag.

#### To monitor one file

```bash
./eyer.sh -f /path/to/file -n notify-id -i 10
```

#### To monitor multiable files

```bash
./eyer.sh -f /path/to/file1 -f /path/to/file2 -f /path/to/file3 -n notify-id -i 10
```
