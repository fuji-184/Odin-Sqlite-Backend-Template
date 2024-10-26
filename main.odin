package main

import "core:fmt"
import "core:log"
import "core:net"
import "core:time"
import http "libs/odin-http"
import sqlite "src"

main :: proc() {

	sqlite.db_check(sqlite.db_init("fuji.db"))
	defer sqlite.db_check(sqlite.db_destroy())

	sqlite.db_cache_cap(64)
	defer sqlite.db_cache_destroy()

	sqlite.db_execute_simple(`DROP TABLE IF EXISTS tes`)

	sqlite.db_execute_simple(`CREATE TABLE IF NOT EXISTS tes(
		id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		name VARCHAR(30)
	)`)

	sqlite.db_insert("tes (name)", "fuji")

	// above turns into
	// stmt := db_cache_prepare(`INSERT INTO tes (name) 
	// 		VALUES (?1,)
	// 	`) 
	// db_bind("fuji",)
	// db_bind_run(stmt)

	sqlite.db_execute("UPDATE tes SET number = ?1", 3)

	Tes :: struct {
		id: i32,
		name: string,
	}

	p1: Tes
	sqlite.db_select("FROM tes WHERE id = ?1", p1, 1)
	fmt.println(p1)

    context.logger = log.create_console_logger(.Info)

    s: http.Server

    http.server_shutdown_on_interrupt(&s)

    router: http.Router
    http.router_init(&router)
    defer http.router_destroy(&router)

    http.route_get(&router, "/", http.handler(root_handler))

    routed := http.router_handler(&router)

    log.info("Listening on http://localhost:6969")

    err := http.listen_and_serve(&s, routed, net.Endpoint{address = net.IP4_Loopback, port = 6969})
    fmt.assertf(err == nil, "server stopped with error: %v", err)
	// return 0
}

root_handler :: proc(req: ^http.Request, res: ^http.Response) {
    http.respond_json(res, "hello")
}
