# wow-way

A minimal World of Warcraft addon that adds a `/way x,y` slash command,
dropping a world/minimap waypoint pin using the same `C_Map` user-waypoint
API that powers retail's built-in map-pin feature.

## Features

- `/way x,y` - drop a waypoint pin on your current map at the given
  coordinates (accepts `45.2,67.8`, `45.2 67.8`, or 0-1 fractions).
- `/way clear` (or `/way off`) - clear the current waypoint.
- Only registers `/way` if no other addon (e.g. TomTom) already owns that
  slash command, so it's safe to run alongside other waypoint addons.
- Listed under **Map** in the AddOns list with a map icon.

## Installation

Install via CurseForge, Wago, or manually by downloading the latest release
from GitHub.

## Development

### Creating a Release

This addon uses BigWigs Packager for automated releases. To create a new release:

1. Update the version in your local repository
2. Create and push a git tag:
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
3. The GitHub Actions workflow will automatically:
   - Package the addon
   - Create a GitHub release
   - Upload to CurseForge (if `CF_API_KEY` secret is configured)
   - Upload to Wago (if `WAGO_API_TOKEN` secret is configured)

### Required Secrets

To enable automatic uploads, configure these repository secrets:

- `CF_API_KEY` - CurseForge API key for uploading to CurseForge
- `WAGO_API_TOKEN` - Wago API token for uploading to Wago Addons

The `GITHUB_TOKEN` is automatically provided by GitHub Actions.

## License

All Rights Reserved
