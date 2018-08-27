"""
Installs Python dependencies using the pip tool.
See the requirements.txt file.
python -m pip install --upgrade -r ../tools/requirements.txt
"""

from common import *
import subprocess


def main():
    args = []
    if sys.executable.startswith("/usr/"):
        args.append("sudo")
    requirements = os.path.join(TOOLS_DIR, "requirements.txt")
    args.extend([sys.executable, "-m", "pip", "install", "--upgrade",
                 "-r", requirements])
    retcode = subprocess.call(args)
    sys.exit(retcode)


if __name__ == "__main__":
    main()
