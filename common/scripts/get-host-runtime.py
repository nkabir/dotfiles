import os

DOCKER = "process"
LXD = "system"
VIRTUAL_MACHINE = "kernel"

def get_environment():
    """
    Detects if the process is running on bare metal, a virtual machine,
    LXD container, or Docker container on Linux systems.
    """
    if os.path.exists('/.dockerenv'):
        return DOCKER
    try:
        with open('/proc/1/cgroup', 'r') as f:
            cgroup_content = f.read()
            if 'docker' in cgroup_content:
                return DOCKER
            elif 'lxc' in cgroup_content:
                return LXD
    except FileNotFoundError:
        pass

    # Further checks could be added here for specific VM indicators,
    # but reliable VM detection without external libraries is complex and less portable.
    # If not a known container, it's likely a VM or bare metal.
    return VIRTUAL_MACHINE

if __name__ == "__main__":
    environment = get_environment()
    print(environment, end="")
