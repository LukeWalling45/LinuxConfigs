
#!/usr/bin/env python3

import re
import subprocess

# Active pane brightness relative to terminal background
BRIGHTNESS = 0.03


def run(*args):
    return subprocess.check_output(
        args, universal_newlines=True
    ).strip()


def lighten(value, amount):
    return int(value + (255 - value) * amount + 0.5)


def main():
    # Find the default GNOME Terminal profile
    profile = run(
        "gsettings", "get",
        "org.gnome.Terminal.ProfilesList", "default"
    ).strip("'")

    schema = (
        "org.gnome.Terminal.Legacy.Profile:"
        f"/org/gnome/terminal/legacy/profiles:/:{profile}/"
    )

    # Read configured terminal background
    background = run(
        "gsettings", "get", schema, "background-color"
    )

    # Parse rgb(R,G,B)
    match = re.search(
        r"rgb\((\d+),\s*(\d+),\s*(\d+)\)",
        background
    )

    if not match:
        return

    rgb = [int(value) for value in match.groups()]

    # Calculate active background
    active = [
        lighten(value, BRIGHTNESS)
        for value in rgb
    ]

    color = "#{:02X}{:02X}{:02X}".format(*active)

    # Update tmux active pane background
    subprocess.run([
        "tmux", "set-option", "-gw",
        "window-active-style", f"bg={color}"
    ], check=True)


if __name__ == "__main__":
    main()

