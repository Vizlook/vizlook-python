import os
from datetime import datetime
from dotenv import load_dotenv
from vizlook import Vizlook

load_dotenv()


def run_examples():
    vizlook = Vizlook(api_key=os.environ.get("VIZLOOK_API_KEY"))

    response = vizlook.search(
        "how to be productive",
        max_results=5,
        start_published_date="2025-08-19T15:01:36.000Z",
        end_published_date=int(datetime.now().timestamp() * 1000),
        include_transcription=True,
        include_summary=True,
    )

    print("response with original API field name: ")
    print(response.to_dict())

    print("response with snake case field name: ")
    print(response.to_dict(use_api_field_name=False))

    print("get field value with snake case key from pydantic model: ")
    print(response.results)


run_examples()
