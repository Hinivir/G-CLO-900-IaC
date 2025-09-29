// main.cpp
// Requires only crow_all.h (https://github.com/CrowCpp/Crow)
// Build: g++ -std=c++17 -O2 -pthread main.cpp -o rest-server

#include <crow_all.h>
#include <unordered_map>
#include <string>
#include <mutex>
#include <atomic>

struct Item {
    long id;
    std::string name;
    std::string description;

    crow::json::wvalue to_json() const {
        crow::json::wvalue x;
        x["id"] = id;
        x["name"] = name;
        x["description"] = description;
        return x;
    }
};

int main(int argc, char* argv[]) {
    crow::SimpleApp app;

    std::unordered_map<long, Item> db;
    std::mutex db_mutex;
    std::atomic<long> next_id{1};

    CROW_ROUTE(app, "/items").methods("GET"_method)([&](){
        crow::json::wvalue arr(crow::json::type::List);
        {
            std::lock_guard<std::mutex> lock(db_mutex);
            for (auto& [id, item] : db) {
                arr.push_back(item.to_json());
            }
        }
        return crow::response{arr};
    });

    CROW_ROUTE(app, "/items/<int>").methods("GET"_method)
    ([&](int id){
        std::lock_guard<std::mutex> lock(db_mutex);
        auto it = db.find(id);
        if (it == db.end())
            return crow::response(404, R"({"error":"not found"})");
        return crow::response{it->second.to_json()};
    });

    CROW_ROUTE(app, "/items").methods("POST"_method)
    ([&](const crow::request& req){
        auto body = crow::json::load(req.body);
        if (!body || !body.has("name"))
            return crow::response(400, R"({"error":"invalid json or missing 'name'})");

        long id = next_id.fetch_add(1);
        Item item{id, body["name"].s(), body.has("description") ? body["description"].s() : ""};

        {
            std::lock_guard<std::mutex> lock(db_mutex);
            db[id] = item;
        }

        auto res = crow::response{item.to_json()};
        res.code = 201;
        return res;
    });

    CROW_ROUTE(app, "/items/<int>").methods("PUT"_method)
    ([&](const crow::request& req, int id){
        auto body = crow::json::load(req.body);
        if (!body)
            return crow::response(400, R"({"error":"invalid json"})");

        std::lock_guard<std::mutex> lock(db_mutex);
        auto it = db.find(id);
        if (it == db.end())
            return crow::response(404, R"({"error":"not found"})");

        if (body.has("name")) it->second.name = body["name"].s();
        if (body.has("description")) it->second.description = body["description"].s();

        return crow::response{it->second.to_json()};
    });

    CROW_ROUTE(app, "/items/<int>").methods("DELETE"_method)
    ([&](int id){
        std::lock_guard<std::mutex> lock(db_mutex);
        auto it = db.find(id);
        if (it == db.end())
            return crow::response(404, R"({"error":"not found"})");

        db.erase(it);
        return crow::response(204);
    });

    unsigned short port = 18080;
    if (argc > 1) port = static_cast<unsigned short>(std::stoi(argv[1]));
    app.port(port).multithreaded().run();
}
