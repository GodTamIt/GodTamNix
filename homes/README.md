# Directory Layout

The `homes/` directory is organized to separate system-specific configurations
from shared user settings:

- **`<arch>/<username>@<hostname>`**: Contains configurations specific to a user
  on a particular architecture and host.
- **`users/<username>`**: Contains "common" configurations for a user that are
  shared across multiple systems.
