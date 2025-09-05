from typing import Optional
from ._version import __version__


class Vizlook:
    """The Vizlook class encapsulates the API's endpoints."""

    def __init__(
        self,
        api_key: Optional[str],
        base_url: str = "https://api.vizlook.com",
    ):
        if api_key is None:
            import os

            api_key = os.environ.get("VIZLOOK_API_KEY")
            if api_key is None:
                raise ValueError(
                    "The API key must be provided as an argument or as an environment variable (VIZLOOK_API_KEY)."
                )

        self.base_url = base_url
        self.headers = {
            "x-api-key": api_key,
            "User-Agent": f"vizlook-python-sdk {__version__}",
            "Content-Type": "application/json",
        }
