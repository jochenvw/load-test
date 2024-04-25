import azure.functions as func
import logging
import random
import time

app = func.FunctionApp()

@app.route(route="slow_response", auth_level=func.AuthLevel.ANONYMOUS)
def slow_response(req: func.HttpRequest) -> func.HttpResponse:
    sleep_time = random.randint(3000, 7000)
    logging.info(f"Processing request. Simulating processing time of {sleep_time} ms ...")
    time.sleep(sleep_time / 1000)

    return func.HttpResponse(
             f"Done processing request - that took {sleep_time} ms..",
             status_code=200
        )
