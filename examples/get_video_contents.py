import os
from dotenv import load_dotenv
from vizlook import Vizlook

load_dotenv()


def run_examples():
    vizlook = Vizlook(api_key=os.environ.get("VIZLOOK_API_KEY"))

    response = vizlook.get_video_contents(
        "https://www.youtube.com/watch?v=QdBokRd2ahw",
        crawl_mode="Fallback",
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
