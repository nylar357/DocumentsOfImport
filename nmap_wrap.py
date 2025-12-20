#!/usr/bin/env python3

## Created by nylar ##
## github.com/nylar357 ##
## linkedin.com/brycezg ##

import sys
import socket
import subprocess
import tempfile
import shutil
import argparse
import os

PROXY_HOST = "Proxy Address Here"
PROXY_PORT = Proxy_Port_here

def find_proxychains_executable():
    """Finds the 'proxychains' or 'proxychains4' executable in the system's PATH."""
    for name in ["proxychains4", "proxychains-ng", "proxychains"]:
        if shutil.which(name):
            return name
    return None

def resolve_proxy_ip(host):
    """Resolves the given hostname to an IPv4 address."""
    try:
        # Use getaddrinfo for robust resolution
        # AF_INET restricts to IPv4
        addr_info = socket.getaddrinfo(host, None, socket.AF_INET)
        # Return the IP address from the first result
        return addr_info[0][4][0]
    except socket.gaierror as e:
        print(f"[-] Error: Could not resolve proxy hostname '{host}': {e}", file=sys.stderr)
        sys.exit(1)
    except IndexError:
        print(f"[-] Error: No IPv4 address found for proxy hostname '{host}'", file=sys.stderr)
        sys.exit(1)

def main():
    """
    A wrapper to run nmap through a SOCKS5 proxy that uses a DNS hostname.
    """
    parser = argparse.ArgumentParser(
        description="A wrapper to run nmap through a DNS-based SOCKS5 proxy like IPRoyal.",
        usage="%(prog)s [normal nmap usage]"
    )
    # This will capture all arguments meant for nmap
    parser.add_argument('nmap_args', nargs=argparse.REMAINDER)
    
    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    args = parser.parse_args()

    # 1. Check for proxychains
    proxychains_exec = find_proxychains_executable()
    if not proxychains_exec:
        print("[-] Error: 'proxychains' or 'proxychains4' is not installed.", file=sys.stderr)
        print("[-] Please install it to use this script (e.g., 'sudo apt install proxychains-ng').", file=sys.stderr)
        sys.exit(1)
    
    # 2. Resolve the proxy IP address
    print(f"[+] Resolving proxy host: {PROXY_HOST}...")
    proxy_ip = resolve_proxy_ip(PROXY_HOST)
    print(f"[+] Proxy IP resolved to: {proxy_ip}")

    # 3. Create a temporary proxychains configuration file
    conf_content = f"""
[ProxyList]
# type host port
socks5 {proxy_ip} {PROXY_PORT}
"""
    try:
        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix=".conf") as temp_conf:
            temp_conf_path = temp_conf.name
            temp_conf.write(conf_content)
        
        print(f"[+] Temporary proxychains config created at: {temp_conf_path}")

        # 4. Construct and run the nmap command
        command = [proxychains_exec, "-f", temp_conf_path, "nmap"] + args.nmap_args
        
        print(f"[+] Executing command: {' '.join(command)}")
        print("-" * 40)
        
        # We use Popen and communicate to stream the output in real-time
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        
        # Stream stdout
        if process.stdout:
            for line in iter(process.stdout.readline, ''):
                print(line, end='')
        
        # Capture and display stderr after the process finishes
        stdout, stderr = process.communicate()
        if stderr:
            print(stderr, file=sys.stderr)

        print("-" * 40)
        
        if process.returncode 
