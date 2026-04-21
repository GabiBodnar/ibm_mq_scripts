# IBM MQ Administration & Migration Toolbox

This repository is a collection of Bash scripts designed to simplify repetitive IBM MQ administration tasks and automate security migrations. 

These scripts serve as my personal practice field for learning Bash scripting and IBM MQ management. The code was developed through a collaborative process of AI-assisted generation and manual refinement, followed by testing in a dedicated practice environment.

## Scripts Overview

### 1. set_authrec.sh (Migration Tool)
The primary migration filter. It uses the output from `extr_obj_names.sh` to generate an `.mqsc` file. It filters old 'SET AUTHREC' commands from a source Queue Manager and keeps only those that correspond to objects existing on the destination manager.
- **Usage:** `./set_authrec.sh <ORIGIN_QM> <USER_ID|ALL> /path/to/DEST_QM_objects.tst`
- **Output:** A `.mqsc` file containing valid SET AUTHREC commands.
- **Key Feature:** Automatically preserves wildcard/generic profiles (e.g., `SYSTEM.**`).

### 2. extr_obj_names.sh (Extraction Tool)
Extracts a clean list of all existing objects (Queues and Channels) from a specific Queue Manager. This list is required as input for the `set_authrec.sh` script.
- **Usage:** `./extr_obj_names.sh <QMNAME>`
- **Output:** A `.tst` file containing clean object names.

### 3. channel_status.sh
Scans all channels and identifies those that are NOT in a 'RUNNING' state. Displays the results directly in the terminal for quick troubleshooting.
- **Usage:** `./channel_status.sh`

### 4. ssl_ciph.sh
Generates a comprehensive list of all channels across all Queue Managers hosted on the current server, specifically focusing on identifying configured SSL/TLS channels.
- **Usage:** `./ssl_ciph.sh`
- **Output:** A `.txt` file containing channel details.

### 5. change_cluster_parameter.sh
Automates the process of changing the cluster parameter for a specific channel to a desired value.
- **Usage:** `./change_cluster_parameter.sh <QMGR> <CLUSNAME>`

### 6. cluster_to_dummy.sh
A specialized utility to change a channel's cluster parameter to a placeholder value ('dummy').
- **Usage:** `./cluster_to_dummy.sh <QMNAME> <CLUSNAME>`

### 7. list_of_execution_groups.sh
Designed for environments using IBM Integration Bus (IIB) / ACE, this script lists all execution groups running on a specific Broker.
- **Usage:** `./list_of_execution_groups.sh <BROKER>`
- **Output:** A `.txt` file listing the execution groups.

## Migration Workflow

To migrate permissions between two Queue Managers:
1. **On Destination Server:** Run `extr_obj_names.sh` to catalog built objects.
2. **Transfer File:** Copy the generated `.tst` file to the Origin server.
3. **On Origin Server:** Run `set_authrec.sh`. It will match your old permission "keys" with the "doors" available on the new server.
4. **Final Step:** Apply the generated `.mqsc` file to your Destination Queue Manager using `runmqsc`.

## Requirements
- IBM MQ (tested on version 9.4)
- Bash or Korn shell
- 'mqm' user permissions
