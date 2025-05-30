#include <chrono>
#include <cstdlib>
#include <iostream>
#include <nlohmann/json.hpp>
#include <sstream>
#include <thread>
#include <uWebSockets/App.h>

#include <grpcpp/grpcpp.h>
#include "part/part.hpp"

int main()
{
    uWS::App()
        .get("/",
             [](auto *res, auto *req)
             {
                 res->writeHeader("Content-Type", "text/plain")->end("OK");
             })
        .post("/events",
              [](auto *res, auto *req)
              {
                  try
                  {
                      res->onAborted([]()
                                     { std::cerr << "[HTTP] client aborted the request\n"; });
                      res->onData([res](std::string_view data, bool last)
                                  {
                  if (last) {
                    try {
                      nlohmann::json j = nlohmann::json::parse(data);
                      // Проверка обязательных атрибутов CloudEvents
                      if (j.contains("specversion") && j.contains("id") &&
                          j.contains("source") && j.contains("type")) {
                        res->writeStatus("200 OK")->end(call());
                      } else {
                        std::cout
                            << "Invalid CloudEvent: missing required attributes"
                            << std::endl;
                        res->writeStatus("400 Bad Request")
                            ->end("Missing required CloudEvent attributes");
                      }
                    }
                    catch (const std::exception &e)
                    {
                        std::cout << "Error parsing JSON: " << e.what()
                                  << std::endl;
                        res->writeStatus("400 Bad Request")->end("Invalid JSON");
                    }
                  } });
                  }
                  catch (const std::exception &e)
                  {
                      res->writeStatus("500 Internal Server Error")
                          ->writeHeader("Content-Type", "text/plain")
                          ->end("Failed to get random number");
                  }
              })
        .listen(8080,
                [](auto *token)
                {
                    if (token)
                    {
                        std::cout << "service listening on port 8080\n";
                    }
                    else
                    {
                        std::cerr << "Failed to listen on port 8080\n";
                    }
                })
        .run();
    return 0;
}
