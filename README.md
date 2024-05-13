# File Monitor Tool

The `eyer.sh` script is a bash script that monitors a file for modifications and sends a notification when the file is modified. The script takes several optional parameters:

- `-f`: The path to the file(s) to monitor
- `-i`: The interval (in seconds) between checks for modifications (default: 5)
- `-n`: The ID of the [notify](https://github.com/projectdiscovery/notify) tool service to use
- `-up`: Specify the action to send the file when a file is updated
- `-filename`: Specify the name of the file

## Usage

To use the script, simply provide the path to the file(s) to monitor using the `-f` flag, and the ID of the [notify](https://github.com/projectdiscovery/notify) service to use using the `-n` flag. You can also optionally specify the interval between checks for modifications using the `-i` flag, the action to perform when a file is updated using the `-up` flag, and the name of the file using the `-filename` flag.

#### To monitor one file

```bash
./eyer.sh -f /path/to/file -n notify-id -i 10
```

#### To monitor multiple files

```bash
./eyer.sh -f /path/to/file1 -f /path/to/file2 -f /path/to/file3 -n notify-id -i 10
```

#### To monitor files and send updated file to discord

```bash
./eyer.sh -f /path/to/file1 -f /path/to/file2 -f /path/to/file3 -n notify-id -i 10 -up -filename "subdomains-of-hackerone"
```

For more details on usage and available options, you can run the script with the `-h` or `--help` flag.

```bash
./eyer.sh --help
```