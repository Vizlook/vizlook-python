import os
from dotenv import load_dotenv
from vizlook import AsyncVizlook

load_dotenv()


async def run_examples():
    vizlook = AsyncVizlook(api_key=os.environ.get("VIZLOOK_API_KEY"))

    print("============= non stream =============")
    response = await vizlook.answer(
        "how to be productive",
        need_transcription=True,
    )

    print("response with original API field name: ")
    print(response.to_dict())

    print("response with snake case field name: ")
    print(response.to_dict(use_api_field_name=False))

    print("get field value with snake case key from pydantic model: ")
    print(response.answer)

    print("============= stream =============")
    stream_response = await vizlook.stream_answer(
        "how to be productive",
        need_transcription=True,
    )
    answer = ""

    async for chunk in stream_response:
        # response with original field name
        chunk_dict = chunk.to_dict()
        chunk_type = chunk_dict.get("type")

        if chunk_type == "answer-chunk":
            answer += chunk_dict.get("data", "")
        if chunk_type == "data-citations":
            print("Citations: ", chunk_dict.get("data").get("citations"))
        if chunk_type == "data-cost":
            print("Cost: ", chunk_dict.get("data").get("dollarCost"))
        if chunk_type == "error":
            print("Error: ", chunk_dict.get("data").get("errorText"))

    print("Answer: ", answer)


if __name__ == "__main__":
    import asyncio

    asyncio.run(run_examples())
